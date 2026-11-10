# Pop Smoke AI rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Pop Smoke AI
- Songs: 1
- Bars kept (Pop Smoke AI lyric lines): 24
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Pop Smoke AI.
- Credit strings: Pop Smoke AI.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 76
- REPEAT pairs, recorded separately: 11
- END rhymes: 15
- INNER rhymes: 61

By match:

- PERFECT: 3 (END 1, INNER 2)
- SLANT: 23 (END 4, INNER 19)
- ASSONANCE: 48 (END 10, INNER 38)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 4
- MED: 70
- LOW: 2

## Core

- Core Y: 74
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 25 (32.9%)
- vowel: 48 (63.2%)
- spelling: 1 (1.3%)
- multi: 2 (2.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 16 pairs (END 1, INNER 15). Words: send, em, heaven, sent, x, heavens, tell, bentley.
2. `vow:AA` — 13 pairs (END 7, INNER 6). Words: bottom, rockin, drop, top, watch, glock, want, block.
3. `vow:OW` — 8 pairs (END 0, INNER 8). Words: know, smoking, no, hold, over, 092mlboa, don't, whole.
4. `slant:AA:stop` — 5 pairs (END 2, INNER 3). Words: got, want, glock.
5. `vow:IH` — 5 pairs (END 1, INNER 4). Words: biggie, lyrics, chillin, big, shit, chilling.
6. `slant:AA:sib-stop` — 4 pairs (END 0, INNER 4). Words: watch, drop, top, cause, got.
7. `slant:IH:stop` — 4 pairs (END 0, INNER 4). Words: big, quick, nicki.
8. `slant:EH:liq-nas` — 3 pairs (END 0, INNER 3). Words: em, tell.
9. `vow:AH` — 3 pairs (END 0, INNER 3). Words: once, come, what.
10. `cmu:AA-P` — 2 pairs (END 1, INNER 1). Words: top, drop.
11. `multi:IH-L-IH-NG` — 2 pairs (END 0, INNER 2). Words: biggie chillin, x chilling, chillin, chilling.
12. `vow:IY` — 2 pairs (END 0, INNER 2). Words: biggie, flossy, jeans, even.
13. `cmu:IH-N` — 1 pairs (END 0, INNER 1). Words: even, flossin.
14. `slant:AA:nas` — 1 pairs (END 1, INNER 0). Words: bottom, rockin.
15. `slant:AA:nas-stop` — 1 pairs (END 1, INNER 0). Words: rockin, glock.
16. `slant:AE:stop` — 1 pairs (END 0, INNER 1). Words: programmed, gangsta.
17. `slant:AH:nas-stop` — 1 pairs (END 0, INNER 1). Words: come, what.
18. `slant:EH:nas-sib` — 1 pairs (END 0, INNER 1). Words: heaven, heavens.
19. `slant:IH:nas-stop` — 1 pairs (END 0, INNER 1). Words: spin, shit.
20. `slant:OW:liq-stop` — 1 pairs (END 0, INNER 1). Words: whole, hold.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- 092mlboa — 1 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- flossy — 1 pair sides, mostly vowel via spelling phonetic key, often with biggie (1)
- flossin — 1 pair sides, mostly spelling via spelling phonetic key, often with even (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Pop Smoke AI | Programmed For This [AI] | 24 | 15 | 61 | loose |
