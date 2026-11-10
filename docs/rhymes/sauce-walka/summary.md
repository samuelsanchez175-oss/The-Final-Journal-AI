# Sauce Walka rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Sauce Walka
- Songs: 2
- Bars kept (Sauce Walka lyric lines): 78
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Sauce Walka.
- Credit strings: Sauce Walka.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 562
- REPEAT pairs, recorded separately: 74
- END rhymes: 116
- INNER rhymes: 446

By match:

- PERFECT: 32 (END 4, INNER 28)
- SLANT: 176 (END 45, INNER 131)
- ASSONANCE: 338 (END 62, INNER 276)
- MULTI: 16 (END 5, INNER 11)

By confidence:

- HIGH: 40
- MED: 516
- LOW: 6

## Core

- Core Y: 559
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 199 (35.4%)
- vowel: 338 (60.1%)
- spelling: 9 (1.6%)
- multi: 16 (2.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 119 pairs (END 14, INNER 105). Words: shit, million, wrist, bitch, sticks, dripping, hit, middleton.
2. `vow:AH` — 68 pairs (END 29, INNER 39). Words: bust, ugly, double, husband, muzzle, cuff, hundred, bubbles.
3. `vow:AA` — 43 pairs (END 3, INNER 40). Words: want, got, blossom, bottles, garments, chargers, harder, car.
4. `vow:AE` — 36 pairs (END 12, INNER 24). Words: can't, gravity, dragons, mad, academy, magic, monogram, mansion.
5. `slant:AH:stop` — 23 pairs (END 15, INNER 8). Words: fuck, buttercup, butt, club, buddy, muddy, cup, bucket.
6. `vow:AY` — 18 pairs (END 0, INNER 18). Words: like, fire, by, ice, fly, stylin, tri, ridin.
7. `vow:EY` — 17 pairs (END 3, INNER 14). Words: nba, player, neighbors, major, made, trainers, danger, say.
8. `slant:IH:sib-stop` — 12 pairs (END 4, INNER 8). Words: bitch, hit, rich, shit, fit, switch, trigger, kid.
9. `vow:OW` — 12 pairs (END 1, INNER 11). Words: styrofoam, don't, go, clothes, lo, no, gold, coast.
10. `slant:AE:stop` — 10 pairs (END 9, INNER 1). Words: havoc, automatic, static, magic, gravity, mad, fast, wassup.
11. `slant:AA:stop` — 9 pairs (END 0, INNER 9). Words: got, not, want, drop, block, glock, carpet, harder.
12. `vow:UW` — 9 pairs (END 0, INNER 9). Words: two, gucci, blue, new, shooter, woof, who, soon.
13. `slant:AA:liq-stop` — 8 pairs (END 0, INNER 8). Words: car, nascar, not, block, pop, spark, bar.
14. `slant:AE:nas` — 8 pairs (END 0, INNER 8). Words: action, splashing, scrapping, lacking, clapping, monogram, fanny.
15. `slant:IH:liq-stop` — 7 pairs (END 0, INNER 7). Words: still, hit, big, trigger, really, bill, shit.
16. `multi:AE-P-IH-NG` — 6 pairs (END 0, INNER 6). Words: not rapping, jewellery clapping, rapping, clapping, working scrapping, scrapping.
17. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: shit, trigger, big, kicked, spirit, kid, hit, drip.
18. `cmu:OW` — 5 pairs (END 0, INNER 5). Words: go, lo, no, toe, low.
19. `multi:AO-T-ER` — 5 pairs (END 0, INNER 5). Words: cause water, daughter daughter, wife daughter, water water, water, daughter.
20. `slant:AH:liq` — 5 pairs (END 5, INNER 0). Words: muzzle, ugly, trouble, double.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- wockhart — 3 pair sides, mostly vowel via vault phonetic_class, often with poptart (1)
- wassup — 3 pair sides, mostly spelling via spelling phonetic key, often with cup (2)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with dallas (1)
- poptart — 2 pair sides, mostly cmu via vault phonetic_class, often with wockhart (1)
- flossy — 2 pair sides, mostly spelling via spelling phonetic key, often with toaster (1)
- grrah — 1 pair sides, mostly spelling via spelling phonetic key, often with mad (1)
- burbs — 1 pair sides, mostly vowel via spelling phonetic key, often with plug (1)
- imma — 1 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Sauce Walka | PTSD (Puttin’ That Shit Dine) | 49 | 94 | 284 | loose |
| Sauce Walka | Water On My Wrist | 29 | 22 | 162 | loose |
