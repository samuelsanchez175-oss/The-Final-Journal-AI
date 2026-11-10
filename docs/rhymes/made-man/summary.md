# Made Man rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Made Man
- Songs: 1
- Bars kept (Made Man lyric lines): 54
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Made Man.
- Credit strings: Made Man.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 208
- REPEAT pairs, recorded separately: 21
- END rhymes: 66
- INNER rhymes: 142

By match:

- PERFECT: 27 (END 15, INNER 12)
- SLANT: 105 (END 34, INNER 71)
- ASSONANCE: 76 (END 17, INNER 59)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 24
- MED: 179
- LOW: 5

## Core

- Core Y: 207
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 125 (60.1%)
- vowel: 76 (36.5%)
- spelling: 7 (3.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 21 pairs (END 7, INNER 14). Words: racks, strapped, mapped, having, can't, bag, taxi, man.
2. `vow:IH` — 21 pairs (END 4, INNER 17). Words: michigan, risk, bricks, bitch, digging, sip, thinking, wrist.
3. `slant:IH:stop` — 17 pairs (END 2, INNER 15). Words: big, shit, hit, brick, dick, fishtailing, sip, nigga.
4. `slant:EY:sib-stop` — 11 pairs (END 9, INNER 2). Words: face, cake, wait, lake, relate, straight, made, tape.
5. `slant:EY:stop` — 9 pairs (END 5, INNER 4). Words: relate, lake, straight, cake, wait, paint, made.
6. `vow:EY` — 9 pairs (END 0, INNER 9). Words: game, paint, play, made, way, nailing, lake, face.
7. `cmu:AA-T` — 8 pairs (END 0, INNER 8). Words: not, got, bought.
8. `slant:AE:sib` — 7 pairs (END 7, INNER 0). Words: bags, taxi, racks, saks, tax.
9. `slant:AE:stop` — 7 pairs (END 2, INNER 5). Words: back, bag, strapped, mapped, had, bad, trap.
10. `slant:AH:nas` — 7 pairs (END 2, INNER 5). Words: money, coming, come, jumping, young.
11. `slant:IH:sib-stop` — 7 pairs (END 0, INNER 7). Words: bitch, bigger, rich, big, brick, hit, shit.
12. `vow:OW` — 7 pairs (END 0, INNER 7). Words: know, won't, fold, don't, no, phone, 'lone, home.
13. `slant:AA:stop` — 6 pairs (END 0, INNER 6). Words: top, not, hop, got, bought.
14. `vow:AH` — 6 pairs (END 1, INNER 5). Words: nuts, hundred, young, monkey, hundreds, summers.
15. `vow:EH` — 5 pairs (END 5, INNER 0). Words: medicine, again, elliot, pedaling.
16. `slant:AE:nas-stop` — 4 pairs (END 0, INNER 4). Words: man, can't, bad, trap, had.
17. `slant:AE:sib-stop` — 4 pairs (END 3, INNER 1). Words: back, bags, bag, saks, tax, taxi.
18. `cmu:AE-K-S` — 3 pairs (END 3, INNER 0). Words: racks, saks, tax.
19. `cmu:EY-T` — 3 pairs (END 3, INNER 0). Words: wait, relate, straight.
20. `slant:EH:stop` — 3 pairs (END 0, INNER 3). Words: get, respect, tec, spent.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- fishtailing — 6 pair sides, mostly cmu via vault phonetic_class, often with shit (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with bricks (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with big (1)
- wraith — 1 pair sides, mostly spelling via spelling phonetic key, often with tape (1)
- kel — 1 pair sides, mostly spelling via spelling phonetic key, often with tec (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Made Man | Big Money | 54 | 66 | 142 | loose |
