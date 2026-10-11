# wordplay-index / notes queue — for chat 7 (Anti-Gravity)

**notes-queue.jsonl is your scope-D input.** It holds every saved Genius community note (genius-clicks/*.jsonl, type "line", field `meaning`) whose text matched a Play on Words tab signal: 17,024 unique artist+song+bar rows, built 2026-10-10 03:14 ET. No Genius API calls were made, and no vault, Swift, click log, candidates file or recheck.jsonl was touched.

**`guess_tab` / `guess_subtype` are only regex hints.** Classify every line yourself into one of these: sound_flips (sound_flip, homophone), double_meanings (double_meaning, idiom_twist, extended_metaphor), split_names (split_name, split_brand), hidden_references (hidden_title, hidden_number, letter_play). `punchline_setup` is a flag, not a tab. Rows with guess_tab = null matched only punchline signals. Many rows are not wordplay at all. The weakest are rows whose only signal is "both", "play on", "metaphor" or "code".

Nothing was dropped for drug, gun, sex, gang or faith content. `hedged: true` means the note hedges (possibly, might, maybe, perhaps, or "?"). Hedging is not a reason to reject a row.

Row fields: artist, song, bar (vault bar, which is the vault_lines joined, or the Genius fragment if there are none), note (full), source_url, guess_tab, guess_subtype, matched_signals[], hedged, punchline_setup, already_reviewed / prior_verdict (matched against confirmed-recheck/recheck.jsonl on the joined bar, each vault line, or the Genius fragment), wired_chip (noun from wordplay-wiring-log.jsonl, falling back to heard_as from wordplay-highlights.jsonl), genius_fragment, vault_lines, annotation_id, votes, other_notes[] (other notes on the same bar, merged during dedupe).

Order: the 81 main artists (20+ vault songs, from all-artists-baseline.md) by song count, then everyone else, then song. Start with `already_reviewed: false` (15,614 rows).

Files: notes-queue.jsonl, notes-queue-summary.md, build_notes_queue.py (rerun writes fail if outputs exist; delete them first). index.jsonl, summary.md, reindex_engine.py, run_full_reindex.py in this folder belong to a separate reindex job and were left alone.
