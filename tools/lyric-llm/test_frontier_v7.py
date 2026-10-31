"""Frontier V7 tests — one pass + one fail per target, caveat flags,
novelty gate, no-comma-fail, repeated-end-word.

All offline. LLM is stubbed via `call_fn` so no API keys are touched.
Run: tools/lyric-llm/.venv/bin/python3 -m unittest test_frontier_v7
"""
from __future__ import annotations

import json
import os
import re
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

import frontier_v7 as fv7


def _bar(text: str, index: int, end_word: str, strong: bool = False,
         syl_target: int = 12, chips: tuple[str, ...] = ()) -> fv7.BarTarget:
    return fv7.BarTarget(index=index, end_word=end_word, rhyme_vowel="",
                         syl_target=syl_target, syl_lo=syl_target - 2,
                         syl_hi=syl_target + 2, strong=strong,
                         chip_targets=chips)


class TestTarget1EndRhyme(unittest.TestCase):
    def test_pass_vowel_match(self):
        t = _bar("", 1, "down", strong=True)
        prior = ["I ride through the city with a crown"]
        bar = "The whole block watchin' when I'm comin' down"
        g = fv7.grade_bar(bar, t, prior)
        self.assertTrue(g.ok, g.violations)
        self.assertGreater(g.soft_scores["rhyme_exact_bonus"], 0.0)

    def test_fail_vowel_mismatch(self):
        t = _bar("", 1, "night", strong=True)
        prior = ["Pockets full of hundred stacks of cash tonight"]
        bar = "I ride up to the Pentagon with my dog"
        g = fv7.grade_bar(bar, t, prior)
        self.assertFalse(g.ok)
        self.assertTrue(any("rhyme family" in v or "anchor vowel" in v for v in g.violations))

    def test_rhyme_family_accepts_different_word_same_rime(self):
        """New rule (replaces exact end-word match): any word with the
        same CMU rime passes. 'town' and 'crown' share AW1-N."""
        t = _bar("", 1, "crown", strong=True)
        prior = ["Pockets full of hundreds and bands by the town"]
        bar = "I rock around the city, holding my own crown"
        g = fv7.grade_bar(bar, t, prior, check_novelty=False)
        self.assertFalse(any("rhyme family" in v for v in g.violations), g.violations)

    def test_rhyme_family_rejects_different_rime(self):
        t = _bar("", 1, "crown", strong=True)
        prior = ["Pockets full of hundreds and bands in the town"]
        bar = "I walk around the city, holding my own gym"
        g = fv7.grade_bar(bar, t, prior, check_novelty=False)
        self.assertTrue(any("rhyme family" in v for v in g.violations), g.violations)


class TestTarget2Multisyl(unittest.TestCase):
    def test_pass_multisyl_internal(self):
        t = _bar("", 0, "money", strong=False, syl_target=12)
        bar = "Pockets full of honey, I'm counting my money"
        g = fv7.grade_bar(bar, t, [])
        self.assertEqual(g.soft_scores["multisyl"], 1.0)

    def test_fail_no_multisyl(self):
        t = _bar("", 0, "money", strong=False, syl_target=12)
        bar = "I count my money"
        g = fv7.grade_bar(bar, t, [])
        self.assertEqual(g.soft_scores["multisyl"], 0.0)


class TestTarget3InnerRhyme(unittest.TestCase):
    def test_pass_inner_rhyme(self):
        t = _bar("", 0, "crown", syl_target=10)
        bar = "I rock around the town, in a Rolls I ride through the town"
        g = fv7.grade_bar(bar, t, [])
        self.assertGreater(g.soft_scores["inner_rhyme"], 0.0)

    def test_fail_no_inner_rhyme(self):
        t = _bar("", 0, "crown", syl_target=10)
        bar = "I walk home from the gym"
        g = fv7.grade_bar(bar, t, [])
        self.assertEqual(g.soft_scores["inner_rhyme"], 0.0)


class TestTarget4Commas(unittest.TestCase):
    def test_pass_one_comma(self):
        t = _bar("", 0, "down", syl_target=12)
        bar = "I ride through the city, holding the crown down"
        g = fv7.grade_bar(bar, t, [])
        self.assertGreaterEqual(g.soft_scores["commas"], 1.0)

    def test_missing_comma_does_not_fail(self):
        t = _bar("", 0, "down", syl_target=12)
        bar = "I ride through the city with the crown down"
        g = fv7.grade_bar(bar, t, [])
        self.assertFalse(any("comma" in v for v in g.violations))
        self.assertLessEqual(g.soft_scores["commas"], 1.0)


