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
HERE = Path(__file__).resolve().parent.parent  # lyric-llm; this file lives in tests_retired_v4
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

import polish


class TestGridAwareGate(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.cmu = polish._get_cmu()

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
