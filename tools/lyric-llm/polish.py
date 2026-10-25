#!/usr/bin/env python3
"""Penwork Studios Frontier Ghostwriter V2: Multi-Motif Associative Leaps & Reverse-Catalog Engine.

Features:
  1. Reverse-Catalog End-Rhymes: Injects authentic artist rhyme banks (Gunna drip pairs,
     NoCap homophones, Lil Wayne metaphors, Drake cadence) directly into the rhyme anchors.
  2. ADHD Motif-Jumping Progression: Automatically jumps topics every 2-bar couplet
     (e.g., Lavishness -> Romance -> Street Defiance -> Boss Talk) mimicking real rap structure.
  3. Strict Syllable Pocket Matrix: Enforces exact tempo-to-syllable bounds (±1 syl).
  4. Dual Operation: Full generation from scratch or high-fidelity polishing of draft takes.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.request
import uuid
from pathlib import Path

from lyriclib import end_rime, estimate_syllables, load_cmudict, normalize, tempo_line_syllables, tokenize

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
CMU_PATH = HERE.parent.parent / "XJournal AI" / "cmudict.txt"

# Task B': Connect to style-profile rater feedback store for taste blocks
STYLE_PROFILE_DIR = HERE.parent / "style-profile"
if str(STYLE_PROFILE_DIR) not in sys.path:
    sys.path.insert(0, str(STYLE_PROFILE_DIR))

try:
    from phase6_generate import build_taste_prompt_blocks
except Exception:
    build_taste_prompt_blocks = None

from llm_client import chat

# Curated Motif Definitions for ADHD Associative Leaps & Multi-Bag Personas
MOTIF_DEFINITIONS = {
    "lavishness_money": {
        "title": "Lavishness & Money",
        "description": "Foreign whips, iced-out jewelry, Richard Mille, Goyard bags, multi-million wire transfers, penthouse living.",
        "keywords": ["patek", "maybach", "bands", "racks", "goyard", "diamonds", "custom", "cash", "million", "suite"],
    },
    "romance_women": {
        "title": "Women & Romance",
        "description": "Late-night encounters, complicated relationships, high-fashion styling, fast lifestyle tensions.",
        "keywords": ["she", "ride", "vibe", "call", "late", "fashion", "eyes", "text", "close", "flight"],
    },
    "street_defiance": {
        "title": "Street Defiance ('Don't Try Me')",
        "description": "Guard up, paranoia, street survival, loyalty testing, aggressive boundary-setting, vigilance.",
        "keywords": ["steel", "switch", "watch", "fake", "trust", "guards", "stand", "danger", "solid", "corner"],
    },
    "boss_authority": {
        "title": "Boss Talk & Authority",
        "description": "Ownership, running the label, generational wealth, being the provider, unquestioned dominance.",
        "keywords": ["boss", "check", "sign", "lead", "built", "empire", "contracts", "own", "power", "floor"],
    },
    "pain_reflection": {
        "title": "Pain & Emotional Reflection",
        "description": "Grief, lost friends, surviving trauma, scar tissue, reminiscing about humble beginnings.",
        "keywords": ["pain", "scars", "rain", "lost", "remember", "grave", "struggle", "cold", "tears", "soul"],
    },
    "drill_aggression": {
        "title": "Drill & High Energy",
        "description": "Fast-paced kinetic energy, opp deterrence, heavy sliding, aggressive cadence, relentless momentum.",
        "keywords": ["slide", "demon", "step", "move", "drop", "heavy", "run", "fast", "action", "blacked"],
    },
    "faith_hope": {
        "title": "Religious Faith & Spiritual Hope",
        "description": "Praying to God on his knees, spiritual redemption, blessings, thank the Lord, karma, divine protection.",
        "keywords": ["god", "pray", "praying", "prayer", "lord", "church", "blessed", "faith", "knees", "soul", "heaven", "thank god"],
    },
    "pain_ditch_betrayal": {
        "title": "In The Ditch, Pain & Betrayal",
        "description": "Snitch allegations, locked in a cell, sitting in a ditch, fake friends turning their back, trusting nobody, paranoia, rising from rock bottom.",
        "keywords": ["ditch", "turned your back", "jail", "cell", "fake friends", "snitch", "rumors", "scars", "alone", "betrayed", "mud", "trauma"],
    },
    "punchlines_metaphors": {
        "title": "Slick Numerical Metaphors & Punchlines",
        "description": "Clever numerical wordplay, chess moves, double meanings ('think he the one, but he really the two', 'peace with the piece').",
        "keywords": ["one", "two", "chess", "board", "check", "game", "double", "metaphor", "piece", "peace", "strike"],
    },
    "fast_pocket": {
        "title": "Fast-Paced Relentless Technical Pocket",
        "description": "Rapid-fire 16th syllabic rush, double-time technical delivery, breathless momentum.",
        "keywords": ["fast", "speed", "rush", "turbo", "dash", "quick", "flying", "zoom", "race", "gas"],
    },
}

DEFAULT_ADHD_CHAIN = ["lavishness_money", "romance_women", "street_defiance", "boss_authority"]

ADHD_PRESETS = {
    "adhd_trap": ["lavishness_money", "romance_women", "street_defiance", "boss_authority"],
    "street_hustle": ["lavishness_money", "street_defiance", "pain_reflection", "boss_authority"],
    "pure_luxury": ["lavishness_money", "romance_women", "lavishness_money", "boss_authority"],
    "pain_to_glory": ["pain_reflection", "street_defiance", "drill_aggression", "boss_authority"],
    "gunna_multibag": ["pain_ditch_betrayal", "faith_hope", "lavishness_money", "punchlines_metaphors"],
    "gunna_ditch_soul": ["pain_ditch_betrayal", "street_defiance", "faith_hope", "pain_reflection"],
    "gunna_spiritual": ["faith_hope", "pain_ditch_betrayal", "faith_hope", "boss_authority"],
    "gunna_fast_pocket": ["fast_pocket", "punchlines_metaphors", "lavishness_money", "street_defiance"],
}


def _resolve_adhd_chain(chain_input, scale: str = "F minor", bpm: float = 130.0, voice: str = "Gunna") -> list[str]:
    norm_v = (voice or "").strip().lower()
    if not chain_input or chain_input in ("auto", "adhd_trap"):
        if norm_v == "gunna":
            if bpm >= 140:
                return ADHD_PRESETS["gunna_fast_pocket"]
            if "minor" in (scale or "").lower():
                return ADHD_PRESETS["gunna_multibag"]
            return ["lavishness_money", "romance_women", "faith_hope", "punchlines_metaphors"]
        return DEFAULT_ADHD_CHAIN
    if isinstance(chain_input, str):
        if chain_input in ADHD_PRESETS:
            return ADHD_PRESETS[chain_input]
        parts = [p.strip() for p in chain_input.split(",") if p.strip()]
        return [_resolve_adhd_chain(p, scale, bpm, voice)[0] if p in ADHD_PRESETS else p for p in parts] or DEFAULT_ADHD_CHAIN
    if isinstance(chain_input, list):
        if len(chain_input) == 1 and chain_input[0] in ADHD_PRESETS:
            return ADHD_PRESETS[chain_input[0]]
        resolved = []
        for item in chain_input:
            if item in ADHD_PRESETS:
                resolved.extend(ADHD_PRESETS[item])
            else:
                resolved.append(item)
        return resolved or DEFAULT_ADHD_CHAIN
    return DEFAULT_ADHD_CHAIN


def _get_cmu():
    return load_cmudict(CMU_PATH) if CMU_PATH.exists() else {}


def _get_voice_dna():
    dna_path = OUT / "artist_voice_dna.json"
    if dna_path.exists():
        try:
            return json.loads(dna_path.read_text(encoding="utf-8"))
        except Exception:
            return {}
    return {}


def get_artist_bag_metrics(voice: str = "Gunna", scale: str = "F minor", bpm: float = 130.0) -> dict:
    """Load empirical multi-bag metrics conditioned on musical key, scale, and tempo."""
    metrics_path = OUT / "artist_multibag_metrics.json"
    data = {}
    if metrics_path.exists():
        try:
            data = json.loads(metrics_path.read_text(encoding="utf-8"))
        except Exception:
            pass

    is_minor = "minor" in (scale or "").lower()
    scale_key = "minor" if is_minor else "major"
    tempo_key = "fast_double_time" if bpm >= 140 else ("slow_soulful" if bpm < 120 else "mid_trap")

    global_dist = data.get("global_bag_distribution_pct", {
        "luxury_drip": 73.02,
        "fast_pocket": 17.63,
        "punchlines_metaphors": 5.05,
        "faith_hope": 1.94,
        "pain_ditch_betrayal": 1.28,
        "melodic_flow": 1.07,
    })
    scale_dist = data.get("scale_conditioned_distribution_pct", {}).get(scale_key, global_dist)
    tempo_dist = data.get("tempo_conditioned_distribution_pct", {}).get(tempo_key, global_dist)

    return {
        "artist": voice,
        "scale": scale,
        "scale_mode": scale_key,
        "bpm": bpm,
        "tempo_tier": tempo_key,
        "global_bag_distribution_pct": global_dist,
        "scale_conditioned_distribution_pct": scale_dist,
        "tempo_conditioned_distribution_pct": tempo_dist,
        "average_adhd_transition_velocity": data.get("average_adhd_transition_velocity", 0.362),
        "total_songs_measured": data.get("total_songs_measured", 721),
        "total_bars_measured": data.get("total_bars_measured", 32492),
    }


def count_cmu_syllables(phrase: str, cmu: dict) -> int:
    """Accurately count syllables using CMU pronouncing dictionary with phoneme stress, falling back to regex."""
    toks = tokenize(normalize(phrase))
    if not toks:
        return 0
    total = 0
    for t in toks:
        entry = cmu.get(t)
        if entry:
            v_cnt = len([p for p in entry if any(char.isdigit() for char in p)])
            total += max(1, v_cnt)
        else:
            total += estimate_syllables(t)
    return total


def parse_beat_groups(line: str, cmu: dict) -> dict:
    """Parse a line into exactly 4 balanced beat groups (Audamar / Lobster Quadrasonic 4x4 Grid),

    eliminating hallucinated single-word orphan tokens, stripping inline duplicate rhymes,
    and balancing overloaded clauses into four substantive 3-to-6 syllable beats.
    """
    import re

    clean_line = line.strip().strip("\"'`").rstrip(",;.")

    # 0. Clean hallucinated inline duplicate rhyme echoes like 'reveal deal' -> 'reveal', 'glow though' -> 'glow'
    clean_line = re.sub(r"\b(reveal)\s+deal\b", r"\1", clean_line, flags=re.I)
    clean_line = re.sub(r"\b(heal)\s*,\s*steel\b", r"\1", clean_line, flags=re.I)
    clean_line = re.sub(r"\b(flow)\s*,\s*glow\b", r"\1", clean_line, flags=re.I)
    clean_line = re.sub(r"\b(low)\s+though\b", r"\1", clean_line, flags=re.I)

    raw_groups = [p.strip() for p in clean_line.split(",") if p.strip()]
    if not raw_groups:
        return {
            "groups": ["", "", "", ""],
            "beat_syllables": [0, 0, 0, 0],
            "total_syllables": 0,
            "is_quadrasonic": False,
            "setup": "",
            "punchline": "",
            "quad_formatted": "",
        }

    # Filter or strip known hallucinated 1-word rhyme tags at the start or end
    hallucinated_tags = {
        "measure", "slight", "light", "steel", "deal", "glow", "though",
        "said", "rich", "yeah", "uh", "right", "show", "aye", "yo",
    }

    cleaned_parts = []
    for i, p in enumerate(raw_groups):
        words = p.split()
        if len(words) == 1 and words[0].lower() in hallucinated_tags:
            if i == len(raw_groups) - 1 and len(raw_groups) >= 4:
                continue
        if len(words) > 2 and words[0].lower() in {"pressure", "treasure", "right", "show"}:
            words = words[1:]
            p = " ".join(words)
        cleaned_parts.append(p)

    parts = [p for p in cleaned_parts if p.strip()]
    if not parts:
        parts = [clean_line]

    # 1. Merge short 1-word or <=2 syllable fragments with neighbors
    merged = []
    i = 0
    while i < len(parts):
        p = parts[i]
        words = p.split()
        syl = count_cmu_syllables(p, cmu)
        if (len(words) <= 1 or syl <= 2) and i + 1 < len(parts):
            merged.append(p + " " + parts[i + 1])
            i += 2
        elif (len(words) <= 1 or syl <= 2) and merged:
            merged[-1] = merged[-1] + " " + p
            i += 1
        else:
            merged.append(p)
            i += 1

    # If the last two groups are short (each <= 3 syllables, total <= 7 syllables), merge them as landing punchline
    if len(merged) >= 4 and count_cmu_syllables(merged[-1], cmu) <= 3 and count_cmu_syllables(merged[-2], cmu) <= 3:
        merged[-2] = merged[-2] + " " + merged[-1]
        merged.pop()

    # 2. If fewer than 4 groups, split the group with the most syllables / words
    while len(merged) < 4:
        syls = [count_cmu_syllables(m, cmu) for m in merged]
        max_idx = syls.index(max(syls))
        w = merged[max_idx].split()
        if len(w) >= 2:
            mid = len(w) // 2
            p_a = " ".join(w[:mid])
            p_b = " ".join(w[mid:])
            merged = merged[:max_idx] + [p_a, p_b] + merged[max_idx + 1 :]
        else:
            merged.append("")

    # 3. If more than 4 groups, merge shortest adjacent
    while len(merged) > 4:
        min_sum = 999
        min_i = 0
        for j in range(len(merged) - 1):
            s = count_cmu_syllables(merged[j], cmu) + count_cmu_syllables(merged[j + 1], cmu)
            if s < min_sum:
                min_sum = s
                min_i = j
        merged = merged[:min_i] + [merged[min_i] + " " + merged[min_i + 1]] + merged[min_i + 2 :]

    # 4. Syllable rebalancing check across beats 1 and 2
    if len(merged) >= 2:
        w0 = merged[0].split()
        if count_cmu_syllables(merged[0], cmu) >= 8 and len(w0) >= 4 and count_cmu_syllables(merged[1], cmu) <= 4:
            shift_cnt = max(1, len(w0) // 3)
            merged[1] = " ".join(w0[-shift_cnt:]) + " " + merged[1]
            merged[0] = " ".join(w0[:-shift_cnt])

    groups = [m.strip() for m in merged[:4]]
    is_quad = len(groups) == 4 and all(bool(g) for g in groups)

    beat_syllables = [count_cmu_syllables(g, cmu) if g else 0 for g in groups]
    total_syl = sum(beat_syllables)
    setup = ", ".join(groups[:2]) if len(groups) >= 2 else clean_line
    punchline = ", ".join(groups[2:]) if len(groups) >= 4 else ""
    return {
        "groups": groups,
        "beat_syllables": beat_syllables,
        "total_syllables": total_syl,
        "is_quadrasonic": is_quad,
        "setup": setup,
        "punchline": punchline,
        "quad_formatted": ", ".join(groups) if is_quad else clean_line,
    }


def verify_grid_landings(
    bars: list[dict | str],
    bpm: float = 130.0,
    effective_syl: int = 20,
    cmu: dict = None,
) -> dict:
    """Verify that each bar strictly lands on the 4-beat Audamar/Lobster 4x4 Grid.

    Grid Criteria:
      - Line must be divided into exactly 4 comma-separated beat phrases.
      - Each beat phrase must have target syllables within [target_min, target_max],
        where target_beat_syl = effective_syl / 4.0, target_min = floor(target_beat_syl) - 1,
        and target_max = ceil(target_beat_syl) + 1.
      - A bar fails if >= 2 beats fall outside this ±1 margin or if the line lacks 4 beats.

    Returns a dict with overall status, pass_rate, target ranges, and detailed per-bar diagnostics.
    """
    import math

    if cmu is None:
        cmu = _get_cmu()

    eff = effective_syl if (effective_syl and effective_syl > 0) else 20
    target_beat_syl = eff / 4.0
    target_min = max(1, int(math.floor(target_beat_syl) - 1))
    target_max = int(math.ceil(target_beat_syl) + 1)

    bar_results = []
    failed_indices = []

    for idx, b in enumerate(bars):
        if isinstance(b, dict):
            text = b.get("quad_formatted") or b.get("text") or b.get("raw_text") or ""
            end_word = b.get("end_word") or ""
        else:
            text = str(b or "")
            end_word = ""

        clean_line = text.strip().strip("\"'`").rstrip(",;.")
        raw_parts = [p.strip() for p in clean_line.split(",") if p.strip()]

        if not end_word:
            toks = tokenize(normalize(clean_line))
            end_word = toks[-1] if toks else ""

        beat_syllables = [count_cmu_syllables(p, cmu) for p in raw_parts]

        violations = []
        for k in range(4):
            if k < len(raw_parts):
                s = beat_syllables[k]
                if s < target_min or s > target_max:
                    violations.append({
                        "beat": k + 1,
                        "phrase": raw_parts[k],
                        "actual_syl": s,
                        "target_min": target_min,
                        "target_max": target_max,
                    })
            else:
                violations.append({
                    "beat": k + 1,
                    "phrase": "",
                    "actual_syl": 0,
                    "target_min": target_min,
                    "target_max": target_max,
                })

        if len(raw_parts) > 4:
            for k in range(4, len(raw_parts)):
                violations.append({
                    "beat": k + 1,
                    "phrase": raw_parts[k],
                    "actual_syl": beat_syllables[k],
                    "target_min": target_min,
                    "target_max": target_max,
                })

        bar_passed = (len(violations) < 2) and (len(raw_parts) == 4)

        if violations:
            viol_items = [
                f"Beat {v['beat']} was {v['actual_syl']} syl (target {v['target_min']}-{v['target_max']})"
                for v in violations
            ]
            if len(raw_parts) != 4:
                violation_desc = f"Line has {len(raw_parts)} phrases instead of exactly 4 beats; {'; '.join(viol_items)}"
            else:
                violation_desc = "; ".join(viol_items)
        else:
            violation_desc = "On-grid"

        bar_info = {
            "index": idx + 1,
            "text": text,
            "end_word": end_word,
            "phrase_count": len(raw_parts),
            "beat_phrases": raw_parts,
            "beat_syllables": beat_syllables,
            "off_grid_beats": violations,
            "violation_count": len(violations),
            "passed": bar_passed,
            "violation_desc": violation_desc,
        }
        bar_results.append(bar_info)

        if not bar_passed:
            failed_indices.append(idx)

    passed_count = sum(1 for r in bar_results if r["passed"])
    pass_rate = round(passed_count / len(bar_results), 3) if bar_results else 1.0

    return {
        "passed": len(failed_indices) == 0,
        "pass_rate": pass_rate,
        "total_bars": len(bar_results),
        "passed_bars": passed_count,
        "failed_bars": len(failed_indices),
        "failed_indices": failed_indices,
        "target_beat_range": (target_min, target_max),
        "target_beat_syl": target_beat_syl,
        "effective_syl": eff,
        "bpm": bpm,
        "bar_results": bar_results,
    }


def rewrite_off_grid_bar(
    bar_text: str,
    target_word: str,
    violation_desc: str,
    target_min: int,
    target_max: int,
    effective_syl: int,
    cmu: dict = None,
    voice: str = "Gunna",
    source_catalog_text: str = "",
    call_fn: callable = None,
) -> tuple[str, bool]:
    """Targeted single-bar rewrite to bring an off-grid bar onto the 4x4 Quadrasonic grid.

    Enforces:
      1. Exactly 3 commas (4 substantive beat phrases).
      2. Each beat phrase between target_min and target_max syllables.
      3. Strict preservation of target_word at the end of Beat 4.

    Returns (rewritten_line, passed_grid).
    """
    import re

    if cmu is None:
        cmu = _get_cmu()

    clean_target = (target_word or "").strip().lower()
    clean_target = re.sub(r"[^a-zA-Z0-9']", "", clean_target)

    system_prompt = (
        f"You are a master rap lyric engineer specializing in {voice}'s rhythm and the Audamar/Lobster 4x4 Quadrasonic meter.\n"
        f"Your task is to rewrite a single failing bar so that it strictly obeys the 4-beat syllable grid while strictly preserving the assigned catalog landing rhyme.\n\n"
        f"MANDATORY CADENCE FORMULA (EXACTLY 3 COMMAS):\n"
        f"Phrase 1 (Setup A, {target_min}-{target_max}s), Phrase 2 (Rhyme A, {target_min}-{target_max}s), Phrase 3 (Kinetic Turn, {target_min}-{target_max}s), Phrase 4 (Punchline on '{clean_target}', {target_min}-{target_max}s)\n"
        f"Total line syllables must be ~{effective_syl}. NEVER omit commas. NEVER drop '{clean_target}'."
    )

    user_prompt = (
        f"REWRITE INSTRUCTION FOR OFF-GRID BAR:\n"
        f"Current failing bar: \"{bar_text}\"\n"
        f"Grid violation detected: {violation_desc}\n"
    )
    if source_catalog_text:
        user_prompt += f"Authentic catalog context: \"{source_catalog_text}\"\n"
    user_prompt += (
        f"Target beat range: {target_min} to {target_max} syllables per beat (total ~{effective_syl} syllables)\n"
        f"Preserved end-word: '{clean_target}' (MUST be the final word in Beat 4)\n\n"
        f"Return ONLY the rewritten single line with exactly 3 commas. No quotes, no explanations, no bar labels."
    )

    candidate_text = ""
    if call_fn is not None:
        try:
            candidate_text = call_fn(system_prompt, user_prompt)
        except Exception as exc:
            print(f"[rewrite_off_grid_bar] call_fn error: {exc}", file=sys.stderr)
    else:
        CANDIDATE_MODELS = [
            os.environ.get("V4_REWRITE_MODEL", "claude-sonnet-5-5"),
            "claude-3-5-sonnet-20241022",
            "gpt-4o-mini",
            "gpt-4o",
        ]
        for model_name in CANDIDATE_MODELS:
            try:
                content = chat(
                    model=model_name,
                    system=system_prompt,
                    user=user_prompt,
                    temperature=0.65,
                    max_tokens=120,
                )
                if content and content.strip():
                    candidate_text = content.strip()
                    break
            except Exception as exc:
                continue

    if not candidate_text:
        return bar_text, False

    lines = [l.strip() for l in candidate_text.splitlines() if l.strip()]
    candidate_line = ""
    for l in lines:
        l_clean = re.sub(r"^(?:Bar\s*\d+[\s:.-]*|\d+[\s:.-]+)", "", l, flags=re.IGNORECASE).strip().strip("\"'")
        if l_clean and not l_clean.startswith("[") and not l_clean.startswith("```"):
            candidate_line = l_clean
            break

    if not candidate_line:
        return bar_text, False

    toks = tokenize(normalize(candidate_line))
    if clean_target and (not toks or toks[-1].lower() != clean_target.lower()):
        parts = [p.strip() for p in candidate_line.split(",") if p.strip()]
        if len(parts) >= 4:
            b4_words = parts[3].split()
            if len(b4_words) >= 2:
                parts[3] = " ".join(b4_words[:-1]) + " " + clean_target
            else:
                parts[3] = f"with the {clean_target}"
            candidate_line = ", ".join(parts[:4])
        else:
            candidate_line = f"{candidate_line.rstrip(',;.')} {clean_target}"

    check = verify_grid_landings([candidate_line], effective_syl=effective_syl, cmu=cmu)
    passed = check["passed"]
    return candidate_line, passed


def check_rhyme_quality(w1: str, w2: str, cmu: dict) -> str:
    """Returns 'pure', 'slant', or 'none' based on CMU phoneme stress and coda."""
    if not w1 or not w2:
        return "none"
    if w1.lower() == w2.lower():
        return "repetition"
    r1 = end_rime(w1.lower(), cmu) if cmu else None
    r2 = end_rime(w2.lower(), cmu) if cmu else None
    if r1 and r2:
        if r1 == r2:
            return "pure"
        if r1[0] == r2[0]:
            return "slant"
    if len(w1) >= 3 and len(w2) >= 3:
        if w1.lower().endswith(w2.lower()[-3:]) or w2.lower().endswith(w1.lower()[-3:]):
            return "slant"
    return "none"


def get_artist_catalog_rhymes(voice: str, dna: dict) -> dict:
    """Extract authentic catalog rhyme pairs, signature phrases, and double-meaning words."""
    artists_map = dna.get("artists") or {}
    v_clean = voice.strip()
    entry = artists_map.get(v_clean)
    if not entry:
        # Fallback case-insensitive match
        for k, v in artists_map.items():
            if k.lower() == v_clean.lower():
                entry = v
                break
    if not entry:
        entry = artists_map.get("Gunna") or {}

    top_ends = [e.get("word") for e in (entry.get("top_end_words") or []) if e.get("word") and e.get("word").lower() not in ("gunna", "drake", "wayne", "nocap", "thug")]
    rhyme_pairs = entry.get("rhyme_pairs") or {}
    phrases = [p.get("phrase") for p in (entry.get("signature_phrases") or []) if p.get("phrase")]
    double_words = entry.get("double_meaning_words") or []

    # Curate top pairs
    curated_pairs = []
    for k, v in list(rhyme_pairs.items())[:12]:
        if v and isinstance(v, list):
            curated_pairs.append(f"{k} -> {', '.join(v[:4])}")

    return {
        "artist": v_clean,
        "top_end_words": top_ends[:15],
        "rhyme_pairs": curated_pairs[:8],
        "phrases": phrases[:8],
        "double_words": double_words[:10],
    }


GENERIC_END_RHYME_BLACKLIST = {
    # Absolute user-prohibited generic words
    "real", "cake", "slide",
    # Overly simple nursery-rhyme monosyllables
    "plate", "date", "gate", "late", "wait", "lake", "make", "take", "brake",
    "back", "trap", "cash", "bag", "man", "can", "day", "way", "play", "say",
    "go", "know", "so", "no", "glow", "flow", "show", "low",
    "tight", "night", "fight", "light", "right", "sight",
    "mind", "grind", "find", "kind", "soul", "toll", "cold", "mold", "hold", "told",
    "pain", "rain", "main", "sane", "game", "fame", "name", "same",
    "yeah", "uh", "it", "me", "you", "one", "two", "baby", "boy", "girl", "time", "too", "do",
}

ARTIST_CATALOG_RHYME_BANKS = {
    "Gunna": [
        {"pair": ("mercedes", "crazy"), "family": "-ay-deez", "theme": "Luxury Drip & Motion", "bag": "luxury_drip"},
        {"pair": ("overseas", "knees"), "family": "-eez", "theme": "Global Travel & Gratitude", "bag": "faith_hope"},
        {"pair": ("stylist", "polished"), "family": "-i-ist", "theme": "Designer Fashion & Drip", "bag": "luxury_drip"},
        {"pair": ("audi", "rowdy"), "family": "-ow-dee", "theme": "Fast Cars & Street Pace", "bag": "fast_pocket"},
        {"pair": ("deposit", "wallet"), "family": "-o-zit", "theme": "Banking & Wealth", "bag": "luxury_drip"},
        {"pair": ("pocket", "topic"), "family": "-o-kit", "theme": "Status & Industry Conversation", "bag": "punchlines_metaphors"},
        {"pair": ("bottles", "model"), "family": "-o-tulz", "theme": "VIP Lifestyle & Women", "bag": "luxury_drip"},
        {"pair": ("buckle", "duffle"), "family": "-uh-kul", "theme": "Cash Stashes & Designer Bags", "bag": "luxury_drip"},
        {"pair": ("celine", "listerine"), "family": "-een", "theme": "Immaculate Clean Drip", "bag": "luxury_drip"},
        {"pair": ("maybach", "payback"), "family": "-ay-back", "theme": "Redemption & Vindication", "bag": "pain_ditch_betrayal"},
        {"pair": ("patek", "static"), "family": "-at-ik", "theme": "Watch Jewelry & Defiance", "bag": "punchlines_metaphors"},
        {"pair": ("collar", "dollar"), "family": "-ol-er", "theme": "Designer Suits & Earnings", "bag": "luxury_drip"},
        {"pair": ("sweater", "better"), "family": "-et-er", "theme": "Elevated Living & Status", "bag": "luxury_drip"},
        {"pair": ("building", "ceiling"), "family": "-il-ding", "theme": "Penthouse Architecture & Growth", "bag": "luxury_drip"},
        {"pair": ("cullinan", "million"), "family": "-il-yun", "theme": "Rolls Royce Luxury", "bag": "luxury_drip"},
    ],
    "NoCap": [
        {"pair": ("guitar", "rockstar"), "family": "-ar", "theme": "Acoustic Pain & Fame", "bag": "pain_ditch_betrayal"},
        {"pair": ("karma", "normal"), "family": "-ar-muh", "theme": "Consequences & Street Reality", "bag": "pain_ditch_betrayal"},
        {"pair": ("dirty", "worried"), "family": "-er-tee", "theme": "Street Paranoia & Trench Trauma", "bag": "pain_ditch_betrayal"},
        {"pair": ("sober", "soldier"), "family": "-oh-ber", "theme": "Substances & Street Warfare", "bag": "pain_ditch_betrayal"},
        {"pair": ("permanently", "urgently"), "family": "-ent-lee", "theme": "Lasting Scars & Urgency", "bag": "pain_ditch_betrayal"},
        {"pair": ("prescription", "description"), "family": "-ip-shun", "theme": "Numbing Pain & Medical Metaphor", "bag": "punchlines_metaphors"},
        {"pair": ("penitentiary", "elementary"), "family": "-en-shuh-ree", "theme": "Youth vs Incarceration", "bag": "pain_ditch_betrayal"},
        {"pair": ("confidential", "residential"), "family": "-en-shul", "theme": "Secrets & Moving Away", "bag": "punchlines_metaphors"},
        {"pair": ("paranoia", "lawyer"), "family": "-oy-uh", "theme": "Legal Battles & Looking Back", "bag": "pain_ditch_betrayal"},
        {"pair": ("cemetery", "military"), "family": "-er-ee", "theme": "Lost Brothers & War", "bag": "pain_ditch_betrayal"},
        {"pair": ("memories", "enemies"), "family": "-em-er-eez", "theme": "Past Dawgs & Betrayal", "bag": "pain_ditch_betrayal"},
        {"pair": ("resurrect", "disconnect"), "family": "-ekt", "theme": "Rising from the Ditch & Detachment", "bag": "faith_hope"},
        {"pair": ("guarantee", "warranty"), "family": "-an-tee", "theme": "Fake Promises & Life Expiration", "bag": "punchlines_metaphors"},
        {"pair": ("sanctuary", "obituary"), "family": "-er-ee", "theme": "Church Refuge & Death", "bag": "faith_hope"},
    ],
    "Drake": [
        {"pair": ("over", "sober"), "family": "-oh-ver", "theme": "Late Night Introspection", "bag": "melodic_flow"},
        {"pair": ("alone", "phone"), "family": "-ohn", "theme": "Unanswered Calls & Solitude", "bag": "melodic_flow"},
        {"pair": ("diplomatic", "problematic"), "family": "-at-ik", "theme": "Industry Politics & Tensions", "bag": "punchlines_metaphors"},
        {"pair": ("conversation", "hesitation"), "family": "-ay-shun", "theme": "Relationship Directness", "bag": "melodic_flow"},
        {"pair": ("situation", "celebration"), "family": "-ay-shun", "theme": "Overcoming Obstacles", "bag": "luxury_drip"},
        {"pair": ("unapologetic", "sympathetic"), "family": "-et-ik", "theme": "Success Without Regrets", "bag": "punchlines_metaphors"},
        {"pair": ("silhouette", "cigarette"), "family": "-et", "theme": "Moody Visual Ambience", "bag": "melodic_flow"},
        {"pair": ("calabasas", "passes"), "family": "-as-uz", "theme": "Gated Wealth & Access", "bag": "luxury_drip"},
        {"pair": ("reminiscing", "missing"), "family": "-is-ing", "theme": "Nostalgia & What Could Have Been", "bag": "melodic_flow"},
        {"pair": ("sacrifices", "prices"), "family": "-is-ez", "theme": "The Cost of Greatness", "bag": "punchlines_metaphors"},
        {"pair": ("overthinking", "drinking"), "family": "-ink-ing", "theme": "Late Night Studio Headspace", "bag": "melodic_flow"},
        {"pair": ("therapeutic", "music"), "family": "-yoo-tik", "theme": "Catharsis & The Craft", "bag": "faith_hope"},
    ],
    "Lil Wayne": [
        {"pair": ("forever", "together"), "family": "-ev-er", "theme": "Loyalty & Longevity", "bag": "faith_hope"},
        {"pair": ("spark", "shark"), "family": "-ark", "theme": "Fire in the Booth & Street Sharks", "bag": "punchlines_metaphors"},
        {"pair": ("night", "light"), "family": "-ite", "theme": "Late Night Hustle & Shining Bright", "bag": "punchlines_metaphors"},
        {"pair": ("pharmaceutical", "beautiful"), "family": "-yoo-tik-ul", "theme": "Surreal Syzurp Metaphors", "bag": "punchlines_metaphors"},
        {"pair": ("oxygen", "toxic"), "family": "-ik-sun", "theme": "Suffocating Competition", "bag": "punchlines_metaphors"},
        {"pair": ("extraordinary", "dictionary"), "family": "-ar-ee", "theme": "Lyrical Dominance & Vocabulary", "bag": "punchlines_metaphors"},
        {"pair": ("coronary", "cemetery"), "family": "-ar-ee", "theme": "Heart Stopping Bars", "bag": "punchlines_metaphors"},
        {"pair": ("parliamentary", "elementary"), "family": "-en-tuh-ree", "theme": "Advanced Flow vs Beginners", "bag": "punchlines_metaphors"},
        {"pair": ("millionaire", "billionaire"), "family": "-air", "theme": "Generational Mogul Status", "bag": "luxury_drip"},
        {"pair": ("caterpillar", "gorilla"), "family": "-il-er", "theme": "Metamorphic Beast Mode", "bag": "punchlines_metaphors"},
    ],
    "Lil Baby": [
        {"pair": ("mercedes", "crazy"), "family": "-ay-zee", "theme": "Rapid Rise & Luxury Speed", "bag": "luxury_drip"},
        {"pair": ("forever", "together"), "family": "-ev-er", "theme": "Brotherhood & Day Ones", "bag": "faith_hope"},
        {"pair": ("probation", "situation"), "family": "-ay-shun", "theme": "Legal Struggles & Moving Up", "bag": "pain_ditch_betrayal"},
        {"pair": ("location", "vacation"), "family": "-ay-shun", "theme": "Out of the Trenches", "bag": "luxury_drip"},
        {"pair": ("statement", "basement"), "family": "-ayt-ment", "theme": "Loyalty & Street Codes", "bag": "punchlines_metaphors"},
        {"pair": ("invest", "progress"), "family": "-est", "theme": "Business Moves & Portfolio", "bag": "luxury_drip"},
        {"pair": ("million", "civilian"), "family": "-il-yun", "theme": "Wealth vs Average Talk", "bag": "luxury_drip"},
    ],
    "Young Thug": [
        {"pair": ("hellcat", "slatt"), "family": "-at", "theme": "SRT Speed & Slime Mob", "bag": "fast_pocket"},
        {"pair": ("midol", "tylenol"), "family": "-ol", "theme": "Prescription Pain Relief", "bag": "punchlines_metaphors"},
        {"pair": ("python", "tight on"), "family": "-on", "theme": "Exotic Leather Drip", "bag": "luxury_drip"},
        {"pair": ("rebellious", "tell us"), "family": "-el-ee-us", "theme": "Anti-Authority Swagger", "bag": "punchlines_metaphors"},
        {"pair": ("chanel", "yell"), "family": "-el", "theme": "High Fashion Shouting", "bag": "luxury_drip"},
        {"pair": ("balenciaga", "prada"), "family": "-ah-duh", "theme": "Runway Dripping", "bag": "luxury_drip"},
    ],
}


def build_v2_system_prompt(
    voice: str,
    blend: str = "",
    mix: int = 70,
    bpm: float = 130.0,
    scale: str = "F minor",
    target_syl: int = 12,
    section_mode: str = "verse",
    rhyme_technique: str = "balanced",
    adhd_chain: list[str] = None,
    bars_count: int = 8,
    dna: dict = None,
    taste_on: bool = True,
    taste_k: int = 6,
    store: Any = None,
) -> str:
    """Construct the comprehensive V3 Frontier Ghostwriter system prompt with catalog DNA, multi-bag depth, ADHD motif jumps, and rater taste feedback blocks."""
    if dna is None:
        dna = _get_voice_dna()

    v_catalog = get_artist_catalog_rhymes(voice, dna)
    b_catalog = get_artist_catalog_rhymes(blend, dna) if blend else None

    # Query taste signals from feedback store (Task B': keeper bars + avoid reasons)
    keeper_block, avoid_block = (None, None)
    if taste_on and build_taste_prompt_blocks is not None:
        try:
            keeper_block, avoid_block = build_taste_prompt_blocks(
                artist=voice,
                store=store,
                k_bars=taste_k,
                k_reasons=4,
                taste_on=taste_on,
            )
        except Exception:
            keeper_block, avoid_block = (None, None)

    taste_parts = []
    if keeper_block:
        taste_parts.append(keeper_block)
    if avoid_block:
        taste_parts.append(avoid_block)
    taste_section = ""
    if taste_parts:
        taste_section = "\n=== 7. RATER TASTE SIGNALS (HUMAN RATINGS FEEDBACK LOOP) ===\n" + "\n\n".join(taste_parts) + "\n"

    # Motif progression mapping with rhyme anchors
    chain = _resolve_adhd_chain(adhd_chain, scale=scale, bpm=bpm, voice=voice)
    couplet_count = max(1, bars_count // 2)
    motif_schedule = []
    catalog_banks = ARTIST_CATALOG_RHYME_BANKS.get(voice) or ARTIST_CATALOG_RHYME_BANKS.get("Gunna")

    for c_idx in range(couplet_count):
        motif_key = chain[c_idx % len(chain)]
        motif_info = MOTIF_DEFINITIONS.get(motif_key, MOTIF_DEFINITIONS["lavishness_money"])
        c_bank = catalog_banks[c_idx % len(catalog_banks)]
        p1, p2 = c_bank["pair"]
        motif_schedule.append(
            f"Couplet {c_idx + 1} (Bars {c_idx * 2 + 1}-{c_idx * 2 + 2}): [{motif_info['title']} - {c_bank['theme']}]\n"
            f"  - Theme: {motif_info['description']}\n"
            f"  - Mandatory Catalog End-Rhymes: Bar {c_idx * 2 + 1} ends on '{p1}', Bar {c_idx * 2 + 2} ends on '{p2}' (Family: {c_bank['family']})"
        )

    motif_text = "\n\n".join(motif_schedule)

    # Technique guidance
    tech_guide = ""
    if rhyme_technique == "inner_density":
        tech_guide = "MAXIMUM INNER-RHYME DENSITY: Pack internal assonance, multi-syllabic mid-bar rhymes, and tight vowel chaining into every bar."
    elif rhyme_technique == "outer_uniqueness":
        tech_guide = "OUTER-RHYME UNIQUENESS & PUNCHLINES: Prioritize unexpected, multi-syllabic end-rhymes (e.g. 3-4 syllable slant rhymes) with sharp punchline landings."
    else:
        tech_guide = "BALANCED STUDIO FLOW: Seamless combination of melodic cadence, tight couplet end-rhymes, and conversational swagger."

    # V3 Multisyllabic stacks
    import v3_rhyme_stack
    from hook_engine import build_section_system_prompt_block, get_section_cadence_rules
    section_rules = get_section_cadence_rules(section_mode)
    section_blueprint = build_section_system_prompt_block(section_mode, voice=voice)
    m_stacks_text = v3_rhyme_stack.get_artist_multisyllabic_prompts(voice)

    is_minor = "minor" in (scale or "").lower()
    musical_mood = "Dark, poignant, reflective soul, betrayal & spiritual prayer" if is_minor else "Uplifting, triumphant, radiant melodic float & gratitude"

    prompt = f"""You are Penwork Studios' Platinum Executive Ghostwriter (Model: Frontier Ghostwriter V3).
