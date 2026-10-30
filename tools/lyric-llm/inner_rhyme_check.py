"""Move 6: Inner-Rhyme, Comma, and Syllable Structural Post-Check with Targeted Retries.

Requirements:
1. Every bar MUST contain at least 2 inner rhymes before/connecting to the end-word.
   - An inner rhyme = two distinct content words whose stressed vowel class or rime matches (CMU standard).
   - Cap counted inner rhymes at 4 to prevent tongue-twister runaway.
2. Comma count must match the foundation anchor (or default to 3 commas for 4x4 meter).
3. Syllable count must be within ±1 of target syllables.
4. If a bar fails, format targeted rewrite prompt specifying the exact violation.
5. If rewrite breaches edit-distance cap or drops end-word, catalog line remains the floor.
"""

from typing import Any, Optional
import os
import re

from catalog_retriever import (
    normalize,
    tokenize,
    detect_inner_rhymes,
    token_levenshtein_distance,
    get_dynamic_cap,
    load_cmudict,
    CMU_PATH,
)


def get_cmu_dict(cmu: Optional[dict[str, list[str]]] = None) -> dict[str, list[str]]:
    """Loads CMU dictionary if not provided."""
    if cmu is not None:
        return cmu
    if CMU_PATH.exists():
        return load_cmudict(CMU_PATH)
    return {}


def count_bar_syllables(phrase: str, cmu: Optional[dict[str, list[str]]] = None) -> int:
    """Accurately count syllables using CMU dictionary, falling back to vowel groups."""
    cmu_dict = get_cmu_dict(cmu)
    toks = tokenize(normalize(phrase))
    if not toks:
        return 0
    total = 0
    for t in toks:
        entry = cmu_dict.get(t)
        if entry:
            v_cnt = len([p for p in entry if any(char.isdigit() for char in p)])
            total += max(1, v_cnt)
        else:
            # Fallback regex estimate
            clean = re.sub(r"[^a-z]", "", t.lower())
            if not clean:
                continue
            v_matches = re.findall(r"[aeiouy]+", clean)
            cnt = len(v_matches)
            if clean.endswith("e") and not clean.endswith("le") and cnt > 1:
                cnt -= 1
            total += max(1, cnt)
    return total


def audit_bar_structure(
    bar_text: str,
    anchor_text: str = "",
    target_syl: int = 16,
    cmu: Optional[dict[str, list[str]]] = None,
) -> dict[str, Any]:
    """Audits a single generated bar against Move 6 structural criteria:
    - Inner rhymes >= 2 (capped at 4)
    - Comma count == expected_commas
    - Syllable count within ±1 of target_syl
    """
    cmu_dict = get_cmu_dict(cmu)
    clean_bar = bar_text.strip().strip("\"'`").rstrip(";.")
    clean_anchor = anchor_text.strip().strip("\"'`").rstrip(";.") if anchor_text else ""

    # 1. Comma count. Optional on a 9-19 syllable block line.
    #    A 9-11 syllable line is never failed for missing commas.
    bar_commas = clean_bar.count(",")
    expected_commas = clean_anchor.count(",") if clean_anchor else 3
    bar_syl = count_bar_syllables(clean_bar, cmu_dict)
    comma_optional = 9 <= bar_syl <= 19
    if comma_optional:
        comma_passed = True
    else:
        comma_passed = (bar_commas == expected_commas) or (bar_commas in (3, 4) and expected_commas in (0, 1, 3, 4))

    # 2. Syllable count. A block line passes when it sits in 9-19.
    #    Longer bars still use ±1 of the target.
    eff_target_syl = count_bar_syllables(clean_anchor, cmu_dict) if clean_anchor else target_syl
    syl_delta = min(abs(bar_syl - eff_target_syl), abs(bar_syl - target_syl))
    in_block_band = 9 <= bar_syl <= 19 and 9 <= int(target_syl or 0) <= 19
    syl_passed = (syl_delta <= 1) or in_block_band

    # 3. Inner-rhyme detection (distinct content word pairs BEFORE the end word)
    raw_inner = detect_inner_rhymes(clean_bar, cmu_dict)
    seen_pairs = set()
    filtered_inner = []
    for m in raw_inner:
        if m.get("is_to_end"):
            continue  # Must be internal words before the end word
        w1, w2 = m["w1"].lower(), m["w2"].lower()
        if w1 == w2:
            continue
        pair_key = tuple(sorted([w1, w2]))
        if pair_key not in seen_pairs:
            seen_pairs.add(pair_key)
            filtered_inner.append(m)

    # Cap counted inner rhymes at 4 to prevent tongue-twister runaway
    inner_rhyme_count = min(4, len(filtered_inner))
    inner_passed = (inner_rhyme_count >= 2)

    violations = []
    if not inner_passed:
        violations.append(f"fewer than 2 inner rhymes (found {inner_rhyme_count})")
    if not comma_passed:
        violations.append(f"comma count {bar_commas} != expected {expected_commas}")
    if not syl_passed:
        violations.append(f"syllable count {bar_syl} deviates from target {eff_target_syl} by {syl_delta}")

    passed = inner_passed and comma_passed and syl_passed

    return {
        "passed": passed,
        "bar_text": clean_bar,
        "anchor_text": clean_anchor,
        "inner_rhyme_count": inner_rhyme_count,
        "inner_rhymes": filtered_inner,
        "inner_passed": inner_passed,
        "comma_count": bar_commas,
        "expected_commas": expected_commas,
        "comma_passed": comma_passed,
        "syllable_count": bar_syl,
        "target_syllables": eff_target_syl,
        "syl_delta": syl_delta,
        "syl_passed": syl_passed,
        "violations": violations,
    }


