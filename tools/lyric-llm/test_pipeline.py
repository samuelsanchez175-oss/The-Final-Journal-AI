#!/usr/bin/env python3
"""Synthetic checks. These do not read the lyric catalog."""

from __future__ import annotations

import os
import tempfile
import time
import unittest
from datetime import datetime
from pathlib import Path

import json

import desk
import generate
import listen_batch
from lyriclib import (
    NearDupIndex,
    collect_voice_rows,
    control_prefix,
    corpus_bpm_syllables,
    dedupe_songs,
    dominance_flags,
    estimate_syllables,
    is_junk_line,
    line_reached_budget,
    loose_key,
    messages_for_chunk,
    normalize,
    open_originality,
    originality_hit,
    originality_score,
    index_originality,
    split_song_ids,
    target_syllables,
    tempo_line_syllables,
    tokenize,
    voice_example_counts,
    write_voice_inventory,
)
import infer


def song(artist: str, lines: list[str], bpm=None, scale=None) -> dict:
    return {
        "artist": artist,
        "title": "t",
        "bpm": bpm,
        "scale": scale,
        "lines": [{"text": text, "syl": 8} for text in lines],
    }


class PipelineTests(unittest.TestCase):
    def test_normalize_drops_adlib_parens_and_case(self):
        self.assertEqual(normalize("I Keep the DRUM (yeah)!!!"), "i keep the drum")

    def test_loose_key_drops_trailing_yeah(self):
        left = loose_key(tokenize(normalize("I keep the drum in the trunk")))
        right = loose_key(tokenize(normalize("I keep the drum in the trunk, yeah")))
        self.assertEqual(left, right)

    def test_junk_section_headers(self):
        self.assertTrue(is_junk_line("[Chorus]"))
        self.assertTrue(is_junk_line("You might also like"))
        self.assertFalse(is_junk_line("I keep the drum in the trunk"))

    def test_cross_song_dedupe_prefers_bpm_song(self):
        songs = {
            "a": song("A", ["I keep the drum in the trunk"] * 6 + ["Alpha owns this extra line here"]),
            "b": song(
                "B",
                ["I keep the drum in the trunk, yeah"] * 3 + ["Beta owns this other line now"],
                bpm=140,
                scale="A minor",
            ),
        }
        stats = dedupe_songs(songs)
        a_text = " ".join(line["text"] for line in songs["a"]["lines"])
        b_text = " ".join(line["norm"] for line in songs["b"]["lines"])
        self.assertNotIn("drum", a_text)
        self.assertIn("drum", b_text)
        self.assertLessEqual(sum(1 for line in songs["b"]["lines"] if "drum" in line["norm"]), 4)
        self.assertGreater(stats["dropped_exact"], 0)
        self.assertIn("alpha owns", a_text.lower())

    def test_split_is_disjoint_95_3_2(self):
        splits = split_song_ids([f"s{i}" for i in range(100)], seed=7)
        self.assertEqual(len(splits["train"]), 95)
        self.assertEqual(len(splits["valid"]), 3)
        self.assertEqual(len(splits["test"]), 2)
        self.assertEqual(len(set(splits["train"]) & set(splits["valid"]) & set(splits["test"])), 0)
        self.assertEqual(len(set(splits["train"]) | set(splits["valid"]) | set(splits["test"])), 100)

    def test_voice_prefix_buckets_bpm(self):
        prefix = control_prefix("Ty Dolla $ign", 142, "F# minor", 11.2, blend="Future")
        self.assertIn("<voice:Ty Dolla $ign>", prefix)
        self.assertIn("<blend:Future>", prefix)
        self.assertIn("<bpm:140>", prefix)
        self.assertIn("<scale:F# minor>", prefix)
        self.assertIn("<syl:11>", prefix)

    def test_missing_bpm_and_scale_omit_the_tags(self):
        prefix = control_prefix("Ada", None, None, 10)
        self.assertEqual(prefix, "<voice:Ada> <syl:10>")
        self.assertNotIn("unk", prefix)
        self.assertEqual(control_prefix("Ada", None, "  ", None), "<voice:Ada>")

    def test_voice_inventory_flags_thin_artists_and_keeps_case(self):
        fat_lines = "\n".join("kept line %d" % i for i in range(8))
        thin_lines = "[Verse]\n" + "\n".join("thin line %d" % i for i in range(3))
        records = {
            "train": [
                {"text": fat_lines, "artist": "Ada", "bpm": 140, "scale": "A minor", "song_id": "a"},
                {"text": thin_lines, "artist": "ada", "bpm": None, "scale": None, "song_id": "b"},
                {"text": "only three lines\nsecond\nthird", "artist": "Bea", "bpm": 90, "scale": None, "song_id": "c"},
            ],
            "valid": [
                {"text": fat_lines, "artist": "Val Only", "bpm": 100, "scale": "C major", "song_id": "v"},
            ],
            "test": [
                {"text": fat_lines, "artist": "Ada", "bpm": None, "scale": "D minor", "song_id": "t"},
            ],
        }
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            paths = {}
            for split, rows in records.items():
                path = root / ("%s.jsonl" % split)
                with path.open("w", encoding="utf-8") as handle:
                    for row in rows:
                        handle.write(json.dumps(row) + "\n")
                paths[split] = path
            found = collect_voice_rows(paths, min_lines=5)
            by_artist = {row["artist"]: row for row in found}
            self.assertEqual(set(by_artist), {"Ada", "ada", "Bea", "Val Only"})
            self.assertTrue(by_artist["Ada"]["reliable"])
            self.assertEqual(by_artist["Ada"]["train_lines"], 8)
            self.assertEqual(by_artist["Ada"]["train_windows"], 1)
            self.assertEqual(by_artist["Ada"]["test_lines"], 8)
            self.assertEqual(voice_example_counts(records["train"][1]), (3, 1))
            self.assertFalse(by_artist["ada"]["reliable"])
            self.assertIn("too few train lines (3 < 5)", by_artist["ada"]["flag"])
            self.assertEqual(by_artist["ada"]["train_windows"], 1)
            self.assertEqual(by_artist["Bea"]["train_windows"], 0)
            self.assertIn("no training window", by_artist["Bea"]["flag"])
            self.assertIn("too few train lines (3 < 5)", by_artist["Bea"]["flag"])
            self.assertEqual(by_artist["Val Only"]["train_lines"], 0)
            self.assertIn("no training window", by_artist["Val Only"]["flag"])
            written = write_voice_inventory(paths, root / "out", min_lines=5)
            self.assertEqual([row["token"] for row in written], ["<voice:Ada>", "<voice:Bea>", "<voice:Val Only>", "<voice:ada>"])
            text = (root / "out" / "voices.txt").read_text(encoding="utf-8")
            self.assertNotIn("kept line", text)
            self.assertNotIn("thin line", text)
            report = (root / "out" / "voice_tokens.md").read_text(encoding="utf-8")
            self.assertIn("<voice:Ada>", report)
            self.assertIn("too few train lines", report)

    def test_mix_is_seventy_thirty_and_the_compare_shares_one_setup(self):
        import random

        self.assertEqual(infer.parse_mix("70"), (70, 30))
        self.assertEqual(infer.parse_mix("70/30"), (70, 30))
        with self.assertRaises(infer.MixError):
            infer.parse_mix("70/20")
        with self.assertRaises(infer.MixError):
            infer.parse_mix("0")
        left = infer.softmax([40.0, 0.0])
        right = infer.softmax([0.0, 40.0])
        mixed = infer.mix_probs(left, right, 0.7)
        self.assertAlmostEqual(mixed[0], 0.7, places=3)
        self.assertAlmostEqual(mixed[1], 0.3, places=3)
        rng = random.Random(7)
        solo = infer.draw_token([40.0, 0.0], [0.0, 40.0], 1.0, 1.0, 1.0, rng)
        self.assertEqual(solo, 0)
        rng = random.Random(7)
        other = infer.draw_token([40.0, 0.0], [0.0, 40.0], 0.0, 1.0, 1.0, rng)
        self.assertEqual(other, 1)
        plan = infer.mix_plan(
            "Gunna",
            "Young Thug",
            "70",
            140,
            None,
            11,
            "Count the room before I say the number",
            16,
            7,
        )
        self.assertEqual([job["share"] for job in plan["jobs"]], [1.0, 0.0, 0.7])
        self.assertEqual(plan["bars"], 16)
        self.assertEqual(plan["seed"], 7)
        self.assertEqual(plan["bpm"], 140)
        self.assertEqual(plan["seed_line"], "Count the room before I say the number")
        self.assertTrue(plan["left_prefix"].startswith("<voice:Gunna>"))
        self.assertIn("<bpm:140>", plan["left_prefix"])
        self.assertNotIn("<blend:", plan["left_prefix"])
        self.assertTrue(plan["right_prefix"].startswith("<voice:Young Thug>"))
        self.assertIn("<bpm:140>", plan["right_prefix"])
        self.assertIn("<syl:11>", plan["left_prefix"])
        self.assertIn("<syl:11>", plan["right_prefix"])
        self.assertNotIn("Count the room", plan["left_prefix"])
        report = infer.format_mix_report(
            dict(plan, temperature=0.9, top_p=0.9),
            [
                {"title": plan["jobs"][0]["title"], "lines": ["alpha one"] * 16},
                {"title": plan["jobs"][1]["title"], "lines": ["beta two"] * 16},
                {"title": plan["jobs"][2]["title"], "lines": ["blend three"] * 16},
            ],
            "Adapter: none loaded.",
            [],
        )
        self.assertIn("70% of Gunna and 30% of Young Thug", report)
        self.assertEqual(report.count("\n1. alpha one\n"), 1)
        self.assertEqual(report.count("\n16. blend three\n"), 1)
        self.assertIn("Seed line: Count the room before I say the number", report)

    def test_generation_warns_for_a_thin_or_unknown_voice(self):
        counts = {
            "<voice:Ada>": {"reliable": False, "train_lines": 3, "train_windows": 0},
            "<voice:Gunna>": {"reliable": True, "train_lines": 28000, "train_windows": 3000},
        }
        thin = infer.voice_note("Ada", counts, False)
        self.assertIn("<voice:Ada>", thin)
        self.assertIn("too few lines to learn a reliable voice", thin)
        self.assertEqual(infer.voice_note("Gunna", counts, False), "")
        self.assertIn("not a trained voice token", infer.voice_note("Nope", counts, False))
        self.assertEqual(infer.voice_note("Ada", counts, True), "")
        self.assertEqual(infer.voice_note("Ada", {}, False), "")

    def test_custom_exemplar_is_not_the_completion(self):
        block = [{"text": f"line number {i} stays original", "syl": 6} for i in range(4)]
        message = messages_for_chunk(
            "Ada", 100, "C minor", block, custom=True, exemplar=["example one stays here now"]
        )
        user = message["messages"][0]["content"]
        assistant = message["messages"][1]["content"]
        self.assertIn("<voice:custom>", user)
        self.assertIn("example one stays here now", user)
        self.assertNotIn("example one stays here now", assistant)
        self.assertIn("line number 0", assistant)

    def test_near_index_ignores_same_song(self):
        index = NearDupIndex()
        index.add(0xABCDEF, "song-a")
        self.assertTrue(index.seen_other(0xABCDEF, "song-b"))
        self.assertFalse(index.seen_other(0xABCDEF, "song-a"))

    def test_originality_flags_exact_without_storing_text(self):
        with tempfile.TemporaryDirectory() as tmp:
            conn = open_originality(Path(tmp) / "fp.sqlite")
            index_originality(conn, ["i keep the drum in the trunk"])
            self.assertEqual(originality_hit(conn, "I keep the drum in the trunk!"), "exact")
            scored = originality_score(conn, "I keep the drum in the trunk!")
            self.assertEqual(scored["kind"], "exact")
            self.assertEqual(scored["hamming"], 0)
            self.assertEqual(scored["similarity"], 1.0)
            self.assertIsNone(originality_hit(conn, "totally different sentence about weather"))
            self.assertIsNone(originality_score(conn, "totally different sentence about weather"))
            stored = conn.execute("SELECT sha, sim FROM fp").fetchall()
            blob = " ".join(str(cell) for row in stored for cell in row)
            self.assertNotIn("drum", blob)
            conn.close()

    def test_dominance_and_syllable_curve(self):
        from collections import Counter

        flags = dominance_flags(Counter({"Big": 500, "Next": 100, "Third": 100, "Small": 10}))
        self.assertTrue(any(row["artist"] == "Big" for row in flags))
        curve = {"buckets": {"140": {"n": 40, "median_syl": 12}}, "global_median_syl": 9}
        self.assertEqual(target_syllables(curve, 141), 12)
        self.assertEqual(target_syllables(curve, None), 9)

    def test_tempo_budget_is_roomier_at_70_and_denser_at_140(self):
        self.assertEqual(tempo_line_syllables(70), 8)
        self.assertEqual(tempo_line_syllables(140), 14)
        self.assertEqual(tempo_line_syllables(105), 11)
        self.assertEqual(tempo_line_syllables(40), 6)
        self.assertEqual(tempo_line_syllables(220), 18)
        self.assertLess(tempo_line_syllables(70), tempo_line_syllables(140))
        self.assertFalse(line_reached_budget("one two", 8))
        self.assertTrue(line_reached_budget("one two three four five six seven eight", 8))
        self.assertFalse(line_reached_budget("", 8))
        slow = control_prefix("Gunna", 70, "A minor", tempo_line_syllables(70))
        fast = control_prefix("Gunna", 140, "A minor", tempo_line_syllables(140))
        self.assertIn("<voice:Gunna>", slow)
        self.assertIn("<bpm:70>", slow)
        self.assertIn("<scale:A minor>", slow)
        self.assertIn("<syl:8>", slow)
        self.assertIn("<bpm:140>", fast)
        self.assertIn("<scale:A minor>", fast)
        self.assertIn("<syl:14>", fast)
        self.assertEqual(infer.parse_tempos("70,140"), [70.0, 140.0])
        with self.assertRaises(infer.MixError):
            infer.parse_tempos("nope")
        with self.assertRaises(infer.MixError):
            infer.parse_tempos("70")
        report = infer.format_tempo_report(
            "Gunna",
            "A minor",
            7,
            0.9,
            0.9,
            [
                {
                    "bpm": 70.0,
                    "syl": 8,
                    "prefix": slow,
                    "lines": ["one two"],
                    "flags": ["near"],
                }
            ],
            {70: {"songs": 1, "lines": 2, "mean": 10.5, "median": 10}},
            "Adapter: none loaded. These bars are the base model. The syllable budget is applied by the sampler.",
        )
        bare = estimate_syllables("one two")
        self.assertIn("mean %.2f" % bare, report)
        self.assertIn("1. one two  (%d syl)  [near train match]" % bare, report)
        self.assertIn("Corpus 70 BPM: 1 songs, 2 lines, mean 10.5, median 10.", report)
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "songs.jsonl"
            rows = [
                {
                    "text": "[Verse]\nhello there\nhi",
                    "artist": "Ada",
                    "bpm": 70,
                    "scale": "A minor",
                    "song_id": "s70",
                },
                {
                    "text": "[Chorus]\n",
                    "artist": "Ada",
                    "bpm": 72,
                    "scale": None,
                    "song_id": "empty",
                },
                {
                    "text": "one two three four",
                    "artist": "Bea",
                    "bpm": 140,
                    "scale": "A minor",
                    "song_id": "s140",
                },
                {
                    "text": "ignored line here now",
                    "artist": "Bea",
                    "bpm": 100,
                    "scale": None,
                    "song_id": "other",
                },
            ]
            path.write_text("".join(json.dumps(row) + "\n" for row in rows), encoding="utf-8")
            found = corpus_bpm_syllables([path], [70, 140])
            blob = json.dumps(found)
            self.assertNotIn("hello", blob)
            self.assertNotIn("ignored", blob)
            self.assertEqual(set(found), {70, 140})
            self.assertEqual(found[70]["songs"], 1)
            self.assertEqual(found[70]["lines"], 2)
            self.assertEqual(
                found[70]["mean"],
                round(
                    (estimate_syllables("hello there") + estimate_syllables("hi")) / 2.0,
                    2,
                ),
            )
            self.assertEqual(found[140]["lines"], 1)
            self.assertEqual(found[140]["songs"], 1)
            self.assertEqual(found[140]["mean"], float(estimate_syllables("one two three four")))


