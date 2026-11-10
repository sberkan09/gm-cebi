from gmcebi_pipeline.segments import apply_translation, needs_translation, record_segments, segment_key


REC = {
    "id": "blinded", "name": "Blinded", "kind": "condition", "tags": ["Condition"],
    "source": {"document": "SRD 5.2.1", "page": 177, "heading": ["Rules Glossary"]},
    "blocks": [
        {"type": "p", "text": "**Can’t See.** You can’t see. You fail checks that need sight."},
        {"type": "table", "header": ["1d8", "Ray"], "rows": [["1", "Red."], ["2", "—"]]},
    ],
}


def test_segments_cover_text_but_not_ids_numbers_or_enum_fields():
    segs = record_segments(REC, "conditions")
    ens = [s.en for s in segs]
    assert "Blinded" in ens and "**Can’t See.**" in ens and "Red." in ens and "Ray" in ens
    assert "blinded" not in ens and "1" not in ens and "—" not in ens and "Condition" not in ens
    name = next(s for s in segs if s.path == "name")
    assert name.key == segment_key("Blinded", "conditions") != segment_key("Blinded")


def test_roundtrip_and_partial_fallback():
    segs = record_segments(REC, "conditions")
    tm = {s.key: f"TR<{s.en}>" for s in segs}
    tr, done, missing = apply_translation(REC, tm.get, "conditions")
    assert missing == 0 and done == len(segs)
    assert tr["name"] == "TR<Blinded>"
    assert tr["blocks"][1]["rows"][0] == ["1", "TR<Red.>"]
    del tm[segment_key("Red.")]
    tr, done, missing = apply_translation(REC, tm.get, "conditions")
    assert missing == 1 and tr["blocks"][1]["rows"][0][1] == "Red."


def test_needs_translation():
    assert not needs_translation("2d6 + 3")
    assert not needs_translation("—")
    assert needs_translation("60 feet")


def test_context_namespaces():
    from gmcebi_pipeline.segments import record_segments, segment_key
    cls = {"id": "bard", "name": "Bard", "blocks": [
        {"type": "table", "title": "Cantrips", "header": ["Spell", "School"], "rows": [["Light", "Evocation"]]},
        {"type": "table", "title": "Gear", "header": ["Item", "Cost"], "rows": [["Light", "1 GP"]]}]}
    keys = {(s.path, s.en): s.key for s in record_segments(cls, "classes")}
    assert keys[("blocks.0.rows.0.0", "Light")] == segment_key("Light", "spells")  # the spell
    assert keys[("blocks.1.rows.0.0", "Light")] == segment_key("Light")            # plain text
    beads = {"id": "necklace-of-prayer-beads", "name": "Necklace of Prayer Beads", "blocks": [
        {"type": "table", "header": ["1d20", "Bead", "Spell"], "rows": [["1–6", "Bead of Blessing", "Bless"]]}]}
    keys = {s.path: s.key for s in record_segments(beads, "magic_items")}
    assert keys["blocks.0.rows.0.2"] == segment_key("Bless", "spells")  # a "Spell" column anywhere
    assert keys["blocks.0.rows.0.1"] == segment_key("Bead of Blessing")
    mon = {"id": "ettin", "name": "Ettin", "creature_type": "Giant", "details": {"Languages": "Giant"}}
    keys = {s.path: s.key for s in record_segments(mon, "monsters")}
    assert keys["details.Languages"] == segment_key("Giant", "lang")
    assert keys["creature_type"] == segment_key("Giant")
