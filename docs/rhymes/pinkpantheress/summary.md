# PinkPantheress rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: PinkPantheress
- Songs: 1
- Bars kept (PinkPantheress lyric lines): 25
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: PinkPantheress.
- Credit strings: PinkPantheress.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 142
- REPEAT pairs, recorded separately: 16
- END rhymes: 26
- INNER rhymes: 116

By match:

- PERFECT: 22 (END 11, INNER 11)
- SLANT: 51 (END 5, INNER 46)
- ASSONANCE: 69 (END 10, INNER 59)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 22
- MED: 120
- LOW: 0

## Core

- Core Y: 142
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 73 (51.4%)
- vowel: 69 (48.6%)
- spelling: 0 (0.0%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 42 pairs (END 10, INNER 32). Words: know, don't, road, froze, almost, go, told, grow.
2. `vow:EH` — 16 pairs (END 0, INNER 16). Words: best, messed, step, when, end, friend, tears, boyfriend.
3. `cmu:OW` — 9 pairs (END 4, INNER 5). Words: know, go, grow, no.
4. `slant:EH:nas-stop` — 7 pairs (END 0, INNER 7). Words: when, end, friend, boyfriend, step.
5. `cmu:EH-R` — 6 pairs (END 3, INNER 3). Words: care, air, there, pair.
6. `slant:EH:liq-sib` — 5 pairs (END 3, INNER 2). Words: tears, pair, care, air, there, s.
7. `slant:EH:liq-stop` — 5 pairs (END 0, INNER 5). Words: get, care, air, there, pair, tell, said.
8. `vow:AY` — 4 pairs (END 0, INNER 4). Words: cry, find, right, time, fighting, arrive.
9. `cmu:EH-N-D` — 3 pairs (END 3, INNER 0). Words: end, friend, boyfriend.
10. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: want, not.
11. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: can, bad, had, can't.
12. `slant:AH:fric-nas` — 3 pairs (END 0, INNER 3). Words: love, someone, one.
13. `slant:OW:stop` — 3 pairs (END 0, INNER 3). Words: don't, most, almost, road, told.
14. `vow:AH` — 3 pairs (END 0, INNER 3). Words: someone, loved, love, somethin.
15. `slant:AH:fric-sib` — 2 pairs (END 0, INNER 2). Words: love, touch, another.
16. `slant:AH:nas-sib` — 2 pairs (END 0, INNER 2). Words: another, one, someone.
17. `slant:AY:liq-stop` — 2 pairs (END 0, INNER 2). Words: lifestyle, like, right.
18. `slant:EH:sib-stop` — 2 pairs (END 0, INNER 2). Words: s, get, met.
19. `vow:AA` — 2 pairs (END 0, INNER 2). Words: wasn't, part, start.
20. `cmu:AA-R-T` — 1 pairs (END 0, INNER 1). Words: part, start.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- None.

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| PinkPantheress | bbycakes (Mixed) | 25 | 26 | 116 | loose |
