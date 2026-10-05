"""Wrap-count, inner rhyme, imagery — the ranking the scorecard was missing."""

from __future__ import annotations

from metaphors import imagery_words
from rhyme import WORD_RE, classify_rhyme, strip_adlib

FUNCTION = {
    "a", "an", "the", "of", "to", "in", "on", "and", "or", "but", "for", "with", "at",
    "i", "i'm", "im", "my", "me", "you", "that", "this", "it", "is", "be",
}


def syllable_count(line: str, cmu: dict[str, list[str]]) -> int:
    """Count spoken syllables via CMU nuclei (same idea as the catalog recalc)."""
    total = 0
    for raw in WORD_RE.findall(strip_adlib(line).lower()):
        w = raw.replace("'", "")
        phones = cmu.get(raw) or cmu.get(w)
        if phones:
            n = sum(1 for p in phones if p[-1:].isdigit())
            total += max(1, n)
            continue
        n = 0
        prev = False
        for ch in w:
            v = ch in "aeiouy"
            if v and not prev:
                n += 1
            prev = v
        total += max(1, n)
    return max(total, 1)


def inner_rhyme_score(line: str, cmu: dict[str, list[str]]) -> int:
    """Internal rhymes + repeats + alliteration. End-word echoing an earlier punch counts."""
    toks = [t.lower() for t in WORD_RE.findall(strip_adlib(line)) if t.lower() not in FUNCTION]
    if len(toks) < 2:
        return 0
    score = 0
    for i, a in enumerate(toks):
        for b in toks[i + 1 :]:
            if a == b:
                score += 2
                continue
            kind = classify_rhyme(a, b, cmu)
            if kind == "perfect":
                score += 3
            elif kind == "slant":
                score += 2
    for i in range(len(toks) - 1):
        if toks[i] and toks[i + 1] and toks[i][0] == toks[i + 1][0] and len(toks[i]) > 2:
            score += 1
    return score


def imagery_score(line: str) -> int:
    n = len(imagery_words(line, limit=6))
    from rhyme import WORD_RE, strip_adlib
    for t in WORD_RE.findall(strip_adlib(line).lower()):
        if t in FUNCTION:
            continue
        if len(t) >= 6:
            n += 1
    return n


def wrap_distance(hit_syl: int, host_syl: int) -> int:
    return abs(int(hit_syl) - int(host_syl))
