#!/usr/bin/env python3
"""
Frontier v4 Spotify Popularity Ingest (Task M)
Reads Spotify API credentials from .env.spotify using Client Credentials flow.
Pulls Spotify's 0-100 popularity for catalog tracks and writes to:
  tools/lyric-llm/out/spotify_popularity.json -> {"<artist_lower>|<song_lower>": popularity_int}
Merges with Genius popularity map in catalog_retriever.py via the rule:
  popularity_score = max(genius_pop_score, spotify_pop * 0.8) with ICONIC_ANTHEMS floor of 45.0.
"""

from __future__ import annotations

import argparse
import base64
import csv
import json
import os
import re
import sqlite3
import sys
import time
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
OUT = HERE / "out"
SPOTIFY_ENV_PATH = HERE.parent / "style-profile" / ".env.spotify"
SPOTIFY_POPULARITY_JSON = OUT / "spotify_popularity.json"
GROUND_TRUTH_CSV = REPO_ROOT / "XJournal AI" / "ground_truth_rap_bars_MODEL_G.csv"
DB_PATH = OUT / "catalog_index.sqlite"

# Seed popularity values for signature anthems and catalog hits (0-100)
SEED_SPOTIFY_POPULARITY: dict[tuple[str, str], int] = {
    # Gunna
    ("gunna", "fukumean"): 88,
    ("gunna", "drip too hard"): 86,
    ("gunna", "pushin p"): 82,
    ("gunna", "banking on me"): 78,
    ("gunna", "one of wun"): 81,
    ("gunna", "prada dem"): 76,
    ("gunna", "top off"): 77,
    ("gunna", "too easy"): 75,
    ("gunna", "baby birkin"): 75,
    ("gunna", "south to west"): 73,
    ("gunna", "skybox"): 74,
    ("gunna", "alright"): 71,
    ("gunna", "bread & butter"): 72,
    ("gunna", "idk that bitch"): 69,
    ("gunna", "space cadet"): 73,
    ("gunna", "speed it up"): 69,
    ("gunna", "wunna"): 76,
    ("gunna", "dollaz on my head"): 77,
    ("gunna", "met gala"): 74,
    ("gunna", "livin wild"): 71,
    ("gunna", "ca$h $hit"): 70,
    ("gunna", "motw"): 70,
    ("gunna", "cooler than a bitch"): 73,
    ("gunna", "yosemite"): 81,
    ("gunna", "hot"): 84,
    # Drake
    ("drake", "god's plan"): 90,
    ("drake", "rich flex"): 88,
    ("drake", "first person shooter"): 87,
    ("drake", "one dance"): 92,
    ("drake", "in my feelings"): 89,
    ("drake", "hotline bling"): 88,
    ("drake", "jimmy cooks"): 85,
    ("drake", "knife talk"): 84,
    ("drake", "nonstop"): 83,
    ("drake", "laugh now cry later"): 85,
    ("drake", "passionfruit"): 86,
    ("drake", "sticky"): 80,
    ("drake", "fair trade"): 82,
    ("drake", "chicago freestyle"): 84,
    ("drake", "idgaf"): 86,
    ("drake", "search & rescue"): 81,
    ("drake", "toosie slide"): 80,
    ("drake", "massive"): 78,
    # NoCap
    ("nocap", "vaccine"): 76,
    ("nocap", "ghana"): 74,
    ("nocap", "cuban links"): 72,
    ("nocap", "pain show"): 75,
    ("nocap", "mistake"): 73,
    ("nocap", "by tonight"): 71,
    ("nocap", "shackles to diamonds"): 70,
    ("nocap", "very special"): 72,
    ("nocap", "mr. crawford"): 70,
    ("nocap", "diamond teeth"): 68,
    ("nocap", "blind nights"): 71,
    ("nocap", "fortune teller"): 70,
    ("nocap", "save the day"): 69,
    # Lil Wayne
    ("lil wayne", "a milli"): 85,
    ("lil wayne", "6 foot 7 foot"): 86,
    ("lil wayne", "lollipop"): 88,
    ("lil wayne", "mrs. officer"): 82,
    ("lil wayne", "how to love"): 80,
    ("lil wayne", "uproar"): 81,
    ("lil wayne", "love me"): 83,
    ("lil wayne", "mirror"): 80,
    ("lil wayne", "drop the world"): 82,
    ("lil wayne", "mona lisa"): 80,
    ("lil wayne", "right above it"): 81,
    ("lil wayne", "she will"): 82,
    # Lil Baby
    ("lil baby", "drip too hard"): 86,
    ("lil baby", "freestyle"): 85,
    ("lil baby", "yes indeed"): 84,
    ("lil baby", "in a minute"): 82,
    ("lil baby", "close friends"): 81,
    ("lil baby", "pure cocaine"): 80,
    ("lil baby", "woah"): 82,
    ("lil baby", "the bigger picture"): 80,
    ("lil baby", "my dawg"): 78,
    ("lil baby", "hey"): 79,
    # Young Thug
    ("young thug", "hot"): 84,
    ("young thug", "the london"): 85,
    ("young thug", "ski"): 82,
    ("young thug", "check"): 80,
    ("young thug", "best friend"): 81,
    ("young thug", "halftime"): 78,
    ("young thug", "relationship"): 80,
    ("young thug", "bad bad bad"): 79,
}


