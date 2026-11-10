# Zater Mann rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Zater Mann
- Songs: 1
- Bars kept (Zater Mann lyric lines): 20
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Zater Mann.
- Credit strings: Zater Mann.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 97
- REPEAT pairs, recorded separately: 21
- END rhymes: 15
- INNER rhymes: 82

By match:

- PERFECT: 8 (END 3, INNER 5)
- SLANT: 37 (END 3, INNER 34)
- ASSONANCE: 51 (END 9, INNER 42)
- MULTI: 1 (END 0, INNER 1)

By confidence:

- HIGH: 4
- MED: 83
- LOW: 10

## Core

- Core Y: 91
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 37 (38.1%)
- vowel: 51 (52.6%)
- spelling: 8 (8.2%)
- multi: 1 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 17 pairs (END 5, INNER 12). Words: hundreds, young, hustling, money, gunners, some, nothing, thuggin.
2. `vow:AA` — 12 pairs (END 0, INNER 12). Words: lotta, choppers, fox, solid, gonna, shots, mama, got.
3. `slant:AH:nas` — 9 pairs (END 1, INNER 8). Words: young, run, money, some, nothing, hustling.
4. `vow:OW` — 5 pairs (END 0, INNER 5). Words: whole, know, no, zone.
5. `slant:AA:nas-stop` — 4 pairs (END 0, INNER 4). Words: gonna, lotta, got, mama.
6. `vow:IH` — 4 pairs (END 0, INNER 4). Words: withcha, nigga, niggas.
7. `cmu:UW` — 3 pairs (END 3, INNER 0). Words: blue, new, boo.
8. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: young, motherfucker, what, some.
9. `slant:IH:sib-stop` — 3 pairs (END 0, INNER 3). Words: nigga, niggas.
10. `vow:AE` — 3 pairs (END 0, INNER 3). Words: savage, pass, gang.
11. `vow:EH` — 3 pairs (END 0, INNER 3). Words: rentals, rep, shell, send, get.
12. `vow:EY` — 3 pairs (END 0, INNER 3). Words: say, scale, bails, bail.
13. `vow:UW` — 3 pairs (END 3, INNER 0). Words: shoot, boo, new, booth.
14. `cmu:AE-S` — 2 pairs (END 0, INNER 2). Words: niggas, pass.
15. `cmu:IH-N` — 2 pairs (END 0, INNER 2). Words: youngin, thuggin.
16. `slant:AA:sib-stop` — 2 pairs (END 0, INNER 2). Words: shots, lotta, got.
17. `slant:AA:stop` — 2 pairs (END 0, INNER 2). Words: lotta, got.
18. `slant:EH:nas-stop` — 2 pairs (END 0, INNER 2). Words: when, send, get.
19. `slant:EY:liq-sib` — 2 pairs (END 1, INNER 1). Words: bails, scale, bail.
20. `slant:IY:liq-stop` — 2 pairs (END 0, INNER 2). Words: real, keep, street.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with withcha (3)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- thuggin — 4 pair sides, mostly vowel via spelling phonetic key, often with youngin (2)
- withcha — 4 pair sides, mostly vowel via spelling phonetic key, often with nigga (3)
- youngin — 2 pair sides, mostly spelling via spelling phonetic key, often with thuggin (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Zater Mann | On Me | 20 | 15 | 82 | loose |
