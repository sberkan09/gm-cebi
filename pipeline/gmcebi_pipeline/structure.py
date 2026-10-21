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


def segment(lines: list[Line], min_level: int = 1, max_level: int = 5) -> list[Section]:
    """Split lines into a flat list of sections, each with its heading path."""
    out: list[Section] = []
    stack: list[tuple[int, str]] = []
    cur = Section(0, "", lines[0].page if lines else 0)
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
                j = i + 1
                while j < len(sec.lines) and is_table_line(sec.lines[j]):
                    j += 1
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
    for ln in lines:
        raw = ln.text
        first = ln.spans[0]
        new = (raw.lstrip(" ").startswith("\t") or raw.lstrip().startswith("•")
               # Bold (not bold-italic) run-in sub-options such as "Forest Gnome."
               or (first.font.endswith("-Bold") and first.text.strip().endswith(".")))
        if new or not paras:
            paras.append([])
        paras[-1].append(line_markdown(ln))
    return [p for p in (tidy_markdown(join_text(x)) for x in paras) if p]


# ---------------------------------------------------------------- tables

def is_table_line(ln: Line) -> bool:
    return ln.font.startswith("GillSans") and 8.9 <= ln.size <= 9.9 and "SC700" not in ln.font


def is_table_header(ln: Line) -> bool:
    return ln.font.startswith("GillSans-SemiBold") and abs(ln.size - 9.2) < 0.15


@dataclass
class Table:
    title: str
    header: list[str]
    rows: list[list[str]]
    page: int


def _build_segment(lines: list[Line]) -> tuple[list[str], list[list[str]]]:
    head = [ln for ln in lines if is_table_header(ln)]
    body = sorted((ln for ln in lines if not is_table_header(ln)), key=lambda l: l.y0)
    xs = sorted({round(ln.x0) for ln in body} or {round(h.x0) for h in head})
    anchors: list[float] = []
    for x in xs:
        if not anchors or x - anchors[-1] > 14:
            anchors.append(x)
    if not anchors:
        return [], []

    def col(x: float) -> int:
        idx = 0
        for i, a in enumerate(anchors):
            if x >= a - 6:
                idx = i
        return idx

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
        starts_row = 0 in cols and not (only_first and lower_start and rows)
        if starts_row or not rows:
            rows.append([[] for _ in anchors])
        for ln in sorted(cl, key=lambda l: l.x0):
            rows[-1][col(ln.x0)].append(ln.text)
    clean = [[tidy_markdown(join_text(cell)) for cell in r] for r in rows]
    keep = [i for i in range(len(anchors)) if header[i] or any(r[i] for r in clean)]
    return [header[i] for i in keep], [[r[i] for i in keep] for r in clean]


def build_table(title: str, lines: list[Line]) -> Table:
    """Rebuild a table; a repeated header (page/column break) starts a new segment."""
    page = lines[0].page if lines else 0
    segments: list[list[Line]] = []
    seen_body = False
    for ln in lines:
        if is_table_header(ln) and (seen_body or not segments):
            segments.append([])
            seen_body = False
        if not is_table_header(ln):
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
            j = i
            while j < n and is_table_line(lines[j]):
                j += 1
            flush_para()
            t = build_table("", lines[i:j])
            blocks.append({"type": "table", "header": t.header, "rows": t.rows, "page": t.page})
            i = j
            continue
        para_buf.append(ln)
        i += 1
    flush_para()
    return blocks
