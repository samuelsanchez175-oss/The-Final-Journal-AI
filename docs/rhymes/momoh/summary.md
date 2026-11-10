# Momoh rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Momoh
- Songs: 1
- Bars kept (Momoh lyric lines): 28
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Momoh.
- Credit strings: Momoh.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 205
- REPEAT pairs, recorded separately: 19
- END rhymes: 26
- INNER rhymes: 179

By match:

- PERFECT: 27 (END 11, INNER 16)
- SLANT: 101 (END 9, INNER 92)
- ASSONANCE: 77 (END 6, INNER 71)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 21
- MED: 157
- LOW: 27

## Core

- Core Y: 202
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 98 (47.8%)
- vowel: 77 (37.6%)
- spelling: 30 (14.6%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 27 pairs (END 4, INNER 23). Words: say, case, day, ain’t, face, made, safe, scale.
2. `vow:AY` — 18 pairs (END 2, INNER 16). Words: y, like, might, buy, try, time, pints, by.
3. `cmu:EY` — 14 pairs (END 6, INNER 8). Words: way, away, stay, k, jay, play, spray, say.
4. `slant:AY:nas-stop` — 13 pairs (END 4, INNER 9). Words: slide, time, line, dime, like, might, ride, mine.
5. `slant:AY:stop` — 12 pairs (END 1, INNER 11). Words: like, might, inside, ride, right, slide, find.
6. `vow:IH` — 11 pairs (END 0, INNER 11). Words: bricks, still, million, sittin, ginger, shit, nigga, finna.
7. `slant:EY:sib-stop` — 8 pairs (END 1, INNER 7). Words: case, weight, made, face, wraith.
8. `slant:IH:stop` — 8 pairs (END 0, INNER 8). Words: nigga, shit, hit.
9. `vow:EH` — 5 pairs (END 0, INNER 5). Words: spend, twelve, check, jet, f, hell, tell.
10. `slant:EH:fric-liq` — 4 pairs (END 0, INNER 4). Words: twelve, bell, hella, f, hell, tell, ever.
11. `slant:EH:stop` — 4 pairs (END 0, INNER 4). Words: jet, let, neck, check, head, dead.
12. `slant:EY:fric-sib` — 4 pairs (END 0, INNER 4). Words: safe, wraith, case, face.
13. `slant:EY:liq-sib` — 4 pairs (END 0, INNER 4). Words: scale, case, wraith, face.
14. `slant:EY:sib` — 4 pairs (END 1, INNER 3). Words: wraith, face, case.
15. `vow:AA` — 4 pairs (END 0, INNER 4). Words: la, got, hopped.
16. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: got, hopped.
17. `slant:AY:nas` — 3 pairs (END 0, INNER 3). Words: time, line, mine, dime.
18. `slant:EH:liq` — 3 pairs (END 0, INNER 3). Words: bell, hella, cheverlay.
19. `slant:EY:liq-stop` — 3 pairs (END 0, INNER 3). Words: scale, weight, made, ale, take.
20. `vow:AH` — 3 pairs (END 0, INNER 3). Words: what’s, coming, another, flood.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 12 pair sides, mostly spelling via spelling phonetic key, often with shit (7)
- wraith — 9 pair sides, mostly spelling via spelling phonetic key, often with face (2)
- cheverlay — 4 pair sides, mostly spelling via spelling phonetic key, often with say (1)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- hella — 3 pair sides, mostly spelling via spelling phonetic key, often with twelve (1)
- finna — 3 pair sides, mostly vowel via spelling phonetic key, often with nigga (2)
- hunnit — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with feel (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Momoh | Wraith | 28 | 26 | 179 | loose |
