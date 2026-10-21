"""Glossary loading and term-consistency checks.

glossary.csv is the single source of truth for Turkish rules terms. A row
with enforce=yes means: whenever the English pattern occurs in a source
segment, the Turkish term (or an inflected form of it) must occur in the
translation. Turkish is agglutinative, so matching uses a stem: for
multi-word terms whose last word ends in a compound (izafet) suffix
(Can Puanı → Can Puan-) the suffix is dropped, and a final p/ç/t/k may
soften (Kitap → Kitabı).
"""

from __future__ import annotations

import csv
import re
from dataclasses import dataclass, field
from functools import cached_property
from pathlib import Path

from .textutil import tr_lower

GLOSSARY_PATH = Path(__file__).resolve().parents[1] / "glossary.csv"
STATUSES = {"topluluk", "öneri", "tartışmalı"}
FIELDS = ["id", "en", "tr", "category", "status", "alternatives", "note", "evidence", "enforce", "en_pattern"]

_IZAFET = re.compile(r"(?<=\w)(sı|si|su|sü|ı|i|u|ü)$")
_SOFTEN = {"p": "[pb]", "ç": "[çc]", "t": "[td]", "k": "[kğ]", "ğ": "[ğk]"}


@dataclass
class Term:
    id: str
    en: str
    tr: str
    category: str
    status: str
    alternatives: list[str] = field(default_factory=list)
    note: str = ""
    evidence: str = ""
    enforce: bool = True
    en_pattern: str = ""

    @cached_property
    def en_re(self) -> re.Pattern[str]:
        if self.en_pattern:
            return re.compile(self.en_pattern)
        return re.compile(r"\b" + re.escape(self.en) + r"s?\b")

    @cached_property
    def tr_re(self) -> re.Pattern[str]:
        words = tr_lower(self.tr).split()
        last = words[-1]
        if len(words) > 1:
            stem = _IZAFET.sub("", last) if len(last) >= 4 else last
        else:
            stem = last
        if stem and stem[-1] in _SOFTEN and len(stem) > 2:
            stem_re = re.escape(stem[:-1]) + _SOFTEN[stem[-1]]
        else:
            stem_re = re.escape(stem)
        parts = [re.escape(w) for w in words[:-1]] + [stem_re]
        # Allow inflection and apostrophe suffixes after the last word.
        return re.compile(r"(?<!\w)" + r"\s+".join(parts) + r"[\w'’]*", re.UNICODE)

    def found_in_tr(self, tr_text: str) -> bool:
        return bool(self.tr_re.search(tr_lower(tr_text)))


class Glossary:
    def __init__(self, terms: list[Term]):
        self.terms = terms
        # Longest English surface first, so "Bonus Action" masks "Action".
        self.enforced = sorted((t for t in terms if t.enforce), key=lambda t: -len(t.en))

    @classmethod
    def load(cls, path: Path = GLOSSARY_PATH) -> "Glossary":
        with path.open(encoding="utf-8", newline="") as f:
            rows = list(csv.DictReader(f))
        terms = []
        for r in rows:
            terms.append(Term(
                id=r["id"], en=r["en"], tr=r["tr"], category=r["category"], status=r["status"],
                alternatives=[a for a in r["alternatives"].split("|") if a],
                note=r["note"], evidence=r["evidence"], enforce=r["enforce"].strip() == "yes",
                en_pattern=r["en_pattern"],
            ))
        return cls(terms)

    def validate(self) -> list[str]:
        """Structural checks on the glossary file itself."""
        errors = []
        ids = set()
        for t in self.terms:
            if t.id in ids:
                errors.append(f"duplicate id {t.id}")
            ids.add(t.id)
            if t.status not in STATUSES:
                errors.append(f"{t.id}: bad status {t.status!r}")
            if not t.tr.strip():
                errors.append(f"{t.id}: empty Turkish term")
            try:
                t.en_re, t.tr_re  # noqa: B018 - compile check
            except re.error as e:
                errors.append(f"{t.id}: bad pattern {e}")
        return errors

    def terms_in(self, en_text: str) -> list[Term]:
        """Enforced terms occurring in an English segment (longest match wins)."""
        spans = []
        for t in self.enforced:
            for m in t.en_re.finditer(en_text):
                spans.append((m.end() - m.start(), m.start(), m.end(), t))
        spans.sort(key=lambda s: (-s[0], s[1]))
        taken: list[tuple[int, int]] = []
        hits: list[Term] = []
        for _, a, b, t in spans:
            if any(a < e and s < b for s, e in taken):
                continue  # covered by a longer match ("Bonus Action" over "Action")
            taken.append((a, b))
            if t not in hits:
                hits.append(t)
        return hits

    def check(self, en_text: str, tr_text: str) -> list[str]:
        """Return a message per required term missing from the translation."""
        missing = []
        for t in self.terms_in(en_text):
            if not t.found_in_tr(tr_text):
                missing.append(f"term:{t.id} '{t.en}' → '{t.tr}' bulunamadı")
        return missing

    def lookup(self, en: str) -> Term | None:
        for t in self.terms:
            if t.en == en:
                return t
        return None
