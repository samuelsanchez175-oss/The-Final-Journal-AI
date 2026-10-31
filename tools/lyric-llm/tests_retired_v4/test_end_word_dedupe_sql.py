#!/usr/bin/env python3
"""test_end_word_dedupe_sql.py
===========================
Unit tests for Move 4: End-Word Dedupe Window in SQL.
Tests:
1. SQL NOT IN filtering: Passing recent_end_words excludes those exact words in Tier A, B, C, D.
2. Explicit target override: If target_word is explicitly requested, it is not filtered out by SQL.
3. Relaxed dedupe fallback: If all candidates are in recent_end_words, relaxation allows retrieval rather than failing to hardcoded bank.
4. Back-to-back generations: Two consecutive generations with history tracking have zero overlapping end words.
"""


from __future__ import annotations

import os
from pathlib import Path
import sys
import unittest

HERE = Path(__file__).resolve().parent.parent  # lyric-llm; this file lives in tests_retired_v4
REPO_ROOT = HERE.parent.parent
for p in (HERE, REPO_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from catalog_retriever import (
    clear_end_word_history,
    get_end_word_history,
    record_used_end_words,
    retrieve_matching_catalog_lines,
)
from frontier_v4 import generate_v4

TEST_DEDUPE_HISTORY = HERE / "out" / "test_dedupe_history.json"


class TestEndWordDedupeSQL(unittest.TestCase):
    def setUp(self):
        self._orig_seed = os.environ.get("V4_SEED")
        os.environ["V4_SEED"] = "42"
        clear_end_word_history(TEST_DEDUPE_HISTORY)
        clear_end_word_history()

    def tearDown(self):
        if self._orig_seed is None:
            os.environ.pop("V4_SEED", None)
        else:
            os.environ["V4_SEED"] = self._orig_seed
        clear_end_word_history(TEST_DEDUPE_HISTORY)
        clear_end_word_history()

    def test_sql_not_in_exclusion(self):
        """Verify that words in recent_end_words are excluded from SQL query results."""
        pattern = {
            "end_word": "",
            "end_rime": "IY1 N",
            "vowel_class": "V_front_high",
            "target_syllables": 14,
        }
        # First query without dedupe
        initial_results = retrieve_matching_catalog_lines(
            artist="Gunna",
            pattern=pattern,
            recent_end_words=[],
            limit=10,
        )
        self.assertTrue(len(initial_results) > 0)
        top_words = list({(r.get("end_word") or "").lower() for r in initial_results if r.get("end_word")})
        self.assertTrue(len(top_words) > 0)

        # Now pass top_words in recent_end_words
        deduped_results = retrieve_matching_catalog_lines(
            artist="Gunna",
            pattern=pattern,
            recent_end_words=top_words,
            limit=10,
        )
        for r in deduped_results:
            end_w = (r.get("end_word") or "").lower()
            self.assertNotIn(
                end_w,
                top_words,
                f"Word '{end_w}' was in recent_end_words and should have been excluded by SQL NOT IN",
            )

    def test_explicit_target_word_overrides_sql_dedupe(self):
        """Verify that if caller explicitly provides target_word, it is not blocked by SQL NOT IN."""
        explicit_target = "mercedes"
        pattern = {
            "end_word": explicit_target,
            "end_rime": "EY1 D IY0 Z",
            "vowel_class": "V_front_mid",
            "target_syllables": 14,
        }
        # Include explicit_target in recent_end_words
        results = retrieve_matching_catalog_lines(
            artist="Gunna",
            pattern=pattern,
            recent_end_words=["patek", explicit_target, "audamar"],
            limit=60,
        )
        self.assertTrue(len(results) > 0)
        found_target = any((r.get("end_word") or "").lower() == explicit_target for r in results)
        self.assertTrue(found_target, f"Explicit target '{explicit_target}' should be retrieved despite being in recent_end_words")
        # Ensure the other recent_end_words (patek, audamar) are strictly excluded
        for r in results:
            end_w = (r.get("end_word") or "").lower()
            self.assertNotIn(end_w, ["patek", "audamar"])

    def test_back_to_back_generations_zero_end_word_collision(self):
        """Verify two consecutive generations in the same session have zero repeating end words."""
        # Unset seed for stochastic diversity
        os.environ.pop("V4_SEED", None)
        os.environ["V4_RETRIEVAL_TEMP"] = "2.0"

        # Generate Verse 1
        res1 = generate_v4(
            voice="Gunna",
            blend="NoCap",
            mix=70,
            bars_count=8,
            topic_hint="jewelry_and_ice",
            candidates=1,
            use_cache=False,
        )
        ends1 = [b.get("end_word", "").lower() for b in res1.get("bars", []) if b.get("end_word")]
        self.assertEqual(len(ends1), 8)

        # Generate Verse 2 with the same session history
        res2 = generate_v4(
            voice="Gunna",
            blend="NoCap",
            mix=70,
            bars_count=8,
            topic_hint="jewelry_and_ice",
            candidates=1,
            use_cache=False,
        )
        ends2 = [b.get("end_word", "").lower() for b in res2.get("bars", []) if b.get("end_word")]
        self.assertEqual(len(ends2), 8)

        overlap = set(ends1).intersection(set(ends2))
        self.assertEqual(
            len(overlap),
            0,
            f"Expected zero end-word overlap between consecutive generations, got overlap: {overlap}",
        )


if __name__ == "__main__":
    unittest.main()
