# DJ Scream rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Scream
- Songs: 1
- Bars kept (DJ Scream lyric lines): 50
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DJ Scream.
- Credit strings: DJ Scream.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 325
- REPEAT pairs, recorded separately: 62
- END rhymes: 97
- INNER rhymes: 228

By match:

- PERFECT: 26 (END 13, INNER 13)
- SLANT: 191 (END 49, INNER 142)
- ASSONANCE: 105 (END 35, INNER 70)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 29
- MED: 268
- LOW: 28

## Core

- Core Y: 322
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 192 (59.1%)
- vowel: 105 (32.3%)
- spelling: 25 (7.7%)
- multi: 3 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:IH:stop` — 68 pairs (END 14, INNER 54). Words: lit, nigga, stick, wick, lick, shit, drip, wig.
2. `slant:IH:sib-stop` — 62 pairs (END 25, INNER 37). Words: bitch, lit, wick, stick, rich, shit, wig, lick.
3. `vow:OW` — 33 pairs (END 20, INNER 13). Words: go, toast, lovin, no, low, load, most, ghost.
4. `vow:IH` — 31 pairs (END 14, INNER 17). Words: lit, drippin, witness, bitches, wrist, different, bitch, drip.
5. `vow:AH` — 13 pairs (END 0, INNER 13). Words: hundred, bust, drum, nothing, club, motherfucker, nut, wonder.
6. `vow:IY` — 9 pairs (END 0, INNER 9). Words: three, these, see, keep, shawty, whitney, feed, weed.
7. `slant:AH:stop` — 8 pairs (END 0, INNER 8). Words: motherfucker, fucked, fuck, bust, nut, club.
8. `vow:AA` — 8 pairs (END 0, INNER 8). Words: gotta, shoppin, talkin, choppers, wanna, want, stop, bottle.
9. `cmu:OW` — 7 pairs (END 4, INNER 3). Words: go, know, no, ho, low, dough.
10. `slant:AH:nas-stop` — 7 pairs (END 0, INNER 7). Words: motherfuckin, fuck, some, motherfucker, nut, drum, fucked.
11. `cmu:IH-T` — 6 pairs (END 1, INNER 5). Words: shit, lit, hit.
12. `slant:AA:nas-stop` — 6 pairs (END 0, INNER 6). Words: hop, poppin, shoppin, cop.
13. `vow:EH` — 6 pairs (END 0, INNER 6). Words: gettin, sense, next, tell, when, well, every, spend.
14. `cmu:OW-S-T` — 5 pairs (END 5, INNER 0). Words: toast, most, ghost.
15. `slant:IH:nas-stop` — 5 pairs (END 2, INNER 3). Words: lit, whitney, drip, drippin.
16. `slant:IY:sib-stop` — 5 pairs (END 0, INNER 5). Words: these, feed, keep, weed.
17. `cmu:IH-K` — 4 pairs (END 3, INNER 1). Words: stick, wick, pick.
18. `multi:AA-P-IH-NG` — 3 pairs (END 0, INNER 3). Words: wonder shoppin, poppin, shoppin, poppin poppin, when poppin.
19. `slant:AA:liq-stop` — 3 pairs (END 0, INNER 3). Words: dollar, cop, hop, gotta.
20. `slant:OW:nas-stop` — 3 pairs (END 0, INNER 3). Words: gon, load, boat.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 21 pair sides, mostly spelling via spelling phonetic key, often with lit (8)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with load (2)
- shawty — 2 pair sides, mostly spelling via spelling phonetic key, often with slaughter (1)
- aquafina — 1 pair sides, mostly vowel via spelling phonetic key, often with gang (1)
- cartis — 1 pair sides, mostly vowel via spelling phonetic key, often with talkin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Scream | Lit | 50 | 97 | 228 | loose |
