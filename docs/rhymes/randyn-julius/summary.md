# Randyn Julius rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Randyn Julius
- Songs: 1
- Bars kept (Randyn Julius lyric lines): 12
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Randyn Julius.
- Credit strings: Randyn Julius.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 79
- REPEAT pairs, recorded separately: 21
- END rhymes: 8
- INNER rhymes: 71

By match:

- PERFECT: 6 (END 1, INNER 5)
- SLANT: 47 (END 3, INNER 44)
- ASSONANCE: 26 (END 4, INNER 22)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 6
- MED: 65
- LOW: 8

## Core

- Core Y: 77
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 47 (59.5%)
- vowel: 26 (32.9%)
- spelling: 6 (7.6%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:IH:sib-stop` — 12 pairs (END 0, INNER 12). Words: bitch, sticky, big, hit, sit.
2. `vow:IH` — 8 pairs (END 0, INNER 8). Words: missed, bitch, bimmer, bitches, big, sticky, sit.
3. `slant:IH:stop` — 7 pairs (END 0, INNER 7). Words: big, sticky, hit, nigga, missed, sit.
4. `vow:OW` — 6 pairs (END 0, INNER 6). Words: sosa, snow, know, roll.
5. `slant:IH:sib` — 5 pairs (END 0, INNER 5). Words: bitch, bitches, smith.
6. `vow:AE` — 5 pairs (END 3, INNER 2). Words: can't, gang, jackson, bank, stank.
7. `vow:EY` — 5 pairs (END 1, INNER 4). Words: say, ain't, faint, name.
8. `slant:EY:nas-stop` — 4 pairs (END 1, INNER 3). Words: rain, name, make, faint, great.
9. `cmu:OW` — 3 pairs (END 0, INNER 3). Words: know, no, snow.
10. `slant:AE:nas` — 2 pairs (END 0, INNER 2). Words: gang, lackin.
11. `slant:AO:liq-stop` — 2 pairs (END 0, INNER 2). Words: glory, shorty.
12. `slant:IH:nas-stop` — 2 pairs (END 0, INNER 2). Words: i'ma, hit, sit.
13. `slant:OW:liq-sib` — 2 pairs (END 0, INNER 2). Words: sosa, roll.
14. `vow:IY` — 2 pairs (END 0, INNER 2). Words: feelin, chief, amnesia.
15. `cmu:AA-T` — 1 pairs (END 0, INNER 1). Words: got, bought.
16. `cmu:AE-NG-K` — 1 pairs (END 1, INNER 0). Words: bank, stank.
17. `cmu:IH-T` — 1 pairs (END 0, INNER 1). Words: hit, sit.
18. `slant:AA:nas-stop` — 1 pairs (END 0, INNER 1). Words: bought, wanna.
19. `slant:AE:stop` — 1 pairs (END 1, INNER 0). Words: stank, can't.
20. `slant:AH:fric-stop` — 1 pairs (END 0, INNER 1). Words: fuck, love.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with hit (1)
- bimmer — 3 pair sides, mostly vowel via spelling phonetic key, often with missed (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with big (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Randyn Julius | She Noticed Me | 12 | 8 | 71 | loose |
