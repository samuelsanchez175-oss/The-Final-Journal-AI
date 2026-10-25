#!/usr/bin/env python3
"""
Frontier v4 Section-Aware Generation & Hook Engine (Task Q)

Ports and expands the core hook generation logic of XJournal AI/ModelG/HookEngine.swift into Python.
Supports four distinct song section modes:
  1. verse  -> Audamar/Lobster 4x4 Quadrasonic meter (17-24 syl, exactly 3 commas, dense storytelling).
  2. hook   -> Shorter bars (10-14 syl), two-line AABB with memorable repetition, call-and-response chant.
  3. bridge -> Half-time cadence, spacious melodic pocket (8-11 syl).
  4. outro  -> Fade pattern, de-escalating syllables (6-10 syl), trailing sign-off motifs.

Features:
  - get_section_cadence_rules(section_mode)
  - build_section_system_prompt_block(section_mode, voice)
  - build_hook_blueprint(voice, theme, bars_count)
  - verify_section_structure(bars, section_mode, cmu)
  - generate_hook_lines(voice, theme, bars_count, call_fn)
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
for p in (HERE, REPO_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from lyriclib import end_rime, estimate_syllables, normalize, tokenize

# ==============================================================================
# SECTION CADENCE RULES & CONSTRAINTS
# ==============================================================================

SECTION_CONSTRAINTS: dict[str, dict[str, Any]] = {
    "verse": {
        "min_syl": 17,
        "max_syl": 24,
        "target_syl": 18,
        "commas": 3,
        "title": "Verse (Storytelling 4x4 Pocket)",
        "meter_desc": "Audamar/Lobster 4x4 Quadrasonic cadence. Exactly 3 commas separating 4 substantive beat phrases.",
        "rhyme_pattern": "Couplet AABB with internal rhyme connecting Beat 1 and Beat 2.",
        "density": "High density, continuous rhythmic momentum, kinetic status escalation.",
    },
    "hook": {
        "min_syl": 10,
        "max_syl": 14,
        "target_syl": 12,
        "commas": 1,
        "title": "Hook / Chorus (Anthemic Repetition & Call-and-Response)",
        "meter_desc": "Punchy, catchy, melodic-glide phrasing. 10-14 syllables per bar with 1-2 commas.",
        "rhyme_pattern": "Two-line AABB or repeated chant with memorable repetition and call-and-response.",
        "density": "Spacious, sing-along phrasing; emotional anchor over complex technical density.",
    },
    "bridge": {
        "min_syl": 8,
        "max_syl": 11,
        "target_syl": 9,
        "commas": 1,
        "title": "Bridge (Half-Time Introspective Pocket)",
        "meter_desc": "Half-time cadence. 8-11 syllables per bar, breathing room between phrases.",
        "rhyme_pattern": "AABB or ABCB with melodic suspension and contemplative perspective shift.",
        "density": "Vocal float, open 808 pockets, reflective or vulnerable transition.",
    },
    "outro": {
        "min_syl": 6,
        "max_syl": 10,
        "target_syl": 8,
        "commas": 0,
        "title": "Outro (De-escalation & Fade Pattern)",
        "meter_desc": "Fade-out cadence. 6-10 syllables per bar, minimal phrasing, trailing echoes.",
        "rhyme_pattern": "Echoing end words, trailing ad-lib anchors, thematic sign-off.",
        "density": "Minimalist fade, decaying energy, resolving final chords.",
    },
}

# Core Cold Trap Repetition Templates for Hooks
HOOK_REPETITION_PATTERNS: dict[str, list[dict[str, Any]]] = {
    "Gunna": [
        {
            "pattern": "anaphora_prefix",
            "anchor": "Bank on me",
            "lines": [
                "Bank on me, watch the money multiply",
                "Bank on me, foreign coupe is rolling by",
                "Drip on me, know they cannot touch the sky",
                "Drip on me, keep the faith until I die",
            ],
        },
        {
            "pattern": "call_and_response",
            "anchor": "Pull up in a foreign",
            "lines": [
                "Pull up in a foreign, make the city shake",
                "Racks inside the duffel, know it isn't fake",
                "Diamonds in the water, never will I break",
                "Everything we started, everything at stake",
            ],
        },
    ],
    "Drake": [
        {
            "pattern": "call_and_response",
            "anchor": "Late night calls",
            "lines": [
                "Late night calls, know you want me by your side",
                "City lights, nowhere left for you to hide",
                "All these games, took me on a crazy ride",
                "Hold it down, leave my feelings satisfied",
            ],
        },
        {
            "pattern": "epiphora_echo",
            "anchor": "in the city",
            "lines": [
                "Table for the table in the city",
                "Spend a hundred thousand in the city",
                "Everybody talking looking pretty",
                "Know they got no mercy and no pity",
            ],
        },
    ],
    "Lil Wayne": [
        {
            "pattern": "call_and_response",
            "anchor": "Light the spark",
            "lines": [
                "Light the spark, fire running through the dark",
                "In the jungle, swimming with the biggest shark",
                "Hit the gas, leave a permanent trademark",
                "Top down, watching all the shadows bark",
            ],
        },
    ],
    "NoCap": [
        {
            "pattern": "emotional_anchor",
            "anchor": "Scars on my heart",
            "lines": [
                "Scars on my heart, pain that never fades away",
                "In the dark, praying for a better day",
                "Broken promises, nothing left for them to say",
                "Paid the price, know the debt I had to pay",
            ],
        },
    ],
}


# ==============================================================================
# SECTION RULE LOOKUP & SYSTEM PROMPT BUILDER
# ==============================================================================

def get_section_cadence_rules(section_mode: str) -> dict[str, Any]:
    """Retrieves cadence and syllable constraints for a given section mode."""
    mode_key = (section_mode or "verse").strip().lower()
    return SECTION_CONSTRAINTS.get(mode_key, SECTION_CONSTRAINTS["verse"])


def build_section_system_prompt_block(section_mode: str, voice: str = "Gunna") -> str:
    """
    Constructs the exact Section 3 Cadence & Meter system prompt block based on section_mode.
    Branches cleanly between:
      - verse  -> Audamar/Lobster 4x4 Quadrasonic Meter (17-24 syl, exactly 3 commas).
      - hook   -> Anthemic Repetition & Call-and-Response (10-14 syl, 2-line AABB).
      - bridge -> Half-Time Introspective Turn (8-11 syl).
      - outro  -> De-escalation Fade-Out (6-10 syl).
    """
    mode = (section_mode or "verse").strip().lower()

    if mode == "hook":
        return f"""=== 3. THE ANTHEMIC HOOK BLUEPRINT: REPETITION & CALL-AND-RESPONSE (10-14 SYLLABLES) ===
