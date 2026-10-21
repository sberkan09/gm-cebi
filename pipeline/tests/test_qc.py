from gmcebi_pipeline.qc import check_markup, check_numbers, check_references, check_segment


def test_numbers_and_dice_preserved():
    assert check_numbers("takes 2d6+3 Fire damage within 60 feet", "60 fit içinde 2d6+3 Ateş hasarı alır") == []
    assert check_numbers("takes 2d6+3 damage", "2d6+2 hasar alır")
    assert check_numbers("within 60 feet", "altmış fit içinde")


def test_markup_preserved():
    assert check_markup("**Can’t See.**", "**Göremez.**") == []
    assert check_markup("**Can’t See.**", "Göremez.")
    assert check_markup("cast *Fireball*", "*Ateş Topu* yap") == []


def test_references_resolve():
    titles = {"Rules Glossary": "Kurallar Sözlüğü", "*Fireball": "Ateş Topu"}
    assert check_references("(see “Rules Glossary”)", "(bkz. “Kurallar Sözlüğü”)", titles) == []
    assert check_references("(see “Rules Glossary”)", "(bkz. “Kurallar”)", titles)
    assert check_references("like *Fireball*", "*Fireball* gibi", titles)


def test_untranslated_english_flagged(glossary):
    issues = check_segment("You fall.", "You düşersin.", glossary)
    assert any(i.startswith("untranslated") for i in issues)
