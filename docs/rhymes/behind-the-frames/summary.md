# Behind The Frames rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Behind The Frames
- Songs: 1
- Bars kept (Behind The Frames lyric lines): 5
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Behind The Frames.
- Credit strings: Behind The Frames.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 18
- REPEAT pairs, recorded separately: 1
- END rhymes: 1
- INNER rhymes: 17

By match:

- PERFECT: 1 (END 1, INNER 0)
- SLANT: 7 (END 0, INNER 7)
- ASSONANCE: 10 (END 0, INNER 10)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 1
- MED: 16
- LOW: 1

## Core

- Core Y: 18
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 7 (38.9%)
- vowel: 10 (55.6%)
- spelling: 1 (5.6%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- ABCB: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 5 pairs (END 0, INNER 5). Words: player, name, place, waiting, take.
2. `vow:AA` — 4 pairs (END 0, INNER 4). Words: softer, charge, hockey, glock.
3. `cmu:EH-R` — 1 pairs (END 1, INNER 0). Words: there, welfare.
4. `slant:AH:fric-nas` — 1 pairs (END 0, INNER 1). Words: tough, some.
5. `slant:AY:fric-stop` — 1 pairs (END 0, INNER 1). Words: like, five.
6. `slant:AY:nas-stop` — 1 pairs (END 0, INNER 1). Words: time, like.
7. `slant:EY:nas-sib` — 1 pairs (END 0, INNER 1). Words: name, place.
8. `slant:EY:nas-stop` — 1 pairs (END 0, INNER 1). Words: take, name.
9. `slant:EY:sib-stop` — 1 pairs (END 0, INNER 1). Words: take, place.
10. `slant:IH:stop` — 1 pairs (END 0, INNER 1). Words: stick, nigga.
11. `vow:AO` — 1 pairs (END 0, INNER 1). Words: all, talking.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with stick (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Behind The Frames | Scrimmage | 5 | 1 | 17 | ABCB |
