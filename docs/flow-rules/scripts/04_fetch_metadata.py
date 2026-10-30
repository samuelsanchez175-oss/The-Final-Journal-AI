#!/usr/bin/env python3
"""Step 3: fetch per-track tempo/key/energy from GetSongBPM + AcousticBrainz.

Reads docs/flow-rules/gunna_songs.csv (unique (artist, song) list produced by
step 01). Normalizes titles (strip feat., remix, punctuation). Hits two sources
with ≥1s rate limiting, backs off on 429, caches every response in
docs/flow-rules/cache/<source>/<slug>.json so reruns don't refetch.

Source 1: GetSongBPM (https://api.getsongbpm.com), reads GETSONGBPM_API_KEY
  from env. Never logs the key.
Source 2: MusicBrainz → AcousticBrainz (open data, frozen 2022).
  AcousticBrainz low-level + high-level. Many 2022+ tracks will miss.

Writes docs/flow-rules/gunna_track_meta.csv with:
  artist,song,norm_title,source,match_confidence,bpm,key_of,scale,
  time_sig,danceability,energy,disagreement_flag,half_time_candidate

Aborts cleanly with status 2 if GETSONGBPM_API_KEY is unset.
"""
from __future__ import annotations

import csv
import hashlib
import json
import os
import re
import sys
import time
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
    t = re.sub(r"\s*\(remix\)|\s*\(remastered.*\)|\s*\(.*version.*\)", "", t, flags=re.IGNORECASE)
    t = re.sub(r"[^\w\s]", " ", t)
    t = re.sub(r"\s+", " ", t).strip().lower()
    return t


def _slug(*parts: str) -> str:
    key = "|".join(parts)
    return hashlib.sha1(key.encode("utf-8")).hexdigest()[:16]


def _cache_path(source: str, slug: str) -> Path:
    (CACHE_DIR / source).mkdir(parents=True, exist_ok=True)
    return CACHE_DIR / source / f"{slug}.json"


def _get(url: str, headers: dict[str, str] | None = None,
         retry: int = 3, delay: float = 1.0) -> dict | None:
    req = urllib.request.Request(url, headers={**(headers or {}), "User-Agent": UA})
    for attempt in range(retry):
        try:
            with urllib.request.urlopen(req, timeout=20) as resp:
                data = resp.read().decode("utf-8")
                try:
                    return json.loads(data)
                except json.JSONDecodeError:
                    return {"raw": data}
        except urllib.error.HTTPError as e:
            if e.code == 429:
                time.sleep(delay * (2 ** attempt))
                continue
            if 500 <= e.code < 600 and attempt + 1 < retry:
                time.sleep(delay * (2 ** attempt))
                continue
            return {"error": f"http {e.code}"}
        except Exception as exc:
            if attempt + 1 < retry:
                time.sleep(delay)
                continue
            return {"error": str(exc)}
    return None


def getsongbpm(artist: str, title: str, api_key: str) -> dict | None:
    slug = _slug("getsongbpm", artist, title)
    cp = _cache_path("getsongbpm", slug)
    if cp.exists():
        return json.loads(cp.read_text())
    q = f"song:{title} artist:{artist}"
    url = ("https://api.getsongbpm.com/search/"
           f"?api_key={urllib.parse.quote(api_key)}&type=both&lookup={urllib.parse.quote(q)}")
    time.sleep(1.1)
    res = _get(url)
    if res is not None:
        cp.write_text(json.dumps(res))
    return res


def mb_recording(artist: str, title: str) -> dict | None:
    slug = _slug("mb", artist, title)
    cp = _cache_path("musicbrainz", slug)
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


def acousticbrainz(mbid: str) -> dict | None:
    slug = _slug("ab", mbid)
    cp = _cache_path("acousticbrainz", slug)
    if cp.exists():
        return json.loads(cp.read_text())
    low = f"https://acousticbrainz.org/{mbid}/low-level"
    high = f"https://acousticbrainz.org/{mbid}/high-level"
    time.sleep(1.1)
    low_res = _get(low)
    time.sleep(1.1)
    high_res = _get(high)
    merged = {"low": low_res, "high": high_res}
    cp.write_text(json.dumps(merged))
    return merged


