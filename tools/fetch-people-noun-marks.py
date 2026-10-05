#!/usr/bin/env python3
"""Fetch real Wikimedia/Openverse portraits for jeweler, producer, and artist chips.

Never invent faces. If no free photo exists, write a stacked typographic mark.
"""

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

import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path("/Users/samuel/Documents/The Final Journal AI.nosync")
DESKTOP = Path("/Users/samuel/Desktop/pennworkstudios.nosync")
ASSET = ROOT / "XJournal AI" / "Assets.xcassets" / "NounMarks"
DESK_ASSET = DESKTOP / "XJournal AI" / "Assets.xcassets" / "NounMarks"
CACHE = ROOT / "docs" / "noun-chooser" / "people-src"
UA = "PenworkNounChooser/1.0 (educational lyric noun marks; contact: local)"
CTX = ssl.create_default_context()
SIZE = 1024
FONT = Path("/System/Library/Fonts/Supplemental/Arial Bold.ttf")

PALETTES = {
    "jeweler": [0xD4AF37, 0xC8E0F0, 0x1A1A2E, 0xB01E23, 0xC0C0C0, 0x004F3B],
    "producer": [0x1A1A1A, 0xD4AF37, 0x4A7BA7, 0xB01E23, 0x2C2C2C, 0xC4A35A],
    "artist": [0x1A1A1A, 0xB01E23, 0x4A7BA7, 0xD4AF37, 0x2F6B3A, 0x6B3FA0],
}

FACE = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
FACE2 = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_alt2.xml")


def P(
    chip: str,
    icon: str,
    kind: str,
    wiki: list[str] | None = None,
    files: list[str] | None = None,
    search: str | None = None,
    aliases: list[str] | None = None,
    category: str = "",
) -> dict:
    return {
        "chip": chip,
        "icon": icon,
        "kind": kind,  # face | logo | store
        "wiki": wiki or [],
        "files": files or [],
        "search": search or "",
        "aliases": aliases or [],
        "category": category,
    }


JEWELERS = [
    P("Johnny Dang", "noun-johnny-dang", "face",
      wiki=["Johnny Dang"], search="Johnny Dang jeweler portrait",
      aliases=["johnny", "dang"], category="jeweler"),
    P("Eliantte", "noun-eliantte", "logo",
      wiki=["Eliantte"], search="Eliantte jeweler logo",
      category="jeweler"),
    P("Icebox", "noun-jewelers-icebox", "store",
      wiki=["Icebox (jewelry store)", "Icebox Diamonds & Watches"],
      search="Icebox Atlanta jewelry store storefront",
      category="jeweler"),
    P("Avianne", "noun-avianne", "logo",
      wiki=["Avianne", "Avianne & Co"], search="Avianne jeweler logo",
      category="jeweler"),
    P("Ben Baller", "noun-ben-baller", "face",
      wiki=["Ben Baller", "Ben Yang"], search="Ben Baller jeweler portrait",
      aliases=["baller"], category="jeweler"),
    P("Jacob the Jeweler", "noun-jacob-jeweler", "face",
      wiki=["Jacob Arabo", "Jacob the Jeweler"],
      search="Jacob Arabo jeweler portrait",
      aliases=["jacob arabo"], category="jeweler"),
    P("Lorraine Schwartz", "noun-lorraine-schwartz", "face",
      wiki=["Lorraine Schwartz"], search="Lorraine Schwartz jeweler portrait",
      aliases=["lorraine"], category="jeweler"),
    P("Alex Moss", "noun-alex-moss", "face",
      wiki=["Alex Moss"], search="Alex Moss jeweler portrait",
      category="jeweler"),
    P("Chopard", "noun-chopard", "logo",
      wiki=["Chopard"],
      files=["Logo Chopard.svg", "Chopard Alpine Eagle.jpg", "Chopard (Madison Ave - New York).jpg"],
      search="Chopard watch jewelry logo",
      category="jeweler"),
    P("David Yurman", "noun-david-yurman", "face",
      wiki=["David Yurman"],
      files=["David Yurman.jpg", "David Yurman portrait.jpg"],
      search="David Yurman jeweler portrait",
      aliases=["yurman"], category="jeweler"),
    P("Harry Winston", "noun-harry-winston", "logo",
      wiki=["Harry Winston", "Harry Winston, Inc."],
      files=["Harry-winston-logo.jpg", "HarryWinstonStorefront.JPG", "HARRY WINSTON Ginza, Tokyo, Japan - Mar 4, 2022.jpg"],
      search="Harry Winston jewelry store",
      aliases=["winston"], category="jeweler"),
    P("Jason of Beverly Hills", "noun-jason-of-beverly-hills", "face",
      wiki=["Jason of Beverly Hills", "Jason Arasheben"],
      search="Jason of Beverly Hills jeweler portrait",
      aliases=["jason of bh"], category="jeweler"),
]

