# Ksoo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ksoo
- Songs: 1
- Bars kept (Ksoo lyric lines): 44
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Ksoo.
- Credit strings: Ksoo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 159
- REPEAT pairs, recorded separately: 34
- END rhymes: 34
- INNER rhymes: 125

By match:

- PERFECT: 10 (END 5, INNER 5)
- SLANT: 88 (END 18, INNER 70)
- ASSONANCE: 61 (END 11, INNER 50)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 10
- MED: 143
- LOW: 6

## Core

- Core Y: 157
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 94 (59.1%)
- vowel: 61 (38.4%)
- spelling: 4 (2.5%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AA:nas-stop` — 14 pairs (END 0, INNER 14). Words: mama, got, gotta, bought, god.
2. `vow:EY` — 14 pairs (END 0, INNER 14). Words: vacant, take, day, make, ain't, say, wait, gave.
3. `vow:AW` — 9 pairs (END 2, INNER 7). Words: now, thou, house, down, proud, about, how.
4. `slant:EY:stop` — 8 pairs (END 4, INNER 4). Words: make, wait, trade, take, made, straight.
5. `vow:AH` — 8 pairs (END 1, INNER 7). Words: mother, runnin, couple, months, love, hunnid, sum.
6. `vow:EH` — 8 pairs (END 3, INNER 5). Words: against, stressin, when, lesson, left, regret, there, blessins.
7. `vow:AY` — 6 pairs (END 1, INNER 5). Words: times, pipe, like, nine, sometimes, die, slide, life.
8. `slant:AA:liq-nas` — 5 pairs (END 0, INNER 5). Words: mama, sorry.
9. `slant:UW:sib` — 5 pairs (END 4, INNER 1). Words: rules, choose, jewels, choos, blues, lose.
10. `vow:IH` — 5 pairs (END 1, INNER 4). Words: listen, shit, kid, anything, livin, kicked.
11. `slant:AA:liq-stop` — 4 pairs (END 0, INNER 4). Words: sorry, got, god.
12. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: gotta, got, bought.
13. `slant:UW:liq-sib` — 4 pairs (END 4, INNER 0). Words: school, lose, choose, rules, jewels.
14. `cmu:AE-P` — 3 pairs (END 3, INNER 0). Words: trap, rap, strap.
15. `slant:AW:sib-stop` — 3 pairs (END 1, INNER 2). Words: house, proud, about, crowd.
16. `slant:EH:liq-nas` — 3 pairs (END 0, INNER 3). Words: when, there, chanel.
17. `slant:EY:fric-stop` — 3 pairs (END 0, INNER 3). Words: gave, hate, take.
18. `slant:IH:nas-stop` — 3 pairs (END 1, INNER 2). Words: anything, kid, shit, jimmy, wit.
19. `slant:IH:stop` — 3 pairs (END 0, INNER 3). Words: shit, kid, kicked, nigga.
20. `vow:AA` — 3 pairs (END 0, INNER 3). Words: poppin, bought, gotta, mama.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- blessins — 1 pair sides, mostly vowel via spelling phonetic key, often with stressin (1)
- hunnid — 1 pair sides, mostly vowel via spelling phonetic key, often with runnin (1)
- choos — 1 pair sides, mostly spelling via spelling phonetic key, often with blues (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with kicked (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with wont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ksoo | Mothers | 44 | 34 | 125 | loose |
