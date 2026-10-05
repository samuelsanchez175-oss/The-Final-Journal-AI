#!/usr/bin/env python3
"""Convert the Genius ground-truth CSV into a gzipped SQLite catalog for bar hits.

Usage:
  python3 tools/build-bar-hits-catalog.py \
    --csv "XJournal AI/ground_truth_rap_bars_MODEL_G.csv" \
    --out "XJournal AI/RemindsMeOf/BarHitsCatalog.sqlite.gz"
"""

from __future__ import annotations

import argparse
import csv
import gzip
import re
import sqlite3
import sys
import unicodedata
from pathlib import Path

FRAGMENTS = {
    "yeah", "yah", "ah", "ooh", "uh", "skrrt", "skrr", "ayy", "ay", "woah", "whoa",
}
WORD_RE = re.compile(r"[A-Za-z0-9']+")
NON_ALNUM = re.compile(r"[^a-z0-9]+")


def is_real_bar(text: str) -> bool:
    words = text.split()
    if len(words) < 4:
        return False
    content = 0
    for raw in words:
        token = raw.lower().strip(".,!?;:\"()[]{}")
        if len(token) >= 2 and token not in FRAGMENTS:
            content += 1
    return content >= 3


def looks_like_artist_credit(line: str) -> bool:
    trimmed = line.strip()
    if "," not in trimmed:
        return False
    if "&" not in trimmed and " and " not in trimmed.lower():
        return False
    tokens = [t for t in re.split(r"[^A-Za-z0-9]+", trimmed) if t]
    if len(tokens) < 3:
        return False
    allow = {"and", "the", "of", "y", "n"}
    return all(t.lower() in allow or (t[:1].isupper()) for t in tokens)


def normalize_line(line: str) -> str:
    return re.sub(r"\s+", " ", line.strip().lower())


def end_word(line: str, rhyme_word: str) -> str:
    hint = rhyme_word.strip().lower().strip("'\"")
    if hint and WORD_RE.fullmatch(hint.replace("'", "")):
        return hint
    tokens = WORD_RE.findall(line.lower())
    return tokens[-1] if tokens else ""


def phonetic_class_from_phones(phones: list[str]) -> str:
    idx = 0
    for i, phone in enumerate(phones):
        if phone[-1:] == "1":
            idx = i
    return " ".join(phones[idx:])


