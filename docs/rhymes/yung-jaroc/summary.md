# Yung Jaroc rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Yung Jaroc
- Songs: 1
- Bars kept (Yung Jaroc lyric lines): 40
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Yung Jaroc.
- Credit strings: Yung Jaroc.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 191
- REPEAT pairs, recorded separately: 34
- END rhymes: 21
- INNER rhymes: 170

By match:

- PERFECT: 8 (END 0, INNER 8)
- SLANT: 80 (END 13, INNER 67)
- ASSONANCE: 103 (END 8, INNER 95)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 6
- MED: 171
- LOW: 14

## Core

- Core Y: 186
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 75 (39.3%)
- vowel: 103 (53.9%)
- spelling: 13 (6.8%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 27 pairs (END 5, INNER 22). Words: checkin, reckless, get, demo, spend, flexin, second, lesson.
2. `vow:IH` — 26 pairs (END 3, INNER 23). Words: bitch, spittin, bitches, nigga, winnin, business, wit, think.
3. `vow:AA` — 17 pairs (END 0, INNER 17). Words: cost, problem, shots, got, talkin, watch, wanna, compliment.
4. `slant:IH:sib-stop` — 13 pairs (END 5, INNER 8). Words: bitch, shit, wit, dick, slick.
5. `vow:OW` — 11 pairs (END 0, INNER 11). Words: mo, boa, won't, foe, hoes, rose, sosa, whoeva.
6. `vow:UW` — 8 pairs (END 0, INNER 8). Words: used, through, school, use, move, lose.
7. `slant:IH:stop` — 7 pairs (END 3, INNER 4). Words: nigga, shit, slick, think, wit, dick.
8. `vow:IY` — 6 pairs (END 0, INNER 6). Words: see, d, chief, keef, street, teach, greedy, need.
9. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: not, got, want, roc, cost.
10. `slant:EH:nas-stop` — 5 pairs (END 2, INNER 3). Words: get, n, ent, nem, demo, vet, gettin.
11. `slant:EH:stop` — 4 pairs (END 0, INNER 4). Words: get, check, ent, spend, second, vet.
12. `slant:IH:liq-sib` — 4 pairs (END 0, INNER 4). Words: bitch, till, still, really.
13. `slant:AA:liq-stop` — 3 pairs (END 0, INNER 3). Words: star, roc, not.
14. `slant:EH:nas` — 3 pairs (END 1, INNER 2). Words: flexin, checkin.
15. `slant:IH:fric-sib` — 3 pairs (END 0, INNER 3). Words: bitch, give.
16. `vow:EY` — 3 pairs (END 0, INNER 3). Words: ain't, say, place.
17. `slant:AA:sib-stop` — 2 pairs (END 0, INNER 2). Words: watch, not, roc.
18. `slant:AE:nas-sib` — 2 pairs (END 0, INNER 2). Words: bang, a1's, ass.
19. `slant:AH:nas-stop` — 2 pairs (END 0, INNER 2). Words: fuck, money, come.
20. `slant:IH:sib` — 2 pairs (END 0, INNER 2). Words: bitch, bitches.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- hittas — 3 pair sides, mostly vowel via spelling phonetic key, often with nigga (3)
- whoeva — 2 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- homie — 2 pair sides, mostly spelling via spelling phonetic key, often with whoeva (1)
- a1s — 2 pair sides, mostly spelling via spelling phonetic key, often with bang (1)
- nem — 1 pair sides, mostly spelling via spelling phonetic key, often with get (1)
- choppas — 1 pair sides, mostly vowel via spelling phonetic key, often with whoeva (1)
- moneygang — 1 pair sides, mostly spelling via spelling phonetic key, often with bang (1)
- stuntin — 1 pair sides, mostly spelling via spelling phonetic key, often with survin (1)
- survin — 1 pair sides, mostly spelling via spelling phonetic key, often with stuntin (1)
- neeckless — 1 pair sides, mostly spelling via spelling phonetic key, often with reckless (1)
- nexted — 1 pair sides, mostly vowel via vault phonetic_class, often with cause (1)
- chiraq — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Yung Jaroc | Got Them 30's | 40 | 21 | 170 | loose |
