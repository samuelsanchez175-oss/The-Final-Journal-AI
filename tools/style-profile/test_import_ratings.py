#!/usr/bin/env python3
"""Unit tests for tools/style-profile/import_ratings.py (Task A)."""

from __future__ import annotations

import json
import os
import shutil
import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import feedback_store
from import_ratings import import_ratings, ensure_schema


class TestImportRatings(unittest.TestCase):
    def setUp(self):
        self.test_dir = tempfile.mkdtemp(prefix="test_import_ratings_")
        self.exports_dir = Path(self.test_dir) / "exports"
        self.exports_dir.mkdir(parents=True, exist_ok=True)
        self.db_path = Path(self.test_dir) / "test_feedback.sqlite"

        # Initialize feedback store and seed a generation
        self.store = feedback_store.FeedbackStore(str(self.db_path))
        self.gid = "gen_test_001"
        self.store.db.execute(
            "INSERT INTO generations (id, created_at, artist, request_json, model, prompt_version) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            (self.gid, 1791940000.0, "Gunna", "{}", "sonnet", "verse.v4"),
        )
        for i in range(4):
            bid = f"{self.gid}:{i}"
            self.store.db.execute(
                "INSERT INTO generation_bars (id, generation_id, bar_index, text, topic) "
                "VALUES (?, ?, ?, ?, ?)",
                (bid, self.gid, i, f"Bar text {i}", "money_flex"),
            )
        self.store.db.commit()

        # Create a sample valid export file matching sparkler.ratings.v1
        self.sample_export = {
            "schema": "sparkler.ratings.v1",
            "rater": "samuel",
            "exported_at": "2026-10-14T07:36:19.419Z",
            "ratings": [
                {
                    "generation_id": self.gid,
                    "model": "sonnet",
                    "artist": "Gunna",
                    "topic": "money_flex",
                    "prompt_version": "verse.v4",
                    "passed_checks": True,
                    "verse_score": 8,
                    "verse_vote": 8,
                    "verse_reasons": ["off_flow"],
                    "note": "solid take",
                    "bar_votes": [
                        {
                            "bar_index": 0,
                            "bar_id": f"{self.gid}:0",
                            "text": "Bar text 0",
                            "vote": 1,
                            "keeper": True,
                            "reasons": [],
                            "rewrite": "",
                        },
                        {
                            "bar_index": 1,
                            "bar_id": f"{self.gid}:1",
                            "text": "Bar text 1",
                            "vote": -1,
                            "keeper": False,
                            "reasons": ["bad_rhyme", "cringe"],
                            "rewrite": "",
                        },
                    ],
                    "rated_at": "2026-10-14T01:36:39.464Z",
                    "time_to_rate_ms": 12000,
                }
            ],
        }
        self.sample_file = self.exports_dir / "sparkler_ratings_2026-10-14_0136.json"
        self.sample_file.write_text(json.dumps(self.sample_export, indent=2), encoding="utf-8")

    def tearDown(self):
        shutil.rmtree(self.test_dir, ignore_errors=True)

    def test_round_trip_counts_and_rows(self):
        """Assure import_ratings reads the export, writes verse and bar votes, and records metadata."""
        summary = import_ratings(self.exports_dir, self.db_path)
        self.assertEqual(summary["files_processed"], 1)
        self.assertEqual(summary["bar_votes_added"], 2)
        self.assertEqual(summary["verse_votes_added"], 1)
        self.assertEqual(summary["duplicates_skipped"], 0)

        # Check DB rows
        cur = self.store.db.cursor()
        cur.execute("SELECT target_kind, target_ref, vote, rater, reasons FROM votes ORDER BY target_kind, target_ref")
        rows = cur.fetchall()
        self.assertEqual(len(rows), 3)

        # Bar vote 0: upvote
        bar0 = [r for r in rows if r[0] == "bar" and r[1] == f"{self.gid}:0"][0]
        self.assertEqual(bar0[2], 1)
        self.assertEqual(bar0[3], "samuel")

        # Bar vote 1: downvote with reasons
        bar1 = [r for r in rows if r[0] == "bar" and r[1] == f"{self.gid}:1"][0]
        self.assertEqual(bar1[2], -1)
        self.assertEqual(bar1[3], "samuel")
        reasons_parsed = json.loads(bar1[4])
        self.assertIn("bad_rhyme", reasons_parsed)
        self.assertIn("cringe", reasons_parsed)

        # Verse vote: score 8
        verse_vote = [r for r in rows if r[0] == "verse" and r[1] == self.gid][0]
        self.assertEqual(verse_vote[2], 8)
        self.assertEqual(verse_vote[3], "samuel")
        v_reasons_parsed = json.loads(verse_vote[4])
        self.assertIn("off_flow", v_reasons_parsed)

    def test_idempotent_reimport_adds_zero_rows(self):
        """Running twice on the same directory must add 0 rows the second time."""
        summary1 = import_ratings(self.exports_dir, self.db_path)
        self.assertEqual(summary1["bar_votes_added"], 2)
        self.assertEqual(summary1["verse_votes_added"], 1)

        summary2 = import_ratings(self.exports_dir, self.db_path)
        self.assertEqual(summary2["files_processed"], 1)
        self.assertEqual(summary2["bar_votes_added"], 0)
        self.assertEqual(summary2["verse_votes_added"], 0)
        self.assertEqual(summary2["duplicates_skipped"], 3)

    def test_weight_returns_sensible_score_after_import(self):
        """feedback_store.weight(kind='bar', ref='<bar_id>') must return sensible smoothed scores."""
        import_ratings(self.exports_dir, self.db_path)
        up_weight = self.store.weight(kind="bar", ref=f"{self.gid}:0")
        down_weight = self.store.weight(kind="bar", ref=f"{self.gid}:1")

        self.assertGreater(up_weight, 0.5)
        self.assertLess(down_weight, 0.5)
        self.assertEqual(up_weight, 0.6)  # (1 + 4*0.5) / (1 + 0 + 4) = 3 / 5 = 0.6
        self.assertEqual(down_weight, 0.4)  # (0 + 4*0.5) / (0 + 1 + 4) = 2 / 5 = 0.4

    def test_skip_sparkler_grader(self):
        """Synthetic ratings from sparkler-grader must be ignored."""
        synth_file = self.exports_dir / "sparkler_autograde.json"
        synth_data = dict(self.sample_export)
        synth_data["rater"] = "sparkler-grader"
        synth_file.write_text(json.dumps(synth_data), encoding="utf-8")

        summary = import_ratings(self.exports_dir, self.db_path)
        # Only the real file is processed
        self.assertEqual(summary["files_processed"], 1)

    def test_fail_loud_on_invalid_schema(self):
        """Must fail loud if schema != sparkler.ratings.v1."""
        bad_file = self.exports_dir / "bad_schema.json"
        bad_data = dict(self.sample_export)
        bad_data["schema"] = "sparkler.ratings.v2_unknown"
        bad_file.write_text(json.dumps(bad_data), encoding="utf-8")

        with self.assertRaises(ValueError):
            import_ratings(self.exports_dir, self.db_path)

    def test_dry_run_does_not_commit(self):
        """Dry run must count candidates but leave the database untouched."""
        summary = import_ratings(self.exports_dir, self.db_path, dry_run=True)
        self.assertEqual(summary["files_processed"], 1)
        self.assertEqual(summary["bar_votes_added"], 2)
        self.assertEqual(summary["verse_votes_added"], 1)

        # Database must still have 0 votes
        cur = self.store.db.cursor()
        cur.execute("SELECT COUNT(*) FROM votes")
        self.assertEqual(cur.fetchone()[0], 0)

    def test_since_filter(self):
        """Ratings before --since date must be ignored."""
        summary = import_ratings(self.exports_dir, self.db_path, since="2026-10-15")
        self.assertEqual(summary["files_processed"], 0)
        self.assertEqual(summary["bar_votes_added"], 0)
        self.assertEqual(summary["verse_votes_added"], 0)


if __name__ == "__main__":
    unittest.main()
