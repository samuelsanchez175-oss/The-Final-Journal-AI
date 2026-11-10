# Justo (GBE) rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Justo (GBE)
- Songs: 1
- Bars kept (Justo (GBE) lyric lines): 29
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Justo (GBE).
- Credit strings: Justo (GBE).
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 166
- REPEAT pairs, recorded separately: 8
- END rhymes: 32
- INNER rhymes: 134

By match:

- PERFECT: 18 (END 2, INNER 16)
- SLANT: 94 (END 25, INNER 69)
- ASSONANCE: 52 (END 3, INNER 49)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 19
- MED: 125
- LOW: 22

## Core

- Core Y: 160
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 95 (57.2%)
- vowel: 52 (31.3%)
- spelling: 17 (10.2%)
- multi: 2 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:IY:stop` — 22 pairs (END 9, INNER 13). Words: sweeper, street, eat, seek, seaker, cheeter, treat, keeper.
2. `slant:AA:stop` — 13 pairs (END 5, INNER 8). Words: block, shot, top, got, chopper, gotta, glock, body.
3. `vow:EY` — 11 pairs (END 0, INNER 11). Words: ain't, play, scrape, way, lake, th, paper, make.
4. `vow:AH` — 10 pairs (END 0, INNER 10). Words: fucking, love, some, bullits, run, plugs, fucked, brother's.
5. `vow:IY` — 10 pairs (END 3, INNER 7). Words: zebra, t, heat, street, sweeper, streets, eat, cheeta.
6. `slant:IH:sib-stop` — 7 pairs (END 4, INNER 3). Words: bitch, hit, nigga, niggas, drip, trick, swisher, fisher.
7. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: no, know, glo, throw, low.
8. `slant:IY:sib-stop` — 6 pairs (END 0, INNER 6). Words: these, seek, streets, sneak, treat, cheeter, cheeta.
9. `vow:AY` — 6 pairs (END 0, INNER 6). Words: try, riding, sides, fired, hide, y, wipe, stripes.
10. `vow:OW` — 6 pairs (END 0, INNER 6). Words: no, hoes, rolling, know, glo, throw.
11. `slant:AA:sib-stop` — 5 pairs (END 0, INNER 5). Words: cause, got, gotta, glock, block, rob.
12. `vow:IH` — 5 pairs (END 0, INNER 5). Words: finna, niggas, dissing, nigga, bitch, drip.
13. `slant:IH:sib` — 4 pairs (END 2, INNER 2). Words: bitch, swisher, fisher, miss.
14. `slant:IY:nas-stop` — 4 pairs (END 3, INNER 1). Words: seen, eat, cheeter, keep, cheeta.
15. `cmu:IY-T` — 3 pairs (END 0, INNER 3). Words: street, treat, heat, eat.
16. `slant:IH:stop` — 3 pairs (END 1, INNER 2). Words: drip, hit, trick.
17. `vow:AE` — 3 pairs (END 0, INNER 3). Words: gang, savage, can't, ass.
18. `cmu:AA-K` — 2 pairs (END 1, INNER 1). Words: glock, knock, block.
19. `cmu:EY` — 2 pairs (END 0, INNER 2). Words: play, way.
20. `cmu:IY-K` — 2 pairs (END 0, INNER 2). Words: seek, sneak.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- cheeter — 6 pair sides, mostly spelling via spelling phonetic key, often with sweeper (1)
- cheeta — 6 pair sides, mostly spelling via spelling phonetic key, often with zebra (1)
- seaker — 4 pair sides, mostly spelling via spelling phonetic key, often with sweeper (1)
- finna — 4 pair sides, mostly vowel via spelling phonetic key, often with niggas (2)
- niggas — 3 pair sides, mostly vowel via spelling phonetic key, often with finna (2)
- nigga — 2 pair sides, mostly vowel via spelling phonetic key, often with finna (1)
- bullits — 2 pair sides, mostly vowel via spelling phonetic key, often with fucking (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Justo (GBE) | Hide and Seek | 29 | 32 | 134 | loose |
