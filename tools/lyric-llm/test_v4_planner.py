#!/usr/bin/env python3
"""Unit tests for Frontier V4 Task J: Reasoning-Model Planner Stage."""

import json
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

# Add tools/lyric-llm to sys.path
HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

import planner
import polish


class TestV4Planner(unittest.TestCase):
    def test_plan_v4_mock_model(self):
        valid_mock_json = {
            "motif_chain": ["lavishness_money", "romance_women", "street_defiance", "boss_authority"],
            "couplet_voices": ["Gunna", "Gunna", "Gunna", "Gunna"],
            "end_words": ["audamar", "car", "mercedes", "crazy", "maybach", "payback", "toronto", "pronto"],
            "rhyme_families": ["/ɑːr/", "/eɪzi/", "/eɪbæk/", "/ɒntoʊ/"],
            "couplet_narratives": [
                "Penthouse luxury and dining",
                "High speed traffic and lavish living",
                "Executive vengeance and street payback",
                "International private jet movements",
            ],
        }

        def mock_call(sys_prompt, user_prompt):
            self.assertIn("Gunna", user_prompt)
            return json.dumps(valid_mock_json)

        plan = planner.plan_v4(
            voice="Gunna",
            bpm=130.0,
            bars=8,
            topic_hint="luxury lifestyle",
            call_fn=mock_call,
        )

        self.assertTrue(plan["plan_valid"])
        self.assertEqual(len(plan["end_words"]), 8)
        self.assertEqual(len(plan["couplet_voices"]), 4)
        self.assertEqual(len(plan["motif_chain"]), 4)
        self.assertEqual(plan["end_words"][0], "audamar")
        self.assertEqual(plan["end_words"][1], "car")

    def test_plan_v4_oov_and_generic_blacklist_substitution(self):
        # Plan contains "real" and "cake" (in GENERIC_END_RHYME_BLACKLIST) and "randomgibberish123" (OOV)
        bad_words_mock_json = {
            "motif_chain": ["lavishness_money", "romance_women"],
            "couplet_voices": ["Gunna", "Gunna"],
            "end_words": ["real", "cake", "randomgibberish123", "audamar"],
            "rhyme_families": ["nursery", "custom"],
            "couplet_narratives": ["desc 1", "desc 2"],
        }

        def mock_call(sys_prompt, user_prompt):
            return json.dumps(bad_words_mock_json)

        plan = planner.plan_v4(
            voice="Gunna",
            bpm=130.0,
            bars=4,
            call_fn=mock_call,
        )

        self.assertTrue(plan["plan_valid"])
        # "real" and "cake" must be replaced with authentic catalog words
        self.assertNotIn("real", plan["end_words"])
        self.assertNotIn("cake", plan["end_words"])
        self.assertNotIn("randomgibberish123", plan["end_words"])
        self.assertEqual(plan["end_words"][3], "audamar")

    def test_plan_v4_fallback_on_error(self):
        def broken_call(sys_prompt, user_prompt):
            raise RuntimeError("OmniRoute 503 Service Unavailable")

        plan = planner.plan_v4(
            voice="Gunna",
            bpm=130.0,
            bars=8,
            call_fn=broken_call,
        )

        self.assertTrue(plan["plan_valid"])
        self.assertEqual(plan["planner_model"], "heuristic_fallback")
        self.assertEqual(len(plan["end_words"]), 8)
        self.assertEqual(len(plan["couplet_voices"]), 4)

    def test_generate_frontier_bars_v2_with_plan(self):
        custom_plan = {
            "motif_chain": ["lavishness_money", "boss_authority"],
            "couplet_voices": ["Gunna", "NoCap"],
            "end_words": ["audamar", "lobster", "maybach", "payback"],
            "rhyme_families": ["/ɑːr/", "/eɪbæk/"],
            "couplet_narratives": ["Gunna penthouse flex", "NoCap street wordplay"],
            "voice": "Gunna",
            "blend": "NoCap",
            "bpm": 130.0,
            "bars_count": 4,
            "planner_model": "test_planner",
            "plan_valid": True,
        }

        fake_resp = {
            "choices": [{
                "message": {
                    "content": (
                        "Penthouse is large, gotta fast car, maximum withdraws, blue audamar\n"
                        "She is a stylist, date has been lavish, we caught up and pop shit, over a lobster\n"
                        "Bought me a Maybach, plannin' the payback, runnin' through static, Patek automatic\n"
                        "Keepin' the steel, never will heal, scars in the ditch, waitin' for the payback\n"
                    )
                }
            }]
        }

        def fake_urlopen(req, timeout=30):
            mock_resp = MagicMock()
            mock_resp.read.return_value = json.dumps(fake_resp).encode("utf-8")
            mock_resp.__enter__.return_value = mock_resp
            mock_resp.__exit__.return_value = False
            return mock_resp

        with patch("urllib.request.urlopen", side_effect=fake_urlopen):
            res = polish.generate_frontier_bars_v2(
                voice="Gunna",
                blend="NoCap",
                bars_count=4,
                plan=custom_plan,
            )

        self.assertTrue(res["ok"])
        self.assertIn("plan", res)
        self.assertEqual(res["plan"]["planner_model"], "test_planner")
        self.assertEqual(res["plan"]["end_words"], ["audamar", "lobster", "maybach", "payback"])
        self.assertEqual(res["blend_allocation"], ["Gunna", "Gunna", "NoCap", "NoCap"])


if __name__ == "__main__":
    unittest.main()
