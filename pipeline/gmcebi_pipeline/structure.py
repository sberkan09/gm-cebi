"""Section segmentation, markdown rendering and table reconstruction."""

from __future__ import annotations

import re
from dataclasses import dataclass, field

from .extract import Line, join_text

HEADING_LEVEL = {"h1": 1, "h2": 2, "h3": 3, "h4": 4, "h5": 5}


@dataclass
class Section:
    level: int
    title: str
    page: int
    lines: list[Line] = field(default_factory=list)
    path: tuple[str, ...] = ()

    @property
    def last_page(self) -> int:
        return self.lines[-1].page if self.lines else self.page


def heading_level(line: Line) -> int | None:
    st = line.style()
    if st in HEADING_LEVEL:
        return HEADING_LEVEL[st]
    if st == "sc" and line.size >= 11.5 and "SemiBold" in line.font:
        return 4  # small-caps spell/entry names use the h4 slot
    return None


# ---------------------------------------------------------------- sidebars
# Boxed sidebars ("Heroic Inspiration", "Marching Order") have a small-caps GillSans 11pt
# title and GillSans 9pt body text; no other text in the SRD uses 9pt GillSans. The layout
# engine emits a sidebar wherever the box happens to sit in the content stream, often in the
# middle of a sentence that runs on from one column to the next.

def is_sidebar_title(line: Line) -> bool:
    return "SC700" in line.font and abs(line.size - 11) < 0.3 and heading_level(line) is None


def is_sidebar_body(line: Line) -> bool:
    return line.font.startswith("GillSans") and abs(line.size - 9.0) < 0.05


def is_sidebar(line: Line) -> bool:
    return is_sidebar_title(line) or is_sidebar_body(line)


def lift_sidebars(lines: list[Line]) -> list[Line]:
    """Move each sidebar out of the text it interrupts to the end of that (sub)section.

    A sidebar is re-emitted just before the next heading of level 1-4, so the paragraph it
    split reads continuously and the text after the sidebar's own "### Title" is only the
    sidebar. A sidebar printed on the opening page of a chapter, which the content stream
    puts before the chapter title, is moved after that title (it opens the chapter).
    """
    out: list[Line] = []
    pending: list[Line] = []
    i, n = 0, len(lines)
    while i < n:
        ln = lines[i]
        if is_sidebar_title(ln):
            pending.append(ln)
            i += 1
            while i < n and is_sidebar_body(lines[i]):
                pending.append(lines[i])
                i += 1
            continue
        lvl = heading_level(ln)
        if pending and lvl is not None and lvl <= 4:
            if lvl == 1 and all(p.page == ln.page for p in pending):
                out.append(ln)
                out += pending
            else:
                out += pending
                out.append(ln)
            pending = []
        else:
            out.append(ln)
        i += 1
    return out + pending


def segment(lines: list[Line], min_level: int = 1, max_level: int = 5,
            keep_preamble: bool = False) -> list[Section]:
    """Split lines into a flat list of sections, each with its heading path.

    Lines before the first heading are dropped unless `keep_preamble` is set; then they
    come first as a level-0 section with an empty title (only if there are any).
    """
    out: list[Section] = []
    stack: list[tuple[int, str]] = []
    cur = Section(0, "", lines[0].page if lines else 0)
    if keep_preamble:
        out.append(cur)
    for ln in lines:
        lvl = heading_level(ln)
        if lvl is not None and min_level <= lvl <= max_level:
            # Multi-line headings: same level, directly below, same column.
            prev = out[-1] if out else None
            if (
                prev is cur
                and not cur.lines
                and cur.level == lvl
                and ln.page == cur.page
                and abs(ln.x0 - getattr(cur, "_x", ln.x0)) < 3
            ):
                cur.title = (cur.title + " " + ln.text.strip()).strip()
                continue
            while stack and stack[-1][0] >= lvl:
                stack.pop()
            path = tuple(t for _, t in stack)
            title = ln.text.strip()
            stack.append((lvl, title))
            cur = Section(lvl, title, ln.page, [], path)
            cur._x = ln.x0  # type: ignore[attr-defined]
            out.append(cur)
        else:
            cur.lines.append(ln)
    if keep_preamble and not out[0].lines:
        out.pop(0)
    return out


