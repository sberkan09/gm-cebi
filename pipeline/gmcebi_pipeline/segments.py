"""Cut English records into translatable segments and stitch translations back.

A *segment* is one sentence (or one short field value). Segments are keyed by
the hash of their English text, so identical strings ("Action", "60 feet")
are translated once and reused (translation memory).
"""

from __future__ import annotations

import re
from collections.abc import Iterator
from dataclasses import dataclass
from typing import Any

from .textutil import key, split_sentences

# Never sent to translation.
SKIP_KEYS = {"id", "kind", "source", "class_id", "subclasses", "document",
             # Derived views rebuilt from translated blocks / names at asset build time.
             "effects", "see_also"}
# Mapped deterministically through the glossary instead of the LLM.
GLOSSARY_KEYS = {"school", "classes", "tags", "category", "group_ref"}
# Fields that hold running text and are split into sentences.
PROSE_KEYS = {"text", "higher_levels", "cantrip_upgrade", "material_text"}

_NON_TEXT = re.compile(r"^[\s\d+\-−–—/,.%½()×]*$|^\d*d\d+")


def needs_translation(s: str) -> bool:
    return bool(s and s.strip()) and not _NON_TEXT.match(s.strip()) and re.search(r"[A-Za-z]{2}", s) is not None


@dataclass
class Segment:
    record_id: str
    path: str  # dotted path inside the record, e.g. blocks.2.text
    index: int  # sentence index within the field (or paragraph*1000 + sentence)
    en: str
    ns: str = ""  # record names are keyed per dataset ("Shield" spell ≠ "Shield" armor)

    @property
    def key(self) -> str:
        return segment_key(self.en, self.ns)

    @property
    def ref(self) -> str:
        return f"{self.record_id}:{self.path}#{self.index}"


def segment_key(en: str, ns: str = "") -> str:
    return key(f"{ns}|{en}") if ns else key(en)


def _pieces(path_key: str, value: str) -> list[str]:
    if path_key in PROSE_KEYS:
        out = []
        for para in value.split("\n\n"):
            out.extend(split_sentences(para))
        return out
    return [value]


def walk(obj: Any, path: str = "") -> Iterator[tuple[str, str]]:
    """Yield (dotted_path, string) for every translatable leaf."""
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k in SKIP_KEYS or k in GLOSSARY_KEYS:
                continue
            yield from walk(v, f"{path}.{k}" if path else k)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            yield from walk(v, f"{path}.{i}")
    elif isinstance(obj, str) and needs_translation(obj):
        yield path, obj


def record_segments(rec: dict, dataset: str = "") -> list[Segment]:
    segs: list[Segment] = []
    for path, value in walk(rec):
        leaf = path.rsplit(".", 1)[-1]
        if leaf.isdigit():  # list element, e.g. table cell or ability score list
            leaf = path.rsplit(".", 2)[-2]
        ns = dataset if path == "name" else ""
        for i, piece in enumerate(_pieces(leaf, value)):
            segs.append(Segment(rec["id"], path, i, piece, ns))
    return segs


def _set_path(obj: Any, path: str, value: Any) -> None:
    parts = path.split(".")
    for p in parts[:-1]:
        obj = obj[int(p)] if isinstance(obj, list) else obj[p]
    last = parts[-1]
    if isinstance(obj, list):
        obj[int(last)] = value
    else:
        obj[last] = value


def _get_path(obj: Any, path: str) -> Any:
    for p in path.split("."):
        obj = obj[int(p)] if isinstance(obj, list) else obj[p]
    return obj


def apply_translation(rec: dict, tm_lookup, dataset: str = "") -> tuple[dict, int, int]:
    """Return a Turkish copy of `rec` plus (translated, missing) segment counts.

    `tm_lookup(segment_key) -> str | None`. Fields with any missing sentence keep the
    English value so the app can fall back per field.
    """
    import copy

    out = copy.deepcopy(rec)
    done = missing = 0
    for path, value in walk(rec):
        leaf = path.rsplit(".", 1)[-1]
        if leaf.isdigit():
            leaf = path.rsplit(".", 2)[-2]
        paras = value.split("\n\n") if leaf in PROSE_KEYS else [value]
        tr_paras = []
        ok = True
        for para in paras:
            pieces = split_sentences(para) if leaf in PROSE_KEYS else [para]
            ns = dataset if path == "name" else ""
            trs = [tm_lookup(segment_key(p, ns)) for p in pieces]
            done += sum(t is not None for t in trs)
            missing += sum(t is None for t in trs)
            if any(t is None for t in trs):
                ok = False
            tr_paras.append(" ".join(t or "" for t in trs))
        if ok:
            _set_path(out, path, "\n\n".join(tr_paras))
    return out, done, missing


__all__ = ["Segment", "segment_key", "record_segments", "apply_translation", "walk", "needs_translation", "_get_path"]
