#!/usr/bin/env python3
"""Apply A/B/C chooser: keep A, replace B with real marks, write C from found photos."""

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

from PIL import Image, ImageChops, ImageFilter

ROOT = Path("/Users/samuel/Documents/The Final Journal AI.nosync")
DESKTOP = Path("/Users/samuel/Desktop/pennworkstudios.nosync")
ASSET = ROOT / "XJournal AI" / "Assets.xcassets" / "NounMarks"
FOUND = ROOT / "docs" / "noun-chooser" / "found"
CACHE = ROOT / "docs" / "noun-chooser" / "wrong-src"
UA = "PenworkNounChooser/1.0 (local educational; lyric noun marks)"
CTX = ssl.create_default_context()
SIZE = 1024
PAD = 56

# C found files that are the wrong subject — fetch a real mark instead.
C_REJECT = {
    "noun-alexander-mcqueen",  # motorcycle McQueen, not fashion house
    "noun-alyx",  # hospital pump
    "noun-balmain",  # pub interior
    "noun-fashion-nova",  # unrelated portrait
    "noun-who-decides-war",  # film still
    "noun-daytona",  # ALPHA homage, not Rolex
    "noun-vvs",  # raw quartz, not a diamond
}

# Fractional crop (l,t,r,b) on the found photo before padding.
C_CROP = {
    "noun-ace": (0.38, 0.12, 0.82, 0.88),  # gold Ace bottle
}

C_FROM_FOUND = [
    "noun-bape", "noun-chanel", "noun-corteiz", "noun-ksubi", "noun-pelle-pelle",
    "noun-rick-owens", "noun-tiffany", "noun-tom-ford", "noun-vans", "noun-timbs",
    "noun-drug-weed", "noun-gun-draco", "noun-dweller-watch", "noun-pendant",
    "noun-tennis-bracelet", "noun-vs1-stone", "noun-1942", "noun-absolut",
    "noun-ace", "noun-bourbon", "noun-casamigos", "noun-ciroc", "noun-clase-azul",
    "noun-cognac", "noun-cristal", "noun-don-julio", "noun-grey-goose",
    "noun-hennessy", "noun-louis-xiii", "noun-moet", "noun-patron", "noun-remy",
    "noun-vodka", "noun-whiskey", "noun-place-calabasas", "noun-place-mansion",
    "noun-place-memphis", "noun-place-overseas", "noun-place-penthouse",
    "noun-place-philly", "noun-place-studio", "noun-place-tokyo",
    "noun-dirty-sprite",
]

