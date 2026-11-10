# NBA KD rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: NBA KD
- Songs: 1
- Bars kept (NBA KD lyric lines): 46
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: NBA KD.
- Credit strings: NBA KD.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 252
- REPEAT pairs, recorded separately: 20
- END rhymes: 64
- INNER rhymes: 188

By match:

- PERFECT: 16 (END 7, INNER 9)
- SLANT: 125 (END 24, INNER 101)
- ASSONANCE: 109 (END 33, INNER 76)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 18
- MED: 212
- LOW: 22

## Core

- Core Y: 250
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 121 (48.0%)
- vowel: 109 (43.3%)
- spelling: 20 (7.9%)
- multi: 2 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 39 pairs (END 13, INNER 26). Words: go, don’t, know, no, told, hoes, toes, pole.
2. `vow:EH` — 22 pairs (END 12, INNER 10). Words: helpin, left, vest, myself, never, step, flex, ever.
3. `slant:AA:stop` — 20 pairs (END 2, INNER 18). Words: everybody, got, block, rocket, not, gotta, top, opp.
4. `slant:AA:nas-stop` — 11 pairs (END 0, INNER 11). Words: momma, wanna, got, knock, lotta, gotta, not, block.
5. `vow:AE` — 11 pairs (END 7, INNER 4). Words: stranded, abandoned, strap, sack, back, mad, straps, racks.
6. `vow:EY` — 10 pairs (END 0, INNER 10). Words: ain’t, play, came, always, facin, make.
7. `slant:EH:stop` — 9 pairs (END 8, INNER 1). Words: tec, step, set, felt, wet, left, vest, kept.
8. `slant:AH:fric-nas` — 8 pairs (END 0, INNER 8). Words: love, come, run, some, everyone, done.
9. `slant:OW:nas-stop` — 8 pairs (END 0, INNER 8). Words: don’t, gon, alone, float, broke.
10. `vow:AA` — 7 pairs (END 1, INNER 6). Words: cops, talkin, momma, everybody, block, knock, opp, top.
11. `vow:IH` — 6 pairs (END 0, INNER 6). Words: thinkin, kilt, give, years, still, till, kill.
12. `vow:IY` — 6 pairs (END 0, INNER 6). Words: even, feel, prolly, streets, everybody, navy, see, beef.
13. `slant:AH:nas` — 5 pairs (END 0, INNER 5). Words: come, run, everyone, some.
14. `slant:OW:liq-stop` — 5 pairs (END 2, INNER 3). Words: pole, told, whole, float, broke, road.
15. `slant:OW:sib-stop` — 5 pairs (END 3, INNER 2). Words: toes, float, hoes, broke, road.
16. `slant:IH:liq-nas` — 4 pairs (END 0, INNER 4). Words: i’ma, till, kill.
17. `slant:OW:stop` — 4 pairs (END 0, INNER 4). Words: float, don’t, broke, road, told.
18. `cmu:AW-N` — 3 pairs (END 3, INNER 0). Words: down, clown, frown.
19. `cmu:OW` — 3 pairs (END 0, INNER 3). Words: know, go.
20. `slant:AE:stop` — 3 pairs (END 3, INNER 0). Words: strap, sack, back, stranded, abandoned.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 9 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with give (3)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with real (2)
- prolly — 2 pair sides, mostly vowel via spelling phonetic key, often with navy (1)
- nawf — 1 pair sides, mostly spelling via spelling phonetic key, often with water (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| NBA KD | Realize | 46 | 64 | 188 | loose |
