# SBGLol rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: SBGLol
- Songs: 1
- Bars kept (SBGLol lyric lines): 45
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: SBGLol.
- Credit strings: SBGLol.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 212
- REPEAT pairs, recorded separately: 23
- END rhymes: 30
- INNER rhymes: 182

By match:

- PERFECT: 17 (END 7, INNER 10)
- SLANT: 84 (END 14, INNER 70)
- ASSONANCE: 110 (END 8, INNER 102)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 17
- MED: 189
- LOW: 6

## Core

- Core Y: 211
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 95 (44.8%)
- vowel: 110 (51.9%)
- spelling: 6 (2.8%)
- multi: 1 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 28 pairs (END 0, INNER 28). Words: go, don't, no, soul, hoes, control, won't, know.
2. `vow:IY` — 17 pairs (END 3, INNER 14). Words: even, see, free, deep, nobody, clique, sleep, feet.
3. `vow:IH` — 13 pairs (END 1, INNER 12). Words: years, thinkin, missin, wish, give, bitch, vicinity, guilt.
4. `vow:EY` — 11 pairs (END 4, INNER 7). Words: ain't, games, fakes, fake, rain, break, snakes, take.
5. `vow:AH` — 10 pairs (END 0, INNER 10). Words: nothing, love, gun, bustin, what's, fuck, runnin, fucked.
6. `vow:AO` — 9 pairs (END 0, INNER 9). Words: horses, y'all, more, four, thoughts, called, stalker, walker.
7. `slant:AO:liq` — 8 pairs (END 0, INNER 8). Words: y'all, more, four.
8. `slant:AH:stop` — 7 pairs (END 2, INNER 5). Words: fuck, fucked, what.
9. `vow:AA` — 6 pairs (END 0, INNER 6). Words: nothin, want, car, got, wantin, hard, rollin.
10. `vow:AE` — 6 pairs (END 0, INNER 6). Words: ass, can't, bank, past, frank, pass.
11. `vow:AY` — 6 pairs (END 0, INNER 6). Words: right, finally, mind, lies, outside, buy, try, line.
12. `slant:AE:nas-stop` — 5 pairs (END 0, INNER 5). Words: had, damn, can't, can.
13. `slant:AO:liq-nas` — 5 pairs (END 2, INNER 3). Words: wrong, y'all, more, four.
14. `slant:IY:stop` — 5 pairs (END 0, INNER 5). Words: weak, feet, sleep, deep.
15. `slant:AE:stop` — 4 pairs (END 0, INNER 4). Words: can't, past, bank, frank.
16. `slant:EY:sib-stop` — 4 pairs (END 0, INNER 4). Words: snakes, break, take, chains, ain't, make, days.
17. `cmu:EY-K` — 3 pairs (END 0, INNER 3). Words: fake, break, take.
18. `slant:AH:nas` — 3 pairs (END 3, INNER 0). Words: nothing, bustin.
19. `slant:AO:liq-stop` — 3 pairs (END 0, INNER 3). Words: all, called, stalker, walker.
20. `slant:EY:nas-stop` — 3 pairs (END 0, INNER 3). Words: rain, fake, wait, make.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- pedo — 2 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with give (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with pass (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| SBGLol | Glo Limit 4 | 45 | 30 | 182 | loose |