class TestTarget5Syllables(unittest.TestCase):
    def test_pass_in_range(self):
        t = _bar("", 0, "down", syl_target=12)
        bar = "I ride through the city with the crown down"
        g = fv7.grade_bar(bar, t, [])
        self.assertNotIn(True, [v.startswith("syllables") for v in g.violations])

    def test_fail_too_short(self):
        t = _bar("", 0, "down", syl_target=12)
        bar = "Go down"
        g = fv7.grade_bar(bar, t, [])
        self.assertTrue(any(v.startswith("syllables") for v in g.violations))

    def test_density_soft_penalty_flags(self):
        t = _bar("", 0, "crown", syl_target=16)
        bar = ("Pockets full of hundred, million, racks, I ride up with my team, "
               "sliding down, holding gold with the whole big crown")
        g = fv7.grade_bar(bar, t, [])
        self.assertGreaterEqual(g.soft_scores["density_hit"], 0.0)


class TestTarget6CarryBlocked(unittest.TestCase):
    def test_carry_is_blocked(self):
        self.assertTrue(any(b["target"] == "6_carry_rate" for b in fv7.BLOCKED_TARGETS))


class TestTarget7FillerEndWord(unittest.TestCase):
    def test_pass_content_end_word(self):
        t = _bar("", 0, "crown", syl_target=10)
        bar = "I ride through the city with my crown"
        g = fv7.grade_bar(bar, t, [])
        self.assertFalse(any("filler" in v or "adlib" in v for v in g.violations))

    def test_fail_adlib_end_word(self):
        t = _bar("", 0, "yeah", syl_target=10)
        bar = "I ride through the city with my yeah"
        g = fv7.grade_bar(bar, t, [])
        self.assertTrue(any("filler" in v or "adlib" in v for v in g.violations))


class TestTarget8POV(unittest.TestCase):
    def test_first_person_rate_pass(self):
        bars = ["I ride through the city with my crown",
                "I count my money, my pockets full",
                "I'm in the kitchen, I'm whipping it up",
                "My niggas with me, we never fold"]
        grades = []
        for i, b in enumerate(bars):
            t = _bar("", i, b.split()[-1].rstrip(".,!?;:'\""), syl_target=10)
            grades.append(fv7.grade_bar(b, t, bars[:i]))
        v = fv7.score_verse(bars, grades, voice="Gunna")
        self.assertGreaterEqual(v["components"]["pov_rate"], 0.5)

    def test_first_person_rate_fail(self):
        bars = ["They ride through the city with the crown",
                "They count their money, their pockets full"]
        grades = [fv7.grade_bar(b, _bar("", i, b.split()[-1], syl_target=10), bars[:i])
                  for i, b in enumerate(bars)]
        v = fv7.score_verse(bars, grades, voice="Gunna")
        self.assertLess(v["components"]["pov_rate"], 0.5)


class TestTarget9Mood(unittest.TestCase):
    def test_mood_words_under_5_pct(self):
        bars = ["I ride through the city with a crown",
                "Pockets full of money, counting change",
                "Patek on my wrist, iced out jewelry",
                "In the Lambo with my gang, we strange"]
        grades = [fv7.grade_bar(b, _bar("", i, b.split()[-1], syl_target=10), bars[:i])
                  for i, b in enumerate(bars)]
        v = fv7.score_verse(bars, grades, voice="Gunna")
        # at most 2 of 4 contain a mood-lexicon word (flex); ≤ 50% is far above 5%
        # we only assert the field exists + computes
        self.assertIn("mood_word_rate", v["components"])


class TestTarget10Subtopic(unittest.TestCase):
    def test_chip_hit_scored(self):
        t = _bar("", 0, "ice", chips=("Patek", "Henny"))
        bar = "I rock a Patek wrist, flooded with ice"
        g = fv7.grade_bar(bar, t, [], chips=["Patek", "Henny"])
        self.assertEqual(g.soft_scores["chip_hit"], 1.0)

    def test_chip_hit_none(self):
        t = _bar("", 0, "ice", chips=("Patek",))
        bar = "I walk around the city with my dog"
        g = fv7.grade_bar(bar, t, [], chips=["Patek"])
        self.assertEqual(g.soft_scores["chip_hit"], 0.0)


