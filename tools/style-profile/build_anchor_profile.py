#!/usr/bin/env python3
"""Measure Gunna's anchor-set writing and write out/anchor_profile_gunna.json.

Deterministic. No model call. Reads the lyrics CSV and the local CMUdict.
Prints a short numeric summary. Does not write lyric lines into the JSON.

Usage (from the repo root):
  python3 tools/style-profile/build_anchor_profile.py

Expect:
  a summary that starts with "Gunna anchor profile  (20 songs)"
  raw lines near 1100
  one row per anchor song
  the last line: wrote .../out/anchor_profile_gunna.json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import phase1_song_metrics as p1
import anchor_lib

HERE = Path(__file__).resolve().parent
DEFAULT_OUT = HERE / "out" / "anchor_profile_gunna.json"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--csv", type=Path, default=p1.DEFAULT_CSV)
    parser.add_argument("--cmudict", type=Path, default=p1.DEFAULT_CMU)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    args = parser.parse_args()

    built = anchor_lib.compute(args.csv, args.cmudict)
    profile = built["profile"]
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(profile, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(profile["summary"])
    print(f"\nwrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
