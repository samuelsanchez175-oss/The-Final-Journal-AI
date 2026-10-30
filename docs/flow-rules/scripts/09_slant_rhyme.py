#!/usr/bin/env python3
"""Slant / assonance rhyme detector.

Three rules, tried in order; the first that matches wins:
  EXACT    — CMU end-rime tuples equal (last stressed vowel + following phones)
  SLANT    — last stressed vowel equal AND the final consonant classes match
             (same manner-of-articulation group: stops / nasals / fricatives /
             liquids / etc.), OR last stressed vowel + any following vowel-less
             tail that shares the final consonant group.
  ASSONANCE— last stressed vowel only.
  NONE     — otherwise.

Fallback for OOV: strip to the last vowel+coda cluster of the word's letters;
treat matching clusters as SLANT. Pure consonant-only tails fall through to
NONE. Everything tagged ESTIMATE because CMU is incomplete and consonant
grouping is a heuristic.

Writes docs/flow-rules/slant_rhyme_recompute.json and
     docs/flow-rules/slant_rhyme_examples.md
"""
from __future__ import annotations

import collections
import json
import random
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
LLM = REPO / "tools" / "lyric-llm"
OUT = REPO / "docs" / "flow-rules"
sys.path.insert(0, str(LLM))

from lyriclib import load_cmudict  # type: ignore

CMU = load_cmudict(REPO / "XJournal AI" / "cmudict.txt")

_W = re.compile(r"[A-Za-z']+")

CONS_GROUPS = {
    # ARPAbet consonants grouped by manner
    "stop": {"P", "B", "T", "D", "K", "G"},
    "fric": {"F", "V", "S", "Z", "SH", "ZH", "TH", "DH", "HH"},
    "nasal": {"M", "N", "NG"},
    "liquid": {"L", "R"},
    "glide": {"W", "Y"},
    "affric": {"CH", "JH"},
}
PHON_TO_GROUP = {ph: g for g, phones in CONS_GROUPS.items() for ph in phones}


def _phones(word: str) -> list[str]:
    w = re.sub(r"[^A-Za-z']", "", word).lower()
    entries = CMU.get(w)
    if not entries:
        return []
    return list(entries)


def _stressed_tail(ph: list[str]) -> list[str]:
    """From the LAST stressed vowel through the end."""
    for i in range(len(ph) - 1, -1, -1):
        if any(c.isdigit() for c in ph[i]):
            return ph[i:]
    # no stressed vowel → fall back to last vowel-ish
    for i in range(len(ph) - 1, -1, -1):
        if re.match(r"[AEIOU]", ph[i]):
            return ph[i:]
    return ph


def _vowel_only(tail: list[str]) -> str:
    """Strip stress markers from the vowel of the tail."""
    for seg in tail:
        if re.match(r"[AEIOU]", seg):
            return re.sub(r"\d", "", seg)
    return ""


def _consonant_tail(tail: list[str]) -> list[str]:
    out = []
    for seg in tail[1:]:  # skip the vowel itself
        if not re.match(r"[AEIOU]", seg):
            out.append(seg)
    return out


def _group_tail(cons: list[str]) -> tuple[str, ...]:
    return tuple(PHON_TO_GROUP.get(c, c) for c in cons)


def rhyme_type(a: str, b: str) -> str:
    pa, pb = _phones(a), _phones(b)
    if not pa or not pb:
        return _letter_fallback(a, b)
    ta, tb = _stressed_tail(pa), _stressed_tail(pb)
    if ta == tb and ta:
        return "exact"
    va, vb = _vowel_only(ta), _vowel_only(tb)
    if not va or not vb:
        return "none"
    ca, cb = _consonant_tail(ta), _consonant_tail(tb)
    ga, gb = _group_tail(ca), _group_tail(cb)
    if va == vb and ga == gb and (ga or gb):
        return "slant"
    if va == vb:
        return "assonance"
    return "none"


_LETTER_VOWELS = "aeiouy"


def _letter_fallback(a: str, b: str) -> str:
    def tail(w: str) -> str:
        w = re.sub(r"[^A-Za-z']", "", (w or "").lower())
        # last vowel + everything after
        for i in range(len(w) - 1, -1, -1):
            if w[i] in _LETTER_VOWELS:
                return w[i:]
        return ""
    ta, tb = tail(a), tail(b)
    if ta and ta == tb:
        return "slant"  # letter-level agreement
    # vowel-only match
    va = next((c for c in ta if c in _LETTER_VOWELS), "")
    vb = next((c for c in tb if c in _LETTER_VOWELS), "")
    if va and va == vb:
        return "assonance"
    return "none"


