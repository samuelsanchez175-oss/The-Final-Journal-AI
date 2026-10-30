from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from taste.chips import ChipIndex, DEFAULT_PATH, TOPIC_MAP_PATH


@unittest.skipUnless(DEFAULT_PATH.exists(), "chips.jsonl missing — run chips_export first")
class TestChipIndex(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.idx = ChipIndex.load()

    def test_loaded(self):
        self.assertGreater(len(self.idx), 500)

    def test_topic_map_populated(self):
        cats = self.idx.categories_for_topic("money_flex")
        self.assertIn("money", cats)
        self.assertIn("jewelry", cats)

    def test_retrieve_by_topic_only(self):
        hits = self.idx.retrieve(topic="money_flex", k=5)
        self.assertLessEqual(len(hits), 5)
        # at least one should be from a money-related category
        cats = {h.get("category") for h in hits}
        self.assertTrue(cats & {"money", "jewelry", "jewelers", "brands", "cars", "clothing"})

    def test_retrieve_many_rimes(self):
        rimes = [["AO1", "N"], ["IY1"]]
        hits = self.idx.retrieve_many_rimes(topic="money_flex", end_rimes=rimes,
                                            per_rime=2, k=4)
        self.assertLessEqual(len(hits), 4)

    def test_generic_slang_is_not_suggested(self):
        from taste.chips import ChipIndex, is_generic_slang_chip, slang_chip_names

        dropped = [name.lower() for name in slang_chip_names(self.idx.rows)]
        for name in ("dog shit", "opp shit", "cash out"):
            self.assertIn(name, dropped)
            self.assertTrue(is_generic_slang_chip(name))
        self.assertFalse(is_generic_slang_chip("Sp5der"))
        hits = self.idx.retrieve_many_rimes(
            topic="come_up_hustle",
            end_rimes=[["IH1", "T"], ["AW1", "T"]],
            per_rime=4,
            k=8,
        )
        got = {hit["chip"].lower() for hit in hits}
        self.assertFalse(got & {"dog shit", "opp shit", "cash out"})
        rows = [
            {"chip": "dog shit", "category": "money", "end_rime": ["IH1", "T"], "vault_count": 9},
            {"chip": "Patek", "category": "jewelry", "end_rime": ["IH1", "T"], "vault_count": 1},
        ]
        tiny = ChipIndex(rows, {})
        picked = tiny.retrieve_many_rimes(
            topic="money_flex", end_rimes=[["IH1", "T"]], per_rime=2, k=2,
        )
        self.assertEqual([row["chip"] for row in picked], ["Patek"])

    def test_rime_rank_beats_category(self):
        # a hit whose end_rime matches should rank ahead
        sample_row = next((r for r in self.idx.rows if r.get("end_rime")), None)
        if not sample_row:
            self.skipTest("no rimes present")
        hits = self.idx.retrieve(topic="money_flex", end_rime=sample_row["end_rime"], k=1)
        self.assertEqual(hits[0]["end_rime"], sample_row["end_rime"])


if __name__ == "__main__":
    unittest.main()
