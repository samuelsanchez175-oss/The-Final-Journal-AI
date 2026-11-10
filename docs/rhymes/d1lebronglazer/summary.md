# D1LebronGlazer rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: D1LebronGlazer
- Songs: 1
- Bars kept (D1LebronGlazer lyric lines): 41
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: D1LebronGlazer.
- Credit strings: D1LebronGlazer.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 299
- REPEAT pairs, recorded separately: 11
- END rhymes: 30
- INNER rhymes: 269

By match:

- PERFECT: 19 (END 9, INNER 10)
- SLANT: 141 (END 16, INNER 125)
- ASSONANCE: 129 (END 4, INNER 125)
- MULTI: 10 (END 1, INNER 9)

By confidence:

- HIGH: 26
- MED: 255
- LOW: 18

## Core

- Core Y: 295
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 146 (48.8%)
- vowel: 129 (43.1%)
- spelling: 14 (4.7%)
- multi: 10 (3.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 52 pairs (END 0, INNER 52). Words: stay, day, always, changing, laden, away, sayin, ayo.
2. `vow:IY` — 20 pairs (END 0, INNER 20). Words: feelin, shi, these, stealing, scene, received, heat, seen.
3. `vow:EH` — 16 pairs (END 0, INNER 16). Words: lebron, d1lebronglazer, lets, getting, pepper, stepper, death, better.
4. `vow:OW` — 14 pairs (END 4, INNER 10). Words: only, go, toes, hoe, blows, blowing, woken, smokin.
5. `slant:EY:nas-stop` — 13 pairs (END 2, INNER 11). Words: make, game, sayin, fake, staying, wade, take, awake.
6. `slant:EH:stop` — 9 pairs (END 0, INNER 9). Words: better, stepper, pepper, rec, wetter.
7. `slant:EY:nas` — 9 pairs (END 2, INNER 7). Words: game, fame, jane, insane, lane, playing, ain.
8. `vow:AE` — 9 pairs (END 0, INNER 9). Words: candles, cancel, ass, chattin, al, man, can't, gang.
9. `slant:EH:sib-stop` — 8 pairs (END 2, INNER 6). Words: death, better, weather, stepper, lets, pepper, rec, wetter.
10. `slant:IH:stop` — 7 pairs (END 0, INNER 7). Words: big, nigga, shit, wit, hit.
11. `slant:IY:nas-stop` — 7 pairs (END 2, INNER 5). Words: scene, nicotine, heat, cheat, keep, seen, meta, weed.
12. `slant:EY:nas-sib` — 6 pairs (END 1, INNER 5). Words: sayin, always, age, slayin, glazer, staying, game, james.
13. `slant:EY:sib-stop` — 6 pairs (END 0, INNER 6). Words: always, awake, make, age, take, glazer, fake, wade.
14. `multi:EY-IH-NG` — 5 pairs (END 0, INNER 5). Words: playin, sayin, slayin, flight playin, goat sayin, calling sayin, dont staying, staying.
15. `slant:EH:liq-stop` — 5 pairs (END 0, INNER 5). Words: bellow, head, stepper, wetter, better, tell, where.
16. `slant:IY:liq-stop` — 5 pairs (END 0, INNER 5). Words: feel, here, cheat, keep, weed, feed, seed.
17. `slant:AY:stop` — 4 pairs (END 0, INNER 4). Words: like, flight, swipe.
18. `slant:IY:nas-sib` — 4 pairs (END 0, INNER 4). Words: these, seen, nicotine, greens, scene.
19. `slant:IY:sib-stop` — 4 pairs (END 0, INNER 4). Words: these, heat, meta, weed.
20. `vow:AH` — 4 pairs (END 0, INNER 4). Words: tuggin, number, sum, fucking, front, hungry, come.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- d1lebronglazer — 4 pair sides, mostly vowel via spelling phonetic key, often with better (1)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- yall — 3 pair sides, mostly spelling via spelling phonetic key, often with feel (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with blowing (1)
- dwyane — 2 pair sides, mostly multi via spelling phonetic key, often with maryjane (2)
- maryjane — 2 pair sides, mostly multi via spelling phonetic key, often with dwyane (2)
- ain — 2 pair sides, mostly spelling via spelling phonetic key, often with playing (1)
- feins — 1 pair sides, mostly spelling via spelling phonetic key, often with dennis (1)
- dont — 1 pair sides, mostly spelling via spelling phonetic key, often with only (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| D1LebronGlazer | 16 Candles | 41 | 30 | 269 | loose |
