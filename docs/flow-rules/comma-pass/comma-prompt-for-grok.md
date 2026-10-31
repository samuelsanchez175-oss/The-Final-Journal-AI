# Comma-placement analysis pass — paste-ready prompt for Grok

Design intent: in Penwork, the comma is the breath/break marker in a bar. Eventually it will be combined with syllable count to place a bar behind, on, or ahead of the beat. THIS PASS IS ANALYSIS ONLY. Nothing in the app or the vault changes.

Project root: /Users/samuel/Music/all xcode projects files/pennworkstudios.nosync

## Goal
Run a comma analysis pass over the lyric vault and write a report. Report only.

## Hard rules
- Open tools/bar-hits-catalog/BarHitsCatalog.sqlite read-only (sqlite URI `mode=ro`). Table `bars`: artist, song, line. Never write to it.
- No Swift or xcodeproj edits. No chip promotion. No writes to click logs (docs/play-on-words/genius-clicks/).
- Don't touch git stash@{0}. Don't commit.
- No web calls. If one is unavoidable, make them one at a time and throttle them.
- Write all output to docs/flow-rules/comma-pass/.

## Steps
1. Read every bar. Record its comma count, and for each comma its word index and its percent of the bar's length.
2. Flag bad commas using a lightweight part-of-speech tagger (spaCy small model, or NLTK). Keep the rules simple and explainable.
   - Subject-verb split: a comma right after a lone pronoun or subject, before its verb. Example: "If I, slide to your city".
   - Mid-phrase split: a comma inside a phrase like "what I got", or between a verb and its object. Example: "I can't share what, I got".
3. Flag possible missing commas at clause breaks: before cuz, but, when, so, 'cause, while, till, or before a second "I" clause. These are suggestions only. 44% of vault bars have no comma, so a missing comma is never an error.
4. For each flagged bar, suggest a corrected comma position, or "no comma needed". Keep the original lines unchanged.
5. Hand-check 100 random flags. Report the precision for each flag type, and mark any type under 70% precision as unreliable.
6. Write these files:
   - report.md (real counts only): bars read; bars with commas; total commas; flags by type; missing-comma suggestions; suggested fixes; precision for each flag type; comma-position distribution (check that the median is still about 45% into the bar); top 20 artists by flag rate.
   - flags.jsonl: one row per flag, with artist, song, line, flag_type, comma_position, suggestion.
   - examples.md: 15 examples of each flag type, plus 15 good clause-break commas for contrast.
7. Report back with the counts, the precision numbers and the file paths. Don't propose app changes. Samuel reviews first.
