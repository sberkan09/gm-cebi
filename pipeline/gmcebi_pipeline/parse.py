"""Turn the SRD line stream into typed records (see models.py)."""

from __future__ import annotations

import re
import unicodedata
from collections.abc import Iterable

from .extract import Line, join_text
from .models import (
    AbilityLine,
    Background,
    Block,
    CharacterClass,
    Components,
    Condition,
    EquipmentItem,
    Feat,
    Feature,
    Monster,
    NamedText,
    RuleEntry,
    SourceRef,
    Species,
    Spell,
    Subclass,
    WeaponMastery,
    WeaponProperty,
)
from .structure import (
    Section,
    build_table,
    heading_level,
    is_table_header,
    is_table_line,
    line_markdown,
    relocate_tables,
    md_paragraphs,
    segment,
    tidy_markdown,
)

# Chapter page ranges (inclusive) from the PDF outline.
CHAPTERS = {
    "playing": (5, 18),
    "creation": (19, 27),
    "classes": (28, 83),
    "origins": (83, 87),
    "feats": (87, 89),
    "equipment": (89, 104),
    "spells": (104, 175),
    "glossary": (176, 191),
    "toolbox": (192, 203),
    "magic_items": (204, 253),
    "monsters": (254, 364),
}

RUNIN_RE = re.compile(r"^\*\*(?P<name>[^*]+?)\.?\*\*\.?\s*(?P<text>.*)$", re.S)
TAG_RE = re.compile(r"^(?P<name>.+?)\s*\[(?P<tag>[^\]]+)\]$")
SEE_ALSO_RE = re.compile(r"See also (?P<rest>.+)$", re.S)
QUOTED_RE = re.compile(r"“([^”]+?)[,.]?”")


def slug(text: str) -> str:
    t = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    t = re.sub(r"[’'`]", "", t.lower())
    return re.sub(r"[^a-z0-9]+", "-", t).strip("-")


def lines_between(lines: list[Line], first: int, last: int) -> list[Line]:
    return [ln for ln in lines if first <= ln.page <= last]


def section_lines(lines: list[Line], start_title: str, page: int) -> int:
    for i, ln in enumerate(lines):
        if ln.page >= page and ln.text.strip() == start_title and heading_level(ln):
            return i
    raise KeyError(start_title)


def src(sec: Section, lines: Iterable[Line] | None = None) -> SourceRef:
    ls = list(lines) if lines is not None else sec.lines
    end = max([sec.page] + [ln.page for ln in ls])
    return SourceRef(page=sec.page, page_end=end if end != sec.page else None,
                     heading=[*sec.path, sec.title])


def to_blocks(lines: list[Line]) -> list[Block]:
    """Paragraphs and tables. h5 lines directly above a table become its title."""
    blocks: list[Block] = []
    buf: list[Line] = []
    pending_title: str | None = None

    def flush():
        for p in md_paragraphs(buf):
            blocks.append(Block(type="p", text=p))
        buf.clear()

    i, n = 0, len(lines)
    while i < n:
        ln = lines[i]
        lvl = heading_level(ln)
        if lvl == 5 or (lvl and lvl >= 4 and i + 1 < n and is_table_header(lines[i + 1])):
            flush()
            if i + 1 < n and is_table_header(lines[i + 1]):
                pending_title = ln.text.strip()
            else:
                blocks.append(Block(type="p", text=f"**{ln.text.strip()}**"))
            i += 1
            continue
        if is_table_header(ln):
            flush()
            j = i
            while j < n and is_table_line(lines[j]):
                j += 1
            t = build_table(pending_title or "", lines[i:j])
            blocks.append(Block(type="table", title=t.title or None, header=t.header, rows=t.rows))
            pending_title = None
            i = j
            continue
        buf.append(ln)
        i += 1
    flush()
    return blocks


def split_runins(blocks: list[Block]) -> tuple[list[Block], list[NamedText]]:
    rest: list[Block] = []
    named: list[NamedText] = []
    for b in blocks:
        m = RUNIN_RE.match(b.text or "") if b.type == "p" else None
        if m and len(m.group("name")) < 80:
            named.append(NamedText(name=m.group("name").strip().rstrip("."),
                                   text=m.group("text").strip()))
        else:
            rest.append(b)
    return rest, named


