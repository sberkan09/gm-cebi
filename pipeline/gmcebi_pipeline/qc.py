"""Quality checks applied to every translated segment.

1. Term consistency: every enforced glossary term in the source must appear
   (inflected) in the Turkish text.
2. Numbers and dice: the multiset of numbers and dice expressions (2d6+3)
   must be identical.
3. References: quoted cross-references (“Rules Glossary”) and *italic* spell
   names must resolve to a translated title.
4. Markup: bold/italic markers must stay balanced and run-in labels kept.
5. Product identity: denylisted names must not appear.
"""

from __future__ import annotations

import re

from .glossary import Glossary
from .license import find_terms
from .textutil import dice_tokens, number_tokens

# English number words → digits are allowed to be rendered either way, so the
# QC only compares digit tokens.


def check_numbers(en: str, tr: str) -> list[str]:
    issues = []
    if dice_tokens(en) != dice_tokens(tr):
        issues.append(f"dice: {dice_tokens(en)} ≠ {dice_tokens(tr)}")
    en_n, tr_n = number_tokens(en), number_tokens(tr)
    if en_n != tr_n:
        issues.append(f"numbers: {en_n} ≠ {tr_n}")
    return issues


def check_markup(en: str, tr: str) -> list[str]:
    issues = []
    if en.count("**") != tr.count("**"):
        issues.append("markup: ** sayısı farklı")
    en_i = len(re.findall(r"(?<!\*)\*(?!\*)", en))
    tr_i = len(re.findall(r"(?<!\*)\*(?!\*)", tr))
    if en_i != tr_i:
        issues.append("markup: * sayısı farklı")
    if en.startswith("**") and not tr.startswith("**"):
        issues.append("markup: başlık etiketi kayboldu")
    if en.lstrip().startswith("- ") and not tr.lstrip().startswith("- "):
        issues.append("markup: madde işareti kayboldu")
    return issues


def check_references(en: str, tr: str, title_map: dict[str, str]) -> list[str]:
    """Quoted references and italic spell names must map to translated titles."""
    issues = []
    for ref in re.findall(r"“([^”]+?)[,.]?”", en):
        tgt = title_map.get(ref)
        if tgt is None:
            continue  # unknown target: chapter names are checked elsewhere
        if tgt.lower() not in tr.lower():
            issues.append(f"ref: “{ref}” → “{tgt}” bulunamadı")
    for ref in re.findall(r"(?<!\*)\*([^*]+?)\*(?!\*)", en):
        tgt = title_map.get(ref)
        if tgt and tgt.lower() not in tr.lower():
            issues.append(f"ref: *{ref}* → *{tgt}* bulunamadı")
    return issues


def check_segment(en: str, tr: str, glossary: Glossary, title_map: dict[str, str] | None = None) -> list[str]:
    if not tr.strip():
        return ["empty"]
    issues = glossary.check(en, tr)
    issues += check_numbers(en, tr)
    issues += check_markup(en, tr)
    issues += check_references(en, tr, title_map or {})
    pi = find_terms(tr)
    if pi:
        issues.append(f"product-identity: {pi}")
    if re.search(r"\b(the|and|you|your|with)\b", tr, re.I):
        issues.append("untranslated: İngilizce kelime kalmış olabilir")
    return issues
