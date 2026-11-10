# Rich Brian rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rich Brian
- Songs: 1
- Bars kept (Rich Brian lyric lines): 55
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Rich Brian.
- Credit strings: Rich Brian.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 342
- REPEAT pairs, recorded separately: 26
- END rhymes: 56
- INNER rhymes: 286

By match:

- PERFECT: 30 (END 7, INNER 23)
- SLANT: 130 (END 25, INNER 105)
- ASSONANCE: 175 (END 23, INNER 152)
- MULTI: 7 (END 1, INNER 6)

By confidence:

- HIGH: 28
- MED: 293
- LOW: 21

## Core

- Core Y: 339
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 140 (40.9%)
- vowel: 175 (51.2%)
- spelling: 20 (5.8%)
- multi: 7 (2.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 49 pairs (END 7, INNER 42). Words: bitch, wrist, mission, trippin, fidget, shit, picture, didn't.
2. `vow:OW` — 27 pairs (END 6, INNER 21). Words: know, home, no, ago, own, old, smoke, both.
3. `slant:IH:stop` — 25 pairs (END 0, INNER 25). Words: shit, nigga, ticket, big, pit, hit, hip, fist.
4. `vow:IY` — 25 pairs (END 7, INNER 18). Words: adidas, leave, heated, reason, li, v, hear, here.
5. `vow:AE` — 20 pairs (END 0, INNER 20). Words: can't, savage, fast, hangin, bad, man, act, gladly.
6. `vow:AH` — 15 pairs (END 0, INNER 15). Words: wonder, what's, enough, jumpin, cut, come, drum, drums.
7. `vow:EY` — 11 pairs (END 0, INNER 11). Words: facin, say, made, baby, saint, always, save, favors.
8. `slant:IH:sib-stop` — 8 pairs (END 1, INNER 7). Words: bitch, shit, miss, city, fist, hip, rich.
9. `slant:IY:stop` — 8 pairs (END 7, INNER 1). Words: heated, beeper, eat, beat, repeat.
10. `vow:AA` — 8 pairs (END 3, INNER 5). Words: box, got, nothin, not, stop, somebody's, watchin, hop.
11. `slant:AA:stop` — 7 pairs (END 6, INNER 1). Words: not, glock, stop, hop, want.
12. `cmu:IH-P` — 6 pairs (END 0, INNER 6). Words: whip, dip, strip, trip.
13. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: go, no, though, ago.
14. `multi:IY-P-ER-Z` — 5 pairs (END 1, INNER 4). Words: keepers, creepers, jeepers, like jeepers, no keepers, jeepers creepers.
15. `slant:AA:liq-stop` — 5 pairs (END 0, INNER 5). Words: car, not, glock, hop, stop.
16. `slant:IH:nas-stop` — 5 pairs (END 0, INNER 5). Words: him, hit, sittin, dip, strip, trip.
17. `slant:IY:sib` — 5 pairs (END 4, INNER 1). Words: adidas, freezer, keepers, creepers, jeepers.
18. `slant:IY:sib-stop` — 5 pairs (END 2, INNER 3). Words: beeper, knees, keepers, creepers, jeepers, repeat, eat.
19. `cmu:IY-T` — 4 pairs (END 3, INNER 1). Words: repeat, eat, beat.
20. `slant:AE:stop` — 4 pairs (END 0, INNER 4). Words: fast, can't, act, back.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- creepers — 9 pair sides, mostly spelling via spelling phonetic key, often with jeepers (2)
- jeepers — 8 pair sides, mostly multi via spelling phonetic key, often with keepers (2)
- chigga — 3 pair sides, mostly multi via spelling phonetic key, often with nigga (2)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with home (1)
- cig — 1 pair sides, mostly spelling via spelling phonetic key, often with kid (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rich Brian | Crisis | 55 | 56 | 286 | loose |
