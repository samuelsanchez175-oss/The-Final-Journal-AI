#!/usr/bin/env python3
"""Grouped K-fold cross-validation + permutation test for the taste judge.

For each of N seeds:
  - deterministic shuffle of verse groups
  - K-fold split (groups to folds, not individual rows / pairs)
  - For each fold: train on 4 folds (within-batch pairs + bar rewrites),
    evaluate on held-out fold (Spearman of model margin vs samuel_score,
    plus pair accuracy on within-batch pairs that live in the held-out fold)
  - Record Spearman for the taste judge AND the old char-suffix scorer

Permutation test: shuffle the held-out scores J times per fold; the p-value
is the fraction of permutations whose Spearman >= the observed one. Report
the pooled permutation p-value across folds and seeds.

Writes eval/judge_cv_report.md and prints the headline table.
"""
from __future__ import annotations

import json
import random
import re
import statistics
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
LLM_ROOT = HERE.parent
sys.path.insert(0, str(LLM_ROOT))

from taste.dataset import iter_verse_rows, iter_bar_rewrite_pairs, build_pairs, build_bar_pairs, verse_group_key  # noqa: E402
from taste.features import FEATURE_KEYS, extract, vector  # noqa: E402
from taste.judge import TasteJudge, spearman  # noqa: E402

OUT_WEIGHTS = HERE / "weights.json"
OUT_REPORT = LLM_ROOT / "eval" / "judge_cv_report.md"


def _old_generic_score(bars: list[str]) -> float:
    _VOWELS = set("aeiou")
    def syls(w):
        w = re.sub(r"[^a-z]", "", w.lower())
        if not w: return 0
        c = 0; pv = False
        for ch in w:
            v = ch in _VOWELS
            if v and not pv: c += 1
            pv = v
        if w.endswith("e") and c > 1: c -= 1
        return max(c, 1)
    def line_syls(ln): return sum(syls(w) for w in re.findall(r"[A-Za-z']+", ln))
    def ew(ln):
        w = re.findall(r"[A-Za-z']+", ln)
        return w[-1].lower() if w else ""
    def rh(a, b): return bool(a) and bool(b) and (a[-2:] == b[-2:] or a[-3:] == b[-3:])
    if not bars: return 0.0
    sl = [line_syls(b) for b in bars]
    en = [ew(b) for b in bars]
    hits = sum(1 for i in range(1, len(en)) if rh(en[i-1], en[i]))
    rhyme = hits / max(len(en) - 1, 1)
    mean = statistics.mean(sl) if sl else 0.0
    cons = 1.0 - min(1.0, (statistics.pstdev(sl) / max(mean, 1.0)))
    return 0.5 * rhyme + 0.5 * cons


def _grouped_folds(rows: list[dict], k: int, seed: int) -> list[list[int]]:
    """Return k lists of row indices; each row's group lands in exactly one fold."""
    groups: dict[str, list[int]] = {}
    for i, r in enumerate(rows):
        groups.setdefault(verse_group_key(r), []).append(i)
    group_keys = list(groups.keys())
    rng = random.Random(seed)
    rng.shuffle(group_keys)
    folds: list[list[int]] = [[] for _ in range(k)]
    for g_idx, gk in enumerate(group_keys):
        folds[g_idx % k].extend(groups[gk])
    return folds


def _permutation_pvalue(xs: list[float], ys: list[float], observed: float,
                        trials: int, seed: int) -> float:
    """One-sided p-value: fraction of permutations with rho >= observed."""
    if len(xs) < 3:
        return 1.0
    rng = random.Random(seed)
    ys_perm = list(ys)
    greater = 0
    for _ in range(trials):
        rng.shuffle(ys_perm)
        rho = spearman(xs, ys_perm)
        if rho >= observed:
            greater += 1
    return (greater + 1) / (trials + 1)