PRODUCERS = [
    P("Metro Boomin", "noun-prod-metro", "face",
      wiki=["Metro Boomin"], search="Metro Boomin producer portrait",
      aliases=["metro"], category="producer"),
    P("Wheezy", "noun-prod-wheezy", "face",
      wiki=["Wheezy (record producer)", "Wesley Tyler Glass"],
      search="Wheezy producer rap portrait", category="producer"),
    P("Tay Keith", "noun-prod-tay-keith", "face",
      wiki=["Tay Keith"], search="Tay Keith producer portrait", category="producer"),
    P("Pharrell", "noun-prod-pharrell", "face",
      wiki=["Pharrell Williams"], search="Pharrell Williams portrait",
      aliases=["pharrell williams"], category="producer"),
    P("ATL Jacob", "noun-prod-atl-jacob", "face",
      wiki=["ATL Jacob"], search="ATL Jacob producer portrait", category="producer"),
    P("Mustard", "noun-prod-mustard", "face",
      wiki=["Mustard (record producer)", "DJ Mustard"],
      search="DJ Mustard producer portrait",
      aliases=["dj mustard"], category="producer"),
    P("Hit-Boy", "noun-prod-hit-boy", "face",
      wiki=["Hit-Boy"], search="Hit-Boy producer portrait",
      aliases=["hit boy"], category="producer"),
    P("London on da Track", "noun-prod-london", "face",
      wiki=["London on da Track"], search="London on da Track producer portrait",
      aliases=["london"], category="producer"),
    P("Zaytoven", "noun-prod-zaytoven", "face",
      wiki=["Zaytoven"], search="Zaytoven producer portrait", category="producer"),
    P("808 Mafia", "noun-prod-808-mafia", "logo",
      wiki=["808 Mafia"], search="808 Mafia producer logo", category="producer"),
    P("Dr Dre", "noun-prod-dre", "face",
      wiki=["Dr. Dre"], search="Dr Dre portrait",
      aliases=["dr. dre", "dre"], category="producer"),
    P("Southside on the Track", "noun-prod-southside", "face",
      wiki=["Southside (record producer)", "Southside on the Track"],
      search="Southside 808 Mafia producer portrait",
      aliases=["southside"], category="producer"),
    P("Mike Will", "noun-prod-mike-will", "face",
      wiki=["Mike Will Made It", "Mike WiLL Made-It"],
      search="Mike Will Made It producer portrait",
      aliases=["mike will made it", "mike will made-it"], category="producer"),
    P("Lex Luger", "noun-prod-lex-luger", "face",
      wiki=["Lex Luger (record producer)"], search="Lex Luger producer portrait",
      category="producer"),
    P("Timbaland", "noun-prod-timbaland", "face",
      wiki=["Timbaland"], search="Timbaland producer portrait", category="producer"),
    P("BNYX", "noun-prod-bnyx", "face",
      wiki=["BNYX"], search="BNYX producer portrait", category="producer"),
    P("F1lthy", "noun-prod-f1lthy", "face",
      wiki=["F1lthy"], search="F1lthy producer portrait",
      aliases=["filthy"], category="producer"),
    P("DY Krazy", "noun-prod-dy-krazy", "face",
      wiki=["DY Krazy"], search="DY Krazy producer portrait", category="producer"),
    P("Dun Deal", "noun-prod-dun-deal", "face",
      wiki=["Dun Deal"], search="Dun Deal producer portrait", category="producer"),
    P("Scott Storch", "noun-prod-scott-storch", "face",
      wiki=["Scott Storch"], search="Scott Storch producer portrait", category="producer"),
    P("Honorable C.N.O.T.E.", "noun-prod-cnote", "face",
      wiki=["Honorable C.N.O.T.E."], search="Honorable CNOTE producer portrait",
      aliases=["honorable cnote", "cnote", "honorable c.n.o.t.e"], category="producer"),
    P("Bangladesh", "noun-prod-bangladesh", "face",
      wiki=["Bangladesh (record producer)"],
      search="Bangladesh record producer portrait", category="producer"),
    P("Just Blaze", "noun-prod-just-blaze", "face",
      wiki=["Just Blaze"], search="Just Blaze producer portrait", category="producer"),
    P("Alchemist", "noun-prod-alchemist", "face",
      wiki=["The Alchemist (musician)"], search="The Alchemist producer portrait",
      aliases=["the alchemist"], category="producer"),
    P("T-Minus", "noun-prod-t-minus", "face",
      wiki=["T-Minus (record producer)"], search="T-Minus producer portrait",
      aliases=["t minus"], category="producer"),
    P("Ronny J", "noun-prod-ronny-j", "face",
      wiki=["Ronny J"], search="Ronny J producer portrait", category="producer"),
    P("DJ Premier", "noun-prod-dj-premier", "face",
      wiki=["DJ Premier"], search="DJ Premier producer portrait",
      aliases=["premier"], category="producer"),
    P("Madlib", "noun-prod-madlib", "face",
      wiki=["Madlib"], search="Madlib producer portrait", category="producer"),
    P("Cardo", "noun-prod-cardo", "face",
      wiki=["Cardo (record producer)"], search="Cardo Got Wings producer portrait",
      category="producer"),
    P("TM88", "noun-prod-tm88", "face",
      wiki=["TM88"], search="TM88 producer portrait", category="producer"),
    P("Drumma Boy", "noun-prod-drumma-boy", "face",
      wiki=["Drumma Boy"], search="Drumma Boy producer portrait", category="producer"),
    P("Outtatown", "noun-prod-outtatown", "face",
      wiki=["Outtatown"], search="Outtatown producer portrait", category="producer"),
    P("Murda Beatz", "noun-prod-murda-beatz", "face",
      wiki=["Murda Beatz"], search="Murda Beatz producer portrait", category="producer"),
    P("Pi'erre Bourne", "noun-prod-pierre", "face",
      wiki=["Pi'erre Bourne"], search="Pi'erre Bourne producer portrait",
      aliases=["pierre bourne", "pierre"], category="producer"),
    P("Boi-1da", "noun-prod-boi-1da", "face",
      wiki=["Boi-1da"], search="Boi-1da producer portrait",
      aliases=["boi1da"], category="producer"),
]

