"""Download the official SRD 5.2.1 PDF and verify its checksum."""

from __future__ import annotations

import hashlib
import sys
import urllib.request
from pathlib import Path

SRD_URL = "https://media.dndbeyond.com/compendium-images/srd/5.2/SRD_CC_v5.2.1.pdf"
SRD_SHA256 = "8974902d109d6e63672d7c490bde9ccf052410503d9cfa768237154fbc5e3d87"
DEFAULT_PATH = Path(__file__).resolve().parents[1] / "raw" / "SRD_CC_v5.2.1.pdf"


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def ensure_pdf(path: Path = DEFAULT_PATH) -> Path:
    if not path.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        print(f"Downloading {SRD_URL}", file=sys.stderr)
        urllib.request.urlretrieve(SRD_URL, path)
    digest = sha256(path)
    if digest != SRD_SHA256:
        raise SystemExit(f"Checksum mismatch for {path}: {digest}")
    return path


if __name__ == "__main__":
    print(ensure_pdf())
