#!/usr/bin/env python3
"""Add one Genius artist to the Penwork bar-hits catalog.

Scrapes songs where the artist is a lead (primary), splits lyrics into bars,
then incrementally inserts into BarHitsCatalog.sqlite, refreshes FTS, re-gzips,
and appends matching rows to the 557 MB ground-truth CSV.

Usage:
  python3 tools/add-artist-to-catalog.py --artist Fridayy --artist-id 2600051
"""

from __future__ import annotations

import argparse
import csv
import gzip
import html as htmlmod
import json
import re
import sqlite3
import sys
import time
import unicodedata
import urllib.error
import urllib.request
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUILD = Path(__file__).resolve().parent / "build-bar-hits-catalog.py"

sys.path.insert(0, str(Path(__file__).resolve().parent))
import importlib.util

spec = importlib.util.spec_from_file_location("bar_hits_build", BUILD)
build = importlib.util.module_from_spec(spec)
assert spec.loader
spec.loader.exec_module(build)

UA = (
    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) "
    "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
)
WORD_RE = re.compile(r"[A-Za-z0-9']+")
NON_ALNUM = re.compile(r"[^a-z0-9]+")
SECTION_RE = re.compile(r"^\s*\[.*\]\s*$")
TRANSLATION_RE = re.compile(r"\b(translation|traducción|traducao|oversettelse)\b", re.I)


def slug(text: str) -> str:
    folded = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    return NON_ALNUM.sub("", folded.lower())


def request_json(url: str, retries: int = 4) -> dict:
    last: Exception | None = None
    for attempt in range(retries):
        req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
        try:
            with urllib.request.urlopen(req, timeout=40) as resp:
                return json.loads(resp.read().decode("utf-8", errors="replace"))
        except urllib.error.HTTPError as exc:
            last = exc
            if exc.code in {403, 429, 500, 502, 503, 504}:
                time.sleep(1.5 * (attempt + 1))
                continue
            raise
        except Exception as exc:  # noqa: BLE001
            last = exc
            time.sleep(1.2 * (attempt + 1))
    raise RuntimeError(f"GET {url} failed: {last}")


def request_text(url: str, retries: int = 4) -> str:
    last: Exception | None = None
    for attempt in range(retries):
        req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "text/html"})
        try:
            with urllib.request.urlopen(req, timeout=40) as resp:
                return resp.read().decode("utf-8", errors="replace")
        except urllib.error.HTTPError as exc:
            last = exc
            if exc.code in {403, 429, 500, 502, 503, 504}:
                time.sleep(1.5 * (attempt + 1))
                continue
            raise
        except Exception as exc:  # noqa: BLE001
            last = exc
            time.sleep(1.2 * (attempt + 1))
    raise RuntimeError(f"GET {url} failed: {last}")


def is_lead_song(song: dict, artist_name: str) -> bool:
    target = artist_name.casefold()
    primary = ((song.get("primary_artist") or {}).get("name") or "").casefold()
    names = [(p.get("name") or "").casefold() for p in (song.get("primary_artists") or [])]
    if primary == target:
        return True
    if names and names[0] == target:
        return True
    if primary.startswith(target + " &") or primary.startswith(target + " and "):
        return True
    return False


def list_songs(artist_id: int, artist_name: str) -> list[dict]:
    out: list[dict] = []
    seen: set[int] = set()
    page = 1
    while page:
        url = (
            f"https://genius.com/api/artists/{artist_id}/songs"
            f"?sort=popularity&per_page=50&page={page}"
        )
        payload = request_json(url)
        songs = (payload.get("response") or {}).get("songs") or []
        for song in songs:
            sid = song.get("id")
            if not isinstance(sid, int) or sid in seen:
                continue
            title = song.get("title") or ""
            if TRANSLATION_RE.search(title):
                continue
            if song.get("instrumental"):
                continue
            if (song.get("lyrics_state") or "") not in {"complete", "unreleased", ""}:
                continue
            if not is_lead_song(song, artist_name):
                continue
            seen.add(sid)
            out.append(song)
        page = (payload.get("response") or {}).get("next_page")
        time.sleep(0.25)
    return out


class LyricsParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.parts: list[str] = []
        self.stack: list[str] = []
        self.in_lyrics = 0

    def _skipping(self) -> bool:
        return "skip" in self.stack

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        data = {k: v or "" for k, v in attrs}
        if data.get("data-lyrics-container") == "true":
            self.in_lyrics += 1
            self.stack.append("lyrics")
            return
        if self.in_lyrics == 0:
            return
        if tag == "div":
            self.stack.append("skip" if data.get("data-exclude-from-selection") == "true" else "other")
        if tag == "br" and not self._skipping():
            self.parts.append("\n")

    def handle_endtag(self, tag: str) -> None:
        if self.in_lyrics == 0 or not self.stack:
            return
        if tag != "div":
            return
        kind = self.stack.pop()
        if kind == "lyrics":
            self.in_lyrics = max(0, self.in_lyrics - 1)
            self.parts.append("\n")

    def handle_data(self, data: str) -> None:
        if self.in_lyrics and not self._skipping():
            self.parts.append(data)


def extract_lyrics(page_html: str) -> str:
    parser = LyricsParser()
    parser.feed(page_html)
    text = htmlmod.unescape("".join(parser.parts))
    text = text.replace("\xa0", " ").replace("\u2005", " ").replace("\u2009", " ")
    lines = []
    for raw in text.splitlines():
        line = re.sub(r"\s+", " ", raw).strip()
        if not line:
            continue
        if line.lower().endswith(" lyrics") and len(line.split()) <= 8:
            continue
        if SECTION_RE.match(line):
            continue
        lines.append(line)
    return "\n".join(lines)


def load_cmu(path: Path) -> tuple[dict[str, str], dict[str, int]]:
    klass = build.load_cmudict(path)
    syl: dict[str, int] = {}
    if not path.exists():
        return klass, syl
    with path.open("r", errors="replace") as handle:
        for raw in handle:
            line = raw.strip()
            if not line or line.startswith(";;;"):
                continue
            parts = line.split()
            if len(parts) < 2:
                continue
            word = parts[0].split("(", 1)[0].lower()
            if word in syl:
                continue
            syl[word] = sum(1 for phone in parts[1:] if phone[-1:].isdigit())
    return klass, syl


def count_syllables(line: str, cmu_syl: dict[str, int]) -> int:
    total = 0
    for token in WORD_RE.findall(line.lower()):
        word = token.replace("'", "")
        if not word:
            continue
        if word in cmu_syl:
            total += cmu_syl[word]
            continue
        groups = re.findall(r"[aeiouy]+", word)
        n = len(groups)
        if word.endswith("e") and n > 1:
            n -= 1
        total += max(1, n)
    return total


def bars_from_lyrics(
    lyrics: str,
    artist: str,
    song: str,
    cmu_class: dict[str, str],
    cmu_syl: dict[str, int],
) -> list[tuple]:
    artist_slug = slug(artist)
    song_slug = slug(song)
    rows: list[tuple] = []
    seen: set[str] = set()
    for index, raw in enumerate(lyrics.splitlines(), start=1):
        line = re.sub(r"\s+", " ", raw).strip()
        if not line or not build.is_real_bar(line) or build.looks_like_artist_credit(line):
            continue
        if build.normalize_line(line) == build.normalize_line(song):
            continue
        key = build.normalize_line(line)
        if key in seen:
            continue
        syllables = count_syllables(line, cmu_syl)
        if syllables < 4 or syllables > 24:
            continue
        seen.add(key)
        ending = build.end_word(line, "")
        klass = cmu_class.get(ending, "")
        row_id = f"{artist_slug}.{song_slug}.{index}"
        rows.append((row_id, line, artist, song, syllables, ending, klass))
    return rows


def fetch_song_lyrics(song: dict, cache: dict[str, str]) -> str:
    url = song.get("url") or ""
    if not url:
        path = song.get("path") or ""
        url = f"https://genius.com{path}" if path else ""
    if not url:
        return ""
    if url in cache:
        return cache[url]
    page = request_text(url)
    lyrics = extract_lyrics(page)
    cache[url] = lyrics
    time.sleep(0.45)
    return lyrics


def insert_bars(sqlite_path: Path, rows: list[tuple]) -> int:
    con = sqlite3.connect(sqlite_path)
    con.execute("PRAGMA journal_mode = WAL")
    before = con.execute("SELECT MAX(rowid) FROM bars").fetchone()[0] or 0
    con.executemany(
        "INSERT OR IGNORE INTO bars(id, line, artist, song, syllables, end_word, phonetic_class) "
        "VALUES (?, ?, ?, ?, ?, ?, ?)",
        rows,
    )
    inserted = con.execute("SELECT COUNT(*) FROM bars WHERE rowid > ?", (before,)).fetchone()[0]
    if inserted:
        con.execute(
            "INSERT INTO bars_fts(rowid, line) SELECT rowid, line FROM bars WHERE rowid > ?",
            (before,),
        )
    con.commit()
    con.close()
    return inserted


