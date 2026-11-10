# Choshane Johnson rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Choshane Johnson
- Songs: 1
- Bars kept (Choshane Johnson lyric lines): 34
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Choshane Johnson.
- Credit strings: Choshane Johnson.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 157
- REPEAT pairs, recorded separately: 6
- END rhymes: 34
- INNER rhymes: 123

By match:

- PERFECT: 19 (END 10, INNER 9)
- SLANT: 58 (END 15, INNER 43)
- ASSONANCE: 80 (END 9, INNER 71)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 19
- MED: 130
- LOW: 8

## Core

- Core Y: 157
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 67 (42.7%)
- vowel: 80 (51.0%)
- spelling: 10 (6.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 31 pairs (END 7, INNER 24). Words: g, these, green, bee, even, feast, beast, real.
2. `vow:AY` — 14 pairs (END 2, INNER 12). Words: like, triton, irish, diamonds, expired, time, ice, shine.
3. `vow:OW` — 8 pairs (END 0, INNER 8). Words: no, won't, hope, flow, broke, poke, gold.
4. `cmu:IY` — 7 pairs (END 4, INNER 3). Words: g, b, p, bee, e.
5. `vow:IH` — 7 pairs (END 0, INNER 7). Words: women, lit, million, richly, disco, really, lids, bid.
6. `vow:UW` — 7 pairs (END 0, INNER 7). Words: truest, cool, crew, newest, lose, true, new.
7. `vow:AE` — 6 pairs (END 0, INNER 6). Words: task, tap, grant, after, gas, can't, family.
8. `vow:EH` — 5 pairs (END 0, INNER 5). Words: yes, left, plenty, never, flex, when.
9. `slant:AH:nas-sib` — 4 pairs (END 4, INNER 0). Words: anyone, guns, puns, done.
10. `slant:AH:sib-stop` — 4 pairs (END 4, INNER 0). Words: luck, bucks, chucks, snuck.
11. `cmu:AA-T` — 3 pairs (END 0, INNER 3). Words: hot, not, got.
12. `slant:AY:nas-stop` — 3 pairs (END 0, INNER 3). Words: like, shine, time.
13. `slant:AY:sib-stop` — 3 pairs (END 1, INNER 2). Words: like, ice, irish, expired.
14. `slant:EH:fric-sib` — 3 pairs (END 0, INNER 3). Words: yes, never, every, ever, ts.
15. `slant:EH:stop` — 3 pairs (END 0, INNER 3). Words: get, left, plenty.
16. `slant:AO:liq` — 2 pairs (END 0, INNER 2). Words: more, ball, basketball.
17. `slant:AO:liq-sib` — 2 pairs (END 1, INNER 1). Words: balls, basketball, ball.
18. `slant:EH:fric-stop` — 2 pairs (END 0, INNER 2). Words: never, get, ever, read.
19. `slant:EH:sib-stop` — 2 pairs (END 0, INNER 2). Words: yes, get, read, ts.
20. `slant:IH:liq` — 2 pairs (END 0, INNER 2). Words: really, icl.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- chucks — 3 pair sides, mostly spelling via spelling phonetic key, often with luck (1)
- icl — 2 pair sides, mostly spelling via spelling phonetic key, often with really (2)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with really (2)
- yalls — 1 pair sides, mostly spelling via spelling phonetic key, often with balls (1)
- filthiest — 1 pair sides, mostly spelling via spelling phonetic key, often with truest (1)
- bling — 1 pair sides, mostly spelling via spelling phonetic key, often with king (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Choshane Johnson | A million bucks ( no hating) | 34 | 34 | 123 | loose |
