# Grok ↔ Claude handoff: Sparkler Rater

Shared log between the Grok conversation that builds the rating page and the Claude Code
sessions that own the AI Sparkler pipeline. Samuel pastes Grok's HANDOFF ENTRY blocks at the
bottom of this file (newest last). Nothing else needs to be copied over.

## For Claude (read this first when Samuel says "pick up from Grok")

1. Read every entry below, newest last. The latest entry's **Status** is the truth.
2. Read `tools/style-profile/rater/index.html` (Samuel saves Grok's latest code there).
3. Check the export against the contract in `tools/style-profile/grok_rating_page_prompt.md`
   ("Export" section). Any deviation Grok lists under **Contract changes** must be handled in the
   importer, or sent back to Grok as a fix request.
4. Answer anything under **Questions for Claude** and give Samuel a reply he can paste back to Grok.
5. Pipeline side still to build (update this list as items land):
   - [ ] `import_ratings.py`: export JSON → `feedback_store.vote()` rows (bar votes + verse votes)
   - [ ] keeper / 👍 bars → few-shot examples in `phase6_generate.build_prompt`
   - [ ] 👎 reasons → "avoid" notes in the prompt
   - [ ] batch generator so there are enough verses to rate

## Fixed facts (do not change without updating both sides)

- Page lives at: `tools/style-profile/rater/index.html`
- Input: `tools/style-profile/out/model_comparison.json` (schema `phase6.v2`), one or more files
- Export schema: `sparkler.ratings.v1`, files named `sparkler_ratings_YYYY-MM-DD_HHMM.json`
- Save exports to: `tools/style-profile/rater/exports/`
- `bar_id` = `"<generation_id>:<bar_index>"` (0-based), matches `feedback_store.generation_bars.id`
- Reason codes: `no_sense`, `bad_rhyme`, `off_flow`, `off_topic`, `too_copied`, `cringe`

## Entries

<!-- Paste Grok's HANDOFF ENTRY blocks below this line, newest last. -->

### CLAUDE CHECK: mimic mode + Gunna scorer (2026-10-14, Claude)

**Grok handoff entries pasted:** none. Grok's files were found on disk and committed as-is in `a9955ee4`
(`anchor_lib.py`, `build_anchor_profile.py`, `gunna_score.py`, mimic mode in `phase6_generate.py`,
`phase6_compare_models.py`). All compile; `phase6_generate.py self-check` and `gunna_score.py self-check` pass.

**Scorer verdict (from Grok's own `out/gunna_score_report.json`):** does not work yet.
- Held-out real Gunna (4 bars) mean 34.8/100; peers 36.0; random artists 37.5.
- AUC held-out vs peers 0.47, vs random artists 0.40, vs current generator 0.74.
- Signature-vocabulary component is lower on held-out Gunna (19.3) than on peers (28.9), so it overfits
  the exact anchor songs.
- Do NOT use it to rank `--candidates` until it clears ~0.75 AUC on held-out songs.

**Samuel's ratings (verse_score is 1-10):**
- `verse.mimic.v1` with `gemini/gemini-3.1-flash-lite`: n=50, mean 2.1, median 2. Top reasons:
  bad_rhyme 28, no_sense 17, cringe 10, off_flow 10.
- `verse.mimic.v1` with `sonnet`: n=1, score 7 (highest score of any verse so far).
- Earlier `verse.v4` (all models): means 1.8-2.2.

**Claude is doing next:** mimic batches with Sonnet and Opus (`--candidates 2`, so the scorer never picks)
in `out/rater-batch-claude/{sonnet,opus}/` for Samuel to rate.

**FROM CLAUDE (paste to Grok):**
FROM CLAUDE: Your gunna_score proof is honest and correct: it does not separate held-out Gunna from peers
(AUC 0.47) or random artists (0.40). Please (1) add a second scorer that is a stdlib word + character
n-gram classifier (Naive Bayes or logistic regression with function words), trained Gunna-anchor vs other
artists with leave-one-song-out, reporting AUC on the same groups; (2) check either scorer against
Samuel's real ratings: Spearman correlation between score and `verse_score` across the rated verses in
`rater/exports/sparkler_ratings_*.json` (skip files with rater "sparkler-grader"); (3) until a scorer
reaches AUC >= 0.75 on held-out songs AND correlates positively with Samuel's scores, make `--candidates`
keep candidates in generation order instead of ranking them; (4) bad_rhyme is the top complaint in mimic
verses (28 of 50): show how mimic mode picks and checks end rhymes and propose a fix. Reply with full
files and a HANDOFF ENTRY.
