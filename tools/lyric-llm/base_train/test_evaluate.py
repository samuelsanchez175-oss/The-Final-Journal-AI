#!/usr/bin/env python3
"""D4 harness tests. The OpenAI client is a fake. No network call."""

from __future__ import annotations

import contextlib
import io
import json
import math
import os
import sys
import tempfile
import unittest
from pathlib import Path

from base_train import evaluate as ev
from inner_rhyme_check import count_bar_syllables

HERE = Path(__file__).resolve().parent
LYRIC = HERE.parent
LIVE_COMPARE = LYRIC / "out" / "compare_50k_vs_full.md"
LIVE_COMPARE_EXISTS = LIVE_COMPARE.exists()

MODEL_A = "ft:gpt-4o-mini:org:v5-base-mini-50k:abc"
MODEL_B = "ft:gpt-4o-mini:org:v5-base-mini-full:def"
SENTINEL = "SENTINEL_LYRIC"
SECRET = "sk-test-do-not-print"


def chat_row(artist: str, end_word: str, fim: bool = False) -> dict:
    syllables = count_bar_syllables(end_word, {})
    if fim:
        system = "Write the missing bar. Context above and below is from the same song."
        user = (
            f"<voice: {artist}>\n"
            f"ABOVE: prev bar\n"
            f"BELOW: next bar\n"
            f"END_WORD: {end_word}\n"
            f"SYLLABLES: {syllables}"
        )
    else:
        system = ev.SYSTEM_PROMPT
        user = (
            f"<voice: {artist}> <section: verse> <bar 7 of 16>\n"
            f"PREV_BAR: prev bar\n"
            f"TOPIC: luxury_drip\n"
            f"END_WORD: {end_word}\n"
            f"SYLLABLES: {syllables}"
        )
    return {
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
            {"role": "assistant", "content": f"{SENTINEL} gold {end_word}"},
        ]
    }


def write_jsonl(path: Path, rows: list[dict]) -> None:
    with path.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row))
            handle.write("\n")


def win_rows() -> list[dict]:
    rows = []
    for artist in ("Gunna", "Lil Baby"):
        for index in range(5):
            rows.append(chat_row(artist, "mercedes", fim=(artist == "Gunna" and index == 0)))
        rows.append(chat_row(artist, "coupe"))
    return rows


class SplitClient:
    """50k matches the end word. full returns a rhyming line and a cheap token count."""

    def __init__(self):
        self.held = {"50k": [], "full": []}
        self.voice = {"50k": [], "full": []}

    def generate(self, model, messages):
        slot = "50k" if "50k" in model else "full"
        user = messages[-1]["content"]
        voice = "END_WORD:" not in user
        if voice:
            self.voice[slot].append(user)
            text = "mercedes" if slot == "50k" else "unrelated"
        else:
            self.held[slot].append(user)
            if slot == "50k":
                text = ev._field_map(user)["END_WORD"]
            else:
                text = "drip trip banana"
        if slot == "50k":
            return ev.GenResult(text, 1000, 100, [-0.05, -0.05])
        return ev.GenResult(text, 10, 2, [-2.0, -2.0])


class SameClient:
    def generate(self, model, messages):
        return ev.GenResult("mercedes", 20, 4, [-0.2, -0.2])


class RecordClient:
    def __init__(self):
        self.held = {"50k": [], "full": []}

    def generate(self, model, messages):
        slot = "50k" if "50k" in model else "full"
        self.held[slot].append(messages[-1]["content"])
        return ev.GenResult("mercedes", 5, 5, [-0.1])


