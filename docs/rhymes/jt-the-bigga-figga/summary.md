# JT the Bigga Figga rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: JT the Bigga Figga
- Songs: 1
- Bars kept (JT the Bigga Figga lyric lines): 26
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: JT the Bigga Figga.
- Credit strings: JT the Bigga Figga.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 125
- REPEAT pairs, recorded separately: 27
- END rhymes: 17
- INNER rhymes: 108

By match:

- PERFECT: 6 (END 0, INNER 6)
- SLANT: 61 (END 12, INNER 49)
- ASSONANCE: 54 (END 5, INNER 49)
- MULTI: 4 (END 0, INNER 4)

By confidence:

- HIGH: 8
- MED: 88
- LOW: 29

## Core

- Core Y: 124
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 37 (29.6%)
- vowel: 54 (43.2%)
- spelling: 30 (24.0%)
- multi: 4 (3.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:IH:stop` — 23 pairs (END 6, INNER 17). Words: nigga, big, bigger, dick, digger.
2. `vow:IH` — 13 pairs (END 3, INNER 10). Words: figures, bigger, big, drippin, killer, really, killers, digger.
3. `vow:EY` — 12 pairs (END 0, INNER 12). Words: ain't, played, names, baby, pay, player, same, game.
4. `slant:IH:sib-stop` — 7 pairs (END 0, INNER 7). Words: nigga, niggas, bitch, big, dick.
5. `vow:OW` — 7 pairs (END 0, INNER 7). Words: don't, know, over, hold, smoking, slosin.
6. `vow:AA` — 6 pairs (END 0, INNER 6). Words: knocking, got, wanna, not.
7. `vow:AE` — 5 pairs (END 0, INNER 5). Words: racks, ran, mask, gang, can't, trap.
8. `multi:IH-G-ER` — 4 pairs (END 0, INNER 4). Words: digger, bigger, gold digger, got bigger.
9. `slant:IH:liq-stop` — 4 pairs (END 2, INNER 2). Words: killer, bigger, digger, big.
10. `vow:IY` — 4 pairs (END 0, INNER 4). Words: ski, streets, these, team.
11. `slant:EY:nas-sib` — 3 pairs (END 1, INNER 2). Words: names, days, came, same, game.
12. `vow:AY` — 3 pairs (END 1, INNER 2). Words: tyson, like, mike.
13. `cmu:AY-K` — 2 pairs (END 0, INNER 2). Words: like, mike.
14. `slant:AA:nas-stop` — 2 pairs (END 0, INNER 2). Words: got, wanna.
15. `slant:AE:nas-stop` — 2 pairs (END 0, INNER 2). Words: ran, back, trap.
16. `slant:AH:nas` — 2 pairs (END 1, INNER 1). Words: one, money.
17. `slant:EY:nas-stop` — 2 pairs (END 0, INNER 2). Words: played, game, same.
18. `slant:IH:liq-sib` — 2 pairs (END 0, INNER 2). Words: really, killers.
19. `slant:IY:liq-stop` — 2 pairs (END 0, INNER 2). Words: street, real.
20. `spell:king` — 2 pairs (END 0, INNER 2). Words: smoking, knocking, chalking.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 25 pair sides, mostly spelling via spelling phonetic key, often with big (11)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)
- roli — 2 pair sides, mostly spelling via spelling phonetic key, often with over (1)
- slosin — 1 pair sides, mostly vowel via spelling phonetic key, often with smoking (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with zone (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| JT the Bigga Figga | Money Talk | 26 | 17 | 108 | loose |
