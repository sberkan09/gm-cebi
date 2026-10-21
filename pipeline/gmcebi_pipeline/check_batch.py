"""Read-only QC report for a translated batch file (does not touch the memory).

  python -m gmcebi_pipeline.check_batch translations/out/batch_003.jsonl
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from .glossary import Glossary
from .qc import check_segment


def main(paths: list[str]) -> int:
    glossary = Glossary.load()
    bad = total = 0
    for p in paths:
        out = Path(p)
        queue = out.parent.parent / "queue" / out.name
        src = {d["key"]: d for d in map(json.loads, queue.read_text(encoding="utf-8").splitlines()) if d}
        got = {}
        for line in out.read_text(encoding="utf-8").splitlines():
            if line.strip():
                d = json.loads(line)
                got[d["key"]] = d["tr"]
        missing = set(src) - set(got)
        if missing:
            print(f"{out.name}: {len(missing)} keys missing: {sorted(missing)[:10]}")
            bad += len(missing)
        for k, tr in got.items():
            if k not in src:
                print(f"{out.name}: unknown key {k}")
                continue
            total += 1
            titles = src[k].get("titles", {})
            issues = check_segment(src[k]["en"], tr, glossary, titles)
            if issues:
                bad += 1
                print(f"[{k}] {src[k]['en']}\n    → {tr}\n    ! {'; '.join(issues)}")
    print(f"checked {total}, problems {bad}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
