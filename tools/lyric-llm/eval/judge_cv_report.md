# Taste judge — grouped K-fold CV report

**Branch:** `claude/taste-judge-wordplay`
**Deduped rated verses:** 26
**Bar-rewrite pairs (always in train):** 23
**Grouping:** verse `generation_id` (so a verse and its bar rewrites never
split across folds).
**K=5, seeds=10, permutations/fold=200**

## Spearman (held-out), mean ± sd across seeds

| scorer | mean | sd | n_seeds |
| --- | ---:| ---:| ---:|
| **taste judge (pairwise logistic)** | **+0.339** | 0.125 | 10 |
| old char-suffix generic composite | -0.496 | 0.101 | 10 |

**Permutation p-value (pooled across folds):** 0.3241
(fraction of label-shuffle permutations with Spearman ≥ observed)

## Decision

**KEEP JUDGE OFF — tie-break ranks**

Rule: enable the judge as the best-of-N ranker only when its CV mean
clearly beats the old scorer (by more than max(sd_judge, sd_old, 0.05)),
its mean is positive (>=0.10), AND the permutation p-value is < 0.05.
Otherwise fall back to the deterministic tie-break in
`frontier_v5.generate_judged`.

## Per-fold details

| seed | fold | n_test | rho_judge | rho_old |
| ---:| ---:| ---:| ---:| ---:|
| 0 | 0 | 6 | +0.493 | -0.087 |
| 0 | 1 | 5 | +0.564 | -0.821 |
| 0 | 2 | 5 | +0.105 | +0.186 |
| 0 | 3 | 5 | +0.051 | -0.918 |
| 0 | 4 | 5 | +0.872 | -0.947 |
| 1 | 0 | 6 | +0.478 | -0.635 |
| 1 | 1 | 5 | +0.564 | -0.632 |
| 1 | 2 | 5 | +0.264 | -0.270 |
| 1 | 3 | 5 | +0.200 | -0.100 |
| 1 | 4 | 5 | -0.205 | -0.789 |
| 2 | 0 | 6 | +0.029 | -0.132 |
| 2 | 1 | 5 | +0.718 | -1.000 |
| 2 | 2 | 5 | +0.632 | -0.270 |
| 2 | 3 | 5 | -0.359 | -0.789 |
| 2 | 4 | 5 | +0.410 | -0.553 |
| 3 | 0 | 6 | +0.618 | -0.706 |
| 3 | 1 | 5 | +0.300 | -0.359 |
| 3 | 2 | 5 | +0.316 | -0.324 |
| 3 | 3 | 5 | +0.700 | -0.564 |
| 3 | 4 | 5 | -0.051 | -0.894 |

(First 20 rows shown; full detailed data available by re-running this script.)

## Weights

Final judge is trained on ALL deduped data and saved to
`tools/lyric-llm/taste/weights.json`. It is NOT used by
`frontier_v5.generate_judged` unless `use_judge_ranker=True` is passed
explicitly, i.e. the decision above is "USE JUDGE".
