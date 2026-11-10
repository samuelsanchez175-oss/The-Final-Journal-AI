# VL Deck rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: VL Deck
- Songs: 1
- Bars kept (VL Deck lyric lines): 44
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: VL Deck.
- Credit strings: VL Deck.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 357
- REPEAT pairs, recorded separately: 18
- END rhymes: 43
- INNER rhymes: 314

By match:

- PERFECT: 16 (END 6, INNER 10)
- SLANT: 132 (END 14, INNER 118)
- ASSONANCE: 202 (END 21, INNER 181)
- MULTI: 7 (END 2, INNER 5)

By confidence:

- HIGH: 20
- MED: 323
- LOW: 14

## Core

- Core Y: 353
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 135 (37.8%)
- vowel: 202 (56.6%)
- spelling: 13 (3.6%)
- multi: 7 (2.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 60 pairs (END 0, INNER 60). Words: bags, ass, can't, trap, thank, cappin, ask, racks.
2. `vow:AA` — 51 pairs (END 2, INNER 49). Words: bottles, robbin, got, everybody, squad, parkin, bars, yard.
3. `slant:AE:stop` — 21 pairs (END 0, INNER 21). Words: can't, fat, fanatic, rack, fast, trap, thank, happy.
4. `vow:EH` — 20 pairs (END 1, INNER 19). Words: carats, never, myself, engine, check, sent, left, m's.
5. `vow:IH` — 20 pairs (END 1, INNER 19). Words: bitch, think, shit, pictures, christmas, years, six, lift.
6. `slant:AE:sib-stop` — 19 pairs (END 1, INNER 18). Words: ass, fat, bag, match, smash, gas, bags, bad.
7. `vow:ER` — 17 pairs (END 16, INNER 1). Words: pur, swerve, words, sermon, nervous, birds, slur, burglar.
8. `slant:AE:nas-stop` — 8 pairs (END 0, INNER 8). Words: can, fat, can't, bag, bad, hashtag, capped, snappin.
9. `slant:AA:sib-stop` — 7 pairs (END 1, INNER 6). Words: dodge, lot, boss, top, shots, bars, yard, squad.
10. `slant:AA:stop` — 7 pairs (END 1, INNER 6). Words: squad, got, rock, lot, top, yard, bought.
11. `vow:EY` — 7 pairs (END 0, INNER 7). Words: ain't, face, fake, named, baby, shake.
12. `vow:OW` — 7 pairs (END 0, INNER 7). Words: sofa, gold, motion, moncler, clothes, no, don't, scope.
13. `vow:UW` — 7 pairs (END 1, INNER 6). Words: two, shootin, lose, shooters, shoes, movie, tuesday, uzi.
14. `cmu:AE-P` — 6 pairs (END 3, INNER 3). Words: trap, cap, rap.
15. `slant:AE:nas-sib` — 6 pairs (END 0, INNER 6). Words: can, ass, smash, advance, gas, match.
16. `slant:AE:sib` — 6 pairs (END 0, INNER 6). Words: ass, gas, stash, smash, fabolous, bags, advance, match.
17. `slant:IH:stop` — 5 pairs (END 1, INNER 4). Words: fifty, pretty, litty, shit, lift, nigga, city, hit.
18. `vow:IY` — 5 pairs (END 0, INNER 5). Words: seen, thirty, cleaned, three, fatigue, real, here.
19. `slant:AO:liq-stop` — 4 pairs (END 0, INNER 4). Words: talk, all, ford, four.
20. `slant:EH:fric-liq` — 4 pairs (END 0, INNER 4). Words: forever, scary, where, never.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- pics — 4 pair sides, mostly vowel via spelling phonetic key, often with lift (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with six (1)
- dap — 3 pair sides, mostly spelling via spelling phonetic key, often with ass (1)
- moncler — 2 pair sides, mostly vowel via spelling phonetic key, often with scope (1)
- fabolous — 1 pair sides, mostly spelling via spelling phonetic key, often with bags (1)
- lucious — 1 pair sides, mostly spelling via spelling phonetic key, often with fuck (1)
- youngin — 1 pair sides, mostly spelling via spelling phonetic key, often with robbin (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with city (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| VL Deck | Stash It | 44 | 43 | 314 | loose |
