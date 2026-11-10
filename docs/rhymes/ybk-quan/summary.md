# YBK Quan rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: YBK Quan
- Songs: 1
- Bars kept (YBK Quan lyric lines): 8
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: YBK Quan.
- Credit strings: YBK Quan.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 236
- REPEAT pairs, recorded separately: 28
- END rhymes: 4
- INNER rhymes: 232

By match:

- PERFECT: 51 (END 2, INNER 49)
- SLANT: 111 (END 2, INNER 109)
- ASSONANCE: 71 (END 0, INNER 71)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 52
- MED: 133
- LOW: 51

## Core

- Core Y: 228
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 113 (47.9%)
- vowel: 71 (30.1%)
- spelling: 49 (20.8%)
- multi: 3 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 31 pairs (END 0, INNER 31). Words: don’t, go, smokin, lilo, those, blow, flow, fro.
2. `cmu:OW` — 25 pairs (END 1, INNER 24). Words: go, fro, low, hoe, blow, flow.
3. `slant:IH:liq-sib` — 17 pairs (END 0, INNER 17). Words: lilo, lil, bitch, kill, snitch, ditch, scritch, stitch.
4. `slant:IH:sib-stop` — 17 pairs (END 0, INNER 17). Words: shit, bitch, hit, ditch, scritch, stitch, snitch, nigga.
5. `slant:AA:stop` — 16 pairs (END 2, INNER 14). Words: got, cock, drop, block, shot, roddy, glock, swat.
6. `cmu:IH-CH` — 13 pairs (END 1, INNER 12). Words: bitch, scritch, ditch, stitch, snitch.
7. `vow:AA` — 13 pairs (END 0, INNER 13). Words: cops, ops, box, got, shot, swat, block, cock.
8. `vow:IH` — 13 pairs (END 0, INNER 13). Words: strippers, bitch, killin, ricch, shit, kill, lil, hit.
9. `vow:AH` — 12 pairs (END 0, INNER 12). Words: fuck, w, dump, what, rubbing, sucking, fucking.
10. `slant:IH:stop` — 9 pairs (END 0, INNER 9). Words: nigga, shit, hit.
11. `slant:IH:liq-stop` — 8 pairs (END 0, INNER 8). Words: shit, lilo, lil, kill, hit.
12. `slant:AH:nas-stop` — 6 pairs (END 0, INNER 6). Words: fuck, sucking, fucking.
13. `slant:IH:sib` — 6 pairs (END 0, INNER 6). Words: ricch, bitch, snitch, ditch, scritch, stitch, strippers, niggas.
14. `slant:IH:nas-sib` — 5 pairs (END 0, INNER 5). Words: spin, bitch, ditch, scritch, stitch.
15. `cmu:AA-K` — 4 pairs (END 0, INNER 4). Words: block, cock, glock.
16. `cmu:AA-T` — 3 pairs (END 0, INNER 3). Words: got, shot, swat.
17. `meta:BLK` — 3 pairs (END 0, INNER 3). Words: block, blac, black.
18. `slant:AH:stop` — 3 pairs (END 0, INNER 3). Words: fuck, what.
19. `multi:AH-K-IH-NG` — 2 pairs (END 0, INNER 2). Words: bitch sucking, don’t fucking, sucking, fucking.
20. `slant:AY:liq-stop` — 2 pairs (END 0, INNER 2). Words: like, i’ll.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- lilo — 17 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- scritch — 13 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with shit (6)
- ricch — 8 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- blac — 4 pair sides, mostly spelling via spelling phonetic key, often with block (2)
- chyna — 3 pair sides, mostly spelling via spelling phonetic key, often with real (1)
- tyga — 3 pair sides, mostly spelling via spelling phonetic key, often with real (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| YBK Quan | Black Opps | 8 | 4 | 232 | loose |
