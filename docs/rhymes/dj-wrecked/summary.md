# DJ Wrecked rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Wrecked
- Songs: 1
- Bars kept (DJ Wrecked lyric lines): 24
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DJ Wrecked.
- Credit strings: DJ Wrecked.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 121
- REPEAT pairs, recorded separately: 14
- END rhymes: 33
- INNER rhymes: 88

By match:

- PERFECT: 11 (END 4, INNER 7)
- SLANT: 49 (END 13, INNER 36)
- ASSONANCE: 61 (END 16, INNER 45)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 7
- MED: 113
- LOW: 1

## Core

- Core Y: 121
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 55 (45.5%)
- vowel: 61 (50.4%)
- spelling: 5 (4.1%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 28 pairs (END 11, INNER 17). Words: hundred, budden, budgin, fuck, budget, london, pumpin, flooded.
2. `slant:AA:stop` — 10 pairs (END 0, INNER 10). Words: rock, top, pop, got, bought, hot.
3. `vow:IH` — 9 pairs (END 2, INNER 7). Words: think, bitches, wrist, stick, shit, 'til, 'fit, bitch.
4. `slant:IH:sib-stop` — 4 pairs (END 2, INNER 2). Words: bitch, shit, stick, 'fit.
5. `spell:oy` — 4 pairs (END 2, INNER 2). Words: calboy, boy, cowboy.
6. `vow:AY` — 4 pairs (END 0, INNER 4). Words: like, tie, by.
7. `cmu:AA-T` — 3 pairs (END 0, INNER 3). Words: got, bought, hot.
8. `cmu:OY` — 3 pairs (END 1, INNER 2). Words: boy, cowboy.
9. `slant:AH:nas-stop` — 3 pairs (END 1, INNER 2). Words: one, fuck, budget, budgin.
10. `slant:IH:stop` — 3 pairs (END 2, INNER 1). Words: stick, 'fit, think, wrist.
11. `vow:AA` — 3 pairs (END 0, INNER 3). Words: talkin, pop, got, poppin, want.
12. `vow:AE` — 3 pairs (END 0, INNER 3). Words: dance, back, bag, match.
13. `vow:EH` — 3 pairs (END 0, INNER 3). Words: send, air, never, said, spent.
14. `vow:EY` — 3 pairs (END 0, INNER 3). Words: ain't, say, make, made.
15. `vow:OW` — 3 pairs (END 0, INNER 3). Words: don't, broke, told, no, smoke.
16. `vow:UW` — 3 pairs (END 3, INNER 0). Words: stu, shoot, juice, shoes.
17. `slant:AE:sib-stop` — 2 pairs (END 0, INNER 2). Words: match, back, bag.
18. `slant:AH:nas` — 2 pairs (END 1, INNER 1). Words: london, budden, pumpin.
19. `slant:AY:fric-stop` — 2 pairs (END 2, INNER 0). Words: arrive, outside, slide.
20. `slant:EH:fric-nas` — 2 pairs (END 0, INNER 2). Words: when, never, envy.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- calboy — 4 pair sides, mostly spelling via spelling phonetic key, often with boy (3)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with broke (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Wrecked | Zeus | 24 | 33 | 88 | loose |
