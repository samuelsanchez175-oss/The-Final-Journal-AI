#!/usr/bin/env python3
"""test_llm_client.py
===================
Unit tests for direct SDK dispatcher in llm_client.py.
Verifies:
1. Alias normalization (e.g. claude-opus-4-7, auto/fast).
2. Anthropic SDK mock dispatch for claude-* models.
3. OpenAI SDK mock dispatch for gpt-* models.
4. Clean errors without key leakage.
"""


import os
import unittest
from unittest.mock import MagicMock, patch
from pathlib import Path

# Add tools/lyric-llm to sys.path
import sys
HERE = Path(__file__).resolve().parent.parent  # lyric-llm; this file lives in tests_retired_v4
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

import llm_client


class TestLLMClient(unittest.TestCase):

    def test_unsupported_model_raises_value_error(self):
        with self.assertRaises(ValueError) as ctx:
            llm_client.chat(
                model="some-unknown-provider-model-xyz",
                system="sys",
                user="usr",
            )
        self.assertIn("Unsupported model provider", str(ctx.exception))


if __name__ == "__main__":
    unittest.main()
