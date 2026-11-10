# OMN Twee rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: OMN Twee
- Songs: 1
- Bars kept (OMN Twee lyric lines): 40
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: OMN Twee.
- Credit strings: OMN Twee.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 123
- REPEAT pairs, recorded separately: 23
- END rhymes: 17
- INNER rhymes: 106

By match:

- PERFECT: 13 (END 6, INNER 7)
- SLANT: 48 (END 5, INNER 43)
- ASSONANCE: 62 (END 6, INNER 56)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 13
- MED: 103
- LOW: 7

## Core

- Core Y: 119
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 58 (47.2%)
- vowel: 62 (50.4%)
- spelling: 3 (2.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 30 pairs (END 0, INNER 30). Words: know, no, don't, potion, smoking, rolex, roll, expose.
2. `vow:IH` — 15 pairs (END 5, INNER 10). Words: ribs, bitch, grilled, crib, pigs, killers, kid, sip.
3. `slant:IH:liq-stop` — 9 pairs (END 2, INNER 7). Words: city, still, drill, chill, grilled, killed, crib.
4. `vow:EH` — 8 pairs (END 1, INNER 7). Words: mexicans, next, again, went, stressed, forever, trentches.
5. `cmu:IH-P` — 4 pairs (END 3, INNER 1). Words: drip, grip, slip, sip.
6. `cmu:IY-L` — 4 pairs (END 2, INNER 2). Words: real, feel, deal.
7. `slant:IH:stop` — 4 pairs (END 1, INNER 3). Words: whip, crib, dick, city.
8. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: ran, miami, scat, bag, rack.
9. `slant:AY:nas-stop` — 3 pairs (END 0, INNER 3). Words: biting, tight, right, signed, line.
10. `slant:IH:sib` — 3 pairs (END 0, INNER 3). Words: killers, niggas, ribs, drills, pigs.
11. `slant:IY:liq-sib` — 3 pairs (END 0, INNER 3). Words: here, police, these, hear.
12. `vow:IY` — 3 pairs (END 0, INNER 3). Words: shysty, city, lady, miami.
13. `cmu:IH-L` — 2 pairs (END 0, INNER 2). Words: still, drill.
14. `slant:AA:nas-stop` — 2 pairs (END 0, INNER 2). Words: mama, got, bought.
15. `slant:AE:stop` — 2 pairs (END 1, INNER 1). Words: bag, rack, had, land.
16. `slant:EH:stop` — 2 pairs (END 0, INNER 2). Words: stressed, went, next.
17. `slant:IH:nas-stop` — 2 pairs (END 1, INNER 1). Words: gripping, drip, sip.
18. `slant:OW:nas-stop` — 2 pairs (END 0, INNER 2). Words: broke, smoking, poking.
19. `vow:AE` — 2 pairs (END 0, INNER 2). Words: rack, gangsta, had, rats.
20. `cmu:AY` — 1 pairs (END 0, INNER 1). Words: buy, high.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- shysty — 3 pair sides, mostly vowel via spelling phonetic key, often with city (1)
- trentches — 2 pair sides, mostly vowel via spelling phonetic key, often with forever (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with ribs (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| OMN Twee | Oceans | 40 | 17 | 106 | loose |
