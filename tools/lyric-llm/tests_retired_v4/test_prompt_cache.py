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

HERE = Path(__file__).resolve().parent.parent  # lyric-llm; this file lives in tests_retired_v4
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
