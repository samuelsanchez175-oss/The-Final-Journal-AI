# Alcy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Alcy
- Songs: 1
- Bars kept (Alcy lyric lines): 42
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Alcy.
- Credit strings: Alcy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 276
- REPEAT pairs, recorded separately: 46
- END rhymes: 51
- INNER rhymes: 225

By match:

- PERFECT: 22 (END 3, INNER 19)
- SLANT: 134 (END 28, INNER 106)
- ASSONANCE: 117 (END 20, INNER 97)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 22
- MED: 208
- LOW: 46

## Core

- Core Y: 272
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 111 (40.2%)
- vowel: 117 (42.4%)
- spelling: 45 (16.3%)
- multi: 3 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:UW` — 30 pairs (END 14, INNER 16). Words: true, move, movin, through, shoe, coolin, boo, booth.
2. `vow:EY` — 25 pairs (END 6, INNER 19). Words: chain, rain, rockaway, operate, say, gate, paved, way.
3. `slant:IH:stop` — 22 pairs (END 0, INNER 22). Words: hit, nigga, stick, pick, jigga, big, fifty, dick.
4. `slant:IH:nas-stop` — 18 pairs (END 1, INNER 17). Words: stick, i'ma, stickin, jiggin, jiggaboo, nigga, dick, him.
5. `slant:UW:fric-liq` — 15 pairs (END 7, INNER 8). Words: move, tool, fool, roof, cool, poor, school.
6. `vow:AA` — 14 pairs (END 0, INNER 14). Words: honest, got, solid, everybody, college, shots, polish, bottom.
7. `vow:AY` — 12 pairs (END 0, INNER 12). Words: like, stylist, dry, high, pilot.
8. `vow:AW` — 9 pairs (END 0, INNER 9). Words: now, pounds, touchdown, how, broward, county, down, town.
9. `vow:IH` — 9 pairs (END 0, INNER 9). Words: him, think, grippin, skippin, bitch, fifty, pick, big.
10. `slant:UW:fric-nas` — 7 pairs (END 4, INNER 3). Words: move, movin, maneuverin.
11. `slant:UW:liq-stop` — 7 pairs (END 1, INNER 6). Words: school, tool, swoop, loot, coupe, doobie, cool.
12. `vow:EH` — 6 pairs (END 0, INNER 6). Words: headin, went, where, get, let, hell, best, gettin.
13. `cmu:EY` — 5 pairs (END 1, INNER 4). Words: stay, say, away, dj, rockaway.
14. `slant:UW:liq-sib` — 5 pairs (END 3, INNER 2). Words: choose, cool, news, tool, fool, booth, poor.
15. `slant:EH:stop` — 4 pairs (END 0, INNER 4). Words: best, better, let, went.
16. `slant:UW:fric-sib` — 4 pairs (END 2, INNER 2). Words: move, choose, news.
17. `cmu:EY-T` — 3 pairs (END 1, INNER 2). Words: operate, straight, gate.
18. `slant:AA:sib-stop` — 3 pairs (END 1, INNER 2). Words: shots, got, college, solid.
19. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: damn, man, rap, kodak, had.
20. `slant:IY:liq-nas` — 3 pairs (END 0, INNER 3). Words: real, lean, tryna, being.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 13 pair sides, mostly spelling via spelling phonetic key, often with stick (13)
- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with hit (3)
- soowoo — 7 pair sides, mostly spelling via spelling phonetic key, often with booth (1)
- jiggaboo — 6 pair sides, mostly spelling via spelling phonetic key, often with true (2)
- jigga — 3 pair sides, mostly spelling via spelling phonetic key, often with pick (1)
- jiggin — 3 pair sides, mostly spelling via spelling phonetic key, often with stick (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with being (1)
- shoutout — 2 pair sides, mostly spelling via spelling phonetic key, often with broward (1)
- flocka — 2 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- doobie — 1 pair sides, mostly spelling via spelling phonetic key, often with cool (1)
- holic — 1 pair sides, mostly spelling via spelling phonetic key, often with bankroll (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with flocka (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Alcy | Stick & Move | 42 | 51 | 225 | loose |
