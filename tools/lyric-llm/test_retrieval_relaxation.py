#!/usr/bin/env python3
"""test_retrieval_relaxation.py
=============================
Unit tests for Move 2: 3-Tier Filter Relaxation & Fallback Logging.
Verifies:
1. Tier A hits on strict album + rhyme match, records tier='A'.
2. Tier B hits when strict album misses, drops album filter and records tier='B'.
3. Tier C hits when rhyme misses, drops rhyme and records tier='C' by vowel class.
4. Tier D hits when vowel misses, drops vowel and records tier='D' by syllables (±4).
5. Hardcoded bank fallback fires when all tiers miss, returns [] and records tier='bank'.
6. Telemetry rows in out/v4_telemetry.jsonl match the required schema.
"""

import json
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


class TestRetrievalRelaxation(unittest.TestCase):
    def setUp(self):
        # Create temp sqlite db
        self.temp_db = tempfile.NamedTemporaryFile(suffix=".sqlite", delete=False)
        self.db_path = Path(self.temp_db.name)
        self.conn = sqlite3.connect(str(self.db_path))
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

        # Insert 4 distinct bars:
        # Bar A: Strict match for 'mercedes' on Album A
        cur.execute("""
            INSERT INTO catalog_bars VALUES (
                'barA', 'Gunna', 'Song A', 'Album A',
                'switchin lanes in the mercedes', 'mercedes', 'EY1 D IY0 Z', 'EY',
                14, 2, 20.0, 1, 10, 0.1, 'verse', '', 0, 'drip', 'V_front_mid', 0
            )
        """)
        # Bar B: On Album B (matches rime 'AY1 K', end word 'strike')
        cur.execute("""
            INSERT INTO catalog_bars VALUES (
                'barB', 'Gunna', 'Song B', 'Album B',
                'lightning hit with the strike', 'strike', 'AY1 K', 'AY',
                14, 1, 15.0, 2, 10, 0.2, 'verse', '', 0, 'street', 'V_broad', 0
            )
        """)
        # Bar C: Vowel class 'OW', rime 'OW1 L D', end word 'cold'
        cur.execute("""
            INSERT INTO catalog_bars VALUES (
                'barC', 'Gunna', 'Song C', 'Album C',
                'wrist is completely cold', 'cold', 'OW1 L D', 'OW',
                14, 1, 10.0, 3, 10, 0.3, 'verse', '', 0, 'ice', 'V_round_mid', 0
            )
        """)
        # Bar D: Non-matching phonetics, but syllables = 14
        cur.execute("""
            INSERT INTO catalog_bars VALUES (
                'barD', 'Gunna', 'Song D', 'Album D',
                'standing tall never ever down', 'down', 'AW1 N', 'AW',
                14, 0, 5.0, 4, 10, 0.4, 'verse', '', 0, 'stand', 'V_weak', 0
            )
        """)
        self.conn.commit()

        # Temp telemetry file
        self.temp_telem_dir = tempfile.TemporaryDirectory()
        self.telem_dir = Path(self.temp_telem_dir.name)
        self.telem_file = self.telem_dir / "v4_telemetry.jsonl"
        import catalog_retriever
        self.orig_out = catalog_retriever.OUT
        catalog_retriever.OUT = self.telem_dir

    def tearDown(self):
        self.conn.close()
        if self.db_path.exists():
            self.db_path.unlink()
        self.temp_telem_dir.cleanup()
        import catalog_retriever
        catalog_retriever.OUT = self.orig_out

    def _read_telemetry_tiers(self) -> list[str]:
        if not self.telem_file.exists():
            return []
        tiers = []
        with open(self.telem_file, "r") as f:
            for line in f:
                if line.strip():
                    data = json.loads(line)
                    if data.get("event") == "retrieval_fallback":
                        tiers.append(data.get("tier"))
        return tiers

    def test_tier_a_hit_on_strict_album_and_rhyme(self):
        pattern = {
            "end_word": "mercedes",
            "end_rime": "EY1 D IY0 Z",
            "vowel_class": "EY",
            "syllables": 14,
            "topic": "drip",
        }
        res = retrieve_matching_catalog_lines("Gunna", pattern, chosen_albums=["Album A"], limit=1, db_path=self.db_path)
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0]["id"], "barA")
        tiers = self._read_telemetry_tiers()
        self.assertEqual(tiers, ["A"])

    def test_tier_b_hit_when_strict_album_misses_but_catalog_has_rhyme(self):
        # Asking for 'Album NonExistent', so Tier A misses on album filter.
        # Tier B drops album filter and finds barB matching rime 'AY1 K'.
        pattern = {
            "end_word": "strike",
            "end_rime": "AY1 K",
            "vowel_class": "AY",
            "syllables": 14,
            "topic": "street",
        }
        res = retrieve_matching_catalog_lines("Gunna", pattern, chosen_albums=["Album NonExistent"], limit=1, db_path=self.db_path)
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0]["id"], "barB")
        tiers = self._read_telemetry_tiers()
        self.assertEqual(tiers, ["B"])

    def test_tier_c_hit_when_rime_misses_but_vowel_matches(self):
        # Target end-word and rime do not exist in catalog, but vowel_class 'OW' matches barC
        pattern = {
            "end_word": "completely_unmatched_word",
            "end_rime": "ZZ1 QQ0",
            "vowel_class": "OW",
            "syllables": 14,
            "topic": "ice",
        }
        res = retrieve_matching_catalog_lines("Gunna", pattern, chosen_albums=[], limit=1, db_path=self.db_path)
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0]["id"], "barC")
        tiers = self._read_telemetry_tiers()
        self.assertEqual(tiers, ["C"])

    def test_tier_d_hit_when_vowel_misses_but_syllables_match(self):
        # Non-matching phonetics, but syllables = 14 matches barD
        pattern = {
            "end_word": "alien_word",
            "end_rime": "XX YY ZZ",
            "vowel_class": "V_unmatched_vowel",
            "syllables": 14,
            "topic": "alien",
        }
        res = retrieve_matching_catalog_lines("Gunna", pattern, chosen_albums=[], limit=1, db_path=self.db_path)
        self.assertEqual(len(res), 1)
        tiers = self._read_telemetry_tiers()
        self.assertEqual(tiers, ["D"])

    def test_fallback_bank_hit_when_all_tiers_miss(self):
        # Syllables = 50 (outside +-4 of any catalog bar), everything misses
        pattern = {
            "end_word": "unknown",
            "end_rime": "NONE",
            "vowel_class": "NONE",
            "syllables": 50,
            "topic": "none",
        }
        res = retrieve_matching_catalog_lines("Gunna", pattern, chosen_albums=[], limit=1, db_path=self.db_path)
        self.assertEqual(len(res), 0)
        tiers = self._read_telemetry_tiers()
        self.assertEqual(tiers, ["bank"])

        # Verify telemetry schema
        with open(self.telem_file, "r") as f:
            row = json.loads(f.readline())
            self.assertEqual(row["event"], "retrieval_fallback")
            self.assertEqual(row["artist"], "Gunna")
            self.assertEqual(row["tier"], "bank")
            self.assertIn("timestamp", row)
            self.assertIn("bar", row)


if __name__ == "__main__":
    unittest.main()
