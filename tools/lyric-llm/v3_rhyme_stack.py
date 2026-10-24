#!/usr/bin/env python3
"""Penwork Studios V3: Dynamic Multisyllabic Slant-Rhyme Stacks (M-SRS).

Features:
  1. Multisyllabic Vowel Skeleton Extraction: Extracts the last 2 to 4 syllables of a phrase.
  2. Slant Assonance Equivalence Classing: Groups reduced and near-neighbor vowels.
  3. Multisyllabic Match Depth Scoring: Detects 2-, 3-, and 4-syllable compound rhymes.
  4. Artist Multisyllabic Rhyme Banks: Curated stacks for Gunna, NoCap, Wayne, and Drake.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import List, Tuple, Dict, Any

from lyriclib import load_cmudict, tokenize, normalize

HERE = Path(__file__).resolve().parent
CMU_PATH = HERE.parent.parent / "XJournal AI" / "cmudict.txt"

# Vowel Phonetic Equivalence Classes for Modern Trap Slant Assonances
VOWEL_CLASSES = {
    # Reduced / Weak / Near-Close
    "IH": "V_weak", "IH0": "V_weak", "IH1": "V_weak", "IH2": "V_weak",
    "AH": "V_weak", "AH0": "V_weak", "AH1": "V_weak", "AH2": "V_weak",
    "AX": "V_weak", "AX0": "V_weak", "IX": "V_weak", "IX0": "V_weak",

    # Open Back / Broad Diphthong
    "AA": "V_broad", "AA0": "V_broad", "AA1": "V_broad", "AA2": "V_broad",
    "AO": "V_broad", "AO0": "V_broad", "AO1": "V_broad", "AO2": "V_broad",
    "AW": "V_broad", "AW0": "V_broad", "AW1": "V_broad", "AW2": "V_broad",

    # Front High / Long A & E
    "EY": "V_front_mid", "EY0": "V_front_mid", "EY1": "V_front_mid", "EY2": "V_front_mid",
    "AY": "V_front_low", "AY0": "V_front_low", "AY1": "V_front_low", "AY2": "V_front_low",
    "IY": "V_front_high", "IY0": "V_front_high", "IY1": "V_front_high", "IY2": "V_front_high",
    "EH": "V_front_open", "EH0": "V_front_open", "EH1": "V_front_open", "EH2": "V_front_open",
    "AE": "V_front_open", "AE0": "V_front_open", "AE1": "V_front_open", "AE2": "V_front_open",

    # Round Back / O & U
    "OW": "V_round_mid", "OW0": "V_round_mid", "OW1": "V_round_mid", "OW2": "V_round_mid",
    "UW": "V_round_high", "UW0": "V_round_high", "UW1": "V_round_high", "UW2": "V_round_high",
    "UH": "V_round_mid", "UH0": "V_round_mid", "UH1": "V_round_mid", "UH2": "V_round_mid",
    "OY": "V_round_dip", "OY0": "V_round_dip", "OY1": "V_round_dip", "OY2": "V_round_dip",

    # R-colored Vowels
    "ER": "V_rhot", "ER0": "V_rhot", "ER1": "V_rhot", "ER2": "V_rhot",
}

# Curated Artist Multisyllabic Rhyme Stacks
ARTIST_MULTISYLLABIC_BANKS = {
    "Gunna": {
        "2_syl": [
            ("drip clean", "slip seen"),
            ("young wunna", "done run a"),
            ("blue cash", "new dash"),
            ("rich vibe", "slick glide"),
        ],
        "3_syl": [
            ("stacking up plates", "locking the gates", "counting the states"),
            ("flooded the clock", "out of the box", "heavy on locks"),
            ("maximum withdraws", "blue Audemars", "smoke the cigar"),
        ],
        "4_syl": [
            ("diamonds on the face", "foreign in the space", "never in the race"),
            ("pull up in the wraith", "stepping in the place", "stacking up the safe"),
        ],
    },
    "NoCap": {
        "2_syl": [
            ("no cap", "cold trap"),
            ("steel gun", "real one"),
            ("deep pain", "street rain"),
            ("bad news", "sad blues"),
        ],
        "3_syl": [
            ("pain in the rain", "plane in the plain", "stain on the brain"),
            ("peace with the piece", "lease with a crease", "feast in the east"),
            ("sitting in the cell", "got a lot to sell", "rings on the bell"),
        ],
        "4_syl": [
            ("scars on the soul", "diamonds in the roll", "heavier the toll"),
            ("judge in the court", "never play the sport", "bleeding at the port"),
        ],
    },
    "Lil Wayne": {
        "2_syl": [
            ("lighter flick", "tighter grip"),
            ("big cash", "quick dash"),
            ("red beast", "dead feast"),
        ],
        "3_syl": [
            ("flow so electric", "grow with the metric", "blow up eccentric"),
            ("fire in the booth", "higher in the roof", "buyer of the truth"),
        ],
        "4_syl": [
            ("killing every track", "never looking back", "heavy with the stack"),
            ("monster in the dark", "swimming with the shark", "walking through the park"),
        ],
    },
    "Drake": {
        "2_syl": [
            ("late night", "great sight"),
            ("my side", "high tide"),
            ("old friend", "cold bend"),
        ],
        "3_syl": [
            ("texting on the phone", "left me all alone", "sitting on the throne"),
            ("drinking on the wine", "looking so divine", "running out of time"),
        ],
        "4_syl": [
            ("living in the city", "pity for the pretty", "keeping it committee"),
            ("never had to worry", "leaving in a hurry", "moving in a flurry"),
        ],
    },
}


def get_phrase_vowels(phrase: str, cmu: dict) -> list[str]:
    """Extract phonemic vowel sequence with stress for all tokens in phrase."""
    tokens = tokenize(normalize(phrase))
    vowels = []
    for t in tokens:
        entry = cmu.get(t)
        if entry:
            w_vowels = [p for p in entry if any(c.isdigit() for c in p)]
            vowels.extend(w_vowels)
        else:
            # Fallback vowel cluster estimation
            groups = re.findall(r"[aeiouy]+", t)
            for g in groups:
                vowels.append("AH1")
    return vowels


def analyze_multisyllabic_stack(phrase1: str, phrase2: str, cmu: dict = None) -> dict:
    """Analyze the multisyllabic slant-rhyme depth and phonetic match between two phrases."""
    if cmu is None:
        cmu = load_cmudict(CMU_PATH) if CMU_PATH.exists() else {}

    v1 = get_phrase_vowels(phrase1, cmu)
    v2 = get_phrase_vowels(phrase2, cmu)

    if not v1 or not v2:
        return {"depth": 0, "type": "none", "v1": [], "v2": [], "matched_vowels": []}

    # Evaluate trailing vowel match depth (pure vs slant)
    pure_depth = 0
    slant_depth = 0
    matched_pure = []
    matched_slant = []

    for a, b in zip(reversed(v1), reversed(v2)):
        a_base = a.rstrip("012")
        b_base = b.rstrip("012")
        a_class = VOWEL_CLASSES.get(a, a_base)
        b_class = VOWEL_CLASSES.get(b, b_base)

        if a == b:
            pure_depth += 1
            matched_pure.append(a)
        elif a_base == b_base or a_class == b_class:
            slant_depth += 1
            matched_slant.append(f"{a}~{b}")
        else:
            break

    total_depth = pure_depth + slant_depth
    stack_type = "none"
    if total_depth >= 4:
        stack_type = "diamond_4syl"
    elif total_depth == 3:
        stack_type = "compound_3syl"
    elif total_depth == 2:
        stack_type = "double_2syl"
    elif total_depth == 1:
        stack_type = "single_1syl"

    return {
        "depth": total_depth,
        "pure_depth": pure_depth,
        "slant_depth": slant_depth,
        "type": stack_type,
        "v1": v1,
        "v2": v2,
        "matched_pure": list(reversed(matched_pure)),
        "matched_slant": list(reversed(matched_slant)),
    }


def get_artist_multisyllabic_prompts(voice: str) -> str:
    """Format multisyllabic guidance for system prompts."""
    artist_data = ARTIST_MULTISYLLABIC_BANKS.get(voice) or ARTIST_MULTISYLLABIC_BANKS["Gunna"]
    lines = [f"=== MULTISYLLABIC SLANT-RHYME STACKS ({voice}) ==="]
    lines.append("Layer 2-to-4 syllable compound rhyme stacks into Beat 3 & Beat 4:")
    for group_name, stacks in artist_data.items():
        label = group_name.replace("_", " ").upper()
        lines.append(f"- {label}:")
        for s in stacks[:3]:
            lines.append(f"    • {' / '.join(s)}")
    return "\n".join(lines)


if __name__ == "__main__":
    cmu = load_cmudict(CMU_PATH) if CMU_PATH.exists() else {}
    test_pairs = [
        ("Diamonds on the face", "Foreign in the space"),
        ("Stacking up plates", "Locking the gates"),
        ("Maximum withdraws", "Blue Audemars"),
        ("Hop in the foreign", "Clock in the morning"),
        ("Just a deal", "Keep it steel"),
    ]
    print("[Penwork V3 M-SRS Engine] Testing Multisyllabic Slant Depth:\n")
    for p1, p2 in test_pairs:
        res = analyze_multisyllabic_stack(p1, p2, cmu)
        print(f"\"{p1}\" vs \"{p2}\"")
        print(f"  -> Stack Depth: {res['depth']} syllables ({res['type']}) | Pure: {res['pure_depth']}, Slant: {res['slant_depth']}")
        print(f"  -> Matches: {res['matched_pure']} {res['matched_slant']}\n")
