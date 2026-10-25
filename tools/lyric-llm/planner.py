#!/usr/bin/env python3
"""Penwork Studios Frontier V4 Task J: Reasoning-Model Planner Stage.

Uses frontier reasoning models (Opus / auto/best-reasoning / GPT-4o) to generate
strict structural blueprints for rap verses:
  - Motif progression chain
  - Couplet-level voice assignments
  - Authentic catalog end-word rhyme targets
  - Rhyme family vowel classifications
  - Couplet narrative objectives
"""

from __future__ import annotations

import json
import os
import random
import re
import sys
import urllib.request
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional

from llm_client import chat

HERE = Path(__file__).resolve().parent

REASONING_MODELS = [
    os.environ.get("V4_PLAN_MODEL", "claude-opus-4-7"),
    "claude-3-5-sonnet-20241022",
    "gpt-4o",
    "gpt-4o-mini",
]

# Motif keys supported across ADHD progression
VALID_MOTIF_KEYS = [
    "lavishness_money",
    "romance_women",
    "street_defiance",
    "boss_authority",
    "spiritual_faith",
    "pain_betrayal",
]

# Prohibited generic nursery words (same as polish.GENERIC_END_RHYME_BLACKLIST)
GENERIC_END_RHYME_BLACKLIST = {
    "real", "cake", "slide", "plate", "date", "gate", "late", "wait", "lake", "make", "take", "brake",
    "back", "trap", "cash", "bag", "man", "can", "day", "way", "play", "say",
    "go", "know", "so", "no", "glow", "flow", "show", "low",
    "tight", "night", "fight", "light", "right", "sight",
    "mind", "grind", "find", "kind", "soul", "toll", "cold", "mold", "hold", "told",
    "pain", "rain", "main", "sane", "game", "fame", "name", "same",
    "yeah", "uh", "it", "me", "you", "one", "two", "baby", "boy", "girl", "time", "too", "do",
}


def _get_catalog_end_words(voice: str, blend: str = "") -> set[str]:
    """Retrieve all known authentic catalog end-words and rhyme pairs for validation."""
    SIGNATURE_BENCHMARK_WORDS = {
        "audamar", "audemars", "car", "mercedes", "crazy", "squeeze", "toronto", "pronto",
        "patek", "maybach", "collar", "dollar", "paris", "cellar", "fella", "payback",
        "franklins", "ankles", "celine", "listerine", "carbone",
    }
    try:
        from polish import ARTIST_CATALOG_RHYME_BANKS, _get_voice_dna, get_artist_catalog_rhymes
        dna = _get_voice_dna()
        v_cat = get_artist_catalog_rhymes(voice, dna)
        valid_words = set(w.lower() for w in v_cat.get("top_end_words", []))
        valid_words.update(SIGNATURE_BENCHMARK_WORDS)
        for bank in ARTIST_CATALOG_RHYME_BANKS.get(voice, []):
            valid_words.add(bank["pair"][0].lower())
            valid_words.add(bank["pair"][1].lower())
        if blend:
            b_cat = get_artist_catalog_rhymes(blend, dna)
            for w in b_cat.get("top_end_words", []):
                valid_words.add(w.lower())
            for bank in ARTIST_CATALOG_RHYME_BANKS.get(blend, []):
                valid_words.add(bank["pair"][0].lower())
                valid_words.add(bank["pair"][1].lower())
        return valid_words
    except Exception:
        return SIGNATURE_BENCHMARK_WORDS
        return {
            "audamar", "audemars", "lobster", "mercedes", "squeeze", "toronto", "patek", "maybach",
            "collar", "dollar", "paris", "cellar", "fella", "payback", "franklins", "ankles",
        }


