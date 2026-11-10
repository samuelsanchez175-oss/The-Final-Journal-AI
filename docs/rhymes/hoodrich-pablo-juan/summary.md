# Hoodrich Pablo Juan rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Hoodrich Pablo Juan
- Songs: 2
- Bars kept (Hoodrich Pablo Juan lyric lines): 82
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Hoodrich Pablo Juan.
- Credit strings: Hoodrich Pablo Juan.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 462
- REPEAT pairs, recorded separately: 35
- END rhymes: 127
- INNER rhymes: 335

By match:

- PERFECT: 34 (END 16, INNER 18)
- SLANT: 181 (END 39, INNER 142)
- ASSONANCE: 246 (END 72, INNER 174)
- MULTI: 1 (END 0, INNER 1)

By confidence:

- HIGH: 31
- MED: 408
- LOW: 23

## Core

- Core Y: 448
- Core N among rhyme pairs: 14

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 203 (43.9%)
- vowel: 246 (53.2%)
- spelling: 12 (2.6%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 88 pairs (END 36, INNER 52). Words: racks, can't, bandit, pants, glasses, mansion, hand, stand.
2. `vow:OW` — 39 pairs (END 18, INNER 21). Words: low, rainbow, don't, know, smoking, o's, raincoats, no.
3. `vow:AA` — 24 pairs (END 5, INNER 19). Words: got, pablo, shots, arm, bonds, raw, palms, fanta.
4. `slant:EH:stop` — 18 pairs (END 8, INNER 10). Words: head, get, neck, better, check, vette, twenty, let.
5. `vow:EH` — 18 pairs (END 7, INNER 11). Words: next, get, head, selling, marilyn, remembered, hennessy, enemy.
6. `vow:IH` — 18 pairs (END 0, INNER 18). Words: bitch, bitches, digging, minute, little, years, give, mil.
7. `slant:AA:stop` — 17 pairs (END 0, INNER 17). Words: got, popped, top, copped, forgot, cartier, drop, fanta.
8. `vow:AY` — 15 pairs (END 0, INNER 15). Words: like, riding, diamonds, fly, trying, outside, might, life.
9. `vow:IY` — 14 pairs (END 3, INNER 11). Words: these, feeling, finna, v, street, pee, lean, see.
10. `slant:AE:nas-stop` — 13 pairs (END 3, INNER 10). Words: man, ran, hand, bad, can't, dab, bandana, land.
11. `vow:AH` — 13 pairs (END 0, INNER 13). Words: fucked, custom, one, double, nothing, drunk, cup, money.
12. `vow:AO` — 12 pairs (END 3, INNER 9). Words: all, storm, pouring, orange, call, walk, baseball, gone.
13. `slant:AE:stop` — 9 pairs (END 3, INNER 6). Words: can't, hand, stand, bandit, bad, landed, wrapped.
14. `cmu:OW` — 8 pairs (END 4, INNER 4). Words: know, low, rainbow, show, o, no.
15. `slant:AY:sib-stop` — 8 pairs (END 4, INNER 4). Words: white, ice, dike, price, nice.
16. `slant:EH:nas-stop` — 8 pairs (END 0, INNER 8). Words: many, head, get, vette, neck, better, when, ben.
17. `cmu:IY` — 6 pairs (END 5, INNER 1). Words: pee, finna, c, tea, ap, three, v.
18. `slant:AA:liq-stop` — 6 pairs (END 0, INNER 6). Words: rockstar, bar, top, pop, forgot, drop, got.
19. `slant:AO:nas` — 6 pairs (END 4, INNER 2). Words: foreign, pouring, horny, storm.
20. `slant:IH:sib-stop` — 6 pairs (END 0, INNER 6). Words: nigga, niggas, dick, bitch, rich.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- finna — 6 pair sides, mostly vowel via vault phonetic_class, often with v (1)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- fabo — 5 pair sides, mostly vowel via spelling phonetic key, often with dracos (1)
- dro — 4 pair sides, mostly vowel via spelling phonetic key, often with show (1)
- faygo — 4 pair sides, mostly vowel via spelling phonetic key, often with fabo (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- dracos — 2 pair sides, mostly vowel via spelling phonetic key, often with fabo (1)
- hitech — 2 pair sides, mostly spelling via spelling phonetic key, often with little (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- carti — 1 pair sides, mostly spelling via spelling phonetic key, often with got (1)
- swerving — 1 pair sides, mostly multi via spelling phonetic key, often with serving (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with manson (1)
- tatted — 1 pair sides, mostly vowel via spelling phonetic key, often with pineapple (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Hoodrich Pablo Juan | Check | 49 | 72 | 169 | loose |
| Hoodrich Pablo Juan | They Can’t Stand It | 33 | 55 | 166 | loose |
