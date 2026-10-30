#!/usr/bin/env python3
"""Recompute order-dependent stats ONLY on the 593 order-preserved songs.

Reads docs/flow-rules/song_order_flags.json, keeps only songs flagged
`order_preserved`. Writes docs/flow-rules/true_order_stats.json with:
  adjacent-rhyme by tier (exact / slant / assonance / none),
  4-bar single-rime (anchor), 4-bar any-2-share-vowel,
  carry-rate (grammar).

Alphabetical and unclear songs are SKIPPED — their adjacent-pair numbers
are meaningless.
"""
from __future__ import annotations

import collections
import json
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
    "nasal": {"M", "N", "NG"}, "liquid": {"L", "R"},
    "glide": {"W", "Y"}, "affric": {"CH", "JH"},
}
PHON_TO_GROUP = {ph: g for g, phones in CONS_GROUPS.items() for ph in phones}
TERMINAL = ".!?"
HANG = {"to","of","in","on","with","by","for","at","from","into","about",
        "over","under","through","across","between","around","like","upon",
        "within","'cause","cause","where"}
CONJ = {"and","but","or","so","yet","then","when","while","though","as",
        "because","since","unless","if"}
RELATIVE = {"that","which","who","whom","whose"}


def strip_adlibs(line: str) -> str:
    s = re.sub(r"\([^)]*\)|\[[^\]]*\]", "", line or "")
    while True:
        s = s.rstrip(" ,.!?;:—-")
        toks = _W.findall(s)
        if not toks or toks[-1].lower().strip("'") not in ADLIBS:
            break
        m = re.search(r"[A-Za-z']+[\s,!?.;:—-]*$", s)
        if not m:
            break
        s = s[:m.start()].rstrip(" ,.!?;:—-")
    return s.strip()


def _phones(w):
    w = re.sub(r"[^A-Za-z']", "", (w or "").lower())
    return list(CMU.get(w) or [])


def anchor_tail(line: str) -> list[str]:
    toks = _W.findall(line or "")
    all_phones = []
    for t in toks:
        for p in _phones(t):
            all_phones.append(p)
    if not all_phones:
        return []
    for i in range(len(all_phones) - 1, -1, -1):
        p = all_phones[i]
        if re.match(r"[AEIOU]", p) and p.endswith("1"):
            return all_phones[i:]
    for i in range(len(all_phones) - 1, -1, -1):
        p = all_phones[i]
        if re.match(r"[AEIOU]", p) and p.endswith("2"):
            return all_phones[i:]
    for i in range(len(all_phones) - 1, -1, -1):
        if re.match(r"[AEIOU]", all_phones[i]):
            return all_phones[i:]
    return all_phones[-3:]


def classify(a, b):
    if not a or not b:
        return "none"
    if tuple(a) == tuple(b):
        return "exact"
    def v(seq):
        for p in seq:
            if re.match(r"[AEIOU]", p):
                return re.sub(r"\d", "", p)
        return ""
    def c(seq):
        out = []; hit = False
        for p in seq:
            if re.match(r"[AEIOU]", p):
                if hit: out.append(PHON_TO_GROUP.get(p, p))
                else: hit = True
            else: out.append(PHON_TO_GROUP.get(p, p))
        return tuple(out)
    va, vb = v(a), v(b)
    if va and va == vb:
        if c(a) == c(b):
            return "slant"
        return "assonance"
    return "none"


def _vowel(tail):
    for p in tail:
        if re.match(r"[AEIOU]", p):
            return re.sub(r"\d", "", p)
    return ""


def classify_carry(cur, nxt):
    cs = strip_adlibs(cur); ns = strip_adlibs(nxt)
    if not cs or cs.rstrip()[-1:] in TERMINAL:
        return False
    ct = _W.findall(cs); nt = _W.findall(ns)
    if not ct or not nt: return False
    ce = ct[-1].lower().strip("'"); ns_tok = nt[0].lower().strip("'")
    reasons = []
    if ce in HANG: reasons.append("hang")
    if ns_tok in (CONJ | RELATIVE | HANG): reasons.append("start")
    def has_verb(toks):
        c = {"is","am","are","was","were","be","been","being","'s","'re",
             "'m","do","did","does","doin'","doing","ain't","aint","got",
             "gotta","gon'","gonna","wanna","finna","'ma","ima"}
        for t in toks:
            tl = t.lower()
            if tl in c: return True
            if tl.endswith(("ing", "in'")) or tl.endswith("ed") or tl.endswith("s"):
                return True
        return False
    if not has_verb(ct) and has_verb(nt):
        reasons.append("verbless-into-verbed")
    return bool(reasons)


