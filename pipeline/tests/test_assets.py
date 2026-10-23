import json
from pathlib import Path

import pytest

ASSETS = Path(__file__).resolve().parents[2] / "assets" / "data"


@pytest.mark.skipif(not (ASSETS / "manifest.json").exists(), reason="assets not built")
def test_manifest_and_budget():
    m = json.loads((ASSETS / "manifest.json").read_text(encoding="utf-8"))
    assert m["license"] == "CC-BY-4.0"
    assert m["attribution"].startswith("This work includes material from the System Reference Document 5.2.1")
    size = sum(p.stat().st_size for p in ASSETS.glob("*.json") if p.name != "manifest.json")
    assert size < 10 * 1024 * 1024


@pytest.mark.skipif(not (ASSETS / "manifest.json").exists(), reason="assets not built")
def test_pilot_translations_present():
    conds = json.loads((ASSETS / "conditions.json").read_text(encoding="utf-8"))
    assert all(r["tr"] is not None for r in conds["records"])
    blinded = next(r for r in conds["records"] if r["id"] == "blinded")
    assert blinded["tr"]["name"] == "Kör"
    assert blinded["tr"]["tags"] == ["Durum"]


@pytest.mark.skipif(not (ASSETS / "manifest.json").exists(), reason="assets not built")
def test_turkish_records_keep_the_structure_of_english():
    """Structural fields (block types, table shapes) are never translated."""
    def shape(node):
        if isinstance(node, dict):
            return {k: (v if k in ("type", "kind", "id") else shape(v)) for k, v in node.items()}
        if isinstance(node, list):
            return [shape(v) for v in node]
        return None

    for path in ASSETS.glob("*.json"):
        if path.name in ("manifest.json", "glossary.json"):
            continue
        for rec in json.loads(path.read_text(encoding="utf-8"))["records"]:
            if rec["tr"] is not None:
                assert shape(rec["tr"]) == shape(rec["en"]), (path.name, rec["id"])
