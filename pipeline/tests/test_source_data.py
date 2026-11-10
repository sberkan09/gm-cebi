"""Checks on the committed English source JSON (pipeline/data/source)."""

import pytest

from gmcebi_pipeline.models import DATASETS

# Counts verified by hand against the SRD 5.2.1 table of contents.
EXPECTED = {
    "conditions": 15, "spells": 339, "monsters": 330, "classes": 12, "subclasses": 12,
    "species": 9, "backgrounds": 4, "feats": 17, "weapon_mastery": 8, "weapon_properties": 10,
    "magic_items": 258, "rules": 52,
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


SIDEBARS = {  # sidebar title -> (dataset, record id) it ends up in
    "Exceptions Supersede General Rules": ("rules", "playing-intro"),
    "Round Down": ("rules", "playing-intro"),
    "Heroic Inspiration": ("rules", "playing-d20-tests"),
    "Marching Order": ("rules", "playing-exploration"),
    "Playing on a Grid": ("rules", "playing-exploration"),
    "Unseen Attackers and Targets": ("rules", "playing-combat"),
    "Resting": ("rules", "playing-combat"),
    "Knocking Out a Creature": ("rules", "playing-damage-and-healing"),
    "Unaligned Creatures": ("rules", "creation-create-your-character"),
    "Bonus Feats at Level 20": ("rules", "creation-level-advancement"),
    "Breaking Your Oath": ("classes", "paladin"),
    "Expanding and Replacing a Spellbook": ("classes", "wizard"),
    "Selling Equipment": ("rules", "equipment-intro"),
    "Improvised Weapons": ("rules", "equipment-weapons"),
    "Casting in Armor": ("rules", "spells-intro"),
    "Identifying an Ongoing Spell": ("rules", "spells-casting-spells"),
    "Magic Item Rules": ("rules", "magic-items-magic-item-categories"),
}


def _strings(obj):
    if isinstance(obj, str):
        yield obj
    elif isinstance(obj, dict):
        for v in obj.values():
            yield from _strings(v)
    elif isinstance(obj, list):
        for v in obj:
            yield from _strings(v)


def test_sidebars_are_lifted(source):
    """A sidebar is its own heading + paragraphs, never glued into the text it interrupts."""
    for title, (name, rid) in SIDEBARS.items():
        rec = next(r for r in source[name] if r["id"] == rid)
        assert {f"### {title}", f"#### {title}"} & set(_strings(rec)), title
    glued = [(name, r["id"], title) for name in DATASETS for r in source[name] for s in _strings(r)
             for title in SIDEBARS if f"**{title}**" in s]
    assert not glued, glued
    # The paragraph the sidebar interrupted reads on; the sidebar follows it.
    texts = [b.get("text") for b in next(r for r in source["rules"] if r["id"] == "playing-d20-tests")["blocks"]]
    i = texts.index("#### Heroic Inspiration")
    assert texts[i - 1] == ("You usually acquire Advantage or Disadvantage through the use of special "
                            "abilities and actions. The GM can also decide that circumstances grant "
                            "Advantage or impose Disadvantage.")
    assert texts[i + 1].startswith("Sometimes the GM or a rule gives you Heroic Inspiration.")
    assert texts[i + 2].startswith("**Only One at a Time.**")
    feat = next(f for f in source["feats"] if f["id"] == "boon-of-truesight")
    assert feat["blocks"][-1]["text"] == "**Truesight.** You have Truesight with a range of 60 feet."


def test_spellcasting_rule_sections(source):
    rules = {r["id"]: r for r in source["rules"]}
    casting = rules["spells-casting-spells"]
    assert casting["chapter"] == "Spells" and casting["source"]["page"] == 104
    texts = [b.get("text") for b in casting["blocks"]]
    for h in ["### Spell Level", "#### Spell Slots", "### Casting Time", "#### Longer Casting Times",
              "### Range", "### Components", "#### Verbal (V)", "#### Material (M)", "### Duration",
              "### Effects", "#### Targets", "#### Combining Spell Effects"]:
        assert h in texts, h
    assert ("**Concentration.** A duration that requires Concentration follows the Concentration "
            "rules (see “Rules Glossary”).") in texts
    # Run-in labels split as "Rituals" + "." start their own paragraph; formulas keep their tail.
    assert any(t.startswith("**Rituals**. Certain spells") for t in texts)
    assert "**Spell save DC** = 8 + your spellcasting ability modifier + your Proficiency Bonus" in texts
    assert _table(casting, "Schools of Magic")["rows"][-1] == ["Transmutation", "Transforms creatures or objects"]
    prep = _table(rules["spells-gaining-spells"], "Spell Preparation by Class")
    assert prep["header"] == ["Class", "Change When You …", "Number of Spells"] and len(prep["rows"]) == 8
    assert "spells-spell-descriptions" not in rules  # the spell list itself is the spells dataset


def test_equipment_rule_sections(source):
    rules = {r["id"]: r for r in source["rules"]}
    eq = [r["id"] for r in source["rules"] if r["chapter"] == "Equipment"]
    assert eq[0] == "equipment-intro" and eq[-1] == "equipment-scribing-spell-scrolls"
    for rid in ["equipment-coins", "equipment-lifestyle-expenses", "equipment-food-drink-and-lodging",
                "equipment-hirelings", "equipment-spellcasting", "equipment-magic-items",
                "equipment-crafting-nonmagical-items", "equipment-brewing-potions-of-healing"]:
        assert rid in eq, rid
    food = _table(rules["equipment-food-drink-and-lodging"], "Food, Drink, and Lodging")
    assert food["header"] == ["Item", "Cost"]
    assert [r[0] for r in food["rows"]] == [
        "Ale (mug)", "Bread (loaf)", "Cheese (wedge)",
        "Inn Stay per Day", "Squalid", "Poor", "Modest", "Comfortable", "Wealthy", "Aristocratic",
        "Meal", "Squalid", "Poor", "Modest", "Comfortable", "Wealthy", "Aristocratic",
        "Wine (bottle)", "Common", "Fine"]
    assert food["rows"][9] == ["Aristocratic", "4 GP"] and food["rows"][16] == ["Aristocratic", "6 SP"]
    assert food["rows"][-1] == ["Fine", "10 GP"]
    assert _table(rules["equipment-spellcasting"], "Spellcasting Services")["rows"][-1] == [
        "9", "City only", "100,000 GP"]
    assert _table(rules["equipment-scribing-spell-scrolls"], "Spell Scroll Costs")["rows"][-1] == [
        "9", "120 days", "50,000 GP"]
    # Item tables and entries already in the equipment datasets are not repeated.
    titles = {t.get("title") for r in source["rules"] if r["chapter"] == "Equipment" for t in _tables(r)}
    assert not titles & {"Weapons", "Armor", "Adventuring Gear", "Airborne and Waterborne Vehicles"}
    weapons = [b.get("text") for b in rules["equipment-weapons"]["blocks"]]
    assert "#### Finesse" not in weapons and "### Properties" in weapons


def test_rule_sections_have_unique_names_and_no_empty_headings(source):
    names = [r["name"] for r in source["rules"]]
    assert len(names) == len(set(names))
    for r in source["rules"]:
        heads = [i for i, b in enumerate(r["blocks"]) if (b.get("text") or "").startswith("###")]
        assert not heads or heads[-1] != len(r["blocks"]) - 1, r["id"]
