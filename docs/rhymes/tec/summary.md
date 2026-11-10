# TEC rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: TEC
- Songs: 2
- Bars kept (TEC lyric lines): 76
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: TEC.
- Credit strings: TEC.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 733
- REPEAT pairs, recorded separately: 57
- END rhymes: 137
- INNER rhymes: 596

By match:

- PERFECT: 62 (END 18, INNER 44)
- SLANT: 276 (END 49, INNER 227)
- ASSONANCE: 392 (END 70, INNER 322)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 61
- MED: 651
- LOW: 21

## Core

- Core Y: 729
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 317 (43.2%)
- vowel: 392 (53.5%)
- spelling: 21 (2.9%)
- multi: 3 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 91 pairs (END 6, INNER 85). Words: ain't, say, flavors, papers, patience, taste, occasion, maintenance.
2. `vow:IY` — 69 pairs (END 37, INNER 32). Words: streets, free, p, dreams, seeds, creams, three, reefer.
3. `vow:AY` — 58 pairs (END 20, INNER 38). Words: high, like, guy, died, vibes, die, cry, might.
4. `vow:AA` — 41 pairs (END 4, INNER 37). Words: rollin, marley, armed, bob, narcotics, robberies, droppin, shoppin.
5. `vow:OW` — 41 pairs (END 1, INNER 40). Words: don't, no, smoke, know, showin, coke, 'posed, slow.
6. `vow:EH` — 35 pairs (END 0, INNER 35). Words: get, else, evidence, there, gettin, energy, benz, vegan.
7. `vow:AE` — 23 pairs (END 0, INNER 23). Words: ask, jacket, trappin, montana, slammer, answers, hands, bad.
8. `slant:AA:stop` — 16 pairs (END 0, INNER 16). Words: got, hot, want, block, opp, not, gotta, drop.
9. `slant:IY:fric-stop` — 15 pairs (END 9, INNER 6). Words: keef, leave, reefer, keep, cheap, sleep, weak, street.
10. `slant:IY:stop` — 15 pairs (END 11, INNER 4). Words: week, weak, street, jeep, creep, meat, deep, reaper.
11. `slant:AY:stop` — 14 pairs (END 4, INNER 10). Words: like, right, died, backfired, ride, might, tight, vibe.
12. `vow:AH` — 13 pairs (END 2, INNER 11). Words: hundred, under, come, somethin, front, cut, run, plug.
13. `vow:IH` — 13 pairs (END 0, INNER 13). Words: mr, missiles, bitch, stick, askin, think, chiefin, killed.
14. `cmu:AY` — 12 pairs (END 3, INNER 9). Words: guy, high, die, eye, why, cry.
15. `slant:IY:liq-nas` — 10 pairs (END 3, INNER 7). Words: real, here, feel, mean, seen, green, team, feeling.
16. `slant:IY:sib-stop` — 9 pairs (END 4, INNER 5). Words: breather, creep, meat, street, p's, knees, heaters, deep.
17. `slant:AE:nas-stop` — 8 pairs (END 0, INNER 8). Words: man, bad, mad, can, bag, back, had, ran.
18. `cmu:OW` — 7 pairs (END 1, INNER 6). Words: know, hello, o, slow, bro.
19. `slant:AO:liq-nas` — 7 pairs (END 0, INNER 7). Words: gone, before, pour, four, more, belong, all.
20. `slant:EH:liq-stop` — 7 pairs (END 0, INNER 7). Words: tell, get, met, there, head, check, yellow, wet.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- dawg — 9 pair sides, mostly spelling via spelling phonetic key, often with gone (3)
- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with him (2)
- cleavers — 3 pair sides, mostly vowel via spelling phonetic key, often with breather (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with stick (1)
- chiefin — 2 pair sides, mostly vowel via spelling phonetic key, often with bitch (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with ass (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| TEC | Bad Guy | 31 | 30 | 250 | loose |
| TEC | Marley Vibez | 45 | 107 | 346 | loose |
