# Cordae rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Cordae
- Songs: 1
- Bars kept (Cordae lyric lines): 7
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Cordae.
- Credit strings: Cordae.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 36
- REPEAT pairs, recorded separately: 6
- END rhymes: 2
- INNER rhymes: 34

By match:

- PERFECT: 4 (END 1, INNER 3)
- SLANT: 6 (END 0, INNER 6)
- ASSONANCE: 26 (END 1, INNER 25)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 4
- MED: 32
- LOW: 0

## Core

- Core Y: 36
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 9 (25.0%)
- vowel: 26 (72.2%)
- spelling: 1 (2.8%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 11 pairs (END 1, INNER 10). Words: trenches, never, attention, send, when, heavy.
2. `vow:IH` — 7 pairs (END 0, INNER 7). Words: listened, mill, think, grill.
3. `cmu:IH-L` — 2 pairs (END 1, INNER 1). Words: mill, grill.
4. `slant:EH:fric-nas` — 2 pairs (END 0, INNER 2). Words: never, when.
5. `slant:EY:stop` — 2 pairs (END 0, INNER 2). Words: ain't, hate.
6. `vow:AW` — 2 pairs (END 0, INNER 2). Words: countin, down, without.
7. `vow:AY` — 2 pairs (END 0, INNER 2). Words: grind, right.
8. `vow:EY` — 2 pairs (END 0, INNER 2). Words: made, yesterday, chevrolet.
9. `cmu:EY` — 1 pairs (END 0, INNER 1). Words: yesterday, chevrolet.
10. `slant:AW:nas-stop` — 1 pairs (END 0, INNER 1). Words: down, without.
11. `slant:EH:nas-stop` — 1 pairs (END 0, INNER 1). Words: when, send.
12. `spell:ion` — 1 pairs (END 0, INNER 1). Words: attention, suspition.
13. `vow:AA` — 1 pairs (END 0, INNER 1). Words: got, pops.
14. `vow:ER` — 1 pairs (END 0, INNER 1). Words: turned, first.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- suspition — 1 pair sides, mostly spelling via spelling phonetic key, often with attention (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Cordae | Yesterday* | 7 | 2 | 34 | loose |
