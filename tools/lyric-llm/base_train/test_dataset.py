#!/usr/bin/env python3
"""Split, shape, and subset checks for the base-train JSONL builder.

These tests build a tiny sqlite catalog. They do not call OpenAI.
"""

from __future__ import annotations

import json
import os
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
LYRIC_LLM = HERE.parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(LYRIC_LLM))

import build_dataset


def _schema(conn: sqlite3.Connection) -> None:
    conn.execute(
        """
        CREATE TABLE catalog_bars (
            id INTEGER PRIMARY KEY,
            artist TEXT NOT NULL,
            song TEXT NOT NULL,
            text TEXT NOT NULL,
            end_word TEXT NOT NULL,
            syllables INTEGER NOT NULL,
            popularity_score REAL DEFAULT 0.0,
            is_generic INTEGER DEFAULT 0,
            is_junk INTEGER DEFAULT 0,
            line_seq INTEGER DEFAULT 1,
            total_lines INTEGER DEFAULT 1,
            chronological_arc TEXT DEFAULT 'verse_build',
            topic TEXT DEFAULT '',
            is_iconic_anthem INTEGER DEFAULT 0
        )
        """
    )


def _insert(conn: sqlite3.Connection, rows: list[dict]) -> None:
    cols = (
        "id",
        "artist",
        "song",
        "text",
        "end_word",
        "syllables",
        "popularity_score",
        "is_generic",
        "is_junk",
        "line_seq",
        "total_lines",
        "chronological_arc",
        "topic",
        "is_iconic_anthem",
    )
    sql = "INSERT INTO catalog_bars (" + ", ".join(cols) + ") VALUES (" + ", ".join("?" for _ in cols) + ")"
    for row in rows:
        conn.execute(sql, [row[col] for col in cols])
    conn.commit()


def _bar(
    row_id: int,
    artist: str,
    song: str,
    line_seq: int,
    total: int = 3,
    text: str | None = None,
    end_word: str = "mercedes",
    syllables: int = 12,
    generic: int = 0,
    junk: int = 0,
    arc: str = "verse_build",
    topic: str = "luxury_brands",
    iconic: int = 0,
    popularity: float = 1.0,
) -> dict:
    if text is None:
        text = f"{song}|bar-{line_seq}"
    return {
        "id": row_id,
        "artist": artist,
        "song": song,
        "text": text,
        "end_word": end_word,
        "syllables": syllables,
        "popularity_score": popularity,
        "is_generic": generic,
        "is_junk": junk,
        "line_seq": line_seq,
        "total_lines": total,
        "chronological_arc": arc,
        "topic": topic,
        "is_iconic_anthem": iconic,
    }


def _catalog_of_songs() -> list[dict]:
    """100 songs, 3 bars each. A few bars are generic or junk."""
    rows: list[dict] = []
    row_id = 1
    for index in range(100):
        artist = "Gunna" if index < 80 else "Lil Baby"
        song = f"song-{index:03d}"
        arc = "intro" if index == 3 else "verse_build"
        topic = "" if index == 4 else "luxury_brands"
        for line_seq in (1, 2, 3):
            generic = 1 if index == 0 and line_seq == 2 else 0
            junk = 1 if index == 2 and line_seq == 3 else 0
            text = f"{song}|bar-{line_seq}"
            if index == 1 and line_seq == 2:
                text = "[Chorus]"
            if index == 5 and line_seq == 2:
                text = "don't\nstop"
            iconic = 1 if index == 10 and line_seq == 2 else 0
            popularity = 80.0 if iconic else float(index)
            rows.append(
                _bar(
                    row_id,
                    artist,
                    song,
                    line_seq,
                    text=text,
                    generic=generic,
                    junk=junk,
                    arc=arc,
                    topic=topic,
                    iconic=iconic,
                    popularity=popularity,
                    end_word="mercedes" if line_seq == 2 else "coupe",
                    syllables=17 if line_seq == 2 else 11,
                )
            )
            row_id += 1
    return rows


def _song_name(text: str, song: str) -> str:
    if "|bar-" in text:
        return text.split("|", 1)[0]
    return song


