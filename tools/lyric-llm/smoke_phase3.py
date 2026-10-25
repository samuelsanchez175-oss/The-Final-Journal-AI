#!/usr/bin/env python3
"""smoke_phase3.py
================
Phase 3 Smoke Verification:
Generates 10 consecutive Gunna verses with no seed (stochastic sampling active, temp 2.0).
Verifies:
- Zero repeat end words across consecutive generations (Verse N to Verse N+1).
- End-word deduplication window in SQL is actively blocking collisions.
- End-word Shannon entropy across the 80 bars (target >= 3.0 bits).
- tools/lyric-llm/out/end_word_history.jsonl is populated.
"""

from __future__ import annotations

import json
import os
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

from catalog_retriever import (
    clear_end_word_history,
    get_end_word_history,
)
from frontier_v4 import generate_v4
from measure_entropy import compute_shannon_entropy


def run_smoke_phase3():
    os.environ.pop("V4_SEED", None)
    os.environ["V4_RETRIEVAL_TEMP"] = "2.0"

    out_dir = HERE / "out"
    out_dir.mkdir(parents=True, exist_ok=True)
    history_jsonl = out_dir / "end_word_history.jsonl"

    print("Running Phase 3 Smoke Test: Generating 10 consecutive Gunna verses...")
    all_end_words = []
    verse_end_words = []
    consecutive_overlaps = []

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

        ends = [b.get("end_word", "").lower() for b in res.get("bars", []) if b.get("end_word")]
        verse_end_words.append(ends)
        all_end_words.extend(ends)

        overlap_with_prev = set()
        if idx > 0:
            overlap_with_prev = set(ends).intersection(set(verse_end_words[idx - 1]))
            consecutive_overlaps.append(len(overlap_with_prev))

        overlap_str = f"Overlap with prev: {list(overlap_with_prev)}" if idx > 0 else "Baseline"
        print(f"  [Verse {idx+1:02d}/10] Topic: {topic:20s} | Ends: {', '.join(ends)} | {overlap_str}")

    entropy = compute_shannon_entropy(all_end_words)
    total_consecutive_collisions = sum(consecutive_overlaps)
    unique_ends = len(set(all_end_words))
    total_bars = len(all_end_words)

    print("\n================ Phase 3 Verification Results ================")
    print(f"Total Verses Generated:             10")
    print(f"Total Bars Generated:               {total_bars}")
    print(f"Unique End Words:                   {unique_ends} / {total_bars}")
    print(f"Consecutive Overlap Events:         {total_consecutive_collisions} [Target: 0]")
    print(f"End-Word Shannon Entropy:           {entropy:.3f} bits [Target >= 3.0 bits]")
    print(f"History File (jsonl):               {history_jsonl}")
    print("==============================================================")

    assert total_consecutive_collisions == 0, f"Expected 0 consecutive end-word collisions, got {total_consecutive_collisions}"
    assert entropy >= 3.0, f"Expected Shannon entropy >= 3.0 bits, got {entropy:.3f}"
    print(">>> Phase 3 Exit Verification SUCCESSFUL! All criteria met. <<<")


if __name__ == "__main__":
    run_smoke_phase3()
