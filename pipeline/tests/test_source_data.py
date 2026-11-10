"""Checks on the committed English source JSON (pipeline/data/source)."""

import pytest

from gmcebi_pipeline.models import DATASETS

# Counts verified by hand against the SRD 5.2.1 table of contents.
EXPECTED = {
    "conditions": 15, "spells": 339, "monsters": 330, "classes": 12, "subclasses": 12,
    "species": 9, "backgrounds": 4, "feats": 17, "weapon_mastery": 8, "weapon_properties": 10,
    "magic_items": 258, "rules": 34,
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


def test_animals_are_not_in_a_monster_family(source):
    """Review B1: the Animals chapter must reset the family heading."""
    mons = {m["id"]: m for m in source["monsters"]}
    assert mons["wolf"].get("group") is None
    assert mons["wolf"]["source"]["heading"] == ["Animals", "Wolf"]
    assert sum(m.get("group") == "Zombies" for m in source["monsters"]) == 2


def test_lists_and_continuations(source):
    aoe = next(r for r in source["rules_glossary"] if r["id"] == "area-of-effect")
    assert [b["text"] for b in aoe["blocks"][1:7]] == ["- Cone", "- Cube", "- Cylinder", "- Emanation",
                                                       "- Line", "- Sphere"]
    dwarf = next(s for s in source["species"] if s["id"] == "dwarf")
    assert "Bonus Action" in dwarf["traits"][-1]["text"] and len(dwarf["blocks"]) == 1
    presti = next(s for s in source["spells"] if s["id"] == "prestidigitation")
    assert any(b["text"].startswith("**Fire Play.**") for b in presti["blocks"])


def test_no_soft_hyphen_leftovers(source):
    import json
    import re
    blob = json.dumps(source, ensure_ascii=False)
    assert "\u00ad" not in blob
    # "word- word" from a line-break hyphen that was not joined
    leftovers = re.findall(r"[a-z]{3,}- [a-z]{3,}", blob)
    assert len(leftovers) <= 3, leftovers


def test_vehicle_tables(source):
    eq = {e["id"]: e for e in source["equipment"]}
    assert eq["galley"]["fields"]["Cost"] == "30,000 GP"
    assert eq["rowboat"]["fields"]["HP"] == "50" and eq["rowboat"]["fields"]["Cost"] == "50 GP"
    assert eq["saddle-exotic"]["name"] == "Saddle, Exotic"
    assert eq["cart"]["fields"] == {"Weight": "200 lb.", "Cost": "15 GP"}
    # Header cells and rows of the food table that leaked into the ship table are gone.
    assert not {"speed", "exotic", "comfortable", "common", "saddle"} & set(eq)


def test_magic_items_and_rule_sections(source):
    items = {i["id"]: i for i in source["magic_items"]}
    assert items["bag-of-holding"]["category"] == "Wondrous Item"
    assert items["bag-of-holding"]["rarity"] == "Uncommon" and "attunement" not in items["bag-of-holding"]
    assert items["holy-avenger"]["attunement"] == "Requires Attunement by a Paladin"
    assert items["armor-1-2-or-3"]["rarity"] == "Rare (+1), Very Rare (+2), or Legendary (+3)"
    # Body text that opens with the item's italic name is not swallowed into the header.
    assert items["dragon-scale-mail"]["type_line"] == "Armor (Scale Mail), Very Rare (Requires Attunement)"
    rules = {r["id"]: r for r in source["rules"]}
    enc = rules["toolbox-combat-encounters"]
    assert enc["chapter"] == "Gameplay Toolbox"
    assert any(b.get("text") == "### Combat Encounter Difficulty" for b in enc["blocks"])
    assert any(b["type"] == "table" for b in enc["blocks"])


def _tables(obj):
    if isinstance(obj, dict):
        if obj.get("type") == "table":
            yield obj
        for v in obj.values():
            yield from _tables(v)
    elif isinstance(obj, list):
        for v in obj:
            yield from _tables(v)


# Tables that are genuinely ragged or have a blank header cell in the PDF: (dataset, record
# id, table title) → reason. None at present. The ability table of a stat block has a blank
# first header cell by design.
RAGGED_TABLES: dict[tuple[str, str, str | None], str] = {}
STAT_BLOCK_HEADER = ["", "Score", "Mod", "Save"]


@pytest.mark.parametrize("name", DATASETS)
def test_tables_are_rectangular(source, name):
    """Every header cell is filled and every row has as many cells as the header."""
    bad = []
    for rec in source[name]:
        for t in _tables(rec):
            if (name, rec["id"], t.get("title")) in RAGGED_TABLES:
                continue
            h = t["header"]
            if ("" in h and h != STAT_BLOCK_HEADER) or any(len(r) != len(h) for r in t["rows"]):
                bad.append((rec["id"], t.get("title"), h))
    assert not bad, bad


def _table(rec, title=None):
    return next(t for t in _tables(rec) if title is None or t.get("title") == title)


def test_rule_tables(source):
    rules = {r["id"]: r for r in source["rules"]}
    # A different header ends a table: the Actions table keeps all twelve actions.
    skills = _table(rules["playing-proficiency"], "Skills")
    actions = _table(rules["playing-actions"], "Actions")
    assert len(skills["rows"]) == 18 and all(len(r) == 3 for r in skills["rows"])
    assert len(actions["rows"]) == 12 and [actions["rows"][0][0], actions["rows"][-1][0]] == ["Attack", "Utilize"]
    rarity = _table(rules["magic-items-magic-item-rarity"], "Magic Item Rarities and Values")
    assert rarity["header"] == ["Rarity", "Value*"]
    assert rarity["rows"][3:] == [["Very Rare", "40,000 GP"], ["Legendary", "200,000 GP"], ["Artifact", "Priceless"]]
    craft = _table(rules["magic-items-crafting-magic-items"], "Magic Item Crafting Time and Cost")
    assert craft["rows"][0] == ["Common", "5 days", "50 GP"] and craft["rows"][2] == ["Rare", "50 days", "2,000 GP"]
    adv = _table(rules["creation-level-advancement"], "Character Advancement")
    assert adv["header"] == ["Level", "Experience Points", "Proficiency Bonus"]
    assert adv["rows"][3] == ["4", "2,700", "+2"]
    hp = _table(rules["creation-create-your-character"], "Level 1 Hit Points by Class")
    assert hp["rows"][2] == ["Bard, Cleric, Druid, Monk, Rogue, or Warlock", "8 + Con. modifier"]
    overview = _table(rules["creation-create-your-character"], "Class Overview")
    assert overview["rows"][0] == ["Barbarian", "Battle", "Strength", "Average"]
    terrain = _table(rules["toolbox-travel-pace"], "Travel Terrain")
    assert terrain["header"][2:] == ["Encounter Distance", "Foraging DC", "Navigation DC", "Search DC"]
    assert terrain["rows"][0] == ["Arctic", "Fast*", "6d6 × 10 feet", "20", "10", "10"]
    items = {i["id"]: i for i in source["magic_items"]}
    assert _table(items["staff-of-healing"])["rows"][0] == [
        "Cure Wounds", "1 charge per spell level (maximum 4 for a level 4 spell)"]
    assert _table(items["manual-of-golems"])["header"] == ["1d20", "Golem", "Time", "Cost"]
    # Two copies of a narrow table printed side by side are stacked.
    assert len(_table(items["dragon-scale-mail"])["rows"]) == 10


def test_chapter_intros(source):
    rules = {r["id"]: r for r in source["rules"]}
    intro = rules["playing-intro"]
    assert intro["name"] == "Playing the Game" and list(rules)[0] == "playing-intro"
    texts = [b["text"] for b in intro["blocks"]]
    assert texts[0] == "### Exceptions Supersede General Rules" and "### Round Down" in texts
    assert rules["magic-items-intro"]["blocks"][0]["text"].startswith("Magic items are gleaned")
    az = rules["magic-items-magic-items-az"]["blocks"]
    assert az[0]["text"] == "Magic items are presented in alphabetical order."


def test_magic_item_stat_blocks(source):
    items = {i["id"]: i for i in source["magic_items"]}
    for item, name, ac in [("figurine-of-wondrous-power", "Giant Fly", "**AC** 11"),
                           ("mysterious-deck", "Avatar of Death", "**AC** 20")]:
        blocks = items[item]["blocks"]
        texts = [b.get("text") for b in blocks]
        i = texts.index(f"### {name}")
        assert texts[i + 2] == ac
        assert any(b["type"] == "table" and b["header"] == STAT_BLOCK_HEADER for b in blocks[i:])
