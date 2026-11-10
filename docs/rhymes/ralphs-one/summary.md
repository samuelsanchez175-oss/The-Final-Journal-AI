# Ralph’s One rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ralph’s One
- Songs: 1
- Bars kept (Ralph’s One lyric lines): 44
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Ralph’s One.
- Credit strings: Ralph’s One.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 172
- REPEAT pairs, recorded separately: 29
- END rhymes: 40
- INNER rhymes: 132

By match:

- PERFECT: 20 (END 9, INNER 11)
- SLANT: 80 (END 18, INNER 62)
- ASSONANCE: 70 (END 13, INNER 57)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 12
- MED: 140
- LOW: 20

## Core

- Core Y: 164
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 80 (46.5%)
- vowel: 70 (40.7%)
- spelling: 20 (11.6%)
- multi: 2 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 20 pairs (END 3, INNER 17). Words: smokin, sosa, don't, hoes, no, choppas, toe, though.
2. `vow:IH` — 19 pairs (END 0, INNER 19). Words: bitch, sister, flippin, chips, wrist, stinky, think, finna.
3. `vow:EY` — 12 pairs (END 9, INNER 3). Words: case, paint, spray, today, play, lay, date, wavin.
4. `slant:AH:nas-stop` — 6 pairs (END 0, INNER 6). Words: money, blood, some, truck, fuck, summer.
5. `slant:EY:sib` — 6 pairs (END 4, INNER 2). Words: days, ways, james, face, place.
6. `slant:IH:liq-sib` — 6 pairs (END 0, INNER 6). Words: lil, bitch.
7. `slant:AA:nas-stop` — 5 pairs (END 0, INNER 5). Words: johnny, lot, marijuana, mama, bought, hop, drop.
8. `vow:AH` — 5 pairs (END 1, INNER 4). Words: hundred, summer, run, hummers, fuck, comin.
9. `cmu:ER-Z` — 4 pairs (END 0, INNER 4). Words: rangers, hummers, monclers, oppers, coppers.
10. `cmu:OW` — 4 pairs (END 1, INNER 3). Words: no, guapa, imposters, though.
11. `slant:AA:sib-stop` — 4 pairs (END 0, INNER 4). Words: cause, got, coppers, drop, chopper.
12. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: pocket, lot, hop, drop, chopper, miyake.
13. `slant:AH:nas` — 4 pairs (END 0, INNER 4). Words: money, run, some, comin.
14. `slant:EY:nas-stop` — 4 pairs (END 4, INNER 0). Words: paint, wayne, stain, date.
15. `vow:AA` — 4 pairs (END 0, INNER 4). Words: parkin, marijuana, lot, pocket, johnny, hot, riccardo.
16. `cmu:EY` — 3 pairs (END 3, INNER 0). Words: lay, spray, today.
17. `cmu:IH-NG` — 3 pairs (END 0, INNER 3). Words: jocking, lookin, pimpin, wavin.
18. `slant:IH:liq-nas` — 3 pairs (END 0, INNER 3). Words: lil, dinner, thing, bling.
19. `slant:IH:nas` — 3 pairs (END 0, INNER 3). Words: finna, dinner, thing.
20. `slant:IH:stop` — 3 pairs (END 0, INNER 3). Words: winter, think, nigga, sig, hit, wrist.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- choppas — 7 pair sides, mostly spelling via spelling phonetic key, often with sosa (3)
- jocking — 5 pair sides, mostly spelling via spelling phonetic key, often with smokin (2)
- finna — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- imposters — 4 pair sides, mostly cmu via vault phonetic_class, often with guapa (1)
- hummers — 3 pair sides, mostly spelling via spelling phonetic key, often with summer (1)
- guapa — 3 pair sides, mostly cmu via vault phonetic_class, often with imposters (1)
- nigga — 3 pair sides, mostly vowel via spelling phonetic key, often with finna (2)
- issey — 3 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- monclers — 2 pair sides, mostly spelling via spelling phonetic key, often with rangers (1)
- choppa — 2 pair sides, mostly spelling via spelling phonetic key, often with choppas (2)
- oppers — 2 pair sides, mostly vowel via spelling phonetic key, often with imposters (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with choppas (1)
- ganja — 1 pair sides, mostly spelling via spelling phonetic key, often with can (1)
- llari — 1 pair sides, mostly spelling via spelling phonetic key, often with dang (1)
- bling — 1 pair sides, mostly spelling via spelling phonetic key, often with lil (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ralph’s One | Carolina | 44 | 40 | 132 | loose |
