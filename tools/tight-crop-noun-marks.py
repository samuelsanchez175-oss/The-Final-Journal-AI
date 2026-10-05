#!/usr/bin/env python3
"""Crop light studio margins so noun-chip photos fill the square."""

from __future__ import annotations

import shutil
from pathlib import Path

from PIL import Image

ROOT = Path("/Users/samuel/Documents/The Final Journal AI.nosync")
ASSET = ROOT / "XJournal AI" / "Assets.xcassets" / "NounMarks"
DESK = Path("/Users/samuel/Desktop/pennworkstudios.nosync/XJournal AI/Assets.xcassets/NounMarks")
SIZE = 1024
PAD = 12  # ~1% so rounded-chip corners don't clip the subject


def corner_bg(rgb: Image.Image) -> tuple[int, int, int] | None:
    w, h = rgb.size
    samples = [
        rgb.getpixel((0, 0)),
        rgb.getpixel((w - 1, 0)),
        rgb.getpixel((0, h - 1)),
        rgb.getpixel((w - 1, h - 1)),
        rgb.getpixel((w // 2, 0)),
        rgb.getpixel((w // 2, h - 1)),
        rgb.getpixel((0, h // 2)),
        rgb.getpixel((w - 1, h // 2)),
    ]
    bg = tuple(sum(c[i] for c in samples) // len(samples) for i in range(3))
    if sum(bg) / 3 < 188:
        return None
    return bg  # type: ignore[return-value]


def content_bbox(rgb: Image.Image, bg: tuple[int, int, int], tol: int = 26) -> tuple[int, int, int, int] | None:
    w, h = rgb.size
    pix = rgb.load()
    min_x, min_y, max_x, max_y = w, h, 0, 0
    found = False
    step = 2 if w > 400 else 1
    for y in range(0, h, step):
        for x in range(0, w, step):
            p = pix[x, y]
            if abs(p[0] - bg[0]) > tol or abs(p[1] - bg[1]) > tol or abs(p[2] - bg[2]) > tol:
                found = True
                if x < min_x:
                    min_x = x
                if y < min_y:
                    min_y = y
                if x > max_x:
                    max_x = x
                if y > max_y:
                    max_y = y
    if not found:
        return None
    # expand for step sampling
    min_x = max(0, min_x - step)
    min_y = max(0, min_y - step)
    max_x = min(w - 1, max_x + step)
    max_y = min(h - 1, max_y + step)
    return min_x, min_y, max_x + 1, max_y + 1


def tight_square(im: Image.Image) -> Image.Image:
    rgb = im.convert("RGB")
    bg = corner_bg(rgb)
    if bg is None:
        # already a full-bleed darker photo; just fit to square
        box = rgb
    else:
        bbox = content_bbox(rgb, bg)
        if bbox is None:
            box = rgb
        else:
            x0, y0, x1, y1 = bbox
            area = (x1 - x0) * (y1 - y0)
            if area < 0.12 * rgb.size[0] * rgb.size[1]:
                box = rgb
            else:
                box = rgb.crop(bbox)
    bw, bh = box.size
    inner = SIZE - 2 * PAD
    scale = min(inner / max(bw, 1), inner / max(bh, 1))
    nw, nh = max(1, int(bw * scale)), max(1, int(bh * scale))
    box = box.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", (SIZE, SIZE), (255, 255, 255))
    canvas.paste(box, ((SIZE - nw) // 2, (SIZE - nh) // 2))
    return canvas


def main() -> None:
    pngs = sorted(ASSET.glob("*.imageset/*.png"))
    ok = 0
    for png in pngs:
        try:
            im = Image.open(png)
            out = tight_square(im)
            out.save(png, "PNG", optimize=True)
            dest = DESK / png.parent.name / png.name
            if dest.parent.parent.exists():
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(png, dest)
            ok += 1
        except Exception as e:
            print("FAIL", png, e)
    print(f"tight-cropped {ok}/{len(pngs)} noun marks")


if __name__ == "__main__":
    main()
