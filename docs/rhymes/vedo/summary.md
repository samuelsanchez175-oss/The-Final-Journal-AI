# VEDO rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: VEDO
- Songs: 1
- Bars kept (VEDO lyric lines): 65
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: VEDO.
- Credit strings: VEDO.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 242
- REPEAT pairs, recorded separately: 47
- END rhymes: 35
- INNER rhymes: 207

By match:

- PERFECT: 25 (END 4, INNER 21)
- SLANT: 113 (END 20, INNER 93)
- ASSONANCE: 101 (END 10, INNER 91)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 25
- MED: 208
- LOW: 9

## Core

- Core Y: 241
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 127 (52.5%)
- vowel: 101 (41.7%)
- spelling: 11 (4.5%)
- multi: 3 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 29 pairs (END 3, INNER 26). Words: when, ex, credit, jealous, regular, invest, question, get.
2. `vow:OW` — 16 pairs (END 1, INNER 15). Words: don't, know, over, no, hoes, glow, go.
3. `slant:EH:stop` — 15 pairs (END 5, INNER 10). Words: credit, get, regret, let, poetic, pathetic, better, best.
4. `vow:IH` — 13 pairs (END 1, INNER 12). Words: shit, fix, didn't, mix, kids, him, gym, hit.
5. `slant:AA:stop` — 12 pairs (END 2, INNER 10). Words: got, body, rocket, want, gotta, property, smart, top.
6. `vow:AA` — 11 pairs (END 2, INNER 9). Words: shopping, got, goddess, smart, rocket, bought, cali, not.
7. `cmu:OW` — 9 pairs (END 0, INNER 9). Words: know, no, glow, go.
8. `vow:EY` — 9 pairs (END 0, INNER 9). Words: ain't, taking, day, days, baby, lame, way.
9. `slant:EY:stop` — 8 pairs (END 0, INNER 8). Words: baby, take, jaded, make, hate.
10. `vow:AY` — 8 pairs (END 0, INNER 8). Words: like, by, mesmerized, find, i'll.
11. `slant:AA:sib-stop` — 7 pairs (END 1, INNER 6). Words: got, boss, squats, goddess, body, not.
12. `slant:UH:sib-stop` — 7 pairs (END 0, INNER 7). Words: pussy, good.
13. `vow:AH` — 6 pairs (END 0, INNER 6). Words: nothing, hustling, what, lunges, another, one, fuck, cut.
14. `cmu:AA-T` — 5 pairs (END 0, INNER 5). Words: got, not.
15. `slant:EH:liq-stop` — 5 pairs (END 0, INNER 5). Words: tell, let, get.
16. `vow:ER` — 5 pairs (END 3, INNER 2). Words: purpose, personally, deserve, worth.
17. `slant:AA:liq-stop` — 4 pairs (END 0, INNER 4). Words: cali, got, bought, not.
18. `slant:AA:nas-stop` — 4 pairs (END 2, INNER 2). Words: property, popping, dropping, top.
19. `cmu:AW-T` — 3 pairs (END 3, INNER 0). Words: 'bout, doubt, without.
20. `slant:AE:stop` — 3 pairs (END 1, INNER 2). Words: bag, back, had.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- brunching — 3 pair sides, mostly spelling via spelling phonetic key, often with bummy (1)
- wip — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with didnt (1)
- bummy — 1 pair sides, mostly spelling via spelling phonetic key, often with brunching (1)
- shawty — 1 pair sides, mostly vowel via spelling phonetic key, often with property (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| VEDO | You Got It (Remix) | 65 | 35 | 207 | loose |
