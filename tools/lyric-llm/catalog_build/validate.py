"""C5 — per-artist catalog report and thin-catalog warnings."""

from __future__ import annotations

import sqlite3
from pathlib import Path


def _artists(conn: sqlite3.Connection, only: list[str] | None) -> list[str]:
    if only:
        return only
    rows = conn.execute("SELECT DISTINCT artist FROM catalog_bars ORDER BY artist").fetchall()
    return [row[0] for row in rows]


def artist_stats(conn: sqlite3.Connection, artist: str) -> dict:
    columns = {info[1] for info in conn.execute("PRAGMA table_info(catalog_bars)")}
    spotify_expr = "SUM(CASE WHEN spotify_popularity > 0 THEN 1 ELSE 0 END)" if "spotify_popularity" in columns else "0"
    genius_expr = "SUM(CASE WHEN genius_votes > 0 THEN 1 ELSE 0 END)" if "genius_votes" in columns else "0"
    row = conn.execute(
        f"""
        SELECT COUNT(*) AS lines,
               COUNT(DISTINCT end_word) AS end_words,
               AVG(inner_rhyme_count) AS mean_inner,
               {spotify_expr} AS spotify_bars,
               {genius_expr} AS genius_bars,
               SUM(is_proper_noun) AS proper_bars,
               SUM(CASE WHEN topic != '' THEN 1 ELSE 0 END) AS topic_bars,
               SUM(CASE WHEN popularity_score > 0 THEN 1 ELSE 0 END) AS popular_bars
        FROM catalog_bars
        WHERE artist = ?
        """,
        (artist,),
    ).fetchone()
    lines = int(row[0] or 0)
    end_words = int(row[1] or 0)
    mean_inner = float(row[2] or 0)
    spotify_bars = int(row[3] or 0)
    genius_bars = int(row[4] or 0)
    proper_bars = int(row[5] or 0)
    topic_bars = int(row[6] or 0)
    popular_bars = int(row[7] or 0)
    songs = conn.execute(
        "SELECT COUNT(DISTINCT song) FROM catalog_bars WHERE artist = ?",
        (artist,),
    ).fetchone()[0]
    histogram_rows = conn.execute(
        """
        SELECT inner_rhyme_count, COUNT(*) FROM catalog_bars
        WHERE artist = ? GROUP BY inner_rhyme_count
        """,
        (artist,),
    ).fetchall()
    histogram = {int(count): int(n) for count, n in histogram_rows}
    dead = conn.execute(
        """
        SELECT end_word, COUNT(*) AS n FROM catalog_bars
        WHERE artist = ?
        GROUP BY end_word
        HAVING n < 3
        """,
        (artist,),
    ).fetchall()
    return {
        "lines": lines,
        "end_words": end_words,
        "dead_end_words": len(dead),
        "mean_inner": mean_inner,
        "histogram": histogram,
        "popular_bars": popular_bars,
        "spotify_bars": spotify_bars,
        "genius_bars": genius_bars,
        "proper_bars": proper_bars,
        "topic_bars": topic_bars,
        "songs": int(songs or 0),
    }


def retrieval_ready(stats: dict) -> bool:
    return bool(
        stats["lines"] >= 500
        and stats["end_words"] >= 50
        and stats["mean_inner"] >= 0.5
    )


def warnings_for(stats: dict, artist: str) -> list[str]:
    notes = []
    if stats["lines"] < 500:
        notes.append(f"{artist} has {stats['lines']} lines, under 500. Retrieval will be thin.")
    if stats["end_words"] < 50:
        notes.append(f"{artist} has {stats['end_words']} distinct end words, under 50.")
    if stats["lines"] and stats["mean_inner"] < 0.5:
        notes.append(f"{artist} mean inner rhymes {stats['mean_inner']:.2f} is under 0.5.")
    return notes


def render_report(conn: sqlite3.Connection, artists: list[str] | None = None) -> tuple[str, list[str]]:
    names = _artists(conn, artists)
    warnings: list[str] = []
    parts = ["# Catalog eval", ""]
    for artist in names:
        stats = artist_stats(conn, artist)
        notes = warnings_for(stats, artist)
        warnings.extend(notes)
        lines = stats["lines"] or 1
        hist = stats["histogram"]
        hist_text = ", ".join(f"{key}:{hist[key]}" for key in sorted(hist))
        parts.append(f"## {artist}")
        parts.append(f"- Total lines: {stats['lines']}")
        parts.append(f"- Distinct end words: {stats['end_words']}")
        parts.append(f"- Dead end words (under 3): {stats['dead_end_words']}")
        parts.append(f"- Signal gaps: {'; '.join(notes) if notes else 'none'}")
        parts.append(f"- Mean inner rhymes: {stats['mean_inner']:.2f}")
        parts.append(f"- Inner-rhyme histogram: {hist_text or 'none'}")
        parts.append(f"- Bars with Spotify popularity: {stats['spotify_bars']} ({100.0 * stats['spotify_bars'] / lines:.1f}%)")
        parts.append(f"- Bars with Genius votes: {stats['genius_bars']} ({100.0 * stats['genius_bars'] / lines:.1f}%)")
        parts.append(f"- Bars with a popularity score: {stats['popular_bars']} ({100.0 * stats['popular_bars'] / lines:.1f}%)")
        parts.append(f"- Bars tagged is_proper_noun: {stats['proper_bars']} ({100.0 * stats['proper_bars'] / lines:.1f}%)")
        parts.append(f"- Bars with a topic: {stats['topic_bars']} ({100.0 * stats['topic_bars'] / lines:.1f}%)")
        ready = "yes" if retrieval_ready(stats) else "no"
        parts.append(f"- Retrieval-ready: {ready}")
        parts.append("")
        top = conn.execute(
            """
            SELECT end_word, COUNT(*) AS n FROM catalog_bars
            WHERE artist = ?
            GROUP BY end_word
            ORDER BY n DESC
            LIMIT 25
            """,
            (artist,),
        ).fetchall()
        parts.append("End words:")
        for word, count in top:
            parts.append(f"- {word}: {count}")
        parts.append("")
    if warnings:
        parts.append("## Warnings")
        for note in warnings:
            parts.append(f"- {note}")
        parts.append("")
    return "\n".join(parts), warnings


def write_report(db_path: Path, report_path: Path, artists: list[str] | None = None) -> list[str]:
    conn = sqlite3.connect(str(db_path))
    try:
        text, warnings = render_report(conn, artists)
    finally:
        conn.close()
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(text, encoding="utf-8")
    for note in warnings:
        print(f"[catalog] {note}", flush=True)
    return warnings
