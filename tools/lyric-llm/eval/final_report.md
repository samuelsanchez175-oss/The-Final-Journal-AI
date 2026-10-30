# Taste judge + chip bank + novelty guard — status report

**Branch:** `claude/taste-judge-wordplay` (rebased onto `83c31129`)
**Date:** 2026-10-30

## Design, in one page

| problem | fix |
| --- | --- |
| V4/V5 verses copy vault lyrics word-for-word (new finding below) | `taste/novelty.py` + `_hard_check_bars` novelty gate (reject bars with exact OR shared-run ≥6 OR 5-gram ≥0.40 OR Jaccard ≥0.70, chip words excluded from shared-run) |
| Generator ignores Samuel's chip bank | `taste/chips_export.py` dumps all 5560 chips (55 categories) to `eval/chips.jsonl`; `taste/chips.py` indexes by rime+topic+freq; `plan_v5` emits a CHIP_BANK block; `generate_judged` pre-samples the menu, pulls chips by rime, records `planned_chips` to labels |
| Learned taste judge isn't proven | Grouped-5-fold CV × 10 seeds + permutation p-value in `taste/cv.py`; result ships the judge **OFF** by default; ranker uses a deterministic tie-break instead |
| Antigravity-authored "KEEP" wordplay rows were polluting the few-shot | `WordplayIndex` only loads `by: samuel`-authored rows; 3201 antigravity KEEPs exported to `eval/review_antigravity_keeps/<tab>_batch_NNN.jsonl` (50 per file) for Y/N |
| Blind rater file leaked path identity via base-/judge- id prefixes | `eval/run_taste30.py` v2 uses random 16-hex IDs + random model_key hashes per prompt + shuffled row order; drops any prompt where ≥1 arm has no passing draft, logs skipped to labels only |
| Verdict scorer used crude char-suffix rhyme | `base_train/path_a_vs_b_verdict.py` now uses CMU `end_rime` (lyriclib) with char-suffix fallback for OOV words |

Trace of every file:function entry point for chip + novelty is in [`eval/trace_gen_scoring.md`](tools/lyric-llm/eval/trace_gen_scoring.md).

## Commits on the branch

```
$ git log main..claude/taste-judge-wordplay --oneline
<new>  feat(taste-judge): wire chips + novelty into frontier_v5, judge off by default
<new>  feat(taste-judge): dedup + grouped CV + permutation (judge stays OFF)
<new>  feat(taste-judge): wordplay confirmed = samuel-authored only; antigravity export
<new>  feat(taste-judge): trace doc + chip bank export + ChipIndex + novelty guard
<new>  chore(deps): vendor lyriclib.py — CMU + end_rime helpers
<new>  feat(taste-judge): rater-blind runner + final status report
<new>  feat(taste-judge): wire wordplay few-shot into frontier_v5 planner
<new>  feat(taste-judge): confirmed-wordplay loader + retrieval index
<new>  feat(taste-judge): originality guard + best-of-N wrapper in frontier_v5
<new>  feat(taste-judge): pairwise-logistic preference model + Spearman eval
<new>  feat(taste-judge): freeze taste30 eval set
<new>  feat(taste-judge): step 0 — ratings audit + phonetic verdict scorer
```

(Exact hashes: run `git log main..claude/taste-judge-wordplay --oneline` — included in the branch push.)

## Numbers — baseline vault-copy rate on existing V4 / V5 / V6 outputs

Measured by running `taste.novelty.bar_novelty` against `BarHitsCatalog.sqlite` (read-only) for every bar in each existing output file. Thresholds: exact-normalized OR shared-run ≥6 OR 5-gram ≥0.40 OR Jaccard ≥0.70. Chip words NOT excluded here — this is the plain baseline before the fix.

| output file | model | n bars | **exact match** | **near-dup** | mean 5-gram overlap | mean longest shared run |
| --- | --- | ---:| ---:| ---:| ---:| ---:|
| model_comparison_v4_phase6_final | frontier_v4 | 364 | **67.9%** | **100.0%** | 0.929 ± 0.213 | 10.0 ± 2.7 |
| model_comparison_v4_50verses | frontier_v4 | 360 | 27.5% | 43.9% | 0.936 ± 0.172 | 9.4 ± 2.5 |
| model_comparison_pathA_matched | v5_pathA (gpt-4o-mini + catalog) | 160 | 1.9% | **83.1%** | 0.555 ± 0.222 | 8.0 ± 1.8 |
| model_comparison_pathB_lora_v3 | Together LoRA 50k | 160 | 0.0% | 19.4% | 0.332 ± 0.146 | 6.0 ± 0.3 |
| model_comparison_v4_blocks50 | catalog_block | 200 | 0.0% | 3.0% | 0.271 ± 0.035 | 6.0 ± 0.0 |
| model_comparison_v4_20verses | frontier_v4 | 144 | 0.0% | 3.5% | 0.161 ± 0.063 | 6.6 ± 0.8 |
| model_comparison_grok_expert | v5_grok_expert | 48 | 0.0% | 2.1% | 0.286 ± 0.000 | 6.0 ± 0.0 |
| model_comparison_grok_hand | v5_grok_hand | 8 | 0.0% | 0.0% | 0.000 ± 0.000 | 0.0 ± 0.0 |

**Key finding.** `v5_pathA` (the prior "winner" using gpt-4o-mini + catalog retrieval) has an **83.1% near-duplicate rate** — the catalog scaffold is being paraphrased, not rewritten. `v4_phase6_final` is 100% near-duplicate with 68% EXACT normalized matches — the frontier_v4 engine was effectively a search-and-return system.