def _extract_gsb(res: dict | None) -> dict | None:
    if not isinstance(res, dict):
        return None
    search = res.get("search") or []
    if not search:
        return None
    hit = search[0]
    return {
        "source": "getsongbpm",
        "match_confidence": "medium" if hit else "none",
        "bpm": hit.get("tempo"), "key_of": hit.get("key_of"),
        "time_sig": hit.get("time_sig"), "danceability": hit.get("danceability"),
        "acousticness": hit.get("acousticness"),
    }


def _extract_ab(res: dict | None) -> dict | None:
    if not isinstance(res, dict):
        return None
    low = res.get("low") or {}
    high = res.get("high") or {}
    try:
        bpm = (low.get("rhythm") or {}).get("bpm")
        key_of = (low.get("tonal") or {}).get("key_key")
        scale = (low.get("tonal") or {}).get("key_scale")
    except Exception:
        bpm = key_of = scale = None
    try:
        hl = high.get("highlevel") or {}
        dance = (hl.get("danceability") or {}).get("all", {}).get("danceable")
        mood_agg = (hl.get("mood_aggressive") or {}).get("all", {}).get("aggressive")
    except Exception:
        dance = mood_agg = None
    return {
        "source": "acousticbrainz",
        "match_confidence": "medium",
        "bpm": bpm, "key_of": key_of, "scale": scale,
        "danceability": dance, "energy_aggressive": mood_agg,
    }


def main() -> int:
    key = os.environ.get("GETSONGBPM_API_KEY")
    if not key:
        print("ERROR: GETSONGBPM_API_KEY not set. Export the key and re-run.",
              file=sys.stderr)
        return 2
    rows = []
    with (OUT / "gunna_songs.csv").open() as f:
        r = csv.DictReader(f)
        rows = [row for row in r]
    out_rows = []
    matched_g = matched_a = 0
    for i, row in enumerate(rows, 1):
        artist = row["artist"]
        song = row["song"]
        norm = _norm_title(song)
        gsb = _extract_gsb(getsongbpm("Gunna", norm, key))
        ab_record = None
        mbid = None
        mb = mb_recording("Gunna", norm)
        if isinstance(mb, dict):
            recs = mb.get("recordings") or []
            if recs:
                mbid = recs[0].get("id")
        if mbid:
            ab_record = _extract_ab(acousticbrainz(mbid))

        bpm_g = (gsb or {}).get("bpm")
        bpm_a = (ab_record or {}).get("bpm")
        disagreement = False
        half_time = False
        try:
            if bpm_g and bpm_a:
                g = float(bpm_g); a = float(bpm_a)
                if abs(g - a) > 3:
                    disagreement = True
                if abs(g * 2 - a) <= 3 or abs(a * 2 - g) <= 3:
                    half_time = True
        except Exception:
            pass
        if gsb and gsb.get("bpm"): matched_g += 1
        if ab_record and ab_record.get("bpm"): matched_a += 1
        out_rows.append({
            "artist": artist, "song": song, "norm_title": norm,
            "bpm_gsb": bpm_g, "bpm_ab": bpm_a, "mbid": mbid,
            "key_of_gsb": (gsb or {}).get("key_of"),
            "key_of_ab": (ab_record or {}).get("key_of"),
            "scale_ab": (ab_record or {}).get("scale"),
            "time_sig": (gsb or {}).get("time_sig"),
            "danceability_gsb": (gsb or {}).get("danceability"),
            "danceability_ab": (ab_record or {}).get("danceability"),
            "disagreement_flag": disagreement, "half_time_candidate": half_time,
        })
        if i % 25 == 0:
            print(f"  {i}/{len(rows)} fetched (gsb matched={matched_g}, ab matched={matched_a})",
                  file=sys.stderr)

    csv_path = OUT / "gunna_track_meta.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=out_rows[0].keys())
        w.writeheader()
        w.writerows(out_rows)
    print(f"wrote {csv_path}  ({len(out_rows)} rows)")
    print(f"gsb matched: {matched_g}/{len(rows)}  ab matched: {matched_a}/{len(rows)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
