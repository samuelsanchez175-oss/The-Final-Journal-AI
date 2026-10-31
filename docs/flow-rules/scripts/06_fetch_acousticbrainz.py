#!/usr/bin/env python3
"""MusicBrainz → AcousticBrainz for every unique (Gunna, song).

No API key required. Rate-limited: 1 req/sec against each host, back off
on 429. Caches responses under docs/flow-rules/cache/{musicbrainz,
acousticbrainz}/<sha1>.json so reruns don't refetch.

Writes docs/flow-rules/gunna_acousticbrainz.csv:
  artist,song,norm_title,mbid,bpm_ab,key_of_ab,scale_ab,
  danceability_ab,aggressive_ab,ab_match
"""
from __future__ import annotations

import csv
import hashlib
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
OUT = REPO / "docs" / "flow-rules"
CACHE_DIR = OUT / "cache"
UA = "pennworkstudios-flow-rules/0.1 (samuelsanchez175@gmail.com)"


def _norm_title(title: str) -> str:
    t = title or ""
    t = re.sub(r"\s*\(feat\.?[^)]+\)", "", t, flags=re.IGNORECASE)
    t = re.sub(r"\s*\[feat\.?[^\]]+\]", "", t, flags=re.IGNORECASE)
    t = re.sub(r"\s*\((remix|remastered.*|.* version|original.*)\)", "", t, flags=re.IGNORECASE)
    t = re.sub(r"[^\w\s]", " ", t)
    t = re.sub(r"\s+", " ", t).strip().lower()
    return t


def _slug(*parts: str) -> str:
    return hashlib.sha1("|".join(parts).encode("utf-8")).hexdigest()[:16]


def _cache(source: str, slug: str) -> Path:
    (CACHE_DIR / source).mkdir(parents=True, exist_ok=True)
    return CACHE_DIR / source / f"{slug}.json"


def _get(url: str, retries: int = 3) -> dict | None:
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=30) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            if e.code == 429:
                time.sleep(2.0 * (2 ** attempt))
                continue
            if e.code == 404:
                return {"not_found": True, "status": 404}
            if 500 <= e.code < 600 and attempt + 1 < retries:
                time.sleep(2.0 * (2 ** attempt))
                continue
            return {"error": f"http {e.code}"}
        except Exception as exc:
            if attempt + 1 < retries:
                time.sleep(1.5)
                continue
            return {"error": str(exc)}
    return None


def mb_recording(artist: str, title: str) -> dict | None:
    slug = _slug("mb", artist, title)
    cp = _cache("musicbrainz", slug)
    if cp.exists():
        return json.loads(cp.read_text())
    q = f'recording:"{title}" AND artist:"{artist}"'
    url = ("https://musicbrainz.org/ws/2/recording/"
           f"?query={urllib.parse.quote(q)}&fmt=json&limit=5")
    time.sleep(1.1)
    res = _get(url)
    if res is not None:
        cp.write_text(json.dumps(res))
    return res


def ab_pair(mbid: str) -> dict:
    slug = _slug("ab", mbid)
    cp = _cache("acousticbrainz", slug)
    if cp.exists():
        return json.loads(cp.read_text())
    time.sleep(1.1)
    low = _get(f"https://acousticbrainz.org/{mbid}/low-level")
    time.sleep(1.1)
    high = _get(f"https://acousticbrainz.org/{mbid}/high-level")
    out = {"low": low, "high": high}
    cp.write_text(json.dumps(out))
    return out


def _ab_fields(res: dict | None) -> dict:
    if not isinstance(res, dict):
        return {}
    low = (res.get("low") or {}) if isinstance(res.get("low"), dict) else {}
    high = (res.get("high") or {}) if isinstance(res.get("high"), dict) else {}
    bpm = (low.get("rhythm") or {}).get("bpm") if low else None
    key_of = (low.get("tonal") or {}).get("key_key") if low else None
    scale = (low.get("tonal") or {}).get("key_scale") if low else None
    hl = (high.get("highlevel") or {}) if high else {}
    dance = (hl.get("danceability") or {}).get("all", {}).get("danceable") if hl else None
    aggr = (hl.get("mood_aggressive") or {}).get("all", {}).get("aggressive") if hl else None
    return {"bpm": bpm, "key_of": key_of, "scale": scale,
            "danceability": dance, "aggressive": aggr,
            "found": bool(bpm or key_of)}


def main() -> int:
    rows = []
    with (OUT / "gunna_songs.csv").open() as f:
        rdr = csv.DictReader(f)
        rows = list(rdr)
    out_rows = []
    matched = 0
    for i, row in enumerate(rows, 1):
        song = row["song"]
        norm = _norm_title(song)
        mb = mb_recording("Gunna", norm)
        mbid = None
        if isinstance(mb, dict):
            recs = mb.get("recordings") or []
            if recs:
                mbid = recs[0].get("id")
        ab_fields = {}
        if mbid:
            ab_fields = _ab_fields(ab_pair(mbid))
            if ab_fields.get("found"):
                matched += 1
        out_rows.append({
            "artist": row["artist"], "song": song, "norm_title": norm, "mbid": mbid or "",
            "bpm_ab": ab_fields.get("bpm") or "",
            "key_of_ab": ab_fields.get("key_of") or "",
            "scale_ab": ab_fields.get("scale") or "",
            "danceability_ab": ab_fields.get("danceability") or "",
            "aggressive_ab": ab_fields.get("aggressive") or "",
            "ab_match": bool(ab_fields.get("found")),
        })
        if i % 20 == 0:
            print(f"  {i}/{len(rows)} fetched (ab matches so far: {matched})",
                  file=sys.stderr, flush=True)
    out_path = OUT / "gunna_acousticbrainz.csv"
    with out_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=out_rows[0].keys())
        w.writeheader()
        w.writerows(out_rows)
    print(f"wrote {out_path}  rows={len(out_rows)}  AB matches={matched}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
