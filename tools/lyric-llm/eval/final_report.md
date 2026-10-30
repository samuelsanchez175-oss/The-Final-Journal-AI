# Taste judge + wordplay grounding — status report

**Branch:** `claude/taste-judge-wordplay` (off `grok/base-llm-voice-conditioning`)
**Date:** 2026-10-29
**Scope:** everything up to and including the rater-blind export; generation itself is blocked on `OPENAI_API_KEY`.

## What's in the branch

| commit | subject |
| --- | --- |
| `4e5d2cac` | step 0 — ratings audit + phonetic verdict scorer |
| `001f626e` | freeze taste30 eval set (30 prompts, 7 artists, 10 topics) |
| `bcaad2a4` | pairwise-logistic preference model + Spearman eval |
| `7c3a7792` | originality guard + best-of-N wrapper in frontier_v5 |
| `a6cb3ebd` | confirmed-wordplay loader + retrieval index |
| `8a163485` | wire wordplay few-shot into frontier_v5 planner |

## Files added

- `tools/lyric-llm/base_train/test_verdict_rhyme.py` — 7 tests, all pass
- `tools/lyric-llm/eval/step0_audit.{md,json}` — rated-corpus audit
- `tools/lyric-llm/eval/taste30.jsonl` — frozen 30-prompt eval set
- `tools/lyric-llm/eval/taste_judge_report.md` — training metrics
- `tools/lyric-llm/eval/run_taste30.py` — rater-blind generator (needs OPENAI_API_KEY)
- `tools/lyric-llm/taste/features.py` + `test_features.py` (6 tests)
- `tools/lyric-llm/taste/dataset.py`
- `tools/lyric-llm/taste/judge.py` + `test_judge.py` (6 tests)
- `tools/lyric-llm/taste/train.py`
- `tools/lyric-llm/taste/weights.json` — trained judge weights
- `tools/lyric-llm/taste/originality.py` + `test_originality.py` (4 tests)
- `tools/lyric-llm/taste/wordplay.py` + `test_wordplay.py` (6 tests)
- `tools/lyric-llm/taste/test_best_of_n.py` (4 tests)

Edited:
- `tools/lyric-llm/base_train/path_a_vs_b_verdict.py` — phonetic `rhyme_hit` via CMU
- `tools/lyric-llm/frontier_v5.py` — `generate_judged` wrapper, `_hard_check_bars`, wordplay-hints threading in `plan_v5`

## Step 0 — Audit

- **188** sparkler verse ratings (6 files, rater=samuel), mean verse_score **2.83/10**
- **320** bar votes nested in those, **72 bar-level rewrites**, 144 keeper / 118 reject votes
- **19** autograde LOO19 rows (`samuel_score` + `samuel_reasons`)
- Verse tags: `bad_rhyme` 83, `no_sense` 79, `off_flow` 63, `cringe` 52, `off_topic` 33, `too_copied` 7
- Per-engine mean score: `catalog_block` 4.02 (n=50) · `frontier_v4` 2.65 (n=20) · gemini variants ~2.0 · sonnet n=2 7.00
- `reject-rerun-v2.jsonl` → 6832 rows (NOT loaded as examples, per instructions)

**`rhyme_density = 0`** diagnosis — scorer was correct (crude but accurate). Path A rows genuinely had no end rhymes. Still upgraded to phonetic end-rime via `lyriclib.end_rime` with char-suffix fallback; test suite added. The generator-side comma/rhyme fix already landed in `frontier_v5.py` (prior session) is what addresses the no-rhyme bug.

## Step 1 — Taste judge

| scorer | Spearman vs Samuel (held-out 20 verses) |
| --- | ---:|
| new taste judge (pairwise logistic over 8 features) | **+0.223** |
| old char-suffix generic composite | −0.205 |

Held-out pair-accuracy: **0.690** on 482 within-batch training pairs + 68 bar-rewrite pairs.

Features: `end_rhyme_hit_rate`, `multisyllable_rhyme`, `inner_rhyme_mean`, `syl_mean`, `syl_variance`, `commas_per_bar`, `profanity_rate`, `name_leak`. No embeddings yet (kept pure-python; can bolt on later as extra columns).

**Originality:** 5-gram phrase overlap + normalized exact-line match against `tools/bar-hits-catalog/BarHitsCatalog.sqlite` (opened read-only). Hard-rejects any verse with exact catalog line, bar ≥60% n-gram overlap, or verse mean overlap ≥35%.

