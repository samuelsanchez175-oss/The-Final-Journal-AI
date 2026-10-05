#!/usr/bin/env python3
"""Build docs/noun-chooser — A/B/C mark picker with found-online product photos."""

from __future__ import annotations

import json
import re
import shutil
import ssl
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request
import unicodedata
from collections import defaultdict
from io import BytesIO
from pathlib import Path

from PIL import Image

ROOT = Path("/Users/samuel/Documents/The Final Journal AI.nosync")
DESKTOP = Path("/Users/samuel/Desktop/pennworkstudios.nosync")
SWIFT_CATALOG = ROOT / "XJournal AI" / "NounBankCatalog.swift"
SWIFT_MARK = ROOT / "XJournal AI" / "NounBankMark.swift"
SWIFT_STORE = ROOT / "XJournal AI" / "NounBankStore.swift"
ASSET_DIR = ROOT / "XJournal AI" / "Assets.xcassets" / "NounMarks"
OUT = ROOT / "docs" / "noun-chooser"
CURRENT_DIR = OUT / "current"
FOUND_DIR = OUT / "found"
UA = "PenworkNounChooser/1.0 (local; Penn Work Studios lyric noun marks)"
CTX = ssl.create_default_context()
THUMB = 420

# Wikipedia titles / Commons filenames / extra URLs for real-world products.
# Prefer a real bottle, logo, pill, chain, or garment — never a generated stand-in.
FOUND_SOURCES: dict[str, dict] = {
    # —— Liquors ——
    "noun-hennessy": {
        "files": ["2023 Hennessy V.S. Cognac.jpg", "Hennessy XO Cognac 3L 40%.jpg", "Logo Hennessy studio.png"],
        "search": "Hennessy VS cognac bottle",
    },
    "noun-remy": {
        "files": ["Remy Martin wordmark.svg", "Remy Martin VSOP.jpg", "Rémy Martin cognac.jpg"],
        "search": "Remy Martin VSOP bottle",
    },
    "noun-ace": {
        "files": ["Armand de Brignac.jpg"],
        "search": "Armand de Brignac Ace of Spades bottle",
    },
    "noun-dom": {
        "files": ["Logo - Dom Pérignon.svg", "DomPerignonChampagne.jpg", "Champagne Dom Perignon.jpg"],
        "search": "Dom Perignon champagne bottle",
    },
    "noun-cristal": {
        "files": ["Louis Roederer Cristal Champagne.jpg", "Louis Roederer Cristal.jpg"],
        "search": "Louis Roederer Cristal champagne bottle",
    },
    "noun-moet": {
        "files": ["85 moet et chandon emballage.jpg"],
        "search": "Moet Chandon champagne bottle",
    },
    "noun-dusse": {
        "search": "Dusse cognac bottle",
    },
    "noun-don-julio": {
        "files": ["Tequila Don Julio.jpg", "Don Julio 2014.jpg", "Don Julio 02.jpg"],
        "search": "Don Julio tequila bottle",
    },
    "noun-clase-azul": {
        "search": "Clase Azul tequila bottle",
    },
    "noun-1942": {
        "files": ["Don Julio 2014.jpg", "Tequila Don Julio.jpg"],
        "search": "Don Julio 1942 tequila bottle",
    },
    "noun-casamigos": {
        "search": "Casamigos tequila bottle",
    },
    "noun-ciroc": {
        "search": "Ciroc vodka bottle",
    },
    "noun-grey-goose": {
        "files": ["Grey Goose Bottle.jpg", "Trois bouteilles de Grey Goose..jpg"],
        "search": "Grey Goose vodka bottle",
    },
    "noun-belvedere": {
        "search": "Belvedere vodka bottle",
    },
    "noun-louis-xiii": {
        "files": ["80127 Louis XIII.jpg", "$5,000 Louis XIII de Remy Martin Cognac (6279270249).jpg"],
        "search": "Louis XIII cognac decanter",
    },
    "noun-nuvo": {
        "wiki": ["Nuvo (liqueur)"],
        "search": "Nuvo liqueur pink bottle",
    },
    "noun-belaire": {
        "wiki": ["Luc Belaire"],
        "search": "Luc Belaire Rare rose bottle",
    },
    "noun-yak": {
        "wiki": ["Cognac"],
        "search": "cognac bottle",
    },
    "noun-patron": {
        "files": ["PatronGoldBottle.jpg"],
        "search": "Patron tequila bottle",
    },
    "noun-tequila": {
        "wiki": ["Tequila"],
        "search": "tequila bottle",
    },
    "noun-vodka": {
        "wiki": ["Vodka"],
        "search": "vodka bottle",
    },
    "noun-whiskey": {
        "wiki": ["Whisky"],
        "search": "whiskey bottle",
    },
    "noun-cognac": {
        "wiki": ["Cognac"],
        "search": "cognac bottle",
    },
    "noun-bourbon": {
        "wiki": ["Bourbon whiskey"],
        "search": "bourbon whiskey bottle",
    },
    "noun-champagne": {
        "wiki": ["Champagne"],
        "search": "champagne bottle",
    },
    "noun-1800": {
        "wiki": ["1800 Tequila"],
        "search": "1800 tequila bottle",
    },
    "noun-absolut": {
        "search": "Absolut vodka bottle",
    },
    "noun-vsop": {
        "wiki": ["Cognac"],
        "search": "VSOP cognac bottle",
    },
    "noun-xo": {
        "wiki": ["Cognac"],
        "search": "XO cognac bottle",
    },
    # —— Syrups ——
    "noun-lean": {
        "wiki": ["Purple drank"],
        "search": "purple drank double cup styrofoam",
    },
    "noun-wockhardt": {
        "wiki": ["Wockhardt"],
        "search": "Wockhardt codeine cough syrup bottle",
    },
    "noun-hi-tech": {
        "wiki": ["Promethazine"],
        "search": "Hi-Tech promethazine codeine red syrup",
    },
    "noun-robitussin": {
        "wiki": ["Robitussin"],
        "search": "Robitussin cough syrup bottle",
    },
    "noun-qualitest": {
        "wiki": ["Endo International", "Promethazine"],
        "search": "Qualitest promethazine codeine syrup",
    },
    "noun-dirty-sprite": {
        "wiki": ["Sprite (drink)"],
        "search": "Sprite soda bottle green",
    },
    "noun-codeine-daiquiri": {
        "wiki": ["Codeine"],
        "search": "codeine syrup bottle",
    },
    "noun-codeine": {
        "wiki": ["Codeine"],
        "search": "codeine phosphate bottle",
    },
    "noun-promethazine": {
        "wiki": ["Promethazine"],
        "search": "promethazine codeine cough syrup",
    },
    "noun-styrofoam": {
        "wiki": ["Polystyrene"],
        "search": "white styrofoam cup",
    },
    "noun-double-cup": {
        "wiki": ["Purple drank"],
        "search": "double styrofoam cup lean",
    },
    "noun-actavis": {
        "wiki": ["Purple drank", "Actavis"],
        "search": "Actavis promethazine codeine purple",
    },
    # —— Drugs (educational product photos) ——
    "noun-drug-perc": {
        "wiki": ["Oxycodone/paracetamol", "Percocet"],
        "search": "Percocet pill",
    },
    "noun-drug-xanax": {
        "wiki": ["Alprazolam"],
        "search": "Xanax alprazolam bar pill",
    },
    "noun-drug-molly": {
        "wiki": ["MDMA"],
        "search": "MDMA ecstasy pills",
    },
    "noun-drug-cocaine": {
        "wiki": ["Cocaine"],
        "search": "cocaine powder",
    },
    "noun-drug-weed": {
        "wiki": ["Cannabis (drug)"],
        "search": "cannabis bud",
    },
    "noun-drug-backwood": {
        "wiki": ["Backwoods (cigar)"],
        "search": "Backwoods cigar pack",
    },
    "noun-drug-addy": {
        "wiki": ["Adderall"],
        "search": "Adderall pill",
    },
    "noun-drug-shroom": {
        "wiki": ["Psilocybin mushroom"],
        "search": "psilocybe mushroom",
    },
    "noun-drug-fetty": {
        "wiki": ["Fentanyl"],
        "search": "fentanyl pharmaceutical",
    },
    "noun-drug-oxy": {
        "wiki": ["Oxycodone"],
        "search": "oxycodone pill",
    },
    "noun-drug-acid": {
        "wiki": ["Lysergic acid diethylamide"],
        "search": "LSD blotter",
    },
    # —— Jewelry ——
    "noun-rolex": {
        "search": "Rolex watch",
    },
    "noun-ap": {
        "wiki": ["Audemars Piguet"],
        "search": "Audemars Piguet Royal Oak watch",
    },
    "noun-patek": {
        "wiki": ["Patek Philippe"],
        "search": "Patek Philippe watch",
    },
    "noun-cartier": {
        "search": "Cartier logo watch",
    },
    "noun-cuban": {
        "wiki": ["Gold chain", "Chain (ornament)"],
        "search": "gold cuban link chain",
    },
    "noun-vvs": {
        "wiki": ["Diamond"],
        "search": "round diamond gem",
    },
    "noun-jacob": {
        "wiki": ["Jacob & Co"],
        "search": "Jacob and Co watch",
    },
    "noun-hublot": {
        "wiki": ["Hublot"],
        "search": "Hublot Big Bang watch",
    },
    "noun-chrome-hearts": {
        "wiki": ["Chrome Hearts"],
        "search": "Chrome Hearts logo cross",
    },
    # —— Brands / clothing houses ——
    "noun-louis": {"wiki": ["Louis Vuitton"], "search": "Louis Vuitton logo"},
    "noun-louis-trench": {"wiki": ["Trench coat"], "search": "Louis Vuitton trench coat"},
    "noun-louis-pouch": {"wiki": ["Louis Vuitton"], "search": "Louis Vuitton pouch"},
    "noun-louis-bag": {"wiki": ["Louis Vuitton"], "search": "Louis Vuitton Speedy bag"},
    "noun-louis-belt": {"wiki": ["Louis Vuitton"], "search": "Louis Vuitton belt buckle"},
    "noun-louis-luggage": {"wiki": ["Louis Vuitton"], "search": "Louis Vuitton trunk luggage"},
    "noun-louis-loafers": {"wiki": ["Loafer"], "search": "Louis Vuitton loafers"},
    "noun-louis-scarf": {"wiki": ["Louis Vuitton"], "search": "Louis Vuitton monogram scarf"},
    "noun-louis-vest": {"wiki": ["Louis Vuitton"], "search": "leather vest"},
    "noun-louis-damier": {"wiki": ["Louis Vuitton"], "search": "Louis Vuitton Damier print"},
    "noun-louis-bandana": {"wiki": ["Bandana"], "search": "Louis Vuitton bandana"},
    "noun-louboutin": {"wiki": ["Christian Louboutin"], "search": "Louboutin red sole shoe"},
    "noun-gucci": {"wiki": ["Gucci"], "search": "Gucci logo"},
    "noun-chanel": {"wiki": ["Chanel"], "search": "Chanel logo CC"},
    "noun-dior": {"wiki": ["Dior"], "search": "Dior logo"},
    "noun-prada": {"wiki": ["Prada"], "search": "Prada logo"},
    "noun-versace": {"wiki": ["Versace"], "search": "Versace Medusa logo"},
    "noun-balenciaga": {"wiki": ["Balenciaga"], "search": "Balenciaga logo"},
    "noun-off-white": {"wiki": ["Off-White (company)"], "search": "Off-White logo"},
    "noun-yeezy": {"wiki": ["Yeezy"], "search": "Yeezy logo"},
    "noun-goyard": {"wiki": ["Goyard"], "search": "Goyard logo"},
    "noun-hermes": {"wiki": ["Hermès"], "search": "Hermes logo"},
    "noun-ysl": {"wiki": ["Yves Saint Laurent (fashion house)"], "search": "Saint Laurent YSL logo"},
    "noun-amiri": {"wiki": ["Amiri (fashion brand)"], "search": "Amiri logo"},
    "noun-fendi": {"wiki": ["Fendi"], "search": "Fendi logo"},
    "noun-bape": {"wiki": ["A Bathing Ape"], "search": "Bape ape head logo"},
    "noun-nike": {"wiki": ["Nike, Inc."], "search": "Nike swoosh logo"},
    "noun-givenchy": {"wiki": ["Givenchy"], "search": "Givenchy logo"},
    "noun-supreme": {"wiki": ["Supreme (brand)"], "search": "Supreme box logo"},
    "noun-celine": {"wiki": ["Celine (brand)"], "search": "Celine logo"},
    "noun-vlone": {"wiki": ["Vlone"], "search": "Vlone V logo"},
    "noun-moncler": {"wiki": ["Moncler"], "search": "Moncler logo"},
    "noun-bottega": {"wiki": ["Bottega Veneta"], "search": "Bottega Veneta logo"},
    "noun-adidas": {"wiki": ["Adidas"], "search": "Adidas logo"},
    "noun-fear-of-god": {"wiki": ["Fear of God (fashion brand)"], "search": "Fear of God logo"},
    "noun-telfar": {"wiki": ["Telfar"], "search": "Telfar logo"},
    "noun-sp5der": {
        "urls": ["https://kingspider.co/cdn/shop/files/SSIMG.png"],
        "wiki": ["Young Thug"],
        "search": "Sp5der 555 hoodie logo",
    },
    "noun-palm-angels": {"wiki": ["Palm Angels"], "search": "Palm Angels logo"},
    "noun-rick-owens": {"wiki": ["Rick Owens"], "search": "Rick Owens logo"},
    "noun-true-religion": {"wiki": ["True Religion (jeans)"], "search": "True Religion logo"},
    "noun-north-face": {"wiki": ["The North Face"], "search": "North Face logo"},
    "noun-canada-goose": {"wiki": ["Canada Goose (clothing)"], "search": "Canada Goose Arctic Program logo"},
    "noun-ski-mask": {"wiki": ["Balaclava (clothing)"], "search": "black ski mask balaclava"},
    "noun-timbs": {"wiki": ["Timberland (company)"], "search": "Timberland wheat boot"},
    "noun-mink": {"wiki": ["Fur clothing"], "search": "mink fur coat"},
    # —— Cars ——
    "noun-car-ferrari": {"wiki": ["Ferrari"], "search": "Ferrari sports car"},
    "noun-car-lambo": {"wiki": ["Lamborghini"], "search": "Lamborghini Aventador"},
    "noun-car-urus": {"wiki": ["Lamborghini Urus"], "search": "Lamborghini Urus"},
    "noun-car-benz": {"wiki": ["Mercedes-Benz"], "search": "Mercedes-Benz S-Class"},
    "noun-car-gwagon": {"wiki": ["Mercedes-Benz G-Class"], "search": "Mercedes G-Wagon"},
    "noun-car-rangerover": {"wiki": ["Range Rover"], "search": "Range Rover"},
    "noun-car-rolls": {"wiki": ["Rolls-Royce Motor Cars"], "search": "Rolls-Royce Cullinan"},
    "noun-car-hellcat": {"wiki": ["Dodge Charger (2015)"], "search": "Dodge Hellcat Charger"},
    "noun-car-porsche": {"wiki": ["Porsche"], "search": "Porsche 911"},
    "noun-car-maybach": {"wiki": ["Mercedes-Maybach"], "search": "Maybach sedan"},
    "noun-car-bentley": {"wiki": ["Bentley"], "search": "Bentley Continental"},
    "noun-car-mclaren": {"wiki": ["McLaren Automotive"], "search": "McLaren supercar"},
    "noun-car-tesla": {"wiki": ["Tesla, Inc."], "search": "Tesla Model S"},
    "noun-car-cadillac": {"wiki": ["Cadillac"], "search": "Cadillac Escalade"},
    "noun-car-chevy": {"wiki": ["Chevrolet"], "search": "Chevrolet Impala"},
    "noun-car-sprinter": {"wiki": ["Mercedes-Benz Sprinter"], "search": "Sprinter van"},
    "noun-car-jet": {"wiki": ["Private jet"], "search": "private jet"},
    "noun-car-whip": {"wiki": ["Car"], "search": "luxury car"},
    # —— Money ——
    "noun-money-racks": {"wiki": ["United States one-hundred-dollar bill"], "search": "stack of 100 dollar bills"},
    "noun-money-bands": {"wiki": ["United States one-hundred-dollar bill"], "search": "banded cash stack"},
    "noun-money-hundred": {"wiki": ["United States one-hundred-dollar bill"], "search": "US 100 dollar bill"},
    "noun-money-bag": {"wiki": ["Money bag"], "search": "money bag cash"},
    "noun-money-millie": {"wiki": ["United States one-hundred-dollar bill"], "search": "million dollars cash"},
    "noun-money-zelle": {"wiki": ["Zelle (payment service)"], "search": "Zelle logo"},
    "noun-money-cashapp": {"wiki": ["Cash App"], "search": "Cash App logo"},
    "noun-money-paycheck": {"wiki": ["Paycheck"], "search": "paycheck stub"},
    "noun-money-watch": {"wiki": ["Richard Mille"], "search": "Richard Mille watch"},
    # —— Places ——
    "noun-place-atlanta": {"wiki": ["Atlanta"], "search": "Atlanta skyline"},
    "noun-place-miami": {"wiki": ["Miami"], "search": "Miami skyline"},
    "noun-place-memphis": {"wiki": ["Memphis, Tennessee"], "search": "Memphis skyline"},
    "noun-place-chicago": {"wiki": ["Chicago"], "search": "Chicago skyline"},
    "noun-place-houston": {"wiki": ["Houston"], "search": "Houston skyline"},
    "noun-place-magiccity": {"wiki": ["Magic City (strip club)"], "search": "Atlanta Magic City"},
    "noun-place-calabasas": {"wiki": ["Calabasas, California"], "search": "Calabasas"},
    "noun-place-hollywood": {"wiki": ["Hollywood Sign"], "search": "Hollywood sign"},
    "noun-place-nola": {"wiki": ["New Orleans"], "search": "New Orleans French Quarter"},
    "noun-place-philly": {"wiki": ["Philadelphia"], "search": "Philadelphia skyline"},
    "noun-place-penthouse": {"wiki": ["Penthouse apartment"], "search": "penthouse interior"},
    "noun-place-mansion": {"wiki": ["Mansion"], "search": "luxury mansion"},
    "noun-place-paris": {"wiki": ["Eiffel Tower"], "search": "Eiffel Tower"},
    "noun-place-london": {"wiki": ["London"], "search": "London skyline Big Ben"},
    "noun-place-dubai": {"wiki": ["Burj Khalifa"], "search": "Burj Khalifa Dubai"},
    "noun-place-tokyo": {"wiki": ["Tokyo"], "search": "Tokyo skyline"},
    "noun-place-jamaica": {"wiki": ["Jamaica"], "search": "Jamaica beach"},
    "noun-place-overseas": {"wiki": ["Passport"], "search": "passport travel"},
    "noun-place-trap": {"wiki": ["Trap house"], "search": "urban house night"},
    "noun-place-studio": {"wiki": ["Recording studio"], "search": "recording studio booth"},
    "noun-place-block": {"wiki": ["City block"], "search": "city residential block"},
    "noun-place-hood": {"wiki": ["Neighbourhood"], "search": "urban neighborhood street"},
    # —— Guns (product side profile; lyric chips only) ——
    "noun-gun-glock": {"wiki": ["Glock"], "search": "Glock pistol"},
    "noun-gun-draco": {"wiki": ["AK-47"], "search": "Draco pistol AK"},
    "noun-gun-mac11": {"wiki": ["MAC-11"], "search": "MAC-11"},
    "noun-gun-fn": {"wiki": ["FN Herstal"], "search": "FN Five-seven"},
    "noun-gun-rifle": {"wiki": ["Rifle"], "search": "rifle side view"},
    "noun-gun-shotgun": {"wiki": ["Shotgun"], "search": "shotgun side view"},
    "noun-gun-pistol": {"wiki": ["Pistol"], "search": "pistol side view"},
    "noun-gun-drum": {"wiki": ["Drum magazine"], "search": "drum magazine"},
}


