#!/usr/bin/env python3
"""Shape tests for the one_hot voice dataset. No network. No API key."""

from __future__ import annotations

import json
import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import build_dataset  # noqa: E402
import voice_dataset  # noqa: E402
import voice_variant  # noqa: E402


def _write_catalog(path: Path, rows: list[tuple]) -> None:
    con = sqlite3.connect(path)
    con.execute(
        """
        CREATE TABLE catalog_bars (
            id INTEGER PRIMARY KEY,
            artist TEXT, song TEXT, song_id TEXT, album TEXT, text TEXT,
            end_word TEXT, syllables INTEGER, is_generic INTEGER,
            line_seq INTEGER, total_lines INTEGER, chronological_arc TEXT,
            topic TEXT, is_iconic_anthem INTEGER, popularity_score REAL
        )
        """
    )
    con.executemany(
        """
        INSERT INTO catalog_bars (
            id, artist, song, song_id, album, text, end_word, syllables,
            is_generic, line_seq, total_lines, chronological_arc, topic,
            is_iconic_anthem, popularity_score
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        rows,
    )
    con.commit()
    con.close()


def _bar(
    bar_id: int,
    artist: str,
    song: str,
    line_seq: int,
    text: str,
    end: str,
    generic: int = 0,
    iconic: int = 0,
    popularity: float = 1.0,
    arc: str = "verse_build",
    topic: str = "money_flex",
    syllables: int = 11,
) -> tuple:
    return (
        bar_id,
        artist,
        song,
        f"id-{song}",
        "album",
        text,
        end,
        syllables,
        generic,
        line_seq,
        4,
        arc,
        topic,
        iconic,
        popularity,
    )


def _fixture_rows() -> list[tuple]:
    rows: list[tuple] = []
    bar_id = 1
    for artist, songs in (("Gunna", 25), ("Lil Baby", 25)):
        for song_index in range(songs):
            song = f"{artist}-song-{song_index}"
            iconic = 1 if song_index == 0 else 0
            popularity = 40.0 if iconic else float(song_index)
            lines = [
                (1, f"{song} first line", "first", 0),
                (2, f"{song} GENERIC filler", "filler", 1),
                (3, f"{song} kept middle", "middle", 0),
                (4, f"{song} kept last", "last", 0),
            ]
            for line_seq, text, end, generic in lines:
                rows.append(
                    _bar(
                        bar_id,
                        artist,
                        song,
                        line_seq,
                        text,
                        end,
                        generic=generic,
                        iconic=iconic,
                        popularity=popularity,
                    )
                )
                bar_id += 1
    return rows


class VoiceVariantTests(unittest.TestCase):
    def test_one_hot_user_token_and_system_name(self) -> None:
        record = voice_variant.render_messages(
            {
                "artist": "Gunna",
                "section": "verse",
                "line_seq": 7,
                "total_lines": 16,
                "prev_text": "previous line",
                "topic": "luxury_brands",
                "end_word": "mercedes",
                "syllables": 17,
                "text": "the kept bar",
                "next_text": "next line",
                "fim": False,
            },
            "one_hot",
        )
        messages = record["messages"]
        self.assertEqual([item["role"] for item in messages], ["system", "user", "assistant"])
        self.assertEqual(
            messages[0]["content"],
            "Write bars like Gunna. Keep the artist's slang, syllable count, and rhyme pattern.",
        )
        self.assertTrue(messages[1]["content"].startswith("<voice: Gunna> <section: verse> <bar 7 of 16>"))
        self.assertIn("PREV_BAR: previous line", messages[1]["content"])
        self.assertIn("TOPIC: luxury_brands", messages[1]["content"])
        self.assertIn("END_WORD: mercedes", messages[1]["content"])
        self.assertIn("SYLLABLES: 17", messages[1]["content"])
        self.assertNotIn("ABOVE:", messages[1]["content"])
        self.assertEqual(messages[2]["content"], "the kept bar")

    def test_fim_keeps_voice_token_and_drops_section(self) -> None:
        record = voice_variant.render_messages(
            {
                "artist": "Lil Baby",
                "section": "verse",
                "line_seq": 3,
                "total_lines": 8,
                "prev_text": "above bar",
                "topic": "untagged",
                "end_word": "hood",
                "syllables": 12,
                "text": "missing bar",
                "next_text": "below bar",
                "fim": True,
            },
            "one_hot",
        )
        system = record["messages"][0]["content"]
        user = record["messages"][1]["content"]
        self.assertEqual(system, voice_variant.FIM_SYSTEM)
        self.assertTrue(user.startswith("<voice: Lil Baby>\nABOVE: above bar\nBELOW: below bar\n"))
        self.assertNotIn("<section:", user)
        self.assertNotIn("<voice: Gunna>", user)

    def test_systembrief_is_not_this_phase(self) -> None:
        with self.assertRaises(ValueError):
            voice_variant.render_messages({"artist": "Gunna", "fim": False}, "systembrief")

    def test_section_map(self) -> None:
        self.assertEqual(voice_variant.section_name("intro"), "intro")
        self.assertEqual(voice_variant.section_name("climax_punch"), "verse")
        self.assertEqual(voice_variant.section_name(None), "verse")


class SplitAndFilterTests(unittest.TestCase):
    def test_split_is_95_3_2_and_stable(self) -> None:
        keys = [f"song-{index}" for index in range(100)]
        first = voice_dataset.split_songs(keys, 7)
        second = voice_dataset.split_songs(keys, 7)
        self.assertEqual(first, second)
        counts = {"train": 0, "val": 0, "test": 0}
        for role in first.values():
            counts[role] += 1
        self.assertEqual(counts, {"train": 95, "val": 3, "test": 2})
        self.assertEqual(len(set(first)), 100)

    def test_filters_drop_generic_and_first_bar_and_hold_out_songs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            catalog = Path(tmp) / "catalog.sqlite"
            _write_catalog(catalog, _fixture_rows())
            bars = voice_dataset.load_bars(catalog)
            roles = voice_dataset.split_songs(sorted({bar.song_key for bar in bars}), 7)
            train_keys = {key for key, role in roles.items() if role == "train"}
            examples = voice_dataset.eligible_examples(bars, train_keys)
            assistants = {row.text for row in examples}
            self.assertTrue(assistants)
            for text in assistants:
                self.assertNotIn("first line", text)
                self.assertNotIn("GENERIC", text)
            for row in examples:
                self.assertIn(row.song_key, train_keys)
                self.assertTrue(row.prev_text)

    def test_sample_is_deterministic_subset_of_full(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            catalog = Path(tmp) / "catalog.sqlite"
            _write_catalog(catalog, _fixture_rows())
            sample_a = voice_dataset.identity_pairs(catalog, "50k_sample", 7, sample_size=4)
            sample_b = voice_dataset.identity_pairs(catalog, "50k_sample", 7, sample_size=4)
            full = voice_dataset.identity_pairs(catalog, "full", 7, sample_size=4)
            self.assertEqual(sample_a, sample_b)
            self.assertEqual(len(sample_a), 4)
            self.assertTrue(sample_a < full)

    def test_fim_rate_and_cli_round_trip(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            catalog = Path(tmp) / "catalog.sqlite"
            out = Path(tmp) / "train.jsonl"
            _write_catalog(catalog, _fixture_rows())
            code = build_dataset.main(
                [
                    "--mode",
                    "50k_sample",
                    "--fim",
                    "0.2",
                    "--variant",
                    "one_hot",
                    "--seed",
                    "7",
                    "--catalog",
                    str(catalog),
                    "--out",
                    str(out),
                ]
            )
            self.assertEqual(code, 0)
            lines = out.read_text(encoding="utf-8").splitlines()
            self.assertGreaterEqual(len(lines), 8)
            fim = 0
            for line in lines:
                record = json.loads(line)
                self.assertEqual(
                    [item["role"] for item in record["messages"]],
                    ["system", "user", "assistant"],
                )
                user = record["messages"][1]["content"]
                self.assertIn("<voice: ", user)
                if record["messages"][0]["content"].startswith("Write the missing bar"):
                    fim += 1
                    self.assertIn("\nABOVE: ", user)
                    self.assertIn("\nBELOW: ", user)
                else:
                    self.assertIn("<section: ", user)
            self.assertEqual(fim, int(round(0.2 * len(lines))))


if __name__ == "__main__":
    unittest.main()
