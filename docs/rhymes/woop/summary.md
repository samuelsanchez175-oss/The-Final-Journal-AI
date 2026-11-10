# Woop rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Woop
- Songs: 1
- Bars kept (Woop lyric lines): 35
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Woop.
- Credit strings: Woop.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 270
- REPEAT pairs, recorded separately: 44
- END rhymes: 22
- INNER rhymes: 248

By match:

- PERFECT: 25 (END 3, INNER 22)
- SLANT: 121 (END 13, INNER 108)
- ASSONANCE: 122 (END 6, INNER 116)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 19
- MED: 235
- LOW: 16

## Core

- Core Y: 265
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 127 (47.0%)
- vowel: 122 (45.2%)
- spelling: 19 (7.0%)
- multi: 2 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 32 pairs (END 0, INNER 32). Words: got, bodyguard, molly, yard, bars, hard, rock, park.
2. `vow:AH` — 25 pairs (END 0, INNER 25). Words: hungry, onions, clutching, club, money, snuck, busting, hunt.
3. `slant:AA:liq-stop` — 21 pairs (END 2, INNER 19). Words: jar, molly, got, ar, bar, bodyguard, guard, rock.
4. `vow:EY` — 14 pairs (END 3, INNER 11). Words: j, case, ray, ain't, day, place, cake, late.
5. `slant:AA:stop` — 13 pairs (END 1, INNER 12). Words: body, rock, got, park, og, bodyguard, not, yard.
6. `vow:IH` — 13 pairs (END 2, INNER 11). Words: milk, tips, bitch, shits, hit, till, lil, hip.
7. `vow:OW` — 12 pairs (END 0, INNER 12). Words: no, going, told, dont, know, own, chrome, old.
8. `vow:UH` — 9 pairs (END 0, INNER 9). Words: cookies, pulling, hood, pull, cookie, security.
9. `cmu:IH-NG` — 7 pairs (END 0, INNER 7). Words: grubbing, vibing, going, pimping, popping, clutching, busting.
10. `slant:EY:sib-stop` — 7 pairs (END 2, INNER 5). Words: face, place, cake, late, jays, take, break, shake.
11. `cmu:AA-R-D` — 5 pairs (END 3, INNER 2). Words: bodyguard, guard, yard, hard.
12. `slant:AA:nas-stop` — 5 pairs (END 0, INNER 5). Words: got, body, bomb, tommy, mama.
13. `slant:AH:nas` — 5 pairs (END 2, INNER 3). Words: sum, nun, money, hunni, clutching, busting.
14. `slant:IY:stop` — 5 pairs (END 1, INNER 4). Words: need, geeked, deep, sleep.
15. `vow:AE` — 5 pairs (END 0, INNER 5). Words: xanax, dat, laughing, grandma, dash.
16. `slant:AA:sib-stop` — 4 pairs (END 3, INNER 1). Words: bars, bodyguard, yard, park, hard.
17. `slant:IH:nas` — 4 pairs (END 0, INNER 4). Words: fien, ima, sticking, singing, vibing, pippen.
18. `slant:IY:sib-stop` — 4 pairs (END 1, INNER 3). Words: piece, need, sleep, deep.
19. `vow:AY` — 4 pairs (END 0, INNER 4). Words: sniper, by, try, right.
20. `cmu:EY-K` — 3 pairs (END 0, INNER 3). Words: take, break, shake.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- grubbing — 5 pair sides, mostly spelling via spelling phonetic key, often with pimping (1)
- geeked — 4 pair sides, mostly spelling via spelling phonetic key, often with piece (1)
- vibing — 4 pair sides, mostly spelling via spelling phonetic key, often with popping (1)
- hunni — 3 pair sides, mostly vowel via spelling phonetic key, often with money (1)
- dont — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- throught — 2 pair sides, mostly spelling via spelling phonetic key, often with caught (1)
- wifey — 2 pair sides, mostly spelling via spelling phonetic key, often with rip (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with fien (2)
- fien — 2 pair sides, mostly spelling via spelling phonetic key, often with ima (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Woop | Bodyguard | 35 | 22 | 248 | loose |
