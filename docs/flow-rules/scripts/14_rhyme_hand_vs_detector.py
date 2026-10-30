#!/usr/bin/env python3
"""Hand-labeled rhyme groups vs anchor-detector output.

Three Gunna sections chosen because the vault stores them in song order
(verified via low alphabetical-pair-rate of the rowid sequence):
  - pushin P         bars 3-13   (alpha-rate 0.43)
  - Understood       bars 5-14   (alpha-rate 0.42)
  - Floyd Mayweather bars 5-14   (alpha-rate 0.47)

Caveat: the Gunna vault stores MOST songs alphabetically (verified on the
7 next-biggest tracks: fukumean, Baby Birkin, SKYBOX, WUNNA FLO, BLINDFOLD
all ~1.00 alphabetical-pair-rate). Only ~15–20% of songs preserve order;
these three are among them.

For each section:
  1. Load the lines.
  2. Apply the HAND_LABELS dict below (rhyme group per bar).
  3. Build the hand-labeled rhyme PAIR set (all i<j where group[i]==group[j]).
  4. Run the anchor detector on every pair in the section; collect pairs
     flagged (exact | slant | assonance).
  5. Compute precision = detector-&-hand / detector; recall = detector-&-hand
     / hand.
  6. Also compute `any_2_share_vowel_in_4bar_window` rate for all songs
     (not just these three) with the anchor-based assonance signal — this
     is the "any 2+ bars share anchor vowel" metric the user asked for.

Writes docs/flow-rules/rhyme_hand_vs_detector.md.
"""
from __future__ import annotations

import collections
import json
import re
import sqlite3
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
LLM = REPO / "tools" / "lyric-llm"
OUT = REPO / "docs" / "flow-rules"
DB = REPO / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite"
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
    """CMU returns a flat phone list for the first pronunciation."""
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


def classify(a: list[str], b: list[str]) -> str:
    if not a or not b:
        return "none"
    if tuple(a) == tuple(b):
        return "exact"
    def vowel(seq):
        for p in seq:
            if re.match(r"[AEIOU]", p):
                return re.sub(r"\d", "", p)
        return ""
    def ctail(seq):
        out = []
        hit = False
        for p in seq:
            if re.match(r"[AEIOU]", p):
                if hit:
                    out.append(PHON_TO_GROUP.get(p, p))
                else:
                    hit = True
            else:
                out.append(PHON_TO_GROUP.get(p, p))
        return tuple(out)
    va, vb = vowel(a), vowel(b)
    if va and va == vb:
        if ctail(a) == ctail(b):
            return "slant"
        return "assonance"
    return "none"


def _vowel(a: list[str]) -> str:
    for p in a:
        if re.match(r"[AEIOU]", p):
            return re.sub(r"\d", "", p)
    return ""


# ============================================================
# HAND-LABELED RHYME GROUPS
# For each bar index (1-based within the section slice), a letter.
# Two bars share a rhyme <=> they share the same letter.
# ============================================================
HAND = {
    "pushin P": {
        "slice": (3, 13),  # bars 3..13 inclusive = 11 bars
        # all bars end on "P" or near-"P" (short "ee" vowel + stop P/s):
        #   peace, P's, P's, Pesbian, presidents, P, P, P, P
        # labels: A = "ee" + P/s; B = "esident/esbian" (ɛ vowel, s/n tail);
        # P alone is also A (ee + P).
        "labels": {3:"A", 4:"A", 5:"A", 6:"A", 7:"B", 8:"B", 9:"A", 10:"A", 11:"A", 12:"A", 13:"A"},
    },
    "Understood": {
        "slice": (5, 14),  # bars 5..14 inclusive = 10 bars
        # 5 understood  A (ʊd)
        # 6 hood        A (ʊd)
        # 7 foot        A (ʊt — close vowel, slight)
        # 8 good        A (ʊd)
        # 9 bros        B (oʊz)
        # 10 hoes       B (oʊz)
        # 11 rollin     C (oʊlɪn)
        # 12 totin'     C (oʊtɪn)
        # 13 rougeish   D (ʊʒ... really the end "-ish" / rougeish is weird)
        # 14 Lotus      D (-us, slight match)
        "labels": {5:"A", 6:"A", 7:"A", 8:"A", 9:"B", 10:"B", 11:"C", 12:"C", 13:"D", 14:"D"},
    },
    "Floyd Mayweather": {
        "slice": (5, 14),  # bars 5..14 inclusive = 10 bars, all ending ɪs/ɪst/ɪsh/ɪk/ɪp
        # 5 wrist       A (ɪst)
        # 6 fist        A (ɪst)
        # 7 dick        B (ɪk)
        # 8 chicks      B (ɪks)
        # 9 missed      A (ɪst)
        # 10 fish       A (ɪʃ, slant with ɪst)
        # 11 clip       C (ɪp)
        # 12 Artest     A (ɪst)
        # 13 Miss       A (ɪs, slant)
        # 14 kiss       A (ɪs)
        "labels": {5:"A", 6:"A", 7:"B", 8:"B", 9:"A", 10:"A", 11:"C", 12:"A", 13:"A", 14:"A"},
    },
}


