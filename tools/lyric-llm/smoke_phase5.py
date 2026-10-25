#!/usr/bin/env python3
"""Phase 5 Smoke Test: Edit-This-Line Prompt & Token-Levenshtein Anchor Floor.

Generates 10 fresh verses across target artists and verifies that:
1. Token-level Levenshtein distance from retrieved catalog anchor <= cap_tokens on >= 90% of bars.
2. Catalog end-word is preserved on >= 90% of bars.
3. Summary metrics and per-bar audits are reported.
"""

import os
import sys
import time

# Ensure directory is in PYTHONPATH
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from catalog_retriever import (
    normalize,
    tokenize,
    token_levenshtein_distance,
    get_dynamic_cap,
)
from polish import generate_frontier_bars_v2

ARTISTS = [
    "Gunna",
    "Drake",
    "NoCap",
    "Lil Wayne",
    "Young Thug",
    "Gunna",
    "Drake",
    "NoCap",
    "Gunna",
    "Lil Wayne",
]

THEMES = [
    "late night in the studio mixing records",
    "loyalty over money standing against all odds",
    "private flights to Paris counting investments",
    "deep betrayal rising up from the trenches",
    "spiritual armor and gratitude to God",
    "maybach cruising through traffic midnight",
    "championship rings and platinum plaques",
    "scars from the cold cell turning pain to power",
    "diamond bezels reflecting street neon lights",
    "unshakable brotherhood through the fire",
]


def run_smoke_test(num_verses: int = 10) -> bool:
    print("=" * 80)
    print(f"🚀 RUNNING PHASE 5 SMOKE TEST ({num_verses} VERSES)")
    print("Goal: Token-Levenshtein distance <= cap_tokens on >= 90% of bars")
    print("=" * 80)

    total_bars = 0
    compliant_bars = 0
    end_words_preserved = 0
    floor_hit_bars = 0
    bars_with_anchors = 0

    t_start = time.time()

    for v_idx in range(num_verses):
        artist = ARTISTS[v_idx % len(ARTISTS)]
        theme = THEMES[v_idx % len(THEMES)]
        print(f"\n--- Verse {v_idx + 1}/{num_verses} [{artist}] --- Theme: \"{theme}\"")

        res = generate_frontier_bars_v2(
            voice=artist,
            bars_count=8,
            topic_hint=theme,
            generation_id=f"smoke_phase5_{v_idx}_{int(time.time())}",
        )

        bars = res.get("bars", [])
        print(f"Provider: {res.get('provider', 'unknown')} | Bars returned: {len(bars)}")

        for b_idx, bar in enumerate(bars):
            total_bars += 1
            cat_text = bar.get("source_catalog_text", "")
            gen_text = bar.get("raw_text", bar.get("text", ""))
            end_w = bar.get("end_word", "")

            if not cat_text:
                # Fallback bar without catalog anchor
                print(f"  Bar {b_idx + 1:02d}: [NO ANCHOR] \"{gen_text}\" (end: {end_w})")
                continue

            bars_with_anchors += 1
            cat_toks = tokenize(normalize(cat_text))
            gen_toks = tokenize(normalize(gen_text))

            cap_ratio = bar.get("edit_distance_cap", 0.30)
            cap_tokens = max(2, int(len(cat_toks) * cap_ratio))
            dist = token_levenshtein_distance(cat_toks, gen_toks)

            cat_end = cat_toks[-1].lower() if cat_toks else ""
            gen_end = gen_toks[-1].lower() if gen_toks else ""
            end_match = (cat_end == gen_end)

            is_compliant = (dist <= cap_tokens)
            if is_compliant:
                compliant_bars += 1
            if end_match:
                end_words_preserved += 1
            if dist == 0:
                floor_hit_bars += 1

            status = "✅ PASS" if is_compliant and end_match else ("⚠️ CAP EXCEEDED" if not is_compliant else "⚠️ END-WORD MISMATCH")
            print(f"  Bar {b_idx + 1:02d} [{status}]: dist={dist}/{cap_tokens} (cap {int(cap_ratio*100)}%) | end='{gen_end}' vs anchor='{cat_end}'")
            print(f"       Anchor: \"{cat_text}\"")
            print(f"       Output: \"{gen_text}\"")

    elapsed = round(time.time() - t_start, 2)
    compliance_rate = (compliant_bars / bars_with_anchors) if bars_with_anchors > 0 else 1.0
    end_word_rate = (end_words_preserved / bars_with_anchors) if bars_with_anchors > 0 else 1.0

    print("\n" + "=" * 80)
    print("📊 PHASE 5 SMOKE TEST SUMMARY")
    print("=" * 80)
    print(f"Total Verses Generated:       {num_verses}")
    print(f"Total Bars Evaluated:         {total_bars}")
    print(f"Bars with Catalog Anchors:    {bars_with_anchors}")
    print(f"Compliant Bars (dist <= cap): {compliant_bars} / {bars_with_anchors} ({compliance_rate * 100:.1f}%)")
    print(f"End-Word Preserved Bars:      {end_words_preserved} / {bars_with_anchors} ({end_word_rate * 100:.1f}%)")
    print(f"Catalog Floor Kept Unchanged: {floor_hit_bars} / {bars_with_anchors} ({(floor_hit_bars / bars_with_anchors) * 100:.1f}%)")
    print(f"Elapsed Time:                 {elapsed:.2f}s")
    print("=" * 80)

    target_met = (compliance_rate >= 0.90) and (end_word_rate >= 0.90)
    if target_met:
        print("🎉 SUCCESS: Phase 5 Token-Levenshtein compliance >= 90% threshold achieved!")
    else:
        print(f"❌ FAILURE: Compliance rate {compliance_rate * 100:.1f}% below 90% threshold.")

    return target_met


if __name__ == "__main__":
    success = run_smoke_test(num_verses=10)
    sys.exit(0 if success else 1)