def see_also(blocks: list[Block]) -> list[str]:
    out: list[str] = []
    for b in blocks:
        if b.type != "p" or not b.text:
            continue
        m = SEE_ALSO_RE.search(b.text.replace("*", ""))
        if m:
            out += [q.strip() for q in QUOTED_RE.findall(m.group("rest"))]
    return out


# ---------------------------------------------------------------- glossary

def parse_glossary(lines: list[Line]) -> tuple[list[RuleEntry], list[Condition]]:
    a, b = CHAPTERS["glossary"]
    secs = relocate_tables(segment(lines_between(lines, a, b), max_level=4))
    rules: list[RuleEntry] = []
    conds: list[Condition] = []
    for s in secs:
        if s.level != 4 or "Rules Glossary" in s.title:
            continue
        m = TAG_RE.match(s.title)
        name, tags = (m.group("name"), [m.group("tag")]) if m else (s.title, [])
        blocks = to_blocks(s.lines)
        if "Condition" in tags:
            rest, effects = split_runins(blocks)
            conds.append(Condition(id=slug(name), name=name, tags=tags, blocks=blocks,
                                   effects=effects, see_also=see_also(blocks), source=src(s)))
        else:
            rules.append(RuleEntry(id=slug(name), name=name, tags=tags, blocks=blocks,
                                   see_also=see_also(blocks), source=src(s)))
    return rules, conds


# ---------------------------------------------------------------- spells

SPELL_HEAD_RE = re.compile(
    r"^(?:Level (?P<level>\d) (?P<school>\w+)|(?P<school2>\w+) Cantrip)\s*\((?P<classes>[^)]*)\)"
)
META_LABEL_RE = re.compile(r"^(Casting Time|Range|Components|Duration):\s*(.*)$")


def parse_spells(lines: list[Line]) -> list[Spell]:
    a, b = CHAPTERS["spells"]
    chunk = lines_between(lines, a, b)
    start = section_lines(chunk, "Spell Descriptions", 106)
    secs = relocate_tables(segment(chunk[start:], min_level=4, max_level=4))
    spells: list[Spell] = []
    for s in secs:
        if s.level != 4:
            continue
        ls = s.lines
        i = 0
        head = []
        while i < len(ls) and "Italic" in ls[i].font and ls[i].font.startswith("Cambria"):
            head.append(ls[i].text)
            i += 1
        head_txt = join_text(head)
        m = SPELL_HEAD_RE.match(head_txt)
        if not m:
            raise ValueError(f"Bad spell header for {s.title!r}: {head_txt!r} (p{s.page})")
        meta: dict[str, str] = {}
        last = None
        while i < len(ls) and (META_LABEL_RE.match(ls[i].text.strip())
                               or (last and ls[i].font.startswith("GillSans"))):
            t = ls[i].text.strip()
            mm = META_LABEL_RE.match(t)
            if mm:
                last = mm.group(1)
                meta[last] = mm.group(2).strip()
            elif last:
                meta[last] = join_text([meta[last], t])
            i += 1
        blocks = to_blocks(ls[i:])
        higher = cantrip = None
        body: list[Block] = []
        for bl in blocks:
            mm = RUNIN_RE.match(bl.text or "") if bl.type == "p" else None
            if mm and mm.group("name").startswith("Using a Higher-Level Spell Slot"):
                higher = mm.group("text").strip()
            elif mm and mm.group("name").startswith("Cantrip Upgrade"):
                cantrip = mm.group("text").strip()
            else:
                body.append(bl)
        comps = meta.get("Components", "")
        mat = re.search(r"M \((.+)\)\s*$", comps)
        ct = meta.get("Casting Time", "")
        dur = meta.get("Duration", "")
        spells.append(Spell(
            id=slug(s.title), name=s.title,
            level=int(m.group("level") or 0),
            school=m.group("school") or m.group("school2"),
            classes=[c.strip() for c in m.group("classes").split(",") if c.strip()],
            casting_time=ct, ritual="Ritual" in ct,
            range=meta.get("Range", ""),
            components=Components(
                verbal=bool(re.search(r"(^|,\s*)V\b", comps)),
                somatic=bool(re.search(r"(^|,\s*)S\b", comps)),
                material=bool(re.search(r"(^|,\s*)M\b", comps)),
                material_text=mat.group(1) if mat else None,
            ),
            duration=dur, concentration=dur.startswith("Concentration"),
            blocks=body, higher_levels=higher, cantrip_upgrade=cantrip,
            source=SourceRef(page=s.page, page_end=src(s).page_end,
                             heading=["Spells", "Spell Descriptions", s.title]),
        ))
    return spells


