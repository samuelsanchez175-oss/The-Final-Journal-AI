# YGG Tay rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: YGG Tay
- Songs: 1
- Bars kept (YGG Tay lyric lines): 41
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: YGG Tay.
- Credit strings: YGG Tay.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 363
- REPEAT pairs, recorded separately: 92
- END rhymes: 23
- INNER rhymes: 340

By match:

- PERFECT: 27 (END 0, INNER 27)
- SLANT: 147 (END 20, INNER 127)
- ASSONANCE: 186 (END 2, INNER 184)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 25
- MED: 328
- LOW: 10

## Core

- Core Y: 363
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 159 (43.8%)
- vowel: 186 (51.2%)
- spelling: 15 (4.1%)
- multi: 3 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 36 pairs (END 0, INNER 36). Words: blow, no, hoes, clothes, don’t, don't, known, know.
2. `vow:AH` — 33 pairs (END 0, INNER 33). Words: done, pumping, fuck, number, once, nothing, niggas, running.
3. `vow:EY` — 30 pairs (END 0, INNER 30). Words: ain’t, way, lay, savings, yay, lazy, make, crazy.
4. `vow:IH` — 18 pairs (END 0, INNER 18). Words: shit, business, think, bit, little, sipping, bricks, bitch.
5. `slant:IH:liq-stop` — 17 pairs (END 1, INNER 16). Words: little, shit, bit, lil, really, dick, lick.
6. `vow:AA` — 15 pairs (END 2, INNER 13). Words: block, shots, mops, prada, robins, problems, want, ops.
7. `slant:AH:nas` — 13 pairs (END 2, INNER 11). Words: nothing, bluffing, done, money, fucking, some, discussion, run.
8. `vow:EH` — 13 pairs (END 0, INNER 13). Words: twelve, went, bent, head, said, x, never, sellin.
9. `slant:IH:stop` — 11 pairs (END 2, INNER 9). Words: shit, nigga, lick, dick, bit.
10. `vow:AW` — 11 pairs (END 0, INNER 11). Words: now, bout, round, ounce, down.
11. `vow:AY` — 11 pairs (END 0, INNER 11). Words: why, like, hype, times, night, life, lying, lights.
12. `vow:IY` — 10 pairs (END 0, INNER 10). Words: dc, eating, these, e, sleep, even, here, need.
13. `slant:AA:stop` — 8 pairs (END 1, INNER 7). Words: got, top, not, block, copped, prada, want, cop.
14. `slant:IH:sib-stop` — 8 pairs (END 3, INNER 5). Words: bitch, shit, rich, lick, dick.
15. `cmu:IH-T` — 7 pairs (END 0, INNER 7). Words: shit, bit.
16. `slant:AH:nas-stop` — 7 pairs (END 0, INNER 7). Words: niggas, fuck, some, money, done, run, number.
17. `slant:AA:sib` — 6 pairs (END 1, INNER 5). Words: blocks, shots, ops, mops, robins, problems.
18. `slant:AA:sib-stop` — 6 pairs (END 2, INNER 4). Words: block, blocks, top, got, ops, shots, mops, cause.
19. `slant:AH:fric-stop` — 5 pairs (END 0, INNER 5). Words: love, fuck, what, enough, dub.
20. `slant:AH:nas-sib` — 5 pairs (END 0, INNER 5). Words: crush, some, done, much, once, running.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- niggas — 7 pair sides, mostly cmu via vault phonetic_class, often with fuck (1)
- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- cuffing — 4 pair sides, mostly spelling via spelling phonetic key, often with riding (2)
- nas — 1 pair sides, mostly spelling via spelling phonetic key, often with gram (1)
- hella — 1 pair sides, mostly spelling via spelling phonetic key, often with sellin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| YGG Tay | Ain’t Done Shit | 41 | 23 | 340 | loose |
