"""Unit tests for Task D: End-rhyme pre-plan + post-check in mimic mode.

Verifies:
1. Mimic prompt contains explicit planned end words for each bar.
2. Post-check retry loop fires when the model outputs a non-rhyming end word.
3. Retry resolves when the model delivers valid rhyming end words.
4. Slang phonemes from slang_phonemes.json are accepted as valid rhymes.
5. CMU multi-pronunciations treat ANY pronunciation match as a hit.
6. Retry exhaustion (after 2 retries = 3 attempts) keeps the best candidate and logs misses.
"""

import json
import random
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import phase1_song_metrics as p1
import phase6_generate as p6


class TestMimicRhyme(unittest.TestCase):
    def setUp(self):
        self.lex = p6.get_lexicon()
        self.corpus = p6.Corpus("Gunna", self.lex, songs=[("Example", [
            "I pull up in the foreign car tonight",
            "the diamonds shining in the summer light",
            "we running up the money day and night",
            "she keep the heavy pressure sitting tight",
        ])])
        self.profile = {
            "prompt_facts": ["Measured line length in this era: median 9 syllables."],
            "rhyme": {"dist1_rate": 0.5, "alt_rate": 0.2, "run3_share": 0.2},
            "hard_rhyme": {"min_any_links": 1, "identical_only_ok": False},
            "cadence": {"syl_p10": 5, "syl_p90": 20},
            "adlibs": {"rate": 0.39, "position": {"end": 0.94}},
            "targets": {},
        }
        self.exemplars = [{"song": "Example", "bars": ["I pull up in the coupe (yeah)", "she met me in the room"], "topic": None}]
        self.bank = [
            {"key": "AY T", "words": ["night", "light", "right", "tight", "sight", "fight"],
             "rich_words": ["night", "light", "right", "tight", "sight", "fight"],
             "linked": 5, "uses": 10, "songs": ["Song1"]},
            {"key": "AA R", "words": ["audemar", "car", "star", "far", "bar", "scar"],
             "rich_words": ["audemar", "car", "star", "far", "bar", "scar"],
             "linked": 4, "uses": 8, "songs": ["Song2"]},
        ]

    def test_prompt_contains_explicit_end_words(self):
        rng = random.Random(42)
        plan = p6.make_rhyme_plan(self.bank, 8, rng, self.profile, "rhyme", register=False)
        self.assertEqual(len(plan["slots"]), 8)
        for slot in plan["slots"]:
            self.assertIsNotNone(slot)
            self.assertIn("word", slot)
            self.assertIn("group", slot)

        prompt = p6.build_mimic_prompt("Gunna", 8, self.exemplars, self.profile, 0.7, plan=plan)
        self.assertIn("RHYME PLAN (HARD CONSTRAINT)", prompt)
        self.assertIn("HARD CONSTRAINT: each bar MUST end with its planned end word", prompt)
        for i, slot in enumerate(plan["slots"], 1):
            expected = f'Bar {i} ends with "{slot["word"]}"'
            self.assertIn(expected, prompt)

    def test_retry_fires_on_non_rhyming_end_word_and_resolves(self):
        rng = random.Random(10)
        plan = p6.make_rhyme_plan(self.bank, 4, rng, self.profile, "rhyme", register=False)
        # Ensure slots are planned for 4 bars
        w1 = plan["slots"][0]["word"]
        w2 = plan["slots"][1]["word"]
        w3 = plan["slots"][2]["word"]
        w4 = plan["slots"][3]["word"]

        # Attempt 1 returns non-rhyming end words for couplet 1
        attempt1_json = json.dumps({"bars": [
            {"bar": f"I pull up late inside the heavy {w1}", "meaning": "driving at night"},
            {"bar": "she looking through the open window", "meaning": "looking outside"},  # misses w2, non-rhyming
            {"bar": f"we counting up the paper in the {w3}", "meaning": "counting cash"},
            {"bar": f"I bought a brand new shining {w4}", "meaning": "bought jewelry"},
        ]})

        # Attempt 2 fixes the rhyme by delivering the planned word w2
        attempt2_json = json.dumps({"bars": [
            {"bar": f"I pull up late inside the heavy {w1}", "meaning": "driving at night"},
            {"bar": f"she looking through the flash of yellow {w2}", "meaning": "seeing headlights"},  # fixed!
            {"bar": f"we counting up the paper in the {w3}", "meaning": "counting cash"},
            {"bar": f"I bought a brand new shining {w4}", "meaning": "bought jewelry"},
        ]})

        prompt = p6.build_mimic_prompt("Gunna", 4, self.exemplars, self.profile, 0.7, plan=plan)

        with patch("phase6_generate.call_model") as mock_call:
            mock_call.side_effect = [attempt1_json, attempt2_json]
            res = p6._one_candidate(prompt, "sonnet", 4, self.corpus, self.profile, plan)

            self.assertEqual(mock_call.call_count, 2)
            # Verify the second call's prompt contained the retry amendment listing violations
            call_2_prompt = mock_call.call_args_list[1][0][0]
            self.assertIn("MUST-FIX:", call_2_prompt)
            self.assertIn("lines 1 and 2 were planned to rhyme", call_2_prompt)

            self.assertTrue(res["passed"])
            self.assertEqual(len(res["problems"]), 0)
            self.assertEqual(len(res["bars"]), 4)

    def test_slang_rhymes_accepted_via_slang_phonemes(self):
        # gunna / wunna and audemar / car should be recognized as perfect rhymes
        kind_gunna = p6.check_rhyme_kind("gunna", "wunna", self.lex)
        self.assertEqual(kind_gunna, "perfect")

        kind_opp = p6.check_rhyme_kind("opp", "pop", self.lex)
        self.assertEqual(kind_opp, "perfect")

        kind_aude = p6.check_rhyme_kind("audemar", "car", self.lex)
        self.assertEqual(kind_aude, "perfect")

        # Test in analyze_mimic with a plan
        plan = {
            "groups": [
                {"lines": [0, 1], "words": ["gunna", "wunna"], "family": ["gunna", "wunna"], "key": "AH N AH"},
                {"lines": [2, 3], "words": ["audemar", "car"], "family": ["audemar", "car"], "key": "AA R"},
            ],
            "slots": [
                {"group": 0, "word": "gunna"},
                {"group": 0, "word": "wunna"},
                {"group": 1, "word": "audemar"},
                {"group": 1, "word": "car"},
            ],
        }
        texts = [
            "they know I'm standing with big Gunna",
            "we took the city over, Young Wunna",
            "I checked the time upon my Audemar",
            "and then we sped away inside the car",
        ]
        _rows, problems, _notes = p6.analyze_mimic(texts, self.corpus, self.profile, ["m1", "m2", "m3", "m4"], plan)
        self.assertEqual(problems, [])

    def test_cmu_alternate_pronunciations_treated_as_rhyme(self):
        # 'route' has prons [R UW1 T] and [R AW1 T]
        # It must rhyme with both 'boot' [B UW1 T] and 'doubt' [D AW1 T]
        kind_boot = p6.check_rhyme_kind("route", "boot", self.lex)
        self.assertEqual(kind_boot, "perfect")

        kind_doubt = p6.check_rhyme_kind("route", "doubt", self.lex)
        self.assertEqual(kind_doubt, "perfect")

    def test_retry_exhaustion_keeps_best_candidate(self):
        rng = random.Random(5)
        plan = p6.make_rhyme_plan(self.bank, 4, rng, self.profile, "rhyme", register=False)
        bad_json = json.dumps({"bars": [
            {"bar": "I pull up late inside the foreign window", "meaning": "driving"},
            {"bar": "she looking through the open window", "meaning": "looking"},
            {"bar": "we counting up the paper in the window", "meaning": "counting"},
            {"bar": "I bought a brand new shining window", "meaning": "bought"},
        ]})

        prompt = p6.build_mimic_prompt("Gunna", 4, self.exemplars, self.profile, 0.7, plan=plan)

        with patch("phase6_generate.call_model") as mock_call:
            mock_call.side_effect = [bad_json, bad_json, bad_json]
            res = p6._one_candidate(prompt, "sonnet", 4, self.corpus, self.profile, plan)

            # Max attempts = 3 (1 initial + 2 retries)
            self.assertEqual(mock_call.call_count, p6.MIMIC_ATTEMPTS)
            self.assertFalse(res["passed"])
            # The candidate is still preserved with its bars and problems logged
            self.assertEqual(len(res["bars"]), 4)
            self.assertTrue(len(res["problems"]) > 0)


if __name__ == "__main__":
    unittest.main()
