#!/usr/bin/env python3
"""Penwork Studios Training Dataset Generator (Task 9)

Synthesizes high-impact, authentic rap training pairs from the 231,240 indexed catalog lines
(oversampling high-popularity songs, iconic albums, and dense inner-rhyme structures).
Formatted for LoRA / QLoRA fine-tuning of Llama / Mistral models into Frontier Ghostwriters.
"""

import argparse
import json
import sqlite3
import sys
import time
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
DB_PATH = HERE / "out" / "catalog_index.sqlite"
OUT_PATH = HERE / "out" / "lyric_training_pairs.jsonl"

sys.path.insert(0, str(HERE))
from catalog_retriever import (
    DEFAULT_CHOSEN_ALBUMS,
    calculate_edit_distance_ratio,
    detect_inner_rhymes,
    extract_seed_pattern,
    retrieve_matching_catalog_lines,
    verify_remix_compliance,
)
from lyriclib import load_cmudict, tokenize, normalize
from polish import MOTIF_DEFINITIONS, build_v2_system_prompt, parse_beat_groups


def generate_training_dataset(
    target_artists: list[str] = None,
    total_pairs: int = 1500,
    db_path: Path = DB_PATH,
    out_path: Path = OUT_PATH,
) -> dict[str, Any]:
    t0 = time.time()
    if target_artists is None:
        target_artists = ["Gunna", "Drake", "Lil Wayne", "NoCap", "Lil Baby", "Young Thug"]

    if not db_path.exists():
        print(f"[DatasetGenerator] Error: DB not found at {db_path}", file=sys.stderr)
        return {"ok": False, "error": "db_not_found"}

    conn = sqlite3.connect(str(db_path))
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    cmu_path = REPO / "XJournal AI" / "cmudict.txt"
    cmu = load_cmudict(cmu_path) if cmu_path.exists() else {}

    out_path.parent.mkdir(parents=True, exist_ok=True)
    generated_count = 0
    stats_by_artist = {a: 0 for a in target_artists}

    with open(out_path, "w", encoding="utf-8") as out_f:
        per_artist_cap = max(20, total_pairs // len(target_artists))
        for artist in target_artists:
            chosen_albs = DEFAULT_CHOSEN_ALBUMS.get(artist, [])
            user_albs_lower = [a.lower() for a in chosen_albs]

            # Query top-tier catalog bars: non-generic, high inner-rhyme, high popularity, strictly lyric content
            sql = """
                SELECT id, artist, song, album, text, end_word, end_rime,
                       vowel_class, syllables, inner_rhyme_count, popularity_score
                FROM catalog_bars
                WHERE artist = ? AND is_generic = 0 AND syllables >= 12 AND inner_rhyme_count >= 1
                  AND text NOT LIKE '%producer tag%'
                  AND text NOT LIKE '%originat%'
                  AND text NOT LIKE '%team up%'
                  AND text NOT LIKE '%tracklist%'
                  AND text NOT LIKE '%annotat%'
                  AND text NOT LIKE '% by %'
                ORDER BY (popularity_score * 1.5) + (inner_rhyme_count * 5.0) DESC
                LIMIT 800;
            """
            cur.execute(sql, (artist,))
            rows = [dict(r) for r in cur.fetchall()]
            if not rows:
                continue

            # Group into couplets and generate 4x4 training examples
            step = 2
            artist_count = 0
            for i in range(0, len(rows) - 1, step):
                if artist_count >= per_artist_cap or generated_count >= total_pairs:
                    break
                row1 = rows[i]
                row2 = rows[i + 1]

                t1 = tokenize(normalize(row1["text"]))
                t2 = tokenize(normalize(row2["text"]))
                if not t1 or not t2:
                    continue
                # Filter out repetitive chant / onomatopoeia bars / non-lyric text
                if (len(set(t1)) / len(t1) < 0.55) or (len(set(t2)) / len(t2) < 0.55):
                    continue
                if any(w in ("pew", "la", "ooh", "aye", "uh") for w in t1[:2] + t2[:2]):
                    continue
                if any(bad in row1["text"].lower() or bad in row2["text"].lower() for bad in ("tracklist", "remix by", "produced by", "team up", "originates from", "producer tag")):
                    continue
                if any(len(tok) > 25 for tok in row1["text"].split() + row2["text"].split()):
                    continue

                # Synthesize balanced 4x4 Quadrasonic representations
                b1 = parse_beat_groups(row1["text"], cmu)
                b2 = parse_beat_groups(row2["text"], cmu)

                # Ensure non-trivial substantive beat groups
                if len(b1["groups"]) < 4 or len(b2["groups"]) < 4:
                    continue

                w1 = row1["end_word"]
                w2 = row2["end_word"]
                bpm = 144.0 if artist in ("Gunna", "Lil Baby") else (130.0 if artist == "Drake" else 138.0)
                scale = "F minor" if (i % 2 == 0) else "C major"
                motif_keys = list(MOTIF_DEFINITIONS.keys())
                motif_key = motif_keys[i % len(motif_keys)]
                motif_info = MOTIF_DEFINITIONS[motif_key]

                # Format system prompt adhering to Audamar/Lobster blueprint
                sys_prompt = build_v2_system_prompt(
                    voice=artist,
                    bpm=bpm,
                    scale=scale,
                    target_syl=18,
                    bars_count=2,
                )

                # Format user instruction with Retrieve & Remix foundations
                user_msg = (
                    f"=== RETRIEVE AND REMIX TASK (20% TO 30% EDIT CAP) ===\n"
                    f"Artist: {artist} | BPM: {bpm} | Scale: {scale} ({motif_info['title']})\n"
                    f"Foundation 1: [{row1['album']} | {row1['song']}] \"{row1['text']}\" -> Target End: '{w1}'\n"
                    f"Foundation 2: [{row2['album']} | {row2['song']}] \"{row2['text']}\" -> Target End: '{w2}'\n\n"
                    f"Mandate: Output exactly 2 bars in Audamar/Lobster 4x4 meter (exactly 3 commas per line, 4-5 syllables each).\n"
                    f"Bar 01: [Beat 1 Sound A], [Beat 2 Sound A Rhyme], [Beat 3 Kinetic Action], [Beat 4 Punchline on '{w1}']\n"
                    f"Bar 02: [Beat 1 Sound B], [Beat 2 Sound B Rhyme], [Beat 3 Kinetic Action], [Beat 4 Punchline on '{w2}']"
                )

                # Assistant target response: Perfectly formatted 4x4 Quadrasonic lines
                assistant_msg = f"{b1['quad_formatted']}\n{b2['quad_formatted']}"

                # Calculate training pair metadata
                ed1 = calculate_edit_distance_ratio(row1["text"], b1["quad_formatted"])
                ed2 = calculate_edit_distance_ratio(row2["text"], b2["quad_formatted"])

                record = {
                    "artist": artist,
                    "bpm": bpm,
                    "scale": scale,
                    "motif": motif_info["title"],
                    "album1": row1["album"],
                    "song1": row1["song"],
                    "end_word1": w1,
                    "album2": row2["album"],
                    "song2": row2["song"],
                    "end_word2": w2,
                    "avg_edit_ratio": round((ed1 + ed2) / 2.0, 3),
                    "messages": [
                        {"role": "system", "content": sys_prompt},
                        {"role": "user", "content": user_msg},
                        {"role": "assistant", "content": assistant_msg},
                    ],
                }

                out_f.write(json.dumps(record) + "\n")
                generated_count += 1
                artist_count += 1
                stats_by_artist[artist] += 1

    conn.close()
    elapsed = round(time.time() - t0, 2)
    print(f"[DatasetGenerator] Synthesized {generated_count} high-grade training pairs in {elapsed}s.")
    for a, cnt in stats_by_artist.items():
        print(f"  - {a}: {cnt} pairs")
    return {
        "ok": True,
        "total_pairs": generated_count,
        "elapsed_sec": elapsed,
        "stats_by_artist": stats_by_artist,
        "output_path": str(out_path),
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Penwork Studios Training Dataset Generator")
    parser.add_argument("--count", type=int, default=1500, help="Total pairs to synthesize")
    args = parser.parse_args()

    res = generate_training_dataset(total_pairs=args.count)
    print(f"[Done] Dataset generated at: {res['output_path']}")
