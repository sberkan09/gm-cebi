"""Turkish-aware text helpers and sentence segmentation."""

from __future__ import annotations

import hashlib
import re

_TR_LOWER = str.maketrans({"I": "ı", "İ": "i"})
_TR_UPPER = str.maketrans({"i": "İ", "ı": "I"})


def tr_lower(s: str) -> str:
    """Lowercase with Turkish dotted/dotless i rules (I→ı, İ→i)."""
    return s.translate(_TR_LOWER).lower()


def tr_upper(s: str) -> str:
    return s.translate(_TR_UPPER).upper()


def tr_fold(s: str) -> str:
    """Search key: Turkish lowercase, then strip diacritics so 'cuce' finds 'Cüce'."""
    s = tr_lower(s)
    return s.translate(str.maketrans("çğıöşüâîû", "cgiosuaiu"))


def key(text: str) -> str:
    return hashlib.sha1(text.encode("utf-8")).hexdigest()[:16]


# --- sentence splitting (English source) ------------------------------------

_ABBREVS = ("ft.", "lb.", "lbs.", "e.g.", "i.e.", "vs.", "St.", "Dr.", "Mr.", "Mrs.", "No.", "etc.",
            "approx.", "in.")
# Candidate boundary: sentence punctuation, optional closing quote/bracket/markup,
# whitespace, then something that starts a sentence.
_SPLIT_RE = re.compile(r"[.!?][”\"’)\]*]*\s+(?=[\"“(*]*[A-Z0-9])")


def split_sentences(text: str) -> list[str]:
    """Split a paragraph into sentences; markdown run-in labels stay separate."""
    if not text or len(text) < 60:
        return [text] if text else []
    parts: list[str] = []
    last = 0
    for m in _SPLIT_RE.finditer(text):
        head = text[last:m.start() + 1]
        if head.rstrip().endswith(_ABBREVS):
            continue
        chunk = text[last:m.end()].strip()
        if chunk:
            parts.append(chunk)
        last = m.end()
    tail = text[last:].strip()
    if tail:
        parts.append(tail)
    # Re-attach fragments that are too short to be sentences (e.g. "1.").
    out: list[str] = []
    for p in parts:
        if out and (len(p) < 4 or re.fullmatch(r"[\d.]+", p)):
            out[-1] += " " + p
        else:
            out.append(p)
    return out


# --- invariant tokens --------------------------------------------------------

DICE_RE = re.compile(r"(?<![\w])\d*d\d+(?:\s*[+\-−]\s*\d+)?(?=s?\b)")
NUMBER_RE = re.compile(r"(?<![\w])[+\-−]?\d(?:[\d,.]*\d)?(?:/\d+)?(?:½)?")
_THOUSANDS = re.compile(r"\d{1,3}(?:[.,]\d{3})+")


def dice_tokens(text: str) -> list[str]:
    return sorted(re.sub(r"\s+", "", m.group()).replace("−", "-") for m in DICE_RE.finditer(text))


def number_tokens(text: str) -> list[str]:
    """All numbers (incl. inside dice), normalised; used to check preservation."""
    toks = []
    for m in NUMBER_RE.finditer(text):
        t = m.group().replace("−", "-").lstrip("+")
        # 1,000 (English) and 1.000 (Turkish) are the same number.
        if _THOUSANDS.fullmatch(t.lstrip("-")):
            t = t.replace(",", "").replace(".", "")
        toks.append(t)
    # dice like 2d6 contribute 2 and 6 through \d boundaries handled above
    for m in re.finditer(r"d(\d+)", text):
        toks.append(m.group(1))
    return sorted(toks)
