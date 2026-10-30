#!/usr/bin/env python3
"""Run three arms through taste30 and build a blind rater export.

Arms (same prompts, same seeds):
  a) current           — generate_v5 only (baseline, no best-of-N, no chips)
  b) bo8+novelty       — generate_judged with best-of-8 + novelty hard check,
                         chips OFF
  c) bo8+novelty+chips — generate_judged with best-of-8 + novelty + chips

Flags:
  --smoke       10 prompts only, no blind file write, prints per-arm stats
  --n N         override prompt count (full run: 30)
  --model NAME  override gpt-4o-mini (also honours TASTE30_MODEL env)

Full run writes:
  eval/taste30_runs_blind.json   — rater-ready, random IDs, model_keys shuffled,
                                   no `path` hints; if ANY arm has no passing
                                   draft for a prompt, that prompt is DROPPED
                                   from every arm (logged in the labels file)
  eval/taste30_runs_labels.json  — mapping id -> {arm, generation_id,
                                   wordplay_pattern, planned_chips,
                                   novelty_report, tie_break_score,
                                   judge_rejected, judge_reasons}
                                   DO NOT show before rating.

Requires OPENAI_API_KEY. Prints the "OPENAI_API_KEY not set" message and
exits with status 2 if the key is missing. Does NOT fake output.
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
import uuid
from pathlib import Path

HERE = Path(__file__).resolve().parent
LLM_ROOT = HERE.parent
sys.path.insert(0, str(LLM_ROOT))

TASTE30 = HERE / "taste30.jsonl"
OUT_BLIND = HERE / "taste30_runs_blind.json"
OUT_LABELS = HERE / "taste30_runs_labels.json"
LOG_DIR = LLM_ROOT / "out"


def _split_bars(raw: str) -> list[str]:
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


def _bar_entries(bars_text: list[str]) -> list[dict]:
    out = []
    for i, text in enumerate(bars_text):
        words = re.findall(r"[A-Za-z']+", text)
        end = words[-1].lower() if words else ""
        out.append({
            "index": i, "text": text, "halves": [],
            "syllables": 0, "end_word": end, "rhyme_letter": "",
            "internal": [], "meaning": "", "checks": {},
        })
    return out


def _random_id(rng: random.Random) -> str:
    return "".join(rng.choice("0123456789abcdef") for _ in range(16))


DEFAULT_OPENAI_MODEL = "gpt-4o-mini"


def _print_arm_summary(stats: dict[str, list[dict]]) -> None:
    print("\n=== per-arm stats ===")
    print(f"{'arm':20s}{'n':>4s}{'pass':>8s}{'ndup':>8s}"
          f"{'mean_5g':>10s}{'mean_run':>10s}{'chip_rate':>12s}")
    for arm in ("current", "bo8_novelty", "bo8_novelty_chips"):
        xs = stats.get(arm) or []
        n = len(xs)
        if n == 0:
            print(f"{arm:20s}{0:>4d}")
            continue
        pass_rate = sum(1 for x in xs if x["passed"]) / n
        bar_total = sum(x["n_bars"] for x in xs) or 1
        ndup_rate = sum(x["near_dup_bars"] for x in xs) / bar_total
        mean_5g = statistics.mean([x["mean_5g"] for x in xs if x["mean_5g"] is not None]
                                  or [0.0])
        mean_run = statistics.mean([x["mean_run"] for x in xs if x["mean_run"] is not None]
                                   or [0.0])
        chip_rate = statistics.mean([x["chip_rate"] for x in xs] or [0.0])
        print(f"{arm:20s}{n:>4d}{pass_rate:>8.2%}{ndup_rate:>8.2%}"
              f"{mean_5g:>10.3f}{mean_run:>10.2f}{chip_rate:>12.2%}")


def _verse_arm_stats(bars_list: list[str], result: dict, chip_words: list[str]) -> dict:
    nv = result.get("novelty_report") or {}
    per = nv.get("bars") or []
    overlap_vals = [b["best_match"]["fivegram_overlap"]
                    for b in per if b.get("best_match")]
    run_vals = [b["best_match"]["longest_run"] for b in per if b.get("best_match")]
    chip_set = {c.lower() for c in chip_words if c}
    chip_hits = 0
    for b in bars_list:
        bl = b.lower()
        if any(c in bl for c in chip_set):
            chip_hits += 1
    return {
        "passed": not result.get("judge_rejected", False) and bool(bars_list),
        "n_bars": len(bars_list),
        "near_dup_bars": len(nv.get("near_dup_bar_indexes") or []),
        "mean_5g": statistics.mean(overlap_vals) if overlap_vals else None,
        "mean_run": statistics.mean(run_vals) if run_vals else None,
        "chip_rate": chip_hits / max(len(bars_list), 1),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--smoke", action="store_true",
                        help="10 prompts, no blind-file write, print per-arm stats")
    parser.add_argument("--n", type=int, default=None,
                        help="override prompt count")
    parser.add_argument("--model", default=os.environ.get("TASTE30_MODEL", DEFAULT_OPENAI_MODEL),
                        help=f"OpenAI model (default: {DEFAULT_OPENAI_MODEL})")
    args = parser.parse_args()

    # frontier_v5 defaults PLAN_MODEL/EDIT_MODEL to claude-opus-4-7 which
    # dispatches to Anthropic (needs ANTHROPIC_API_KEY). This runner is
    # documented as needing OPENAI_API_KEY, so pin the models to an OpenAI
    # model BEFORE importing frontier_v5 (the module reads env at import).
    openai_model = args.model
    os.environ.setdefault("V5_PLAN_MODEL", openai_model)
    os.environ.setdefault("V5_EDIT_MODEL", openai_model)

    if not os.environ.get("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set. Export the key and re-run.", file=sys.stderr)
        print("  export OPENAI_API_KEY=sk-...", file=sys.stderr)
        return 2

    prompts = [json.loads(l) for l in TASTE30.read_text().splitlines() if l.strip()]
    limit = args.n if args.n is not None else (10 if args.smoke else len(prompts))
    prompts = prompts[:max(1, limit)]
    print(f"loaded {len(prompts)} prompts; "
          f"V5_PLAN_MODEL={os.environ['V5_PLAN_MODEL']}  "
          f"V5_EDIT_MODEL={os.environ['V5_EDIT_MODEL']}  "
          f"smoke={args.smoke}")

    from frontier_v5 import generate_v5, generate_judged

    LOG_DIR.mkdir(parents=True, exist_ok=True)
    seed = 20261030
    rng = random.Random(seed)
    arms = ["current", "bo8_novelty", "bo8_novelty_chips"]
    log_fs = {a: (LOG_DIR / f"taste30_arm_{a}.jsonl").open("w") for a in arms}

    # per-arm stats accumulator (used in --smoke summary)
    arm_stats: dict[str, list[dict]] = {a: [] for a in arms}

    # (artist, topic) -> {arm: {bars, generation_id, meta}}
    per_prompt: list[dict] = []
    skipped: list[dict] = []

    for i, p in enumerate(prompts, 1):
        print(f"[{i}/{len(prompts)}] {p['artist']} | {p['topic']}", flush=True)
        shape = {"bpm": p.get("bpm", 140), "bars": p.get("bars", 8),
                 "section_mode": p.get("section", "verse"),
                 "seed_line": p.get("seed_line", "")}

        arm_results: dict[str, dict] = {}
        drop = False
        for arm in arms:
            t0 = time.time()
            try:
                if arm == "current":
                    r = generate_v5(shape, voice=p["artist"],
                                    topic_hint=p["topic"], use_cache=False)
                    r_bars = _split_bars(r.get("raw_text") or "")
                    passed = bool(r.get("verified"))
                elif arm == "bo8_novelty":
                    r = generate_judged(shape, voice=p["artist"],
                                        topic_hint=p["topic"], candidates=8,
                                        use_wordplay_hints=True,
                                        use_chip_hints=False,
                                        use_novelty=True, use_cache=False)
                    r_bars = _split_bars(r.get("raw_text") or "")
                    passed = not r.get("judge_rejected", False)
                else:
                    r = generate_judged(shape, voice=p["artist"],
                                        topic_hint=p["topic"], candidates=8,
                                        use_wordplay_hints=True,
                                        use_chip_hints=True,
                                        use_novelty=True, use_cache=False)
                    r_bars = _split_bars(r.get("raw_text") or "")
                    passed = not r.get("judge_rejected", False)
            except Exception as exc:
                print(f"  {arm} ERROR: {exc}", flush=True)
                r = {"error": str(exc)}
                r_bars = []
                passed = False
            log_fs[arm].write(json.dumps({**r, "_prompt": p,
                                          "_elapsed_s": round(time.time()-t0, 2)},
                                         default=str) + "\n")
            log_fs[arm].flush()
            if not passed or not r_bars:
                drop = True
                print(f"  {arm}: no passing draft")
            arm_results[arm] = {"bars": r_bars, "result": r, "passed": passed}
            # record stats for this arm (chip words from result when present)
            chip_words_used = [c.get("chip", "") for c in
                               (r.get("chip_hints_shown") or []) if c.get("chip")]
            arm_stats[arm].append(_verse_arm_stats(r_bars, r, chip_words_used))
        if drop:
            skipped.append({"artist": p["artist"], "topic": p["topic"],
                            "reasons": {a: {
                                "judge_rejected": arm_results[a]["result"].get("judge_rejected"),
                                "judge_reasons": arm_results[a]["result"].get("judge_reasons"),
                                "bars_count": len(arm_results[a]["bars"]),
                            } for a in arms}})
            continue
        per_prompt.append({"prompt": p, "arms": arm_results})

    for f in log_fs.values():
        f.close()

    if args.smoke:
        _print_arm_summary(arm_stats)
        print(f"\nkept {len(per_prompt)} prompts, skipped {len(skipped)}")
        print(f"raw logs in {LOG_DIR}/taste30_arm_*.jsonl")
        print("(--smoke: blind file NOT written)")
        return 0

    # Build blind file + labels: random IDs, random model_key order, random row order
    blind: list[dict] = []
    labels: dict[str, dict] = {}
    for p_entry in per_prompt:
        p = p_entry["prompt"]
        arms_data = p_entry["arms"]
        # random model_key assignments
        model_keys = ["model_" + _random_id(rng)[:8] for _ in arms]
        rng.shuffle(model_keys)
        row = {
            "artist": p["artist"], "topic": p["topic"],
            "topic_brief": p["topic"].replace("_", " "),
            "prompt_version": "taste30-blind-v2",
            "models": {},
        }
        for arm, key in zip(arms, model_keys):
            data = arms_data[arm]
            gid = _random_id(rng)
            labels[gid] = {
                "arm": arm,
                "generation_id_internal": data["result"].get("generation_id"),
                "model_key_blind": key,
                "artist": p["artist"], "topic": p["topic"],
                "wordplay_pattern": data["result"].get("wordplay_pattern"),
                "planned_chips": data["result"].get("planned_chips"),
                "novelty_report": data["result"].get("novelty_report"),
                "tie_break_score": data["result"].get("tie_break_score"),
                "judge_rejected": data["result"].get("judge_rejected"),
                "judge_reasons": data["result"].get("judge_reasons"),
            }
            row["models"][key] = {
                "generation_id": gid,
                "model": OPENAI_MODEL,
                "artist": p["artist"], "topic": p["topic"],
                "passed": True,
                "bars": _bar_entries(data["bars"]),
            }
        blind.append(row)

    rng.shuffle(blind)
    OUT_BLIND.write_text(json.dumps(blind, indent=2))
    OUT_LABELS.write_text(json.dumps({
        "note": "DO NOT SHOW TO SAMUEL BEFORE RATING",
        "arms": arms, "seed": seed,
        "labels": labels, "skipped_prompts": skipped,
    }, indent=2))
    print(f"\nwrote {OUT_BLIND}  ({len(blind)} rows, blind)")
    print(f"wrote {OUT_LABELS}  (private)")
    print(f"skipped {len(skipped)} prompt(s) because at least one arm had no passing draft")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
