#!/usr/bin/env python3
"""Unit tests for Task B — Wire ratings into generator prompt (taste blocks)."""

from __future__ import annotations

import json
import sqlite3
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import feedback_store
import phase6_generate as gen


class TestTasteBlocks(unittest.TestCase):
    def setUp(self):
        # Create an in-memory feedback store
        self.store = feedback_store.FeedbackStore(":memory:")
        self.store._ensure_schema()

        # Seed generations and bars for Gunna
        self.gid = "gen_gunna_001"
        self.store.db.execute(
            "INSERT INTO generations (id, created_at, artist, request_json, model, prompt_version) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            (self.gid, 1000.0, "Gunna", "{}", "sonnet", "verse.v5"),
        )

        bars = [
            ("I'm in the Maybach, watching the city go grey", "money_flex"),
            ("Sacks on the table, counting the twenties in racks", "money_flex"),
            ("Bought a new Celine, I'm flyin' out to Tokyo", "luxury"),
            ("Grandad fix the motor so the vintage cycles ride", "cars"),
            ("Off-beat rhyme line that makes no sense at all", "filler"),
            ("Another terrible line with awkward rhythm", "filler"),
        ]
        for i, (txt, top) in enumerate(bars):
            bid = f"{self.gid}:{i}"
            self.store.db.execute(
                "INSERT INTO generation_bars (id, generation_id, bar_index, text, topic) "
                "VALUES (?, ?, ?, ?, ?)",
                (bid, self.gid, i, txt, top),
            )

        # Seed votes:
        # Upvotes on first 4 bars (weights will be > 0.5)
        for i in range(4):
            bid = f"{self.gid}:{i}"
            for _ in range(3):
                self.store.vote(
                    bar_id=bid,
                    vote=1,
                    target_kind="bar",
                    target_ref=bid,
                    artist="Gunna",
                    topic=bars[i][1],
                )

        # Downvotes on bars 4 and 5 with reasons
        self.store.vote(
            bar_id=f"{self.gid}:4",
            vote=-1,
            target_kind="bar",
            target_ref=f"{self.gid}:4",
            reason="bad_rhyme",
            reasons=["bad_rhyme", "no_sense"],
            artist="Gunna",
            topic="filler",
        )
        self.store.vote(
            bar_id=f"{self.gid}:5",
            vote=-1,
            target_kind="bar",
            target_ref=f"{self.gid}:5",
            reason="off_flow",
            reasons=["off_flow", "cringe"],
            artist="Gunna",
            topic="filler",
        )
        self.store.db.commit()

        # Mock standard profile, grades, rollup, and exemplars
        self.exemplars = [{"song": "Drip Too Hard", "bars": ["Real bar one, real bar two"]}]
        self.grades = {"end_rhyme_scheme_share": {"couplet": 70, "alternate": 30}}
        self.rollup = {"metrics": {"cadence.syl_per_bar_mean": {"median": 10.5}}}
        self.profile = {"prompt_facts": ["Measured fact 1"]}

    def test_taste_blocks_appear_in_build_prompt(self):
        """With taste_on=True, keeper and avoid blocks must appear in build_prompt."""
        prompt = gen.build_prompt(
            artist="Gunna",
            n_bars=4,
            topic="money_flex",
            scheme="aabb",
            exemplars=self.exemplars,
            grades=self.grades,
            rollup=self.rollup,
            mode="fresh",
            taste_on=True,
            taste_k=6,
            store=self.store,
        )

        self.assertIn("WRITE LIKE THIS (keeper bars from this artist, rated by the writer):", prompt)
        self.assertIn("I'm in the Maybach, watching the city go grey", prompt)
        self.assertIn("Bought a new Celine, I'm flyin' out to Tokyo", prompt)

        self.assertIn("AVOID (these problems hit before):", prompt)
        self.assertIn("weak or missing end rhyme", prompt)

    def test_taste_blocks_appear_in_build_mimic_prompt(self):
        """With taste_on=True, keeper and avoid blocks must appear in build_mimic_prompt."""
        prompt = gen.build_mimic_prompt(
            artist="Gunna",
            n_bars=8,
            exemplars=self.exemplars,
            profile=self.profile,
            closeness=0.7,
            taste=None,
            plan=None,
            taste_on=True,
            taste_k=6,
            store=self.store,
        )

        self.assertIn("WRITE LIKE THIS (keeper bars from this artist, rated by the writer):", prompt)
        self.assertIn("I'm in the Maybach, watching the city go grey", prompt)
        self.assertIn("AVOID (these problems hit before):", prompt)
        self.assertIn("weak or missing end rhyme", prompt)

    def test_taste_off_snapshot_byte_identical(self):
        """With taste_on=False and taste=None, output prompt must be byte-identical to baseline."""
        # Baseline prompt with taste_on=False
        prompt_off = gen.build_prompt(
            artist="Gunna",
            n_bars=4,
            topic="money_flex",
            scheme="aabb",
            exemplars=self.exemplars,
            grades=self.grades,
            rollup=self.rollup,
            mode="fresh",
            taste=None,
            taste_on=False,
            store=self.store,
        )

        self.assertNotIn("WRITE LIKE THIS", prompt_off)
        self.assertNotIn("AVOID (these problems hit before):", prompt_off)
        self.assertNotIn("BARS THE USER LOVED", prompt_off)
        self.assertNotIn("BARS THE USER REJECTED", prompt_off)

        # Calling without taste_on (defaulting to taste_on=False when no store or explicit taste_on=False)
        prompt_baseline = gen.build_prompt(
            artist="Gunna",
            n_bars=4,
            topic="money_flex",
            scheme="aabb",
            exemplars=self.exemplars,
            grades=self.grades,
            rollup=self.rollup,
            mode="fresh",
            taste=None,
            taste_on=False,
        )
        self.assertEqual(prompt_off, prompt_baseline)

    def test_pitfall_dominance_fallback_when_fewer_than_two_bars(self):
        """If fewer than 2 distinct keeper bars are available, do not emit the WRITE LIKE THIS block."""
        store_one = feedback_store.FeedbackStore(":memory:")
        store_one._ensure_schema()
        gid = "gen_single"
        store_one.db.execute(
            "INSERT INTO generations (id, created_at, artist, request_json, model, prompt_version) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            (gid, 1000.0, "Gunna", "{}", "sonnet", "verse.v5"),
        )
        store_one.db.execute(
            "INSERT INTO generation_bars (id, generation_id, bar_index, text, topic) "
            "VALUES (?, ?, ?, ?, ?)",
            (f"{gid}:0", gid, 0, "Only one solitary good line", "money_flex"),
        )
        store_one.vote(f"{gid}:0", 1, target_kind="bar", target_ref=f"{gid}:0", artist="Gunna")
        store_one.db.commit()

        prompt = gen.build_prompt(
            artist="Gunna",
            n_bars=4,
            topic="money_flex",
            scheme="aabb",
            exemplars=self.exemplars,
            grades=self.grades,
            rollup=self.rollup,
            mode="fresh",
            taste_on=True,
            store=store_one,
        )
        self.assertNotIn("WRITE LIKE THIS", prompt)

    def test_pii_scrubbing(self):
        """Bars with PII (email, phone, urls) must have PII scrubbed before prompt inclusion."""
        store_pii = feedback_store.FeedbackStore(":memory:")
        store_pii._ensure_schema()
        gid = "gen_pii"
        store_pii.db.execute(
            "INSERT INTO generations (id, created_at, artist, request_json, model, prompt_version) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            (gid, 1000.0, "Gunna", "{}", "sonnet", "verse.v5"),
        )
        store_pii.db.execute(
            "INSERT INTO generation_bars (id, generation_id, bar_index, text, topic) VALUES (?, ?, ?, ?, ?)",
            (f"{gid}:0", gid, 0, "Call me at 404-555-1234 or hit samuel@pennwork.com, racks in the bank", "money"),
        )
        store_pii.db.execute(
            "INSERT INTO generation_bars (id, generation_id, bar_index, text, topic) VALUES (?, ?, ?, ?, ?)",
            (f"{gid}:1", gid, 1, "Visit https://private-penthouse.com right now, living lavish", "money"),
        )
        store_pii.vote(f"{gid}:0", 1, target_kind="bar", target_ref=f"{gid}:0", artist="Gunna")
        store_pii.vote(f"{gid}:1", 1, target_kind="bar", target_ref=f"{gid}:1", artist="Gunna")
        store_pii.db.commit()

        prompt = gen.build_prompt(
            artist="Gunna",
            n_bars=4,
            topic="money_flex",
            scheme="aabb",
            exemplars=self.exemplars,
            grades=self.grades,
            rollup=self.rollup,
            mode="fresh",
            taste_on=True,
            store=store_pii,
        )
        self.assertIn("WRITE LIKE THIS", prompt)
        self.assertNotIn("404-555-1234", prompt)
        self.assertNotIn("samuel@pennwork.com", prompt)
        self.assertNotIn("https://private-penthouse.com", prompt)

    def test_taste_k_controls_number_of_keeper_bars(self):
        """taste_k parameter limits the number of keeper bars included."""
        prompt = gen.build_prompt(
            artist="Gunna",
            n_bars=4,
            topic="money_flex",
            scheme="aabb",
            exemplars=self.exemplars,
            grades=self.grades,
            rollup=self.rollup,
            mode="fresh",
            taste_on=True,
            taste_k=2,
            store=self.store,
        )
        # Count bullets in WRITE LIKE THIS block
        lines = prompt.splitlines()
        in_block = False
        bullets = []
        for line in lines:
            if "WRITE LIKE THIS" in line:
                in_block = True
                continue
            if in_block:
                if line.startswith("- "):
                    bullets.append(line)
                elif line.strip() and not line.startswith("+"):
                    break
        self.assertEqual(len(bullets), 2)


if __name__ == "__main__":
    unittest.main()
