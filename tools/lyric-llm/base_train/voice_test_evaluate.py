#!/usr/bin/env python3
"""Voice eval tests. No network. No API key."""

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import voice_evaluate as ev  # noqa: E402
import voice_variant  # noqa: E402


def _row(artist: str, end: str, text: str, fim: bool = False) -> dict:
    example = {
        "artist": artist,
        "section": "verse",
        "line_seq": 2,
        "total_lines": 8,
        "prev_text": "previous bar",
        "topic": "untagged",
        "end_word": end,
        "syllables": 8,
        "text": text,
        "next_text": "below bar" if fim else None,
        "fim": fim,
    }
    briefs = voice_variant.load_briefs()
    return voice_variant.render_messages(example, "one_hot", briefs)


class ParseAndScoreTests(unittest.TestCase):
    def test_parse_one_hot_and_rebuild_systembrief_without_voice_token(self) -> None:
        record = _row("Gunna", "chips", "And stack my chips")
        parsed = ev.parse_example(record)
        self.assertEqual(parsed["artist"], "Gunna")
        self.assertEqual(parsed["end_word"], "chips")
        self.assertEqual(parsed["syllables"], 8)
        self.assertFalse(parsed["fim"])
        briefs = voice_variant.load_briefs()
        messages = ev.prompt_messages(parsed, "systembrief", briefs)
        self.assertEqual(messages[0]["content"], briefs["Gunna"]["brief"])
        self.assertNotIn("<voice:", messages[1]["content"])
        self.assertIn("END_WORD: chips", messages[1]["content"])

    def test_voice_match_prompt_drops_end_word(self) -> None:
        briefs = voice_variant.load_briefs()
        messages = ev.voice_match_messages("Lil Baby", "one_hot", briefs, "previous bar", "untagged")
        self.assertIn("<voice: Lil Baby>", messages[1]["content"])
        self.assertNotIn("END_WORD:", messages[1]["content"])
        self.assertNotIn("SYLLABLES:", messages[1]["content"])

    def test_end_word_syllable_leakage_and_distance(self) -> None:
        self.assertTrue(ev.end_word_match("And stack my chips", "chips"))
        self.assertFalse(ev.end_word_match("And stack my chips", "drip"))
        self.assertTrue(ev.syllable_hit("one two three", 3, {}))
        self.assertEqual(ev.leakage_count(["thugger pulled up", "plain bar"], "Gunna"), 1)
        self.assertEqual(ev.leakage_count(["dwayne stayed home"], "Gunna"), 0)
        self.assertGreater(ev.edit_distance("wunna slide", "brodie day"), 0)
        self.assertEqual(ev.edit_distance("same", "same"), 0)

    def test_spearman_perfect_and_flat(self) -> None:
        perfect = ev.spearman({"a": 3, "b": 1}, {"a": 9, "b": 2})
        self.assertAlmostEqual(perfect, 1.0)
        self.assertIsNone(ev.spearman({"a": 1}, {"a": 1}))

    def test_plan_counts_four_prompt_pairs(self) -> None:
        plan = ev.plan_calls(3211, 20, 100)
        self.assertEqual(plan["fixture"], 3211 * 4)
        self.assertEqual(plan["flip"], 160)
        self.assertEqual(plan["voice"], 800)
        self.assertEqual(plan["total"], 13804)

    def test_verdict_rules(self) -> None:
        def scores(one_hot_better: bool, brief_better: bool):
            built = {}
            for name, direction in ev.METRICS:
                if direction == "higher":
                    base, high, low = 1.0, 2.0, 0.0
                else:
                    base, high, low = 2.0, 1.0, 3.0
                built[name] = {
                    "base": base,
                    "base_brief": base,
                    "one_hot": high if one_hot_better else low,
                    "systembrief": high if brief_better else low,
                }
            return built

        self.assertEqual(ev.verdict(scores(True, False)), "one_hot wins")
        self.assertEqual(ev.verdict(scores(False, True)), "systembrief wins")
        self.assertEqual(
            ev.verdict(scores(False, False)),
            "DATASET OR BASE INSUFFICIENT — do not ship",
        )
        both = scores(True, True)
        self.assertEqual(ev.verdict(both), "tie")
        both["perplexity"]["one_hot"] = 0.5
        both["end_word_match"]["one_hot"] = 3.0
        both["syllable_precision"]["one_hot"] = 3.0
        both["voice_match"]["one_hot"] = 3.0
        both["inner_rhyme"]["one_hot"] = 3.0
        self.assertEqual(ev.verdict(both), "one_hot wins")

    def test_metric_winner_is_no_lift_when_neither_beats_baseline(self) -> None:
        self.assertEqual(ev.metric_winner("higher", 5, 4, 5, 4), "NO LIFT")
        self.assertEqual(ev.metric_winner("lower", 5, 4, 5, 6), "one_hot")


