# TK Kravitz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: TK Kravitz
- Songs: 1
- Bars kept (TK Kravitz lyric lines): 33
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: TK Kravitz.
- Credit strings: TK Kravitz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 144
- REPEAT pairs, recorded separately: 24
- END rhymes: 22
- INNER rhymes: 122

By match:

- PERFECT: 21 (END 9, INNER 12)
- SLANT: 57 (END 4, INNER 53)
- ASSONANCE: 65 (END 8, INNER 57)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 22
- MED: 119
- LOW: 3

## Core

- Core Y: 143
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 76 (52.8%)
- vowel: 65 (45.1%)
- spelling: 2 (1.4%)
- multi: 1 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 16 pairs (END 5, INNER 11). Words: perfection, remember, let, pretend, never, said, direction, get.
2. `vow:EY` — 15 pairs (END 0, INNER 15). Words: game, scrapin, ain't, everyday, play, make, days, pay.
3. `cmu:EY` — 12 pairs (END 0, INNER 12). Words: play, everyday, pay.
4. `slant:EY:stop` — 10 pairs (END 4, INNER 6). Words: ain't, hate, made, plate, ate, donate, make.
5. `vow:OW` — 10 pairs (END 0, INNER 10). Words: no, hoes, don't, boatload, won't, hope, know.
6. `slant:EH:stop` — 7 pairs (END 0, INNER 7). Words: get, credit, bread, said, remember, friend, pretend.
7. `vow:AE` — 7 pairs (END 3, INNER 4). Words: madness, classic, have, madman, nigga, ran, can't.
8. `cmu:EY-T` — 6 pairs (END 6, INNER 0). Words: plate, ate, donate, hate.
9. `slant:EH:nas-stop` — 5 pairs (END 0, INNER 5). Words: when, friend, pretend, get.
10. `vow:AO` — 5 pairs (END 0, INNER 5). Words: jordans, wanted, all, more.
11. `vow:AY` — 5 pairs (END 0, INNER 5). Words: try, mind, life.
12. `slant:EY:nas-stop` — 4 pairs (END 0, INNER 4). Words: came, make, pain, donate, hate, made.
13. `vow:IY` — 4 pairs (END 0, INNER 4). Words: even, feet, eat, realest.
14. `slant:AA:nas-stop` — 3 pairs (END 0, INNER 3). Words: wanna, want, got.
15. `vow:IH` — 3 pairs (END 0, INNER 3). Words: shit, didn't.
16. `slant:AH:nas-stop` — 2 pairs (END 0, INNER 2). Words: some, fuck, what.
17. `slant:AH:stop` — 2 pairs (END 0, INNER 2). Words: fuck, what.
18. `slant:AY:fric-stop` — 2 pairs (END 0, INNER 2). Words: right, strive, life.
19. `slant:EH:fric-nas` — 2 pairs (END 0, INNER 2). Words: never, when.
20. `slant:EH:liq-stop` — 2 pairs (END 0, INNER 2). Words: dare, let, get.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with ran (1)
- realest — 1 pair sides, mostly vowel via spelling phonetic key, often with even (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| TK Kravitz | No Mind | 33 | 22 | 122 | loose |