# ---------------------------------------------------------------- monsters

STAT_LABELS = ["AC", "Initiative", "HP", "Speed", "Skills", "Saving Throws", "Vulnerabilities",
               "Resistances", "Immunities", "Gear", "Senses", "Languages", "CR"]
STAT_LABEL_RE = re.compile(r"^(" + "|".join(re.escape(x) for x in STAT_LABELS) + r")\b\s*(.*)$")
ABILITY_RE = re.compile(r"(Str|Dex|Con|Int|Wis|Cha)\s+(\d+)\s+([+\-−]?\d+)\s+([+\-−]?\d+)")
WARNINGS: list[str] = []
MON_SECTIONS = {"Traits": "traits", "Actions": "actions", "Bonus Actions": "bonus_actions",
                "Reactions": "reactions", "Legendary Actions": "legendary_actions"}


def _int(s: str) -> int:
    return int(s.replace("−", "-").replace("+", ""))


def _is_mon_section(ln: Line) -> bool:
    return ln.font == "GillSans" and abs(ln.size - 12) < 0.3 and ln.text.strip() in MON_SECTIONS


def parse_statblock(sec: Section, group: str | None) -> Monster:
    ls = sec.lines
    i = 0
    while i < len(ls) and not ls[i].font.startswith("Optima"):
        i += 1  # skip any lore text preceding the block
    type_line = ls[i].text.strip()
    i += 1
    fields: dict[str, str] = {}
    ability_lines: list[Line] = []
    last = None
    while i < len(ls) and not _is_mon_section(ls[i]):
        ln = ls[i]
        t = ln.text.replace("\t", " ").strip()
        if ln.font.startswith("GillSans"):
            ability_lines.append(ln)
        else:
            m = STAT_LABEL_RE.match(t) if ln.font.startswith("Optima-Bold") else None
            if m:
                last = m.group(1)
                fields[last] = m.group(2).strip()
            elif last:
                fields[last] = join_text([fields[last], t])
        i += 1
    rows: list[list[Line]] = []
    for ln in sorted(ability_lines, key=lambda l: l.y0):
        if rows and abs(ln.y0 - rows[-1][0].y0) < 5:
            rows[-1].append(ln)
        else:
            rows.append([ln])
    ab_txt = " ".join(ln.text.replace("\t", " ") for r in rows for ln in sorted(r, key=lambda l: l.x0))
    abilities = {}
    for a, sc, mo, sv in ABILITY_RE.findall(ab_txt):
        mod, save = _int(mo), _int(sv)
        if sv[0].isdigit() and mod < 0 and save == -mod:
            save = mod  # sign glyph missing in the PDF
            WARNINGS.append(f"{sec.title}: {a} save printed without sign; assumed {save}")
        abilities[a.lower()] = AbilityLine(score=int(sc), mod=mod, save=save)
    if len(abilities) != 6:
        raise ValueError(f"{sec.title}: abilities parse failed: {ab_txt!r}")
    sections: dict[str, list[NamedText]] = {v: [] for v in MON_SECTIONS.values()}
    intros: dict[str, str] = {}
    cur_key = None
    intro_buf: list[str] = []
    entry_lines: list[str] = []

    def flush_entry():
        if cur_key and entry_lines:
            paras = [tidy_markdown(join_text(p.split("\n"))) for p in "\n".join(entry_lines).split("\n\t")]
            text = "\n\n".join(paras)
            m = RUNIN_RE.match(text)
            if m:
                sections[cur_key].append(NamedText(name=m.group("name").strip().rstrip("."),
                                                   text=m.group("text").strip()))
            elif sections[cur_key]:
                sections[cur_key][-1].text += "\n\n" + text
            else:
                intros[cur_key] = (intros.get(cur_key, "") + " " + text).strip()
        entry_lines.clear()

    while i < len(ls):
        ln = ls[i]
        if _is_mon_section(ln):
            flush_entry()
            cur_key = MON_SECTIONS[ln.text.strip()]
        elif ln.font.startswith("Optima") and ln.font.endswith("Italic") and ln.size < 9.2 and not entry_lines:
            intros[cur_key or "traits"] = join_text([intros.get(cur_key or "traits", ""), ln.text])
        else:
            starts = ln.spans[0].font.startswith("Optima-BoldItalic") or (
                ln.text.startswith("\t") and len(ln.spans) > 1 and ln.spans[1].font.startswith("Optima-BoldItalic"))
            if starts and entry_lines:
                flush_entry()
            md = line_markdown(ln)
            if ln.text.startswith("\t") and entry_lines and not starts:
                entry_lines.append("\t" + md.lstrip("\t "))
            else:
                entry_lines.append(md.lstrip("\t "))
        i += 1
    flush_entry()

    m = re.match(r"^(?P<size>.+?) (?P<type>(?:Aberration|Beast|Celestial|Construct|Dragon|Elemental|Fey|Fiend|Giant|Humanoid|Monstrosity|Ooze|Plant|Undead|Swarm of Tiny \w+)(?: \([^)]*\))?), (?P<al>.+)$", type_line)
    if not m:
        raise ValueError(f"{sec.title}: bad type line {type_line!r}")
    ac_m = re.match(r"(\d+)\s*(.*)", fields.get("AC", ""))
    hp_m = re.match(r"(\d+)\s*(?:\((.+)\))?", fields.get("HP", ""))
    cr_m = re.match(r"(\S+)\s*(?:\((.*)\))?", fields.get("CR", ""))
    xp = pb = None
    if cr_m and cr_m.group(2):
        xp_m = re.search(r"XP ([^;]+)", cr_m.group(2))
        pb_m = re.search(r"PB ([+\-−]\d+)", cr_m.group(2))
        xp = xp_m.group(1).strip() if xp_m else None
        pb = _int(pb_m.group(1)) if pb_m else None
    details = {k: v for k, v in fields.items() if k not in ("AC", "Initiative", "HP", "Speed", "CR")}
    return Monster(
        id=slug(sec.title), name=sec.title, group=group,
        size=m.group("size"), creature_type=m.group("type"), alignment=m.group("al"),
        ac=int(ac_m.group(1)), ac_note=ac_m.group(2).strip() or None,
        initiative=fields.get("Initiative", ""),
        hp=int(hp_m.group(1)), hp_formula=hp_m.group(2),
        speed=fields.get("Speed", ""), abilities=abilities, details=details,
        cr=cr_m.group(1), xp=xp, proficiency_bonus=pb,
        section_intros={k: v for k, v in intros.items() if v},
        source=SourceRef(page=sec.page, page_end=src(sec).page_end,
                         heading=["Monsters", *([group] if group else []), sec.title]),
        **sections,
    )


