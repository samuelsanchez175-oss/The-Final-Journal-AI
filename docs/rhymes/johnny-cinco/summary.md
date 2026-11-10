# Johnny Cinco rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Johnny Cinco
- Songs: 10
- Bars kept (Johnny Cinco lyric lines): 392
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Johnny Cinco.
- Credit strings: Johnny Cinco.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 2153
- REPEAT pairs, recorded separately: 421
- END rhymes: 426
- INNER rhymes: 1727

By match:

- PERFECT: 205 (END 57, INNER 148)
- SLANT: 1024 (END 150, INNER 874)
- ASSONANCE: 905 (END 215, INNER 690)
- MULTI: 19 (END 4, INNER 15)

By confidence:

- HIGH: 216
- MED: 1831
- LOW: 106

## Core

- Core Y: 2119
- Core N among rhyme pairs: 34

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1147 (53.3%)
- vowel: 905 (42.0%)
- spelling: 82 (3.8%)
- multi: 19 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 10 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 185 pairs (END 53, INNER 132). Words: way, ain't, day, make, came, fade, pray, pay.
2. `vow:AE` — 126 pairs (END 39, INNER 87). Words: trappin, happen, back, lavish, can't, had, mattress, average.
3. `vow:OW` — 118 pairs (END 43, INNER 75). Words: go, don't, hoes, know, hoe, no, road, goals.
4. `vow:EH` — 105 pairs (END 18, INNER 87). Words: get, never, when, send, went, checkers, paris, confidential.
5. `slant:AA:stop` — 102 pairs (END 3, INNER 99). Words: gotta, got, stop, want, not, start, drop, top.
6. `vow:IH` — 80 pairs (END 24, INNER 56). Words: bitch, filled, difference, drink, bitches, little, shit, wrist.
7. `vow:AA` — 79 pairs (END 6, INNER 73). Words: want, stop, top, bottom, started, got, da, john.
8. `vow:AY` — 71 pairs (END 13, INNER 58). Words: time, mind, buy, high, grind, might, like, prices.
9. `vow:AH` — 65 pairs (END 10, INNER 55). Words: money, hundreds, comin, love, front, hunnids, some, hustle.
10. `slant:AH:nas` — 48 pairs (END 1, INNER 47). Words: money, run, some, young, comin, done, come, running.
11. `slant:AE:stop` — 43 pairs (END 12, INNER 31). Words: back, dat, cracked, mad, had, stack, can't, factor.
12. `cmu:OW` — 41 pairs (END 14, INNER 27). Words: know, go, hoe, row, no, mo, low, foe.
13. `slant:EY:sib-stop` — 40 pairs (END 12, INNER 28). Words: days, race, fade, make, wraith, face, hate, case.
14. `slant:AY:nas-stop` — 39 pairs (END 11, INNER 28). Words: mind, grind, mine, like, time, line, wine, shine.
15. `slant:IH:sib-stop` — 39 pairs (END 12, INNER 27). Words: bitch, shit, niggas, nigga, fish, brick, wit, hit.
16. `slant:EH:stop` — 36 pairs (END 5, INNER 31). Words: better, best, jet, get, retrospect, went, bet, neck.
17. `slant:EH:sib-stop` — 30 pairs (END 8, INNER 22). Words: together, get, success, chess, better, checkers, dead, press.
18. `vow:IY` — 30 pairs (END 4, INNER 26). Words: see, week, feeling, even, g, keep, streets, lean.
19. `slant:IH:stop` — 28 pairs (END 5, INNER 23). Words: nigga, hit, shit, picked, brick, whip, trigger, wit.
20. `slant:AE:nas-stop` — 25 pairs (END 4, INNER 21). Words: back, man, thang, can, happen, happy, dat, damn.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 17 pair sides, mostly spelling via spelling phonetic key, often with lean (3)
- nigga — 15 pair sides, mostly spelling via spelling phonetic key, often with niggas (5)
- wraith — 8 pair sides, mostly spelling via spelling phonetic key, often with fade (2)
- mutombo — 8 pair sides, mostly vowel via spelling phonetic key, often with mo (2)
- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with fridge (2)
- niggas — 7 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)
- popi — 6 pair sides, mostly spelling via spelling phonetic key, often with whole (1)
- dont — 6 pair sides, mostly vowel via spelling phonetic key, often with know (3)
- hunnids — 5 pair sides, mostly vowel via spelling phonetic key, often with comin (4)
- bezels — 5 pair sides, mostly vowel via spelling phonetic key, often with together (3)
- arouser — 5 pair sides, mostly vowel via spelling phonetic key, often with trapper (1)
- 2chainz — 3 pair sides, mostly spelling via spelling phonetic key, often with chains (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- cuffing — 2 pair sides, mostly spelling via spelling phonetic key, often with building (1)
- hunned — 2 pair sides, mostly vowel via spelling phonetic key, often with plugged (1)
- hunneds — 2 pair sides, mostly spelling via spelling phonetic key, often with hunned (1)
- opps — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (2)
- cappers — 2 pair sides, mostly vowel via spelling phonetic key, often with trapper (1)
- papi — 2 pair sides, mostly vowel via spelling phonetic key, often with grabbing (1)
- dem — 1 pair sides, mostly spelling via spelling phonetic key, often with many (1)
- imma — 1 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- lambo — 1 pair sides, mostly vowel via spelling phonetic key, often with hoe (1)
- maybach — 1 pair sides, mostly spelling via spelling phonetic key, often with mercedes (1)
- badder — 1 pair sides, mostly spelling via spelling phonetic key, often with pradas (1)
- pradas — 1 pair sides, mostly spelling via spelling phonetic key, often with badder (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Johnny Cinco | Do Better | 35 | 19 | 338 | loose |
| Johnny Cinco | Gotta Stop | 53 | 65 | 155 | loose |
| Johnny Cinco | Literally | 36 | 23 | 111 | loose |
| Johnny Cinco | Pourin Up | 41 | 91 | 269 | loose |
| Johnny Cinco | Some More | 36 | 29 | 107 | loose |
| Johnny Cinco | Talk | 44 | 29 | 223 | loose |
| Johnny Cinco | The Ghetto | 44 | 65 | 220 | loose |
| Johnny Cinco | They Know It | 40 | 28 | 108 | loose |
| Johnny Cinco | Trappin’ & Rappin | 37 | 59 | 90 | loose |
| Johnny Cinco | We Came A Long Way | 26 | 18 | 106 | loose |
