#!/usr/bin/env python3
"""Fetch product-specific noun marks so brand chips stop sharing the house logo."""

from __future__ import annotations

import json
import shutil
import ssl
import time
import urllib.error
import urllib.parse
import urllib.request
from io import BytesIO
from pathlib import Path

from PIL import Image

ROOT = Path("/Users/samuel/Documents/The Final Journal AI.nosync")
DESKTOP = Path("/Users/samuel/Desktop/pennworkstudios.nosync")
ASSET = ROOT / "XJournal AI" / "Assets.xcassets" / "NounMarks"
CACHE = ROOT / "docs" / "noun-chooser" / "wrong-src"
FOUND = ROOT / "docs" / "noun-chooser" / "found"
UA = "PenworkNounChooser/1.0 (local educational; lyric noun marks)"
CTX = ssl.create_default_context()
SIZE = 1024
PAD = 56

# icon -> Commons filenames, Wikipedia titles, Openverse search.
SOURCES: dict[str, dict] = {
    "noun-gucci-bag": {
        "files": [
            "Gucci, bamboo bag, 1960-65 ca. (firenze, archivio storico gucci).jpg",
            "Gucci Purse and Belt in Montreal (1132464411).jpg",
            "Gucci Garment Bag (216880222).jpg",
        ],
        "wiki": ["Gucci"],
        "search": "Gucci Jackie bag handbag",
    },
    "noun-gucci-belt": {
        "files": ["Gucci Purse and Belt in Montreal (1132464411).jpg"],
        "search": "Gucci GG belt buckle web stripe",
    },
    "noun-gucci-socks": {
        "search": "Gucci socks GG",
    },
    "noun-gucci-slides": {
        "search": "Gucci slides sandal GG",
    },
    "noun-gucci-sweater": {
        "files": [
            "Camp - Notes on Fashion at the Met - Alessandro Michele for Gucci (73831).jpg",
        ],
        "search": "Gucci knit sweater GG jacquard",
    },
    "noun-gucci-shirt": {
        "files": [
            "Camp - Notes on Fashion at the Met - Alessandro Michele for Gucci (73831).jpg",
        ],
        "search": "Gucci polo shirt",
    },
    "noun-gucci-bomber": {
        "search": "Gucci bomber jacket GG",
    },
    "noun-gucci-store": {
        "files": [
            "Gucci_NYC_Flagship_(48064046878).jpg",
            "Gucci NYC Flagship (48064046878).jpg",
            "Gucci store.jpg",
        ],
        "wiki": ["Gucci"],
        "search": "Gucci flagship store New York",
    },
    "noun-gats": {
        "search": "Gucci Ace sneaker white bee",
    },
    "noun-chanel-bag": {
        "wiki": ["Chanel", "Classic Flap"],
        "search": "Chanel 2.55 classic flap bag",
    },
    "noun-prada-bag": {
        "wiki": ["Prada"],
        "search": "Prada nylon bag Galleria",
    },
    "noun-fendi-bag": {
        "wiki": ["Fendi"],
        "search": "Fendi Baguette bag",
    },
    "noun-amiri-jeans": {
        "wiki": ["Amiri (fashion brand)"],
        "search": "Amiri jeans stacked denim",
    },
    "noun-chrome-hearts-glasses": {
        "wiki": ["Chrome Hearts"],
        "search": "Chrome Hearts eyeglasses frames",
    },
    "noun-chrome-hearts-jeans": {
        "search": "Chrome Hearts jeans denim cross",
    },
    "noun-ysl-jeans": {
        "wiki": ["Yves Saint Laurent (fashion house)"],
        "search": "Saint Laurent skinny jeans",
    },
    "noun-versace-shades": {
        "wiki": ["Versace"],
        "search": "Versace Medusa sunglasses",
    },
    "noun-balenciaga-boots": {
        "wiki": ["Balenciaga"],
        "search": "Balenciaga boots combat",
    },
    "noun-off-white-coat": {
        "wiki": ["Off-White (company)"],
        "search": "Off-White coat industrial belt",
    },
    "noun-off-white-fur": {
        "search": "Off-White fur jacket",
    },
    "noun-goyard-bag": {
        "wiki": ["Goyard"],
        "search": "Goyard Saint Louis tote bag",
    },
    "noun-goyard-backpack": {
        "search": "Goyard backpack",
    },
    "noun-birkin": {
        "wiki": ["Birkin bag", "Hermès"],
        "search": "Hermes Birkin bag",
    },
    "noun-bb-belt": {
        "search": "Hermes Constance H belt buckle",
    },
    "noun-jordan": {
        "wiki": ["Air Jordan"],
        "search": "Air Jordan 1 sneaker",
    },
    "noun-bapesta": {
        "wiki": ["A Bathing Ape"],
        "search": "Bapesta sneaker BAPE STA",
    },
    "noun-palm-angels-sweater": {
        "wiki": ["Palm Angels"],
        "search": "Palm Angels hoodie sweater",
    },
    "noun-rick-owens-denims": {
        "wiki": ["Rick Owens"],
        "search": "Rick Owens jeans denim",
    },
}


