#!/usr/bin/env python3
"""Unit tests for Frontier V4 Task B': Wire Rater Feedback Taste Blocks into polish.py."""


import json
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

# Add tools/lyric-llm and tools/style-profile to sys.path
HERE = Path(__file__).resolve().parent.parent  # lyric-llm; this file lives in tests_retired_v4
STYLE_PROFILE_DIR = HERE.parent / "style-profile"
for p in (HERE, STYLE_PROFILE_DIR):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

import feedback_store
import polish


class TestTasteBlocksV4(unittest.TestCase):
    def test_taste_on_includes_keeper_and_avoid_blocks(self):
        prompt = polish.build_v2_system_prompt("Gunna", taste_on=True, taste_k=6)
        self.assertIn("RATER TASTE SIGNALS", prompt)
        self.assertIn("WRITE LIKE THIS (keeper bars from this artist, rated by the writer):", prompt)
        self.assertIn("AVOID (these problems hit before):", prompt)

    def test_taste_k_limits_bars(self):
        prompt = polish.build_v2_system_prompt("Gunna", taste_on=True, taste_k=2)
        self.assertIn("WRITE LIKE THIS", prompt)
        # Extract WRITE LIKE THIS block
        keeper_section = prompt.split("WRITE LIKE THIS (keeper bars from this artist, rated by the writer):\n")[1]
        keeper_lines = keeper_section.split("\n\n")[0].strip().splitlines()
        # Count bullet lines starting with '- '
        bullet_lines = [l for l in keeper_lines if l.strip().startswith("- ")]
        self.assertLessEqual(len(bullet_lines), 2)
        self.assertGreaterEqual(len(bullet_lines), 1)

    def test_generate_frontier_bars_v2_wires_taste(self):
        recorded_payloads = []

        fake_resp = {
            "choices": [{
                "message": {
                    "content": (
                        "Penthouse is large, gotta fast car, maximum withdraws, blue audamar\n"
                        "She is a stylist, date has been lavish, we caught up and pop shit, over a lobster\n"
                        "Penthouse is spacious, lifestyle is gracious, switchin' lanes in traffic, double M Mercedes\n"
                        "Drippin' in designer, pull up in a foreign, private jet in Paris, paid a dime to squeeze\n"
                    )
                }
            }]
        }

        def fake_urlopen(req, timeout=30):
            body = req.data.decode("utf-8") if hasattr(req, "data") else ""
            if body:
                try:
                    recorded_payloads.append(json.loads(body))
                except Exception:
                    pass
            mock_resp = MagicMock()
            mock_resp.read.return_value = json.dumps(fake_resp).encode("utf-8")
            mock_resp.__enter__.return_value = mock_resp
            mock_resp.__exit__.return_value = False
            return mock_resp

        with patch("urllib.request.urlopen", side_effect=fake_urlopen):
            res_on = polish.generate_frontier_bars_v2(
                voice="Gunna",
                bars_count=4,
                taste_on=True,
                taste_k=3,
                use_cache=False,
            )

        self.assertTrue(res_on["ok"])
        self.assertTrue(res_on["taste_on"])
        self.assertEqual(res_on["taste_k"], 3)

        # Check ghostwriter generation payload had taste blocks
        ghostwriter_payloads = [
            p for p in recorded_payloads
            if "Ghostwriter" in p["messages"][0]["content"] and "Planner" not in p["messages"][0]["content"]
        ]
        self.assertGreater(len(ghostwriter_payloads), 0)
        sys_prompt = ghostwriter_payloads[0]["messages"][0]["content"]
        self.assertIn("WRITE LIKE THIS", sys_prompt)
        self.assertIn("AVOID (these problems hit before):", sys_prompt)

        # Now test with taste_on=False
        recorded_payloads.clear()
        with patch("urllib.request.urlopen", side_effect=fake_urlopen):
            res_off = polish.generate_frontier_bars_v2(
                voice="Gunna",
                bars_count=4,
                taste_on=False,
                use_cache=False,
            )

        self.assertFalse(res_off["taste_on"])
        ghostwriter_payloads_off = [
            p for p in recorded_payloads
            if "Ghostwriter" in p["messages"][0]["content"] and "Planner" not in p["messages"][0]["content"]
        ]
        self.assertGreater(len(ghostwriter_payloads_off), 0)
        sys_prompt_off = ghostwriter_payloads_off[0]["messages"][0]["content"]
        self.assertNotIn("WRITE LIKE THIS", sys_prompt_off)
        self.assertNotIn("AVOID (these problems hit before):", sys_prompt_off)


if __name__ == "__main__":
    unittest.main()
