#!/usr/bin/env python3
"""test_innerrhyme_reweight.py
===========================
Unit test for Move 3: Inner-rhyme SQL reweight (vowel-match 50 -> 200, + inner_rhyme_count * 15).
Asserts that candidate bars with high inner_rhyme_count outrank lower inner-rhyme candidates,
and inner_vowel_class matching receives +200 boost.
"""

import os
import sqlite3
import tempfile
import unittest
from pathlib import Path

# Add tools/lyric-llm to sys.path
import sys
HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

from catalog_retriever import retrieve_matching_catalog_lines


class TestInnerRhymeReweight(unittest.TestCase):
    def setUp(self):
        # Create a temporary SQLite db with catalog_bars schema
        self.temp_db = tempfile.NamedTemporaryFile(suffix=".sqlite", delete=False)
        self.db_path = self.temp_db.name
        self.conn = sqlite3.connect(self.db_path)
        cur = self.conn.cursor()
        cur.execute("""
            CREATE TABLE catalog_bars (
                id TEXT PRIMARY KEY,
                artist TEXT,
                song TEXT,
                album TEXT,
                text TEXT,
                end_word TEXT,
                end_rime TEXT,
                vowel_class TEXT,
                syllables INTEGER,
                inner_rhyme_count INTEGER,
                popularity_score REAL,
                line_seq INTEGER,
                total_lines INTEGER,
                relative_pos REAL,
                chronological_arc TEXT,
                next_bar_text TEXT,
                is_iconic_anthem INTEGER,
                topic TEXT,
                inner_vowel_class TEXT,
                is_generic INTEGER DEFAULT 0
            )
        """)

        # Insert 3 test bars for Gunna:
        # Bar 1: standard bar, 0 inner rhymes, no inner vowel match
        cur.execute("""
            INSERT INTO catalog_bars VALUES (
                'bar1', 'Gunna', 'Song A', 'Album A',
                'walking in the rain with the shades', 'shades', 'EY1 D Z', 'EY',
                10, 0, 10.0, 1, 10, 0.1, 'intro', '', 0, 'drip', 'IH', 0
            )
        """)
        # Bar 2: high inner rhymes (4 inner rhymes: +60)
        cur.execute("""
            INSERT INTO catalog_bars VALUES (
                'bar2', 'Gunna', 'Song B', 'Album A',
                'paid the blade and made the trade for shades', 'shades', 'EY1 D Z', 'EY',
                10, 4, 10.0, 2, 10, 0.2, 'verse', '', 0, 'drip', 'IH', 0
            )
        """)
        # Bar 3: high inner rhymes + matching inner vowel (4 inner rhymes + matching inner vowel: +60 + 200 = +260)
        cur.execute("""
            INSERT INTO catalog_bars VALUES (
                'bar3', 'Gunna', 'Song C', 'Album A',
                'stayed and paid, made the grade in shades', 'shades', 'EY1 D Z', 'EY',
                10, 4, 10.0, 3, 10, 0.2, 'verse', '', 0, 'drip', 'V_front_mid', 0
            )
        """)
        self.conn.commit()

    def tearDown(self):
        self.conn.close()
        if os.path.exists(self.db_path):
            os.remove(self.db_path)

    def test_inner_rhymes_rank_higher_in_retrieval(self):
        pattern = {
            "end_word": "shades",
            "end_rime": "EY1 D Z",
            "vowel_class": "EY",
            "syllables": 10,
            "topic": "drip",
            "inner_vowel_class": "EY",
            "position": 0.2,
            "arc": "verse",
        }

        # Override default catalog db path temporarily
        results = retrieve_matching_catalog_lines(
            artist="Gunna",
            pattern=pattern,
            chosen_albums=[],
            limit=3,
            db_path=Path(self.db_path),
        )

        self.assertEqual(len(results), 3)
        # Bar 3 (4 inner rhymes + matching inner vowel class 'EY') must be rank 1
        self.assertEqual(results[0]["id"], "bar3")
        # Bar 2 (4 inner rhymes) must outrank Bar 1 (0 inner rhymes)
        self.assertEqual(results[1]["id"], "bar2")
        self.assertEqual(results[2]["id"], "bar1")

        # Verify score difference reflects the Move 3 inner-rhyme reweight
        # Bar 2 vs Bar 1 diff is 4 * 15 = 60 points
        diff_rhymes = results[1]["match_score"] - results[2]["match_score"]
        self.assertGreaterEqual(diff_rhymes, 50.0)

        # Bar 3 vs Bar 2 diff is inner_vowel match = 200 points
        diff_vowel = results[0]["match_score"] - results[1]["match_score"]
        self.assertGreaterEqual(diff_vowel, 190.0)


if __name__ == "__main__":
    unittest.main()
