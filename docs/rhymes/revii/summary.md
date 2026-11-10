# Revii rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Revii
- Songs: 1
- Bars kept (Revii lyric lines): 40
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Revii.
- Credit strings: Revii.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 323
- REPEAT pairs, recorded separately: 33
- END rhymes: 39
- INNER rhymes: 284

By match:

- PERFECT: 17 (END 2, INNER 15)
- SLANT: 137 (END 15, INNER 122)
- ASSONANCE: 167 (END 22, INNER 145)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 19
- MED: 284
- LOW: 20

## Core

- Core Y: 321
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 136 (42.1%)
- vowel: 167 (51.7%)
- spelling: 18 (5.6%)
- multi: 2 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 56 pairs (END 10, INNER 46). Words: shit, drink, digits, triple, bills, twins, big, sittin.
2. `vow:AA` — 24 pairs (END 2, INNER 22). Words: got, want, started, flops, bottom, problem, cock, top.
3. `vow:OW` — 23 pairs (END 0, INNER 23). Words: don't, no, hold, know, throw, smoke, rollie, knowin.
4. `vow:AE` — 19 pairs (END 1, INNER 18). Words: asking, happened, landed, reaction, action, can't, act, matter.
5. `slant:IH:stop` — 14 pairs (END 4, INNER 10). Words: shit, nigga, big, minute, hit, flip, liquor, sit.
6. `slant:IH:nas-stop` — 12 pairs (END 0, INNER 12). Words: shit, swing, him, i'ma, big, drink, sittin.
7. `vow:AH` — 11 pairs (END 1, INNER 10). Words: fucks, what, blunts, blunt, puff, double, love, some.
8. `slant:AA:stop` — 9 pairs (END 3, INNER 6). Words: got, want, top, cock, not, hard, heart.
9. `slant:IH:sib-stop` — 7 pairs (END 0, INNER 7). Words: bitch, liquor, big, fix, minute, twins, nigga, niggas.
10. `vow:AW` — 7 pairs (END 0, INNER 7). Words: maui, counts, bouncin, downin, bouncy, count, 'bout.
11. `vow:UW` — 7 pairs (END 7, INNER 0). Words: roof, snoozin, movin, movement, boolin.
12. `slant:AH:nas-stop` — 6 pairs (END 0, INNER 6). Words: one, what, some, cut, blunt, luck.
13. `slant:AH:stop` — 6 pairs (END 0, INNER 6). Words: what, blunt, luck, cup, rub, cut.
14. `slant:AE:stop` — 5 pairs (END 1, INNER 4). Words: bad, act, rag, back, happened, can't, had.
15. `vow:AO` — 5 pairs (END 1, INNER 4). Words: cords, longer, pour, foreign, store, more, four.
16. `cmu:OW` — 4 pairs (END 0, INNER 4). Words: know, throw, no.
17. `slant:AA:liq-stop` — 4 pairs (END 0, INNER 4). Words: cali, got, car, job, hard.
18. `slant:AH:fric-stop` — 4 pairs (END 0, INNER 4). Words: puff, what, love, cup, luck.
19. `slant:EH:stop` — 4 pairs (END 0, INNER 4). Words: said, get, ready, send, set.
20. `slant:IH:liq-sib` — 4 pairs (END 0, INNER 4). Words: bitch, really, bill, bills.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with big (3)
- gon — 6 pair sides, mostly spelling via spelling phonetic key, often with smoke (2)
- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- boolin — 2 pair sides, mostly vowel via spelling phonetic key, often with snoozin (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Revii | Greenroom | 40 | 39 | 284 | loose |