ARTISTS = [
    P("Drake", "noun-artist-drake", "face",
      wiki=["Drake (musician)"], search="Drake rapper portrait", category="artist"),
    P("Wayne", "noun-artist-wayne", "face",
      wiki=["Lil Wayne"], search="Lil Wayne portrait",
      aliases=["lil wayne"], category="artist"),
    P("Future", "noun-artist-future", "face",
      wiki=["Future (rapper)"], search="Future rapper portrait", category="artist"),
    P("Thugger", "noun-artist-thugger", "face",
      wiki=["Young Thug"], search="Young Thug portrait",
      aliases=["young thug"], category="artist"),
    P("Gunna", "noun-artist-gunna", "face",
      wiki=["Gunna"], search="Gunna rapper portrait", category="artist"),
    P("Lil Baby", "noun-artist-lil-baby", "face",
      wiki=["Lil Baby"], search="Lil Baby rapper portrait", category="artist"),
    P("Kodak", "noun-artist-kodak", "face",
      wiki=["Kodak Black"], search="Kodak Black portrait",
      aliases=["kodak black"], category="artist"),
    P("YoungBoy", "noun-artist-youngboy", "face",
      wiki=["YoungBoy Never Broke Again"], search="NBA YoungBoy portrait",
      aliases=["nba youngboy", "youngboy never broke again"], category="artist"),
    P("Durk", "noun-artist-durk", "face",
      wiki=["Lil Durk"], search="Lil Durk portrait",
      aliases=["lil durk"], category="artist"),
    P("King Von", "noun-artist-king-von", "face",
      wiki=["King Von"], search="King Von rapper portrait", category="artist"),
    P("Carti", "noun-artist-carti", "face",
      wiki=["Playboi Carti"], search="Playboi Carti portrait",
      aliases=["playboi carti"], category="artist"),
    P("Uzi", "noun-artist-uzi", "face",
      wiki=["Lil Uzi Vert"], search="Lil Uzi Vert portrait",
      aliases=["lil uzi", "lil uzi vert"], category="artist"),
    P("Juice WRLD", "noun-artist-juice-wrld", "face",
      wiki=["Juice Wrld", "Juice WRLD"], search="Juice WRLD portrait",
      aliases=["juice wrld"], category="artist"),
    P("Travis Scott", "noun-artist-travis", "face",
      wiki=["Travis Scott"], search="Travis Scott portrait",
      aliases=["travis"], category="artist"),
    P("Kendrick", "noun-artist-kendrick", "face",
      wiki=["Kendrick Lamar"], search="Kendrick Lamar portrait",
      aliases=["kendrick lamar"], category="artist"),
    P("J Cole", "noun-artist-j-cole", "face",
      wiki=["J. Cole"], search="J Cole portrait",
      aliases=["j. cole"], category="artist"),
    P("Nas", "noun-artist-nas", "face",
      wiki=["Nas"], search="Nas rapper portrait", category="artist"),
    P("Jay-Z", "noun-artist-jayz", "face",
      wiki=["Jay-Z"], search="Jay-Z portrait",
      aliases=["jay z", "jayz"], category="artist"),
    P("Eminem", "noun-artist-eminem", "face",
      wiki=["Eminem"], search="Eminem portrait", category="artist"),
    P("50 Cent", "noun-artist-50-cent", "face",
      wiki=["50 Cent"], search="50 Cent portrait",
      aliases=["50cent"], category="artist"),
    P("Kanye", "noun-artist-kanye", "face",
      wiki=["Kanye West"], search="Kanye West portrait",
      aliases=["kanye west", "ye"], category="artist"),
    P("Nicki", "noun-artist-nicki", "face",
      wiki=["Nicki Minaj"], search="Nicki Minaj portrait",
      aliases=["nicki minaj"], category="artist"),
    P("Cardi B", "noun-artist-cardi-b", "face",
      wiki=["Cardi B"], search="Cardi B portrait", category="artist"),
    P("Megan", "noun-artist-megan", "face",
      wiki=["Megan Thee Stallion"], search="Megan Thee Stallion portrait",
      aliases=["megan thee stallion"], category="artist"),
    P("Latto", "noun-artist-latto", "face",
      wiki=["Latto"], search="Latto rapper portrait", category="artist"),
    P("Ice Spice", "noun-artist-ice-spice", "face",
      wiki=["Ice Spice"], search="Ice Spice rapper portrait", category="artist"),
    P("Sexyy Red", "noun-artist-sexyy-red", "face",
      wiki=["Sexyy Red"], search="Sexyy Red rapper portrait", category="artist"),
    P("Gucci Mane", "noun-artist-gucci-mane", "face",
      wiki=["Gucci Mane"], search="Gucci Mane portrait", category="artist"),
    P("21 Savage", "noun-artist-21", "face",
      wiki=["21 Savage"], search="21 Savage portrait",
      aliases=["21"], category="artist"),
    P("Migos", "noun-artist-migos", "face",
      wiki=["Migos"], search="Migos group photo", category="artist"),
    P("Quavo", "noun-artist-quavo", "face",
      wiki=["Quavo"], search="Quavo rapper portrait", category="artist"),
    P("Offset", "noun-artist-offset", "face",
      wiki=["Offset (rapper)"], search="Offset Migos rapper portrait", category="artist"),
    P("Takeoff", "noun-artist-takeoff", "face",
      wiki=["Takeoff (rapper)"], search="Takeoff Migos rapper portrait", category="artist"),
    P("Sosa", "noun-artist-sosa", "face",
      wiki=["Chief Keef"], search="Chief Keef portrait",
      aliases=["chief keef"], category="artist"),
    P("G Herbo", "noun-artist-g-herbo", "face",
      wiki=["G Herbo"], search="G Herbo rapper portrait",
      aliases=["herb"], category="artist"),
    P("Pop Smoke", "noun-artist-pop-smoke", "face",
      wiki=["Pop Smoke"], search="Pop Smoke rapper portrait", category="artist"),
    P("Yeat", "noun-artist-yeat", "face",
      wiki=["Yeat"], search="Yeat rapper portrait", category="artist"),
    P("Ken Carson", "noun-artist-ken-carson", "face",
      wiki=["Ken Carson"], search="Ken Carson rapper portrait", category="artist"),
    P("2Pac", "noun-artist-tupac", "face",
      wiki=["Tupac Shakur"], search="Tupac Shakur portrait",
      aliases=["tupac", "2 pac"], category="artist"),
    P("Biggie", "noun-artist-biggie", "face",
      wiki=["The Notorious B.I.G."], search="Notorious BIG Biggie portrait",
      aliases=["notorious b.i.g.", "notorious big"], category="artist"),
    P("Nipsey", "noun-artist-nipsey", "face",
      wiki=["Nipsey Hussle"], search="Nipsey Hussle portrait",
      aliases=["nipsey hussle"], category="artist"),
    P("The Game", "noun-artist-the-game", "face",
      wiki=["Game (rapper)"], search="The Game rapper portrait",
      aliases=["game"], category="artist"),
    P("Diddy", "noun-artist-diddy", "face",
      wiki=["Sean Combs", "Diddy"], search="Diddy Sean Combs portrait",
      aliases=["puffy", "puff daddy", "sean combs"], category="artist"),
    P("Birdman", "noun-artist-birdman", "face",
      wiki=["Birdman (rapper)"], search="Birdman Cash Money rapper portrait",
      category="artist"),
    P("Yo Gotti", "noun-artist-yo-gotti", "face",
      wiki=["Yo Gotti"], search="Yo Gotti rapper portrait", category="artist"),
    P("Lil Yachty", "noun-artist-lil-yachty", "face",
      wiki=["Lil Yachty"], search="Lil Yachty rapper portrait",
      aliases=["yachty"], category="artist"),
    P("Young Dolph", "noun-artist-young-dolph", "face",
      wiki=["Young Dolph"], search="Young Dolph rapper portrait",
      aliases=["dolph"], category="artist"),
    P("GloRilla", "noun-artist-glorilla", "face",
      wiki=["GloRilla"], search="GloRilla rapper portrait", category="artist"),
    P("Fivio Foreign", "noun-artist-fivio-foreign", "face",
      wiki=["Fivio Foreign"], search="Fivio Foreign rapper portrait",
      aliases=["fivio"], category="artist"),
    P("Unfoonk", "noun-artist-unfoonk", "face",
      wiki=["Unfoonk"], search="Unfoonk rapper portrait", category="artist"),
    P("SahBabii", "noun-artist-sahbabii", "face",
      wiki=["SahBabii"], search="SahBabii rapper portrait", category="artist"),
    P("Peewee Longway", "noun-artist-peewee-longway", "face",
      wiki=["Peewee Longway"], search="Peewee Longway rapper portrait", category="artist"),
    P("Lil Duke", "noun-artist-lil-duke", "face",
      wiki=["Lil Duke"], search="Lil Duke rapper portrait", category="artist"),
    P("Tadoe", "noun-artist-tadoe", "face",
      wiki=["Tadoe"], search="Tadoe Glory Boyz rapper portrait", category="artist"),
    P("Marlo", "noun-artist-marlo", "face",
      wiki=["ILoveMarlo", "Marlo (rapper)"], search="ILoveMarlo rapper portrait",
      aliases=["ilovemarlo"], category="artist"),
    P("Young Scooter", "noun-artist-young-scooter", "face",
      wiki=["Young Scooter"], search="Young Scooter rapper portrait", category="artist"),
    P("Bankroll Fresh", "noun-artist-bankroll-fresh", "face",
      wiki=["Bankroll Fresh"], search="Bankroll Fresh rapper portrait", category="artist"),
    P("Skooly", "noun-artist-skooly", "face",
      wiki=["Skooly"], search="Skooly rapper portrait", category="artist"),
    P("NoCap", "noun-artist-nocap", "face",
      wiki=["NoCap"], search="NoCap rapper portrait",
      aliases=["no cap"], category="artist"),
    P("Homixide Gang", "noun-artist-homixide-gang", "logo",
      wiki=["Homixide Gang"], search="Homixide Gang rap group", category="artist"),
    P("Young Nudy", "noun-artist-young-nudy", "face",
      wiki=["Young Nudy"], search="Young Nudy rapper portrait",
      aliases=["nudy"], category="artist"),
    P("Lil Keed", "noun-artist-lil-keed", "face",
      wiki=["Lil Keed"], search="Lil Keed rapper portrait", category="artist"),
    P("Lil Gotit", "noun-artist-lil-gotit", "face",
      wiki=["Lil Gotit"], search="Lil Gotit rapper portrait", category="artist"),
    P("Omelly", "noun-artist-omelly", "face",
      wiki=["Omelly"], search="Omelly rapper portrait", category="artist"),
    P("Kap G", "noun-artist-kap-g", "face",
      wiki=["Kap G"], search="Kap G rapper portrait", category="artist"),
    P("Veeze", "noun-artist-veeze", "face",
      wiki=["Veeze"], search="Veeze rapper portrait", category="artist"),
    P("Moneybagg Yo", "noun-artist-moneybagg-yo", "face",
      wiki=["Moneybagg Yo"], search="Moneybagg Yo rapper portrait",
      aliases=["moneybagg"], category="artist"),
    P("Pooh Shiesty", "noun-artist-pooh-shiesty", "face",
      wiki=["Pooh Shiesty"], search="Pooh Shiesty rapper portrait", category="artist"),
]

