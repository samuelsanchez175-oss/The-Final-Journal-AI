#!/usr/bin/env python3
"""
Frontier v4 Prompt & Params Cache (Task L)
Hashes canonical generation parameters:
  (voice, blend, mix, bpm, scale, section_mode, chosen_albums, seed_line, scratchpad, topic_hint, remix_ratio)
Caches both retrieved catalog blocks and the final verse to tools/lyric-llm/out/cache/<hash>.json.
Supports --no-cache bypass.
"""

from __future__ import annotations

import hashlib
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
CACHE_DIR = OUT / "cache"


def canonical_cache_params(
    voice: str = "Gunna",
    blend: Optional[str] = None,
    mix: int = 70,
    bpm: float = 130.0,
    scale: str = "F minor",
    section_mode: str = "verse",
    chosen_albums: Optional[list[str]] = None,
    seed_line: str = "",
    scratchpad: str = "",
    topic_hint: str = "",
    remix_ratio: int = 25,
    base_cap: float = 0.30,
    bars_count: int = 8,
    target_syl: Optional[int] = None,
    taste_on: bool = True,
    taste_k: int = 6,
    engine: str = "v4",
    **kwargs: Any,
) -> dict[str, Any]:
    """Returns a deterministic, normalized dictionary of generation parameters for hashing."""
    # Normalize albums to sorted lower-case list
    norm_albums = sorted([str(a).strip().lower() for a in (chosen_albums or []) if a and str(a).strip()])
    return {
        "engine": (engine or "v4").strip().lower(),
        "voice": (voice or "Gunna").strip().title(),
        "blend": (blend or "").strip().title() if blend else None,
        "mix": int(mix) if blend else None,
        "bpm": round(float(bpm), 1),
        "scale": (scale or "F minor").strip(),
        "section_mode": (section_mode or "verse").strip().lower(),
        "chosen_albums": norm_albums,
        "seed_line": (seed_line or "").strip(),
        "scratchpad": (scratchpad or "").strip(),
        "topic_hint": (topic_hint or "").strip().lower(),
        "remix_ratio": int(remix_ratio),
        "base_cap": round(float(base_cap), 2),
        "bars_count": int(bars_count),
        "target_syl": int(target_syl) if target_syl else None,
        "taste_on": bool(taste_on),
        "taste_k": int(taste_k),
    }


def compute_cache_key(params: dict[str, Any]) -> str:
    """Computes a deterministic SHA-256 hex digest for the parameter dictionary."""
    canonical_json = json.dumps(params, sort_keys=True, separators=(",", ":"), ensure_ascii=True)
    return hashlib.sha256(canonical_json.encode("utf-8")).hexdigest()


def get_cached_verse(
    cache_key: str,
    cache_dir: Path = CACHE_DIR,
    max_age_seconds: Optional[float] = None,
) -> Optional[dict[str, Any]]:
    """
    Retrieves cached generation result if present and valid.
    Returns None if cache miss, corrupt, or expired.
    """
    cache_file = cache_dir / f"{cache_key}.json"
    if not cache_file.exists():
        return None

    try:
        if max_age_seconds is not None:
            age = time.time() - cache_file.stat().st_mtime
            if age > max_age_seconds:
                return None

        with cache_file.open("r", encoding="utf-8") as f:
            data = json.load(f)

        if isinstance(data, dict) and "result" in data:
            res = dict(data["result"])
            res["cached"] = True
            res["cache_key"] = cache_key
            res["cached_at"] = data.get("created_at")
            if "plan" in data and not res.get("plan"):
                res["plan"] = data["plan"]
            if "retrieved_catalog_bars" in data and not res.get("retrieved_catalog_bars"):
                res["retrieved_catalog_bars"] = data["retrieved_catalog_bars"]
            return res
    except Exception:
        return None
    return None


def save_cached_verse(
    cache_key: str,
    params: dict[str, Any],
    result: dict[str, Any],
    retrieved_catalog_bars: Optional[list[Any]] = None,
    plan: Optional[dict[str, Any]] = None,
    cache_dir: Path = CACHE_DIR,
) -> Path:
    """
    Atomically writes the verse result, retrieved catalog bars, and plan to disk.
    """
    cache_dir.mkdir(parents=True, exist_ok=True)
    cache_file = cache_dir / f"{cache_key}.json"

    # Make clean copy of result without volatile flags
    clean_result = dict(result)
    clean_result["cached"] = True
    clean_result["cache_key"] = cache_key

    payload = {
        "cache_key": cache_key,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "params": params,
        "plan": plan or result.get("plan"),
        "retrieved_catalog_bars": retrieved_catalog_bars or result.get("retrieved_catalog_bars"),
        "result": clean_result,
    }

    # Write atomically via temp file to avoid race conditions
    temp_file = cache_dir / f"{cache_key}.tmp.{os.getpid()}"
    with temp_file.open("w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=True)
    temp_file.replace(cache_file)
    return cache_file


def clear_cache(cache_dir: Path = CACHE_DIR) -> int:
    """Removes all cached JSON entries and returns the number of deleted files."""
    if not cache_dir.exists():
        return 0
    count = 0
    for p in cache_dir.glob("*.json"):
        try:
            p.unlink()
            count += 1
        except Exception:
            pass
    return count


def get_cache_stats(cache_dir: Path = CACHE_DIR) -> dict[str, Any]:
    """Returns statistics about the current prompt & params cache."""
    if not cache_dir.exists():
        return {
            "total_entries": 0,
            "size_bytes": 0,
            "size_kb": 0.0,
            "oldest_entry": None,
            "newest_entry": None,
            "cache_dir": str(cache_dir),
        }

    files = list(cache_dir.glob("*.json"))
    total_size = sum(f.stat().st_size for f in files)
    mtimes = [f.stat().st_mtime for f in files] if files else []

    return {
        "total_entries": len(files),
        "size_bytes": total_size,
        "size_kb": round(total_size / 1024.0, 2),
        "oldest_entry": datetime.fromtimestamp(min(mtimes), tz=timezone.utc).isoformat() if mtimes else None,
        "newest_entry": datetime.fromtimestamp(max(mtimes), tz=timezone.utc).isoformat() if mtimes else None,
        "cache_dir": str(cache_dir),
    }


if __name__ == "__main__":
    stats = get_cache_stats()
    print("[Frontier V4 Prompt & Params Cache Stats]")
    print(json.dumps(stats, indent=2))
