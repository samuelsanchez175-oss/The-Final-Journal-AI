#!/usr/bin/env python3
"""smoke_phase1.py
================
Phase 1 Smoke Verification:
Generates 10 Gunna verses with no seed (stochastic sampling active, temp 2.0).
Computes:
- End-word Shannon entropy across the 80 bars (target >= 3.0 bits).
- Mean inner-rhyme count per retrieved and generated bar.
- Appends end words to out/end_word_history.jsonl.
"""

from __future__ import annotations

import json
import os
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

from frontier_v4 import generate_v4
from measure_entropy import compute_shannon_entropy


def run_smoke():
    # Ensure no seed is set for live diversity
    os.environ.pop("V4_SEED", None)
    os.environ["V4_RETRIEVAL_TEMP"] = "2.0"

    print("Running Phase 1 Smoke Test: Generating 10 Gunna verses...")
    all_end_words = []
    all_inner_counts = []
    verses_summary = []

    out_dir = HERE / "out"
    out_dir.mkdir(parents=True, exist_ok=True)
    jsonl_path = out_dir / "end_word_history.jsonl"

    topics = [
        "drip_and_jewelry",
        "private_jets",
        "penthouse_views",
        "wire_transfers",
        "maybach_cruising",
        "loyalty_and_brothers",
        "watch_collection",
        "designer_threads",
        "foreign_compound",
        "late_night_studio",
    ]

    with open(jsonl_path, "a") as jf:
        for idx in range(10):
            topic = topics[idx]
            res = generate_v4(
                voice="Gunna",
                blend="NoCap",
                mix=70,
                bars_count=8,
                topic_hint=topic,
                candidates=1,
                use_cache=False,
            )

            verse_ends = [b.get("end_word", "").lower() for b in res.get("bars", [])]
            all_end_words.extend(verse_ends)

            retrieved = res.get("retrieved_catalog_bars", [])
            for rb in retrieved:
                if rb and isinstance(rb, dict):
                    all_inner_counts.append(rb.get("inner_rhyme_count", 0))

            verse_info = {
                "verse_num": idx + 1,
                "topic": topic,
                "grid_pass_rate": res.get("grid_pass_rate", 0.0),
                "end_words": verse_ends,
                "bars": [b.get("text", "") for b in res.get("bars", [])],
            }
            verses_summary.append(verse_info)
            jf.write(json.dumps(verse_info) + "\n")
            print(f"  [Verse {idx+1:02d}/10] Topic: {topic:20s} | End words: {', '.join(verse_ends)}")

    # Compute Shannon entropy
    entropy = compute_shannon_entropy(all_end_words)
    unique_ends = len(set(all_end_words))
    total_bars = len(all_end_words)
    mean_inner = sum(all_inner_counts) / len(all_inner_counts) if all_inner_counts else 0.0

    print("\n================ Phase 1 Verification Results ================")
    print(f"Total Bars Generated: {total_bars}")
    print(f"Unique End Words:     {unique_ends} / {total_bars}")
    print(f"Shannon Entropy:      {entropy:.3f} bits (Target >= 3.0 bits)")
    print(f"Mean Inner Rhymes:    {mean_inner:.2f} per catalog bar (Target >= 3.0)")
    print(f"Snapshot written to:  {jsonl_path}")
    print("==============================================================")

    if entropy < 3.0:
        print(f"WARNING: Entropy {entropy} bits is below target 3.0 bits.")
    else:
        print(f"SUCCESS: Entropy {entropy} bits meets target >= 3.0 bits!")


if __name__ == "__main__":
    run_smoke()
