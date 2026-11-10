# 310Babii rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 310Babii
- Songs: 1
- Bars kept (310Babii lyric lines): 25
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: 310Babii.
- Credit strings: 310Babii.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 173
- REPEAT pairs, recorded separately: 19
- END rhymes: 32
- INNER rhymes: 141

By match:

- PERFECT: 16 (END 7, INNER 9)
- SLANT: 111 (END 21, INNER 90)
- ASSONANCE: 46 (END 4, INNER 42)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 15
- MED: 153
- LOW: 5

## Core

- Core Y: 173
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 121 (69.9%)
- vowel: 46 (26.6%)
- spelling: 6 (3.5%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AY:fric-stop` — 13 pairs (END 10, INNER 3). Words: right, wife, life, night, pipe, inside.
2. `vow:OW` — 12 pairs (END 0, INNER 12). Words: only, post, go, over, hoes, blow, don't, told.
3. `slant:AY:sib-stop` — 10 pairs (END 4, INNER 6). Words: nice, right, night, like, pipe, inside.
4. `vow:AH` — 8 pairs (END 2, INNER 6). Words: combust, husband, somethin, fuckin, other, love, young, truck.
5. `vow:IY` — 8 pairs (END 2, INNER 6). Words: ac, eat, p, believe, these, cheese, need, treat.
6. `slant:AY:stop` — 7 pairs (END 0, INNER 7). Words: right, like, pipe, inside, night.
7. `vow:AY` — 7 pairs (END 0, INNER 7). Words: bae, right, likin, pipe, nice, wife, inside, fine.
8. `cmu:AY-T` — 6 pairs (END 4, INNER 2). Words: right, night.
9. `slant:AE:nas-sib` — 5 pairs (END 0, INNER 5). Words: ass, scam, 'gram, rather.
10. `slant:AY:nas-stop` — 5 pairs (END 0, INNER 5). Words: mine, right, night, like, inside, fine.
11. `vow:EY` — 5 pairs (END 0, INNER 5). Words: say, make, ain't, spontaneously.
12. `slant:AA:stop` — 4 pairs (END 2, INNER 2). Words: spot, dropped, cropped, blocked.
13. `slant:AH:sib-stop` — 4 pairs (END 2, INNER 2). Words: truck, much, crush, shut.
14. `slant:IY:sib-stop` — 4 pairs (END 0, INNER 4). Words: keep, these, cheese, need.
15. `slant:EH:fric-liq` — 3 pairs (END 0, INNER 3). Words: tell, whenever, ever.
16. `slant:EH:fric-nas` — 3 pairs (END 0, INNER 3). Words: when, whenever, ever.
17. `slant:EH:fric-stop` — 3 pairs (END 0, INNER 3). Words: get, ever, whenever.
18. `slant:EH:liq-nas` — 3 pairs (END 0, INNER 3). Words: tell, when.
19. `slant:IH:sib-stop` — 3 pairs (END 0, INNER 3). Words: bitch, rich, pic, shit, hit.
20. `vow:AE` — 3 pairs (END 0, INNER 3). Words: after, rap, have, 'gram.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- thot — 4 pair sides, mostly spelling via spelling phonetic key, often with over (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with only (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 310Babii | do it right | 25 | 32 | 141 | loose |
