# Joey Shady rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Joey Shady
- Songs: 1
- Bars kept (Joey Shady lyric lines): 35
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Joey Shady.
- Credit strings: Joey Shady.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 273
- REPEAT pairs, recorded separately: 26
- END rhymes: 37
- INNER rhymes: 236

By match:

- PERFECT: 18 (END 7, INNER 11)
- SLANT: 149 (END 19, INNER 130)
- ASSONANCE: 103 (END 11, INNER 92)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 19
- MED: 247
- LOW: 7

## Core

- Core Y: 269
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 164 (60.1%)
- vowel: 103 (37.7%)
- spelling: 3 (1.1%)
- multi: 3 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 57 pairs (END 10, INNER 47). Words: spent, flex, exes, bent, finesse, check, rent, jet.
2. `vow:IH` — 23 pairs (END 1, INNER 22). Words: bitches, mister, wrist, sick, dick, lick, think, fingers.
3. `slant:EH:stop` — 20 pairs (END 3, INNER 17). Words: jet, check, spent, bet, already, get, dead, went.
4. `slant:EH:sib-stop` — 16 pairs (END 6, INNER 10). Words: finesse, check, flex, neck, guess, bet, already, dead.
5. `slant:AA:sib-stop` — 15 pairs (END 0, INNER 15). Words: watch, bought, cause, alot, rot, got, rock, glo'd.
6. `slant:AA:stop` — 12 pairs (END 1, INNER 11). Words: bought, glo'd, rock, top, stop.
7. `slant:EH:liq-stop` — 7 pairs (END 1, INNER 6). Words: hell, check, bet, already, dead, fed, get, tell.
8. `slant:IH:sib-stop` — 7 pairs (END 4, INNER 3). Words: bitch, crib, big, sick, dick, lick.
9. `slant:AA:nas-stop` — 6 pairs (END 0, INNER 6). Words: gonna, bought, rock, glo'd, stop, top.
10. `slant:EH:sib` — 6 pairs (END 2, INNER 4). Words: finesse, flex.
11. `vow:AH` — 6 pairs (END 0, INNER 6). Words: what, fuckin, buckin, runnin, fuck, money, some.
12. `vow:OW` — 6 pairs (END 0, INNER 6). Words: show, joey, glo, smoke, don't, dont, shondale.
13. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: what, money, fuck, fuckin, some, thumb.
14. `slant:IH:liq-stop` — 5 pairs (END 1, INNER 4). Words: lil, til, dick, lick, shit, brick, mill, crib.
15. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: brick, think, wrist, mister, shit, sick, crib.
16. `slant:EH:liq-nas` — 4 pairs (END 0, INNER 4). Words: atm, hell, when, care, swear.
17. `slant:EH:liq-sib` — 4 pairs (END 1, INNER 3). Words: finesse, hell, guess, swear.
18. `vow:AE` — 4 pairs (END 0, INNER 4). Words: man, happens, stands, gang.
19. `cmu:AA-T` — 3 pairs (END 0, INNER 3). Words: alot, rot, bought.
20. `cmu:EH-N-T` — 3 pairs (END 1, INNER 2). Words: spent, bent, rent, went.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- coulda — 6 pair sides, mostly spelling via spelling phonetic key, often with shoulda (2)
- shoulda — 2 pair sides, mostly multi via spelling phonetic key, often with coulda (2)
- dont — 1 pair sides, mostly vowel via spelling phonetic key, often with show (1)
- shondale — 1 pair sides, mostly vowel via spelling phonetic key, often with smoke (1)
- imma — 1 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- niggas — 1 pair sides, mostly vowel via spelling phonetic key, often with imma (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Joey Shady | Won’t Finesse Me | 35 | 37 | 236 | loose |