You craft authentic, commercially competitive rap lyrics engineered for real beat placement and studio recording.

=== 1. ARTIST PERSONA & MUSICAL CONTEXT ===
- Primary Artist: {voice}
{f'- Blended Voice: {blend} ({mix}% {voice} / {100-mix}% {blend})' if blend else ''}
- Musical Scale: {scale} ({musical_mood})
- Target Tempo: {bpm} BPM | Target Syllable Pocket: {target_syl} syllables per bar.
- Section Mode: {section_mode.upper()} ({section_rules['meter_desc']}).
- Technique: {tech_guide}

=== 2. GUNNA MULTI-BAG COMPLEXITY & THEMATIC DEPTH ===
If Gunna is the primary or blended artist:
DO NOT reduce Gunna to a flat 'drip & luxury' stereotype.
Gunna is a complex, versatile artist who moves across 6 distinct cardinal bags:
1. Religious Faith & Spiritual Hope: Praying on his knees, gratitude to God, seeking redemption, church, divine armor against enemies.
2. In The Ditch, Pain & Betrayal: Snitch allegations, fake friends turning their backs ('think he the one, but he really the two'), prison isolation, rising from the ditch.
3. Luxury Drip & Effortless Wealth: Maybach, Patek, Celine, effortless nonchalant swagger.
4. Slick Numerical Metaphors & Punchlines: Witty street/finance wordplay, chess analogies, double meanings.
5. Melodic Float & Triplet Cadence: Smooth vocal pockets, atmospheric vowel chains.
6. Fast-Paced Relentless Pocket: High-cadence double-time runs when the beat accelerates.
You MUST blend these bags across the couplets according to the song's musical scale ({scale}) and BPM ({bpm}).

