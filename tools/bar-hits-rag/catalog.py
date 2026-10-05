"""Ingest the ground-truth CSV into a bench sqlite with craft columns the app catalog drops."""

from __future__ import annotations

import csv
import sqlite3
import sys
import unicodedata
from pathlib import Path

from people import artist_ids, people_phrase, resolve_people
from rhyme import end_word, load_cmudict, phonetic_class_from_phones, signature_from_phones

FRAGMENTS = {
    "yeah", "yah", "ah", "ooh", "uh", "skrrt", "skrr", "ayy", "ay", "woah", "whoa",
}


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
    import re

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
    import re

    return re.sub(r"\s+", " ", line.strip().lower())


def colmap(header: list[str]) -> dict[str, int]:
    lower = [unicodedata.normalize("NFKC", h).strip().lower() for h in header]

    def idx(*names: str) -> int:
        for name in names:
            if name in lower:
                return lower.index(name)
        return -1

    return {
        "id": idx("text_id", "id"),
        "artist": idx("artist"),
        "song": idx("song"),
        "line": idx("text_bar_line", "text", "line"),
        "rhyme_word": idx("rhyme_word"),
        "rhyme_class": idx("rhyme_class"),
        "syllables": idx("syllable_count_recalc", "syllable_count"),
        "phonetic_class": idx("phonetic_rhyme_class"),
        "phonetic_ending": idx("phonetic_ending"),
        "tone": idx("primary_tone"),
        "bar_index": idx("bar_index"),
    }


def cell(row: list[str], index: int) -> str:
    if index < 0 or index >= len(row):
        return ""
    return row[index].strip()


SCHEMA = """
PRAGMA journal_mode = OFF;
PRAGMA synchronous = OFF;
PRAGMA temp_store = MEMORY;
DROP TABLE IF EXISTS bars;
CREATE TABLE bars (
    id TEXT PRIMARY KEY,
    line TEXT NOT NULL,
    artist TEXT,
    song TEXT,
    syllables INTEGER NOT NULL,
    end_word TEXT,
    phonetic_class TEXT,
    destressed_class TEXT,
    vowel_base TEXT,
    rhyme_class TEXT,
    phonetic_ending TEXT,
    tone TEXT,
    people TEXT,
    artist_ids TEXT,
    person_n INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_bars_syl ON bars(syllables);
CREATE INDEX idx_bars_end ON bars(end_word);
CREATE INDEX idx_bars_class ON bars(phonetic_class);
CREATE INDEX idx_bars_destress ON bars(destressed_class);
CREATE INDEX idx_bars_vowel ON bars(vowel_base);
CREATE INDEX idx_bars_end_person ON bars(end_word, person_n, syllables);
CREATE INDEX idx_bars_class_person ON bars(phonetic_class, person_n, syllables);
CREATE INDEX idx_bars_vowel_person ON bars(vowel_base, person_n, syllables);
CREATE INDEX idx_bars_person ON bars(person_n);
"""


def ingest(csv_path: Path, sqlite_path: Path, cmudict_path: Path, limit: int | None = None) -> dict:
    cmu = load_cmudict(cmudict_path)
    sqlite_path.parent.mkdir(parents=True, exist_ok=True)
    if sqlite_path.exists():
        sqlite_path.unlink()

    con = sqlite3.connect(sqlite_path)
    con.executescript(SCHEMA)
    batch: list[tuple] = []
    seen: set[tuple[str, str]] = set()
    kept = 0
    skipped = 0

    def flush() -> None:
        if not batch:
            return
        con.executemany(
            """INSERT OR IGNORE INTO bars(
                id, line, artist, song, syllables, end_word, phonetic_class,
                destressed_class, vowel_base, rhyme_class, phonetic_ending, tone, people, artist_ids, person_n
            ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
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
            phones = cmu.get(ending, [])
            if not klass and phones:
                klass = phonetic_class_from_phones(phones)
            destressed = ""
            if klass:
                destressed = " ".join(
                    "".join(ch for ch in p if not ch.isdigit()) for p in klass.split()
                )
            elif phones:
                sig = signature_from_phones(phones)
                if sig:
                    destressed = sig.destressed_class
            vowel_base = destressed.split()[0] if destressed else ""
            ids = artist_ids(artist)
            resolved = resolve_people(artist)
            person_n = next((p["number"] for p in resolved if p["number"]), 0)
            row_id = cell(row, cmap["id"]) or f"{artist}.{song}.{kept}"
            batch.append(
                (
                    row_id,
                    line,
                    artist,
                    song,
                    syllables,
                    ending,
                    klass,
                    destressed,
                    vowel_base,
                    cell(row, cmap["rhyme_class"]),
                    cell(row, cmap["phonetic_ending"]),
                    cell(row, cmap["tone"]),
                    people_phrase(artist),
                    ",".join(ids),
                    person_n,
                )
            )
            kept += 1
            if len(batch) >= 4000:
                flush()
            if i % 200_000 == 0:
                print(f"… scanned {i:,} rows, kept {kept:,}", file=sys.stderr)

    flush()
    con.commit()
    n = con.execute("SELECT COUNT(*) FROM bars").fetchone()[0]
    con.close()
    return {"kept": kept, "skipped": skipped, "rows": n}


def connect(sqlite_path: Path) -> sqlite3.Connection:
    con = sqlite3.connect(f"file:{sqlite_path}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    return con
