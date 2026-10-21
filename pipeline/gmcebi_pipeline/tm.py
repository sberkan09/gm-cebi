"""Translation memory: one JSONL line per unique English segment.

Fields:
  key      sha1(en)[:16]
  en       English source sentence (kept side by side for review)
  tr       Turkish translation
  status   machine | reviewed | rejected
  engine   who produced `tr` (model id, or "human:<name>")
  qc       list of QC findings at import time (empty = clean)
  refs     a few record references where the segment occurs (for context)
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass, field
from pathlib import Path

TM_PATH = Path(__file__).resolve().parents[1] / "translations" / "tm.jsonl"
STATUSES = ("machine", "reviewed", "rejected")


@dataclass
class Entry:
    key: str
    en: str
    tr: str = ""
    status: str = "machine"
    engine: str = ""
    qc: list[str] = field(default_factory=list)
    refs: list[str] = field(default_factory=list)


class TM:
    def __init__(self, path: Path = TM_PATH):
        self.path = path
        self.entries: dict[str, Entry] = {}
        if path.exists():
            for line in path.read_text(encoding="utf-8").splitlines():
                if line.strip():
                    d = json.loads(line)
                    self.entries[d["key"]] = Entry(**d)

    def get(self, key: str) -> Entry | None:
        return self.entries.get(key)

    def lookup_tr(self, en: str, key_fn) -> str | None:
        e = self.entries.get(key_fn(en))
        if e and e.tr and e.status != "rejected":
            return e.tr
        return None

    def put(self, entry: Entry) -> None:
        old = self.entries.get(entry.key)
        if old and old.status == "reviewed" and entry.status != "reviewed":
            return  # never overwrite human-reviewed text with machine output
        self.entries[entry.key] = entry

    def save(self) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        lines = [json.dumps(asdict(e), ensure_ascii=False) for e in
                 sorted(self.entries.values(), key=lambda e: e.key)]
        self.path.write_text("\n".join(lines) + "\n", encoding="utf-8")
