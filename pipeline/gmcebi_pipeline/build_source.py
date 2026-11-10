"""SRD PDF -> English structured JSON (pipeline/data/source/*.json)."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from . import parse
from .extract import load_lines
from .fetch import DEFAULT_PATH, ensure_pdf
from .license import check_product_identity
from .models import Record

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "data" / "source"

# Known extraction artefacts in the PDF text (a superscript fraction read as digits), and
# trademarks / product names the SRD text itself mentions: the app never shows them
# (license.py), so the sentence is made neutral. The result is a modified work (CC-BY 4.0
# notice in lib/app_info.dart).
TEXT_FIXUPS = {
    "holds up to 11/2 pints": "holds up to 1½ pints",
    "to advance the worship of Tiamat,": "to advance the worship of an evil dragon god,",
    "Dragon deities such as Tiamat are unaffected": "Dragon deities are unaffected",
    "The three main pillars of D&D play are": "The three main pillars of play are",
    "each time you sit down to play D&D)": "each time you sit down to play)",
    "seasoned D&D players": "seasoned players",
    "a yuan-ti with a snakelike tail": "a creature with a snakelike tail",
}


def _fixup(rec: Record) -> Record:
    raw = json.dumps(rec.model_dump(mode="json", exclude_none=True), ensure_ascii=False)
    fixed = raw
    for bad, good in TEXT_FIXUPS.items():
        fixed = fixed.replace(bad, good)
    return rec if fixed == raw else type(rec).model_validate(json.loads(fixed))


def build(pdf: Path) -> dict[str, list[Record]]:
    return {name: [_fixup(r) for r in recs] for name, recs in _parse(pdf).items()}


def _parse(pdf: Path) -> dict[str, list[Record]]:
    lines = load_lines(pdf)
    rules, conditions = parse.parse_glossary(lines)
    classes, subclasses = parse.parse_classes(lines)
    backgrounds, species = parse.parse_origins(lines)
    equipment, props, masteries = parse.parse_equipment(lines)
    return {
        "rules_glossary": rules,
        "conditions": conditions,
        "spells": parse.parse_spells(lines),
        "monsters": parse.parse_monsters(lines),
        "classes": classes,
        "subclasses": subclasses,
        "species": species,
        "backgrounds": backgrounds,
        "feats": parse.parse_feats(lines),
        "equipment": equipment,
        "weapon_properties": props,
        "weapon_mastery": masteries,
        "magic_items": parse.parse_magic_items(lines),
        "rules": parse.parse_rule_sections(lines),
    }


def write(datasets: dict[str, list[Record]], out: Path = OUT) -> dict[str, int]:
    out.mkdir(parents=True, exist_ok=True)
    counts = {}
    for name, recs in datasets.items():
        ids = [r.id for r in recs]
        dupes = {i for i in ids if ids.count(i) > 1}
        if dupes:
            raise SystemExit(f"{name}: duplicate ids {sorted(dupes)}")
        payload = [r.model_dump(mode="json", exclude_none=True) for r in recs]
        (out / f"{name}.json").write_text(json.dumps(payload, ensure_ascii=False, indent=1) + "\n")
        counts[name] = len(recs)
    (out / "_warnings.json").write_text(json.dumps(parse.WARNINGS, ensure_ascii=False, indent=1) + "\n")
    return counts


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--pdf", type=Path, default=DEFAULT_PATH)
    args = ap.parse_args()
    data = build(ensure_pdf(args.pdf))
    problems = check_product_identity(OUT.parent, data)
    if problems:
        raise SystemExit("Product-identity terms found:\n" + "\n".join(problems))
    for k, v in write(data).items():
        print(f"{k:20s} {v}")


if __name__ == "__main__":
    main()