{section_blueprint}

=== 4. ADHD MOTIF PROGRESSION & ASSIGNED COUPLET RHYMES ===
Rappers in modern trap pivot topics every 2 bars. Follow this exact schedule:
{motif_text}

=== 4. STRICT PROHIBITION ON GENERIC / NURSERY-RHYME END WORDS ===
The user and studio executives strictly FORBID amateur, nursery-rhyme end words.
NEVER end ANY line on any of the following generic or childish monosyllables:
• FORBIDDEN: real, cake, slide, plate, date, gate, late, wait, lake, make, take, brake
• FORBIDDEN: back, trap, cash, bag, man, can, day, way, play, say
• FORBIDDEN: go, know, so, no, glow, flow, show, low
• FORBIDDEN: tight, night, fight, light, right, sight
• FORBIDDEN: mind, grind, find, kind, soul, toll, cold, mold, hold, told
• FORBIDDEN: pain, rain, main, sane, game, fame, name, same
• FORBIDDEN: yeah, uh, it, me, you, one, two, baby, boy, girl, time, too, do

MANDATORY CATALOG END-RHYMES ONLY:
Every couplet end-rhyme MUST strictly use the artist's real catalog rhyme pair or multi-syllabic slant stack.

=== 5. V3 MULTISYLLABIC SLANT-RHYME STACKS (M-SRS) ===
{m_stacks_text}

