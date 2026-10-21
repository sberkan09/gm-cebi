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
                      "enforce", "en_pattern", "tr_pattern"]


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


def test_prefix_words_are_not_accepted(glossary):
    """Review B2: a Turkish word that merely starts with the term must not pass."""
    bad = [
        ("Cast a spell.", "Büyük bir şey yap."),
        ("Make a Religion check.", "Dinlenme testi yap."),
        ("Make a Strength check.", "Güçlü bir test yap."),
        ("Your Speed is 30.", "Hızlı olursun, 30."),
        ("in its Lair", "inisiyatifinde"),
    ]
    for en, tr in bad:
        assert glossary.check(en, tr), (en, tr)


def test_real_inflections_are_accepted(glossary):
    good = [
        ("You have Advantage.", "Avantajlısın."),
        ("You lose Hit Points.", "Can Puanlarını kaybedersin."),
        ("a DC 15 Wisdom saving throw", "ZD 15 Bilgelik kurtarma zarında"),
        ("if you have the Prone condition", "Yerde durumundaysan"),
        ("Your Speed is 0.", "Hızının 0 olduğu"),
        ("its Passive Perception", "Pasif Algısı"),
        ("in a 15-foot Cone", "15 fitlik bir Koni içinde"),
    ]
    for en, tr in good:
        assert glossary.check(en, tr) == [], (en, tr, glossary.check(en, tr))


def test_rejected_alternative_is_flagged(glossary):
    issues = glossary.check("You have Proficiency in it.", "Bunda Yeterliliğin var, Yetkinliğin de.")
    assert any(i.startswith("term-alt:proficiency") for i in issues)


def test_capitalisation_follows_source(glossary):
    assert any(i.startswith("case:") for i in glossary.check("You have Advantage on it.", "Bunda avantajın var."))
    assert glossary.check("Make a saving throw now.", "Şimdi bir kurtarma zarı at.") == []


def test_title_map_keeps_spell_and_rule_apart(glossary):
    from gmcebi_pipeline.glossary import build_title_map
    titles = build_title_map(glossary, [])
    assert titles["*Shield"] == "Kalkan Büyüsü"
    assert titles["Shield"] == "Kalkan"
