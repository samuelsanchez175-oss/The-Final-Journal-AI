# Birdman rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Birdman
- Songs: 2
- Bars kept (Birdman lyric lines): 84
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Birdman.
- Credit strings: Birdman.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 440
- REPEAT pairs, recorded separately: 72
- END rhymes: 59
- INNER rhymes: 381

By match:

- PERFECT: 38 (END 7, INNER 31)
- SLANT: 200 (END 23, INNER 177)
- ASSONANCE: 191 (END 26, INNER 165)
- MULTI: 11 (END 3, INNER 8)

By confidence:

- HIGH: 41
- MED: 371
- LOW: 28

## Core

- Core Y: 434
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 210 (47.7%)
- vowel: 191 (43.4%)
- spelling: 28 (6.4%)
- multi: 11 (2.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 37 pairs (END 2, INNER 35). Words: slippin, hit, six, shit, original, bullshit, simple, nigga.
2. `vow:EH` — 29 pairs (END 6, INNER 23). Words: invested, weapons, shepherd, feather, sellin, spreading, lesson, chest.
3. `vow:AA` — 28 pairs (END 7, INNER 21). Words: poppin, project, nothin, bottles, got, jock, yacht, lotta.
4. `vow:AH` — 25 pairs (END 5, INNER 20). Words: somethin, fuckin, money, young, flood, bunch, stomach, comin.
5. `vow:EY` — 19 pairs (END 0, INNER 19). Words: ain't, way, make, baby, ayo, making, waiting, save.
6. `slant:IH:liq-stop` — 18 pairs (END 0, INNER 18). Words: hit, lil, shit, little, 'til, big, really, bullshit.
7. `slant:AH:nas` — 16 pairs (END 9, INNER 7). Words: money, somethin, comin, young, stuntin, runnin, stunna, gunna.
8. `slant:AH:nas-stop` — 16 pairs (END 2, INNER 14). Words: fuck, young, money, blood, some, flood, thug, bug.
9. `vow:IY` — 16 pairs (END 5, INNER 11). Words: here, levi's, reebok, knee, see, streets, pee, ki.
10. `vow:AY` — 15 pairs (END 1, INNER 14). Words: flyer, like, high, die, butterfly, ride, side, twice.
11. `vow:OW` — 14 pairs (END 0, INNER 14). Words: know, show, told, rollie, rode, only, no, rope.
12. `slant:EH:stop` — 12 pairs (END 0, INNER 12). Words: get, steady, step, let, best, better, neck, went.
13. `slant:EH:nas-stop` — 11 pairs (END 0, INNER 11). Words: ten, steady, get, let, step, tec, when.
14. `slant:AA:nas` — 9 pairs (END 9, INNER 0). Words: poppin, watchin, blockin, stoppin, rockin.
15. `cmu:IH-T` — 8 pairs (END 2, INNER 6). Words: hit, shit, bullshit.
16. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: lotta, yacht, gotta, cost, peacock, got, og, hot.
17. `slant:EH:nas-sib` — 6 pairs (END 0, INNER 6). Words: any, weather, feather, ten, bezo, when.
18. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: nigga, shit, hit, bullshit, big.
19. `cmu:IH-N` — 5 pairs (END 3, INNER 2). Words: nothin, stuntin, wylin, sellin, roadrunnin.
20. `multi:AE-P-IH-NG` — 5 pairs (END 0, INNER 5). Words: trappin, rappin, trappin rappin, nigga trappin, rappin trappin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with caterpillar (3)
- stuntin — 7 pair sides, mostly spelling via spelling phonetic key, often with nothin (3)
- tryna — 4 pair sides, mostly spelling via spelling phonetic key, often with believe (1)
- stunna — 3 pair sides, mostly spelling via spelling phonetic key, often with somethin (1)
- wylin — 3 pair sides, mostly spelling via spelling phonetic key, often with real (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- bezo — 3 pair sides, mostly spelling via spelling phonetic key, often with tec (1)
- bezel — 2 pair sides, mostly vowel via spelling phonetic key, often with shepherd (1)
- gunna — 2 pair sides, mostly spelling via spelling phonetic key, often with stuntin (1)
- homie — 2 pair sides, mostly spelling via spelling phonetic key, often with gon (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- roadrunnin — 1 pair sides, mostly spelling via spelling phonetic key, often with sellin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Birdman | Any Weather | 17 | 7 | 84 | loose |
| Birdman | Ride | 67 | 52 | 297 | loose |
