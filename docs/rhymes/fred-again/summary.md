# Fred again.. rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Fred again..
- Songs: 1
- Bars kept (Fred again.. lyric lines): 25
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Fred again...
- Credit strings: Fred again...
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 74
- REPEAT pairs, recorded separately: 18
- END rhymes: 8
- INNER rhymes: 66

By match:

- PERFECT: 2 (END 0, INNER 2)
- SLANT: 38 (END 3, INNER 35)
- ASSONANCE: 34 (END 5, INNER 29)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 2
- MED: 71
- LOW: 1

## Core

- Core Y: 74
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 39 (52.7%)
- vowel: 34 (45.9%)
- spelling: 1 (1.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 7 pairs (END 0, INNER 7). Words: can't, half, had, last.
2. `vow:IY` — 7 pairs (END 2, INNER 5). Words: breathe, see, evenings, sleepin, free, between, heal.
3. `slant:EH:stop` — 6 pairs (END 2, INNER 4). Words: went, let, get.
4. `vow:EH` — 6 pairs (END 0, INNER 6). Words: went, where, heh, every, when, there's.
5. `slant:EH:liq-stop` — 5 pairs (END 0, INNER 5). Words: where, let, get.
6. `slant:IH:liq` — 5 pairs (END 0, INNER 5). Words: year, really, still.
7. `slant:EH:nas-stop` — 4 pairs (END 0, INNER 4). Words: when, let, went, get.
8. `vow:AY` — 4 pairs (END 0, INNER 4). Words: mind, life, night.
9. `slant:AE:stop` — 3 pairs (END 0, INNER 3). Words: last, can't.
10. `slant:AY:fric-stop` — 3 pairs (END 0, INNER 3). Words: life, night, fired.
11. `vow:AH` — 3 pairs (END 0, INNER 3). Words: wonderin, drugs, love.
12. `cmu:EH-T` — 2 pairs (END 0, INNER 2). Words: let, get.
13. `slant:EH:liq-nas` — 2 pairs (END 0, INNER 2). Words: when, where, there.
14. `slant:IY:fric-nas` — 2 pairs (END 0, INNER 2). Words: believe, between.
15. `vow:AA` — 2 pairs (END 1, INNER 1). Words: stops, god, hard, gonna.
16. `vow:OW` — 2 pairs (END 0, INNER 2). Words: hold, don't, no.
17. `slant:AO:liq` — 1 pairs (END 0, INNER 1). Words: all, floor.
18. `slant:AY:stop` — 1 pairs (END 1, INNER 0). Words: night, fired.
19. `slant:EH:fric-liq` — 1 pairs (END 0, INNER 1). Words: where, every.
20. `slant:EH:fric-nas` — 1 pairs (END 0, INNER 1). Words: every, when.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with breathe (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Fred again.. | Kahan (last year) | 25 | 8 | 66 | loose |