# Real-world sources for WRONG + rejected C. Prefer Commons file names, then wiki, then search.
SOURCES: dict[str, dict] = {
    "noun-alexander-mcqueen": {"wiki": ["Alexander McQueen"], "search": "Alexander McQueen logo fashion"},
    "noun-alyx": {"search": "1017 ALYX 9SM logo"},
    "noun-balmain": {"wiki": ["Balmain (fashion house)"], "search": "Balmain Paris logo"},
    "noun-fashion-nova": {"search": "Fashion Nova logo"},
    "noun-who-decides-war": {"search": "Who Decides War clothing logo"},
    "noun-daytona": {
        "files": ["Rolex Daytona.jpg", "Rolex Cosmograph Daytona.jpg"],
        "wiki": ["Rolex Daytona"],
        "search": "Rolex Daytona watch",
    },
    "noun-vvs": {
        "files": ["Brilliant-cut diamond.jpg", "Round brilliant cut diamond.jpg"],
        "wiki": ["Diamond"],
        "search": "round brilliant diamond gem",
    },
    "noun-bb-belt": {"wiki": ["Hermès"], "search": "Hermes H belt buckle"},
    "noun-bvlgari": {"wiki": ["Bulgari"], "search": "Bvlgari Bulgari logo"},
    "noun-cactus-jack": {"search": "Cactus Jack Travis Scott logo"},
    "noun-carhartt": {"wiki": ["Carhartt"], "search": "Carhartt logo"},
    "noun-casablanca": {"wiki": ["Casablanca (brand)"], "search": "Casablanca Paris logo"},
    "noun-cdg": {"wiki": ["Comme des Garçons"], "search": "Comme des Garcons CDG logo"},
    "noun-comme-des-garcons": {"wiki": ["Comme des Garçons"], "search": "Comme des Garcons logo"},
    "noun-converse": {"wiki": ["Converse (shoe company)"], "search": "Converse star chevron logo"},
    "noun-denim-tears": {"search": "Denim Tears logo"},
    "noun-dickies": {"wiki": ["Dickies"], "search": "Dickies logo"},
    "noun-ed-hardy": {"wiki": ["Ed Hardy"], "search": "Ed Hardy logo"},
    "noun-evisu": {"wiki": ["Evisu"], "search": "Evisu seagull logo"},
    "noun-fear-of-god-pants": {"wiki": ["Fear of God (fashion brand)"], "search": "Fear of God Essentials sweatpants"},
    "noun-ferragamo": {"wiki": ["Salvatore Ferragamo S.p.A."], "search": "Ferragamo logo"},
    "noun-force-1s": {"wiki": ["Nike Air Force"], "search": "Nike Air Force 1 sneaker white"},
    "noun-fubu": {"wiki": ["FUBU"], "search": "FUBU logo"},
    "noun-gats": {"wiki": ["Gucci"], "search": "Gucci Ace sneaker"},
    "noun-givenchy": {"wiki": ["Givenchy"], "search": "Givenchy logo 4G"},
    "noun-golden-goose": {"wiki": ["Golden Goose (company)"], "search": "Golden Goose logo"},
    "noun-golf-wang": {"search": "Golf Wang logo Tyler"},
    "noun-helmut-lang": {"wiki": ["Helmut Lang (fashion brand)"], "search": "Helmut Lang logo"},
    "noun-heron-preston": {"wiki": ["Heron Preston"], "search": "Heron Preston logo"},
    "noun-human-made": {"search": "Human Made Nigo logo"},
    "noun-issey-miyake": {"wiki": ["Issey Miyake"], "search": "Issey Miyake logo"},
    "noun-kapital": {"wiki": ["Kapital (company)"], "search": "Kapital denim logo"},
    "noun-kenzo": {"wiki": ["Kenzo (brand)"], "search": "Kenzo logo"},
    "noun-kith": {"wiki": ["Kith (brand)"], "search": "Kith logo"},
    "noun-le-fleur": {"search": "Golf le Fleur logo"},
    "noun-loewe": {"wiki": ["Loewe (brand)"], "search": "Loewe anagram logo"},
    "noun-lululemon": {"wiki": ["Lululemon"], "search": "Lululemon logo"},
    "noun-margiela": {"wiki": ["Maison Margiela"], "search": "Maison Margiela logo"},
    "noun-marni": {"wiki": ["Marni"], "search": "Marni logo"},
    "noun-mcm": {"wiki": ["MCM (fashion house)"], "search": "MCM logo visetos"},
    "noun-michael-kors": {"wiki": ["Michael Kors"], "search": "Michael Kors logo"},
    "noun-moschino": {"wiki": ["Moschino"], "search": "Moschino logo"},
    "noun-new-balance": {"wiki": ["New Balance"], "search": "New Balance logo"},
    "noun-puma": {"wiki": ["Puma (brand)"], "search": "Puma logo cat"},
    "noun-raf-simons": {"wiki": ["Raf Simons"], "search": "Raf Simons logo"},
    "noun-ray-bans": {"wiki": ["Ray-Ban"], "search": "Ray-Ban logo"},
    "noun-reebok": {"wiki": ["Reebok"], "search": "Reebok logo"},
    "noun-rhude": {"search": "Rhude logo"},
    "noun-robin-jeans": {"search": "Robins Jeans logo"},
    "noun-sean-john": {"wiki": ["Sean John"], "search": "Sean John logo"},
    "noun-skims": {"wiki": ["Skims"], "search": "Skims logo"},
    "noun-stussy": {"wiki": ["Stüssy"], "search": "Stussy logo"},
    "noun-thom-browne": {"wiki": ["Thom Browne"], "search": "Thom Browne logo"},
    "noun-triple-s": {"wiki": ["Balenciaga"], "search": "Balenciaga Triple S sneaker"},
    "noun-van-cleef": {"wiki": ["Van Cleef & Arpels"], "search": "Van Cleef Arpels logo"},
    "noun-vetements": {"wiki": ["Vetements"], "search": "Vetements logo"},
    "noun-virgil": {"wiki": ["Virgil Abloh"], "search": "Off-White logo"},
    "noun-yohji": {"wiki": ["Yohji Yamamoto"], "search": "Yohji Yamamoto logo"},
    "noun-gun-switch": {"wiki": ["Glock"], "search": "Glock 17 pistol side"},
    "noun-100k-bezel": {"search": "diamond bezel Rolex watch"},
    "noun-baguette": {"search": "baguette diamond jewelry"},
    "noun-bezel": {"search": "diamond bezel watch close up"},
    "noun-bustdown": {"search": "iced out Rolex bust down"},
    "noun-bustdown-wrist": {"search": "iced out watch on wrist"},
    "noun-cross": {"search": "diamond cross pendant gold"},
    "noun-down-bling": {"search": "iced out gold chain jewelry"},
    "noun-flooded": {"search": "iced out diamond jewelry"},
    "noun-flooded-belt": {"search": "diamond belt buckle iced"},
    "noun-flooded-belt-buckle": {"search": "iced out belt buckle"},
    "noun-flooded-diamond": {"search": "pavé diamond jewelry close up"},
    "noun-flooded-neck": {"search": "iced out cuban link chain diamonds"},
    "noun-gangsta-grillz": {"search": "gold grillz teeth jewelry"},
    "noun-grill": {"search": "gold grillz"},
    "noun-grillz": {"search": "gold diamond grillz"},
    "noun-honeycomb": {"search": "Audemars Piguet royal oak tapisserie"},
    "noun-hublot": {"wiki": ["Hublot"], "search": "Hublot Big Bang watch"},
    "noun-icebox": {"search": "iced out jewelry display"},
    "noun-jacob": {"wiki": ["Jacob & Co"], "search": "Jacob and Co watch"},
    "noun-jane-both": {"search": "two Rolex watches"},
    "noun-jesus-piece": {"search": "jesus piece gold pendant"},
    "noun-mille-aquia": {"wiki": ["Richard Mille"], "search": "Richard Mille watch"},
    "noun-offshore": {"wiki": ["Audemars Piguet"], "search": "Royal Oak Offshore watch"},
    "noun-patek": {"wiki": ["Patek Philippe"], "search": "Patek Philippe Nautilus watch"},
    "noun-pointers": {"search": "diamond solitaire ring"},
    "noun-presidential": {"search": "Rolex Day-Date Presidential watch"},
    "noun-presidential-face": {"search": "Rolex Day-Date gold watch face"},
    "noun-ring-blingin": {"search": "diamond ring close up"},
    "noun-rolex": {
        "files": ["Rolex logo.svg", "Rolex Datejust.jpg"],
        "wiki": ["Rolex"],
        "search": "Rolex Submariner watch",
    },
    "noun-rose-sky-dweller": {"search": "Rolex Sky-Dweller Everose"},
    "noun-skydweller-jubilee": {"search": "Rolex Sky-Dweller Jubilee"},
    "noun-tennis-chain": {"search": "gold tennis chain necklace diamonds"},
    "noun-vs1": {"search": "round diamond gemstone"},
    "noun-place-block": {"wiki": ["City block"], "search": "urban city residential block street"},
    "noun-1800": {"wiki": ["1800 Tequila"], "search": "1800 tequila bottle"},
    "noun-belaire": {"wiki": ["Luc Belaire"], "search": "Luc Belaire Rare rose bottle"},
    "noun-dom": {
        "files": ["DomPerignonChampagne.jpg", "Champagne Dom Perignon.jpg"],
        "wiki": ["Dom Pérignon"],
        "search": "Dom Perignon champagne bottle",
    },
    "noun-dusse": {"wiki": ["D'USSÉ"], "search": "Dusse cognac bottle"},
    "noun-tequila": {"wiki": ["Tequila"], "search": "tequila bottle agave"},
    "noun-vsop": {
        "files": ["Remy Martin VSOP.jpg"],
        "search": "VSOP cognac bottle",
    },
    "noun-xo": {
        "files": ["Hennessy XO Cognac 3L 40%.jpg", "Cognac Hennessy XO.jpg"],
        "search": "Hennessy XO cognac bottle",
    },
    "noun-yak": {"wiki": ["Cognac"], "search": "cognac bottle"},
    "noun-money-paycheck": {"wiki": ["Paycheck"], "search": "paycheck stub"},
    "noun-place-trap": {"search": "urban brick house night"},
    "noun-codeine-daiquiri": {"search": "pink daiquiri cocktail"},
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
    last = None
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
            "iiurlwidth": 900,
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
        {"q": query, "page_size": 12}
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
    for score, url, _t in ranked[:8]:
        try:
            data = http_get_retry(url)
            if len(data) > 2500:
                return data, url
        except Exception:
            continue
    return None


def fetch_real(icon: str) -> Path | None:
    CACHE.mkdir(parents=True, exist_ok=True)
    dest = CACHE / f"{icon}.png"
    if dest.exists() and dest.stat().st_size > 2000:
        return dest
    spec = SOURCES.get(icon, {})
    needle = icon.replace("noun-", "").replace("-", " ")
    for fn in spec.get("files") or []:
        got = commons_thumb(fn)
        time.sleep(0.5)
        if got and save_raw(got[0], dest):
            return dest
    for title in spec.get("wiki") or []:
        got = wiki_thumb(title)
        time.sleep(0.5)
        if got and save_raw(got[0], dest):
            return dest
    q = spec.get("search") or needle + " logo"
    got = openverse(q, needle)
    time.sleep(0.4)
    if got and save_raw(got[0], dest):
        return dest
    got = commons_search(q)
    if got and save_raw(got[0], dest):
        return dest
    return None


def commons_search(query: str) -> tuple[bytes, str] | None:
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
    # Flatten tiny alpha onto white for bbox, then crop non-white.
    bg = Image.new("RGBA", im.size, (255, 255, 255, 255))
    bg.alpha_composite(im)
    rgb = bg.convert("RGB")
    # Near-white mask
    gray = rgb.convert("L")
    inv = Image.eval(gray, lambda p: 0 if p > 242 else 255)
    bbox = inv.getbbox()
    if not bbox:
        return im
    # pad bbox a little
    x0, y0, x1, y1 = bbox
    pad = 8
    x0 = max(0, x0 - pad)
    y0 = max(0, y0 - pad)
    x1 = min(im.size[0], x1 + pad)
    y1 = min(im.size[1], y1 + pad)
    # Don't crop away most of a photo
    area = (x1 - x0) * (y1 - y0)
    if area < 0.18 * im.size[0] * im.size[1]:
        return im
    return im.crop((x0, y0, x1, y1))


def to_square(im: Image.Image) -> Image.Image:
    im = im.convert("RGBA")
    # Flatten on white
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
                "images": [{"filename": f"{icon}.png", "idiom": "universal", "scale": "1x"}],
                "info": {"author": "xcode", "version": 1},
            },
            indent=2,
        )
        + "\n"
    )
    return png


