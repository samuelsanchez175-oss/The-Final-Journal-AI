# Step 0 — Ratings audit + rhyme_density diagnosis

**Branch:** `claude/taste-judge-wordplay`
**Date:** 2026-10-29

## Ratings corpus

Samuel's confirmed ratings live in `tools/style-profile/rater/exports/`:

| source | rows | mean score (1–10) | notes |
| --- | ---:| ---:| --- |
| `sparkler_ratings_*.json` (6 files, rater=samuel) | 188 verses | 2.83 | 158 with `verse_score`; harsh distribution |
| &nbsp;&nbsp;↳ bar votes nested in those files | 320 bars | — | votes `+1`/`-1`/null = 144/118/58; **72 bar-level rewrites** |
| `autograde_loo19.jsonl` | 19 verses | 2.11 | has `samuel_score` + `samuel_reasons`, 5 engines |

### Verse engines (sparkler)

| engine | n | mean score |
| --- | ---:| ---:|
| `gemini/gemini-3.1-flash-lite` | 65 | 2.06 |
| `catalog_block` | 50 | **4.02** |
| `frontier_v4` | 20 | 2.65 |
| `gemini/gemini-2.5-flash-lite` | 15 | 2.20 |
| `sonnet` | 2 | 7.00 (tiny n) |
| `haiku` / `opus` | 3 / 3 | 2.00 / 2.00 |

### Tag frequencies

| scope | tag | count |
| --- | --- | ---:|
| verse | `bad_rhyme` | 83 |
| verse | `no_sense` | 79 |
| verse | `off_flow` | 63 |
| verse | `cringe` | 52 |
| verse | `off_topic` | 33 |
| verse | `too_copied` | 7 |

Bar-level `reasons` key present but almost always empty — the raw signal is `vote` (+1 keeper / −1 reject) and `rewrite` text.

### LOO19 tags
`no_sense` 11, `cringe` 10, `bad_rhyme` 8, `off_flow` 7, `off_topic` 4, `too_copied` 1.

### Reference-only (not training examples per instructions)

- `docs/play-on-words/confirmed-recheck/reject-rerun-v2.jsonl` → **6832 rows** (unreviewed, excluded from training).
- `docs/play-on-words/confirmed-recheck/recheck.jsonl` → 11,794 rows.

Full JSON audit: `scratchpad/step0_audit.json`.

## rhyme_density = 0.0 diagnosis

**Not a bug on every row.** The verdict output (`tools/lyric-llm/out/path_a_vs_b_verdict.json`) shows Path A rhyme_density 0.0 on 18/20 rows and Path B 0.0 on 5/20 — Path B has realistic distribution (0 to 0.57).

Root cause: Path A verses from `frontier_v5` genuinely do not rhyme at line ends (sample row 0 ends: `bitch, nigga, shit, now, ayy, woah, out, hey`). This confirms the comma/rhyme generation bug the prior session already fixed in `tools/lyric-llm/frontier_v5.py` (strict couplet validator in `_plan_from_json`, `_repair_rhyme_pairs` fallback, planner prompt rule, comma floor at 1).

**Scorer weakness fixed anyway.** The old `rhyme_hit` compared the last 2–3 characters, which false-matched `the/me` and missed phonetic rhymes like `fire/liar`. Replaced with CMU phoneme end-rime via `lyriclib.end_rime`, with char-suffix as fallback for words outside CMU.

- Edit: `tools/lyric-llm/base_train/path_a_vs_b_verdict.py` — new `_cmu()` lazy loader, upgraded `rhyme_hit`.
- Test: `tools/lyric-llm/base_train/test_verdict_rhyme.py` (7 cases, all pass).

Note on headline impact: when every artist in the eval has a voice profile loaded (7/7 for the matched 20), the generic scorer never runs — voice profile dominates. The upgraded `rhyme_hit` matters whenever a new artist shows up without a profile, and feeds any future feature that computes end-rhyme hit rate for the taste judge.

## Next

Step 1 begins with freezing a 30-prompt eval set and training the preference model.
