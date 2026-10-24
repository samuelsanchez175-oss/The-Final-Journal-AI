#!/usr/bin/env python3
"""Turn the Penwork bar CSV into a song-level train/valid/test set.

Writes JSONL with text, artist, bpm, and scale. BPM and scale are joined from
the Sparkler tempo cache when that song was matched. Output stays under out/
and is gitignored.

  python3 prep.py
  python3 prep.py --limit-songs 200
"""

from __future__ import annotations

import argparse
import csv
import json
import random
import re
import statistics
import sys
import time
from collections import Counter, defaultdict
from pathlib import Path

from lyriclib import (
    chunks,
    dedupe_songs,
    dominance_flags,
    estimate_syllables,
    flow_consistency,
    index_originality,
    line_record,
    load_cmudict,
    messages_for_chunk,
    open_originality,
    rhyme_rate,
    split_song_ids,
    write_json,
)
from report import write_eval_report

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
DEFAULT_CSV = ROOT / "XJournal AI" / "ground_truth_rap_bars_MODEL_G.csv"
DEFAULT_TEMPO = ROOT / "tools" / "style-profile" / "out" / "tempo_cache.jsonl"
DEFAULT_CMU = ROOT / "XJournal AI" / "cmudict.txt"
OUT = HERE / "out"

csv.field_size_limit(min(sys.maxsize, 2**31 - 1))


def norm_title(value: str) -> str:
    text = value.lower().replace("\u2019", "'")
    text = re.sub(r"\((feat|ft|with|prod)[^)]*\)", " ", text)
    text = re.sub(r"\b(feat|ft)\.?\s.*$", " ", text)
    return " ".join(re.findall(r"[a-z0-9]+", text))


def load_tempo(path: Path) -> dict[tuple[str, str], dict]:
    merged: dict[tuple[str, str], dict] = {}
    if not path.exists():
        print(f"tempo cache missing: {path}", file=sys.stderr)
        return merged
    with path.open(encoding="utf-8") as handle:
        for raw in handle:
            raw = raw.strip()
            if not raw:
                continue
            row = json.loads(raw)
            artist = (row.get("artist") or "").strip()
            song = (row.get("song") or "").strip()
            if not artist or not song:
                continue
            key = (artist.lower(), song.lower())
            rec = merged.setdefault(key, {"bpm": None, "scale": None})
            tempo = row.get("tempo")
            if isinstance(tempo, (int, float)) and rec["bpm"] is None:
                rec["bpm"] = int(round(float(tempo)))
            scale = _scale_name(row)
            if scale and rec["scale"] is None:
                rec["scale"] = scale
    by_norm: dict[tuple[str, str], dict] = {}
    for (artist, song), rec in merged.items():
        by_norm.setdefault((norm_title(artist), norm_title(song)), rec)
    merged.update(by_norm)
    return merged


def _scale_name(row: dict) -> str | None:
    key_name = (row.get("key_name") or "").strip()
    if key_name:
        return key_name
    root = (row.get("key_root") or "").strip()
    scale = (row.get("scale") or "").strip()
    if root and scale:
        return f"{root} {scale}"
    return scale or None


def lookup_tempo(index: dict, artist: str, song: str) -> tuple[int | None, str | None]:
    for key in (
        (artist.lower(), song.lower()),
        (norm_title(artist), norm_title(song)),
    ):
        hit = index.get(key)
        if hit and (hit.get("bpm") is not None or hit.get("scale")):
            return hit.get("bpm"), hit.get("scale")
    return None, None


