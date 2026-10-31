"""Unit tests for Move 6: Inner-Rhyme, Comma, and Syllable Structural Check (Phase 6)."""

import sys
from pathlib import Path

_LYRIC_LLM = Path(__file__).resolve().parent.parent
if str(_LYRIC_LLM) not in sys.path:
    sys.path.insert(0, str(_LYRIC_LLM))


import unittest
from unittest.mock import patch, MagicMock

from inner_rhyme_check import (
    audit_bar_structure,
    format_structure_rewrite_instruction,
    rewrite_structurally_failed_bar,
    count_bar_syllables,
)
from polish import generate_frontier_bars_v2, build_v2_system_prompt


class TestMove6StructureCheck(unittest.TestCase):

    def test_audit_bar_structure_flags_comma_mismatch(self):
        bar = "single continuous phrase with zero commas in it"
        anchor = "first phrase, second phrase, third phrase, fourth phrase"
        audit = audit_bar_structure(bar_text=bar, anchor_text=anchor, target_syl=12)
        self.assertFalse(audit["comma_passed"])
        self.assertEqual(audit["comma_count"], 0)
        self.assertEqual(audit["expected_commas"], 3)
        self.assertTrue(any("comma count" in v for v in audit["violations"]))

    def test_format_structure_rewrite_instruction(self):
        audit = {
            "inner_rhyme_count": 0,
            "expected_commas": 3,
            "target_syllables": 18,
            "violations": ["fewer than 2 inner rhymes", "comma count 1 != expected 3"],
        }
        instr = format_structure_rewrite_instruction(
            bar_index=1,
            bar_text="bad line, here",
            audit=audit,
            target_word="mercedes",
            voice="Gunna",
        )
        self.assertIn("Bar 1 structural violation", instr)
        self.assertIn("mercedes", instr)
        self.assertIn("exactly 3 commas", instr)
        self.assertIn("18 ±1", instr)
        self.assertIn("Add at least 2 new internal rhymes", instr)

    def test_rewrite_preserves_anchor_floor_on_cap_breach(self):
        anchor = {
            "text": "on the block, stackin' knots, pushin' weight, in the mercedes",
            "end_word": "mercedes",
            "syllables": 17,
        }
        audit = {
            "inner_rhyme_count": 0,
            "expected_commas": 3,
            "target_syllables": 17,
            "violations": ["fewer than 2 inner rhymes"],
        }
        # Model returns a completely unrelated line that violates cap
        wild_rewrite = "flying in a rocket through the milky way galaxy"
        fake_chat = MagicMock(return_value=wild_rewrite)

        rewritten, passed = rewrite_structurally_failed_bar(
            bar_text="some bad line",
            anchor_dict=anchor,
            target_word="mercedes",
            audit=audit,
            bar_index=1,
            voice="Gunna",
            call_fn=fake_chat,
        )
        # Since rewrite exceeded cap, must revert to anchor text
        self.assertEqual(rewritten, anchor["text"])


if __name__ == "__main__":
    unittest.main()
