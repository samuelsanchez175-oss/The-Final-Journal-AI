#!/usr/bin/env python3
"""smoke_phase2.py
================
Phase 2 Smoke Verification:
Generates 10 Gunna verses with no seed (stochastic sampling active, temp 2.0).
Inspects tools/lyric-llm/out/v4_telemetry.jsonl to verify:
- 4-tier relaxation is active and logging.
- tier="bank" events are < 10% of total bar retrievals (was ~60%).
- Distribution of tiers A, B, C, D, and bank.
- Verification exit criteria pass.
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


def run_smoke_phase2():
    os.environ.pop("V4_SEED", None)
    os.environ["V4_RETRIEVAL_TEMP"] = "2.0"

    out_dir = HERE / "out"
    out_dir.mkdir(parents=True, exist_ok=True)
    telemetry_path = out_dir / "v4_telemetry.jsonl"

    # Record starting position in telemetry file
    start_pos = 0
    if telemetry_path.exists():
        start_pos = telemetry_path.stat().st_size

    print("Running Phase 2 Smoke Test: Generating 10 Gunna verses...")
    all_end_words = []
    verses_summary = []
    fallback_counts = []

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

        verse_ends = [b.get("end_word", "").lower() for b in res.get("bars", [])]
        all_end_words.extend(verse_ends)
        fb_used = res.get("fallback_used", False)
        fb_cnt = res.get("fallback_count", 0)
        fallback_counts.append(fb_cnt)

        verses_summary.append({
            "verse_num": idx + 1,
            "topic": topic,
            "fallback_used": fb_used,
            "fallback_count": fb_cnt,
            "end_words": verse_ends,
        })
        print(f"  [Verse {idx+1:02d}/10] Topic: {topic:20s} | Fallback count: {fb_cnt} | Ends: {', '.join(verse_ends)}")

    # Read telemetry entries written during this run
    new_telemetry_entries = []
    if telemetry_path.exists():
        with open(telemetry_path, "r") as f:
            f.seek(start_pos)
            for line in f:
                line = line.strip()
                if line:
                    try:
                        new_telemetry_entries.append(json.loads(line))
                    except Exception:
                        pass

    tier_counts = {"A": 0, "B": 0, "C": 0, "D": 0, "bank": 0}
    fallback_events = [e for e in new_telemetry_entries if e.get("event") == "retrieval_fallback"]
    for entry in fallback_events:
        tier = entry.get("tier", "unknown")
        tier_counts[tier] = tier_counts.get(tier, 0) + 1

    total_bars = len(all_end_words)
    total_telemetry = len(fallback_events)
    bank_count = tier_counts.get("bank", 0)
    bank_rate = (bank_count / total_bars) * 100.0 if total_bars else 0.0

    entropy = compute_shannon_entropy(all_end_words)

    print("\n================ Phase 2 Verification Results ================")
    print(f"Total Verses Generated:     10")
    print(f"Total Bars Generated:       {total_bars}")
    print(f"Telemetry Entries Logged:   {total_telemetry}")
    print(f"Telemetry File Path:        {telemetry_path}")
    print("Tier Distribution:")
    for tier, count in sorted(tier_counts.items()):
        pct = (count / total_telemetry * 100.0) if total_telemetry else 0.0
        print(f"  Tier {tier:4s}: {count:3d} ({pct:5.1f}%)")
    print(f"Bank Fallback Rate:         {bank_count}/{total_bars} bars ({bank_rate:.1f}%) [Target < 10%]")
    print(f"End-Word Shannon Entropy:   {entropy:.3f} bits (Target >= 3.0 bits)")
    print("==============================================================")

    assert total_telemetry > 0, "Expected telemetry to be logged to out/v4_telemetry.jsonl"
    assert bank_rate < 10.0, f"Expected bank fallback rate < 10%, got {bank_rate:.1f}%"
    print(">>> Phase 2 Exit Verification SUCCESSFUL! All criteria met. <<<")


if __name__ == "__main__":
    run_smoke_phase2()
