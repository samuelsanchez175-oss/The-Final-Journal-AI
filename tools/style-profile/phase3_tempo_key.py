#!/usr/bin/env python3
"""AI Sparkler style profile — Phase 3: BPM / key / mode per song.

Two steps, both cached and resumable (out/tempo_cache.jsonl, append-only):
  resolve : "artist + song title" -> Spotify track id, via Spotify Web API *search*
            (still available to new apps; needs a free developer app, client-credentials).
  features: Spotify track id -> tempo/key/mode/energy/... via ReccoBeats (free, no key).

Credentials: put these two lines in tools/style-profile/.env.spotify (git-ignored), never in chat:
  SPOTIFY_CLIENT_ID=...
  SPOTIFY_CLIENT_SECRET=...

Usage:
  python3 tools/style-profile/phase3_tempo_key.py --artists "Gunna,J. Cole" --limit 50   # coverage test
  python3 tools/style-profile/phase3_tempo_key.py                                        # all songs
  python3 tools/style-profile/phase3_tempo_key.py --step features                        # only ReccoBeats
"""

from __future__ import annotations

import argparse
import base64
import difflib
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

SCHEMA_VERSION = "phase3.v1"
RETRY_UNMATCHED = False
HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
ENV_FILE = HERE / ".env.spotify"
RECCO = "https://api.reccobeats.com/v1/audio-features"
PITCH = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
MIN_TITLE_SIM = 0.85
MIN_ARTIST_SIM = 0.80

# ---------------------------------------------------------------- text matching


def norm_title(t: str) -> str:
    t = t.lower().replace("’", "'")
    t = re.sub(r"\((feat|ft|with|prod)[^)]*\)|\[(feat|ft|with|prod)[^\]]*\]", " ", t)
    t = re.sub(r"\s+-\s+(remaster(ed)?|single|radio edit|clean|explicit|bonus|deluxe).*$", " ", t)
    t = re.sub(r"\b(feat|ft)\.?\s.*$", " ", t)
    return " ".join(re.findall(r"[a-z0-9]+", t))


def norm_artist(a: str) -> str:
    return " ".join(re.findall(r"[a-z0-9]+", a.lower().replace("$", "s")))


def sim(a: str, b: str) -> float:
    return difflib.SequenceMatcher(None, a, b).ratio() if a and b else 0.0


def best_match(artist: str, title: str, items: list[dict]):
    """Pick the Spotify search result that best matches; None if nothing clears the thresholds."""
    want_t, want_a = norm_title(title), norm_artist(artist)
    best, best_score = None, 0.0
    for it in items:
        ts = sim(want_t, norm_title(it.get("name", "")))
        names = [norm_artist(a["name"]) for a in it.get("artists", [])]
        as_ = max((sim(want_a, n) for n in names), default=0.0)
        if ts < MIN_TITLE_SIM or as_ < MIN_ARTIST_SIM:
            continue
        score = 0.65 * ts + 0.35 * as_ + 0.001 * (it.get("popularity") or 0) / 100
        if score > best_score:
            best, best_score = it, score
    return (best, round(best_score, 3)) if best else (None, 0.0)


# ---------------------------------------------------------------- http


def http_json(url: str, headers: dict | None = None, data: bytes | None = None, retries: int = 4):
    for attempt in range(retries):
        req = urllib.request.Request(url, data=data, headers={"User-Agent": "ai-sparkler-profile/1", **(headers or {})})
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                return json.loads(r.read())
        except urllib.error.HTTPError as e:
            if e.code == 429:
                wait = int(e.headers.get("Retry-After", "5"))
                if wait > 300:
                    raise RateLimited(wait)
                time.sleep(wait + 1)
                continue
            if e.code in (500, 502, 503, 504):
                time.sleep(2 ** attempt)
                continue
            if e.code in (400, 404):
                return None
            raise
        except (urllib.error.URLError, TimeoutError):
            time.sleep(2 ** attempt)
    return None


def load_env() -> dict:
    env = {}
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text().splitlines():
            if "=" in line and not line.startswith("#"):
                k, v = line.split("=", 1)
                env[k.strip()] = v.strip()
    return env


class RateLimited(Exception):
    """Spotify asked us to wait too long to just sleep; stop cleanly and resume later."""

    def __init__(self, seconds: int):
        super().__init__(f"Spotify rate limit: retry after {seconds}s (~{seconds / 3600:.1f}h)")
        self.seconds = seconds