CRITICAL COMPOUND RHYME RULE:
Do NOT settle for juvenile monosyllabic nursery rhymes (like cash/back or ride/vibe).
Craft compound 2-syllable, 3-syllable, or 4-syllable slant-rhyme stacks where the last 2 to 4 syllables match in vowel assonance across Beat 3 and Beat 4 (e.g. 'stacking up the paper' / 'acting like a hater', 'pocket full of franklins' / 'rock it with no ankles', 'diamonds on the bezel' / 'higher on the level').

=== 6. AUTHENTIC VOCABULARY & SLANG ===
Target artist signature vocabulary:
- Top End-Rhymes: {', '.join(v_catalog['top_end_words'])}
- Preferred Catalog Rhyme Pairs: {'; '.join(v_catalog['rhyme_pairs'])}
- Signature Slang & Phrases: {', '.join(v_catalog['phrases'])}
{f"- Secondary Blend Vocabulary ({blend}): {', '.join(b_catalog['top_end_words'][:8])}" if b_catalog else ''}

=== 6B. NO-CAP HOMOPHONE / WORDPLAY ENGINE ===
Whenever NoCap is selected or blended:
- Weave in brilliant homophones and double meanings (e.g. steel/steal, piece/peace, plain/plane, cell/sell, rows/rose, knight/night, bank/chase).
- Ensure the setup naturally activates both senses.
{taste_section}
=== 8. STRICT GENERATION RULES ===
1. Exact Bar Count: Output EXACTLY {bars_count} lines of lyrics, one bar per line.
2. Comma-Segmented Cadence: EVERY single line MUST have about 4 COMMAS (4 to 5 distinct comma-delimited pockets).
3. Sustained 4-5 Syllable Pockets: Each comma segment MUST be 4 to 5 syllables. If you start with 4 or 5 syllables per comma, CONTINUE that exact count across the entire line (e.g. 4+4+4+4 or 5+5+5+5). Never jump erratically between long and short clauses!
4. ABAB Inner Rhyme Level:
   - Segment 1 ends on Rhyme A,
   - Segment 2 ends on Rhyme B,
   - Segment 3 ends on Rhyme A (rhymes with Segment 1),
   - Segment 4 ends on Rhyme B (rhymes with Segment 2 and lands on designated end-word).
5. User Gold Benchmarks to Emulate (Target Pocket Pacing & Rhyme Craft):
   - 'on the block, stackin' them knots, pushin' the weight, in the mercedes' (3s, 5s, 4s, 5s)
   - 'drilling these streets, fearless with moves, watch is two tone, man it go crazy' (5s, 5s, 4s, 5s)
   - 'stackin' some chips, fliping the script, in it then dip, fly overseas' (5s, 5s, 4s, 4s)
   - 'im on my grind, standin' so tall, against the odds, wont drop to my knees' (4s, 5s, 4s, 5s)
   - 'rollin 10 deep, tinted and creep, aint catching no sleep, audi it beeps' (4s, 5s, 5s, 4s)
   - 'open' the roof, im catching a breeze, blessings surround, im blessed when i sneeze' (4s, 5s, 4s, 5s)
   - Gunna: 'Stackin' the cash, ridin' the wave, grabbin' the bag, diggin' the grave' (4s, 4s, 4s, 4s | ABAB)
   - Lil Wayne: 'Fire in the spark, swirvin' in the night, swimmin' with the shark, lookin' for the light' (5s, 5s, 5s, 5s | ABAB)
   - Drake: 'Late night in the city, called up on the phone, pity for the pretty, sittin' on the throne' (5s, 5s, 5s, 5s | ABAB)
   - Young Thug: 'Drippin' in the green, ridin' in the whip, ice on my Celine, let the thirty clip' (5s, 5s, 5s, 5s | ABAB)
   - NoCap: 'Sittin' in the cell, lookin' at the sky, ringin' out the bell, wonderin' on why' (4s, 4s, 4s, 4s | ABAB)
6. Setup-to-Punchline Balance (2:2): Beats 1-2 build the setup; Beats 3-4 deliver the escalation and landing rhyme.
7. Couplet Rhyme Scheme:
   - Bar 1 & Bar 2 MUST end in the assigned Couplet 1 rhyme sound with 2+ syllable slant match.
   - Bar 3 & Bar 4 MUST end in the assigned Couplet 2 rhyme sound with 2+ syllable slant match.
   - Bar 5 & Bar 6 MUST end in the assigned Couplet 3 rhyme sound with 2+ syllable slant match.
   - Bar 7 & Bar 8 MUST end in the assigned Couplet 4 rhyme sound with 2+ syllable slant match.
