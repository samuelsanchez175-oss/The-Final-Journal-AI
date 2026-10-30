"""Smoke test for frontier_v5.generate_judged (best-of-N).

Uses stub sample_fn/retrieve_fn to avoid any model/network dependency.
"""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import frontier_v5  # noqa: E402


class TestHardCheck(unittest.TestCase):
    def test_rhyming_commas_pass(self):
        bars = [
            "I ride through the city, with a crown",
            "The whole block watchin', as I come down",
            "Pockets full of hundreds, and honey",
            "Street dreams, we chasin' the money",
        ]
        r = frontier_v5._hard_check_bars(bars, voice="Drake")
        # may or may not pass originality — just ensure comma/rhyme reasons absent
        self.assertNotIn("end-rhyme couplet failure", r["reasons"])

    def test_missing_comma_flags(self):
        bars = [
            "I ride through the city with a crown",
            "The whole block watchin', as I come down",
        ]
        r = frontier_v5._hard_check_bars(bars, voice="Drake")
        self.assertFalse(r["ok"])
        self.assertTrue(any("missing comma" in rr for rr in r["reasons"]))

    def test_rhyme_failure_flags(self):
        bars = [
            "I ride through the city, with a crown",
            "The whole block watchin', as I come up",
        ]
        r = frontier_v5._hard_check_bars(bars, voice="Drake")
        self.assertFalse(r["ok"])
        self.assertIn("end-rhyme couplet failure", r["reasons"])

    def test_empty_fails(self):
        r = frontier_v5._hard_check_bars([], voice="Drake")
        self.assertFalse(r["ok"])


if __name__ == "__main__":
    unittest.main()
