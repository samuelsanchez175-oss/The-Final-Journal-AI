#!/usr/bin/env python3
"""Build a voice profile JSON for any artist (not just Gunna).

Produces the same `targets` schema that gunna_score.score_lines() consumes, so
path_a_vs_b_verdict.py can pass `--profile` and score any model's output
against artist X's voice.

Unlike build_anchor_profile.py (which requires a hand-picked ANCHOR_SONGS list
specific to one era), this builder uses the ARTIST'S WHOLE CATALOG as the
measurement set and ALL OTHER ARTISTS as the catalog background for signature
lift. Signature words are the ones the target artist uses meaningfully more
often than the rest of the mixed-artist corpus.

Usage (run from tools/style-profile/):
  python3 build_artist_profile.py --artist "Drake"
  python3 build_artist_profile.py --artist "Lil Baby" --out out/anchor_profile_lilbaby.json
"""
from __future__ import annotations

import argparse
import csv
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import phase1_song_metrics as p1
import anchor_lib

csv.field_size_limit(sys.maxsize)


def slug(artist: str) -> str:
    return artist.lower().replace(" ", "").replace("$", "").replace("-", "")


def load_songs(csv_path: Path, target_artist: str, progress: bool = True) -> tuple[list[dict], dict]:
    """Return (target_songs, catalog_bucket) where catalog_bucket is counts over all OTHER artists."""
    target_lower = target_artist.lower()
    target_songs_raw: dict[tuple[str, str, str], dict] = {}
    other_songs_raw: dict[tuple[str, str, str], dict] = {}
    total_rows = 0
    with open(csv_path, encoding="utf-8", errors="replace", newline="") as f:
        r = csv.reader(f)
        hdr = next(r)
        col = {name: i for i, name in enumerate(hdr)}
        c_id = 0
        c_art, c_song, c_alb = col["artist"], col["song"], col["album"]
        c_text, c_year = col["text_bar_line"], col["year"]
        for row in r:
            if len(row) <= c_text:
                continue
            artist = row[c_art].strip()
            title = row[c_song].strip()
            text = row[c_text].strip()
            if not artist or not title or not text:
                continue
            total_rows += 1
            key = (artist, title, row[c_alb].strip())
            is_target = artist.lower() == target_lower
            bucket = target_songs_raw if is_target else other_songs_raw
            rec = bucket.setdefault(key, {"year": row[c_year], "lines": [], "artist": artist, "title": title, "album": row[c_alb].strip()})
            rec["lines"].append((p1.trailing_number(row[c_id]), text))
            if progress and total_rows % 200000 == 0:
                print(f"  read {total_rows:,} rows", file=sys.stderr)

    # Build target song list
    target_songs = []
    for key in sorted(target_songs_raw):
        rec = target_songs_raw[key]
        lines = []
        for _, text in sorted(rec["lines"], key=lambda p: p[0]):
            text = text.strip()
            if not text or anchor_lib.is_chrome_line(text):
                continue
            lines.append(text)
        if lines:
            target_songs.append({**rec, "lines": lines})

    if progress:
        print(f"  target '{target_artist}': {len(target_songs)} songs, {sum(len(s['lines']) for s in target_songs):,} lines", file=sys.stderr)
        print(f"  catalog (other artists): {len(other_songs_raw):,} songs", file=sys.stderr)

    return target_songs, other_songs_raw


def build_catalog_bucket(other_songs_raw: dict, lex, progress: bool = True) -> dict:
    """Compute content/bigram/trigram counts over all other-artist lines (light pass)."""
    bucket = {
        "content": Counter(), "content_n": 0, "tokens": 0,
        "bigrams": Counter(), "bigram_n": 0, "trigrams": Counter(), "trigram_n": 0,
    }
    n = 0
    for key, rec in other_songs_raw.items():
        lines = []
        for _, text in sorted(rec["lines"], key=lambda p: p[0]):
            text = text.strip()
            if not text or anchor_lib.is_chrome_line(text):
                continue
            lines.append(text)
        if not lines:
            continue
        counts = anchor_lib.features_from_lines(lines, lex, light=True)
        bucket["content"].update(counts["content"])
        bucket["content_n"] += counts["content_n"]
        bucket["tokens"] += counts["tokens"]
        bucket["bigrams"].update(counts["bigrams"])
        bucket["bigram_n"] += counts["bigram_n"]
        bucket["trigrams"].update(counts["trigrams"])
        bucket["trigram_n"] += counts["trigram_n"]
        n += 1
        if progress and n % 500 == 0:
            print(f"  catalog counts: {n:,} songs", file=sys.stderr)
    if progress:
        print(f"  catalog: {bucket['content_n']:,} content tokens, {bucket['bigram_n']:,} bigrams", file=sys.stderr)
    return bucket


