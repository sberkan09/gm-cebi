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
FIELDS = ["id", "en", "tr", "category", "status", "alternatives", "note", "evidence", "enforce", "en_pattern",
          "tr_pattern"]

_IZAFET = re.compile(r"(?<=\w)(sı|si|su|sü|ı|i|u|ü)$")
_SOFTEN = {"p": "[pb]", "ç": "[çc]", "t": "[td]", "k": "[kğ]", "ğ": "[ğk]"}

# Turkish inflection allowed after a glossary term, as ordered slots:
# plural, possessive, case, "-ki", copula/person. A bare prefix match ("büyü" in
# "büyük", "din" in "dinlenme") is NOT accepted. Meaning-changing derivations
# (-lı "with", -lık, -sız) are excluded; "-lı" is only allowed with a personal
# ending (Avantajlısın, Dezavantajlıdır).
def _alt(words: str) -> str:
    return "(?:" + "|".join(sorted(set(words.split()), key=len, reverse=True)) + ")"


_PLURAL = _alt("lar ler")
_POSS = _alt("""ı i u ü sı si su sü ım im um üm m ın in un ün n
                mız miz muz müz ımız imiz umuz ümüz nız niz nuz nüz ınız iniz unuz ünüz""")
_CASE = _alt("""yı yi yu yü nı ni nu nü ı i u ü a e ya ye na ne da de ta te nda nde
                dan den tan ten ndan nden la le yla yle nın nin nun nün ın in un ün ca ce""")
_COND = _alt("ysa yse sa se")
_PERSON = _alt("m n k nız niz nuz nüz lar ler")
_COPULA = _alt("""ken yken dır dir dur dür tır tir tur tür sın sin sun sün sınız siniz
                  ymış ymiş ymuş ymüş mış miş muş müş
                  lısın lisin lusun lüsün lıdır lidir ludur lüdür""")
_TAIL = (rf"(?:['’])?{_PLURAL}?{_POSS}?{_CASE}?(?:ki)?(?:{_COND}{_PERSON}?)?{_COPULA}?{_COPULA}?"
         r"(?!\w)")


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
    tr_pattern: str = ""  # optional regex over lowercased Turkish, for natural derivations

    @cached_property
    def en_re(self) -> re.Pattern[str]:
        if self.en_pattern:
            return re.compile(self.en_pattern)
        return re.compile(r"\b" + re.escape(self.en) + r"s?\b")

    @cached_property
    def tr_re(self) -> re.Pattern[str]:
        if self.tr_pattern:
            return re.compile(r"(?<!\w)(?:" + self.tr_pattern + ")" + _TAIL, re.UNICODE)
        words = tr_lower(self.tr).split()
        last = words[-1]
        stems = {last}
        if len(words) > 1 and len(last) >= 4:
            stems.add(_IZAFET.sub("", last))  # Can Puanı → Can Puan-ları (and Pasif Algı-sı keeps both)
        alts = []
        for stem in sorted(stems, key=len, reverse=True):
            if stem and stem[-1] in _SOFTEN and len(stem) > 2:
                alts.append(re.escape(stem[:-1]) + _SOFTEN[stem[-1]])
            else:
                alts.append(re.escape(stem))
        parts = [re.escape(w) for w in words[:-1]] + ["(?:" + "|".join(alts) + ")"]
        # Inflection (and an apostrophe after abbreviations/numbers) may follow the last word.
        return re.compile(r"(?<!\w)" + r"\s+".join(parts) + _TAIL, re.UNICODE)

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
                en_pattern=r["en_pattern"], tr_pattern=r.get("tr_pattern", ""),
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

    def _rejected_alternatives(self, t: Term) -> list[Term]:
        """Alternatives of `t` that must not be used instead of the chosen term.

        Skips alternatives that are themselves the chosen Turkish of another term
        (e.g. "Kuvvet" is rejected for Strength but is the term for Force) and
        English abbreviations.
        """
        if not hasattr(self, "_chosen"):
            self._chosen = {tr_lower(x.tr) for x in self.terms}
        out = []
        for alt in t.alternatives:
            a = tr_lower(alt)
            if a in self._chosen or re.fullmatch(r"[A-Z]{1,4}", alt) or alt == t.en \
                    or re.search(rf"(?<!\w){re.escape(a)}(?!\w)", tr_lower(t.tr)):
                continue
            out.append(Term(id=f"{t.id}~alt", en=t.en, tr=alt, category=t.category, status=t.status))
        return out

    def check(self, en_text: str, tr_text: str) -> list[str]:
        """One message per required term missing, and per rejected alternative used."""
        issues = []
        for t in self.terms_in(en_text):
            if not t.found_in_tr(tr_text):
                issues.append(f"term:{t.id} '{t.en}' → '{t.tr}' bulunamadı")
            else:
                case = _case_issue(t, en_text, tr_text)
                if case:
                    issues.append(case)
            for alt in self._rejected_alternatives(t):
                if alt.found_in_tr(tr_text):
                    issues.append(f"term-alt:{t.id} reddedilen '{alt.tr}' kullanılmış (sözlük: '{t.tr}')")
        return issues

    def lookup(self, en: str) -> Term | None:
        for t in self.terms:
            if t.en == en:
                return t
        return None


_SKIP_CASE = {"kısaltma", "birim", "para"}


def _at_sentence_start(text: str, pos: int) -> bool:
    head = re.sub(r"[\s*“”\"'(\-]+$", "", text[:pos])
    return not head or head.endswith((".", "!", "?", ":", ";"))


def _case_issue(t: Term, en: str, tr: str) -> str | None:
    """Capitalisation follows the source: Advantage → Avantaj, saving throw → kurtarma zarı."""
    if t.category in _SKIP_CASE or not t.tr[:1].isalpha():
        return None
    em = t.en_re.search(en)
    if not em or _at_sentence_start(en, em.start()):
        return None
    want_upper = en[em.start()].isupper()
    seen = None
    for tm_ in t.tr_re.finditer(tr_lower(tr)):
        if _at_sentence_start(tr, tm_.start()) or tr[tm_.start()].isupper() == want_upper:
            return None  # one correctly-cased (or sentence-initial) occurrence is enough
        seen = seen or tm_
    if seen is None:
        return None
    return f"case:{t.id} '{tr[seen.start():seen.end()]}' kaynağın büyük/küçük harfini izlemiyor"


def build_title_map(glossary: "Glossary", names: list[tuple[str, str, str]]) -> dict[str, str]:
    """English title → Turkish title for cross-reference checks and see-also links.

    Quoted references (“Cover”) use plain keys; italic spell references
    (*Fireball*) use "*"-prefixed keys, so a spell and a rule with the same
    English name ("Shield", "Light") never shadow each other.
    `names` = [(dataset, english_name, turkish_name)] of translated records.
    """
    titles: dict[str, str] = {}
    for t in glossary.terms:
        k = f"*{t.en}" if t.category == "büyü adı" else t.en
        titles.setdefault(k, t.tr)
    for ds, en, tr in names:
        titles.setdefault(f"*{en}" if ds == "spells" else en, tr)
    return titles