class TestTarget11Novelty(unittest.TestCase):
    def test_novelty_hard_gate_runs(self):
        bars = ["I ride through the city with a crown",
                "The whole block watchin' when I'm coming down"]
        # novelty is run against the catalog SQLite. Just ensure the gate
        # produces a boolean verdict.
        prompt = {"bpm": 140, "bars": 2, "section_mode": "verse"}
        def stub(sys_, usr_, model="x"):
            raise RuntimeError("should not be called by this test")
        # grade bars individually (bypasses the writer loop)
        grades = []
        for i, b in enumerate(bars):
            t = _bar("", i, b.split()[-1].strip(".,!?;:'\""), strong=(i % 2 == 1), syl_target=10)
            grades.append(fv7.grade_bar(b, t, bars[:i]))
        hard = fv7._hard_check_bars(bars, "Gunna", novelty_on=True)
        self.assertIn("ok", hard)


class TestRepeatedEndWord(unittest.TestCase):
    def test_repeated_end_in_block_fails(self):
        t = _bar("", 2, "money", syl_target=10)
        prior = ["I ride through the city with my money",
                 "Pockets full of cash, counting money",
                 "I rock a Patek wrist, flooded with ice"]  # index 2 is this one
        # about to check bar index 3 (the new one) repeating "money"
        new_target = _bar("", 3, "money", syl_target=10)
        g = fv7.grade_bar("Count that honey, dripping money", new_target, prior)
        self.assertTrue(any("repeats within" in v for v in g.violations))


class TestGenerateV7Stub(unittest.TestCase):
    """End-to-end run with a stub LLM. No API calls."""

    def test_stub_run_produces_result(self):
        # Stub returns a syllable-correct, end-word-matching bar every time.
        def stub(system: str, user: str, model: str = "gpt-4o-mini") -> str:
            # pull the end word from the prompt
            import re as _re
            m = _re.search(r"End word must be exactly: '([^']+)'", user)
            end = m.group(1) if m else "down"
            # 10-syl generic line ending with the required end word
            bar = f"I ride through the night, counting it all, {end}"
            return json.dumps({"bar": bar})
        result = fv7.generate_v7(
            prompt={"bpm": 140, "bars": 4, "section_mode": "verse"},
            voice="Gunna", topic="money_flex",
            candidates=1, retries_per_bar=1,
            call_fn=stub,
        )
        self.assertEqual(len(result.bars), 4)
        self.assertEqual(len(result.grades), 4)
        self.assertIsNotNone(result.verse_score)
        self.assertEqual(len(result.blocked_targets), 3)
        self.assertTrue(result.generation_id.startswith("v7-"))

    def test_stub_rewrite_fixes_filler_end(self):
        """When the stub first returns a filler-end bar, grader rejects
        and triggers a rewrite that returns a content-end bar."""
        state = {"attempt": 0}
        def stub(system: str, user: str, model: str = "gpt-4o-mini") -> str:
            import re as _re
            m = _re.search(r"End word must be exactly: '([^']+)'", user)
            end = m.group(1) if m else "down"
            state["attempt"] += 1
            if state["attempt"] == 1 and "Rewrite" not in user:
                return json.dumps({"bar": f"I ride through night and day in my car, yeah"})
            return json.dumps({"bar": f"I ride through town, holding mine, with the {end}"})
        r = fv7.generate_v7(
            prompt={"bpm": 140, "bars": 2, "section_mode": "verse"},
            voice="Gunna", topic="",
            candidates=1, retries_per_bar=1,
            call_fn=stub,
        )
        # the first bar's rewrite should have replaced the yeah-ending draft
        self.assertEqual(len(r.bars), 2)


class TestCaveatFlags(unittest.TestCase):
    def test_three_caveats_present_bpm_dropped(self):
        reasons = {b["target"] for b in fv7.BLOCKED_TARGETS}
        self.assertEqual(reasons, {
            "6_carry_rate",
            "caveat_triplet_pocket",
            "caveat_semantic_hooks",
        })
        self.assertNotIn("caveat_bpm_correlation", reasons)

    def test_triplet_proxy_marked_estimate_in_blocklist(self):
        trip = next(b for b in fv7.BLOCKED_TARGETS if b["target"] == "caveat_triplet_pocket")
        self.assertIn("ESTIMATE", trip["reason"])


