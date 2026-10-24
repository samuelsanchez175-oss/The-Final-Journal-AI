#!/usr/bin/env python3
"""Unit tests for Frontier V4 Task O: Multi-Pass Frontier Polish Orchestrator."""

import json
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

import frontier_v4
import planner
import polish


class TestFrontierV4(unittest.TestCase):
    def setUp(self):
        self.cmu = polish._get_cmu()
        self.sample_plan = {
            "motif_chain": ["lavishness_money", "romance_women"],
            "couplet_voices": ["Gunna", "Gunna"],
            "end_words": ["audamar", "lobster", "mercedes", "squeeze"],
            "rhyme_families": ["/ɑːr/", "/iːz/"],
            "couplet_narratives": ["penthouse dining", "fast traffic"],
            "voice": "Gunna",
            "blend": "",
            "bpm": 130.0,
            "bars_count": 4,
            "planner_model": "test_planner",
            "plan_valid": True,
        }
        self.sample_retrieved = [
            {"text": "Went and got a Rollie, Audemars", "song": "Top Off", "album": "Drip Season 3", "end_word": "audamar", "id": "1"},
            {"text": "On my plate I got lobster", "song": "Oh Okay", "album": "Drip Season 3", "end_word": "lobster", "id": "2"},
            {"text": "Put a big double M on my Mercedes", "song": "Space Cadet", "album": "Drip Harder", "end_word": "mercedes", "id": "3"},
            {"text": "I heard you paid a dime just to squeeze", "song": "Speed On Em", "album": "Drip Season 3", "end_word": "squeeze", "id": "4"},
        ]

    def test_draft_scaffold_mock(self):
        draft_mock_text = (
            "Penthouse is large, gotta fast car, maximum withdraws, blue audamar\n"
            "She is a stylist, date has been lavish, we caught up and pop shit, over a lobster\n"
            "Penthouse is spacious, lifestyle is gracious, switchin' lanes in traffic, double M Mercedes\n"
            "Drippin' in designer, pull up in a foreign, private jet in Paris, paid a dime to squeeze\n"
        )

        def mock_call(sys_prompt, user_prompt):
            self.assertIn("Pass 1", sys_prompt)
            return draft_mock_text

        lines, model = frontier_v4.draft_scaffold(
            voice="Gunna",
            bpm=130.0,
            bars_count=4,
            effective_syl=20,
            plan=self.sample_plan,
            retrieved_bars=self.sample_retrieved,
            call_fn=mock_call,
        )

        self.assertEqual(len(lines), 4)
        for ln in lines:
            parts = [p.strip() for p in ln.split(",") if p.strip()]
            self.assertEqual(len(parts), 4)

    def test_polish_scaffold_mock(self):
        draft_bars = [
            "Penthouse is large, fast car, maximum withdraws, audamar",
            "She is stylist, date is lavish, we caught up and pop, lobster",
            "Penthouse is spacious, lifestyle gracious, lanes in traffic, Mercedes",
            "Drippin' designer, pull up in foreign, jet in Paris, squeeze",
        ]
        polished_mock_text = (
            "Penthouse is large, gotta fast car, maximum withdraws, blue audamar\n"
            "She is a stylist, date has been lavish, we caught up and pop shit, over a lobster\n"
            "Penthouse is spacious, lifestyle is gracious, switchin' lanes in traffic, double M Mercedes\n"
            "Drippin' in designer, pull up in a foreign, private jet in Paris, paid a dime to squeeze\n"
        )

        def mock_call(sys_prompt, user_prompt):
            self.assertIn("PASS 2", user_prompt)
            return polished_mock_text

        lines, model = frontier_v4.polish_scaffold(
            voice="Gunna",
            bpm=130.0,
            effective_syl=20,
            draft_bars=draft_bars,
            plan=self.sample_plan,
            retrieved_bars=self.sample_retrieved,
            cmu=self.cmu,
            call_fn=mock_call,
        )

        self.assertEqual(len(lines), 4)
        self.assertTrue(lines[0].lower().endswith("audamar"))
        self.assertTrue(lines[1].lower().endswith("lobster"))

    def test_generate_v4_end_to_end_mock(self):
        plan_response = json.dumps(self.sample_plan)
        draft_response = (
            "Penthouse is large, gotta fast car, maximum withdraws, blue audamar\n"
            "She is a stylist, date has been lavish, we caught up and pop shit, over a lobster\n"
            "Penthouse is spacious, lifestyle is gracious, switchin' lanes in traffic, double M Mercedes\n"
            "Drippin' in designer, pull up in a foreign, private jet in Paris, paid a dime to squeeze\n"
        )
        polish_response = draft_response

        def mock_call(sys_prompt, user_prompt):
            if "Architectural Plan" in sys_prompt or "Frontier V4 Reasoning Backbone" in sys_prompt:
                return plan_response
            elif "Pass 1" in sys_prompt:
                return draft_response
            else:
                return polish_response

        res = frontier_v4.generate_v4(
            voice="Gunna",
            bars_count=4,
            bpm=130.0,
            target_syl=20,
            call_fn=mock_call,
        )

        self.assertTrue(res["ok"])
        self.assertEqual(res["version"], "v4")
        self.assertIn("plan", res)
        self.assertEqual(len(res["draft_bars"]), 4)
        self.assertEqual(len(res["polished_bars"]), 4)
        self.assertIn("grid_gate", res)
        self.assertTrue(res["grid_gate"]["passed"])
        self.assertEqual(res["grid_pass_rate"], 1.0)
        self.assertIn("style_score", res)
        self.assertGreater(res["style_score"], 0.0)

        # Verify bar details
        for b in res["bars"]:
            self.assertEqual(len(b["beat_groups"]), 4)
            self.assertTrue(b["grid_passed"])

    def test_generate_v4_candidates_ranking(self):
        call_counter = [0]

        def mock_call(sys_prompt, user_prompt):
            call_counter[0] += 1
            if "Frontier V4 Reasoning Backbone" in sys_prompt:
                return json.dumps(self.sample_plan)
            # Alternate responses
            return (
                "Penthouse is large, gotta fast car, maximum withdraws, blue audamar\n"
                "She is a stylist, date has been lavish, we caught up and pop shit, over a lobster\n"
                "Penthouse is spacious, lifestyle is gracious, switchin' lanes in traffic, double M Mercedes\n"
                "Drippin' in designer, pull up in a foreign, private jet in Paris, paid a dime to squeeze\n"
            )

        res = frontier_v4.generate_v4(
            voice="Gunna",
            bars_count=4,
            candidates=2,
            call_fn=mock_call,
        )

        self.assertEqual(res["candidates_count"], 2)
        self.assertEqual(len(res["candidates"]), 2)
        # Winner must be candidate with highest score
        self.assertEqual(res["candidates"][0]["candidate_index"], 1)


if __name__ == "__main__":
    unittest.main()
