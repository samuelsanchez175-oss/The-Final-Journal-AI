#!/usr/bin/env python3
"""Synthetic leak rules. No catalog text."""

from __future__ import annotations

import unittest

from check_leakage import (
    assign_destinations,
    bump,
    crossing_pairs,
    gram_phrases,
    song_words,
    unpack,
)


class LeakRuleTests(unittest.TestCase):
    def test_marker_line_is_not_a_word(self) -> None:
        words = song_words("[Chorus]\nI got five words here now yes please")
        self.assertNotIn("chorus", words)
        self.assertEqual(words[:4], ["i", "got", "five", "words"])

    def test_punctuation_does_not_split_the_sequence(self) -> None:
        left = gram_phrases(song_words("Hello, world — this is eight words exactly here."))
        right = gram_phrases(song_words("hello world this is eight words exactly here"))
        self.assertEqual(left, right)
        self.assertEqual(len(left), 1)

    def test_cap_allows_five_and_flags_six(self) -> None:
        self.assertEqual(crossing_pairs((3, 0, 2)), [])
        self.assertEqual(crossing_pairs((4, 0, 2)), [("train", "test", 6)])
        self.assertEqual(crossing_pairs((6, 0, 0)), [])
        self.assertEqual(crossing_pairs((4, 2, 0)), [("train", "val", 6)])

    def test_pack_round_trip(self) -> None:
        packed = 0
        for _ in range(4):
            packed = bump(packed, 0)
        for _ in range(2):
            packed = bump(packed, 2)
        self.assertEqual(unpack(packed), (4, 0, 2))

    def test_move_keeps_the_group_together(self) -> None:
        gram = b"g"
        members = {
            gram: [("train", "a"), ("train", "b"), ("train", "c"), ("train", "d"), ("test", "e"), ("test", "f")]
        }
        split_of = {
            "a": "train",
            "b": "train",
            "c": "train",
            "d": "train",
            "e": "test",
            "f": "test",
        }
        moves = assign_destinations(members, split_of)
        self.assertEqual(moves, {"e": "train", "f": "train"})

    def test_tie_goes_to_train(self) -> None:
        gram = b"g"
        members = {gram: [("train", "a"), ("test", "b")]}
        moves = assign_destinations(members, {"a": "train", "b": "test"})
        self.assertEqual(moves, {"b": "train"})

    def test_same_sequence_links_songs_that_share_it(self) -> None:
        members = {
            b"g": [("train", "a"), ("test", "b")],
            b"h": [("test", "b"), ("test", "c")],
        }
        split_of = {"a": "train", "b": "test", "c": "test"}
        moves = assign_destinations(members, split_of)
        self.assertEqual(set(moves), {"a"})
        self.assertEqual(moves["a"], "test")


if __name__ == "__main__":
    unittest.main()