PEOPLE = JEWELERS + PRODUCERS + ARTISTS


def http_get(url: str, timeout: int = 30) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "*/*"})
    with urllib.request.urlopen(req, timeout=timeout, context=CTX) as resp:
        ctype = (resp.headers.get("Content-Type") or "").lower()
        data = resp.read()
        if "text/html" in ctype and b"<html" in data[:400].lower():
            raise ValueError("html")
        return data


def http_get_retry(url: str, tries: int = 3) -> bytes:
    last: Exception | None = None
    for i in range(tries):
        try:
            return http_get(url)
        except urllib.error.HTTPError as e:
            last = e
            if e.code == 429:
                time.sleep(5 + i * 5)
                continue
            if e.code in (404, 400):
                raise
            time.sleep(1)
        except Exception as e:
            last = e
            time.sleep(1)
    raise last  # type: ignore


STOPS = {
    "the", "of", "on", "da", "and", "a", "an", "de", "record", "producer",
    "rapper", "musician", "jeweler", "jewelry", "store",
}


def name_tokens(s: str) -> list[str]:
    cleaned = "".join(ch.lower() if ch.isalnum() else " " for ch in s)
    return [w for w in cleaned.split() if w and w not in STOPS]


def title_matches(title: str, chip: str) -> bool:
    core = title.lower().split("(")[0]
    need = name_tokens(chip)
    if not need:
        return chip.lower() in core
    return all(t in core for t in need)


