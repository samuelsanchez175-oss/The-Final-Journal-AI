# Eearz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Eearz
- Songs: 1
- Bars kept (Eearz lyric lines): 40
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Eearz.
- Credit strings: Eearz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 372
- REPEAT pairs, recorded separately: 21
- END rhymes: 42
- INNER rhymes: 330

By match:

- PERFECT: 49 (END 17, INNER 32)
- SLANT: 170 (END 15, INNER 155)
- ASSONANCE: 153 (END 10, INNER 143)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 49
- MED: 318
- LOW: 5

## Core

- Core Y: 372
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 214 (57.5%)
- vowel: 153 (41.1%)
- spelling: 5 (1.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 36 pairs (END 1, INNER 35). Words: can, laughing, lastly, back, franklin, blank, savage, cash.
2. `vow:OW` — 25 pairs (END 2, INNER 23). Words: don't, no, roads, won't, soul, told, know, stove.
3. `vow:IY` — 23 pairs (END 6, INNER 17). Words: three, weeps, thirty, hear, even, mean, see, peeps.
4. `slant:IY:liq-stop` — 20 pairs (END 0, INNER 20). Words: hear, creak, sleep, eat, keep, sheep, greek, feel.
5. `slant:IY:nas-stop` — 19 pairs (END 2, INNER 17). Words: mean, halloween, eat, sleep, creak, cheek, keep, sheep.
6. `slant:IY:stop` — 18 pairs (END 2, INNER 16). Words: creak, sleep, eat, keep, sheep, greek, seek, deep.
7. `vow:EY` — 17 pairs (END 0, INNER 17). Words: way, make, tables, ain't, day, plate, take, pacing.
8. `vow:AY` — 13 pairs (END 0, INNER 13). Words: like, by, wind, nights, spicy, choir, quite, high.
9. `slant:IY:sib-stop` — 11 pairs (END 4, INNER 7). Words: weeps, deep, beneath, teeth, sleep, peeps, street, treat.
10. `slant:EY:stop` — 9 pairs (END 4, INNER 5). Words: plate, make, date, take, steak.
11. `vow:EH` — 9 pairs (END 0, INNER 9). Words: december, there's, twenty, tears, ben, legend, sweat, wear.
12. `vow:IH` — 9 pairs (END 0, INNER 9). Words: tricked, middle, bitch, think, wings, sink, blink, years.
13. `slant:AO:liq` — 7 pairs (END 1, INNER 6). Words: more, before, all, story, glory.
14. `vow:AA` — 7 pairs (END 0, INNER 7). Words: garlic, pops, follow, mama, caught, gotta, hot, stop.
15. `vow:AO` — 7 pairs (END 0, INNER 7). Words: saw, before, morgan, taught, brought, talking, all, more.
16. `cmu:AY-ER` — 6 pairs (END 6, INNER 0). Words: fire, wire, crier, choir.
17. `cmu:IY-T` — 6 pairs (END 6, INNER 0). Words: feet, street, treat, sweet.
18. `cmu:UW` — 6 pairs (END 0, INNER 6). Words: knew, two, few, flew.
19. `slant:AE:nas-stop` — 6 pairs (END 0, INNER 6). Words: man, back, can, bad, can't, tat.
20. `slant:AE:sib-stop` — 6 pairs (END 0, INNER 6). Words: back, cash, bad, pass, last, flash, path.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- None.

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Eearz | No Sleep | 40 | 42 | 330 | loose |
