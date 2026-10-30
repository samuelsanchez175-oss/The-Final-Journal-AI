"""Verdict scorer rhyme_hit: phonetic equality, fallback char-suffix."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from path_a_vs_b_verdict import rhyme_hit, generic_score, HAVE_CMU


class TestRhymeHit(unittest.TestCase):
    def test_identity(self):
        self.assertTrue(rhyme_hit("tonight", "tonight"))

    def test_empty(self):
        self.assertFalse(rhyme_hit("", "night"))
        self.assertFalse(rhyme_hit("night", ""))

    def test_true_rhyme_cmu(self):
        if not HAVE_CMU:
            self.skipTest("CMU dict unavailable")
        self.assertTrue(rhyme_hit("fire", "liar"))
        self.assertTrue(rhyme_hit("crown", "down"))
        self.assertTrue(rhyme_hit("money", "honey"))

    def test_false_rhyme_cmu(self):
        if not HAVE_CMU:
            self.skipTest("CMU dict unavailable")
        self.assertFalse(rhyme_hit("the", "me"))
        self.assertFalse(rhyme_hit("that", "her"))
        self.assertFalse(rhyme_hit("bitch", "nigga"))

    def test_fallback_suffix_outside_cmu(self):
        # neologisms still match on 3-char suffix via fallback
        self.assertTrue(rhyme_hit("xyzzling", "fizzling"))


class TestGenericScore(unittest.TestCase):
    def test_rhyming_couplets(self):
        bars = [
            "I ride through the city with a crown",
            "The whole block watchin' as I come down",
            "Pockets full of hundreds and honey",
            "Street dreams, we chasin' the money",
        ]
        out = generic_score(bars)
        # 3 adjacent pairs: (crown,down)=hit, (down,honey)=miss, (honey,money)=hit → 2/3
        self.assertGreater(out["rhyme_density"], 0.5)

    def test_non_rhyming_fails(self):
        bars = [
            "I know 'bout family ties, but can't say bitch",
            "Diamonds dancing on my wrist, call it nigga",
            "On the block with the shit",
            "Count up right now",
        ]
        out = generic_score(bars)
        self.assertEqual(out["rhyme_density"], 0.0)


if __name__ == "__main__":
    unittest.main()
