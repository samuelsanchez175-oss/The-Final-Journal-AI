# Takeoff rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Takeoff
- Songs: 34
- Bars kept (Takeoff lyric lines): 1220
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 4
- Canonical name: Takeoff.
- Credit strings: Takeoff.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 7138
- REPEAT pairs, recorded separately: 757
- END rhymes: 1556
- INNER rhymes: 5582

By match:

- PERFECT: 627 (END 195, INNER 432)
- SLANT: 3030 (END 599, INNER 2431)
- ASSONANCE: 3408 (END 746, INNER 2662)
- MULTI: 73 (END 16, INNER 57)

By confidence:

- HIGH: 606
- MED: 5747
- LOW: 785

## Core

- Core Y: 6930
- Core N among rhyme pairs: 208

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 2992 (41.9%)
- vowel: 3408 (47.7%)
- spelling: 665 (9.3%)
- multi: 73 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 34 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 665 pairs (END 106, INNER 559). Words: bitch, wrist, bitches, shit, him, think, kitchen, still.
2. `vow:EY` — 598 pairs (END 216, INNER 382). Words: ain't, way, make, say, faces, face, day, take.
3. `vow:EH` — 377 pairs (END 63, INNER 314). Words: remember, get, when, tell, bedre, better, special, eller.
4. `vow:AE` — 328 pairs (END 55, INNER 273). Words: can't, back, bag, cameras, fast, last, havin, trap.
5. `vow:OW` — 297 pairs (END 53, INNER 244). Words: know, don't, no, go, motion, told, over, open.
6. `vow:AA` — 282 pairs (END 60, INNER 222). Words: got, talkin, want, watch, wanna, stars, solid, stop.
7. `vow:AH` — 216 pairs (END 38, INNER 178). Words: double, hundred, money, somethin, fuck, one, what, cup.
8. `slant:AA:stop` — 189 pairs (END 29, INNER 160). Words: got, gotta, want, not, patek, pot, top, glock.
9. `vow:AY` — 176 pairs (END 30, INNER 146). Words: like, diamonds, by, find, high, time, try, dimes.
10. `slant:IH:stop` — 155 pairs (END 16, INNER 139). Words: nigga, shit, hit, ikke, big, stick, city, flippa.
11. `vow:IY` — 155 pairs (END 35, INNER 120). Words: see, three, these, free, seen, need, real, seats.
12. `slant:EH:nas-stop` — 151 pairs (END 3, INNER 148). Words: jeg, en, when, med, m, ven, get, det.
13. `slant:EH:stop` — 131 pairs (END 10, INNER 121). Words: jeg, get, med, twenty, det, ved, remember, let.
14. `vow:UW` — 123 pairs (END 55, INNER 68). Words: two, booster, blue, true, crew, move, units, troops.
15. `slant:IH:sib-stop` — 101 pairs (END 11, INNER 90). Words: bitch, nigga, niggas, shit, which, rich, big, brick.
16. `slant:IH:nas-stop` — 83 pairs (END 0, INNER 83). Words: i'ma, hit, him, whip, big, miney, ring, ting.
17. `slant:EY:nas-stop` — 78 pairs (END 9, INNER 69). Words: make, ain't, came, name, take, same, baby, main.
18. `vow:AO` — 77 pairs (END 13, INNER 64). Words: all, foreign, jaw, talking, takeoff, offs, morning, ordered.
19. `slant:EY:sib` — 71 pairs (END 53, INNER 18). Words: faces, phases, ages, papers, chains, face, wraith, cases.
20. `cmu:IY` — 67 pairs (END 2, INNER 65). Words: p, de, d, t, v, bt, b, e.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- jeg — 101 pair sides, mostly spelling via spelling phonetic key, often with en (14)
- nigga — 86 pair sides, mostly spelling via spelling phonetic key, often with niggas (12)
- ima — 58 pair sides, mostly spelling via spelling phonetic key, often with bitch (5)
- niggas — 38 pair sides, mostly spelling via spelling phonetic key, often with nigga (12)
- ikke — 37 pair sides, mostly vowel via spelling phonetic key, often with disse (7)
- det — 32 pair sides, mostly spelling via spelling phonetic key, often with jeg (8)
- gon — 26 pair sides, mostly spelling via spelling phonetic key, often with dont (8)
- bedre — 23 pair sides, mostly vowel via spelling phonetic key, often with speciel (4)
- wraith — 19 pair sides, mostly spelling via spelling phonetic key, often with face (2)
- ven — 19 pair sides, mostly spelling via spelling phonetic key, often with jeg (6)
- bando — 18 pair sides, mostly vowel via spelling phonetic key, often with cant (2)
- hende — 16 pair sides, mostly spelling via spelling phonetic key, often with en (3)
- disse — 16 pair sides, mostly vowel via spelling phonetic key, often with ikke (7)
- lige — 16 pair sides, mostly spelling via spelling phonetic key, often with ikke (3)
- flippa — 14 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- miney — 12 pair sides, mostly spelling via spelling phonetic key, often with which (3)
- penge — 12 pair sides, mostly spelling via spelling phonetic key, often with pengene (2)
- kket — 12 pair sides, mostly spelling via spelling phonetic key, often with jeg (2)
- ttet — 12 pair sides, mostly spelling via spelling phonetic key, often with en (3)
- pengene — 11 pair sides, mostly spelling via spelling phonetic key, often with penge (2)
- ved — 11 pair sides, mostly spelling via spelling phonetic key, often with jeg (5)
- slikke — 11 pair sides, mostly vowel via spelling phonetic key, often with ikke (4)
- migos — 10 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- migo — 10 pair sides, mostly vowel via spelling phonetic key, often with know (3)
- fik — 10 pair sides, mostly spelling via spelling phonetic key, often with til (3)
- gik — 9 pair sides, mostly spelling via spelling phonetic key, often with ting (2)
- nen — 9 pair sides, mostly spelling via spelling phonetic key, often with med (3)
- ndre — 9 pair sides, mostly vowel via spelling phonetic key, often with ende (1)
- tryna — 8 pair sides, mostly spelling via spelling phonetic key, often with these (2)
- vejret — 8 pair sides, mostly vowel via spelling phonetic key, often with bedre (3)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Takeoff | Action Figure* | 12 | 6 | 42 | loose |
| Takeoff | Astronaut* | 11 | 17 | 52 | loose |
| Takeoff | Bruce Wayne (Outro) | 44 | 49 | 183 | loose |
| Takeoff | Casper | 51 | 72 | 161 | loose |
| Takeoff | Crypto | 49 | 52 | 211 | loose |
| Takeoff | Dirty | 26 | 4 | 170 | loose |
| Takeoff | Freestyle | 17 | 20 | 79 | loose |
| Takeoff | Glock Out* | 3 | 1 | 4 | loose |
| Takeoff | I Remember | 25 | 42 | 190 | loose |
| Takeoff | Ice* | 18 | 10 | 134 | loose |
| Takeoff | Infatuation | 37 | 50 | 206 | loose |
| Takeoff | Insomnia | 61 | 66 | 153 | loose |
| Takeoff | Intro (Takeoff Shooter) | 29 | 37 | 151 | loose |
| Takeoff | Intruder | 31 | 14 | 98 | loose |
| Takeoff | Last Memory | 48 | 92 | 198 | loose |
| Takeoff | Last memory Danish version | 57 | 27 | 625 | loose |
| Takeoff | Lead the Wave | 58 | 92 | 182 | loose |
| Takeoff | Let Me Chill Out | 45 | 75 | 133 | loose |
| Takeoff | Martian (Intro) | 56 | 64 | 234 | loose |
| Takeoff | Migo Flippin | 46 | 86 | 314 | loose |
| Takeoff | Nah For Real* | 30 | 53 | 65 | loose |
| Takeoff | None to Me | 33 | 14 | 154 | loose |
| Takeoff | Put That Shit On* | 3 | 1 | 4 | loose |
| Takeoff | Pyrex Pot | 55 | 44 | 211 | loose |
| Takeoff | Reveal Em* | 17 | 16 | 39 | loose |
| Takeoff | Run In Place (Can’t See The Clock) | 36 | 59 | 177 | loose |
| Takeoff | She Gon Wink | 47 | 95 | 118 | loose |
| Takeoff | Soul Plane | 56 | 111 | 276 | loose |
| Takeoff | Take LA | 29 | 42 | 107 | loose |
| Takeoff | Takeoff | 43 | 37 | 115 | loose |
| Takeoff | Trap-A-Holics | 40 | 17 | 244 | loose |
| Takeoff | Unleashed | 37 | 46 | 161 | loose |
| Takeoff | Vacation | 31 | 79 | 226 | loose |
| Takeoff | What Move Would U Make | 39 | 66 | 165 | loose |
