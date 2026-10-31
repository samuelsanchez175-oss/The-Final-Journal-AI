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
HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

import llm_client


class TestLLMClient(unittest.TestCase):
    def test_resolve_model_name_aliases(self):
        self.assertEqual(llm_client.resolve_model_name("gh/gpt-4o"), "gpt-4o")
        self.assertEqual(llm_client.resolve_model_name("gh/gpt-4o-mini"), "gpt-4o-mini")
        self.assertTrue("opus" in llm_client.resolve_model_name("claude-opus-4-7").lower())
        self.assertTrue("sonnet" in llm_client.resolve_model_name("claude-sonnet-5-5").lower())

    def test_anthropic_dispatch_called_correctly(self):
        mock_client = MagicMock()
        mock_content = MagicMock()
        mock_content.text = "Mocked Claude Output"
        mock_response = MagicMock()
        mock_response.content = [mock_content]
        mock_client.messages.create.return_value = mock_response

        result = llm_client.chat(
            model="claude-3-5-sonnet-20241022",
            system="System prompt here",
            user="User prompt here",
            anthropic_client=mock_client,
        )

        self.assertEqual(result, "Mocked Claude Output")
        mock_client.messages.create.assert_called_once_with(
            model="claude-3-5-sonnet-20241022",
            system="System prompt here",
            messages=[{"role": "user", "content": "User prompt here"}],
            max_tokens=800,
            temperature=0.7,
        )

    def test_openai_dispatch_called_correctly(self):
        mock_client = MagicMock()
        mock_choice = MagicMock()
        mock_choice.message.content = "Mocked GPT Output"
        mock_response = MagicMock()
        mock_response.choices = [mock_choice]
        mock_client.chat.completions.create.return_value = mock_response

        result = llm_client.chat(
            model="gpt-4o",
            system="System instructions",
            user="Generate bars",
            openai_client=mock_client,
        )

        self.assertEqual(result, "Mocked GPT Output")
        mock_client.chat.completions.create.assert_called_once_with(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "System instructions"},
                {"role": "user", "content": "Generate bars"},
            ],
            max_tokens=800,
            temperature=0.7,
        )

    def test_missing_api_key_raises_informative_error(self):
        with patch.dict(os.environ, {}, clear=True):
            with self.assertRaises(ValueError) as ctx:
                llm_client.chat(
                    model="claude-3-5-sonnet-20241022",
                    system="sys",
                    user="usr",
                )
            self.assertIn("ANTHROPIC_API_KEY is not set", str(ctx.exception))


if __name__ == "__main__":
    unittest.main()
