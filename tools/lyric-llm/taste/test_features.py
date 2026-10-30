from __future__ import annotations

import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from taste.features import extract, vector, FEATURE_KEYS


class TestFeatures(unittest.TestCase):
    def test_empty(self):
        f = extract([])
        self.assertEqual(f["bar_count"], 0)
        self.assertEqual(f["end_rhyme_hit_rate"], 0.0)

    def test_rhyming_couplets(self):
        bars = [
            "I ride through the city with a crown",
            "The whole block watchin' as I come down",
            "Pockets full of hundreds and honey",
            "Street dreams, we chasin' the money",
        ]
        f = extract(bars, voice="Drake")
        self.assertGreater(f["end_rhyme_hit_rate"], 0.5)
        self.assertEqual(f["bar_count"], 4)
        self.assertGreater(f["commas_per_bar"], 0.0)

    def test_non_rhyming_fails(self):
        bars = [
            "I know 'bout family ties, but can't say bitch",
            "Diamonds dancing on my wrist, call it nigga",
            "On the block with the shit",
            "Count up right now",
        ]
        f = extract(bars, voice="Young Thug")
        self.assertEqual(f["end_rhyme_hit_rate"], 0.0)
        self.assertGreater(f["profanity_rate"], 0.0)

    def test_name_leak_detected(self):
        bars = ["Slim Shady wasn't talking 'bout this when he spit"]
        f = extract(bars, voice="Young Thug")
        self.assertGreaterEqual(f["name_leak"], 1)

    def test_name_leak_skips_voice_artist(self):
        bars = ["Drake was the first to say it"]
        f = extract(bars, voice="Drake")
        self.assertEqual(f["name_leak"], 0)

    def test_vector_shape(self):
        f = extract(["I ride through the city with a crown",
                     "The whole block watchin' as I come down"])
        v = vector(f)
        self.assertEqual(len(v), len(FEATURE_KEYS))
        self.assertTrue(all(isinstance(x, float) for x in v))


if __name__ == "__main__":
    unittest.main()
