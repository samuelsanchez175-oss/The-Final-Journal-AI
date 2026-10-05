#!/usr/bin/env python3
"""Cover-crop noun marks so landscape photos fill the square chip (no letterbox)."""

from __future__ import annotations

import shutil
from pathlib import Path

from PIL import Image

ROOT = Path("/Users/samuel/Documents/The Final Journal AI.nosync")
ASSET = ROOT / "XJournal AI" / "Assets.xcassets" / "NounMarks"
DESK = Path("/Users/samuel/Desktop/pennworkstudios.nosync/XJournal AI/Assets.xcassets/NounMarks")
SIZE = 1024


def corner_bg(rgb: Image.Image) -> tuple[int, int, int] | None:
    w, h = rgb.size
    samples = [
        rgb.getpixel((1, 1)),
        rgb.getpixel((w - 2, 1)),
        rgb.getpixel((1, h - 2)),
        rgb.getpixel((w - 2, h - 2)),
    ]
    bg = tuple(sum(c[i] for c in samples) // 4 for i in range(3))
    if sum(bg) / 3 < 200:
        return None
    return bg  # type: ignore[return-value]


def trim(rgb: Image.Image, bg: tuple[int, int, int], tol: int = 22) -> Image.Image:
    w, h = rgb.size
    pix = rgb.load()
    min_x, min_y, max_x, max_y = w, h, 0, 0
    found = False
    step = 2
    for y in range(0, h, step):
        for x in range(0, w, step):
            p = pix[x, y]
            if abs(p[0] - bg[0]) > tol or abs(p[1] - bg[1]) > tol or abs(p[2] - bg[2]) > tol:
                found = True
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
    if not found:
        return rgb
    min_x = max(0, min_x - 2)
    min_y = max(0, min_y - 2)
    max_x = min(w, max_x + 3)
    max_y = min(h, max_y + 3)
    area = (max_x - min_x) * (max_y - min_y)
    if area < 0.08 * w * h:
        return rgb
    return rgb.crop((min_x, min_y, max_x, max_y))


def cover_square(im: Image.Image) -> Image.Image:
    rgb = im.convert("RGB")
    bg = corner_bg(rgb)
    if bg is not None:
        rgb = trim(rgb, bg)
    w, h = rgb.size
    aspect = w / max(h, 1)
    # Ultra-wide wordmarks: keep the whole word, don't crop letters.
    if aspect >= 2.15 or aspect <= 0.45:
        scale = min(SIZE / w, SIZE / h)
        nw, nh = max(1, int(w * scale)), max(1, int(h * scale))
        rgb = rgb.resize((nw, nh), Image.Resampling.LANCZOS)
        canvas = Image.new("RGB", (SIZE, SIZE), (255, 255, 255))
        canvas.paste(rgb, ((SIZE - nw) // 2, (SIZE - nh) // 2))
        return canvas
    scale = max(SIZE / w, SIZE / h)
    nw, nh = max(SIZE, int(w * scale + 0.5)), max(SIZE, int(h * scale + 0.5))
    rgb = rgb.resize((nw, nh), Image.Resampling.LANCZOS)
    left = max(0, (nw - SIZE) // 2)
    top = max(0, (nh - SIZE) // 2)
    return rgb.crop((left, top, left + SIZE, top + SIZE))


def main() -> None:
    pngs = sorted(ASSET.glob("*.imageset/*.png"))
    ok = 0
    for png in pngs:
        try:
            out = cover_square(Image.open(png))
            out.save(png, "PNG", optimize=True)
            dest = DESK / png.parent.name / png.name
            if dest.parent.parent.exists():
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(png, dest)
            ok += 1
        except Exception as e:
            print("FAIL", png.name, e)
    print(f"cover-cropped {ok}/{len(pngs)}")


if __name__ == "__main__":
    main()