class GenerateScriptTests(unittest.TestCase):
    def test_defaults_are_temperature_and_top_p(self):
        parser = generate.build_parser()
        args = parser.parse_args(
            ["--voice", "Gunna", "--bpm", "140", "--scale", "A minor", "--seed-line", "Count the room"]
        )
        self.assertEqual(args.temperature, 0.8)
        self.assertEqual(args.top_p, 0.95)
        self.assertEqual(args.bars, 8)

    def test_file_is_bars_only_and_the_name_is_dated(self):
        text = generate.format_bars(["Count the room", "  second   bar  ", ""])
        self.assertEqual(text, "Count the room\nsecond bar\n")
        self.assertNotIn("1.", text)
        self.assertNotIn("syl", text)
        when = datetime(2026, 10, 17, 15, 4, 9)
        with tempfile.TemporaryDirectory() as tmp:
            directory = Path(tmp)
            path = generate.dated_bars_path(directory, when, "Gunna", "Young Thug")
            self.assertEqual(path.name, "2026-10-17-150409-gunna-young-thug.txt")
            path.write_text(text, encoding="utf-8")
            again = generate.dated_bars_path(directory, when, "Gunna", "Young Thug")
            self.assertEqual(again.name, "2026-10-17-150409-gunna-young-thug-2.txt")

    def test_seed_line_is_the_first_bar_and_blend_is_seventy(self):
        single = generate.generation_request(
            "Gunna",
            bpm=140,
            scale="A minor",
            seed_line="Count the room before I say the number",
            bars=16,
        )
        self.assertEqual(single["plan"]["temperature"], 0.8)
        self.assertEqual(single["plan"]["top_p"], 0.95)
        self.assertEqual(single["plan"]["bars"], 15)
        self.assertEqual(single["opening"], "Count the room before I say the number")
        self.assertEqual(single["plan"]["syl"], tempo_line_syllables(140))
        self.assertTrue(single["plan"]["fit_syllables"])
        self.assertTrue(single["plan"]["left_prefix"].startswith("<voice:Gunna>"))
        self.assertIn("<bpm:140>", single["plan"]["left_prefix"])
        self.assertIn("<scale:A minor>", single["plan"]["left_prefix"])
        self.assertNotIn("Count the room", single["plan"]["left_prefix"])
        self.assertEqual(single["job"]["share"], 1.0)
        blend = generate.generation_request(
            "Gunna",
            blend="Young Thug",
            mix="70",
            bpm=140,
            scale="A minor",
            seed_line="Count the room before I say the number",
            bars=16,
        )
        self.assertEqual(blend["job"]["share"], 0.7)
        self.assertTrue(blend["plan"]["right_prefix"].startswith("<voice:Young Thug>"))
        self.assertNotIn("<blend:", blend["plan"]["left_prefix"])
        topic = generate.generation_request(
            "Young Thug",
            bpm=90,
            scale="D minor",
            topic="rain on the windshield",
            bars=8,
            temperature=1.2,
            top_p=0.99,
        )
        self.assertEqual(topic["plan"]["bars"], 8)
        self.assertEqual(topic["opening"], "")
        self.assertEqual(topic["plan"]["temperature"], 1.2)
        self.assertEqual(topic["plan"]["top_p"], 0.99)
        self.assertIn("Write bars about: rain on the windshield", topic["plan"]["left_prefix"])
        self.assertEqual(generate.format_bars(["only the model line"]), "only the model line\n")
        with self.assertRaises(generate.GenerateError):
            generate.generation_request("Gunna", bpm=140, scale="A minor")
        with self.assertRaises(generate.GenerateError):
            generate.generation_request(
                "Gunna", blend="Gunna", mix="70", bpm=140, scale="A minor", topic="room"
            )


