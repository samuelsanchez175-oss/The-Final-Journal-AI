#!/usr/bin/env python3
"""V7 smoke runner — same prompt shape as `run_taste30.py --smoke`, calls
`frontier_v7.generate_v7` instead of V5.

Does NOT touch run_taste30.py (per instructions). Does NOT fake output.
Aborts status 2 if OPENAI_API_KEY is unset.

Flags:
  --smoke       10 prompts, no blind file, per-arm stats printed
  --n N         override prompt count
  --model NAME  OpenAI model (also honours TASTE30_MODEL env, default gpt-4o-mini)
"""
from __future__ import annotations

import argparse
import json
import os
import random
import re
import statistics
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
LLM = HERE.parent
sys.path.insert(0, str(LLM))

TASTE30 = HERE / "taste30.jsonl"
LOG_DIR = LLM / "out"


def _summary(stats: list[dict]) -> None:
    print()
    print(f"{'arm':20s}{'n':>4s}{'pass':>8s}{'score':>10s}"
          f"{'novelty_rej':>14s}{'chip_rate':>12s}{'pov':>8s}")
    for arm, xs in stats:
        n = len(xs)
        if n == 0:
            print(f"{arm:20s}{0:>4d}")
            continue
        pass_rate = sum(1 for x in xs if x["verified"]) / n
        score = statistics.mean([x["score"] for x in xs])
        nvj = sum(1 for x in xs if x["novelty_rejected"]) / n
        chip = statistics.mean([x["chip_hits"] for x in xs]) / 8
        pov = statistics.mean([x["pov_rate"] for x in xs])
        print(f"{arm:20s}{n:>4d}{pass_rate:>8.2%}{score:>10.3f}"
              f"{nvj:>14.2%}{chip:>12.2%}{pov:>8.2%}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--smoke", action="store_true")
    parser.add_argument("--n", type=int, default=None)
    parser.add_argument("--model", default=os.environ.get("TASTE30_MODEL", "gpt-4o-mini"))
    args = parser.parse_args()

    os.environ.setdefault("V5_PLAN_MODEL", args.model)
    os.environ.setdefault("V5_EDIT_MODEL", args.model)

    if not os.environ.get("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set. Export the key and re-run.",
              file=sys.stderr)
        return 2

    prompts = [json.loads(l) for l in TASTE30.read_text().splitlines() if l.strip()]
    limit = args.n if args.n is not None else (10 if args.smoke else len(prompts))
    prompts = prompts[: max(1, limit)]
    print(f"loaded {len(prompts)} prompts; model={args.model}  smoke={args.smoke}")

    from frontier_v7 import generate_v7, _cmu_rime, _word
    try:
        from taste.chips import ChipIndex  # same source V5/V6 use
        _chip_index = ChipIndex.load()
    except Exception as exc:
        print(f"  warning: ChipIndex load failed ({exc}); chips disabled", file=sys.stderr)
        _chip_index = None

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log_v7 = (LOG_DIR / "taste30_v7_smoke.jsonl").open("w")
    arm_rows: list[dict] = []
    # Shared across the whole smoke batch so a rhyme family can't be used
    # by more than one prompt. plan_v7 adds the rime to this set per plan.
    used_families: set[tuple] = set()
    family_pick_log: list[list[tuple]] = []  # per-prompt list of rimes
    for i, p in enumerate(prompts, 1):
        print(f"[{i}/{len(prompts)}] {p['artist']} | {p['topic']}", flush=True)
        shape = {"bpm": p.get("bpm", 140), "bars": p.get("bars", 8),
                 "section_mode": p.get("section", "verse"),
                 "seed_line": p.get("seed_line", "")}
        # chip retrieval the way V6 does it: topic → ChipIndex, k=10.
        chip_hints = []
        if _chip_index is not None and len(_chip_index) > 0:
            try:
                chip_hints = _chip_index.retrieve(topic=p["topic"], k=10) or []
            except Exception as exc:
                print(f"  chip retrieval failed: {exc}", flush=True)
        t0 = time.time()
        try:
            r = generate_v7(prompt=shape, voice=p["artist"], topic=p["topic"],
                            candidates=1, retries_per_bar=1,
                            used_families=used_families,
                            chip_hints=chip_hints)
        except Exception as exc:
            print(f"  V7 ERROR: {exc}", flush=True)
            log_v7.write(json.dumps({"prompt": p, "error": str(exc)}) + "\n")
            continue
        # record which rhyme families this prompt landed on
        prompt_rimes = []
        for ew in r.plan.get("end_words", []):
            rime = _cmu_rime(_word(ew.split()[-1]))
            if rime:
                prompt_rimes.append(tuple(rime))
        family_pick_log.append(sorted(set(prompt_rimes)))
        novelty_rej = any("novelty" in v for v in r.violations_rolled_up)
        row = {
            "artist": p["artist"], "topic": p["topic"],
            "bars": r.bars,
            "verified": r.verified,
            "score": r.verse_score,
            "pov_rate": r.verse_components.get("pov_rate", 0.0),
            "chip_hits": r.verse_components.get("chip_hits_total", 0),
            "subtopics": r.verse_components.get("subtopics_hit", []),
            "novelty_rejected": novelty_rej,
            "violations": r.violations_rolled_up,
            "blocked_targets": r.blocked_targets,
            "elapsed_s": round(time.time() - t0, 2),
        }
        arm_rows.append(row)
        log_v7.write(json.dumps({**row, "generation_id": r.generation_id,
                                 "plan": r.plan}) + "\n")
        log_v7.flush()
    log_v7.close()

    if args.smoke:
        _summary([("v7_bo1_grader", arm_rows)])
        # family reuse report
        from collections import Counter
        all_rimes = [r for prompt in family_pick_log for r in prompt]
        counts = Counter(all_rimes)
        reused = [(r, n) for r, n in counts.items() if n > 1]
        print()
        print(f"=== rhyme family reuse across {len(prompts)} prompts ===")
        print(f"total distinct families used: {len(counts)}")
        print(f"families reused: {len(reused)}  (ideal = 0 under the cap)")
        if reused:
            print("reused families (rime → prompts):")
            for rime, n in sorted(reused, key=lambda x: -x[1])[:10]:
                label = "-".join(rime) if rime else "(empty)"
                print(f"  {label:30s} seen in {n} prompts")
        else:
            print("(none)")
        print(f"\nraw log: {LOG_DIR / 'taste30_v7_smoke.jsonl'}")
        print("(--smoke: no blind file written; app not notified)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
