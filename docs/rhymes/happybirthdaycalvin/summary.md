# HappyBirthdayCalvin rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: HappyBirthdayCalvin
- Songs: 1
- Bars kept (HappyBirthdayCalvin lyric lines): 19
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: HappyBirthdayCalvin.
- Credit strings: HappyBirthdayCalvin.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 206
- REPEAT pairs, recorded separately: 25
- END rhymes: 32
- INNER rhymes: 174

By match:

- PERFECT: 13 (END 0, INNER 13)
- SLANT: 77 (END 13, INNER 64)
- ASSONANCE: 114 (END 17, INNER 97)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 15
- MED: 184
- LOW: 7

## Core

- Core Y: 206
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 83 (40.3%)
- vowel: 114 (55.3%)
- spelling: 7 (3.4%)
- multi: 2 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 29 pairs (END 4, INNER 25). Words: bae, high, time, ice, grind, mine, like, why.
2. `vow:EY` — 23 pairs (END 2, INNER 21). Words: day, ain't, say, make, angel, days, lace, place.
3. `vow:IY` — 22 pairs (END 11, INNER 11). Words: deal, tweakin, demon, reason, competing, leavin, cream, screeching.
4. `slant:IY:nas` — 18 pairs (END 9, INNER 9). Words: reason, treason, tryna, screeching, demon, semen, even, leavin.
5. `vow:AA` — 12 pairs (END 0, INNER 12). Words: got, yah, profit, wanna, pocket, cars, rockin, watch.
6. `vow:OW` — 10 pairs (END 0, INNER 10). Words: no, don't, focused, go, focus.
7. `vow:AE` — 9 pairs (END 0, INNER 9). Words: last, ask, can, bad, half, bands, cash, mad.
8. `slant:EY:sib-stop` — 7 pairs (END 1, INNER 6). Words: make, lace, place, wait, days.
9. `slant:AA:stop` — 6 pairs (END 0, INNER 6). Words: got, heart, want, profit, pocket.
10. `cmu:AY` — 5 pairs (END 0, INNER 5). Words: bae, why, high.
11. `vow:EH` — 5 pairs (END 0, INNER 5). Words: end, where, friends, best, better, mess.
12. `slant:AY:sib-stop` — 4 pairs (END 0, INNER 4). Words: like, nice, tires, ice.
13. `cmu:OW` — 3 pairs (END 0, INNER 3). Words: no, go.
14. `slant:AE:sib-stop` — 3 pairs (END 1, INNER 2). Words: last, ass, stand, bands.
15. `slant:AY:nas-stop` — 3 pairs (END 1, INNER 2). Words: like, mine, time, grind.
16. `slant:EY:nas-sib` — 3 pairs (END 0, INNER 3). Words: playin, days, lace, place.
17. `slant:AA:nas-sib` — 2 pairs (END 0, INNER 2). Words: wanna, watch.
18. `slant:AA:sib-stop` — 2 pairs (END 0, INNER 2). Words: cars, heart, got, watch.
19. `slant:AY:nas-sib` — 2 pairs (END 0, INNER 2). Words: ice, time, mine.
20. `slant:AY:stop` — 2 pairs (END 0, INNER 2). Words: might, side, outside.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 6 pair sides, mostly spelling via spelling phonetic key, often with demon (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with sit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| HappyBirthdayCalvin | No Friends (Remix) | 19 | 32 | 174 | loose |
