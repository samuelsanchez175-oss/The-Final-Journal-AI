#!/usr/bin/env python3
"""Fast unit checks for people + rhyme. No CSV."""

from __future__ import annotations

import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

from people import people_phrase, resolve_people
from craft import inner_rhyme_score, syllable_count
from harness import evaluate, is_last_word_swap
from retrieve import opening_tokens, prefix_overlap
from rhyme import classify_rhyme, end_word, load_cmudict, morph_kind, signature_for
from stress import compare as stress_compare
from stress import profile as stress_profile


CMU = Path(__file__).resolve().parents[2] / "XJournal AI" / "cmudict.txt"


class PeopleTests(unittest.TestCase):
    def test_solo_gunna(self):
        self.assertEqual(people_phrase("Gunna"), "01 Gunna")

    def test_collab_is_two_people(self):
        phrase = people_phrase("Young Thug & Gunna")
        self.assertIn("01 Gunna", phrase)
        self.assertIn("02 Young Thug", phrase)
        self.assertEqual(phrase, "01 Gunna and 02 Young Thug")

    def test_order_does_not_mint_a_third_artist(self):
        a = people_phrase("Young Thug & Gunna")
        b = people_phrase("Gunna & Young Thug")
        self.assertEqual(a, b)

    def test_ysl_three(self):
        phrase = people_phrase("Young Stoner Life, Young Thug & Gunna")
        self.assertEqual(
            phrase,
            "01 Gunna and 02 Young Thug and 04 Young Stoner Life",
        )
        ids = [p["id"] for p in resolve_people("Young Stoner Life, Young Thug & Gunna")]
        self.assertNotIn("Young Thug & Gunna", ids)


class RhymeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.cmu = load_cmudict(CMU)
        if len(cls.cmu) < 1000:
            raise unittest.SkipTest(f"cmudict missing or tiny: {CMU}")

    def test_stage_today_slant(self):
        self.assertEqual(classify_rhyme("stage", "today", self.cmu), "slant")

    def test_stage_stage_perfect(self):
        self.assertEqual(classify_rhyme("stage", "stage", self.cmu), "perfect")

    def test_stage_sage_perfect_rime(self):
        self.assertEqual(classify_rhyme("stage", "sage", self.cmu), "perfect")

    def test_loose_same_vowel_is_not_a_hit(self):
        self.assertIsNone(classify_rhyme("stage", "pavement", self.cmu))
        self.assertIsNone(classify_rhyme("stage", "location", self.cmu))

    def test_today_day_is_perfect_morph(self):
        self.assertEqual(morph_kind("today", "day"), "perfect")
        self.assertEqual(classify_rhyme("today", "day", self.cmu), "perfect")

    def test_payday_today_is_slant_morph(self):
        self.assertEqual(morph_kind("today", "payday"), "slant")
        self.assertEqual(classify_rhyme("today", "payday", self.cmu), "slant")

    def test_signatures_exist(self):
        self.assertIsNotNone(signature_for("stage", self.cmu))
        self.assertIsNotNone(signature_for("today", self.cmu))

    def test_replace_keeps_the_started_opening(self):
        host = opening_tokens("I drip on my dawg's stage")
        self.assertGreaterEqual(
            prefix_overlap(host, opening_tokens("I drip on my new wave")),
            4,
        )
        self.assertGreaterEqual(
            prefix_overlap(host, opening_tokens("I'm sharp like a bald fade")),
            1,
        )
        self.assertEqual(
            prefix_overlap(host, opening_tokens("All the baddies to the stage")),
            0,
        )

    def test_end_word_strips_parenthetical_adlib(self):
        line = "I'm a hustler, I whip it out a bowl (Whip, whip, whip, whip)"
        self.assertEqual(end_word(line), "bowl")


class StressTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.cmu = load_cmudict(CMU)
        if len(cls.cmu) < 1000:
            raise unittest.SkipTest(f"cmudict missing or tiny: {CMU}")

    def test_today_host_punches_die_and_today(self):
        p = stress_profile("Somebody gon' die today", self.cmu, "today")
        self.assertIn("die", p.words)
        self.assertIn("today", p.words)
        self.assertTrue(p.end_stressed)
        self.assertEqual(p.last[-1], "today")

    def test_inner_rhyme_scores_parallel_punches(self):
        n = inner_rhyme_score("I'm dodging the rain and I'm dodging the hate", self.cmu)
        self.assertGreaterEqual(n, 2)

    def test_wrap_count_uses_cmu(self):
        n = syllable_count("I whip the coupe out the lot", self.cmu)
        self.assertGreaterEqual(n, 6)
        self.assertLessEqual(n, 9)

    def test_harness_kills_last_word_swap(self):
        host = "I drip on my dawg's stage"
        self.assertTrue(is_last_word_swap(host, "I drip on my dawg's parade"))
        ok, reasons = evaluate(host, "I drip on my dawg's parade", "replace", self.cmu, 7)
        self.assertFalse(ok)
        self.assertIn("last-word swap", reasons)

    def test_harness_kills_frankenstein(self):
        ok, reasons = evaluate(
            "I whip the coupe out the lot",
            "I whip sip a lot",
            "replace",
            self.cmu,
            8,
            sources=["I whip the coupe out the lot", "I chug sip a lot"],
        )
        self.assertFalse(ok)
        self.assertIn("frankenstein", reasons)

    def test_harness_kills_malformed_graft(self):
        ok, reasons = evaluate(
            "I whip the coupe out the lot",
            "I whip the a lot",
            "replace",
            self.cmu,
            8,
        )
        self.assertFalse(ok)

    def test_harness_kills_titles(self):
        ok, reasons = evaluate(
            "I drip on my dawg's stage",
            "20. Michael Jackson - When I Come Of Age",
            "next",
            self.cmu,
            7,
        )
        self.assertFalse(ok)

    def test_marvellous_day_scores_against_today_host(self):
        host = stress_profile("Somebody gon' die today", self.cmu, "today")
        cand = stress_profile("I'm havin' a marvellous day", self.cmu, "day")
        score, note = stress_compare(host, cand)
        self.assertGreaterEqual(score, 2)
        self.assertIn("punch on landing", note)


if __name__ == "__main__":
    unittest.main()
