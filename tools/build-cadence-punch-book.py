#!/usr/bin/env python3
"""Cut setup→punch pairs from BarHitsCatalog.sqlite into cadence_punches.

Mirrors LyricClause.lastBreathCut: comma / '. ' / dash, 2+ content tokens
on each side. Lookup is last_noun + punch wrap, not live FTS.

Usage:
  python3 tools/build-cadence-punch-book.py
  python3 tools/build-cadence-punch-book.py --sqlite tools/bar-hits-catalog/BarHitsCatalog.sqlite
"""

from __future__ import annotations

import argparse
import gzip
import json
import re
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path

TOKEN_RE = re.compile(r"[a-z0-9]+")
WORD_RE = re.compile(r"[A-Za-z0-9']+")


def all_tokens(text: str) -> list[str]:
    folded = text.lower().replace("'", "").replace("’", "").replace("‘", "")
    return TOKEN_RE.findall(folded)


def content_tokens(text: str) -> list[str]:
    """LyricClause.contentTokens — length ≥ 2, used to decide if a cut is a breath."""
    return [t for t in all_tokens(text) if len(t) >= 2]


def normalize(text: str) -> str:
    """Must match CadenceGhostCache.normalize (keeps 'i' / 'a')."""
    return " ".join(all_tokens(text))


def last_noun(setup: str) -> str:
    toks = content_tokens(setup)
    for tok in reversed(toks):
        if len(tok) >= 3:
            return tok
    return toks[-1] if toks else ""


def end_word(text: str) -> str:
    toks = TOKEN_RE.findall(text.lower().replace("'", ""))
    return toks[-1] if toks else ""


def last_breath_cut(line: str) -> tuple[str, str] | None:
    hits: list[tuple[int, int]] = []
    i = 0
    n = len(line)
    while i < n:
        ch = line[i]
        if ch == ",":
            hits.append((i, 1))
        elif ch == "." and i + 1 < n and line[i + 1] == " ":
            hits.append((i, 2))
        elif ch in "—–":
            hits.append((i, 1))
        i += 1
    for idx, length in reversed(hits):
        setup = line[:idx].strip()
        punch = line[idx + length :].strip().strip("\"'“”")
        st = content_tokens(setup)
        pt = content_tokens(punch)
        if len(st) < 2 or len(pt) < 2:
            continue
        if line[idx] == "." and st and len(st[-1]) <= 2:
            continue
        return setup, punch
    return None


def split_syllables(total: int, setup: str, punch: str) -> tuple[int, int]:
    sw = max(1, len(WORD_RE.findall(setup)))
    pw = max(1, len(WORD_RE.findall(punch)))
    if total <= 0:
        return sw, pw
    punch_n = max(1, round(total * pw / (sw + pw)))
    setup_n = max(1, total - punch_n)
    return setup_n, punch_n


SCHEMA = """
DROP TABLE IF EXISTS cadence_punches;
CREATE TABLE cadence_punches (
    setup TEXT NOT NULL,
    punch TEXT NOT NULL,
    setup_norm TEXT NOT NULL,
    last_noun TEXT NOT NULL,
    punch_syllables INTEGER NOT NULL,
    setup_syllables INTEGER NOT NULL,
    artist TEXT,
    song TEXT,
    punch_has_noun INTEGER NOT NULL DEFAULT 0
);
"""

INDEXES = """
CREATE INDEX idx_cp_setup ON cadence_punches(setup_norm, punch_syllables);
CREATE INDEX idx_cp_noun_wrap ON cadence_punches(last_noun, punch_syllables, punch_has_noun);
CREATE INDEX idx_cp_noun_flip ON cadence_punches(last_noun, punch_has_noun);
"""


