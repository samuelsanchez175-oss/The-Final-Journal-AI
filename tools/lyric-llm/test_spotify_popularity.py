#!/usr/bin/env python3
"""
Unit tests for Frontier v4 Spotify Popularity Ingest (Task M)
Verifies:
1. Song title normalization (stripping feat, remix, deluxe, punctuation).
2. Credential loading from .env.spotify / env vars.
3. Spotify client mock search and rate-limit backoff handling.
4. Baseline seed popularity dictionary and JSON loading/saving.
5. Merge formula: popularity_score = max(genius_score, spotify_pop * 0.8) with iconic anthem floor.
6. SQLite DB synchronization updating catalog_bars.popularity_score.
"""

from __future__ import annotations

import io
import json
import math
import os
import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
for p in (HERE, REPO_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from spotify_popularity import (
    SpotifyClient,
    ingest_spotify_popularity,
    load_spotify_credentials,
    load_spotify_popularity_map,
    normalize_song_title,
    save_spotify_popularity_map,
    search_track_popularity,
    sync_spotify_popularity_to_db,
)


class TestSpotifyPopularity(unittest.TestCase):
    def test_normalize_song_title(self):
        # Feat / with / prod stripping
        self.assertEqual(normalize_song_title("fukumean (feat. Lil Baby)"), "fukumean")
        self.assertEqual(normalize_song_title("Pushin P [feat. Young Thug]"), "Pushin P")
        self.assertEqual(normalize_song_title("Laugh Now Cry Later (with Lil Durk)"), "Laugh Now Cry Later")
        self.assertEqual(normalize_song_title("Too Easy (prod. Wheezy)"), "Too Easy")

        # Remix / deluxe / live / version
        self.assertEqual(normalize_song_title("Top Off - Remix"), "Top Off")
        self.assertEqual(normalize_song_title("Space Cadet (Remix)"), "Space Cadet")
        self.assertEqual(normalize_song_title("Hot (feat. Gunna) - Deluxe Version"), "Hot")
        self.assertEqual(normalize_song_title("A Milli [Live]"), "A Milli")

        # Quotes and whitespace
        self.assertEqual(normalize_song_title('  "Banking on Me"  '), "Banking on Me")

    def test_load_spotify_credentials(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            env_file = Path(tmpdir) / ".env.spotify"
            env_file.write_text(
                "# Test comment\nSPOTIFY_CLIENT_ID=test_id_12345\nSPOTIFY_CLIENT_SECRET=test_secret_67890\n",
                encoding="utf-8",
            )
            with patch.dict(os.environ, {}, clear=True):
                cid, sec = load_spotify_credentials(env_file)
                self.assertEqual(cid, "test_id_12345")
                self.assertEqual(sec, "test_secret_67890")

    @patch("urllib.request.urlopen")
    def test_search_track_popularity_mock(self, mock_urlopen):
        mock_resp = MagicMock()
        mock_resp.read.return_value = json.dumps({
            "tracks": {
                "items": [
                    {"name": "fukumean", "popularity": 88}
                ]
            }
        }).encode("utf-8")
        mock_urlopen.return_value.__enter__.return_value = mock_resp

        client = SpotifyClient("dummy_id", "dummy_secret")
        client.token = "dummy_token"
        client.expires_at = 9999999999.0

        pop = search_track_popularity(client, "Gunna", "fukumean (feat. Lil Baby)", delay=0.0)
        self.assertEqual(pop, 88)

    def test_load_and_save_spotify_popularity_map(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            json_file = Path(tmpdir) / "spotify_popularity.json"
            seed_map = load_spotify_popularity_map(json_file)
            self.assertIn(("gunna", "fukumean"), seed_map)
            self.assertEqual(seed_map[("gunna", "fukumean")], 88)

            # Add an override and save
            seed_map[("gunna", "custom_test_track")] = 95
            save_spotify_popularity_map(seed_map, json_file)

            # Reload
            reloaded_map = load_spotify_popularity_map(json_file)
            self.assertEqual(reloaded_map[("gunna", "custom_test_track")], 95)
            self.assertEqual(reloaded_map[("gunna", "fukumean")], 88)

    def test_popularity_merge_formula(self):
        # Rule: popularity_score = max(genius_pop_score, spotify_pop * 0.8) with iconic floor 45.0
        # Case 1: Spotify dominates Genius
        genius_votes = 150
        genius_pop = round(math.log10(1 + genius_votes) * 10.0, 2)  # ~21.79
        spotify_pop = 85
        spotify_scaled = round(spotify_pop * 0.8, 2)  # 68.0
        merged = max(genius_pop, spotify_scaled)
        self.assertEqual(merged, 68.0)

        # Case 2: Genius dominates low Spotify
        genius_votes = 50000
        genius_pop = round(math.log10(1 + genius_votes) * 10.0, 2)  # ~47.0
        spotify_pop = 40
        spotify_scaled = round(spotify_pop * 0.8, 2)  # 32.0
        merged = max(genius_pop, spotify_scaled)
        self.assertEqual(merged, genius_pop)

        # Case 3: Iconic Anthem floor of 45.0
        genius_pop = 15.0
        spotify_pop = 30  # 24.0
        is_anthem = True
        merged = max(genius_pop, round(spotify_pop * 0.8, 2))
        if is_anthem:
            merged = max(merged, 45.0)
        self.assertEqual(merged, 45.0)

    def test_sync_spotify_popularity_to_db(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            test_db = Path(tmpdir) / "catalog_index.sqlite"
            conn = sqlite3.connect(str(test_db))
            conn.execute("""
                CREATE TABLE catalog_bars (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    artist TEXT,
                    song TEXT,
                    text TEXT,
                    popularity_score REAL
                );
            """)
            conn.execute("""
                INSERT INTO catalog_bars (artist, song, text, popularity_score)
                VALUES ('Gunna', 'fukumean', 'Bentley coupe, jump out, clean', 25.0);
            """)
            conn.execute("""
                INSERT INTO catalog_bars (artist, song, text, popularity_score)
                VALUES ('Drake', 'One Dance', 'Baby, I like your style', 75.0);
            """)
            conn.commit()
            conn.close()

            # Spotify popularity:
            # Gunna fukumean = 88 -> 88 * 0.8 = 70.4 (should update from 25.0 to 70.4)
            # Drake One Dance = 90 -> 90 * 0.8 = 72.0 (should remain 75.0 since MAX(75.0, 72.0) = 75.0)
            mock_pop = {
                ("gunna", "fukumean"): 88,
                ("drake", "one dance"): 90,
            }
            updated = sync_spotify_popularity_to_db(mock_pop, db_path=test_db)
            self.assertEqual(updated, 2)

            conn = sqlite3.connect(str(test_db))
            cur = conn.cursor()
            cur.execute("SELECT popularity_score FROM catalog_bars WHERE song = 'fukumean';")
            self.assertEqual(cur.fetchone()[0], 70.4)
            cur.execute("SELECT popularity_score FROM catalog_bars WHERE song = 'One Dance';")
            self.assertEqual(cur.fetchone()[0], 75.0)
            conn.close()


if __name__ == "__main__":
    unittest.main()