def http_get(url: str, timeout: int = 30) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "*/*"})
    with urllib.request.urlopen(req, timeout=timeout, context=CTX) as resp:
        ctype = (resp.headers.get("Content-Type") or "").lower()
        data = resp.read()
        if "text/html" in ctype and b"<html" in data[:400].lower():
            raise ValueError("html")
        return data


def http_get_retry(url: str, tries: int = 4) -> bytes:
    last: Exception | None = None
    for i in range(tries):
        try:
            return http_get(url)
        except urllib.error.HTTPError as e:
            last = e
            if e.code == 429:
                time.sleep(12 + i * 8)
                continue
            raise
        except Exception as e:
            last = e
            time.sleep(2)
    raise last  # type: ignore


def commons_thumb(filename: str) -> tuple[bytes, str] | None:
    title = filename if filename.lower().startswith("file:") else "File:" + filename
    api = "https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode(
        {
            "action": "query",
            "titles": title,
            "prop": "imageinfo",
            "iiprop": "url|mime",
            "iiurlwidth": 1200,
            "format": "json",
        }
    )
    try:
        info = json.loads(http_get_retry(api).decode())
        for page in info.get("query", {}).get("pages", {}).values():
            ii = (page.get("imageinfo") or [None])[0]
            if not ii:
                continue
            src = ii.get("thumburl") or ii.get("url")
            if src:
                return http_get_retry(src), src
    except Exception:
        return None
    return None


def wiki_thumb(title: str) -> tuple[bytes, str] | None:
    api = "https://en.wikipedia.org/w/api.php?" + urllib.parse.urlencode(
        {
            "action": "query",
            "titles": title,
            "prop": "pageimages",
            "format": "json",
            "pithumbsize": 800,
            "piprop": "thumbnail",
        }
    )
    try:
        info = json.loads(http_get_retry(api).decode())
        for page in info.get("query", {}).get("pages", {}).values():
            src = (page.get("thumbnail") or {}).get("source")
            if src:
                return http_get_retry(src), src
    except Exception:
        return None
    return None


def openverse(query: str, needle: str) -> tuple[bytes, str] | None:
    api = "https://api.openverse.org/v1/images/?" + urllib.parse.urlencode(
        {"q": query, "page_size": 16}
    )
    try:
        info = json.loads(http_get_retry(api).decode())
    except Exception:
        return None
    needle = needle.lower()
    ranked = []
    for r in info.get("results") or []:
        title = (r.get("title") or "").lower()
        url = r.get("url")
        if not url:
            continue
        score = 0
        if needle and needle in title:
            score += 3
        for w in needle.split():
            if len(w) > 2 and w in title:
                score += 1
        ranked.append((score, url, title))
    ranked.sort(key=lambda x: -x[0])
    for _score, url, _t in ranked[:8]:
        try:
            data = http_get_retry(url)
            if len(data) > 2500:
                return data, url
        except Exception:
            continue
    return None


def commons_search(query: str) -> tuple[bytes, str] | None:
    api = "https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode(
        {
            "action": "query",
            "list": "search",
            "srsearch": query,
            "srnamespace": 6,
            "srlimit": 8,
            "format": "json",
        }
    )
    try:
        info = json.loads(http_get_retry(api).decode())
    except Exception:
        return None
    for hit in info.get("query", {}).get("search", []):
        title = hit.get("title") or ""
        got = commons_thumb(title)
        if got:
            return got
        time.sleep(0.4)
    return None


def save_raw(data: bytes, dest: Path) -> bool:
    try:
        if data[:200].lstrip().startswith(b"<svg") or b"<svg" in data[:400]:
            tmp = dest.with_suffix(".svg")
            tmp.write_bytes(data)
            import subprocess

            subprocess.run(
                ["qlmanage", "-t", "-s", "900", "-o", str(dest.parent), str(tmp)],
                check=True,
                capture_output=True,
            )
            produced = Path(str(tmp) + ".png")
            tmp.unlink(missing_ok=True)
            if produced.exists():
                Image.open(produced).convert("RGBA").save(dest)
                produced.unlink()
                return dest.exists()
            return False
        im = Image.open(BytesIO(data)).convert("RGBA")
        im.save(dest)
        return True
    except Exception:
        return False