def relocate_tables(secs: list[Section]) -> list[Section]:
    """Move floating titled tables to the section that refers to them.

    The layout engine sometimes emits a table (h5 title + rows) inside the
    section that happens to precede it in the content stream. If the hosting
    section never mentions "<title> table" but another one does, move it.
    """
    texts = [" ".join(ln.text for ln in sec.lines).replace("\t", " ") for sec in secs]
    for si, sec in enumerate(secs):
        i = 0
        while i < len(sec.lines):
            ln = sec.lines[i]
            if ln.style() == "h5" and i + 1 < len(sec.lines) and is_table_header(sec.lines[i + 1]):
                j = table_end(sec.lines, i + 1)
                title = ln.text.strip()
                needle = f"{title} table"
                own = needle.lower() in re.sub(r"\s+", " ", texts[si]).lower() or sec.title == title
                if not own:
                    owners = [k for k, t in enumerate(texts)
                              if k != si and needle.lower() in re.sub(r"\s+", " ", t).lower()]
                    if len(owners) == 1:
                        chunk = sec.lines[i:j]
                        del sec.lines[i:j]
                        secs[owners[0]].lines.extend(chunk)
                        continue
                i = j
                continue
            i += 1
    return secs


# ---------------------------------------------------------------- markdown

def _span_kind(font: str) -> str:
    if "Bold" in font or "SemiBold" in font:
        return "b"
    if "Italic" in font:
        return "i"
    return "n"


def line_markdown(line: Line) -> str:
    runs: list[list[str]] = []
    for s in line.spans:
        k = _span_kind(s.font)
        if runs and runs[-1][0] == k:
            runs[-1][1] += s.text
        else:
            runs.append([k, s.text])
    out = []
    for k, t in runs:
        if k == "n" or not t.strip():
            out.append(t)
            continue
        lead = t[: len(t) - len(t.lstrip())]
        trail = t[len(t.rstrip()):]
        mark = "**" if k == "b" else "*"
        out.append(f"{lead}{mark}{t.strip()}{mark}{trail}")
    return "".join(out)


def tidy_markdown(text: str) -> str:
    text = re.sub(r"\*\*\s*\*\*", " ", text)
    text = re.sub(r"(?<!\*)\*\s+\*(?!\*)", " ", text)
    text = text.replace(" ", " ").replace("‑", "-")
    text = re.sub("­\\s*(?=[a-z])", "", text).replace("­", "")
    text = re.sub(r"^[••]\s*", "- ", text)
    return re.sub(r"[ \t]+", " ", text).strip()


def md_paragraphs(lines: list[Line]) -> list[str]:
    """Paragraphs (markdown) split on tab-indent / bullet markers."""
    paras: list[list[str]] = []
    prev: Line | None = None
    for ln in lines:
        raw = ln.text
        first = ln.spans[0]
        new = (raw.lstrip(" ").startswith("\t") or raw.lstrip().startswith("•")
               # Bold (not bold-italic) run-in sub-options such as "Forest Gnome."
               or (first.font.endswith("-Bold") and first.text.strip().endswith("."))
               # "Rituals" + "." as two spans, after a finished sentence (not a bold
               # creature name wrapped onto the next line: "**Riding**" / "**Horse**.").
               or (first.font.endswith("-Bold") and raw[len(first.text):].startswith(".")
                   and prev is not None and prev.text.rstrip().endswith((".", ":")))
               # Sidebar text never continues a main-text paragraph, or the reverse.
               or (prev is not None and is_sidebar_body(prev) != is_sidebar_body(ln)))
        prev = ln
        if new or not paras:
            paras.append([])
        paras[-1].append(line_markdown(ln))
    return [p for p in (tidy_markdown(join_text(x)) for x in paras) if p]


# ---------------------------------------------------------------- tables

def is_table_line(ln: Line) -> bool:
    # 9pt GillSans is sidebar text, never a table cell (tables use 9.2-9.8pt).
    return ln.font.startswith("GillSans") and 9.1 <= ln.size <= 9.9 and "SC700" not in ln.font


def is_table_header(ln: Line) -> bool:
    return ln.font.startswith("GillSans-SemiBold") and abs(ln.size - 9.2) < 0.15


def _on_baseline(ln: Line, ref: Line | None) -> bool:
    """A header cell set in another weight or size ("Speed", "Cost") on a header row."""
    return ref is not None and ln.page == ref.page and abs(ln.y0 - ref.y0) < 2


