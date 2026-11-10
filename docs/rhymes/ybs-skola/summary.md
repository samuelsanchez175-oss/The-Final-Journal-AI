# YBS Skola rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: YBS Skola
- Songs: 1
- Bars kept (YBS Skola lyric lines): 36
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: YBS Skola.
- Credit strings: YBS Skola.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 203
- REPEAT pairs, recorded separately: 17
- END rhymes: 47
- INNER rhymes: 156

By match:

- PERFECT: 12 (END 5, INNER 7)
- SLANT: 96 (END 27, INNER 69)
- ASSONANCE: 90 (END 14, INNER 76)
- MULTI: 5 (END 1, INNER 4)

By confidence:

- HIGH: 14
- MED: 175
- LOW: 14

## Core

- Core Y: 201
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 95 (46.8%)
- vowel: 90 (44.3%)
- spelling: 13 (6.4%)
- multi: 5 (2.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 25 pairs (END 10, INNER 15). Words: fly, flyer, timer, time, shiner, blind, find, like.
2. `vow:EH` — 18 pairs (END 0, INNER 18). Words: checkin, when, went, pedal, federal, get, bezel, remember.
3. `slant:AY:nas` — 15 pairs (END 7, INNER 8). Words: timer, time, shiner, shine, designer, dime, line.
4. `slant:AY:nas-stop` — 15 pairs (END 10, INNER 5). Words: shine, shiner, like, blind, find, line, mind, signed.
5. `vow:AH` — 14 pairs (END 0, INNER 14). Words: bust, hundred, some, mud, double, dumpin, nothing, fuckin.
6. `vow:AA` — 6 pairs (END 0, INNER 6). Words: rockin, got, stop, want, talkin, watch.
7. `vow:AW` — 6 pairs (END 4, INNER 2). Words: down, now, rounds.
8. `vow:OW` — 6 pairs (END 0, INNER 6). Words: reload, don't, ho, broke, told, no, go, know.
9. `vow:IH` — 5 pairs (END 0, INNER 5). Words: big, eclipse, hittin, diggin, christian, risking.
10. `cmu:AY-N-D` — 4 pairs (END 4, INNER 0). Words: mind, signed, kind, blind, find.
11. `slant:AH:nas` — 4 pairs (END 0, INNER 4). Words: young, some, nothing.
12. `slant:AW:nas-stop` — 4 pairs (END 3, INNER 1). Words: down, pound, around.
13. `slant:EH:fric-stop` — 4 pairs (END 0, INNER 4). Words: bet, never, whenever, get.
14. `slant:EH:nas-stop` — 4 pairs (END 0, INNER 4). Words: when, get, bet, went.
15. `cmu:OW` — 3 pairs (END 0, INNER 3). Words: ho, go, no, know.
16. `slant:AH:fric-nas` — 3 pairs (END 0, INNER 3). Words: love, some, young.
17. `slant:AY:stop` — 3 pairs (END 3, INNER 0). Words: ride, mind, signed, kind.
18. `slant:EH:fric-liq` — 3 pairs (END 0, INNER 3). Words: somewhere, never, whenever, however.
19. `slant:EH:liq` — 3 pairs (END 3, INNER 0). Words: bezel, pedal, federal.
20. `slant:EH:liq-nas` — 3 pairs (END 0, INNER 3). Words: when, swear, somewhere.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- bezel — 5 pair sides, mostly spelling via spelling phonetic key, often with pedal (1)
- nigga — 5 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- biddies — 3 pair sides, mostly multi via spelling phonetic key, often with rollies (2)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with broke (1)
- rollies — 2 pair sides, mostly multi via spelling phonetic key, often with biddies (2)
- doin — 1 pair sides, mostly spelling via spelling phonetic key, often with boys (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| YBS Skola | Came from Nothing | 36 | 47 | 156 | loose |
