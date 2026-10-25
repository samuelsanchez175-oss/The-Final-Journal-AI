#!/usr/bin/env python3
"""test_retrieval_sampling.py
==========================
Unit test for Move 1: Softmax-sampling of top-K catalog retrieval rows.
Acceptance:
- Seed a fake 60-row result:
  * Same seed → same picks.
  * No seed → >= 20 distinct picks across 50 runs.
"""

import os
import unittest
from pathlib import Path

# Add tools/lyric-llm to sys.path
import sys
HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

from catalog_retriever import softmax_sample_rows


class TestRetrievalSampling(unittest.TestCase):
    def setUp(self):
        # Create a fake 60-row catalog result
        self.fake_rows = [
            {"id": str(i), "text": f"Bar line {i}", "retrieval_rank": float(100 + i * 2)}
            for i in range(60)
        ]

    def test_same_seed_produces_identical_picks(self):
        os.environ["V4_SEED"] = "42"
        os.environ["V4_RETRIEVAL_TEMP"] = "2.0"
        try:
            picks1 = softmax_sample_rows(self.fake_rows, limit=5)
            picks2 = softmax_sample_rows(self.fake_rows, limit=5)
            self.assertEqual([p["id"] for p in picks1], [p["id"] for p in picks2])
        finally:
            os.environ.pop("V4_SEED", None)

    def test_no_seed_produces_diversity_across_50_runs(self):
        os.environ.pop("V4_SEED", None)
        os.environ["V4_RETRIEVAL_TEMP"] = "2.0"
        picks = []
        for _ in range(50):
            sample = softmax_sample_rows(self.fake_rows, limit=1)
            picks.append(sample[0]["id"])

        distinct_picks = set(picks)
        # Plan acceptance criteria: >= 20 distinct picks across 50 runs
        self.assertGreaterEqual(
            len(distinct_picks),
            20,
            f"Expected at least 20 distinct picks across 50 runs, got {len(distinct_picks)}",
        )

    def test_sampling_without_replacement(self):
        os.environ.pop("V4_SEED", None)
        sample = softmax_sample_rows(self.fake_rows, limit=8)
        self.assertEqual(len(sample), 8)
        ids = [p["id"] for p in sample]
        self.assertEqual(len(ids), len(set(ids)), "Picks must be without replacement")


if __name__ == "__main__":
    unittest.main()
