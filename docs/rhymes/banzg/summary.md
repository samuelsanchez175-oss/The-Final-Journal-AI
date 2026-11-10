# BanzG rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: BanzG
- Songs: 1
- Bars kept (BanzG lyric lines): 40
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: BanzG.
- Credit strings: BanzG.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 351
- REPEAT pairs, recorded separately: 21
- END rhymes: 56
- INNER rhymes: 295

By match:

- PERFECT: 26 (END 9, INNER 17)
- SLANT: 141 (END 23, INNER 118)
- ASSONANCE: 178 (END 22, INNER 156)
- MULTI: 6 (END 2, INNER 4)

By confidence:

- HIGH: 31
- MED: 276
- LOW: 44

## Core

- Core Y: 336
- Core N among rhyme pairs: 15

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 137 (39.0%)
- vowel: 178 (50.7%)
- spelling: 30 (8.5%)
- multi: 6 (1.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 100 pairs (END 13, INNER 87). Words: different, bitches, diggin, sinkin, ink, pink, bitch, kill.
2. `slant:IH:stop` — 21 pairs (END 3, INNER 18). Words: nigga, shit, stick, cripper, sticky, liquor, quicker, flipper.
3. `vow:EH` — 15 pairs (END 2, INNER 13). Words: steppin, checking, west, reverend, end, seventies, ephin, sellin.
4. `cmu:AY` — 14 pairs (END 6, INNER 8). Words: lullaby, eye, bye, high, fly, die.
5. `slant:IH:sib-stop` — 14 pairs (END 5, INNER 9). Words: bitch, sticky, drip, slip, diss, itchy, liquor, quicker.
6. `vow:AY` — 14 pairs (END 0, INNER 14). Words: price, slide, fly, lullaby, bye, eye, high, die.
7. `vow:OW` — 14 pairs (END 5, INNER 9). Words: holo, paublo, show, soul, lambo, carlo, no, taco.
8. `slant:AE:nas-stop` — 11 pairs (END 0, INNER 11). Words: gang, kappa, rapper, clapper, damn, pack.
9. `slant:IH:sib` — 10 pairs (END 2, INNER 8). Words: hickeys, diss, snitches, bitches, bitch, blickies, six, itchy.
10. `vow:AE` — 10 pairs (END 1, INNER 9). Words: alpha, gang, drank, catchin, have, raptor, snatcher, damn.
11. `vow:AH` — 10 pairs (END 0, INNER 10). Words: dummies, much, hustle, done, couple, blood, money, plug.
12. `slant:AA:stop` — 7 pairs (END 0, INNER 7). Words: robbed, not, bought, knock, taco, body, chopp, mont.
13. `slant:IH:liq-stop` — 7 pairs (END 0, INNER 7). Words: stick, kill, gear, year, disappear, strip, drip, slip.
14. `vow:AA` — 7 pairs (END 1, INNER 6). Words: carlo, mont, robbed, taco, raw, bought, knock.
15. `slant:AE:stop` — 6 pairs (END 2, INNER 4). Words: raptor, kappa, rapper, clapper, mask, drank.
16. `slant:IY:stop` — 6 pairs (END 0, INNER 6). Words: meat, keep, weed, street, bleed, cheat, sneak, weak.
17. `cmu:IH-R` — 5 pairs (END 2, INNER 3). Words: gear, year, disappear.
18. `slant:IH:fric-stop` — 5 pairs (END 2, INNER 3). Words: liver, liquor, quicker, stick, flipper, sticky, iffy.
19. `slant:AE:sib-stop` — 4 pairs (END 2, INNER 2). Words: snatcher, pack, rapper, kappa, clapper.
20. `slant:IH:nas-stop` — 4 pairs (END 0, INNER 4). Words: hit, him, sinkin, ink, pink.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with shit (6)
- cripper — 6 pair sides, mostly spelling via spelling phonetic key, often with liquor (1)
- holo — 6 pair sides, mostly vowel via spelling phonetic key, often with carlo (1)
- paublo — 5 pair sides, mostly vowel via spelling phonetic key, often with all (1)
- hickeys — 5 pair sides, mostly spelling via spelling phonetic key, often with snitches (1)
- snitches — 4 pair sides, mostly spelling via spelling phonetic key, often with different (1)
- lifell — 3 pair sides, mostly vowel via spelling phonetic key, often with quicker (1)
- lambo — 3 pair sides, mostly vowel via spelling phonetic key, often with carlo (1)
- blickies — 3 pair sides, mostly spelling via spelling phonetic key, often with sticky (1)
- ephin — 2 pair sides, mostly vowel via spelling phonetic key, often with steppin (1)
- reppin — 1 pair sides, mostly spelling via spelling phonetic key, often with steppin (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with soul (1)
- prolly — 1 pair sides, mostly spelling via spelling phonetic key, often with holo (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| BanzG | Knife Talk OG | 40 | 56 | 295 | loose |
