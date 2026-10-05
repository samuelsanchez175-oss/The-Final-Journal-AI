#!/usr/bin/env python3
"""Fetch real portraits (Wikipedia REST / Commons). Never invent faces."""

from __future__ import annotations

import json
import ssl
import time
import urllib.error
import urllib.parse
import urllib.request
from io import BytesIO
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSET = ROOT / "XJournal AI" / "Assets.xcassets" / "NounMarks"
DESK = Path("/Users/samuel/Desktop/pennworkstudios.nosync/XJournal AI/Assets.xcassets/NounMarks")
UA = "PenworkNounChooser/1.0 (local educational; lyric noun marks)"
CTX = ssl.create_default_context()
SIZE = 1024


def http(url: str, timeout: int = 25, retries: int = 4) -> bytes | None:
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "*/*"})
    wait = 2.0
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=timeout, context=CTX) as resp:
                ctype = (resp.headers.get("Content-Type") or "").lower()
                data = resp.read()
                if "text/html" in ctype and b"<html" in data[:300].lower():
                    return None
                return data
        except urllib.error.HTTPError as e:
            if e.code == 429:
                time.sleep(wait)
                wait = min(wait * 2, 30)
                continue
            if e.code in (404, 400):
                return None
            if attempt + 1 < retries:
                time.sleep(wait)
                wait = min(wait * 2, 20)
                continue
            return None
        except Exception:
            if attempt + 1 < retries:
                time.sleep(wait)
                wait = min(wait * 2, 20)
                continue
            return None
    return None


def wiki_rest_summary(title: str) -> dict | None:
    slug = urllib.parse.quote(title.replace(" ", "_"))
    raw = http(f"https://en.wikipedia.org/api/rest_v1/page/summary/{slug}")
    time.sleep(0.4)
    if not raw:
        return None
    try:
        return json.loads(raw.decode())
    except Exception:
        return None


def wiki_rest(title: str) -> bytes | None:
    info = wiki_rest_summary(title)
    if not info:
        return None
    src = (info.get("thumbnail") or {}).get("source") or (info.get("originalimage") or {}).get("source")
    if not src:
        return None
    return http(src.replace("/240px-", "/800px-").replace("/320px-", "/800px-"))


def commons_filepath(filename: str, width: int = 1024) -> bytes | None:
    fn = filename[5:] if filename.lower().startswith("file:") else filename
    url = (
        "https://commons.wikimedia.org/wiki/Special:FilePath/"
        + urllib.parse.quote(fn)
        + f"?width={width}"
    )
    return http(url)


def wikidata_p18(title: str) -> bytes | None:
    """Wikipedia REST wikibase_item → Wikidata P18 → Commons FilePath."""
    info = wiki_rest_summary(title) or {}
    qid = info.get("wikibase_item")
    if not qid:
        api = "https://www.wikidata.org/w/api.php?" + urllib.parse.urlencode(
            {
                "action": "wbgetentities",
                "sites": "enwiki",
                "titles": title,
                "props": "claims",
                "format": "json",
            }
        )
        raw = http(api)
        time.sleep(0.4)
        if not raw:
            return None
        try:
            entities = json.loads(raw.decode()).get("entities") or {}
        except Exception:
            return None
        for key, ent in entities.items():
            if key != "-1" and ent.get("claims"):
                qid = key
                break
        if not qid:
            return None
    else:
        api = "https://www.wikidata.org/w/api.php?" + urllib.parse.urlencode(
            {
                "action": "wbgetentities",
                "ids": qid,
                "props": "claims",
                "format": "json",
            }
        )
        raw = http(api)
        time.sleep(0.4)
        if not raw:
            return None
        try:
            entities = json.loads(raw.decode()).get("entities") or {}
        except Exception:
            return None
    ent = (entities or {}).get(qid) or {}
    claims = (ent.get("claims") or {}).get("P18") or []
    for claim in claims:
        fn = ((claim.get("mainsnak") or {}).get("datavalue") or {}).get("value")
        if not fn:
            continue
        data = commons_filepath(fn)
        if data and len(data) > 4000:
            return data
        time.sleep(0.4)
    return None


