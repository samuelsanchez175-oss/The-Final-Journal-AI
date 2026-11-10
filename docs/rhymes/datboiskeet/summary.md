# DatBoiSkeet rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DatBoiSkeet
- Songs: 1
- Bars kept (DatBoiSkeet lyric lines): 40
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DatBoiSkeet.
- Credit strings: DatBoiSkeet.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 190
- REPEAT pairs, recorded separately: 63
- END rhymes: 39
- INNER rhymes: 151

By match:

- PERFECT: 22 (END 7, INNER 15)
- SLANT: 79 (END 19, INNER 60)
- ASSONANCE: 89 (END 13, INNER 76)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 22
- MED: 166
- LOW: 2

## Core

- Core Y: 189
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 100 (52.6%)
- vowel: 89 (46.8%)
- spelling: 1 (0.5%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 26 pairs (END 4, INNER 22). Words: no, cold, dough, soul, don't, whole, know, fold.
2. `vow:IY` — 20 pairs (END 4, INNER 16). Words: streets, these, reason, eatin, breathing, here, real, need.
3. `vow:AA` — 17 pairs (END 0, INNER 17). Words: heartless, not, scars, heart, god's, bars, got, lock.
4. `slant:AO:liq-nas` — 8 pairs (END 0, INNER 8). Words: long, all, gone, story, fall.
5. `slant:OW:liq-stop` — 8 pairs (END 8, INNER 0). Words: roll, soul, fold, told, sold, cold, load.
6. `slant:AH:nas-stop` — 7 pairs (END 0, INNER 7). Words: what, done, cut, some, money, come, duck.
7. `vow:AE` — 7 pairs (END 2, INNER 5). Words: massacre, matchin, actin, after, addin.
8. `vow:AY` — 7 pairs (END 3, INNER 4). Words: mines, time, ride, ridin, try, sides, times.
9. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: no, know.
10. `cmu:OW-L-D` — 6 pairs (END 6, INNER 0). Words: fold, told, sold, cold.
11. `vow:AH` — 6 pairs (END 0, INNER 6). Words: guns, bucks, cut, what, duck, some, one.
12. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: got, heart, lock, rob.
13. `slant:IY:liq-stop` — 4 pairs (END 0, INNER 4). Words: here, need, real, eat.
14. `slant:AO:liq-sib` — 3 pairs (END 2, INNER 1). Words: story, cloth, because, all.
15. `slant:AY:nas-stop` — 3 pairs (END 1, INNER 2). Words: time, ride, like, valentine.
16. `slant:AY:sib` — 3 pairs (END 1, INNER 2). Words: sides, mines, times.
17. `slant:OW:stop` — 3 pairs (END 3, INNER 0). Words: load, told, sold, cold.
18. `cmu:AA-T` — 2 pairs (END 0, INNER 2). Words: got, not, lot.
19. `cmu:AO-L` — 2 pairs (END 0, INNER 2). Words: fall, all.
20. `slant:AA:liq-stop` — 2 pairs (END 0, INNER 2). Words: dollar, headshot, not.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with still (1)
- boysll — 1 pair sides, mostly vowel via spelling phonetic key, often with boys (1)
- gon — 1 pair sides, mostly cmu via vault phonetic_class, often with see (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DatBoiSkeet | No Love | 40 | 39 | 151 | loose |
