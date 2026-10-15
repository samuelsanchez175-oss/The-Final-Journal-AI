# AI Sparkler footer: borrowed blocks + thumbs feedback

Implementation of the data side: `tools/style-profile/feedback_store.py` (SQLite, tested). The app UI is not built yet.

## What the footer shows
Under each generated lyric: the **Blocks it borrowed** (chips) and the **catalog bars it borrowed from**. Each bar, each chip and each source bar has 👍/👎.

## What gets logged
- `generations`: artist requested, model, prompt version, request knobs.
- `generation_bars`: bar text + the topic the generator was in for that bar.
- `bar_sources`: per bar, which Blocks (`kind=block`, `ref`=normalised block, `category`) and catalog bars (`kind=catalog_bar`, `ref`=artist.song.bar) it used.
- `votes`: `target_kind` = bar | block | catalog_bar, +1/-1, optional reason on bar 👎 (off_topic, bad_rhyme, off_flow, too_copied, cringe).

## How votes become weights
`weight(kind, ref, topic, artist)` = approval 0..1, Beta-smoothed and shrunk: (source, topic, artist) falls back to (source, topic), then (source), then 0.5. So a block can be good for money talk and bad for love talk, and good for one artist only.

A bar 👎 where every chip on that bar was already 👍 is marked `blame = pairing`: the combination failed, so the blocks are not penalised.

## Where the generator uses it
Retrieval/rerank: multiply a candidate block's or source bar's score by its weight in the current (topic, artist). Start here; train a model on the votes later, when there are thousands.

## Topic -> Blocks
`tools/style-profile/phase5_blocks_map.py`: `export` writes `out/blocks_catalog.jsonl` (5,560 blocks in 55 categories, parsed from `NounBankStore.swift` + `WordplayFlips.json`); `map` writes `out/topic_blocks.json` (curated category->topic prior + observed block counts and lift per topic from Phase 4 labels) and `out/artist_topic_blocks.json`.
