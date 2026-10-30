"""Load Samuel's ratings into verse-level and bar-level supervision pairs.

Verse pairs: within each sparkler ratings file, every (hi_score, lo_score)
pair with distinct scores becomes a preference example (hi beats lo).

Bar pairs: when `bar_votes[].rewrite` is non-empty, the rewrite beats the
original bar. Both get wrapped as 1-bar "mini-verses" for feature extraction.

LOO19 jsonl contributes verse-level labels only (`samuel_score`).
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Iterator

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent.parent
LLM_ROOT = HERE.parent
RATINGS_DIR = REPO / "tools" / "style-profile" / "rater" / "exports"

import sys
sys.path.insert(0, str(LLM_ROOT))
from taste.features import extract  # noqa: E402


def _norm_bars(entry: dict) -> list[str]:
    bars = entry.get("bars") or entry.get("verse_bars") or []
    if isinstance(bars, list) and bars and isinstance(bars[0], dict):
        return [b.get("text", "") for b in bars if b.get("text")]
    if isinstance(bars, list):
        return [str(b).strip() for b in bars if b and str(b).strip()]
    # fall back to text split
    text = entry.get("text") or entry.get("verse") or ""
    return [l.strip() for l in text.splitlines() if l.strip()]


def _bars_from_bar_votes(bar_votes: list[dict]) -> list[str]:
    """Rebuild original bar list from bar_votes[].text (preserving index)."""
    if not bar_votes:
        return []
    indexed = []
    for b in bar_votes:
        idx = b.get("bar_index")
        text = b.get("text")
        if isinstance(idx, int) and text:
            indexed.append((idx, text))
    indexed.sort()
    return [t for _, t in indexed]


def iter_verse_rows(dedupe: bool = True) -> Iterator[dict]:
    """Yield verse-level rated rows with features.

    When `dedupe` is True (default), rows with the same (generation_id, artist,
    topic) are deduplicated keeping the most recently rated one (max rated_at).
    """
    all_rows: list[dict] = []
    # sparkler files
    for p in sorted(RATINGS_DIR.glob("sparkler_ratings_*.json")):
        try:
            data = json.loads(p.read_text())
        except Exception:
            continue
        for r in data.get("ratings", []):
            score = r.get("verse_score")
            if not isinstance(score, (int, float)):
                continue
            bars = _bars_from_bar_votes(r.get("bar_votes") or [])
            if not bars:
                bars = _norm_bars(r)
            if not bars:
                continue
            voice = r.get("artist") or ""
            all_rows.append({
                "source": p.name,
                "generation_id": r.get("generation_id"),
                "artist": voice,
                "topic": r.get("topic"),
                "engine": r.get("model"),
                "score": float(score),
                "reasons": r.get("verse_reasons") or [],
                "bars": bars,
                "rated_at": r.get("rated_at") or "",
                "features": extract(bars, voice=voice),
            })
    # LOO19
    loo = RATINGS_DIR / "autograde_loo19.jsonl"
    if loo.exists():
        for line in loo.read_text().splitlines():
            if not line.strip():
                continue
            r = json.loads(line)
            score = r.get("samuel_score")
            if not isinstance(score, (int, float)):
                continue
            bars = _norm_bars(r)
            if not bars:
                continue
            voice = r.get("artist") or ""
            all_rows.append({
                "source": loo.name,
                "generation_id": r.get("generation_id"),
                "artist": voice,
                "topic": r.get("topic"),
                "engine": r.get("model"),
                "score": float(score),
                "reasons": r.get("samuel_reasons") or [],
                "bars": bars,
                "rated_at": "",
                "features": extract(bars, voice=voice),
            })

    if not dedupe:
        yield from all_rows
        return
    # dedupe by (generation_id, artist, topic); keep max rated_at
    best: dict[tuple, dict] = {}
    for r in all_rows:
        key = (r.get("generation_id") or "", r.get("artist") or "", r.get("topic") or "")
        prev = best.get(key)
        if prev is None or (r.get("rated_at") or "") > (prev.get("rated_at") or ""):
            best[key] = r
    for r in best.values():
        yield r


def verse_group_key(row: dict) -> str:
    """Group-identifier for a rated row: shared by a verse and its bar rewrites."""
    gid = row.get("generation_id")
    if gid:
        return str(gid)
    # fallback: hash of bar text joined
    return "|".join((row.get("bars") or []))[:120]


def iter_bar_rewrite_pairs() -> Iterator[dict]:
    """Yield (original_bar, rewrite_bar, voice) training pairs where
    the rewrite is Samuel's fix (rewrite > original)."""
    for p in sorted(RATINGS_DIR.glob("sparkler_ratings_*.json")):
        try:
            data = json.loads(p.read_text())
        except Exception:
            continue
        for r in data.get("ratings", []):
            voice = r.get("artist") or ""
            for b in r.get("bar_votes") or []:
                rewrite = (b.get("rewrite") or "").strip()
                orig = (b.get("text") or "").strip()
                if rewrite and orig and rewrite != orig:
                    yield {
                        "voice": voice,
                        "orig": orig,
                        "rewrite": rewrite,
                        "orig_features": extract([orig], voice=voice),
                        "rewrite_features": extract([rewrite], voice=voice),
                    }


def build_pairs(rows: list[dict]) -> list[tuple[list[float], list[float], int, dict]]:
    """Group verse rows by source file; emit all within-file pairs where
    scores differ. Returns [(vec_hi, vec_lo, label=1, meta)]."""
    from collections import defaultdict
    from taste.features import vector
    pairs: list[tuple] = []
    by_src = defaultdict(list)
    for r in rows:
        by_src[r["source"]].append(r)
    for src, rs in by_src.items():
        for i, a in enumerate(rs):
            for b in rs[i + 1:]:
                if a["score"] == b["score"]:
                    continue
                hi, lo = (a, b) if a["score"] > b["score"] else (b, a)
                pairs.append((
                    vector(hi["features"]), vector(lo["features"]), 1,
                    {"src": src, "hi_id": hi["generation_id"], "lo_id": lo["generation_id"],
                     "hi_score": hi["score"], "lo_score": lo["score"]},
                ))
    return pairs


def build_bar_pairs(rewrite_rows: list[dict]) -> list[tuple[list[float], list[float], int, dict]]:
    from taste.features import vector
    out = []
    for r in rewrite_rows:
        out.append((
            vector(r["rewrite_features"]), vector(r["orig_features"]), 1,
            {"src": "bar_rewrite", "voice": r["voice"], "orig": r["orig"], "rewrite": r["rewrite"]},
        ))
    return out
