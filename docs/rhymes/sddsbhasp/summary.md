# SDDSBHASP rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: SDDSBHASP
- Songs: 1
- Bars kept (SDDSBHASP lyric lines): 7
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: SDDSBHASP.
- Credit strings: SDDSBHASP.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 16
- REPEAT pairs, recorded separately: 8
- END rhymes: 3
- INNER rhymes: 13

By match:

- PERFECT: 0 (END 0, INNER 0)
- SLANT: 9 (END 3, INNER 6)
- ASSONANCE: 7 (END 0, INNER 7)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 0
- MED: 16
- LOW: 0

## Core

- Core Y: 16
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 9 (56.2%)
- vowel: 7 (43.8%)
- spelling: 0 (0.0%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 3 pairs (END 0, INNER 3). Words: savage, had, ass, can.
2. `vow:IY` — 3 pairs (END 0, INNER 3). Words: eating, hear, feature.
3. `slant:AE:nas-sib` — 2 pairs (END 0, INNER 2). Words: ass, can.
4. `slant:IY:fric-liq` — 2 pairs (END 2, INNER 0). Words: hear, levi.
5. `slant:IY:liq-sib` — 2 pairs (END 1, INNER 1). Words: feature, hear.
6. `slant:AE:nas-stop` — 1 pairs (END 0, INNER 1). Words: had, can.
7. `slant:AE:sib-stop` — 1 pairs (END 0, INNER 1). Words: had, ass.
8. `slant:AH:stop` — 1 pairs (END 0, INNER 1). Words: shut, fuck.
9. `vow:IH` — 1 pairs (END 0, INNER 1). Words: wish, industry.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- None.

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| SDDSBHASP | Laced Lemurs | 7 | 3 | 13 | loose |