def main() -> int:
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--seeds", type=int, default=10)
    parser.add_argument("--folds", type=int, default=5)
    parser.add_argument("--perms", type=int, default=200,
                        help="Permutations per fold for the p-value")
    args = parser.parse_args()

    all_rows = list(iter_verse_rows(dedupe=True))
    print(f"deduped rated verses: {len(all_rows)}")
    rewrite_pairs = build_bar_pairs(list(iter_bar_rewrite_pairs()))
    print(f"bar-rewrite pairs (always included in training): {len(rewrite_pairs)}")

    seeds = list(range(args.seeds))
    folds = args.folds
    seed_judge_rhos: list[float] = []
    seed_old_rhos: list[float] = []
    pvalue_counts: list[tuple[int, int]] = []  # (greater, total)

    detailed_folds: list[dict] = []

    for seed in seeds:
        fold_indices = _grouped_folds(all_rows, folds, seed=seed)
        fold_judge: list[float] = []
        fold_old: list[float] = []
        for i, test_idx in enumerate(fold_indices):
            train_rows = [all_rows[j] for f_i, f in enumerate(fold_indices)
                          if f_i != i for j in f]
            test_rows = [all_rows[j] for j in test_idx]
            if len(test_rows) < 3:
                continue
            train_pairs = build_pairs(train_rows)
            judge = TasteJudge.train(train_pairs + rewrite_pairs,
                                     epochs=300, lr=0.05, l2=1e-3,
                                     seed=seed * 101 + i)
            xs_judge = [judge.score_verse(r["bars"], voice=r["artist"]) for r in test_rows]
            xs_old = [_old_generic_score(r["bars"]) for r in test_rows]
            ys = [r["score"] for r in test_rows]
            rho_j = spearman(xs_judge, ys)
            rho_o = spearman(xs_old, ys)
            fold_judge.append(rho_j)
            fold_old.append(rho_o)
            # permutation p-value
            if args.perms > 0:
                rng = random.Random(seed * 1009 + i)
                ys_perm = list(ys)
                greater = 0
                for _ in range(args.perms):
                    rng.shuffle(ys_perm)
                    if spearman(xs_judge, ys_perm) >= rho_j:
                        greater += 1
                pvalue_counts.append((greater, args.perms))
            detailed_folds.append({
                "seed": seed, "fold": i,
                "n_test": len(test_rows), "rho_judge": rho_j, "rho_old": rho_o,
            })
        if fold_judge:
            seed_judge_rhos.append(statistics.mean(fold_judge))
            seed_old_rhos.append(statistics.mean(fold_old))

    def _mean_sd(xs: list[float]) -> tuple[float, float]:
        if not xs:
            return (0.0, 0.0)
        if len(xs) == 1:
            return (xs[0], 0.0)
        return (statistics.mean(xs), statistics.stdev(xs))

    j_mean, j_sd = _mean_sd(seed_judge_rhos)
    o_mean, o_sd = _mean_sd(seed_old_rhos)
    # pooled permutation p-value
    total_g = sum(g for g, _ in pvalue_counts)
    total_t = sum(t for _, t in pvalue_counts)
    pooled_p = (total_g + 1) / (total_t + 1) if total_t else 1.0

    # Final judge trained on EVERYTHING, for serialization
    full_pairs = build_pairs(all_rows) + rewrite_pairs
    judge_full = TasteJudge.train(full_pairs, epochs=400, lr=0.05, l2=1e-3,
                                  seed=20261029)
    judge_full.save(OUT_WEIGHTS)

    decision = "USE JUDGE" if (j_mean > o_mean + max(j_sd, o_sd, 0.05) and j_mean > 0.1 and pooled_p < 0.05) else "KEEP JUDGE OFF — tie-break ranks"
    report = f"""# Taste judge — grouped K-fold CV report

**Branch:** `claude/taste-judge-wordplay`
**Deduped rated verses:** {len(all_rows)}
**Bar-rewrite pairs (always in train):** {len(rewrite_pairs)}
**Grouping:** verse `generation_id` (so a verse and its bar rewrites never
split across folds).
**K={folds}, seeds={args.seeds}, permutations/fold={args.perms}**

## Spearman (held-out), mean ± sd across seeds

| scorer | mean | sd | n_seeds |
| --- | ---:| ---:| ---:|
| **taste judge (pairwise logistic)** | **{j_mean:+.3f}** | {j_sd:.3f} | {len(seed_judge_rhos)} |
| old char-suffix generic composite | {o_mean:+.3f} | {o_sd:.3f} | {len(seed_old_rhos)} |

**Permutation p-value (pooled across folds):** {pooled_p:.4f}
(fraction of label-shuffle permutations with Spearman ≥ observed)

## Decision

**{decision}**

Rule: enable the judge as the best-of-N ranker only when its CV mean
clearly beats the old scorer (by more than max(sd_judge, sd_old, 0.05)),
its mean is positive (>=0.10), AND the permutation p-value is < 0.05.
Otherwise fall back to the deterministic tie-break in
`frontier_v5.generate_judged`.

## Per-fold details

| seed | fold | n_test | rho_judge | rho_old |
| ---:| ---:| ---:| ---:| ---:|
""" + "\n".join(
        f"| {d['seed']} | {d['fold']} | {d['n_test']} | {d['rho_judge']:+.3f} | {d['rho_old']:+.3f} |"
        for d in detailed_folds[:20]
    ) + f"""

(First 20 rows shown; full detailed data available by re-running this script.)

## Weights

Final judge is trained on ALL deduped data and saved to
`{OUT_WEIGHTS.relative_to(LLM_ROOT.parent.parent)}`. It is NOT used by
`frontier_v5.generate_judged` unless `use_judge_ranker=True` is passed
explicitly, i.e. the decision above is "USE JUDGE".
"""
    OUT_REPORT.parent.mkdir(parents=True, exist_ok=True)
    OUT_REPORT.write_text(report)
    print(f"wrote {OUT_REPORT}")
    print(f"\njudge mean ± sd (seeds):  {j_mean:+.3f} ± {j_sd:.3f}")
    print(f"old   mean ± sd (seeds):  {o_mean:+.3f} ± {o_sd:.3f}")
    print(f"pooled permutation p-value: {pooled_p:.4f}")
    print(f"DECISION: {decision}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
