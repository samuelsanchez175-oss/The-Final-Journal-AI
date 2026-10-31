#!/usr/bin/env python3
"""
Unit tests for Frontier v4 Named-Entity Leak Guard (Task P)
Tests:
  1. Candidate entity extraction (multi-word, capitalization, known rap entities).
  2. Per-voice proper noun whitelists (Gunna, Lil Wayne, Drake, Young Thug, etc.).
  3. Acceptance test: Gunna whitelist vs Lil-Wayne-voiced bar containing 'Thugger' -> guard fails -> retry fires.
  4. Cross-voice collaboration allowances & universal luxury brand support.
  5. Verse-level guard verification with multi-voice couplet allocation.
  6. Pipeline integration and auto-retry loop in polish / frontier_v4.
"""


from __future__ import annotations

import json
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

HERE = Path(__file__).resolve().parent.parent  # lyric-llm; this file lives in tests_retired_v4
REPO_ROOT = HERE.parent.parent
for p in (HERE, REPO_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from entity_guard import (
    build_voice_whitelist,
    extract_candidate_entities,
    get_voice_whitelist,
    guard,
    guard_verse,
    rewrite_leaked_entity_bar,
)
import polish


class TestEntityGuard(unittest.TestCase):

    def test_pipeline_auto_retry_integration(self):
        """Tests that polish.generate_frontier_bars_v2 detects leaked entity and auto-retries."""
        fake_bars = [
            "Bentley coupe is large, gotta fast car, me and Thugger in the spot, blue audamar",
            "Twenty-four-seven in the foreign, got the diamonds in the face, sign the check, blue audamar",
            "Light flick in the dark, fire on the spark, running through the jungle, swimming with the shark",
            "Built the whole foundation solid, winning in the race, never fold, swimming with the shark",
        ]
        fake_resp = {
            "choices": [{
                "message": {
                    "content": "\n".join(fake_bars)
                }
            }]
        }

        # Run with Lil Wayne as voice -> Bar 1 has 'Thugger' which is an off-voice leak for Lil Wayne
        with patch("urllib.request.urlopen") as mock_urlopen:
            mock_resp = MagicMock()
            mock_resp.read.return_value = json.dumps(fake_resp).encode("utf-8")
            mock_resp.__enter__.return_value = mock_resp
            mock_resp.__exit__.return_value = False
            mock_urlopen.return_value = mock_resp

            res = polish.generate_frontier_bars_v2(
                voice="Lil Wayne",
                bars_count=4,
                use_cache=False,
            )

        self.assertTrue(res["ok"])
        self.assertIn("entity_guard", res)
        # Verify that entity_retries fired for the failing bar
        self.assertGreater(res["entity_retries"], 0)
        # Bar 1 should be cleaned of 'Thugger'
        final_bar1 = res["bars"][0]["text"]
        self.assertNotIn("thugger", final_bar1.lower())


if __name__ == "__main__":
    unittest.main()