def http_get(url: str, timeout: int = 25) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "*/*"})
    with urllib.request.urlopen(req, timeout=timeout, context=CTX) as resp:
        ctype = (resp.headers.get("Content-Type") or "").lower()
        data = resp.read()
        if "text/html" in ctype and len(data) > 200 and b"<html" in data[:400].lower():
            raise ValueError(f"HTML not image: {url}")
        return data


def wiki_image(title: str) -> tuple[bytes, str] | None:
    api = (
        "https://en.wikipedia.org/w/api.php?"
        + urllib.parse.urlencode(
            {
                "action": "query",
                "titles": title,
                "prop": "pageimages",
                "format": "json",
                "pithumbsize": 800,
                "piprop": "thumbnail",
            }
        )
    )
    try:
        info = json.loads(http_get(api, timeout=30).decode("utf-8"))
        pages = info.get("query", {}).get("pages", {})
        for page in pages.values():
            src = (page.get("thumbnail") or {}).get("source")
            if src:
                return http_get(src, timeout=30), src
    except Exception:
        return None
    return None


def openverse_image(query: str, needle: str) -> tuple[bytes, str] | None:
    api = "https://api.openverse.org/v1/images/?" + urllib.parse.urlencode(
        {"q": query, "page_size": 10}
    )
    try:
        info = json.loads(http_get(api, timeout=30).decode("utf-8"))
    except Exception:
        return None
    needle = (needle or query.split()[0]).lower()
    ranked = []
    for r in info.get("results") or []:
        title = (r.get("title") or "").lower()
        url = r.get("url")
        if not url:
            continue
        score = 2 if needle in title else 0
        ranked.append((score, url, r.get("title") or ""))
    ranked.sort(key=lambda x: -x[0])
    for score, url, _title in ranked[:6]:
        try:
            data = http_get(url, timeout=30)
            if len(data) > 2000:
                return data, url
        except Exception:
            continue
    return None


