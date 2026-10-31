#!/usr/bin/env python3
"""
Frontier v4 Telemetry System (Task K)
Logs structured per-bar telemetry to tools/lyric-llm/out/v4_telemetry.jsonl.
Tracks:
  - generation_id: Unique generation identifier
  - bar_index: 1-based bar sequence (1..8)
  - voice: Artist voice / pocket for this bar
  - retrieval_hit: Whether authentic catalog bar was matched
  - retrieval_id: SQLite catalog bar ID
  - edit_distance: Word-level edit ratio (target 20-30%)
  - end_word_preserved: Whether target catalog end word was kept on Beat 4
  - rhyme_family: Vowel or rime class
  - target_syl: Syllable budget
  - actual_syl: Realized syllable count
  - delta: actual_syl - target_syl
  - punch_demoted: Whether punch token was demoted mid-bar instead of end-word
  - style_score: Learned style classifier / scorer probability
  - plan_hit: Whether bar aligned with reasoning blueprint
"""

import json
import os
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
OUT = HERE / "out"
TELEMETRY_PATH = OUT / "v4_telemetry.jsonl"

from lyriclib import normalize, tokenize

# Known signature punch tokens for punch-demotion checks
SIGNATURE_PUNCH_TOKENS = {
    "audamar", "audemars", "maybach", "patek", "celine", "cullinan", "phantom",
    "rolex", "rollie", "chanel", "goyard", "cartier", "lambo", "ferrari", "amiri",
    "bando", "switch", "glock", "draco", "lobster", "mercedes", "rich", "bag",
    "racks", "bands", "trap", "wraith", "rich"
}

REQUIRED_TELEMETRY_FIELDS = [
    "generation_id",
    "bar_index",
    "voice",
    "retrieval_hit",
    "retrieval_id",
    "edit_distance",
    "end_word_preserved",
    "rhyme_family",
    "target_syl",
    "actual_syl",
    "delta",
    "punch_demoted",
    "style_score",
    "plan_hit",
]


def check_punch_demoted(bar_text: str, target_end_word: str = "", punch_bank: Optional[set[str]] = None) -> bool:
    """
    Checks whether a signature punch token appeared mid-bar instead of as the bar's end word.
    Per eval/grade_modelyou.py punchDemoted rule:
      A punch token appearing anywhere but the bar's end word is demoted.
    """
    toks = tokenize(normalize(bar_text))
    if len(toks) < 2:
        return False
    end_w = toks[-1].lower()

    # 1. Target word demoted to setup/mid-bar
    if target_end_word:
        t_clean = target_end_word.lower()
        if t_clean in toks[:-1]:
            # If end word matches target (or known alias), it's not demoted
            if end_w == t_clean or (t_clean == "audamar" and end_w == "audemars"):
                pass
            else:
                return True

    # 2. Known punch token bank demoted
    bank = punch_bank if punch_bank is not None else SIGNATURE_PUNCH_TOKENS
    for p in bank:
        p_clean = p.lower()
        if p_clean in toks[:-1] and end_w != p_clean:
            if not (p_clean == "audamar" and end_w == "audemars"):
                return True

    return False


def write_bar_telemetry(row: dict[str, Any], telemetry_path: Path = TELEMETRY_PATH) -> dict[str, Any]:
    """Writes a single validated per-bar telemetry row to v4_telemetry.jsonl."""
    # Ensure required fields are present with correct types
    record = {
        "generation_id": str(row.get("generation_id", f"gen_{int(time.time())}")),
        "bar_index": int(row.get("bar_index", 1)),
        "voice": str(row.get("voice", "Gunna")),
        "retrieval_hit": bool(row.get("retrieval_hit", False)),
        "retrieval_id": row.get("retrieval_id"),
        "edit_distance": round(float(row.get("edit_distance", 0.0)), 3),
        "end_word_preserved": bool(row.get("end_word_preserved", False)),
        "rhyme_family": str(row.get("rhyme_family", "")),
        "target_syl": int(row.get("target_syl", 18)),
        "actual_syl": int(row.get("actual_syl", 18)),
        "delta": int(row.get("delta", 0)),
        "punch_demoted": bool(row.get("punch_demoted", False)),
        "style_score": round(float(row.get("style_score", 0.0)), 3),
        "plan_hit": bool(row.get("plan_hit", False)),
        "timestamp": row.get("timestamp") or datetime.now(timezone.utc).isoformat(),
        "text": row.get("text", ""),
        "retries_used": int(row.get("retries_used") or 0),
        "retries_exhausted_at": list(row.get("retries_exhausted_at") or []),
    }

    telemetry_path.parent.mkdir(parents=True, exist_ok=True)
    with telemetry_path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(record) + "\n")
    return record


