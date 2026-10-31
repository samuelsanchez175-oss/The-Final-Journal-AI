#!/usr/bin/env python3
"""Unit tests for Frontier V4 Task B': Wire Rater Feedback Taste Blocks into polish.py."""

import json
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

# Add tools/lyric-llm and tools/style-profile to sys.path
HERE = Path(__file__).resolve().parent
STYLE_PROFILE_DIR = HERE.parent / "style-profile"
for p in (HERE, STYLE_PROFILE_DIR):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

import feedback_store
import polish


class TestTasteBlocksV4(unittest.TestCase):

    def test_taste_off_omits_taste_blocks(self):
        prompt = polish.build_v2_system_prompt("Gunna", taste_on=False)
        self.assertNotIn("RATER TASTE SIGNALS", prompt)
        self.assertNotIn("WRITE LIKE THIS", prompt)
        self.assertNotIn("AVOID (these problems hit before):", prompt)

    def test_custom_feedback_store_mock(self):
        store = feedback_store.FeedbackStore(":memory:")
        # Log generation with bars
        gid = store.log_generation(
            artist="Gunna",
            bars=[
                {"text": "Custom keeper bar number one", "topic": "money_flex"},
                {"text": "Custom keeper bar number two", "topic": "money_flex"},
            ],
            model="test-model",
        )
        bar_id_1 = f"{gid}:0"
        bar_id_2 = f"{gid}:1"

        # Upvote both bars
        store.vote(bar_id_1, +1, rater="human-tester", artist="Gunna")
        store.vote(bar_id_2, +1, rater="human-tester", artist="Gunna")

        # Downvote with bad_rhyme
        store.vote(f"{gid}:99", -1, rater="human-tester", artist="Gunna", reasons=["bad_rhyme"])

        prompt = polish.build_v2_system_prompt("Gunna", taste_on=True, taste_k=4, store=store)
        self.assertIn("Custom keeper bar number one", prompt)
        self.assertIn("Custom keeper bar number two", prompt)
        self.assertIn("weak or missing end rhyme", prompt)


if __name__ == "__main__":
    unittest.main()
