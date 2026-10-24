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
        clear_end_word_history(TEST_HISTORY_PATH)

    def tearDown(self):
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

    def test_topic_chain_boost(self):
        """Verify topic_hint boosts authentic catalog lines with matching topic (+75.0) and sets topic_match=True."""
        pattern = {
            "end_word": "bag",
            "end_rime": "AE1 G",
            "vowel_class": "V_front_open",
            "target_syllables": 18,
        }
        # Retrieve with lavishness_money motif
        results = retrieve_matching_catalog_lines(
            artist="Gunna",
            pattern=pattern,
            topic_hint="lavishness_money",
            limit=10,
        )
        self.assertTrue(len(results) > 0)
        has_topic_match = any(r.get("topic_match") is True for r in results)
        self.assertTrue(has_topic_match, "Expected at least one candidate with topic_match=True")
        # Ensure topic match candidates have authentic topic from motif aliases
        matching_topics = MOTIF_TO_TOPIC_ALIASES.get("lavishness_money", set())
        for r in results:
            if r.get("topic_match"):
                self.assertTrue(
                    r.get("topic") in matching_topics or "money" in (r.get("topic") or "") or "luxury" in (r.get("topic") or "")
                )

    def test_inner_rhyme_indexed_retrieval(self):
        """Verify target_inner_vowel boosts lines matching inner vowel class (+65.0) and sets inner_vowel_match=True."""
        pattern = {
            "end_word": "clean",
            "end_rime": "IY1 N",
            "vowel_class": "V_front_high",
            "target_syllables": 18,
        }
        # Request inner vowel V_front_open (e.g. 'bag', 'cash', 'stylist')
        results = retrieve_matching_catalog_lines(
            artist="Gunna",
            pattern=pattern,
            target_inner_vowel="V_front_open",
            limit=10,
        )
        self.assertTrue(len(results) > 0)
        has_inner_match = any(r.get("inner_vowel_match") is True for r in results)
        self.assertTrue(has_inner_match, "Expected at least one candidate with inner_vowel_match=True")
        for r in results:
            if r.get("inner_vowel_match"):
                self.assertEqual(r.get("inner_vowel_class"), "V_front_open")

    def test_end_word_dedupe_window_penalty(self):
        """Verify recently used end-words receive progressive penalties (-160 in last 4, -80 in last 16)."""
        pattern_open = {
            "end_word": "",  # Unconstrained end-word retrieval
            "end_rime": "",
            "vowel_class": "V_broad",
            "target_syllables": 18,
        }

        # First, retrieve without dedupe history
        clean_results = retrieve_matching_catalog_lines(
            artist="Gunna",
            pattern=pattern_open,
            recent_end_words=[],
            limit=5,
        )
        self.assertTrue(len(clean_results) > 0)
        top_end_word = (clean_results[0]["end_word"] or "").lower()

        # Place that top end-word in recent history (within last 4)
        recent_history = ["phantom", "celine", "audamar", top_end_word]
        penalized_results = retrieve_matching_catalog_lines(
            artist="Gunna",
            pattern=pattern_open,
            recent_end_words=recent_history,
            limit=10,
        )

        for r in penalized_results:
            if (r.get("end_word") or "").lower() == top_end_word:
                self.assertEqual(r.get("dedupe_penalty"), -160.0)

        # Place in last 16 (but outside last 4)
        recent_16 = [top_end_word] + ["word"] * 10
        penalized_16_results = retrieve_matching_catalog_lines(
            artist="Gunna",
            pattern=pattern_open,
            recent_end_words=recent_16,
            limit=10,
        )
        for r in penalized_16_results:
            if (r.get("end_word") or "").lower() == top_end_word:
                self.assertEqual(r.get("dedupe_penalty"), -80.0)

    def test_explicit_target_overrides_dedupe(self):
        """Verify that when a user/plan explicitly seeds target_word, the dedupe penalty is waived."""
        explicit_target = "mercedes"
        pattern_explicit = {
            "end_word": explicit_target,
            "end_rime": "IY1 D IY0 Z",
            "vowel_class": "V_front_high",
            "target_syllables": 18,
        }

        # Put explicit_target in the last 4 recently used words
        recent_history = ["patek", "audamar", "celine", explicit_target]
        results = retrieve_matching_catalog_lines(
            artist="Gunna",
            pattern=pattern_explicit,
            recent_end_words=recent_history,
            limit=5,
        )
        self.assertTrue(len(results) > 0)
        for r in results:
            if (r.get("end_word") or "").lower() == explicit_target:
                # Dedupe penalty must be 0.0 because the caller explicitly targeted this word
                self.assertEqual(r.get("dedupe_penalty"), 0.0)

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