def commons_thumb(filename: str) -> tuple[bytes, str] | None:
    fn = filename[5:] if filename.lower().startswith("file:") else filename
    direct = "https://commons.wikimedia.org/wiki/Special:FilePath/" + urllib.parse.quote(
        fn
    ) + "?width=1280"
    try:
        data = http_get(direct, timeout=20)
        if data and len(data) > 2000:
            return data, direct
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
            "pithumbsize": 1280,
            "piprop": "thumbnail",
            "redirects": 1,
        }
    )
    try:
        info = json.loads(http_get_retry(api).decode())
        pages = info.get("query", {}).get("pages", {})
        for page in pages.values():
            if page.get("missing") is not None or page.get("invalid") is not None:
                continue
            src = (page.get("thumbnail") or {}).get("source")
            if src:
                return http_get_retry(src), src
    except Exception:
        return None
    return None


def wiki_search_thumb(query: str, chip: str) -> tuple[bytes, str] | None:
    api = "https://en.wikipedia.org/w/api.php?" + urllib.parse.urlencode(
        {
            "action": "query",
            "list": "search",
            "srsearch": query,
            "srlimit": 5,
            "format": "json",
        }
    )
    try:
        info = json.loads(http_get_retry(api).decode())
    except Exception:
        return None
    for hit in info.get("query", {}).get("search", []):
        title = hit.get("title") or ""
        if not title_matches(title, chip):
            continue
        got = wiki_thumb(title)
        if got:
            return got
        time.sleep(0.4)
    return None


def commons_search(query: str, chip: str) -> tuple[bytes, str] | None:
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
    ranked: list[tuple[int, str]] = []
    for hit in info.get("query", {}).get("search", []):
        title = hit.get("title") or ""
        if not title_matches(title, chip):
            continue
        tl = title.lower()
        score = 3
        if any(b in tl for b in ("map of", "flag of", "coat of arms", "location map", "diagram")):
            continue
        ranked.append((score, title))
    ranked.sort(key=lambda x: -x[0])
    for _score, title in ranked[:5]:
        got = commons_thumb(title)
        if got:
            return got
        time.sleep(0.4)
    return None


