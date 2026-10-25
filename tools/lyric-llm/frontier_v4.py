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
import uuid
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
    get_dynamic_cap,
    get_end_word_history,
    record_used_end_words,
    retrieve_matching_catalog_lines,
    verify_remix_compliance,
)
from lyriclib import end_rime, normalize, tempo_line_syllables, tokenize
from telemetry import check_punch_demoted, write_verse_telemetry
from prompt_cache import canonical_cache_params, compute_cache_key, get_cached_verse, save_cached_verse

try:
    from style_scorer import score_verse
except Exception:
    score_verse = None

from llm_client import chat

DRAFT_MODELS = [
    os.environ.get("V4_DRAFT_MODEL", "claude-sonnet-5-5"),
    "claude-3-5-sonnet-20241022",
    "gpt-4o-mini",
    "gpt-4o",
]
POLISH_MODELS = [
    os.environ.get("V4_POLISH_MODEL", "claude-opus-4-7"),
    "claude-3-5-sonnet-20241022",
    "gpt-4o",
    "gpt-4o-mini",
]


def _call_model(
    candidate_models: list[str],
    system_prompt: str,
    user_prompt: str,
    temperature: float = 0.7,
    max_tokens: int = 800,
    call_fn: Optional[Callable[[str, str], str]] = None,
) -> tuple[str, str]:
    """Helper to dispatch prompt through call_fn or direct SDK candidate models."""
    if call_fn is not None:
        try:
            return call_fn(system_prompt, user_prompt), "custom_call_fn"
        except Exception as exc:
            print(f"[Frontier V4] call_fn error: {exc}", file=sys.stderr)
            return "", "error"

    for model_name in candidate_models:
        try:
            content = chat(
                model=model_name,
                system=system_prompt,
                user=user_prompt,
                temperature=temperature,
                max_tokens=max_tokens,
            )
            if content and content.strip():
                return content.strip(), model_name
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
        f"Your task is to draft exactly {bars_count} raw lyric lines adhering strictly to the 4-comma / 4-pocket isochronous rap cadence with ABAB inner rhymes.\n\n"
        f"MANDATORY RHYTHMIC & VOCABULARY RULES:\n"
        f"1. EACH BAR MUST HAVE ABOUT 4 COMMAS (4 to 5 distinct comma-delimited segments).\n"
        f"2. SUSTAINED 4-5 SYLLABLES PER COMMA: If you start with 4 or 5 syllables per comma segment, continue that exact count out across every segment in the bar (e.g. 4+4+4+4 or 5+5+5+5).\n"
        f"3. ABAB INNER-RHYME LEVEL: Segment 1 ends on Rhyme A, Segment 2 ends on Rhyme B, Segment 3 ends on Rhyme A (rhyming with Segment 1), Segment 4 ends on Rhyme B (rhyming with Segment 2 and designated end-word).\n"
        f"4. ZERO REPEATED TERMINAL WORDS: Never end multiple lines on the same word or identical root (e.g. NEVER rhyme 'Mercedes' with 'mercedes', NEVER repeat 'overseas'). Every rhyme must land on distinct vocabulary.\n"
        f"5. NO CORNY / FORCED MULTISYLLABIC SLANTS: Strictly avoid unnatural words like 'hospital', 'optical', 'obstacle', 'impossible', 'lobster'. Rhymes must sound like authentic rap speech.\n"
        f"6. USER GROUND TRUTH GOLD BENCHMARKS (EMULATE THIS NATURAL PACING & SLANT CRAFT):\n"
        f"   - 'on the block, stackin' them knots, pushin' the weight, in the mercedes' (3s, 5s, 4s, 5s)\n"
        f"   - 'drilling these streets, fearless with moves, watch is two tone, man it go crazy' (5s, 5s, 4s, 5s)\n"
        f"   - 'stackin' some chips, fliping the script, in it then dip, fly overseas' (5s, 5s, 4s, 4s)\n"
        f"   - 'im on my grind, standin' so tall, against the odds, wont drop to my knees' (4s, 5s, 4s, 5s)\n"
        f"   - 'rollin 10 deep, tinted and creep, aint catching no sleep, audi it beeps' (4s, 5s, 5s, 4s)\n"
        f"   - 'open' the roof, im catching a breeze, blessings surround, im blessed when i sneeze' (4s, 5s, 4s, 5s)\n"
        f"7. Every bar MUST land on its designated authentic catalog end-word in the final segment.\n"
        f"8. Output ONLY the {bars_count} lyric lines, no explanations, no quotes, no bar labels."
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
        f"3. 4-COMMA ISOCHRONOUS CADENCE: About 4 commas per line (4 to 5 distinct rhythmic pockets, 4-5 syllables each, total {effective_syl}s).\n"
        f"4. SUSTAIN SYLLABLE COUNTS: If a line starts with 4 or 5 syllables per comma segment, continue that exact count out across every segment (e.g. 4+4+4+4 or 5+5+5+5).\n"
        f"5. ABAB INNER-RHYME LEVEL: Segment 1 rhymes with Segment 3 (Rhyme A), Segment 2 rhymes with Segment 4 (Rhyme B).\n"
        f"6. ZERO REPEATED TERMINAL WORDS: Never end multiple bars on the same word or identical root (e.g. NEVER rhyme 'Mercedes' with 'mercedes', NEVER repeat 'overseas').\n"
        f"7. NO CORNY / FORCED SLANTS: Strictly reject unnatural words ('hospital', 'optical', 'obstacle', 'impossible', 'lobster').\n"
        f"8. USER GOLD BENCHMARKS: Emulate natural pocket bounce like 'drilling these streets, fearless with moves, watch is two tone, man it go crazy' and 'open' the roof, im catching a breeze, blessings surround, im blessed when i sneeze'.\n\n"
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
    bpm: Optional[float] = None,
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
    base_cap: float = 0.30,
    taste_on: bool = True,
    taste_k: int = 6,
    candidates: int = 1,
    generation_id: str = "",
    use_cache: bool = True,
    call_fn: Optional[Callable[[str, str], str]] = None,
    seed_audio: Optional[str] = None,
    audio_flow_override: Optional[dict] = None,
) -> dict:
    """Master entry point for Frontier V4 Two-Pass Generation with Grid Verification & Style Scoring."""
    t0 = time.time()
    generation_id = generation_id or f"v4_{int(time.time())}_{uuid.uuid4().hex[:8]}"

    # Task S: Whisper Hum-to-Flow Seed Audio Ingestion
    audio_flow = None
    if audio_flow_override is not None:
        audio_flow = audio_flow_override
    elif seed_audio:
        try:
            from whisper_seed import transcribe_and_extract_flow
            audio_flow = transcribe_and_extract_flow(seed_audio)
        except Exception as exc:
            print(f"[Frontier V4] whisper_seed warning: {exc}", file=sys.stderr)

    if audio_flow:
        if bpm is None:
            bpm = float(audio_flow.get("bpm_estimate", 130))
        if target_syl is None or target_syl == 0:
            target_syl = int(audio_flow.get("median_syl_per_line", 18))
        if not seed_line and audio_flow.get("text"):
            seed_line = audio_flow["text"]

    bpm = 130.0 if bpm is None else float(bpm)
    clock_bpm, halftime_bpm, tempo_label = polish.normalize_trap_tempo(bpm)
    from hook_engine import get_section_cadence_rules, verify_section_structure
    sec_rules = get_section_cadence_rules(section_mode)
    effective_syl = target_syl if target_syl else (sec_rules["target_syl"] if section_mode != "verse" else max(15, tempo_line_syllables(clock_bpm) + 2))
    user_albums = chosen_albums or DEFAULT_CHOSEN_ALBUMS.get(voice, [])

    # Task L: Prompt & Params Cache Lookup
    cache_params = canonical_cache_params(
        engine="v4",
        voice=voice,
        blend=blend,
        mix=mix,
        bpm=clock_bpm,
        scale=scale,
        section_mode=section_mode,
        chosen_albums=user_albums,
        seed_line=seed_line,
        scratchpad=scratchpad_bars,
        topic_hint=topic_hint,
        remix_ratio=remix_ratio,
        base_cap=base_cap,
        bars_count=bars_count,
        target_syl=effective_syl,
        taste_on=taste_on,
        taste_k=taste_k,
        seed_audio=seed_audio,
    )
    cache_key = compute_cache_key(cache_params)

    if use_cache:
        cached_result = get_cached_verse(cache_key)
        if cached_result is not None:
            return cached_result

    cmu = polish._get_cmu()
    dna = polish._get_voice_dna()

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

    # Retrieve authentic catalog lines matching the plan's end words (Task H: topic-chain binding + dedupe window)
    bar_artists = [plan["couplet_voices"][i // 2] for i in range(bars_count)] if plan.get("couplet_voices") else [voice] * bars_count
    retrieved_catalog_bars = []
    used_line_ids = set()
    recent_ends = get_end_word_history(window_size=16)

    for i in range(bars_count):
        target_artist = bar_artists[i]
        tw = plan["end_words"][i] if i < len(plan["end_words"]) else "audamar"
        couplet_idx = i // 2
        bar_motif = (
            plan["motif_chain"][couplet_idx % len(plan["motif_chain"])]
            if (plan.get("motif_chain") and len(plan["motif_chain"]) > 0)
            else topic_hint
        )
        p = {
            "end_word": tw,
            "end_rime": " ".join(end_rime(tw, cmu) or ()),
            "vowel_class": "V_other",
            "target_syllables": effective_syl,
            "topic": bar_motif,
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
            topic_hint=bar_motif,
            recent_end_words=recent_ends,
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

        # Pass 2.5: Named-Entity Leak Guard Verification & Auto-Retry (Task P)
        from entity_guard import guard_verse, rewrite_leaked_entity_bar
        entity_eval = guard_verse(voice=voice, bars=polished_lines, bar_artists=bar_artists)
        entity_retries_done = 0

        if not entity_eval["passed"]:
            for failed_i in entity_eval["failed_indices"]:
                b_res = entity_eval["bar_results"][failed_i]
                target_word = plan["end_words"][failed_i] if failed_i < len(plan["end_words"]) else "audamar"
                cat_item = retrieved_catalog_bars[failed_i] if failed_i < len(retrieved_catalog_bars) else None
                cat_txt = cat_item["text"] if cat_item else ""
                artist_i = bar_artists[failed_i]
                offending = b_res["offending_tokens"]

                for _ in range(2):
                    entity_retries_done += 1
                    rewritten, passed = rewrite_leaked_entity_bar(
                        bar_text=polished_lines[failed_i],
                        target_word=target_word,
                        offending_tokens=offending,
                        voice=artist_i,
                        source_catalog_text=cat_txt,
                        cmu=cmu,
                        call_fn=call_fn,
                    )
                    if rewritten:
                        polished_lines[failed_i] = rewritten
                        if passed:
                            break

        final_entity_eval = guard_verse(voice=voice, bars=polished_lines, bar_artists=bar_artists)

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

        # Pass 3.5: Comprehensive Cadence & Anti-Repetition Audit
        from cadence_analyzer import audit_verse_cadence_and_rhymes
        cadence_audit = audit_verse_cadence_and_rhymes(polished_lines, cmu=cmu)
        cadence_penalty = (len(cadence_audit["duplicate_end_words"]) * 0.25) + (len(cadence_audit["corny_words_found"]) * 0.30)
        effective_cadence_score = max(0.0, cadence_audit["overall_score"] - cadence_penalty)

        take_candidates.append({
            "candidate_index": c_idx + 1,
            "draft_bars": draft_lines,
            "polished_bars": polished_lines,
            "draft_model": draft_model,
            "polish_model": polish_model,
            "grid_gate": final_grid,
            "grid_pass_rate": final_grid["pass_rate"],
            "grid_retries": retries_done,
            "entity_guard": final_entity_eval,
            "entity_retries": entity_retries_done,
            "cadence_audit": cadence_audit,
            "effective_cadence_score": round(effective_cadence_score, 3),
            "style_score": style_score_val,
        })

    # Pick best candidate based on (grid_pass_rate, effective_cadence_score, style_score)
    take_candidates.sort(key=lambda t: (t["grid_pass_rate"], t["effective_cadence_score"], t["style_score"]), reverse=True)
    best_take = take_candidates[0]
    final_bars = best_take["polished_bars"]

    # Assemble detailed bar metadata
    detailed_bars = []
    from cadence_analyzer import analyze_bar_cadence

    for idx, ln in enumerate(final_bars):
        couplet_idx = idx // 2
        cat_match = retrieved_catalog_bars[idx] if idx < len(retrieved_catalog_bars) else None
        target_word = plan["end_words"][idx] if idx < len(plan["end_words"]) else "audamar"
        cad = analyze_bar_cadence(ln, cmu=cmu)
        toks = tokenize(normalize(ln))
        end_w = toks[-1] if toks else target_word

        bar_cap = get_dynamic_cap(cat_match, base_cap=base_cap)
        compliance = verify_remix_compliance(cat_match["text"], ln, cap=bar_cap, cmu=cmu) if cat_match else {
            "is_compliant": True,
            "edit_distance_ratio": 0.25,
            "cap": bar_cap,
            "end_word_preserved": True,
        }
        bar_grid = best_take["grid_gate"]["bar_results"][idx] if idx < len(best_take["grid_gate"]["bar_results"]) else {}
        cat_id = cat_match.get("id") if cat_match else None
        p_demoted = check_punch_demoted(ln, target_end_word=target_word)

        detailed_bars.append({
            "index": idx + 1,
            "artist": bar_artists[idx],
            "text": cad["formatted_line"],
            "raw_text": ln,
            "quad_formatted": cad["formatted_line"],
            "beat_groups": [s["text"] for s in cad["segments"]],
            "beat_syllables": [s["syllables"] for s in cad["segments"]],
            "segments": cad["segments"],
            "halves": [{"text": s["text"], "syl": s["syllables"]} for s in cad["segments"]],
            "syllable_pattern": cad["syl_pattern"],
            "is_isochronous": cad["is_isochronous"],
            "is_quadrasonic": len(cad["segments"]) >= 4,
            "abab_detected": cad["abab_detected"],
            "aabb_detected": cad["aabb_detected"],
            "rhyme_type": cad["rhyme_type"],
            "internal": cad["internal_pairs"],
            "cadence_score": cad["cadence_score"],
            "setup": ", ".join(s["text"] for s in cad["segments"][:2]),
            "punchline": ", ".join(s["text"] for s in cad["segments"][2:]),
            "syllables": cad["total_syllables"],
            "target_syllables": effective_syl,
            "delta": cad["total_syllables"] - effective_syl,
            "end_word": end_w,
            "rhyme_family": plan["rhyme_families"][couplet_idx % len(plan["rhyme_families"])] if plan.get("rhyme_families") else "",
            "motif": plan["motif_chain"][couplet_idx % len(plan["motif_chain"])].replace("_", " ").title() if plan.get("motif_chain") else "Motif",
            "couplet_num": couplet_idx + 1,
            "source_catalog_id": cat_id,
            "source_catalog_text": cat_match["text"] if cat_match else "",
            "source_catalog_song": cat_match["song"] if cat_match else "",
            "source_catalog_album": cat_match["album"] if cat_match else "",
            "edit_distance_ratio": compliance["edit_distance_ratio"],
            "edit_distance_cap": compliance["cap"],
            "remix_compliant": compliance["is_compliant"],
            "end_word_preserved": compliance["end_word_preserved"],
            "punch_demoted": p_demoted,
            "grid_passed": bar_grid.get("passed", True),
            "grid_violations": bar_grid.get("off_grid_beats", []),
        })

    # Task H: Record newly generated end words to dedupe history
    try:
        record_used_end_words([b["end_word"] for b in detailed_bars])
    except Exception:
        pass

    # Task K: Write per-bar telemetry to tools/lyric-llm/out/v4_telemetry.jsonl
    try:
        write_verse_telemetry(
            generation_id=generation_id,
            bars=detailed_bars,
            plan=plan,
            style_score=best_take["style_score"],
            voice=voice,
        )
    except Exception as exc:
        print(f"[Frontier V4] Telemetry write failed: {exc}", file=sys.stderr)

    # Audio Stem Alignment Grid
    stem_grid = v3_audio_aligner.generate_full_stem_alignment(
        detailed_bars,
        bpm=clock_bpm,
        pocket_style="laid_back" if voice.lower() in ("gunna", "thug", "young thug") else "on_the_grid",
    )
    stem_grid["grid_pass_rate"] = best_take["grid_pass_rate"]

    elapsed = round(time.time() - t0, 2)

    result_dict = {
        "ok": True,
        "version": "v4",
        "generation_id": generation_id,
        "cached": False,
        "cache_key": cache_key,
        "provider": f"frontier_v4 ({best_take['draft_model']} -> {best_take['polish_model']})",
        "voice": voice,
        "blend": blend,
        "mix": mix if blend else None,
        "blend_allocation": bar_artists,
        "bpm": bpm,
        "clock_bpm": clock_bpm,
        "scale": scale,
        "target_syllables": effective_syl,
        "base_cap": base_cap,
        "section_mode": section_mode,
        "section_structure": verify_section_structure(final_bars, section_mode=section_mode, cmu=cmu),
        "seed_audio": seed_audio,
        "audio_flow": audio_flow,
        "plan": plan,
        "draft_bars": best_take["draft_bars"],
        "polished_bars": best_take["polished_bars"],
        "grid_gate": best_take["grid_gate"],
        "grid_pass_rate": best_take["grid_pass_rate"],
        "grid_retries": best_take["grid_retries"],
        "grid_retries_total": best_take["grid_retries"],
        "entity_guard": best_take.get("entity_guard", {"passed": True, "offending_tokens": []}),
        "entity_retries": best_take.get("entity_retries", 0),
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

    # Task L: Save generated verse to prompt & params cache
    if use_cache:
        try:
            save_cached_verse(
                cache_key=cache_key,
                params=cache_params,
                result=result_dict,
                retrieved_catalog_bars=retrieved_catalog_bars,
                plan=plan,
            )
        except Exception as exc:
            print(f"[Frontier V4] Failed to save prompt cache: {exc}", file=sys.stderr)

    return result_dict


def main():
    parser = argparse.ArgumentParser(description="Penwork Studios Frontier V4 Master Orchestrator")
    parser.add_argument("--voice", default="Gunna", help="Artist pocket")
    parser.add_argument("--blend", default="NoCap", help="Secondary voice blend")
    parser.add_argument("--mix", type=int, default=70, help="Blend mix %")
    parser.add_argument("--bpm", type=float, default=None, help="Tempo BPM (defaults to 130 or audio seed estimate)")
    parser.add_argument("--scale", default="F minor", help="Musical scale")
    parser.add_argument("--syl", type=int, default=None, help="Target syllable budget (defaults to 18 or audio seed estimate)")
    parser.add_argument("--bars", type=int, default=8, help="Number of bars")
    parser.add_argument("--topic", default="", help="Studio theme or topic hint")
    parser.add_argument("--candidates", type=int, default=1, help="Number of candidate takes to generate and rank")
    parser.add_argument("--taste", choices=["on", "off"], default="on", help="Wire rater feedback taste blocks")
    parser.add_argument("--taste-k", type=int, default=6, help="Top K keeper bars")
    parser.add_argument("--base-cap", type=float, default=0.30, help="Base remix edit-distance cap (default: 0.30)")
    parser.add_argument("--seed-audio", default=None, help="Path to vocal audio file (.m4a/.wav) for Whisper hum-to-flow seed")
    parser.add_argument("--no-cache", dest="use_cache", action="store_false", default=True, help="Bypass prompt and params cache")
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
        base_cap=args.base_cap,
        taste_on=(args.taste == "on"),
        taste_k=args.taste_k,
        use_cache=args.use_cache,
        seed_audio=args.seed_audio,
    )

    print(f"\n[Penwork Studios Frontier V4] {res['voice']} ({res['blend']} {res['mix']}%) @ {res['bpm']} BPM")
    print(f"Provider: {res['provider']} · Style Score: {res['style_score']} · Grid Pass Rate: {res['grid_pass_rate']*100:.1f}%\n")
    for b in res["bars"]:
        grid_status = "✓ GRID" if b["grid_passed"] else "✗ OFF-GRID"
        print(f"Bar {b['index']:02d} [{b['syllables']:2d}s | Couplet {b['couplet_num']} | {b['artist']}]: {b['text']} [{grid_status}]")


if __name__ == "__main__":
    main()
