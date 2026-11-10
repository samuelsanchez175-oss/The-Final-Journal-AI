# B La B rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: B La B
- Songs: 1
- Bars kept (B La B lyric lines): 55
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: B La B.
- Credit strings: B La B.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 291
- REPEAT pairs, recorded separately: 27
- END rhymes: 47
- INNER rhymes: 244

By match:

- PERFECT: 31 (END 8, INNER 23)
- SLANT: 105 (END 18, INNER 87)
- ASSONANCE: 150 (END 20, INNER 130)
- MULTI: 5 (END 1, INNER 4)

By confidence:

- HIGH: 30
- MED: 252
- LOW: 9

## Core

- Core Y: 287
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 125 (43.0%)
- vowel: 150 (51.5%)
- spelling: 11 (3.8%)
- multi: 5 (1.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 30 pairs (END 0, INNER 30). Words: flyer, lights, kind, piped, i'll, guys, like, ice.
2. `vow:EH` — 26 pairs (END 3, INNER 23). Words: get, recipe, pedestrian, regular, x, let, specialty, best.
3. `vow:OW` — 16 pairs (END 0, INNER 16). Words: no, don't, smoking, own, whole, gold, roll, dope.
4. `vow:AE` — 14 pairs (END 3, INNER 11). Words: stacks, swag, magic, can, racks, cash, mad, ass.
5. `slant:AY:sib-stop` — 12 pairs (END 0, INNER 12). Words: lights, flight, kite, guys, ice, pipe, fight.
6. `vow:EY` — 12 pairs (END 1, INNER 11). Words: came, patient, change, sunday, ain't, birthday, make, pay.
7. `vow:AH` — 11 pairs (END 8, INNER 3). Words: luxury, guns, touching, nut, fuck, fucking, couple, drum.
8. `vow:IY` — 11 pairs (END 2, INNER 9). Words: company, beast, these, streets, eating, fuckery, meal, team.
9. `vow:AO` — 10 pairs (END 3, INNER 7). Words: walk, important, foreign, jordan, recording, all, balling, fours.
10. `cmu:OW` — 9 pairs (END 3, INNER 6). Words: blow, no, though, go.
11. `slant:AO:nas` — 8 pairs (END 5, INNER 3). Words: foreign, jordan, balling, recording, morning.
12. `vow:IH` — 8 pairs (END 0, INNER 8). Words: dripping, think, finish, bitch, ticket, switch, miss, hit.
13. `slant:AY:stop` — 7 pairs (END 0, INNER 7). Words: piped, pipe, flight, kite, fight.
14. `slant:EH:stop` — 7 pairs (END 3, INNER 4). Words: best, get, recipe, specialty, let.
15. `vow:AA` — 7 pairs (END 0, INNER 7). Words: large, want, got, god, wanna, margiela, r, watching.
16. `slant:AE:sib-stop` — 6 pairs (END 1, INNER 5). Words: ass, rapper, trappers, act, stacks, cash, mad, fat.
17. `multi:EH-L-IY` — 5 pairs (END 1, INNER 4). Words: jelly, kelly, no jelly, belly, r kelly, large belly.
18. `slant:AA:liq-sib` — 5 pairs (END 4, INNER 1). Words: car, bars, stars, r, large.
19. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: got, want, gotta, knock.
20. `slant:AH:nas` — 4 pairs (END 2, INNER 2). Words: drum, young, one, dumb, touching, fucking.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- fuckery — 4 pair sides, mostly vowel via spelling phonetic key, often with company (2)
- swag — 3 pair sides, mostly vowel via vault phonetic_class, often with magic (1)
- stunting — 3 pair sides, mostly spelling via spelling phonetic key, often with having (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with only (1)
- margiela — 1 pair sides, mostly vowel via spelling phonetic key, often with wanna (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with shit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| B La B | Sunday Morning | 55 | 47 | 244 | loose |
