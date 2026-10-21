"""Pydantic data model for SRD 5.2.1 records (English source side).

Every record carries a `source` with page range and heading path so that a
reviewer can find the original text. Rich text is stored as a list of
`Block`s holding light markdown (**bold**, *italic*, "- " bullets).
Turkish text lives in the translation store and is merged at asset build
time; see docs/data-model.md.
"""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, Field

SRD_DOC = "SRD 5.2.1"


class SourceRef(BaseModel):
    document: str = SRD_DOC
    page: int
    page_end: int | None = None
    heading: list[str] = Field(default_factory=list, description="Heading path, outermost first")


class Block(BaseModel):
    type: Literal["p", "table"]
    text: str | None = None
    title: str | None = None
    header: list[str] | None = None
    rows: list[list[str]] | None = None


class NamedText(BaseModel):
    """A run-in labelled paragraph, e.g. a monster trait or species trait."""

    name: str
    text: str


class Record(BaseModel):
    id: str
    name: str
    source: SourceRef


class RuleEntry(Record):
    kind: Literal["rule"] = "rule"
    tags: list[str] = Field(default_factory=list, description='e.g. ["Condition"], ["Action"]')
    blocks: list[Block]
    see_also: list[str] = Field(default_factory=list)


class Condition(RuleEntry):
    kind: Literal["condition"] = "condition"  # type: ignore[assignment]
    effects: list[NamedText] = Field(default_factory=list)


class Components(BaseModel):
    verbal: bool = False
    somatic: bool = False
    material: bool = False
    material_text: str | None = None


class Spell(Record):
    kind: Literal["spell"] = "spell"
    level: int = Field(ge=0, le=9, description="0 = cantrip")
    school: str
    classes: list[str]
    casting_time: str
    ritual: bool = False
    range: str
    components: Components
    duration: str
    concentration: bool = False
    blocks: list[Block]
    higher_levels: str | None = None
    cantrip_upgrade: str | None = None


class AbilityLine(BaseModel):
    score: int
    mod: int
    save: int


class Monster(Record):
    kind: Literal["monster"] = "monster"
    group: str | None = Field(None, description="Family heading, e.g. 'Black Dragons'")
    size: str
    creature_type: str
    alignment: str
    ac: int
    ac_note: str | None = None
    initiative: str
    hp: int
    hp_formula: str | None = None
    speed: str
    abilities: dict[Literal["str", "dex", "con", "int", "wis", "cha"], AbilityLine]
    details: dict[str, str] = Field(
        default_factory=dict,
        description="Skills, Resistances, Immunities, Vulnerabilities, Gear, Senses, Languages",
    )
    cr: str
    xp: str | None = None
    proficiency_bonus: int | None = None
    traits: list[NamedText] = Field(default_factory=list)
    actions: list[NamedText] = Field(default_factory=list)
    bonus_actions: list[NamedText] = Field(default_factory=list)
    reactions: list[NamedText] = Field(default_factory=list)
    legendary_actions: list[NamedText] = Field(default_factory=list)
    section_intros: dict[str, str] = Field(default_factory=dict)


class Feature(BaseModel):
    level: int | None
    name: str
    blocks: list[Block]


class Subclass(Record):
    kind: Literal["subclass"] = "subclass"
    class_id: str
    blocks: list[Block] = Field(default_factory=list)
    features: list[Feature]


class CharacterClass(Record):
    kind: Literal["class"] = "class"
    core_traits: dict[str, str]
    blocks: list[Block] = Field(default_factory=list, description="Intro, tables, option lists")
    features: list[Feature]
    subclasses: list[str] = Field(default_factory=list, description="Subclass ids")


class Species(Record):
    kind: Literal["species"] = "species"
    creature_type: str
    size: str
    speed: str
    blocks: list[Block] = Field(default_factory=list)
    traits: list[NamedText]


class Background(Record):
    kind: Literal["background"] = "background"
    ability_scores: list[str]
    feat: str
    skill_proficiencies: str
    tool_proficiency: str
    equipment: str


class Feat(Record):
    kind: Literal["feat"] = "feat"
    category: str
    prerequisite: str | None = None
    repeatable: str | None = None
    blocks: list[Block]


class EquipmentItem(Record):
    kind: Literal["equipment"] = "equipment"
    category: str = Field(description="weapon | armor | tool | gear | mount | vehicle | ...")
    subcategory: str | None = None
    fields: dict[str, str] = Field(default_factory=dict, description="Table columns, by header")
    blocks: list[Block] = Field(default_factory=list)


class WeaponMastery(Record):
    kind: Literal["weapon_mastery"] = "weapon_mastery"
    text: str


class WeaponProperty(Record):
    kind: Literal["weapon_property"] = "weapon_property"
    text: str


DATASETS: dict[str, type[Record]] = {
    "rules_glossary": RuleEntry,
    "conditions": Condition,
    "spells": Spell,
    "monsters": Monster,
    "classes": CharacterClass,
    "subclasses": Subclass,
    "species": Species,
    "backgrounds": Background,
    "feats": Feat,
    "equipment": EquipmentItem,
    "weapon_mastery": WeaponMastery,
    "weapon_properties": WeaponProperty,
}
