#!/usr/bin/env python3
"""Synthetic checks for song cleaning. No catalog text."""

from __future__ import annotations

import json
import unittest

from clean_split import choose_duplicate_winners, render_song, song_id_for


class CleanSplitTests(unittest.TestCase):
    def test_line_breaks_and_markers_stay(self) -> None:
        text, lyric_lines, markers, _stats = render_song(
            [
                ("first line", "verse"),
                ("second line", "verse"),
                ("hook line", "chorus"),
                ("hook again", "chorus"),
            ]
        )
        self.assertEqual(
            text,
            "[Verse]\nfirst line\nsecond line\n[Chorus]\nhook line\nhook again",
        )
        self.assertEqual(lyric_lines, 4)
        self.assertEqual(markers, 2)
        self.assertIn("\n", text)

    def test_repeated_chorus_kept_once(self) -> None:
        rows = [
            ("verse line", "verse"),
            ("hook line", "chorus"),
            ("second hook", "chorus"),
            ("later verse", "verse"),
            ("hook line", "chorus"),
            ("second hook", "chorus"),
        ]
        text, lyric_lines, _markers, stats = render_song(rows)
        self.assertEqual(stats["chorus_spans_removed"], 1)
        self.assertEqual(lyric_lines, 4)
        self.assertEqual(text.count("hook line"), 1)
        self.assertEqual(text.count("[Chorus]"), 1)
        self.assertIn("later verse", text)

    def test_chorus_line_survives_when_the_verse_used_it(self) -> None:
        text, _lines, _markers, stats = render_song(
            [
                ("same words", "verse"),
                ("same words", "chorus"),
            ]
        )
        self.assertEqual(stats["exact_lines_removed"], 0)
        self.assertEqual(text, "[Verse]\nsame words\n[Chorus]\nsame words")

    def test_exact_duplicate_verse_line_removed(self) -> None:
        text, lyric_lines, _markers, stats = render_song(
            [
                ("only once", "verse"),
                ("only once", "verse"),
                ("new line", ""),
            ]
        )
        self.assertEqual(stats["exact_lines_removed"], 1)
        self.assertEqual(lyric_lines, 2)
        self.assertEqual(text, "[Verse]\nonly once\nnew line")

    def test_different_songs_are_not_merged(self) -> None:
        shared = [("shared line", ""), ("only a", "")]
        other = [("shared line", ""), ("only b", "")]
        songs = {
            "a": {"bpm": None, "scale": None, "order": 1, "rows": shared},
            "b": {"bpm": 100, "scale": "C minor", "order": 2, "rows": other},
        }
        self.assertEqual(choose_duplicate_winners(songs), set())
        text_a, _, _, _ = render_song(shared)
        text_b, _, _, _ = render_song(other)
        self.assertIn("shared line", text_a)
        self.assertIn("shared line", text_b)
        self.assertNotEqual(song_id_for("A", "One"), song_id_for("B", "One"))

    def test_exact_duplicate_song_dropped_without_mixing_artists(self) -> None:
        rows = [("line one", ""), ("line two", "chorus")]
        songs = {
            "early": {"bpm": None, "scale": None, "order": 1, "rows": list(rows), "artist": "Early"},
            "later": {"bpm": 90, "scale": None, "order": 2, "rows": list(rows), "artist": "Later"},
        }
        self.assertEqual(choose_duplicate_winners(songs), {"early"})
        self.assertEqual(songs["later"]["artist"], "Later")
        self.assertEqual(songs["later"]["rows"], rows)

    def test_missing_bpm_and_scale_are_json_null(self) -> None:
        payload = {"text": "a\nb", "artist": "A", "bpm": None, "scale": None, "song_id": "abc"}
        encoded = json.dumps(payload)
        self.assertIn('"bpm": null', encoded)
        self.assertIn('"scale": null', encoded)
        self.assertNotIn("unk", encoded)


if __name__ == "__main__":
    unittest.main()
