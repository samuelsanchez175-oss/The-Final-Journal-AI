#!/usr/bin/env python3
"""
Unit tests for Frontier v4 Dynamic Edit-Distance Cap (Task R)
Tests:
  1. Per-bar dynamic cap derivation (anthem -> 0.15, couplet -> 0.20, standard -> 0.30).
  2. Acceptance test: Anthem lines can only be lightly edited (<=15%); throwaway lines get 30%.
  3. Base cap CLI override (--base-cap).
  4. Slang and CMU phonetic preservation for OOV end-words (audamar/audemars, trappin/trapping).
  5. Pipeline integration in generate_frontier_bars_v2 and generate_v4 reporting edit_distance_cap.
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

from catalog_retriever import (
    calculate_edit_distance_ratio,
    get_dynamic_cap,
    is_end_word_preserved,
    load_cmudict,
    verify_remix_compliance,
)
import polish

CMU_PATH = REPO_ROOT / "XJournal AI" / "cmudict.txt"


class TestDynamicEditDistanceCap(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.cmu = load_cmudict(CMU_PATH)

    def test_dynamic_cap_derivation(self):
        # 1. Iconic Anthem gets 15% cap
        anthem_bar = {"is_iconic_anthem": 1, "is_consecutive_couplet": 0}
        self.assertEqual(get_dynamic_cap(anthem_bar), 0.15)

        # 2. Consecutive Couplet gets 20% cap
        couplet_bar = {"is_iconic_anthem": 0, "is_consecutive_couplet": 1}
        self.assertEqual(get_dynamic_cap(couplet_bar), 0.20)

        # 3. Standard / Throwaway gets 30% cap
        standard_bar = {"is_iconic_anthem": 0, "is_consecutive_couplet": 0}
        self.assertEqual(get_dynamic_cap(standard_bar), 0.30)

        # 4. None / missing metadata falls back to base_cap
        self.assertEqual(get_dynamic_cap(None), 0.30)

    def test_base_cap_override(self):
        standard_bar = {"is_iconic_anthem": 0, "is_consecutive_couplet": 0}
        # Override to 0.22
        self.assertEqual(get_dynamic_cap(standard_bar, base_cap=0.22), 0.22)

        anthem_bar = {"is_iconic_anthem": 1}
        # Anthem cap cannot exceed 0.15
        self.assertEqual(get_dynamic_cap(anthem_bar, base_cap=0.22), 0.15)

        couplet_bar = {"is_consecutive_couplet": 1}
        # Couplet cap cannot exceed 0.20
        self.assertEqual(get_dynamic_cap(couplet_bar, base_cap=0.22), 0.20)

    def test_acceptance_anthem_vs_throwaway(self):
        """
        Acceptance requirement from FRONTIER_V4_PLAN.md:
        Anthem line can only be lightly edited; throwaway line gets 30%.
        """
        orig_text = "Bentley coupe is fast, gotta make it last, maximum withdraws, blue audamar"

        # Case 1: Light edit (1 word changed out of 11 -> ~9% edit ratio)
        light_edit = "Bentley coupe is clean, gotta make it last, maximum withdraws, blue audamar"
        light_ratio = calculate_edit_distance_ratio(orig_text, light_edit)
        self.assertLessEqual(light_ratio, 0.15)

        # Under Anthem Cap (0.15): Light edit PASSES
        res_anthem_light = verify_remix_compliance(orig_text, light_edit, cap=0.15, cmu=self.cmu)
        self.assertTrue(res_anthem_light["is_compliant"])
        self.assertEqual(res_anthem_light["cap"], 0.15)

        # Case 2: Moderate edit (2 words changed out of 12 -> ~16.7% edit ratio)
        moderate_edit = "Bentley truck is fast, gotta make it count, maximum withdraws, blue audamar"
        mod_ratio = calculate_edit_distance_ratio(orig_text, moderate_edit)
        self.assertGreater(mod_ratio, 0.15)
        self.assertLessEqual(mod_ratio, 0.30)

        # Under Anthem Cap (0.15): Moderate edit FAILS
        res_anthem_mod = verify_remix_compliance(orig_text, moderate_edit, cap=0.15, cmu=self.cmu)
        self.assertFalse(res_anthem_mod["is_compliant"])

        # Under Throwaway / Standard Cap (0.30): Moderate edit PASSES
        res_throwaway_mod = verify_remix_compliance(orig_text, moderate_edit, cap=0.30, cmu=self.cmu)
        self.assertTrue(res_throwaway_mod["is_compliant"])
        self.assertEqual(res_throwaway_mod["cap"], 0.30)

        # Case 3: Excessive edit (5 words changed out of 12 -> ~41.7% edit ratio)
        heavy_edit = "Patek wrist is cold, story never told, maximum withdraws, blue audamar"
        res_throwaway_heavy = verify_remix_compliance(orig_text, heavy_edit, cap=0.30, cmu=self.cmu)
        self.assertFalse(res_throwaway_heavy["is_compliant"])

    def test_slang_and_cmu_phonetic_preservation(self):
        # 1. Exact match
        self.assertTrue(is_end_word_preserved("shark", "shark", cmu=self.cmu))

        # 2. Colloquial slang suffix (trappin' vs trapping)
        self.assertTrue(is_end_word_preserved("trappin'", "trapping", cmu=self.cmu))
        self.assertTrue(is_end_word_preserved("sippin", "sipping", cmu=self.cmu))

        # 3. Slang phonetic equivalence (audamar vs audemars via RAP_SLANG_CMU)
        self.assertTrue(is_end_word_preserved("audamar", "audemars", cmu=self.cmu))
        self.assertTrue(is_end_word_preserved("audemars", "audamar", cmu=self.cmu))

        # 4. Mismatch
        self.assertFalse(is_end_word_preserved("audamar", "patek", cmu=self.cmu))

    def test_pipeline_dynamic_cap_metadata(self):
        """Verifies that generate_frontier_bars_v2 exposes edit_distance_cap in detailed bars."""
        fake_bars = [
            "Bentley coupe is clean, gotta make it last, maximum withdraws, blue audamar",
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

        with patch("urllib.request.urlopen") as mock_urlopen:
            mock_resp = MagicMock()
            mock_resp.read.return_value = json.dumps(fake_resp).encode("utf-8")
            mock_resp.__enter__.return_value = mock_resp
            mock_resp.__exit__.return_value = False
            mock_urlopen.return_value = mock_resp

            res = polish.generate_frontier_bars_v2(
                voice="Gunna",
                bars_count=4,
                base_cap=0.28,
                use_cache=False,
            )

        self.assertTrue(res["ok"])
        self.assertEqual(res["base_cap"], 0.28)
        self.assertEqual(len(res["bars"]), 4)

        for bar in res["bars"]:
            self.assertIn("edit_distance_cap", bar)
            self.assertIn("edit_distance_ratio", bar)
            self.assertIn("remix_compliant", bar)
            self.assertIn("end_word_preserved", bar)
            # Cap should be <= base_cap (0.28)
            self.assertLessEqual(bar["edit_distance_cap"], 0.28)


if __name__ == "__main__":
    unittest.main()
