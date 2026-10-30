"""Frontier v5 stages. No model call.

Plan tests stub the model. Name-guard and vault-topic helpers may read
catalog_index.sqlite read-only. A missing comma never opens a fail.
"""

import json
import sqlite3
import tempfile
import unittest
from dataclasses import FrozenInstanceError
from pathlib import Path
from unittest.mock import patch

from catalog_retriever import resolve_catalog_artist, sample_end_words
from frontier_v5 import (
    CatalogLine,
    Plan,
    Shape,
    Verse,
    Bar,
    VerifiedVerse,
    _couplets_rhyme,
    _edit_prompt,
    _parse_edit_lines,
    _phonetic_rhyme,
    cache_params_v5,
    chip_matches_bar,
    edit_v5,
    generate_v5,
    measure_bar,
    plan_v5,
    repair_bar_commas,
    retrieve_v5,
    strip_bar_labels,
    select_v5,
    shape_v5,
    verify_v5,
)
from prompt_cache import compute_cache_key, get_cached_verse
from v5_policy import DOUBLE_MEANING_ANY_VOICE


def _plan(bars=2, words=("tonight", "mercedes")):
    couplets = (bars + 1) // 2
    families = []
    for index in range(couplets):
        pair = [words[min(index * 2, len(words) - 1)]]
        if index * 2 + 1 < len(words):
            pair.append(words[index * 2 + 1])
        families.append(tuple(pair))
    return Plan(
        motif_chain=tuple(["lavishness_money"] * couplets),
        end_words=tuple(words[:bars]),
        couplet_voices=tuple(["Gunna"] * couplets),
        rhyme_families=tuple(families),
        double_meaning_slots=(bars - 1,),
        planner_model="test",
        plan_valid=True,
    )


def _line(text, end_word, source="catalog"):
    return CatalogLine(
        text=text,
        end_word=end_word,
        artist="Gunna",
        song="One",
        album="Wunna",
        retrieval_id=1,
        is_iconic_anthem=False,
        scaffold_source=source,
        comma_count=text.count(","),
    )


