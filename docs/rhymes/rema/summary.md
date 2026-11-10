# Rema rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rema
- Songs: 1
- Bars kept (Rema lyric lines): 50
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Rema.
- Credit strings: Rema.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 237
- REPEAT pairs, recorded separately: 22
- END rhymes: 41
- INNER rhymes: 196

By match:

- PERFECT: 32 (END 11, INNER 21)
- SLANT: 76 (END 14, INNER 62)
- ASSONANCE: 128 (END 15, INNER 113)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 29
- MED: 190
- LOW: 18

## Core

- Core Y: 231
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 93 (39.2%)
- vowel: 128 (54.0%)
- spelling: 15 (6.3%)
- multi: 1 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 23 pairs (END 1, INNER 22). Words: way, hatin, pesos, play, crazy, lagos, baby, graced.
2. `vow:AE` — 22 pairs (END 3, INNER 19). Words: fast, dash, faster, scratchin, attack, badman, cash, bad.
3. `vow:EH` — 18 pairs (END 5, INNER 13). Words: exes, best, get, fresh, arrest, friends, section, menace.
4. `vow:IY` — 16 pairs (END 0, INNER 16). Words: see, shawty, kiliwee, keep, need, g, paparazzi, knees.
5. `vow:AA` — 15 pairs (END 1, INNER 14). Words: want, rock, kiliwee, card, barman, props, wanna, heart.
6. `slant:AE:stop` — 13 pairs (END 5, INNER 8). Words: mad, packed, back, wag, attack, fast, faster.
7. `vow:AH` — 11 pairs (END 3, INNER 8). Words: fucked, love, cups, stomach, monday, ones, luck, what's.
8. `vow:OW` — 10 pairs (END 0, INNER 10). Words: don't, go, no, only, know, home, throw.
9. `cmu:EY` — 9 pairs (END 0, INNER 9). Words: way, runway, sunday, dey, say, away.
10. `cmu:OW` — 7 pairs (END 3, INNER 4). Words: go, slow, low, doh, know, no.
11. `slant:EH:sib-stop` — 7 pairs (END 6, INNER 1). Words: mess, ness, pressed, best, arrest, get.
12. `vow:AY` — 6 pairs (END 0, INNER 6). Words: try, like, by, hiding, time, mind, whine.
13. `slant:AA:nas-stop` — 5 pairs (END 0, INNER 5). Words: wanna, wan, stop, want, hop, got.
14. `slant:EH:liq-stop` — 4 pairs (END 0, INNER 4). Words: naira, get, met, said, nowhere.
15. `slant:IY:nas-stop` — 4 pairs (END 0, INNER 4). Words: jeep, genie, beenie, weenie, tryna, need.
16. `cmu:EH-S-T` — 3 pairs (END 3, INNER 0). Words: pressed, best, arrest.
17. `cmu:EH-T` — 3 pairs (END 0, INNER 3). Words: let, get, met.
18. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: got, rock, body, want, hop.
19. `slant:EH:nas-stop` — 3 pairs (END 0, INNER 3). Words: get, when, dem, already.
20. `slant:EH:stop` — 3 pairs (END 0, INNER 3). Words: said, let, get, met.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- kiliwee — 7 pair sides, mostly vowel via spelling phonetic key, often with g (1)
- beenie — 4 pair sides, mostly spelling via spelling phonetic key, often with genie (1)
- weenie — 4 pair sides, mostly spelling via spelling phonetic key, often with genie (1)
- shawty — 4 pair sides, mostly vowel via spelling phonetic key, often with crazy (1)
- gimm — 2 pair sides, mostly spelling via spelling phonetic key, often with gimme (2)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with reason (1)
- finna — 1 pair sides, mostly spelling via spelling phonetic key, often with ting (1)
- gyal — 1 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- dem — 1 pair sides, mostly spelling via spelling phonetic key, often with get (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rema | Go Fast | 50 | 41 | 196 | loose |
