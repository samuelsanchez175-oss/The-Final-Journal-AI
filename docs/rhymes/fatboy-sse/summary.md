# FatBoy SSE rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: FatBoy SSE
- Songs: 1
- Bars kept (FatBoy SSE lyric lines): 42
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: FatBoy SSE.
- Credit strings: FatBoy SSE.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 289
- REPEAT pairs, recorded separately: 76
- END rhymes: 57
- INNER rhymes: 232

By match:

- PERFECT: 21 (END 9, INNER 12)
- SLANT: 131 (END 32, INNER 99)
- ASSONANCE: 134 (END 16, INNER 118)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 24
- MED: 260
- LOW: 5

## Core

- Core Y: 289
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 147 (50.9%)
- vowel: 134 (46.4%)
- spelling: 5 (1.7%)
- multi: 3 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 28 pairs (END 4, INNER 24). Words: ain't, paid, say, days, ways, gave, wait, james.
2. `vow:EH` — 26 pairs (END 1, INNER 25). Words: selfish, never, remember, end, else, gettin, get, twelve.
3. `vow:AA` — 24 pairs (END 2, INNER 22). Words: rocket, blossom, harvest, la, harden, hard, arsonist, auction.
4. `vow:OW` — 24 pairs (END 2, INNER 22). Words: know, don't, coldest, go, toes, hoes, rollie, froze.
5. `vow:AY` — 20 pairs (END 3, INNER 17). Words: grind, like, flyer, why, fire, night, might, right.
6. `slant:EY:sib-stop` — 15 pairs (END 9, INNER 6). Words: paid, raise, days, shade, lemonade, ways.
7. `slant:AA:stop` — 13 pairs (END 1, INNER 12). Words: got, gotta, want, chopper, harvest, arsonist.
8. `slant:AY:sib-stop` — 9 pairs (END 7, INNER 2). Words: dice, ice, night, right, type.
9. `slant:EY:nas-stop` — 9 pairs (END 0, INNER 9). Words: ain't, paid, jane, plain, wait, came, plane, main.
10. `cmu:EY-D` — 7 pairs (END 4, INNER 3). Words: paid, lemonade, shade.
11. `slant:AY:fric-stop` — 7 pairs (END 6, INNER 1). Words: life, right, night, type.
12. `slant:IH:sib-stop` — 7 pairs (END 3, INNER 4). Words: bitch, shit, quick, hit, switch, rich.
13. `slant:IH:stop` — 7 pairs (END 1, INNER 6). Words: shit, quick, nigga, hip.
14. `vow:IH` — 7 pairs (END 4, INNER 3). Words: bimbos, bitch, shit, quick, switch, will, official.
15. `slant:EH:fric-sib` — 5 pairs (END 0, INNER 5). Words: pressure, never, ever.
16. `slant:AA:sib-stop` — 4 pairs (END 0, INNER 4). Words: boss, gotta.
17. `slant:AY:fric-sib` — 4 pairs (END 4, INNER 0). Words: life, dice, ice.
18. `slant:EH:fric-nas` — 4 pairs (END 0, INNER 4). Words: ten, never, ever, when.
19. `slant:EY:nas-sib` — 4 pairs (END 0, INNER 4). Words: days, james, came, main, jane, plain.
20. `vow:AH` — 4 pairs (END 0, INNER 4). Words: hustler, stomach, thug, one.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- mami — 1 pair sides, mostly spelling via spelling phonetic key, often with bad (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| FatBoy SSE | 12 Days | 42 | 57 | 232 | loose |
