#!/usr/bin/env python3
"""Load sparkler.ratings.v1 exports into the feedback database (Task A).

Pumps rater exports into feedback_store, creating verse votes, bar votes,
and preserving reason codes in the new `reasons` column.

CLI:
  python3 tools/style-profile/import_ratings.py \\
      --exports tools/style-profile/rater/exports \\
      --db tools/style-profile/out/feedback.sqlite \\
      [--since 2026-10-01] [--dry-run]
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))
import feedback_store
import phase6_generate as gen

REASONS = feedback_store.REASONS


def parse_iso_timestamp(ts_str: str | None) -> float:
    """Converts ISO 8601 string to unix timestamp float."""
    if not ts_str:
        return 0.0
    try:
        dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        return dt.timestamp()
    except Exception:
        return 0.0


def ensure_schema(db) -> None:
    """Ensures votes table has reasons, rater, and supports verse target_kind."""
    cur = db.cursor()
    cur.execute("PRAGMA table_info(votes);")
    cols = {row[1] for row in cur.fetchall()}
    if not cols:
        return
    if "reasons" not in cols:
        db.execute("ALTER TABLE votes ADD COLUMN reasons TEXT;")
    if "rater" not in cols:
        db.execute("ALTER TABLE votes ADD COLUMN rater TEXT;")

    cur.execute("SELECT sql FROM sqlite_master WHERE type='table' AND name='votes';")
    res = cur.fetchone()
    if res and res[0] and "CHECK" in res[0] and "'verse'" not in res[0]:
        db.execute("PRAGMA foreign_keys=OFF;")
        db.execute("""
            CREATE TABLE votes_migrated (
                id INTEGER PRIMARY KEY AUTOINCREMENT, ts REAL, generation_id TEXT, bar_id TEXT,
                target_kind TEXT CHECK(target_kind IN ('bar','block','catalog_bar','verse')), target_ref TEXT,
                vote INTEGER, reason TEXT, topic TEXT, artist TEXT, blame TEXT,
                reasons TEXT, rater TEXT
            );
        """)
        db.execute("""
            INSERT INTO votes_migrated (id, ts, generation_id, bar_id, target_kind, target_ref, vote, reason, topic, artist, blame, reasons, rater)
            SELECT id, ts, generation_id, bar_id, target_kind, target_ref, vote, reason, topic, artist, blame,
                   COALESCE(reasons, ''), COALESCE(rater, '')
            FROM votes;
        """)
        db.execute("DROP TABLE votes;")
        db.execute("ALTER TABLE votes_migrated RENAME TO votes;")
        db.execute("CREATE INDEX IF NOT EXISTS votes_target ON votes(target_kind, target_ref, topic, artist);")
        db.execute("PRAGMA foreign_keys=ON;")
    db.commit()


def import_ratings(
    exports_path: Path | str,
    db_path: Path | str | None = None,
    since: str | None = None,
    dry_run: bool = False,
) -> dict[str, int]:
    """Imports sparkler.ratings.v1 export files into feedback_store sqlite."""
    exports_path = Path(exports_path)
    if db_path is None:
        db_path = gen.OUT / "feedback.sqlite"
        if not db_path.exists() and (gen.OUT / "feedback.db").exists():
            db_path = gen.OUT / "feedback.db"
    db_path = Path(db_path)

    store = feedback_store.FeedbackStore(str(db_path))
    ensure_schema(store.db)

    store.db.execute(
        """CREATE TABLE IF NOT EXISTS rating_cards (
             generation_id TEXT PRIMARY KEY,
             payload TEXT NOT NULL
           )"""
    )

    if exports_path.is_file():
        files = [exports_path]
    elif exports_path.is_dir():
        files = sorted(exports_path.glob("*.json"))
    else:
        files = []

    files_processed = 0
    bar_votes_added = 0
    verse_votes_added = 0
    duplicates_skipped = 0

    since_dt_str = since.strip() if since else None

    for file_p in files:
        try:
            content = file_p.read_text(encoding="utf-8")
            data = json.loads(content)
        except Exception as exc:
            print(f"[import_ratings] Error reading {file_p}: {exc}", file=sys.stderr)
            continue

        schema = data.get("schema")
        if schema != "sparkler.ratings.v1":
            raise ValueError(f"Expected schema sparkler.ratings.v1, got {schema} in {file_p}")

        file_rater = str(data.get("rater") or "").strip()
        # Skip synthetic grader files
        if file_rater == "sparkler-grader":
            continue

        exported_at = str(data.get("exported_at") or "")
        if since_dt_str and exported_at and exported_at < since_dt_str:
            continue

        ratings_list = data.get("ratings")
        if not isinstance(ratings_list, list):
            continue

        file_had_eligible_ratings = False

        for row in ratings_list:
            gid = row.get("generation_id")
            if not gid:
                continue

            rated_at_str = str(row.get("rated_at") or exported_at)
            if since_dt_str and rated_at_str and rated_at_str < since_dt_str:
                continue

            file_had_eligible_ratings = True
            rater = str(row.get("rater") or file_rater).strip()
            ts = parse_iso_timestamp(rated_at_str)

            # 1. Preserve rating card payload
            if not dry_run:
                verse_reasons = [code for code in row.get("verse_reasons") or [] if code in REASONS]
                clean = dict(row)
                clean["verse_reasons"] = verse_reasons
                store.db.execute(
                    "INSERT INTO rating_cards (generation_id, payload) VALUES (?, ?) "
                    "ON CONFLICT(generation_id) DO UPDATE SET payload = excluded.payload",
                    (gid, json.dumps(clean, ensure_ascii=False)),
                )

            # 2. Verse Vote
            verse_score = row.get("verse_score")
            verse_vote = row.get("verse_vote")
            v_val = None
            if verse_score is not None:
                v_val = int(verse_score)
            elif verse_vote is not None:
                v_val = int(verse_vote)

            if v_val is not None:
                verse_reasons_clean = [code for code in row.get("verse_reasons") or [] if code in REASONS]
                # Dedupe check: (generation_id, rater, timestamp, vote)
                existing_v = store.db.execute(
                    "SELECT 1 FROM votes WHERE target_ref = ? AND target_kind = 'verse' "
                    "AND (rater = ? OR rater IS NULL OR ? = '') AND ts = ? AND vote = ?",
                    (gid, rater, rater, ts, v_val),
                ).fetchone()

                if existing_v:
                    duplicates_skipped += 1
                else:
                    if not dry_run:
                        store.vote(
                            bar_id=gid,
                            vote=v_val,
                            target_kind="verse",
                            target_ref=gid,
                            reason=verse_reasons_clean[0] if verse_reasons_clean else None,
                            rater=rater,
                            ts=ts,
                            reasons=verse_reasons_clean,
                        )
                    verse_votes_added += 1

            # 3. Bar Votes
            for bar in row.get("bar_votes") or []:
                b_vote = bar.get("vote")
                if b_vote not in (1, -1):
                    continue

                bar_id = bar.get("bar_id") or f"{gid}:{bar.get('bar_index')}"
                bar_reasons_clean = [code for code in bar.get("reasons") or [] if code in REASONS]

                # Dedupe check: (bar_id, rater, timestamp, vote)
                existing_b = store.db.execute(
                    "SELECT 1 FROM votes WHERE target_ref = ? AND target_kind = 'bar' "
                    "AND (rater = ? OR rater IS NULL OR ? = '') AND ts = ? AND vote = ?",
                    (bar_id, rater, rater, ts, b_vote),
                ).fetchone()

                if existing_b:
                    duplicates_skipped += 1
                else:
                    if not dry_run:
                        store.vote(
                            bar_id=bar_id,
                            vote=b_vote,
                            target_kind="bar",
                            target_ref=bar_id,
                            reason=bar_reasons_clean[0] if bar_reasons_clean else None,
                            rater=rater,
                            ts=ts,
                            reasons=bar_reasons_clean,
                        )
                    bar_votes_added += 1

        if file_had_eligible_ratings:
            files_processed += 1

    if not dry_run:
        store.db.commit()

    return {
        "files_processed": files_processed,
        "bar_votes_added": bar_votes_added,
        "verse_votes_added": verse_votes_added,
        "duplicates_skipped": duplicates_skipped,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Import Sparkler ratings into feedback_store.")
    parser.add_argument(
        "--exports",
        type=Path,
        default=Path("tools/style-profile/rater/exports"),
        help="Path to directory containing sparkler.ratings.v1 JSON files (or a single file).",
    )
    parser.add_argument(
        "--db",
        type=Path,
        default=None,
        help="Path to feedback SQLite database.",
    )
    parser.add_argument(
        "--since",
        type=str,
        default=None,
        help="Filter ratings on or after this ISO date/timestamp (e.g. 2026-10-01).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Scan and report without writing to database.",
    )
    parser.add_argument(
        "positional_files",
        nargs="*",
        type=Path,
        help="Optional positional file(s) for backwards compatibility.",
    )

    args = parser.parse_args()

    # Determine input path
    exports_input = args.exports
    if args.positional_files:
        exports_input = args.positional_files[0]

    try:
        summary = import_ratings(
            exports_path=exports_input,
            db_path=args.db,
            since=args.since,
            dry_run=args.dry_run,
        )
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    prefix = "[DRY RUN] " if args.dry_run else ""
    print(
        f"{prefix}files processed: {summary['files_processed']}, "
        f"bar votes added: {summary['bar_votes_added']}, "
        f"verse votes added: {summary['verse_votes_added']}, "
        f"duplicates skipped: {summary['duplicates_skipped']}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
