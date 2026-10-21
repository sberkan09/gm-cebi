import json
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

SOURCE = ROOT / "data" / "source"
PDF = ROOT / "raw" / "SRD_CC_v5.2.1.pdf"


@pytest.fixture(scope="session")
def source():
    return {p.stem: json.loads(p.read_text(encoding="utf-8")) for p in SOURCE.glob("*.json")
            if not p.name.startswith("_")}


@pytest.fixture(scope="session")
def glossary():
    from gmcebi_pipeline.glossary import Glossary
    return Glossary.load()
