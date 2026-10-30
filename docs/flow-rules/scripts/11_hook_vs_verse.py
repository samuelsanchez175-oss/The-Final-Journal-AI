#!/usr/bin/env python3
"""Hook detection + verse-only re-stats.

A line is tagged "hook" if its normalized form (lowercase, no punct, no
parentheticals, no ad-lib tails) repeats ≥3 times inside the SAME song.
Hooks are then excluded for a verse-only recompute of commas, carry
(grammar-based), end-rime, inner-rhyme, and multisyllable rate.

Writes docs/flow-rules/hook_vs_verse_stats.json plus examples.
"""
from __future__ import annotations

import collections
import json
import re
import statistics
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
LLM = REPO / "tools" / "lyric-llm"
OUT = REPO / "docs" / "flow-rules"
sys.path.insert(0, str(LLM))

from lyriclib import load_cmudict, end_rime  # type: ignore

CMU = load_cmudict(REPO / "XJournal AI" / "cmudict.txt")
_W = re.compile(r"[A-Za-z']+")
ADLIBS = {"yeah", "uh", "woo", "huh", "what", "skrrt", "skrr", "ayy",
          "ooh", "woah", "oh", "nah", "hey", "mm", "mmm", "yuh", "yah",
          "aye", "ay", "ye"}


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


def norm(line: str) -> str:
    s = strip_adlibs(line).lower()
    s = re.sub(r"[^\w\s]", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def _syl(w):
    w = re.sub(r"[^A-Za-z']", "", w).lower()
    if not w:
        return 0
    p = CMU.get(w)
    if p:
        return sum(1 for ph in p if any(c.isdigit() for c in ph))
    v = "aeiouy"; c, pv = 0, False
    for ch in w:
        iv = ch in v
        if iv and not pv: c += 1
        pv = iv
    return max(c, 1)


def _end_rime(w):
    r = end_rime(w.lower(), CMU) if w else None
    return tuple(r) if r else ()


def recompute(rows: list[dict]) -> dict:
    # commas
    cc = collections.Counter()
    for r in rows:
        cc[r["line"].count(",")] += 1
    total = sum(cc.values())
    comma_mean = sum(k * v for k, v in cc.items()) / max(total, 1)
    bucket = collections.Counter()
    for k, v in cc.items():
        bucket[min(k, 3)] += v
    # rhyme adjacent + 4-bar
    by_song: dict[tuple, list[dict]] = {}
    for r in rows:
        by_song.setdefault((r["artist"], r["song"]), []).append(r)
    adj_hit = adj_total = 0
    four_one = four_total = 0
    repeated_end_pairs = 0
    multi_total = multi_hit = 0
    inner_counts: list[int] = []
    for seq in by_song.values():
        ends = []
        for r in seq:
            toks = _W.findall(strip_adlibs(r["line"]))
            ends.append(toks[-1].lower() if toks else "")
        rimes = [_end_rime(e) for e in ends]
        for i in range(1, len(rimes)):
            if rimes[i] and rimes[i - 1]:
                adj_total += 1
                if rimes[i] == rimes[i - 1]:
                    adj_hit += 1
        for i in range(1, len(ends)):
            if ends[i] and ends[i] == ends[i - 1]:
                repeated_end_pairs += 1
        for i in range(0, len(rimes) - 3, 4):
            blk = rimes[i:i + 4]
            non_none = [r for r in blk if r]
            if non_none:
                four_total += 1
                if all(r == non_none[0] for r in non_none):
                    four_one += 1
        # inner + multisyl
        for r in seq:
            toks = _W.findall(r["line"])
            if len(toks) < 3:
                continue
            end_w = toks[-1]
            rimes_in = [_end_rime(t) for t in toks]
            seen = {}
            hits = 0
            for ri in rimes_in:
                if not ri: continue
                seen[ri] = seen.get(ri, 0) + 1
                if seen[ri] == 2:
                    hits += 1
            inner_counts.append(hits)
            if _syl(end_w) >= 2:
                multi_total += 1
                erw = _end_rime(end_w)
                for t in toks[:-1]:
                    if _syl(t) >= 2 and _end_rime(t) == erw:
                        multi_hit += 1
                        break
    return {
        "n_lines": total,
        "comma_mean_per_line": round(comma_mean, 3),
        "comma_bucket_rates": {str(k): round(v / max(total, 1), 4) for k, v in sorted(bucket.items())},
        "adjacent_rhyme_rate": round(adj_hit / max(adj_total, 1), 4),
        "adjacent_pairs": adj_total,
        "one_rime_4bar_rate": round(four_one / max(four_total, 1), 4),
        "four_bar_blocks": four_total,
        "repeated_end_pairs_rate": round(repeated_end_pairs / max(adj_total, 1), 4),
        "inner_rhyme_mean": round(statistics.mean(inner_counts), 3) if inner_counts else 0.0,
        "multisyllable_rhyme_rate": round(multi_hit / max(multi_total, 1), 4),
        "multisyllable_rhyme_n": multi_total,
    }


def main() -> int:
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna"]
    by_song: dict[tuple, list[dict]] = {}
    for r in solo:
        by_song.setdefault((r["artist"], r["song"]), []).append(r)
    # find hook lines per song: normalized form repeats >=3 times
    hook_keys: set[tuple] = set()
    hook_sample: list[dict] = []
    for (artist, song), seq in by_song.items():
        norm_count = collections.Counter(norm(r["line"]) for r in seq)
        for n, c in norm_count.items():
            if c >= 3 and n:
                hook_keys.add((artist, song, n))
                if len(hook_sample) < 15:
                    hook_sample.append({"song": song, "normalized": n, "repetitions": c})
    tagged_hook = tagged_verse = 0
    hook_rows: list[dict] = []
    verse_rows: list[dict] = []
    for r in solo:
        key = (r["artist"], r["song"], norm(r["line"]))
        if key in hook_keys:
            tagged_hook += 1
            hook_rows.append(r)
        else:
            tagged_verse += 1
            verse_rows.append(r)

    all_stats = recompute(solo)
    hook_stats = recompute(hook_rows)
    verse_stats = recompute(verse_rows)
    out = {
        "n_solo": len(solo),
        "n_hook": tagged_hook, "n_verse": tagged_verse,
        "hook_rate": round(tagged_hook / max(len(solo), 1), 4),
        "all": all_stats,
        "hook_only": hook_stats,
        "verse_only": verse_stats,
        "hook_examples": hook_sample[:10],
    }
    (OUT / "hook_vs_verse_stats.json").write_text(json.dumps(out, indent=2, ensure_ascii=False))
    print(f"solo n={len(solo)}  hook={tagged_hook}  verse={tagged_verse}  "
          f"hook_rate={out['hook_rate']}")
    print(f"adj-rhyme   all={all_stats['adjacent_rhyme_rate']}  verse={verse_stats['adjacent_rhyme_rate']}")
    print(f"4bar-1rime  all={all_stats['one_rime_4bar_rate']}  verse={verse_stats['one_rime_4bar_rate']}")
    print(f"commas/line all={all_stats['comma_mean_per_line']}  verse={verse_stats['comma_mean_per_line']}")
    print(f"multisyl    all={all_stats['multisyllable_rhyme_rate']}  verse={verse_stats['multisyllable_rhyme_rate']}")
    print(f"inner-mean  all={all_stats['inner_rhyme_mean']}  verse={verse_stats['inner_rhyme_mean']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
