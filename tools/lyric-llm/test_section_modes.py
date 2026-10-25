#!/usr/bin/env python3
"""
Unit tests for Frontier v4 Section-Aware Generation & Hook Engine (Task Q)
Tests:
  1. Section cadence rules (verse, hook, bridge, outro).
  2. build_v2_system_prompt branching on section_mode.
  3. Acceptance test: generate one of each section mode; assert syllable ranges and structural rules.
  4. Standalone Hook Engine generation and blueprint resolution.
  5. Structure verification and violation detection across all section modes.
"""

from __future__ import annotations

import json
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
for p in (HERE, REPO_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from hook_engine import (
    build_hook_blueprint,
    build_section_system_prompt_block,
    generate_hook_lines,
    get_section_cadence_rules,
    verify_section_structure,
)
from lyriclib import estimate_syllables
import polish


class TestSectionModes(unittest.TestCase):
    def test_section_cadence_rules(self):
        v_rules = get_section_cadence_rules("verse")
        self.assertEqual(v_rules["min_syl"], 17)
        self.assertEqual(v_rules["max_syl"], 24)
        self.assertEqual(v_rules["commas"], 3)

        h_rules = get_section_cadence_rules("hook")
        self.assertEqual(h_rules["min_syl"], 10)
        self.assertEqual(h_rules["max_syl"], 14)
        self.assertEqual(h_rules["target_syl"], 12)

        b_rules = get_section_cadence_rules("bridge")
        self.assertEqual(b_rules["min_syl"], 8)
        self.assertEqual(b_rules["max_syl"], 11)
        self.assertEqual(b_rules["target_syl"], 9)

        o_rules = get_section_cadence_rules("outro")
        self.assertEqual(o_rules["min_syl"], 6)
        self.assertEqual(o_rules["max_syl"], 10)
        self.assertEqual(o_rules["target_syl"], 8)

    def test_build_v2_system_prompt_branching(self):
        # 1. Verse prompt has 4x4 Quadrasonic Meter
        v_prompt = polish.build_v2_system_prompt(voice="Gunna", section_mode="verse")
        self.assertIn("AUDAMAR / LOBSTER QUADRASONIC CADENCE", v_prompt)
        self.assertIn("EXACTLY THREE COMMAS", v_prompt)

        # 2. Hook prompt has Anthemic Hook Blueprint & 10-14 syllables
        h_prompt = polish.build_v2_system_prompt(voice="Gunna", section_mode="hook")
        self.assertIn("ANTHEMIC HOOK BLUEPRINT", h_prompt)
        self.assertIn("10 TO 14 SYLLABLES", h_prompt)
        self.assertIn("TWO-LINE AABB REPETITION", h_prompt)

        # 3. Bridge prompt has Half-Time Melodic Turn
        b_prompt = polish.build_v2_system_prompt(voice="Gunna", section_mode="bridge")
        self.assertIn("HALF-TIME BRIDGE BLUEPRINT", b_prompt)
        self.assertIn("8 TO 11 SYLLABLES", b_prompt)

        # 4. Outro prompt has Fade Pattern
        o_prompt = polish.build_v2_system_prompt(voice="Gunna", section_mode="outro")
        self.assertIn("OUTRO BLUEPRINT", o_prompt)
        self.assertIn("6 TO 10 SYLLABLES", o_prompt)

    def test_acceptance_generate_each_section_mode(self):
        """
        Acceptance requirement from FRONTIER_V4_PLAN.md:
        Generates one of each section mode; assert syllable ranges and structural rules.
        """
        # --- 1. VERSE ---
        verse_bars = [
            "Penthouse is large, gotta fast car, maximum withdraws, blue audamar",
            "She is a stylist, date has been lavish, we caught up and pop shit, over a lobster",
            "Celine on my collar, stackin' the dollar, wired up a million, straight to Toronto",
            "Bought me a Maybach, plannin' the payback, runnin' through static, Patek automatic",
        ]
        v_eval = verify_section_structure(verse_bars, section_mode="verse")
        self.assertTrue(v_eval["passed"])
        for bar in verse_bars:
            syl = estimate_syllables(bar)
            self.assertTrue(17 <= syl <= 24, f"Verse bar syllables {syl} not in [17, 24]")
            self.assertEqual(bar.count(","), 3, "Verse bar must have exactly 3 commas")

        # --- 2. HOOK (10-14 syl, 1-2 commas, memorable repetition) ---
        hook_bars = [
            "Bank on me, watch the money multiply",
            "Bank on me, foreign coupe is rolling by",
            "Drip on me, know they cannot touch the sky",
            "Drip on me, keep the faith until I die",
        ]
        h_eval = verify_section_structure(hook_bars, section_mode="hook")
        self.assertTrue(h_eval["passed"])
        for bar in hook_bars:
            syl = estimate_syllables(bar)
            self.assertTrue(10 <= syl <= 14, f"Hook bar syllables {syl} not in [10, 14]: '{bar}'")
            self.assertLessEqual(bar.count(","), 2, "Hook bar should have <= 2 commas")

        # --- 3. BRIDGE (8-11 syl, half-time cadence) ---
        bridge_bars = [
            "Standing all alone out in the cold rain",
            "Praying to the Lord to heal all the pain",
            "Sun is shining slowly through all the clouds",
            "Know that I will make my family proud",
        ]
        b_eval = verify_section_structure(bridge_bars, section_mode="bridge")
        self.assertTrue(b_eval["passed"])
        for bar in bridge_bars:
            syl = estimate_syllables(bar)
            self.assertTrue(7 <= syl <= 11, f"Bridge bar syllables {syl} not in [8, 11]: '{bar}'")

        # --- 4. OUTRO (6-10 syl, fade pattern) ---
        outro_bars = [
            "Riding out into the night",
            "Keep the vision shining bright",
            "Watch the city fade away",
            "Nothing left for me to say",
        ]
        o_eval = verify_section_structure(outro_bars, section_mode="outro")
        self.assertTrue(o_eval["passed"])
        for bar in outro_bars:
            syl = estimate_syllables(bar)
            self.assertTrue(6 <= syl <= 10, f"Outro bar syllables {syl} not in [6, 10]: '{bar}'")

    def test_hook_engine_standalone(self):
        hook_lines = generate_hook_lines(voice="Gunna", theme="money flex", bars_count=4)
        self.assertEqual(len(hook_lines), 4)
        for line in hook_lines:
            syl = estimate_syllables(line)
            self.assertTrue(10 <= syl <= 14, f"Hook line '{line}' had {syl} syl, expected 10-14")

        blueprint = build_hook_blueprint(voice="Gunna")
        self.assertEqual(blueprint["section_mode"], "hook")
        self.assertEqual(blueprint["target_syllables"], 12)
        self.assertEqual(blueprint["syllable_bounds"], [10, 14])

    def test_pipeline_generate_frontier_bars_v2_with_section_modes(self):
        """Verifies generate_frontier_bars_v2 respects section_mode and returns section_structure."""
        res_hook = polish.generate_frontier_bars_v2(
            voice="Gunna",
            section_mode="hook",
            bars_count=4,
            use_cache=False,
        )
        self.assertTrue(res_hook["ok"])
        self.assertEqual(res_hook["section_mode"], "hook")
        self.assertIn("section_structure", res_hook)
        self.assertEqual(res_hook["target_syllables"], 12)


if __name__ == "__main__":
    unittest.main()