def openverse(query: str, chip: str) -> tuple[bytes, str] | None:
    api = "https://api.openverse.org/v1/images/?" + urllib.parse.urlencode(
        {"q": query, "page_size": 16, "license_type": "all"}
    )
    try:
        info = json.loads(http_get_retry(api).decode())
    except Exception:
        return None
    ranked = []
    for r in info.get("results") or []:
        title = r.get("title") or ""
        url = r.get("url")
        if not url or not title_matches(title, chip):
            continue
        ranked.append((3, url, title))
    ranked.sort(key=lambda x: -x[0])
    for _score, url, _t in ranked[:6]:
        try:
            data = http_get_retry(url)
            if len(data) > 2500:
                return data, url
        except Exception:
            continue
    return None


def batch_wiki_thumbs(titles: list[str]) -> dict[str, str]:
    """title -> thumbnail url, following redirects/normalization."""
    out: dict[str, str] = {}
    unique = []
    seen = set()
    for t in titles:
        if t and t not in seen:
            seen.add(t)
            unique.append(t)
    for i in range(0, len(unique), 40):
        chunk = unique[i : i + 40]
        api = "https://en.wikipedia.org/w/api.php?" + urllib.parse.urlencode(
            {
                "action": "query",
                "titles": "|".join(chunk),
                "prop": "pageimages",
                "format": "json",
                "pithumbsize": 1280,
                "piprop": "thumbnail",
                "redirects": 1,
            }
        )
        try:
            info = json.loads(http_get_retry(api).decode())
        except Exception as e:
            print("  batch wiki fail", e)
            time.sleep(8)
            continue
        q = info.get("query", {})
        title_map: dict[str, str] = {}
        for n in q.get("normalized") or []:
            title_map[n["from"]] = n["to"]
        for r in q.get("redirects") or []:
            title_map[r["from"]] = r["to"]
        pages = {}
        for page in (q.get("pages") or {}).values():
            pages[page.get("title")] = page
        for original in chunk:
            cur = original
            for _ in range(4):
                cur = title_map.get(cur, cur)
            page = pages.get(cur)
            if not page or page.get("missing") is not None:
                continue
            src = (page.get("thumbnail") or {}).get("source")
            if src:
                out[original] = src
        time.sleep(1.2)
    return out