def _read_lines(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    if not text:
        return []
    return text.splitlines()


def _messages(line: str) -> list[dict]:
    record = json.loads(line)
    return record["messages"]


class DatasetTests(unittest.TestCase):
    def setUp(self) -> None:
        self._tmpdir = tempfile.TemporaryDirectory()
        self.root = Path(self._tmpdir.name)
        self.db = self.root / "catalog.sqlite"
        self._prior_seed = os.environ.get("SAMPLE_SEED")
        os.environ["SAMPLE_SEED"] = "11"
        conn = sqlite3.connect(self.db)
        _schema(conn)
        _insert(conn, _catalog_of_songs())
        conn.close()

    def tearDown(self) -> None:
        if self._prior_seed is None:
            os.environ.pop("SAMPLE_SEED", None)
        else:
            os.environ["SAMPLE_SEED"] = self._prior_seed
        self._tmpdir.cleanup()

    def _build(self, mode: str, name: str, sample_target: int = 30, fim_rate: float = 0.0) -> dict:
        return build_dataset.build_dataset(
            mode,
            self.root / name,
            self.db,
            sample_target=sample_target,
            fim_rate=fim_rate,
        )

    def test_split_songs_do_not_cross(self) -> None:
        result = self._build("full", "train_full.jsonl")
        keys = result["song_keys"]
        self.assertEqual(keys["train"] & keys["val"], set())
        self.assertEqual(keys["train"] & keys["test"], set())
        self.assertEqual(keys["val"] & keys["test"], set())
        self.assertEqual(
            len(keys["train"]) + len(keys["val"]) + len(keys["test"]),
            100,
        )
        # lyriclib 95/3/2 at n=100 is 95 / 3 / 2 songs.
        self.assertEqual(result["songs"], {"train": 95, "val": 3, "test": 2})

        owner = {}
        for split_name, path in result["paths"].items():
            for line in _read_lines(path):
                assistant = _messages(line)[2]["content"]
                if "|bar-" not in assistant:
                    continue
                song = assistant.split("|", 1)[0]
                prior = owner.get(song)
                self.assertTrue(prior is None or prior == split_name)
                owner[song] = split_name
        self.assertEqual(len(owner), 100)

    def test_filters_and_shape(self) -> None:
        result = self._build("full", "train_shape.jsonl")
        assistants = []
        parsed = []
        for path in result["paths"].values():
            for line in _read_lines(path):
                record = json.loads(line)
                self.assertEqual(list(record.keys()), ["messages"])
                messages = record["messages"]
                self.assertEqual(
                    [item["role"] for item in messages],
                    ["system", "user", "assistant"],
                )
                self.assertEqual(
                    messages[0]["content"],
                    "Write bars like <voice>. Keep the artist's slang, syllable count, "
                    "and rhyme pattern. Preserve the end word if given.",
                )
                user = messages[1]["content"]
                self.assertIn("<voice: ", user)
                self.assertIn("<section: ", user)
                self.assertIn("<bar ", user)
                self.assertIn("\nPREV_BAR: ", user)
                self.assertIn("\nTOPIC: ", user)
                self.assertIn("\nEND_WORD: ", user)
                self.assertIn("\nSYLLABLES: ", user)
                self.assertNotIn("\n", messages[2]["content"])
                self.assertTrue(messages[2]["content"])
                parsed.append(messages)
                assistants.append(messages[2]["content"])

        kept = "\n".join(assistants)
        self.assertNotIn("song-000|bar-1", kept)
        self.assertNotIn("song-000|bar-2", kept)
        self.assertIn("song-000|bar-3", kept)
        self.assertNotIn("[Chorus]", kept)
        self.assertNotIn("song-002|bar-3", kept)
        self.assertIn("don't stop", kept)

        intro = [
            messages
            for messages in parsed
            if "song-003|bar-" in messages[2]["content"]
        ]
        self.assertTrue(intro)
        self.assertIn("<section: intro>", intro[0][1]["content"])

        unknown_topic = [
            messages
            for messages in parsed
            if "song-004|bar-2" in messages[2]["content"]
        ]
        self.assertEqual(len(unknown_topic), 1)
        self.assertIn("TOPIC: unknown", unknown_topic[0][1]["content"])
        self.assertIn("<section: verse>", unknown_topic[0][1]["content"])
        self.assertIn("<bar 2 of 3>", unknown_topic[0][1]["content"])
        self.assertIn("END_WORD: mercedes", unknown_topic[0][1]["content"])
        self.assertIn("SYLLABLES: 17", unknown_topic[0][1]["content"])
        self.assertIn("PREV_BAR: song-004|bar-1", unknown_topic[0][1]["content"])
        self.assertTrue(unknown_topic[0][1]["content"].startswith("<voice: Gunna> "))

    def test_50k_sample_is_strict_subset_of_full(self) -> None:
        full = self._build("full", "train_full.jsonl", sample_target=30)
        sample = self._build("50k_sample", "train_50k.jsonl", sample_target=30)
        full_lines = _read_lines(full["paths"]["train"])
        sample_lines = _read_lines(sample["paths"]["train"])
        self.assertEqual(len(sample_lines), 30)
        self.assertGreater(len(full_lines), len(sample_lines))
        full_counts = Counter(full_lines)
        sample_counts = Counter(sample_lines)
        for line, count in sample_counts.items():
            self.assertLessEqual(count, full_counts[line])
        self.assertNotEqual(sample_counts, full_counts)
        # Held-out files are the same songs, not a second sample.
        self.assertEqual(_read_lines(full["paths"]["val"]), _read_lines(sample["paths"]["val"]))
        self.assertEqual(_read_lines(full["paths"]["test"]), _read_lines(sample["paths"]["test"]))
        self.assertEqual(full["song_keys"], sample["song_keys"])

    def test_same_seed_is_deterministic_and_iconic_wins(self) -> None:
        first = self._build("50k_sample", "train_a.jsonl", sample_target=30)
        second = self._build("50k_sample", "train_b.jsonl", sample_target=30)
        self.assertEqual(
            (self.root / "train_a.jsonl").read_bytes(),
            (self.root / "train_b.jsonl").read_bytes(),
        )
        self.assertEqual(first["sample_seed"], "11")

        # Two bars, equal popularity, one iconic. The iconic bar is the sample.
        rows = [
            _bar(1, "Gunna", "plain", 1, text="open", popularity=5),
            _bar(2, "Gunna", "plain", 2, text="ordinary bar", popularity=50, iconic=0),
            _bar(3, "Gunna", "anthem", 1, text="open anthem", popularity=5),
            _bar(4, "Gunna", "anthem", 2, text="iconic bar", popularity=1, iconic=1),
        ]
        picked = self._voices_from_rows(rows, target=1)
        self.assertEqual([ex["text"] for ex in picked], ["iconic bar"])

    def test_seed_changes_a_tie(self) -> None:
        rows = [
            _bar(1, "Gunna", "one", 1, text="open", popularity=0),
            _bar(2, "Gunna", "one", 2, text="alpha bar", popularity=0),
            _bar(3, "Gunna", "two", 1, text="open", popularity=0),
            _bar(4, "Gunna", "two", 2, text="beta bar", popularity=0),
        ]
        winners = set()
        for seed in ("1", "2", "3", "4", "5", "6", "7", "8", "9"):
            os.environ["SAMPLE_SEED"] = seed
            chosen, _targets = build_dataset.select_stratified(
                self._eligible(rows),
                self._eligible(rows),
                1,
                seed,
            )
            winners.add(chosen[0]["text"])
        self.assertGreater(len(winners), 1)

    def test_allocate_matches_full_set_percentages(self) -> None:
        quotas = build_dataset.allocate({"Gunna": 90, "Lil Baby": 10}, {"Gunna": 90, "Lil Baby": 10}, 20)
        self.assertEqual(quotas, {"Gunna": 18, "Lil Baby": 2})
        self.assertEqual(sum(quotas.values()), 20)
        # Lil Baby has no train bars. His seat goes back to Gunna.
        shifted = build_dataset.allocate({"Gunna": 90, "Lil Baby": 10}, {"Gunna": 80, "Lil Baby": 0}, 20)
        self.assertEqual(shifted, {"Gunna": 20})

    def test_cli_full_writes_siblings_without_openai(self) -> None:
        source = Path(build_dataset.__file__).read_text(encoding="utf-8")
        self.assertNotIn("import openai", source)
        self.assertNotIn("OpenAI(", source)
        self.assertNotIn("api_key", source.lower())

        out = self.root / "train_cli.jsonl"
        env = os.environ.copy()
        env["SAMPLE_SEED"] = "11"
        completed = subprocess.run(
            [
                sys.executable,
                str(HERE / "build_dataset.py"),
                "--mode",
                "full",
                "--out",
                str(out),
                "--db",
                str(self.db),
            ],
            check=False,
            capture_output=True,
            text=True,
            env=env,
        )
        self.assertEqual(completed.returncode, 0, completed.stderr)
        self.assertTrue(out.is_file())
        self.assertTrue((self.root / "val_cli.jsonl").is_file())
        self.assertTrue((self.root / "test_cli.jsonl").is_file())
        self.assertIn("mode: full", completed.stdout)
        self.assertNotIn("sk-", completed.stdout)
        self.assertNotIn("sk-", completed.stderr)

    def test_fim_keeps_above_and_below_on_the_same_song(self) -> None:
        result = self._build("full", "train_fim.jsonl", fim_rate=1.0)
        rows = result["train_examples"] + result["val_examples"] + result["test_examples"]
        fim_rows = [ex for ex in rows if ex["fim"]]
        plain_rows = [ex for ex in rows if not ex["fim"]]
        self.assertTrue(fim_rows)
        self.assertTrue(any("|bar-3" in ex["text"] for ex in plain_rows))
        for ex in plain_rows:
            self.assertFalse(ex.get("next_text"))
        for ex in fim_rows:
            self.assertEqual(_song_name(ex["prev_text"], ex["song"]), ex["song"])
            self.assertEqual(_song_name(ex["next_text"], ex["song"]), ex["song"])
            self.assertEqual(_song_name(ex["text"], ex["song"]), ex["song"])
            record = json.loads(build_dataset.render(ex))
            messages = record["messages"]
            self.assertEqual(messages[0]["content"], build_dataset.FIM_SYSTEM)
            user = messages[1]["content"]
            self.assertEqual(
                user,
                f"<voice: {ex['artist']}>\n"
                f"ABOVE: {ex['prev_text']}\n"
                f"BELOW: {ex['next_text']}\n"
                f"END_WORD: {ex['end_word']}\n"
                f"SYLLABLES: {ex['syllables']}",
            )
            self.assertNotIn("<section:", user)
            self.assertEqual(messages[2]["content"], ex["text"])

    def test_fim_sample_is_a_subset_and_the_rate_is_near_20(self) -> None:
        full = self._build("full", "train_full_fim.jsonl", fim_rate=0.2)
        sample = self._build("50k_sample", "train_50k_fim.jsonl", sample_target=30, fim_rate=0.2)
        full_lines = _read_lines(full["paths"]["train"])
        sample_lines = _read_lines(sample["paths"]["train"])
        full_counts = Counter(full_lines)
        for line, count in Counter(sample_lines).items():
            self.assertLessEqual(count, full_counts[line])
        again = self._build("50k_sample", "train_50k_fim_again.jsonl", sample_target=30, fim_rate=0.2)
        self.assertEqual(sample_lines, _read_lines(again["paths"]["train"]))
        train_n = full["counts"]["train"]
        fim_n = full["fim_counts"]["train"]
        self.assertGreater(fim_n, 0)
        self.assertLess(fim_n, train_n)
        self.assertAlmostEqual(fim_n / train_n, 0.2, delta=0.12)
        zero = self._build("full", "train_nofim.jsonl", fim_rate=0.0)
        self.assertEqual(zero["fim_counts"]["train"], 0)

    def test_cli_fim_stays_on_the_base_builder(self) -> None:
        out = self.root / "train_cli_fim.jsonl"
        env = os.environ.copy()
        env["SAMPLE_SEED"] = "11"
        completed = subprocess.run(
            [
                sys.executable,
                str(HERE / "build_dataset.py"),
                "--mode",
                "full",
                "--fim",
                "0.2",
                "--out",
                str(out),
                "--db",
                str(self.db),
            ],
            check=False,
            capture_output=True,
            text=True,
            env=env,
        )
        self.assertEqual(completed.returncode, 0, completed.stderr)
        self.assertIn("mode: full", completed.stdout)
        self.assertIn("fim_train:", completed.stdout)
        self.assertNotIn("variant=", completed.stdout)
        fim_lines = [
            line
            for line in _read_lines(out)
            if build_dataset.FIM_SYSTEM in line
        ]
        self.assertTrue(fim_lines)
        record = json.loads(fim_lines[0])
        self.assertIn("\nABOVE: ", record["messages"][1]["content"])
        self.assertIn("\nBELOW: ", record["messages"][1]["content"])

    def _eligible(self, rows: list[dict]) -> list[dict]:
        examples, _drops = build_dataset.build_examples(rows)
        return examples

    def _voices_from_rows(self, rows: list[dict], target: int) -> list[dict]:
        examples = self._eligible(rows)
        chosen, _targets = build_dataset.select_stratified(examples, examples, target, "11")
        return chosen


if __name__ == "__main__":
    unittest.main()
