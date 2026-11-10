# TYB rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: TYB
- Songs: 1
- Bars kept (TYB lyric lines): 23
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: TYB.
- Credit strings: TYB.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 95
- REPEAT pairs, recorded separately: 16
- END rhymes: 17
- INNER rhymes: 78

By match:

- PERFECT: 18 (END 1, INNER 17)
- SLANT: 45 (END 8, INNER 37)
- ASSONANCE: 32 (END 8, INNER 24)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 18
- MED: 69
- LOW: 8

## Core

- Core Y: 93
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 57 (60.0%)
- vowel: 32 (33.7%)
- spelling: 6 (6.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 16 pairs (END 3, INNER 13). Words: cops, got, la, shot, da, rock, dropped, clocked.
2. `slant:AA:stop` — 15 pairs (END 7, INNER 8). Words: clocked, shot, got, dropped, rock.
3. `slant:EH:nas-stop` — 14 pairs (END 0, INNER 14). Words: get, n, better, when, dem, den.
4. `cmu:AA-T` — 7 pairs (END 0, INNER 7). Words: got, shot.
5. `vow:AY` — 5 pairs (END 2, INNER 3). Words: time, die, ty, goodbye, life, night.
6. `cmu:IY` — 4 pairs (END 0, INNER 4). Words: b, c, t, see, d.
7. `vow:IY` — 4 pairs (END 1, INNER 3). Words: mean, see, b, c, t.
8. `cmu:OW` — 3 pairs (END 0, INNER 3). Words: no, know.
9. `slant:EH:fric-nas` — 3 pairs (END 0, INNER 3). Words: f, when, dem, n.
10. `vow:AE` — 3 pairs (END 0, INNER 3). Words: chasin, after, black.
11. `vow:OW` — 3 pairs (END 1, INNER 2). Words: codes, o, popo, know, capone.
12. `cmu:AY` — 2 pairs (END 1, INNER 1). Words: die, goodbye.
13. `cmu:EH-N` — 2 pairs (END 0, INNER 2). Words: when, n.
14. `slant:AA:liq-stop` — 2 pairs (END 0, INNER 2). Words: r, got, shot.
15. `slant:AO:liq-sib` — 2 pairs (END 0, INNER 2). Words: because, more, before.
16. `slant:EH:fric-stop` — 2 pairs (END 0, INNER 2). Words: f, better, get.
17. `slant:EH:nas` — 2 pairs (END 0, INNER 2). Words: dem, when, n.
18. `slant:AA:nas-stop` — 1 pairs (END 0, INNER 1). Words: gonna, shot.
19. `slant:AE:stop` — 1 pairs (END 0, INNER 1). Words: black, matter.
20. `slant:AO:liq` — 1 pairs (END 0, INNER 1). Words: before, all.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- dem — 5 pair sides, mostly spelling via spelling phonetic key, often with when (1)
- popo — 1 pair sides, mostly vowel via spelling phonetic key, often with o (1)
- clerked — 1 pair sides, mostly vowel via spelling phonetic key, often with merced (1)
- deez — 1 pair sides, mostly spelling via spelling phonetic key, often with mean (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| TYB | Get Merced | 23 | 17 | 78 | loose |
