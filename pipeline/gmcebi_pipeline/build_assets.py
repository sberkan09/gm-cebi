"""English source + translation memory → assets/data/*.json for the app.

Each dataset file looks like:

  {"dataset": "spells", "schema": 1, "count": 339, "tr_complete": 50,
   "records": [{"id": "...", "en": {...}, "tr": {...} | null,
                "tr_status": "complete" | "partial" | "none"}]}

`tr` is a full copy of the record with every translated field replaced;
untranslated fields keep their English value (the app shows a per-field
fallback marker when tr_status is "partial").
"""

from __future__ import annotations

import json
import re
from pathlib import Path

from .glossary import Glossary, build_title_map
from .license import find_terms
from .parse import RUNIN_RE
from .segments import apply_translation
from .tm import TM

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "data" / "source"
ASSETS = ROOT.parent / "assets" / "data"
SIZE_BUDGET = 10 * 1024 * 1024
SCHEMA_VERSION = 1
HARD_QC = {"dice", "numbers", "markup", "product-identity", "empty"}

ATTRIBUTION = (
    "This work includes material from the System Reference Document 5.2.1 (“SRD 5.2.1”) by "
    "Wizards of the Coast LLC, available at https://www.dndbeyond.com/srd. The SRD 5.2.1 is "
    "licensed under the Creative Commons Attribution 4.0 International License, available at "
    "https://creativecommons.org/licenses/by/4.0/legalcode."
)

DATASETS = ["rules_glossary", "conditions", "spells", "monsters", "classes", "subclasses", "species",
            "backgrounds", "feats", "equipment", "weapon_properties", "weapon_mastery"]


class _Mapper:
    """Deterministic glossary mapping for enum-like fields."""

    def __init__(self, glossary: Glossary):
        self.by_cat: dict[tuple[str, str], str] = {}
        self.any: dict[str, str] = {}
        for t in glossary.terms:
            self.by_cat.setdefault((t.category, t.en), t.tr)
            self.any.setdefault(t.en, t.tr)

    def map(self, en: str, *cats: str) -> str:
        for c in cats:
            if (c, en) in self.by_cat:
                return self.by_cat[(c, en)]
        return self.any.get(en, en)


def _post_tr(ds: str, en: dict, tr: dict, mapper: _Mapper, titles: dict[str, str]) -> None:
    if ds == "spells":
        tr["school"] = mapper.map(en["school"], "büyü okulu")
        tr["classes"] = [mapper.map(c, "sınıf") for c in en["classes"]]
    if "tags" in en:
        tags = {"Condition": "Durum", "Action": "Eylem", "Hazard": "Tehlike",
                "Area of Effect": "Etki Alanı", "Attitude": "Tavır"}
        tr["tags"] = [tags.get(t, mapper.map(t)) for t in en["tags"]]
    if "see_also" in en:
        tr["see_also"] = [titles.get(s, s) for s in en["see_also"]]
    if ds == "conditions":
        effects = []
        for b in tr.get("blocks", []):
            m = RUNIN_RE.match(b.get("text") or "") if b.get("type") == "p" else None
            if m:
                effects.append({"name": m.group("name").strip().rstrip("."), "text": m.group("text").strip()})
        tr["effects"] = effects


def build(out_dir: Path = ASSETS) -> dict[str, dict]:
    glossary = Glossary.load()
    tm = TM()
    mapper = _Mapper(glossary)
    out_dir.mkdir(parents=True, exist_ok=True)
    names: list[tuple[str, str, str]] = []
    loaded = {ds: json.loads((SOURCE / f"{ds}.json").read_text(encoding="utf-8")) for ds in DATASETS}

    def lookup(k: str) -> str | None:
        e = tm.get(k)
        if not e or not e.tr or e.status == "rejected":
            return None
        # Hard QC failures (wrong numbers/dice, broken markup, product identity) never ship;
        # term and wording warnings ship but stay in the review queue.
        if e.status != "reviewed" and any(q.split(":")[0] in HARD_QC for q in e.qc):
            return None
        return e.tr

    # First pass: translated names feed the cross-reference title map.
    translated: dict[str, list[tuple[dict, dict | None, str]]] = {}
    for ds, recs in loaded.items():
        rows = []
        for r in recs:
            tr, done, missing = apply_translation(r, lookup, ds)
            # Records only touched by shared short segments ("Action", "60 feet")
            # are not worth shipping as Turkish yet: require a translated name and
            # at least 80% of the record's segments.
            if done == 0 or tr["name"] == r["name"] and missing or done < 0.8 * (done + missing):
                rows.append((r, None, "none"))
                continue
            if tr["name"] != r["name"]:
                names.append((ds, r["name"], tr["name"]))
            rows.append((r, tr, "complete" if missing == 0 else "partial"))
        translated[ds] = rows

    titles = build_title_map(glossary, names)
    summary: dict[str, dict] = {}
    total = 0
    for ds, rows in translated.items():
        records = []
        for en, tr, status in rows:
            if tr is not None:
                _post_tr(ds, en, tr, mapper, titles)
            records.append({"id": en["id"], "en": en, "tr": tr, "tr_status": status})
        payload = {
            "dataset": ds, "schema": SCHEMA_VERSION, "count": len(records),
            "tr_complete": sum(r["tr_status"] == "complete" for r in records),
            "tr_partial": sum(r["tr_status"] == "partial" for r in records),
            "records": records,
        }
        text = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
        hits = find_terms(text)
        if hits:
            raise SystemExit(f"{ds}: product-identity terms in output: {hits}")
        path = out_dir / f"{ds}.json"
        path.write_text(text, encoding="utf-8")
        size = path.stat().st_size
        total += size
        summary[ds] = {k: payload[k] for k in ("count", "tr_complete", "tr_partial")} | {"bytes": size}

    gl = [{"id": t.id, "en": t.en, "tr": t.tr, "category": t.category, "status": t.status}
          for t in glossary.terms]
    gpath = out_dir / "glossary.json"
    gpath.write_text(json.dumps(gl, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    total += gpath.stat().st_size
    manifest = {
        "schema": SCHEMA_VERSION,
        "source": "SRD 5.2.1",
        "license": "CC-BY-4.0",
        "attribution": ATTRIBUTION,
        "datasets": summary,
        "total_bytes": total,
    }
    (out_dir / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=1) + "\n",
                                           encoding="utf-8")
    if total > SIZE_BUDGET:
        raise SystemExit(f"asset size {total} exceeds budget {SIZE_BUDGET}")
    return manifest


def main() -> None:
    m = build()
    for ds, s in m["datasets"].items():
        print(f"{ds:20s} {s['count']:4d} records  tr complete {s['tr_complete']:4d}  partial {s['tr_partial']:4d}"
              f"  {s['bytes'] / 1024:7.1f} KB")
    print(f"total {m['total_bytes'] / 1024 / 1024:.2f} MB (budget 10 MB)")


if __name__ == "__main__":
    main()


__all__ = ["build", "ATTRIBUTION", "re"]