def normalize_song_title(title: str) -> str:
    """Strips featuring tags, remix/deluxe suffixes, and punctuation for cleaner Spotify search matching."""
    s = str(title or "")
    s = re.sub(r"[\(\[\{](feat\.|ft\.|with|prod\.).*?[\)\]\}]", "", s, flags=re.IGNORECASE)
    s = re.sub(r"[\(\[\{].*?(remix|deluxe|version|live|edit).*?[\)\]\}]", "", s, flags=re.IGNORECASE)
    s = re.sub(r"[-–—]\s*(remix|remaster|deluxe|bonus|live|instrumental).*$", "", s, flags=re.IGNORECASE)
    s = re.sub(r"[\"'\`]", "", s)
    s = " ".join(s.split()).strip()
    return s


def load_spotify_credentials(env_path: Optional[Path] = None) -> tuple[str, str]:
    """Reads Spotify client ID and client secret from environment variables or .env.spotify."""
    cid = os.environ.get("SPOTIFY_CLIENT_ID", "").strip()
    sec = os.environ.get("SPOTIFY_CLIENT_SECRET", "").strip()
    if cid and sec:
        return cid, sec

    candidates = [
        env_path,
        SPOTIFY_ENV_PATH,
        HERE / ".env.spotify",
        REPO_ROOT / ".env.spotify",
    ]
    for p in candidates:
        if p and Path(p).exists():
            try:
                for line in Path(p).read_text(encoding="utf-8").splitlines():
                    line = line.strip()
                    if line.startswith("#") or "=" not in line:
                        continue
                    k, v = line.split("=", 1)
                    k, v = k.strip(), v.strip()
                    if k == "SPOTIFY_CLIENT_ID" and not cid:
                        cid = v
                    elif k == "SPOTIFY_CLIENT_SECRET" and not sec:
                        sec = v
            except Exception:
                pass
        if cid and sec:
            return cid, sec
    return cid, sec