def parse_monsters(lines: list[Line]) -> list[Monster]:
    a, b = CHAPTERS["monsters"]
    chunk = lines_between(lines, a, b)
    start = section_lines(chunk, "Monsters A–Z", 258)
    secs = segment(chunk[start:], min_level=2, max_level=3)
    out: list[Monster] = []
    group = None
    for s in secs:
        if s.level == 2:
            group = s.title
            continue
        if s.level == 3 and any(ln.font.startswith("Optima") for ln in s.lines):
            out.append(parse_statblock(s, group if group != s.title else None))
    return out


# ---------------------------------------------------------------- classes

CLASS_NAMES = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger",
               "Rogue", "Sorcerer", "Warlock", "Wizard"]
CORE_KEYS = ["Primary Ability", "Hit Point Die", "Saving Throw Proficiencies", "Skill Proficiencies",
             "Weapon Proficiencies", "Tool Proficiencies", "Armor Training", "Starting Equipment"]
FEATURE_RE = re.compile(r"^Level (\d+): (.+)$")


def parse_core_traits(lines: list[Line]) -> dict[str, str]:
    items: list[list[str]] = []  # [label, value]
    label_open = False
    for ln in lines:
        if heading_level(ln):
            continue
        t = ln.text.strip()
        is_label = ln.font.startswith("GillSans-SemiBold") and abs(ln.size - 9.2) < 0.15
        if is_label:
            merged = next((k for k in CORE_KEYS if t.startswith(k) and len(t) > len(k)), None)
            if merged:
                items.append([merged, t[len(merged):].strip()])
                label_open = False
            elif label_open and items and not items[-1][1]:
                items[-1][0] = (items[-1][0] + " " + t).strip()
            else:
                items.append([t, ""])
                label_open = True
        elif items:
            items[-1][1] = join_text([items[-1][1], t])
            label_open = False
    return {re.sub(r"\s+", " ", k).strip(): tidy_markdown(v) for k, v in items}


