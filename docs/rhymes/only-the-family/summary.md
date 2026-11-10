# Only The Family rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Only The Family
- Songs: 2
- Bars kept (Only The Family lyric lines): 71
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Only The Family.
- Credit strings: Only The Family.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 637
- REPEAT pairs, recorded separately: 85
- END rhymes: 59
- INNER rhymes: 578

By match:

- PERFECT: 51 (END 12, INNER 39)
- SLANT: 293 (END 26, INNER 267)
- ASSONANCE: 293 (END 21, INNER 272)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 50
- MED: 558
- LOW: 29

## Core

- Core Y: 628
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 323 (50.7%)
- vowel: 293 (46.0%)
- spelling: 21 (3.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 61 pairs (END 4, INNER 57). Words: why, riots, wildin, divided, fighting, trial, sliding, silent.
2. `vow:EH` — 59 pairs (END 6, INNER 53). Words: friends, again, accept, confession, trenches, help, rest, wreckless.
3. `vow:EY` — 56 pairs (END 7, INNER 49). Words: ain't, play, changed, played, waste, backstage, always, face.
4. `vow:OW` — 54 pairs (END 0, INNER 54). Words: don't, know, no, told, won't, go, most, broke.
5. `slant:EH:nas-stop` — 39 pairs (END 3, INNER 36). Words: again, get, said, steady, when, better, forget, end.
6. `slant:EH:stop` — 22 pairs (END 6, INNER 16). Words: accept, get, fed, said, steady, let, respect, neglected.
7. `vow:IH` — 22 pairs (END 1, INNER 21). Words: didn't, still, kids, shit, willing, visit, position, rich.
8. `slant:EH:liq-nas` — 21 pairs (END 6, INNER 15). Words: again, fell, tell, prayer, when, sell, care, where.
9. `slant:EY:sib-stop` — 19 pairs (END 3, INNER 16). Words: date, paid, played, space, always, face, backstage, crazy.
10. `slant:AE:nas-stop` — 17 pairs (END 1, INNER 16). Words: man, can't, diana, can, had, bat, back, sack.
11. `slant:EH:liq-stop` — 15 pairs (END 1, INNER 14). Words: get, tell, fell, sell, hell, fed, let, there.
12. `slant:EY:sib` — 13 pairs (END 3, INNER 10). Words: always, space, crazy, backstage, page.
13. `vow:AE` — 13 pairs (END 0, INNER 13). Words: can't, had, family, stacking, ipads, actin, diana, back.
14. `slant:EY:stop` — 12 pairs (END 0, INNER 12). Words: ain't, date, waste, weight, make, take, played, paid.
15. `cmu:EH-R` — 11 pairs (END 11, INNER 0). Words: care, fair, air, there, prayer.
16. `vow:IY` — 11 pairs (END 2, INNER 9). Words: see, here, street, probably, between, hear, cheated, appeal.
17. `cmu:OW` — 10 pairs (END 0, INNER 10). Words: know, no, go, chicago, radio, show.
18. `slant:EH:nas` — 7 pairs (END 0, INNER 7). Words: confession, again, when, seline.
19. `slant:EH:sib-stop` — 6 pairs (END 0, INNER 6). Words: better, lesser, less, rest, death, said.
20. `vow:AO` — 6 pairs (END 0, INNER 6). Words: talk, alderman, dog, lost, songs, all.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 10 pair sides, mostly spelling via spelling phonetic key, often with police (3)
- wreckless — 5 pair sides, mostly vowel via spelling phonetic key, often with trenches (1)
- clowned — 3 pair sides, mostly spelling via spelling phonetic key, often with clown (1)
- glocks — 3 pair sides, mostly vowel via spelling phonetic key, often with dont (2)
- cuz — 2 pair sides, mostly spelling via spelling phonetic key, often with money (1)
- seline — 1 pair sides, mostly spelling via spelling phonetic key, often with when (1)
- duece — 1 pair sides, mostly spelling via spelling phonetic key, often with young (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- ratted — 1 pair sides, mostly vowel via spelling phonetic key, often with savage (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Only The Family | Dirty Diana | 34 | 22 | 241 | loose |
| Only The Family | Riot | 37 | 37 | 337 | loose |
