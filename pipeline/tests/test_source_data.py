"""Checks on the committed English source JSON (pipeline/data/source)."""

import pytest

from gmcebi_pipeline.models import DATASETS

# Counts verified by hand against the SRD 5.2.1 table of contents.
EXPECTED = {
    "conditions": 15, "spells": 339, "monsters": 330, "classes": 12, "subclasses": 12,
    "species": 9, "backgrounds": 4, "feats": 17, "weapon_mastery": 8, "weapon_properties": 10,
}


def test_all_datasets_present(source):
    assert set(DATASETS) <= set(source)


@pytest.mark.parametrize("name,count", EXPECTED.items())
def test_counts(source, name, count):
    assert len(source[name]) == count


def test_rules_glossary_count(source):
    assert len(source["rules_glossary"]) >= 140


@pytest.mark.parametrize("name", DATASETS)
def test_schema_and_source_refs(source, name):
    model = DATASETS[name]
    ids = set()
    for rec in source[name]:
        obj = model.model_validate(rec)
        assert obj.id not in ids
        ids.add(obj.id)
        assert 1 <= obj.source.page <= 364
        assert obj.source.heading, obj.id


def test_spot_checks(source):
    fb = next(s for s in source["spells"] if s["id"] == "fireball")
    assert fb["level"] == 3 and fb["school"] == "Evocation" and fb["range"] == "150 feet"
    assert "8d6 Fire damage" in fb["blocks"][0]["text"]
    assert fb["higher_levels"].startswith("The damage increases by 1d6")
    ab = next(m for m in source["monsters"] if m["id"] == "aboleth")
    assert ab["ac"] == 17 and ab["hp"] == 150 and ab["cr"] == "10"
    assert ab["abilities"]["str"] == {"score": 21, "mod": 5, "save": 5}
    assert [a["name"] for a in ab["legendary_actions"]] == ["Lash", "Psychic Drain"]
    blinded = next(c for c in source["conditions"] if c["id"] == "blinded")
    assert [e["name"] for e in blinded["effects"]] == ["Can’t See", "Attacks Affected"]
    dagger = next(e for e in source["equipment"] if e["id"] == "dagger")
    assert dagger["fields"]["Damage"] == "1d4 Piercing" and dagger["fields"]["Mastery"] == "Nick"


def test_no_soft_hyphen_leftovers(source):
    import json
    import re
    blob = json.dumps(source, ensure_ascii=False)
    # "word- word" from a line-break hyphen that was not joined
    leftovers = re.findall(r"[a-z]{3,}- [a-z]{3,}", blob)
    assert len(leftovers) <= 3, leftovers
