# Chicken P rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Chicken P
- Songs: 1
- Bars kept (Chicken P lyric lines): 64
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Chicken P.
- Credit strings: Chicken P.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 755
- REPEAT pairs, recorded separately: 50
- END rhymes: 123
- INNER rhymes: 632

By match:

- PERFECT: 51 (END 11, INNER 40)
- SLANT: 364 (END 69, INNER 295)
- ASSONANCE: 337 (END 42, INNER 295)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 52
- MED: 683
- LOW: 20

## Core

- Core Y: 752
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 395 (52.3%)
- vowel: 337 (44.6%)
- spelling: 20 (2.6%)
- multi: 3 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 94 pairs (END 0, INNER 94). Words: think, shit, drink, sippin, lil, mission, vicious, give.
2. `vow:IY` — 52 pairs (END 17, INNER 35). Words: even, bleedin, 'raq, b, week, free, demon, thirty.
3. `vow:AE` — 50 pairs (END 10, INNER 40). Words: happen, castle, tallies, can, raffle, stab, half, gangsters.
4. `vow:AH` — 39 pairs (END 14, INNER 25). Words: front, enough, truck, touched, oven, hundred, jump, cuts.
5. `slant:AE:stop` — 27 pairs (END 1, INNER 26). Words: back, racket, stab, granddaddy, adapt, can't, pack, had.
6. `vow:EH` — 24 pairs (END 0, INNER 24). Words: barely, when, sharin, get, blender, wearin, gettin, sellin.
7. `vow:AA` — 23 pairs (END 1, INNER 22). Words: gotta, pockets, dollars, dark, drop, watch, raw, arc.
8. `slant:AA:stop` — 21 pairs (END 0, INNER 21). Words: gotta, start, got, heart, arc, park, dropped, fanta.
9. `slant:AH:stop` — 21 pairs (END 10, INNER 11). Words: what, cup, fuck, crushed, butter, front, nut, truck.
10. `vow:AY` — 20 pairs (END 0, INNER 20). Words: rhymes, like, fightin, iverson, pie, pint, drive, piper.
11. `slant:IY:sib-stop` — 18 pairs (END 14, INNER 4). Words: week, breathe, z's, p's, seat, ease, asleep, meet.
12. `slant:EH:nas-stop` — 16 pairs (END 0, INNER 16). Words: when, get, many, send, red, went, 'net, ten.
13. `slant:IH:liq-stop` — 16 pairs (END 0, INNER 16). Words: really, shit, lil, big, milli, build, sit, it'd.
14. `vow:EY` — 16 pairs (END 0, INNER 16). Words: today, ain't, pay, paper, days, take, lame, made.
15. `slant:AH:sib-stop` — 15 pairs (END 11, INNER 4). Words: crush, fuck, bus, rush, what, truck, another, stuck.
16. `slant:IH:stop` — 13 pairs (END 0, INNER 13). Words: shit, brick, ticket, spit, it'd, big, hit, think.
17. `slant:IH:sib-stop` — 11 pairs (END 0, INNER 11). Words: tris, switch, shit, bitch, brick, ticket, bricks, sit.
18. `slant:IY:stop` — 11 pairs (END 5, INNER 6). Words: week, seat, meet, weed, sleep, asleep, need.
19. `vow:OW` — 11 pairs (END 0, INNER 11). Words: told, solo, broke, don't, only, brodie, noah's, bankroll.
20. `slant:AH:nas-stop` — 9 pairs (END 0, INNER 9). Words: money, truck, one, fuck, fuckin, buck, run, front.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- raq — 10 pair sides, mostly vowel via vault phonetic_class, often with week (2)
- tris — 9 pair sides, mostly spelling via spelling phonetic key, often with bitches (1)
- bling — 5 pair sides, mostly spelling via spelling phonetic key, often with bleedin (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with bricks (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with tequila (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- ballies — 1 pair sides, mostly spelling via spelling phonetic key, often with tallies (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with lil (1)
- cuz — 1 pair sides, mostly spelling via spelling phonetic key, often with another (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Chicken P | Peter Piper | 64 | 123 | 632 | loose |
