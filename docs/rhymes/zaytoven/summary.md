# Zaytoven rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Zaytoven
- Songs: 11
- Bars kept (Zaytoven lyric lines): 444
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Zaytoven.
- Credit strings: Zaytoven.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 3341
- REPEAT pairs, recorded separately: 706
- END rhymes: 512
- INNER rhymes: 2829

By match:

- PERFECT: 376 (END 87, INNER 289)
- SLANT: 1153 (END 185, INNER 968)
- ASSONANCE: 1770 (END 232, INNER 1538)
- MULTI: 42 (END 8, INNER 34)

By confidence:

- HIGH: 397
- MED: 2704
- LOW: 240

## Core

- Core Y: 3276
- Core N among rhyme pairs: 65

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1335 (40.0%)
- vowel: 1770 (53.0%)
- spelling: 194 (5.8%)
- multi: 42 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 11 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 589 pairs (END 35, INNER 554). Words: know, hope, don't, no, go, clothes, gold, blow.
2. `vow:IH` — 274 pairs (END 43, INNER 231). Words: shit, big, fifty, bitch, million, didn't, bitches, bricks.
3. `vow:AH` — 200 pairs (END 74, INNER 126). Words: bunch, what, hundred, fuck, comfortable, brother, money, hugs.
4. `vow:EY` — 184 pairs (END 29, INNER 155). Words: ain't, baby, day, play, say, stay, way, make.
5. `cmu:OW` — 163 pairs (END 33, INNER 130). Words: know, no, though, show, go, blow, po, co.
6. `vow:AA` — 113 pairs (END 12, INNER 101). Words: got, nothin, projects, party, pockets, started, la, rock.
7. `vow:AE` — 107 pairs (END 5, INNER 102). Words: man, fast, atlanta, bags, can't, gang, can, half.
8. `vow:IY` — 106 pairs (END 4, INNER 102). Words: shawty, see, even, people, leave, baby, here, thotty.
9. `vow:EH` — 94 pairs (END 17, INNER 77). Words: gettin, friends, already, swear, twelve, hell, next, schedule.
10. `slant:IH:stop` — 67 pairs (END 8, INNER 59). Words: nigga, shit, big, hit, city, crib, hid, dick.
11. `slant:IH:sib-stop` — 66 pairs (END 28, INNER 38). Words: bitch, shit, brick, bricks, kick, nigga, niggas, hit.
12. `slant:AH:nas-stop` — 59 pairs (END 5, INNER 54). Words: money, fuck, what, stunt, front, come, sunny, hummer.
13. `vow:AY` — 46 pairs (END 8, INNER 38). Words: like, high, why, drive, fly, by, ride, try.
14. `slant:OW:nas-stop` — 45 pairs (END 0, INNER 45). Words: gon, hope, blown, don't, dope, phone, zone, overcoat.
15. `slant:AH:nas` — 41 pairs (END 5, INNER 36). Words: money, some, dummy, run, young, come, summer, become.
16. `slant:AH:stop` — 40 pairs (END 10, INNER 30). Words: what, fuck, cut, stunt, tucked, trunk, truck, touched.
17. `slant:AA:stop` — 38 pairs (END 2, INNER 36). Words: got, drop, stop, gotta, robbed, god, hard, top.
18. `cmu:EY` — 34 pairs (END 10, INNER 24). Words: day, play, way, say, stay, 'k, holiday, yay.
19. `slant:AE:nas-stop` — 30 pairs (END 6, INNER 24). Words: man, can't, can, bad, passin, gang, back, japan.
20. `slant:EY:sib-stop` — 30 pairs (END 13, INNER 17). Words: face, baby, race, ain't, chains, relate, case, taste.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 42 pair sides, mostly spelling via spelling phonetic key, often with hope (33)
- nigga — 41 pair sides, mostly spelling via spelling phonetic key, often with shit (15)
- ima — 26 pair sides, mostly spelling via spelling phonetic key, often with bitch (6)
- shawty — 14 pair sides, mostly vowel via spelling phonetic key, often with money (4)
- tryna — 12 pair sides, mostly spelling via spelling phonetic key, often with ina (3)
- thotty — 8 pair sides, mostly vowel via spelling phonetic key, often with baby (4)
- youngin — 7 pair sides, mostly spelling via spelling phonetic key, often with tryna (2)
- niggas — 7 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- dually — 7 pair sides, mostly vowel via spelling phonetic key, often with baby (4)
- knuck — 6 pair sides, mostly spelling via spelling phonetic key, often with love (1)
- lambo — 6 pair sides, mostly spelling via spelling phonetic key, often with atlanta (4)
- bando — 6 pair sides, mostly vowel via spelling phonetic key, often with though (2)
- i8s — 5 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- jit — 4 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- herbo — 4 pair sides, mostly vowel via spelling phonetic key, often with know (4)
- wheelies — 4 pair sides, mostly spelling via spelling phonetic key, often with feelings (1)
- stuntin — 4 pair sides, mostly spelling via spelling phonetic key, often with country (2)
- forgis — 4 pair sides, mostly spelling via spelling phonetic key, often with fours (2)
- blingin — 3 pair sides, mostly vowel via spelling phonetic key, often with bitch (1)
- wigglys — 3 pair sides, mostly vowel via spelling phonetic key, often with dilly (1)
- jiggy — 3 pair sides, mostly spelling via spelling phonetic key, often with wit (1)
- dealie — 3 pair sides, mostly spelling via spelling phonetic key, often with wheelies (1)
- yachty — 3 pair sides, mostly vowel via spelling phonetic key, often with money (1)
- dyin — 2 pair sides, mostly spelling via spelling phonetic key, often with youngin (1)
- chevelle — 2 pair sides, mostly vowel via spelling phonetic key, often with tell (1)
- skraightenin — 2 pair sides, mostly spelling via spelling phonetic key, often with nothin (1)
- neimans — 2 pair sides, mostly vowel via spelling phonetic key, often with pedal (1)
- rbo — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- bap — 2 pair sides, mostly spelling via spelling phonetic key, often with cap (1)
- guap — 2 pair sides, mostly spelling via spelling phonetic key, often with what (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Zaytoven | Birds | 36 | 93 | 50 | loose |
| Zaytoven | Brick Man | 36 | 19 | 137 | loose |
| Zaytoven | DID ME BAD | 43 | 52 | 246 | loose |
| Zaytoven | East Atlanta Day | 38 | 36 | 218 | loose |
| Zaytoven | Flees | 54 | 69 | 318 | loose |
| Zaytoven | Hope | 45 | 64 | 527 | loose |
| Zaytoven | How I’m Playing | 51 | 85 | 471 | loose |
| Zaytoven | MOMONEY | 59 | 27 | 386 | loose |
| Zaytoven | Scope Ya | 4 | 3 | 17 | loose |
| Zaytoven | Show It | 40 | 13 | 186 | loose |
| Zaytoven | Stunt | 38 | 51 | 273 | loose |
