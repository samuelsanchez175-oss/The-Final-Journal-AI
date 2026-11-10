# ManMan Savage rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: ManMan Savage
- Songs: 2
- Bars kept (ManMan Savage lyric lines): 60
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: ManMan Savage.
- Credit strings: ManMan Savage.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 424
- REPEAT pairs, recorded separately: 56
- END rhymes: 108
- INNER rhymes: 316

By match:

- PERFECT: 19 (END 1, INNER 18)
- SLANT: 165 (END 39, INNER 126)
- ASSONANCE: 233 (END 67, INNER 166)
- MULTI: 7 (END 1, INNER 6)

By confidence:

- HIGH: 24
- MED: 375
- LOW: 25

## Core

- Core Y: 419
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 162 (38.2%)
- vowel: 233 (55.0%)
- spelling: 22 (5.2%)
- multi: 7 (1.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 118 pairs (END 46, INNER 72). Words: savage, action, traffic, savages, snatch, capping, have, subtracting.
2. `vow:AA` — 35 pairs (END 16, INNER 19). Words: poppin, watch, got, want, socket, shopping, knockin, lockin.
3. `vow:IH` — 35 pairs (END 2, INNER 33). Words: bitch, pimpin, trickin, picken, pippin, slippin, window, kitchen.
4. `vow:OW` — 22 pairs (END 3, INNER 19). Words: know, going, don't, no, go, only, boll, stove.
5. `slant:AE:nas` — 15 pairs (END 11, INNER 4). Words: capping, action, happening, subtracting, gang, ran, man, smashing.
6. `slant:IH:stop` — 14 pairs (END 1, INNER 13). Words: nigga, shit, lick, tick, stick, brick, flip, window.
7. `slant:IH:nas` — 13 pairs (END 3, INNER 10). Words: picken, pippin, whippin, sippin, slippin, pimpin, kitchen, trickin.
8. `slant:IH:sib-stop` — 12 pairs (END 0, INNER 12). Words: bitch, nigga, niggas, shit, miss, brick, tick, stick.
9. `slant:AE:fric-sib` — 10 pairs (END 5, INNER 5). Words: have, savage, snatch, ass, catch.
10. `slant:AA:nas` — 9 pairs (END 9, INNER 0). Words: poppin, lockin, knockin, talkin, shopping.
11. `slant:AE:nas-sib` — 9 pairs (END 1, INNER 8). Words: gang, man, thangs, ass, catch, snatch, stash.
12. `slant:AA:stop` — 8 pairs (END 1, INNER 7). Words: rocket, pocket, chop, want, pop, gotta.
13. `slant:AE:sib` — 8 pairs (END 4, INNER 4). Words: savage, savages, ass, catch, snatch.
14. `slant:IH:sib` — 8 pairs (END 0, INNER 8). Words: bitch, bitches, miss.
15. `vow:EY` — 7 pairs (END 0, INNER 7). Words: ain't, play, cakes, take, favorite.
16. `slant:AA:nas-stop` — 6 pairs (END 3, INNER 3). Words: shopping, pop, chop, poppin, rocket, knockin, talkin, socket.
17. `vow:IY` — 6 pairs (END 0, INNER 6). Words: see, creepin, these, tragity, sneeky, money, every.
18. `cmu:OW` — 5 pairs (END 0, INNER 5). Words: know, no, go, lotto.
19. `vow:AH` — 5 pairs (END 0, INNER 5). Words: w, plug, sucking, trust, none, young.
20. `slant:EH:liq-stop` — 4 pairs (END 0, INNER 4). Words: air, steady, tell, let, get.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 12 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- sneeky — 3 pair sides, mostly spelling via spelling phonetic key, often with see (1)
- thangs — 3 pair sides, mostly spelling via spelling phonetic key, often with gang (2)
- survin — 2 pair sides, mostly spelling via spelling phonetic key, often with ballin (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with sneeky (1)
- tragity — 2 pair sides, mostly vowel via spelling phonetic key, often with money (1)
- coka — 1 pair sides, mostly spelling via spelling phonetic key, often with going (1)
- imma — 1 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| ManMan Savage | Know It | 27 | 38 | 139 | loose |
| ManMan Savage | Life of a Savage | 33 | 70 | 177 | loose |
