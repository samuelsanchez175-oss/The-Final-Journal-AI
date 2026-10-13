#!/usr/bin/env python3
"""Merge Antigravity's manual tempo lookup into Phase 3 cache.

Usage:
  python3 tools/style-profile/merge_tempo_manual.py

Reads out/tempo_manual.jsonl, merges exact/variant rows into tempo_cache.jsonl,
skips rows already in cache, writes merged count.
"""

from pathlib import Path
import json
import sys

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"

def main():
    manual_path = OUT / "tempo_manual.jsonl"
    cache_path = OUT / "tempo_cache.jsonl"

    if not manual_path.exists():
        print(f"tempo_manual.jsonl not found at {manual_path}")
        return 1

    # Load existing cache keys
    cache_keys = set()
    if cache_path.exists():
        for line in cache_path.read_text(encoding="utf-8").splitlines():
            if line.strip():
                r = json.loads(line)
                cache_keys.add((r["artist"], r["song"]))

    # Read manual rows, merge valid ones
    added = skipped_exists = skipped_invalid = 0
    with open(cache_path, "a", encoding="utf-8") as out_fh:
        for line in manual_path.read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            m = json.loads(line)

            # Skip if already in cache
            key = (m["artist"], m["song"])
            if key in cache_keys:
                skipped_exists += 1
                continue

            # Skip if not exact/variant or no BPM
            if m.get("confidence") not in ("exact", "variant") or not isinstance(m.get("bpm"), (int, float)):
                skipped_invalid += 1
                continue

            # Write merged row
            upd = {
                "artist": m["artist"],
                "song": m["song"],
                "tempo": round(float(m["bpm"]), 2),
                "key_name": m.get("key"),
                "tempo_source": f"web:{m.get('source')}",
                "tempo_url": m.get("url"),
                "tempo_confidence": m["confidence"]
            }
            out_fh.write(json.dumps(upd, ensure_ascii=False) + "\n")
            cache_keys.add(key)
            added += 1

    print(f"merged: {added} added, {skipped_exists} skipped (already cached), {skipped_invalid} skipped (invalid)")
    return 0

if __name__ == "__main__":
    sys.exit(main())