class SpotifyToken:
    def __init__(self, cid: str, secret: str):
        self.basic = base64.b64encode(f"{cid}:{secret}".encode()).decode()
        self.token, self.expires = None, 0.0

    def get(self) -> str:
        if not self.token or time.time() > self.expires - 60:
            res = http_json("https://accounts.spotify.com/api/token",
                            {"Authorization": f"Basic {self.basic}", "Content-Type": "application/x-www-form-urlencoded"},
                            b"grant_type=client_credentials")
            if not res:
                sys.exit("Spotify token request failed — check .env.spotify credentials.")
            self.token, self.expires = res["access_token"], time.time() + res.get("expires_in", 3600)
        return self.token


# ---------------------------------------------------------------- cache


def key_of(artist: str, song: str) -> str:
    return f"{artist}|{song}"


def load_cache(path: Path) -> dict:
    cache = {}
    if path.exists():
        for line in path.read_text(encoding="utf-8").splitlines():
            if line.strip():
                row = json.loads(line)
                cache[key_of(row["artist"], row["song"])] = {**cache.get(key_of(row["artist"], row["song"]), {}), **row}
    return cache


def append(path: Path, row: dict) -> None:
    with open(path, "a", encoding="utf-8") as fh:
        fh.write(json.dumps(row, ensure_ascii=False) + "\n")


# ---------------------------------------------------------------- steps


def resolve(songs, cache, cache_path, tok: SpotifyToken, delay: float):
    retry = RETRY_UNMATCHED
    todo = [s for s in songs if key_of(*s) not in cache or "status" not in cache[key_of(*s)]
            or (retry and cache[key_of(*s)].get("status") == "no_match" and cache[key_of(*s)].get("schema") != SCHEMA_VERSION + "+ft")]
    print(f"resolve: {len(todo)} songs to look up ({len(songs) - len(todo)} cached)")
    for i, (artist, song) in enumerate(todo, 1):
        hit, score, items = None, 0.0, []
        for q in (f'track:"{norm_title(song)}" artist:"{artist}"', f"{norm_title(song)} {norm_artist(artist)}"):
            url = "https://api.spotify.com/v1/search?" + urllib.parse.urlencode({"q": q, "type": "track", "limit": 10})
            res = http_json(url, {"Authorization": f"Bearer {tok.get()}"})
            items = ((res or {}).get("tracks") or {}).get("items") or []
            hit, score = best_match(artist, song, items)
            if hit:
                break
            time.sleep(delay)
        row = {"schema": SCHEMA_VERSION + "+ft", "artist": artist, "song": song}
        if hit:
            row.update(status="matched", spotify_id=hit["id"], matched_title=hit["name"],
                       matched_artists=[a["name"] for a in hit["artists"]], match_score=score,
                       isrc=(hit.get("external_ids") or {}).get("isrc"), duration_ms=hit.get("duration_ms"))
        else:
            row.update(status="no_match", candidates=len(items))
        append(cache_path, row)
        cache[key_of(artist, song)] = {**cache.get(key_of(artist, song), {}), **row}
        if i % 100 == 0:
            print(f"  resolved {i}/{len(todo)}")
        time.sleep(delay)


