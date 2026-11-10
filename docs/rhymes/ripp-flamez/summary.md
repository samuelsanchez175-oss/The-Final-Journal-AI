# Ripp Flamez rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ripp Flamez
- Songs: 1
- Bars kept (Ripp Flamez lyric lines): 25
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Ripp Flamez.
- Credit strings: Ripp Flamez.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 100
- REPEAT pairs, recorded separately: 20
- END rhymes: 29
- INNER rhymes: 71

By match:

- PERFECT: 5 (END 3, INNER 2)
- SLANT: 37 (END 14, INNER 23)
- ASSONANCE: 56 (END 12, INNER 44)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 6
- MED: 86
- LOW: 8

## Core

- Core Y: 97
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 36 (36.0%)
- vowel: 56 (56.0%)
- spelling: 6 (6.0%)
- multi: 2 (2.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 24 pairs (END 10, INNER 14). Words: shit, subliminal, kicks, thinking, missing, winning, brick, prison.
2. `vow:IY` — 11 pairs (END 1, INNER 10). Words: hear, sneakin, reachin, reason, schemin, seen, these.
3. `slant:IH:stop` — 10 pairs (END 8, INNER 2). Words: shit, whip, clip, brick, slick, nigga.
4. `vow:EH` — 7 pairs (END 0, INNER 7). Words: spent, extra, twelve, bells, empty, federal, every, sellin.
5. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: colorado, lot, gotta, not, shot.
6. `vow:AA` — 5 pairs (END 0, INNER 5). Words: dodging, charge, shot, colorado, not, marijuana, got.
7. `slant:IY:nas` — 3 pairs (END 2, INNER 1). Words: reachin, reason, sneakin, seen.
8. `vow:UW` — 3 pairs (END 0, INNER 3). Words: through, cool, used.
9. `multi:EY-L-IH-NG` — 2 pairs (END 0, INNER 2). Words: mailing, sailing, marijuana mailing, way sailing.
10. `slant:EH:fric-liq` — 2 pairs (END 0, INNER 2). Words: every, smell.
11. `slant:IH:nas` — 2 pairs (END 1, INNER 1). Words: missing, prison, winning, i'ma.
12. `slant:IH:sib-stop` — 2 pairs (END 0, INNER 2). Words: niggas, nigga.
13. `slant:IY:liq-nas` — 2 pairs (END 0, INNER 2). Words: hear, seen.
14. `vow:AE` — 2 pairs (END 0, INNER 2). Words: rappin, track, pack.
15. `vow:EY` — 2 pairs (END 0, INNER 2). Words: way, mailing, sailing.
16. `cmu:AE-K` — 1 pairs (END 1, INNER 0). Words: track, pack.
17. `cmu:IH-K` — 1 pairs (END 1, INNER 0). Words: brick, slick.
18. `cmu:IY-L` — 1 pairs (END 1, INNER 0). Words: real, feel.
19. `cmu:OW` — 1 pairs (END 0, INNER 1). Words: know, go.
20. `slant:AA:nas-stop` — 1 pairs (END 0, INNER 1). Words: marijuana, got.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 5 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with winning (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ripp Flamez | Reason | 25 | 29 | 71 | loose |
