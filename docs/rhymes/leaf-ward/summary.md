# Leaf Ward rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Leaf Ward
- Songs: 1
- Bars kept (Leaf Ward lyric lines): 56
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Leaf Ward.
- Credit strings: Leaf Ward.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 283
- REPEAT pairs, recorded separately: 16
- END rhymes: 95
- INNER rhymes: 188

By match:

- PERFECT: 67 (END 35, INNER 32)
- SLANT: 96 (END 28, INNER 68)
- ASSONANCE: 116 (END 28, INNER 88)
- MULTI: 4 (END 4, INNER 0)

By confidence:

- HIGH: 70
- MED: 198
- LOW: 15

## Core

- Core Y: 280
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 149 (52.7%)
- vowel: 116 (41.0%)
- spelling: 14 (4.9%)
- multi: 4 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 40 pairs (END 9, INNER 31). Words: like, irish, by, virus, island, stripes, nights, cyrus.
2. `vow:EY` — 31 pairs (END 13, INNER 18). Words: say, gravy, babies, day, chasing, paper, taste, rate.
3. `cmu:AH-T` — 22 pairs (END 10, INNER 12). Words: mutt, what, slut, gut, shut, hut, cut, nut.
4. `vow:OW` — 18 pairs (END 1, INNER 17). Words: know, clothes, show, road, known, go, poles, roll.
5. `cmu:EY-T` — 16 pairs (END 10, INNER 6). Words: great, rate, date, relate, plate, state, fate.
6. `slant:AY:stop` — 13 pairs (END 3, INNER 10). Words: pipe, might, like, right, divide, side, night, kite.
7. `slant:IH:stop` — 12 pairs (END 1, INNER 11). Words: nigga, hit, sllide, flip, fifty, shit, shift.
8. `cmu:AY-T` — 10 pairs (END 7, INNER 3). Words: kite, might, hight, spite, white, night, flight, light.
9. `vow:IH` — 10 pairs (END 1, INNER 9). Words: eyelids, fifty, diss, shit, living, killers, bring, flip.
10. `cmu:AE-D` — 8 pairs (END 6, INNER 2). Words: sad, vlad, bad, dad, had.
11. `slant:AY:fric-stop` — 7 pairs (END 5, INNER 2). Words: life, pipe, night, kite, spite, might, hight, wipe.
12. `slant:EY:stop` — 6 pairs (END 0, INNER 6). Words: make, rate, state, date, great, relate, take, basic.
13. `vow:AE` — 6 pairs (END 4, INNER 2). Words: grabs, dad, sad, vlad, had, tagged, snatching, grab.
14. `slant:AE:stop` — 5 pairs (END 2, INNER 3). Words: tagged, had, sad, vlad, can't, pationt, act.
15. `slant:OW:sib` — 5 pairs (END 5, INNER 0). Words: clothes, chose, poles, souls.
16. `slant:AY:sib` — 4 pairs (END 2, INNER 2). Words: irish, cyrus, nights, virus.
17. `slant:AY:sib-stop` — 4 pairs (END 0, INNER 4). Words: eyes, decide, right, side, divide.
18. `slant:IH:sib-stop` — 4 pairs (END 0, INNER 4). Words: bitch, hit, niggas, nigga, sllide, diss, shit.
19. `cmu:AY-D` — 3 pairs (END 1, INNER 2). Words: decide, side, divide.
20. `multi:EY-S-IH-NG` — 3 pairs (END 3, INNER 0). Words: racing, pasing, chasing.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 9 pair sides, mostly spelling via spelling phonetic key, often with sllide (3)
- sllide — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- hollos — 1 pair sides, mostly vowel via spelling phonetic key, often with show (1)
- vilant — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)
- glocks — 1 pair sides, mostly vowel via spelling phonetic key, often with show (1)
- silant — 1 pair sides, mostly spelling via spelling phonetic key, often with cant (1)
- pationt — 1 pair sides, mostly spelling via spelling phonetic key, often with cant (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Leaf Ward | In What Sport? | 56 | 95 | 188 | loose |