def read_songs(csv_path: Path, tempo: dict, limit_songs: int | None) -> tuple[dict, dict]:
    songs: dict[str, dict] = {}
    order: list[str] = []
    stats = Counter()
    section = Counter()
    with csv_path.open(newline="", encoding="utf-8", errors="replace") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            stats["raw_rows"] += 1
            if stats["raw_rows"] % 200000 == 0:
                print(f"  read {stats['raw_rows']:,} rows, {len(songs):,} songs", flush=True)
            artist = (row.get("artist") or "").strip()
            title = (row.get("song") or "").strip()
            text = row.get("text_bar_line") or ""
            if artist.lower() == "artist" or not artist or not title:
                stats["skipped_header"] += 1
                continue
            if text.strip():
                stats["rows_with_text"] += 1
            section[(row.get("section_type") or "").strip() or "empty"] += 1
            song_id = f"{artist}\t{title}"
            song = songs.get(song_id)
            if song is None:
                if limit_songs is not None and len(songs) >= limit_songs:
                    break
                bpm, scale = lookup_tempo(tempo, artist, title)
                song = {
                    "artist": artist,
                    "title": title,
                    "bpm": bpm,
                    "scale": scale,
                    "lines": [],
                }
                songs[song_id] = song
                order.append(song_id)
                if bpm is not None:
                    stats["songs_with_bpm"] += 1
                if scale:
                    stats["songs_with_scale"] += 1
            syl_raw = (row.get("syllable_count") or "").strip()
            syl = int(syl_raw) if syl_raw.isdigit() and int(syl_raw) > 0 else estimate_syllables(text)
            song["lines"].append({"text": text, "syl": syl})
    stats["songs_read"] = len(songs)
    stats["section_unknown"] = section.get("unknown", 0) + section.get("empty", 0)
    stats["section_rows"] = sum(section.values()) or 1
    return songs, dict(stats)


def artist_histogram(counts: Counter) -> dict[str, int]:
    bins = {
        "1–99": 0,
        "100–999": 0,
        "1,000–9,999": 0,
        "10,000–49,999": 0,
        "50,000+": 0,
    }
    for n in counts.values():
        if n < 100:
            bins["1–99"] += 1
        elif n < 1000:
            bins["100–999"] += 1
        elif n < 10000:
            bins["1,000–9,999"] += 1
        elif n < 50000:
            bins["10,000–49,999"] += 1
        else:
            bins["50,000+"] += 1
    return bins


def craft_curve(songs: dict[str, dict], cmu: dict) -> dict:
    bucket_syls: dict[int, list[int]] = defaultdict(list)
    bucket_rhyme: dict[int, list[float]] = defaultdict(list)
    bucket_flow: dict[int, list[float]] = defaultdict(list)
    all_syls: list[int] = []
    rhymes: list[float] = []
    flows: list[float] = []
    for song in songs.values():
        syls = [int(line["syl"]) for line in song["lines"]]
        all_syls.extend(syls)
        texts = [line["text"] for line in song["lines"]]
        rhyme = rhyme_rate(texts, cmu) if cmu else None
        flow = flow_consistency(syls)
        if rhyme is not None:
            rhymes.append(rhyme)
        if flow is not None:
            flows.append(flow)
        if song.get("bpm") is None:
            continue
        bucket = int(round(song["bpm"] / 5.0) * 5)
        bucket_syls[bucket].extend(syls)
        if rhyme is not None:
            bucket_rhyme[bucket].append(rhyme)
        if flow is not None:
            bucket_flow[bucket].append(flow)
    buckets = {}
    for bucket, syls in sorted(bucket_syls.items()):
        buckets[str(bucket)] = {
            "n": len(syls),
            "median_syl": int(round(statistics.median(syls))) if syls else None,
            "mean_rhyme_rate": round(statistics.fmean(bucket_rhyme[bucket]), 4)
            if bucket_rhyme[bucket]
            else None,
            "mean_flow": round(statistics.fmean(bucket_flow[bucket]), 4)
            if bucket_flow[bucket]
            else None,
        }
    return {
        "buckets": buckets,
        "global_median_syl": int(round(statistics.median(all_syls))) if all_syls else None,
        "global_craft": {
            "median_syl": int(round(statistics.median(all_syls))) if all_syls else None,
            "mean_rhyme_rate": round(statistics.fmean(rhymes), 4) if rhymes else None,
            "mean_flow": round(statistics.fmean(flows), 4) if flows else None,
        },
    }


