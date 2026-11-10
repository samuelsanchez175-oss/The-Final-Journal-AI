# Finesse2Tymes rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Finesse2Tymes
- Songs: 1
- Bars kept (Finesse2Tymes lyric lines): 46
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Finesse2Tymes.
- Credit strings: Finesse2Tymes.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 409
- REPEAT pairs, recorded separately: 13
- END rhymes: 49
- INNER rhymes: 360

By match:

- PERFECT: 14 (END 4, INNER 10)
- SLANT: 203 (END 27, INNER 176)
- ASSONANCE: 191 (END 17, INNER 174)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 15
- MED: 379
- LOW: 15

## Core

- Core Y: 406
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 205 (50.1%)
- vowel: 191 (46.7%)
- spelling: 12 (2.9%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 36 pairs (END 8, INNER 28). Words: spinnin, shit, killers, hideous, crips, really, cities, bring.
2. `vow:IY` — 34 pairs (END 6, INNER 28). Words: even, frequency, meeting, see, p, recently, keep, believe.
3. `vow:AH` — 33 pairs (END 0, INNER 33). Words: hundred, double, fuck, front, sluts, cut, runnin, fucked.
4. `vow:AA` — 29 pairs (END 1, INNER 28). Words: nothin, problems, solve, bond, bodies, r, pocket, swapped.
5. `slant:IY:sib-stop` — 26 pairs (END 9, INNER 17). Words: piece, keep, deep, these, cheese, either, felicia, cease.
6. `vow:EY` — 25 pairs (END 0, INNER 25). Words: ain't, same, way, baby, day, takin, say, haters.
7. `slant:IH:liq-stop` — 14 pairs (END 0, INNER 14). Words: shit, really, lil, year, tip, mil, city, dear.
8. `vow:AE` — 14 pairs (END 2, INNER 12). Words: santa, can't, gangster, ass, have, back, can, romantic.
9. `slant:IY:stop` — 12 pairs (END 7, INNER 5). Words: deep, keep, compete, freak, cheaper, juanita, street, concrete.
10. `slant:IH:stop` — 9 pairs (END 0, INNER 9). Words: shit, nigga, lit, clip, city, fifty, desist, tip.
11. `vow:AW` — 9 pairs (END 0, INNER 9). Words: now, around, 'bout, count, mouth, thousand, south, 'round.
12. `slant:AA:stop` — 8 pairs (END 2, INNER 6). Words: stop, rocket, profit, pocket, top, got, swapped, bought.
13. `slant:AE:nas-stop` — 8 pairs (END 1, INNER 7). Words: back, rapper, savannah, man, miami, santa, camera, slammer.
14. `slant:IY:fric-stop` — 8 pairs (END 0, INNER 8). Words: beef, heat, street, concrete, sweet, deep, compete, freak.
15. `slant:AE:nas` — 7 pairs (END 3, INNER 4). Words: slammer, man, miami, savannah, camera, bangin, can, gang.
16. `vow:EH` — 7 pairs (END 0, INNER 7). Words: memphis, said, tell, left, went, send, set.
17. `slant:AA:liq-stop` — 6 pairs (END 0, INNER 6). Words: r, sorry, stop, got, bought, marco, shot.
18. `slant:AH:nas-stop` — 6 pairs (END 0, INNER 6). Words: fuck, duckin, come, dub, fuckin, one.
19. `slant:EY:nas-stop` — 6 pairs (END 0, INNER 6). Words: make, same, baby, takin, rain, paid.
20. `slant:IH:liq` — 6 pairs (END 0, INNER 6). Words: lil, really, dear, year.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- luh — 2 pair sides, mostly spelling via spelling phonetic key, often with one (1)
- turnt — 2 pair sides, mostly vowel via spelling phonetic key, often with club (1)
- realest — 1 pair sides, mostly vowel via spelling phonetic key, often with concrete (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Finesse2Tymes | Miami with the Heat | 46 | 49 | 360 | loose |
