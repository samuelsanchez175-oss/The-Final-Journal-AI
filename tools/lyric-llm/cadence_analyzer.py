"""tools/lyric-llm/cadence_analyzer.py
====================================
Cadence & Syllable Pocket Analyzer with ABAB Inner-Rhyme Verification.

Engineered for Penwork Studios Frontier v4 rap flow standards:
- Each bar/segment structured with ~4 commas (4 to 5 distinct pockets).
- Syllable uniformity maintained across all comma pockets (4 to 5 syllables each).
- ABAB inner-rhyme level verification (Segment 0 ~ Segment 2, Segment 1 ~ Segment 3).
- Exposes structured segment halves and internal rhyme pairs for Sparkler Rater.
"""

from __future__ import annotations

import re
from typing import Optional, Sequence

import lyriclib
import polish


def normalize_slang_word(word: str) -> str:
    """Normalize rap slang, gerund truncations, and punctuation for CMU lookup."""
    if not word:
        return ""
    clean = re.sub(r"^[^a-zA-Z0-9']+|[^a-zA-Z0-9']+$", "", word).lower()
    # Normalize gerund 'in' / 'in'' to 'ing' (e.g., 'mornin'' -> 'morning', 'rollin'' -> 'rolling')
    if len(clean) >= 4 and clean.endswith("in'"):
        clean = clean[:-3] + "ing"
    elif len(clean) >= 5 and clean.endswith("in") and not clean.endswith("chin") and not clean.endswith("spin"):
        clean = clean + "g"
    return clean.replace("'", "")


def is_hiphop_rhyme(w1: str, w2: str, cmu: Optional[dict] = None) -> bool:
    """Accurately detects pure rhymes and hip-hop slant assonance between two words."""
    if not w1 or not w2:
        return False
    if cmu is None:
        cmu = polish._get_cmu()

    n1 = normalize_slang_word(w1)
    n2 = normalize_slang_word(w2)
    if not n1 or not n2:
        return False
    # CRITICAL: A word cannot rhyme with itself in hip-hop (identity rhyme defect)
    if n1 == n2:
        return False
    if len(n1) >= 4 and len(n2) >= 4 and (n1.startswith(n2) or n2.startswith(n1)):
        return False

    r1 = polish.end_rime(n1, cmu)
    r2 = polish.end_rime(n2, cmu)
    if r1 and r2 and r1 == r2:
        return True

    p1 = cmu.get(n1)
    p2 = cmu.get(n2)
    if not p1 or not p2:
        # Fallback suffix check for unknown slang
        if len(n1) >= 3 and len(n2) >= 3:
            return n1[-3:] == n2[-3:] or n1[-2:] == n2[-2:]
        return False

    v1 = [p for p in p1 if any(c.isdigit() for c in p)]
    v2 = [p for p in p2 if any(c.isdigit() for c in p)]

    # If one is monosyllabic and the other is multisyllabic,
    # the multisyllable word MUST be stressed on the final syllable (e.g. green ~ Ce-line)
    if len(v1) == 1 and len(v2) > 1:
        if not any(c in "12" for c in v2[-1]):
            return False
    elif len(v2) == 1 and len(v1) > 1:
        if not any(c in "12" for c in v1[-1]):
            return False

    # Check via lyriclib hip-hop vowel classes or identical rime onset
    if lyriclib.words_rhyme(n1, n2, cmu):
        return True
    if r1 and r2 and r1[0] == r2[0] and len(v1) == len(v2):
        return True

    # Multi-syllabic slant suffix
    if len(n1) >= 4 and len(n2) >= 4 and (n1[-3:] == n2[-3:] or n1[-2:] == n2[-2:]):
        return True

    return False


