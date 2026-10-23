"""Generates the GM Cebi app icon (own design: a geometric d20 in brass on ink).

  python3 tool/make_icons.py

Writes Android legacy + adaptive launcher icons and the iOS AppIcon set.
Requires Pillow.
"""
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
INK = (18, 19, 24, 255)
BRASS = (227, 168, 87, 255)
BRASS_DIM = (227, 168, 87, 110)


def d20(size, scale=0.62, bg=True, radius=0.22):
    s = size * 4  # supersample
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if bg:
        d.rounded_rectangle([0, 0, s - 1, s - 1], radius=int(s * radius), fill=INK)
    cx, cy, r = s / 2, s / 2, s * scale / 2
    hexa = [(cx + r * math.sin(math.radians(60 * i)), cy - r * math.cos(math.radians(60 * i))) for i in range(6)]
    ir = r * 0.48
    tri = [(cx + ir * math.sin(math.radians(a)), cy - ir * math.cos(math.radians(a)) + r * 0.08) for a in (0, 120, 240)]
    w = max(2, int(s * 0.022))
    # faces: subtle fill on the front triangle (blended, not replaced)
    face = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(face).polygon(tri, fill=BRASS_DIM)
    img.alpha_composite(face)
    d = ImageDraw.Draw(img)
    links = [(0, [0, 1, 5]), (1, [1, 2, 3]), (2, [3, 4, 5])]
    for ti, hs in links:
        for h in hs:
            d.line([tri[ti], hexa[h]], fill=BRASS, width=w)
    d.line(tri + [tri[0]], fill=BRASS, width=w, joint="curve")
    d.line(hexa + [hexa[0]], fill=BRASS, width=int(w * 1.4), joint="curve")
    return img.resize((size, size), Image.LANCZOS)


def main():
    res = ROOT / "android/app/src/main/res"
    legacy = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    for dens, px in legacy.items():
        d20(px).save(res / f"mipmap-{dens}/ic_launcher.png")
        # adaptive foreground: 108dp canvas, art inside the 66dp safe zone
        fg = d20(int(px * 108 / 48), scale=0.50, bg=False)
        fg.save(res / f"mipmap-{dens}/ic_launcher_foreground.png")
    (res / "mipmap-anydpi-v26").mkdir(exist_ok=True)
    (res / "mipmap-anydpi-v26/ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '</adaptive-icon>\n')
    (res / "values/colors.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        '    <color name="ic_launcher_background">#121318</color>\n</resources>\n')

    ios = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = json.loads((ios / "Contents.json").read_text())
    for im in contents["images"]:
        base = float(im["size"].split("x")[0])
        px = int(round(base * int(im["scale"][0])))
        # iOS masks corners itself and rejects transparency in the 1024 icon
        img = d20(px, radius=0).convert("RGB")
        img.save(ios / im["filename"])
    d20(512).save(ROOT / "docs/icon.png")
    print("icons written")


if __name__ == "__main__":
    main()