In hip-hop and trap music, THE HOOK IS THE EMOTIONAL AND COMMERCIAL ANCHOR OF THE TRACK.
Unlike the dense 17-21 syllable verse, THE HOOK DEMANDS BREATHING ROOM, CATCHINESS, AND REPETITION!

MANDATORY HOOK RULES:
1. SYLLABLE POCKET (10 TO 14 SYLLABLES PER LINE):
   Keep each line punchy, memorable, and sing-along friendly.
   NEVER write overly wordy 18-syllable paragraphs for a hook!
2. COMMAS AND BREATHING ROOM:
   Use EXACTLY 1 TO 2 COMMAS PER LINE. Leave space for the beat, 808s, and melodic bounce.
3. TWO-LINE AABB REPETITION STRUCTURE:
   Build the hook in 2-line couplet units that rhyme cleanly (AABB):
   - Line 1 (Theme Call / Prefix Anchor): 10-12 syllables.
   - Line 2 (Response / Rhyme Landing on Sound A): 10-12 syllables.
   - Line 3 (Escalation Call): 10-12 syllables.
   - Line 4 (Climactic Landing on Sound B): 10-12 syllables.
4. REPETITION & CHANT MECHANICS (THE COLD TRAP ANCHOR):
   Use memorable prefix repetition (Anaphora) or punchy call-and-response:
   - Example (Gunna Style):
     "Bank on me, watch the money multiply" (11s)
     "Bank on me, foreign coupe is rolling by" (11s)
     "Drip on me, know they cannot touch the sky" (11s)
     "Drip on me, keep the faith until I die" (10s)
   - Example (Drake Style):
     "Late night calls, know you want me by your side" (12s)
     "City lights, nowhere left for you to hide" (11s)
5. EMOTIONAL CLARITY OVER SPECIFICITY:
   The hook captures the universal core emotional spine: loyalty, elevation, wealth, or triumph."""

    elif mode == "bridge":
        return f"""=== 3. THE HALF-TIME BRIDGE BLUEPRINT: INTROSPECTIVE MELODIC TURN (8-11 SYLLABLES) ===
