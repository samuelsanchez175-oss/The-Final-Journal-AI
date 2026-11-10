# Chopsquad DJ rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Chopsquad DJ
- Songs: 1
- Bars kept (Chopsquad DJ lyric lines): 33
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Chopsquad DJ.
- Credit strings: Chopsquad DJ.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 144
- REPEAT pairs, recorded separately: 17
- END rhymes: 25
- INNER rhymes: 119

By match:

- PERFECT: 19 (END 7, INNER 12)
- SLANT: 76 (END 10, INNER 66)
- ASSONANCE: 49 (END 8, INNER 41)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 16
- MED: 121
- LOW: 7

## Core

- Core Y: 143
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 85 (59.0%)
- vowel: 49 (34.0%)
- spelling: 10 (6.9%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:EH:liq-stop` — 10 pairs (END 0, INNER 10). Words: tell, neck, set, let, air, said, check.
2. `vow:AE` — 10 pairs (END 1, INNER 9). Words: handsome, act, acting, back, financed, man, fallon, cracking.
3. `vow:AY` — 9 pairs (END 1, INNER 8). Words: lightning, like, diamonds, strike, try, height.
4. `slant:AH:nas-stop` — 7 pairs (END 0, INNER 7). Words: what, cut, funny, fuck, run, some, come, done.
5. `vow:AH` — 7 pairs (END 0, INNER 7). Words: run, motherfuckin, duh, fuck, ugly, some, cut, done.
6. `vow:EY` — 7 pairs (END 4, INNER 3). Words: say, ain't, steak, plate, way, make, take.
7. `vow:OW` — 6 pairs (END 2, INNER 4). Words: told, dominoes, ago, hoe, rolls, don't.
8. `slant:EH:liq-nas` — 5 pairs (END 0, INNER 5). Words: when, tell, well.
9. `slant:EH:stop` — 5 pairs (END 2, INNER 3). Words: tester, set, bet, get, check, neck, said, let.
10. `vow:EH` — 5 pairs (END 0, INNER 5). Words: friends, evidence, bet, air, let, said, tell.
11. `cmu:AH-N` — 4 pairs (END 1, INNER 3). Words: done, hun, one, run.
12. `slant:AH:nas` — 4 pairs (END 2, INNER 2). Words: come, run, some, done, hun, one.
13. `slant:EH:liq` — 4 pairs (END 0, INNER 4). Words: tell, hella, air.
14. `vow:IH` — 4 pairs (END 0, INNER 4). Words: think, bitch, still, hit.
15. `cmu:UH-D` — 3 pairs (END 3, INNER 0). Words: wood, would.
16. `slant:AY:stop` — 3 pairs (END 0, INNER 3). Words: height, like, strike.
17. `slant:EH:fric-liq` — 3 pairs (END 0, INNER 3). Words: ever, tell, air.
18. `slant:EH:sib-stop` — 3 pairs (END 3, INNER 0). Words: less, check, set, neck.
19. `slant:IH:sib-stop` — 3 pairs (END 0, INNER 3). Words: wish, bitch, hit, kid, sit.
20. `spell:on` — 3 pairs (END 0, INNER 3). Words: gon, fallon.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 6 pair sides, mostly spelling via spelling phonetic key, often with fallon (3)
- hella — 3 pair sides, mostly spelling via spelling phonetic key, often with tell (3)
- heraint — 1 pair sides, mostly spelling via spelling phonetic key, often with aint (1)
- vamonos — 1 pair sides, mostly vowel via spelling phonetic key, often with fallon (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Chopsquad DJ | I Wish You Would | 33 | 25 | 119 | loose |
