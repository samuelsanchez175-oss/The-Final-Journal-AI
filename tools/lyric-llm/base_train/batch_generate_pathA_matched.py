#!/usr/bin/env python3
"""Regenerate Path A on the exact (artist, topic) prompt list used by a Path B run.

batch_generate_pathA.py uses a hard-coded CONFIGS list, batch_generate_pathB_lora.py
shuffles the full 6x10 grid with seed=7. The two sets overlap on only ~7 of 20 rows,
which blocks a clean paired comparison. This script reads the Path B output JSON and
regenerates Path A verses on exactly those 20 (artist, topic) pairs in order so the
verdict scorer pairs all 20 same-prompt rows.

Usage:
  OPENAI_API_KEY=... V5_PLAN_MODEL=gpt-4o-mini V5_EDIT_MODEL=gpt-4o-mini \\
      python3 base_train/batch_generate_pathA_matched.py \\
          --path-b ../style-profile/out/model_comparison_pathB_lora_v3.json \\
          --out ../style-profile/out/model_comparison_pathA_matched.json
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
import uuid
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

from frontier_v5 import generate_v5  # noqa: E402
from inner_rhyme_check import count_bar_syllables  # noqa: E402
from lyriclib import estimate_syllables  # noqa: E402


def split_bars(raw: str) -> list[str]:
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
        "index": idx, "text": text, "halves": [],
        "syllables": syl, "end_word": end,
        "rhyme_letter": "", "internal": [], "meaning": "", "checks": {},
    }


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--path-b", type=Path, required=True,
                   help="Path B output JSON whose (artist, topic) prompts to mirror.")
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--log", type=Path, default=HERE / "out" / "path_a_matched.jsonl")
    p.add_argument("--bars", type=int, default=0,
                   help="Bars per verse. 0 = read from path-b entry 0.")
    p.add_argument("--bpm", type=float, default=140)
    p.add_argument("--path-b-key", default="v5_pathB_lora")
    args = p.parse_args()

    pathb = json.loads(args.path_b.read_text(encoding="utf-8"))
    prompts = [(e["artist"], e["topic"]) for e in pathb]
    if args.bars:
        bars_count = args.bars
    else:
        first = pathb[0].get("models", {}).get(args.path_b_key, {}).get("bars", [])
        bars_count = len(first) or 8
    print(f"regenerating {len(prompts)} verses, bars={bars_count}, bpm={args.bpm}")

    args.log.parent.mkdir(parents=True, exist_ok=True)
    log_f = args.log.open("w", encoding="utf-8")
    payload: list[dict] = []
    for i, (artist, topic) in enumerate(prompts, 1):
        print(f"[{i}/{len(prompts)}] {artist} | verse | {topic}", flush=True)
        shape = {"bpm": args.bpm, "bars": bars_count, "section_mode": "verse", "seed_line": ""}
        t0 = time.time()
        try:
            result = generate_v5(shape, voice=artist, topic_hint=topic, use_cache=False)
        except Exception as exc:
            print(f"    ERROR {type(exc).__name__}: {exc}", flush=True)
            log_f.write(json.dumps({"error": str(exc), "artist": artist, "topic": topic}) + "\n")
            continue
        log_f.write(json.dumps({**result, "_artist": artist, "_topic": topic,
                                "_elapsed_s": round(time.time() - t0, 2)}, default=str) + "\n")
        log_f.flush()
        raw = result.get("raw_text") or ""
        split = split_bars(raw)
        if not split:
            print(f"    empty bars", flush=True)
            continue
        gen_id = result.get("generation_id") or f"pathA-{uuid.uuid4().hex[:8]}"
        payload.append({
            "artist": artist,
            "topic": topic,
            "topic_brief": topic.replace("_", " "),
            "scheme": result.get("scheme") or "",
            "prompt_version": "v5-pathA-matched-to-pathB",
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
        print(f"    OK {len(split)} bars  took={time.time()-t0:.1f}s", flush=True)
    log_f.close()
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(f"\nwrote {len(payload)} verses to {args.out}")
    print(f"raw log: {args.log}")
    return 0 if payload else 1


if __name__ == "__main__":
    raise SystemExit(main())
