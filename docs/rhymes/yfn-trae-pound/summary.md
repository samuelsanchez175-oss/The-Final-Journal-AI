# YFN Trae Pound rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: YFN Trae Pound
- Songs: 3
- Bars kept (YFN Trae Pound lyric lines): 125
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: YFN Trae Pound.
- Credit strings: YFN Trae Pound.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 651
- REPEAT pairs, recorded separately: 89
- END rhymes: 174
- INNER rhymes: 477

By match:

- PERFECT: 79 (END 23, INNER 56)
- SLANT: 319 (END 81, INNER 238)
- ASSONANCE: 248 (END 69, INNER 179)
- MULTI: 5 (END 1, INNER 4)

By confidence:

- HIGH: 80
- MED: 533
- LOW: 38

## Core

- Core Y: 638
- Core N among rhyme pairs: 13

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 368 (56.5%)
- vowel: 248 (38.1%)
- spelling: 30 (4.6%)
- multi: 5 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 80 pairs (END 20, INNER 60). Words: know, no, go, told, don't, soldier, lower, whole.
2. `vow:IY` — 32 pairs (END 13, INNER 19). Words: keep, probably, keepin, eating, c, feeding, g, even.
3. `slant:AH:stop` — 29 pairs (END 10, INNER 19). Words: fuck, truck, nemon, tucked, bust, blood, club, busted.
4. `vow:AH` — 29 pairs (END 17, INNER 12). Words: some, blunt, month, button, busted, love, bust, dirtied.
5. `slant:AA:stop` — 27 pairs (END 0, INNER 27). Words: got, gotta, lot, pocket, want, start, rob, somebody.
6. `slant:OW:stop` — 26 pairs (END 13, INNER 13). Words: soda, odor, choker, minnesota, load, sober, slowed, hold.
7. `vow:AA` — 20 pairs (END 0, INNER 20). Words: got, hard, partner, narcotics, cause, opp, rollin, gotta.
8. `vow:IH` — 20 pairs (END 13, INNER 7). Words: sticks, shit, wrist, six, lil, kicks, drippin, lit.
9. `vow:EY` — 19 pairs (END 0, INNER 19). Words: ain't, plate, wavin, gave, changed, came, same, play.
10. `slant:IH:stop` — 17 pairs (END 12, INNER 5). Words: shit, vick, lick, lit, nick, dick, kick, nigga.
11. `slant:IY:nas-stop` — 15 pairs (END 6, INNER 9). Words: keep, keepin, demeanor, deeper, seen, beat, need, nina.
12. `slant:IH:liq-stop` — 14 pairs (END 0, INNER 14). Words: lil, shit, lit, lick, nick, dick.
13. `slant:AH:sib-stop` — 13 pairs (END 7, INNER 6). Words: judge, much, blood, club, fuck, tub, blunt, month.
14. `vow:AE` — 13 pairs (END 1, INNER 12). Words: dopeboy, jacket's, ankles, bag, family, act, ballin, pass.
15. `slant:AH:nas-stop` — 12 pairs (END 0, INNER 12). Words: done, some, money, what, nut, blood, club, mud.
16. `slant:IH:sib-stop` — 12 pairs (END 10, INNER 2). Words: hits, dick, shit, lit, sticks, six, bitch, lick.
17. `slant:EH:liq-stop` — 11 pairs (END 2, INNER 9). Words: better, where, get, hell, smell, set, wet, check.
18. `slant:IY:stop` — 11 pairs (END 3, INNER 8). Words: eat, deep, deeper, keep, street, sleep, beat, compete.
19. `slant:EH:nas-stop` — 10 pairs (END 0, INNER 10). Words: many, get, when, went, check, better.
20. `slant:EH:stop` — 10 pairs (END 3, INNER 7). Words: get, set, tec, rest, wet, went, best, better.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- choker — 13 pair sides, mostly spelling via spelling phonetic key, often with folder (2)
- nemon — 8 pair sides, mostly cmu via vault phonetic_class, often with fuck (4)
- gon — 7 pair sides, mostly spelling via spelling phonetic key, often with broke (2)
- dirtied — 6 pair sides, mostly cmu via vault phonetic_class, often with cup (1)
- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- etible — 4 pair sides, mostly vowel via spelling phonetic key, often with there (1)
- dopeboy — 3 pair sides, mostly vowel via vault phonetic_class, often with family (1)
- shawty — 3 pair sides, mostly vowel via spelling phonetic key, often with call (1)
- frolled — 2 pair sides, mostly spelling via spelling phonetic key, often with gold (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with kick (2)
- chanell — 2 pair sides, mostly spelling via spelling phonetic key, often with hell (1)
- misterio — 2 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- brodies — 1 pair sides, mostly multi via spelling phonetic key, often with rollies (1)
- rollies — 1 pair sides, mostly multi via spelling phonetic key, often with brodies (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with all (1)
- petistal — 1 pair sides, mostly spelling via spelling phonetic key, often with etible (1)
- burberry — 1 pair sides, mostly vowel via spelling phonetic key, often with shawty (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| YFN Trae Pound | Ammunition 2 | 55 | 85 | 191 | loose |
| YFN Trae Pound | Dopeboy | 39 | 45 | 160 | loose |
| YFN Trae Pound | Keeper | 31 | 44 | 126 | loose |