def write_outputs(songs: dict, splits: dict[str, list[str]], out: Path, seed: int) -> dict:
    line_dir = out / "lines"
    mlx_dir = out / "mlx"
    line_dir.mkdir(parents=True, exist_ok=True)
    mlx_dir.mkdir(parents=True, exist_ok=True)
    handles = {
        name: (line_dir / f"{name}.jsonl").open("w", encoding="utf-8")
        for name in ("train", "valid", "test")
    }
    mlx_handles = {
        name: (mlx_dir / f"{name}.jsonl").open("w", encoding="utf-8")
        for name in ("train", "valid", "test")
    }
    split_of = {}
    for name, ids in splits.items():
        for song_id in ids:
            split_of[song_id] = name
    counts = Counter()
    train_norms: list[str] = []
    blend_pool: list[dict] = []
    custom_windows = 0
    rng = random.Random(seed)
    try:
        for song_id, song in songs.items():
            split = split_of.get(song_id)
            if split is None or len(song["lines"]) < 4:
                continue
            bpm = song["bpm"]
            scale = song["scale"]
            for line in song["lines"]:
                payload = line_record(line["text"], song["artist"], bpm, scale)
                handles[split].write(json.dumps(payload, ensure_ascii=False) + "\n")
                counts[f"{split}_lines"] += 1
                if split == "train" and line.get("key"):
                    train_norms.append(line["norm"])
            for block in chunks(song["lines"]):
                if split == "train" and len(block) >= 8 and rng.random() < 0.02:
                    mid = len(block) // 2
                    exemplar = [line["text"] for line in block[:mid]]
                    completion = block[mid:]
                    message = messages_for_chunk(
                        song["artist"],
                        bpm,
                        scale,
                        completion,
                        custom=True,
                        exemplar=exemplar,
                    )
                    custom_windows += 1
                else:
                    message = messages_for_chunk(song["artist"], bpm, scale, block)
                    if split == "train" and bpm is not None and len(blend_pool) < 4000:
                        blend_pool.append(
                            {
                                "artist": song["artist"],
                                "bpm": bpm,
                                "scale": scale,
                                "lines": [line["text"] for line in block[:4]],
                            }
                        )
                mlx_handles[split].write(json.dumps(message, ensure_ascii=False) + "\n")
                counts[f"{split}_windows"] += 1
        blend_windows = _write_blends(mlx_handles["train"], blend_pool, rng)
    finally:
        for handle in list(handles.values()) + list(mlx_handles.values()):
            handle.close()
    counts["custom_windows"] = custom_windows
    counts["blend_windows"] = blend_windows
    conn = open_originality(out / "originality.sqlite")
    try:
        counts["index_rows"] = index_originality(conn, train_norms)
    finally:
        conn.close()
    return dict(counts)


def _write_blends(handle, pool: list[dict], rng: random.Random) -> int:
    if len(pool) < 2:
        return 0
    written = 0
    rng.shuffle(pool)
    used = 0
    while used + 1 < len(pool) and written < 1500:
        left = pool[used]
        right = pool[used + 1]
        used += 2
        if left["artist"] == right["artist"]:
            continue
        if abs(left["bpm"] - right["bpm"]) > 10:
            continue
        mixed = []
        for i in range(4):
            source = left if i % 2 == 0 else right
            if i < len(source["lines"]):
                mixed.append({"text": source["lines"][i], "syl": estimate_syllables(source["lines"][i])})
        if len(mixed) < 4:
            continue
        bpm = int(round((left["bpm"] + right["bpm"]) / 2))
        message = messages_for_chunk(
            left["artist"], bpm, left.get("scale") or right.get("scale"), mixed, blend=right["artist"]
        )
        handle.write(json.dumps(message, ensure_ascii=False) + "\n")
        written += 1
    return written


