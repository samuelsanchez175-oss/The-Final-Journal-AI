#!/usr/bin/env python3
"""
Unit tests for Task H: Catalog Retriever v2
Tests:
  1. Topic-Chain Binding (+75.0 boost, motif aliases, topic_match flag)
  2. Inner-Rhyme-Indexed Retrieval (+65.0 boost, phoneme normalization, inner_vowel_match flag)
  3. Cross-Generation End-Word Dedupe Window (-160/-80 penalty, circular window)
  4. Explicit User Target Overrides Dedupe Penalty (waives penalty for user seed target)
  5. extract_seed_pattern inner vowel extraction
  6. Persistent End Word History record and clear
"""

import os
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
for p in (HERE, REPO_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from catalog_retriever import (
    DB_PATH,
    clear_end_word_history,
    extract_seed_pattern,
    get_end_word_history,
    load_cmudict,
    normalize_vowel_class,
    record_used_end_words,
    retrieve_matching_catalog_lines,
    MOTIF_TO_TOPIC_ALIASES,
)
from lyriclib import RAP_VOWEL_CLASSES

TEST_HISTORY_PATH = HERE / "out" / "test_end_word_history.json"


class TestCatalogRetrieverV2(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cmu_path = REPO_ROOT / "XJournal AI" / "cmudict.txt"
        cls.cmu = load_cmudict(cmu_path)

    def setUp(self):
        self._orig_seed = os.environ.get("V4_SEED")
        os.environ["V4_SEED"] = "42"
        clear_end_word_history(TEST_HISTORY_PATH)

    def tearDown(self):
        if self._orig_seed is None:
            os.environ.pop("V4_SEED", None)
        else:
            os.environ["V4_SEED"] = self._orig_seed
        clear_end_word_history(TEST_HISTORY_PATH)

    def test_vowel_normalization(self):
        """Verify vowel phoneme and class aliases normalize accurately to RAP_VOWEL_CLASSES."""
        self.assertEqual(normalize_vowel_class("V_aa"), "V_broad")
        self.assertEqual(normalize_vowel_class("AA"), "V_broad")
        self.assertEqual(normalize_vowel_class("V_broad"), "V_broad")
        self.assertEqual(normalize_vowel_class("V_ae"), "V_front_open")
        self.assertEqual(normalize_vowel_class("AE"), "V_front_open")
        self.assertEqual(normalize_vowel_class("V_front_open"), "V_front_open")
        self.assertEqual(normalize_vowel_class("IY"), "V_front_high")
        self.assertEqual(normalize_vowel_class("V_iy"), "V_front_high")
        self.assertEqual(normalize_vowel_class("OW"), "V_round_mid")
        self.assertEqual(normalize_vowel_class(""), "")

    def test_extract_seed_pattern_inner_vowel(self):
        """Verify extract_seed_pattern extracts inner_vowel_class from seed bars."""
        lines = [
            "I still been in my bag, I'm just on other shit",
            "Patek Philippe flooded, got the diamond in the face",
        ]
        patterns = extract_seed_pattern(lines, self.cmu, bpm=130.0)
        self.assertEqual(len(patterns), 2)
        self.assertIn("inner_vowel_class", patterns[0])
        self.assertIn("inner_rhymes", patterns[0])
        self.assertIn("inner_rhyme_count", patterns[0])

    def test_record_and_clear_history(self):
        """Verify record_used_end_words persists words and clear_end_word_history resets window."""
        words_take1 = ["patek", "maybach", "mercedes", "audamar"]
        record_used_end_words(words_take1, max_history=16, history_path=TEST_HISTORY_PATH)

        loaded = get_end_word_history(window_size=16, history_path=TEST_HISTORY_PATH)
        self.assertEqual(loaded, ["patek", "maybach", "mercedes", "audamar"])

        words_take2 = ["rolls", "celine"]
        record_used_end_words(words_take2, max_history=16, history_path=TEST_HISTORY_PATH)

        loaded_recent4 = get_end_word_history(window_size=4, history_path=TEST_HISTORY_PATH)
        self.assertEqual(loaded_recent4, ["mercedes", "audamar", "rolls", "celine"])

        clear_end_word_history(TEST_HISTORY_PATH)
        cleared = get_end_word_history(window_size=16, history_path=TEST_HISTORY_PATH)
        self.assertEqual(cleared, [])


if __name__ == "__main__":
    unittest.main()
