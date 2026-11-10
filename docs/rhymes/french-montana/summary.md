# French Montana rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: French Montana
- Songs: 13
- Bars kept (French Montana lyric lines): 432
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: French Montana.
- Credit strings: French Montana.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 2649
- REPEAT pairs, recorded separately: 306
- END rhymes: 387
- INNER rhymes: 2262

By match:

- PERFECT: 196 (END 45, INNER 151)
- SLANT: 1105 (END 179, INNER 926)
- ASSONANCE: 1313 (END 152, INNER 1161)
- MULTI: 35 (END 11, INNER 24)

By confidence:

- HIGH: 201
- MED: 2262
- LOW: 186

## Core

- Core Y: 2579
- Core N among rhyme pairs: 70

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1157 (43.7%)
- vowel: 1313 (49.6%)
- spelling: 144 (5.4%)
- multi: 35 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 13 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 197 pairs (END 18, INNER 179). Words: got, hard, lockin, watchin, box, bottom, watch, pop.
2. `vow:AY` — 174 pairs (END 24, INNER 150). Words: like, lie, why, time, diamonds, fire, slidin, try.
3. `vow:AH` — 165 pairs (END 20, INNER 145). Words: months, what, summer, under, one, couple, fuck, fuckin.
4. `vow:AE` — 148 pairs (END 27, INNER 121). Words: can't, candy, have, catch, trapping, back, kodak, had.
5. `vow:IY` — 138 pairs (END 17, INNER 121). Words: even, free, keep, shawty, see, streets, field, real.
6. `vow:IH` — 134 pairs (END 5, INNER 129). Words: shit, bitch, israel, think, bitches, lil, prison, still.
7. `vow:EH` — 92 pairs (END 9, INNER 83). Words: fresh, swear, felon, legend, detector, level, remember, never.
8. `vow:OW` — 91 pairs (END 2, INNER 89). Words: no, don't, going, know, blow, go, gold, loaded.
9. `vow:EY` — 78 pairs (END 3, INNER 75). Words: ain't, baby, k, came, say, chains, play, racin.
10. `slant:AA:stop` — 54 pairs (END 1, INNER 53). Words: got, block, body, hot, top, want, chop, pop.
11. `slant:AH:nas-stop` — 47 pairs (END 5, INNER 42). Words: summer, fuck, one, fuckin, stuck, money, what, run.
12. `slant:AH:stop` — 45 pairs (END 5, INNER 40). Words: truck, fuck, front, trunk, judged, what, number, monkey.
13. `slant:IY:nas-stop` — 38 pairs (END 6, INNER 32). Words: keep, tryna, feet, lean, betweeen, cheaper, sleepin, creep.
14. `vow:AO` — 38 pairs (END 8, INNER 30). Words: all, talk, jaw, warrants, forest, taurus, pawns, foreign.
15. `slant:AY:nas-stop` — 35 pairs (END 6, INNER 29). Words: like, fine, time, prime, alright, white, side, might.
16. `vow:UW` — 35 pairs (END 11, INNER 24). Words: sue, new, two, glue, soup, shoot, fruity, jewish.
17. `slant:IH:liq-stop` — 34 pairs (END 10, INNER 24). Words: shit, lil, crib, still, bill, pill, 'til, hit.
18. `slant:IH:sib-stop` — 33 pairs (END 6, INNER 27). Words: bitch, shit, niggas, nigga, crib, rich, chopstick, city.
19. `slant:AA:nas-stop` — 32 pairs (END 0, INNER 32). Words: haan, got, wanna, mama, drop, hot, caught, bottom.
20. `slant:IH:stop` — 29 pairs (END 0, INNER 29). Words: nigga, crib, hit, shit, liquor, chopstick, city, think.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 22 pair sides, mostly spelling via spelling phonetic key, often with keep (13)
- nigga — 20 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- shawty — 17 pair sides, mostly vowel via spelling phonetic key, often with body (4)
- ima — 11 pair sides, mostly spelling via spelling phonetic key, often with bitch (3)
- henny — 10 pair sides, mostly spelling via spelling phonetic key, often with hemi (2)
- gon — 9 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- chinx — 6 pair sides, mostly vowel via spelling phonetic key, often with still (2)
- toolyd — 6 pair sides, mostly vowel via vault phonetic_class, often with nigga (1)
- dually — 6 pair sides, mostly vowel via spelling phonetic key, often with monkey (3)
- tunk — 6 pair sides, mostly spelling via spelling phonetic key, often with junk (1)
- fam — 6 pair sides, mostly vowel via vault phonetic_class, often with magic (1)
- hunnid — 6 pair sides, mostly spelling via spelling phonetic key, often with front (3)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- kinte — 5 pair sides, mostly spelling via spelling phonetic key, often with cant (2)
- mup — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- enny — 5 pair sides, mostly spelling via spelling phonetic key, often with henny (2)
- hemi — 5 pair sides, mostly spelling via spelling phonetic key, often with remy (2)
- lambo — 5 pair sides, mostly vowel via vault phonetic_class, often with rambo (2)
- iley — 5 pair sides, mostly spelling via spelling phonetic key, often with miley (2)
- sprewell — 5 pair sides, mostly vowel via spelling phonetic key, often with fresh (1)
- ilin — 4 pair sides, mostly vowel via spelling phonetic key, often with fish (1)
- jeezy — 4 pair sides, mostly vowel via spelling phonetic key, often with keep (1)
- tooly — 4 pair sides, mostly vowel via spelling phonetic key, often with monkey (2)
- wap — 4 pair sides, mostly spelling via spelling phonetic key, often with had (2)
- coled — 4 pair sides, mostly spelling via spelling phonetic key, often with polar (1)
- spikely — 4 pair sides, mostly vowel via spelling phonetic key, often with baby (2)
- bezel — 3 pair sides, mostly vowel via spelling phonetic key, often with stretcher (1)
- kunta — 3 pair sides, mostly spelling via spelling phonetic key, often with cant (2)
- crippin — 3 pair sides, mostly spelling via spelling phonetic key, often with stickin (1)
- vevo — 3 pair sides, mostly vowel via spelling phonetic key, often with video (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| French Montana | Double G | 31 | 27 | 192 | loose |
| French Montana | I Can’t Lie | 36 | 38 | 250 | loose |
| French Montana | I Can’t Lie (Radio Edit) | 13 | 12 | 62 | loose |
| French Montana | Letter After F (Stuck In The Jungle Demo) | 34 | 25 | 71 | loose |
| French Montana | Lifestyle | 34 | 20 | 157 | loose |
| French Montana | LockJaw (Clue Radio Remix) | 33 | 48 | 222 | loose |
| French Montana | Lockjaw | 39 | 25 | 207 | loose |
| French Montana | Lockjaw (Remix) | 25 | 14 | 156 | loose |
| French Montana | Miley Cyrus | 50 | 24 | 139 | loose |
| French Montana | Mopstick | 45 | 44 | 294 | loose |
| French Montana | Stuck in the Jungle | 26 | 33 | 280 | loose |
| French Montana | Stuck in the Jungle (Original) | 12 | 11 | 34 | loose |
| French Montana | Wake Up | 54 | 66 | 198 | loose |
