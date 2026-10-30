"""Novelty check: catch bars that near-copy a vault line.

Rules (any ONE triggers hard reject):
  - exact normalized match (lowercase, no punctuation, collapsed spaces)
  - longest shared word RUN >= 6 words (ignoring run tokens that are all
    chip words / names)
  - max 5-gram overlap >= 40%
  - token Jaccard >= 0.7 with the nearest vault line

Reads BarHitsCatalog.sqlite read-only. Candidate recall uses FTS phrase
matches on each 4- or 5-gram of the bar; verification is pure Python.

Also compares against a dynamic set of "shown example lines" per verse,
so quoting from a WORDPLAY_EXAMPLES block is caught.
"""
from __future__ import annotations

import re
import sqlite3
from pathlib import Path
from typing import Iterable, Optional

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent.parent
CATALOG = REPO / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite"

_WORD_RE = re.compile(r"[A-Za-z']+")


def _normalize(line: str) -> str:
    return " ".join(_WORD_RE.findall((line or "").lower()))


def _tokens(line: str) -> list[str]:
    return _normalize(line).split()


def _ngrams(words: list[str], n: int) -> list[tuple[str, ...]]:
    if len(words) < n:
        return []
    return [tuple(words[i:i + n]) for i in range(len(words) - n + 1)]


def _longest_shared_run(a: list[str], b: list[str]) -> int:
    """Longest consecutive matching subsequence length."""
    if not a or not b:
        return 0
    prev = [0] * (len(b) + 1)
    best = 0
    for i in range(len(a)):
        cur = [0] * (len(b) + 1)
        for j in range(len(b)):
            if a[i] == b[j]:
                cur[j + 1] = prev[j] + 1
                if cur[j + 1] > best:
                    best = cur[j + 1]
        prev = cur
    return best


def _jaccard(a: set[str], b: set[str]) -> float:
    if not a and not b:
        return 0.0
    inter = len(a & b)
    union = len(a | b)
    return inter / union if union else 0.0


_CONN: sqlite3.Connection | None = None


def _conn() -> sqlite3.Connection | None:
    global _CONN
    if _CONN is None and CATALOG.exists():
        _CONN = sqlite3.connect(f"file:{CATALOG}?mode=ro", uri=True,
                                check_same_thread=False)
    return _CONN


def _fts_candidates(bar_tokens: list[str], limit: int = 10) -> list[tuple[str, str, str]]:
    """Fetch catalog bars that share a 5-gram with the input (fallback 4-gram)."""
    conn = _conn()
    if conn is None or len(bar_tokens) < 4:
        return []
    out: list[tuple[str, str, str]] = []
    for n in (5, 4):
        if len(bar_tokens) < n:
            continue
        grams = _ngrams(bar_tokens, n)
        for g in grams[:12]:
            phrase = '"' + " ".join(g) + '"'
            try:
                rows = conn.execute(
                    "SELECT bars.line, COALESCE(bars.artist, ''), COALESCE(bars.song, '') "
                    "FROM bars_fts JOIN bars ON bars.rowid = bars_fts.rowid "
                    "WHERE bars_fts MATCH ? LIMIT ?",
                    (phrase, limit),
                ).fetchall()
            except sqlite3.Error:
                continue
            for r in rows:
                out.append(r)
        if out:
            break
    return out


def _overlap_stats(bar_tokens: list[str], cand_tokens: list[str],
                   ignore_tokens: set[str] | None = None) -> dict:
    ignore = ignore_tokens or set()
    bar_set = set(bar_tokens) - ignore
    cand_set = set(cand_tokens) - ignore
    jac = _jaccard(bar_set, cand_set)
    g5_bar = _ngrams(bar_tokens, 5)
    g5_cand = set(_ngrams(cand_tokens, 5))
    g5_overlap = sum(1 for g in g5_bar if g in g5_cand) / max(len(g5_bar), 1)
    # longest shared run computed ignoring runs that are all chip/name tokens
    bar_filtered = [t for t in bar_tokens if t not in ignore]
    cand_filtered = [t for t in cand_tokens if t not in ignore]
    run = _longest_shared_run(bar_filtered, cand_filtered)
    return {
        "jaccard": round(jac, 4),
        "fivegram_overlap": round(g5_overlap, 4),
        "longest_run": run,
    }


