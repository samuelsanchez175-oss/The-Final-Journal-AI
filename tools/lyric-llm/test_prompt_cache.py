#!/usr/bin/env python3
"""
Unit tests for Task L: Prompt & Params Cache
Tests:
  1. canonical_cache_params normalization and determinism
  2. compute_cache_key SHA-256 stability and uniqueness
  3. save_cached_verse and get_cached_verse roundtrip
  4. Cache miss and max_age_seconds expiration handling
  5. clear_cache and get_cache_stats
  6. Integration with frontier_v4.generate_v4 (cache hit and --no-cache bypass)
"""

import json
import os
import sys
import time
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
for p in (HERE, REPO_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from prompt_cache import (
    canonical_cache_params,
    clear_cache,
    compute_cache_key,
    get_cache_stats,
    get_cached_verse,
    save_cached_verse,
)
import frontier_v4

TEST_CACHE_DIR = HERE / "out" / "test_cache"


class TestPromptCache(unittest.TestCase):
    def setUp(self):
        clear_cache(TEST_CACHE_DIR)

    def tearDown(self):
        clear_cache(TEST_CACHE_DIR)

    def test_canonical_cache_params_determinism(self):
        """Verify that parameter order, album list ordering, and casing normalize identically."""
        p1 = canonical_cache_params(
            voice="gunna",
            blend="nocap",
            mix=70,
            bpm=130.04,
            scale="F minor",
            section_mode="verse",
            chosen_albums=["One of Wun", "WUNNA (Deluxe)"],
            seed_line="Diamonds in the rain",
            topic_hint="money_flex",
        )
        p2 = canonical_cache_params(
            voice="Gunna",
            blend="NoCap",
            mix=70,
            bpm=130.01,
            scale="F minor",
            section_mode="VERSE",
            chosen_albums=["wunna (deluxe)", "one of wun"],
            seed_line="Diamonds in the rain",
            topic_hint="money_flex",
        )
        self.assertEqual(p1, p2)
        self.assertEqual(compute_cache_key(p1), compute_cache_key(p2))

    def test_compute_cache_key_uniqueness(self):
        """Verify different parameters generate distinct SHA-256 cache keys."""
        base = canonical_cache_params(voice="Gunna", bpm=130.0, topic_hint="money_flex")
        diff_bpm = canonical_cache_params(voice="Gunna", bpm=140.0, topic_hint="money_flex")
        diff_voice = canonical_cache_params(voice="Drake", bpm=130.0, topic_hint="money_flex")
        diff_topic = canonical_cache_params(voice="Gunna", bpm=130.0, topic_hint="street_defiance")

        k_base = compute_cache_key(base)
        k_bpm = compute_cache_key(diff_bpm)
        k_voice = compute_cache_key(diff_voice)
        k_topic = compute_cache_key(diff_topic)

        self.assertEqual(len(k_base), 64)
        self.assertNotEqual(k_base, k_bpm)
        self.assertNotEqual(k_base, k_voice)
        self.assertNotEqual(k_base, k_topic)

    def test_save_and_get_cached_verse_roundtrip(self):
        """Verify saving a verse payload and reading it back preserves plan, catalog bars, and metadata."""
        params = canonical_cache_params(voice="Gunna", bpm=130.0)
        cache_key = compute_cache_key(params)

        sample_result = {
            "ok": True,
            "version": "v4",
            "generation_id": "gen_test_roundtrip",
            "voice": "Gunna",
            "bars": [
                {"index": 1, "text": "Young Gunna Wunna stepping on the gas, luxury audamar", "syllables": 18}
            ],
            "style_score": 0.88,
        }
        sample_plan = {"end_words": ["audamar"], "couplet_voices": ["Gunna"]}
        sample_cat = [{"id": 401, "text": "Catalog bar text", "end_word": "audamar"}]

        saved_path = save_cached_verse(
            cache_key=cache_key,
            params=params,
            result=sample_result,
            retrieved_catalog_bars=sample_cat,
            plan=sample_plan,
            cache_dir=TEST_CACHE_DIR,
        )
        self.assertTrue(saved_path.exists())

        # Read back
        cached = get_cached_verse(cache_key, cache_dir=TEST_CACHE_DIR)
        self.assertIsNotNone(cached)
        self.assertTrue(cached.get("cached"))
        self.assertEqual(cached.get("cache_key"), cache_key)
        self.assertEqual(cached.get("voice"), "Gunna")
        self.assertEqual(len(cached.get("bars", [])), 1)
        self.assertEqual(cached.get("plan"), sample_plan)
        self.assertEqual(cached.get("retrieved_catalog_bars"), sample_cat)

    def test_cache_miss_and_expiration(self):
        """Verify non-existent and expired keys return None."""
        self.assertIsNone(get_cached_verse("non_existent_hash", cache_dir=TEST_CACHE_DIR))

        params = canonical_cache_params(voice="Gunna")
        key = compute_cache_key(params)
        save_cached_verse(
            cache_key=key,
            params=params,
            result={"ok": True},
            cache_dir=TEST_CACHE_DIR,
        )

        # Immediate read succeeds
        self.assertIsNotNone(get_cached_verse(key, cache_dir=TEST_CACHE_DIR))

        # Read with max_age_seconds=0.0 expires
        time.sleep(0.02)
        expired = get_cached_verse(key, cache_dir=TEST_CACHE_DIR, max_age_seconds=0.01)
        self.assertIsNone(expired)

    def test_clear_cache_and_stats(self):
        """Verify get_cache_stats and clear_cache operation."""
        p1 = canonical_cache_params(voice="Gunna", bpm=120.0)
        p2 = canonical_cache_params(voice="NoCap", bpm=135.0)

        save_cached_verse(compute_cache_key(p1), p1, {"ok": True}, cache_dir=TEST_CACHE_DIR)
        save_cached_verse(compute_cache_key(p2), p2, {"ok": True}, cache_dir=TEST_CACHE_DIR)

        stats = get_cache_stats(cache_dir=TEST_CACHE_DIR)
        self.assertEqual(stats["total_entries"], 2)
        self.assertGreater(stats["size_bytes"], 0)

        cleared = clear_cache(cache_dir=TEST_CACHE_DIR)
        self.assertEqual(cleared, 2)

        stats_after = get_cache_stats(cache_dir=TEST_CACHE_DIR)
        self.assertEqual(stats_after["total_entries"], 0)

    def test_frontier_v4_cache_hit_and_bypass(self):
        """Verify frontier_v4.generate_v4 uses cache on second invocation and bypasses with use_cache=False."""
        call_count = 0
        def counting_mock_call(model, prompt):
            nonlocal call_count
            call_count += 1
            return (
                "Audamar flooded out, ice on the collarbone, diamond in the face, living in a palace\n"
                "Twenty-four-seven in the foreign, burning down the lane, nothing can erase, balance in the chalice\n"
                "Saw the way she look at me, diamonds on the wrist, stepping with the grace, feeling no malice\n"
                "Had to catch a flight to Paris, packing up the bag, never beat the case, sipping out of Dallas\n"
            )

        # Clear global cache directory for this test's unique voice/bpm
        test_seed = f"test_cache_seed_{int(time.time()*1000)}"

        # 1. First run: Cache MISS
        res1 = frontier_v4.generate_v4(
            voice="Gunna",
            blend=None,
            bpm=133.0,
            target_syl=18,
            bars_count=4,
            candidates=1,
            seed_line=test_seed,
            use_cache=True,
            call_fn=counting_mock_call,
        )
        self.assertTrue(res1["ok"])
        self.assertFalse(res1.get("cached", False))
        self.assertIn("cache_key", res1)
        initial_calls = call_count
        self.assertGreater(initial_calls, 0)

        # 2. Second run: Cache HIT (Zero LLM calls made!)
        res2 = frontier_v4.generate_v4(
            voice="Gunna",
            blend=None,
            bpm=133.0,
            target_syl=18,
            bars_count=4,
            candidates=1,
            seed_line=test_seed,
            use_cache=True,
            call_fn=counting_mock_call,
        )
        self.assertTrue(res2["ok"])
        self.assertTrue(res2.get("cached", False))
        self.assertEqual(res2.get("cache_key"), res1.get("cache_key"))
        # Call count should not have increased
        self.assertEqual(call_count, initial_calls)

        # 3. Third run: use_cache=False bypasses cache and regenerates
        res3 = frontier_v4.generate_v4(
            voice="Gunna",
            blend=None,
            bpm=133.0,
            target_syl=18,
            bars_count=4,
            candidates=1,
            seed_line=test_seed,
            use_cache=False,
            call_fn=counting_mock_call,
        )
        self.assertTrue(res3["ok"])
        self.assertFalse(res3.get("cached", False))
        self.assertGreater(call_count, initial_calls)


if __name__ == "__main__":
    unittest.main()
