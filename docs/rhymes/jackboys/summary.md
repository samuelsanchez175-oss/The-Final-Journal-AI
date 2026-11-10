# JACKBOYS rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: JACKBOYS
- Songs: 1
- Bars kept (JACKBOYS lyric lines): 45
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: JACKBOYS.
- Credit strings: JACKBOYS.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 192
- REPEAT pairs, recorded separately: 13
- END rhymes: 53
- INNER rhymes: 139

By match:

- PERFECT: 13 (END 2, INNER 11)
- SLANT: 68 (END 20, INNER 48)
- ASSONANCE: 111 (END 31, INNER 80)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 13
- MED: 175
- LOW: 4

## Core

- Core Y: 189
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 80 (41.7%)
- vowel: 111 (57.8%)
- spelling: 1 (0.5%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 26 pairs (END 1, INNER 25). Words: send, let, revvin, engine, checks, paramedics, pending, expensive.
2. `vow:OW` — 18 pairs (END 12, INNER 6). Words: coco, jokes, smoke, cho, tote, go, don't, know.
3. `vow:EY` — 15 pairs (END 3, INNER 12). Words: away, lay, face, hibernate, take, baby, flame, braid.
4. `vow:IY` — 15 pairs (END 9, INNER 6). Words: v, three, beads, beat, need, piece, keys, reach.
5. `vow:AH` — 14 pairs (END 2, INNER 12). Words: public, cups, cuts, stuff, tuck, frontin, love, jumpin.
6. `vow:AA` — 10 pairs (END 4, INNER 6). Words: choppers, la, droppin, shot, helicopters, doctor, floss, gotta.
7. `slant:AA:stop` — 7 pairs (END 1, INNER 6). Words: got, shot, want, not, cost, bugatti, doctor, pop.
8. `slant:IY:sib-stop` — 6 pairs (END 4, INNER 2). Words: beat, need, piece, keys, reach, peak.
9. `slant:EH:liq-stop` — 5 pairs (END 0, INNER 5). Words: where, red, let, forget, flare, hair, chanel, get.
10. `slant:IY:sib` — 4 pairs (END 4, INNER 0). Words: keys, piece, reach, beads.
11. `vow:UW` — 4 pairs (END 0, INNER 4). Words: who, movin, moves, blue, zoo.
12. `slant:AH:fric-nas` — 3 pairs (END 0, INNER 3). Words: love, one, some, young.
13. `slant:ER:liq-stop` — 3 pairs (END 0, INNER 3). Words: twirl, word, work, hurl.
14. `slant:EY:sib-stop` — 3 pairs (END 2, INNER 1). Words: face, braid, hibernate, take.
15. `slant:EY:stop` — 3 pairs (END 1, INNER 2). Words: braid, hibernate, take.
16. `slant:OW:stop` — 3 pairs (END 2, INNER 1). Words: tote, smoke, folk, don't, hotty.
17. `vow:AE` — 3 pairs (END 0, INNER 3). Words: back, facts, cannot, pacs, man.
18. `cmu:EH-T` — 2 pairs (END 0, INNER 2). Words: let, forget, bet.
19. `cmu:EY` — 2 pairs (END 0, INNER 2). Words: away, lay.
20. `cmu:OW` — 2 pairs (END 1, INNER 1). Words: go, cho, know.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- hotty — 2 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- doggystyle — 1 pair sides, mostly vowel via spelling phonetic key, often with smoke (1)
- extendo — 1 pair sides, mostly vowel via spelling phonetic key, often with coco (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| JACKBOYS | GATTI | 45 | 53 | 139 | loose |
