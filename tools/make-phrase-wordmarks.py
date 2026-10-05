#!/usr/bin/env python3
"""B&W centered wordmarks for Phrases chips. Never clip; pad ~18%."""
from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ASSET = ROOT / "XJournal AI" / "Assets.xcassets" / "NounMarks"
DESK = Path("/Users/samuel/Desktop/pennworkstudios.nosync/XJournal AI/Assets.xcassets/NounMarks")
SIZE = 1024
PAD = 180
FONTS = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/Library/Fonts/Arial Bold.ttf",
    "/System/Library/Fonts/Supplemental/Impact.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
]


def font(size: int) -> ImageFont.FreeTypeFont:
    for p in FONTS:
        if Path(p).exists():
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
    return ImageFont.load_default()


def wrap(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont, max_w: int) -> list[str]:
    words = text.split()
    if len(words) == 1:
        return words
    lines: list[str] = []
    cur = words[0]
    for w in words[1:]:
        trial = f"{cur} {w}"
        if draw.textbbox((0, 0), trial, font=fnt)[2] <= max_w:
            cur = trial
        else:
            lines.append(cur)
            cur = w
    lines.append(cur)
    return lines


def render(text: str) -> Image.Image:
    im = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
    draw = ImageDraw.Draw(im)
    box = SIZE - 2 * PAD
    size = 210 if len(text) < 14 else 170 if len(text) < 22 else 140
    fnt = None
    lines: list[str] = []
    for _ in range(12):
        fnt = font(size)
        lines = wrap(draw, text, fnt, box)
        heights = []
        widths = []
        for ln in lines:
            b = draw.textbbox((0, 0), ln, font=fnt)
            widths.append(b[2] - b[0])
            heights.append(b[3] - b[1])
        total_h = sum(heights) + 18 * (len(lines) - 1)
        if max(widths, default=0) <= box and total_h <= box:
            break
        size -= 12
    assert fnt is not None
    total_h = 0
    metrics = []
    for ln in lines:
        b = draw.textbbox((0, 0), ln, font=fnt)
        w, h = b[2] - b[0], b[3] - b[1]
        metrics.append((ln, w, h, b[1]))
        total_h += h
    total_h += 18 * (len(lines) - 1)
    y = (SIZE - total_h) // 2
    for ln, w, h, top in metrics:
        x = (SIZE - w) // 2
        draw.text((x, y - top), ln, font=fnt, fill=(255, 255, 255))
        y += h + 18
    return im


def write_imageset(icon: str, im: Image.Image) -> None:
    folder = ASSET / f"{icon}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    png = folder / f"{icon}.png"
    im.save(png, "PNG", optimize=True)
    (folder / "Contents.json").write_text(
        json.dumps(
            {
                "images": [
                    {"filename": f"{icon}.png", "idiom": "universal", "scale": "1x"},
                    {"idiom": "universal", "scale": "2x"},
                    {"idiom": "universal", "scale": "3x"},
                ],
                "info": {"author": "xcode", "version": 1},
            },
            indent=2,
        )
        + "\n"
    )
    if DESK.parent.exists():
        dest = DESK / f"{icon}.imageset"
        dest.mkdir(parents=True, exist_ok=True)
        shutil.copy2(png, dest / f"{icon}.png")
        shutil.copy2(folder / "Contents.json", dest / "Contents.json")


PHRASES = [
    ("pull up", "noun-phrase-pull-up"),
    ("on God", "noun-phrase-on-god"),
    ("no cap", "noun-phrase-no-cap"),
    ("on the block", "noun-phrase-on-the-block"),
    ("get money", "noun-phrase-get-money"),
    ("in the trap", "noun-phrase-in-the-trap"),
    ("RIP", "noun-phrase-rip"),
    ("in the kitchen", "noun-phrase-in-the-kitchen"),
    ("real niggas", "noun-phrase-real-niggas"),
    ("turn up", "noun-phrase-turn-up"),
    ("let's get it", "noun-phrase-lets-get-it"),
    ("keep it real", "noun-phrase-keep-it-real"),
    ("run it up", "noun-phrase-run-it-up"),
    ("I want smoke", "noun-phrase-i-want-smoke"),
    ("I don't play", "noun-phrase-i-dont-play"),
    ("in my bag", "noun-phrase-in-my-bag"),
    ("out the mud", "noun-phrase-out-the-mud"),
    ("real shit", "noun-phrase-real-shit"),
    ("locked in", "noun-phrase-locked-in"),
    ("what it do", "noun-phrase-what-it-do"),
    ("ride or die", "noun-phrase-ride-or-die"),
    ("do or die", "noun-phrase-do-or-die"),
    ("fuck 12", "noun-phrase-fuck-12"),
    ("trust nobody", "noun-phrase-trust-nobody"),
    ("long live", "noun-phrase-long-live"),
    ("on my mama", "noun-phrase-on-my-mama"),
    ("on my soul", "noun-phrase-on-my-soul"),
    ("on everything", "noun-phrase-on-everything"),
    ("we outside", "noun-phrase-we-outside"),
    ("it's a movie", "noun-phrase-its-a-movie"),
    ("say less", "noun-phrase-say-less"),
    ("that's facts", "noun-phrase-thats-facts"),
    ("that's cap", "noun-phrase-thats-cap"),
    ("keep it 100", "noun-phrase-keep-it-100"),
    ("started from the bottom", "noun-phrase-started-from-the-bottom"),
    ("look at me now", "noun-phrase-look-at-me-now"),
    ("all eyes on me", "noun-phrase-all-eyes-on-me"),
    ("no days off", "noun-phrase-no-days-off"),
    ("fake love", "noun-phrase-fake-love"),
    ("real talk", "noun-phrase-real-talk"),
    ("I been him", "noun-phrase-i-been-him"),
    ("they not ready", "noun-phrase-they-not-ready"),
    ("God did", "noun-phrase-god-did"),
    ("for the culture", "noun-phrase-for-the-culture"),
    ("real recognize real", "noun-phrase-real-recognize-real"),
    ("keep it a buck", "noun-phrase-keep-it-a-buck"),
    ("secure the bag", "noun-phrase-secure-the-bag"),
    ("no new friends", "noun-phrase-no-new-friends"),
    ("fuck the police", "noun-phrase-fuck-the-police"),
    ("never fold", "noun-phrase-never-fold"),
]


def main() -> None:
    for label, icon in PHRASES:
        write_imageset(icon, render(label.upper()))
        print("OK", icon)


if __name__ == "__main__":
    main()