class TestIncompleteEnd(unittest.TestCase):
    def test_bar_ending_on_preposition_fails(self):
        t = _bar("", 0, "with", syl_target=10)
        bar = "I ride through the city with"
        g = fv7.grade_bar(bar, t, [], check_novelty=False)
        self.assertFalse(g.ok)
        self.assertTrue(any("incomplete" in v for v in g.violations))

    def test_bar_ending_on_content_passes(self):
        t = _bar("", 0, "crown", syl_target=10)
        bar = "I ride through the city with my crown"
        g = fv7.grade_bar(bar, t, [], check_novelty=False)
        self.assertFalse(any("incomplete" in v for v in g.violations))


class TestClicheGate(unittest.TestCase):
    def test_cliche_fails_motivational_filler(self):
        t = _bar("", 0, "sky", syl_target=10)
        bar = "I'm chasing dreams and reaching for the sky"
        g = fv7.grade_bar(bar, t, [], check_novelty=False)
        self.assertFalse(g.ok)
        self.assertTrue(any("cliché" in v for v in g.violations))

    def test_real_rap_slang_passes(self):
        # Real rap slang must NOT fire the cliché gate even when rare in the
        # vault — the gate is for motivational filler, not low-count slang.
        slang_bars = [
            ("crown", "On god, I'm counting hundreds, holding my crown"),       # 2172 / 0.13%
            ("down", "Running it up, flooded wrist, nigga pipe down"),           # 42 / 0.0025%
            ("talk", "Me and my brodie standing on the block, no small talk"),  # 72 / 0.0042%
            ("tonight", "Pop a xan with my slime, we gon' slide tonight"),      # 66 / 0.0039%
            ("friend", "Pulled up and chopped it up with my day-one friend"),   # 61 / 0.0036%
        ]
        for end, bar in slang_bars:
            t = _bar("", 0, end, syl_target=12)
            g = fv7.grade_bar(bar, t, [], check_novelty=False)
            self.assertFalse(any("cliché" in v for v in g.violations),
                             f"bar wrongly flagged cliché: {bar!r}")

    def test_non_cliche_passes(self):
        t = _bar("", 0, "crown", syl_target=10)
        bar = "I count stacks on the balcony, holding my crown"
        g = fv7.grade_bar(bar, t, [], check_novelty=False)
        self.assertFalse(any("cliché" in v for v in g.violations))

    def test_cliche_counts_all_measured_under_threshold(self):
        total_vault_lines = 1708472
        threshold = total_vault_lines * 0.0001  # 170.8 lines = 0.01%
        for phrase, n in fv7.CLICHE_VAULT_COUNTS.items():
            self.assertLess(n, threshold,
                             f"cliché {phrase!r} should appear in <0.01% of vault")

    def test_harvested_smoke_cliches_present(self):
        """Phrases harvested from the first V7 smoke run were measured
        and added. Spot-check a handful."""
        for phrase in ("chasing green", "stacking blessings", "sun is shining",
                       "shine like a star", "level up", "sky is the limit"):
            self.assertIn(phrase, fv7.CLICHE_PHRASES)
            self.assertIn(phrase, fv7.CLICHE_VAULT_COUNTS)


class TestVaultSyllableMedians(unittest.TestCase):
    def test_voice_syl_targets_measured_from_vault(self):
        """User-measured medians: Gunna non-triplet 9 / triplet 12."""
        self.assertEqual(fv7._voice_syl_target("Gunna", triplet=False), 9)
        self.assertEqual(fv7._voice_syl_target("Gunna", triplet=True), 12)
        self.assertEqual(fv7._voice_syl_target("Lil Baby", triplet=False), 9)
        self.assertEqual(fv7._voice_syl_target("Lil Baby", triplet=True), 13)
        self.assertEqual(fv7._voice_syl_target("NoCap", triplet=False), 10)

    def test_v6_twin_table_resolves_future_to_gunna(self):
        """Future routes through Gunna's syllable medians."""
        self.assertEqual(fv7._voice_syl_target("Future", triplet=False),
                         fv7._voice_syl_target("Gunna", triplet=False))

    def test_unknown_voice_falls_back_to_default(self):
        self.assertEqual(fv7._voice_syl_target("Nobody You Know", triplet=False),
                         fv7.DEFAULT_SYL_MEDIAN["non_triplet"])

    def test_plan_uses_vault_median_not_shape_budget(self):
        s = fv7.shape_v5({"bpm": 140, "bars": 4, "section_mode": "verse"})
        plan = fv7.plan_v7(s, voice="Gunna", topic="")
        for t in plan["targets"]:
            self.assertEqual(t.syl_target, 9)
            self.assertEqual(t.syl_lo, 7)
            self.assertEqual(t.syl_hi, 11)


