I need you to upgrade the verse generator in my "AI Sparkler" project so it writes **nearly indistinguishable from Gunna** in one specific era, defined by a fixed set of his songs (the "anchor set" below). Right now the output reads like an AI imitating rap: forced rhymes, lines that don't make sense out loud, generic flexing. I want a listener to think a generated verse is an unreleased Gunna outtake from these songs.

I'm attaching the current code. Claude Code maintains the repo and can't see this chat, so follow the **Handoff protocol** at the bottom in every reply.

**Attached files:** `phase6_generate.py` (generator), `phase1_song_metrics.py` (CMUdict syllables + rhyme logic), `phase4_topic_chain.py` (only `song_bars()` matters), `phase6_compare_models.py` (runs one prompt across models and writes the comparison page data).

---

## What to drop

Do NOT use the noun bank, the "blocks" catalog, topic labels, or topic briefs to drive generation. They made the output generic. The only style source is the anchor set (plus my ratings, see below).

## The anchor set (exact titles as they appear in the data)

| Title in CSV | Album in CSV |
|---|---|
| Phase | Unknown (verify this is the right song) |
| Don’t Give Up | Unknown |
| Invest | Unknown |
| Spending Addiction | Drip Season 3 |
| Mistress | Drip Season 3 |
| back to the moon | Unknown |
| idk nomore | A Gift & A Curse |
| paybach | A Gift & A Curse |
| born rich | A Gift & A Curse |
| turned your back | A Gift & A Curse |
| pushin P | Unknown |
| thought i was playing | DS4EVER |
| poochie gown | A Gift & A Curse |
| mop | DRIP SEASON 4EVER |
| how you did that | DRIP SEASON 4EVER |
| south to west | A Gift & A Curse |
| 25k jacket | DRIP SEASON 4EVER |
| too easy | Unknown |
| idk that bitch | DRIP SEASON 4EVER |
| Diamonds Dancing | Unknown |

"Lie About You" is not in the data; skip it. Match titles case-insensitively after normalizing curly apostrophes. Put the list in one constant (`ANCHOR_SONGS`) so I can edit it later. About 1,100 raw lines total before dedupe; hooks repeat a lot.

## Data you have

- Lyrics CSV: `XJournal AI/ground_truth_rap_bars_MODEL_G.csv`, read via `phase1_song_metrics.read_songs(csv_path, {"gunna"})`. Bars are ordered by the trailing number in the first column. `phase4_topic_chain.song_bars()` gives each song's bars in order with exact duplicate lines removed. Ad-libs are in parentheses inside the bar text.
- `phase1_song_metrics.Lexicon` / `Bar`: CMUdict syllable counts, stress, rhyme keys (`rime`, `v2`), `end_word`, `end_phones`; `trailing_vowel_depth()`.
- `phase6_generate.py` already has: `Corpus` (full Gunna catalog, copy checks), `analyze_verse()` (CMUdict checks), `call_model()` (shells out to `claude -p --model haiku|sonnet|opus`), `run_model()` (retry loop), `load_taste()` (reads my rater exports), and the output shape the rating page reads (schema `phase6.v2`). Keep that shape.
- My ratings: `tools/style-profile/rater/exports/sparkler_ratings_*.json` (schema `sparkler.ratings.v1`; bar-level `vote`, `keeper`, `reasons`). Reasons I use most: `no_sense`, `cringe`, `bad_rhyme`, `off_flow`. Files with `"rater": "sparkler-grader"` are machine-made; ignore them.

## What to build

### 1. Anchor profile (`build_anchor_profile.py` → `out/anchor_profile_gunna.json`)
Measure Gunna's writing in the anchor set only, deterministically (Python, no LLM):
- syllables per bar (distribution, not just mean) and per half when a bar has a comma
- how bars start (first-word and first-two-word frequencies), how often consecutive bars start the same way
- end-rhyme behavior: couplet vs alternating vs runs of 3+ bars on one sound; most-used end-rhyme sound families; how often he rhymes the same word with itself
- repetition: repeated lines, repeated phrases inside a verse, call-and-response shapes
- ad-libs: how often, where in the bar, the most common ones
- vocabulary: his signature words/phrases and slang (ranked by how much more often he uses them in the anchor set than in his whole catalog), brands, names, places
- verse shape: typical verse length, where hooks sit relative to verses

