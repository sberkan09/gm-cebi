"""Generates the Google Play listing graphics from the app icon design.

  python3 tool/make_store_graphics.py <flutter>/bin/cache/artifacts/material_fonts

Writes:
  docs/store/graphics/play-icon-512.png       512×512, full square (Play applies its own mask)
  docs/store/graphics/feature-graphic-1024x500.png

Requires Pillow. Uses Roboto from Flutter's bundled material fonts (not in the repo).
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_icons import BRASS, INK, d20  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/store/graphics"
MUTED = (200, 196, 186, 255)


def main(font_dir: Path):
    OUT.mkdir(parents=True, exist_ok=True)
    d20(512, radius=0).convert("RGB").save(OUT / "play-icon-512.png")

    w, h = 1024, 500
    img = Image.new("RGBA", (w, h), INK)
    die = d20(420, scale=0.80, bg=False)
    img.alpha_composite(die, (40, 40))
    draw = ImageDraw.Draw(img)
    title = ImageFont.truetype(str(font_dir / "Roboto-Bold.ttf"), 104)
    line = ImageFont.truetype(str(font_dir / "Roboto-Regular.ttf"), 38)
    x = 500
    draw.text((x, 120), "GM Cebi", font=title, fill=BRASS)
    # Only conditions, rules glossary and 50 spells are translated so far:
    # do not claim Turkish monsters/classes here.
    draw.text((x, 262), "Kurallar, büyüler, canavarlar,", font=line, fill=MUTED)
    draw.text((x, 312), "zar. Türkçe arama.", font=line, fill=MUTED)
    draw.text((x, 362), "İnternetsiz.", font=line, fill=MUTED)
    img.convert("RGB").save(OUT / "feature-graphic-1024x500.png")
    print("store graphics written to", OUT.relative_to(ROOT))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(Path(sys.argv[1]))