def load(path: Path, frac=None) -> Image.Image:
    im = Image.open(path)
    return crop_content(im, frac)


def main() -> None:
    import urllib.error  # noqa: F401 — used in http_get_retry

    ok, fail = [], []

    print("=== C from found ===")
    for icon in C_FROM_FOUND:
        src = FOUND / f"{icon}.png"
        if not src.exists():
            fail.append((icon, "missing found"))
            continue
        try:
            im = load(src, C_CROP.get(icon))
            write_imageset(icon, im)
            ok.append(icon)
            print("  C", icon)
        except Exception as e:
            fail.append((icon, str(e)))
            print("  C FAIL", icon, e)

    need_fetch = list(C_REJECT) + [
        "noun-bb-belt", "noun-bvlgari", "noun-cactus-jack", "noun-carhartt",
        "noun-casablanca", "noun-cdg", "noun-comme-des-garcons", "noun-converse",
        "noun-denim-tears", "noun-dickies", "noun-ed-hardy", "noun-evisu",
        "noun-fear-of-god-pants", "noun-ferragamo", "noun-force-1s", "noun-fubu",
        "noun-gats", "noun-givenchy", "noun-golden-goose", "noun-golf-wang",
        "noun-helmut-lang", "noun-heron-preston", "noun-human-made",
        "noun-issey-miyake", "noun-kapital", "noun-kenzo", "noun-kith",
        "noun-le-fleur", "noun-loewe", "noun-lululemon", "noun-margiela",
        "noun-marni", "noun-mcm", "noun-michael-kors", "noun-moschino",
        "noun-new-balance", "noun-puma", "noun-raf-simons", "noun-ray-bans",
        "noun-reebok", "noun-rhude", "noun-robin-jeans", "noun-sean-john",
        "noun-skims", "noun-stussy", "noun-thom-browne", "noun-triple-s",
        "noun-van-cleef", "noun-vetements", "noun-virgil", "noun-yohji",
        "noun-gun-switch", "noun-100k-bezel", "noun-baguette", "noun-bezel",
        "noun-bustdown", "noun-bustdown-wrist", "noun-cross", "noun-down-bling",
        "noun-flooded", "noun-flooded-belt", "noun-flooded-belt-buckle",
        "noun-flooded-diamond", "noun-flooded-neck", "noun-gangsta-grillz",
        "noun-grill", "noun-grillz", "noun-honeycomb", "noun-hublot",
        "noun-icebox", "noun-jacob", "noun-jane-both", "noun-jesus-piece",
        "noun-mille-aquia", "noun-offshore", "noun-patek", "noun-pointers",
        "noun-presidential", "noun-presidential-face", "noun-ring-blingin",
        "noun-rolex", "noun-rose-sky-dweller", "noun-skydweller-jubilee",
        "noun-tennis-chain", "noun-vs1", "noun-place-block", "noun-1800",
        "noun-belaire", "noun-dom", "noun-dusse", "noun-tequila", "noun-vsop",
        "noun-xo", "noun-yak", "noun-money-paycheck", "noun-place-trap",
        "noun-codeine-daiquiri",
    ]

    print(f"=== fetch real marks {len(need_fetch)} ===")
    for i, icon in enumerate(need_fetch, 1):
        path = fetch_real(icon)
        if not path:
            fail.append((icon, "fetch miss"))
            print(f"  {i}/{len(need_fetch)} MISS {icon}")
            time.sleep(0.6)
            continue
        try:
            im = load(path)
            write_imageset(icon, im)
            ok.append(icon)
            print(f"  {i}/{len(need_fetch)} OK {icon}")
        except Exception as e:
            fail.append((icon, str(e)))
            print(f"  {i}/{len(need_fetch)} FAIL {icon} {e}")
        time.sleep(0.7)

    # Share CDG / Comme
    cdg = ASSET / "noun-cdg.imageset" / "noun-cdg.png"
    comme = ASSET / "noun-comme-des-garcons.imageset" / "noun-comme-des-garcons.png"
    if cdg.exists() and not comme.exists():
        write_imageset("noun-comme-des-garcons", Image.open(cdg))
        ok.append("noun-comme-des-garcons")
    if comme.exists() and not cdg.exists():
        write_imageset("noun-cdg", Image.open(comme))
        ok.append("noun-cdg")

    dest = DESKTOP / "XJournal AI" / "Assets.xcassets" / "NounMarks"
    if dest.parent.exists():
        shutil.copytree(ASSET, dest, dirs_exist_ok=True)
        print("synced Desktop NounMarks")
    print(f"wrote {len(ok)} imagesets, {len(fail)} failures")
    for icon, why in fail:
        print("  FAIL", icon, why)


if __name__ == "__main__":
    main()
