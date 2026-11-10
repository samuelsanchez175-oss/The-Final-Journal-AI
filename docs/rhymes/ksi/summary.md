# KSI rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: KSI
- Songs: 1
- Bars kept (KSI lyric lines): 47
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: KSI.
- Credit strings: KSI.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 213
- REPEAT pairs, recorded separately: 32
- END rhymes: 29
- INNER rhymes: 184

By match:

- PERFECT: 23 (END 9, INNER 14)
- SLANT: 93 (END 15, INNER 78)
- ASSONANCE: 97 (END 5, INNER 92)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 23
- MED: 180
- LOW: 10

## Core

- Core Y: 210
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 109 (51.2%)
- vowel: 97 (45.5%)
- spelling: 7 (3.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 30 pairs (END 3, INNER 27). Words: militant, witnesses, shit, bitches, trippin, hit, stripper, since.
2. `vow:EH` — 19 pairs (END 1, INNER 18). Words: medals, when, level, gettin, never, lend, where, present.
3. `vow:AE` — 11 pairs (END 0, INNER 11). Words: after, cash, have, racks, plaque, gang, back, pack.
4. `cmu:AA-P` — 10 pairs (END 6, INNER 4). Words: flop, cop, pop, drop.
5. `slant:IH:stop` — 8 pairs (END 1, INNER 7). Words: shit, pick, hit, twitter, stripper.
6. `vow:AA` — 8 pairs (END 0, INNER 8). Words: want, got, dodging, nothin, block, cop, flop, pop.
7. `vow:EY` — 8 pairs (END 0, INNER 8). Words: ain't, take, say, player, bloodstains, face, same.
8. `slant:AH:fric-stop` — 7 pairs (END 2, INNER 5). Words: love, suck, puppy, kentucky.
9. `slant:EH:liq-nas` — 6 pairs (END 0, INNER 6). Words: when, where, tell, many.
10. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: dropped, cop, want, flop, pop, drop.
11. `slant:AH:stop` — 5 pairs (END 3, INNER 2). Words: duppy, puppy, suck, kentucky.
12. `vow:OW` — 5 pairs (END 0, INNER 5). Words: go, focus, know, don't, roaming.
13. `cmu:IH-T` — 4 pairs (END 1, INNER 3). Words: shit, hit, lit.
14. `slant:AE:sib-stop` — 4 pairs (END 1, INNER 3). Words: ass, mask, fast, last.
15. `slant:UW:liq-sib` — 4 pairs (END 2, INNER 2). Words: rules, school, cool, shoes.
16. `vow:AH` — 4 pairs (END 0, INNER 4). Words: number, brothers, come, what, money, one.
17. `cmu:AE-K` — 3 pairs (END 1, INNER 2). Words: plaque, back, pack.
18. `cmu:OW` — 3 pairs (END 0, INNER 3). Words: know, no, go.
19. `slant:AE:liq-stop` — 3 pairs (END 2, INNER 1). Words: ndale, back, plaque, pack.
20. `slant:IH:nas-stop` — 3 pairs (END 1, INNER 2). Words: spin, lit, twin, quit, hit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ndale — 4 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- duppy — 3 pair sides, mostly spelling via spelling phonetic key, often with puppy (1)
- niggas — 2 pair sides, mostly vowel via spelling phonetic key, often with militant (1)
- rcy — 1 pair sides, mostly vowel via spelling phonetic key, often with g (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| KSI | Number 2 | 47 | 29 | 184 | loose |
