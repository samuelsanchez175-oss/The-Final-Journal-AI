# Jim Jones rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Jim Jones
- Songs: 1
- Bars kept (Jim Jones lyric lines): 39
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Jim Jones.
- Credit strings: Jim Jones.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 281
- REPEAT pairs, recorded separately: 24
- END rhymes: 38
- INNER rhymes: 243

By match:

- PERFECT: 35 (END 16, INNER 19)
- SLANT: 95 (END 8, INNER 87)
- ASSONANCE: 142 (END 14, INNER 128)
- MULTI: 9 (END 0, INNER 9)

By confidence:

- HIGH: 41
- MED: 208
- LOW: 32

## Core

- Core Y: 272
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 104 (37.0%)
- vowel: 142 (50.5%)
- spelling: 26 (9.3%)
- multi: 9 (3.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 53 pairs (END 3, INNER 50). Words: won't, go, know, broke, bros, told, goes, going.
2. `vow:AE` — 40 pairs (END 8, INNER 32). Words: can't, crash, blast, max, family, bag, asked, ransom.
3. `vow:EY` — 17 pairs (END 0, INNER 17). Words: play, ain't, game, change, same, way, make, haters.
4. `cmu:OW` — 13 pairs (END 4, INNER 9). Words: know, go, ho, no, doe, though, slow, low.
5. `cmu:AE-S-T` — 12 pairs (END 11, INNER 1). Words: last, fast, past, passed, blast.
6. `slant:AE:stop` — 10 pairs (END 0, INNER 10). Words: falt, blast, can't, bando, mad, had, fast, past.
7. `vow:EH` — 9 pairs (END 0, INNER 9). Words: help, get, let, envy, there, better, never, when.
8. `slant:EH:nas-stop` — 8 pairs (END 0, INNER 8). Words: when, get, let, better.
9. `slant:EH:fric-nas` — 6 pairs (END 0, INNER 6). Words: when, never, envy.
10. `slant:IY:fric-stop` — 6 pairs (END 0, INNER 6). Words: believe, sleep, eat, beef.
11. `multi:EH-V-ER` — 5 pairs (END 0, INNER 5). Words: never, ever, forever.
12. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: gotta, start, alot, got.
13. `slant:OW:nas-sib` — 5 pairs (END 0, INNER 5). Words: bros, gon, going.
14. `vow:AA` — 5 pairs (END 0, INNER 5). Words: projects, gotta, na, got, not.
15. `vow:IY` — 5 pairs (END 0, INNER 5). Words: g, even, sleep, keep.
16. `slant:EH:fric-stop` — 4 pairs (END 0, INNER 4). Words: never, get, better, let.
17. `slant:EH:stop` — 4 pairs (END 0, INNER 4). Words: get, better, spent, let.
18. `slant:OW:nas-stop` — 4 pairs (END 0, INNER 4). Words: gon, won't, coke, broke.
19. `slant:OW:sib-stop` — 4 pairs (END 3, INNER 1). Words: broke, goes, bros, coke.
20. `vow:AY` — 4 pairs (END 0, INNER 4). Words: fly, right, vibe, nights, trial, like, die.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- bros — 17 pair sides, mostly spelling via spelling phonetic key, often with gon (3)
- gon — 10 pair sides, mostly spelling via spelling phonetic key, often with bros (3)
- falt — 5 pair sides, mostly spelling via spelling phonetic key, often with fast (1)
- bando — 2 pair sides, mostly spelling via spelling phonetic key, often with cant (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with til (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with need (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Jim Jones | Gotta Play the Game | 39 | 38 | 243 | loose |