def _heading_block(title: str, level: int) -> Block:
    return Block(type="p", text=f"{'#' * level} {title}")


def parse_classes(lines: list[Line]) -> tuple[list[CharacterClass], list[Subclass]]:
    a, b = CHAPTERS["classes"]
    chunk = lines_between(lines, a, b)
    end = section_lines(chunk, "Character Origins", 83)
    chunk = chunk[:end]
    idx = [i for i, ln in enumerate(chunk) if heading_level(ln) == 2 and ln.text.strip() in CLASS_NAMES]
    classes: list[CharacterClass] = []
    subclasses: list[Subclass] = []
    for n, i in enumerate(idx):
        cls_lines = chunk[i + 1: idx[n + 1] if n + 1 < len(idx) else len(chunk)]
        name = chunk[i].text.strip()
        cid = slug(name)
        first_h3 = next(k for k, ln in enumerate(cls_lines) if heading_level(ln) == 3)
        core = parse_core_traits(cls_lines[:first_h3])
        secs = relocate_tables(segment(cls_lines[first_h3:], min_level=3, max_level=4))
        blocks: list[Block] = []
        features: list[Feature] = []
        cur_sub: Subclass | None = None
        h3 = ""
        for s in secs:
            if s.level == 3:
                h3 = s.title
                if "Subclass:" in s.title:
                    sub_name = s.title.split("Subclass:", 1)[1].strip()
                    cur_sub = Subclass(
                        id=slug(sub_name), name=sub_name, class_id=cid, features=[],
                        blocks=to_blocks(s.lines),
                        source=SourceRef(page=s.page, heading=["Classes", name, s.title]))
                    subclasses.append(cur_sub)
                else:
                    cur_sub = None
                    blocks.append(_heading_block(s.title, 3))
                    blocks += to_blocks(s.lines)
                continue
            fm = FEATURE_RE.match(s.title)
            if fm and (cur_sub is not None or h3.endswith("Class Features")):
                f = Feature(level=int(fm.group(1)), name=fm.group(2), blocks=to_blocks(s.lines))
                (cur_sub.features if cur_sub else features).append(f)
                if cur_sub:
                    cur_sub.source.page_end = s.last_page
            elif cur_sub is not None:
                cur_sub.blocks += [_heading_block(s.title, 4), *to_blocks(s.lines)]
            else:
                blocks.append(_heading_block(s.title, 4))
                blocks += to_blocks(s.lines)
        # Hoist the "<Class> Features" progression table to the class level.
        for f in features:
            keep = []
            for bl in f.blocks:
                if bl.type == "table" and (bl.title or "").endswith("Features"):
                    blocks.insert(0, bl)
                else:
                    keep.append(bl)
            f.blocks = keep
        last = cls_lines[-1].page if cls_lines else chunk[i].page
        classes.append(CharacterClass(
            id=cid, name=name, core_traits=core, blocks=blocks, features=features,
            subclasses=[sc.id for sc in subclasses if sc.class_id == cid],
            source=SourceRef(page=chunk[i].page, page_end=last, heading=["Classes", name])))
    return classes, subclasses


# ---------------------------------------------------------------- origins

