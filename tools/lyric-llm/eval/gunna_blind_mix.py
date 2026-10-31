#!/usr/bin/env python3
"""Blind mix of 5 Gunna verses. Samuel runs this. Do not call it from an agent.

Mix, shuffled with seed 20261031:
  1 V6 verse  (generate_v5)
  2 V7 verses (generate_v7, shipped only)
  2 real Gunna verses (first 8 lines of two songs)

Writes:
  tools/lyric-llm/out/gunna_blind_verses.txt
  tools/lyric-llm/out/gunna_blind_key.json

The blind file has verse numbers and bars. The key file maps each slot to
an arm. This script does not print that map.

Exit 2 when OPENAI_API_KEY is missing, before any generation.
Exit 1 when a V7 does not ship after 3 tries, a V6 does not verify after
3 tries, or the vault cannot supply 2 songs. A failed run writes no mix.
"""
from __future__ import annotations

import json
import os
import random
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
LLM_ROOT = HERE.parent
if str(LLM_ROOT) not in sys.path:
    sys.path.insert(0, str(LLM_ROOT))

SEED = 20261031
BARS = 8
OUT_DIR = LLM_ROOT / "out"
BLIND_PATH = OUT_DIR / "gunna_blind_verses.txt"
KEY_PATH = OUT_DIR / "gunna_blind_key.json"
PROMPT = {"bpm": 140, "bars": BARS, "section_mode": "verse", "topic_hint": "jewelry"}


def _v6_bars(result: dict) -> list[str]:
    bars = []
    for item in result.get("bars") or []:
        if isinstance(item, dict):
            text = str(item.get("text") or "").strip()
        else:
            text = str(item).strip()
        if text:
            bars.append(text)
    return bars


def _generate_v6(generate_v5) -> tuple[dict, list[str]]:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    last: dict = {}
    bars: list[str] = []
    for _attempt in range(3):
        last = generate_v5(
            dict(PROMPT),
            voice="Gunna",
            topic_hint="jewelry",
            use_cache=False,
            candidates=1,
            telemetry_path=OUT_DIR / "gunna_blind_v6_telemetry.jsonl",
            history_path=OUT_DIR / "gunna_blind_v6_end_words.json",
        )
        bars = _v6_bars(last)
        if last.get("verified") and len(bars) == BARS:
            return last, bars
    return last, bars


def _generate_v7(generate_v7, seed: int, used: set) -> object:
    last = None
    for attempt in range(3):
        last = generate_v7(
            {"bpm": 140, "bars": BARS, "section_mode": "verse"},
            voice="Gunna",
            topic="jewelry",
            seed=seed + attempt,
            used_families=used,
            retries_per_bar=1,
            block_retries=2,
        )
        if last.shipped and len(last.bars) == BARS:
            return last
    return last


def main() -> int:
    # frontier_v5 reads these at import. Planner stays mini. V6 editor is gpt-4o.
    os.environ.setdefault("V5_PLAN_MODEL", "gpt-4o-mini")
    os.environ.setdefault("V5_EDIT_MODEL", "gpt-4o")
    os.environ.setdefault("V7_PLAN_MODEL", "gpt-4o-mini")
    os.environ.setdefault("V7_WRITER_MODEL", "gpt-4o")
    # Loading the client reads ~/.env. It does not call the API.
    import llm_client  # noqa: F401

    if not os.environ.get("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set. Export the key and re-run.", file=sys.stderr)
        return 2

    from frontier_v5 import generate_v5
    from frontier_v7 import generate_v7, load_real_spans

    spans = load_real_spans("Gunna", count=2, bars=BARS, seed=SEED)
    if len(spans) < 2:
        print("ERROR: vault did not return 2 Gunna songs with 8 lines.", file=sys.stderr)
        return 1

    v6, v6_bars = _generate_v6(generate_v5)
    if not v6.get("verified") or len(v6_bars) != BARS:
        print("ERROR: V6 did not verify after 3 tries.", file=sys.stderr)
        reasons = v6.get("violations") or []
        if reasons:
            print("V6 violations: " + "; ".join(str(item) for item in reasons[:8]), file=sys.stderr)
        return 1

    used: set = set()
    v7_results = []
    for offset in (0, 100):
        result = _generate_v7(generate_v7, SEED + offset, used)
        if result is None or not result.shipped or len(result.bars) != BARS:
            print("ERROR: V7 did not ship after 3 tries.", file=sys.stderr)
            rolled = list(getattr(result, "violations_rolled_up", []) or [])
            if rolled:
                print("V7 violations: " + "; ".join(rolled[:8]), file=sys.stderr)
            return 1
        v7_results.append(result)

    items = [
        {"arm": "v6", "lines": v6_bars, "generation_id": v6.get("generation_id"), "song": None},
        {"arm": "v7", "lines": list(v7_results[0].bars),
         "generation_id": v7_results[0].generation_id, "song": None},
        {"arm": "v7", "lines": list(v7_results[1].bars),
         "generation_id": v7_results[1].generation_id, "song": None},
        {"arm": "real", "lines": spans[0]["lines"], "generation_id": None, "song": spans[0]["song"]},
        {"arm": "real", "lines": spans[1]["lines"], "generation_id": None, "song": spans[1]["song"]},
    ]
    random.Random(SEED).shuffle(items)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    parts = []
    slots = []
    for index, item in enumerate(items, start=1):
        parts.append(f"Verse {index}\n" + "\n".join(item["lines"]))
        slots.append({
            "slot": index,
            "arm": item["arm"],
            "generation_id": item["generation_id"],
            "song": item["song"],
        })
    BLIND_PATH.write_text("\n\n".join(parts) + "\n", encoding="utf-8")
    KEY_PATH.write_text(json.dumps({
        "seed": SEED,
        "mix": {"v6": 1, "v7": 2, "real": 2},
        "slots": slots,
    }, indent=2) + "\n", encoding="utf-8")
    print(f"wrote 5 verses to {BLIND_PATH}")
    print(f"labels are in {KEY_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
