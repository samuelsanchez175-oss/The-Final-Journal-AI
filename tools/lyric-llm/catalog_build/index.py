"""C4 — write catalog_bars, the full-text table, and the lookup indexes."""

from __future__ import annotations

import json
import sqlite3
from pathlib import Path

from catalog_build.schema import SCHEMA_VERSION, EnrichedLine

CREATE_BARS = """
CREATE TABLE IF NOT EXISTS catalog_bars (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    artist TEXT NOT NULL,
    song TEXT NOT NULL,
    song_id TEXT,
    album TEXT,
    text TEXT NOT NULL,
    end_word TEXT NOT NULL,
    end_rime TEXT NOT NULL,
    vowel_class TEXT NOT NULL,
    syllables INTEGER NOT NULL,
    inner_rhymes_json TEXT,
    inner_rhyme_count INTEGER NOT NULL,
    popularity_score REAL DEFAULT 0.0,
    is_generic INTEGER DEFAULT 0,
    line_seq INTEGER DEFAULT 1,
    total_lines INTEGER DEFAULT 1,
    relative_pos REAL DEFAULT 0.5,
    chronological_arc TEXT DEFAULT 'verse_build',
    next_bar_text TEXT DEFAULT '',
    next_bar_end_word TEXT DEFAULT '',
    is_iconic_anthem INTEGER DEFAULT 0,
    topic TEXT DEFAULT '',
    inner_vowel_class TEXT DEFAULT '',
    is_proper_noun INTEGER DEFAULT 0,
    genius_votes INTEGER DEFAULT 0,
    spotify_popularity INTEGER DEFAULT 0
);
"""

INDEXES = (
    "CREATE INDEX IF NOT EXISTS idx_artist_end_word ON catalog_bars(artist, end_word)",
    "CREATE INDEX IF NOT EXISTS idx_artist_vowel ON catalog_bars(artist, vowel_class)",
    "CREATE INDEX IF NOT EXISTS idx_artist_inner_vowel ON catalog_bars(artist, inner_vowel_class)",
    "CREATE INDEX IF NOT EXISTS idx_artist_topic ON catalog_bars(artist, topic)",
    "CREATE INDEX IF NOT EXISTS idx_artist_anthem ON catalog_bars(artist, is_iconic_anthem)",
    "CREATE INDEX IF NOT EXISTS idx_artist_syllables ON catalog_bars(artist, syllables)",
    "CREATE INDEX IF NOT EXISTS idx_artist_rime ON catalog_bars(artist, end_rime, syllables)",
    "CREATE INDEX IF NOT EXISTS idx_artist_song_seq ON catalog_bars(artist, song, line_seq)",
    "CREATE INDEX IF NOT EXISTS idx_artist_album ON catalog_bars(artist, album)",
    "CREATE INDEX IF NOT EXISTS idx_artist_pos ON catalog_bars(artist, relative_pos)",
    "CREATE INDEX IF NOT EXISTS idx_popularity ON catalog_bars(popularity_score)",
)


def connect(db_path: Path) -> sqlite3.Connection:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(db_path))
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute("PRAGMA synchronous=NORMAL;")
    return conn


def _meta(conn: sqlite3.Connection) -> dict[str, str]:
    conn.execute("CREATE TABLE IF NOT EXISTS catalog_meta (key TEXT PRIMARY KEY, value TEXT)")
    rows = conn.execute("SELECT key, value FROM catalog_meta").fetchall()
    return {row[0]: row[1] for row in rows}


def _set_meta(conn: sqlite3.Connection, key: str, value: str) -> None:
    _meta(conn)
    conn.execute(
        "INSERT INTO catalog_meta (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value",
        (key, value),
    )


def current_stamp(conn: sqlite3.Connection) -> str:
    try:
        return _meta(conn).get("source_stamp", "")
    except sqlite3.DatabaseError:
        return ""


def _ensure_columns(conn: sqlite3.Connection) -> None:
    have = {row[1] for row in conn.execute("PRAGMA table_info(catalog_bars)")}
    if "is_proper_noun" not in have:
        conn.execute("ALTER TABLE catalog_bars ADD COLUMN is_proper_noun INTEGER DEFAULT 0")
    if "topic" not in have:
        conn.execute("ALTER TABLE catalog_bars ADD COLUMN topic TEXT DEFAULT ''")
    if "inner_vowel_class" not in have:
        conn.execute("ALTER TABLE catalog_bars ADD COLUMN inner_vowel_class TEXT DEFAULT ''")
    if "genius_votes" not in have:
        conn.execute("ALTER TABLE catalog_bars ADD COLUMN genius_votes INTEGER DEFAULT 0")
    if "spotify_popularity" not in have:
        conn.execute("ALTER TABLE catalog_bars ADD COLUMN spotify_popularity INTEGER DEFAULT 0")


