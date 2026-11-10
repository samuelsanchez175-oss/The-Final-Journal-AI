# Chuckyy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Chuckyy
- Songs: 1
- Bars kept (Chuckyy lyric lines): 73
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Chuckyy.
- Credit strings: Chuckyy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 443
- REPEAT pairs, recorded separately: 72
- END rhymes: 84
- INNER rhymes: 359

By match:

- PERFECT: 36 (END 7, INNER 29)
- SLANT: 168 (END 29, INNER 139)
- ASSONANCE: 238 (END 47, INNER 191)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 32
- MED: 401
- LOW: 10

## Core

- Core Y: 439
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 193 (43.6%)
- vowel: 238 (53.7%)
- spelling: 11 (2.5%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 61 pairs (END 18, INNER 43). Words: like, diamonds, kind, time, pilot, by, guy, tie.
2. `vow:EY` — 46 pairs (END 23, INNER 23). Words: chains, pastry, baby, say, relations, game, rabies, hatin.
3. `vow:OW` — 37 pairs (END 0, INNER 37). Words: don't, know, told, hoes, no, shoulder, code, only.
4. `vow:AH` — 18 pairs (END 2, INNER 16). Words: somethin, puttin, crutch, money, trucks, cut, fucks, butts.
5. `vow:IH` — 16 pairs (END 0, INNER 16). Words: six, spittin, rings, wrist, shit, really, bitch, jiffy.
6. `vow:IY` — 16 pairs (END 0, INNER 16). Words: these, even, need, probably, see, shawty, suv, speakin.
7. `slant:AY:nas-stop` — 13 pairs (END 6, INNER 7). Words: time, sunshine, like, bright, light, kind, side, nine.
8. `vow:EH` — 12 pairs (END 0, INNER 12). Words: spend, there's, ke, neck, m, tell, left, ten.
9. `vow:AE` — 11 pairs (END 2, INNER 9). Words: can't, had, imax, hat, bags, stand, ballin, bank.
10. `slant:AA:nas-stop` — 8 pairs (END 0, INNER 8). Words: wanna, got, lot, pop.
11. `slant:EY:stop` — 8 pairs (END 3, INNER 5). Words: baby, ate, eighty, taped, maybe, wake, make.
12. `vow:AA` — 8 pairs (END 0, INNER 8). Words: startin, not, talkin, sharkin, pop, apart, wanna, got.
13. `slant:EY:nas-stop` — 7 pairs (END 1, INNER 6). Words: take, same, game, eighty, hatin, tame, make, wake.
14. `slant:IH:liq-nas` — 7 pairs (END 0, INNER 7). Words: fin, lil, really, kill, killin, ring.
15. `slant:IY:stop` — 7 pairs (END 0, INNER 7). Words: keep, freak, cheat, need.
16. `vow:UW` — 7 pairs (END 0, INNER 7). Words: two, cool, uzi, dude, shooters, moon, flu.
17. `slant:AH:nas` — 6 pairs (END 0, INNER 6). Words: money, fuckin, run, one, done.
18. `slant:AY:stop` — 6 pairs (END 4, INNER 2). Words: like, kind, tired, fried, might, side, island, pilot.
19. `slant:AY:fric-stop` — 5 pairs (END 2, INNER 3). Words: like, life, five, tired, fried.
20. `slant:AY:nas` — 5 pairs (END 3, INNER 2). Words: time, stylin, buyin, nine, sunshine, wildin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- lyin — 5 pair sides, mostly spelling via spelling phonetic key, often with vibin (1)
- shawty — 3 pair sides, mostly vowel via spelling phonetic key, often with money (2)
- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- vibin — 2 pair sides, mostly spelling via spelling phonetic key, often with lyin (1)
- chainz — 2 pair sides, mostly spelling via spelling phonetic key, often with chains (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- fre — 1 pair sides, mostly vowel via spelling phonetic key, often with ke (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Chuckyy | All In* | 73 | 84 | 359 | loose |
