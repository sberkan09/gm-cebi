"""Translation pipeline CLI.

  python -m gmcebi_pipeline.translate queue  [--pilot | --datasets a,b]
      Write untranslated segments to translations/queue/batch_NNN.jsonl,
      each line carrying the glossary terms and known titles it needs.
  python -m gmcebi_pipeline.translate api    [--model ...]
      Translate queued batches through the Anthropic Messages API
      (needs ANTHROPIC_API_KEY). Writes translations/out/batch_NNN.jsonl.
  python -m gmcebi_pipeline.translate import FILE... --engine NAME
      QC every {"key","tr"} line and store it in translations/tm.jsonl.
  python -m gmcebi_pipeline.translate qc
      Re-run QC on the whole memory (after a glossary change).
  python -m gmcebi_pipeline.translate prune
      Drop machine translations whose source sentence disappeared (after a re-parse).
  python -m gmcebi_pipeline.translate review
      Write translations/review_queue.csv (source and target side by side).
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
import urllib.request
from pathlib import Path

from .glossary import Glossary, build_title_map
from .qc import check_segment
from .segments import record_segments, segment_key
from .tm import TM, Entry

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "data" / "source"
TRANS = ROOT / "translations"
PROMPT = ROOT / "prompts" / "translate_tr.md"
PILOT = ROOT / "pilot.json"
BATCH_SIZE = 120


def load_dataset(name: str) -> list[dict]:
    return json.loads((SOURCE / f"{name}.json").read_text(encoding="utf-8"))


def pilot_scope() -> dict[str, list[str] | None]:
    """{dataset: [ids] or None for all}."""
    return json.loads(PILOT.read_text(encoding="utf-8"))


def scoped_records(scope: dict[str, list[str] | None]) -> dict[str, list[dict]]:
    out = {}
    for ds, ids in scope.items():
        recs = load_dataset(ds)
        if ids is not None:
            wanted = set(ids)
            recs = [r for r in recs if r["id"] in wanted]
            missing = wanted - {r["id"] for r in recs}
            if missing:
                raise SystemExit(f"{ds}: unknown ids {sorted(missing)}")
        out[ds] = recs
    return out


def title_map(tm: TM, glossary: Glossary) -> dict[str, str]:
    """English title → Turkish title, from the glossary and translated record names."""
    names = []
    for ds_file in SOURCE.glob("*.json"):
        if ds_file.name.startswith("_"):
            continue
        for r in json.loads(ds_file.read_text(encoding="utf-8")):
            tr = tm.lookup_tr(r["name"], lambda en, ds=ds_file.stem: segment_key(en, ds))
            if tr:
                names.append((ds_file.stem, r["name"], tr))
    return build_title_map(glossary, names)


def cmd_queue(args) -> None:
    glossary = Glossary.load()
    tm = TM()
    scope = pilot_scope() if args.pilot else {d: None for d in args.datasets.split(",")}
    titles = title_map(tm, glossary)
    pending: dict[str, dict] = {}
    for ds, recs in scoped_records(scope).items():
        for r in recs:
            for seg in record_segments(r, ds):
                e = tm.get(seg.key)
                if e and e.tr and e.status != "rejected":
                    continue
                item = pending.setdefault(seg.key, {"key": seg.key, "en": seg.en, "refs": [], "terms": [],
                                                    "ds": ds if seg.ns else ""})
                if len(item["refs"]) < 3:
                    item["refs"].append(f"{ds}/{seg.ref}")
    for item in pending.values():
        item["terms"] = [{"en": t.en, "tr": t.tr} for t in glossary.terms_in(item["en"])]
        refs = [t for t in titles
                if (t.startswith("*") and f"{t}*" in item["en"]) or (not t.startswith("*") and f"“{t}" in item["en"])]
        item["titles"] = {t: titles[t] for t in refs}
    # Segments that are exactly a glossary term are filled from the glossary.
    prefer = {"spells": "büyü adı", "conditions": "durum"}
    auto = []
    for k, it in list(pending.items()):
        bullet = it["en"].startswith("- ")
        word = it["en"][2:] if bullet else it["en"]
        cands = [t for t in glossary.terms if t.en in (word, f"{word} [Action]")]
        if not cands:
            continue
        cands.sort(key=lambda t: t.category != prefer.get(it["ds"], t.category))
        cands = [t for t in cands if t.category not in ("bölüm",)] or cands
        if it["ds"] != "spells" and cands[0].category == "büyü adı":
            continue
        pending.pop(k)
        auto.append(k)
        tm.put(Entry(key=k, en=it["en"], tr=("- " if bullet else "") + cands[0].tr, engine="glossary",
                     refs=it["refs"]))
    for it in pending.values():
        it.pop("ds", None)
    if auto:
        tm.save()
        print(f"{len(auto)} segments filled from glossary")
    qdir = TRANS / "queue"
    qdir.mkdir(parents=True, exist_ok=True)
    for old in qdir.glob("batch_*.jsonl"):
        old.unlink()
    items = list(pending.values())
    for b in range(0, len(items), BATCH_SIZE):
        path = qdir / f"batch_{b // BATCH_SIZE:03d}.jsonl"
        path.write_text("\n".join(json.dumps(x, ensure_ascii=False) for x in items[b:b + BATCH_SIZE]) + "\n",
                        encoding="utf-8")
    print(f"{len(items)} segments in {(len(items) + BATCH_SIZE - 1) // BATCH_SIZE} batches → {qdir}")


def _api_translate(batch: list[dict], model: str) -> list[dict]:
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        raise SystemExit("ANTHROPIC_API_KEY is not set; use the import path instead.")
    body = {
        "model": model,
        "max_tokens": 16000,
        "system": PROMPT.read_text(encoding="utf-8"),
        "messages": [{"role": "user", "content": "\n".join(json.dumps(x, ensure_ascii=False) for x in batch)}],
    }
    req = urllib.request.Request(
        os.environ.get("ANTHROPIC_BASE_URL", "https://api.anthropic.com") + "/v1/messages",
        data=json.dumps(body).encode(), method="POST",
        headers={"x-api-key": api_key, "anthropic-version": "2023-06-01", "content-type": "application/json"})
    with urllib.request.urlopen(req, timeout=600) as resp:
        data = json.loads(resp.read())
    text = "".join(c.get("text", "") for c in data["content"])
    out = []
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("{"):
            out.append(json.loads(line))
    return out


def cmd_api(args) -> None:
    odir = TRANS / "out"
    odir.mkdir(parents=True, exist_ok=True)
    for path in sorted((TRANS / "queue").glob("batch_*.jsonl")):
        batch = [json.loads(x) for x in path.read_text(encoding="utf-8").splitlines() if x.strip()]
        res = _api_translate(batch, args.model)
        (odir / path.name).write_text("\n".join(json.dumps(x, ensure_ascii=False) for x in res) + "\n",
                                      encoding="utf-8")
        print(f"{path.name}: {len(res)}/{len(batch)}")


def _all_source_by_key() -> dict[str, tuple[str, list[str]]]:
    out: dict[str, tuple[str, list[str]]] = {}
    for ds_file in sorted(SOURCE.glob("*.json")):
        if ds_file.name.startswith("_"):
            continue
        for r in json.loads(ds_file.read_text(encoding="utf-8")):
            for seg in record_segments(r, ds_file.stem):
                en, refs = out.setdefault(seg.key, (seg.en, []))
                if len(refs) < 3:
                    refs.append(f"{ds_file.stem}/{seg.ref}")
    return out


def cmd_import(args) -> None:
    glossary = Glossary.load()
    tm = TM()
    src = _all_source_by_key()
    titles = title_map(tm, glossary)
    n = bad = 0
    for f in args.files:
        for line in Path(f).read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            d = json.loads(line)
            if d["key"] not in src:
                print(f"unknown key {d['key']}", file=sys.stderr)
                continue
            en, refs = src[d["key"]]
            issues = check_segment(en, d["tr"], glossary, titles)
            tm.put(Entry(key=d["key"], en=en, tr=d["tr"].strip(), status=d.get("status", "machine"),
                         engine=args.engine, qc=issues, refs=refs))
            n += 1
            bad += bool(issues)
    tm.save()
    print(f"imported {n}, with QC findings: {bad}")


def cmd_qc(_args) -> None:
    glossary = Glossary.load()
    tm = TM()
    titles = title_map(tm, glossary)
    bad = 0
    for e in tm.entries.values():
        e.qc = check_segment(e.en, e.tr, glossary, titles)
        bad += bool(e.qc)
    tm.save()
    print(f"{len(tm.entries)} entries, {bad} with QC findings")


def cmd_prune(_args) -> None:
    """Drop machine translations whose English segment no longer exists in the source."""
    tm = TM()
    live = _all_source_by_key()
    orphans = [k for k, e in tm.entries.items() if k not in live and e.status != "reviewed"]
    for k in orphans:
        del tm.entries[k]
    tm.save()
    print(f"pruned {len(orphans)} orphaned entries")


def cmd_review(_args) -> None:
    tm = TM()
    path = TRANS / "review_queue.csv"
    rows = [e for e in tm.entries.values() if e.status != "reviewed"]
    rows.sort(key=lambda e: (not e.qc, e.refs[0] if e.refs else ""))
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["key", "status", "qc", "ref", "en", "tr", "decision", "tr_fixed"])
        for e in rows:
            w.writerow([e.key, e.status, " | ".join(e.qc), e.refs[0] if e.refs else "", e.en, e.tr, "", ""])
    print(f"{len(rows)} rows → {path}")


def cmd_apply_review(args) -> None:
    """Fold a filled review_queue.csv back into the memory.

    decision: ok → reviewed as is; fix → reviewed with tr_fixed; reject → rejected.
    """
    glossary = Glossary.load()
    tm = TM()
    titles = title_map(tm, glossary)
    with open(args.file, encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            e = tm.get(row["key"])
            dec = row["decision"].strip().lower()
            if not e or not dec:
                continue
            if dec == "fix" and row["tr_fixed"].strip():
                e.tr = row["tr_fixed"].strip()
            if dec in ("ok", "fix"):
                e.status, e.engine = "reviewed", f"human:{args.reviewer}"
            elif dec == "reject":
                e.status = "rejected"
            e.qc = check_segment(e.en, e.tr, glossary, titles)
    tm.save()


def main(argv=None) -> None:
    ap = argparse.ArgumentParser(prog="translate")
    sub = ap.add_subparsers(dest="cmd", required=True)
    q = sub.add_parser("queue")
    q.add_argument("--pilot", action="store_true")
    q.add_argument("--datasets", default="")
    a = sub.add_parser("api")
    a.add_argument("--model", default="claude-opus-5-5")
    i = sub.add_parser("import")
    i.add_argument("files", nargs="+")
    i.add_argument("--engine", required=True)
    sub.add_parser("qc")
    sub.add_parser("prune")
    sub.add_parser("review")
    r = sub.add_parser("apply-review")
    r.add_argument("file")
    r.add_argument("--reviewer", required=True)
    args = ap.parse_args(argv)
    {"queue": cmd_queue, "api": cmd_api, "import": cmd_import, "qc": cmd_qc,
     "review": cmd_review, "prune": cmd_prune, "apply-review": cmd_apply_review}[args.cmd](args)


if __name__ == "__main__":
    main()
