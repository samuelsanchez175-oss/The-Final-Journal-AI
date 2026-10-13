#!/usr/bin/env python3
"""GetSongBPM API fallback: query songs without tempo from Phase 3 cache.

Queries GetSongBPM.com API for BPM + key on songs that Spotify/ReccoBeats missed.
Respects rate limit (3k req/hr = 1 req per 1.2s). Appends results to tempo_manual.jsonl.
Resumable: skips songs already in manual or cache.

Usage:
  python3 tools/style-profile/phase3_getsongbpm_fallback.py [--artists "Gunna,Chief Keef"] [--limit 100]

Output: appends rows to out/tempo_manual.jsonl. Status file every 25 songs.
"""

from __future__ import annotations

import argparse
import json
import time
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter
from pathlib import Path

import phase1_song_metrics as p1

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"

GETSONGBPM_API = "https://www.getsongbpm.com/api/search"
DELAY_SEC = 1.2  # 3k req/hr = 1.2s per request
RATE_LIMIT_WAIT_SEC = 60  # if we hit rate limit, wait this long


def load_cache() -> dict:
    """Load Phase 3 tempo cache (artist|song -> has tempo?))."""
    cache = {}
    if (OUT / "tempo_cache.jsonl").exists():
        for line in open(OUT / "tempo_cache.jsonl", encoding="utf-8"):
            if line.strip():
                r = json.loads(line)
                key = f"{r['artist']}|{r['song']}"
                cache[key] = "tempo" in r
    return cache


def load_manual() -> set:
    """Load manual lookup results (artist|song keys already attempted)."""
    manual = set()
    if (OUT / "tempo_manual.jsonl").exists():
        for line in open(OUT / "tempo_manual.jsonl", encoding="utf-8"):
            if line.strip():
                r = json.loads(line)
                manual.add(f"{r['artist']}|{r['song']}")
    return manual


def query_getsongbpm(artist: str, song: str) -> dict | None:
    """Query GetSongBPM API. Returns {bpm, key} or None."""
    try:
        url = GETSONGBPM_API + "?" + urllib.parse.urlencode({"artist": artist, "title": song})
        req = urllib.request.Request(url, headers={"User-Agent": "ai-sparkler/1"})
        with urllib.request.urlopen(req, timeout=10) as r:
            data = json.loads(r.read())

        # API returns list of results; take first if available
        if data and isinstance(data, list) and len(data) > 0:
            result = data[0]
            bpm = result.get("bpm")
            key = result.get("key")
            return {"bpm": bpm, "key": key, "title": result.get("song_title")}
    except urllib.error.HTTPError as e:
        if e.code == 429:
            return "rate_limited"
        # 404 or other error = not found
    except Exception:
        pass

    return None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--artists", help="comma-separated artist names (default: all from worklist)")
    ap.add_argument("--limit", type=int, help="max songs to query")
    args = ap.parse_args()

    # Load worklist
    worklist = []
    if (OUT / "tempo_worklist.jsonl").exists():
        for line in open(OUT / "tempo_worklist.jsonl", encoding="utf-8"):
            if line.strip():
                r = json.loads(line)
                worklist.append(r)

    # Filter by artists if specified
    if args.artists:
        artists = {a.strip().lower() for a in args.artists.split(",")}
        worklist = [w for w in worklist if w["artist"].lower() in artists]

    # Load cache + manual to skip already-done songs
    cache = load_cache()
    manual = load_manual()
    todo = []
    for w in worklist:
        key = f"{w['artist']}|{w['song']}"
        if key in manual or cache.get(key):
            continue
        todo.append(w)

    if args.limit:
        todo = todo[:args.limit]

    print(f"GetSongBPM fallback: {len(todo)} songs to query")

    found = skipped = not_found = 0
    with open(OUT / "tempo_manual.jsonl", "a", encoding="utf-8") as fh:
        for i, work in enumerate(todo, 1):
            artist, song = work["artist"], work["song"]

            result = query_getsongbpm(artist, song)

            if result == "rate_limited":
                print(f"Rate limited at song {i}. Waiting {RATE_LIMIT_WAIT_SEC}s...")
                time.sleep(RATE_LIMIT_WAIT_SEC)
                result = query_getsongbpm(artist, song)

            if result and result.get("bpm"):
                row = {
                    "artist": artist,
                    "song": song,
                    "bpm": result["bpm"],
                    "key": result.get("key"),
                    "source": "getsongbpm",
                    "url": f"https://www.getsongbpm.com/?song={urllib.parse.quote(song)}&artist={urllib.parse.quote(artist)}",
                    "confidence": "exact",
                    "notes": result.get("title", "")
                }
                fh.write(json.dumps(row, ensure_ascii=False) + "\n")
                found += 1
            elif result is None:
                row = {
                    "artist": artist,
                    "song": song,
                    "bpm": None,
                    "confidence": "not_found",
                    "source": "getsongbpm"
                }
                fh.write(json.dumps(row, ensure_ascii=False) + "\n")
                not_found += 1
            else:
                skipped += 1

            if i % 25 == 0:
                pct = 100 * i / len(todo) if todo else 0
                print(f"  {i}/{len(todo)} ({pct:.0f}%) — {found} found, {not_found} not_found, {skipped} skipped")

            time.sleep(DELAY_SEC)

    # Write status file
    status = f"""# GetSongBPM Fallback Status

## Summary
- **Total queried**: {len(todo)}
- **Found**: {found}
- **Not found**: {not_found}
- **Skipped/errors**: {skipped}

## Next
Run: python3 phase3_tempo_key.py --merge-manual
"""
    (OUT / "tempo_manual_status.md").write_text(status)
    print(f"\nDone: {found} found, {not_found} not_found, {skipped} skipped")
    print(f"Status: {OUT / 'tempo_manual_status.md'}")
    return 0


if __name__ == "__main__":
    import sys
    sys.path.insert(0, str(HERE))
    sys.exit(main())
