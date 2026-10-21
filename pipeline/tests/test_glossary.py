import csv
from collections import Counter

from gmcebi_pipeline.glossary import GLOSSARY_PATH, Glossary, Term


def test_glossary_file_is_valid(glossary):
    assert glossary.validate() == []


def test_core_term_count(glossary):
    core = [t for t in glossary.terms if t.category not in ("büyü adı", "bölüm")]
    assert len(core) >= 300


def test_status_values_and_review_flags(glossary):
    statuses = Counter(t.status for t in glossary.terms)
    assert set(statuses) <= {"topluluk", "öneri", "tartışmalı"}
    assert statuses["tartışmalı"] > 0


def test_header_is_stable():
    with GLOSSARY_PATH.open(encoding="utf-8") as f:
        header = next(csv.reader(f))
    assert header == ["id", "en", "tr", "category", "status", "alternatives", "note", "evidence",
                      "enforce", "en_pattern"]


def test_inflected_forms_match():
    t = Term("hp", "Hit Points", "Can Puanı", "kural", "topluluk")
    for form in ["Can Puanı", "can puanını", "Can Puanları", "Can Puanlarının"]:
        assert t.found_in_tr(form), form
    assert not t.found_in_tr("Can Zarı")
    t = Term("st", "Saving Throw", "Kurtarma Zarı", "kural", "topluluk")
    assert t.found_in_tr("Çeviklik kurtarma zarında başarısız olursa")


def test_longest_match_wins(glossary):
    ids = [t.id for t in glossary.terms_in("You take a Bonus Action and make a Dexterity saving throw.")]
    assert "bonus-action" in ids and "action" not in ids
    assert "saving-throw" in ids and "dexterity" in ids


def test_damage_type_detected_alongside_damage(glossary):
    ids = [t.id for t in glossary.terms_in("takes 8d6 Fire damage")]
    assert "fire" in ids


def test_check_reports_missing_term(glossary):
    en = "You have Advantage on the roll."
    assert glossary.check(en, "Zarda Avantajın olur.") == []
    assert glossary.check(en, "Zarda üstünlüğün olur.")