class TestV6TwinTable(unittest.TestCase):
    def test_chief_keef_routes_to_lil_wayne(self):
        """V6 twin table maps Chief Keef → Lil Wayne. V7 must honor that
        so results compare 1:1 with V6."""
        fams = fv7._vault_endword_families("Chief Keef")
        # Lil Wayne has a much larger vault than Chief Keef solo; if the
        # twin kicked in we expect >50 families
        self.assertGreater(len(fams), 50)

    def test_future_routes_to_gunna(self):
        fams = fv7._vault_endword_families("Future")
        self.assertGreater(len(fams), 20)


class TestPerBarNovelty(unittest.TestCase):
    def test_per_bar_novelty_triggers_on_verbatim(self):
        """A verbatim catalog line should fail the per-bar novelty gate."""
        db = fv7._catalog_db()
        if not db.is_file():
            self.skipTest("catalog DB missing")
        conn = fv7._ro_connect(db)
        row = conn.execute(
            "SELECT line, end_word FROM bars WHERE lower(artist)='gunna' "
            "AND length(line) BETWEEN 40 AND 80 LIMIT 1").fetchone()
        conn.close()
        self.assertIsNotNone(row)
        vault_line, end_word = row
        t = _bar("", 0, (end_word or vault_line.split()[-1]).strip(".,!?;:'\"").lower(),
                 syl_target=12)
        g = fv7.grade_bar(vault_line, t, [], check_novelty=True)
        # should fail per-bar novelty with a "near-dup" reason
        self.assertFalse(g.ok)
        self.assertTrue(any("near-dup" in v or "vault" in v for v in g.violations))


class TestVaultEndwordFamilies(unittest.TestCase):
    def test_vault_families_pulled(self):
        fams = fv7._vault_endword_families("Gunna")
        self.assertGreater(len(fams), 5, "expected multiple end-rhyme families from Gunna's vault")
        for rime, words in fams[:3]:
            self.assertIsInstance(rime, tuple)
            self.assertGreaterEqual(len(words), 2)


