# Suav Corleone rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Suav Corleone
- Songs: 1
- Bars kept (Suav Corleone lyric lines): 45
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Suav Corleone.
- Credit strings: Suav Corleone.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 157
- REPEAT pairs, recorded separately: 62
- END rhymes: 29
- INNER rhymes: 128

By match:

- PERFECT: 30 (END 16, INNER 14)
- SLANT: 66 (END 9, INNER 57)
- ASSONANCE: 59 (END 4, INNER 55)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 30
- MED: 110
- LOW: 17

## Core

- Core Y: 154
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 79 (50.3%)
- vowel: 59 (37.6%)
- spelling: 17 (10.8%)
- multi: 2 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 21 pairs (END 2, INNER 19). Words: like, pie, bye, right, eye, popeye, while, rights.
2. `cmu:AY` — 20 pairs (END 12, INNER 8). Words: bye, pie, eye, popeye.
3. `vow:IH` — 15 pairs (END 1, INNER 14). Words: everything, glist, wrist, bitch, hitting, gripping, fifty, drink.
4. `slant:IH:stop` — 9 pairs (END 0, INNER 9). Words: nigga, shit, hit, whiteout, glist, wrist, didn't, milk.
5. `slant:AY:stop` — 6 pairs (END 1, INNER 5). Words: like, right, night, pipe, light.
6. `vow:OW` — 6 pairs (END 0, INNER 6). Words: know, rolling, honeycomb, don't, no, smoking, smoke, only.
7. `slant:IH:nas-sib` — 5 pairs (END 0, INNER 5). Words: everything, bitch, rich.
8. `slant:IH:nas-stop` — 5 pairs (END 0, INNER 5). Words: everything, shit, hitting, hit, whiteout.
9. `vow:AA` — 5 pairs (END 0, INNER 5). Words: want, cops, hard, drop, opp, wanna, got.
10. `slant:AY:liq-stop` — 4 pairs (END 2, INNER 2). Words: while, like, mile, night, right.
11. `slant:AY:sib-stop` — 4 pairs (END 4, INNER 0). Words: night, lights, rights, right.
12. `slant:IH:sib-stop` — 4 pairs (END 0, INNER 4). Words: bitch, hit, rich, shit, pick.
13. `vow:AE` — 4 pairs (END 0, INNER 4). Words: racks, have, act, blanking, flat, had.
14. `vow:IY` — 4 pairs (END 1, INNER 3). Words: even, see, weed, between, feeling, he's, need.
15. `slant:AE:stop` — 3 pairs (END 0, INNER 3). Words: trap, black, act, grab, flat, had.
16. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: fuck, young, fucking, some.
17. `slant:EH:liq` — 3 pairs (END 0, INNER 3). Words: hella, there, jello.
18. `cmu:AW-T` — 2 pairs (END 2, INNER 0). Words: buyout, whiteout, hideout.
19. `cmu:AY-T` — 2 pairs (END 1, INNER 1). Words: night, right, light.
20. `cmu:IH-CH` — 2 pairs (END 0, INNER 2). Words: bitch, rich.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 5 pair sides, mostly spelling via spelling phonetic key, often with hit (2)
- glist — 5 pair sides, mostly vowel via spelling phonetic key, often with everything (2)
- whiteout — 4 pair sides, mostly spelling via spelling phonetic key, often with buyout (1)
- hella — 3 pair sides, mostly spelling via spelling phonetic key, often with there (2)
- thrax — 2 pair sides, mostly spelling via spelling phonetic key, often with pack (1)
- maccy — 1 pair sides, mostly cmu via vault phonetic_class, often with down (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Suav Corleone | Thiyow | 45 | 29 | 128 | loose |