def _ensure_fts(conn: sqlite3.Connection) -> None:
    conn.execute(
        """
        CREATE VIRTUAL TABLE IF NOT EXISTS catalog_bars_fts
        USING fts5(text, artist, song, content='catalog_bars', content_rowid='id')
        """
    )


def _rebuild_fts(conn: sqlite3.Connection) -> None:
    conn.execute("INSERT INTO catalog_bars_fts(catalog_bars_fts) VALUES('rebuild')")


def _row(line: EnrichedLine) -> tuple:
    bar = line.annotated
    raw = bar.raw
    return (
        raw.artist,
        raw.song,
        raw.song_id or "",
        raw.album or "",
        raw.text,
        bar.end_word,
        bar.end_rime,
        bar.vowel_class,
        bar.syllables,
        json.dumps(bar.inner_rhymes, ensure_ascii=False),
        bar.inner_rhyme_count,
        line.popularity_score,
        1 if bar.is_generic else 0,
        raw.line_seq,
        raw.total_lines,
        bar.relative_pos,
        bar.chronological_arc,
        bar.next_bar_text,
        bar.next_bar_end_word,
        1 if line.is_iconic_anthem else 0,
        line.topic or "",
        bar.inner_vowel_class or "",
        1 if bar.is_proper_noun else 0,
        int(line.genius_votes or 0),
        int(line.spotify_popularity or 0),
    )


def index_lines(
    lines: list[EnrichedLine],
    db_path: Path,
    stamp: str,
    artists: list[str] | None,
) -> dict[str, int | bool]:
    """Insert lines. The same stamp on an existing database returns without rewriting."""
    conn = connect(db_path)
    try:
        exists = conn.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='catalog_bars'"
        ).fetchone()
        if exists:
            meta = _meta(conn)
            if meta.get("schema_version") == SCHEMA_VERSION and meta.get("source_stamp") == stamp:
                return {"skipped": True, "rows": 0}
            stored = meta.get("schema_version")
            if stored and stored != SCHEMA_VERSION:
                conn.execute("DROP TABLE IF EXISTS catalog_bars_fts")
                conn.execute("DROP TABLE IF EXISTS catalog_bars")
                exists = None
        if not exists:
            conn.execute(CREATE_BARS)
        else:
            _ensure_columns(conn)
        for statement in INDEXES:
            conn.execute(statement)
        _ensure_fts(conn)
        if artists:
            for artist in artists:
                conn.execute("DELETE FROM catalog_bars WHERE lower(artist) = ?", (artist.strip().lower(),))
        else:
            conn.execute("DELETE FROM catalog_bars")
        payload = [_row(line) for line in lines]
        conn.executemany(
            """
            INSERT INTO catalog_bars (
                artist, song, song_id, album, text, end_word, end_rime,
                vowel_class, syllables, inner_rhymes_json, inner_rhyme_count,
                popularity_score, is_generic, line_seq, total_lines, relative_pos,
                chronological_arc, next_bar_text, next_bar_end_word, is_iconic_anthem,
                topic, inner_vowel_class, is_proper_noun, genius_votes, spotify_popularity
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            payload,
        )
        _rebuild_fts(conn)
        _set_meta(conn, "schema_version", SCHEMA_VERSION)
        _set_meta(conn, "source_stamp", stamp)
        conn.commit()
        return {"skipped": False, "rows": len(payload)}
    finally:
        conn.close()


def explain_uses_index(db_path: Path, artist: str, end_word: str) -> str:
    """Plan for the end-word lookup and the tier-A retrieval select."""
    conn = connect(db_path)
    try:
        rows = conn.execute(
            """
            EXPLAIN QUERY PLAN
            SELECT id FROM catalog_bars
            WHERE artist = ? AND is_generic = 0
              AND (end_word = ? OR end_rime = ?)
              AND ABS(syllables - ?) <= 6
            ORDER BY popularity_score DESC
            LIMIT 60
            """,
            (artist, end_word, end_word, 12),
        ).fetchall()
    finally:
        conn.close()
    return " ".join(str(row[-1]) for row in rows)


def plan_uses_index(plan: str) -> bool:
    text = plan.upper()
    if "USING INDEX" in text or "USING COVERING INDEX" in text:
        return True
    return False