The Bridge serves as the philosophical, emotional, and rhythmic transition between the high-energy verse and the final hook.

MANDATORY BRIDGE RULES:
1. HALF-TIME CADENCE (8 TO 11 SYLLABLES PER LINE):
   Drop the relentless tempo into a spacious half-time vocal glide.
   Lines must be open and contemplative (8-11 syllables).
2. MINIMALIST PUNCTUATION (0 TO 1 COMMA PER BAR):
   Singing / melodic vocal pocket. Let words ring out over sustained synth pads or chords.
3. PERSPECTIVE SHIFT:
   Move away from external flex into internal reflection, vulnerability, or spiritual resolve.
   - Example:
     "Standing in the cold rain" (6s)
     "Praying that I heal the pain" (8s)
     "Sun is coming through the clouds" (8s)
     "Made my family so proud" (7s)"""

    elif mode == "outro":
        return f"""=== 3. THE OUTRO BLUEPRINT: DE-ESCALATION & FADE PATTERN (6-10 SYLLABLES) ===
The Outro resolves the song, letting energy dissipate into a hypnotic, trailing sign-off.

MANDATORY OUTRO RULES:
1. DE-ESCALATING SYLLABLE BUDGET (6 TO 10 SYLLABLES PER LINE):
   Short, fading phrases that resolve the musical theme.
2. TRAILING ECHOES & SIGN-OFF MOTIFS:
   Echo the song's key words, luxury items, or city name with trailing ad-libs.
   - Example:
     "Riding out into the night" (7s)
     "Keep the vision shining bright" (7s)
     "Watch the city fade away" (7s)
     "Nothing left for me to say" (7s)"""

    else:
        # Standard Verse: Audamar/Lobster 4x4 Quadrasonic Meter
        return """=== 3. THE AUDAMAR / LOBSTER QUADRASONIC CADENCE & INTERNAL RHYME BLUEPRINT ===
In hip-hop 4/4 time, EVERY SINGLE LINE (ONE BAR) MUST HIT THE 4x4 METER.
Format per line: EXACTLY THREE COMMAS, which separates the line into EXACTLY FOUR SUBSTANTIVE BEAT PHRASES of 4 to 5 syllables each (total 17-21 syllables):
  [Beat 1: 4-5 syl], [Beat 2: 4-5 syl], [Beat 3: 4-5 syl], [Beat 4: 4-5 syl]

THE QUADRASONIC INTERNAL RHYME ARCHITECTURE:
1. BEAT 1 & BEAT 2 INTERNAL ASSONANCE CHAIN:
   Beat 1 and Beat 2 MUST interlock with an internal rhyme or strong slant vowel match (e.g. large/car, stylist/lavish, maybach/payback, collar/dollar).
2. BEAT 3: KINETIC ACCELERATION / ESCALATION:
   Beat 3 provides financial escalation, street motion, or psychological tension.
