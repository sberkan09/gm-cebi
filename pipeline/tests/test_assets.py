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