def bar_novelty(bar: str, chip_words: Optional[Iterable[str]] = None,
                shown_examples: Optional[Iterable[str]] = None) -> dict:
    """Score a single bar's near-dup risk.

    Returns:
      {bar, is_near_dup, reasons, best_match: {line, artist, song, ...stats}}
    """
    bar_tokens = _tokens(bar)
    if not bar_tokens:
        return {"bar": bar, "is_near_dup": False, "reasons": [], "best_match": None}

    ignore_tokens: set[str] = set()
    for chip in chip_words or []:
        for t in _tokens(chip):
            ignore_tokens.add(t)
    # also ignore stock "name" tokens by default — short all-letter capitalized
    # words. We only have lowercased tokens here, so this just suppresses the
    # chip words themselves.

    reasons: list[str] = []
    norm_bar = _normalize(bar)

    # Dynamic set (example lines quoted in the prompt)
    candidates: list[tuple[str, str, str]] = []
    for ex in shown_examples or []:
        candidates.append((ex, "", "shown-example"))
    # Catalog candidates via FTS
    candidates.extend(_fts_candidates(bar_tokens))

    best: dict | None = None
    best_overlap = -1.0

    exact_hit: dict | None = None

    for cand_line, cand_artist, cand_song in candidates:
        if not cand_line:
            continue
        cand_tokens = _tokens(cand_line)
        if _normalize(cand_line) == norm_bar:
            exact_hit = {"line": cand_line, "artist": cand_artist,
                         "song": cand_song, "jaccard": 1.0,
                         "fivegram_overlap": 1.0,
                         "longest_run": len(bar_tokens)}
            break
        stats = _overlap_stats(bar_tokens, cand_tokens, ignore_tokens)
        rank = max(stats["fivegram_overlap"], stats["jaccard"],
                   min(stats["longest_run"] / max(len(bar_tokens), 1), 1.0))
        if rank > best_overlap:
            best_overlap = rank
            best = {**stats, "line": cand_line, "artist": cand_artist,
                    "song": cand_song}

    if exact_hit:
        reasons.append("exact normalized match")
        return {"bar": bar, "is_near_dup": True, "reasons": reasons,
                "best_match": exact_hit}

    is_near_dup = False
    if best:
        if best["longest_run"] >= 6:
            is_near_dup = True
            reasons.append(f"longest shared run {best['longest_run']} >= 6")
        if best["fivegram_overlap"] >= 0.40:
            is_near_dup = True
            reasons.append(f"5-gram overlap {best['fivegram_overlap']:.2f} >= 0.40")
        if best["jaccard"] >= 0.70:
            is_near_dup = True
            reasons.append(f"Jaccard {best['jaccard']:.2f} >= 0.70")

    return {"bar": bar, "is_near_dup": is_near_dup, "reasons": reasons,
            "best_match": best if is_near_dup else None}


def verse_novelty(bars: Iterable[str], chip_words: Optional[Iterable[str]] = None,
                  shown_examples: Optional[Iterable[str]] = None) -> dict:
    bar_list = [b for b in bars if b and b.strip()]
    per_bar = [bar_novelty(b, chip_words=chip_words,
                           shown_examples=shown_examples) for b in bar_list]
    bad = [i for i, r in enumerate(per_bar) if r["is_near_dup"]]
    max_run = max((r["best_match"]["longest_run"] for r in per_bar
                   if r.get("best_match")), default=0)
    max_overlap = max((r["best_match"]["fivegram_overlap"] for r in per_bar
                       if r.get("best_match")), default=0.0)
    return {
        "bars": per_bar,
        "near_dup_bar_indexes": bad,
        "is_near_dup": bool(bad),
        "max_longest_run": max_run,
        "max_fivegram_overlap": round(max_overlap, 4),
    }