def commons_file(filename: str) -> tuple[bytes, str] | None:
    """Fetch an 800px Wikimedia thumb — full originals trip 429."""
    title = filename if filename.lower().startswith("file:") else "File:" + filename
    api = (
        "https://commons.wikimedia.org/w/api.php?"
        + urllib.parse.urlencode(
            {
                "action": "query",
                "titles": title,
                "prop": "imageinfo",
                "iiprop": "url|mime",
                "iiurlwidth": 800,
                "format": "json",
            }
        )
    )
    try:
        info = json.loads(http_get(api, timeout=30).decode("utf-8"))
        pages = info.get("query", {}).get("pages", {})
        for page in pages.values():
            ii = (page.get("imageinfo") or [None])[0]
            if not ii:
                continue
            src = ii.get("thumburl") or ii.get("url")
            if not src:
                continue
            data = http_get(src, timeout=30)
            if len(data) < 800:
                continue
            return data, src
    except Exception:
        return None
    return None


def commons_search(query: str) -> tuple[bytes, str] | None:
    api = (
        "https://commons.wikimedia.org/w/api.php?"
        + urllib.parse.urlencode(
            {
                "action": "query",
                "list": "search",
                "srsearch": query,
                "srnamespace": 6,
                "srlimit": 5,
                "format": "json",
            }
        )
    )
    try:
        info = json.loads(http_get(api).decode("utf-8"))
    except Exception:
        return None
    for hit in info.get("query", {}).get("search", []):
        title = hit.get("title") or ""
        if not title.lower().startswith("file:"):
            title = "File:" + title
        file_api = (
            "https://commons.wikimedia.org/w/api.php?"
            + urllib.parse.urlencode(
                {
                    "action": "query",
                    "titles": title,
                    "prop": "imageinfo",
                    "iiprop": "url|mime|size",
                    "iiurlwidth": 900,
                    "format": "json",
                }
            )
        )
        try:
            finfo = json.loads(http_get(file_api).decode("utf-8"))
            pages = finfo.get("query", {}).get("pages", {})
            for page in pages.values():
                ii = (page.get("imageinfo") or [None])[0]
                if not ii:
                    continue
                mime = (ii.get("mime") or "").lower()
                if "svg" in mime or "png" in mime or "jpeg" in mime or "jpg" in mime or "webp" in mime:
                    src = ii.get("thumburl") or ii.get("url")
                    if src:
                        return http_get(src), src
        except Exception:
            continue
    return None


