# NERVO rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: NERVO
- Songs: 1
- Bars kept (NERVO lyric lines): 20
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: NERVO.
- Credit strings: NERVO.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 146
- REPEAT pairs, recorded separately: 17
- END rhymes: 9
- INNER rhymes: 137

By match:

- PERFECT: 27 (END 2, INNER 25)
- SLANT: 41 (END 4, INNER 37)
- ASSONANCE: 78 (END 3, INNER 75)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 27
- MED: 119
- LOW: 0

## Core

- Core Y: 146
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 68 (46.6%)
- vowel: 78 (53.4%)
- spelling: 0 (0.0%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 39 pairs (END 1, INNER 38). Words: don't, know, won't, no, owe, cold, toe, only.
2. `vow:EH` — 21 pairs (END 0, INNER 21). Words: where, let's, rest, pretend, ends, there, head.
3. `cmu:OW` — 16 pairs (END 0, INNER 16). Words: know, no, owe, toe, po.
4. `vow:AY` — 11 pairs (END 2, INNER 9). Words: diamond, riding, like, reply, fight, skies, try, deny.
5. `slant:AY:sib-stop` — 6 pairs (END 2, INNER 4). Words: right, night, nights, skies, tonight's.
6. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: exotic, pop, drop, top, got.
7. `slant:EH:liq-stop` — 4 pairs (END 0, INNER 4). Words: head, where, there.
8. `vow:AE` — 4 pairs (END 0, INNER 4). Words: can, tags, bags.
9. `cmu:AA-P` — 3 pairs (END 0, INNER 3). Words: drop, top, pop.
10. `slant:AA:nas-stop` — 3 pairs (END 0, INNER 3). Words: shoppin, drop, top, pop.
11. `slant:AO:liq-stop` — 3 pairs (END 0, INNER 3). Words: thought, more, all.
12. `slant:EY:nas-sib` — 3 pairs (END 0, INNER 3). Words: days, rainy, champagne, place.
13. `cmu:EH-R` — 2 pairs (END 0, INNER 2). Words: where, there.
14. `cmu:OW-N-T` — 2 pairs (END 0, INNER 2). Words: won't, don't.
15. `slant:EH:liq-nas` — 2 pairs (END 0, INNER 2). Words: there, when.
16. `slant:EY:nas-stop` — 2 pairs (END 0, INNER 2). Words: take, champagne.
17. `slant:EY:sib-stop` — 2 pairs (END 0, INNER 2). Words: take, place.
18. `vow:AA` — 2 pairs (END 0, INNER 2). Words: shoppin, exotic, got.
19. `cmu:AE-G-Z` — 1 pairs (END 1, INNER 0). Words: tags, bags.
20. `cmu:AY` — 1 pairs (END 0, INNER 1). Words: try, deny.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- None.

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| NERVO | Champagne | 20 | 9 | 137 | loose |