def partition_into_cadence_pockets(
    line: str,
    cmu: Optional[dict] = None,
    target_pockets: int = 4,
    target_syl_per_pocket: int = 4,
) -> list[str]:
    """Partitions a line into balanced rhythmic pockets separated by commas.

    If the line already has 3 or 4 commas separating substantive phrases,
    those segments are preserved and trimmed.
    If the line is run-on or has uneven segments, rhythmically balances
    them into 4 distinct 4-to-5 syllable pockets.
    """
    if cmu is None:
        cmu = polish._get_cmu()

    clean = line.strip().strip("\"'`").rstrip(",;.")
    raw_parts = [p.strip() for p in clean.split(",") if p.strip()]

    # If already has 4-5 well-formed parts with substantive word count, keep them
    if 4 <= len(raw_parts) <= 5 and all(len(p.split()) >= 2 for p in raw_parts):
        return raw_parts

    # Fallback to quadrasonic beat group balancing in polish.py
    bg = polish.parse_beat_groups(clean, cmu)
    groups = [g for g in bg.get("groups", []) if g.strip()]
    if len(groups) == 4 and all(bool(g) for g in groups):
        return groups

    # Heuristic word chunking if beat groups didn't produce 4 parts
    words = clean.split()
    if len(words) <= target_pockets:
        return [clean]

    chunk_size = max(2, len(words) // target_pockets)
    chunks = []
    curr = []
    for w in words:
        curr.append(w)
        if len(curr) >= chunk_size and len(chunks) < target_pockets - 1:
            chunks.append(" ".join(curr))
            curr = []
    if curr:
        chunks.append(" ".join(curr))
    return chunks


def analyze_bar_cadence(line: str, cmu: Optional[dict] = None) -> dict:
    """Comprehensive analysis of bar comma segments, syllable count per segment,

    isochronous pacing, and ABAB inner-rhyme density.
    """
    if cmu is None:
        cmu = polish._get_cmu()

    pockets = partition_into_cadence_pockets(line, cmu)
    segments = []
    for p in pockets:
        syl = polish.count_cmu_syllables(p, cmu)
        toks = [t for t in re.findall(r"[a-zA-Z0-9']+", p) if t]
        end_w = toks[-1] if toks else ""
        segments.append({
            "text": p,
            "syllables": syl,
            "end_word": end_w,
            "norm_word": normalize_slang_word(end_w),
        })

    syl_list = [s["syllables"] for s in segments]
    total_syl = sum(syl_list)
    syl_pattern = "+".join(str(s) for s in syl_list)

    # Comma count in formatted delivery
    formatted_line = ", ".join(s["text"] for s in segments)
    comma_count = len(segments) - 1

    # Syllable uniformity ("if 4 or 5 syl per comma, continue that out")
    is_isochronous = False
    if segments:
        avg_syl = total_syl / len(segments)
        # Check if all segments are tightly within 4-5 syllables (or range <= 2)
        in_pocket_range = all(3 <= s <= 6 for s in syl_list)
        is_isochronous = in_pocket_range and (max(syl_list) - min(syl_list) <= 2)

    # ABAB Inner-Rhyme Level Verification
    abab_detected = False
    aabb_detected = False
    rhyme_type = "NONE"
    internal_pairs = []

    if len(segments) >= 4:
        w0 = segments[0]["end_word"]
        w1 = segments[1]["end_word"]
        w2 = segments[2]["end_word"]
        w3 = segments[3]["end_word"]

        rhyme_a = is_hiphop_rhyme(w0, w2, cmu)
        rhyme_b = is_hiphop_rhyme(w1, w3, cmu)

        if rhyme_a and rhyme_b:
            abab_detected = True
            rhyme_type = "ABAB"
            internal_pairs.append([w0, w2])
            internal_pairs.append([w1, w3])
        elif rhyme_a:
            rhyme_type = "A_ONLY"
            internal_pairs.append([w0, w2])
        elif rhyme_b:
            rhyme_type = "B_ONLY"
            internal_pairs.append([w1, w3])
        else:
            # Check AABB
            aabb_1 = is_hiphop_rhyme(w0, w1, cmu)
            aabb_2 = is_hiphop_rhyme(w2, w3, cmu)
            if aabb_1 and aabb_2:
                aabb_detected = True
                rhyme_type = "AABB"
                internal_pairs.append([w0, w1])
                internal_pairs.append([w2, w3])
            elif aabb_1:
                internal_pairs.append([w0, w1])
            elif aabb_2:
                internal_pairs.append([w2, w3])

        # If 5 segments, check if 5th pocket also ties in
        if len(segments) >= 5:
            w4 = segments[4]["end_word"]
            if is_hiphop_rhyme(w1, w4, cmu) or is_hiphop_rhyme(w3, w4, cmu):
                internal_pairs.append([w1, w4])

    # Compute overall cadence quality score (0.0 to 1.0)
    score = 0.50
    if len(segments) >= 4:
        score += 0.15
    if is_isochronous:
        score += 0.20
    if abab_detected:
        score += 0.15
    elif aabb_detected:
        score += 0.10

    return {
        "formatted_line": formatted_line,
        "segments": segments,
        "comma_count": comma_count,
        "total_syllables": total_syl,
        "syl_pattern": syl_pattern,
        "is_isochronous": is_isochronous,
        "abab_detected": abab_detected,
        "aabb_detected": aabb_detected,
        "rhyme_type": rhyme_type,
        "internal_pairs": internal_pairs,
        "cadence_score": round(score, 3),
    }


FORBIDDEN_CORNY_WORDS = {"hospital", "optical", "obstacle", "impossible", "lobster"}


def audit_verse_cadence_and_rhymes(bars: list[str], cmu: Optional[dict] = None) -> dict:
    """Audits an entire verse for cadence uniformity, ABAB inner rhymes, terminal duplicate words,
    and corny/robotic slant rhymes.
    """
    if cmu is None:
        cmu = polish._get_cmu()

    bar_cadences = []
    end_words = []
    norm_end_words = []
    defects = []
    corny_found = []

    for i, bar in enumerate(bars):
        c_res = analyze_bar_cadence(bar, cmu)
        bar_cadences.append(c_res)
        toks = [t for t in re.findall(r"[a-zA-Z0-9']+", bar) if t]
        ew = toks[-1] if toks else ""
        norm_ew = normalize_slang_word(ew)
        end_words.append(ew)
        norm_end_words.append(norm_ew)

        # Check corny words anywhere in the bar
        for t in toks:
            t_norm = normalize_slang_word(t)
            if t_norm in FORBIDDEN_CORNY_WORDS:
                defects.append(f"Bar {i+1}: Forbidden/corny word '{t}' detected")
                if t_norm not in corny_found:
                    corny_found.append(t_norm)

    # Check terminal end-word duplicates across the verse
    duplicate_end_words = []
    seen_ends = {}
    for i, norm_w in enumerate(norm_end_words):
        if not norm_w:
            continue
        if norm_w in seen_ends:
            prev_i = seen_ends[norm_w]
            dup_msg = f"Duplicate terminal word '{norm_w}' on Bar {prev_i+1} and Bar {i+1}"
            defects.append(dup_msg)
            if norm_w not in duplicate_end_words:
                duplicate_end_words.append(norm_w)
        else:
            seen_ends[norm_w] = i

    # Check couplet rhyme connectivity
    couplet_rhymes = []
    couplet_count = len(bars) // 2
    for c_idx in range(couplet_count):
        i1 = c_idx * 2
        i2 = i1 + 1
        w1 = end_words[i1]
        w2 = end_words[i2]
        is_rhyme = is_hiphop_rhyme(w1, w2, cmu)
        is_identical = (norm_end_words[i1] == norm_end_words[i2])
        if is_identical:
            defects.append(f"Couplet {c_idx+1} (Bars {i1+1}-{i2+1}): Identity rhyme defect ('{w1}' rhymed with '{w2}')")
        elif not is_rhyme:
            defects.append(f"Couplet {c_idx+1} (Bars {i1+1}-{i2+1}): Non-rhyming pair ('{w1}' and '{w2}')")

        couplet_rhymes.append({
            "couplet_index": c_idx,
            "bars": [i1, i2],
            "pair": [w1, w2],
            "rhymes": is_rhyme and not is_identical,
            "is_identical": is_identical,
        })

    avg_score = (sum(b["cadence_score"] for b in bar_cadences) / len(bar_cadences)) if bar_cadences else 0.0
    passed = len(defects) == 0 and all(b["is_isochronous"] for b in bar_cadences)

    return {
        "passed": passed,
        "defects": defects,
        "bar_cadences": bar_cadences,
        "end_words": end_words,
        "duplicate_end_words": duplicate_end_words,
        "corny_words_found": corny_found,
        "couplet_rhymes": couplet_rhymes,
        "overall_score": round(avg_score, 3),
    }