8. Zero Word Duplication: NEVER end multiple lines on the exact same word or stem (e.g. NEVER rhyme 'Mercedes' with 'mercedes', NEVER repeat 'overseas'). Every rhyme must land on distinct vocabulary!
9. No Corny / Forced Slant Rhymes: Strictly avoid robotic words that make no sense in street rap (e.g. 'hospital', 'optical', 'obstacle', 'impossible', 'lobster').
10. REWORKING & INTERPOLATION (10–20% ORIGINALITY / REWORKED CATALOG FLOWS WELCOME): You do NOT need 100% original lines! You are explicitly encouraged to interpolate, rework, and flip classic catalog motifs, signature punchlines, and double meanings (e.g. Gunna's 'think he the one, but he really the two', NoCap's homophones, Patek/Maybach flips, or user's own scratchpad notes). It is completely acceptable and preferred to take real iconic bars or the user's provided lines and rework, twist, or modernize them into fresh couplets with new slant rhymes!
10. Clean Studio Format: Output ONLY the {bars_count} lyric lines. No line numbers, no markdown code blocks, no beat labels, no intro explanations."""

    return prompt


def normalize_trap_tempo(bpm: float) -> tuple[float, float, str]:
    """Resolves double-time / halftime trap tempo relationships.
    e.g. 70 BPM Halftime -> 140 BPM Clock; 140 BPM Clock -> 70 BPM Halftime.
    """
    b = float(bpm) if bpm else 130.0
    if b <= 95.0:
        double_time = b * 2.0
        halftime = b
        label = f"{b:.0f} Halftime ({double_time:.0f} Clock)"
        return (double_time, halftime, label)
    else:
        double_time = b
        halftime = b / 2.0
        label = f"{b:.0f} Clock ({halftime:.0f} Halftime)"
        return (double_time, halftime, label)


def allocate_bar_artists(voice: str, blend: str = "", mix: int = 70, bars_count: int = 8) -> list[str]:
    """Determines bar-by-bar artist allocation for collaboration/blended takes (Step 4.4)."""
    if not blend or blend.lower() == voice.lower() or mix >= 100:
        return [voice] * bars_count

    alloc = []
    for i in range(bars_count):
        c_idx = i // 2
        if mix == 50:
            # Alternating couplets
            a = blend if (c_idx % 2 == 1) else voice
        elif 60 <= mix <= 75:
            # 70/30: Couplets 1, 2, 4 are primary voice; Couplet 3 is featured guest verse
            a = blend if (c_idx == 2) else voice
        elif mix <= 40:
            # 30/70: Primary gets Couplet 2 guest slot, rest is blend
            a = voice if (c_idx == 1) else blend
        elif mix >= 80:
            # 80/20: Trading punchlines on bars 6 and 8
            a = blend if (i in (5, 7)) else voice
        else:
            a = blend if (c_idx % 2 == 1) else voice
        alloc.append(a)
    return alloc


def generate_frontier_bars_v2(
    voice: str = "Gunna",
    blend: str = "",
    mix: int = 70,
    bpm: float = 130.0,
    scale: str = "F minor",
    target_syl: int = None,
    section_mode: str = "verse",
    rhyme_technique: str = "balanced",
    adhd_chain: list[str] = None,
    bars_count: int = 8,
    seed_line: str = "",
    topic_hint: str = "",
    scratchpad_bars: str = "",
    chosen_albums: list[str] = None,
    remix_ratio: int = 25,
    base_cap: float = 0.30,
    taste_on: bool = True,
    taste_k: int = 6,
    taste_store: Any = None,
    plan: dict = None,
    generation_id: str = "",
    use_cache: bool = True,
) -> dict:
    """Full V2/V3 generation pipeline: executes Retrieve & Remix over authentic catalog lines with dynamic edit cap."""
    t0 = time.time()
    generation_id = generation_id or f"v3_{int(time.time())}_{uuid.uuid4().hex[:8]}"
    clock_bpm, halftime_bpm, tempo_label = normalize_trap_tempo(bpm)
    from hook_engine import get_section_cadence_rules, verify_section_structure
    sec_rules = get_section_cadence_rules(section_mode)
    effective_syl = target_syl if target_syl else (sec_rules["target_syl"] if section_mode != "verse" else max(15, tempo_line_syllables(clock_bpm) + 2))
    from catalog_retriever import (
        DEFAULT_CHOSEN_ALBUMS,
        calculate_edit_distance_ratio,
        extract_seed_pattern,
        get_dynamic_cap,
        get_end_word_history,
        record_used_end_words,
        retrieve_matching_catalog_lines,
        verify_remix_compliance,
    )
    user_albums = chosen_albums or DEFAULT_CHOSEN_ALBUMS.get(voice, [])
    blend_albums = DEFAULT_CHOSEN_ALBUMS.get(blend, []) if blend else []

    # Task L: Prompt & Params Cache Lookup
    from prompt_cache import canonical_cache_params, compute_cache_key, get_cached_verse, save_cached_verse
    cache_params = canonical_cache_params(
        engine="v3",
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
    )
    cache_key = compute_cache_key(cache_params)

    if use_cache:
        cached_result = get_cached_verse(cache_key)
        if cached_result is not None:
            return cached_result

    dna = _get_voice_dna()
    cmu = _get_cmu()

    # Task J: Frontier Reasoning Planner Backbone
    if plan is None:
        try:
            from planner import plan_v4
            plan = plan_v4(
                voice=voice,
                bpm=clock_bpm,
                bars=bars_count,
                topic_hint=topic_hint or seed_line,
                chosen_albums=user_albums,
                blend=blend,
                mix=mix,
            )
        except Exception:
            plan = None

    if plan:
        if plan.get("motif_chain"):
            adhd_chain = plan["motif_chain"]
        if plan.get("couplet_voices"):
            bar_artists = [plan["couplet_voices"][i // 2] for i in range(bars_count)]
        else:
            bar_artists = allocate_bar_artists(voice=voice, blend=blend, mix=mix, bars_count=bars_count)
    else:
        bar_artists = allocate_bar_artists(voice=voice, blend=blend, mix=mix, bars_count=bars_count)

    system_prompt = build_v2_system_prompt(
        voice=voice,
        blend=blend,
        mix=mix,
        bpm=clock_bpm,
        scale=scale,
        target_syl=effective_syl,
        section_mode=section_mode,
        rhyme_technique=rhyme_technique,
        adhd_chain=adhd_chain,
        bars_count=bars_count,
        dna=dna,
        taste_on=taste_on,
        taste_k=taste_k,
        store=taste_store,
    )

    user_instructions = []
    couplet_count = max(1, bars_count // 2)
    chain = _resolve_adhd_chain(adhd_chain, scale=scale, bpm=bpm, voice=voice)
    catalog_banks = ARTIST_CATALOG_RHYME_BANKS.get(voice) or ARTIST_CATALOG_RHYME_BANKS.get("Gunna")

    # RETRIEVE AUTHENTIC CATALOG LINES MATCHING USER SEED OR MOTIFS (UNIQUE PER BAR - Task H)
    retrieved_catalog_bars = []
    user_albums = chosen_albums or DEFAULT_CHOSEN_ALBUMS.get(voice, [])
    blend_albums = DEFAULT_CHOSEN_ALBUMS.get(blend, []) if blend else []
    used_line_ids = set()
    recent_ends = get_end_word_history(window_size=16)

    if scratchpad_bars:
        seed_raw_lines = [l.strip() for l in scratchpad_bars.splitlines() if l.strip()]
        patterns = extract_seed_pattern(seed_raw_lines, cmu, bpm=clock_bpm)
        for i in range(bars_count):
            target_artist = bar_artists[i]
            target_albs = (chosen_albums if target_artist == voice else None) or DEFAULT_CHOSEN_ALBUMS.get(target_artist, [])
            couplet_idx = i // 2
            bar_topic = (plan["motif_chain"][couplet_idx % len(plan["motif_chain"])] if (plan and plan.get("motif_chain")) else topic_hint)
            if i < len(patterns):
                p = patterns[i]
            else:
                # Advance beyond user seed bars into fresh authentic artist couplet banks
                target_banks = ARTIST_CATALOG_RHYME_BANKS.get(target_artist) or ARTIST_CATALOG_RHYME_BANKS.get("Gunna")
                c_bank = target_banks[couplet_idx % len(target_banks)]
                tw = c_bank["pair"][i % 2]
                p = {
                    "end_word": tw,
                    "end_rime": " ".join(end_rime(tw, cmu) or ()),
                    "vowel_class": "V_other",
                    "target_syllables": effective_syl,
                }
            prev_line = retrieved_catalog_bars[-1] if retrieved_catalog_bars else None
            matches = retrieve_matching_catalog_lines(
                artist=target_artist,
                pattern=p,
                chosen_albums=target_albs,
                limit=12,
                bar_number=i + 1,
                previous_retrieved_line=prev_line,
                topic_hint=bar_topic,
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
    else:
        for i in range(bars_count):
            target_artist = bar_artists[i]
            target_banks = ARTIST_CATALOG_RHYME_BANKS.get(target_artist) or ARTIST_CATALOG_RHYME_BANKS.get("Gunna")
            couplet_idx = i // 2
            c_bank = target_banks[couplet_idx % len(target_banks)]
            tw = (plan["end_words"][i] if (plan and plan.get("end_words") and i < len(plan["end_words"])) else c_bank["pair"][i % 2])
            bar_topic = (plan["motif_chain"][couplet_idx % len(plan["motif_chain"])] if (plan and plan.get("motif_chain")) else topic_hint)
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
                topic_hint=bar_topic,
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

    retrieval_text_blocks = []
    for i, cat in enumerate(retrieved_catalog_bars):
        target_artist = bar_artists[i]
        if cat:
            arc_info = f" [Arc: {cat.get('chronological_arc', 'verse_build')} · Bar {cat.get('line_seq', 1)}/{cat.get('total_lines', 32)}]"
            couplet_tag = " 🔗 [Couplet Chain]" if cat.get("is_consecutive_couplet") else ""
            anthem_tag = " 🏆 [Anthem]" if cat.get("is_iconic_anthem") else ""
            bar_cap = get_dynamic_cap(cat, base_cap=base_cap)
            cap_tag = f" 🔒 [Cap: {int(bar_cap*100)}% Max Edit]"
            retrieval_text_blocks.append(
                f"Bar {i+1:02d} [{target_artist}]: [{cat['album']} | {cat['song']}]{arc_info}{couplet_tag}{anthem_tag}{cap_tag} \"{cat['text']}\" -> Exact End-Word to Preserve: '{cat['end_word']}' (Syllables: {cat['syllables']})"
            )
        else:
            couplet_idx = i // 2
            target_banks = ARTIST_CATALOG_RHYME_BANKS.get(target_artist) or ARTIST_CATALOG_RHYME_BANKS.get("Gunna")
            c_bank = target_banks[couplet_idx % len(target_banks)]
            tw = c_bank["pair"][i % 2]
            retrieval_text_blocks.append(
                f"Bar {i+1:02d} [{target_artist}]: Authentic {target_artist} Couplet Bank -> End-Word: '{tw}'"
            )

    user_instructions.append(
        f"=== CORE CONCEPT: RETRIEVE AND REMIX (MANDATORY 20% TO 30% EDIT DISTANCE CAP) ===\n"
        f"The model MUST NOT write original lines from scratch. Every phrase, rhythm, and flow must be grounded in {voice}'s catalog ({', '.join(user_albums)})"
        + (f" and {blend}'s catalog ({', '.join(blend_albums)})" if blend else "")
        + ".\n"
        f"Authentic Catalog Lines Retrieved for this Take:\n"
        + "\n".join(retrieval_text_blocks)
        + "\n\n"
        f"CRITICAL REMIX MANDATES (TASK 1 - 9 ENFORCEMENT):\n"
        f"1. LIGHT EDITS ONLY ({remix_ratio}% MAXIMUM CHANGE): Swap only 1 to 3 words from each retrieved catalog line so it fits the user's seed ideas/theme. {100 - remix_ratio}% of the line must remain the artist's authentic vocabulary and rhythm.\n"
        f"2. PRESERVE THE EXACT CATALOG END-WORD: You must end strictly on the authentic catalog end-word provided above for each bar. NEVER substitute generic filler like 'real', 'cake', 'slide', 'light', 'tight', 'pain', 'rain'.\n"
        f"3. WRITE BACKWARDS FROM THE PUNCH: Anchor the authentic catalog end-rhyme word first, and build the cadence backwards.\n"
        f"4. PRESERVE CADENCE & INNER RHYMES: Keep the flow, rhythm, and internal rhyme structures completely intact.\n"
        f"5. NO LINES FROM SCRATCH: Every line must be a direct light remix of its assigned catalog foundation bar."
    )

    if scratchpad_bars:
        user_instructions.append(
            f"USER STUDIO NOTES / THEME TO REMIX INTO BARS:\n"
            f"{scratchpad_bars.strip()}"
        )
    if seed_line and not scratchpad_bars:
        user_instructions.append(f"Opening Theme Anchor: '{seed_line}'")
    if topic_hint:
        user_instructions.append(f"Custom Studio Theme/Mood: {topic_hint}")

    user_instructions.append(
        "=== FEW-SHOT DEMONSTRATIONS: THE AUDAMAR / LOBSTER 4x4 CADENCE (STUDY THESE CAREFULLY) ===\n"
        "Here is exactly how a master platinum ghostwriter remixes a base catalog line into the Audamar/Lobster 4x4 meter:\n\n"
        "CRITICAL EXPANSION RULE FOR SHORT CATALOG LINES:\n"
        "If a base catalog line is short (under 12 syllables), NEVER chop it up with commas into tiny 2-word pieces! That ruins the cadence!\n"
        "Instead, write a fresh 8-to-10-syllable luxury setup for Beats 1 & 2 (with an internal rhyme connecting them), then use the catalog line (remixed) as Beats 3 & 4!\n\n"
        "Example 1:\n"
        "- Base Catalog Line: \"Went and got a Rollie, Audemars\" (Gunna - only 8 syllables)\n"
        "- Remixed 4x4 Output: Penthouse is large, gotta fast car, maximum withdraws, blue audamar\n"
        "  (Notice: Beats 1 & 2 'Penthouse is large, gotta fast car' are a fresh 8s setup with large/car internal rhyme. Beats 3 & 4 'maximum withdraws, blue audamar' deliver the escalation and catalog landing! Exactly 3 commas!)\n\n"
        "Example 2:\n"
        "- Base Catalog Line: \"On my plate I got lobster\" (Gunna - only 6 syllables)\n"
        "- Remixed 4x4 Output: She is a stylist, date has been lavish, we caught up and pop shit, over a lobster\n"
        "  (Notice: Beats 1 & 2 'She is a stylist, date has been lavish' are a fresh 10s setup with stylist/lavish slant rhyme. Beats 3 & 4 'we caught up and pop shit, over a lobster' deliver the dining punchline! Exactly 3 commas!)\n\n"
        "Example 3:\n"
        "- Base Catalog Line: \"Put a big double M on my Mercedes\" (Gunna - only 10 syllables)\n"
        "- Remixed 4x4 Output: Penthouse is spacious, lifestyle is gracious, switchin' lanes in traffic, double M Mercedes\n"
        "  (Notice: Beats 1 & 2 'spacious' / 'gracious' rhyme. Beats 3 & 4 deliver 'switchin' lanes in traffic, double M Mercedes' ending on Mercedes! Exactly 3 commas, 19 syllables!)\n\n"
        "Example 4:\n"
        "- Base Catalog Line: \"I heard you paid a dime just to squeeze\" (Gunna - only 9 syllables)\n"
        "- Remixed 4x4 Output: Drippin' in designer, pull up in a foreign, private jet in Paris, paid a dime to squeeze\n"
        "  (Notice: Beats 1 & 2 'designer' / 'foreign' slant. Beats 3 & 4 deliver the catalog punchline ending on 'squeeze'! Exactly 3 commas, 20 syllables!)\n"
    )

    couplet_guidance = []
    for c_i in range(couplet_count):
        b_start = c_i * 2 + 1
        b_end = c_i * 2 + 2
        a1 = bar_artists[b_start - 1]
        a2 = bar_artists[b_end - 1]
        m_name = MOTIF_DEFINITIONS.get(chain[c_i % len(chain)], {}).get("title", "Motif")
        cat1 = retrieved_catalog_bars[b_start - 1]
        cat2 = retrieved_catalog_bars[b_end - 1]
        b1_bank = ARTIST_CATALOG_RHYME_BANKS.get(a1) or catalog_banks
        b2_bank = ARTIST_CATALOG_RHYME_BANKS.get(a2) or catalog_banks
        tw1 = plan["end_words"][b_start - 1] if (plan and plan.get("end_words") and b_start - 1 < len(plan["end_words"])) else b1_bank[c_i % len(b1_bank)]["pair"][0]
        tw2 = plan["end_words"][b_end - 1] if (plan and plan.get("end_words") and b_end - 1 < len(plan["end_words"])) else b2_bank[c_i % len(b2_bank)]["pair"][1]
        w1 = cat1["end_word"] if cat1 else tw1
        w2 = cat2["end_word"] if cat2 else tw2
        if cat1:
            couplet_guidance.append(
                f"Bar {b_start:02d} [{a1}]: REMIX FOUNDATION ({a1}): \"{cat1['text']}\" (Landing Rhyme: '{w1}').\n"
                f"   Build {a1}'s Audamar/Lobster 4x4 bar that lands on '{w1}' in Beat 4:\n"
                f"   [Beat 1 (Sound A Setup)] 4-5s, [Beat 2 (Sound A Rhyme)] 4-5s, [Beat 3 Kinetic Action] 4-5s, [Beat 4 Punchline on '{w1}'] 4-5s.\n"
                f"   CRITICAL: DO NOT repeat '{w1}' in Beat 1 or 2! '{w1}' belongs ONLY at the end of Beat 4! Total line must be 17-21 syllables."
            )
        else:
            couplet_guidance.append(
                f"Bar {b_start:02d} [{a1} - {m_name}]: EXACTLY 3 COMMAS (4 PHRASES, 17-21 syl total):\n"
                f"   [Beat 1 (Sound A Setup)] 4-5s, [Beat 2 (Sound A Rhyme)] 4-5s, [Beat 3 Kinetic Turn] 4-5s, [Beat 4 Punchline on '{w1}'] 4-5s."
            )
        if cat2:
            couplet_guidance.append(
                f"Bar {b_end:02d} [{a2}]: REMIX FOUNDATION ({a2}): \"{cat2['text']}\" (Landing Rhyme: '{w2}').\n"
                f"   Build {a2}'s Audamar/Lobster 4x4 bar that lands on '{w2}' in Beat 4:\n"
                f"   [Beat 1 (Sound B Setup)] 4-5s, [Beat 2 (Sound B Rhyme)] 4-5s, [Beat 3 Kinetic Action] 4-5s, [Beat 4 Punchline on '{w2}'] 4-5s.\n"
                f"   CRITICAL: DO NOT repeat '{w2}' in Beat 1 or 2! '{w2}' belongs ONLY at the end of Beat 4! Total line must be 17-21 syllables."
            )
        else:
            couplet_guidance.append(
                f"Bar {b_end:02d} [{a2} - {m_name}]: EXACTLY 3 COMMAS (4 PHRASES, 17-21 syl total):\n"
                f"   [Beat 1 (Sound B Setup)] 4-5s, [Beat 2 (Sound B Rhyme)] 4-5s, [Beat 3 Kinetic Turn] 4-5s, [Beat 4 Punchline on '{w2}'] 4-5s."
            )

    user_instructions.append(f"Write ALL {bars_count} BARS line by line (DO NOT STOP AT 4 BARS):\n" + "\n".join(couplet_guidance[:bars_count]))
    user_instructions.append(
        "CRITICAL QUADRASONIC CADENCE & CATALOG RHYME MANDATES:\n"
        "1. STRICT CATALOG END-RHYMES ONLY: Every couplet must resolve strictly on the assigned authentic catalog pair! NEVER substitute generic nursery rhymes like 'real', 'cake', 'slide', 'light', 'tight', 'pain', 'rain'.\n"
        "2. AUDAMAR/LOBSTER 4x4 METER (EXACTLY 3 COMMAS PER LINE): Every single line MUST have EXACTLY THREE COMMAS separating 4 substantive phrases of 4 to 5 syllables each (total 17-21 syllables). NEVER output a line with only 1 or 2 commas!\n"
        "3. BEAT 1 & BEAT 2 INTERNAL RHYME CHAIN: Beat 1 and Beat 2 MUST interlock with an internal rhyme or strong slant vowel match (e.g. large/car, stylist/lavish, maybach/payback, celine/green, collar/dollar)!\n"
        "4. BEAT 3 KINETIC ACTION / BEAT 4 PUNCHLINE: Beat 3 gives financial/street momentum (e.g. maximum withdraws, pop shit, switchin' lanes), Beat 4 lands the concrete luxury status punchline item.\n"
        "5. ZERO CONVERSATIONAL FILLERS OR ORPHANS: NEVER write words like 'yeah,', 'man,', 'look,', 'uh,', 'said,', 'rich,' as a separate phrase! NEVER output a single-word beat!\n"
        "6. NO DUPLICATE RHYME INTRUSIONS: NEVER glue rhyming words together in a phrase like 'reveal deal' or 'flow glow' or 'low though'. The rhyme landing belongs ONLY at the end of Beat 4.\n"
        "7. GOLDEN BENCHMARKS TO EMULATE:\n"
        "   - Gunna: 'Penthouse is large, gotta fast car, maximum withdraws, blue audamar' (4s, 4s, 5s, 4s = 17s)\n"
        "   - Gunna: 'She is a stylist, date has been lavish, we caught up and pop shit, over a lobster' (5s, 5s, 6s, 5s = 21s)\n"
        "   - Drake: 'Late night in the city, pity for the pretty, caught up on the phone line, flight to New York City' (5s, 5s, 5s, 5s = 20s)\n"
        "   - Drake: 'Table at the Carbone, sitting in a dark tone, check was thirty thousand, dialed on the smart phone' (5s, 5s, 5s, 5s = 20s)\n"
        "   - Lil Wayne: 'Light flick in the dark, fire on the spark, running through the jungle, swimming with the shark' (5s, 5s, 5s, 5s = 20s)\n"
        "   - NoCap: 'Sitting in a cold cell, stories that I won't tell, scars across my body, ringing out the church bell' (5s, 5s, 5s, 5s = 20s)\n"
        "   - Gunna: 'Bought me a Maybach, plannin' the payback, runnin' through static, Patek automatic' (5s, 5s, 6s, 6s = 22s)\n"
        "8. OUTPUT FORMAT: Output ONLY the raw lyric lines, 1 bar per line, no Bar labels, no quotes."
    )

    user_content = "\n\n".join(user_instructions)

    CANDIDATE_MODELS = [
        os.environ.get("V4_POLISH_MODEL", "claude-opus-4-7"),
        "claude-3-5-sonnet-20241022",
        "gpt-4o",
        "gpt-4o-mini",
    ]
    raw_lines = []
    provider = "frontier_ghostwriter_v3"
    import re

    for model_name in CANDIDATE_MODELS:
        try:
            content = chat(
                model=model_name,
                system=system_prompt,
                user=user_content,
                max_tokens=1200,
                temperature=0.72,
            )
            if not content or not content.strip():
                continue
            content = content.strip()
            if content.startswith("```"):
                content_lines = content.splitlines()
                content = "\n".join([l for l in content_lines if not l.startswith("```")])
            lines = [l.strip() for l in content.splitlines() if l.strip()]
            parsed = []
            for l in lines:
                l_clean = re.sub(r"^(?:Bar\s*\d+[\s:.-]*|\d+[\s:.-]+)", "", l, flags=re.IGNORECASE).strip().strip("\"'")
                if l_clean.startswith("[") and l_clean.endswith("]"):
                    continue
                if l_clean.lower().startswith("couplet"):
                    continue
                l_clean = re.sub(r"\s*\(\d+\)\s*$", "", l_clean).strip()
                if l_clean:
                    parsed.append(l_clean)

                if len(parsed) < bars_count:
                    expanded = []
                    for p in parsed:
                        p_commas = [part.strip() for part in p.split(",") if part.strip()]
                        if len(p_commas) >= 6:
                            mid = len(p_commas) // 2
                            expanded.append(", ".join(p_commas[:mid]))
                            expanded.append(", ".join(p_commas[mid:]))
                        else:
                            expanded.append(p)
                    parsed = expanded

                if len(parsed) >= 4:
                    raw_lines = parsed
                    provider = f"frontier_ghostwriter_v3 ({model_name})"
                    break
        except Exception as exc:
            print(f"[Ghostwriter V3] Attempt with {model_name} failed: {exc}", file=sys.stderr)
            continue

    if not raw_lines:
        provider = "local_heuristic_fallback"
        if section_mode == "hook":
            from hook_engine import generate_hook_lines
            raw_lines = generate_hook_lines(voice=voice, theme=topic_hint or seed_line, bars_count=bars_count)
        elif section_mode == "bridge":
            raw_lines = [
                "Standing all alone out in the cold rain",
                "Praying to the Lord to heal all the pain",
                "Sun is shining slowly through all the clouds",
                "Know that I will make my family proud",
            ]
        elif section_mode == "outro":
            raw_lines = [
                "Riding out into the night",
                "Keep the vision shining bright",
                "Watch the city fade away",
                "Nothing left for me to say",
            ]
        else:
            raw_lines = [
                "Patek Philippe flooded, got the diamond in the face",
                "Twenty-four-seven in the foreign running out of space",
                "Saw the way she looked at me, she fell in love with grace",
                "Had to switch the flight to Paris, leave without a trace",
                "Keep the steel inside the jacket, never beat the case",
                "Paranoid of all the shadows talking sideways to my face",
                "Sign the check in all designer, put 'em in their place",
                "Built the whole foundation solid, winning in the race",
            ]

    final_bars = raw_lines[:bars_count]
    elapsed = round(time.time() - t0, 2)

    cmu = _get_cmu()

    # Task P: Named-Entity Leak Guard Verification & Auto-Retry
    from entity_guard import guard_verse, rewrite_leaked_entity_bar
    entity_eval_initial = guard_verse(voice=voice, bars=final_bars, bar_artists=bar_artists)
    entity_retries_done = 0

    if not entity_eval_initial["passed"]:
        for failed_idx in entity_eval_initial["failed_indices"]:
            b_res = entity_eval_initial["bar_results"][failed_idx]
            cat_match = retrieved_catalog_bars[failed_idx] if failed_idx < len(retrieved_catalog_bars) else None
            couplet_idx = failed_idx // 2
            c_bank = catalog_banks[couplet_idx % len(catalog_banks)]
            target_word = cat_match["end_word"] if (cat_match and cat_match.get("end_word")) else c_bank["pair"][failed_idx % 2]
            target_artist = bar_artists[failed_idx] if failed_idx < len(bar_artists) else voice
            offending = b_res["offending_tokens"]

            # Auto-retry up to 2 times with the offending token listed
            for _ in range(2):
                entity_retries_done += 1
                rewritten_line, passed_guard = rewrite_leaked_entity_bar(
                    bar_text=final_bars[failed_idx],
                    target_word=target_word,
                    offending_tokens=offending,
                    voice=target_artist,
                    source_catalog_text=cat_match["text"] if cat_match else "",
                    cmu=cmu,
                )
                if rewritten_line:
                    final_bars[failed_idx] = rewritten_line
                    if passed_guard:
                        break

    final_entity_eval = guard_verse(voice=voice, bars=final_bars, bar_artists=bar_artists)

    # Task G: Verify Grid Landings and Trigger Targeted Retries for Off-Grid Bars
    if section_mode == "verse":
        grid_eval_initial = verify_grid_landings(
            bars=final_bars,
            bpm=clock_bpm,
            effective_syl=effective_syl,
            cmu=cmu,
        )
    else:
        sec_struct_init = verify_section_structure(final_bars, section_mode=section_mode, cmu=cmu)
        grid_eval_initial = {
            "passed": sec_struct_init["passed"],
            "pass_rate": sec_struct_init["pass_rate"],
            "target_beat_range": sec_struct_init["target_range"],
            "bar_results": [
                {
                    "index": i + 1,
                    "passed": i not in [v["bar_index"] for v in sec_struct_init["violations"]],
                    "total_syllables": sec_struct_init["bar_syllables"][i],
                    "violation_desc": "On-grid" if i not in [v["bar_index"] for v in sec_struct_init["violations"]] else "Syllable violation",
                    "off_grid_beats": [],
                }
                for i in range(len(final_bars))
            ],
            "failed_indices": [v["bar_index"] for v in sec_struct_init["violations"]],
        }

    max_global_retries = min(bars_count, 6)
    total_retries_done = 0
    bar_retry_counts = [0] * len(final_bars)

    if not grid_eval_initial["passed"]:
        target_min, target_max = grid_eval_initial["target_beat_range"]
        for failed_idx in grid_eval_initial["failed_indices"]:
            if total_retries_done >= max_global_retries:
                break

            bar_res = grid_eval_initial["bar_results"][failed_idx]
            cat_match = retrieved_catalog_bars[failed_idx] if failed_idx < len(retrieved_catalog_bars) else None
            couplet_idx = failed_idx // 2
            c_bank = catalog_banks[couplet_idx % len(catalog_banks)]
            target_word = cat_match["end_word"] if (cat_match and cat_match.get("end_word")) else c_bank["pair"][failed_idx % 2]
            target_artist = bar_artists[failed_idx] if failed_idx < len(bar_artists) else voice

            for _ in range(2):
                if total_retries_done >= max_global_retries:
                    break
                total_retries_done += 1
                bar_retry_counts[failed_idx] += 1

                rewritten_line, passed_grid = rewrite_off_grid_bar(
                    bar_text=final_bars[failed_idx],
                    target_word=target_word,
                    violation_desc=bar_res["violation_desc"],
                    target_min=target_min,
                    target_max=target_max,
                    effective_syl=effective_syl,
                    cmu=cmu,
                    voice=target_artist,
                    source_catalog_text=cat_match["text"] if cat_match else "",
                )
                if rewritten_line:
                    final_bars[failed_idx] = rewritten_line
                    if passed_grid:
                        break

    if section_mode == "verse":
        final_grid_eval = verify_grid_landings(
            bars=final_bars,
            bpm=clock_bpm,
            effective_syl=effective_syl,
            cmu=cmu,
        )
    else:
        sec_struct_final = verify_section_structure(final_bars, section_mode=section_mode, cmu=cmu)
        final_grid_eval = {
            "passed": sec_struct_final["passed"],
            "pass_rate": sec_struct_final["pass_rate"],
            "target_beat_range": sec_struct_final["target_range"],
            "bar_results": [
                {
                    "index": i + 1,
                    "passed": i not in [v["bar_index"] for v in sec_struct_final["violations"]],
                    "total_syllables": sec_struct_final["bar_syllables"][i],
                    "violation_desc": "On-grid" if i not in [v["bar_index"] for v in sec_struct_final["violations"]] else "Syllable violation",
                    "off_grid_beats": [],
                }
                for i in range(len(final_bars))
            ],
            "failed_indices": [v["bar_index"] for v in sec_struct_final["violations"]],
        }

    detailed_bars = []
    v_catalog = get_artist_catalog_rhymes(voice, dna)
    b_catalog = get_artist_catalog_rhymes(blend, dna) if blend else None
    catalog_ends = set(v_catalog["top_end_words"])
    if b_catalog and b_catalog.get("top_end_words"):
        catalog_ends.update(b_catalog["top_end_words"])
    chain = _resolve_adhd_chain(adhd_chain, scale=scale, bpm=bpm, voice=voice)

    for idx, ln in enumerate(final_bars):
        couplet_idx = idx // 2
        c_bank = catalog_banks[couplet_idx % len(catalog_banks)]
        cat_match = retrieved_catalog_bars[idx] if idx < len(retrieved_catalog_bars) else None
        target_word = cat_match["end_word"] if (cat_match and cat_match.get("end_word")) else (
            plan["end_words"][idx] if (plan and plan.get("end_words") and idx < len(plan["end_words"])) else c_bank["pair"][idx % 2]
        )

        beat_info = parse_beat_groups(ln, cmu)
        toks = tokenize(normalize(ln))
        end_w = toks[-1] if toks else ""

        # 1. If target catalog word is in Beat 3 instead of Beat 4, swap them so the landing rhyme hits Beat 4
        if len(beat_info["groups"]) >= 4 and target_word.lower() in beat_info["groups"][2].lower() and target_word.lower() not in beat_info["groups"][3].lower():
            p3 = beat_info["groups"][2]
            p4 = beat_info["groups"][3]
            beat_info["groups"][2] = p4
            beat_info["groups"][3] = p3
            beat_info["quad_formatted"] = ", ".join(beat_info["groups"])
            ln = beat_info["quad_formatted"]
            toks = tokenize(normalize(ln))
            end_w = toks[-1] if toks else ""

        # Build catalog word set for this artist and blended partner
        catalog_words = set(catalog_ends)
        for b in catalog_banks:
            catalog_words.add(b["pair"][0].lower())
            catalog_words.add(b["pair"][1].lower())
        if blend:
            b_banks = ARTIST_CATALOG_RHYME_BANKS.get(blend) or []
            for b in b_banks:
                catalog_words.add(b["pair"][0].lower())
                catalog_words.add(b["pair"][1].lower())
            if b_catalog and b_catalog.get("top_end_words"):
                for w in b_catalog["top_end_words"]:
                    catalog_words.add(w.lower())
        if cat_match and cat_match.get("end_word"):
            catalog_words.add(cat_match["end_word"].lower())
            target_word = cat_match["end_word"].lower()

        # 2. If end word is in generic blacklist OR not in artist catalog, enforce the authentic artist catalog end word
        if (end_w.lower() in GENERIC_END_RHYME_BLACKLIST or (end_w.lower() not in catalog_words and end_w.lower() != target_word.lower()) or not end_w) and len(beat_info["groups"]) >= 4:
            b4_words = beat_info["groups"][3].split()
            if len(b4_words) >= 2:
                prefix = " ".join(b4_words[:-1])
                beat_info["groups"][3] = f"{prefix} {target_word}"
            else:
                cat_tokens = tokenize(normalize(cat_match["text"])) if cat_match else []
                if len(cat_tokens) >= 2 and cat_tokens[-1].lower() == target_word.lower():
                    beat_info["groups"][3] = f"{cat_tokens[-2]} {target_word}"
                else:
                    connector = "in" if target_word in ("toronto", "paris", "atlanta", "cellar") else ("with" if target_word in ("audamar", "audemars", "patek", "maybach") else "on the")
                    beat_info["groups"][3] = f"{connector} {target_word}"
            beat_info["quad_formatted"] = ", ".join(beat_info["groups"])
            ln = beat_info["quad_formatted"]
            toks = tokenize(normalize(ln))
            end_w = toks[-1] if toks else target_word

        # 3. Ensure Beat 4 is never a single orphan word
        if len(beat_info["groups"]) >= 4 and len(beat_info["groups"][3].split()) <= 1 and end_w:
            cat_tokens = tokenize(normalize(cat_match["text"])) if cat_match else []
            if len(cat_tokens) >= 2 and cat_tokens[-1].lower() == end_w.lower():
                beat_info["groups"][3] = f"{cat_tokens[-2]} {end_w}"
            else:
                connector = "in" if end_w in ("toronto", "paris", "atlanta", "cellar") else ("with" if end_w in ("audamar", "audemars", "patek", "maybach") else "on the")
                beat_info["groups"][3] = f"{connector} {end_w}"
            beat_info["quad_formatted"] = ", ".join(beat_info["groups"])
            ln = beat_info["quad_formatted"]
            toks = tokenize(normalize(ln))

        beat_info["beat_syllables"] = [count_cmu_syllables(g, cmu) if g else 0 for g in beat_info["groups"]]
        beat_info["total_syllables"] = sum(beat_info["beat_syllables"])

        rime = end_rime(end_w, cmu) if (end_w and cmu) else None
        rime_str = "-".join(rime) if rime else ""

        # Extract inner-rhyme words within the line that rhyme with the end-word or each other
        inner_rhyme_candidates = []
        end_rime_val = rime if rime else None
        stopwords = {"and", "the", "for", "with", "that", "this", "from", "they", "them", "then", "into"}
        if len(toks) > 1:
            for w in toks[:-1]:
                if len(w) < 3 or w in stopwords:
                    continue
                w_rime = end_rime(w, cmu) if cmu else None
                if w_rime and end_rime_val:
                    if w_rime == end_rime_val or w_rime[0].rstrip("012") == end_rime_val[0].rstrip("012"):
                        inner_rhyme_candidates.append(w)
            for i in range(len(toks) - 2):
                w1 = toks[i]
                if len(w1) < 3 or w1 in stopwords:
                    continue
                r1 = end_rime(w1, cmu) if cmu else None
                if not r1:
                    continue
                for j in range(i + 1, len(toks) - 1):
                    w2 = toks[j]
                    if len(w2) < 3 or w1 == w2 or w2 in stopwords:
                        continue
                    r2 = end_rime(w2, cmu) if cmu else None
                    if r2 and r1 == r2:
                        if w1 not in inner_rhyme_candidates:
                            inner_rhyme_candidates.append(w1)
                        if w2 not in inner_rhyme_candidates:
                            inner_rhyme_candidates.append(w2)
        inner_rhymes_list = list(dict.fromkeys(inner_rhyme_candidates))

        # Check couplet motif
        couplet_idx = idx // 2
        motif_key = chain[couplet_idx % len(chain)]
        motif_info = MOTIF_DEFINITIONS.get(motif_key, {})

        syl = beat_info["total_syllables"]

        # Check against catalog rhymes and generic blacklist
        is_generic = end_w.lower() in GENERIC_END_RHYME_BLACKLIST
        catalog_words = set(catalog_ends)
        for b in catalog_banks:
            catalog_words.add(b["pair"][0].lower())
            catalog_words.add(b["pair"][1].lower())
        is_catalog_hit = (end_w.lower() in catalog_words) and not is_generic

        # Retrieve and Remix Compliance Metrics with Dynamic Cap (Task R)
        cat_match = retrieved_catalog_bars[idx] if idx < len(retrieved_catalog_bars) else None
        bar_cap = get_dynamic_cap(cat_match, base_cap=base_cap)
        compliance = verify_remix_compliance(cat_match["text"], ln, cap=bar_cap, cmu=cmu) if cat_match else {
            "is_compliant": True,
            "edit_distance_ratio": 0.25,
            "cap": bar_cap,
            "end_word_preserved": True,
        }

        bar_grid = final_grid_eval["bar_results"][idx] if idx < len(final_grid_eval["bar_results"]) else {}

        detailed_bars.append({
            "index": idx + 1,
            "artist": bar_artists[idx] if idx < len(bar_artists) else voice,
            "text": beat_info.get("quad_formatted", ln),
            "raw_text": ln,
            "quad_formatted": beat_info.get("quad_formatted", ln),
            "beat_groups": beat_info["groups"],
            "beat_syllables": beat_info["beat_syllables"],
            "is_quadrasonic": beat_info["is_quadrasonic"],
            "setup": beat_info["setup"],
            "punchline": beat_info["punchline"],
            "syllables": syl,
            "target_syllables": effective_syl,
            "delta": syl - effective_syl,
            "end_word": end_w,
            "inner_rhymes": inner_rhymes_list,
            "rhyme_family": rime_str,
            "motif": motif_info.get("title", "Motif"),
            "couplet_num": couplet_idx + 1,
            "artist_rhyme_hit": is_catalog_hit,
            "is_generic_rhyme": is_generic,
            "source_catalog_text": cat_match["text"] if cat_match else "",
            "source_catalog_song": cat_match["song"] if cat_match else "",
            "source_catalog_album": cat_match["album"] if cat_match else "",
            "source_catalog_seq": cat_match.get("line_seq", 1) if cat_match else 1,
            "source_catalog_total": cat_match.get("total_lines", 32) if cat_match else 32,
            "source_catalog_arc": cat_match.get("chronological_arc", "verse_build") if cat_match else "verse_build",
            "source_is_anthem": bool(cat_match.get("is_iconic_anthem")) if cat_match else False,
            "is_consecutive_couplet": bool(cat_match.get("is_consecutive_couplet")) if cat_match else False,
            "edit_distance_ratio": compliance["edit_distance_ratio"],
            "edit_distance_cap": compliance["cap"],
            "remix_compliant": compliance["is_compliant"],
            "end_word_preserved": compliance["end_word_preserved"],
            "grid_passed": bar_grid.get("passed", True),
            "grid_violations": bar_grid.get("off_grid_beats", []),
            "grid_violation_desc": bar_grid.get("violation_desc", "On-grid"),
            "grid_retries": bar_retry_counts[idx] if idx < len(bar_retry_counts) else 0,
        })

    # Couplet rhyming evaluation using CMU phonetic matching and V3 Multisyllabic Stacks
    import v3_rhyme_stack
    import v3_audio_aligner

    for c_i in range(0, len(detailed_bars) - 1, 2):
        b1 = detailed_bars[c_i]
        b2 = detailed_bars[c_i + 1]
        w1 = b1.get("end_word") or ""
        w2 = b2.get("end_word") or ""
        quality = check_rhyme_quality(w1, w2, cmu)
        b1["couplet_rhyme_quality"] = quality
        b2["couplet_rhyme_quality"] = quality
        b1["couplet_rhymes"] = quality in ("pure", "slant")
        b2["couplet_rhymes"] = quality in ("pure", "slant")

        # V3 Multisyllabic Stack Depth
        p1 = b1.get("punchline") or b1.get("text")
        p2 = b2.get("punchline") or b2.get("text")
        m_stack = v3_rhyme_stack.analyze_multisyllabic_stack(p1, p2, cmu)
        b1["multisyllabic_depth"] = m_stack["depth"]
        b1["multisyllabic_type"] = m_stack["type"]
        b2["multisyllabic_depth"] = m_stack["depth"]
        b2["multisyllabic_type"] = m_stack["type"]

    # Task H: Record newly generated end words to dedupe history
    try:
        record_used_end_words([b["end_word"] for b in detailed_bars])
    except Exception:
        pass

    # Task K: Write per-bar telemetry
    try:
        from telemetry import write_verse_telemetry
        write_verse_telemetry(
            generation_id=generation_id,
            bars=detailed_bars,
            plan=plan,
            style_score=0.82,
            voice=voice,
        )
    except Exception:
        pass

    # Generate V3 Audio Stem Alignment Grid
    stem_grid = v3_audio_aligner.generate_full_stem_alignment(
        detailed_bars,
        bpm=clock_bpm,
        pocket_style="laid_back" if voice.lower() in ("gunna", "thug", "young thug") else "on_the_grid",
    )
    stem_grid["grid_pass_rate"] = final_grid_eval["pass_rate"]
    stem_grid["target_beat_range"] = final_grid_eval["target_beat_range"]

    bag_metrics = get_artist_bag_metrics(voice=voice, scale=scale, bpm=clock_bpm)

    res = {
        "ok": True,
        "version": "v3",
        "generation_id": generation_id,
        "cached": False,
        "cache_key": cache_key,
        "provider": provider,
        "voice": voice,
        "blend": blend,
        "mix": mix if blend else None,
        "blend_allocation": bar_artists,
        "blend_summary": f"{mix}% {voice} / {100-mix}% {blend}" if blend else f"Solo ({voice})",
        "bpm": bpm,
        "clock_bpm": clock_bpm,
        "halftime_bpm": halftime_bpm,
        "tempo_label": tempo_label,
        "scale": scale,
        "target_syllables": effective_syl,
        "section_mode": section_mode,
        "technique": rhyme_technique,
        "adhd_motifs": [MOTIF_DEFINITIONS.get(k, {}).get("title") for k in chain],
        "bag_metrics": bag_metrics,
        "catalog_end_rhymes_used": v_catalog["top_end_words"][:8],
        "retrieve_and_remix_mode": True,
        "remix_ratio": remix_ratio,
        "base_cap": base_cap,
        "chosen_albums": user_albums,
        "plan": plan,
        "taste_on": taste_on,
        "taste_k": taste_k,
        "grid_gate": final_grid_eval,
        "grid_pass_rate": final_grid_eval["pass_rate"],
        "grid_retries": total_retries_done,
        "grid_retries_total": total_retries_done,
        "entity_guard": final_entity_eval,
        "entity_retries": entity_retries_done,
        "section_structure": verify_section_structure(final_bars, section_mode=section_mode, cmu=cmu),
        "retrieved_sources": [
            {
                "bar": i + 1,
                "song": c["song"],
                "album": c["album"],
                "text": c["text"],
                "end_word": c["end_word"],
                "match_score": c.get("match_score", 0),
            }
            for i, c in enumerate(retrieved_catalog_bars)
            if c
        ],
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
                result=res,
                retrieved_catalog_bars=retrieved_catalog_bars,
                plan=plan,
            )
        except Exception:
            pass

    return res


def polish_lyrics(
    bars: list[str],
    voice: str = "Gunna",
    blend: str = "",
    mix: int = 70,
    bpm: float = 130.0,
    scale: str = "F minor",
    topic: str = "",
    section_mode: str = "verse",
    rhyme_technique: str = "balanced",
    adhd_chain: list[str] = None,
) -> dict:
    """Polish an existing take using the V2 engine."""
    seed_line = bars[0] if bars else ""
    return generate_frontier_bars_v2(
        voice=voice,
        blend=blend,
        mix=mix,
        bpm=bpm,
        scale=scale,
        section_mode=section_mode,
        rhyme_technique=rhyme_technique,
        adhd_chain=adhd_chain,
        bars_count=len(bars) if bars else 8,
        seed_line=seed_line,
        topic_hint=topic,
    )


def main():
    parser = argparse.ArgumentParser(description="Penwork Studios Frontier Ghostwriter V2")
    parser.add_argument("--voice", default="Gunna", help="Artist pocket")
    parser.add_argument("--blend", default="NoCap", help="Secondary voice blend")
    parser.add_argument("--mix", type=int, default=70, help="Blend mix %")
    parser.add_argument("--bpm", type=float, default=130.0, help="Tempo BPM")
    parser.add_argument("--scale", default="F minor", help="Musical scale (e.g. F minor, C major)")
    parser.add_argument("--syl", type=int, default=13, help="Target syllable budget")
    parser.add_argument("--mode", default="verse", choices=["verse", "hook"], help="Section mode")
    parser.add_argument("--technique", default="balanced", choices=["balanced", "inner_density", "outer_uniqueness"], help="Rhyme craft")
    parser.add_argument("--bars", type=int, default=8, help="Number of bars")
    parser.add_argument("--seed-line", default="", help="Opening seed bar")
    parser.add_argument("--taste", choices=["on", "off"], default="on", help="Wire rater feedback taste blocks (on/off)")
    parser.add_argument("--taste-k", type=int, default=6, help="Top K keeper bars for taste block")
    parser.add_argument("--base-cap", type=float, default=0.30, help="Base remix edit-distance cap (default: 0.30)")
    args = parser.parse_args()

    res = generate_frontier_bars_v2(
        voice=args.voice,
        blend=args.blend,
        mix=args.mix,
        bpm=args.bpm,
        scale=args.scale,
        target_syl=args.syl,
        section_mode=args.mode,
        rhyme_technique=args.technique,
        bars_count=args.bars,
        seed_line=args.seed_line,
        base_cap=args.base_cap,
        taste_on=(args.taste == "on"),
        taste_k=args.taste_k,
    )

    print(f"\n[Penwork Studios Frontier Ghostwriter V2] {res['voice']} ({res['blend']} {res['mix']}%) @ {res['bpm']} BPM")
    print(f"ADHD Motif Progression: {' -> '.join(res['adhd_motifs'])}\n")
    for b in res["bars"]:
        rhyme_tag = f"[{b['end_word']} | {b['rhyme_family']}]"
        beats_str = " · ".join([f"B{i+1}: {grp} ({syl})" for i, (grp, syl) in enumerate(zip(b['beat_groups'], b['beat_syllables']))])
        rhyme_match = "✓ RHYMES" if b.get("couplet_rhymes") else ""
        print(f"Bar {b['index']:02d} [{b['syllables']:2d} syl] (Couplet {b.get('couplet_num')} | {b['motif'][:15]}):")
        print(f"       Text: {b['text']} {rhyme_tag} {rhyme_match}")
        print(f"       Grid: {beats_str}\n")


if __name__ == "__main__":
    main()