def rasterize_svg(data: bytes, dest: Path) -> bool:
    tmp = dest.with_suffix(".svg")
    tmp.write_bytes(data)
    outdir = dest.parent
    try:
        subprocess.run(
            ["qlmanage", "-t", "-s", "900", "-o", str(outdir), str(tmp)],
            check=True,
            capture_output=True,
        )
    except Exception:
        tmp.unlink(missing_ok=True)
        return False
    produced = Path(str(tmp) + ".png")
    alt = outdir / (tmp.name + ".png")
    src = produced if produced.exists() else alt
    tmp.unlink(missing_ok=True)
    if not src.exists():
        return False
    Image.open(src).convert("RGBA").save(dest)
    src.unlink(missing_ok=True)
    return dest.exists()


def to_thumb(im: Image.Image, size: int = THUMB) -> Image.Image:
    im = im.convert("RGBA")
    # Flatten onto white so invented-transparent and photo both read on dark UI.
    bg = Image.new("RGBA", im.size, (255, 255, 255, 255))
    bg.alpha_composite(im)
    rgb = bg.convert("RGB")
    rgb.thumbnail((size, size), Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", (size, size), (255, 255, 255))
    x = (size - rgb.size[0]) // 2
    y = (size - rgb.size[1]) // 2
    canvas.paste(rgb, (x, y))
    return canvas


def save_image_bytes(data: bytes, dest: Path) -> bool:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if data[:200].lstrip().startswith(b"<svg") or data[:5] == b"<?xml":
        return rasterize_svg(data, dest)
    try:
        im = Image.open(BytesIO(data))
        to_thumb(im).save(dest, "PNG", optimize=True)
        return True
    except Exception:
        return False


def fetch_found(icon: str) -> dict:
    dest = FOUND_DIR / f"{icon}.png"
    if dest.exists() and dest.stat().st_size > 2000:
        return {"ok": True, "source": f"(cached {dest.name})", "via": "cache"}
    spec = FOUND_SOURCES.get(icon, {})
    needle = icon.replace("noun-", "").replace("-", " ")
    for url in spec.get("urls") or []:
        try:
            data = http_get(url)
            if save_image_bytes(data, dest):
                return {"ok": True, "source": url, "via": "url"}
        except Exception:
            pass
        time.sleep(0.4)
    for fn in spec.get("files") or []:
        got = commons_file(fn)
        if got and save_image_bytes(got[0], dest):
            return {"ok": True, "source": got[1], "via": "commons-file"}
        time.sleep(0.6)
    for title in spec.get("wiki") or []:
        got = wiki_image(title)
        if got and save_image_bytes(got[0], dest):
            return {"ok": True, "source": got[1], "via": "wikipedia"}
        time.sleep(0.6)
    q = spec.get("search") or needle
    got = openverse_image(q, needle)
    if got and save_image_bytes(got[0], dest):
        return {"ok": True, "source": got[1], "via": "openverse"}
    time.sleep(0.4)
    got = commons_search(q)
    if got and save_image_bytes(got[0], dest):
        return {"ok": True, "source": got[1], "via": "commons-search"}
    return {"ok": False, "source": None, "via": None}


def normalize(word: str) -> str:
    s = unicodedata.normalize("NFKD", word)
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = s.casefold()
    for a, b in (("’", ""), ("'", ""), (".", ""), ("-", " "), ("/", " ")):
        s = s.replace(a, b)
    return " ".join(s.split())


def fold_icon(icon: str) -> str:
    s = unicodedata.normalize("NFKD", icon)
    return "".join(c for c in s if not unicodedata.combining(c))


def parse_families(text: str) -> list[dict]:
    families = []
    for m in re.finditer(
        r'Family\(id:\s*"([^"]+)",\s*aliases:\s*\[(.*?)\]',
        text,
        re.S,
    ):
        fid = m.group(1)
        aliases = re.findall(r'"([^"]*)"', m.group(2))
        families.append({"id": fid, "aliases": [normalize(a) for a in aliases]})
    return families


def build_alias_index(families: list[dict]) -> dict[str, str]:
    idx = {}
    for fam in families:
        idx[normalize(fam["id"])] = fam["id"]
        for a in fam["aliases"]:
            idx[a] = fam["id"]
    return idx


def match_family(normalized: str, idx: dict[str, str]) -> str:
    if normalized in idx:
        return idx[normalized]
    tokens = normalized.split()
    if len(tokens) >= 2:
        for i in range(len(tokens) - 1):
            key = tokens[i] + " " + tokens[i + 1]
            if key in idx:
                return idx[key]
    for t in tokens:
        if t in idx:
            return idx[t]
    return normalized


def parse_dict_block(text: str, name: str) -> dict[str, str]:
    m = re.search(rf"{name}:\s*\[String:\s*String\]\s*=\s*\[(.*?)\n\s*\]", text, re.S)
    if not m:
        return {}
    return {k.lower(): v for k, v in re.findall(r'"([^"]+)":\s*"([^"]+)"', m.group(1))}


def parse_store_words(text: str) -> list[tuple[str, str]]:
    items = []
    for m in re.finditer(r"case \.(\w+):\s*return unique\(\[(.*?)\]\)", text, re.S):
        cat = m.group(1)
        words = re.findall(r'"([^"]*)"', m.group(2))
        for w in words:
            items.append((cat, w))
    return items


def icon_name(word: str, family: str, product: dict[str, str], shared: dict[str, str]) -> str:
    key = normalize(word)
    if key in product:
        return product[key]
    if family in shared:
        return shared[family]
    slug = family.replace(" ", "-").replace("'", "")
    return "noun-" + slug


def copy_current(icon: str) -> bool:
    folder = ASSET_DIR / f"{icon}.imageset"
    if not folder.is_dir():
        return False
    pngs = list(folder.glob("*.png"))
    if not pngs:
        return False
    im = Image.open(pngs[0])
    CURRENT_DIR.mkdir(parents=True, exist_ok=True)
    to_thumb(im).save(CURRENT_DIR / f"{icon}.png", "PNG", optimize=True)
    return True


def category_label(key: str) -> str:
    return {
        "liquors": "Liquors",
        "syrups": "Syrups",
        "drugs": "Drugs",
        "jewelry": "Jewelry",
        "brands": "Brands",
        "clothing": "Clothing",
        "guns": "Guns",
        "kill": "Kill",
        "woman": "Woman",
        "money": "Money",
        "cars": "Cars",
        "places": "Places",
    }.get(key, key)


def prefer_found(cats: list[str]) -> bool:
    return any(c in {"Liquors", "Syrups", "Drugs", "Jewelry", "Brands"} for c in cats)


def html_page(rows: list[dict]) -> str:
    data = json.dumps(rows, ensure_ascii=False)
    cats = []
    for r in rows:
        for c in r["categories"]:
            if c not in cats:
                cats.append(c)
    cat_btns = "".join(
        f'<button type="button" class="tab" data-cat="{c}">{c}</button>' for c in cats
    )
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Penn Work · Noun mark A/B/C</title>
<style>
:root {{
  --bg:#111114; --card:#1c1c22; --ink:#f4f1ea; --muted:#9a958c;
  --line:#2e2e36; --keep:#3d8b5a; --wrong:#b01e23; --found:#c4a35a;
  --wash:#18181d;
}}
* {{ box-sizing:border-box; }}
html,body {{ margin:0; background:var(--bg); color:var(--ink);
  font: 14px/1.4 ui-sans-serif, system-ui, -apple-system, sans-serif; }}
header {{
  position:sticky; top:0; z-index:5; background:rgba(17,17,20,.94);
  backdrop-filter:blur(12px); border-bottom:1px solid var(--line);
  padding:14px 18px 10px;
}}
h1 {{ font-size:18px; margin:0 0 6px; font-weight:650; letter-spacing:.01em; }}
.lede {{ color:var(--muted); max-width:72rem; margin:0 0 10px; }}
.tabs {{ display:flex; flex-wrap:wrap; gap:6px; }}
.tab, .ghost {{
  background:var(--card); color:var(--ink); border:1px solid var(--line);
  border-radius:999px; padding:5px 11px; cursor:pointer;
}}
.tab.on, .ghost.on {{ background:#f4f1ea; color:#111; }}
.meta {{ color:var(--muted); margin-top:8px; font-size:12px; }}
main {{ padding:16px 18px 280px; display:flex; flex-direction:column; gap:14px; }}
.row {{
  background:var(--card); border:1px solid var(--line); border-radius:14px;
  padding:12px;
}}
.row.hidden {{ display:none; }}
.rowhead {{ display:flex; justify-content:space-between; gap:12px; flex-wrap:wrap; }}
.iconid {{ font-family:ui-monospace, Menlo, monospace; font-size:12px; color:var(--muted); }}
.chips {{ color:var(--muted); font-size:12px; margin-top:4px; }}
.hint {{ font-size:11px; color:var(--found); margin-top:4px; }}
.choices {{ display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:8px; margin-top:10px; }}
.choice {{
  background:var(--wash); border:2px solid var(--line); border-radius:12px;
  padding:8px; cursor:pointer; text-align:center; min-height:210px;
}}
.choice img {{ width:100%; aspect-ratio:1; object-fit:contain; background:#fff; border-radius:8px; }}
.choice .ph {{
  width:100%; aspect-ratio:1; border-radius:8px; display:flex; align-items:center;
  justify-content:center; background:#2a2a32; color:var(--muted); font-size:12px; padding:10px;
}}
.choice .k {{ display:block; margin-top:8px; font-size:11px; letter-spacing:.08em; font-weight:700; }}
.choice[data-pick="a"].on {{ border-color:var(--keep); box-shadow:0 0 0 1px var(--keep); }}
.choice[data-pick="b"].on {{ border-color:var(--wrong); box-shadow:0 0 0 1px var(--wrong); }}
.choice[data-pick="c"].on {{ border-color:var(--found); box-shadow:0 0 0 1px var(--found); }}
.choice .k.a {{ color:var(--keep); }}
.choice .k.b {{ color:#e07070; }}
.choice .k.c {{ color:var(--found); }}
footer {{
  position:fixed; left:0; right:0; bottom:0; z-index:6;
  background:#0c0c0f; border-top:1px solid var(--line); padding:10px 18px 14px;
}}
footer .bar {{ display:flex; justify-content:space-between; align-items:center; gap:10px; margin-bottom:6px; }}
#prompt {{
  width:100%; height:150px; resize:vertical; background:#16161a; color:var(--ink);
  border:1px solid var(--line); border-radius:10px; padding:10px; font:12px/1.45 ui-monospace, Menlo, monospace;
}}
button.copy {{
  background:var(--found); color:#111; border:0; border-radius:8px; padding:8px 12px;
  font-weight:700; cursor:pointer;
}}
@media (max-width:720px) {{
  .choices {{ grid-template-columns:1fr; }}
  #prompt {{ height:180px; }}
}}
</style>
</head>
<body>
<header>
  <h1>Noun mark A / B / C</h1>
  <p class="lede">
    For every unique tile: <b>A</b> keeps the current in-app image,
    <b>B</b> marks it wrong (regenerate — do not invent logos),
    <b>C</b> regenerates off the real photo/logo found online (right).
    Liquors, syrups, drugs, jewelry, and brands already exist — prefer C when the current mark is made up.
    Picks collapse into one paste-back prompt at the bottom.
  </p>
  <div class="tabs">
    <button type="button" class="tab on" data-cat="ALL">All</button>
    {cat_btns}
    <button type="button" class="ghost" data-filter="unreviewed">Unreviewed</button>
    <button type="button" class="ghost" data-filter="c">Found only</button>
  </div>
  <div class="meta" id="meta"></div>
</header>
<main id="list"></main>
<footer>
  <div class="bar">
    <strong>Copy-paste correction prompt</strong>
    <button type="button" class="copy" id="copy">Copy prompt</button>
  </div>
  <textarea id="prompt" readonly></textarea>
</footer>
<script>
const ROWS = {data};
const KEY = "pennwork-noun-chooser-v1";
const picks = JSON.parse(localStorage.getItem(KEY) || "{{}}");
let cat = "ALL";
let extra = "all";
const absFound = {json.dumps(str(FOUND_DIR))};

function render() {{
  const root = document.getElementById("list");
  root.innerHTML = "";
  let shown = 0;
  for (const row of ROWS) {{
    const pick = picks[row.icon] || "";
    const catOk = cat === "ALL" || row.categories.includes(cat);
    const extraOk = extra === "all"
      || (extra === "unreviewed" && !pick)
      || (extra === "c" && pick === "c");
    const hide = !catOk || !extraOk;
    if (!hide) shown += 1;
    const el = document.createElement("article");
    el.className = "row" + (hide ? " hidden" : "");
    el.dataset.icon = row.icon;
    const hint = row.preferFound
      ? "Real product/logo exists — if A looks invented, pick C."
      : "";
    const aImg = row.hasCurrent
      ? `<img src="current/${{row.icon}}.png" alt="current ${{row.icon}}">`
      : `<div class="ph">no current imageset</div>`;
    const cImg = row.hasFound
      ? `<img src="found/${{row.icon}}.png" alt="found ${{row.icon}}">`
      : `<div class="ph">no clean photo found — pick B to regen, or skip</div>`;
    el.innerHTML = `
      <div class="rowhead">
        <div>
          <div><b>${{row.label}}</b> · ${{row.categories.join(" / ")}}</div>
          <div class="iconid">${{row.icon}} · family ${{row.family}}</div>
          <div class="chips">${{row.chips.join(" · ")}}</div>
          ${{hint ? `<div class="hint">${{hint}}</div>` : ""}}
        </div>
      </div>
      <div class="choices">
        <button type="button" class="choice" data-pick="a">${{aImg}}<span class="k a">A · KEEP current</span></button>
        <button type="button" class="choice" data-pick="b">
          <div class="ph">Current is wrong.<br>Find the real thing or regenerate — do not invent a logo.</div>
          <span class="k b">B · WRONG / regen</span>
        </button>
        <button type="button" class="choice" data-pick="c">${{cImg}}<span class="k c">C · REGEN from this found image</span></button>
      </div>`;
    for (const btn of el.querySelectorAll(".choice")) {{
      if (btn.dataset.pick === pick) btn.classList.add("on");
      btn.addEventListener("click", () => {{
        const next = picks[row.icon] === btn.dataset.pick ? "" : btn.dataset.pick;
        if (next) picks[row.icon] = next; else delete picks[row.icon];
        localStorage.setItem(KEY, JSON.stringify(picks));
        render();
      }});
    }}
    root.appendChild(el);
  }}
  const n = ROWS.length;
  const k = Object.keys(picks).length;
  document.getElementById("meta").textContent =
    `${{shown}} showing · ${{k}} / ${{n}} chosen · ${{n-k}} left`;
  document.getElementById("prompt").value = buildPrompt();
}}

function buildPrompt() {{
  const keep = [], wrong = [], found = [];
  for (const row of ROWS) {{
    const p = picks[row.icon];
    if (p === "a") keep.push(row);
    else if (p === "b") wrong.push(row);
    else if (p === "c") found.push(row);
  }}
  const lines = [];
  lines.push("PENN WORK STUDIOS — noun-mark correction from the A/B/C HTML chooser.");
  lines.push("Work in Documents/The Final Journal AI.nosync AND sync Desktop/pennworkstudios.nosync.");
  lines.push("Do not invent logos. Liquors, syrups, drugs, jewelry, and brand marks already exist — use the real product or logo.");
  lines.push("");
  lines.push("KEEP (current in-app image is correct — do not change):");
  if (!keep.length) lines.push("- (none)");
  for (const r of keep) {{
    lines.push(`- ${{r.icon}}  [${{r.categories.join(", ")}}]  chips: ${{r.chips.join(", ")}}`);
  }}
  lines.push("");
  lines.push("WRONG (current is invented or incorrect). Find a clean real photo/logo online and replace the imageset. Do not generate a fake mark.");
  if (!wrong.length) lines.push("- (none)");
  for (const r of wrong) {{
    lines.push(`- ${{r.icon}}  [${{r.categories.join(", ")}}]  chips: ${{r.chips.join(", ")}}  family=${{r.family}}`);
  }}
  lines.push("");
  lines.push("REGENERATE FROM FOUND IMAGE (option C). Use the found file as the source: crop to the real mark/object, pad to a 1024 white square, write the imageset PNG. Do not redraw or invent.");
  if (!found.length) lines.push("- (none)");
  for (const r of found) {{
    const path = r.hasFound ? `${{absFound}}/${{r.icon}}.png` : "(missing — search again)";
    const src = r.source || "";
    lines.push(`- ${{r.icon}}  [${{r.categories.join(", ")}}]  chips: ${{r.chips.join(", ")}}`);
    lines.push(`  found image: ${{path}}`);
    if (src) lines.push(`  source URL: ${{src}}`);
  }}
  lines.push("");
  lines.push("After replacing imagesets, copy NounMarks into the Desktop pennworkstudios.nosync tree so both apps match.");
  return lines.join("\\n");
}}

document.querySelectorAll(".tab").forEach(btn => {{
  btn.addEventListener("click", () => {{
    document.querySelectorAll(".tab").forEach(b => b.classList.remove("on"));
    btn.classList.add("on");
    cat = btn.dataset.cat;
    render();
  }});
}});
document.querySelectorAll(".ghost").forEach(btn => {{
  btn.addEventListener("click", () => {{
    const on = btn.classList.contains("on");
    document.querySelectorAll(".ghost").forEach(b => b.classList.remove("on"));
    extra = on ? "all" : btn.dataset.filter;
    if (!on) btn.classList.add("on");
    render();
  }});
}});
document.getElementById("copy").addEventListener("click", async () => {{
  const text = document.getElementById("prompt").value;
  try {{
    await navigator.clipboard.writeText(text);
    document.getElementById("copy").textContent = "Copied";
    setTimeout(() => document.getElementById("copy").textContent = "Copy prompt", 1200);
  }} catch (e) {{
    document.getElementById("prompt").select();
  }}
}});
render();
</script>
</body>
</html>
"""


def main() -> None:
    store = SWIFT_STORE.read_text()
    mark = SWIFT_MARK.read_text()
    catalog = SWIFT_CATALOG.read_text()
    families = parse_families(mark)
    idx = build_alias_index(families)
    product = parse_dict_block(catalog, "productIcons")
    # shared lives inside iconName; parse the inner dict after `let shared`
    sm = re.search(r"let shared: \[String: String\] = \[((?:.|\n)*?)\n\s*\]", catalog)
    shared = {k: v for k, v in re.findall(r'"([^"]+)":\s*"([^"]+)"', sm.group(1))} if sm else {}

    existing = {p.name.replace(".imageset", "") for p in ASSET_DIR.glob("*.imageset")}

    grouped: dict[str, dict] = {}
    for cat_key, word in parse_store_words(store):
        fam = match_family(normalize(word), idx)
        icon = icon_name(word, fam, product, shared)
        folded = fold_icon(icon)
        if icon not in existing and folded in existing:
            icon = folded
        rec = grouped.setdefault(
            icon,
            {
                "icon": icon,
                "family": fam,
                "chips": [],
                "categories": [],
            },
        )
        if word not in rec["chips"]:
            rec["chips"].append(word)
        cl = category_label(cat_key)
        if cl not in rec["categories"]:
            rec["categories"].append(cl)

    OUT.mkdir(parents=True, exist_ok=True)
    CURRENT_DIR.mkdir(parents=True, exist_ok=True)
    FOUND_DIR.mkdir(parents=True, exist_ok=True)

    # One row per unique mark: existing imagesets, plus liquor/syrup/drug/jewelry/brand gaps.
    icons = [
        i
        for i in grouped
        if i in existing or prefer_found(grouped[i]["categories"])
    ]
    icons.sort(key=lambda i: (grouped[i]["categories"][0], i))
    print(f"unique icons: {len(icons)} (from {len(grouped)} chip groups, {len(existing)} imagesets)")

    current_ok = {}
    for icon in icons:
        current_ok[icon] = copy_current(icon)

    found_meta = {}
    priority = [i for i in icons if prefer_found(grouped[i]["categories"])]
    rest = [i for i in icons if i not in priority]
    order = priority + rest
    print(f"fetching found images serially: {len(order)} ({len(priority)} product-first)")

    for n, icon in enumerate(order, 1):
        meta = fetch_found(icon)
        found_meta[icon] = meta
        print(f"  {n}/{len(order)} {icon} -> {meta.get('via') or 'MISS'}")
        if meta.get("via") != "cache":
            time.sleep(0.9)

    rows = []
    for icon in icons:
        rec = grouped[icon]
        meta = found_meta.get(icon) or {}
        rows.append(
            {
                "icon": icon,
                "family": rec["family"],
                "label": rec["chips"][0],
                "chips": rec["chips"][:24],
                "categories": rec["categories"],
                "hasCurrent": bool(current_ok.get(icon)),
                "hasFound": bool(meta.get("ok")),
                "source": meta.get("source"),
                "via": meta.get("via"),
                "preferFound": prefer_found(rec["categories"]),
            }
        )

    html = html_page(rows)
    (OUT / "index.html").write_text(html, encoding="utf-8")
    (OUT / "manifest.json").write_text(json.dumps(rows, indent=2), encoding="utf-8")

    ok_found = sum(1 for r in rows if r["hasFound"])
    ok_cur = sum(1 for r in rows if r["hasCurrent"])
    print(f"wrote {OUT / 'index.html'}")
    print(f"current thumbs: {ok_cur}/{len(rows)}  found photos: {ok_found}/{len(rows)}")

    dest = DESKTOP / "docs" / "noun-chooser"
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(OUT, dest)
    print(f"copied to {dest}")


if __name__ == "__main__":
    main()
