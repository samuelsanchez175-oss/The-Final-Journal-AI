# 2Pac rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 2Pac
- Songs: 1
- Bars kept (2Pac lyric lines): 250
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: 2Pac.
- Credit strings: 2Pac.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1945
- REPEAT pairs, recorded separately: 125
- END rhymes: 251
- INNER rhymes: 1694

By match:

- PERFECT: 171 (END 35, INNER 136)
- SLANT: 843 (END 109, INNER 734)
- ASSONANCE: 878 (END 98, INNER 780)
- MULTI: 53 (END 9, INNER 44)

By confidence:

- HIGH: 209
- MED: 1634
- LOW: 102

## Core

- Core Y: 1924
- Core N among rhyme pairs: 21

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 925 (47.6%)
- vowel: 878 (45.1%)
- spelling: 89 (4.6%)
- multi: 53 (2.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 153 pairs (END 19, INNER 134). Words: shit, givin, dick, think, six, hits, bitch, big.
2. `vow:EH` — 107 pairs (END 8, INNER 99). Words: gettin, when, n, get, respect, let's, let, melanin.
3. `vow:AA` — 101 pairs (END 16, INNER 85). Words: got, dada, rottweilers, cause, boss, want, pop, robbery.
4. `vow:EY` — 94 pairs (END 4, INNER 90). Words: say, day, face, way, make, take, layer, ain't.
5. `vow:AH` — 93 pairs (END 5, INNER 88). Words: fuckin, motherfuckers, fuck, love, money, hundred, guns, one.
6. `vow:AY` — 93 pairs (END 11, INNER 82). Words: life, high, die, like, playa, live, why, time.
7. `vow:AE` — 77 pairs (END 9, INNER 68). Words: gangsta, fast, cash, have, ballin, can't, bad, cappin.
8. `vow:IY` — 71 pairs (END 17, INNER 54). Words: see, g, tv, leeches, peaches, green, even, jesus.
9. `vow:OW` — 66 pairs (END 3, INNER 63). Words: no, don't, hold, won't, goes, know, behold, notes.
10. `slant:IH:stop` — 63 pairs (END 11, INNER 52). Words: shit, nigga, dick, kid, nip, crip, big, trip.
11. `slant:IH:sib-stop` — 36 pairs (END 9, INNER 27). Words: bitch, nigga, niggas, shit, dick, rich, hits, hit.
12. `slant:AE:stop` — 32 pairs (END 5, INNER 27). Words: back, fat, strapped, fact, smack, bag, act, jab.
13. `cmu:OW` — 29 pairs (END 7, INNER 22). Words: dough, know, no, ho, slow, go, grow, low.
14. `slant:EH:nas-stop` — 29 pairs (END 0, INNER 29). Words: get, n, when, gettin, let, spend, ghetto, send.
15. `slant:AA:liq-stop` — 27 pairs (END 1, INNER 26). Words: drop, pop, properly, sloppily, hop, collar, dollar, monopoly.
16. `slant:AA:stop` — 26 pairs (END 7, INNER 19). Words: got, god, want, gotta, top, rock, bobby, party.
17. `slant:AY:fric-stop` — 26 pairs (END 1, INNER 25). Words: life, like, live, ride, side, tonight, five, might.
18. `slant:AA:sib-stop` — 21 pairs (END 2, INNER 19). Words: got, cause, boss, god, top, floss, macho, father.
19. `slant:AA:nas-stop` — 20 pairs (END 0, INNER 20). Words: wanna, got, drop, don, hop, coppin, stoppin, pop.
20. `slant:AH:nas` — 20 pairs (END 1, INNER 19). Words: one, some, come, dumb, young, money, bunny, sunny.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 23 pair sides, mostly spelling via spelling phonetic key, often with niggas (8)
- niggas — 18 pair sides, mostly spelling via spelling phonetic key, often with nigga (8)
- clit — 9 pair sides, mostly spelling via spelling phonetic key, often with dick (2)
- gyal — 9 pair sides, mostly spelling via spelling phonetic key, often with eat (1)
- hetero — 9 pair sides, mostly spelling via spelling phonetic key, often with follow (1)
- naythin — 8 pair sides, mostly vowel via spelling phonetic key, often with waitin (1)
- lif — 6 pair sides, mostly spelling via spelling phonetic key, often with until (2)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with creepy (1)
- tokes — 4 pair sides, mostly spelling via spelling phonetic key, often with notes (1)
- cony — 4 pair sides, mostly multi via spelling phonetic key, often with matrimony (2)
- hyperventilatin — 3 pair sides, mostly multi via spelling phonetic key, often with perculatin (2)
- spliff — 3 pair sides, mostly vowel via spelling phonetic key, often with shit (1)
- perculatin — 3 pair sides, mostly multi via spelling phonetic key, often with hyperventilatin (2)
- motherfuck — 2 pair sides, mostly spelling via spelling phonetic key, often with fuck (1)
- lambo — 2 pair sides, mostly spelling via spelling phonetic key, often with gangster (1)
- renll — 2 pair sides, mostly vowel via spelling phonetic key, often with gets (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with big (1)
- phonies — 1 pair sides, mostly multi via spelling phonetic key, often with homies (1)
- homies — 1 pair sides, mostly multi via spelling phonetic key, often with phonies (1)
- humpin — 1 pair sides, mostly spelling via spelling phonetic key, often with jumpin (1)
- rari — 1 pair sides, mostly spelling via spelling phonetic key, often with had (1)
- gangbang — 1 pair sides, mostly vowel via spelling phonetic key, often with half (1)
- niggaz4life — 1 pair sides, mostly vowel via spelling phonetic key, often with bitches (1)
- thatll — 1 pair sides, mostly vowel via spelling phonetic key, often with crack (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with smoke (1)
- hussle — 1 pair sides, mostly vowel via spelling phonetic key, often with hundred (1)
- ars — 1 pair sides, mostly spelling via spelling phonetic key, often with promise (1)
- bustas — 1 pair sides, mostly vowel via spelling phonetic key, often with what (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 2Pac | Write This Down (ft. Biggie, DMX, Eazy E, Ice Cube, Dr Dre, NWA, Nipsey, Snoop Dogg) | 250 | 251 | 1694 | loose |
