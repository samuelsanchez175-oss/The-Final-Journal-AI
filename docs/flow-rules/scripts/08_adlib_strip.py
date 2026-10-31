#!/usr/bin/env python3
"""Strip ad-libs and recompute end-word-dependent stats.

Ad-lib patterns stripped per line (in order):
  1. parenthetical text — `(...)` and `[...]`
  2. trailing ad-lib tags — yeah / uh / woo / huh / what / skrrt / ayy / ooh /
     woah / oh / nah / hey / mm / yuh / yah (case-insensitive), possibly
     repeated with spaces or commas
  3. trailing ad-lib stripped recursively (so "yeah, uh, woo" → "")

Writes docs/flow-rules/adlib_strip_stats.json and prints the old vs new
headline. Does NOT touch the vault.
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

try:
    from lyriclib import load_cmudict, end_rime
    CMU = load_cmudict(REPO / "XJournal AI" / "cmudict.txt")
except Exception:
    CMU = {}
    end_rime = lambda w, d: None  # type: ignore

_W = re.compile(r"[A-Za-z']+")
ADLIBS = {"yeah", "uh", "woo", "huh", "what", "skrrt", "skrr", "ayy",
          "ooh", "woah", "oh", "nah", "hey", "mm", "mmm", "yuh", "yah",
          "aye", "ay", "ye"}


def strip_parens(line: str) -> str:
    s = line or ""
    s = re.sub(r"\([^)]*\)", "", s)
    s = re.sub(r"\[[^\]]*\]", "", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s


def strip_trailing_adlibs(line: str) -> str:
    s = line or ""
    changed = True
    while changed:
        changed = False
        s = s.rstrip(" ,.!?;:—-")
        tokens = _W.findall(s)
        if not tokens:
            break
        if tokens[-1].lower().strip("'") in ADLIBS:
            # drop that word (and any trailing punctuation / comma before it)
            match = re.search(r"[A-Za-z']+[\s,!?.;:—-]*$", s)
            if match:
                s = s[:match.start()].rstrip(" ,.!?;:—-")
                changed = True
    return s.strip()


def strip_adlibs(line: str) -> str:
    return strip_trailing_adlibs(strip_parens(line))


def _end_word(line: str) -> str:
    t = _W.findall(line or "")
    return t[-1].lower() if t else ""


def _end_rime(word: str) -> tuple[str, ...]:
    r = end_rime(word.lower(), CMU) if CMU else None
    return tuple(r) if r else ()


def main() -> int:
    lines = [json.loads(l) for l in (OUT / "gunna_lines.jsonl").read_text().splitlines() if l.strip()]
    solo = [r for r in lines if r["artist"].lower() == "gunna"]
    stripped: list[dict] = []
    dropped = 0
    for r in solo:
        s = strip_adlibs(r["line"])
        if not s:
            dropped += 1
            continue
        stripped.append({**r, "line": s})
    # top end words
    def top_ends(rows: list[dict], k: int = 15) -> list[tuple[str, int]]:
        c = collections.Counter()
        for r in rows:
            ew = _end_word(r["line"])
            if ew:
                c[ew] += 1
        return c.most_common(k)
    # adjacent-rhyme + 4-bar one-rime recompute
    def rhyme_stats(rows: list[dict]) -> dict:
        by_song: dict[tuple, list[str]] = {}
        for r in rows:
            by_song.setdefault((r["artist"], r["song"]), []).append(r["line"])
        hit = total = 0
        one_r = total_blocks = 0
        for seq in by_song.values():
            rimes = [_end_rime(_end_word(l)) for l in seq]
            for i in range(1, len(rimes)):
                if rimes[i] and rimes[i - 1]:
                    total += 1
                    if rimes[i] == rimes[i - 1]:
                        hit += 1
            for i in range(0, len(rimes) - 3, 4):
                blk = rimes[i:i + 4]
                non_none = [r for r in blk if r]
                if non_none:
                    total_blocks += 1
                    if all(r == non_none[0] for r in non_none):
                        one_r += 1
        return {
            "adjacent_rhyme_hit": hit, "adjacent_pairs": total,
            "adjacent_rhyme_rate": round(hit / max(total, 1), 4),
            "one_rime_4bar": one_r, "four_bar_blocks": total_blocks,
            "one_rime_4bar_rate": round(one_r / max(total_blocks, 1), 4),
        }
    stats = {
        "n_before": len(solo),
        "n_after": len(stripped),
        "lines_dropped_empty_after_strip": dropped,
        "old_top_end_words": top_ends(solo),
        "new_top_end_words": top_ends(stripped),
        "old_rhyme": rhyme_stats(solo),
        "new_rhyme": rhyme_stats(stripped),
    }
    (OUT / "adlib_strip_stats.json").write_text(json.dumps(stats, indent=2, ensure_ascii=False))
    print(f"before={len(solo)}  after={len(stripped)}  dropped_empty={dropped}")
    print("\nold top end words:", stats["old_top_end_words"][:5])
    print("new top end words:", stats["new_top_end_words"][:5])
    print(f"\nadjacent-rhyme rate  OLD={stats['old_rhyme']['adjacent_rhyme_rate']}  "
          f"NEW={stats['new_rhyme']['adjacent_rhyme_rate']}  "
          f"(pairs {stats['old_rhyme']['adjacent_pairs']} -> {stats['new_rhyme']['adjacent_pairs']})")
    print(f"4-bar single-rime  OLD={stats['old_rhyme']['one_rime_4bar_rate']}  "
          f"NEW={stats['new_rhyme']['one_rime_4bar_rate']}  "
          f"(blocks {stats['old_rhyme']['four_bar_blocks']} -> {stats['new_rhyme']['four_bar_blocks']})")
    print(f"\nwrote {OUT / 'adlib_strip_stats.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
