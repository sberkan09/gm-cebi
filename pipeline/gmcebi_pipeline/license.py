"""License guard: product-identity terms must never reach the app data."""

from __future__ import annotations

import json
import re
from pathlib import Path

# Not exhaustive; extend when in doubt. Terms that appear in SRD 5.2.1 itself
# (e.g. "Drow" as an elven lineage) are CC-BY-licensed and therefore allowed.
# Matching is case-insensitive, whole word.
DENYLIST = [
    "Beholder", "Strahd", "Orcus", "Tiamat", "Bahamut", "Artificer", "Aasimar", "Forgotten Realms",
    "Faerûn", "Faerun", "Greyhawk", "Eberron", "Ravenloft", "Mind Flayer", "Illithid", "Githyanki",
    "Githzerai", "Lolth", "Vecna", "Mordenkainen", "Tasha", "Xanathar", "Elminster",
    "Baldur's Gate", "Waterdeep", "Neverwinter", "Dungeons & Dragons", "Dungeons and Dragons",
    "D&D", "Displacer Beast", "Carrion Crawler", "Umber Hulk", "Yuan-ti", "Kuo-toa", "Slaad",
    "Spelljammer", "Planescape", "Dragonlance",
]
_RX = re.compile(r"(?<![\w&])(" + "|".join(re.escape(t) for t in DENYLIST) + r")(?![\w&])", re.I)


def find_terms(text: str) -> list[str]:
    return sorted({m.group(1) for m in _RX.finditer(text)})


def check_product_identity(_root: Path, datasets: dict) -> list[str]:
    problems = []
    for name, recs in datasets.items():
        for r in recs:
            blob = json.dumps(r.model_dump(mode="json") if hasattr(r, "model_dump") else r,
                              ensure_ascii=False)
            hits = find_terms(blob)
            if hits:
                problems.append(f"{name}/{getattr(r, 'id', '?')}: {', '.join(hits)}")
    return problems
