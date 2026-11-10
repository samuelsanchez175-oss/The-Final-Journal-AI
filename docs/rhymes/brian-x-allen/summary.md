# Brian X Allen rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Brian X Allen
- Songs: 1
- Bars kept (Brian X Allen lyric lines): 36
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Brian X Allen.
- Credit strings: Brian X Allen.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 194
- REPEAT pairs, recorded separately: 15
- END rhymes: 39
- INNER rhymes: 155

By match:

- PERFECT: 11 (END 2, INNER 9)
- SLANT: 89 (END 14, INNER 75)
- ASSONANCE: 91 (END 20, INNER 71)
- MULTI: 3 (END 3, INNER 0)

By confidence:

- HIGH: 13
- MED: 167
- LOW: 14

## Core

- Core Y: 192
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 86 (44.3%)
- vowel: 91 (46.9%)
- spelling: 14 (7.2%)
- multi: 3 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 21 pairs (END 10, INNER 11). Words: slatt, raiders, wafers, save, rearrange, sager, craig, vegas.
2. `vow:IY` — 16 pairs (END 9, INNER 7). Words: eatin, believe, reese's, nieces, receive, leases, need, jesus.
3. `vow:AE` — 10 pairs (END 1, INNER 9). Words: mascot, back, handle, damage, can't, bad, trap, slaps.
4. `vow:AY` — 9 pairs (END 0, INNER 9). Words: like, tie, buy, bae, times, time, five, outside.
5. `vow:OW` — 9 pairs (END 0, INNER 9). Words: don't, go, over, show, know, gold, no, broke.
6. `slant:AA:stop` — 8 pairs (END 1, INNER 7). Words: flock, not, shot, block, got, top, want, soft.
7. `vow:AH` — 8 pairs (END 0, INNER 8). Words: hundred, buckle, pups, what, fuck, w, truck, brother.
8. `slant:AA:sib-stop` — 7 pairs (END 0, INNER 7). Words: watch, shots, got, flock, shot, block, pop, locks.
9. `vow:AA` — 7 pairs (END 0, INNER 7). Words: locks, soft, shots, want, top, bars, block, watch.
10. `vow:IH` — 6 pairs (END 0, INNER 6). Words: kickin, innocent, big, 'til, will, million, crib.
11. `slant:AE:sib-stop` — 5 pairs (END 0, INNER 5). Words: ass, back, brag, cash, trap, slaps.
12. `slant:EH:liq-nas` — 5 pairs (END 0, INNER 5). Words: ten, tell, yellow, ben.
13. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: crib, nigga, thick, big.
14. `slant:IY:sib` — 4 pairs (END 3, INNER 1). Words: jesus, reese's, nieces, leases, g's, bys.
15. `slant:UH:sib-stop` — 4 pairs (END 2, INNER 2). Words: pussy, overlook, cookie.
16. `multi:IY-S-IH-Z` — 3 pairs (END 3, INNER 0). Words: reese's, nieces, leases.
17. `slant:AA:nas-stop` — 3 pairs (END 0, INNER 3). Words: wanna, top, want, not.
18. `slant:AE:nas-sib` — 3 pairs (END 0, INNER 3). Words: can, dance, cash.
19. `slant:AE:stop` — 3 pairs (END 0, INNER 3). Words: can't, frank, bad, trap, back, brag.
20. `slant:EH:fric-stop` — 3 pairs (END 0, INNER 3). Words: every, jet, sweat, get.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- slatt — 8 pair sides, mostly vowel via vault phonetic_class, often with wafers (1)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with thick (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- headtop — 2 pair sides, mostly vowel via spelling phonetic key, often with dreadlocks (1)
- dreadlocks — 2 pair sides, mostly vowel via spelling phonetic key, often with headtop (1)
- tecs — 2 pair sides, mostly vowel via spelling phonetic key, often with where (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with sheet (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with thick (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- dawgs — 1 pair sides, mostly spelling via spelling phonetic key, often with tecs (1)
- bys — 1 pair sides, mostly spelling via spelling phonetic key, often with gs (1)
- cuz — 1 pair sides, mostly spelling via spelling phonetic key, often with what (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Brian X Allen | I’m Fucking A Lot Of Niggas | 36 | 39 | 155 | loose |
