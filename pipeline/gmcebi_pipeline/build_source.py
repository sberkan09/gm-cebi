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


def build(pdf: Path) -> dict[str, list[Record]]:
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
