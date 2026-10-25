"""Unit tests for Move 6: Inner-Rhyme, Comma, and Syllable Structural Check (Phase 6)."""

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
    def test_audit_bar_structure_passes_compliant_bar(self):
        # "large/car" has matching vowel class; 3 commas; ~16-17 syl
        bar = "penthouse is large, gotta fast car, maximum withdraws, blue audamar"
        anchor = "penthouse is large, gotta fast car, maximum withdraws, blue audamar"
        audit = audit_bar_structure(bar_text=bar, anchor_text=anchor, target_syl=17)
        self.assertTrue(audit["passed"])
        self.assertGreaterEqual(audit["inner_rhyme_count"], 1)
        self.assertTrue(audit["comma_passed"])
        self.assertTrue(audit["syl_passed"])
        self.assertEqual(len(audit["violations"]), 0)

    def test_audit_bar_structure_flags_fewer_inner_rhymes(self):
        # Bar with very few / no internal assonance
        bar = "the boy went down the long dirt path"
        anchor = "the boy went down, the long dirt path, and stopped right there, to take a bath"
        audit = audit_bar_structure(bar_text=bar, anchor_text=anchor, target_syl=16)
        self.assertFalse(audit["passed"])
        self.assertTrue(any("inner rhymes" in v for v in audit["violations"]))

    def test_audit_bar_structure_flags_comma_mismatch(self):
        bar = "single continuous phrase with zero commas in it"
        anchor = "first phrase, second phrase, third phrase, fourth phrase"
        audit = audit_bar_structure(bar_text=bar, anchor_text=anchor, target_syl=12)
        self.assertFalse(audit["comma_passed"])
        self.assertEqual(audit["comma_count"], 0)
        self.assertEqual(audit["expected_commas"], 3)
        self.assertTrue(any("comma count" in v for v in audit["violations"]))

    def test_audit_bar_structure_flags_syllable_deviation(self):
        # Target 20 syllables, but bar is only 6 syllables
        bar = "short line, right now, just few, words"
        audit = audit_bar_structure(bar_text=bar, anchor_text="", target_syl=20)
        self.assertFalse(audit["syl_passed"])
        self.assertGreater(audit["syl_delta"], 1)
        self.assertTrue(any("syllable count" in v for v in audit["violations"]))

    def test_inner_rhymes_capped_at_four(self):
        # Excessive rhymes: large, car, star, far, bar, scar, jar
        bar = "large car, star far, bar scar, jar"
        audit = audit_bar_structure(bar_text=bar, anchor_text="", target_syl=10)
        # Should be capped at 4 to prevent runaway tongue-twisters
        self.assertLessEqual(audit["inner_rhyme_count"], 4)

    def test_system_prompt_contains_move6_mandates(self):
        prompt = build_v2_system_prompt(voice="Gunna", bars_count=8)
        self.assertIn("MOVE 6 INNER-RHYME & STRUCTURAL MANDATES", prompt)
        self.assertIn("Every single bar MUST contain at least 2 distinct inner rhymes", prompt)
        self.assertIn("Cap at 4 inner rhymes", prompt)

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

    @patch("prompt_cache.get_cached_verse", return_value=None)
    @patch("polish.chat")
    @patch("catalog_retriever.retrieve_matching_catalog_lines")
    def test_pipeline_populates_move6_metrics(self, mock_retrieve, mock_chat, mock_cache):
        anchor_line = "on the block, stackin' knots, pushin' weight, in the mercedes"
        mock_retrieve.return_value = [
            {
                "id": f"line_{i}",
                "text": anchor_line,
                "end_word": "mercedes",
                "syllables": 17,
                "album": "Drip Harder",
                "song": "Never Recover",
                "line_seq": i,
                "total_lines": 32,
            }
            for i in range(8)
        ]

        # Model returns 8 bars of light edits with internal rhymes
        mock_chat.return_value = "\n".join([anchor_line] * 8)

        res = generate_frontier_bars_v2(
            voice="Gunna",
            bars_count=8,
            topic_hint="studio grind",
            generation_id="test_move6_metrics",
        )

        self.assertIn("mean_inner_rhymes", res)
        self.assertIn("comma_match_rate", res)
        self.assertIn("syl_tolerance_rate", res)
        self.assertIn("structure_pass_rate", res)

        for bar in res["bars"]:
            self.assertIn("inner_rhyme_count", bar)
            self.assertIn("comma_count", bar)
            self.assertIn("expected_commas", bar)
            self.assertIn("syl_delta", bar)
            self.assertIn("structure_passed", bar)


if __name__ == "__main__":
    unittest.main()