def crop_content(im: Image.Image, frac: tuple[float, float, float, float] | None = None) -> Image.Image:
    im = im.convert("RGBA")
    if frac:
        w, h = im.size
        l, t, r, b = frac
        im = im.crop((int(w * l), int(h * t), int(w * r), int(h * b)))
    bg = Image.new("RGBA", im.size, (255, 255, 255, 255))
    bg.alpha_composite(im)
    rgb = bg.convert("RGB")
    gray = rgb.convert("L")
    inv = Image.eval(gray, lambda p: 0 if p > 242 else 255)
    bbox = inv.getbbox()
    if not bbox:
        return im
    x0, y0, x1, y1 = bbox
    pad = 8
    x0 = max(0, x0 - pad)
    y0 = max(0, y0 - pad)
    x1 = min(im.size[0], x1 + pad)
    y1 = min(im.size[1], y1 + pad)
    area = (x1 - x0) * (y1 - y0)
    if area < 0.18 * im.size[0] * im.size[1]:
        return im
    return im.crop((x0, y0, x1, y1))


def to_square(im: Image.Image) -> Image.Image:
    im = im.convert("RGBA")
    bg = Image.new("RGBA", im.size, (255, 255, 255, 255))
    bg.alpha_composite(im)
    rgb = bg.convert("RGB")
    inner = SIZE - 2 * PAD
    w, h = rgb.size
    scale = min(inner / max(w, 1), inner / max(h, 1))
    nw, nh = max(1, int(w * scale)), max(1, int(h * scale))
    rgb = rgb.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", (SIZE, SIZE), (255, 255, 255))
    x = (SIZE - rgb.size[0]) // 2
    y = (SIZE - rgb.size[1]) // 2
    canvas.paste(rgb, (x, y))
    return canvas


def write_imageset(icon: str, im: Image.Image) -> Path:
    folder = ASSET / f"{icon}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    png = folder / f"{icon}.png"
    to_square(im).save(png, "PNG", optimize=True)
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
    return png


def fetch_real(icon: str) -> Path | None:
    CACHE.mkdir(parents=True, exist_ok=True)
    dest = CACHE / f"{icon}.png"
    spec = SOURCES.get(icon, {})
    needle = icon.replace("noun-", "").replace("-", " ")
    q = spec.get("search") or needle
    for fn in spec.get("files") or []:
        got = commons_thumb(fn)
        time.sleep(0.4)
        if got and save_raw(got[0], dest):
            print(f"    commons file {fn}")
            return dest
    # Commons search before Wikipedia pageimages — brand wiki thumbs are logos.
    got = commons_search(q)
    if got and save_raw(got[0], dest):
        print("    commons search")
        return dest
    got = openverse(q, needle)
    time.sleep(0.4)
    if got and save_raw(got[0], dest):
        print("    openverse")
        return dest
    for title in spec.get("wiki") or []:
        got = wiki_thumb(title)
        time.sleep(0.4)
        if got and save_raw(got[0], dest):
            print(f"    wiki {title}")
            return dest
    return None


def main() -> None:
    ok, fail = [], []
    icons = list(SOURCES)
    print(f"fetching {len(icons)} product marks")
    for i, icon in enumerate(icons, 1):
        path = fetch_real(icon)
        if not path:
            fail.append((icon, "fetch miss"))
            print(f"  {i}/{len(icons)} MISS {icon}")
            time.sleep(0.5)
            continue
        try:
            im = crop_content(Image.open(path).convert("RGBA"))
            write_imageset(icon, im)
            FOUND.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, FOUND / f"{icon}.png")
            ok.append(icon)
            print(f"  {i}/{len(icons)} OK {icon}")
        except Exception as e:
            fail.append((icon, str(e)))
            print(f"  {i}/{len(icons)} FAIL {icon} {e}")
        time.sleep(0.6)

    dest = DESKTOP / "XJournal AI" / "Assets.xcassets" / "NounMarks"
    if dest.parent.exists():
        for icon in ok:
            src = ASSET / f"{icon}.imageset"
            if src.exists():
                shutil.copytree(src, dest / f"{icon}.imageset", dirs_exist_ok=True)
        print("synced Desktop NounMarks for new product sets")
    print(f"wrote {len(ok)} imagesets, {len(fail)} failures")
    for icon, why in fail:
        print("  FAIL", icon, why)


if __name__ == "__main__":
    main()