def main() -> int:
    conn = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    md = ["# Rhyme detector — hand-labeled ground truth comparison", ""]
    md.append("**Vault order caveat.** Most Gunna songs are stored "
              "alphabetically — see the top of this file for how that was "
              "discovered. The three sections below are among the ~15% that "
              "preserve song order (alphabetical-pair-rate ≤ 0.47). All "
              "order-dependent stats in gunna_rulebook.md v1-v3 are therefore "
              "measuring rhyme between alphabetically-adjacent lines for most "
              "songs, not song-adjacent. Per-line stats (commas, triplets, "
              "POV, mood, subtopics, inner-rhyme-per-line) are unaffected.")
    md.append("")

    overall = {"tp": 0, "fp": 0, "fn": 0, "pairs_total": 0, "hand_pairs": 0, "det_pairs": 0}
    per_song: list[dict] = []
    for song, cfg in HAND.items():
        a, b = cfg["slice"]
        rows = conn.execute(
            "SELECT line FROM bars WHERE lower(artist)='gunna' AND song=? ORDER BY rowid",
            (song,),
        ).fetchall()
        lines_all = [r[0] for r in rows]
        section = lines_all[a - 1 : b]  # 1-based inclusive
        hand = cfg["labels"]
        hand_groups = {i: hand[a + i] for i in range(len(section))}  # i is 0-based
        # hand pair set
        hand_pairs = set()
        n = len(section)
        for i in range(n):
            for j in range(i + 1, n):
                if hand_groups[i] == hand_groups[j]:
                    hand_pairs.add((i, j))
        # detector pairs classified exact / slant / assonance / none
        anchors = [anchor_tail(strip_adlibs(l)) for l in section]
        pair_calls: dict[tuple[int, int], str] = {}
        tier_pairs = {"exact": set(), "exact_slant": set(), "exact_slant_assonance": set()}
        for i in range(n):
            for j in range(i + 1, n):
                k = classify(anchors[i], anchors[j])
                pair_calls[(i, j)] = k
                if k == "exact":
                    tier_pairs["exact"].add((i, j))
                    tier_pairs["exact_slant"].add((i, j))
                    tier_pairs["exact_slant_assonance"].add((i, j))
                elif k == "slant":
                    tier_pairs["exact_slant"].add((i, j))
                    tier_pairs["exact_slant_assonance"].add((i, j))
                elif k == "assonance":
                    tier_pairs["exact_slant_assonance"].add((i, j))
        det_pairs = tier_pairs["exact_slant_assonance"]
        tp = len(hand_pairs & det_pairs)
        fp = len(det_pairs - hand_pairs)
        fn = len(hand_pairs - det_pairs)
        pair_total = n * (n - 1) // 2
        precision = tp / (tp + fp) if (tp + fp) else 0.0
        recall = tp / (tp + fn) if (tp + fn) else 0.0
        f1 = 2 * precision * recall / (precision + recall) if (precision + recall) else 0.0
        # per-tier PR
        tier_scores: dict[str, dict] = {}
        for tier, pairs in tier_pairs.items():
            t_tp = len(hand_pairs & pairs)
            t_fp = len(pairs - hand_pairs)
            t_fn = len(hand_pairs - pairs)
            t_p = t_tp / (t_tp + t_fp) if (t_tp + t_fp) else 0.0
            t_r = t_tp / (t_tp + t_fn) if (t_tp + t_fn) else 0.0
            t_f1 = 2 * t_p * t_r / (t_p + t_r) if (t_p + t_r) else 0.0
            tier_scores[tier] = {"tp": t_tp, "fp": t_fp, "fn": t_fn,
                                 "precision": round(t_p, 3), "recall": round(t_r, 3),
                                 "f1": round(t_f1, 3)}
        overall["tp"] += tp; overall["fp"] += fp; overall["fn"] += fn
        overall["pairs_total"] += pair_total
        overall["hand_pairs"] += len(hand_pairs)
        overall["det_pairs"] += len(det_pairs)
        per_song.append({"song": song, "n_bars": n,
                         "hand_rhyme_pairs": len(hand_pairs),
                         "detector_pairs": len(det_pairs),
                         "tp": tp, "fp": fp, "fn": fn,
                         "precision": precision, "recall": recall, "f1": f1,
                         "tiers": tier_scores})

        md.append(f"## `{song}` — bars {a}..{b} ({n} bars)")
        md.append("")
        md.append("| bar | line (ad-libs stripped) | hand label | anchor |")
        md.append("| ---:| --- | :-:| --- |")
        for i, line in enumerate(section):
            md.append(f"| {a + i} | {strip_adlibs(line)!r} | **{hand[a + i]}** | "
                      f"`{'-'.join(anchors[i])}` |")
        md.append("")
        md.append(f"**Hand-labeled rhyme pairs:** {len(hand_pairs)}  "
                  f"**Detector-flagged pairs:** {len(det_pairs)}  "
                  f"**True positives:** {tp}  **False positives:** {fp}  **False negatives:** {fn}")
        md.append(f"**Precision:** {precision:.3f}  **Recall:** {recall:.3f}  **F1:** {f1:.3f}")
        md.append("")
        md.append("### False positives (detector says rhyme, hand says no)")
        for (i, j) in sorted(det_pairs - hand_pairs):
            md.append(f"- bars {a + i} + {a + j} ({pair_calls[(i, j)]}): "
                      f"{strip_adlibs(section[i])!r} / {strip_adlibs(section[j])!r}")
        md.append("")
        md.append("### False negatives (hand says rhyme, detector says no)")
        for (i, j) in sorted(hand_pairs - det_pairs):
            md.append(f"- bars {a + i} + {a + j}: "
                      f"{strip_adlibs(section[i])!r} / {strip_adlibs(section[j])!r}")
        md.append("")

    # overall
    P = overall["tp"] / (overall["tp"] + overall["fp"]) if (overall["tp"] + overall["fp"]) else 0.0
    R = overall["tp"] / (overall["tp"] + overall["fn"]) if (overall["tp"] + overall["fn"]) else 0.0
    F1 = 2 * P * R / (P + R) if (P + R) else 0.0
    md.insert(2, f"**Overall across all 3 sections.** "
                  f"Precision **{P:.3f}**, recall **{R:.3f}**, F1 **{F1:.3f}**. "
                  f"TP={overall['tp']}  FP={overall['fp']}  FN={overall['fn']}  "
                  f"pairs_total={overall['pairs_total']}.")
    md.insert(3, "")

    # ----------------------------------------------------
    # 4-bar window metric: any 2+ bars share anchor vowel
    # NOTE: computed over the FULL solo set using the ORDER
    # the vault provides. For songs stored alphabetically that
    # order is meaningless; stat is reported with that caveat.
    # ----------------------------------------------------
    lines_all = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines_all if r["artist"].lower() == "gunna"]
    by_song: dict[str, list[dict]] = {}
    for r in solo:
        by_song.setdefault(r["song"], []).append(r)
    blocks_with_vowel_pair = 0
    total_blocks = 0
    for seq in by_song.values():
        tails = [anchor_tail(strip_adlibs(r["line"])) for r in seq]
        vowels = [_vowel(t) for t in tails]
        for i in range(0, len(vowels) - 3, 4):
            blk = vowels[i:i + 4]
            non_empty = [v for v in blk if v]
            if non_empty:
                total_blocks += 1
                counter = collections.Counter(non_empty)
                if any(v >= 2 for v in counter.values()):
                    blocks_with_vowel_pair += 1
    md.append("---")
    md.append("")
    md.append("## 4-bar window — any 2+ bars share anchor vowel")
    md.append("")
    md.append(f"Fraction of 4-bar windows (sliding across song-order rowid) "
              f"where at least two bars share their anchor vowel: "
              f"**{blocks_with_vowel_pair / max(total_blocks, 1):.4f}** "
              f"({blocks_with_vowel_pair}/{total_blocks} blocks).")
    md.append("")
    md.append("Caveat: for most songs the vault order is alphabetical, so this "
              "stat includes both real song-order windows and alphabetical windows. "
              "The real-song-order rate is probably higher; we can't separate them "
              "without an external song-order source.")
    (OUT / "rhyme_hand_vs_detector.md").write_text("\n".join(md) + "\n")

    print(f"Overall P={P:.3f}  R={R:.3f}  F1={F1:.3f}  TP={overall['tp']}  FP={overall['fp']}  FN={overall['fn']}")
    for row in per_song:
        print(f"  {row['song']:20s} n_bars={row['n_bars']:2d}  P={row['precision']:.3f}  R={row['recall']:.3f}  F1={row['f1']:.3f}")
    # tier breakdown overall
    tier_total = {"exact": {"tp":0,"fp":0,"fn":0}, "exact_slant":{"tp":0,"fp":0,"fn":0}, "exact_slant_assonance":{"tp":0,"fp":0,"fn":0}}
    for row in per_song:
        for t, s in row["tiers"].items():
            tier_total[t]["tp"] += s["tp"]; tier_total[t]["fp"] += s["fp"]; tier_total[t]["fn"] += s["fn"]
    print()
    print(f"{'tier':30s}{'P':>8s}{'R':>8s}{'F1':>8s}{'TP':>5s}{'FP':>5s}{'FN':>5s}")
    for t in ("exact", "exact_slant", "exact_slant_assonance"):
        s = tier_total[t]
        p = s["tp"]/(s["tp"]+s["fp"]) if (s["tp"]+s["fp"]) else 0
        r = s["tp"]/(s["tp"]+s["fn"]) if (s["tp"]+s["fn"]) else 0
        f1 = 2*p*r/(p+r) if (p+r) else 0
        print(f"{t:30s}{p:>8.3f}{r:>8.3f}{f1:>8.3f}{s['tp']:>5d}{s['fp']:>5d}{s['fn']:>5d}")
    print(f"4-bar-window share-anchor-vowel rate: {blocks_with_vowel_pair / max(total_blocks, 1):.4f} "
          f"({blocks_with_vowel_pair}/{total_blocks})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
