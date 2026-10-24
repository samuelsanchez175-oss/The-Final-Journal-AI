#!/usr/bin/env python3
"""
Unit tests for Task K: Per-Bar Telemetry System
Tests:
  1. check_punch_demoted detection logic (mid-bar punchline demotion vs end-word)
  2. write_bar_telemetry exact 14-field schema conformance
  3. write_verse_telemetry roundtrip across 8 bars
  4. read_telemetry & get_telemetry_stats aggregation
  5. Integration with frontier_v4.generate_v4 pipeline execution
"""

import json
import os
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
for p in (HERE, REPO_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from telemetry import (
    REQUIRED_TELEMETRY_FIELDS,
    check_punch_demoted,
    get_telemetry_stats,
    read_telemetry,
    write_bar_telemetry,
    write_verse_telemetry,
)
import frontier_v4

TEST_TELEMETRY_PATH = HERE / "out" / "test_telemetry.jsonl"


class TestV4Telemetry(unittest.TestCase):
    def setUp(self):
        if TEST_TELEMETRY_PATH.exists():
            TEST_TELEMETRY_PATH.unlink()

    def tearDown(self):
        if TEST_TELEMETRY_PATH.exists():
            TEST_TELEMETRY_PATH.unlink()

    def test_check_punch_demoted(self):
        """Verify punch-demotion detection when signature words appear mid-bar rather than at end-word."""
        # 1. Target word demoted to mid-bar
        demoted_line1 = "Maybach parked outside, I'm heading to the spot"
        self.assertTrue(check_punch_demoted(demoted_line1, target_end_word="maybach"))

        # 2. Target word properly placed as end-word
        proper_line1 = "Heading to the spot, I'm pulling in a maybach"
        self.assertFalse(check_punch_demoted(proper_line1, target_end_word="maybach"))

        # 3. Known signature punch token bank demoted mid-line
        demoted_line2 = "Got the audamar on wrist, stepping through the rain"
        self.assertTrue(check_punch_demoted(demoted_line2, target_end_word="rain"))

        # 4. Known punch token placed as end-word
        proper_line2 = "Diamonds in the rain, flooded out the audamar"
        self.assertFalse(check_punch_demoted(proper_line2, target_end_word="audamar"))

        # 5. Generic line without any punch tokens
        clean_line = "Looking at the clouds, walking through the hall"
        self.assertFalse(check_punch_demoted(clean_line, target_end_word="hall"))

    def test_write_bar_telemetry_schema(self):
        """Verify that every written row contains the exact 14 required telemetry fields."""
        sample_row = {
            "generation_id": "test_gen_12345",
            "bar_index": 1,
            "voice": "Gunna",
            "retrieval_hit": True,
            "retrieval_id": 999,
            "edit_distance": 0.235,
            "end_word_preserved": True,
            "rhyme_family": "AA1 M ER0",
            "target_syl": 18,
            "actual_syl": 18,
            "delta": 0,
            "punch_demoted": False,
            "style_score": 0.88,
            "plan_hit": True,
            "text": "Young Gunna Wunna fly, standing in the audamar",
        }
        written = write_bar_telemetry(sample_row, telemetry_path=TEST_TELEMETRY_PATH)

        # Assert all 14 required fields are present
        for field in REQUIRED_TELEMETRY_FIELDS:
            self.assertIn(field, written, f"Missing required telemetry field: {field}")

        # Check types
        self.assertIsInstance(written["generation_id"], str)
        self.assertIsInstance(written["bar_index"], int)
        self.assertIsInstance(written["voice"], str)
        self.assertIsInstance(written["retrieval_hit"], bool)
        self.assertIsInstance(written["edit_distance"], float)
        self.assertIsInstance(written["end_word_preserved"], bool)
        self.assertIsInstance(written["rhyme_family"], str)
        self.assertIsInstance(written["target_syl"], int)
        self.assertIsInstance(written["actual_syl"], int)
        self.assertIsInstance(written["delta"], int)
        self.assertIsInstance(written["punch_demoted"], bool)
        self.assertIsInstance(written["style_score"], float)
        self.assertIsInstance(written["plan_hit"], bool)

    def test_write_verse_telemetry_roundtrip(self):
        """Verify logging an 8-bar verse produces 8 formatted rows with correct indices and metrics."""
        sample_bars = [
            {
                "index": i + 1,
                "artist": "Gunna" if i < 4 else "NoCap",
                "text": f"Bar text line number {i+1}, shining in the audamar",
                "end_word": "audamar",
                "rhyme_family": "V_broad",
                "target_syllables": 18,
                "syllables": 18,
                "delta": 0,
                "source_catalog_id": 100 + i,
                "source_catalog_text": "Sample authentic catalog text",
                "edit_distance_ratio": 0.25,
                "end_word_preserved": True,
            }
            for i in range(8)
        ]
        sample_plan = {
            "couplet_voices": ["Gunna", "Gunna", "NoCap", "NoCap"],
            "end_words": ["audamar"] * 8,
            "rhyme_families": ["V_broad"] * 4,
        }

        written_rows = write_verse_telemetry(
            generation_id="verse_test_roundtrip_01",
            bars=sample_bars,
            plan=sample_plan,
            style_score=0.91,
            voice="Gunna",
            telemetry_path=TEST_TELEMETRY_PATH,
        )
        self.assertEqual(len(written_rows), 8)

        # Read back from file
        read_rows = read_telemetry(limit=10, telemetry_path=TEST_TELEMETRY_PATH)
        self.assertEqual(len(read_rows), 8)
        for idx, row in enumerate(read_rows):
            self.assertEqual(row["generation_id"], "verse_test_roundtrip_01")
            self.assertEqual(row["bar_index"], idx + 1)
            self.assertEqual(row["retrieval_hit"], True)
            self.assertEqual(row["retrieval_id"], 100 + idx)
            self.assertEqual(row["end_word_preserved"], True)
            self.assertEqual(row["style_score"], 0.91)
            self.assertEqual(row["plan_hit"], True)

    def test_telemetry_stats_calculation(self):
        """Verify get_telemetry_stats computes accurate rates and distributions."""
        sample_rows = [
            {
                "generation_id": "gen_1",
                "bar_index": 1,
                "voice": "Gunna",
                "retrieval_hit": True,
                "retrieval_id": 1,
                "edit_distance": 0.20,
                "end_word_preserved": True,
                "rhyme_family": "V_broad",
                "target_syl": 18,
                "actual_syl": 18,
                "delta": 0,
                "punch_demoted": False,
                "style_score": 0.90,
                "plan_hit": True,
            },
            {
                "generation_id": "gen_1",
                "bar_index": 2,
                "voice": "Gunna",
                "retrieval_hit": True,
                "retrieval_id": 2,
                "edit_distance": 0.30,
                "end_word_preserved": False,
                "rhyme_family": "V_broad",
                "target_syl": 18,
                "actual_syl": 20,
                "delta": 2,
                "punch_demoted": True,
                "style_score": 0.90,
                "plan_hit": False,
            },
        ]
        for r in sample_rows:
            write_bar_telemetry(r, telemetry_path=TEST_TELEMETRY_PATH)

        stats = get_telemetry_stats(telemetry_path=TEST_TELEMETRY_PATH)
        self.assertEqual(stats["total_bars"], 2)
        self.assertEqual(stats["total_generations"], 1)
        self.assertEqual(stats["retrieval_hit_rate"], 1.0)
        self.assertEqual(stats["end_word_preservation_rate"], 0.5)
        self.assertEqual(stats["mean_edit_distance"], 0.25)
        self.assertEqual(stats["punch_demoted_count"], 1)
        self.assertEqual(stats["punch_demoted_rate"], 0.5)
        self.assertEqual(stats["plan_hit_rate"], 0.5)
        self.assertEqual(stats["mean_style_score"], 0.90)

    def test_frontier_v4_pipeline_logs_telemetry(self):
        """Verify that running generate_v4 automatically generates a generation_id and logs telemetry rows."""
        mock_response = (
            "Audamar flooded out, ice on the collarbone, diamond in the face, living in a palace\n"
            "Twenty-four-seven in the foreign, burning down the lane, nothing can erase, balance in the chalice\n"
            "Saw the way she look at me, diamonds on the wrist, stepping with the grace, feeling no malice\n"
            "Had to catch a flight to Paris, packing up the bag, never beat the case, sipping out of Dallas\n"
        )
        def mock_call(model, prompt):
            return mock_response

        res = frontier_v4.generate_v4(
            voice="Gunna",
            blend=None,
            bpm=130.0,
            target_syl=18,
            bars_count=4,
            candidates=1,
            call_fn=mock_call,
        )

        self.assertTrue(res["ok"])
        self.assertIn("generation_id", res)
        self.assertTrue(len(res["generation_id"]) > 0)
        self.assertEqual(len(res["bars"]), 4)

        for b in res["bars"]:
            self.assertIn("source_catalog_id", b)
            self.assertIn("punch_demoted", b)
            self.assertIn("edit_distance_ratio", b)
            self.assertIn("remix_compliant", b)


if __name__ == "__main__":
    unittest.main()
