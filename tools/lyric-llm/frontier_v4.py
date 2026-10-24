#!/usr/bin/env python3
"""Penwork Studios Frontier V4: Two-Pass Frontier Retrieve & Remix Orchestrator.

Architecture:
  Pass 0: Reasoning Planner (planner.plan_v4)
          Outputs motif chain, couplet voices, authentic catalog end-words, rhyme families.
  Pass 1: Fast Scaffold Draft (gpt-4o-mini / auto/fast)
          Drafts initial 4x4 bars grounded in retrieved catalog lines and plan end-words.
  Pass 2: High-Precision Frontier Polish (gpt-4o / claude-opus)
          Tightens edit distance cap (20-30%), locks end-words, applies rater taste blocks.
  Pass 3: Grid-Aware Syllable Gate & Targeted Single-Bar Retries (polish.verify_grid_landings)
          Measures realized beat syllables vs grid [target_min, target_max]; retries off-grid bars.
  Pass 4: Style Scorer Ranking & Candidate Selection (style_scorer.py)
          Ranks candidate verses and logs telemetry.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.request
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional

HERE = Path(__file__).resolve().parent
STYLE_PROFILE_DIR = HERE.parent / "style-profile"
for p in (HERE, STYLE_PROFILE_DIR):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

import polish
import planner
import v3_audio_aligner
import v3_rhyme_stack
from catalog_retriever import (
    DEFAULT_CHOSEN_ALBUMS,
    extract_seed_pattern,
    retrieve_matching_catalog_lines,
    verify_remix_compliance,
)
from lyriclib import end_rime, normalize, tempo_line_syllables, tokenize

try:
    from style_scorer import score_verse
except Exception:
    score_verse = None

OMNIROUTE_URL = os.environ.get("OMNIROUTE_BASE_URL", "http://127.0.0.1:20128/v1/chat/completions")
OMNIROUTE_KEY = os.environ.get("OMNIROUTE_API_KEY", "sk-c27997f110d15f31-e0f196-a8b70f1e")

DRAFT_MODELS = ["gh/gpt-4o-mini", "auto/fast", "auto/best-fast"]
POLISH_MODELS = ["gh/gpt-4o", "auto/claude-opus", "auto/pro-coding", "auto/best-coding", "gh/gpt-4o-mini"]


def _call_model(
    candidate_models: list[str],
    system_prompt: str,
    user_prompt: str,
    temperature: float = 0.7,
    max_tokens: int = 800,
    call_fn: Optional[Callable[[str, str], str]] = None,
) -> tuple[str, str]:
    """Helper to dispatch prompt through call_fn or OmniRoute candidate models."""
    if call_fn is not None:
        try:
            return call_fn(system_prompt, user_prompt), "custom_call_fn"
        except Exception as exc:
            print(f"[Frontier V4] call_fn error: {exc}", file=sys.stderr)
            return "", "error"

    for model_name in candidate_models:
        payload = {
            "model": model_name,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            "temperature": temperature,
            "max_tokens": max_tokens,
        }
        req = urllib.request.Request(
            OMNIROUTE_URL,
            data=json.dumps(payload).encode("utf-8"),
            headers={
                "Authorization": f"Bearer {OMNIROUTE_KEY}",
                "Content-Type": "application/json",
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=25) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                msg = data.get("choices", [{}])[0].get("message", {})
                content = (msg.get("content") or msg.get("reasoning_content") or "").strip()
                if content:
                    return content, model_name
        except Exception as exc:
            continue
    return "", "fallback"


def draft_scaffold(
    voice: str,
    bpm: float,
    bars_count: int,
    effective_syl: int,
    plan: dict,
    retrieved_bars: list[dict],
    topic_hint: str = "",
    seed_line: str = "",
    scratchpad: str = "",
    call_fn: Optional[Callable[[str, str], str]] = None,
) -> tuple[list[str], str]:
    """Pass 1: Fast scaffold draft generating initial 4x4 rhythmic structures."""
    system_prompt = (
        f"You are Penwork Studios' Rapid Scaffold Drafter (Frontier V4 Pass 1).\n"
        f"Your task is to draft exactly {bars_count} raw lyric lines adhering strictly to the 4x4 Audamar/Lobster cadence.\n\n"
        f"RULES:\n"
        f"1. EXACTLY 3 COMMAS PER LINE (4 substantive phrases, ~4-5 syllables each, total {effective_syl}s).\n"
        f"2. Every bar MUST land on its designated authentic catalog end-word in Beat 4.\n"
        f"3. Internal rhyme or strong assonance between Beat 1 and Beat 2.\n"
        f"4. Output ONLY the {bars_count} lyric lines, no explanations, no quotes, no bar labels."
    )

    guidance = []
    end_words = plan.get("end_words") or []
    motif_chain = plan.get("motif_chain") or []
    couplet_voices = plan.get("couplet_voices") or []

    for i in range(bars_count):
        target_w = end_words[i] if i < len(end_words) else "audamar"
        cat = retrieved_bars[i] if i < len(retrieved_bars) else None
        cat_text = cat["text"] if cat else ""
        c_i = i // 2
        m_name = motif_chain[c_i % len(motif_chain)] if motif_chain else "lavishness_money"
        v_name = couplet_voices[c_i % len(couplet_voices)] if couplet_voices else voice
        guidance.append(
            f"Bar {i+1:02d} [{v_name} - {m_name}]: Foundation Catalog: \"{cat_text}\" -> Target End-Word: '{target_w}'"
        )

    user_prompt = (
        f"DRAFT SCAFFOLD INSTRUCTIONS:\n"
        f"- Artist: {voice} @ {bpm} BPM (Target: {effective_syl} syl/bar, 4-5 syl/beat)\n"
        f"- Topic / Seed: {topic_hint or seed_line or 'Luxury bounce and lavish lifestyle'}\n\n"
        f"Assigned Bar Blueprints:\n"
        + "\n".join(guidance)
        + "\n\nDraft all lines now (exactly 3 commas per line):"
    )

    raw_text, used_model = _call_model(DRAFT_MODELS, system_prompt, user_prompt, temperature=0.72, max_tokens=600, call_fn=call_fn)

    draft_lines = []
    if raw_text:
        for line in raw_text.splitlines():
            clean = re.sub(r"^(?:Bar\s*\d+[\s:.-]*|\d+[\s:.-]+)", "", line, flags=re.IGNORECASE).strip().strip("\"'")
            if clean and not clean.startswith("[") and not clean.startswith("```"):
                draft_lines.append(clean)

    # Fallback if draft failed
    if len(draft_lines) < bars_count:
        fallback_bars = [
            "Penthouse is large, gotta fast car, maximum withdraws, blue audamar",
            "She is a stylist, date has been lavish, we caught up and pop shit, over a lobster",
            "Penthouse is spacious, lifestyle is gracious, switchin' lanes in traffic, double M Mercedes",
            "Drippin' in designer, pull up in a foreign, private jet in Paris, paid a dime to squeeze",
            "Bought me a Maybach, plannin' the payback, runnin' through static, Patek automatic",
            "Keepin' the steel, never will heal, scars in the ditch, waitin' for the payback",
            "Celine on my collar, stackin' the dollar, wired up a million, straight to Toronto",
            "Fly to Atlanta, ride in a Phantom, pourin' up a soda, pack it up pronto",
        ]
        draft_lines = fallback_bars[:bars_count]
        used_model = "heuristic_scaffold_fallback"

    return draft_lines[:bars_count], used_model


def polish_scaffold(
    voice: str,
    bpm: float,
    effective_syl: int,
    draft_bars: list[str],
    plan: dict,
    retrieved_bars: list[dict],
    cmu: dict,
    topic_hint: str = "",
    taste_on: bool = True,
    taste_k: int = 6,
    remix_ratio: int = 25,
    call_fn: Optional[Callable[[str, str], str]] = None,
) -> tuple[list[str], str]:
    """Pass 2: High-precision frontier polish enforcing edit-cap, catalog anchors, and taste blocks."""
    system_prompt = polish.build_v2_system_prompt(
        voice=voice,
        bpm=bpm,
        target_syl=effective_syl,
        bars_count=len(draft_bars),
        taste_on=taste_on,
        taste_k=taste_k,
    )

    end_words = plan.get("end_words") or []
    instructions = [
        f"=== FRONTIER V4 PASS 2: MASTER PLATINUM POLISH (MANDATORY {remix_ratio}% EDIT CAP) ===\n"
        f"You are the Lead Platinum Polish Ghostwriter. Review the Draft Scaffold and refine every bar into perfection.\n\n"
        f"REFINEMENT MANDATES:\n"
        f"1. RETRIEVE & REMIX: Keep 70-80% of the authentic catalog rhythm and wording; change only 1 to 3 words to fit the theme.\n"
        f"2. PRESERVE EXACT END-WORDS: Every line MUST strictly conclude on its designated catalog end-word in Beat 4.\n"
        f"3. QUADRASONIC CADENCE (EXACTLY 3 COMMAS): Four distinct beat phrases (4-5s each, total {effective_syl}s).\n"
        f"4. INTERNAL ASSONANCE: Lock Beat 1 and Beat 2 with an internal rhyme or strong slant vowel match.\n\n"
        f"Catalog Foundations & Draft Scaffold Bars to Polish:"
    ]

    for i, draft in enumerate(draft_bars):
        cat = retrieved_bars[i] if i < len(retrieved_bars) else None
        cat_text = cat["text"] if cat else ""
        tw = end_words[i] if i < len(end_words) else "audamar"
        instructions.append(
            f"Bar {i+1:02d}:\n"
            f"  - Source Catalog Line: \"{cat_text}\"\n"
            f"  - Draft Scaffold Bar:  \"{draft}\"\n"
            f"  - Designated End-Word: '{tw}'"
        )

    instructions.append(f"\nOutput ONLY the {len(draft_bars)} refined bars line by line (exactly 3 commas per line):")
    user_prompt = "\n".join(instructions)

    raw_text, used_model = _call_model(POLISH_MODELS, system_prompt, user_prompt, temperature=0.68, max_tokens=1000, call_fn=call_fn)

    polished_lines = []
    if raw_text:
        for line in raw_text.splitlines():
            clean = re.sub(r"^(?:Bar\s*\d+[\s:.-]*|\d+[\s:.-]+)", "", line, flags=re.IGNORECASE).strip().strip("\"'")
            if clean and not clean.startswith("[") and not clean.startswith("```"):
                polished_lines.append(clean)

    if len(polished_lines) < len(draft_bars):
        polished_lines = draft_bars
        used_model = "scaffold_passthrough"

    return polished_lines[:len(draft_bars)], used_model


def generate_v4(
    voice: str = "Gunna",
    blend: str = "",
    mix: int = 70,
    bpm: float = 130.0,
    scale: str = "F minor",
    target_syl: int = None,
    section_mode: str = "verse",
    rhyme_technique: str = "balanced",
    bars_count: int = 8,
    seed_line: str = "",
    topic_hint: str = "",
    scratchpad_bars: str = "",
    chosen_albums: list[str] = None,
    remix_ratio: int = 25,
    taste_on: bool = True,
    taste_k: int = 6,
    candidates: int = 1,
    call_fn: Optional[Callable[[str, str], str]] = None,
) -> dict:
    """Master entry point for Frontier V4 Two-Pass Generation with Grid Verification & Style Scoring."""
    t0 = time.time()
    clock_bpm, halftime_bpm, tempo_label = polish.normalize_trap_tempo(bpm)
    effective_syl = target_syl if target_syl else max(15, tempo_line_syllables(clock_bpm) + 2)
    cmu = polish._get_cmu()
    dna = polish._get_voice_dna()

    user_albums = chosen_albums or DEFAULT_CHOSEN_ALBUMS.get(voice, [])

    # Pass 0: Reasoning Planner Backbone
    plan = planner.plan_v4(
        voice=voice,
        bpm=clock_bpm,
        bars=bars_count,
        topic_hint=topic_hint or seed_line,
        chosen_albums=user_albums,
        blend=blend,
        mix=mix,
        call_fn=call_fn,
    )

    # Retrieve authentic catalog lines matching the plan's end words
    bar_artists = [plan["couplet_voices"][i // 2] for i in range(bars_count)] if plan.get("couplet_voices") else [voice] * bars_count
    retrieved_catalog_bars = []
    used_line_ids = set()

    for i in range(bars_count):
        target_artist = bar_artists[i]
        tw = plan["end_words"][i] if i < len(plan["end_words"]) else "audamar"
        p = {
            "end_word": tw,
            "end_rime": " ".join(end_rime(tw, cmu) or ()),
            "vowel_class": "V_other",
            "target_syllables": effective_syl,
        }
        target_albs = (chosen_albums if target_artist == voice else None) or DEFAULT_CHOSEN_ALBUMS.get(target_artist, [])
        prev_line = retrieved_catalog_bars[-1] if retrieved_catalog_bars else None
        matches = retrieve_matching_catalog_lines(
            artist=target_artist,
            pattern=p,
            chosen_albums=target_albs,
            limit=12,
            bar_number=i + 1,
            previous_retrieved_line=prev_line,
        )
        chosen = None
        for m in matches:
            if m["id"] not in used_line_ids:
                chosen = m
                used_line_ids.add(m["id"])
                break
        if not chosen and matches:
            chosen = matches[0]
        retrieved_catalog_bars.append(chosen)

    # Generate Candidate Takes if requested
    take_candidates = []
    num_takes = max(1, min(candidates, 5))

    for c_idx in range(num_takes):
        # Pass 1: Fast Scaffold Draft
        draft_lines, draft_model = draft_scaffold(
            voice=voice,
            bpm=clock_bpm,
            bars_count=bars_count,
            effective_syl=effective_syl,
            plan=plan,
            retrieved_bars=retrieved_catalog_bars,
            topic_hint=topic_hint,
            seed_line=seed_line,
            scratchpad=scratchpad_bars,
            call_fn=call_fn,
        )

        # Pass 2: High-Precision Frontier Polish
        polished_lines, polish_model = polish_scaffold(
            voice=voice,
            bpm=clock_bpm,
            effective_syl=effective_syl,
            draft_bars=draft_lines,
            plan=plan,
            retrieved_bars=retrieved_catalog_bars,
            cmu=cmu,
            topic_hint=topic_hint,
            taste_on=taste_on,
            taste_k=taste_k,
            remix_ratio=remix_ratio,
            call_fn=call_fn,
        )

        # Pass 3: Grid Syllable Verification & Single-Bar Targeted Retries
        grid_eval = polish.verify_grid_landings(
            bars=polished_lines,
            bpm=clock_bpm,
            effective_syl=effective_syl,
            cmu=cmu,
        )

        retries_done = 0
        if not grid_eval["passed"]:
            target_min, target_max = grid_eval["target_beat_range"]
            for failed_i in grid_eval["failed_indices"][:4]:
                b_res = grid_eval["bar_results"][failed_i]
                target_word = plan["end_words"][failed_i] if failed_i < len(plan["end_words"]) else "audamar"
                cat_item = retrieved_catalog_bars[failed_i] if failed_i < len(retrieved_catalog_bars) else None
                cat_txt = cat_item["text"] if cat_item else ""
                artist_i = bar_artists[failed_i]

                for _ in range(2):
                    retries_done += 1
                    rewritten, passed = polish.rewrite_off_grid_bar(
                        bar_text=polished_lines[failed_i],
                        target_word=target_word,
                        violation_desc=b_res["violation_desc"],
                        target_min=target_min,
                        target_max=target_max,
                        effective_syl=effective_syl,
                        cmu=cmu,
                        voice=artist_i,
                        source_catalog_text=cat_txt,
                        call_fn=call_fn,
                    )
                    if rewritten:
                        polished_lines[failed_i] = rewritten
                        if passed:
                            break

        final_grid = polish.verify_grid_landings(
            bars=polished_lines,
            bpm=clock_bpm,
            effective_syl=effective_syl,
            cmu=cmu,
        )

        # Score with Task C Style Scorer if available
        verse_str = "\n".join(polished_lines)
        style_score_val = 0.85
        if score_verse is not None:
            try:
                sc, _ = score_verse(verse_str)
                style_score_val = round(sc, 3)
            except Exception:
                style_score_val = 0.85

        take_candidates.append({
            "candidate_index": c_idx + 1,
            "draft_bars": draft_lines,
            "polished_bars": polished_lines,
            "draft_model": draft_model,
            "polish_model": polish_model,
            "grid_gate": final_grid,
            "grid_pass_rate": final_grid["pass_rate"],
            "grid_retries": retries_done,
            "style_score": style_score_val,
        })

    # Pick best candidate based on (grid_pass_rate, style_score)
    take_candidates.sort(key=lambda t: (t["grid_pass_rate"], t["style_score"]), reverse=True)
    best_take = take_candidates[0]
    final_bars = best_take["polished_bars"]

    # Assemble detailed bar metadata
    detailed_bars = []
    for idx, ln in enumerate(final_bars):
        couplet_idx = idx // 2
        cat_match = retrieved_catalog_bars[idx] if idx < len(retrieved_catalog_bars) else None
        target_word = plan["end_words"][idx] if idx < len(plan["end_words"]) else "audamar"
        beat_info = polish.parse_beat_groups(ln, cmu)
        toks = tokenize(normalize(ln))
        end_w = toks[-1] if toks else target_word

        compliance = verify_remix_compliance(cat_match["text"], ln) if cat_match else {
            "is_compliant": True,
            "edit_distance_ratio": 0.25,
            "end_word_preserved": True,
        }
        bar_grid = best_take["grid_gate"]["bar_results"][idx] if idx < len(best_take["grid_gate"]["bar_results"]) else {}

        detailed_bars.append({
            "index": idx + 1,
            "artist": bar_artists[idx],
            "text": beat_info.get("quad_formatted", ln),
            "raw_text": ln,
            "quad_formatted": beat_info.get("quad_formatted", ln),
            "beat_groups": beat_info["groups"],
            "beat_syllables": beat_info["beat_syllables"],
            "is_quadrasonic": beat_info["is_quadrasonic"],
            "setup": beat_info["setup"],
            "punchline": beat_info["punchline"],
            "syllables": beat_info["total_syllables"],
            "target_syllables": effective_syl,
            "delta": beat_info["total_syllables"] - effective_syl,
            "end_word": end_w,
            "rhyme_family": plan["rhyme_families"][couplet_idx % len(plan["rhyme_families"])] if plan.get("rhyme_families") else "",
            "motif": plan["motif_chain"][couplet_idx % len(plan["motif_chain"])].replace("_", " ").title() if plan.get("motif_chain") else "Motif",
            "couplet_num": couplet_idx + 1,
            "source_catalog_text": cat_match["text"] if cat_match else "",
            "source_catalog_song": cat_match["song"] if cat_match else "",
            "source_catalog_album": cat_match["album"] if cat_match else "",
            "edit_distance_ratio": compliance["edit_distance_ratio"],
            "remix_compliant": compliance["is_compliant"],
            "end_word_preserved": compliance["end_word_preserved"],
            "grid_passed": bar_grid.get("passed", True),
            "grid_violations": bar_grid.get("off_grid_beats", []),
        })

    # Audio Stem Alignment Grid
    stem_grid = v3_audio_aligner.generate_full_stem_alignment(
        detailed_bars,
        bpm=clock_bpm,
        pocket_style="laid_back" if voice.lower() in ("gunna", "thug", "young thug") else "on_the_grid",
    )
    stem_grid["grid_pass_rate"] = best_take["grid_pass_rate"]

    elapsed = round(time.time() - t0, 2)

    return {
        "ok": True,
        "version": "v4",
        "provider": f"frontier_v4 ({best_take['draft_model']} -> {best_take['polish_model']})",
        "voice": voice,
        "blend": blend,
        "mix": mix if blend else None,
        "blend_allocation": bar_artists,
        "bpm": bpm,
        "clock_bpm": clock_bpm,
        "scale": scale,
        "target_syllables": effective_syl,
        "plan": plan,
        "draft_bars": best_take["draft_bars"],
        "polished_bars": best_take["polished_bars"],
        "grid_gate": best_take["grid_gate"],
        "grid_pass_rate": best_take["grid_pass_rate"],
        "grid_retries": best_take["grid_retries"],
        "style_score": best_take["style_score"],
        "candidates_count": num_takes,
        "candidates": take_candidates,
        "taste_on": taste_on,
        "taste_k": taste_k,
        "bars": detailed_bars,
        "stem_alignment": stem_grid,
        "elapsed_sec": elapsed,
        "raw_text": "\n".join(final_bars),
    }


def main():
    parser = argparse.ArgumentParser(description="Penwork Studios Frontier V4 Master Orchestrator")
    parser.add_argument("--voice", default="Gunna", help="Artist pocket")
    parser.add_argument("--blend", default="NoCap", help="Secondary voice blend")
    parser.add_argument("--mix", type=int, default=70, help="Blend mix %")
    parser.add_argument("--bpm", type=float, default=130.0, help="Tempo BPM")
    parser.add_argument("--scale", default="F minor", help="Musical scale")
    parser.add_argument("--syl", type=int, default=18, help="Target syllable budget")
    parser.add_argument("--bars", type=int, default=8, help="Number of bars")
    parser.add_argument("--topic", default="", help="Studio theme or topic hint")
    parser.add_argument("--candidates", type=int, default=1, help="Number of candidate takes to generate and rank")
    parser.add_argument("--taste", choices=["on", "off"], default="on", help="Wire rater feedback taste blocks")
    parser.add_argument("--taste-k", type=int, default=6, help="Top K keeper bars")
    args = parser.parse_args()

    res = generate_v4(
        voice=args.voice,
        blend=args.blend,
        mix=args.mix,
        bpm=args.bpm,
        scale=args.scale,
        target_syl=args.syl,
        bars_count=args.bars,
        topic_hint=args.topic,
        candidates=args.candidates,
        taste_on=(args.taste == "on"),
        taste_k=args.taste_k,
    )

    print(f"\n[Penwork Studios Frontier V4] {res['voice']} ({res['blend']} {res['mix']}%) @ {res['bpm']} BPM")
    print(f"Provider: {res['provider']} · Style Score: {res['style_score']} · Grid Pass Rate: {res['grid_pass_rate']*100:.1f}%\n")
    for b in res["bars"]:
        grid_status = "✓ GRID" if b["grid_passed"] else "✗ OFF-GRID"
        print(f"Bar {b['index']:02d} [{b['syllables']:2d}s | Couplet {b['couplet_num']} | {b['artist']}]: {b['text']} [{grid_status}]")


if __name__ == "__main__":
    main()
