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
    from frontier_v5 import strip_bar_labels

    return strip_bar_labels(raw)


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


GATE_CODES = (
    "scaffold",
    "bank",
    "end_word",
    "vault_end",
    "rhyme_family",
    "commas",
    "syllables",
    "inner_rhyme",
    "name_guard",
    "punch",
    "cliche",
    "incomplete",
)


def _gate_hits(result: dict) -> dict[str, int]:
    """Bars failing each verify code. A bar can fail more than one gate."""
    counts: dict[str, int] = {}
    for row in result.get("violations") or []:
        if not isinstance(row, dict):
            continue
        for code in row.get("codes") or []:
            name = str(code)
            counts[name] = counts.get(name, 0) + 1
    return counts


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
    rows = [row for xs in stats.values() for row in xs]
    prompt_tokens = sum(int(row.get("prompt_tokens") or 0) for row in rows)
    completion_tokens = sum(int(row.get("completion_tokens") or 0) for row in rows)
    thinking_tokens = sum(int(row.get("thinking_tokens") or 0) for row in rows)
    cost_usd = sum(float(row.get("cost_usd") or 0.0) for row in rows)
    print(
        f"prompt_tokens={prompt_tokens} completion_tokens={completion_tokens} "
        f"thinking_tokens={thinking_tokens} cost_usd={cost_usd:.4f}"
    )
    arms = ("current", "bo8_novelty", "bo8_novelty_chips")
    seen = []
    for arm in arms:
        for row in stats.get(arm) or []:
            for code in (row.get("gates") or {}):
                if code not in seen:
                    seen.append(code)
    ordered = list(GATE_CODES) + [code for code in seen if code not in GATE_CODES]
    print("\n=== per-gate failures (bars) ===")
    print(f"{'gate':16s}" + "".join(f"{arm:>22s}" for arm in arms))
    for code in ordered:
        cells = []
        for arm in arms:
            total = sum(int((row.get("gates") or {}).get(code) or 0) for row in (stats.get(arm) or []))
            cells.append(f"{total:>22d}")
        print(f"{code:16s}" + "".join(cells))
    print("\n=== repeated end word (4-bar blocks) ===")
    for arm in arms:
        xs = stats.get(arm) or []
        reps = sum(int(row.get("repeat_blocks") or 0) for row in xs)
        blocks = sum(int(row.get("end_blocks") or 0) for row in xs)
        rate = (reps / blocks) if blocks else 0.0
        print(f"{arm:20s}{reps:>4d}/{blocks:<4d}{rate:>8.2%}")
    print("\n=== plan fallbacks ===")
    for arm in arms:
        xs = stats.get(arm) or []
        n = sum(1 for row in xs if row.get("planner_model") == "heuristic_fallback")
        print(f"plan fallback {arm} {n}/{len(xs)}")
    print("\n=== end words per verse ===")
    for arm in arms:
        for index, row in enumerate(stats.get(arm) or [], 1):
            ends = " ".join(row.get("end_words") or [])
            artist = row.get("artist") or ""
            topic = row.get("topic") or ""
            print(f"{arm} {index:>2d} {artist} | {topic} | {ends}")
    print("\n=== rhyme family reuse ===")
    from frontier_v5 import run_rhyme_family_report

    family_rows = run_rhyme_family_report()
    reused = [row for row in family_rows if int(row["count"]) > 1]
    print(f"families {len(family_rows)}  reused {len(reused)}")
    if reused:
        for row in reused:
            print(f"{int(row['count']):>3d}  {row['label']}")
    else:
        print("no family used more than once")
    print(f"families used once: {len(family_rows) - len(reused)}")


def _verse_arm_stats(bars_list: list[str], result: dict, chip_words: list[str]) -> dict:
    from frontier_v5 import _word, chip_matches_bar, repeated_end_block_counts

    nv = result.get("novelty_report") or {}
    repeat_blocks, end_blocks = repeated_end_block_counts(bars_list)
    per = nv.get("bars") or []
    overlap_vals = [b["best_match"]["fivegram_overlap"]
                    for b in per if b.get("best_match")]
    run_vals = [b["best_match"]["longest_run"] for b in per if b.get("best_match")]
    chip_hits = 0
    for bar in bars_list:
        if any(chip_matches_bar(chip, bar) for chip in chip_words if chip):
            chip_hits += 1
    return {
        "passed": bool(result.get("verified")) and bool(bars_list),
        "n_bars": len(bars_list),
        "near_dup_bars": len(nv.get("near_dup_bar_indexes") or []),
        "mean_5g": statistics.mean(overlap_vals) if overlap_vals else None,
        "mean_run": statistics.mean(run_vals) if run_vals else None,
        "chip_rate": chip_hits / max(len(bars_list), 1),
        "prompt_tokens": int(result.get("prompt_tokens") or 0),
        "completion_tokens": int(result.get("completion_tokens") or 0),
        "thinking_tokens": int(result.get("thinking_tokens") or 0),
        "cost_usd": float(result.get("cost_usd") or 0.0),
        "gates": _gate_hits(result),
        "repeat_blocks": repeat_blocks,
        "end_blocks": end_blocks,
        "end_words": [_word(bar) for bar in bars_list],
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

    from frontier_v5 import (
        enable_run_rhyme_once,
        generate_judged,
        generate_v5,
        reset_run_rhyme_families,
    )
    from taste.chips import ChipIndex, slang_chip_names

    chip_index = ChipIndex.load()
    dropped_chips = slang_chip_names(chip_index.rows)
    print("chip filter dropped: " + (", ".join(dropped_chips) if dropped_chips else "(none)"))
    mercedes = next(
        (
            row for row in chip_index.rows
            if (row.get("chip") or "") == "Mercedes" and (row.get("category") or "") == "cars"
        ),
        None,
    )
    if mercedes is not None:
        print(f"chip reload: Mercedes cars syllables={mercedes.get('syllables')}")
    # One exact end-rime family per run, across every arm. Tests leave this off.
    enable_run_rhyme_once(True)
    reset_run_rhyme_families()

    # Syllables and inner rhyme are a score penalty on --smoke only.
    # End rhyme, novelty, and name guard stay hard fails.
    # A missing comma never fails. Greeting-card ends fail as vault_end.
    soft_codes = {"syllables", "inner_rhyme"} if args.smoke else None

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
                                    topic_hint=p["topic"], use_cache=False,
                                    soft_codes=soft_codes)
                    r_bars = _split_bars(r.get("raw_text") or "")
                    passed = bool(r.get("verified"))
                elif arm == "bo8_novelty":
                    r = generate_judged(shape, voice=p["artist"],
                                        topic_hint=p["topic"], candidates=8,
                                        use_wordplay_hints=True,
                                        use_chip_hints=False,
                                        use_novelty=True, use_cache=False,
                                        soft_codes=soft_codes)
                    r_bars = _split_bars(r.get("raw_text") or "")
                    passed = not r.get("judge_rejected", False)
                else:
                    r = generate_judged(shape, voice=p["artist"],
                                        topic_hint=p["topic"], candidates=8,
                                        use_wordplay_hints=True,
                                        use_chip_hints=True,
                                        use_novelty=True, use_cache=False,
                                        soft_codes=soft_codes)
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
            stats_row = _verse_arm_stats(r_bars, r, chip_words_used)
            plan_blob = r.get("plan") if isinstance(r, dict) else None
            stats_row["planner_model"] = str((plan_blob or {}).get("planner_model") or "")
            stats_row["artist"] = p["artist"]
            stats_row["topic"] = p["topic"]
            arm_stats[arm].append(stats_row)
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