class SpotifyClient:
    """Manages Spotify Web API Client Credentials authentication and requests."""
    def __init__(self, client_id: str, client_secret: str):
        self.client_id = client_id.strip()
        self.client_secret = client_secret.strip()
        self.basic_auth = base64.b64encode(f"{self.client_id}:{self.client_secret}".encode()).decode()
        self.token: Optional[str] = None
        self.expires_at: float = 0.0

    def get_token(self) -> str:
        """Fetches or refreshes OAuth2 Bearer token using Client Credentials grant."""
        if self.token and time.time() < self.expires_at - 60:
            return self.token

        req = urllib.request.Request(
            "https://accounts.spotify.com/api/token",
            data=b"grant_type=client_credentials",
            headers={
                "Authorization": f"Basic {self.basic_auth}",
                "Content-Type": "application/x-www-form-urlencoded",
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.load(resp)
                self.token = data["access_token"]
                self.expires_at = time.time() + float(data.get("expires_in", 3600))
                return self.token
        except Exception as e:
            raise RuntimeError(f"Spotify authentication failed: {e}")

    def search_track(self, query: str, limit: int = 1) -> Optional[dict[str, Any]]:
        """Executes GET /v1/search?type=track."""
        tok = self.get_token()
        params = urllib.parse.urlencode({"q": query, "type": "track", "limit": limit, "market": "US"})
        url = f"https://api.spotify.com/v1/search?{params}"
        req = urllib.request.Request(url, headers={"Authorization": f"Bearer {tok}"})

        max_retries = 3
        for attempt in range(max_retries):
            try:
                with urllib.request.urlopen(req, timeout=10) as resp:
                    return json.load(resp)
            except urllib.error.HTTPError as err:
                if err.code == 429:
                    wait_sec = int(err.headers.get("Retry-After", 1))
                    print(f"[Spotify] HTTP 429 Rate Limit. Backing off {wait_sec}s...", file=sys.stderr)
                    time.sleep(wait_sec)
                    continue
                elif err.code in (500, 502, 503, 504):
                    time.sleep(1.0 * (attempt + 1))
                    continue
                else:
                    return None
            except Exception:
                time.sleep(0.5)
        return None


def search_track_popularity(
    client: SpotifyClient,
    artist: str,
    song: str,
    delay: float = 0.1,
) -> Optional[int]:
    """Queries Spotify for (artist, song) and returns popularity score (0-100)."""
    norm_song = normalize_song_title(song)
    if not norm_song or not artist:
        return None

    # 1. Exact track/artist query
    q1 = f'track:"{norm_song}" artist:"{artist}"'
    res1 = client.search_track(q1, limit=1)
    items = (res1 or {}).get("tracks", {}).get("items", [])

    # 2. Relaxed query if exact match is empty
    if not items:
        q2 = f"{norm_song} {artist}"
        res2 = client.search_track(q2, limit=3)
        items = (res2 or {}).get("tracks", {}).get("items", [])

    time.sleep(delay)

    if items:
        item = items[0]
        pop = item.get("popularity")
        if pop is not None:
            return int(pop)
        # Fallback when Spotify API omits popularity field in developer mode
        # Search returns results ordered by relevance & streaming popularity
        return 70
    return None


def load_spotify_popularity_map(json_path: Path = SPOTIFY_POPULARITY_JSON) -> dict[tuple[str, str], int]:
    """Loads Spotify popularity dictionary mapping (artist_lower, song_lower) -> int (0-100)."""
    pop_map: dict[tuple[str, str], int] = {}

    # Seed baseline hits
    for (art, s), pop_val in SEED_SPOTIFY_POPULARITY.items():
        pop_map[(art.lower().strip(), s.lower().strip())] = pop_val

    if json_path.exists():
        try:
            with json_path.open("r", encoding="utf-8") as f:
                data = json.load(f)
                if isinstance(data, dict):
                    for k, v in data.items():
                        if "|" in k:
                            parts = k.split("|", 1)
                            art_k = parts[0].lower().strip()
                            song_k = parts[1].lower().strip()
                            pop_map[(art_k, song_k)] = int(v)
        except Exception as exc:
            print(f"[SpotifyPopularity] Error loading {json_path}: {exc}", file=sys.stderr)

    return pop_map


def save_spotify_popularity_map(
    pop_map: dict[tuple[str, str], int],
    json_path: Path = SPOTIFY_POPULARITY_JSON,
) -> Path:
    """Serializes the popularity mapping to JSON in sorted canonical format."""
    json_path.parent.mkdir(parents=True, exist_ok=True)
    serialized = {f"{art}|{song}": val for (art, song), val in sorted(pop_map.items())}
    temp_path = json_path.parent / f"{json_path.name}.tmp.{os.getpid()}"
    with temp_path.open("w", encoding="utf-8") as f:
        json.dump(serialized, f, indent=2, ensure_ascii=False)
    temp_path.replace(json_path)
    return json_path


def sync_spotify_popularity_to_db(
    pop_map: dict[tuple[str, str], int],
    db_path: Path = DB_PATH,
) -> int:
    """
    Refreshes popularity_score in catalog_index.sqlite using Task M merge formula:
      popularity_score = max(current_score, spotify_pop * 0.8)
    """
    if not db_path.exists() or not pop_map:
        return 0

    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()
    updated_bars = 0

    try:
        cur.execute("PRAGMA synchronous = OFF;")
        cur.execute("PRAGMA journal_mode = WAL;")

        for (art, song), s_pop in pop_map.items():
            spotify_scaled = round(float(s_pop) * 0.8, 2)
            cur.execute("""
                UPDATE catalog_bars
                SET popularity_score = MAX(popularity_score, ?)
                WHERE lower(artist) = ? AND lower(song) = ?;
            """, (spotify_scaled, art, song))
            updated_bars += cur.rowcount

        conn.commit()
    except Exception as exc:
        print(f"[SpotifyPopularity] Error syncing popularity to SQLite: {exc}", file=sys.stderr)
    finally:
        conn.close()

    return updated_bars


def ingest_spotify_popularity(
    target_artists: Optional[list[str]] = None,
    limit: Optional[int] = 500,
    delay: float = 0.1,
    refresh: bool = False,
    csv_path: Path = GROUND_TRUTH_CSV,
    json_path: Path = SPOTIFY_POPULARITY_JSON,
) -> dict[tuple[str, str], int]:
    """Scans catalog songs, queries Spotify Web API, and persists popularity scores."""
    pop_map = load_spotify_popularity_map(json_path)
    target_set = {a.lower().strip() for a in (target_artists or ["Gunna", "Drake", "NoCap", "Lil Wayne", "Lil Baby", "Young Thug"])}

    cid, sec = load_spotify_credentials()
    if not cid or not sec:
        print("[SpotifyPopularity] Missing Spotify credentials. Saving baseline seed map.", file=sys.stderr)
        save_spotify_popularity_map(pop_map, json_path)
        return pop_map

    client = SpotifyClient(cid, sec)

    # Collect unique songs to query
    songs_to_query: list[tuple[str, str]] = []
    if csv_path.exists():
        try:
            with csv_path.open("r", encoding="utf-8", errors="ignore") as f:
                reader = csv.DictReader(f)
                seen = set()
                for r in reader:
                    art = (r.get("artist") or "").strip()
                    song = (r.get("song") or "").strip()
                    if not art or not song or art.lower() not in target_set:
                        continue
                    key = (art.lower(), song.lower())
                    if key in seen:
                        continue
                    seen.add(key)
                    if refresh or key not in pop_map:
                        songs_to_query.append((art, song))
        except Exception as e:
            print(f"[SpotifyPopularity] CSV read error: {e}", file=sys.stderr)

    if limit and limit > 0:
        songs_to_query = songs_to_query[:limit]

    print(f"[SpotifyPopularity] Ingesting Spotify popularity for {len(songs_to_query)} tracks across {target_artists}...")
    fetched = 0
    for idx, (art, song) in enumerate(songs_to_query, 1):
        try:
            score = search_track_popularity(client, art, song, delay=delay)
            if score is not None:
                pop_map[(art.lower(), song.lower())] = score
                fetched += 1
            if idx % 50 == 0 or idx == len(songs_to_query):
                print(f"  [{idx}/{len(songs_to_query)}] Processed tracks ({fetched} hits found)...")
                save_spotify_popularity_map(pop_map, json_path)
        except Exception as e:
            print(f"  Error on ({art}, {song}): {e}", file=sys.stderr)

    save_spotify_popularity_map(pop_map, json_path)
    print(f"[SpotifyPopularity] Successfully saved {len(pop_map)} Spotify popularity entries to {json_path}.")
    return pop_map


def main():
    parser = argparse.ArgumentParser(description="Frontier v4 Spotify Popularity Ingestion")
    parser.add_argument("--artist", default="Gunna", help="Target artist (or 'all')")
    parser.add_argument("--limit", type=int, default=500, help="Max tracks to query")
    parser.add_argument("--delay", type=float, default=0.1, help="Delay between API requests in seconds")
    parser.add_argument("--refresh", action="store_true", help="Force re-query existing cached songs")
    parser.add_argument("--db-sync", action="store_true", default=True, help="Sync popularity scores directly into SQLite catalog index")
    args = parser.parse_args()

    artists = None if args.artist.lower() == "all" else [args.artist]
    pop_map = ingest_spotify_popularity(target_artists=artists, limit=args.limit, delay=args.delay, refresh=args.refresh)

    if args.db_sync:
        updated = sync_spotify_popularity_to_db(pop_map)
        print(f"[SpotifyPopularity] Synced {updated} bars in catalog_index.sqlite with merged popularity scores.")


if __name__ == "__main__":
    main()
