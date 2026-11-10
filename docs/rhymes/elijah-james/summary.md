# Elijah James rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Elijah James
- Songs: 1
- Bars kept (Elijah James lyric lines): 39
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Elijah James.
- Credit strings: Elijah James.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 170
- REPEAT pairs, recorded separately: 22
- END rhymes: 31
- INNER rhymes: 139

By match:

- PERFECT: 14 (END 3, INNER 11)
- SLANT: 54 (END 7, INNER 47)
- ASSONANCE: 99 (END 18, INNER 81)
- MULTI: 3 (END 3, INNER 0)

By confidence:

- HIGH: 16
- MED: 148
- LOW: 6

## Core

- Core Y: 170
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 61 (35.9%)
- vowel: 99 (58.2%)
- spelling: 7 (4.1%)
- multi: 3 (1.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 27 pairs (END 13, INNER 14). Words: alexa, extras, affection, blessed, tesla, tell, spare, next.
2. `vow:OW` — 23 pairs (END 0, INNER 23). Words: know, go, alone, roll, don't, won't, soul, going.
3. `vow:EY` — 15 pairs (END 2, INNER 13). Words: way, taste, pain, waste, ain't, grave, always, slave.
4. `vow:AA` — 6 pairs (END 0, INNER 6). Words: follow, darkness, want, god, wants.
5. `vow:AH` — 6 pairs (END 0, INNER 6). Words: nothing, suck, struggle, running, love, libs, some, enough.
6. `vow:AY` — 6 pairs (END 0, INNER 6). Words: mind, time, find, i'll, like.
7. `vow:IH` — 6 pairs (END 0, INNER 6). Words: think, will, living, different, cheers, really, clear.
8. `cmu:OW` — 5 pairs (END 0, INNER 5). Words: know, go, slow, no.
9. `slant:EY:sib-stop` — 5 pairs (END 4, INNER 1). Words: taste, chase, place, make.
10. `vow:AE` — 5 pairs (END 0, INNER 5). Words: can't, ad, gas, mad, relax, last.
11. `slant:EY:sib` — 4 pairs (END 0, INNER 4). Words: days, place, chase, always.
12. `cmu:EH-R` — 3 pairs (END 1, INNER 2). Words: spare, there, where.
13. `multi:AE-T-AH-T-UW-D` — 3 pairs (END 3, INNER 0). Words: attitude, latitude, gratitude.
14. `slant:EH:fric-liq` — 3 pairs (END 0, INNER 3). Words: every, spare, there, where.
15. `vow:AW` — 3 pairs (END 3, INNER 0). Words: now, down, bound.
16. `slant:AA:stop` — 2 pairs (END 0, INNER 2). Words: got, want, confidant.
17. `slant:AE:nas-stop` — 2 pairs (END 0, INNER 2). Words: can, can't, mad.
18. `slant:AE:stop` — 2 pairs (END 0, INNER 2). Words: can't, last.
19. `slant:AH:fric-nas` — 2 pairs (END 0, INNER 2). Words: some, love, enough.
20. `slant:AH:fric-stop` — 2 pairs (END 0, INNER 2). Words: libs, love, enough.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- libs — 4 pair sides, mostly cmu via vault phonetic_class, often with love (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with broke (1)
- ramidon — 1 pair sides, mostly spelling via spelling phonetic key, often with gon (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with here (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Elijah James | Slow Down | 39 | 31 | 139 | loose |
