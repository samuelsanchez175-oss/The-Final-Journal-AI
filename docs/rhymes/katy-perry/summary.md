# Katy Perry rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Katy Perry
- Songs: 2
- Bars kept (Katy Perry lyric lines): 62
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Katy Perry.
- Credit strings: Katy Perry.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 225
- REPEAT pairs, recorded separately: 21
- END rhymes: 67
- INNER rhymes: 158

By match:

- PERFECT: 22 (END 8, INNER 14)
- SLANT: 104 (END 29, INNER 75)
- ASSONANCE: 93 (END 30, INNER 63)
- MULTI: 6 (END 0, INNER 6)

By confidence:

- HIGH: 28
- MED: 189
- LOW: 8

## Core

- Core Y: 223
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 119 (52.9%)
- vowel: 93 (41.3%)
- spelling: 7 (3.1%)
- multi: 6 (2.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 18 pairs (END 9, INNER 9). Words: feelin, eat, deep, free, see, keeps, weeks, need.
2. `vow:AA` — 13 pairs (END 0, INNER 13). Words: heart, party, shopping, card, stop, wanna, body, want.
3. `slant:AA:stop` — 12 pairs (END 0, INNER 12). Words: gotta, got, heart, party, want, job, stop, body.
4. `slant:AH:nas-stop` — 12 pairs (END 0, INNER 12). Words: fuck, what, money, some, blood, come, sun, drum.
5. `vow:AY` — 12 pairs (END 11, INNER 1). Words: dimes, mind, tonight, tryin, blind, eye, time, like.
6. `vow:EY` — 11 pairs (END 0, INNER 11). Words: say, baby, wastin, take, gave, stimulate, maybe, chase.
7. `slant:AY:nas-stop` — 10 pairs (END 8, INNER 2). Words: fine, time, like, might, shine, blind, tonight, ride.
8. `vow:EH` — 10 pairs (END 1, INNER 9). Words: texts, flex, energy, destiny, never, centiped, m, temperature.
9. `slant:AA:nas-stop` — 9 pairs (END 0, INNER 9). Words: stop, wanna, amazon, gotta, got, body, want, shoppin.
10. `slant:AY:stop` — 9 pairs (END 5, INNER 4). Words: like, night, ride, tonight, mind, right, bite, might.
11. `vow:IH` — 7 pairs (END 1, INNER 6). Words: clearly, beginning, river, here's, listening, thing, bring, scripture.
12. `cmu:AY-T` — 6 pairs (END 3, INNER 3). Words: night, bite, might, right, light, tonight.
13. `slant:EY:stop` — 6 pairs (END 0, INNER 6). Words: baby, take, stimulate, maybe, make.
14. `slant:IY:sib` — 6 pairs (END 6, INNER 0). Words: dreams, jeans, keys, keeps, peace, weeks.
15. `vow:AH` — 6 pairs (END 3, INNER 3). Words: what, lovers, jump, under, come, sun, drum, motherfuckin.
16. `slant:IY:sib-stop` — 5 pairs (END 4, INNER 1). Words: peace, deep, need, keys, eat, keeps, underneath, keep.
17. `vow:OW` — 5 pairs (END 0, INNER 5). Words: know, don't, go, only, no, goes, hope.
18. `cmu:OW` — 4 pairs (END 0, INNER 4). Words: no, know, go.
19. `cmu:UW` — 4 pairs (END 1, INNER 3). Words: knew, through, true, interview, doo.
20. `multi:AA-P-IH-NG` — 4 pairs (END 0, INNER 4). Words: limit shoppin, shopping, shoppin, go shopping, paris shopping.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- centiped — 2 pair sides, mostly vowel via spelling phonetic key, often with texts (1)
- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with tryin (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with hope (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with please (1)
- dabba — 1 pair sides, mostly spelling via spelling phonetic key, often with yabba (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Katy Perry | GIMME GIMME | 33 | 53 | 89 | loose |
| Katy Perry | Legendary Lovers (Save Me) | 29 | 14 | 69 | loose |