def _labelled_fields(lines: list[Line], labels: list[str]) -> tuple[dict[str, str], list[Line]]:
    """Read leading 'Label: value' lines (GillSans), return fields and remaining lines."""
    fields: dict[str, str] = {}
    last = None
    i = 0
    rx = re.compile(r"^(" + "|".join(re.escape(x) for x in labels) + r"):\s*(.*)$")
    while i < len(lines) and lines[i].font.startswith("GillSans"):
        t = lines[i].text.strip()
        m = rx.match(t)
        if m:
            last = m.group(1)
            fields[last] = m.group(2)
        elif last:
            fields[last] = join_text([fields[last], t])
        else:
            break
        i += 1
    return {k: tidy_markdown(v) for k, v in fields.items()}, lines[i:]


def parse_origins(lines: list[Line]) -> tuple[list[Background], list[Species]]:
    a, b = CHAPTERS["origins"]
    secs = relocate_tables(segment(lines_between(lines, a, b), max_level=4))
    bgs: list[Background] = []
    species: list[Species] = []
    for s in secs:
        if s.level != 4:
            continue
        if s.path[-1:] == ("Background Descriptions",):
            f, _ = _labelled_fields(s.lines, ["Ability Scores", "Feat", "Skill Proficiencies",
                                              "Tool Proficiency", "Equipment"])
            bgs.append(Background(
                id=slug(s.title), name=s.title,
                ability_scores=[x.strip() for x in f["Ability Scores"].split(",")],
                feat=f["Feat"], skill_proficiencies=f["Skill Proficiencies"],
                tool_proficiency=f["Tool Proficiency"], equipment=f["Equipment"],
                source=src(s)))
        elif s.path[-1:] == ("Species Descriptions",):
            f, rest = _labelled_fields(s.lines, ["Creature Type", "Size", "Speed"])
            blocks, traits = split_runins(to_blocks(rest))
            # Paragraphs that continue a trait (no run-in label) stay as blocks.
            species.append(Species(
                id=slug(s.title), name=s.title, creature_type=f["Creature Type"],
                size=f["Size"], speed=f["Speed"], blocks=blocks, traits=traits,
                source=src(s)))
    return bgs, species


# ---------------------------------------------------------------- feats

def parse_feats(lines: list[Line]) -> list[Feat]:
    a, b = CHAPTERS["feats"]
    secs = segment(lines_between(lines, a, b), max_level=4)
    out: list[Feat] = []
    for s in secs:
        if s.level != 4 or not s.path or not s.path[-1].endswith("Feats"):
            continue
        ls = s.lines
        cat_line = ls[0].text.strip() if ls and "Italic" in ls[0].font else ""
        m = re.match(r"^(?P<cat>.+? Feat)(?: \(Prerequisite: (?P<pre>.+)\))?$", cat_line)
        body = ls[1:] if cat_line else ls
        # Prerequisite may wrap onto a second italic line.
        if cat_line and not m and len(ls) > 1:
            cat_line = join_text([cat_line, ls[1].text])
            m = re.match(r"^(?P<cat>.+? Feat)(?: \(Prerequisite: (?P<pre>.+)\))?$", cat_line)
            body = ls[2:]
        blocks = to_blocks(body)
        rep = None
        keep = []
        for bl in blocks:
            mm = RUNIN_RE.match(bl.text or "") if bl.type == "p" else None
            if mm and mm.group("name").startswith("Repeatable"):
                rep = mm.group("text")
            keep.append(bl)
        out.append(Feat(
            id=slug(s.title), name=s.title,
            category=(m.group("cat").replace(" Feat", "") if m else s.path[-1].replace(" Feats", "")),
            prerequisite=m.group("pre") if m else None, repeatable=rep, blocks=keep,
            source=src(s)))
    return out


# ---------------------------------------------------------------- equipment

COST_RE = re.compile(r"^[\d,]+ (CP|SP|EP|GP|PP)$|^Varies$")
WEIGHT_RE = re.compile(r"lb\.$|^—$|^Varies$")
PRICE_IN_TITLE = re.compile(r"^(?P<name>.+?) \((?P<cost>[^)]*)\)$")


def _weight_cost(cells: list[str]) -> tuple[str, str]:
    tail = [c for c in cells if c]
    cost = tail[-1] if tail and COST_RE.match(tail[-1]) else ""
    weight = tail[-2] if len(tail) >= 2 and WEIGHT_RE.search(tail[-2]) else ""
    return weight, cost


