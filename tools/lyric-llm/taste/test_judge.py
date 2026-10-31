from __future__ import annotations

import math
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from taste.features import FEATURE_KEYS, extract, vector
from taste.judge import TasteJudge, spearman


class TestSpearman(unittest.TestCase):
    def test_identical(self):
        self.assertAlmostEqual(spearman([1, 2, 3], [1, 2, 3]), 1.0)

    def test_inverse(self):
        self.assertAlmostEqual(spearman([1, 2, 3], [3, 2, 1]), -1.0)

    def test_tied(self):
        # all ties → correlation 0 (undefined, we return 0.0)
        self.assertEqual(spearman([1, 1, 1], [1, 2, 3]), 0.0)


class TestJudge(unittest.TestCase):
    def test_tiny_training(self):
        # a > b when end_rhyme_hit_rate is higher — supervise 10 pairs
        pairs = []
        for _ in range(10):
            good = [0.9, 0.0, 2.0, 1.0, 15.0, 1.0, 0.1, 0]
            bad = [0.1, 0.0, 1.0, 2.0, 14.0, 0.5, 0.3, 1]
            pairs.append((good, bad, 1, {}))
        j = TasteJudge.train(pairs, epochs=200, lr=0.05)
        self.assertGreater(j.margin(dict(zip(FEATURE_KEYS, good))),
                           j.margin(dict(zip(FEATURE_KEYS, bad))))

    def test_round_trip(self):
        j = TasteJudge([0.1] * len(FEATURE_KEYS), 0.0, [0.0] * len(FEATURE_KEYS), [1.0] * len(FEATURE_KEYS))
        d = j.to_dict()
        j2 = TasteJudge.from_dict(d)
        self.assertEqual(j.margin({}), j2.margin({}))

    def test_score_verse(self):
        j = TasteJudge.load(Path(__file__).parent / "weights.json")
        s = j.score_verse([
            "I ride through the city with a crown",
            "The whole block watchin' as I come down",
        ], voice="Drake")
        self.assertTrue(math.isfinite(s))


if __name__ == "__main__":
    unittest.main()