Print a short human-readable summary too. I want to read what "Gunna in this era" looks like as numbers.

### 2. `mimic` generation mode in `phase6_generate.py`
- Retrieval only from the anchor set. Give the model **whole real verses (8–16 bars)** as examples, not isolated couplets: flow and repetition only show up across a full verse.
- Put the anchor profile numbers into the prompt as plain facts.
- Task framing: "write a new verse that sounds like an unreleased outtake from these exact songs."
- A `--closeness` dial from 0 to 1. Near 1: keep his line shapes and phrases, swap names, numbers, objects, places. Near 0: same voice, new lines. Default 0.7.
- Ad-libs in parentheses are allowed in this mode, matched to his real rate and placement. The other modes currently ban them.
- Keep only these hard rules: the verse must make sense read out loud, follow the anchor profile's rhyme behavior (not a fixed AABB), and never output a line identical to a real Gunna bar (`Corpus.full_copy`). Everything else is a target, not a pass/fail.
- My liked/keeper bars from `load_taste()` go in as "this is the target", rejected bars as "never like this".
- `--bars` stays (4, 8, 16).

### 3. "Gunna-ness" scorer (`gunna_score.py`)
A deterministic score (0–100) for how close a verse is to the anchor profile: syllable-distribution distance, rhyme-family overlap, signature-vocabulary rate, bar-start patterns, repetition rate, ad-lib rate, and function-word profile (small words carry style). Then **prove it works**: score held-out real anchor verses (leave-one-song-out), verses from other artists in the same CSV, and verses from the current generator. Print each group's average and how well the score separates real Gunna from everything else (AUC or a plain confusion table). If it can't tell real Gunna from fake, say so. Don't hide it.

### 4. Best-of-N
`--candidates N` (default 8): generate N verses, drop any with hard-rule failures, rank by the scorer, keep the top 2 for the rating page. Record every candidate's score in the output so we can later check whether my thumbs agree with the scorer.

## Constraints
- Python 3.9, standard library only (no pip installs). CMUdict is a local text file, already loaded by `phase1_song_metrics`.
- Don't break the existing `rewrite` and `fresh` modes or the `phase6.v2` output shape (the rating page and `phase6_compare_models.py` depend on it). Add new fields; don't rename old ones.
- Model calls go through the existing `call_model()`.
- This is a private writing aid. Don't paste lyrics into code comments or docs; read them from the CSV at runtime.
- You can't run code, so for every file give me the exact command to run it and what output I should expect to see.

## Handoff protocol (every reply, no exceptions)

I save your files into `tools/style-profile/` and paste your handoff entry into `tools/style-profile/rater/GROK_HANDOFF.md`, which Claude Code reads before touching the pipeline.

1. Always send COMPLETE files, never partial diffs.
2. End EVERY reply with this block (write "none" for empty fields):

````markdown
### HANDOFF ENTRY: <short title> (<YYYY-MM-DD>, Grok, generator)

**Status:** <working / partly working / untested / broken: one line>
**Files added or changed:** <path: one line each on what it does>
**How to run:** <exact commands, and the output Samuel should expect>
**Contract changes:** <new or changed fields in the phase6.v2 output, CLI flags, file paths. "none" if none>
**Known bugs / not done yet:** <bullets>
**Questions for Claude:** <anything you need checked or measured on the real data>
**What Samuel asked for this round:** <one line>
````

3. If I paste a message starting with `FROM CLAUDE:`, treat it as instructions from the repo maintainer (usually test results from running your code) and answer it in the next handoff entry.
4. If I say `handoff`, reply with only a full-summary HANDOFF ENTRY for the whole conversation.

Start with: (a) a short plan, (b) any questions about the data, then (c) `build_anchor_profile.py` and `gunna_score.py` first, since they tell us what "sounds like Gunna" means before we change generation.
