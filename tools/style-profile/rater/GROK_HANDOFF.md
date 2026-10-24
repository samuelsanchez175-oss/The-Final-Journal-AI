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
   - [x] `import_ratings.py`: export JSON → `feedback_store.vote()` rows (bar votes + verse votes)
   - [x] keeper / 👍 bars → few-shot examples in `phase6_generate.build_prompt`
   - [x] 👎 reasons → "avoid" notes in the prompt
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

### HANDOFF ENTRY: Task A Completed — import_ratings.py (2026-10-24, Antigravity)

**Status:** Task A is complete and fully verified.
- **Implemented:** `tools/style-profile/import_ratings.py` supporting `--exports`, `--db`, `--since`, `--dry-run`, and positional file arguments.
- **Database Schema Upgrades:** `feedback_store.py` updated with schema migration adding `reasons` and `rater` columns, and broadening `target_kind` CHECK constraint to include `'verse'` with integer scores (1..10 or -1/+1).
- **Idempotency & Deduplication:** Dedupe key `(target_ref, rater, timestamp, vote)` verified. Re-running on existing export directories adds exactly 0 rows and reports all duplicates skipped.
- **Grader Filtering:** Synthetic files where `rater == "sparkler-grader"` (`sparkler_autograde_family_fame_street.json`) are automatically skipped.
- **Unit Tests:** `tools/style-profile/test_import_ratings.py` with 7 comprehensive tests passing cleanly in 0.049s.
- **Live Ingestion Run:** Ingested 4 real export files into `tools/style-profile/out/feedback.sqlite` (90 bar votes, 72 verse votes, 142 duplicates skipped). Subsequent re-run confirmed 0 new rows and 304 duplicates skipped. Verified `feedback_store.weight(kind="bar", ref=...)` returns 0.6 for thumbs-up and 0.4 for thumbs-down.
- **Next Task:** Task B — Wire ratings into generator prompt (`tools/style-profile/phase6_generate.py`).

### HANDOFF ENTRY: Task B Completed — Wire Ratings into Prompt (Taste Blocks) (2026-10-24, Antigravity)

**Status:** Task B is complete and fully verified.
- **Implemented:** `tools/style-profile/phase6_generate.py` updated to wire ratings and feedback reasons into prompt generation:
  - `build_taste_prompt_blocks(artist, store, k_bars, k_reasons, taste_on)`: queries `feedback_store` for highest-weighted positive bars (`weight() > 0.5`) and maps top negative reason codes to human explanations (`REASON_AVOID_TEXT`).
  - Added `WRITE LIKE THIS (keeper bars from this artist, rated by the writer):` block with top-K positive keeper bars.
  - Added `AVOID (these problems hit before):` block mapping reason codes (e.g., `bad_rhyme` → `"weak or missing end rhyme"`, `no_sense` → `"lines that make no sense or have broken logic"`).
  - Common code path: both `build_prompt` and `build_mimic_prompt` use `build_taste_prompt_blocks` identically.
  - CLI flags: `--taste on|off` (default `on`), `--taste-k` (default `6`).
  - Dominance guard: if fewer than 2 distinct keeper bars exist in store, falls back to existing exemplar logic.
  - PII scrubbing: `scrub_bar_pii(text)` strips emails, phone numbers, URLs, and `@mentions` prior to prompt insertion.
  - Backwards compatibility: `--taste off` produces a byte-identical prompt to the pre-change baseline (verified via snapshot test).
- **Unit Tests:** `tools/style-profile/test_taste_blocks.py` contains 6 comprehensive tests covering `build_prompt`, `build_mimic_prompt`, snapshot byte-identity with `--taste off`, dominance fallback, PII scrubbing, and `--taste-k` limits. All pass in 0.014s.
- **Full Suite Verification:**
  - `python3 -m unittest discover tools/style-profile/ -p "test_*.py"`: 23/23 tests pass.
  - `python3 tools/style-profile/phase6_generate.py self-check`: passes (`phase6 mimic self-check ok`).
- **Live Output Check:** Verified against live `tools/style-profile/out/feedback.sqlite` with Gunna ratings (6 high-weight keeper bars and 4 avoid reasons formatted and rendered as expected).
- **Next Task:** Task C — Replace `gunna_score.py` with a learned classifier (`tools/style-profile/style_scorer.py`).
