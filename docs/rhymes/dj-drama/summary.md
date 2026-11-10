# DJ Drama rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Drama
- Songs: 3
- Bars kept (DJ Drama lyric lines): 178
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DJ Drama.
- Credit strings: DJ Drama.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1079
- REPEAT pairs, recorded separately: 115
- END rhymes: 170
- INNER rhymes: 909

By match:

- PERFECT: 60 (END 10, INNER 50)
- SLANT: 457 (END 74, INNER 383)
- ASSONANCE: 545 (END 78, INNER 467)
- MULTI: 17 (END 8, INNER 9)

By confidence:

- HIGH: 70
- MED: 952
- LOW: 57

## Core

- Core Y: 1072
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 463 (42.9%)
- vowel: 545 (50.5%)
- spelling: 54 (5.0%)
- multi: 17 (1.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 102 pairs (END 34, INNER 68). Words: camera, pans, romantic, dancer, dancing, handsome, sac, handle.
2. `vow:IH` — 78 pairs (END 8, INNER 70). Words: shit, little, still, bitches, innocence, system, bitch, since.
3. `vow:AA` — 68 pairs (END 2, INNER 66). Words: want, got, hardest, hardly, block, nothin, start, dropped.
4. `vow:OW` — 51 pairs (END 6, INNER 45). Words: know, only, don't, no, hoes, go, told, old.
5. `vow:EH` — 48 pairs (END 4, INNER 44). Words: remember, mention, benefits, tell, extended, seven, flexin, said.
6. `vow:EY` — 45 pairs (END 9, INNER 36). Words: make, tasty, way, ain't, change, davidson, eight, greats.
7. `vow:AH` — 39 pairs (END 1, INNER 38). Words: double, cul, money, cousin, couple, comin, fucked, some.
8. `slant:AA:stop` — 31 pairs (END 5, INNER 26). Words: got, top, lot, block, want, robbed, pop, not.
9. `vow:AO` — 27 pairs (END 0, INNER 27). Words: short, all, forward, call, lost, pork, cross, small.
10. `slant:IH:stop` — 24 pairs (END 4, INNER 20). Words: shit, nigga, dick, jiggy, city, lick, thicker, quicker.
11. `slant:AH:nas` — 23 pairs (END 4, INNER 19). Words: money, runnin, comin, bunkin, run, come, some, london.
12. `slant:AE:nas-stop` — 22 pairs (END 1, INNER 21). Words: had, ran, back, can, camera, makin, hand, sack.
13. `vow:AY` — 21 pairs (END 3, INNER 18). Words: like, mind, time, designs, lines, dime, while, signs.
14. `slant:AE:stop` — 20 pairs (END 4, INNER 16). Words: daddy, back, had, trap, matter, sac, planned, candid.
15. `vow:UW` — 20 pairs (END 4, INNER 16). Words: new, shootin, retribution, coolin, lucci, su, super, true.
16. `vow:IY` — 19 pairs (END 1, INNER 18). Words: de, sleep, screaming, screamin, jiggy, eat, see, leak.
17. `cmu:OW` — 14 pairs (END 1, INNER 13). Words: go, no, know, low, slow, bro, o, flow.
18. `slant:EH:nas-stop` — 14 pairs (END 1, INNER 13). Words: let, when, gettin, get, emmy, jet, ten, again.
19. `slant:IH:sib-stop` — 14 pairs (END 4, INNER 10). Words: winter, shit, nigga, niggas, dizzy, since, minute, bitch.
20. `slant:EY:sib-stop` — 13 pairs (END 7, INNER 6). Words: crazy, baby, face, case, hate, greats, make, paper.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- jojo — 8 pair sides, mostly spelling via spelling phonetic key, often with mojo (2)
- jiggy — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- bunkin — 5 pair sides, mostly spelling via spelling phonetic key, often with runnin (4)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with keep (1)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with give (2)
- hemi — 3 pair sides, mostly spelling via spelling phonetic key, often with semis (1)
- jit — 3 pair sides, mostly spelling via spelling phonetic key, often with dizzy (1)
- pov — 3 pair sides, mostly spelling via spelling phonetic key, often with phone (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with phone (1)
- hemis — 2 pair sides, mostly spelling via spelling phonetic key, often with hemi (1)
- nem — 2 pair sides, mostly spelling via spelling phonetic key, often with there (1)
- guap — 2 pair sides, mostly spelling via spelling phonetic key, often with what (1)
- def — 2 pair sides, mostly spelling via spelling phonetic key, often with death (1)
- titties — 1 pair sides, mostly spelling via spelling phonetic key, often with picture (1)
- benjamins — 1 pair sides, mostly spelling via spelling phonetic key, often with benefits (1)
- mozzy — 1 pair sides, mostly vowel via spelling phonetic key, often with vory (1)
- vory — 1 pair sides, mostly vowel via spelling phonetic key, often with mozzy (1)
- bubblegum — 1 pair sides, mostly vowel via spelling phonetic key, often with fuck (1)
- ganja — 1 pair sides, mostly spelling via spelling phonetic key, often with cant (1)
- slangin — 1 pair sides, mostly spelling via spelling phonetic key, often with standin (1)
- geeked — 1 pair sides, mostly spelling via spelling phonetic key, often with sleep (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Drama | Been A While | 42 | 32 | 262 | loose |
| DJ Drama | Big Money (C4 Remix) | 72 | 60 | 368 | loose |
| DJ Drama | Camera | 64 | 78 | 279 | loose |