class ListenBatchTests(unittest.TestCase):
    def test_twenty_batches_vary_voice_bpm_and_temperature(self):
        self.assertEqual(len(listen_batch.SPECS), 20)
        voices = [row["voice"] for row in listen_batch.SPECS]
        self.assertIn("Gunna", voices)
        self.assertIn("Young Thug", voices)
        self.assertIn("Young Stoner Life", voices)
        self.assertGreater(len(set(row["bpm"] for row in listen_batch.SPECS)), 5)
        self.assertGreater(len(set(row["temperature"] for row in listen_batch.SPECS)), 5)
        keys = [(row["voice"], row["bpm"], row["temperature"]) for row in listen_batch.SPECS]
        self.assertEqual(len(keys), len(set(keys)))

    def test_file_header_and_blank_grading_sheet(self):
        spec = dict(listen_batch.SPECS[0], seed=101)
        text = listen_batch.render_batch(spec, ["first bar", "second bar"])
        self.assertTrue(text.startswith("batch: 01\nvoice: Gunna\nbpm: 70\ntemperature: 0.6\n"))
        self.assertIn("\n\nfirst bar\nsecond bar\n", text)
        self.assertEqual(listen_batch.bar_count(text), 2)
        self.assertNotIn("rhyme", text)
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "grading.csv"
            listen_batch.write_grading_sheet(path)
            raw = path.read_text(encoding="utf-8")
            self.assertTrue(
                raw.startswith(
                    "batch,voice,bpm,temperature,rhyme (1-5),flow (1-5),"
                    "voice match (1-5),originality (1-5),keep (yes/no),notes\n"
                )
            )
            self.assertIn("01,Gunna,70,0.6,,,,,,\n", raw)
            self.assertIn("02,Young Thug,140,1.2,,,,,,\n", raw)
            self.assertIn("03,Young Stoner Life,100,0.8,,,,,,\n", raw)
            self.assertEqual(raw.count("\n"), 21)
            self.assertFalse(listen_batch.sheet_has_grades(path))

    def test_listen_page_shows_one_batch_and_does_not_score(self):
        page = listen_batch.render_listen_page(
            [
                {
                    "batch": "01",
                    "voice": "Gunna",
                    "bpm": "70",
                    "temperature": "0.6",
                    "scale": "A minor",
                    "top_p": "0.95",
                    "seed": "101",
                    "topic": "a night that ran long",
                    "bars": ["alpha line", "beta line"],
                },
                {
                    "batch": "02",
                    "voice": "Young Thug",
                    "bpm": "140",
                    "temperature": "1.2",
                    "scale": "A minor",
                    "top_p": "0.95",
                    "seed": "102",
                    "topic": "a night that ran long",
                    "bars": ["gamma line"],
                },
            ]
        )
        self.assertIn("I checked this batch", page)
        self.assertIn("Next batch", page)
        self.assertIn("does not score the bars", page)
        self.assertIn("Gunna", page)
        self.assertIn("Young Thug", page)
        self.assertIn("alpha line", page)
        self.assertIn("End word", page)
        self.assertIn("Not scored", page)
        self.assertIn('"syllables": 4', page)
        self.assertIn("Download the sheet", page)


