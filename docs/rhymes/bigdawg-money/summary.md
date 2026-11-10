# BigDawg Money rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: BigDawg Money
- Songs: 1
- Bars kept (BigDawg Money lyric lines): 37
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: BigDawg Money.
- Credit strings: BigDawg Money.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 367
- REPEAT pairs, recorded separately: 21
- END rhymes: 82
- INNER rhymes: 285

By match:

- PERFECT: 38 (END 12, INNER 26)
- SLANT: 140 (END 38, INNER 102)
- ASSONANCE: 187 (END 30, INNER 157)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 40
- MED: 316
- LOW: 11

## Core

- Core Y: 365
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 169 (46.0%)
- vowel: 187 (51.0%)
- spelling: 9 (2.5%)
- multi: 2 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 123 pairs (END 26, INNER 97). Words: know, go, no, broke, mo, don't, sold, hoe.
2. `slant:OW:liq-stop` — 39 pairs (END 20, INNER 19). Words: cola, roll, smoke, soda, stroller, bipolar, october, sober.
3. `cmu:OW` — 30 pairs (END 10, INNER 20). Words: go, mo, blow, no, flow, know, though, toe.
4. `slant:OW:stop` — 20 pairs (END 6, INNER 14). Words: coca, code, coke, soda, throat, minnesota, sold, broke.
5. `vow:IY` — 14 pairs (END 0, INNER 14). Words: v, z, bein, jeans, weak, feelin, see, keep.
6. `vow:EY` — 11 pairs (END 0, INNER 11). Words: way, takin, ain't, same, brain, planes, always, take.
7. `slant:OW:liq` — 10 pairs (END 5, INNER 5). Words: stroller, bipolar, cola, roll, pole, only.
8. `slant:OW:nas-stop` — 6 pairs (END 0, INNER 6). Words: gon, broke, tone, boat, sober, minnesota, spoken.
9. `slant:OW:sib-stop` — 6 pairs (END 0, INNER 6). Words: broke, hoes, rose, dope, boat.
10. `vow:AY` — 6 pairs (END 0, INNER 6). Words: lie, might, diamonds, grindin, life.
11. `vow:AE` — 5 pairs (END 0, INNER 5). Words: can't, hang, gang'll, gang.
12. `vow:AH` — 5 pairs (END 0, INNER 5). Words: hustle, come, jungle, some, young, bubble.
13. `vow:EH` — 5 pairs (END 0, INNER 5). Words: never, gettin, went, area, every, spend.
14. `slant:OW:liq-sib` — 4 pairs (END 0, INNER 4). Words: rose, soul, bankroll.
15. `vow:AO` — 4 pairs (END 0, INNER 4). Words: jaw, ball, fall, all, fort, wanted.
16. `vow:IH` — 4 pairs (END 0, INNER 4). Words: still, bitches, addicted, shit.
17. `vow:OY` — 4 pairs (END 4, INNER 0). Words: boy, royce.
18. `slant:OW:fric-stop` — 3 pairs (END 3, INNER 0). Words: over, october, sober, minnesota.
19. `vow:AA` — 3 pairs (END 0, INNER 3). Words: talkin, want, raw, not, block, bottom.
20. `cmu:IY` — 2 pairs (END 0, INNER 2). Words: v, z, ap, see.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with sober (1)
- thes — 2 pair sides, mostly spelling via spelling phonetic key, often with when (1)
- gangll — 2 pair sides, mostly vowel via spelling phonetic key, often with cant (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with dream (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| BigDawg Money | Coke Flow | 37 | 82 | 285 | loose |
