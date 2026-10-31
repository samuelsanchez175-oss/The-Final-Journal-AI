#!/usr/bin/env python3
"""Offline 3-arm evaluation over existing V4/V5/V6 outputs on disk.

Simulates what each arm's hard check would say about already-generated
verses — no API calls, no new generation.

Arms (same bars, different gates):
  a) current           — comma + couplet-rhyme only (pre-fix behaviour)
  b) bo8+novelty       — comma + rhyme + novelty (chip_words=[], no scaffold ignore)
  c) bo8+novelty+chips — same, but with per-prompt chip_words injected via
                         ChipIndex.retrieve(topic) so a bar sharing a chip
                         token doesn't trip the longest-shared-run check

For each (file, model_key, arm):
  n_verses, n_bars, pass_rate (verse-level), near_dup_rate (bar-level),
  mean_5gram_overlap ± sd, mean_longest_shared_run ± sd,
  chip_usage_rate (bars containing a chip token).

Writes eval/arm_simulator_report.{md,json}.
"""
from __future__ import annotations

import json
import re
import statistics
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
LLM_ROOT = HERE.parent
REPO = LLM_ROOT.parent.parent
sys.path.insert(0, str(LLM_ROOT))

from frontier_v5 import _hard_check_bars, _couplets_rhyme, _word, _cmu  # noqa: E402
from taste.novelty import verse_novelty, _tokens  # noqa: E402
from taste.chips import ChipIndex  # noqa: E402

STYLE_OUT = REPO / "tools" / "style-profile" / "out"
TARGETS = [
    "model_comparison_v4_20verses.json",
    "model_comparison_v4_50verses.json",
    "model_comparison_v4_blocks50.json",
    "model_comparison_v4_phase6_final.json",
    "model_comparison_pathA_matched.json",
    "model_comparison_pathB_lora_v3.json",
    "model_comparison_grok_expert.json",
    "model_comparison_grok_hand.json",
]


def _bars_from_entry(entry: dict) -> dict[str, tuple[str, str, list[str]]]:
    """Return {model_key: (artist, topic, [bar_text])}."""
    out: dict[str, tuple[str, str, list[str]]] = {}
    artist = (entry.get("artist") or "").strip()
    topic = (entry.get("topic") or "").strip()
    for key, model in (entry.get("models") or {}).items():
        bars = model.get("bars") or []
        texts = []
        for b in bars:
            text = (b.get("text") if isinstance(b, dict) else str(b)) or ""
            if text.strip():
                texts.append(text.strip())
        if texts:
            out[key] = (artist, topic, texts)
    return out


def _arm_check(bars: list[str], chip_words: list[str] | None, novelty_on: bool) -> dict:
    """Thin wrapper around _hard_check_bars without the comma rule in arm (a),
    because the pre-fix output often omits commas. Arm (a) only checks the
    couplet rhyme so we see what the ORIGINAL pipeline produced."""
    reasons: list[str] = []
    novelty = None
    # couplet rhyme (always)
    try:
        ends = tuple(_word(b.rstrip(".,!?;:").split()[-1]) if b.strip() else "" for b in bars)
        if not _couplets_rhyme(ends, _cmu()):
            reasons.append("rhyme")
    except Exception as exc:
        reasons.append(f"rhyme_err:{exc}")
    if novelty_on:
        novelty = verse_novelty(bars, chip_words=chip_words or [], shown_examples=[])
        if novelty.get("is_near_dup"):
            reasons.append("novelty")
    return {"ok": not reasons, "reasons": reasons, "novelty": novelty}


def _chip_usage(bars: list[str], chip_set: set[str]) -> float:
    if not bars or not chip_set:
        return 0.0
    hits = 0
    for b in bars:
        text = b.lower()
        for ch in chip_set:
            if ch and ch in text:
                hits += 1
                break
    return hits / len(bars)


