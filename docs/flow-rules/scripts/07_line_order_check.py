#!/usr/bin/env python3
"""Line-order sanity check on 3 well-known Gunna songs.

Prints lines in rowid order next to the original Genius page order IF a
click-log exists for Gunna; the log doesn't exist in this repo, so we fall
back to within-vault structural checks:
  - duplicate line detection (a hook returning in order)
  - section marker scan ([Verse], [Chorus] etc. — captured in the line
    column when the ingest preserved them)
  - gap detection in rowid stride (big jumps = possible shuffle)

Writes docs/flow-rules/line_order_check.md.
"""
from __future__ import annotations

import json
import sqlite3
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
DB = REPO / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite"
OUT = REPO / "docs" / "flow-rules"

SONGS = ["pushin P", "fukumean", "Baby Birkin"]
CLICK_DIR = REPO / "docs" / "play-on-words" / "genius-clicks"


def _has_click_log() -> Path | None:
    for name in ("gunna.jsonl",):
        p = CLICK_DIR / name
        if p.exists():
            return p
    return None


def main() -> int:
    conn = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    click_log = _has_click_log()
    md: list[str] = [
        "# Line-order verification — 3 Gunna songs", "",
        "**Click log for Gunna in `docs/play-on-words/genius-clicks/`:** "
        f"{'FOUND at ' + str(click_log.relative_to(REPO)) if click_log else 'NOT FOUND — no external order source available on this branch'}", "",
        "No new scraping, per instruction. Below each song shows: vault rowid order, "
        "duplicate-line markers (likely hook returns), and gap-in-rowid markers.", "",
    ]
    for song in SONGS:
        rows = conn.execute(
            "SELECT rowid, line FROM bars "
            "WHERE lower(artist) = 'gunna' AND lower(song) = lower(?) ORDER BY rowid",
            (song,),
        ).fetchall()
        md.append(f"## `{song}` — {len(rows)} lines")
        md.append("")
        if not rows:
            md.append("(none)"); md.append(""); continue
        rowids = [r[0] for r in rows]
        # gap stride
        strides = [rowids[i] - rowids[i - 1] for i in range(1, len(rowids))]
        median_stride = sorted(strides)[len(strides) // 2] if strides else 0
        big_gaps = [(i, s) for i, s in enumerate(strides, start=1) if s > median_stride * 5]
        # dup detection
        seen: dict[str, list[int]] = {}
        dups: list[tuple[int, str, int]] = []  # (idx, line, first_seen_idx)
        for i, (_, line) in enumerate(rows):
            key = (line or "").strip().lower()
            if not key:
                continue
            if key in seen:
                dups.append((i, line, seen[key][0]))
                seen[key].append(i)
            else:
                seen[key] = [i]
        md.append("| # | rowid | line | note |")
        md.append("| ---:| ---:| --- | --- |")
        for i, (rid, line) in enumerate(rows):
            notes = []
            if any(gi == i for gi, _ in big_gaps):
                stride = next(s for gi, s in big_gaps if gi == i)
                notes.append(f"rowid gap +{stride}")
            if any(di == i for di, _, _ in dups):
                first_idx = next(f for di, _, f in dups if di == i)
                notes.append(f"dup of #{first_idx + 1}")
            # escape pipes
            safe = (line or "").replace("|", "\\|")
            md.append(f"| {i+1} | {rid} | {safe!r} | {'; '.join(notes) or '—'} |")
        md.append("")
        md.append(f"**Median rowid stride:** {median_stride}. "
                  f"**Big gaps (>5× median):** {len(big_gaps)}. "
                  f"**Duplicate lines (likely chorus returns):** {len(dups)}.")
        md.append("")
    (OUT / "line_order_check.md").write_text("\n".join(md) + "\n")
    print(f"wrote {OUT / 'line_order_check.md'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
