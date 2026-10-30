"""Spotify track popularity. Cached for 30 days. The client secret is never logged."""

from __future__ import annotations

import json
import time
import urllib.parse
from pathlib import Path

from catalog_build.paths import SPOTIFY_CACHE

CACHE_DAYS = 30


def redact(message: str, secret: str) -> str:
    if secret and secret in message:
        return message.replace(secret, "[redacted]")
    return message


def _now() -> float:
    return time.time()


def load_cache(path: Path = SPOTIFY_CACHE) -> dict[str, dict]:
    if not path.exists():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    entries = data.get("entries") if isinstance(data, dict) else None
    return entries if isinstance(entries, dict) else {}


def save_cache(entries: dict[str, dict], path: Path = SPOTIFY_CACHE) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {"entries": entries}
    tmp = path.parent / f"{path.name}.tmp"
    tmp.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")
    tmp.replace(path)


def cache_key(artist: str, song: str) -> str:
    return f"{artist.strip().lower()}|{song.strip().lower()}"


def cached_popularity(entries: dict[str, dict], artist: str, song: str, now: float | None = None) -> int | None:
    row = entries.get(cache_key(artist, song))
    if not isinstance(row, dict) or "popularity" not in row:
        return None
    stamp = float(row.get("fetched_at") or 0)
    moment = _now() if now is None else now
    if moment - stamp > CACHE_DAYS * 86400:
        return None
    return int(row["popularity"])


def remember(entries: dict[str, dict], artist: str, song: str, popularity: int, now: float | None = None) -> None:
    entries[cache_key(artist, song)] = {
        "popularity": int(popularity),
        "fetched_at": _now() if now is None else now,
    }


class SpotifySearch:
    """GET /v1/search?type=track. Retry-After is honored. Secrets stay out of logs."""

    def __init__(self, client_id: str, client_secret: str) -> None:
        self.client_id = client_id.strip()
        self.client_secret = client_secret.strip()
        self._token = ""
        self._expires = 0.0

    def _token_value(self) -> str:
        from spotify_popularity import SpotifyClient

        if self._token and time.time() < self._expires - 30:
            return self._token
        try:
            client = SpotifyClient(self.client_id, self.client_secret)
            self._token = client.get_token()
        except Exception as exc:
            safe = redact(str(exc), self.client_secret)
            raise RuntimeError(f"Spotify authentication failed: {safe}") from None
        self._expires = time.time() + 3600
        return self._token

    def popularity(self, artist: str, song: str) -> int | None:
        import urllib.error
        import urllib.request

        query = f"track:{song} artist:{artist}"
        params = urllib.parse.urlencode({"type": "track", "q": query, "limit": 1})
        url = f"https://api.spotify.com/v1/search?{params}"
        token = self._token_value()
        request = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
        for attempt in range(3):
            try:
                with urllib.request.urlopen(request, timeout=10) as response:
                    payload = json.loads(response.read().decode("utf-8"))
            except urllib.error.HTTPError as err:
                if err.code == 429:
                    try:
                        wait = int(err.headers.get("Retry-After", "1"))
                    except ValueError:
                        wait = 1
                    print(f"[Spotify] HTTP 429. Waiting {wait}s.", flush=True)
                    time.sleep(max(0, wait))
                    continue
                print(f"[Spotify] HTTP {err.code} for a track search.", flush=True)
                return None
            except Exception as exc:
                print(f"[Spotify] search failed: {redact(str(exc), self.client_secret)}", flush=True)
                if attempt < 2:
                    time.sleep(0.5)
                    continue
                return None
            items = ((payload.get("tracks") or {}).get("items") or [])
            if not items:
                return None
            value = items[0].get("popularity")
            if value is None:
                return None
            return int(value)
        return None


def fetch_popularity(
    songs: list[tuple[str, str]],
    refresh: bool = False,
    cache_path: Path = SPOTIFY_CACHE,
    client: SpotifySearch | None = None,
) -> dict[tuple[str, str], int]:
    """Return (artist_lower, song_lower) -> 0-100. Network only for a miss or refresh."""
    entries = load_cache(cache_path)
    found: dict[tuple[str, str], int] = {}
    pending: list[tuple[str, str]] = []
    for artist, song in songs:
        if not refresh:
            hit = cached_popularity(entries, artist, song)
            if hit is not None:
                found[(artist.strip().lower(), song.strip().lower())] = hit
                continue
        pending.append((artist, song))
    if not pending:
        return found
    search = client
    if search is None:
        from spotify_popularity import load_spotify_credentials

        client_id, secret = load_spotify_credentials()
        if not client_id or not secret:
            print("[Spotify] No credentials. Cache only.", flush=True)
            return found
        search = SpotifySearch(client_id, secret)
    for artist, song in pending:
        try:
            value = search.popularity(artist, song)
        except Exception as exc:
            print(redact(str(exc), getattr(search, "client_secret", "")), flush=True)
            continue
        if value is None:
            continue
        remember(entries, artist, song, value)
        found[(artist.strip().lower(), song.strip().lower())] = value
    if pending:
        save_cache(entries, cache_path)
    return found


def merged_seed_map() -> dict[tuple[str, str], int]:
    """Existing popularity file plus the 30-day cache. No network."""
    from spotify_popularity import load_spotify_popularity_map

    merged = load_spotify_popularity_map()
    now = _now()
    for key, row in load_cache().items():
        if "|" not in key or not isinstance(row, dict):
            continue
        stamp = float(row.get("fetched_at") or 0)
        if now - stamp > CACHE_DAYS * 86400:
            continue
        artist, song = key.split("|", 1)
        try:
            merged[(artist, song)] = int(row["popularity"])
        except (KeyError, TypeError, ValueError):
            continue
    return merged