**Best-of-8:** `generate_judged(voice, candidates=8)` builds 8 drafts via `generate_v5(candidates=8)`, injects a score_fn that returns the judge margin or −∞ on any hard-check failure (comma floor, phonetic couplet rhyme, originality), then post-checks the winner and sets `verified=False` + `judge_rejected=True` if no draft passed.

## Step 2 — Wordplay grounding

- **1386 Samuel-confirmed entries** loaded, across 66 artists and 506 unique end-rimes
- Tabs: sound_flips 1144 · hidden_references 133 · double_meanings 64 · split_names 39 · punchline_setups 1
- Sources: index.jsonl 1274 · index-v2.jsonl 107 · recheck.jsonl (by samuel only) 5
- Per-tab rules apply as specified:
  - sound_flip: heard_as filled, ≥2 chars, ≠ setup
  - double_meaning: play field evidences two senses OR setup_spans + play_spans + heard, OR heard_as names a specific alt word (not a meta-label like "dual meaning")
  - hidden_references (acronyms): play / heard / reason non-empty
  - split_names (brand flips): play or heard content
  - punchline_setups: play non-empty

`WordplayIndex.retrieve(artist, end_word, tabs, k)` prefers (same artist + same end-rime) → (same end-rime) → (same tab + artist) → (same tab) → (same artist).

`plan_v5` now accepts `wordplay_hints` and injects a `WORDPLAY_EXAMPLES` block in the planner prompt. `generate_judged` auto-attaches `wordplay_pattern` (the ONE chosen flip) to the result so the rater can show it next to the verse.

## Step 3 — Proof — **BLOCKED on OPENAI_API_KEY**

`tools/lyric-llm/eval/run_taste30.py` is ready to generate both paths and write a blind-labeled rater export:

```
export OPENAI_API_KEY=sk-...
tools/lyric-llm/.venv/bin/python3 tools/lyric-llm/eval/run_taste30.py
```

Produces:
- `tools/lyric-llm/eval/taste30_runs_blind.json` — sparkler-compatible, model_keys randomized per prompt and row order shuffled; Samuel rates without seeing labels
- `tools/lyric-llm/eval/taste30_runs_labels.json` — mapping of each `generation_id` back to `baseline` / `judge+wordplay`, plus the wordplay pattern used

Without the key the runner exits with status 2 and the message `OPENAI_API_KEY not set.` — no fake outputs.

### What the full write-up (judge vs baseline on taste30, pass rates, too_copied rate, 3 best / 3 worst with reasons, what's still weak) requires

Running the two paths through the 30 prompts (60 verses), then rating or scoring them. After the user supplies a key and runs the generator:
1. Record `judge_rejected` rate (how often best-of-8 produced nothing)
2. Count `too_copied` flags on the baseline (expected > 0 given Path B LoRA dup rate in prior eval)
3. Judge-score mean per path on the surviving verses
4. If Samuel rates them: Spearman on the rated 60 vs the judge's rank
5. Pick 3 best / 3 worst by Samuel's score and attach wordplay_pattern for each

## Tests

```
tools/lyric-llm/.venv/bin/python3 -m unittest \
  tools.lyric-llm.base_train.test_verdict_rhyme \
  tools.lyric-llm.taste.test_features \
  tools.lyric-llm.taste.test_judge \
  tools.lyric-llm.taste.test_originality \
  tools.lyric-llm.taste.test_wordplay \
  tools.lyric-llm.taste.test_best_of_n
```

All 33 new tests pass. Pre-existing `frontier_v5` suite: 14/14 pass.

## Hard rules — compliance

- Did NOT edit `tools/bar-hits-catalog/BarHitsCatalog.sqlite` (opened read-only via `?mode=ro` URI).
- Did NOT edit Swift (no changes under `XJournal AI/` or `PennWork Studios.xcodeproj/`).
- Did NOT promote chips into the noun bank.
- Did NOT use `docs/play-on-words/confirmed-recheck/reject-rerun-v2.jsonl` as training examples (count-only: 6832 rows reported).
- Did NOT paste API keys into chat or logs; the runner reads `OPENAI_API_KEY` from the environment and exits cleanly if unset.
- Committed in small steps with clear messages.
