#!/usr/bin/env python3
"""Rhyme anchored on the last STRESSED syllable, not the end word.

For every line:
  1. Strip parentheticals + trailing ad-libs.
  2. Walk tokens right-to-left; for each token get CMU phones.
  3. Find the last primary-stressed vowel across the (word_index, phone_index)
     grid. The anchor tail is [that stressed vowel, through end of line].
     This includes any unstressed suffix words (it/me/up/you/out/that/em).
  4. If no primary-stressed vowel exists in CMU-covered tokens, fall back to
     the last secondary stress, then to the last end-word CMU rime, then to
     the letter-based tail.

Classifies adjacent-pair rhyme on these anchors:
  EXACT     — anchor tuple equal
  SLANT     — same stressed vowel + same consonant-group tail
  ASSONANCE — same stressed vowel only
  NONE      — else.

Also recomputes the 4-bar single-rime rate using the anchor.

Writes docs/flow-rules/rhyme_anchor_recompute.json and appends an "Anchor"
section with 10 examples per category to slant_rhyme_examples.md.
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
ADLIBS = {"yeah", "uh", "woo", "huh", "what", "skrrt", "skrr", "ayy",
          "ooh", "woah", "oh", "nah", "hey", "mm", "mmm", "yuh", "yah",
          "aye", "ay", "ye"}

CONS_GROUPS = {
    "stop": {"P", "B", "T", "D", "K", "G"},
    "fric": {"F", "V", "S", "Z", "SH", "ZH", "TH", "DH", "HH"},
    "nasal": {"M", "N", "NG"},
    "liquid": {"L", "R"},
    "glide": {"W", "Y"},
    "affric": {"CH", "JH"},
}
PHON_TO_GROUP = {ph: g for g, phones in CONS_GROUPS.items() for ph in phones}


def strip_adlibs(line: str) -> str:
    s = re.sub(r"\([^)]*\)|\[[^\]]*\]", "", line or "")
    while True:
        s = s.rstrip(" ,.!?;:—-")
        toks = _W.findall(s)
        if not toks:
            break
        if toks[-1].lower().strip("'") not in ADLIBS:
            break
        m = re.search(r"[A-Za-z']+[\s,!?.;:—-]*$", s)
        if not m:
            break
        s = s[:m.start()].rstrip(" ,.!?;:—-")
    return s.strip()


def _phones(word: str) -> list[str]:
    w = re.sub(r"[^A-Za-z']", "", (word or "").lower())
    return list(CMU.get(w) or [])


def _is_stressed(seg: str, level: str = "1") -> bool:
    return seg.endswith(level)


def _is_vowel(seg: str) -> bool:
    return bool(re.match(r"[AEIOU]", seg))


def anchor_tail(line: str) -> list[str]:
    """Walk tokens right-to-left; find last primary-stress vowel; return
    [that vowel ... end-of-line's last phone] including unstressed suffix.
    """
    tokens = _W.findall(line or "")
    if not tokens:
        return []
    # build (token_idx, phones) list
    all_phones: list[tuple[int, int, str]] = []
    for ti, t in enumerate(tokens):
        for pi, p in enumerate(_phones(t)):
            all_phones.append((ti, pi, p))
    if not all_phones:
        return []
    # scan right-to-left for primary stress on a vowel
    for i in range(len(all_phones) - 1, -1, -1):
        _, _, p = all_phones[i]
        if _is_vowel(p) and p.endswith("1"):
            return [ph for _, _, ph in all_phones[i:]]
    # secondary stress fallback
    for i in range(len(all_phones) - 1, -1, -1):
        _, _, p = all_phones[i]
        if _is_vowel(p) and p.endswith("2"):
            return [ph for _, _, ph in all_phones[i:]]
    # any vowel fallback
    for i in range(len(all_phones) - 1, -1, -1):
        _, _, p = all_phones[i]
        if _is_vowel(p):
            return [ph for _, _, ph in all_phones[i:]]
    return [ph for _, _, ph in all_phones[-3:]]


def classify_anchor(a: list[str], b: list[str]) -> str:
    if not a or not b:
        return "none"
    if tuple(a) == tuple(b):
        return "exact"
    def vowel(seq):
        for p in seq:
            if _is_vowel(p):
                return re.sub(r"\d", "", p)
        return ""
    def cons_group_tail(seq):
        out = []
        hit_v = False
        for p in seq:
            if _is_vowel(p):
                if hit_v:
                    out.append(PHON_TO_GROUP.get(p, p))
                else:
                    hit_v = True
            else:
                out.append(PHON_TO_GROUP.get(p, p))
        return tuple(out)
    va, vb = vowel(a), vowel(b)
    if va and va == vb:
        if cons_group_tail(a) == cons_group_tail(b):
            return "slant"
        return "assonance"
    return "none"


def anchor_label(tail: list[str]) -> str:
    """Human-readable: STRESSED-vowel + joined phones, e.g. 'IH1-P-T-IH0-T'."""
    return "-".join(tail) if tail else "—"


def main() -> int:
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna"]
    by_song: dict[tuple, list[dict]] = {}
    for r in solo:
        by_song.setdefault((r["artist"], r["song"]), []).append(r)

    totals = collections.Counter()
    four_total = 0; four_one = 0
    examples: dict[str, list[tuple]] = collections.defaultdict(list)
    for (artist, song), seq in by_song.items():
        stripped = [strip_adlibs(r["line"]) for r in seq]
        anchors = [anchor_tail(s) for s in stripped]
        for i in range(1, len(anchors)):
            a, b = anchors[i - 1], anchors[i]
            if not a or not b:
                totals["none"] += 1
                continue
            k = classify_anchor(a, b)
            totals[k] += 1
            examples[k].append((song, stripped[i - 1], stripped[i],
                                anchor_label(a), anchor_label(b)))
        for i in range(0, len(anchors) - 3, 4):
            blk = anchors[i:i + 4]
            non_empty = [tuple(x) for x in blk if x]
            if non_empty:
                four_total += 1
                if all(x == non_empty[0] for x in non_empty):
                    four_one += 1
    total_pairs = sum(totals.values())
    rates = {k: round(v / max(total_pairs, 1), 4) for k, v in totals.items()}
    four_rate = round(four_one / max(four_total, 1), 4)

    # Old-vs-new load
    old = json.loads((OUT / "slant_rhyme_recompute.json").read_text())
    old_counts = old["counts"]
    old_pairs = old["pairs_examined"]
    old_rates = old["rates"]

    report = {
        "pairs_examined_old": old_pairs,
        "pairs_examined_new_anchor": total_pairs,
        "exact":     {"old": old_rates.get("exact", 0),     "new": rates.get("exact", 0),
                      "old_count": old_counts.get("exact", 0), "new_count": totals.get("exact", 0)},
        "slant":     {"old": old_rates.get("slant", 0),     "new": rates.get("slant", 0),
                      "old_count": old_counts.get("slant", 0), "new_count": totals.get("slant", 0)},
        "assonance": {"old": old_rates.get("assonance", 0), "new": rates.get("assonance", 0),
                      "old_count": old_counts.get("assonance", 0), "new_count": totals.get("assonance", 0)},
        "none":      {"old": old_rates.get("none", 0),      "new": rates.get("none", 0),
                      "old_count": old_counts.get("none", 0), "new_count": totals.get("none", 0)},
        "four_bar_single_rime": {
            "old_rate": 0.0311,  # from adlib_strip_stats.json "new_rhyme.one_rime_4bar_rate"
            "new_rate": four_rate,
            "new_blocks": four_total,
        },
    }
    (OUT / "rhyme_anchor_recompute.json").write_text(json.dumps({**report, "examples_count":
        {k: len(v) for k, v in examples.items()}}, indent=2, ensure_ascii=False))

    # Append anchor examples section to slant_rhyme_examples.md
    rng = random.Random(20261030)
    append = ["", "---", "", "## Anchor-based rhyme — 10 random examples per category",
              "", "Anchor = last primary-stressed vowel + all following phones (through "
              "unstressed suffix words). Each pair shows the two anchor tails.", ""]
    for cat in ("exact", "slant", "assonance", "none"):
        pool = examples.get(cat) or []
        append.append(f"### {cat} ({len(pool)} total pairs, {rates.get(cat, 0):.4f})")
        append.append("")
        if not pool:
            append.append("- (none)")
            append.append("")
            continue
        picks = rng.sample(pool, min(10, len(pool)))
        for song, a, b, al, bl in picks:
            append.append(f"- `[{song}]`")
            append.append(f"  - A: {a!r}  anchor=`{al}`")
            append.append(f"  - B: {b!r}  anchor=`{bl}`")
        append.append("")
    with (OUT / "slant_rhyme_examples.md").open("a", encoding="utf-8") as f:
        f.write("\n".join(append))

    # Side-by-side table
    print(f"OLD pairs: {old_pairs}  NEW pairs: {total_pairs}")
    print(f"              OLD    NEW")
    for k in ("exact", "slant", "assonance", "none"):
        print(f"{k:12s} {old_rates.get(k, 0):>6.4f}  {rates.get(k, 0):>6.4f}")
    print(f"4bar single-rime OLD {0.0311}  NEW {four_rate}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
