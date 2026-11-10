# Quicktrip rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Quicktrip
- Songs: 1
- Bars kept (Quicktrip lyric lines): 39
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Quicktrip.
- Credit strings: Quicktrip.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 191
- REPEAT pairs, recorded separately: 28
- END rhymes: 37
- INNER rhymes: 154

By match:

- PERFECT: 30 (END 6, INNER 24)
- SLANT: 86 (END 14, INNER 72)
- ASSONANCE: 74 (END 16, INNER 58)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 23
- MED: 158
- LOW: 10

## Core

- Core Y: 184
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 106 (55.5%)
- vowel: 74 (38.7%)
- spelling: 10 (5.2%)
- multi: 1 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 36 pairs (END 14, INNER 22). Words: shift, think, strips, bitch, quicktrip, whip, inches, kickin.
2. `slant:IH:stop` — 18 pairs (END 1, INNER 17). Words: hit, quick, trip, stick, big, ticket, shift, think.
3. `vow:AA` — 13 pairs (END 2, INNER 11). Words: hah, stop, carbin, spot, shop, got, hardtop, car.
4. `slant:AA:stop` — 11 pairs (END 0, INNER 11). Words: spot, stop, aka, top, shop, got, gotta, pot.
5. `slant:IH:sib-stop` — 10 pairs (END 2, INNER 8). Words: bitch, trip, hit, stick, big, quick, strips.
6. `slant:AH:nas` — 9 pairs (END 3, INNER 6). Words: money, one, rerun, some.
7. `vow:IY` — 7 pairs (END 0, INNER 7). Words: street, feeling, c, g, see, chief, keef.
8. `slant:AH:nas-stop` — 6 pairs (END 2, INNER 4). Words: one, thunder, fuck, run, truck.
9. `spell:op` — 6 pairs (END 2, INNER 4). Words: stop, droptop, hardtop, shop.
10. `vow:AH` — 6 pairs (END 0, INNER 6). Words: double, young, fuck, what's, some, truck, thunder, uncle.
11. `cmu:AA-T` — 5 pairs (END 0, INNER 5). Words: bought, not, got, pot, spot.
12. `cmu:AE-K-S` — 5 pairs (END 1, INNER 4). Words: packs, racks, stacks.
13. `slant:AA:liq-stop` — 5 pairs (END 0, INNER 5). Words: car, stop, aka, shop, spot.
14. `slant:UW:nas` — 5 pairs (END 3, INNER 2). Words: room, spoon, perfume, goon.
15. `vow:AE` — 5 pairs (END 0, INNER 5). Words: trap, standing, asking, had, packs, racks.
16. `slant:AY:nas-stop` — 4 pairs (END 0, INNER 4). Words: like, time, everytime, white.
17. `vow:AO` — 4 pairs (END 0, INNER 4). Words: walked, all, snorin, court.
18. `slant:AY:stop` — 3 pairs (END 0, INNER 3). Words: like, white.
19. `cmu:AA-P` — 2 pairs (END 1, INNER 1). Words: stop, shop.
20. `cmu:AE-NG` — 2 pairs (END 0, INNER 2). Words: bang, gang.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- quicktrip — 7 pair sides, mostly vowel via spelling phonetic key, often with bitch (2)
- hardtop — 5 pair sides, mostly spelling via spelling phonetic key, often with stop (2)
- droptop — 4 pair sides, mostly spelling via spelling phonetic key, often with stop (2)
- tooly — 2 pair sides, mostly spelling via spelling phonetic key, often with coupe (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with ticket (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Quicktrip | What’s The Ticket | 39 | 37 | 154 | loose |
