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

    def test_generate_frontier_bars_v2_grid_integration(self):
        # Mock urllib.request.urlopen to return an initial off-grid bar, then rewrite fixes it
        initial_response = {
            "choices": [{
                "message": {
                    "content": (
                        "Penthouse, car, big money in the bank with the foreign ride, blue audamar\n"
                        "She is a stylist, date has been lavish, we caught up and pop shit, over a lobster\n"
                        "Penthouse is spacious, lifestyle is gracious, switchin' lanes in traffic, double M Mercedes\n"
                        "Drippin' in designer, pull up in a foreign, private jet in Paris, paid a dime to squeeze\n"
                    )
                }
            }]
        }
        rewrite_response = {
            "choices": [{
                "message": {
                    "content": "Penthouse is large, gotta fast car, maximum withdraws, blue audamar"
                }
            }]
        }

        call_count = [0]

        def fake_urlopen(req, timeout=30):
            call_count[0] += 1
            body = req.data.decode("utf-8") if hasattr(req, "data") else ""
            if "REWRITE INSTRUCTION FOR OFF-GRID BAR" in body:
                payload = rewrite_response
            else:
                payload = initial_response

            mock_resp = MagicMock()
            mock_resp.read.return_value = json.dumps(payload).encode("utf-8")
            mock_resp.__enter__.return_value = mock_resp
            mock_resp.__exit__.return_value = False
            return mock_resp

        with patch("urllib.request.urlopen", side_effect=fake_urlopen):
            res = polish.generate_frontier_bars_v2(
                voice="Gunna",
                bars_count=4,
                bpm=130.0,
                target_syl=20,
            )

        self.assertTrue(res["ok"])
        self.assertIn("grid_gate", res)
        self.assertIn("grid_pass_rate", res)
        self.assertGreaterEqual(res["grid_pass_rate"], 0.75)
        self.assertGreaterEqual(res["grid_retries_total"], 1)

        # Check per-bar grid fields
        for b in res["bars"]:
            self.assertIn("grid_passed", b)
            self.assertIn("grid_violations", b)
            self.assertIn("grid_retries", b)
            self.assertIn("grid_violation_desc", b)

        # Check stem alignment received grid pass rate
        self.assertIn("grid_pass_rate", res["stem_alignment"])


if __name__ == "__main__":
    unittest.main()