def _end_word(line: str, strip_adlib: bool = True) -> str:
    s = (line or "").strip()
    if strip_adlib:
        # drop parentheticals and trailing ad-libs (match 08_adlib_strip.py)
        s = re.sub(r"\([^)]*\)", "", s)
        s = re.sub(r"\[[^\]]*\]", "", s)
        trail = {"yeah", "uh", "woo", "huh", "what", "skrrt", "skrr", "ayy",
                 "ooh", "woah", "oh", "nah", "hey", "mm", "mmm", "yuh", "yah",
                 "aye", "ay", "ye"}
        while True:
            toks = _W.findall(s)
            if not toks or toks[-1].lower().strip("'") not in trail:
                break
            m = re.search(r"[A-Za-z']+[\s,!?.;:—-]*$", s)
            if not m:
                break
            s = s[:m.start()].rstrip(" ,.!?;:—-")
    t = _W.findall(s)
    return t[-1].lower() if t else ""


def main() -> int:
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna"]
    # group by song for adjacent pair analysis (lines in rowid order)
    by_song: dict[tuple, list[dict]] = {}
    for r in solo:
        by_song.setdefault((r["artist"], r["song"]), []).append(r)
    totals = collections.Counter()
    examples: dict[str, list[dict]] = {"exact": [], "slant": [], "assonance": [], "none": []}
    rng = random.Random(20261030)
    pairs_for_sample: list[tuple[str, str, str, str, str]] = []  # (kind, song, a_line, b_line, pair_words)
    for (artist, song), seq in by_song.items():
        ends = [_end_word(r["line"]) for r in seq]
        for i in range(1, len(ends)):
            a, b = ends[i - 1], ends[i]
            if not a or not b:
                continue
            k = rhyme_type(a, b)
            totals[k] += 1
            pairs_for_sample.append((k, song, seq[i - 1]["line"], seq[i]["line"],
                                     f"{a} / {b}"))
    total_pairs = sum(totals.values())
    rates = {k: round(v / max(total_pairs, 1), 4) for k, v in totals.items()}
    # 10 random examples per kind
    by_kind: dict[str, list[tuple]] = collections.defaultdict(list)
    for row in pairs_for_sample:
        by_kind[row[0]].append(row)
    for k in ("exact", "slant", "assonance", "none"):
        if by_kind.get(k):
            picks = rng.sample(by_kind[k], min(10, len(by_kind[k])))
            examples[k] = [{"song": s, "a": a, "b": b, "pair": pw}
                           for _, s, a, b, pw in picks]
    stats = {
        "pairs_examined": total_pairs,
        "counts": dict(totals),
        "rates": rates,
    }
    (OUT / "slant_rhyme_recompute.json").write_text(json.dumps({**stats, "examples": examples},
                                                                 indent=2, ensure_ascii=False))
    md = ["# Slant / assonance rhyme — recompute", "",
          f"Pairs examined: {total_pairs}", "",
          "| category | count | rate | definition |",
          "| --- | ---:| ---:| --- |",
          f"| exact | {totals['exact']} | {rates.get('exact', 0)} | CMU rime equal (last stressed vowel + full tail) |",
          f"| slant | {totals['slant']} | {rates.get('slant', 0)} | same vowel + same consonant-group tail |",
          f"| assonance | {totals['assonance']} | {rates.get('assonance', 0)} | same vowel only |",
          f"| none | {totals['none']} | {rates.get('none', 0)} | no match |",
          "", "ESTIMATE: CMU is incomplete; OOV words fall back to a letter-level rule. "
          "Consonant grouping is a manner-of-articulation heuristic.", ""]
    for k in ("exact", "slant", "assonance", "none"):
        md.append(f"## 10 random `{k}` pairs — spot-check")
        md.append("")
        for ex in examples[k]:
            md.append(f"- `[{ex['song']}]`")
            md.append(f"  - A: {ex['a']!r}")
            md.append(f"  - B: {ex['b']!r}")
            md.append(f"  - pair: {ex['pair']}")
        md.append("")
    (OUT / "slant_rhyme_examples.md").write_text("\n".join(md) + "\n")
    print(f"pairs={total_pairs}  exact={rates.get('exact')}  slant={rates.get('slant')}  "
          f"assonance={rates.get('assonance')}  none={rates.get('none')}")
    print(f"wrote slant_rhyme_recompute.json + slant_rhyme_examples.md")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