def parse_equipment(lines: list[Line]) -> tuple[list[EquipmentItem], list[WeaponProperty], list[WeaponMastery]]:
    a, b = CHAPTERS["equipment"]
    chunk = lines_between(lines, a, b)
    end = section_lines(chunk, "Spells", 104)
    secs = segment(chunk[:end], max_level=5)
    items: dict[str, EquipmentItem] = {}
    props: list[WeaponProperty] = []
    masteries: list[WeaponMastery] = []

    def add(item: EquipmentItem):
        if item.id in items:
            old = items[item.id]
            old.fields.update({k: v for k, v in item.fields.items() if v})
            old.blocks += item.blocks
        else:
            items[item.id] = item

    for s in secs:
        parent = s.path[-1] if s.path else ""
        if s.level == 4 and parent == "Properties":
            props.append(WeaponProperty(id=slug(s.title), name=s.title,
                                        text="\n\n".join(md_paragraphs(s.lines)), source=src(s)))
        elif s.level == 4 and parent == "Mastery Properties":
            masteries.append(WeaponMastery(id=slug(s.title), name=s.title,
                                           text="\n\n".join(md_paragraphs(s.lines)), source=src(s)))
        elif s.level == 5 and s.title in ("Weapons", "Armor"):
            t = build_table(s.title, [ln for ln in s.lines if is_table_line(ln)])
            sub = None
            for r in t.rows:
                if r[0] and not any(r[1:]):
                    sub = r[0]
                    continue
                if not r[0]:
                    continue
                weight, cost = _weight_cost(r[1:])
                if s.title == "Weapons":
                    f = {"Damage": r[1], "Properties": r[2], "Mastery": r[3], "Weight": weight, "Cost": cost}
                    cat = "weapon"
                else:
                    f = {"Armor Class (AC)": r[1], "Strength": r[2], "Stealth": r[3], "Weight": weight, "Cost": cost}
                    cat = "armor"
                add(EquipmentItem(id=slug(r[0]), name=r[0], category=cat, subcategory=sub, fields=f,
                                  source=SourceRef(page=s.page, heading=["Equipment", s.title, sub or ""])))
        elif s.level == 5 and s.title in ("Adventuring Gear", "Mounts and Other Animals",
                                          "Tack, Harness, and Drawn Vehicles",
                                          "Airborne and Waterborne Vehicles"):
            t = build_table(s.title, [ln for ln in s.lines if is_table_line(ln)])
            cat = {"Adventuring Gear": "gear", "Mounts and Other Animals": "mount"}.get(s.title, "vehicle")
            for r in t.rows:
                if not r[0] or r[0] in ("Weight",):
                    continue
                cells = [c for c in r[1:] if c]
                f: dict[str, str] = {}
                if cat == "gear":
                    f["Weight"], f["Cost"] = _weight_cost(r[1:])
                else:
                    hdr = [h for h in t.header[1:] if h]
                    for k, v in zip(hdr + ["Cost"] * 3, cells):
                        f.setdefault(k, v)
                add(EquipmentItem(id=slug(r[0]), name=r[0], category=cat, fields=f,
                                  source=SourceRef(page=s.page, heading=["Equipment", s.title])))
        elif s.level == 4 and (parent in ("Artisan’s Tools", "Other Tools") or "Adventuring Gear" in s.path):
            m = PRICE_IN_TITLE.match(s.title)
            name, cost = (m.group("name"), m.group("cost")) if m else (s.title, "")
            cat = "tool" if parent in ("Artisan’s Tools", "Other Tools") else "gear"
            f: dict[str, str] = {"Cost": cost}
            blocks = to_blocks(s.lines)
            if cat == "tool":
                keep = []
                for bl in blocks:
                    parts = re.split(r"\*\*([^*]+?):\*\*", bl.text or "") if bl.type == "p" else [""]
                    if len(parts) > 1 and not parts[0].strip():
                        for k, v in zip(parts[1::2], parts[2::2]):
                            f[k.strip()] = v.strip()
                    else:
                        keep.append(bl)
                blocks = keep
            add(EquipmentItem(id=slug(name), name=name, category=cat,
                              subcategory=parent if cat == "tool" else None,
                              fields=f, blocks=blocks, source=src(s)))
    return list(items.values()), props, masteries