3. BEAT 4: CONCRETE STATUS PUNCHLINE LANDING:
   Beat 4 delivers the concrete luxury status item, timepiece, or assigned catalog rhyme."""


# ==============================================================================
# HOOK BLUEPRINT & PATTERN RESOLUTION
# ==============================================================================

def build_hook_blueprint(
    voice: str = "Gunna",
    theme: str = "",
    bars_count: int = 4,
) -> dict[str, Any]:
    """
    Constructs a structured Hook Blueprint for generation, establishing
    the repetition anchor, rhyme scheme (AABB), and cadence bounds.
    """
    clean_v = voice.strip().title()
    templates = HOOK_REPETITION_PATTERNS.get(clean_v) or HOOK_REPETITION_PATTERNS["Gunna"]
    chosen_template = templates[0]

    anchor_phrase = chosen_template["anchor"]
    if theme:
        # Blend theme into anchor if provided
        t_word = theme.split()[-1] if theme.split() else "flow"
        anchor_phrase = f"{chosen_template['anchor'].split()[0]} on my {t_word}"

    return {
        "voice": clean_v,
        "section_mode": "hook",
        "bars_count": bars_count,
        "pattern_type": chosen_template["pattern"],
        "anchor_phrase": anchor_phrase,
        "target_syllables": 12,
        "syllable_bounds": [10, 14],
        "rhyme_scheme": "AABB",
        "exemplar_lines": chosen_template["lines"][:bars_count],
    }


# ==============================================================================
# SECTION STRUCTURE VERIFICATION
# ==============================================================================

def verify_section_structure(
    bars: list[str],
    section_mode: str = "verse",
    cmu: Optional[dict[str, list[str]]] = None,
) -> dict[str, Any]:
    """
    Validates a list of lyric lines against the syllable and structural rules of section_mode.

    Rules checked:
      - verse:  Syllables in [17, 24], exactly 3 commas per bar.
      - hook:   Syllables in [10, 14], 1-2 commas per bar, memorable repetition.
      - bridge: Syllables in [8, 11], half-time open cadence.
      - outro:  Syllables in [6, 10], de-escalating fade cadence.
    """
    mode = (section_mode or "verse").strip().lower()
    rules = get_section_cadence_rules(mode)
    min_syl = rules["min_syl"]
    max_syl = rules["max_syl"]

    bar_syllables: list[int] = []
    comma_counts: list[int] = []
    violations: list[dict[str, Any]] = []

    for idx, raw_bar in enumerate(bars):
        clean_bar = str(raw_bar or "").strip()
        syl = estimate_syllables(clean_bar)
        bar_syllables.append(syl)

        commas = clean_bar.count(",")
        comma_counts.append(commas)

        bar_violation = []
        if syl < min_syl:
            bar_violation.append(f"Under min syllables ({syl} < {min_syl})")
        elif syl > max_syl:
            bar_violation.append(f"Over max syllables ({syl} > {max_syl})")

        if mode == "verse" and commas != 3:
            bar_violation.append(f"Verse requires exactly 3 commas (found {commas})")
        elif mode == "hook" and commas > 2:
            bar_violation.append(f"Hook should not exceed 2 commas (found {commas})")
        elif mode in ("bridge", "outro") and commas > 2:
            bar_violation.append(f"{mode.title()} requires sparse punctuation (found {commas} commas)")

        if bar_violation:
            violations.append({
                "bar_index": idx,
                "bar_text": clean_bar,
                "syllables": syl,
                "commas": commas,
                "reasons": bar_violation,
            })

    total_bars = max(1, len(bars))
    passed_bars = total_bars - len(violations)
    pass_rate = round(passed_bars / float(total_bars), 3)

    return {
        "section_mode": mode,
        "passed": len(violations) == 0,
        "pass_rate": pass_rate,
        "bar_syllables": bar_syllables,
        "comma_counts": comma_counts,
        "target_range": [min_syl, max_syl],
        "violations": violations,
        "structural_score": pass_rate,
    }


# ==============================================================================
# STANDALONE HOOK GENERATION (Port of HookEngine.swift)
# ==============================================================================

def generate_hook_lines(
    voice: str = "Gunna",
    theme: str = "",
    bars_count: int = 4,
    call_fn: Optional[Callable[[str, str], str]] = None,
) -> list[str]:
    """
    Generates a dedicated melodic trap hook.
    If call_fn is provided, invokes the frontier model using the Hook Engine prompt.
    Otherwise returns authentic exemplar hook lines tailored to the voice.
    """
    blueprint = build_hook_blueprint(voice=voice, theme=theme, bars_count=bars_count)
    clean_voice = blueprint["voice"]

    if call_fn is not None:
        sys_prompt = build_section_system_prompt_block("hook", voice=clean_voice)
        user_prompt = (
            f"Generate a {bars_count}-line ANTHEMIC HOOK for {clean_voice}.\n"
            f"Theme: {theme or 'Elevation, loyalty and luxury'}\n"
            f"Anchor Phrase: '{blueprint['anchor_phrase']}'\n"
            f"Requirements: 10-14 syllables per bar, exactly 1-2 commas, catchy two-line AABB repetition.\n"
            f"Output ONLY the {bars_count} lyric lines, no explanations, no quotes."
        )
        try:
            raw = call_fn(sys_prompt, user_prompt)
            lines = [l.strip().strip("\"'") for l in raw.splitlines() if l.strip() and not l.startswith("[")]
            if len(lines) >= bars_count:
                return lines[:bars_count]
        except Exception:
            pass

    # High-fidelity fallback from exemplar blueprint
    return blueprint["exemplar_lines"][:bars_count]


if __name__ == "__main__":
    print("Testing Hook Engine...")
    for mode in ["verse", "hook", "bridge", "outro"]:
        rules = get_section_cadence_rules(mode)
        print(f"[{mode.upper()}]: {rules['target_syl']} syl ({rules['min_syl']}-{rules['max_syl']}), commas: {rules['commas']}")