def _header_text(lines: list[Line], i: int) -> str:
    """Normalised text of the header row group starting at lines[i]."""
    group: list[Line] = []
    ref: Line | None = None
    while i < len(lines) and (is_table_header(lines[i])
                              or (is_table_line(lines[i]) and _on_baseline(lines[i], ref))):
        if is_table_header(lines[i]):
            ref = lines[i]
        group.append(lines[i])
        i += 1
    txt = " ".join(ln.text for ln in sorted(group, key=lambda l: (round(l.y0), l.x0)))
    return re.sub(r"[^a-z0-9]+", "", txt.lower())


def table_end(lines: list[Line], i: int) -> int:
    """End (exclusive) of the table whose header row starts at lines[i].

    The run continues over table lines, including a repeated header row (the table
    resumes after a page or column break). A header row with different text is a new
    table that only happens to follow in the content stream, so it ends this one.
    """
    head = _header_text(lines, i)
    j, seen_body = i, False
    ref: Line | None = None
    while j < len(lines) and is_table_line(lines[j]):
        ln = lines[j]
        if is_table_header(ln):
            if seen_body and _header_text(lines, j) != head:
                break
            ref = ln
            seen_body = False
        elif not _on_baseline(ln, ref):
            seen_body = True
        j += 1
    return j


def same_header(a: list[str], b: list[str]) -> bool:
    norm = lambda h: re.sub(r"[^a-z0-9]+", "", " ".join(h).lower())  # noqa: E731
    return bool(a) and norm(a) == norm(b)


@dataclass
class Table:
    title: str
    header: list[str]
    rows: list[list[str]]
    page: int


def _header_ids(lines: list[Line]) -> set[int]:
    """Header-row lines. Cells set in another weight or size ("Cost", "Encounter
    Distance") count too: they sit on the baseline of a header-font line."""
    at = [(h.page, h.y0) for h in lines if is_table_header(h)]
    return {id(ln) for ln in lines
            if is_table_header(ln) or any(p == ln.page and abs(y - ln.y0) < 2 for p, y in at)}


def _split_merged(ln: Line, anchors: list[float]) -> list[Line]:
    """Split a line that holds two cells ("Barbarian" + "Battle") where a span starts
    exactly at a later column's anchor after a gap."""
    out: list[Line] = []
    start = 0
    for k, sp in enumerate(ln.spans):
        if (k and sp.text.strip() and not ln.spans[k - 1].text.strip()
                and any(a > ln.x0 + 14 and abs(sp.x0 - a) <= 3 for a in anchors)):
            out.append(ln.spans[start:k])
            start = k
    if not out:
        return [ln]
    out.append(ln.spans[start:])
    pieces = []
    for spans in out:
        spans = [sp for sp in spans if sp.text.strip()] or spans
        pieces.append(Line(ln.page, spans[0].x0 if pieces else ln.x0, ln.y0, spans, spans[-1].x1))
    return pieces


