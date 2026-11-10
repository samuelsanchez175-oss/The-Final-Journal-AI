# Uncle Murda rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Uncle Murda
- Songs: 1
- Bars kept (Uncle Murda lyric lines): 52
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Uncle Murda.
- Credit strings: Uncle Murda.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 207
- REPEAT pairs, recorded separately: 140
- END rhymes: 10
- INNER rhymes: 197

By match:

- PERFECT: 19 (END 2, INNER 17)
- SLANT: 108 (END 4, INNER 104)
- ASSONANCE: 79 (END 4, INNER 75)
- MULTI: 1 (END 0, INNER 1)

By confidence:

- HIGH: 16
- MED: 160
- LOW: 31

## Core

- Core Y: 207
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 92 (44.4%)
- vowel: 79 (38.2%)
- spelling: 35 (16.9%)
- multi: 1 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 31 pairs (END 0, INNER 31). Words: young, fuckin, trust, drugs, some, bloods, puttin, money.
2. `slant:OW:nas-stop` — 17 pairs (END 0, INNER 17). Words: gon, don't, dont.
3. `vow:AA` — 14 pairs (END 0, INNER 14). Words: cars, got, bottles, coppin, wanna, watchin, god, want.
4. `cmu:OW` — 11 pairs (END 0, INNER 11). Words: blow, ho, no, mexico, metro.
5. `slant:IH:sib` — 11 pairs (END 2, INNER 9). Words: niggas, strippers, crips, whips, hittas.
6. `vow:OW` — 10 pairs (END 0, INNER 10). Words: don't, mexico, metro, no.
7. `slant:AH:nas` — 9 pairs (END 0, INNER 9). Words: some, young, money, come.
8. `slant:AY:sib-stop` — 9 pairs (END 0, INNER 9). Words: right, price, recognize.
9. `slant:AH:nas-stop` — 8 pairs (END 0, INNER 8). Words: money, some, fuck, plug, dub, club, fuckin, young.
10. `slant:IH:sib-stop` — 7 pairs (END 1, INNER 6). Words: bitch, nigga, niggas, brick, lit, shit, flick.
11. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: shit, hit, flick, wrist, brick.
12. `vow:IH` — 6 pairs (END 0, INNER 6). Words: wrist, 'til, bitches, crips, strippers, whippin, bitch, flick.
13. `slant:AE:stop` — 5 pairs (END 0, INNER 5). Words: back, trap, strapped, clapped.
14. `vow:AW` — 5 pairs (END 4, INNER 1). Words: now, down, pounds.
15. `vow:EH` — 5 pairs (END 0, INNER 5). Words: feds, spend, gettin, deck, get, tell, never, swear.
16. `cmu:AE-S` — 4 pairs (END 2, INNER 2). Words: niggas, hittas.
17. `slant:AH:fric-nas` — 4 pairs (END 0, INNER 4). Words: love, young, some.
18. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: bang, brat, 'pac.
19. `slant:EH:liq-stop` — 3 pairs (END 0, INNER 3). Words: tell, get, bread, head.
20. `slant:AA:nas-stop` — 2 pairs (END 0, INNER 2). Words: wanna, got, popped, coppin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 17 pair sides, mostly spelling via spelling phonetic key, often with dont (17)
- niggas — 15 pair sides, mostly spelling via spelling phonetic key, often with hittas (4)
- hittas — 6 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- dont — 1 pair sides, mostly spelling via spelling phonetic key, often with gon (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Uncle Murda | Right Now | 52 | 10 | 197 | loose |