def save_raw(data: bytes, dest: Path) -> bool:
    try:
        dest.parent.mkdir(parents=True, exist_ok=True)
        if data[:200].lstrip().startswith(b"<svg") or b"<svg" in data[:400]:
            import subprocess

            tmp = dest.with_suffix(".svg")
            tmp.write_bytes(data)
            subprocess.run(
                ["qlmanage", "-t", "-s", "1024", "-o", str(dest.parent), str(tmp)],
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
        if min(im.size) < 64:
            return False
        im.save(dest)
        return True
    except Exception:
        return False


WIKI_URLS: dict[str, str] = {}
FORCE_REDO = {"noun-eliantte"}  # previous search grabbed the wrong person


def wiki_thumb_url(src: str, width: int = 800) -> str:
    """Turn API thumbnail/original URLs into Commons Special:FilePath thumbs."""
    raw = src.split("?")[0]
    name = urllib.parse.unquote(raw.rsplit("/", 1)[-1])
    if "px-" in name:
        name = name.split("px-", 1)[-1]
    return (
        "https://commons.wikimedia.org/wiki/Special:FilePath/"
        + urllib.parse.quote(name)
        + f"?width={width}"
    )


def fetch_real(person: dict) -> Path | None:
    CACHE.mkdir(parents=True, exist_ok=True)
    dest = CACHE / f"{person['icon']}.png"
    if dest.exists() and dest.stat().st_size > 2000 and person["icon"] not in FORCE_REDO:
        print("    cache", flush=True)
        return dest
    chip = person["chip"]
    q = person["search"] or chip
    has_wiki = any(t in WIKI_URLS for t in person["wiki"])
    for title in person["wiki"]:
        src = WIKI_URLS.get(title)
        if not src:
            continue
        src = wiki_thumb_url(src)
        try:
            data = http_get_retry(src)
            if save_raw(data, dest):
                print(f"    wiki {title}", flush=True)
                time.sleep(0.7)
                return dest
        except Exception as e:
            print(f"    wiki download fail {title}: {e}", flush=True)
            time.sleep(2)
    if has_wiki:
        # Photo exists on wiki; don't wander into unrelated search hits.
        return None
    for fn in person["files"]:
        got = commons_thumb(fn)
        time.sleep(0.35)
        if got and save_raw(got[0], dest):
            print(f"    commons file {fn}", flush=True)
            return dest
    for title in person["wiki"]:
        if title in WIKI_URLS:
            continue
        got = wiki_thumb(title)
        time.sleep(0.4)
        if got and save_raw(got[0], dest):
            print(f"    wiki {title}", flush=True)
            return dest
    got = wiki_search_thumb(q, chip)
    time.sleep(0.35)
    if got and save_raw(got[0], dest):
        print("    wiki search", flush=True)
        return dest
    got = commons_search(q, chip)
    time.sleep(0.35)
    if got and save_raw(got[0], dest):
        print("    commons search", flush=True)
        return dest
    got = openverse(q, chip)
    time.sleep(0.35)
    if got and save_raw(got[0], dest):
        print("    openverse", flush=True)
        return dest
    return None


def detect_faces(rgb: Image.Image) -> list[tuple[int, int, int, int]]:
    arr = np.array(rgb.convert("RGB"))
    gray = cv2.cvtColor(arr, cv2.COLOR_RGB2GRAY)
    h, w = gray.shape
    scale = 1.0
    if max(w, h) > 900:
        scale = 900 / max(w, h)
        gray = cv2.resize(gray, (int(w * scale), int(h * scale)))
    min_side = max(24, int(min(gray.shape) * 0.08))
    boxes: list[tuple[int, int, int, int]] = []
    for cascade in (FACE, FACE2):
        found = cascade.detectMultiScale(
            gray, scaleFactor=1.12, minNeighbors=5, minSize=(min_side, min_side)
        )
        for x, y, fw, fh in found:
            boxes.append(
                (int(x / scale), int(y / scale), int(fw / scale), int(fh / scale))
            )
        if boxes:
            break
    # merge duplicates
    boxes.sort(key=lambda b: b[2] * b[3], reverse=True)
    kept: list[tuple[int, int, int, int]] = []
    for b in boxes:
        x, y, fw, fh = b
        overlap = False
        for kx, ky, kw, kh in kept:
            ix0, iy0 = max(x, kx), max(y, ky)
            ix1, iy1 = min(x + fw, kx + kw), min(y + fh, ky + kh)
            if ix1 > ix0 and iy1 > iy0:
                inter = (ix1 - ix0) * (iy1 - iy0)
                if inter > 0.45 * fw * fh:
                    overlap = True
                    break
        if not overlap:
            kept.append(b)
    return kept


def square_crop(im: Image.Image, kind: str) -> Image.Image:
    rgb = im.convert("RGB")
    w, h = rgb.size
    if kind == "face":
        faces = detect_faces(rgb)
        if faces:
            if len(faces) >= 2:
                x0 = min(x for x, y, fw, fh in faces)
                y0 = min(y for x, y, fw, fh in faces)
                x1 = max(x + fw for x, y, fw, fh in faces)
                y1 = max(y + fh for x, y, fw, fh in faces)
                cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
                span = max(x1 - x0, y1 - y0)
                side = int(span * 1.55)
            else:
                x, y, fw, fh = faces[0]
                cx, cy = x + fw / 2, y + fh / 2 - fh * 0.08
                side = int(max(fw, fh) * 2.35)
            side = max(side, 64)
            side = min(side, max(w, h))
            x0 = int(cx - side / 2)
            y0 = int(cy - side / 2)
            x0 = max(0, min(x0, w - min(side, w)))
            y0 = max(0, min(y0, h - min(side, h)))
            side = min(side, w - x0, h - y0)
            rgb = rgb.crop((x0, y0, x0 + side, y0 + side))
        else:
            side = min(w, h)
            x0 = (w - side) // 2
            y0 = int(h * 0.06) if h > w else (h - side) // 2
            if y0 + side > h:
                y0 = h - side
            rgb = rgb.crop((x0, y0, x0 + side, y0 + side))
    elif kind == "store":
        side = min(w, h)
        x0 = (w - side) // 2
        y0 = (h - side) // 2
        rgb = rgb.crop((x0, y0, x0 + side, y0 + side))
    else:
        # logo: trim near-white then pad
        gray = rgb.convert("L")
        inv = Image.eval(gray, lambda p: 0 if p > 246 else 255)
        bbox = inv.getbbox()
        if bbox:
            x0, y0, x1, y1 = bbox
            pad = 8
            x0, y0 = max(0, x0 - pad), max(0, y0 - pad)
            x1, y1 = min(w, x1 + pad), min(h, y1 + pad)
            area = (x1 - x0) * (y1 - y0)
            if area > 0.12 * w * h:
                rgb = rgb.crop((x0, y0, x1, y1))
        bw, bh = rgb.size
        inner = int(SIZE * 0.86)
        scale = min(inner / max(bw, 1), inner / max(bh, 1))
        nw, nh = max(1, int(bw * scale)), max(1, int(bh * scale))
        rgb = rgb.resize((nw, nh), Image.Resampling.LANCZOS)
        canvas = Image.new("RGB", (SIZE, SIZE), (255, 255, 255))
        canvas.paste(rgb, ((SIZE - nw) // 2, (SIZE - nh) // 2))
        return canvas
    return rgb.resize((SIZE, SIZE), Image.Resampling.LANCZOS)


def hex_rgb(h: int) -> tuple[int, int, int]:
    return ((h >> 16) & 0xFF, (h >> 8) & 0xFF, h & 0xFF)


def stable_hex(name: str, category: str) -> int:
    palette = PALETTES.get(category) or PALETTES["artist"]
    h = 5381
    for b in name.lower().encode():
        h = ((h * 33) + b) & 0xFFFFFFFFFFFFFFFF
    return palette[h % len(palette)]


def type_mark(name: str, category: str) -> Image.Image:
    bg = hex_rgb(stable_hex(name, category))
    lum = (0.299 * bg[0] + 0.587 * bg[1] + 0.114 * bg[2]) / 255.0
    fg = (247, 244, 236) if lum <= 0.62 else (28, 28, 30)
    stops = {"OF", "THE", "A", "AN", "ON", "DA", "AND", "DE"}
    raw = (
        name.replace(".", "")
        .replace("'", "")
        .replace("\u2019", "")
        .replace("-", " ")
        .upper()
        .split()
    )
    words = [w for w in raw if w]
    if len(words) > 2:
        core = [w for w in words if w not in stops]
        if core:
            words = core
    im = Image.new("RGB", (SIZE, SIZE), bg)
    draw = ImageDraw.Draw(im)
    pad = 88
    lo, hi = 28, 280
    font = ImageFont.truetype(str(FONT), 80)
    for _ in range(14):
        mid = (lo + hi) // 2
        font = ImageFont.truetype(str(FONT), mid)
        widths = [draw.textlength(w, font=font) for w in words]
        line_h = font.getbbox("Ag")[3] - font.getbbox("Ag")[1]
        gap = int(mid * 0.18)
        total_h = line_h * len(words) + gap * max(0, len(words) - 1)
        if max(widths, default=0) <= SIZE - 2 * pad and total_h <= SIZE - 2 * pad:
            lo = mid + 1
        else:
            hi = mid - 1
    font = ImageFont.truetype(str(FONT), max(28, hi))
    line_h = font.getbbox("Ag")[3] - font.getbbox("Ag")[1]
    gap = int(max(28, hi) * 0.18)
    total_h = line_h * len(words) + gap * max(0, len(words) - 1)
    y = (SIZE - total_h) // 2
    for w in words:
        tw = draw.textlength(w, font=font)
        draw.text(((SIZE - tw) / 2, y), w, font=font, fill=fg)
        y += line_h + gap
    return im


def write_imageset(icon: str, im: Image.Image) -> Path:
    folder = ASSET / f"{icon}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    png = folder / f"{icon}.png"
    im.convert("RGB").save(png, "PNG", optimize=True)
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


def chip_key(word: str) -> str:
    return word.strip().lower()


def build_json(people: list[dict]) -> dict[str, str]:
    out: dict[str, str] = {}
    for p in people:
        out[chip_key(p["chip"])] = p["icon"]
        for a in p["aliases"]:
            out[chip_key(a)] = p["icon"]
    return out


def sync_desktop(icon: str) -> None:
    src = ASSET / f"{icon}.imageset"
    if not DESK_ASSET.parent.exists():
        return
    dest = DESK_ASSET / f"{icon}.imageset"
    dest.mkdir(parents=True, exist_ok=True)
    for item in src.iterdir():
        shutil.copy2(item, dest / item.name)


def main() -> None:
    global WIKI_URLS
    photo: dict[str, list[str]] = {"jeweler": [], "producer": [], "artist": []}
    fallback: dict[str, list[str]] = {"jeweler": [], "producer": [], "artist": []}

    all_titles = [t for p in PEOPLE for t in p["wiki"]]
    wiki_cache = CACHE / "wiki-thumbs.json"
    if wiki_cache.exists():
        WIKI_URLS = json.loads(wiki_cache.read_text())
        print(f"  loaded {len(WIKI_URLS)} cached wiki thumbs", flush=True)
    else:
        print(f"batch wikipedia pageimages ({len(all_titles)} titles)...", flush=True)
        WIKI_URLS = batch_wiki_thumbs(all_titles)
        CACHE.mkdir(parents=True, exist_ok=True)
        wiki_cache.write_text(json.dumps(WIKI_URLS, indent=2))
        print(f"  got {len(WIKI_URLS)} thumbs", flush=True)

    for i, person in enumerate(PEOPLE, 1):
        cat = person["category"]
        icon = person["icon"]
        png = ASSET / f"{icon}.imageset" / f"{icon}.png"
        cache = CACHE / f"{icon}.png"
        print(f"[{i}/{len(PEOPLE)}] {person['chip']} -> {icon}", flush=True)
        has_wiki = any(t in WIKI_URLS for t in person["wiki"])
        if (
            png.exists()
            and icon not in FORCE_REDO
            and png.stat().st_size > 2000
            and not (has_wiki and not (cache.exists() and cache.stat().st_size > 2000))
        ):
            if cache.exists() and cache.stat().st_size > 2000:
                photo[cat].append(icon)
                print("    skip PHOTO", flush=True)
            else:
                fallback[cat].append(icon)
                print("    skip TYPE", flush=True)
            continue
        src = fetch_real(person)
        if src:
            try:
                im = square_crop(Image.open(src), person["kind"])
                write_imageset(icon, im)
                sync_desktop(icon)
                photo[cat].append(icon)
                print(f"    PHOTO {icon}", flush=True)
            except Exception as e:
                im = type_mark(person["chip"], cat)
                write_imageset(icon, im)
                sync_desktop(icon)
                fallback[cat].append(icon)
                print(f"    TYPE (crop fail {e})", flush=True)
        else:
            im = type_mark(person["chip"], cat)
            write_imageset(icon, im)
            sync_desktop(icon)
            fallback[cat].append(icon)
            print("    TYPE fallback", flush=True)
        time.sleep(0.2)

    mapping = build_json(PEOPLE)
    json_path = ROOT / "docs" / "noun-product-maps-people.json"
    json_path.write_text(json.dumps(mapping, indent=2, ensure_ascii=False) + "\n")

    print("\n=== COUNTS ===")
    for cat in ("jeweler", "producer", "artist"):
        print(
            f"{cat}s: {len(photo[cat])} photo / {len(fallback[cat])} type "
            f"(total {len(photo[cat]) + len(fallback[cat])})"
        )
        if fallback[cat]:
            print("  type:", ", ".join(fallback[cat]))
    print("json", json_path)


if __name__ == "__main__":
    main()
