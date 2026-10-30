"""Originality check: how much does a generated verse copy the catalog?

Scores each bar by the fraction of its 5-grams that appear as phrases in
the Bar Hits catalog FTS5 index. Flags `too_copied` above the threshold.
Hard-rejects any bar that exactly matches a catalog line.

Opens the SQLite DB read-only; never writes.
"""
from __future__ import annotations

import re
import sqlite3
from pathlib import Path
from typing import Iterable

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent.parent
CATALOG = REPO / "tools" / "bar-hits-catalog" / "BarHitsCatalog.sqlite"

_WORD_RE = re.compile(r"[A-Za-z']+")


def _normalize(line: str) -> str:
    return " ".join(_WORD_RE.findall(line.lower()))


def _ngrams(words: list[str], n: int) -> list[tuple[str, ...]]:
    if len(words) < n:
        return []
    return [tuple(words[i:i + n]) for i in range(len(words) - n + 1)]


_CONN: sqlite3.Connection | None = None


def _conn() -> sqlite3.Connection:
    global _CONN
    if _CONN is None:
        uri = f"file:{CATALOG}?mode=ro"
        _CONN = sqlite3.connect(uri, uri=True, check_same_thread=False)
    return _CONN


def _fts_phrase_hit(phrase: str) -> int:
    """Return catalog hit count for a 5-word phrase. Short-circuits at 1."""
    sql = 'SELECT COUNT(*) FROM bars_fts WHERE bars_fts MATCH ?'
    quoted = '"' + phrase.replace('"', ' ') + '"'
    try:
        row = _conn().execute(sql, (quoted,)).fetchone()
        return int(row[0]) if row else 0
    except sqlite3.Error:
        return 0


def _exact_line_hit(line: str) -> bool:
    """Normalized exact match against the catalog.

    Compares `_normalize(bar)` against FTS phrase hit (word-only form) then
    confirms with word-tokenized equality on each candidate row.
    """
    norm = _normalize(line)
    if not norm:
        return False
    try:
        quoted = '"' + norm.replace('"', ' ') + '"'
        rows = _conn().execute(
            "SELECT bars.line FROM bars_fts "
            "JOIN bars ON bars.rowid = bars_fts.rowid "
            "WHERE bars_fts MATCH ? LIMIT 10",
            (quoted,),
        ).fetchall()
        for (candidate,) in rows:
            if _normalize(candidate) == norm:
                return True
        return False
    except sqlite3.Error:
        return False


def bar_overlap(bar: str, n: int = 5) -> dict:
    """Return {'ngram_overlap', 'exact_hit', 'ngram_total', 'ngram_hits'}."""
    norm = _normalize(bar)
    words = norm.split()
    grams = _ngrams(words, n)
    if not grams:
        return {"ngram_overlap": 0.0, "exact_hit": False,
                "ngram_total": 0, "ngram_hits": 0}
    hits = 0
    for g in grams:
        if _fts_phrase_hit(" ".join(g)) > 0:
            hits += 1
    return {
        "ngram_overlap": round(hits / len(grams), 4),
        "exact_hit": _exact_line_hit(bar),
        "ngram_total": len(grams),
        "ngram_hits": hits,
    }


def verse_originality(bars: Iterable[str], n: int = 5,
                      bar_threshold: float = 0.6,
                      verse_threshold: float = 0.35) -> dict:
    """Score a whole verse.

    Returns:
      bars: per-bar overlap stats
      verse_overlap: mean ngram_overlap across bars
      too_copied: bool (True if any exact line hit, or mean overlap > verse_threshold,
                  or any bar overlap > bar_threshold)
      reasons: short strings explaining each flag
    """
    bar_list = [b for b in bars if b and b.strip()]
    stats = [bar_overlap(b, n) for b in bar_list]
    if not stats:
        return {"bars": [], "verse_overlap": 0.0, "too_copied": False, "reasons": []}
    reasons = []
    exact_bars = [i for i, s in enumerate(stats) if s["exact_hit"]]
    hot_bars = [i for i, s in enumerate(stats) if s["ngram_overlap"] >= bar_threshold]
    verse_overlap = sum(s["ngram_overlap"] for s in stats) / len(stats)
    too_copied = False
    if exact_bars:
        too_copied = True
        reasons.append(f"exact catalog match on bar(s) {exact_bars}")
    if hot_bars:
        too_copied = True
        reasons.append(f"bar overlap >= {bar_threshold} on bar(s) {hot_bars}")
    if verse_overlap >= verse_threshold:
        too_copied = True
        reasons.append(f"verse overlap {verse_overlap:.2f} >= {verse_threshold}")
    return {
        "bars": stats, "verse_overlap": round(verse_overlap, 4),
        "too_copied": too_copied, "reasons": reasons,
    }