def commons_search(query: str) -> bytes | None:
    api = "https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode(
        {
            "action": "query",
            "list": "search",
            "srsearch": query,
            "srnamespace": 6,
            "srlimit": 6,
            "format": "json",
        }
    )
    raw = http(api)
    if not raw:
        return None
    try:
        info = json.loads(raw.decode())
    except Exception:
        return None
    for hit in info.get("query", {}).get("search", []):
        title = hit.get("title") or ""
        if not title.lower().startswith("file:"):
            title = "File:" + title
        q = "https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode(
            {
                "action": "query",
                "titles": title,
                "prop": "imageinfo",
                "iiprop": "url|mime",
                "iiurlwidth": 900,
                "format": "json",
            }
        )
        meta = http(q)
        if not meta:
            continue
        pages = json.loads(meta.decode()).get("query", {}).get("pages", {})
        for page in pages.values():
            ii = (page.get("imageinfo") or [None])[0]
            if not ii:
                continue
            src = ii.get("thumburl") or ii.get("url")
            if src:
                data = http(src)
                if data and len(data) > 4000:
                    return data
        time.sleep(0.3)
    return None


def cover(data: bytes) -> Image.Image | None:
    try:
        im = Image.open(BytesIO(data)).convert("RGB")
    except Exception:
        return None
    w, h = im.size
    if min(w, h) < 40:
        return None
    # skip near-solid
    extrema = im.convert("L").getextrema()
    if extrema[1] - extrema[0] < 12:
        return None
    scale = max(SIZE / w, SIZE / h)
    nw, nh = int(w * scale + 0.5), int(h * scale + 0.5)
    im = im.resize((nw, nh), Image.Resampling.LANCZOS)
    left = (nw - SIZE) // 2
    top = max(0, (nh - SIZE) // 2 - nh // 12)
    return im.crop((left, top, left + SIZE, top + SIZE))


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
        import shutil

        shutil.copy2(png, dest / f"{icon}.png")
        shutil.copy2(folder / "Contents.json", dest / "Contents.json")


def fetch_one(wiki: str) -> Image.Image | None:
    for fn in (wiki_rest, wikidata_p18, lambda t: commons_search(t)):
        data = fn(wiki)
        time.sleep(0.4)
        if not data:
            continue
        im = cover(data)
        if im:
            return im
    return None


def main(jobs: list[tuple[str, str]]) -> None:
    ok, miss = [], []
    for i, (icon, wiki) in enumerate(jobs, 1):
        im = fetch_one(wiki)
        if im is None:
            miss.append(icon)
            print(f"  {i}/{len(jobs)} MISS {icon} ({wiki})")
            continue
        write_imageset(icon, im)
        ok.append(icon)
        print(f"  {i}/{len(jobs)} OK {icon}")
    print(f"portraits {len(ok)} ok, {len(miss)} miss")
    for m in miss:
        print("  FAIL", m)


if __name__ == "__main__":
    import sys

    # default: leftover artists
    jobs = [
        ("noun-artist-biggie", "The Notorious B.I.G."),
        ("noun-artist-nocap", "NoCap"),
        ("noun-artist-peewee-longway", "Peewee Longway"),
        ("noun-artist-lil-duke", "Lil Duke"),
        ("noun-artist-tadoe", "Tadoe"),
        ("noun-artist-marlo", "Marlo (rapper)"),
        ("noun-artist-omelly", "Omelly"),
        ("noun-artist-kap-g", "Kap G"),
        ("noun-artist-unfoonk", "Unfoonk"),
    ]
    if len(sys.argv) > 1:
        jobs = []
        for arg in sys.argv[1:]:
            icon, wiki = arg.split("|", 1)
            jobs.append((icon, wiki))
    main(jobs)