def build(sqlite_path: Path) -> dict:
    con = sqlite3.connect(sqlite_path)
    con.execute("PRAGMA journal_mode = WAL")
    con.execute("PRAGMA synchronous = OFF")
    con.execute("PRAGMA temp_store = MEMORY")
    con.executescript(SCHEMA)

    seen: set[tuple[str, str]] = set()
    batch: list[tuple] = []
    kept = 0
    scanned = 0
    skipped = 0

    def flush() -> None:
        if not batch:
            return
        con.executemany(
            """
            INSERT INTO cadence_punches(
                setup, punch, setup_norm, last_noun, punch_syllables, setup_syllables,
                artist, song, punch_has_noun
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            batch,
        )
        batch.clear()

    for line, artist, song, syllables in con.execute(
        "SELECT line, artist, song, syllables FROM bars"
    ):
        scanned += 1
        cut = last_breath_cut(line or "")
        if cut is None:
            skipped += 1
            continue
        setup, punch = cut
        setup_norm = normalize(setup)
        punch_norm = normalize(punch)
        if not setup_norm or not punch_norm or setup_norm == punch_norm:
            skipped += 1
            continue
        key = (setup_norm, punch_norm)
        if key in seen:
            skipped += 1
            continue
        seen.add(key)
        noun = last_noun(setup)
        if not noun:
            skipped += 1
            continue
        setup_n, punch_n = split_syllables(int(syllables or 0), setup, punch)
        has_noun = 1 if noun in punch_norm.split() else 0
        batch.append(
            (
                setup,
                punch,
                setup_norm,
                noun,
                punch_n,
                setup_n,
                artist or "",
                song or "",
                has_noun,
            )
        )
        kept += 1
        if len(batch) >= 5000:
            flush()
        if scanned % 200_000 == 0:
            print(f"… scanned {scanned:,} bars, kept {kept:,} punches", file=sys.stderr)

    flush()
    con.executescript(INDEXES)
    con.execute("PRAGMA wal_checkpoint(TRUNCATE)")
    con.commit()
    count = con.execute("SELECT COUNT(*) FROM cadence_punches").fetchone()[0]
    flips = con.execute(
        "SELECT COUNT(*) FROM cadence_punches WHERE punch_has_noun = 1"
    ).fetchone()[0]
    con.close()
    return {"scanned": scanned, "kept": kept, "skipped": skipped, "rows": count, "flips": flips}


ADLIB_NOUNS = {
    "yeah", "yeh", "yah", "uh", "ah", "ooh", "ayy", "ay", "woah", "whoa", "huh",
    "nah", "yea", "ok", "okay", "hey", "woo", "skrrt", "skrr", "ha", "hah",
}

FLIP_MARKERS = {"dont", "never", "aint", "cant", "wont", "no", "need", "needed"}


def write_seed(sqlite_path: Path, dest: Path, limit_setups: int = 250) -> int:
    con = sqlite3.connect(f"file:{sqlite_path}?mode=ro", uri=True)
    rows = con.execute(
        """
        SELECT setup_norm, punch, artist, song, last_noun, punch_syllables, setup_syllables
        FROM cadence_punches
        WHERE punch_has_noun = 1
          AND setup_syllables BETWEEN 4 AND 12
          AND punch_syllables BETWEEN 3 AND 12
        """
    ).fetchall()
    con.close()

    def score(row: tuple) -> tuple:
        setup_norm, punch, _artist, _song, noun, punch_n, setup_n = row
        toks = set(setup_norm.split())
        punch_toks = set(normalize(punch).split())
        flip = 1 if toks & FLIP_MARKERS else 0
        shared = len((toks - {noun}) & punch_toks)
        adlib = 0 if noun in ADLIB_NOUNS else 1
        wrap = -abs(punch_n - setup_n)
        return (adlib, flip, shared, wrap, -len(setup_norm))

    rows.sort(key=score, reverse=True)
    by_setup: dict[str, list[dict]] = {}
    per_noun: dict[str, int] = defaultdict(int)
    for setup_norm, punch, artist, song, noun, _pn, _sn in rows:
        if noun in ADLIB_NOUNS:
            continue
        setup_toks = set(setup_norm.split())
        punch_toks = set(normalize(punch).split())
        novel = punch_toks - setup_toks - ADLIB_NOUNS
        if len(novel) < 1:
            continue
        if punch_toks <= setup_toks:
            continue
        if per_noun[noun] >= 6:
            continue
        if setup_norm not in by_setup and len(by_setup) >= limit_setups:
            continue
        bucket = by_setup.setdefault(setup_norm, [])
        if len(bucket) >= 3:
            continue
        text = punch.strip()
        if any(p["text"].lower() == text.lower() for p in bucket):
            continue
        bucket.append({"text": text, "artist": artist or None, "song": song or None})
        per_noun[noun] += 1
    payload = dict(list(by_setup.items())[:limit_setups])
    con = sqlite3.connect(f"file:{sqlite_path}?mode=ro", uri=True)
    for forced in ("i dont need a bitch", "i dont need nobody", "i aint never been the type"):
        if forced in payload:
            continue
        hits = con.execute(
            """
            SELECT punch, artist, song FROM cadence_punches
            WHERE setup_norm = ? AND punch_has_noun = 1
            ORDER BY punch_syllables LIMIT 3
            """,
            (forced,),
        ).fetchall()
        if hits:
            payload[forced] = [
                {"text": p, "artist": a or None, "song": s or None} for p, a, s in hits
            ]
    con.close()
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(payload, ensure_ascii=False, indent=0) + "\n")
    return len(payload)


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
    parser.add_argument(
        "--sqlite",
        type=Path,
        default=root / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite",
    )
    parser.add_argument(
        "--gzip",
        type=Path,
        default=root / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite.gz",
    )
    parser.add_argument(
        "--seed",
        type=Path,
        default=root / "XJournal AI" / "ModelG" / "Ghost" / "CadenceGhostSeed.json",
    )
    parser.add_argument("--skip-gzip", action="store_true")
    args = parser.parse_args()
    if not args.sqlite.exists():
        print(f"missing sqlite: {args.sqlite}", file=sys.stderr)
        return 1
    print(f"sqlite: {args.sqlite}", file=sys.stderr)
    stats = build(args.sqlite)
    print(
        f"scanned {stats['scanned']:,} bars → {stats['rows']:,} unique punches "
        f"({stats['flips']:,} noun flips, skipped {stats['skipped']:,})",
        file=sys.stderr,
    )
    nseed = write_seed(args.sqlite, args.seed)
    print(f"seed setups: {nseed} → {args.seed}", file=sys.stderr)
    if not args.skip_gzip:
        print(f"gzip → {args.gzip}", file=sys.stderr)
        gzip_copy(args.sqlite, args.gzip)
        print(
            f"sqlite {args.sqlite.stat().st_size / 1e6:.1f} MB → "
            f"gzip {args.gzip.stat().st_size / 1e6:.1f} MB",
            file=sys.stderr,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
