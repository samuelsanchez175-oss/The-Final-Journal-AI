# Generator + scoring trace — where chips and novelty enter

Branch `claude/taste-judge-wordplay` on 83c31129. Vault copy path marked with COPY-RISK.

## Generation pipeline

| file:function | role | chip hook | novelty hook |
| --- | --- | --- | --- |
| [`frontier_v5.generate_judged`](tools/lyric-llm/frontier_v5.py) | best-of-N over generate_v5; score_fn ranks | **chip retrieval** by voice/topic/end-rimes, attach `planned_chips` to labels; **novelty check** runs on each candidate before judge/tie-break | **novelty-first**: reject near-dup candidates, record matched vault line in labels only |
| [`frontier_v5.generate_v5`](tools/lyric-llm/frontier_v5.py) | 7-stage pipeline + cache pre-gate | pass `chip_hints` through to plan_v5 | — |
| [`frontier_v5.plan_v5`](tools/lyric-llm/frontier_v5.py) | sample end-word menu, build plan JSON | `chip_hints` kwarg after `allowed` build (~line 432); CHIP_BANK prompt block (~line 471) alongside WORDPLAY_EXAMPLES | prompt rule: "use chips as end words / punchline subject; never copy example lines verbatim" |
| [`frontier_v5._plan_from_json`](tools/lyric-llm/frontier_v5.py) | validate plan; couplet rhyme check | optionally capture `planned_chips` from the plan JSON | — |
| [`frontier_v5._fallback_plan`](tools/lyric-llm/frontier_v5.py) | v3 motif fallback when LLM plan fails | — | — |
| [`frontier_v5.retrieve_v5`](tools/lyric-llm/frontier_v5.py) | **COPY-RISK**: pulls catalog scaffold lines by end-word | — | catalog line IS a vault line; its text goes directly to the writer |
| [`frontier_v5.edit_v5`](tools/lyric-llm/frontier_v5.py) | **COPY-RISK**: writer prompt receives scaffold catalog line as "SCAFFOLD" and must rewrite; current prompt doesn't forbid near-copy | add CHIP_BANK to writer system prompt too (rhyme + category) | writer prompt rule: "SCAFFOLD is a target not text to reuse; change the wording while keeping the rhyme + topic" |
| [`frontier_v5.verify_v5`](tools/lyric-llm/frontier_v5.py) | per-bar measure, retry editor | — | before marking verified, call novelty.check_verse; if any bar is near-dup, retry that bar once with "rewrite, don't reuse this phrasing" |
| [`frontier_v5.select_v5`](tools/lyric-llm/frontier_v5.py) | score candidates; max over gate_open | — | ranker now uses hard checks + tie-break (not the learned judge) until CV proves it |
| [`frontier_v5._hard_check_bars`](tools/lyric-llm/frontier_v5.py) | comma / couplet rhyme / originality guard | — | **add novelty.verse_novelty gate**; near-dup bar → fail with reason + matched vault line |
| [`catalog_retriever.retrieve_matching_catalog_lines`](tools/lyric-llm/catalog_retriever.py) | **COPY-RISK**: SQLite FTS lookup on end_word + rhyme family; returns verbatim bar text with artist/song | — | ✱ **this is the primary copy entry point** |
| [`polish.allocate_bar_artists`](tools/lyric-llm/polish.py) | voice-blend bar-level artist allocation | — | — |

## Scoring pipeline

| file:function | role | chip hook | novelty hook |
| --- | --- | --- | --- |
| [`taste.features.extract`](tools/lyric-llm/taste/features.py) | 8 scalar features over bars | add `chip_used`, `chip_used_at_end`, `chip_rime_match`, `chip_category_fit` features (SOFT, tie-break only) | optional: `max_vault_overlap`, `longest_shared_run` as features for the judge |
| [`taste.judge.TasteJudge.score_verse`](tools/lyric-llm/taste/judge.py) | pairwise-logistic margin over feature vec | — | — (judge not used until CV proves it) |
| [`taste.originality.verse_originality`](tools/lyric-llm/taste/originality.py) | 5-gram FTS overlap vs catalog + normalized exact match | — | **SUPERSEDED** by novelty.py: stricter thresholds (5-gram ≥40%, Jaccard ≥0.7, shared run ≥6, exact OR normalized match), single-chip exclusion |
| [`taste.wordplay.WordplayIndex.retrieve`](tools/lyric-llm/taste/wordplay.py) | confirmed-wordplay few-shot | — | — |
| [`inner_rhyme_check.audit_bar_structure`](tools/lyric-llm/inner_rhyme_check.py) | per-bar measure (inner, commas, syllables) | — | — |

## Vault copy paths (**primary targets to break**)

1. **`catalog_retriever.retrieve_matching_catalog_lines`** → verbatim vault bar text lands in the plan's scaffold → `edit_v5` writer prompt presents it as "SCAFFOLD" with the end word to match. The LLM often just rewrites the comma or synonym-swaps a word and returns the vault line almost verbatim. **This is the root cause.**
2. **`taste.wordplay.WordplayIndex.retrieve`** → confirmed-wordplay example lines quoted in the planner prompt. Prompt already says "use as PATTERNS not quotes", but no automated check enforces it.
3. **`polish.py`** blend-weighted mixer: if secondary voice has a cached line matching the end-word, it can bleed in verbatim.

## Entry points for the two fixes

- **Chips**: `generate_judged` builds `chip_hints` from `ChipIndex.retrieve(topic, end_rime=matching_menu_rime, k=8)` → threads through `generate_v5(user_input)` → `plan_v5(wordplay_hints, chip_hints)` adds a CHIP_BANK block. Chip usage becomes a soft feature in `_hard_check_bars` tie-break (never a hard-pass requirement).
- **Novelty**: new `taste.novelty.VaultIndex` built once over `catalog_retriever`'s SQLite copy (read-only), plus a dynamic set of just-shown example lines per verse. Called from `_hard_check_bars` before best-of-8 ranking (reject + retry one bar). Matched vault line/artist/song written to the labels file only.

## Scope of the fix

Replace `_hard_check_bars` with:
1. comma floor (unchanged)
2. couplet end-rhyme (unchanged, phonetic)
3. **novelty.verse_novelty** (NEW; replaces originality)
4. chip usage → soft tie-break only (never hard pass requirement)

`generate_judged.score_fn`:
1. hard-reject on novelty / comma / rhyme failure (−∞)
2. tie-break: `(end_rhyme_hit, −syl_variance, chip_used_at_end, chip_used, −novelty_overlap)` — NOT the learned judge margin until grouped-CV says it clearly beats the old scorer.
