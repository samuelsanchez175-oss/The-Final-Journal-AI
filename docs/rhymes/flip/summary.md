# Flip rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Flip
- Songs: 1
- Bars kept (Flip lyric lines): 15
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Flip.
- Credit strings: Flip.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 73
- REPEAT pairs, recorded separately: 12
- END rhymes: 22
- INNER rhymes: 51

By match:

- PERFECT: 7 (END 4, INNER 3)
- SLANT: 43 (END 14, INNER 29)
- ASSONANCE: 23 (END 4, INNER 19)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 7
- MED: 64
- LOW: 2

## Core

- Core Y: 73
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 48 (65.8%)
- vowel: 23 (31.5%)
- spelling: 2 (2.7%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 11 pairs (END 3, INNER 8). Words: send, legs, wet, checks, neck, head, tec, vet.
2. `slant:EH:stop` — 10 pairs (END 9, INNER 1). Words: head, neck, tec, wet, vette, vet, send.
3. `slant:AA:nas-stop` — 5 pairs (END 0, INNER 5). Words: got, don, juan, everybody, wan.
4. `slant:OW:fric-sib` — 5 pairs (END 2, INNER 3). Words: nose, stove, over, hoes.
5. `vow:AE` — 5 pairs (END 0, INNER 5). Words: standing, damn, bank, trap.
6. `vow:OW` — 5 pairs (END 1, INNER 4). Words: close, know, open, clothes, stove, over.
7. `slant:OW:fric` — 4 pairs (END 0, INNER 4). Words: over, stove.
8. `cmu:AA-N` — 3 pairs (END 0, INNER 3). Words: wan, don, juan.
9. `slant:AH:nas` — 3 pairs (END 0, INNER 3). Words: money, some, summer.
10. `slant:AO:liq-stop` — 3 pairs (END 0, INNER 3). Words: all, walk, slaughter.
11. `cmu:EH-T` — 2 pairs (END 2, INNER 0). Words: wet, vette, vet.
12. `slant:AE:nas` — 2 pairs (END 0, INNER 2). Words: standing, gambine.
13. `slant:AY:stop` — 2 pairs (END 0, INNER 2). Words: inside, like.
14. `slant:EH:nas-stop` — 2 pairs (END 0, INNER 2). Words: ten, spend, get.
15. `slant:IY:liq-sib` — 2 pairs (END 0, INNER 2). Words: these, feel.
16. `slant:OW:sib` — 2 pairs (END 2, INNER 0). Words: clothes, nose, hoes.
17. `cmu:EH-K` — 1 pairs (END 1, INNER 0). Words: tec, neck.
18. `cmu:OW-Z` — 1 pairs (END 1, INNER 0). Words: nose, hoes.
19. `slant:AE:nas-stop` — 1 pairs (END 0, INNER 1). Words: trap, gang.
20. `slant:EH:sib` — 1 pairs (END 0, INNER 1). Words: legs, checks.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gambine — 2 pair sides, mostly spelling via spelling phonetic key, often with standing (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Flip | Trap Money | 15 | 22 | 51 | loose |