EVAL_FIXTURE = """## Model scores

No LoRA adapter has been trained. Every score below is the base checkpoint `mlx-community/Qwen2.5-3B-Instruct-4bit`.

## 1. Perplexity

- Test songs: 781
- Windows scored: 4,010
- Test loss: 4.3742
- Perplexity: 79.38

## 2. Rhyme density

- Corpus mean end-rhyme rate: 0.106
- Generated mean end-rhyme rate: 0.000

## 3. Syllable consistency at a matched BPM

- Corpus mean flow consistency: 0.686
- Generated mean flow consistency on the five fidelity samples: 0.135

| Voice | BPM | BPM source | Mean syllables | Bucket median | Flow | Bucket flow |
| --- | ---: | --- | ---: | ---: | ---: | ---: |
| Gunna | 116.5 | held-out songs | 19.12 | 10 | 0.030 | 0.682 |
| Young Thug | 138.0 | train songs | 27.00 | 11 | 0.445 | 0.689 |
| Young Stoner Life | 139.0 | held-out songs | 11.88 | 11 | 0.000 | 0.689 |

## 4. Voice fidelity
"""


class DeskTests(unittest.TestCase):
    def _root(self, tmp: str, report: str = EVAL_FIXTURE) -> Path:
        root = Path(tmp)
        out = root / "out"
        out.mkdir()
        (out / "eval_report.md").write_text(report, encoding="utf-8")
        (out / "voices.txt").write_text(
            "<voice:Lil Wayne>\n<voice:Gunna>\n<voice:Young Stoner Life>\n<voice:Young Thug>\n",
            encoding="utf-8",
        )
        (root / "train_config.yaml").write_text(
            "model: mlx-community/Qwen2.5-3B-Instruct-4bit\n",
            encoding="utf-8",
        )
        return root

    def test_missing_log_shows_no_data_and_real_perplexity(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = self._root(tmp)
            payload = desk.collect_metrics(root, grades_path=Path(tmp) / "missing.csv", now=1_700_000_000)
            self.assertIsNone(payload["training"]["train_loss"])
            self.assertIsNone(payload["training"]["val_loss"])
            self.assertIsNone(payload["training"]["learning_rate"])
            self.assertEqual(payload["eval"]["perplexity"], "79.38")
            self.assertEqual(payload["eval"]["generated_rhyme"], "0.000")
            self.assertEqual(payload["eval"]["corpus_rhyme"], "0.106")
            self.assertEqual(payload["voices"][:3], ["Gunna", "Young Thug", "Young Stoner Life"])
            self.assertFalse(payload["adapter"]["present"])
            page = desk.render_page(payload)
            self.assertIn("no data yet", page)
            self.assertIn("79.38", page)
            self.assertIn("0.000", page)
            self.assertIn("0.106", page)
            self.assertIn('id="metrics"', page)
            self.assertIn('id="adjusters"', page)
            self.assertIn('id="editor"', page)
            self.assertIn(">Metrics<", page)
            self.assertIn(">Adjusters<", page)
            self.assertIn(">Editor<", page)
            self.assertIn('id="generate" type="button" disabled', page)
            self.assertIn("The sampler does not use this yet", page)
            self.assertIn("It does not upload the catalog or the weights.", page)
            self.assertIn("Nothing has been trained.", page)
            self.assertNotIn("<polyline", page)
            self.assertIn("Gunna", page)
            self.assertIn("Young Thug", page)
            self.assertIn("Young Stoner Life", page)
            self.assertIn("2 of 3 samples", page)

    def test_log_rows_draw_the_real_series(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = self._root(tmp)
            log = root / "out" / "training_log.csv"
            log.write_text(
                "step,train_loss,val_loss,learning_rate,tokens_per_second,peak_memory_gb\n"
                "1,2.50,,2.0e-5,10,4.1\n"
                "2,2.40,2.20,1.9e-5,11,4.2\n",
                encoding="utf-8",
            )
            now = time.time()
            payload = desk.collect_metrics(root, grades_path=Path(tmp) / "missing.csv", now=now)
            self.assertEqual(payload["training"]["train_loss"], "2.40")
            self.assertEqual(payload["training"]["val_loss"], "2.20")
            self.assertEqual(payload["training"]["learning_rate"], "1.9e-5")
            self.assertFalse(payload["training"]["stale"])
            page = desk.render_page(payload)
            self.assertIn("<polyline", page)
            self.assertIn("2.40", page)
            self.assertIn("2.20", page)
            old = now - 1000
            os.utime(log, (old, old))
            stale = desk.collect_metrics(root, grades_path=Path(tmp) / "missing.csv", now=now)
            self.assertTrue(stale["training"]["stale"])
            stale_page = desk.render_page(stale)
            self.assertIn("This log has stopped updating.", stale_page)

    def test_grades_keep_blank_cells_blank(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = self._root(tmp)
            sheet = Path(tmp) / "grading.csv"
            sheet.write_text(
                "batch,voice,bpm,temperature,rhyme (1-5),flow (1-5),voice match (1-5),originality (1-5),keep (yes/no),notes\n"
                "01,Gunna,70,0.6,1,1,1,5,no,\n"
                "02,Young Thug,140,1.2,,,,,no,\n"
                "03,Young Stoner Life,100,0.8,,,,,,\n",
                encoding="utf-8",
            )
            listen = root / "out" / "listen"
            listen.mkdir()
            (listen / "grading.csv").write_text(
                "batch,voice,bpm,temperature,rhyme (1-5),flow (1-5),voice match (1-5),originality (1-5),keep (yes/no),notes\n"
                "01,Gunna,70,0.6,,,,,,\n",
                encoding="utf-8",
            )
            payload = desk.collect_metrics(root, grades_path=sheet, now=1_700_000_000)
            self.assertEqual(len(payload["grades"]["rows"]), 2)
            self.assertEqual(payload["listen_sheet"], "blank")
            page = desk.render_page(payload)
            self.assertIn("Batch 01", page)
            self.assertIn("Rhyme 1", page)
            self.assertIn("Keep no", page)
            self.assertIn("Rhyme not scored", page)
            self.assertIn("still blank", page)
            self.assertNotIn("Batch 03", page)

    def test_real_eval_report_numbers(self):
        path = Path(__file__).resolve().parent / "out" / "eval_report.md"
        if not path.is_file():
            self.skipTest("eval report is not on disk")
        report = desk.read_eval(path, time.time())
        self.assertGreater(float(report["perplexity"]), 0.0)
        self.assertGreater(float(report["test_loss"]), 0.0)
        self.assertIsNotNone(report["generated_rhyme"])
        self.assertEqual(report["corpus_rhyme"], "0.106")
        self.assertIsNotNone(report["generated_flow"])
        names = [row["voice"] for row in report["syllables"]]
        self.assertIn("Gunna", names)
        self.assertIn("Young Thug", names)
        self.assertIn("Young Stoner Life", names)


if __name__ == "__main__":
    unittest.main()