class FakeRunTests(unittest.TestCase):
    def test_fake_client_writes_eight_rows_and_does_not_need_a_key(self) -> None:
        briefs = voice_variant.load_briefs()
        examples = [
            ev.parse_example(_row("Gunna", "chips", "And stack my chips")),
            ev.parse_example(_row("Lil Baby", "hood", "back in the hood")),
            ev.parse_example(_row("Drake", "time", "another time", fim=True)),
        ]

        class Fake:
            def generate(self, model, messages):
                blob = messages[0]["content"] + "\n" + messages[1]["content"]
                if "Lil Baby" in blob or "Atlanta street rap" in blob:
                    text = "brodie moved the work today"
                elif "Gunna" in blob or "Atlanta melodic trap" in blob:
                    text = "thugger is not gunna"
                else:
                    text = "plain bar for the night"
                return ev.GenResult(text, 30, 6, [-0.2, -0.4])

        report, scores = ev.run_eval(
            examples,
            Fake(),
            briefs,
            {},
            "gpt-4o-mini",
            "ft:gpt-4o-mini:pennworkstudios:v5-base-voice-a:test",
            "ft:gpt-4o-mini:pennworkstudios:v5-base-voice-b:test",
            1,
            1,
            7,
            1,
        )
        self.assertEqual(len(ev.METRICS), 8)
        for name, _direction in ev.METRICS:
            self.assertIn(name, scores)
        self.assertIn("Verdict:", report)
        self.assertIn("| perplexity |", report)
        self.assertIn("| cross_voice_leakage |", report)
        self.assertNotIn("OPENAI_API_KEY", report)
        self.assertGreater(scores["voice_flip"]["one_hot"], 0)
        self.assertGreater(scores["cross_voice_leakage"]["one_hot"], 0)

    def test_backoff_retries_429(self) -> None:
        calls = {"n": 0}

        def call():
            calls["n"] += 1
            if calls["n"] == 1:
                raise type("Rate", (Exception,), {"status_code": 429})("slow")
            return "ok"

        slept = []
        self.assertEqual(ev.with_backoff(call, sleep=slept.append), "ok")
        self.assertEqual(slept, [1.0])

    def test_voice_eval_flag_is_required(self) -> None:
        with self.assertRaises(SystemExit):
            ev.parse_args(["--baseline", "gpt-4o-mini", "--model-a", "a", "--model-b", "b",
                           "--fixture", "x", "--out", "y"])
        args = ev.parse_args([
            "--baseline", "gpt-4o-mini", "--model-a", "a", "--model-b", "b",
            "--fixture", "x", "--voice-eval", "--out", "y",
        ])
        self.assertTrue(args.voice_eval)
        self.assertEqual(args.workers, 4)
        self.assertEqual(args.voice_n, 100)
        self.assertEqual(args.flip_n, 20)

    def test_source_does_not_log_the_key(self) -> None:
        text = Path(__file__).with_name("voice_evaluate.py").read_text(encoding="utf-8")
        self.assertNotIn("print(api_key", text)
        self.assertNotIn("print(key", text)
        self.assertIn("max_workers=workers", text)
        self.assertIn("logprobs=True", text)


if __name__ == "__main__":
    unittest.main()