def _fallback_plan(
    voice: str,
    blend: str,
    bpm: float,
    bars: int,
    topic_hint: str = "",
) -> dict:
    """Authentic catalog bank plan with stochastic diversity and topic matching."""
    couplet_count = max(1, bars // 2)
    try:
        from polish import ARTIST_CATALOG_RHYME_BANKS, allocate_bar_artists
        from catalog_retriever import get_end_word_history
        banks = list(ARTIST_CATALOG_RHYME_BANKS.get(voice) or ARTIST_CATALOG_RHYME_BANKS.get("Gunna", []))
        bar_artists = allocate_bar_artists(voice=voice, blend=blend, mix=70, bars_count=bars)
        couplet_voices = [bar_artists[i * 2] for i in range(couplet_count)]
        recent_ends = set(w.lower() for w in get_end_word_history(window_size=16) if w)
    except Exception:
        banks = [
            {"pair": ("audamar", "car"), "family": "/ɑːr/", "theme": "Penthouse Luxury & Exotic Cars", "bag": "luxury_drip"},
            {"pair": ("mercedes", "crazy"), "family": "/eɪzi/", "theme": "High-Speed Highway", "bag": "luxury_drip"},
            {"pair": ("maybach", "payback"), "family": "/eɪbæk/", "theme": "Executive Vengeance", "bag": "pain_ditch_betrayal"},
            {"pair": ("toronto", "pronto"), "family": "/ɒntoʊ/", "theme": "Cross-Border Business", "bag": "fast_pocket"},
        ]
        couplet_voices = [voice] * couplet_count
        recent_ends = set()

    seed_env = os.environ.get("V4_SEED")
    rng = random.Random(int(seed_env)) if seed_env else random.Random()

    # Filter out recently used end-words to prevent duplicate consecutive verses
    candidate_banks = [
        b for b in banks
        if not any(w.lower() in recent_ends for w in b.get("pair", ()))
    ]
    if len(candidate_banks) < couplet_count:
        candidate_banks = list(banks)

    # Score candidates by topic match
    topic_clean = topic_hint.lower().replace("_", " ")
    topic_words = [t for t in topic_clean.split() if len(t) >= 3]
    pool = []
    for b in candidate_banks:
        weight = 1.0
        theme = (b.get("theme") or "").lower()
        bag = (b.get("bag") or "").lower()
        if any(tw in theme or tw in bag for tw in topic_words):
            weight += 4.0
        pool.append((b, weight))

    chosen_banks = []
    pool_copy = list(pool)
    for _ in range(min(couplet_count, len(pool_copy))):
        weights = [p[1] for p in pool_copy]
        pick = rng.choices(pool_copy, weights=weights, k=1)[0]
        chosen_banks.append(pick[0])
        pool_copy.remove(pick)

    # If still short, cycle remaining
    while len(chosen_banks) < couplet_count:
        chosen_banks.append(banks[len(chosen_banks) % len(banks)])

    motif_chain = [VALID_MOTIF_KEYS[i % len(VALID_MOTIF_KEYS)] for i in range(couplet_count)]
    end_words = []
    rhyme_families = []
    couplet_narratives = []

    for c_i, b in enumerate(chosen_banks):
        p1, p2 = b.get("pair", ("audamar", "car"))
        end_words.extend([p1, p2])
        rhyme_families.append(b.get("family", "/ɑːr/"))
        couplet_narratives.append(f"{couplet_voices[c_i]} establishes {motif_chain[c_i].replace('_', ' ')}")

    return {
        "motif_chain": motif_chain[:couplet_count],
        "couplet_voices": couplet_voices[:couplet_count],
        "end_words": end_words[:bars],
        "rhyme_families": rhyme_families[:couplet_count],
        "couplet_narratives": couplet_narratives[:couplet_count],
        "voice": voice,
        "blend": blend,
        "bpm": bpm,
        "bars_count": bars,
        "planner_model": "heuristic_fallback",
        "plan_valid": True,
    }


def plan_v4(
    voice: str = "Gunna",
    bpm: float = 130.0,
    bars: int = 8,
    topic_hint: str = "",
    chosen_albums: list[str] = None,
    blend: str = "",
    mix: int = 70,
    call_fn: Optional[Callable[[str, str], str]] = None,
) -> dict:
    """Generates a structured frontier reasoning blueprint for verse construction."""
    couplet_count = max(1, bars // 2)
    catalog_words = _get_catalog_end_words(voice, blend)

    # Determine couplet voice allocation based on mix
    from polish import allocate_bar_artists, ARTIST_CATALOG_RHYME_BANKS
    bar_artists = allocate_bar_artists(voice=voice, blend=blend, mix=mix, bars_count=bars)
    expected_couplet_voices = [bar_artists[i * 2] for i in range(couplet_count)]

    # Example authentic catalog pairs to guide the planner
    v_banks = ARTIST_CATALOG_RHYME_BANKS.get(voice) or ARTIST_CATALOG_RHYME_BANKS.get("Gunna", [])
    example_pairs = [f"{b['pair'][0]} / {b['pair'][1]} ({b['family']})" for b in v_banks[:4]]

    system_prompt = (
        "You are Penwork Studios' Platinum Executive Ghostwriting Planner (Frontier V4 Reasoning Backbone).\n"
        "Your role is to return a strict JSON blueprint defining the overarching motifs, couplet voice distribution, "
        "and authentic catalog rhyme anchors for a rap verse. You do NOT write full verses; you design the architectural plan.\n\n"
        "CRITICAL PLANNING MANDATES:\n"
        "1. STRICT CATALOG END-WORDS: Every couplet must resolve on authentic artist catalog words (e.g. audamar, car, mercedes, crazy, patek, maybach, celine, cellar).\n"
        "2. ZERO GENERIC NURSERY RHYMES: NEVER use words like real, cake, slide, plate, light, tight, day, way, pain, rain, cash, trap.\n"
        "3. ADHD MOTIF JUMPS: Modern rap pivots thematic focus every 2 bars (couplet). Select motif keys from: lavishness_money, romance_women, street_defiance, boss_authority, spiritual_faith, pain_betrayal.\n"
        "4. OUTPUT FORMAT: Return ONLY valid JSON with no markdown wrapping, no commentary."
    )

    user_prompt = (
        f"PLANNING REQUEST FOR RAP VERSE:\n"
        f"- Primary Artist: {voice}\n"
        f"- Blended Voice: {blend} ({mix}% {voice} / {100-mix}% {blend})\n"
        f"- Target Tempo: {bpm} BPM\n"
        f"- Bar Count: {bars} bars ({couplet_count} couplets)\n"
        f"- Topic / Mood Hint: \"{topic_hint or 'Platinum luxury living, late night drives, effortless swagger'}\"\n"
        f"- Albums: {', '.join(chosen_albums or ['Drip Season 3', 'WUNNA'])}\n"
        f"- Known Authentic End-Rhyme Pairs for {voice}: {'; '.join(example_pairs)}\n\n"
        f"Return a JSON object with exactly these fields:\n"
        f"{{\n"
        f'  "motif_chain": ["motif_1", "motif_2", ...],       // length {couplet_count}, chosen from VALID_MOTIF_KEYS\n'
        f'  "couplet_voices": ["{expected_couplet_voices[0]}", ...],     // length {couplet_count}, matching blend distribution\n'
        f'  "end_words": ["word_1", "word_2", ...],           // length {bars}, authentic catalog words (AABB rhyme scheme)\n'
        f'  "rhyme_families": ["/vowel_sound/", ...],         // length {couplet_count}\n'
        f'  "couplet_narratives": ["brief objective", ...]    // length {couplet_count}\n'
        f"}}"
    )

    response_text = ""
    used_model = "custom_call_fn"

    if call_fn is not None:
        try:
            response_text = call_fn(system_prompt, user_prompt)
        except Exception as exc:
            print(f"[plan_v4] call_fn error: {exc}", file=sys.stderr)
    else:
        for model_name in REASONING_MODELS:
            try:
                content = chat(
                    model=model_name,
                    system=system_prompt,
                    user=user_prompt,
                    max_tokens=600,
                    temperature=0.5,
                )
                if content and content.strip():
                    response_text = content.strip()
                    used_model = model_name
                    break
            except Exception as exc:
                continue

    if not response_text:
        return _fallback_plan(voice, blend, bpm, bars, topic_hint)

    # Parse JSON from response
    parsed_json = None
    clean_text = response_text.strip()
    if clean_text.startswith("```"):
        lines = [l for l in clean_text.splitlines() if not l.startswith("```")]
        clean_text = "\n".join(lines).strip()

    try:
        parsed_json = json.loads(clean_text)
    except Exception:
        # Try finding JSON object within response
        match = re.search(r"\{.*\}", clean_text, re.DOTALL)
        if match:
            try:
                parsed_json = json.loads(match.group(0))
            except Exception:
                parsed_json = None

    if not isinstance(parsed_json, dict):
        return _fallback_plan(voice, blend, bpm, bars, topic_hint)

    # Validate and normalize parsed plan fields
    motif_chain = parsed_json.get("motif_chain") or []
    if not isinstance(motif_chain, list) or len(motif_chain) < couplet_count:
        motif_chain = [VALID_MOTIF_KEYS[i % len(VALID_MOTIF_KEYS)] for i in range(couplet_count)]
    else:
        motif_chain = [m if m in VALID_MOTIF_KEYS else VALID_MOTIF_KEYS[i % len(VALID_MOTIF_KEYS)] for i, m in enumerate(motif_chain[:couplet_count])]

    couplet_voices = parsed_json.get("couplet_voices") or []
    if not isinstance(couplet_voices, list) or len(couplet_voices) < couplet_count:
        couplet_voices = expected_couplet_voices
    else:
        couplet_voices = [v if v in (voice, blend) else expected_couplet_voices[i] for i, v in enumerate(couplet_voices[:couplet_count])]

    end_words = parsed_json.get("end_words") or []
    if not isinstance(end_words, list) or len(end_words) < bars:
        fb = _fallback_plan(voice, blend, bpm, bars, topic_hint)
        end_words = fb["end_words"]
    else:
        # Validate each end word against generic blacklist and catalog presence
        clean_ends = []
        for i, w in enumerate(end_words[:bars]):
            w_clean = re.sub(r"[^a-zA-Z0-9']", "", str(w).strip().lower())
            couplet_i = i // 2
            bank = v_banks[couplet_i % len(v_banks)]
            catalog_fallback = bank["pair"][i % 2]

            if w_clean in GENERIC_END_RHYME_BLACKLIST or not w_clean:
                clean_ends.append(catalog_fallback)
            elif catalog_words and (w_clean not in catalog_words):
                # If word is OOV, use authentic catalog fallback
                clean_ends.append(catalog_fallback)
            else:
                clean_ends.append(w_clean)
        end_words = clean_ends

    rhyme_families = parsed_json.get("rhyme_families") or []
    if not isinstance(rhyme_families, list) or len(rhyme_families) < couplet_count:
        rhyme_families = [f"Couplet {i+1} Rhyme Family" for i in range(couplet_count)]
    else:
        rhyme_families = [str(f) for f in rhyme_families[:couplet_count]]

    couplet_narratives = parsed_json.get("couplet_narratives") or []
    if not isinstance(couplet_narratives, list) or len(couplet_narratives) < couplet_count:
        couplet_narratives = [f"{couplet_voices[i]} explores {motif_chain[i]}" for i in range(couplet_count)]
    else:
        couplet_narratives = [str(n) for n in couplet_narratives[:couplet_count]]

    return {
        "motif_chain": motif_chain,
        "couplet_voices": couplet_voices,
        "end_words": end_words,
        "rhyme_families": rhyme_families,
        "couplet_narratives": couplet_narratives,
        "voice": voice,
        "blend": blend,
        "bpm": bpm,
        "bars_count": bars,
        "planner_model": used_model,
        "plan_valid": True,
    }


if __name__ == "__main__":
    plan = plan_v4(voice="Gunna", bpm=130.0, bars=8, topic_hint="penthouse audamar")
    print(json.dumps(plan, indent=2))