The LoRA (`pathB_lora_v3`) is paradoxically the most original of the paid runs at 19.4%, because the fine-tune doesn't retrieve verbatim catalog text to feed back to the writer.

Raw data: `eval/baseline_duplicate_rate.json`.

## Numbers — judge CV (dedup + grouped 5-fold × 10 seeds + permutation p)

| scorer | Spearman mean | sd (across 10 seeds) |
| --- | ---:| ---:|
| taste judge (pairwise logistic) | +0.339 | 0.125 |
| old char-suffix generic composite | −0.496 | 0.101 |

**Pooled permutation p-value (over all 50 folds):** 0.3241
**Decision:** KEEP JUDGE OFF. Dedup collapsed the corpus from 96 → **26 unique verses** (most sparkler exports were cumulative re-exports). Mean beats old scorer by a wide margin, but spread is big and p=0.32 can't reject the null. Ranker in `generate_judged` is the deterministic tie-break:
```
10 * end_rhyme_hit_rate + 3 * multisyllable_rhyme
  − 0.3 * syl_variance − 1.5 * name_leak
  + 0.4 per chip used + 0.8 per chip landing on an end word
  − 2.0 * max_5gram_overlap − 0.2 * max_longest_run
```
So copying can never win a tie. Flip the judge on with `use_judge_ranker=True` once the corpus grows.

Raw data: `eval/judge_cv_report.md`.

## Numbers — chip bank export

- **5560 chips** across **55 categories** read from
  `XJournal AI/NounBankSections.swift` via `git show grok/base-llm-voice-conditioning:…` (branch has no Swift files; nothing was written to Swift sources).
- Top categories: tattoos 38, money 37, looks 36, liquors 35, guns 35, hair 35, sports 35, religion 34, games 30.
- 99.9% chip end-rime coverage (CMU → big_phoney fallback).
- Fixed `taste30` topic → chip-category map in `eval/chips_topic_map.json`.

## Numbers — wordplay few-shot filter

- Samuel-authored rows only: **5 entries** across index.jsonl / index-v2.jsonl / recheck.jsonl.
- Antigravity KEEPs exported for Samuel's Y/N: **3201 entries** across 67 files
  (double_meanings 1859, sound_flips 1159, hidden_references 143, split_names 39, punchline_setups 1), 50 rows each. Any row Samuel saves with `by: samuel` and `verdict: KEEP` is picked up by the next `WordplayIndex.build()`.

## Novelty guard — tests

8/8 unit tests pass:
- `test_verbatim_rejected` — exact vault line → near-dup=True
- `test_light_paraphrase_caught` — vault line + 1 trailing filler → near-dup=True
- `test_new_line_passes` — a brand-new line → near-dup=False
- `test_shared_chip_alone_passes` — share only one chip noun ("Henny") → False
- `test_shown_verbatim_quoted_is_rejected` — quoting a shown example → True
- `test_verse_near_dup_indexes` — per-bar reporting

## What's still weak

1. **n is small everywhere.** 26 deduped rated verses; 5 Samuel-confirmed wordplay. Judge CV spread is wide because of this. Growing the rated corpus is the biggest leverage point.
2. **Novelty candidate recall.** The novelty check uses FTS phrase match on the bar's own 5-grams. A paraphrase that drops every 5-gram but keeps the skeleton (e.g. swap every 5th word) will slip past. User's spec notes LSH/MinHash as an alternative. The 4-gram fallback catches most short-skeleton paraphrases; if false negatives show up in review, bump to 3-gram.
3. **The actual 3-arm generation is paid and blocked.** `eval/run_taste30.py` is wired, aborts cleanly without `OPENAI_API_KEY`, and when run writes a blind rater file + a labels file with `arm`, `planned_chips`, `novelty_report`, `tie_break_score` per generation. Drop-prompt-on-either-arm-fail is implemented.
4. **Chip usage is a soft tie-break only.** Not a hard pass requirement — the model may still ignore chips. The scoring bonus is small enough that bar quality dominates, which is deliberate; but we won't see "chip hit rate" climb unless the planner picks them up.
5. **Writer prompt still shows the scaffold catalog line.** `edit_v5` presents it as a target. Novelty blocks the copy-paste outcome, but the next step is to NOT show the scaffold text at all — give the writer only the end-word, syllable budget, rhyme family, and chip + topic. That edit is in `edit_v5` prompt builder, out of scope here.
6. **CMU coverage** is still limited for slang. Chips OOV (e.g. "Henny") fall back to big_phoney, which may be noisier for 1-off brand terms.

## Hard-rules compliance

- **No Swift / xcodeproj edits.** All Swift reads use `git show grok/base-llm-voice-conditioning:…`.
- **No noun-bank chip promotion.** Chip data is read-only; exporter only writes to `eval/chips.jsonl`.
- **No writes to `BarHitsCatalog.sqlite`.** All opens use `file:…?mode=ro`.
- **No `reject-rerun-v2.jsonl` as training data.** Audited for count only (6832 rows, documented in Step 0 audit).
- **Branch rebased onto `83c31129`** (grok head integrated with main, no Swift conflicts for my feature commits).
- **`stash@{0}`** ("pre-rebase prior-session wip") not touched.
- **Paid `taste30` blind run NOT executed.** Runner aborts without the key.
