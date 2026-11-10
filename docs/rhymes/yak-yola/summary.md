# Yak Yola rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Yak Yola
- Songs: 1
- Bars kept (Yak Yola lyric lines): 18
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Yak Yola.
- Credit strings: Yak Yola.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 119
- REPEAT pairs, recorded separately: 8
- END rhymes: 17
- INNER rhymes: 102

By match:

- PERFECT: 13 (END 2, INNER 11)
- SLANT: 69 (END 11, INNER 58)
- ASSONANCE: 37 (END 4, INNER 33)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 13
- MED: 99
- LOW: 7

## Core

- Core Y: 116
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 78 (65.5%)
- vowel: 37 (31.1%)
- spelling: 4 (3.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AA:stop` — 18 pairs (END 5, INNER 13). Words: top, slot, gotta, block, pop, roc, drop, want.
2. `vow:IH` — 18 pairs (END 2, INNER 16). Words: hits, christian, bitch, kicks, give, mill, glick, big.
3. `vow:AA` — 11 pairs (END 0, INNER 11). Words: shots, want, top, cause, molly, block, roc, pop.
4. `slant:IH:sib-stop` — 8 pairs (END 1, INNER 7). Words: bitch, big, city, glick, hits, kicks.
5. `cmu:AA-P` — 6 pairs (END 1, INNER 5). Words: top, drop, pop, crop.
6. `slant:IH:liq-stop` — 6 pairs (END 0, INNER 6). Words: mill, big, city, glick, lil, spit, 'til.
7. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: city, big, glick, nigga.
8. `vow:OW` — 5 pairs (END 1, INNER 4). Words: post, know, opps, no.
9. `slant:IH:fric-stop` — 4 pairs (END 0, INNER 4). Words: give, big, city, glick.
10. `slant:AA:liq-stop` — 3 pairs (END 0, INNER 3). Words: molly, block, roc, pop.
11. `slant:AA:sib-stop` — 3 pairs (END 2, INNER 1). Words: cause, block, roc, pop.
12. `cmu:IH-L` — 2 pairs (END 0, INNER 2). Words: still, lil.
13. `slant:EH:nas-stop` — 2 pairs (END 0, INNER 2). Words: nem, dread, head.
14. `slant:ER:nas-stop` — 2 pairs (END 0, INNER 2). Words: turn, work, shirt.
15. `slant:ER:stop` — 2 pairs (END 0, INNER 2). Words: shirt, work, first.
16. `slant:IH:fric-sib` — 2 pairs (END 0, INNER 2). Words: bitch, give.
17. `slant:IH:liq-sib` — 2 pairs (END 0, INNER 2). Words: bitch, mill.
18. `slant:IH:sib` — 2 pairs (END 2, INNER 0). Words: kicks, hits, blitz.
19. `vow:ER` — 2 pairs (END 1, INNER 1). Words: first, work, turn.
20. `cmu:AA-K` — 1 pairs (END 0, INNER 1). Words: roc, block.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- opps — 2 pair sides, mostly vowel via spelling phonetic key, often with post (1)
- nem — 2 pair sides, mostly spelling via spelling phonetic key, often with dread (1)
- loubs — 1 pair sides, mostly vowel via spelling phonetic key, often with round (1)
- coulda — 1 pair sides, mostly spelling via spelling phonetic key, often with round (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with city (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Yak Yola | Get Back | 18 | 17 | 102 | loose |
