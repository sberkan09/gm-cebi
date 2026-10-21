"""Re-parses the PDF and checks it reproduces the committed source JSON."""

import json

import pytest

from conftest import PDF, SOURCE

pytestmark = pytest.mark.pdf


@pytest.mark.skipif(not PDF.exists(), reason="SRD PDF not downloaded")
def test_parse_is_deterministic_and_matches_committed():
    from gmcebi_pipeline.build_source import build
    data = build(PDF)
    for name, recs in data.items():
        fresh = [r.model_dump(mode="json", exclude_none=True) for r in recs]
        committed = json.loads((SOURCE / f"{name}.json").read_text(encoding="utf-8"))
        assert fresh == committed, f"{name} drifted; rerun python -m gmcebi_pipeline.build_source"
