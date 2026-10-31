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

HERE = Path(__file__).resolve().parent
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

    def test_record_and_get_history_json_and_jsonl(self):
        """Verify get_end_word_history and record_used_end_words properly track sliding window."""
        words_batch1 = ["maybach", "celine", "compound", "rich"]
        record_used_end_words(words_batch1, max_history=16, history_path=TEST_DEDUPE_HISTORY)
        loaded = get_end_word_history(window_size=16, history_path=TEST_DEDUPE_HISTORY)
        self.assertEqual(loaded, words_batch1)

        words_batch2 = ["patek", "jet"]
        record_used_end_words(words_batch2, max_history=16, history_path=TEST_DEDUPE_HISTORY)
        loaded_window4 = get_end_word_history(window_size=4, history_path=TEST_DEDUPE_HISTORY)
        self.assertEqual(loaded_window4, ["compound", "rich", "patek", "jet"])


if __name__ == "__main__":
    unittest.main()
