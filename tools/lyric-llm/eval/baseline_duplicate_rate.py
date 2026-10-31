#!/usr/bin/env python3
"""Measure the duplicate / near-duplicate rate in existing V4/V5/V6 outputs.

Reads tools/style-profile/out/model_comparison*.json; for each verse's bars,
runs taste.novelty.bar_novelty against BarHitsCatalog.sqlite (read-only).
Reports per-file:
  - total bars
  - exact normalized-match rate
  - near-duplicate rate (any novelty flag)
  - max 5-gram overlap mean
  - longest-shared-run mean
with n and spread (sd) so no headline deltas without them.
"""
from __future__ import annotations

import json
import statistics
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
LLM_ROOT = HERE.parent
REPO = LLM_ROOT.parent.parent
sys.path.insert(0, str(LLM_ROOT))

from taste.novelty import bar_novelty, _normalize  # noqa: E402

STYLE_OUT = REPO / "tools" / "style-profile" / "out"
TARGET_FILES = [
    "model_comparison_v4_20verses.json",
    "model_comparison_v4_50verses.json",
    "model_comparison_v4_blocks50.json",
    "model_comparison_v4_phase6_final.json",
    "model_comparison_pathA_matched.json",
    "model_comparison_pathB_lora_v3.json",
    "model_comparison_grok_expert.json",
    "model_comparison_grok_hand.json",
]


def _extract_bar_text(entry: dict) -> list[tuple[str, str, str, str]]:
    """Yield (model_key, artist, topic, bar_text) tuples from the entry."""
    artist = entry.get("artist") or ""
    topic = entry.get("topic") or ""
    out: list[tuple[str, str, str, str]] = []
    for key, model_data in (entry.get("models") or {}).items():
        bars = model_data.get("bars") or []
        for b in bars:
            text = b.get("text") if isinstance(b, dict) else str(b)
            if text and text.strip():
                out.append((key, artist, topic, text.strip()))
    return out


def main() -> int:
    report_rows: list[dict] = []
    for name in TARGET_FILES:
        path = STYLE_OUT / name
        if not path.exists():
            continue
        data = json.loads(path.read_text())
        rows = data if isinstance(data, list) else data.get("ratings", [])
        all_bars: list[tuple[str, str, str, str]] = []
        for entry in rows:
            if not isinstance(entry, dict):
                continue
            all_bars.extend(_extract_bar_text(entry))
        if not all_bars:
            continue
        by_key: dict[str, list[dict]] = {}
        for key, artist, topic, bar in all_bars:
            r = bar_novelty(bar)
            by_key.setdefault(key, []).append({
                "bar": bar, "artist": artist, "topic": topic,
                "is_near_dup": r["is_near_dup"],
                "best_match": r["best_match"],
                "reasons": r["reasons"],
            })
        for key, bars in by_key.items():
            n = len(bars)
            near = sum(1 for b in bars if b["is_near_dup"])
            exact = sum(1 for b in bars if any("exact" in r for r in b["reasons"]))
            overlap_vals = [float(b["best_match"]["fivegram_overlap"])
                            for b in bars if b.get("best_match")]
            run_vals = [int(b["best_match"]["longest_run"])
                        for b in bars if b.get("best_match")]
            def sd(xs): return statistics.pstdev(xs) if len(xs) > 1 else 0.0
            def mean(xs): return statistics.mean(xs) if xs else 0.0
            row = {
                "file": name, "model_key": key,
                "n_bars": n,
                "exact_rate": round(exact / n, 4),
                "near_dup_rate": round(near / n, 4),
                "mean_5gram_overlap": round(mean(overlap_vals), 4),
                "sd_5gram_overlap": round(sd(overlap_vals), 4),
                "mean_longest_run": round(mean(run_vals), 2),
                "sd_longest_run": round(sd(run_vals), 2),
            }
            report_rows.append(row)
            print(f"{name:50s} {key:30s} n={n:4d}  "
                  f"exact={row['exact_rate']:.3f} near={row['near_dup_rate']:.3f} "
                  f"mean_5gram={row['mean_5gram_overlap']:.3f}±{row['sd_5gram_overlap']:.3f} "
                  f"mean_run={row['mean_longest_run']:.1f}±{row['sd_longest_run']:.1f}")
    out = LLM_ROOT / "eval" / "baseline_duplicate_rate.json"
    out.write_text(json.dumps(report_rows, indent=2))
    print(f"\nwrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
