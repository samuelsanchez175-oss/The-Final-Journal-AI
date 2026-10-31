#!/usr/bin/env python3
"""Unit tests for Frontier V4 Task G: Grid-Aware Syllable Gate & Targeted Retries."""

import io
import json
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

# Add tools/lyric-llm to sys.path
HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

import polish


class TestGridAwareGate(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.cmu = polish._get_cmu()

    def test_verify_grid_landings_golden_bars(self):
        golden_bars = [
            "Penthouse is large, gotta fast car, maximum withdraws, blue audamar",
            "She is a stylist, date has been lavish, we caught up and pop shit, over a lobster",
            "Table at the Carbone, sitting in a dark tone, check was thirty thousand, dialed on the smart phone",
        ]
        res = polish.verify_grid_landings(golden_bars, effective_syl=20, cmu=self.cmu)
        self.assertTrue(res["passed"])
        self.assertEqual(res["pass_rate"], 1.0)
        self.assertEqual(res["failed_bars"], 0)
        self.assertEqual(len(res["failed_indices"]), 0)
        for b in res["bar_results"]:
            self.assertTrue(b["passed"])
            self.assertEqual(b["phrase_count"], 4)

    def test_verify_grid_landings_off_grid_fails(self):
        # Beat 1 (2 syl), Beat 2 (1 syl), Beat 3 (16 syl) -> 3 beats off grid
        bad_bar = "Penthouse, car, maximum withdraws out of the bank with all the cash, blue audamar"
        res = polish.verify_grid_landings([bad_bar], effective_syl=20, cmu=self.cmu)
        self.assertFalse(res["passed"])
        self.assertEqual(res["pass_rate"], 0.0)
        self.assertEqual(res["failed_bars"], 1)
        self.assertEqual(res["failed_indices"], [0])
        self.assertGreaterEqual(len(res["bar_results"][0]["off_grid_beats"]), 2)

    def test_verify_grid_landings_wrong_comma_count(self):
        # Only 2 phrases (1 comma) instead of 4
        bad_bar = "Penthouse is large and fast car, maximum withdraws and blue audamar"
        res = polish.verify_grid_landings([bad_bar], effective_syl=20, cmu=self.cmu)
        self.assertFalse(res["passed"])
        self.assertIn("instead of exactly 4 beats", res["bar_results"][0]["violation_desc"])

    def test_single_beat_minor_delta_passes(self):
        # Beat 1: 4s, Beat 2: 3s (slight delta if target is 4-6), Beat 3: 5s, Beat 4: 4s -> only 1 beat off
        bar = "Penthouse is large, gotta fast, maximum withdraws, blue audamar"
        res = polish.verify_grid_landings([bar], effective_syl=20, cmu=self.cmu)
        # Target beat range for 20 syl is 4-6. Beat 2 is 3 syl (1 violation).
        # Since violation count == 1 (< 2) and phrase_count == 4, bar should pass
        b0 = res["bar_results"][0]
        self.assertEqual(b0["violation_count"], 1)
        self.assertTrue(b0["passed"])
        self.assertTrue(res["passed"])

    def test_rewrite_off_grid_bar_mock_success(self):
        bad_bar = "Penthouse, car, maximum withdraws out of the bank with all the cash, blue audamar"
        clean_rewritten = "Penthouse is large, gotta fast car, maximum withdraws, blue audamar"

        def mock_call(system_prompt, user_prompt):
            self.assertIn("blue audamar", user_prompt)
            return clean_rewritten

        rewritten, passed = polish.rewrite_off_grid_bar(
            bar_text=bad_bar,
            target_word="audamar",
            violation_desc="Beat 1 was 2 syl; Beat 2 was 1 syl",
            target_min=4,
            target_max=6,
            effective_syl=20,
            cmu=self.cmu,
            voice="Gunna",
            call_fn=mock_call,
        )
        self.assertEqual(rewritten, clean_rewritten)
        self.assertTrue(passed)

    def test_rewrite_off_grid_bar_preserves_end_word(self):
        bad_bar = "Penthouse, car, maximum withdraws out of the bank with all the cash, blue audamar"
        # The mock model generated a line but forgot the target word "audamar", using "paper"
        model_output_dropped_word = "Penthouse is large, gotta fast car, maximum withdraws, counting up paper"

        def mock_call(system_prompt, user_prompt):
            return model_output_dropped_word

        rewritten, passed = polish.rewrite_off_grid_bar(
            bar_text=bad_bar,
            target_word="audamar",
            violation_desc="Beat 1 was 2 syl",
            target_min=4,
            target_max=6,
            effective_syl=20,
            cmu=self.cmu,
            voice="Gunna",
            call_fn=mock_call,
        )
        # End word must be restored to audamar
        self.assertTrue(rewritten.lower().endswith("audamar"))


if __name__ == "__main__":
    unittest.main()
