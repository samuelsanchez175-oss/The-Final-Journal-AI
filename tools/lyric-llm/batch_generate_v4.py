#!/usr/bin/env python3
"""Penwork Studios Frontier V4: 20-Verse Multi-Artist Live Batch Generator.

Generates 20 authentic, studio-grade rap verses across top catalog artists,
blends, tempos, musical keys, and section modes using Frontier v4:
- Reasoning Planner backbone (plan_v4)
- Fast scaffold draft (gpt-4o-mini)
- High-precision frontier polish (gpt-4o)
- 4x4 Quadrasonic / Section cadence gate with targeted bar retries
- Dynamic edit-distance caps (15% anthem, 20% couplet, 30% standard)
- Slang/CMU phonetic end-word preservation
- Named-entity leak guard auto-retry

Outputs:
1. tools/style-profile/out/model_comparison_v4_20verses.json (Sparkler Rater format)
2. tools/lyric-llm/out/frontier_v4_20_verses_report.md (Comprehensive markdown report)
3. Obsidian Vault sync for team reference
"""

from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
STYLE_PROFILE_DIR = HERE.parent / "style-profile"
REPO_ROOT = HERE.parent.parent
for p in (HERE, STYLE_PROFILE_DIR, REPO_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

import frontier_v4

BATCH_CONFIGS = [
    {
        "id": "take_01",
        "voice": "Gunna",
        "blend": "",
        "mix": 100,
        "bpm": 130.0,
        "scale": "F minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "lavishness_money",
        "topic_brief": "Gunna on lavishness, offshore accounts, and effortless luxury",
    },
    {
        "id": "take_02",
        "voice": "Gunna",
        "blend": "",
        "mix": 100,
        "bpm": 120.0,
        "scale": "F minor",
        "section_mode": "hook",
        "bars": 4,
        "topic": "drip_lifestyle",
        "topic_brief": "Gunna anthemic call-and-response hook on jewelry and status",
    },
    {
        "id": "take_03",
        "voice": "Gunna",
        "blend": "NoCap",
        "mix": 70,
        "bpm": 135.0,
        "scale": "F minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "street_defiance",
        "topic_brief": "Gunna & NoCap on surviving street wars and standing tall",
    },
    {
        "id": "take_04",
        "voice": "Gunna",
        "blend": "Young Thug",
        "mix": 60,
        "bpm": 140.0,
        "scale": "F minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "high_fashion_luxury",
        "topic_brief": "YSL synergy on Paris designer fashion and iced timepieces",
    },
    {
        "id": "take_05",
        "voice": "Lil Wayne",
        "blend": "",
        "mix": 100,
        "bpm": 140.0,
        "scale": "G minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "punchline_wordplay",
        "topic_brief": "Lil Wayne high-cadence punchline assault and clever metaphors",
    },
    {
        "id": "take_06",
        "voice": "Lil Wayne",
        "blend": "Drake",
        "mix": 50,
        "bpm": 132.0,
        "scale": "G minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "status_legacy",
        "topic_brief": "Young Money royalty on empire building and longevity",
    },
    {
        "id": "take_07",
        "voice": "Drake",
        "blend": "",
        "mix": 100,
        "bpm": 128.0,
        "scale": "C# minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "late_night_reflection",
        "topic_brief": "Drake midnight drives, shifting loyalties, and solitary success",
    },
    {
        "id": "take_08",
        "voice": "Drake",
        "blend": "",
        "mix": 100,
        "bpm": 115.0,
        "scale": "C# minor",
        "section_mode": "hook",
        "bars": 4,
        "topic": "certified_anthem",
        "topic_brief": "Drake infectious melodic hook on stadium-level dominance",
    },
    {
        "id": "take_09",
        "voice": "Young Thug",
        "blend": "",
        "mix": 100,
        "bpm": 142.0,
        "scale": "Eb minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "eccentric_slime_flex",
        "topic_brief": "Young Thug unconventional cadences, slime energy, and alien flows",
    },
    {
        "id": "take_10",
        "voice": "Young Thug",
        "blend": "Gunna",
        "mix": 50,
        "bpm": 138.0,
        "scale": "Eb minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "drip_season_brothers",
        "topic_brief": "Unbreakable bond between Thug & Gunna trading lavish bars",
    },
    {
        "id": "take_11",
        "voice": "NoCap",
        "blend": "",
        "mix": 100,
        "bpm": 130.0,
        "scale": "Bb minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "pain_metaphors",
        "topic_brief": "NoCap intricate emotional lyricism and heart-wrenching metaphors",
    },
    {
        "id": "take_12",
        "voice": "NoCap",
        "blend": "Rylo Rodriguez",
        "mix": 60,
        "bpm": 126.0,
        "scale": "Bb minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "southern_heartbreak",
        "topic_brief": "Alabama street poets detailing trauma and unhealed scars",
    },
    {
        "id": "take_13",
        "voice": "Chief Keef",
        "blend": "",
        "mix": 100,
        "bpm": 135.0,
        "scale": "C minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "drill_glory_street",
        "topic_brief": "Chief Keef raw energy, heavy artillery, and O-Block defiance",
    },
    {
        "id": "take_14",
        "voice": "21 Savage",
        "blend": "",
        "mix": 100,
        "bpm": 140.0,
        "scale": "F minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "cold_slaughter_bank",
        "topic_brief": "21 Savage sinister deadpan delivery on money and zone 6 realities",
    },
    {
        "id": "take_15",
        "voice": "21 Savage",
        "blend": "",
        "mix": 100,
        "bpm": 124.0,
        "scale": "F minor",
        "section_mode": "hook",
        "bars": 4,
        "topic": "zone6_repetition",
        "topic_brief": "21 Savage dark, repetitive chant on street rules",
    },
    {
        "id": "take_16",
        "voice": "Future",
        "blend": "",
        "mix": 100,
        "bpm": 134.0,
        "scale": "G# minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "toxic_luxury_pluto",
        "topic_brief": "Future prescription cups, endless checks, and dark glamour",
    },
    {
        "id": "take_17",
        "voice": "Future",
        "blend": "Lil Wayne",
        "mix": 50,
        "bpm": 140.0,
        "scale": "G# minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "astronaut_status",
        "topic_brief": "Future & Wayne legendary collision of Southern mixtape titans",
    },
    {
        "id": "take_18",
        "voice": "Lil Baby",
        "blend": "",
        "mix": 100,
        "bpm": 136.0,
        "scale": "C minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "relentless_momentum",
        "topic_brief": "Lil Baby non-stop breathless cadence on turning hustle to wealth",
    },
    {
        "id": "take_19",
        "voice": "Lil Baby",
        "blend": "Gunna",
        "mix": 50,
        "bpm": 130.0,
        "scale": "C minor",
        "section_mode": "verse",
        "bars": 8,
        "topic": "drip_harder_loyalty",
        "topic_brief": "Drip Harder classic duo trading seamless back-to-back lines",
    },
    {
        "id": "take_20",
        "voice": "Travis Scott",
        "blend": "",
        "mix": 100,
        "bpm": 128.0,
        "scale": "E minor",
        "section_mode": "hook",
        "bars": 4,
        "topic": "rodeo_psychedelic",
        "topic_brief": "Travis Scott arena-ready stadium chant drenched in reverb",
    },
]


def run_batch():
    out_dir = HERE / "out"
    out_dir.mkdir(parents=True, exist_ok=True)
    rater_out_dir = STYLE_PROFILE_DIR / "out"
    rater_out_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n========================================================")
    print(f"  PENWORK STUDIOS FRONTIER V4: 20-VERSE LIVE BATCH RUN  ")
    print(f"========================================================\n")

    results = []
    t_start = time.time()

    for idx, cfg in enumerate(BATCH_CONFIGS, 1):
        print(f"[{idx:02d}/20] Generating {cfg['voice']}{' x ' + cfg['blend'] if cfg['blend'] else ''} ({cfg['section_mode'].upper()}) @ {cfg['bpm']} BPM...")
        t0 = time.time()

        res = frontier_v4.generate_v4(
            voice=cfg["voice"],
            blend=cfg["blend"],
            mix=cfg["mix"],
            bpm=cfg["bpm"],
            scale=cfg["scale"],
            section_mode=cfg["section_mode"],
            bars_count=cfg["bars"],
            topic_hint=cfg["topic"],
            candidates=1,
            use_cache=False,  # Always freshly generated for live evaluation
        )
        dur = round(time.time() - t0, 2)
        res["config"] = cfg
        res["duration_sec"] = dur
        results.append(res)

        grid_pct = res.get("grid_pass_rate", 1.0) * 100
        style_score = res.get("style_score", 0.0)
        print(f"       Done in {dur}s · Grid: {grid_pct:.0f}% · Style Score: {style_score:.2f} · Lines: {len(res['bars'])}")
        # Print a sample couplet
        if len(res["bars"]) >= 2:
            print(f"       ↳ \"{res['bars'][0]['text']}\"")
            print(f"       ↳ \"{res['bars'][1]['text']}\"")
        print()

    total_time = round(time.time() - t_start, 1)

    # 1. Compile Sparkler Rater export format (phase6.v2)
    comparison_cards = []
    for r in results:
        cfg = r["config"]
        card_bars = []
        for b in r["bars"]:
            # Format segment halves with exact comma pocket syllable counts & ABAB inner rhymes
            from cadence_analyzer import analyze_bar_cadence
            cad = analyze_bar_cadence(b["text"])
            halves = [{"text": s["text"], "syl": s["syllables"]} for s in cad["segments"]]
            internal_pairs = cad["internal_pairs"]

            card_bars.append({
                "text": cad["formatted_line"],
                "halves": halves,
                "syllables": cad["total_syllables"],
                "end_word": b["end_word"],
                "rhyme_letter": chr(65 + (b["couplet_num"] % 4)),
                "internal": internal_pairs,
                "borrowed": None,
                "meaning": f"Bar {b['index']} by {b['artist']} in {cfg['section_mode']} [{cad['syl_pattern']} · {cad['rhyme_type']}]",
                "checks": {
                    "grid_passed": b["grid_passed"],
                    "remix_compliant": b["remix_compliant"],
                    "edit_distance_ratio": b["edit_distance_ratio"],
                }
            })

        card = {
            "schema": "phase6.v2",
            "prompt_version": "verse.v4",
            "artist": cfg["voice"] if not cfg["blend"] else f"{cfg['voice']} x {cfg['blend']}",
            "topic": cfg["topic"],
            "topic_brief": cfg["topic_brief"],
            "scheme": "aabb",
            "bpm": cfg["bpm"],
            "scale": cfg["scale"],
            "section_mode": cfg["section_mode"],
            "syl_range": [r.get("target_syllables", 18) - 2, r.get("target_syllables", 18) + 2],
            "models": {
                "frontier_v4": {
                    "model": "frontier_v4",
                    "generation_id": r["generation_id"],
                    "passed": r.get("grid_pass_rate", 1.0) >= 0.85,
                    "problems": [],
                    "style_score": r.get("style_score", 0.0),
                    "grid_pass_rate": r.get("grid_pass_rate", 1.0),
                    "elapsed_s": r["duration_sec"],
                    "bars": card_bars,
                }
            }
        }
        comparison_cards.append(card)

    comparison_file = rater_out_dir / "model_comparison_v4_20verses.json"
    comparison_file.write_text(json.dumps(comparison_cards, indent=2), encoding="utf-8")
    unified_file = rater_out_dir / "model_comparison.json"
    unified_file.write_text(json.dumps(comparison_cards, indent=2), encoding="utf-8")
    print(f"[✓] Saved Sparkler Rater export: {comparison_file} and {unified_file} ({len(comparison_cards)} verse cards)")

    # 2. Build Markdown Anthology
    md_lines = [
        "---",
        "title: Frontier v4 — Live 20-Verse Multi-Artist Anthology",
        "tags: [penwork-studios, frontier-v4, anthology, lyrics, evaluation]",
        f"generated: {time.strftime('%Y-%m-%d %H:%M:%S')}",
        "---",
        "",
        "# 🎤 Frontier v4 — Live 20-Verse Multi-Artist Anthology",
        "",
        "Generated using **Frontier v4 (QLoRA-free)** master orchestrator:",
        "- **Reasoning Planner Backbone (`plan_v4`):** Motif chain + authentic catalog end-words + couplet voice allocation.",
        "- **Two-Pass Generation:** Fast scaffolding draft (`gpt-4o-mini`) + high-precision frontier polish (`gpt-4o`).",
        "- **Cadence & Syllable Verification:** 4x4 Quadrasonic meter / Section cadence rules with targeted single-bar retries.",
        "- **Safety & Integrity:** Dynamic edit caps (15% anthem, 20% couplet, 30% standard) + named-entity leak guard.",
        "",
        f"**Summary Metrics:**",
        f"- **Total Verses:** 20 takes across 10 top catalog voices",
        f"- **Total Generation Time:** {total_time}s (average: {round(total_time/20, 1)}s / take)",
        f"- **Mean Grid Pass Rate:** {sum(r.get('grid_pass_rate', 1.0) for r in results) / len(results) * 100:.1f}%",
        f"- **Mean Style Score:** {sum(r.get('style_score', 0.0) for r in results) / len(results):.2f} / 1.00",
        "",
        "---",
        "",
    ]

    for idx, r in enumerate(results, 1):
        cfg = r["config"]
        artist_title = cfg["voice"] if not cfg["blend"] else f"{cfg['voice']} feat. {cfg['blend']} ({cfg['mix']}% / {100-cfg['mix']}%)"
        grid_pct = r.get("grid_pass_rate", 1.0) * 100
        style_score = r.get("style_score", 0.0)

        md_lines.append(f"## Take {idx:02d}: {artist_title} — {cfg['section_mode'].upper()}")
        md_lines.append(f"*{cfg['topic_brief']}*  ")
        md_lines.append(f"**Tempo:** {cfg['bpm']} BPM · **Scale:** {cfg['scale']} · **Target Syllables:** {r.get('target_syllables')} syl · **Grid Pass:** {grid_pct:.0f}% · **Style Score:** {style_score:.2f} · **Gen ID:** `{r['generation_id']}`")
        md_lines.append("")
        md_lines.append("```text")
        for b in r["bars"]:
            status = "✓" if b["grid_passed"] else "✗"
            md_lines.append(f"[{b['syllables']:2d}s | {b['artist']:11s} | {status}] {b['text']}")
        md_lines.append("```")
        md_lines.append("")

    report_content = "\n".join(md_lines)
    report_file = out_dir / "frontier_v4_20_verses_report.md"
    report_file.write_text(report_content, encoding="utf-8")
    print(f"[✓] Saved Markdown report: {report_file}")

    # 3. Synchronize Anthology into both Obsidian vaults
    obsidian_vaults = [
        Path("/Users/samuel/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work Studios vault/🧠 Penwork Studios - Model G/Frontier v4 & Studio AI Stack"),
        Path("/Users/samuel/Pictures/OB CLAUDE vault/OB CLAUDE V1/🧠 Penwork Studios - Model G/Frontier v4 & Studio AI Stack")
    ]
    for ov in obsidian_vaults:
        if ov.exists():
            dest = ov / "13 Frontier v4 — Live 20-Verse Multi-Artist Anthology.md"
            dest.write_text(report_content, encoding="utf-8")
            print(f"[✓] Synced into Obsidian: {dest}")

    print(f"\n========================================================")
    print(f"  BATCH COMPLETE: 20/20 LIVE VERSES GENERATED & SYNCED  ")
    print(f"========================================================\n")


if __name__ == "__main__":
    run_batch()
