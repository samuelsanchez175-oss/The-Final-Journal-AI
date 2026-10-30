#!/usr/bin/env python3
"""Step 1-2: inventory + pull every Gunna row (name variants + dedup).

Reads BarHitsCatalog.sqlite READ-ONLY. Writes:
  docs/flow-rules/inventory.md         — table + column report
  docs/flow-rules/gunna_lines.jsonl    — one record per deduped line, in rowid order
  docs/flow-rules/gunna_songs.csv      — unique (artist, song) with counts
"""
from __future__ import annotations

import csv
import json
import re
import sqlite3
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
DB = REPO / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite"
OUT = REPO / "docs" / "flow-rules"


def _open() -> sqlite3.Connection:
    return sqlite3.connect(f"file:{DB}?mode=ro", uri=True)


def _norm(line: str) -> str:
    return re.sub(r"\s+", " ", (line or "").strip().lower())


def inventory(conn: sqlite3.Connection) -> dict:
    out: dict = {"tables": {}, "line_order": None}
    for (t,) in conn.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall():
        cols = [{"name": r[1], "type": r[2]} for r in conn.execute(f"PRAGMA table_info({t})").fetchall()]
        try:
            n = conn.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
        except sqlite3.Error:
            n = None
        out["tables"][t] = {"n": n, "cols": cols}
    out["line_order"] = ("rowid-within-song",
                        "No explicit order column. We treat ascending rowid as song order; "
                        "reliability depends on the vault ingestion script having inserted lines "
                        "in order per song. Spot-checks on anthology tracks are consistent but not guaranteed.")
    return out


def _variants(conn: sqlite3.Connection, target: str = "gunna") -> list[tuple[str, int]]:
    rows = conn.execute(
        "SELECT artist, COUNT(*) FROM bars "
        "WHERE lower(artist) LIKE ? GROUP BY artist ORDER BY COUNT(*) DESC",
        (f"%{target}%",),
    ).fetchall()
    return [(a, int(n)) for a, n in rows]


def _pull_rows(conn: sqlite3.Connection, variants: list[str]) -> list[dict]:
    placeholders = ",".join("?" for _ in variants)
    sql = (f"SELECT rowid, artist, song, line, syllables, end_word, phonetic_class "
           f"FROM bars WHERE artist IN ({placeholders}) ORDER BY artist, song, rowid")
    out = []
    for row in conn.execute(sql, tuple(variants)).fetchall():
        rowid, artist, song, line, syl, end_word, phon = row
        out.append({
            "rowid": int(rowid),
            "artist": artist, "song": song, "line": line or "",
            "syllables": int(syl) if syl is not None else None,
            "end_word": end_word or "",
            "phonetic_class": phon or "",
        })
    return out


def _dedupe(rows: list[dict]) -> tuple[list[dict], int]:
    seen = set(); kept = []; dups = 0
    for r in rows:
        key = (r["artist"].lower(), r["song"].lower(), _norm(r["line"]))
        if not r["line"].strip() or key in seen:
            dups += 1
            continue
        seen.add(key)
        kept.append(r)
    return kept, dups


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    with _open() as conn:
        inv = inventory(conn)
        variants = _variants(conn)
        gunna_variants = [a for a, _ in variants]
        rows = _pull_rows(conn, gunna_variants)
        kept, dups = _dedupe(rows)
    songs: dict[tuple, int] = {}
    for r in kept:
        songs[(r["artist"], r["song"])] = songs.get((r["artist"], r["song"]), 0) + 1

    # inventory.md
    inv_md = [
        "# Vault inventory", "",
        f"**DB:** `{DB.relative_to(REPO)}` (opened read-only)", "",
        "## Tables", "",
        "| table | rows | columns |", "| --- | ---:| --- |",
    ]
    for t, info in inv["tables"].items():
        n = info["n"] if info["n"] is not None else "?"
        cols = ", ".join(f"{c['name']}:{c['type']}" for c in info["cols"])
        inv_md.append(f"| `{t}` | {n} | {cols} |")
    inv_md += [
        "", "## Line order reconstruction", "",
        inv["line_order"][1], "",
        "## No metadata columns", "",
        "Neither `bars` nor `cadence_punches` carries a BPM, tempo, key, year, or album column. "
        "Track metadata must come from external sources (GetSongBPM + AcousticBrainz) "
        "and be joined on (artist, normalized_song_title).",
    ]
    (OUT / "inventory.md").write_text("\n".join(inv_md) + "\n")

    # dedup report
    report = [
        "# Gunna pull report", "",
        f"**Variants matched** (SQL `artist LIKE '%gunna%'`): {len(variants)}", "",
        "| artist | lines |", "| --- | ---:|",
    ]
    for a, n in variants:
        report.append(f"| `{a}` | {n} |")
    report += [
        "",
        f"**Raw lines pulled:** {len(rows)}",
        f"**Lines after dedup (artist, song, normalized_line):** {len(kept)}  (dropped {dups})",
        f"**Unique songs:** {len(songs)}",
    ]
    (OUT / "gunna_pull_report.md").write_text("\n".join(report) + "\n")

    # gunna_lines.jsonl
    with (OUT / "gunna_lines.jsonl").open("w", encoding="utf-8") as f:
        for r in kept:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")

    # gunna_songs.csv
    with (OUT / "gunna_songs.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["artist", "song", "line_count"])
        for (a, s), n in sorted(songs.items(), key=lambda kv: -kv[1]):
            w.writerow([a, s, n])

    print(f"variants: {len(variants)}  raw: {len(rows)}  deduped: {len(kept)}  "
          f"songs: {len(songs)}  dups_dropped: {dups}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
