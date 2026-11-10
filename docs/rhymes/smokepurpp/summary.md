# Smokepurpp rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Smokepurpp
- Songs: 1
- Bars kept (Smokepurpp lyric lines): 66
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Smokepurpp.
- Credit strings: Smokepurpp.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 258
- REPEAT pairs, recorded separately: 52
- END rhymes: 60
- INNER rhymes: 198

By match:

- PERFECT: 24 (END 5, INNER 19)
- SLANT: 147 (END 31, INNER 116)
- ASSONANCE: 81 (END 23, INNER 58)
- MULTI: 6 (END 1, INNER 5)

By confidence:

- HIGH: 28
- MED: 217
- LOW: 13

## Core

- Core Y: 255
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 160 (62.0%)
- vowel: 81 (31.4%)
- spelling: 11 (4.3%)
- multi: 6 (2.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 16 pairs (END 7, INNER 9). Words: fuck, puzzle, young, crumble, plumbers, bubble, trouble, tussle.
2. `vow:OW` — 16 pairs (END 3, INNER 13). Words: blow, know, don't, ho, lower, hoes, road, toes.
3. `slant:AY:sib-stop` — 14 pairs (END 9, INNER 5). Words: price, like, dice, slice, poltergeist, tonight, roadside, ride.
4. `slant:AY:stop` — 12 pairs (END 3, INNER 9). Words: like, tonight, ride, roadside, fight, poltergeist.
5. `slant:AA:liq-stop` — 11 pairs (END 0, INNER 11). Words: ferrari, drop, top, block, got.
6. `slant:AA:stop` — 11 pairs (END 0, INNER 11). Words: block, got, drop, top, pop, dropped, hop.
7. `vow:AA` — 11 pairs (END 0, INNER 11). Words: flops, solve, gotti, dropped, started, cause, bah, versace.
8. `vow:AY` — 10 pairs (END 6, INNER 4). Words: poltergeist, tie, like, ride, roadside, tonight.
9. `cmu:IY-T` — 9 pairs (END 0, INNER 9). Words: heat, street, elite, suite, beat, seat, feet.
10. `slant:AH:liq` — 9 pairs (END 9, INNER 0). Words: bubble, trouble, puzzle, tussle, humble, crumble.
11. `slant:IH:liq-sib` — 9 pairs (END 0, INNER 9). Words: bitch, still, lil.
12. `slant:AA:sib-stop` — 8 pairs (END 0, INNER 8). Words: versace, gotti, flops, drop, top, cause, pop, got.
13. `cmu:OW-Z` — 5 pairs (END 0, INNER 5). Words: hoes, toes, nose.
14. `slant:IY:stop` — 5 pairs (END 1, INNER 4). Words: deep, heat, speak, street, reek, seat.
15. `slant:OW:liq-sib` — 5 pairs (END 1, INNER 4). Words: soul, hoes, toes, nose, pole, sosa, roll.
16. `vow:AE` — 5 pairs (END 4, INNER 1). Words: ratchet, daddy, have, magic, gamble, had.
17. `vow:IY` — 5 pairs (END 2, INNER 3). Words: thirty, deep, tree, heat, street, reek.
18. `cmu:AA-P` — 4 pairs (END 0, INNER 4). Words: drop, top.
19. `slant:EH:stop` — 4 pairs (END 0, INNER 4). Words: bread, get, belt, set, ready.
20. `slant:IH:sib-stop` — 4 pairs (END 4, INNER 0). Words: bitch, shit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- percocet — 4 pair sides, mostly vowel via spelling phonetic key, often with set (1)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with pretty (4)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with smoke (1)
- nem — 2 pair sides, mostly spelling via spelling phonetic key, often with very (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with greedy (1)
- blickies — 1 pair sides, mostly multi via spelling phonetic key, often with shorties (1)
- shorties — 1 pair sides, mostly multi via spelling phonetic key, often with blickies (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Smokepurpp | I Don’t Know You | 66 | 60 | 198 | loose |
