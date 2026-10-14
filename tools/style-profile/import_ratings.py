#!/usr/bin/env python3
"""Load a sparkler.ratings.v1 export into the feedback database.

Bar thumbs go through FeedbackStore.vote() so bar ids stay
"<generation_id>:<bar_index>". The whole rating is also stored unchanged
in rating_cards. Verse votes are not copied onto bars.

Usage:
  python3 tools/style-profile/import_ratings.py tools/style-profile/rater/exports/sparkler_ratings_2026-10-14_0150.json
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import feedback_store
import phase6_generate as gen

REASONS = feedback_store.REASONS


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: import_ratings.py <sparkler_ratings.json>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("schema") != "sparkler.ratings.v1" or not isinstance(data.get("ratings"), list):
        print("expected schema sparkler.ratings.v1", file=sys.stderr)
        return 1
    store = feedback_store.FeedbackStore(str(gen.OUT / "feedback.db"))
    store.db.execute(
        """CREATE TABLE IF NOT EXISTS rating_cards (
             generation_id TEXT PRIMARY KEY,
             payload TEXT NOT NULL
           )"""
    )
    bar_rows = 0
    cards = 0
    missing = []
    for row in data["ratings"]:
        gid = row.get("generation_id")
        if not gid:
            continue
        reasons = [code for code in row.get("verse_reasons") or [] if code in REASONS]
        clean = dict(row)
        clean["verse_reasons"] = reasons
        store.db.execute(
            "INSERT INTO rating_cards (generation_id, payload) VALUES (?, ?) "
            "ON CONFLICT(generation_id) DO UPDATE SET payload = excluded.payload",
            (gid, json.dumps(clean, ensure_ascii=False)),
        )
        cards += 1
        for bar in row.get("bar_votes") or []:
            vote = bar.get("vote")
            if vote not in (1, -1):
                continue
            bar_id = bar.get("bar_id") or f"{gid}:{bar.get('bar_index')}"
            found = store.db.execute("SELECT 1 FROM generation_bars WHERE id = ?", (bar_id,)).fetchone()
            if not found:
                missing.append(bar_id)
                continue
            already = store.db.execute(
                "SELECT 1 FROM votes WHERE bar_id = ? AND target_kind = 'bar' AND vote = ?",
                (bar_id, vote),
            ).fetchone()
            if already:
                continue
            store.vote(bar_id, vote)
            bar_rows += 1
    store.db.commit()
    print(f"cards {cards}, bar votes added {bar_rows}, missing bars {len(missing)}")
    for bar_id in missing:
        print(f"  missing {bar_id}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
