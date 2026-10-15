# AI Sparkler style profile — build phases

Full spec: [ai-sparkler-style-profile-job-prompt.md](ai-sparkler-style-profile-job-prompt.md)

| Phase | Scope | Status |
|---|---|---|
| 1 | Deterministic per-song metrics from the CSV: cadence, end rhyme, internal rhyme, vocab. Artist rollups. `tools/style-profile/phase1_song_metrics.py` | **done, full catalog run (42,647 songs)** |
| 2 | Catalog percentiles + letter grades + artist-vs-artist ranks + style cards. `phase2_grades.py --skip-cadence`. **Run on full catalog (39,259 songs, 758 artists): rhyme + vocab done. Cadence grades still held until tempo is merged.** | **partly done** |
| 3 | BPM/key/mode. Spotify search (title → id) → ReccoBeats features. `phase3_tempo_key.py`. ~630 of 42k songs done; **Spotify rate-limited the app for ~24h (until about 2026-10-14 ~01:00 EDT)**; script now stops cleanly on long limits, default 1.2s delay. Expected coverage ~40-47% (rest are leaks/unreleased). | **paused (rate limit)** |
| 4 | Topic chains (LLM, Haiku), delivery shifts, Genius device stats. `phase4_topic_chain.py`. Genius stats done (783 artists). Topic chains piloted on 6 artists × 5 songs (30/30 labeled); full catalog not run. | **in progress** |
| 5 | Blocks map + footer data model. `phase5_blocks_map.py` (5,560 blocks exported; topic→blocks map, refreshed as Phase 4 labels grow), `feedback_store.py` (bar + block 👍/👎 → weights, 4 tests pass), spec: `ai-sparkler-footer-feedback.md`. App UI not built. | **data side built** |
| 6 | Eval harness: held-out songs, generated-vs-real profile match, originality guard. | |

## Phase 1 notes
- Run: `python3 -I tools/style-profile/phase1_song_metrics.py [--artists "A,B"] [--tag pilot]`; tests: `python3 -I tools/style-profile/test_phase1.py`.
- Output: `tools/style-profile/out/song_metrics*.jsonl`, `artist_rollup*.jsonl`.
- Repeated bars are collapsed per song (`dup_bar_pct` records how much), so hooks don't dominate. Songs under 16 bars are `confident: false` and excluded from rollups.
- `section_type` is `unknown` for ~99.8% of rows, so section-level stats (verse vs hook) are not possible yet; `dup_bar_pct` is the hook proxy.
- Rhyme tails use CMUdict (stressed rime); out-of-dictionary words are counted in `vocab.oov_pct` and skipped for rhyme.
