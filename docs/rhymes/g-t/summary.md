# G.T. rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: G.T.
- Songs: 1
- Bars kept (G.T. lyric lines): 42
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: G.T..
- Credit strings: G.T..
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 338
- REPEAT pairs, recorded separately: 21
- END rhymes: 49
- INNER rhymes: 289

By match:

- PERFECT: 24 (END 9, INNER 15)
- SLANT: 139 (END 23, INNER 116)
- ASSONANCE: 172 (END 14, INNER 158)
- MULTI: 3 (END 3, INNER 0)

By confidence:

- HIGH: 25
- MED: 300
- LOW: 13

## Core

- Core Y: 333
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 151 (44.7%)
- vowel: 172 (50.9%)
- spelling: 12 (3.6%)
- multi: 3 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 39 pairs (END 5, INNER 34). Words: gettin, legend, better, heaven, left, very, prayers, elders.
2. `vow:EY` — 31 pairs (END 1, INNER 30). Words: ain't, day, aimin, eighth, grade, k, playin, wait.
3. `vow:AY` — 22 pairs (END 3, INNER 19). Words: pipes, rights, fightin, life, ninety, five, i'll, time.
4. `vow:IH` — 15 pairs (END 0, INNER 15). Words: since, literally, really, him, shit, spittin, tim, picture.
5. `vow:AE` — 14 pairs (END 1, INNER 13). Words: can't, family, grandma, passed, ladder, catch, raps, last.
6. `vow:OW` — 13 pairs (END 2, INNER 11). Words: home, know, don't, hold, no, told, tote, fazo.
7. `slant:EH:nas-stop` — 12 pairs (END 0, INNER 12). Words: when, better, gettin, setter, spent, send, already, twenty.
8. `slant:AA:stop` — 11 pairs (END 7, INNER 4). Words: heart, dark, hard, start, spot, drop, gotta, glock.
9. `vow:AH` — 10 pairs (END 0, INNER 10). Words: drugs, young, hundred, money, fuckin, somethin, love, crunch.
10. `vow:AO` — 10 pairs (END 0, INNER 10). Words: saw, lost, all, dog, more, before, jaw.
11. `cmu:AY-D` — 8 pairs (END 5, INNER 3). Words: beside, outside, ride, lied, divide, hide.
12. `slant:AY:nas-stop` — 8 pairs (END 5, INNER 3). Words: cryin, tryin, right, lied, outside, like, time, fightin.
13. `slant:AY:sib-stop` — 8 pairs (END 5, INNER 3). Words: fantasize, like, nikes, right, rights, lied, outside, ride.
14. `vow:AA` — 8 pairs (END 2, INNER 6). Words: spot, bought, wasn't, got, raw, dark, hard, la.
15. `slant:AH:nas` — 7 pairs (END 0, INNER 7). Words: money, run, fuckin, young.
16. `slant:AY:fric-nas` — 6 pairs (END 2, INNER 4). Words: life, cryin, tryin, five.
17. `slant:EH:stop` — 6 pairs (END 0, INNER 6). Words: shed, against, spent, better, setter, 'member, twenty, get.
18. `vow:IY` — 6 pairs (END 0, INNER 6). Words: shiesty, free, nobody, here, probably, nineteen, forty, likely.
19. `slant:AH:nas-sib` — 5 pairs (END 0, INNER 5). Words: another, money, crunch, son, run, young.
20. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: ain't, eight, cake, state, grade, wait, straight.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- dyin — 4 pair sides, mostly spelling via spelling phonetic key, often with cryin (1)
- shiesty — 4 pair sides, mostly vowel via spelling phonetic key, often with forty (1)
- fazo — 3 pair sides, mostly vowel via spelling phonetic key, often with had (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with nineteen (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with really (1)
- shiesties — 1 pair sides, mostly spelling via spelling phonetic key, often with shiesty (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| G.T. | Hold On | 42 | 49 | 289 | loose |
