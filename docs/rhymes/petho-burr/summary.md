# Petho Burr rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Petho Burr
- Songs: 1
- Bars kept (Petho Burr lyric lines): 27
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Petho Burr.
- Credit strings: Petho Burr.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 124
- REPEAT pairs, recorded separately: 29
- END rhymes: 9
- INNER rhymes: 115

By match:

- PERFECT: 17 (END 5, INNER 12)
- SLANT: 41 (END 1, INNER 40)
- ASSONANCE: 66 (END 3, INNER 63)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 16
- MED: 97
- LOW: 11

## Core

- Core Y: 124
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 45 (36.3%)
- vowel: 66 (53.2%)
- spelling: 13 (10.5%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 31 pairs (END 1, INNER 30). Words: don't, go, open, over, no, yoda, know, close.
2. `vow:EY` — 12 pairs (END 1, INNER 11). Words: play, ain't, waitin, david, game, snake, day, main.
3. `cmu:OW` — 10 pairs (END 3, INNER 7). Words: go, know, show, o, no.
4. `slant:IH:sib-stop` — 7 pairs (END 0, INNER 7). Words: niggas, nigga.
5. `vow:AY` — 7 pairs (END 0, INNER 7). Words: sirens, times, applyin, terrorized, flyin, like, slidin.
6. `vow:AH` — 5 pairs (END 0, INNER 5). Words: double, cut, guts, couple, love.
7. `slant:AH:sib-stop` — 4 pairs (END 0, INNER 4). Words: cut, guts.
8. `vow:AA` — 4 pairs (END 1, INNER 3). Words: bodies, stoppin, got, drop.
9. `slant:AA:nas-sib` — 3 pairs (END 0, INNER 3). Words: cause, gonna, mama, wanna.
10. `slant:AA:nas-stop` — 3 pairs (END 0, INNER 3). Words: gotta, gonna, not, mama, wanna.
11. `slant:EY:nas-stop` — 3 pairs (END 0, INNER 3). Words: take, game, main, snake.
12. `vow:IH` — 3 pairs (END 0, INNER 3). Words: 'till, physically, sittin.
13. `cmu:AO-R` — 2 pairs (END 0, INNER 2). Words: 'fore, more.
14. `slant:AA:sib-stop` — 2 pairs (END 0, INNER 2). Words: cause, not, gotta.
15. `slant:EH:liq-stop` — 2 pairs (END 0, INNER 2). Words: get, care, chair.
16. `slant:EH:nas` — 2 pairs (END 0, INNER 2). Words: gettin, reppin.
17. `slant:IH:fric-stop` — 2 pairs (END 0, INNER 2). Words: shit, forgive, give.
18. `slant:IY:liq-stop` — 2 pairs (END 0, INNER 2). Words: keep, real.
19. `vow:AO` — 2 pairs (END 0, INNER 2). Words: all, lord.
20. `vow:EH` — 2 pairs (END 0, INNER 2). Words: sellin, gettin, get.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- niggas — 7 pair sides, mostly spelling via spelling phonetic key, often with nigga (7)
- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with niggas (7)
- reppin — 3 pair sides, mostly spelling via spelling phonetic key, often with gettin (2)
- mollies — 1 pair sides, mostly spelling via spelling phonetic key, often with bodies (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with call (1)
- nolia — 1 pair sides, mostly spelling via spelling phonetic key, often with yoda (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Petho Burr | Times Up | 27 | 9 | 115 | loose |
