import json

from gmcebi_pipeline.license import find_terms


def test_denylist_matches_whole_words_only():
    assert find_terms("A Beholder floats here.") == ["Beholder"]
    assert find_terms("Dungeons & Dragons and D&D") == ["D&D", "Dungeons & Dragons"]
    assert find_terms("He beheld the strahdian sky.") == []


def test_source_data_has_no_product_identity(source):
    for name, recs in source.items():
        assert find_terms(json.dumps(recs, ensure_ascii=False)) == [], name
