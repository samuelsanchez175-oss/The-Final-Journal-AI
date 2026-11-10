# Yuno Miles rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Yuno Miles
- Songs: 1
- Bars kept (Yuno Miles lyric lines): 44
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Yuno Miles.
- Credit strings: Yuno Miles.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 260
- REPEAT pairs, recorded separately: 45
- END rhymes: 96
- INNER rhymes: 164

By match:

- PERFECT: 44 (END 24, INNER 20)
- SLANT: 79 (END 24, INNER 55)
- ASSONANCE: 132 (END 46, INNER 86)
- MULTI: 5 (END 2, INNER 3)

By confidence:

- HIGH: 48
- MED: 205
- LOW: 7

## Core

- Core Y: 257
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 119 (45.8%)
- vowel: 132 (50.8%)
- spelling: 4 (1.5%)
- multi: 5 (1.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 86 pairs (END 45, INNER 41). Words: show, know, don't, open, closed, volvo, nose, bro.
2. `cmu:OW` — 27 pairs (END 19, INNER 8). Words: show, go, dough, no, slow, flow, know, bro.
3. `slant:OW:stop` — 12 pairs (END 5, INNER 7). Words: note, don't, most, toast, coat, don’t, tightrope, soap.
4. `vow:EH` — 11 pairs (END 0, INNER 11). Words: girlfriend, legs, twenty, twelve, every, em, friends, left.
5. `vow:IH` — 11 pairs (END 0, INNER 11). Words: minutes, city, listen, hit, switchin, link, until, really.
6. `slant:OW:sib-stop` — 9 pairs (END 9, INNER 0). Words: choase, close, hoes, tightrope, note, closed, soap, most.
7. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: got, gotta, top, not, want, bought.
8. `slant:AO:liq-nas` — 6 pairs (END 5, INNER 1). Words: long, delorean, more, floor, before, mor.
9. `slant:AY:fric-stop` — 6 pairs (END 0, INNER 6). Words: drive, might, like, life.
10. `cmu:AO-R` — 5 pairs (END 2, INNER 3). Words: more, mor, before, floor.
11. `cmu:AY-T` — 5 pairs (END 0, INNER 5). Words: right, tonight, might.
12. `cmu:AA-T` — 4 pairs (END 0, INNER 4). Words: got, not.
13. `multi:EH-N-T-IY-M-AO-R` — 4 pairs (END 1, INNER 3). Words: twenty more, twenty mor.
14. `slant:AA:nas-stop` — 4 pairs (END 0, INNER 4). Words: wanna, bought, gotta, gonna.
15. `vow:AA` — 4 pairs (END 0, INNER 4). Words: toppin, got, gotta.
16. `vow:AO` — 4 pairs (END 1, INNER 3). Words: saw, delorean, slaughter, floor, before, long.
17. `vow:AY` — 4 pairs (END 0, INNER 4). Words: by, right, tonight, might, like, tri.
18. `vow:IY` — 4 pairs (END 0, INNER 4). Words: twenty, nty, these, free.
19. `slant:AO:liq-stop` — 3 pairs (END 2, INNER 1). Words: slaughter, more, floor, before.
20. `slant:EH:stop` — 3 pairs (END 0, INNER 3). Words: met, twenty, left, get, ready.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- choase — 4 pair sides, mostly spelling via spelling phonetic key, often with note (1)
- nty — 3 pair sides, mostly vowel via spelling phonetic key, often with twenty (3)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Yuno Miles | 20 Min Remix | 44 | 96 | 164 | loose |
