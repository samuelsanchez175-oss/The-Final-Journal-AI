# Lihtz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lihtz
- Songs: 1
- Bars kept (Lihtz lyric lines): 36
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lihtz.
- Credit strings: Lihtz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 234
- REPEAT pairs, recorded separately: 49
- END rhymes: 41
- INNER rhymes: 193

By match:

- PERFECT: 19 (END 4, INNER 15)
- SLANT: 83 (END 9, INNER 74)
- ASSONANCE: 130 (END 26, INNER 104)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 19
- MED: 214
- LOW: 1

## Core

- Core Y: 234
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 99 (42.3%)
- vowel: 130 (55.6%)
- spelling: 3 (1.3%)
- multi: 2 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 59 pairs (END 10, INNER 49). Words: get, presence, pregnant, destined, investment, stressin, blessin, lesson.
2. `vow:OW` — 28 pairs (END 7, INNER 21). Words: go, know, don't, only, cold, lovin, no, lows.
3. `vow:AE` — 22 pairs (END 9, INNER 13). Words: backwards, nasty, savage, ask, naturally, static, happy, past.
4. `slant:EH:nas-stop` — 12 pairs (END 0, INNER 12). Words: when, many, let, said, get, dead, shed, meant.
5. `slant:EH:stop` — 11 pairs (END 0, INNER 11). Words: get, said, shed, let, meant, dead, best, internet.
6. `cmu:OW` — 10 pairs (END 4, INNER 6). Words: go, snow, eskimo, know, no.
7. `slant:AH:fric-nas` — 7 pairs (END 0, INNER 7). Words: love, done, come, someone.
8. `vow:IH` — 7 pairs (END 0, INNER 7). Words: years, shit, still, interested, big.
9. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: done, what, cut, come, someone.
10. `vow:AA` — 5 pairs (END 0, INNER 5). Words: wasn't, gotta, heart, start, car, hard.
11. `slant:AE:nas-stop` — 4 pairs (END 0, INNER 4). Words: man, braggin, bag, can't, had.
12. `slant:AA:liq-stop` — 3 pairs (END 0, INNER 3). Words: car, heart, start, gotta.
13. `slant:AE:stop` — 3 pairs (END 0, INNER 3). Words: mad, bag, nasty, past.
14. `slant:AH:fric-stop` — 3 pairs (END 0, INNER 3). Words: love, what, fuck.
15. `slant:AH:nas` — 3 pairs (END 0, INNER 3). Words: come, someone, done, runnin.
16. `slant:EH:nas` — 3 pairs (END 2, INNER 1). Words: lesson, stressin, blessin, when.
17. `slant:EY:stop` — 3 pairs (END 3, INNER 0). Words: sacred, naked, waited.
18. `slant:IH:liq-stop` — 3 pairs (END 0, INNER 3). Words: shit, subzero, still.
19. `vow:UW` — 3 pairs (END 0, INNER 3). Words: move, through, beautiful, delusional.
20. `cmu:EH-D` — 2 pairs (END 0, INNER 2). Words: said, dead.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ntical — 2 pair sides, mostly spelling via spelling phonetic key, often with skeptical (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with need (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lihtz | Let You Go | 36 | 41 | 193 | loose |