def _build_segment(lines: list[Line]) -> tuple[list[str], list[list[str]]]:
    hid = _header_ids(lines)
    head = [ln for ln in lines if id(ln) in hid]
    body = sorted((ln for ln in lines if id(ln) not in hid), key=lambda l: l.y0)
    xs = sorted({round(ln.x0) for ln in body} or {round(h.x0) for h in head})
    anchors: list[float] = []
    for x in xs:
        if not anchors or x - anchors[-1] > 14:
            anchors.append(x)
    if not anchors:
        return [], []
    body = [piece for ln in body for piece in _split_merged(ln, anchors)]

    raw = list(anchors)

    def raw_col(x: float) -> int:
        idx = 0
        for i, a in enumerate(raw):
            if x >= a - 6:
                idx = i
        return idx

    # Right-aligned or centred columns ("2,700" / "355,000") start at varying x: neighbouring
    # anchors whose lines all share one right edge or one centre are a single column.
    members: list[list[Line]] = [[] for _ in anchors]
    for ln in body:
        members[raw_col(ln.x0)].append(ln)
    groups: list[list[int]] = []
    for i in range(len(anchors)):
        if groups and members[i]:
            union = [ln for g in groups[-1] for ln in members[g]] + members[i]
            r = [ln.x1 for ln in union]
            c = [(ln.x0 + ln.x1) / 2 for ln in union]
            if max(r) - min(r) <= 2 or max(c) - min(c) <= 3:
                groups[-1].append(i)
                continue
        groups.append([i])
    gmap = {i: n for n, g in enumerate(groups) for i in g}
    anchors = [anchors[g[0]] for g in groups]

    def col(x: float) -> int:
        return gmap[raw_col(x)]

    centers: list[list[float]] = [[] for _ in anchors]
    for ln in body:
        centers[col(ln.x0)].append((ln.x0 + ln.x1) / 2)
    mid = [sorted(c)[len(c) // 2] if c else anchors[i] for i, c in enumerate(centers)]

    def head_col(h: Line) -> int:
        for i, a in enumerate(anchors):
            if abs(h.x0 - a) <= 6:
                return i
        hc = (h.x0 + h.x1) / 2
        # A header can't sit left of its column's start by more than a little.
        return min(range(len(anchors)), key=lambda i: abs(hc - mid[i]) + (50 if h.x1 < anchors[i] else 0))

    header = [""] * len(anchors)
    for h in sorted(head, key=lambda l: (l.y0, l.x0)):
        # Drop decorative group labels such as "——Spell Slots per Spell Level——".
        txt = re.sub(r"—+[^—\d]+—+\s*", "", h.text).strip()
        if not txt:
            continue
        c = head_col(h)
        header[c] = (header[c] + " " + txt).strip()
    clusters: list[list[Line]] = []
    for ln in body:
        if clusters and abs(ln.y0 - clusters[-1][0].y0) < 4:
            clusters[-1].append(ln)
        else:
            clusters.append([ln])
    rows: list[list[list[str]]] = []
    for cl in clusters:
        cols = {col(ln.x0) for ln in cl}
        only_first = cols == {0}
        lower_start = cl[0].text.strip()[:1].islower()
        # A first-column line that continues a wrapped cell ("Bard, Cleric, Druid, Monk," /
        # "Rogue, or Warlock") starts lower-case or follows a trailing comma.
        after_comma = bool(rows and rows[-1][0] and rows[-1][0][-1].rstrip().endswith(","))
        starts_row = 0 in cols and not (only_first and (lower_start or after_comma) and rows)
        if starts_row or not rows:
            rows.append([[] for _ in anchors])
        for ln in sorted(cl, key=lambda l: l.x0):
            rows[-1][col(ln.x0)].append(ln.text)
    clean = [[tidy_markdown(join_text(cell)) for cell in r] for r in rows]
    keep = [i for i in range(len(anchors)) if header[i] or any(r[i] for r in clean)]
    return [header[i] for i in keep], [[r[i] for i in keep] for r in clean]


def build_table(title: str, lines: list[Line]) -> Table:
    """Rebuild a table; a repeated header (page/column break) starts a new segment.

    Callers cut `lines` with table_end(), so every header row here repeats the first.
    """
    page = lines[0].page if lines else 0
    segments: list[list[Line]] = []
    seen_body = False
    hid = _header_ids(lines)
    for ln in lines:
        if id(ln) in hid and (seen_body or not segments):
            segments.append([])
            seen_body = False
        if id(ln) not in hid:
            seen_body = True
        if not segments:
            segments.append([])
        segments[-1].append(ln)
    header: list[str] = []
    rows: list[list[str]] = []
    for seg in segments:
        h, r = _build_segment(seg)
        if not header:
            header = h
        rows += r
    # Two copies of a narrow table side by side (Rarity | Value | Rarity | Value): stack them.
    half = len(header) // 2
    if half >= 2 and len(header) % 2 == 0 and header[:half] == header[half:] and all(header):
        rows = [r[:half] for r in rows] + [r[half:] for r in rows if any(r[half:])]
        header = header[:half]
    return Table(title, header, rows, page)


def split_blocks(lines: list[Line]) -> list[dict]:
    """Split section content into paragraph and table blocks.

    A table is a run of GillSans 9-9.8pt lines that contains a header row;
    an h5 title immediately before it (already consumed as a heading by the
    segmenter) is passed in by callers when needed.
    """
    blocks: list[dict] = []
    i = 0
    n = len(lines)
    para_buf: list[Line] = []

    def flush_para():
        if para_buf:
            for p in md_paragraphs(para_buf):
                blocks.append({"type": "p", "text": p})
            para_buf.clear()

    while i < n:
        ln = lines[i]
        if is_table_header(ln):
            j = table_end(lines, i)
            flush_para()
            t = build_table("", lines[i:j])
            blocks.append({"type": "table", "header": t.header, "rows": t.rows, "page": t.page})
            i = j
            continue
        para_buf.append(ln)
        i += 1
    flush_para()
    return blocks
