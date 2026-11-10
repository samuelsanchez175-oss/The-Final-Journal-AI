# MAKJ rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: MAKJ
- Songs: 1
- Bars kept (MAKJ lyric lines): 7
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: MAKJ.
- Credit strings: MAKJ.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 33
- REPEAT pairs, recorded separately: 6
- END rhymes: 6
- INNER rhymes: 27

By match:

- PERFECT: 15 (END 3, INNER 12)
- SLANT: 12 (END 3, INNER 9)
- ASSONANCE: 6 (END 0, INNER 6)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 7
- MED: 17
- LOW: 9

## Core

- Core Y: 29
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 14 (42.4%)
- vowel: 6 (18.2%)
- spelling: 13 (39.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `spell:or` — 6 pairs (END 3, INNER 3). Words: dolor, amor, llor, por, calor.
2. `cmu:IY` — 5 pairs (END 0, INNER 5). Words: de, mi, ti.
3. `slant:AE:liq-nas` — 3 pairs (END 2, INNER 1). Words: amor, calor, mal.
4. `vow:OW` — 3 pairs (END 0, INNER 3). Words: lloro, no, lo.
5. `cmu:AO-R` — 2 pairs (END 0, INNER 2). Words: por, llor.
6. `cmu:OW` — 2 pairs (END 0, INNER 2). Words: no, lo.
7. `slant:EH:liq-nas` — 2 pairs (END 0, INNER 2). Words: n, el, para.
8. `slant:EH:liq-sib` — 2 pairs (END 0, INNER 2). Words: beso, el, para.
9. `vow:AA` — 2 pairs (END 0, INNER 2). Words: la, con.
10. `slant:AE:liq` — 1 pairs (END 0, INNER 1). Words: calor, mal.
11. `slant:AH:sib` — 1 pairs (END 0, INNER 1). Words: tus, curas.
12. `slant:EH:liq` — 1 pairs (END 0, INNER 1). Words: para, el.
13. `slant:EH:nas-sib` — 1 pairs (END 0, INNER 1). Words: beso, n.
14. `slant:OW:liq` — 1 pairs (END 1, INNER 0). Words: lloro, dolor.
15. `vow:EH` — 1 pairs (END 0, INNER 1). Words: medicina, para.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- dolor — 6 pair sides, mostly spelling via spelling phonetic key, often with amor (2)
- lloro — 4 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- llor — 4 pair sides, mostly spelling via spelling phonetic key, often with por (2)
- beso — 3 pair sides, mostly spelling via spelling phonetic key, often with para (1)
- medicina — 1 pair sides, mostly vowel via spelling phonetic key, often with para (1)
- tus — 1 pair sides, mostly spelling via spelling phonetic key, often with curas (1)
- curas — 1 pair sides, mostly spelling via spelling phonetic key, often with tus (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| MAKJ | Muñequita Linda [Mixed] | 7 | 6 | 27 | loose |
