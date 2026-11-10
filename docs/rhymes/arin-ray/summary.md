# Arin Ray rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Arin Ray
- Songs: 1
- Bars kept (Arin Ray lyric lines): 31
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Arin Ray.
- Credit strings: Arin Ray.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 112
- REPEAT pairs, recorded separately: 19
- END rhymes: 15
- INNER rhymes: 97

By match:

- PERFECT: 7 (END 1, INNER 6)
- SLANT: 51 (END 9, INNER 42)
- ASSONANCE: 52 (END 3, INNER 49)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 7
- MED: 95
- LOW: 10

## Core

- Core Y: 109
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 49 (43.8%)
- vowel: 52 (46.4%)
- spelling: 9 (8.0%)
- multi: 2 (1.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 15 pairs (END 2, INNER 13). Words: women, skinned, pistol, disappear, kiss, trick, babysitter, linguini.
2. `vow:AA` — 12 pairs (END 0, INNER 12). Words: models, bottom, restaurants, top, opp, god, dark.
3. `vow:IY` — 8 pairs (END 1, INNER 7). Words: seats, leave, lamborghinis, eating, seen, see, free, mean.
4. `vow:AE` — 7 pairs (END 0, INNER 7). Words: savage, phantoms, thank, bag, sware.
5. `slant:AA:nas-stop` — 6 pairs (END 0, INNER 6). Words: wanna, everybody, stop, got.
6. `vow:EH` — 6 pairs (END 0, INNER 6). Words: let, blessing, stressing, get.
7. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: god, stop, got, everybody, top, opp.
8. `slant:IH:liq-stop` — 4 pairs (END 1, INNER 3). Words: babysitter, trick, disappear, brittle, lil.
9. `slant:AA:sib-stop` — 3 pairs (END 0, INNER 3). Words: boss, got, god.
10. `slant:EH:stop` — 3 pairs (END 0, INNER 3). Words: best, let, get.
11. `slant:EY:nas-stop` — 3 pairs (END 0, INNER 3). Words: came, make, straight.
12. `slant:IH:liq` — 3 pairs (END 1, INNER 2). Words: pillo, brittle, lil.
13. `vow:OW` — 3 pairs (END 0, INNER 3). Words: going, don't, know, broke, bones.
14. `cmu:EH-T` — 2 pairs (END 0, INNER 2). Words: let, get.
15. `slant:AY:sib-stop` — 2 pairs (END 2, INNER 0). Words: twice, right, tight.
16. `slant:EH:nas-stop` — 2 pairs (END 2, INNER 0). Words: best, blessing, stressing.
17. `slant:EY:stop` — 2 pairs (END 0, INNER 2). Words: make, straight.
18. `slant:IH:liq-sib` — 2 pairs (END 0, INNER 2). Words: kiss, disappear.
19. `slant:IY:nas-stop` — 2 pairs (END 0, INNER 2). Words: beat, seen, dream, need.
20. `slant:IY:sib-stop` — 2 pairs (END 0, INNER 2). Words: these, keep.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- linguini — 3 pair sides, mostly vowel via spelling phonetic key, often with women (1)
- pillo — 2 pair sides, mostly spelling via spelling phonetic key, often with brittle (1)
- raris — 2 pair sides, mostly spelling via spelling phonetic key, often with lamborghinis (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with mean (1)
- sware — 1 pair sides, mostly vowel via spelling phonetic key, often with savage (1)
- ar15 — 1 pair sides, mostly spelling via spelling phonetic key, often with dark (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Arin Ray | Blessings | 31 | 15 | 97 | loose |