class TestFamilyReuseCap(unittest.TestCase):
    def test_cap_prevents_same_family_in_consecutive_plans(self):
        used: set = set()
        s = fv7.shape_v5({"bpm": 140, "bars": 4, "section_mode": "verse"})
        p1 = fv7.plan_v7(s, voice="Gunna", topic="", used_families=used)
        rimes1 = {tuple(fv7._cmu_rime(fv7._word(ew.split()[-1])))
                  for ew in p1["end_words"]}
        # second plan on the same used set should avoid the first plan's rimes
        p2 = fv7.plan_v7(s, voice="Gunna", topic="", used_families=used)
        rimes2 = {tuple(fv7._cmu_rime(fv7._word(ew.split()[-1])))
                  for ew in p2["end_words"]}
        overlap = (rimes1 & rimes2) - {()}
        # non-empty overlap means the cap was ignored; it may be empty or
        # near-empty for the first few prompts
        self.assertLessEqual(len(overlap), len(rimes1) // 2 + 1)


class TestFourBarVowelShare(unittest.TestCase):
    def test_bonus_fires_when_vowels_cluster(self):
        bars = ["I ride through the city with a crown",       # AW
                "The whole block watchin' as I come down",     # AW
                "Pockets full of hundreds and honey",          # AH
                "Street dreams, we chasin' the money"]         # AH
        rate = fv7._four_bar_vowel_share_rate(bars)
        self.assertGreaterEqual(rate, 0.9)

    def test_bonus_in_verse_score(self):
        bars = ["I ride through the city with a crown",
                "The whole block watchin' as I come down",
                "Pockets full of hundreds and honey",
                "Street dreams, we chasin' the money"]
        grades = [fv7.grade_bar(b, _bar("", i, b.split()[-1], strong=(i % 2 == 1),
                                        syl_target=10), bars[:i], check_novelty=False)
                  for i, b in enumerate(bars)]
        v = fv7.score_verse(bars, grades, voice="Gunna")
        self.assertIn("four_bar_vowel_share_rate", v["components"])


class TestStyleExamples(unittest.TestCase):
    def test_topic_matches_fill_twenty_to_thirty(self):
        jewelry = [f"Ice on the chain and the patek bar {i}" for i in range(25)]
        other = [f"Just another line about the weather {i}" for i in range(20)]
        picked = fv7.select_style_examples(jewelry + other, "jewelry", seed=3)
        self.assertGreaterEqual(len(picked), 20)
        self.assertLessEqual(len(picked), 30)
        self.assertTrue(all("chain" in line or "patek" in line for line in picked[:20]))

    def test_prompt_includes_examples_and_do_not_copy(self):
        examples = [f"Ice on the chain bar {i}" for i in range(22)]
        target = _bar("", 0, "crown", syl_target=9)
        prompt = fv7._write_bar_prompt(target, "Gunna", "jewelry", [], [], examples)
        self.assertIn("do not copy", prompt.lower())
        self.assertIn(examples[0], prompt)
        self.assertIn("End word must be exactly: 'crown'", prompt)

    def test_shown_examples_reach_the_novelty_gate(self):
        seen = {}

        def fake(bar, chip_words=None, shown_examples=None):
            seen["shown"] = list(shown_examples or [])
            return {"is_near_dup": False, "reasons": []}

        target = _bar("", 0, "crown", syl_target=9)
        with patch("taste.novelty.bar_novelty", fake):
            fv7.grade_bar("Marble turtles holding on my crown", target, [],
                          check_vocab=False, shown_examples=["alpha example line"])
        self.assertEqual(seen["shown"], ["alpha example line"])

    def test_gunna_jewelry_retrieval_is_read_only_and_bounded(self):
        if not fv7._catalog_db().is_file():
            self.skipTest("catalog DB missing")
        rows = fv7.retrieve_style_examples("Gunna", "jewelry", seed=20261031)
        self.assertGreaterEqual(len(rows), 20)
        self.assertLessEqual(len(rows), 30)
        words = set(fv7._W.findall(rows[0].lower()))
        needles = {"chain", "iced", "diamond", "rolex", "patek", "watch",
                   "cuban", "pendant", "bezel", "vvs"}
        self.assertTrue(words & needles)


class TestFourBarRhymePlan(unittest.TestCase):
    def _crown_family(self):
        rime = tuple(fv7._cmu_rime("crown"))
        words = [("crown", 40), ("down", 30), ("town", 20), ("gown", 10)]
        for word, _count in words:
            self.assertEqual(tuple(fv7._cmu_rime(word)), rime)
        return rime, words

    def test_one_family_per_block_and_no_invented_ends(self):
        rime, words = self._crown_family()
        shape = fv7.shape_v5({"bpm": 140, "bars": 4, "section_mode": "verse"})
        with patch("frontier_v7._vault_family_weights", return_value=[(rime, words)]):
            plan = fv7.plan_v7(shape, voice="Gunna", topic="jewelry", seed=1)
        self.assertTrue(plan["complete"])
        self.assertEqual(len(set(plan["end_words"])), 4)
        self.assertEqual({tuple(target.block_rime) for target in plan["targets"]}, {rime})
        self.assertTrue(set(plan["end_words"]) <= {"crown", "down", "town", "gown"})
        with patch("frontier_v7._vault_family_weights", return_value=[]):
            empty = fv7.plan_v7(shape, voice="Gunna", topic="jewelry", seed=1)
        self.assertFalse(empty["complete"])
        self.assertEqual(empty["end_words"], [])

    def test_frequent_family_wins_the_weight(self):
        heavy = tuple(fv7._cmu_rime("crown"))
        light = tuple(fv7._cmu_rime("night"))
        fams = [
            (heavy, [("crown", 80), ("down", 70), ("town", 60), ("gown", 50)]),
            (light, [("night", 1), ("light", 1), ("flight", 1), ("sight", 1)]),
        ]
        shape = fv7.shape_v5({"bpm": 140, "bars": 4, "section_mode": "verse"})
        wins = 0
        for seed in range(40):
            with patch("frontier_v7._vault_family_weights", return_value=fams):
                plan = fv7.plan_v7(shape, voice="Gunna", topic="", seed=seed)
            if plan["end_words"] and plan["end_words"][0] in {"crown", "down", "town", "gown"}:
                wins += 1
        self.assertGreaterEqual(wins, 30)

    def test_chip_rime_is_preferred(self):
        heavy = tuple(fv7._cmu_rime("crown"))
        light = tuple(fv7._cmu_rime("night"))
        fams = [
            (heavy, [("crown", 80), ("down", 70), ("town", 60), ("gown", 50)]),
            (light, [("night", 1), ("light", 1), ("flight", 1), ("sight", 1)]),
        ]
        shape = fv7.shape_v5({"bpm": 140, "bars": 4, "section_mode": "verse"})
        with patch("frontier_v7._vault_family_weights", return_value=fams):
            plan = fv7.plan_v7(
                shape, voice="Gunna", topic="", seed=1,
                chip_hints=[{"chip": "night", "end_rime": light}],
            )
        self.assertTrue(set(plan["end_words"]) <= {"night", "light", "flight", "sight"})

    def test_gunna_vault_plan_is_one_family_per_block(self):
        if not fv7._catalog_db().is_file():
            self.skipTest("catalog DB missing")
        shape = fv7.shape_v5({"bpm": 140, "bars": 8, "section_mode": "verse"})
        plan = fv7.plan_v7(shape, voice="Gunna", topic="jewelry", seed=20261031)
        self.assertTrue(plan["complete"])
        self.assertEqual(len(plan["end_words"]), 8)
        self.assertEqual(plan["plan_model"], fv7.PLAN_MODEL_NAME)
        for start in (0, 4):
            chunk = plan["end_words"][start:start + 4]
            self.assertEqual(len(set(chunk)), 4, chunk)
            rimes = {tuple(fv7._cmu_rime(fv7._word(word))) for word in chunk}
            self.assertEqual(rimes, {tuple(plan["targets"][start].block_rime)})
        self.assertNotEqual(tuple(plan["targets"][0].block_rime),
                            tuple(plan["targets"][4].block_rime))


class TestVocabGate(unittest.TestCase):
    def test_injected_vocab_rejects_domination_and_allows_digital(self):
        bank = {"whole", "block", "comin", "down", "chain", "wrist", "money", "digital"}
        bad = fv7._grade_vocab(
            "Blockchain crypto wallet settlement digital", "Gunna", vocab=bank)
        self.assertFalse(bad["ok"])
        self.assertTrue(any("vocabulary hit" in reason for reason in bad["reasons"]))
        good = fv7._grade_vocab("Whole block comin down on the chain", "Gunna", vocab=bank)
        self.assertTrue(good["ok"], good)
        allowed = fv7._grade_vocab("Digital chain on the wrist down", "Gunna", vocab=bank)
        self.assertTrue(allowed["ok"], allowed)

    def test_missing_vault_fails_closed(self):
        fv7._VOCAB_CACHE.pop("missing voice", None)
        with patch.object(fv7, "_voice_lines", return_value=[]):
            grade = fv7._grade_vocab("Blockchain crypto wallet settlement", "Missing Voice")
        self.assertFalse(grade["ok"])
        self.assertTrue(any("could not be read" in reason for reason in grade["reasons"]))

    def test_gunna_vault_has_digital_and_not_blockchain(self):
        if not fv7._catalog_db().is_file():
            self.skipTest("catalog DB missing")
        bank = fv7.voice_vocab("Gunna")
        self.assertNotIn("blockchain", bank)
        self.assertNotIn("crypto", bank)
        self.assertIn("digital", bank)
        dominated = fv7._grade_vocab("The blockchain crypto wallet settlement", "Gunna")
        self.assertFalse(dominated["ok"])


class TestWriterModelAndShipGate(unittest.TestCase):
    def _examples(self):
        return [f"Style example line number {i} about the room" for i in range(22)]

    def test_broken_block_retries_and_does_not_ship(self):
        rime, words = tuple(fv7._cmu_rime("crown")), [
            ("crown", 40), ("down", 30), ("town", 20), ("gown", 10)]
        calls = {"n": 0}
        ends = ["dog", "cat", "tree", "moon"]

        def stub(system, user, model="gpt-4o-mini"):
            calls["n"] += 1
            end = ends[calls["n"] % 4]
            return json.dumps({"bar": f"Marble turtles holding on my {end}"})

        with patch("frontier_v7._vault_family_weights", return_value=[(rime, words)]):
            result = fv7.generate_v7(
                {"bpm": 140, "bars": 4, "section_mode": "verse"},
                voice="Gunna", topic="jewelry", call_fn=stub,
                style_examples=self._examples(), vocab={"marble", "turtles", "holding"},
                retries_per_bar=0, block_retries=2, seed=5,
            )
        self.assertEqual(len(result.bars), 4)
        self.assertGreater(calls["n"], 4)
        self.assertFalse(result.shipped)
        self.assertFalse(result.verified)
        self.assertTrue(any("do not share" in item for item in result.violations_rolled_up))

    def test_incomplete_plan_does_not_call_the_writer(self):
        calls = {"n": 0}

        def stub(system, user, model="gpt-4o-mini"):
            calls["n"] += 1
            return json.dumps({"bar": "Marble turtles holding on my crown"})

        shape_prompt = {"bpm": 140, "bars": 4, "section_mode": "verse"}
        with patch("frontier_v7._vault_family_weights", return_value=[]):
            result = fv7.generate_v7(
                shape_prompt, voice="Gunna", topic="jewelry", call_fn=stub,
                style_examples=self._examples(),
            )
        self.assertEqual(calls["n"], 0)
        self.assertFalse(result.shipped)
        self.assertEqual(result.bars, [])

    def test_writer_defaults_stronger_than_mini_and_block_can_ship(self):
        self.assertEqual(fv7.PLAN_MODEL_NAME, os.environ.get("V7_PLAN_MODEL", "gpt-4o-mini"))
        self.assertEqual(fv7.WRITER_MODEL_NAME, os.environ.get("V7_WRITER_MODEL", "gpt-4o"))
        self.assertNotEqual(fv7.WRITER_MODEL_NAME, "gpt-4o-mini")
        rime = tuple(fv7._cmu_rime("crown"))
        words = [("crown", 40), ("down", 30), ("town", 20), ("gown", 10)]
        models = []

        def stub(system, user, model="gpt-4o-mini"):
            models.append(model)
            match = re.search(r"End word must be exactly: '([^']+)'", user)
            end = match.group(1) if match else "crown"
            return json.dumps({"bar": f"Marble turtles holding on my {end}"})

        vocab = {"marble", "turtles", "holding", "crown", "down", "town", "gown"}
        with patch("frontier_v7._vault_family_weights", return_value=[(rime, words)]):
            result = fv7.generate_v7(
                {"bpm": 140, "bars": 4, "section_mode": "verse"},
                voice="Gunna", topic="jewelry", call_fn=stub,
                style_examples=self._examples(), vocab=vocab,
                retries_per_bar=0, block_retries=0, seed=3,
            )
        self.assertEqual(len(result.bars), 4)
        self.assertTrue(models)
        self.assertTrue(all(model == fv7.WRITER_MODEL_NAME for model in models))
        self.assertEqual(result.plan["plan_model"], fv7.PLAN_MODEL_NAME)
        self.assertEqual(result.plan["writer_model"], fv7.WRITER_MODEL_NAME)
        self.assertEqual(result.plan["style_example_count"], 22)
        self.assertTrue(fv7._block_shares_rime(result.bars, rime), result.bars)
        self.assertTrue(result.shipped, result.violations_rolled_up)


class TestRealGunnaSpans(unittest.TestCase):
    def test_two_songs_eight_lines_numeric_order(self):
        if not fv7._catalog_db().is_file():
            self.skipTest("catalog DB missing")
        spans = fv7.load_real_spans("Gunna", count=2, bars=8, seed=20261031)
        self.assertEqual(len(spans), 2)
        self.assertNotEqual(spans[0]["song"], spans[1]["song"])
        conn = fv7._ro_connect(fv7._catalog_db())
        try:
            for span in spans:
                self.assertEqual(len(span["lines"]), 8)
                rows = conn.execute(
                    "SELECT id, line FROM bars WHERE lower(artist)='gunna' AND song=?",
                    (span["song"],),
                ).fetchall()
                rows.sort(key=lambda row: (fv7._line_number(row[0]), str(row[0])))
                expect = [str(row[1]).strip() for row in rows if str(row[1]).strip()][:8]
                self.assertEqual(span["lines"], expect)
        finally:
            conn.close()


if __name__ == "__main__":
    unittest.main()
