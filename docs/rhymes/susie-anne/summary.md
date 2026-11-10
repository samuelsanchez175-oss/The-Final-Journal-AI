# Susie Anne rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Susie Anne
- Songs: 1
- Bars kept (Susie Anne lyric lines): 9
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Susie Anne.
- Credit strings: Susie Anne.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 61
- REPEAT pairs, recorded separately: 3
- END rhymes: 4
- INNER rhymes: 57

By match:

- PERFECT: 5 (END 3, INNER 2)
- SLANT: 32 (END 0, INNER 32)
- ASSONANCE: 24 (END 1, INNER 23)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 5
- MED: 51
- LOW: 5

## Core

- Core Y: 59
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 34 (55.7%)
- vowel: 24 (39.3%)
- spelling: 3 (4.9%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 11 pairs (END 1, INNER 10). Words: offended, legs, get, when, spread, never.
2. `slant:IH:sib-stop` — 8 pairs (END 0, INNER 8). Words: bitch, fit, sit, yip, shit, sick.
3. `vow:IH` — 6 pairs (END 0, INNER 6). Words: bitch, little, serious, seriously, sick, yip.
4. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: sick, fit, sit, yip, shit.
5. `vow:IY` — 5 pairs (END 0, INNER 5). Words: being, ssy, p, seriously, g, t.
6. `cmu:IH-T` — 3 pairs (END 3, INNER 0). Words: shit, fit, sit.
7. `slant:EH:fric-stop` — 3 pairs (END 0, INNER 3). Words: never, get, spread.
8. `slant:EH:nas-stop` — 3 pairs (END 0, INNER 3). Words: when, get, spread.
9. `slant:IH:liq-stop` — 3 pairs (END 0, INNER 3). Words: little, shit, fit, sit.
10. `slant:EH:stop` — 2 pairs (END 0, INNER 2). Words: get, spread.
11. `vow:EY` — 2 pairs (END 0, INNER 2). Words: change, same, ways.
12. `cmu:IY` — 1 pairs (END 0, INNER 1). Words: g, t.
13. `cmu:OW-N-T` — 1 pairs (END 0, INNER 1). Words: don't, won't.
14. `slant:AE:nas-sib` — 1 pairs (END 0, INNER 1). Words: damn, phas.
15. `slant:AE:nas-stop` — 1 pairs (END 0, INNER 1). Words: bad, damn.
16. `slant:AE:sib-stop` — 1 pairs (END 0, INNER 1). Words: bad, phas.
17. `slant:AH:sib` — 1 pairs (END 0, INNER 1). Words: does, lovers.
18. `slant:EH:fric-nas` — 1 pairs (END 0, INNER 1). Words: when, never.
19. `slant:EY:nas-sib` — 1 pairs (END 0, INNER 1). Words: same, ways.
20. `slant:IH:liq-sib` — 1 pairs (END 0, INNER 1). Words: serious, seriously.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ssy — 2 pair sides, mostly vowel via spelling phonetic key, often with seriously (1)
- phas — 2 pair sides, mostly spelling via spelling phonetic key, often with bad (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with being (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Susie Anne | IDGAF | 9 | 4 | 57 | loose |