def build_baseline(read_stats: dict, dedupe_stats: dict, songs: dict, splits: dict, curve: dict, write_stats: dict) -> dict:
    counts: Counter = Counter()
    case_groups: dict[str, set[str]] = defaultdict(set)
    lines_with_bpm = 0
    lines_with_scale = 0
    kept_songs = 0
    for song_id, song in songs.items():
        n = len(song["lines"])
        if n < 4:
            continue
        if song_id not in {sid for ids in splits.values() for sid in ids}:
            continue
        kept_songs += 1
        counts[song["artist"]] += n
        case_groups[song["artist"].lower()].add(song["artist"])
        if song.get("bpm") is not None:
            lines_with_bpm += n
        if song.get("scale"):
            lines_with_scale += n
    kept = sum(counts.values()) or 1
    top = [
        {"artist": name, "lines": n, "share": round(n / kept, 4)}
        for name, n in counts.most_common(15)
    ]
    split_summary = {}
    for name, ids in splits.items():
        split_summary[name] = {
            "songs": len(ids),
            "lines": write_stats.get(f"{name}_lines", 0),
        }
    unknown = read_stats.get("section_unknown", 0) / (read_stats.get("section_rows") or 1)
    return {
        "raw_rows": read_stats.get("raw_rows", 0),
        "rows_with_text": read_stats.get("rows_with_text", 0),
        "junk": dedupe_stats.get("junk", 0),
        "dropped_exact": dedupe_stats.get("dropped_exact", 0),
        "dropped_near": dedupe_stats.get("dropped_near", 0),
        "kept_lines": kept,
        "songs_read": read_stats.get("songs_read", 0),
        "songs_kept": kept_songs,
        "artists": len(counts),
        "lines_with_bpm": lines_with_bpm,
        "lines_with_scale": lines_with_scale,
        "bpm_line_share": lines_with_bpm / kept,
        "scale_line_share": lines_with_scale / kept,
        "section_unknown_share": unknown,
        "songs_with_bpm": read_stats.get("songs_with_bpm", 0),
        "songs_with_scale": read_stats.get("songs_with_scale", 0),
        "splits": split_summary,
        "train_windows": write_stats.get("train_windows", 0),
        "blend_windows": write_stats.get("blend_windows", 0),
        "custom_windows": write_stats.get("custom_windows", 0),
        "heavy": dominance_flags(counts),
        "top_artists": top,
        "artist_histogram": artist_histogram(counts),
        "thin_voice_artists": sum(1 for n in counts.values() if n < 200),
        "case_variant_groups": sum(1 for names in case_groups.values() if len(names) > 1),
        "curve": {"buckets": curve["buckets"], "global_median_syl": curve["global_median_syl"]},
        "global_craft": curve["global_craft"],
        "index_rows": write_stats.get("index_rows", 0),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Prep the Penwork lyric corpus for LoRA.")
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--tempo", type=Path, default=DEFAULT_TEMPO)
    parser.add_argument("--cmudict", type=Path, default=DEFAULT_CMU)
    parser.add_argument("--out", type=Path, default=OUT)
    parser.add_argument("--limit-songs", type=int, default=None)
    parser.add_argument("--seed", type=int, default=7)
    args = parser.parse_args()
    if not args.csv.exists():
        print(f"CSV not found: {args.csv}", file=sys.stderr)
        return 1
    started = time.time()
    print("loading tempo cache", flush=True)
    tempo = load_tempo(args.tempo)
    print(f"  tempo keys {len(tempo):,}", flush=True)
    print("reading bars", flush=True)
    songs, read_stats = read_songs(args.csv, tempo, args.limit_songs)
    print(f"  songs {read_stats['songs_read']:,}", flush=True)
    print("deduping", flush=True)
    dedupe_stats = dedupe_songs(songs)
    print(
        f"  kept {dedupe_stats.get('kept_lines', 0):,}  "
        f"exact -{dedupe_stats.get('dropped_exact', 0):,}  "
        f"near -{dedupe_stats.get('dropped_near', 0):,}",
        flush=True,
    )
    eligible = [song_id for song_id, song in songs.items() if len(song["lines"]) >= 4]
    splits = split_song_ids(eligible, seed=args.seed)
    for name, ids in splits.items():
        print(f"  {name} songs {len(ids):,}", flush=True)
    print("scoring rhyme and syllable curve on the train split", flush=True)
    cmu = load_cmudict(args.cmudict)
    train_songs = {song_id: songs[song_id] for song_id in splits["train"]}
    curve = craft_curve(train_songs, cmu)
    print("writing jsonl and originality index", flush=True)
    write_stats = write_outputs(songs, splits, args.out, args.seed)
    baseline = build_baseline(read_stats, dedupe_stats, songs, splits, curve, write_stats)
    write_json(args.out / "baseline.json", baseline)
    write_json(args.out / "syllable_curve.json", baseline["curve"])
    # Raw artist names from this prep pass. The training token list is
    # `python3 train.py --list-voices`, which rewrites this file from the
    # leak-checked song JSONL as <voice:...> tokens.
    voices = sorted({song["artist"] for song in songs.values() if song["lines"]})
    (args.out / "voices.txt").write_text("\n".join(voices) + "\n", encoding="utf-8")
    write_eval_report(args.out / "eval_report.md", baseline, model=None)
    elapsed = time.time() - started
    print(f"done in {elapsed:.0f}s -> {args.out}", flush=True)
    print(f"kept lines {baseline['kept_lines']:,}  artists {baseline['artists']:,}", flush=True)
    if baseline["heavy"]:
        print("heavy artists:", flush=True)
        for row in baseline["heavy"]:
            print(f"  {row['share']:.1%}  {row['artist']}  {row['reason']}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
