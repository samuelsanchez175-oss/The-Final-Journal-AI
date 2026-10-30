#!/usr/bin/env python3
"""Run both paths through taste30 and build a blind rater export.

Path A (baseline):  frontier_v5.generate_v5  — no best-of-N, no wordplay hints.
Path B (new):       frontier_v5.generate_judged — best-of-8, taste judge,
                    originality guard, confirmed-wordplay few-shot.

Outputs:
  eval/taste30_runs_blind.json       — sparkler-compatible, labels hidden
  eval/taste30_runs_labels.json      — generation_id -> path label (keep private)
  out/path_taste30_baseline.jsonl    — raw log for Path A
  out/path_taste30_judged.jsonl      — raw log for Path B

Requires OPENAI_API_KEY in the environment. Exits with status 2 and a
clear message if the key is missing; does NOT fake outputs.
"""
from __future__ import annotations

import json
import os
import random
import sys
import time
import uuid
from pathlib import Path

HERE = Path(__file__).resolve().parent
LLM_ROOT = HERE.parent
sys.path.insert(0, str(LLM_ROOT))

TASTE30 = HERE / "taste30.jsonl"
OUT_BLIND = HERE / "taste30_runs_blind.json"
OUT_LABELS = HERE / "taste30_runs_labels.json"
LOG_DIR = LLM_ROOT / "out"
LOG_A = LOG_DIR / "path_taste30_baseline.jsonl"
LOG_B = LOG_DIR / "path_taste30_judged.jsonl"


def _bar_entries(bars_text: list[str]) -> list[dict]:
    out = []
    for i, text in enumerate(bars_text):
        end = ""
        import re
        words = re.findall(r"[A-Za-z']+", text)
        if words:
            end = words[-1].lower()
        out.append({
            "index": i, "text": text, "halves": [],
            "syllables": 0, "end_word": end, "rhyme_letter": "",
            "internal": [], "meaning": "", "checks": {},
        })
    return out


def _split_bars(raw: str) -> list[str]:
    import re
    bars = []
    for line in (raw or "").splitlines():
        s = line.strip()
        if not s:
            continue
        s = re.sub(r"^\d+\.\s*", "", s)
        s = s.strip().strip('"').strip("'").strip()
        if s:
            bars.append(s)
    return bars


def main() -> int:
    if not os.environ.get("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set. Export the key and re-run.",
              file=sys.stderr)
        print("  export OPENAI_API_KEY=sk-...", file=sys.stderr)
        return 2

    prompts = [json.loads(l) for l in TASTE30.read_text().splitlines() if l.strip()]
    print(f"loaded {len(prompts)} prompts from taste30")

    from frontier_v5 import generate_v5, generate_judged

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    blind = []
    labels = {}
    rng = random.Random(20261029)
    log_a = LOG_A.open("w"); log_b = LOG_B.open("w")

    for i, p in enumerate(prompts, 1):
        print(f"[{i}/{len(prompts)}] {p['artist']} | {p['topic']}", flush=True)
        shape = {"bpm": p.get("bpm", 140), "bars": p.get("bars", 8),
                 "section_mode": p.get("section", "verse"),
                 "seed_line": p.get("seed_line", "")}

        # Path A — baseline
        t0 = time.time()
        try:
            a = generate_v5(shape, voice=p["artist"],
                            topic_hint=p["topic"], use_cache=False)
        except Exception as exc:
            print(f"  baseline ERROR: {exc}")
            log_a.write(json.dumps({"prompt": p, "error": str(exc)}) + "\n")
            continue
        a_bars = _split_bars(a.get("raw_text") or "")
        a_id = a.get("generation_id") or f"base-{uuid.uuid4().hex[:8]}"
        log_a.write(json.dumps({**a, "_prompt": p,
                                "_elapsed_s": round(time.time()-t0, 2)}, default=str) + "\n")
        log_a.flush()

        # Path B — best-of-8 + judge + wordplay
        t1 = time.time()
        try:
            b = generate_judged(shape, voice=p["artist"],
                                topic_hint=p["topic"], candidates=8,
                                use_wordplay_hints=True, use_cache=False)
        except Exception as exc:
            print(f"  judge path ERROR: {exc}")
            log_b.write(json.dumps({"prompt": p, "error": str(exc)}) + "\n")
            continue
        b_bars = _split_bars(b.get("raw_text") or "")
        b_id = b.get("generation_id") or f"judge-{uuid.uuid4().hex[:8]}"
        log_b.write(json.dumps({**b, "_prompt": p,
                                "_elapsed_s": round(time.time()-t1, 2)}, default=str) + "\n")
        log_b.flush()

        if b.get("judge_rejected"):
            print(f"  judge path REJECTED: {b.get('judge_reasons')}")

        # randomize which model_key gets A vs B so rater can't tell
        key_order = ["v5_pathA", "v5_pathB"]
        rng.shuffle(key_order)
        a_key, b_key = key_order
        labels[a_id] = {"path": "baseline", "model_key": a_key}
        labels[b_id] = {"path": "judge+wordplay", "model_key": b_key,
                        "wordplay_pattern": b.get("wordplay_pattern"),
                        "judge_score": b.get("judge_score"),
                        "judge_rejected": b.get("judge_rejected", False)}

        blind.append({
            "artist": p["artist"], "topic": p["topic"],
            "topic_brief": p["topic"].replace("_", " "),
            "prompt_version": "taste30-blind-v1",
            "models": {
                a_key: {"generation_id": a_id, "model": "gpt-4o-mini",
                        "artist": p["artist"], "topic": p["topic"],
                        "passed": True, "bars": _bar_entries(a_bars)},
                b_key: {"generation_id": b_id, "model": "gpt-4o-mini",
                        "artist": p["artist"], "topic": p["topic"],
                        "passed": not b.get("judge_rejected", False),
                        "bars": _bar_entries(b_bars) if not b.get("judge_rejected", False) else []},
            },
        })

    log_a.close(); log_b.close()
    # randomize row order too
    rng.shuffle(blind)
    OUT_BLIND.write_text(json.dumps(blind, indent=2))
    OUT_LABELS.write_text(json.dumps(labels, indent=2))
    print(f"\nwrote {OUT_BLIND}  ({len(blind)} rows, blind)")
    print(f"wrote {OUT_LABELS}  (DO NOT SHOW TO SAMUEL BEFORE RATING)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