class FrontierV5Tests(unittest.TestCase):
    def test_shape_is_the_only_budget(self):
        verse = shape_v5({"bpm": 140, "section_mode": "verse", "bars": 4})
        self.assertEqual(verse.syl_budget, 15)
        self.assertEqual(verse.meter_commas, 3)
        self.assertEqual(verse.bar_count, 4)
        hook = shape_v5({"bpm": 140, "section_mode": "hook"})
        self.assertEqual(hook.syl_budget, 14)
        self.assertEqual(hook.meter_commas, 1)
        bridge = shape_v5({"bpm": 140, "section_mode": "bridge"})
        self.assertEqual(bridge.syl_budget, 12)
        self.assertEqual(bridge.meter_commas, 1)
        outro = shape_v5({"bpm": 70, "section_mode": "outro"})
        self.assertEqual(outro.syl_budget, 8)
        self.assertEqual(outro.meter_commas, 0)
        hum = shape_v5({
            "section_mode": "verse",
            "audio_flow": {"bpm_estimate": 90, "median_syl_per_line": 18, "text": "hum line"},
        })
        self.assertEqual(hum.syl_budget, 18)
        self.assertEqual(hum.bpm, 90)
        self.assertEqual(hum.seed_line, "hum line")

    def test_sample_end_words_skips_recent_and_does_not_create_a_db(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            missing = root / "missing.sqlite"
            self.assertEqual(sample_end_words("Gunna", count=4, db_path=missing), [])
            self.assertFalse(missing.exists())
            db = root / "catalog.sqlite"
            conn = sqlite3.connect(str(db))
            conn.execute(
                "CREATE TABLE catalog_bars (artist TEXT, end_word TEXT, is_generic INTEGER)"
            )
            rows = [("Gunna", "street", 0)] * 4 + [("Gunna", "tonight", 0), ("Gunna", "back", 0)] * 3
            conn.executemany("INSERT INTO catalog_bars VALUES (?, ?, ?)", rows)
            conn.commit()
            conn.close()
            picked = sample_end_words(
                "Gunna",
                count=4,
                db_path=db,
                recent_end_words=["tonight"],
            )
            self.assertIn("street", picked)
            self.assertNotIn("tonight", picked)
            self.assertNotIn("back", picked)
            conn = sqlite3.connect(str(db))
            conn.execute(
                "INSERT INTO catalog_bars VALUES (?, ?, ?)",
                ("Lil Wayne", "milli", 0),
            )
            conn.commit()
            conn.close()
            self.assertEqual(resolve_catalog_artist("Chief Keef"), "lil wayne")
            twin = sample_end_words("Chief Keef", count=4, db_path=db, recent_end_words=[])
            self.assertEqual(twin, ["milli"])

    def test_plan_rejects_an_invented_end_word_and_opens_double_meaning(self):
        self.assertTrue(DOUBLE_MEANING_ANY_VOICE)
        calls = {"n": 0}

        def sample_fn(voice, count=8, dedupe_window=16):
            return ["night", "light", "fight", "sight"]

        def call_fn(system, user):
            calls["n"] += 1
            if calls["n"] == 1:
                return json.dumps({
                    "motif_chain": ["lavishness_money", "street_defiance"],
                    "couplet_voices": ["Gunna", "Gunna"],
                    "end_words": ["unicorn", "unicorn", "unicorn", "unicorn"],
                    "rhyme_families": [["unicorn"], ["unicorn"]],
                })
            return json.dumps({
                "motif_chain": ["lavishness_money", "street_defiance"],
                "couplet_voices": ["Gunna", "Gunna"],
                "end_words": ["night", "light", "fight", "sight"],
                "rhyme_families": [["night", "light"], ["fight", "sight"]],
            })

        shape = shape_v5({"bpm": 140, "section_mode": "verse", "bars": 4})
        for voice in ("Gunna", "Lil Wayne"):
            calls["n"] = 0
            plan = plan_v5(shape, voice, call_fn=call_fn, sample_fn=sample_fn)
            self.assertEqual(calls["n"], 2)
            self.assertEqual(plan.end_words, ("night", "light", "fight", "sight"))
            self.assertIn(3, plan.double_meaning_slots)
            self.assertNotEqual(plan.planner_model, "heuristic_fallback")
            with self.assertRaises(FrozenInstanceError):
                plan.end_words = ("car",)

    def test_plan_second_failure_uses_the_v3_motif_chain(self):
        def sample_fn(voice, count=8, dedupe_window=16):
            return ["tonight"]

        def call_fn(system, user):
            return "not json"

        shape = shape_v5({"bpm": 140, "section_mode": "hook", "bars": 4})
        plan = plan_v5(shape, "Lil Wayne", call_fn=call_fn, sample_fn=sample_fn)
        self.assertEqual(plan.planner_model, "heuristic_fallback")
        self.assertEqual(len(plan.end_words), 4)
        self.assertTrue(plan.double_meaning_slots)

    def test_empty_menu_does_not_ask_the_model_to_invent(self):
        def sample_fn(voice, count=8, dedupe_window=16):
            return []

        def call_fn(system, user):
            raise AssertionError("model was called with an empty catalog menu")

        shape = shape_v5({"bpm": 140, "section_mode": "verse", "bars": 2})
        plan = plan_v5(shape, "Gunna", call_fn=call_fn, sample_fn=sample_fn)
        self.assertEqual(plan.planner_model, "heuristic_fallback")

    def test_retrieve_tags_bank_and_leaves_the_plan(self):
        plan = _plan()
        ends = plan.end_words
        with tempfile.TemporaryDirectory() as tmp:
            missing = Path(tmp) / "missing.sqlite"
            scaffold = retrieve_v5(plan, shape_v5({"bpm": 140, "bars": 2}), "Gunna", db_path=missing)
        self.assertEqual(plan.end_words, ends)
        self.assertEqual(len(scaffold), 2)
        self.assertTrue(all(line.scaffold_source == "bank" for line in scaffold))
        self.assertFalse(missing.exists())

    def test_verify_retries_one_bar_and_bank_is_refused(self):
        shape = shape_v5({"bpm": 140, "section_mode": "verse", "bars": 2})
        plan = _plan()
        good = [
            "Clock on the block, rain on the curb, light on the glass, landing tonight",
            "Chain on the seat, gold on the hand, ring on the glass, foreign mercedes",
        ]
        scaffold = (_line(good[0], "tonight"), _line(good[1], "mercedes"))
        bad = Verse(
            bars=[
                Bar(0, good[0], "tonight", "Gunna"),
                Bar(1, "Chain on the seat, gold on the hand, ring on the glass, foreign yesterday", "mercedes", "Gunna"),
            ],
            model="test",
        )
        seen = []

        def editor(plan, scaffold, shape, voice, taste="", call_fn=None, only_index=None, violations=None, verse=None):
            seen.append((only_index, list(violations or [])))
            fixed = list(verse.bars)
            fixed[only_index] = Bar(only_index, good[only_index], plan.end_words[only_index], "Gunna")
            return Verse(bars=fixed, model="retry")

        checked = verify_v5(
            bad,
            plan,
            scaffold,
            shape,
            "Gunna",
            edit_fn=editor,
            max_retries=2,
            cmu={},
            syllable_fn=lambda text: shape.syl_budget,
            inner_fn=lambda text, cmu: [{}, {}],
            rhyme_fn=lambda word, family, cmu: True,
        )
        self.assertEqual(seen, [(1, ["end_word"])])
        self.assertTrue(checked.verified)
        self.assertEqual(checked.retries_used, 1)
        self.assertEqual(plan.end_words, ("tonight", "mercedes"))

        bank = (_line(good[0], "tonight", source="bank"), scaffold[1])
        refused = verify_v5(
            Verse(bars=[Bar(0, good[0], "tonight", "Gunna"), Bar(1, good[1], "mercedes", "Gunna")], model="test"),
            plan,
            bank,
            shape,
            "Gunna",
            edit_fn=editor,
            max_retries=2,
            cmu={},
            syllable_fn=lambda text: shape.syl_budget,
            inner_fn=lambda text, cmu: [{}, {}],
            rhyme_fn=lambda word, family, cmu: True,
        )
        self.assertFalse(refused.verified)
        self.assertIn("bank", refused.violations[0]["codes"])
        self.assertEqual(refused.retries_used, 0)

    def test_real_checkers_name_the_miss(self):
        shape = Shape(16, 1, "verse", 3, 140.0, "")
        plan = _plan(1, ("tonight",))
        scaffold = _line("Clock on the block, rain on the curb, light on the glass, landing tonight", "tonight")
        measured = measure_bar(0, "yeah", plan, scaffold, shape, cmu={})
        self.assertIn("end_word", measured["codes"])
        self.assertIn("syllables", measured["codes"])
        self.assertIn("inner_rhyme", measured["codes"])
        self.assertIn("rhyme_family", measured["codes"])

    def test_edit_prompt_gives_rime_not_the_vault_line(self):
        vault = "Clock on the block, rain on the curb, light on the glass, landing tonight"
        other = "Chain on the seat, gold on the hand, ring on the glass, foreign mercedes"
        shape = shape_v5({"bpm": 140, "bars": 2})
        plan = _plan()
        scaffold = (_line(vault, "tonight"), _line(other, "mercedes"))
        text = _edit_prompt(
            plan,
            scaffold,
            shape,
            "Gunna",
            taste="WRITE LIKE THIS keeper bar from the vault",
            only_index=None,
            violations=None,
            wordplay_pick={"line": "Quoted example line should stay out", "tab": "flip"},
            chip_hints=[{"chip": "Cuban link", "end_rime": ["IH1", "NG", "K"]}],
            topic="braggadocio_skill",
        )
        self.assertNotIn(vault, text)
        self.assertNotIn(other, text)
        self.assertNotIn("WRITE LIKE THIS", text)
        self.assertNotIn("Quoted example line should stay out", text)
        self.assertIn("braggadocio_skill", text)
        self.assertIn("Cuban link", text)
        self.assertIn("tonight", text)
        self.assertIn(str(shape.syl_budget), text)
        self.assertIn("end rime:", text)
        self.assertIn("Comma rule:", text)
        self.assertIn("optional, from the vault", text)

        def call_fn(system, user):
            self.assertNotIn(vault, system)
            self.assertNotIn(vault, user)
            return ""

        edited = edit_v5(plan, scaffold, shape, "Gunna", call_fn=call_fn, topic="braggadocio_skill")
        self.assertEqual(edited.bars[0].text, "tonight")
        self.assertNotIn("Clock on the block", edited.bars[0].text)

    def test_scaffold_distance_is_off_when_the_writer_is_blind(self):
        import frontier_v5

        self.assertFalse(frontier_v5.WRITER_SEES_VAULT_LINES)
        shape = Shape(16, 1, "verse", 3, 140.0, "")
        plan = _plan(1, ("tonight",))
        vault = "Clock on the block, rain on the curb, light on the glass, landing tonight"
        far = "zzzz, yyyy, xxxx, wwww tonight"
        kwargs = dict(
            syllable_fn=lambda text: 16,
            inner_fn=lambda text, cmu: [{}, {}],
            rhyme_fn=lambda word, family, cmu: True,
        )
        measured = measure_bar(0, far, plan, _line(vault, "tonight"), shape, cmu={}, **kwargs)
        self.assertNotIn("scaffold", measured["codes"])
        self.assertGreater(measured["scaffold_distance"], measured["scaffold_cap"])
        frontier_v5.WRITER_SEES_VAULT_LINES = True
        try:
            shown = measure_bar(0, far, plan, _line(vault, "tonight"), shape, cmu={}, **kwargs)
            self.assertIn("scaffold", shown["codes"])
        finally:
            frontier_v5.WRITER_SEES_VAULT_LINES = False
        banked = measure_bar(0, far, plan, _line(vault, "tonight", source="bank"), shape, cmu={}, **kwargs)
        self.assertIn("bank", banked["codes"])

    def test_commas_are_vault_derived_and_never_fail(self):
        shape = Shape(16, 1, "verse", 3, 140.0, "")
        bare = "one two three four five six seven eight"
        self.assertEqual(repair_bar_commas(bare, shape, {}), bare)
        self.assertEqual(repair_bar_commas("one two, three four,", shape, {}), "one two, three four")
        plan = _plan(1, ("eight",))
        scaffold = (_line("vault words that the writer never sees at all", "eight"),)
        checked = verify_v5(
            Verse(bars=[Bar(0, bare, "eight", "Gunna")], model="test"),
            plan, scaffold, shape, "Gunna",
            edit_fn=lambda **kwargs: (_ for _ in ()).throw(AssertionError("no retry for a missing comma")),
            max_retries=1, cmu={},
            syllable_fn=lambda text: shape.syl_budget,
            inner_fn=lambda text, cmu: [{}, {}],
            rhyme_fn=lambda word, family, cmu: True,
        )
        codes = [code for row in checked.violations for code in row["codes"]]
        self.assertNotIn("commas", codes)
        self.assertEqual(checked.verse.bars[0].text, bare)

    def test_slant_family_rime_is_allowed_and_a_miss_is_logged(self):
        import contextlib
        import io

        cmu = {
            "night": ["N", "AY1", "T"],
            "light": ["L", "AY1", "T"],
            "flight": ["F", "L", "AY1", "T"],
            "mind": ["M", "AY1", "N", "D"],
            "yeah": ["Y", "EH1"],
            "vacation": ["V", "EY0", "K", "EY1", "SH", "AH0", "N"],
            "location": ["L", "OW0", "K", "EY1", "SH", "AH0", "N"],
        }
        self.assertTrue(_phonetic_rhyme("mind", "night", cmu))
        self.assertTrue(_phonetic_rhyme("vacation", "location", cmu))
        self.assertFalse(_phonetic_rhyme("yeah", "night", cmu))
        self.assertTrue(_couplets_rhyme(("mind", "flight"), cmu, families=[("night", "light")]))
        shape = Shape(16, 1, "verse", 3, 140.0, "")
        plan = _plan(1, ("night",))
        scaffold = _line("totally different vault sentence about the block", "night")
        hit = measure_bar(0, "I keep a quiet mind", plan, scaffold, shape, cmu=cmu)
        self.assertNotIn("rhyme_family", hit["codes"])
        self.assertNotIn("end_word", hit["codes"])
        self.assertNotIn("scaffold", hit["codes"])
        buf = io.StringIO()
        with contextlib.redirect_stderr(buf):
            miss = measure_bar(0, "I said yeah", plan, scaffold, shape, cmu=cmu)
        self.assertIn("rhyme_family", miss["codes"])
        self.assertIn("end_word", miss["codes"])
        self.assertEqual(miss["planned_end"], "night")
        self.assertEqual(miss["actual_end"], "yeah")
        logged = buf.getvalue()
        self.assertIn("planned=night", logged)
        self.assertIn("actual=yeah", logged)

    def test_plan_json_repair_is_the_third_call(self):
        calls = []

        def sample_fn(voice, count=8, dedupe_window=16):
            return ["night", "light", "fight", "sight"]

        good = {
            "motif_chain": ["lavishness_money", "street_defiance"],
            "couplet_voices": ["Gunna", "Gunna"],
            "end_words": ["night", "light", "fight", "sight"],
            "rhyme_families": [["night", "light"], ["fight", "sight"]],
            "double_meaning_slots": [],
        }

        def call_fn(system, user):
            calls.append((system, user))
            if len(calls) < 3:
                return "not json {"
            return json.dumps(good)

        shape = shape_v5({"bpm": 140, "section_mode": "verse", "bars": 4})
        plan = plan_v5(shape, "Gunna", call_fn=call_fn, sample_fn=sample_fn)
        self.assertEqual(len(calls), 3)
        self.assertIn("STRICT SCHEMA", calls[2][1])
        self.assertIn('"enum"', calls[2][1])
        self.assertIn("night", calls[2][1])
        self.assertIn("repair", calls[2][0].lower())
        self.assertEqual(plan.end_words, ("night", "light", "fight", "sight"))
        self.assertNotEqual(plan.planner_model, "heuristic_fallback")

        failed = {"n": 0}

        def always_bad(system, user):
            failed["n"] += 1
            return "still not json"

        fallback = plan_v5(shape, "Gunna", call_fn=always_bad, sample_fn=sample_fn)
        self.assertEqual(failed["n"], 3)
        self.assertEqual(fallback.planner_model, "heuristic_fallback")

    def test_chief_keef_braggadocio_row_drops_bar_labels(self):
        # Stored bo8_novelty_chips row: Chief Keef, braggadocio_skill.
        raw = (
            "Bar, 1\n"
            "I’m the king, no doubt, I’m spitting, hot like dog shit\n"
            "Bar, 2\n"
            "Flexing hard, I’m sharp, my flow’s a weapon, like opp shit\n"
            "Bar, 3\n"
            "When I step, they know, I’m the best, can’t touch him\n"
            "Bar, 4\n"
            "In the game, I reign, watch me rise, you can’t miss this"
        )
        lines = strip_bar_labels(raw)
        self.assertEqual(lines, [
            "I’m the king, no doubt, I’m spitting, hot like dog shit",
            "Flexing hard, I’m sharp, my flow’s a weapon, like opp shit",
            "When I step, they know, I’m the best, can’t touch him",
            "In the game, I reign, watch me rise, you can’t miss this",
        ])
        self.assertTrue(lines[0].endswith("shit"))
        self.assertTrue(lines[2].endswith("him"))
        parsed = _parse_edit_lines(raw, 8)
        self.assertEqual(parsed, lines)
        self.assertNotIn("Bar, 1", parsed)
        prefixed = _parse_edit_lines(
            "Bar 1: clock on the block tonight\nBar 2: chain on the seat mercedes\n",
            2,
        )
        self.assertEqual(prefixed, [
            "clock on the block tonight",
            "chain on the seat mercedes",
        ])

    def test_smoke_soft_gates_penalize_syllables_and_inner_rhyme(self):
        shape = Shape(16, 1, "verse", 3, 140.0, "")
        plan = _plan(1, ("tonight",))
        scaffold = _line(
            "Clock on the block, rain on the curb, light on the glass, landing tonight",
            "tonight",
        )
        hard = measure_bar(0, "yeah", plan, scaffold, shape, cmu={})
        self.assertIn("syllables", hard["codes"])
        self.assertIn("inner_rhyme", hard["codes"])
        self.assertEqual(hard["soft_penalty"], 0.0)
        soft = measure_bar(
            0, "yeah", plan, scaffold, shape, cmu={},
            soft_codes={"syllables", "inner_rhyme"},
        )
        self.assertNotIn("syllables", soft["codes"])
        self.assertNotIn("inner_rhyme", soft["codes"])
        self.assertIn("end_word", soft["codes"])
        self.assertIn("rhyme_family", soft["codes"])
        self.assertEqual(set(soft["penalties"]), {"syllables", "inner_rhyme"})
        self.assertEqual(soft["soft_penalty"], 2.0)

    def test_name_guard_skips_contractions_and_flags_a_proper_name(self):
        from frontier_v5 import _unknown_names

        line = "I’m the king, no doubt, I’m spitting, and you're late, I'ma go, we're up"
        self.assertEqual(_unknown_names(line, "Chief Keef"), [])
        self.assertEqual(_unknown_names("Don't stop, they’re here, I’ll slide", "Drake"), [])
        self.assertEqual(_unknown_names("I met Zendaya downtown", "Chief Keef"), ["zendaya"])
        self.assertEqual(_unknown_names("I saw Drake in the spot", "Drake"), [])
        self.assertEqual(_unknown_names("I saw Drake in the spot", "Chief Keef"), ["drake"])

    def test_name_guard_allows_chip_brands_and_flags_people(self):
        import frontier_v5
        from frontier_v5 import _unknown_names

        line = "Pulled the Maybach with a Patek, Celine bag, Mercedes and the Cullinan"
        self.assertEqual(_unknown_names(line, "Chief Keef"), [])
        people = _unknown_names("I saw Brad Pitt and Zendaya", "Chief Keef")
        self.assertEqual(people, ["brad", "pitt", "zendaya"])
        frontier_v5._VAULT_TOKEN_CACHE["chief keef"] = {"zendaya"}
        try:
            self.assertEqual(_unknown_names("I met Zendaya downtown", "Chief Keef"), [])
        finally:
            frontier_v5._VAULT_TOKEN_CACHE.pop("chief keef", None)
        self.assertEqual(_unknown_names("I met Zendaya downtown", "Chief Keef"), ["zendaya"])

    def test_greeting_card_end_needs_a_vault_end_word(self):
        import frontier_v5
        from frontier_v5 import _hard_check_bars, greeting_end_blocked

        frontier_v5._VAULT_END_CACHE["drake"] = {"conversation"}
        try:
            self.assertFalse(greeting_end_blocked("conversation", "Drake"))
            self.assertTrue(greeting_end_blocked("therapeutic", "Drake"))
            self.assertTrue(greeting_end_blocked("hesitation", "Drake"))
            self.assertTrue(greeting_end_blocked("destination", "Drake"))
            self.assertFalse(greeting_end_blocked("phone", "Drake"))
            self.assertFalse(greeting_end_blocked("eight", "Gunna"))
            shape = Shape(4, 1, "verse", 0, 140.0, "")
            blocked = Plan(
                motif_chain=("come_up_hustle",),
                end_words=("therapeutic",),
                couplet_voices=("Drake",),
                rhyme_families=(("therapeutic",),),
                double_meaning_slots=(),
                planner_model="test",
                plan_valid=True,
            )
            kwargs = dict(
                syllable_fn=lambda text: 4,
                inner_fn=lambda text, cmu: [{}, {}],
                rhyme_fn=lambda word, family, cmu: True,
            )
            hit = measure_bar(
                0, "I need this therapeutic", blocked,
                _line("vault line the writer never sees", "therapeutic"),
                shape, cmu={}, **kwargs,
            )
            self.assertIn("vault_end", hit["codes"])
            allowed_plan = Plan(
                motif_chain=("come_up_hustle",),
                end_words=("conversation",),
                couplet_voices=("Drake",),
                rhyme_families=(("conversation",),),
                double_meaning_slots=(),
                planner_model="test",
                plan_valid=True,
            )
            clean = measure_bar(
                0, "we had a conversation", allowed_plan,
                _line("vault line the writer never sees", "conversation"),
                shape, cmu={}, **kwargs,
            )
            self.assertNotIn("vault_end", clean["codes"])
            reasons = _hard_check_bars(
                ["we kept it therapeutic"], voice="Drake",
            )
            self.assertTrue(any("greeting-card end word therapeutic" in reason for reason in reasons["reasons"]))
        finally:
            frontier_v5._VAULT_END_CACHE.pop("drake", None)

    def test_split_block_plan_snaps_onto_a_vault_family(self):
        import contextlib
        import io

        import frontier_v5
        from frontier_v5 import _block_plan_ok

        # Captured gpt-4o-mini repair body. The words are in the top menu and
        # the JSON parses. They are not one rime family, so the old path
        # replaced them with the v3 greeting-card bank.
        raw = {
            "motif_chain": [
                "grind hard, never sleep, always on the move",
                "stacking paper, dreams alive, gotta make it prove",
                "from the bottom, rising up, we gon' take the crown",
                "never backin' down, always holdin' it down",
            ],
            "couplet_voices": ["Drake", "Drake", "Drake", "Drake"],
            "end_words": ["money", "down", "niggas", "love", "again", "that", "though", "here"],
            "rhyme_families": [
                ["money", "down", "niggas", "love"],
                ["again", "that", "though", "here"],
            ],
            "double_meaning_slots": [],
            "wordplay_hint_index": None,
            "wordplay_bar_index": None,
        }
        menu = [
            "night", "light", "fight", "sight",
            "money", "down", "niggas", "love", "again", "that", "though", "here",
        ]

        def sample_fn(voice, count=8, dedupe_window=16):
            return list(menu)

        calls = []

        def call_fn(system, user):
            calls.append((system, user))
            return json.dumps(raw)

        frontier_v5._PLAN_RAW_LOGGED = False
        shape = shape_v5({"bpm": 140, "section_mode": "verse", "bars": 8})
        buf = io.StringIO()
        with contextlib.redirect_stderr(buf):
            plan = plan_v5(shape, "Gunna", call_fn=call_fn, sample_fn=sample_fn)
        logged = buf.getvalue()
        self.assertEqual(len(calls), 3)
        self.assertNotEqual(plan.planner_model, "heuristic_fallback")
        self.assertEqual(
            plan.end_words,
            ("night", "light", "fight", "sight", "night", "light", "fight", "sight"),
        )
        self.assertTrue(_block_plan_ok(plan.end_words))
        self.assertNotIn("grind hard", " ".join(plan.motif_chain))
        self.assertIn("plan raw response", logged)
        self.assertIn("money", logged)
        self.assertEqual(frontier_v5._planner_menu(["tonight"], 4), ["tonight"])

    def test_block_rejects_a_repeat_and_an_unplanned_filler(self):
        from frontier_v5 import _plan_from_json, block_end_problems

        problems = block_end_problems(
            ["night", "light", "light", "sight"],
            ["night", "light", "fight", "sight"],
        )
        self.assertIn((2, "repeated", "light"), problems)
        filler = block_end_problems(
            ["her", "light", "fight", "sight"],
            ["night", "light", "fight", "sight"],
        )
        self.assertTrue(any(kind == "filler" and word == "her" for _, kind, word in filler))
        planned_filler = block_end_problems(
            ["shit", "grit", "split", "lit"],
            ["shit", "grit", "split", "lit"],
        )
        self.assertFalse(any(kind == "filler" for _, kind, _ in planned_filler))
        self.assertFalse(any(kind == "repeated" for _, kind, _ in planned_filler))
        rejected = _plan_from_json(
            {
                "motif_chain": ["a", "b"],
                "couplet_voices": ["Gunna", "Gunna"],
                "end_words": ["night", "night", "light", "fight"],
                "rhyme_families": [["night"], ["light"]],
            },
            4, "Gunna", "", {"night", "light", "fight", "sight"}, "test",
        )
        self.assertIsNone(rejected)
        accepted = _plan_from_json(
            {
                "motif_chain": ["a", "b"],
                "couplet_voices": ["Gunna", "Gunna"],
                "end_words": ["night", "light", "fight", "sight"],
                "rhyme_families": [["night"], ["sight"]],
            },
            4, "Gunna", "", {"night", "light", "fight", "sight"}, "test",
        )
        self.assertIsNotNone(accepted)
        self.assertEqual(accepted.end_words, ("night", "light", "fight", "sight"))

    def test_chip_match_is_a_whole_word(self):
        self.assertFalse(chip_matches_bar("rat", "I'll smack a phony with a ratchet"))
        self.assertFalse(chip_matches_bar("choppa", "that ch-cho-cho-cho-choppa bottles"))
        self.assertTrue(chip_matches_bar("choppa", "pass the choppa, then move"))
        self.assertTrue(chip_matches_bar("Cuban link", "ice on the Cuban link tonight"))

    def test_pass_column_requires_verified(self):
        import importlib.util

        path = Path(__file__).resolve().parent / "eval" / "run_taste30.py"
        spec = importlib.util.spec_from_file_location("run_taste30_under_test", path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        missed = module._verse_arm_stats(
            ["bar one, here"],
            {"verified": False, "judge_rejected": False},
            ["rat"],
        )
        self.assertFalse(missed["passed"])
        whole = module._verse_arm_stats(
            ["pass the choppa, now"],
            {"verified": True, "prompt_tokens": 3, "completion_tokens": 1, "cost_usd": 0.01},
            ["choppa"],
        )
        self.assertTrue(whole["passed"])
        self.assertEqual(whole["chip_rate"], 1.0)
        self.assertEqual(whole["prompt_tokens"], 3)
        self.assertEqual(whole["cost_usd"], 0.01)
        stutter = module._verse_arm_stats(
            ["that ch-cho-cho-cho-choppa bottles, yeah"],
            {"verified": True},
            ["choppa"],
        )
        self.assertEqual(stutter["chip_rate"], 0.0)
        gated = module._verse_arm_stats(
            ["bar one, here"],
            {"verified": False, "violations": [{"bar_index": 0, "codes": ["syllables", "end_word"]}]},
            [],
        )
        self.assertEqual(gated["gates"], {"syllables": 1, "end_word": 1})

    def test_edit_retry_changes_only_that_bar(self):
        shape = shape_v5({"bpm": 140, "bars": 2})
        plan = _plan()
        good = [
            "Clock on the block, rain on the curb, light on the glass, landing tonight",
            "Chain on the seat, gold on the hand, ring on the glass, foreign mercedes",
        ]
        scaffold = (_line(good[0], "tonight"), _line(good[1], "mercedes"))
        verse = Verse(bars=[Bar(0, good[0], "tonight", "Gunna"), Bar(1, "bad yesterday", "mercedes", "Gunna")], model="first")

        def call_fn(system, user):
            self.assertIn("retry this bar only", user)
            self.assertIn("Bar 2", user)
            return "Bar 2: " + good[1]

        edited = edit_v5(plan, scaffold, shape, "Gunna", call_fn=call_fn, only_index=1, violations=["end_word"], verse=verse)
        self.assertEqual(edited.bars[0].text, good[0])
        self.assertEqual(edited.bars[1].text, good[1])

    def test_select_uses_the_score_only_when_the_gate_is_open(self):
        def verse(text, verified, score=None):
            return VerifiedVerse(
                verse=Verse(bars=[Bar(0, text, "tonight", "Gunna")], model="test"),
                violations=[] if verified else [{"bar_index": 0, "codes": ["syllables"]}],
                verified=verified,
                retries_used=0,
                retries_exhausted=False,
                measures=[],
                style_score=score,
            )

        low = verse("low", True, 0.2)
        high = verse("high", True, 0.9)
        closed = select_v5([low, high], score_fn=lambda text: 0.1, gate_open=False)
        self.assertEqual(closed.verse.bars[0].text, "low")
        self.assertEqual(closed.style_score, 0.2)
        opened = select_v5([low, high], score_fn=lambda text: 0.1, gate_open=True)
        self.assertEqual(opened.verse.bars[0].text, "high")
        unverified = verse("first", False, 0.99)
        later = verse("second", True, 0.1)
        picked = select_v5([unverified, later], score_fn=lambda text: 0.5, gate_open=False)
        self.assertEqual(picked.verse.bars[0].text, "second")

    def test_generate_verifies_records_and_cache_hits(self):
        lines = [
            "Clock on the block, rain on the curb, light on the glass, landing tonight",
            "Chain on the seat, gold on the hand, ring on the glass, foreign light",
        ]
        calls = {"n": 0}

        def sample_fn(voice, count=8, dedupe_window=16):
            return ["tonight", "light"]

        def retrieve_fn(**kwargs):
            return [{
                "id": 7,
                "text": lines[0],
                "end_word": "tonight",
                "artist": "Gunna",
                "song": "One",
                "album": "Wunna",
                "is_iconic_anthem": 0,
                "match_score": 10,
            }]

        def call_fn(system, user):
            calls["n"] += 1
            if "V5 PLAN" in user:
                return json.dumps({
                    "motif_chain": ["lavishness_money"],
                    "couplet_voices": ["Gunna"],
                    "end_words": ["tonight", "light"],
                    "rhyme_families": [["tonight", "light"]],
                })
            return "\n".join(f"Bar {index + 1}: {line}" for index, line in enumerate(lines))

        user = {"bpm": 140, "section_mode": "verse", "bars": 2, "seed_line": "seed"}
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            telemetry = root / "v5_telemetry.jsonl"
            history = root / "end_word_history.jsonl"
            cache = root / "cache"
            shape = shape_v5(user)
            result = generate_v5(
                user,
                voice="Gunna",
                topic_hint="night",
                use_cache=True,
                call_fn=call_fn,
                sample_fn=sample_fn,
                retrieve_fn=retrieve_fn,
                score_fn=lambda text: 0.91,
                gate_open=False,
                telemetry_path=telemetry,
                history_path=history,
                cache_dir=cache,
                max_retries=2,
                cmu={},
                syllable_fn=lambda text: shape.syl_budget,
                inner_fn=lambda text, cmu: [{}, {}],
                rhyme_fn=lambda word, family, cmu: True,
            )
            self.assertTrue(result["verified"])
            self.assertEqual(result["version"], "v5")
            self.assertIn("landing tonight", result["raw_text"])
            self.assertEqual(result["plan"]["double_meaning_slots"], [1])
            rows = [json.loads(line) for line in telemetry.read_text(encoding="utf-8").splitlines()]
            self.assertEqual(len(rows), 2)
            self.assertEqual(rows[0]["scaffold_source"], "catalog")
            self.assertEqual(rows[0]["target_syl"], shape.syl_budget)
            self.assertIn("inner_rhyme_count", rows[0])
            self.assertIn("violations", rows[0])
            history_text = history.read_text(encoding="utf-8")
            self.assertIn("tonight", history_text)
            self.assertTrue(any(cache.glob("*.json")))

            def boom(system, user):
                raise AssertionError("cache hit should skip the pipeline")

            again = generate_v5(
                user,
                voice="Gunna",
                topic_hint="night",
                use_cache=True,
                call_fn=boom,
                cache_dir=cache,
                telemetry_path=root / "unused.jsonl",
                history_path=root / "unused_history.jsonl",
            )
            self.assertTrue(again["cached"])
            self.assertEqual(again["raw_text"], result["raw_text"])

    def test_unverified_verse_is_not_cached(self):
        shape = shape_v5({"bpm": 140, "bars": 1})
        plan = _plan(1, ("tonight",))
        line = _line("No catalog line, bank lands tonight", "tonight", source="bank")
        winner = VerifiedVerse(
            verse=Verse(bars=[Bar(0, line.text, "tonight", "Gunna")], model="test"),
            violations=[{"bar_index": 0, "codes": ["bank"]}],
            verified=False,
            retries_used=0,
            retries_exhausted=False,
            measures=[{
                "bar_index": 0,
                "codes": ["bank"],
                "scaffold_distance": 0,
                "scaffold_cap": 1,
                "end_word_ok": True,
                "rhyme_family_ok": False,
                "inner_rhyme_count": 0,
                "inner_rhyme_ok": False,
                "actual_syl": 8,
                "delta": -7,
                "syllable_ok": False,
                "commas": 0,
                "comma_ok": False,
                "name_guard_ok": True,
                "punch_demoted": False,
                "plan_hit": False,
            }],
            style_score=0.91,
            plan=plan,
            shape=shape,
            scaffold=(line,),
        )
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            from frontier_v5 import record_v5
            params = cache_params_v5(shape, "Gunna")
            key = compute_cache_key(params)
            record_v5(
                winner,
                shape,
                plan,
                (line,),
                "Gunna",
                cache_key=key,
                cache_params=params,
                telemetry_path=root / "v5_telemetry.jsonl",
                history_path=root / "end_word_history.jsonl",
                cache_dir=root / "cache",
            )
            self.assertEqual(list((root / "cache").glob("*.json")), [])
            self.assertIsNone(get_cached_verse(key, cache_dir=root / "cache"))

    def test_vault_frequency_ranks_a_frequent_family_first(self):
        from frontier_v5 import _FAMILY_DROP, _families_from_song_lines

        night = []
        seq = 1
        for _ in range(4):
            night.append(("night", seq))
            seq += 1
            night.append(("light", seq))
            seq += 1
        night.append(("fight", seq))
        seq += 1
        night.append(("sight", seq))
        songs = [
            night,
            [("ghost", 1), ("most", 2), ("coast", 3), ("toast", 4)],
            [("you", 1), ("do", 2), ("you", 3), ("do", 4)],
        ]
        ranked = _families_from_song_lines(songs)
        self.assertGreaterEqual(len(ranked), 2)
        self.assertEqual(ranked[0][2], 5)
        self.assertEqual(ranked[0][1][:2], ["light", "night"])
        self.assertEqual(ranked[1][2], 2)
        self.assertEqual(set(ranked[1][1]), {"coast", "ghost", "most", "toast"})
        self.assertGreater(ranked[0][2], ranked[1][2])
        flat = [word for _rime, words, _count in ranked for word in words]
        self.assertNotIn("you", flat)
        self.assertNotIn("do", flat)
        self.assertTrue(all(word not in _FAMILY_DROP for word in flat))

    def test_rhyme_family_is_used_once_then_the_next_vault_family(self):
        import frontier_v5
        from frontier_v5 import (
            _note_run_families,
            _snap_diverse,
            enable_run_rhyme_once,
            reset_run_rhyme_families,
            run_rhyme_family_report,
        )

        groups = [
            ["light", "night", "fight", "sight"],
            ["coast", "ghost", "most", "toast"],
        ]
        enable_run_rhyme_once(True)
        reset_run_rhyme_families()
        try:
            both = _snap_diverse(groups, 8)
            self.assertEqual(
                both,
                ("light", "night", "fight", "sight", "coast", "ghost", "most", "toast"),
            )
            _note_run_families(("light", "night", "fight", "sight"))
            nxt = _snap_diverse(groups, 4)
            self.assertEqual(nxt, ("coast", "ghost", "most", "toast"))
            _note_run_families(nxt)
            again = _snap_diverse(groups, 4)
            self.assertEqual(again, ("light", "night", "fight", "sight"))
            _note_run_families(again)
            by_label = {row["label"]: row["count"] for row in run_rhyme_family_report()}
            self.assertEqual(by_label["light/night/fight/sight"], 2)
            self.assertEqual(by_label["coast/ghost/most/toast"], 1)
        finally:
            enable_run_rhyme_once(False)
            reset_run_rhyme_families()
            self.assertFalse(frontier_v5._RUN_RHYME_ONCE)
            self.assertEqual(frontier_v5._RUN_RHYME_USED, {})

    def test_cliche_and_incomplete_bars_fail(self):
        from frontier_v5 import CLICHE_PHRASES, _hard_check_bars, cliche_hits

        self.assertEqual(len(CLICHE_PHRASES), 61)
        self.assertIn(("chasing", "dreams"), CLICHE_PHRASES)
        self.assertIn(("in", "the", "shadows"), CLICHE_PHRASES)
        self.assertIn(("grinding", "hard"), CLICHE_PHRASES)
        self.assertIn(("hustle", "hard"), CLICHE_PHRASES)
        self.assertNotIn(("built", "for"), CLICHE_PHRASES)
        self.assertNotIn(("never", "fading"), CLICHE_PHRASES)
        self.assertEqual(cliche_hits("Chasing dreams through the fire"), ["chasing dreams"])
        self.assertEqual(cliche_hits("never before"), [])
        shape = Shape(8, 1, "verse", 0, 140.0, "")
        kwargs = dict(
            syllable_fn=lambda text: 8,
            inner_fn=lambda text, cmu: [{}, {}],
            rhyme_fn=lambda word, family, cmu: True,
        )
        built = measure_bar(
            0, "I was built for",
            _plan(1, ("for",)),
            _line("vault line the writer never sees", "for"),
            shape, cmu={}, **kwargs,
        )
        self.assertIn("incomplete", built["codes"])
        self.assertNotIn("cliche", built["codes"])
        chasing = measure_bar(
            0, "Chasing dreams through the night",
            _plan(1, ("night",)),
            _line("vault line the writer never sees", "night"),
            shape, cmu={}, **kwargs,
        )
        self.assertIn("cliche", chasing["codes"])
        self.assertNotIn("incomplete", chasing["codes"])
        before = measure_bar(
            0, "I made it never before",
            _plan(1, ("before",)),
            _line("vault line the writer never sees", "before"),
            shape, cmu={}, **kwargs,
        )
        self.assertNotIn("incomplete", before["codes"])
        self.assertNotIn("cliche", before["codes"])
        hard = _hard_check_bars(
            ["I was built for", "Chasing dreams through the night"], voice="Drake",
        )
        self.assertTrue(any(reason.startswith("incomplete end word for") for reason in hard["reasons"]))
        self.assertTrue(any("cliche chasing dreams" in reason for reason in hard["reasons"]))
        clean = _hard_check_bars(["I made it never before"], voice="Drake")
        self.assertFalse(any("incomplete" in reason for reason in clean["reasons"]))

    def test_artist_vault_families_outrank_closed_class(self):
        from frontier_v5 import _FAMILY_DROP, _vault_rhyme_families

        drake = _vault_rhyme_families("Drake")
        wayne = _vault_rhyme_families("Lil Wayne")
        keef = _vault_rhyme_families("Chief Keef")
        self.assertGreaterEqual(len(drake), 10)
        self.assertGreaterEqual(len(wayne), 10)
        self.assertIs(keef, wayne)
        self.assertGreater(drake[0][2], drake[1][2])
        for _rime, words, count in drake[:8]:
            self.assertGreaterEqual(count, 1)
            self.assertGreaterEqual(len(words), 4)
            self.assertTrue(all(word not in _FAMILY_DROP and len(word) >= 2 for word in words))
        self.assertNotIn(drake[0][1][0], {"you", "do", "me", "be", "to"})


class DeskV5FlagTests(unittest.TestCase):
    def test_desk_default_is_v5_and_retired_v4_names_call_v5(self):
        import desk

        v5_payload = {"ok": True, "version": "v5", "raw_text": "one line tonight"}
        with patch("frontier_v5.generate_v5", return_value=v5_payload) as mock_v5, \
                patch("polish.generate_frontier_bars_v2", return_value={"ok": True, "version": "v2"}) as mock_v2:
            res = desk.run_live_generation(Path("."), {
                "adapter": "v5",
                "voice": "Gunna",
                "bars": 4,
                "bpm": 140,
                "section_mode": "verse",
            })
            self.assertEqual(res["version"], "v5")
            self.assertEqual(res["adapter_used"], "v5")
            self.assertEqual(mock_v5.call_count, 1)
            args, kwargs = mock_v5.call_args
            self.assertEqual(kwargs["voice"], "Gunna")
            self.assertEqual(args[0]["bars"], 4)
            self.assertEqual(args[0]["bpm"], 140.0)
            self.assertEqual(args[0]["section_mode"], "verse")
            self.assertTrue(kwargs["use_cache"])
            mock_v2.assert_not_called()

            alias = desk.run_live_generation(Path("."), {"adapter": "frontier_v5", "voice": "Gunna", "bars": 4})
            self.assertEqual(alias["adapter_used"], "frontier_v5")

            for retired in ("v4", "frontier_v4"):
                retired_res = desk.run_live_generation(Path("."), {
                    "adapter": retired,
                    "voice": "Gunna",
                    "bars": 4,
                })
                self.assertEqual(retired_res["version"], "v5", retired)
                self.assertEqual(retired_res["adapter_used"], "frontier_v5", retired)

            default = desk.run_live_generation(Path("."), {"voice": "Gunna", "bars": 4})
            self.assertEqual(default["version"], "v5")
            self.assertEqual(default["adapter_used"], "frontier_v5")
            self.assertEqual(mock_v5.call_count, 5)

            old = desk.run_live_generation(Path("."), {
                "adapter": "frontier_v3",
                "voice": "Gunna",
                "bars": 4,
            })
            self.assertEqual(old["version"], "v2")
            self.assertEqual(mock_v2.call_count, 1)
            self.assertEqual(mock_v5.call_count, 5)


class V5AbReportTests(unittest.TestCase):
    def test_mean_entropy_and_inner_count_leave_v5_blank(self):
        from v5_ab_report import build_report, mean_score, verse_scores

        self.assertEqual(verse_scores([
            {"verse_score": 8},
            {"verse_score": 2, "skipped": True},
            {"verse_score": 0},
            {"verse_score": 4},
        ]), [8.0, 4.0])
        self.assertEqual(mean_score([{"verse_score": 8}, {"verse_score": 2}])["mean"], 5.0)

        def detect(line, cmu):
            return [{}] if "squeeze" in line else []

        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            deck = {
                "cards": [{
                    "generation_id": "v4_one",
                    "lines": ["The lemon squeeze", "A plain night"],
                    "end_words": ["squeeze", "night"],
                }],
            }
            ratings = {
                "schema": "sparkler.ratings.v1",
                "exported_at": "2026-10-26T14:45:36.490Z",
                "ratings": [
                    {"generation_id": "v4_one", "verse_score": 8},
                    {"generation_id": "other", "verse_score": 1},
                ],
            }
            deck_path = root / "deck.json"
            ratings_path = root / "ratings.json"
            missing_v5 = root / "no-v5.json"
            deck_path.write_text(json.dumps(deck), encoding="utf-8")
            ratings_path.write_text(json.dumps(ratings), encoding="utf-8")
            report = build_report(deck_path, ratings_path, missing_v5, cmu={})
            # The fixture detector is not the default. Recompute through engine_block.
            from v5_ab_report import engine_block
            block = engine_block("v4", deck["cards"], ratings["ratings"], {}, detect)
            self.assertEqual(block["mean_score"], 8.0)
            self.assertEqual(block["rated"], 1)
            self.assertEqual(block["bars"], 2)
            self.assertEqual(block["cards"][0]["inner_rhyme_count_per_bar"], [1, 0])
            self.assertEqual(block["inner_rhyme_count_per_bar_mean"], 0.5)
            self.assertGreater(block["end_word_entropy_bits"], 0)
            self.assertEqual(report["v5"]["verses"], 0)
            self.assertIsNone(report["v5"]["mean_score"])
            self.assertIn("not generated", report["v5"]["note"])


if __name__ == "__main__":
    unittest.main()
