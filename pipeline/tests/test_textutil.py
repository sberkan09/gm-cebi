from gmcebi_pipeline.textutil import dice_tokens, number_tokens, split_sentences, tr_fold, tr_lower, tr_upper


def test_turkish_case():
    assert tr_lower("IŞIK İnisiyatif") == "ışık inisiyatif"
    assert tr_upper("ışık inisiyatif") == "IŞIK İNİSİYATİF"
    assert tr_fold("Cüce Büyücü ÇIĞ") == "cuce buyucu cig"


def test_split_keeps_runin_label_and_abbreviations():
    s = ("**Can’t See.** You can’t see and automatically fail any ability check that requires sight. "
         "It moves 30 ft. toward you. See also “Cover.” Done here.")
    assert split_sentences(s) == [
        "**Can’t See.**",
        "You can’t see and automatically fail any ability check that requires sight.",
        "It moves 30 ft. toward you.",
        "See also “Cover.”",
        "Done here.",
    ]


def test_short_text_is_one_segment():
    assert split_sentences("Action") == ["Action"]


def test_dice_and_numbers():
    assert dice_tokens("takes 2d6 + 3 Fire damage and 1d4") == ["1d4", "2d6+3"]
    assert number_tokens("DC 15, 1,500 GP, −2") == ["-2", "15", "1500"]


def test_thousands_separators_are_equivalent():
    assert number_tokens("1,000 GP") == number_tokens("1.000 altın") == ["1000"]
    assert number_tokens("XP 7,200") == number_tokens("TP 7.200")