def write_verse_telemetry(
    generation_id: str,
    bars: list[dict[str, Any]],
    plan: Optional[dict[str, Any]] = None,
    style_score: float = 0.0,
    voice: str = "Gunna",
    telemetry_path: Path = TELEMETRY_PATH,
) -> list[dict[str, Any]]:
    """Writes telemetry rows for all bars in a generated verse."""
    plan = plan or {}
    planned_voices = plan.get("couplet_voices", [])
    planned_ends = plan.get("end_words", [])
    planned_rhymes = plan.get("rhyme_families", [])

    written = []
    ts = datetime.now(timezone.utc).isoformat()

    for idx, b in enumerate(bars):
        couplet_idx = idx // 2
        bar_idx = b.get("index", idx + 1)
        bar_voice = b.get("artist") or (planned_voices[couplet_idx] if couplet_idx < len(planned_voices) else voice)
        bar_text = b.get("text") or b.get("raw_text") or ""
        end_w = (b.get("end_word") or "").lower()

        # Check retrieval information
        cat_id = b.get("source_catalog_id") or (b.get("source_catalog_bar", {}).get("id") if isinstance(b.get("source_catalog_bar"), dict) else None)
        retrieval_hit = bool(cat_id or b.get("source_catalog_text"))

        edit_dist = b.get("edit_distance_ratio", 0.25)
        end_preserved = b.get("end_word_preserved", True)
        rhyme_fam = b.get("rhyme_family", "")
        target_syl = b.get("target_syllables", 18)
        actual_syl = b.get("syllables", target_syl)
        delta = b.get("delta", actual_syl - target_syl)

        # Planned targets for plan_hit calculation
        p_voice = planned_voices[couplet_idx] if couplet_idx < len(planned_voices) else voice
        p_end = (planned_ends[idx] if idx < len(planned_ends) else "").lower()
        p_rhyme = (planned_rhymes[couplet_idx % len(planned_rhymes)] if planned_rhymes else "").lower()

        # Check punch demoted
        p_demoted = check_punch_demoted(bar_text, target_end_word=p_end)

        # Check plan hit: voice matches and (end word matches planned target, or preserved, or rhyme family matches)
        voice_hit = (bar_voice.lower() == p_voice.lower())
        end_hit = (end_w == p_end) or (p_end == "audamar" and end_w == "audemars") or end_preserved or (p_rhyme and p_rhyme in rhyme_fam.lower())
        plan_hit = voice_hit and bool(end_hit)

        row = {
            "generation_id": generation_id,
            "bar_index": bar_idx,
            "voice": bar_voice,
            "retrieval_hit": retrieval_hit,
            "retrieval_id": cat_id,
            "edit_distance": edit_dist,
            "end_word_preserved": end_preserved,
            "rhyme_family": rhyme_fam,
            "target_syl": target_syl,
            "actual_syl": actual_syl,
            "delta": delta,
            "punch_demoted": p_demoted,
            "style_score": style_score,
            "plan_hit": plan_hit,
            "timestamp": ts,
            "text": bar_text,
            "retries_used": int(b.get("retries_used") or 0),
            "retries_exhausted_at": list(b.get("retries_exhausted_at") or []),
        }
        written.append(write_bar_telemetry(row, telemetry_path=telemetry_path))

    return written


def read_telemetry(limit: int = 50, telemetry_path: Path = TELEMETRY_PATH) -> list[dict[str, Any]]:
    """Reads the last N telemetry rows from v4_telemetry.jsonl."""
    if not telemetry_path.exists():
        return []
    rows = []
    try:
        with telemetry_path.open("r", encoding="utf-8") as f:
            for line in f:
                line_str = line.strip()
                if line_str:
                    try:
                        rows.append(json.loads(line_str))
                    except Exception:
                        continue
    except Exception:
        return []
    return rows[-limit:] if limit > 0 else rows


def bar_telemetry_rows(rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Keep formal per-bar rows. Retrieval-fallback events stay out of the rates."""
    kept = []
    for row in rows:
        if row.get("event") == "retrieval_fallback":
            continue
        if "generation_id" not in row or "bar_index" not in row:
            continue
        kept.append(row)
    return kept


def get_telemetry_stats(telemetry_path: Path = TELEMETRY_PATH) -> dict[str, Any]:
    """Computes aggregate analytics and gate metrics across formal per-bar rows."""
    rows = bar_telemetry_rows(read_telemetry(limit=0, telemetry_path=telemetry_path))
    total_bars = len(rows)
    if total_bars == 0:
        return {
            "total_bars": 0,
            "total_generations": 0,
            "retrieval_hit_rate": 0.0,
            "end_word_preservation_rate": 0.0,
            "mean_edit_distance": 0.0,
            "mean_syllable_delta": 0.0,
            "on_grid_rate": 0.0,
            "punch_demoted_count": 0,
            "punch_demoted_rate": 0.0,
            "plan_hit_rate": 0.0,
            "mean_style_score": 0.0,
        }

    gens = {r.get("generation_id") for r in rows if r.get("generation_id")}
    retrieval_hits = sum(1 for r in rows if r.get("retrieval_hit"))
    ends_preserved = sum(1 for r in rows if r.get("end_word_preserved"))
    plan_hits = sum(1 for r in rows if r.get("plan_hit"))
    punch_demoted_cnt = sum(1 for r in rows if r.get("punch_demoted"))
    on_grid_cnt = sum(1 for r in rows if abs(r.get("delta", 0)) <= 1)

    mean_edit = sum(r.get("edit_distance", 0.0) for r in rows) / float(total_bars)
    mean_abs_delta = sum(abs(r.get("delta", 0)) for r in rows) / float(total_bars)
    mean_style = sum(r.get("style_score", 0.0) for r in rows) / float(total_bars)

    return {
        "total_bars": total_bars,
        "total_generations": len(gens),
        "retrieval_hit_rate": round(retrieval_hits / float(total_bars), 3),
        "end_word_preservation_rate": round(ends_preserved / float(total_bars), 3),
        "mean_edit_distance": round(mean_edit, 3),
        "mean_syllable_delta": round(mean_abs_delta, 2),
        "on_grid_rate": round(on_grid_cnt / float(total_bars), 3),
        "punch_demoted_count": punch_demoted_cnt,
        "punch_demoted_rate": round(punch_demoted_cnt / float(total_bars), 3),
        "plan_hit_rate": round(plan_hits / float(total_bars), 3),
        "mean_style_score": round(mean_style, 3),
    }


if __name__ == "__main__":
    stats = get_telemetry_stats()
    print("[Frontier V4 Telemetry Stats]")
    print(json.dumps(stats, indent=2))