def main() -> int:
    flags = json.loads((OUT / "song_order_flags.json").read_text())
    keep_songs = {s["song"] for s in flags["songs"] if s["flag"] == "order_preserved"}
    print(f"keeping {len(keep_songs)} order-preserved songs")
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna" and r["song"] in keep_songs]
    by_song = {}
    for r in solo:
        by_song.setdefault(r["song"], []).append(r)
    totals = collections.Counter()
    pair_total = 0
    four_total = four_one = 0
    four_vowel_pair = four_vowel_total = 0
    carry_count = carry_pair_total = 0
    carry_lengths = collections.Counter()
    for seq in by_song.values():
        stripped = [strip_adlibs(r["line"]) for r in seq]
        anchors = [anchor_tail(s) for s in stripped]
        for i in range(1, len(anchors)):
            a, b = anchors[i-1], anchors[i]
            if not a or not b:
                totals["none"] += 1
            else:
                totals[classify(a, b)] += 1
            pair_total += 1
        for i in range(0, len(anchors) - 3, 4):
            blk = anchors[i:i+4]
            non_empty = [tuple(x) for x in blk if x]
            if non_empty:
                four_total += 1
                if all(x == non_empty[0] for x in non_empty):
                    four_one += 1
            vowels = [_vowel(x) for x in blk if x]
            if vowels:
                four_vowel_total += 1
                counter = collections.Counter(vowels)
                if any(v >= 2 for v in counter.values()):
                    four_vowel_pair += 1
        # carry
        i = 0
        while i < len(seq) - 1:
            if classify_carry(seq[i]["line"], seq[i+1]["line"]):
                carry_count += 1
                length = 2
                j = i + 1
                while j < len(seq) - 1 and classify_carry(seq[j]["line"], seq[j+1]["line"]):
                    length += 1; j += 1
                key = str(length) if length < 4 else "4+"
                carry_lengths[key] += 1
                i = j + 1
            else:
                i += 1
            carry_pair_total += 1
    stats = {
        "n_songs": len(by_song),
        "n_lines": len(solo),
        "pairs_total": pair_total,
        "adjacent_rhyme": {
            "exact":     {"count": totals["exact"],     "rate": round(totals["exact"]/max(pair_total,1), 4)},
            "slant":     {"count": totals["slant"],     "rate": round(totals["slant"]/max(pair_total,1), 4)},
            "assonance": {"count": totals["assonance"], "rate": round(totals["assonance"]/max(pair_total,1), 4)},
            "none":      {"count": totals["none"],      "rate": round(totals["none"]/max(pair_total,1), 4)},
        },
        "four_bar_single_rime_anchor": round(four_one/max(four_total,1), 4),
        "four_bar_any_2_share_vowel":  round(four_vowel_pair/max(four_vowel_total,1), 4),
        "four_bar_blocks": four_total,
        "carry_rate_grammar": round(carry_count/max(carry_pair_total,1), 4),
        "carry_count": carry_count,
        "carry_pairs_examined": carry_pair_total,
        "carry_lengths": dict(carry_lengths),
    }
    (OUT / "true_order_stats.json").write_text(json.dumps(stats, indent=2))
    print(f"n_lines={stats['n_lines']}  n_songs={stats['n_songs']}  pairs={pair_total}")
    print(f"adjacent  exact={stats['adjacent_rhyme']['exact']['rate']}  "
          f"slant={stats['adjacent_rhyme']['slant']['rate']}  "
          f"assonance={stats['adjacent_rhyme']['assonance']['rate']}  "
          f"none={stats['adjacent_rhyme']['none']['rate']}")
    print(f"4-bar  single-rime(anchor)={stats['four_bar_single_rime_anchor']}  "
          f"any-2-share-vowel={stats['four_bar_any_2_share_vowel']}  "
          f"blocks={four_total}")
    print(f"carry  rate(grammar)={stats['carry_rate_grammar']}  "
          f"count={carry_count}/{carry_pair_total}  lengths={dict(carry_lengths)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