def compute_target(target_songs: list[dict], lex, progress: bool = True) -> tuple[list[dict], dict]:
    """Return (packets, total_counts) for the target artist, FULL measurement (not light)."""
    packets = []
    total = anchor_lib.blank_counts()
    for i, song in enumerate(target_songs):
        info, counts = anchor_lib.song_counts(song, lex, light=False)
        packets.append({"song": song, "info": info, "counts": counts})
        anchor_lib.merge_counts(total, counts)
        if progress and (i + 1) % 100 == 0:
            print(f"  measured {i+1}/{len(target_songs)} target songs", file=sys.stderr)
    return packets, total


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--artist", required=True)
    ap.add_argument("--csv", type=Path, default=p1.DEFAULT_CSV)
    ap.add_argument("--cmudict", type=Path, default=p1.DEFAULT_CMU)
    ap.add_argument("--out", type=Path, default=None)
    ap.add_argument("--max-catalog-songs", type=int, default=0, help="cap catalog scan to N other songs (0 = all)")
    args = ap.parse_args()

    out_path = args.out or (HERE / "out" / f"anchor_profile_{slug(args.artist)}.json")

    print(f"reading rows from {args.csv} ...", file=sys.stderr)
    target_songs, other_songs_raw = load_songs(args.csv, args.artist)

    if not target_songs:
        raise SystemExit(f"No songs found for artist {args.artist!r}")

    if args.max_catalog_songs > 0 and len(other_songs_raw) > args.max_catalog_songs:
        import random
        rng = random.Random(7)
        keys = list(other_songs_raw.keys())
        rng.shuffle(keys)
        other_songs_raw = {k: other_songs_raw[k] for k in keys[:args.max_catalog_songs]}
        print(f"  capped catalog to {len(other_songs_raw):,} songs", file=sys.stderr)

    print("loading CMUdict ...", file=sys.stderr)
    lex = p1.Lexicon(p1.load_cmudict(args.cmudict))

    print("measuring target artist songs (full features) ...", file=sys.stderr)
    packets, total_counts = compute_target(target_songs, lex)

    print("measuring catalog (light features) ...", file=sys.stderr)
    catalog = build_catalog_bucket(other_songs_raw, lex)

    print("building signature ...", file=sys.stderr)
    signature = anchor_lib.build_signature(total_counts, packets, catalog)

    print("building targets ...", file=sys.stderr)
    targets = anchor_lib.make_targets(total_counts, signature["set"], signature["hit_rate"])

    # Minimal overlap map (no per-song overlap report needed for scoring)
    overlap = {(s["title"], s["album"]): {"overlap": 0.0, "overlap_with": None, "overlap_lines": 0} for s in target_songs}

    profile = anchor_lib._assemble(packets, total_counts, signature, targets, overlap)
    profile["artist"] = args.artist
    profile["schema"] = anchor_lib.SCHEMA  # keep v1 so gunna_score.load_profile accepts it
    profile["schema_variant"] = "whole_catalog"

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(profile, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

    print()
    print(f"{args.artist} profile  ({len(target_songs)} songs, {total_counts['measured']} measured bars)")
    print(f"  syl median {targets['syl_median']}  signature size {len(signature['set'])}  signature hit rate {targets['signature_hit_rate']}")
    print(f"  top signature: {', '.join(w['text'] for w in signature['unigrams'][:10])}")
    print()
    print(f"wrote {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
