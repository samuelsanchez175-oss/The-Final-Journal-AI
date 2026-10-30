from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from taste.wordplay import WordplayIndex, iter_confirmed, INDEX, _tab_rules_ok


@unittest.skipUnless(INDEX.exists(), "wordplay index missing")
class TestWordplay(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.idx = WordplayIndex.build()

    def test_index_populated(self):
        # Samuel-authored only — small by design; antigravity KEEPs are
        # exported for review via wordplay_review_export.py.
        self.assertGreaterEqual(len(self.idx), 1)

    def test_tab_rules_sound_flip_requires_heard_as(self):
        self.assertFalse(_tab_rules_ok({"tab": "sound_flips", "verdict": "KEEP",
                                        "heard_as": ""}))
        self.assertTrue(_tab_rules_ok({"tab": "sound_flips", "verdict": "KEEP",
                                       "heard_as": "mercedes", "setup": "merce"}))

    def test_tab_rules_double_meaning_two_senses(self):
        self.assertFalse(_tab_rules_ok({"tab": "double_meanings", "verdict": "KEEP",
                                        "play": "just drug reference"}))
        self.assertTrue(_tab_rules_ok({"tab": "double_meanings", "verdict": "KEEP",
                                       "play": "ballin' as basketball and money"}))

    def test_retrieve_returns_at_most_k(self):
        hits = self.idx.retrieve(artist="Lil Wayne", end_word="crown", k=5)
        self.assertLessEqual(len(hits), 5)

    def test_retrieve_filters_by_tab(self):
        hits = self.idx.retrieve(tabs=["double_meanings"], k=3)
        self.assertLessEqual(len(hits), 3)
        for h in hits:
            self.assertEqual(h["tab"].lower(), "double_meanings")

    def test_iter_confirmed_has_only_keep(self):
        for e in iter_confirmed():
            self.assertIn(e["source"], {"index-samuel", "index-v2-samuel", "recheck-samuel"})


if __name__ == "__main__":
    unittest.main()
