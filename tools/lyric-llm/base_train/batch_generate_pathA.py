#!/usr/bin/env python3
"""Path A batch generator: v5 pipeline + base gpt-4o-mini (no fine-tune).

Writes a Sparkler-compatible JSON for the rater. One generation_id per verse.
Also keeps a jsonl log with raw v5 result for audit.

Usage:
  OPENAI_API_KEY=... V5_PLAN_MODEL=gpt-4o-mini V5_EDIT_MODEL=gpt-4o-mini \
      python3 base_train/batch_generate_pathA.py --n 20 --bars 8
"""

from __future__ import annotations

import argparse
import json
import os
import random
import re
import sys
import time
import uuid
from datetime import datetime
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

from frontier_v5 import generate_v5  # noqa: E402
from inner_rhyme_check import count_bar_syllables  # noqa: E402
from lyriclib import estimate_syllables  # noqa: E402

CONFIGS = [
    ("Gunna",      "verse", "luxury_brands"),
    ("Gunna",      "verse", "money_flex"),
    ("Gunna",      "verse", "women_romance"),
    ("Gunna",      "verse", "come_up_hustle"),
    ("Drake",      "verse", "women_romance"),
    ("Drake",      "verse", "fame_industry"),
    ("Drake",      "verse", "loyalty_friends"),
    ("Lil Wayne",  "verse", "braggadocio_skill"),
    ("Lil Wayne",  "verse", "violence_street"),
    ("Lil Wayne",  "verse", "women_romance"),
    ("Lil Baby",   "verse", "come_up_hustle"),
    ("Lil Baby",   "verse", "money_flex"),
    ("Lil Baby",   "verse", "loyalty_friends"),
    ("NoCap",      "verse", "pain_trauma"),
    ("NoCap",      "verse", "come_up_hustle"),
    ("NoCap",      "verse", "loyalty_friends"),
    ("Young Thug", "verse", "women_romance"),
    ("Young Thug", "verse", "money_flex"),
    ("Young Thug", "verse", "braggadocio_skill"),
    ("Young Thug", "verse", "luxury_brands"),
]


def split_bars(raw: str) -> list[str]:
    """Pull one bar per line, drop leading numbering/quotes."""
    bars: list[str] = []
    for line in (raw or "").splitlines():
        s = line.strip()
        if not s:
            continue
        s = re.sub(r"^\d+\.\s*", "", s)
        s = s.strip().strip('"').strip("'").strip()
        if s:
            bars.append(s)
    return bars


def to_sparkler_bar(text: str, idx: int) -> dict:
    end = text.rstrip(".,!?;:").split()[-1] if text.strip() else ""
    end = end.strip(".,!?;:'\"").lower()
    try:
        syl = count_bar_syllables(text)
    except Exception:
        syl = estimate_syllables(text)
    return {
        "index": idx,
        "text": text,
        "halves": [],
        "syllables": syl,
        "end_word": end,
        "rhyme_letter": "",
        "internal": [],
        "meaning": "",
        "checks": {},
    }


def run_one(artist: str, section: str, topic: str, bars: int, bpm: float) -> dict:
    shape = {"bpm": bpm, "bars": bars, "section_mode": section, "seed_line": ""}
    t0 = time.time()
    try:
        result = generate_v5(shape, voice=artist, topic_hint=topic, use_cache=False)
    except Exception as exc:
        return {"error": f"{type(exc).__name__}: {exc}", "artist": artist, "section": section, "topic": topic}
    result["_elapsed_s"] = round(time.time() - t0, 2)
    result["_artist"] = artist
    result["_section"] = section
    result["_topic"] = topic
    return result


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--n", type=int, default=len(CONFIGS))
    p.add_argument("--bars", type=int, default=8)
    p.add_argument("--bpm", type=float, default=140)
    p.add_argument("--out", type=Path, default=HERE / "out" / "path_a_batch.json")
    p.add_argument("--log", type=Path, default=HERE / "out" / "path_a_batch.jsonl")
    args = p.parse_args(argv)

    configs = CONFIGS[: args.n]
    rater_payload: list[dict] = []
    log_file = args.log.open("w", encoding="utf-8")

    print(f"generating {len(configs)} verses, bars={args.bars}, bpm={args.bpm}")
    for i, (artist, section, topic) in enumerate(configs, 1):
        print(f"[{i}/{len(configs)}] {artist} | {section} | {topic}", flush=True)
        result = run_one(artist, section, topic, args.bars, args.bpm)
        log_file.write(json.dumps(result, default=str) + "\n")
        log_file.flush()
        if "error" in result:
            print(f"    ERROR {result['error']}", flush=True)
            continue
        raw = result.get("raw_text") or ""
        split = split_bars(raw)
        if not split:
            print(f"    empty bars (len raw={len(raw)})", flush=True)
            continue
        gen_id = result.get("generation_id") or f"pathA-{uuid.uuid4().hex[:8]}"
        rater_payload.append({
            "artist": artist,
            "topic": topic,
            "topic_brief": topic.replace("_", " "),
            "scheme": result.get("scheme") or "",
            "prompt_version": "v5-pathA-gpt4omini",
            "models": {
                "v5_pathA": {
                    "generation_id": gen_id,
                    "model": "gpt-4o-mini",
                    "artist": artist,
                    "topic": topic,
                    "scheme": result.get("scheme") or "",
                    "passed": bool(result.get("verified")),
                    "bars": [to_sparkler_bar(b, idx) for idx, b in enumerate(split)],
                }
            },
        })
        print(f"    OK {len(split)} bars  verified={bool(result.get('verified'))}  took={result.get('_elapsed_s')}s", flush=True)

    log_file.close()
    args.out.write_text(json.dumps(rater_payload, indent=2), encoding="utf-8")
    print(f"\nwrote {len(rater_payload)} verses to {args.out}")
    print(f"raw log: {args.log}")
    return 0 if rater_payload else 1


if __name__ == "__main__":
    raise SystemExit(main())
