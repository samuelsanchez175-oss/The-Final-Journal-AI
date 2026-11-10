# Boosie Badazz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Boosie Badazz
- Songs: 3
- Bars kept (Boosie Badazz lyric lines): 213
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Boosie Badazz.
- Credit strings: Boosie Badazz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1637
- REPEAT pairs, recorded separately: 203
- END rhymes: 181
- INNER rhymes: 1456

By match:

- PERFECT: 122 (END 32, INNER 90)
- SLANT: 714 (END 88, INNER 626)
- ASSONANCE: 796 (END 60, INNER 736)
- MULTI: 5 (END 1, INNER 4)

By confidence:

- HIGH: 110
- MED: 1388
- LOW: 139

## Core

- Core Y: 1617
- Core N among rhyme pairs: 20

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 697 (42.6%)
- vowel: 796 (48.6%)
- spelling: 139 (8.5%)
- multi: 5 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 183 pairs (END 6, INNER 177). Words: christmas, him, shit, nigga, bitch, kids, killed, killin.
2. `vow:EY` — 123 pairs (END 7, INNER 116). Words: ain't, today, make, play, take, day, away, way.
3. `vow:EH` — 106 pairs (END 12, INNER 94). Words: presents, blessin, hectic, spent, friends, where, twelve, end.
4. `vow:OW` — 83 pairs (END 4, INNER 79). Words: don't, no, know, go, whole, ropes, total, loaded.
5. `vow:AA` — 75 pairs (END 14, INNER 61). Words: got, partners, rocket, garbage, honest, nothin, talkin, top.
6. `vow:AH` — 67 pairs (END 7, INNER 60). Words: wonder, fuck, mumblin, bust, what, runnin, comin, strugglin.
7. `slant:IH:stop` — 45 pairs (END 11, INNER 34). Words: nigga, shit, brick, sick, hit, hitter, flip, crib.
8. `vow:IY` — 44 pairs (END 4, INNER 40). Words: even, these, see, thirty, feelin, ree's, feelings, real.
9. `slant:AA:stop` — 43 pairs (END 6, INNER 37). Words: got, rocket, gotta, chopper, squad, cop, god, everybody.
10. `slant:IH:nas-stop` — 34 pairs (END 2, INNER 32). Words: shit, him, kin, i'ma, everything, bring, hit, sin.
11. `slant:IH:sib-stop` — 31 pairs (END 1, INNER 30). Words: bitch, nigga, niggas, shit, spit, stick, diss, rich.
12. `vow:AW` — 31 pairs (END 3, INNER 28). Words: how, 'bout, now, bounds, house, round, down, about.
13. `vow:AE` — 29 pairs (END 0, INNER 29). Words: had, gang, lavish, damn, atlanta, santa, raps, masks.
14. `vow:AY` — 29 pairs (END 2, INNER 27). Words: die, like, fire, mind, fly, tonight, while, slide.
15. `slant:OW:nas-stop` — 25 pairs (END 1, INNER 24). Words: gon, don't, dope, won't, coke, smoke, homie, road.
16. `slant:EH:nas-stop` — 20 pairs (END 0, INNER 20). Words: get, many, again, when, red, ten, gettin, vent.
17. `cmu:EY` — 18 pairs (END 9, INNER 9). Words: today, play, say, hideaway, highway, pay, away.
18. `slant:EH:liq-stop` — 17 pairs (END 4, INNER 13). Words: get, merry, there, where, nowhere, care, check, bed.
19. `slant:AH:nas-stop` — 15 pairs (END 0, INNER 15). Words: fuck, what, money, wonder, come, runnin, some, young.
20. `slant:AY:stop` — 15 pairs (END 5, INNER 10). Words: like, might, side, stepchild, baptized, candlelight, outside, tonight.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 57 pair sides, mostly spelling via spelling phonetic key, often with christmas (13)
- gon — 29 pair sides, mostly spelling via spelling phonetic key, often with dont (10)
- niggas — 16 pair sides, mostly spelling via spelling phonetic key, often with nigga (11)
- dyin — 16 pair sides, mostly spelling via spelling phonetic key, often with seein (4)
- tryna — 13 pair sides, mostly spelling via spelling phonetic key, often with these (2)
- boosie — 6 pair sides, mostly spelling via spelling phonetic key, often with shoes (2)
- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with really (1)
- homie — 4 pair sides, mostly spelling via spelling phonetic key, often with homies (1)
- dawg — 4 pair sides, mostly spelling via spelling phonetic key, often with more (2)
- finna — 4 pair sides, mostly spelling via spelling phonetic key, often with thinkin (2)
- jojo — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- glocks — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- funkin — 2 pair sides, mostly spelling via spelling phonetic key, often with cuffin (1)
- mafioso — 2 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- homies — 1 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- nog — 1 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- motherfuck — 1 pair sides, mostly spelling via spelling phonetic key, often with fuck (1)
- usin — 1 pair sides, mostly spelling via spelling phonetic key, often with done (1)
- rocketman — 1 pair sides, mostly spelling via spelling phonetic key, often with can (1)
- homeboy — 1 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- cuffin — 1 pair sides, mostly spelling via spelling phonetic key, often with funkin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Boosie Badazz | Christmas List | 48 | 37 | 310 | loose |
| Boosie Badazz | Creep | 56 | 47 | 383 | loose |
| Boosie Badazz | Rocketman (Remix) | 109 | 97 | 763 | loose |
