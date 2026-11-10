# John Wicks rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: John Wicks
- Songs: 3
- Bars kept (John Wicks lyric lines): 111
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: John Wicks.
- Credit strings: John Wicks.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 638
- REPEAT pairs, recorded separately: 69
- END rhymes: 124
- INNER rhymes: 514

By match:

- PERFECT: 41 (END 5, INNER 36)
- SLANT: 246 (END 60, INNER 186)
- ASSONANCE: 343 (END 54, INNER 289)
- MULTI: 8 (END 5, INNER 3)

By confidence:

- HIGH: 48
- MED: 538
- LOW: 52

## Core

- Core Y: 620
- Core N among rhyme pairs: 18

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 252 (39.5%)
- vowel: 343 (53.8%)
- spelling: 35 (5.5%)
- multi: 8 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 78 pairs (END 6, INNER 72). Words: go, don't, roll, know, holdin, hold, no, boat.
2. `vow:IY` — 67 pairs (END 16, INNER 51). Words: z, zebra, beast, illegal, vini, si, te, real.
3. `vow:EY` — 50 pairs (END 13, INNER 37). Words: ain't, spray, baby, crazy, say, take, lazy, related.
4. `vow:IH` — 49 pairs (END 3, INNER 46). Words: different, wick's, i'mma, nigga, niggas, imma, shit, mr.
5. `slant:EY:stop` — 30 pairs (END 12, INNER 18). Words: haiti, lady, baby, take, chased, eighty, ate, related.
6. `vow:AA` — 20 pairs (END 6, INNER 14). Words: regardless, pa, pardon, artist, john, hard, got, sorry.
7. `vow:AE` — 18 pairs (END 1, INNER 17). Words: grandma, back, catch, hand, masked, had, bag, man.
8. `slant:AE:stop` — 17 pairs (END 0, INNER 17). Words: back, had, bag, strap, track, act, swag, jaab.
9. `vow:AH` — 17 pairs (END 1, INNER 16). Words: hundred, nothing, fucking, love, doubling, funds, months, trump.
10. `vow:EH` — 17 pairs (END 0, INNER 17). Words: heaven, left, when, getting, stepped, said, belly, hell.
11. `slant:AW:nas-stop` — 16 pairs (END 8, INNER 8). Words: town, down, around, sound, bout, ground.
12. `slant:EY:sib-stop` — 16 pairs (END 10, INNER 6). Words: crazy, lazy, haiti, take, lady, baby, eighty.
13. `slant:IH:stop` — 12 pairs (END 0, INNER 12). Words: shit, nigga, city, big, mr, wit, quick, wrist.
14. `slant:OW:liq-nas` — 11 pairs (END 0, INNER 11). Words: roll, rolling, stone, gon, home.
15. `cmu:OW` — 10 pairs (END 0, INNER 10). Words: go, know, kilo, 'no, no, overflow.
16. `vow:AW` — 10 pairs (END 5, INNER 5). Words: rounds, town, bout, down, around, how.
17. `slant:IH:sib-stop` — 9 pairs (END 0, INNER 9). Words: niggas, nigga, bitch, big.
18. `vow:AY` — 9 pairs (END 1, INNER 8). Words: behind, like, y, sniper, times, life, christ, eyes.
19. `cmu:EH-L` — 7 pairs (END 2, INNER 5). Words: well, fell, hotel.
20. `slant:AO:liq-nas` — 7 pairs (END 0, INNER 7). Words: gone, y'all, small, story, glory, purgatory, fall, before.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 21 pair sides, mostly spelling via spelling phonetic key, often with niggas (8)
- niggas — 16 pair sides, mostly spelling via spelling phonetic key, often with nigga (8)
- imma — 14 pair sides, mostly vowel via spelling phonetic key, often with nigga (7)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with roll (3)
- swag — 5 pair sides, mostly spelling via spelling phonetic key, often with bat (1)
- cuz — 4 pair sides, mostly spelling via spelling phonetic key, often with love (2)
- jaab — 2 pair sides, mostly spelling via spelling phonetic key, often with back (2)
- papi — 2 pair sides, mostly spelling via spelling phonetic key, often with clappin (1)
- selavi — 1 pair sides, mostly vowel via spelling phonetic key, often with mezanmi (1)
- mezanmi — 1 pair sides, mostly vowel via spelling phonetic key, often with selavi (1)
- gonaive — 1 pair sides, mostly vowel via spelling phonetic key, often with hope (1)
- lyin — 1 pair sides, mostly vowel via vault phonetic_class, often with sweeter (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| John Wicks | Haiti | 37 | 44 | 162 | loose |
| John Wicks | Haiti (Remix) | 34 | 21 | 130 | loose |
| John Wicks | Zebra | 40 | 59 | 222 | loose |