def load_cmudict(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    out: dict[str, str] = {}
    with path.open("r", errors="replace") as handle:
        for raw in handle:
            line = raw.strip()
            if not line or line.startswith(";;;"):
                continue
            parts = line.split()
            if len(parts) < 2:
                continue
            word = parts[0].split("(", 1)[0].lower()
            if word in out:
                continue
            out[word] = phonetic_class_from_phones(parts[1:])
    return out


def colmap(header: list[str]) -> dict[str, int]:
    lower = [unicodedata.normalize("NFKC", h).strip().lower() for h in header]
    def idx(*names: str) -> int | None:
        for name in names:
            if name in lower:
                return lower.index(name)
        return None
    return {
        "id": idx("text_id", "id", "real lyrics 2026 new jan 24") or 0,
        "artist": idx("artist") or 1,
        "song": idx("song") or 2,
        "line": idx("text_bar_line", "text", "line") or 6,
        "rhyme_word": idx("rhyme_word") or 7,
        "syllables": idx("syllable_count") or 16,
        "phonetic_class": idx("phonetic_rhyme_class") or 19,
    }


def cell(row: list[str], index: int) -> str:
    if index < 0 or index >= len(row):
        return ""
    return row[index].strip()


def create_schema(con: sqlite3.Connection) -> None:
    con.executescript(
        """
        PRAGMA journal_mode = OFF;
        PRAGMA synchronous = OFF;
        PRAGMA temp_store = MEMORY;
        DROP TABLE IF EXISTS bars;
        DROP TABLE IF EXISTS bars_fts;
        CREATE TABLE bars (
            id TEXT PRIMARY KEY,
            line TEXT NOT NULL,
            artist TEXT,
            song TEXT,
            syllables INTEGER NOT NULL,
            end_word TEXT,
            phonetic_class TEXT
        );
        """
    )


def finish_indexes(con: sqlite3.Connection) -> None:
    con.executescript(
        """
        CREATE INDEX idx_bars_syl ON bars(syllables);
        CREATE INDEX idx_bars_end ON bars(end_word);
        CREATE INDEX idx_bars_class ON bars(phonetic_class);
        CREATE VIRTUAL TABLE bars_fts USING fts5(line, content='bars', content_rowid='rowid');
        INSERT INTO bars_fts(rowid, line) SELECT rowid, line FROM bars;
        """
    )


def artist_row_counts(csv_path: Path) -> dict[str, int]:
    counts: dict[str, int] = {}
    with csv_path.open("r", errors="replace", newline="") as handle:
        reader = csv.reader(handle)
        header = next(reader)
        artist_i = colmap(header)["artist"]
        for row in reader:
            artist = cell(row, artist_i)
            if not artist or artist.lower() == "artist":
                continue
            counts[artist] = counts.get(artist, 0) + 1
    return counts


def ingest(
    csv_path: Path,
    sqlite_path: Path,
    cmudict_path: Path,
    limit: int | None,
    min_bars: int,
) -> dict:
    cmap = None
    cmu = load_cmudict(cmudict_path)
    sqlite_path.parent.mkdir(parents=True, exist_ok=True)
    if sqlite_path.exists():
        sqlite_path.unlink()

    raw_counts = artist_row_counts(csv_path)
    allowed = {name for name, n in raw_counts.items() if n >= min_bars}
    ranked = sorted(allowed, key=lambda name: raw_counts[name], reverse=True)
    print(
        f"catalogs: {len(allowed)} artists with ≥{min_bars:,} rows "
        f"(dropped {len(raw_counts) - len(allowed)} credit strings)",
        file=sys.stderr,
    )
    for name in ranked:
        print(f"  {raw_counts[name]:7d}  {name}", file=sys.stderr)

    con = sqlite3.connect(sqlite_path)
    create_schema(con)
    batch: list[tuple] = []
    seen: set[tuple[str, str]] = set()
    kept = 0
    skipped = 0
    artists: set[str] = set()

    def flush() -> None:
        if not batch:
            return
        con.executemany(
            "INSERT OR IGNORE INTO bars(id, line, artist, song, syllables, end_word, phonetic_class) "
            "VALUES (?, ?, ?, ?, ?, ?, ?)",
            batch,
        )
        batch.clear()

    with csv_path.open("r", errors="replace", newline="") as handle:
        reader = csv.reader(handle)
        header = next(reader)
        cmap = colmap(header)
        for i, row in enumerate(reader, start=1):
            if limit is not None and kept >= limit:
                break
            line = cell(row, cmap["line"])
            artist = cell(row, cmap["artist"])
            song = cell(row, cmap["song"])
            if not line or not artist or artist.lower() == "artist":
                skipped += 1
                continue
            if artist not in allowed:
                skipped += 1
                continue
            if not is_real_bar(line) or looks_like_artist_credit(line):
                skipped += 1
                continue
            if normalize_line(line) == normalize_line(song):
                skipped += 1
                continue
            key = (normalize_line(line), artist.lower())
            if key in seen:
                skipped += 1
                continue
            seen.add(key)
            try:
                syllables = int(float(cell(row, cmap["syllables"]) or "0"))
            except ValueError:
                skipped += 1
                continue
            if syllables < 4 or syllables > 24:
                skipped += 1
                continue
            ending = end_word(line, cell(row, cmap["rhyme_word"]))
            klass = cell(row, cmap["phonetic_class"])
            if not klass and ending:
                klass = cmu.get(ending, "")
            row_id = cell(row, cmap["id"]) or f"{artist}.{kept}"
            batch.append((row_id, line, artist, song, syllables, ending, klass))
            artists.add(artist)
            kept += 1
            if len(batch) >= 4000:
                flush()
            if i % 100_000 == 0:
                print(f"… scanned {i:,} rows, kept {kept:,}", file=sys.stderr)

    flush()
    finish_indexes(con)
    con.commit()
    con.close()
    punch_script = Path(__file__).resolve().parent / "build-cadence-punch-book.py"
    if punch_script.exists():
        import subprocess
        subprocess.run(
            [sys.executable, str(punch_script), "--sqlite", str(sqlite_path), "--skip-gzip"],
            check=False,
        )
    return {"kept": kept, "skipped": skipped, "artists": len(artists)}


def gzip_copy(src: Path, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with src.open("rb") as raw, gzip.open(dest, "wb", compresslevel=6) as out:
        while True:
            chunk = raw.read(1024 * 1024)
            if not chunk:
                break
            out.write(chunk)


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", type=Path, default=root / "XJournal AI" / "ground_truth_rap_bars_MODEL_G.csv")
    parser.add_argument("--out", type=Path, default=root / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite.gz")
    parser.add_argument("--cmudict", type=Path, default=root / "XJournal AI" / "cmudict.txt")
    parser.add_argument("--limit", type=int, default=None)
    parser.add_argument(
        "--min-bars",
        type=int,
        default=0,
        help="If >0, keep only artist credits with at least this many CSV rows. 0 keeps every credit (no cutoff).",
    )
    args = parser.parse_args()

    sqlite_path = args.out.with_suffix("")  # .sqlite.gz -> .sqlite
    if sqlite_path.suffix != ".sqlite":
        sqlite_path = args.out.parent / "BarHitsCatalog.sqlite"

    print(f"csv: {args.csv}", file=sys.stderr)
    stats = ingest(args.csv, sqlite_path, args.cmudict, args.limit, args.min_bars)
    gzip_copy(sqlite_path, args.out)
    sqlite_mb = sqlite_path.stat().st_size / 1e6
    gz_mb = args.out.stat().st_size / 1e6
    print(
        f"kept {stats['kept']:,} bars from {stats['artists']:,} artists "
        f"(skipped {stats['skipped']:,})"
    )
    print(f"sqlite {sqlite_mb:.1f} MB → gzip {gz_mb:.1f} MB")
    print(f"wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