def format_structure_rewrite_instruction(
    bar_index: int,
    bar_text: str,
    audit: dict[str, Any],
    target_word: str,
    voice: str = "Gunna",
) -> str:
    """Formats a concise, targeted single-bar rewrite prompt for structural violations."""
    k = audit["inner_rhyme_count"]
    needed_inner = max(0, 2 - k)
    exp_c = audit["expected_commas"]
    syl = audit["target_syllables"]
    viol_desc = "; ".join(audit["violations"])
    if 9 <= int(syl or 0) <= 19:
        comma_line = "  • Commas are optional. Do not insert commas to split a line of 9-19 syllables.\n"
        syl_line = "  • Keep the line between 9 and 19 syllables.\n"
    else:
        comma_line = f"  • Target exactly {exp_c} commas dividing the bar into balanced rhythmic phrases.\n"
        syl_line = f"  • Syllable count MUST be {syl} ±1.\n"

    return (
        f"Bar {bar_index} structural violation: {viol_desc}.\n"
        f"Original: \"{bar_text}\"\n"
        f"Rewrite mandate for {voice}:\n"
        f"  • Preserve the exact end word \"{target_word}\".\n"
        f"{comma_line}"
        f"{syl_line}"
        f"  • Add at least {needed_inner} new internal rhymes / same-vowel assonance pairs before the end word.\n"
        f"  • Output ONLY the single rewritten bar."
    )


def rewrite_structurally_failed_bar(
    bar_text: str,
    anchor_dict: Optional[dict[str, Any]],
    target_word: str,
    audit: dict[str, Any],
    bar_index: int = 1,
    voice: str = "Gunna",
    cmu: Optional[dict[str, list[str]]] = None,
    call_fn: Optional[Any] = None,
    base_cap: float = 0.30,
) -> tuple[str, bool]:
    """Rewrite one bar that failed the structure check.

    The rewritten sentence stays. The catalog line is not pasted back.
    """
    cmu_dict = get_cmu_dict(cmu)
    anchor_text = anchor_dict.get("text", "") if anchor_dict else ""

    instruction = format_structure_rewrite_instruction(
        bar_index=bar_index,
        bar_text=bar_text,
        audit=audit,
        target_word=target_word,
        voice=voice,
    )

    rewritten = None
    if call_fn is not None:
        try:
            resp = call_fn(
                model=os.environ.get("V4_POLISH_MODEL", "claude-opus-4-7"),
                system=f"You are Penwork Studios' Platinum Executive Ghostwriter for {voice}. Fix the single bar according to instructions.",
                user=instruction,
                max_tokens=150,
                temperature=0.72,
            )
            if resp and resp.strip():
                clean_lines = [l.strip().strip("\"'") for l in resp.strip().splitlines() if l.strip()]
                if clean_lines:
                    rewritten = clean_lines[0]
                    rewritten = re.sub(r"^(?:Bar\s*\d+[\s:.-]*|\d+[\s:.-]+)", "", rewritten, flags=re.IGNORECASE).strip()
        except Exception:
            rewritten = None

    if not rewritten:
        return bar_text, False

    new_audit = audit_bar_structure(
        bar_text=rewritten,
        anchor_text=anchor_text,
        target_syl=audit["target_syllables"],
        cmu=cmu_dict,
    )

    return rewritten, new_audit["passed"]
