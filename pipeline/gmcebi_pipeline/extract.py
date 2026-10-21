"""Low-level PDF extraction for SRD 5.2.1.

Turns the PDF into a flat stream of styled lines in content-stream order
(which matches reading order for this document), with running headers and
footers removed. Higher-level parsers work on this stream.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

import pymupdf

FOOTER_Y = 735  # page number / document title live below this line
SOFT_HYPHEN_RE = re.compile(r"(?<=[a-z])-$")


@dataclass
class Span:
    text: str
    font: str
    size: float

    @property
    def bold(self) -> bool:
        return "Bold" in self.font or "SemiBold" in self.font

    @property
    def italic(self) -> bool:
        return "Italic" in self.font


@dataclass
class Line:
    page: int
    x0: float
    y0: float
    spans: list[Span] = field(default_factory=list)
    x1: float = 0.0

    @property
    def text(self) -> str:
        return "".join(s.text for s in self.spans)

    @property
    def font(self) -> str:
        for s in self.spans:
            if s.text.strip():
                return s.font
        return self.spans[0].font if self.spans else ""

    @property
    def size(self) -> float:
        for s in self.spans:
            if s.text.strip():
                return s.size
        return self.spans[0].size if self.spans else 0.0

    @property
    def starts_paragraph(self) -> bool:
        return self.text.startswith("\t")

    def style(self) -> str:
        """Coarse style class used by parsers."""
        f, sz = self.font, self.size
        if "GillSans-SemiBold" in f and "SC700" not in f:
            if sz >= 25:
                return "h1"
            if sz >= 17:
                return "h2"
            if sz >= 13.5:
                return "h3"
            if sz >= 11.5:
                return "h4"
            if sz >= 10.4:
                return "h5"
        if "SC700" in f:
            return "sc"  # small-caps heading (spell names, stat labels)
        return "body"


def load_lines(pdf_path: Path | str) -> list[Line]:
    doc = pymupdf.open(str(pdf_path))
    out: list[Line] = []
    for pno, page in enumerate(doc, start=1):
        for block in page.get_text("dict")["blocks"]:
            for raw in block.get("lines", []):
                spans = [
                    Span(s["text"], s["font"], round(s["size"], 1))
                    for s in raw["spans"]
                    if s["text"]
                ]
                if not spans or not "".join(s.text for s in spans).strip():
                    continue
                x0, y0, x1 = raw["bbox"][0], raw["bbox"][1], raw["bbox"][2]
                if y0 > FOOTER_Y:
                    continue
                out.append(Line(pno, round(x0, 1), round(y0, 1), spans, round(x1, 1)))
    return out


def join_text(lines: list[str]) -> str:
    """Join wrapped lines, undoing typographic hyphenation."""
    buf = ""
    for raw in lines:
        t = raw.replace("\t", " ").strip()
        if not t:
            continue
        styled = re.search(r"(?<=[a-z])-(\*{1,2})$", buf)
        if not buf:
            buf = t
        elif styled and t.startswith(styled.group(1)) and t[len(styled.group(1)):][:1].islower():
            # "*Presti-*" + "*digitation*" -> "*Prestidigitation*"
            buf = buf[: styled.start()] + t[len(styled.group(1)):]
        elif SOFT_HYPHEN_RE.search(buf) and t[:1].islower():
            buf = buf[:-1] + t
        elif re.search(r"\d-$", buf) and t[:1].islower():
            buf += t  # "10-" + "foot" -> "10-foot"
        elif buf.endswith(("—", "–")):
            buf += t
        else:
            buf += " " + t
    return re.sub(r"\s+", " ", buf).strip()


def paragraphs(lines: list[Line]) -> list[str]:
    """Group body lines into paragraphs using the tab-indent marker."""
    paras: list[list[str]] = []
    for ln in lines:
        if ln.starts_paragraph or not paras:
            paras.append([])
        paras[-1].append(ln.text)
    return [p for p in (join_text(x) for x in paras) if p]