class EvaluateTests(unittest.TestCase):
    def test_spearman_identity_and_reversal(self):
        dist = {"mercedes": 5.0, "coupe": 1.0}
        self.assertAlmostEqual(ev.spearman(dist, dict(dist)), 1.0)
        left = {"a": 1.0, "b": 2.0, "c": 3.0}
        right = {"a": 3.0, "b": 2.0, "c": 1.0}
        self.assertAlmostEqual(ev.spearman(left, right), -1.0)
        self.assertIsNone(ev.spearman({"only": 1.0}, {"only": 4.0}))

    def test_metric_rules(self):
        self.assertEqual(ev.metric_winner(None, None, "lower"), "tie")
        self.assertEqual(ev.metric_winner(None, 1.0, "lower"), "tie")
        self.assertEqual(ev.metric_winner(1.0, 1.0, "higher"), "tie")
        self.assertEqual(ev.metric_winner(1.0, 2.0, "lower"), "50k")
        self.assertEqual(ev.metric_winner(1.0, 2.0, "higher"), "full")
        self.assertEqual(ev.overall_winner(4, 2), "50k wins")
        self.assertEqual(ev.overall_winner(2, 4), "full wins")
        self.assertEqual(ev.overall_winner(4, 4), "tie")
        self.assertEqual(ev.overall_winner(3, 1), "tie")

    def test_perplexity_and_cost(self):
        self.assertIsNone(ev.perplexity([]))
        self.assertAlmostEqual(ev.perplexity([[-1.0, -1.0]]), math.e)
        self.assertAlmostEqual(ev.cost_per_1000(1_000_000, 0, 1000, True), 0.30)
        self.assertAlmostEqual(ev.cost_per_1000(0, 1_000_000, 1000, True), 1.20)
        self.assertAlmostEqual(ev.cost_per_1000(1_000_000, 0, 1000, False), 0.15)
        self.assertAlmostEqual(ev.cost_per_1000(0, 1_000_000, 1000, False), 0.60)

    def test_parse_chat_response(self):
        class Tok:
            logprob = -0.2

        class Choice:
            class message:
                content = " mercedes "

            logprobs = type("LP", (), {"content": [Tok(), {"logprob": -0.4}]})()

        class Resp:
            choices = [Choice()]
            usage = {"prompt_tokens": 3, "completion_tokens": 4}

        got = ev.parse_chat_response(Resp())
        self.assertEqual(got.text, "mercedes")
        self.assertEqual(got.logprobs, [-0.2, -0.4])
        self.assertEqual(got.prompt_tokens, 3)
        self.assertEqual(got.completion_tokens, 4)

    def test_sample_is_stable_and_ordered(self):
        picked = ev.sample_rows(list(range(20)), 5, 7)
        self.assertEqual(picked, sorted(picked))
        self.assertEqual(len(picked), 5)
        self.assertEqual(picked, ev.sample_rows(list(range(20)), 5, 7))
        self.assertEqual(ev.sample_rows(list(range(3)), 10, 7), [0, 1, 2])

    def test_fim_row_parses(self):
        parsed = ev.parse_example(chat_row("Gunna", "mercedes", fim=True))
        self.assertIsNotNone(parsed)
        self.assertEqual(parsed.artist, "Gunna")
        self.assertEqual(parsed.end_word, "mercedes")
        self.assertIn("ABOVE:", parsed.user)
        self.assertEqual(parsed.prev_text, "prev bar")

    def test_inner_rhyme_and_syllable_gap(self):
        self.assertEqual(ev.inner_rhyme_count("mercedes", {}), 0)
        self.assertGreaterEqual(ev.inner_rhyme_count("drip trip banana", {}), 1)
        short = count_bar_syllables("mercedes", {})
        long = count_bar_syllables("drip trip banana", {})
        self.assertGreater(abs(long - short), 1)
        self.assertGreater(abs(long - count_bar_syllables("coupe", {})), 1)

    def test_50k_wins_four_metrics(self):
        client = SplitClient()
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            fixture = root / "fixture.jsonl"
            out = root / "compare.md"
            write_jsonl(fixture, win_rows())
            secret = os.environ.get("OPENAI_API_KEY")
            os.environ["OPENAI_API_KEY"] = SECRET
            stdout = io.StringIO()
            try:
                with contextlib.redirect_stdout(stdout):
                    code = ev.main(
                        [
                            "--model-a", MODEL_A,
                            "--model-b", MODEL_B,
                            "--fixture", str(fixture),
                            "--out", str(out),
                        ],
                        client=client,
                        cmu={},
                    )
            finally:
                if secret is None:
                    os.environ.pop("OPENAI_API_KEY", None)
                else:
                    os.environ["OPENAI_API_KEY"] = secret
            self.assertEqual(code, 0)
            report = out.read_text(encoding="utf-8")
        self.assertIn("Overall: 50k wins", report)
        self.assertNotIn("Overall: full wins", report)
        self.assertIn("50k metric wins: 4. full metric wins: 2.", report)
        self.assertIn("not gold-bar next-token loss", report)
        self.assertNotIn(SENTINEL, report)
        self.assertNotIn(SECRET, report)
        self.assertNotIn(SECRET, stdout.getvalue())
        self.assertIn("overall=50k wins", stdout.getvalue())
        self.assertEqual(client.held["50k"], client.held["full"])
        self.assertEqual(len(client.held["50k"]), 12)
        self.assertTrue(any("ABOVE:" in prompt for prompt in client.held["50k"]))
        self.assertEqual(len(client.voice["50k"]), 12)
        self.assertTrue(all("END_WORD:" not in prompt for prompt in client.voice["50k"]))
        self.assertTrue(all("SYLLABLES:" not in prompt for prompt in client.voice["50k"]))
        self.assertIn("<voice: Gunna>", client.voice["50k"][0])
        self.assertIn("Calls: 48", report)
        self.assertIn("The fixture has fewer than 400 bars, so every bar was scored.", report)
        self.assertNotIn("openai", sys.modules)

    def test_identical_models_tie(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            fixture = root / "fixture.jsonl"
            out = root / "compare.md"
            write_jsonl(fixture, win_rows())
            with contextlib.redirect_stdout(io.StringIO()):
                ev.main(
                    [
                        "--model-a", MODEL_A,
                        "--model-b", MODEL_B,
                        "--fixture", str(fixture),
                        "--out", str(out),
                    ],
                    client=SameClient(),
                    cmu={},
                )
            report = out.read_text(encoding="utf-8")
        self.assertIn("Overall: tie", report)
        self.assertIn("50k metric wins: 0. full metric wins: 0.", report)
        self.assertNotIn("50k wins", report.split("Overall: ", 1)[1])

    def test_limit_scores_400(self):
        rows = [chat_row("Drake", "mercedes") for _ in range(401)]
        client = RecordClient()
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            fixture = root / "fixture.jsonl"
            out = root / "compare.md"
            write_jsonl(fixture, rows)
            with contextlib.redirect_stdout(io.StringIO()):
                ev.main(
                    [
                        "--model-a", MODEL_A,
                        "--model-b", MODEL_B,
                        "--fixture", str(fixture),
                        "--out", str(out),
                        "--voice-n", "0",
                    ],
                    client=client,
                    cmu={},
                )
            report = out.read_text(encoding="utf-8")
        self.assertIn("Scored 400 of 401.", report)
        self.assertNotIn("fewer than", report)
        self.assertEqual(len(client.held["50k"]), 400)
        self.assertEqual(client.held["50k"], client.held["full"])
        self.assertIn("Calls: 800", report)

    def test_mlx_fixture_exits(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            fixture = root / "test.jsonl"
            out = root / "compare.md"
            fixture.write_text(
                json.dumps({
                    "artist": "Gunna",
                    "bpm": 140,
                    "scale": "C major",
                    "song_id": "abc",
                    "text": "not a chat row",
                }) + "\n",
                encoding="utf-8",
            )
            stderr = io.StringIO()
            with contextlib.redirect_stderr(stderr):
                with self.assertRaises(SystemExit) as caught:
                    ev.main(
                        [
                            "--model-a", MODEL_A,
                            "--model-b", MODEL_B,
                            "--fixture", str(fixture),
                            "--out", str(out),
                        ],
                        cmu={},
                    )
            self.assertEqual(caught.exception.code, 2)
            message = stderr.getvalue()
            self.assertIn("out/test.jsonl is the MLX song split.", message)
            self.assertIn("out/test_50k_fim.jsonl", message)
            self.assertFalse(out.exists())

    def test_missing_key_and_hidden_import_error(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            fixture = root / "fixture.jsonl"
            out = root / "compare.md"
            write_jsonl(fixture, [chat_row("Gunna", "mercedes")])
            argv = [
                "--model-a", MODEL_A,
                "--model-b", MODEL_B,
                "--fixture", str(fixture),
                "--out", str(out),
                "--voice-n", "0",
            ]
            saved_key = os.environ.pop("OPENAI_API_KEY", None)
            saved_file = os.environ.get("OPENAI_ENV_FILE")
            os.environ["OPENAI_ENV_FILE"] = str(root / "missing.env")
            stderr = io.StringIO()
            try:
                with contextlib.redirect_stderr(stderr):
                    with self.assertRaises(SystemExit) as caught:
                        ev.main(argv, cmu={})
                self.assertEqual(caught.exception.code, 1)
                self.assertIn("missing .env.openai", stderr.getvalue())
                self.assertNotIn(SECRET, stderr.getvalue())
                self.assertFalse(out.exists())

                if "openai" in sys.modules:
                    self.skipTest("openai sdk is installed")
                os.environ["OPENAI_API_KEY"] = SECRET
                os.environ.pop("OPENAI_ENV_FILE", None)
                stderr = io.StringIO()
                stdout = io.StringIO()
                with contextlib.redirect_stderr(stderr), contextlib.redirect_stdout(stdout):
                    with self.assertRaises(SystemExit) as caught:
                        ev.main(argv, cmu={})
                self.assertEqual(caught.exception.code, 1)
                self.assertIn("ModuleNotFoundError", stderr.getvalue())
                self.assertNotIn(SECRET, stderr.getvalue())
                self.assertNotIn(SECRET, stdout.getvalue())
                self.assertFalse(out.exists())
            finally:
                if saved_key is None:
                    os.environ.pop("OPENAI_API_KEY", None)
                else:
                    os.environ["OPENAI_API_KEY"] = saved_key
                if saved_file is None:
                    os.environ.pop("OPENAI_ENV_FILE", None)
                else:
                    os.environ["OPENAI_ENV_FILE"] = saved_file

    def test_source_has_no_secret_and_no_voice_imports(self):
        source = (HERE / "evaluate.py").read_text(encoding="utf-8")
        self.assertNotIn("sk-", source)
        self.assertNotIn("voice_evaluate", source)
        self.assertNotIn("voice_variant", source)
        self.assertNotIn("voice_briefs", source)
        self.assertNotIn("model_registry", source)
        for line in source.splitlines():
            stripped = line.strip()
            if stripped.startswith("import openai") or stripped.startswith("from openai"):
                self.assertNotEqual(line, stripped)

    def test_live_compare_was_not_written(self):
        if not LIVE_COMPARE_EXISTS:
            self.assertFalse(LIVE_COMPARE.exists())


if __name__ == "__main__":
    unittest.main()