def features(cache, cache_path, delay: float, batch: int = 20):
    todo = [r for r in cache.values() if r.get("status") == "matched" and "tempo" not in r and not r.get("features_missing")]
    print(f"features: {len(todo)} matched songs without tempo")
    for i in range(0, len(todo), batch):
        chunk = todo[i:i + batch]
        res = http_json(RECCO + "?ids=" + ",".join(r["spotify_id"] for r in chunk))
        by_id = {}
        for f in (res or {}).get("content", []):
            m = re.search(r"track/([A-Za-z0-9]+)", f.get("href", ""))
            if m:
                by_id[m.group(1)] = f
        for r in chunk:
            f = by_id.get(r["spotify_id"])
            if f and f.get("tempo"):
                upd = {"artist": r["artist"], "song": r["song"], "tempo": round(f["tempo"], 2), "key": f.get("key"),
                       "mode": f.get("mode"), "key_name": key_name(f.get("key"), f.get("mode")),
                       "energy": f.get("energy"), "danceability": f.get("danceability"), "valence": f.get("valence"),
                       "speechiness": f.get("speechiness"), "loudness": f.get("loudness"), "tempo_source": "reccobeats"}
            else:
                upd = {"artist": r["artist"], "song": r["song"], "features_missing": True}
            append(cache_path, upd)
            cache[key_of(r["artist"], r["song"])].update(upd)
        if (i // batch) % 10 == 0:
            print(f"  features {min(i + batch, len(todo))}/{len(todo)}")
        time.sleep(delay)


def merge_manual(cache, cache_path, manual_path: Path):
    """Fold hand/agent-found tempos (out/tempo_manual.jsonl) into the cache. Spotify/ReccoBeats data wins."""
    if not manual_path.exists():
        print(f"merge-manual: {manual_path.name} not found")
        return
    added = skipped = 0
    for line in manual_path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        m = json.loads(line)
        k = key_of(m["artist"], m["song"])
        if m.get("confidence") not in ("exact", "variant") or not isinstance(m.get("bpm"), (int, float)):
            skipped += 1
            continue
        if "tempo" in cache.get(k, {}):
            continue
        name = m.get("key")
        upd = {"artist": m["artist"], "song": m["song"], "tempo": round(float(m["bpm"]), 2), "key_name": name,
               "tempo_source": f"web:{m.get('source')}", "tempo_url": m.get("url"), "tempo_confidence": m["confidence"]}
        append(cache_path, upd)
        cache.setdefault(k, {"artist": m["artist"], "song": m["song"]}).update(upd)
        added += 1
    print(f"merge-manual: {added} added, {skipped} skipped (not found / no bpm)")


def key_name(key, mode):
    if key is None or key < 0:
        return None
    return f"{PITCH[key]} {'major' if mode == 1 else 'minor'}"


def songs_from_phase1(path: Path, artists: set[str] | None):
    out = []
    for line in open(path, encoding="utf-8"):
        r = json.loads(line)
        if artists and r["artist"].lower() not in artists:
            continue
        out.append((r["artist"], r["song"]))
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--songs", type=Path, default=OUT / "song_metrics.jsonl", help="Phase 1 output (song list source)")
    ap.add_argument("--artists")
    ap.add_argument("--limit", type=int, help="only the first N songs")
    ap.add_argument("--sample", type=int, help="random N songs across artists (coverage test, seeded)")
    ap.add_argument("--step", choices=["resolve", "features", "all"], default="all")
    ap.add_argument("--merge-manual", action="store_true", help="fold out/tempo_manual.jsonl into the cache and exit")
    ap.add_argument("--retry-unmatched", action="store_true", help="re-search earlier misses with the free-text fallback")
    ap.add_argument("--delay", type=float, default=1.2, help="seconds between Spotify requests (dev-mode apps are rate-limited hard)")
    ap.add_argument("--cache", type=Path, default=OUT / "tempo_cache.jsonl")
    args = ap.parse_args()

    global RETRY_UNMATCHED
    RETRY_UNMATCHED = args.retry_unmatched
    OUT.mkdir(exist_ok=True)
    artists = {a.strip().lower() for a in args.artists.split(",")} if args.artists else None
    songs = songs_from_phase1(args.songs, artists)
    if args.sample:
        import random
        songs = random.Random(7).sample(songs, min(args.sample, len(songs)))
    if args.limit:
        songs = songs[: args.limit]
    cache = load_cache(args.cache)

    if args.merge_manual:
        merge_manual(cache, args.cache, OUT / "tempo_manual.jsonl")
        return 0

    if args.step in ("resolve", "all"):
        env = load_env()
        if "SPOTIFY_CLIENT_ID" not in env or "SPOTIFY_CLIENT_SECRET" not in env:
            print(f"No Spotify credentials in {ENV_FILE}. Skipping resolve (use --step features to only run ReccoBeats).")
        else:
            try:
                resolve(songs, cache, args.cache, SpotifyToken(env["SPOTIFY_CLIENT_ID"], env["SPOTIFY_CLIENT_SECRET"]), args.delay)
            except RateLimited as e:
                print(f"STOPPED: {e}. Progress is saved; re-run later to resume.")
    if args.step in ("features", "all"):
        features(cache, args.cache, args.delay)

    mine = [cache[k] for k in (key_of(*s) for s in songs) if k in cache]
    matched = sum(1 for r in mine if r.get("status") == "matched")
    with_tempo = sum(1 for r in mine if "tempo" in r)
    print(f"coverage: {len(songs)} songs, {matched} matched ({100 * matched // max(1, len(songs))}%), "
          f"{with_tempo} with tempo ({100 * with_tempo // max(1, len(songs))}%)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