def append_csv(csv_path: Path, rows: list[tuple], header_len: int) -> int:
    if not rows:
        return 0
    with csv_path.open("a", newline="") as handle:
        writer = csv.writer(handle)
        for row_id, line, artist, song, syllables, ending, klass in rows:
            out = [""] * header_len
            out[0] = row_id
            out[1] = artist
            out[2] = song
            out[6] = line
            out[7] = ending
            out[16] = str(syllables)
            out[19] = klass
            writer.writerow(out)
    return len(rows)


def gzip_copy(src: Path, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_suffix(dest.suffix + ".tmp")
    with src.open("rb") as raw, gzip.open(tmp, "wb", compresslevel=6) as out:
        while True:
            chunk = raw.read(1024 * 1024)
            if not chunk:
                break
            out.write(chunk)
    tmp.replace(dest)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--artist", default="Fridayy")
    parser.add_argument("--artist-id", type=int, default=2600051)
    parser.add_argument("--sqlite", type=Path, default=ROOT / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite")
    parser.add_argument("--gzip", type=Path, default=ROOT / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite.gz")
    parser.add_argument("--csv", type=Path, default=ROOT / "XJournal AI" / "ground_truth_rap_bars_MODEL_G.csv")
    parser.add_argument("--cmudict", type=Path, default=ROOT / "XJournal AI" / "cmudict.txt")
    parser.add_argument("--cache", type=Path, default=ROOT / "tools" / "bar-hits-catalog" / "ingest-cache")
    parser.add_argument("--skip-csv", action="store_true")
    parser.add_argument("--skip-gzip", action="store_true")
    args = parser.parse_args()

    artist = args.artist
    cache_dir = args.cache
    cache_dir.mkdir(parents=True, exist_ok=True)
    lyrics_cache_path = cache_dir / f"{slug(artist)}-lyrics.json"
    lyrics_cache: dict[str, str] = {}
    if lyrics_cache_path.exists():
        lyrics_cache = json.loads(lyrics_cache_path.read_text())

    print(f"listing Genius songs for {artist} ({args.artist_id})", file=sys.stderr)
    songs = list_songs(args.artist_id, artist)
    print(f"lead songs: {len(songs)}", file=sys.stderr)

    cmu_class, cmu_syl = load_cmu(args.cmudict)
    all_rows: list[tuple] = []
    song_ok = 0
    for i, song in enumerate(songs, start=1):
        title = song.get("title") or "Untitled"
        try:
            lyrics = fetch_song_lyrics(song, lyrics_cache)
        except Exception as exc:  # noqa: BLE001
            print(f"  ! {title}: {exc}", file=sys.stderr)
            continue
        rows = bars_from_lyrics(lyrics, artist, title, cmu_class, cmu_syl)
        print(f"  [{i}/{len(songs)}] {title}: {len(rows)} bars", file=sys.stderr)
        if rows:
            song_ok += 1
            all_rows.extend(rows)
        if i % 5 == 0:
            lyrics_cache_path.write_text(json.dumps(lyrics_cache))

    lyrics_cache_path.write_text(json.dumps(lyrics_cache))
    # de-dupe ids just in case
    unique: dict[str, tuple] = {}
    for row in all_rows:
        unique[row[0]] = row
    all_rows = list(unique.values())
    print(f"parsed {len(all_rows)} bars across {song_ok} songs", file=sys.stderr)

    if not all_rows:
        print("no bars to insert", file=sys.stderr)
        return 1

    inserted = insert_bars(args.sqlite, all_rows)
    print(f"sqlite inserted (new): {inserted}", file=sys.stderr)

    if not args.skip_csv:
        with args.csv.open("r", errors="replace", newline="") as handle:
            header = next(csv.reader(handle))
        appended = append_csv(args.csv, all_rows, len(header))
        print(f"csv appended: {appended}", file=sys.stderr)

    if not args.skip_gzip:
        print("gzipping sqlite…", file=sys.stderr)
        gzip_copy(args.sqlite, args.gzip)
        print(f"wrote {args.gzip}", file=sys.stderr)

    con = sqlite3.connect(args.sqlite)
    n = con.execute("SELECT COUNT(*) FROM bars WHERE artist = ?", (artist,)).fetchone()[0]
    songs_n = con.execute(
        "SELECT COUNT(DISTINCT song) FROM bars WHERE artist = ?", (artist,)
    ).fetchone()[0]
    con.close()
    print(f"catalog now has {n} {artist} bars / {songs_n} songs")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
