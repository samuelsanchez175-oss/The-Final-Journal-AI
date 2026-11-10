# LIL ARSA rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: LIL ARSA
- Songs: 1
- Bars kept (LIL ARSA lyric lines): 8
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: LIL ARSA.
- Credit strings: LIL ARSA.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 35
- REPEAT pairs, recorded separately: 0
- END rhymes: 3
- INNER rhymes: 32

By match:

- PERFECT: 1 (END 0, INNER 1)
- SLANT: 13 (END 0, INNER 13)
- ASSONANCE: 20 (END 2, INNER 18)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 2
- MED: 31
- LOW: 2

## Core

- Core Y: 34
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 13 (37.1%)
- vowel: 20 (57.1%)
- spelling: 1 (2.9%)
- multi: 1 (2.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 6 pairs (END 1, INNER 5). Words: rings, bitchin, stripper, kitty, him.
2. `vow:EH` — 3 pairs (END 0, INNER 3). Words: swear, tension, pension, hotel.
3. `vow:IY` — 3 pairs (END 0, INNER 3). Words: feelin, need, these, kitty, shawty.
4. `slant:IH:liq-sib` — 2 pairs (END 0, INNER 2). Words: lil, bitch, rich.
5. `slant:IH:nas-sib` — 2 pairs (END 0, INNER 2). Words: bitchin, bitch, rich.
6. `vow:AE` — 2 pairs (END 0, INNER 2). Words: savin, smashed, tango.
7. `vow:EY` — 2 pairs (END 1, INNER 1). Words: chains, playin, cape.
8. `vow:OW` — 2 pairs (END 0, INNER 2). Words: hoes, no, told.
9. `cmu:IH-CH` — 1 pairs (END 0, INNER 1). Words: rich, bitch.
10. `multi:EH-N-SH-AH-N` — 1 pairs (END 1, INNER 0). Words: pension, tension.
11. `slant:AO:liq-stop` — 1 pairs (END 0, INNER 1). Words: walk, all.
12. `slant:EH:liq` — 1 pairs (END 0, INNER 1). Words: swear, hotel.
13. `slant:EY:nas-stop` — 1 pairs (END 0, INNER 1). Words: playin, cape.
14. `slant:IH:nas-stop` — 1 pairs (END 0, INNER 1). Words: kitty, him.
15. `slant:IH:stop` — 1 pairs (END 0, INNER 1). Words: stripper, kitty.
16. `slant:IY:sib-stop` — 1 pairs (END 0, INNER 1). Words: need, these.
17. `slant:OW:nas-sib` — 1 pairs (END 0, INNER 1). Words: gon, hoes.
18. `slant:OW:sib-stop` — 1 pairs (END 0, INNER 1). Words: hoes, road.
19. `slant:OW:stop` — 1 pairs (END 0, INNER 1). Words: told, road.
20. `vow:AA` — 1 pairs (END 0, INNER 1). Words: partner, talkin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with hoes (1)
- shawty — 1 pair sides, mostly vowel via spelling phonetic key, often with kitty (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| LIL ARSA | Step Back | 8 | 3 | 32 | loose |
