# Alison Wonderland rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Alison Wonderland
- Songs: 1
- Bars kept (Alison Wonderland lyric lines): 29
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Alison Wonderland.
- Credit strings: Alison Wonderland.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 120
- REPEAT pairs, recorded separately: 11
- END rhymes: 18
- INNER rhymes: 102

By match:

- PERFECT: 9 (END 2, INNER 7)
- SLANT: 64 (END 7, INNER 57)
- ASSONANCE: 47 (END 9, INNER 38)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 9
- MED: 111
- LOW: 0

## Core

- Core Y: 120
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 71 (59.2%)
- vowel: 47 (39.2%)
- spelling: 2 (1.7%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 15 pairs (END 4, INNER 11). Words: know, folgers, dope, don't, controller, pro, canoga, over.
2. `vow:AE` — 7 pairs (END 3, INNER 4). Words: tasks, can, hands, bad, pass, catch, bang.
3. `slant:EH:fric-liq` — 5 pairs (END 0, INNER 5). Words: never, smell, sell, tell, yell.
4. `slant:AY:stop` — 4 pairs (END 0, INNER 4). Words: pipe, right, wide, wipe, might, like.
5. `slant:EH:liq-stop` — 4 pairs (END 0, INNER 4). Words: depp, sell, tell, yell, smell, get.
6. `vow:AA` — 4 pairs (END 0, INNER 4). Words: dodging, pop, gotta, sa, johnny, want, god.
7. `vow:AH` — 4 pairs (END 0, INNER 4). Words: comin, love, everyone, bumble, fuck, jump.
8. `vow:AW` — 4 pairs (END 1, INNER 3). Words: now, down, around, about, how.
9. `cmu:EH-L` — 3 pairs (END 0, INNER 3). Words: sell, tell, yell.
10. `slant:AE:sib-stop` — 3 pairs (END 1, INNER 2). Words: bad, catch, pass, had.
11. `slant:AY:fric-stop` — 3 pairs (END 0, INNER 3). Words: like, drive, live, might.
12. `slant:AY:sib-stop` — 3 pairs (END 0, INNER 3). Words: eyes, tires, ride, wide, pipe.
13. `slant:IY:sib-stop` — 3 pairs (END 0, INNER 3). Words: keep, complete, these, bees, creeps.
14. `vow:EH` — 3 pairs (END 0, INNER 3). Words: else, get, yell, gettin, never, smelling.
15. `cmu:OW` — 2 pairs (END 0, INNER 2). Words: know, pro.
16. `slant:AA:liq-stop` — 2 pairs (END 0, INNER 2). Words: gotta, car.
17. `slant:AE:fric-sib` — 2 pairs (END 0, INNER 2). Words: have, catch, pass.
18. `slant:AE:nas-sib` — 2 pairs (END 0, INNER 2). Words: can, catch, pass.
19. `slant:AH:nas-stop` — 2 pairs (END 0, INNER 2). Words: fuck, come, comin, jump.
20. `slant:AW:nas-stop` — 2 pairs (END 0, INNER 2). Words: down, around.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nightgown — 2 pair sides, mostly spelling via spelling phonetic key, often with down (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Alison Wonderland | Dreamy Dragon | 29 | 18 | 102 | loose |
