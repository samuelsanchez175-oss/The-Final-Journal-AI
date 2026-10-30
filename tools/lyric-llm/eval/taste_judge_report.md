# Taste judge — training report

**Branch:** `claude/taste-judge-wordplay`
**Rated verses:** 96 (train 76 / held-out 20)
**Within-batch training pairs:** 482
**Bar-rewrite pairs:** 68

## Spearman correlation vs Samuel's real verse_score

| scorer | train rho | held-out rho |
| --- | ---:| ---:|
| new taste judge (pairwise logistic over 8 features) | 0.282 | **0.223** |
| old char-suffix generic composite | — | -0.205 |

**Held-out pair-accuracy:** 0.690  (42 pairs)

## Learned weights (normalized)

| feature | weight |
| --- | ---:|
| `end_rhyme_hit_rate` | -0.003 |
| `multisyllable_rhyme` | +0.002 |
| `inner_rhyme_mean` | -0.025 |
| `syl_variance` | +0.011 |
| `syl_mean` | -0.012 |
| `commas_per_bar` | -0.008 |
| `profanity_rate` | +0.009 |
| `name_leak` | -0.012 |
| bias | +9.274 |

Weights are over standardized features; sign shows direction, magnitude shows strength.

## Notes

- Training uses pairs where (a) same-batch verses with different scores (higher beats
  lower) and (b) bar-level `rewrite` beats bar `text` from Samuel's rewrites.
- Features: end-rhyme hit rate, multisyllable rhyme share, inner-rhyme mean,
  syllable mean/stdev, commas-per-bar, profanity rate, celebrity name leak count.
- No embeddings yet (keeps the model pure-python, no dependency wall);
  embeddings can bolt on later as additional feature columns.
- Weights: `tools/lyric-llm/taste/weights.json`
