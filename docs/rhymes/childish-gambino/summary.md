# Childish Gambino rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Childish Gambino
- Songs: 2
- Bars kept (Childish Gambino lyric lines): 134
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Childish Gambino.
- Credit strings: Childish Gambino.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 568
- REPEAT pairs, recorded separately: 75
- END rhymes: 68
- INNER rhymes: 500

By match:

- PERFECT: 30 (END 9, INNER 21)
- SLANT: 265 (END 27, INNER 238)
- ASSONANCE: 268 (END 31, INNER 237)
- MULTI: 5 (END 1, INNER 4)

By confidence:

- HIGH: 30
- MED: 524
- LOW: 14

## Core

- Core Y: 564
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 281 (49.5%)
- vowel: 268 (47.2%)
- spelling: 14 (2.5%)
- multi: 5 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 42 pairs (END 5, INNER 37). Words: psilocybin, like, papaya, fire, life, i'll, right, private.
2. `vow:EH` — 38 pairs (END 0, INNER 38). Words: special, said, trenches, telling, ellis, when, ben, flexin.
3. `vow:EY` — 38 pairs (END 2, INNER 36). Words: ain't, baby, way, halos, stay, percolating, sunday, changin.
4. `vow:OW` — 35 pairs (END 4, INNER 31). Words: don't, no, know, hold, most, go, closed, joe's.
5. `vow:AE` — 34 pairs (END 8, INNER 26). Words: franklin, damn, facts, harassin, black, fact, laughed, understand.
6. `slant:EY:stop` — 30 pairs (END 2, INNER 28). Words: baby, babe, make, ain't, great, straight, take, made.
7. `vow:AA` — 21 pairs (END 1, INNER 20). Words: wanna, want, harvard, raw, pockets, proper, dark, stop.
8. `vow:IH` — 21 pairs (END 7, INNER 14). Words: spinach, chicken, little, ignorant, give, pictures, stepsisters, lips.
9. `vow:IY` — 14 pairs (END 1, INNER 13). Words: reason, wee, deep, feeling, see, dream, beat, dreams.
10. `slant:EH:fric-stop` — 12 pairs (END 0, INNER 12). Words: whatever, said, let, never, check, every.
11. `slant:AY:stop` — 10 pairs (END 0, INNER 10). Words: like, might, right, outside, side, write, ride.
12. `vow:AH` — 10 pairs (END 2, INNER 8). Words: jemisin, kumbaya, some, love, come, touched, another, colors.
13. `slant:AE:stop` — 9 pairs (END 2, INNER 7). Words: back, mad, slanted, matter, panic, manic, tracee, cat.
14. `slant:EH:liq-stop` — 9 pairs (END 0, INNER 9). Words: said, yellow, let, jelly, smell, set, red, tell.
15. `cmu:OW` — 8 pairs (END 1, INNER 7). Words: no, know, go, throw, radio, though, show, moscow.
16. `slant:EH:stop` — 8 pairs (END 0, INNER 8). Words: said, let, set, get, neck, twenty, check, red.
17. `slant:UH:stop` — 8 pairs (END 0, INNER 8). Words: took, could, look, put.
18. `slant:AA:stop` — 7 pairs (END 2, INNER 5). Words: got, want, bought, patek, closet, deposit, park, hard.
19. `slant:AE:nas-stop` — 7 pairs (END 1, INNER 6). Words: can, back, had, damn, wack, matter, black, man.
20. `slant:AY:nas-sib` — 7 pairs (END 0, INNER 7). Words: time, realize, summertime, ice, popeyes, popeye's.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- szas — 3 pair sides, mostly spelling via spelling phonetic key, often with chaka (1)
- tracee — 3 pair sides, mostly spelling via spelling phonetic key, often with have (1)
- jemisin — 3 pair sides, mostly vowel via vault phonetic_class, often with some (2)
- chaka — 2 pair sides, mostly spelling via spelling phonetic key, often with szas (1)
- vibin — 2 pair sides, mostly spelling via spelling phonetic key, often with lyin (1)
- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with vibin (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with bode (1)
- ignant — 1 pair sides, mostly vowel via spelling phonetic key, often with spinach (1)
- oochie — 1 pair sides, mostly spelling via spelling phonetic key, often with coochie (1)
- aight — 1 pair sides, mostly spelling via spelling phonetic key, often with right (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with give (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with szas (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Childish Gambino | 12.38 | 104 | 55 | 383 | loose |
| Childish Gambino | Do Whatever You Want | 30 | 13 | 117 | loose |
