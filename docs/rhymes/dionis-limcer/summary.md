# DIONIS LIMCER rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DIONIS LIMCER
- Songs: 1
- Bars kept (DIONIS LIMCER lyric lines): 22
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DIONIS LIMCER.
- Credit strings: DIONIS LIMCER.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 102
- REPEAT pairs, recorded separately: 15
- END rhymes: 16
- INNER rhymes: 86

By match:

- PERFECT: 9 (END 3, INNER 6)
- SLANT: 62 (END 9, INNER 53)
- ASSONANCE: 31 (END 4, INNER 27)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 9
- MED: 87
- LOW: 6

## Core

- Core Y: 100
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 67 (65.7%)
- vowel: 31 (30.4%)
- spelling: 4 (3.9%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 16 pairs (END 0, INNER 16). Words: selling, bend, send, hell, em, n, fresh, benz.
2. `cmu:EY-M` — 8 pairs (END 3, INNER 5). Words: name, game, same, came.
3. `slant:AA:stop` — 7 pairs (END 3, INNER 4). Words: block, pop, everybody, shot, body, got.
4. `slant:EY:nas` — 7 pairs (END 6, INNER 1). Words: pain, name, game, same.
5. `slant:EY:nas-sib` — 7 pairs (END 0, INNER 7). Words: th, name, same, came, game.
6. `vow:EY` — 7 pairs (END 0, INNER 7). Words: changed, pain, game, name, same, came, th.
7. `slant:EH:liq-nas` — 5 pairs (END 0, INNER 5). Words: hell, atm, em, n.
8. `slant:AH:sib-stop` — 4 pairs (END 0, INNER 4). Words: fuck, cus.
9. `slant:EH:nas` — 4 pairs (END 0, INNER 4). Words: n, m, em.
10. `slant:EH:nas-sib` — 4 pairs (END 0, INNER 4). Words: fresh, n, benz, atm, em.
11. `slant:EH:nas-stop` — 4 pairs (END 0, INNER 4). Words: n, went, bend, send.
12. `vow:OW` — 4 pairs (END 3, INNER 1). Words: loco, monaco, nockdown.
13. `vow:AY` — 3 pairs (END 1, INNER 2). Words: vibe, sides, y.
14. `slant:AE:stop` — 2 pairs (END 0, INNER 2). Words: back, tat.
15. `slant:AH:nas-sib` — 2 pairs (END 0, INNER 2). Words: cus, one.
16. `slant:AH:nas-stop` — 2 pairs (END 0, INNER 2). Words: fuck, one.
17. `slant:EH:liq` — 2 pairs (END 0, INNER 2). Words: hella, hell.
18. `slant:EH:liq-sib` — 2 pairs (END 0, INNER 2). Words: fresh, hell.
19. `slant:EY:nas-stop` — 2 pairs (END 0, INNER 2). Words: make, name, pain.
20. `slant:IH:nas-stop` — 2 pairs (END 0, INNER 2). Words: grimey, tit, big.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nockdown — 2 pair sides, mostly vowel via spelling phonetic key, often with loco (1)
- hella — 2 pair sides, mostly spelling via spelling phonetic key, often with hell (2)
- grimey — 2 pair sides, mostly spelling via spelling phonetic key, often with tit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DIONIS LIMCER | Custom Remix | 22 | 16 | 86 | loose |
