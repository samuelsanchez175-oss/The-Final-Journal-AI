"""Unit tests for Move 5: Edit-Line Prompt Enforcement & Catalog Floor (Phase 5)."""

import sys
from pathlib import Path

_LYRIC_LLM = Path(__file__).resolve().parent.parent
if str(_LYRIC_LLM) not in sys.path:
    sys.path.insert(0, str(_LYRIC_LLM))


import unittest
from unittest.mock import patch, MagicMock

from catalog_retriever import (
    token_levenshtein_distance,
    verify_remix_compliance,
    tokenize,
    normalize,
)
from polish import generate_frontier_bars_v2, build_v2_system_prompt


class TestEditLinePrompt(unittest.TestCase):

    def test_system_prompt_contains_edit_line_rules(self):
        prompt = build_v2_system_prompt(voice="Gunna", bars_count=8)
        self.assertIn("EDIT THIS LINE, DO NOT REWRITE", prompt)
        self.assertIn("quality floor", prompt.lower())
        self.assertIn("return the catalog foundation line completely unchanged", prompt.lower())

    @patch("prompt_cache.get_cached_verse", return_value=None)
    @patch("polish.chat")
    @patch("catalog_retriever.retrieve_matching_catalog_lines")
    def test_prompt_construction_has_edit_this_line_blocks(self, mock_retrieve, mock_chat, mock_cache):
        mock_retrieve.return_value = [
            {
                "text": "on the block, stackin' knots, pushin' weight, in the mercedes",
                "end_word": "mercedes",
                "syllables": 17,
                "album": "Drip Harder",
                "song": "Never Recover",
                "line_seq": 1,
                "total_lines": 32,
                "inner_rhymes": ["block", "knots"],
            }
        ] * 8
        # Mock chat to capture user prompt
        captured_user = []

        def fake_chat(model, system, user, **kwargs):
            captured_user.append(user)
            return (
                "in the lab, stackin' knots, pushin' weight, in the mercedes\n" * 8
            )

        mock_chat.side_effect = fake_chat

        res = generate_frontier_bars_v2(
            voice="Gunna",
            bars_count=8,
            topic_hint="studio recording",
        )
        self.assertTrue(len(captured_user) > 0)
        prompt_text = captured_user[0]
        self.assertIn("EDIT THIS LINE, do not rewrite", prompt_text)
        self.assertIn("Keep the end word \"mercedes\" exactly", prompt_text)
        self.assertIn("return the catalog line unchanged", prompt_text)

    @patch("prompt_cache.get_cached_verse", return_value=None)
    @patch("polish.chat")
    @patch("catalog_retriever.retrieve_matching_catalog_lines")
    def test_floor_enforcement_on_cap_violation(self, mock_retrieve, mock_chat, mock_cache):
        # Anchor catalog line
        catalog_anchor = "on the block, stackin' knots, pushin' weight, in the mercedes"
        mock_retrieve.return_value = [
            {
                "text": catalog_anchor,
                "end_word": "mercedes",
                "syllables": 17,
                "album": "Drip Harder",
                "song": "Never Recover",
                "line_seq": 1,
                "total_lines": 32,
            }
        ] * 8

        # Model returns a completely hallucinated line that changes 90% of words
        wild_hallucination = "i was flying in a rocket spaceship heading to the galaxy"
        mock_chat.return_value = "\n".join([wild_hallucination] * 8)

        res = generate_frontier_bars_v2(
            voice="Gunna",
            bars_count=8,
            topic_hint="outer space",
        )

        # Since wild_hallucination violates token Levenshtein cap and end word,
        # Move 5 post-generation hard check MUST enforce the catalog line unchanged!
        for bar in res["bars"]:
            self.assertEqual(bar["raw_text"], catalog_anchor)
            self.assertEqual(bar["end_word"].lower(), "mercedes")
            self.assertEqual(bar["token_levenshtein"], 0)


if __name__ == "__main__":
    unittest.main()