def main() -> int:
    chips_idx = ChipIndex.load()
    print(f"loaded ChipIndex: {len(chips_idx)} chips")

    rows: list[dict] = []
    for name in TARGETS:
        p = STYLE_OUT / name
        if not p.exists():
            continue
        data = json.loads(p.read_text())
        entries = data if isinstance(data, list) else data.get("ratings") or []
        per_model_arms: dict[str, dict] = {}
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            by_model = _bars_from_entry(entry)
            topic = (entry.get("topic") or "").lower()
            chip_rows = chips_idx.retrieve(topic=topic, k=20) if topic else []
            chip_words = [c.get("chip", "") for c in chip_rows if c.get("chip")]
            chip_set = {ch.lower() for ch in chip_words}
            for model_key, (artist, _topic, bars) in by_model.items():
                for arm_label, novelty_on, chip_aware in [
                    ("a_current",            False, False),
                    ("b_novelty",            True,  False),
                    ("c_novelty_chips",      True,  True),
                ]:
                    chip_arg = chip_words if chip_aware else []
                    r = _arm_check(bars, chip_arg, novelty_on)
                    bar_count = len(bars)
                    nv = r.get("novelty") or {}
                    near_bars = len(nv.get("near_dup_bar_indexes") or [])
                    overlap_vals = [b["best_match"]["fivegram_overlap"]
                                    for b in (nv.get("bars") or [])
                                    if b.get("best_match")]
                    run_vals = [b["best_match"]["longest_run"]
                                for b in (nv.get("bars") or [])
                                if b.get("best_match")]
                    chip_rate = _chip_usage(bars, chip_set)
                    bucket = per_model_arms.setdefault((model_key, arm_label), {
                        "file": name, "model_key": model_key, "arm": arm_label,
                        "n_verses": 0, "n_bars": 0, "pass": 0, "near_bar": 0,
                        "ov": [], "run": [], "chip_rate": [],
                    })
                    bucket["n_verses"] += 1
                    bucket["n_bars"] += bar_count
                    bucket["pass"] += int(r["ok"])
                    bucket["near_bar"] += near_bars
                    bucket["ov"].extend(overlap_vals)
                    bucket["run"].extend(run_vals)
                    bucket["chip_rate"].append(chip_rate)
        for (model_key, arm_label), bucket in per_model_arms.items():
            def _m(xs):
                return (round(statistics.mean(xs), 4) if xs else 0.0,
                        round(statistics.pstdev(xs), 4) if len(xs) > 1 else 0.0)
            m_ov, s_ov = _m(bucket["ov"])
            m_run, s_run = _m(bucket["run"])
            m_cr, s_cr = _m(bucket["chip_rate"])
            rows.append({
                **{k: bucket[k] for k in ("file", "model_key", "arm", "n_verses", "n_bars")},
                "pass_rate": round(bucket["pass"] / max(bucket["n_verses"], 1), 4),
                "near_dup_bar_rate": round(bucket["near_bar"] / max(bucket["n_bars"], 1), 4),
                "mean_5gram_overlap": m_ov, "sd_5gram_overlap": s_ov,
                "mean_longest_run": m_run, "sd_longest_run": s_run,
                "mean_chip_usage": m_cr, "sd_chip_usage": s_cr,
            })

    # pretty print
    print(f"\n{'file':38s}{'model_key':24s}{'arm':20s}"
          f"{'n_v':5s}{'n_b':5s}{'pass':7s}{'ndup':7s}{'5g':14s}{'run':11s}{'chip':10s}")
    for r in rows:
        print(f"{r['file'][:36]:38s}{r['model_key'][:22]:24s}{r['arm']:20s}"
              f"{r['n_verses']:5d}{r['n_bars']:5d}"
              f"{r['pass_rate']:>6.2%} {r['near_dup_bar_rate']:>6.2%} "
              f"{r['mean_5gram_overlap']:>5.3f}±{r['sd_5gram_overlap']:>5.3f} "
              f"{r['mean_longest_run']:>4.1f}±{r['sd_longest_run']:>4.1f} "
              f"{r['mean_chip_usage']:>6.2%}")

    out_json = HERE / "arm_simulator_report.json"
    out_json.write_text(json.dumps(rows, indent=2))
    print(f"\nwrote {out_json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
