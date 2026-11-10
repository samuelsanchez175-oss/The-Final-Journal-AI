# Alexander Lewis rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Alexander Lewis
- Songs: 1
- Bars kept (Alexander Lewis lyric lines): 41
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Alexander Lewis.
- Credit strings: Alexander Lewis.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 130
- REPEAT pairs, recorded separately: 32
- END rhymes: 34
- INNER rhymes: 96

By match:

- PERFECT: 5 (END 1, INNER 4)
- SLANT: 38 (END 9, INNER 29)
- ASSONANCE: 86 (END 23, INNER 63)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 6
- MED: 113
- LOW: 11

## Core

- Core Y: 125
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 37 (28.5%)
- vowel: 86 (66.2%)
- spelling: 6 (4.6%)
- multi: 1 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 21 pairs (END 0, INNER 21). Words: bitches, chicken, living, still, livin, give, fiendin, biggest.
2. `vow:OW` — 18 pairs (END 7, INNER 11). Words: hoes, go, blindfold, told, know, smoke, toes, dont.
3. `vow:AA` — 12 pairs (END 0, INNER 12). Words: want, momma, rock, pockets, dollars.
4. `vow:AE` — 8 pairs (END 2, INNER 6). Words: phantom, stand, scammers, camera, can’t, trapping.
5. `vow:EY` — 8 pairs (END 5, INNER 3). Words: estates, away, fade, layaway, mayonnaise.
6. `vow:IY` — 8 pairs (END 6, INNER 2). Words: streets, these, succeed, g’s, sleeves, trees, sleep, fleek.
7. `vow:EH` — 4 pairs (END 0, INNER 4). Words: devil, heaven, air, let, bury, get.
8. `vow:UW` — 4 pairs (END 3, INNER 1). Words: through, shoes, gucci, coop, room.
9. `slant:EH:liq-stop` — 3 pairs (END 0, INNER 3). Words: air, let, bury, get.
10. `slant:IY:sib-stop` — 3 pairs (END 2, INNER 1). Words: trees, sleep, succeed, these.
11. `cmu:OW` — 2 pairs (END 0, INNER 2). Words: know, go.
12. `slant:AA:sib-stop` — 2 pairs (END 0, INNER 2). Words: got, oz.
13. `slant:AA:stop` — 2 pairs (END 0, INNER 2). Words: want, lot.
14. `slant:AH:fric-nas` — 2 pairs (END 0, INNER 2). Words: love, money, some.
15. `slant:EH:nas-stop` — 2 pairs (END 0, INNER 2). Words: get, em.
16. `slant:IH:fric-nas` — 2 pairs (END 0, INNER 2). Words: give, livin, living.
17. `slant:OW:sib` — 2 pairs (END 2, INNER 0). Words: bros, toes, nose.
18. `vow:AY` — 2 pairs (END 0, INNER 2). Words: might, buy, crime, diamonds.
19. `cmu:AY-M` — 1 pairs (END 0, INNER 1). Words: time, crime.
20. `cmu:IY-Z` — 1 pairs (END 0, INNER 1). Words: g’s, these.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- bros — 3 pair sides, mostly spelling via spelling phonetic key, often with blindfold (1)
- fiendin — 3 pair sides, mostly vowel via spelling phonetic key, often with livin (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with biggest (1)
- dont — 1 pair sides, mostly vowel via spelling phonetic key, often with told (1)
- bling — 1 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with smokey (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Alexander Lewis | Layaway | 41 | 34 | 96 | loose |
