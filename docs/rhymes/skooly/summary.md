# Skooly rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Skooly
- Songs: 1
- Bars kept (Skooly lyric lines): 38
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Skooly.
- Credit strings: Skooly.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 251
- REPEAT pairs, recorded separately: 77
- END rhymes: 38
- INNER rhymes: 213

By match:

- PERFECT: 13 (END 3, INNER 10)
- SLANT: 110 (END 22, INNER 88)
- ASSONANCE: 128 (END 13, INNER 115)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 13
- MED: 228
- LOW: 10

## Core

- Core Y: 250
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 112 (44.6%)
- vowel: 128 (51.0%)
- spelling: 11 (4.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 39 pairs (END 11, INNER 28). Words: funds, fucking, guns, motherfucker, run, double, brother, truck.
2. `vow:AE` — 35 pairs (END 2, INNER 33). Words: jammed, that'll, can't, man, last, damn, savage, gang.
3. `slant:AH:sib` — 18 pairs (END 12, INNER 6). Words: funds, guns.
4. `slant:AA:stop` — 16 pairs (END 0, INNER 16). Words: not, got, robbed, mob, job, cobb, bought, chopper.
5. `vow:IH` — 16 pairs (END 0, INNER 16). Words: dripping, shit, bitch, wishes, bricks, shrimp, whip.
6. `vow:AA` — 14 pairs (END 0, INNER 14). Words: cops, problems, got, not, profit, mob, costra, mama.
7. `vow:EH` — 11 pairs (END 0, INNER 11). Words: credit, getting, when, handheld, flexing, get, friendly, better.
8. `slant:AE:nas-stop` — 7 pairs (END 0, INNER 7). Words: man, canned, can't, damn, jammed, ran'd.
9. `slant:AE:stop` — 7 pairs (END 2, INNER 5). Words: jammed, can't, canned, ran'd, last.
10. `slant:EH:stop` — 7 pairs (END 0, INNER 7). Words: get, better, credit.
11. `slant:IH:stop` — 7 pairs (END 0, INNER 7). Words: pick, nigga, picked, shit, whip.
12. `slant:AH:sib-stop` — 6 pairs (END 0, INNER 6). Words: brother, club, cup, motherfucker, guns, front.
13. `slant:AE:nas` — 5 pairs (END 0, INNER 5). Words: damn, man, gang, hang.
14. `slant:AH:nas-sib` — 5 pairs (END 4, INNER 1). Words: guns, run.
15. `cmu:AA-B` — 4 pairs (END 0, INNER 4). Words: cobb, mob, job, rob.
16. `cmu:AY-D` — 3 pairs (END 0, INNER 3). Words: hide, inside.
17. `slant:EH:nas-stop` — 3 pairs (END 0, INNER 3). Words: get, getting, when.
18. `slant:IH:sib-stop` — 3 pairs (END 0, INNER 3). Words: whip, bitch, niggas, nigga.
19. `vow:AY` — 3 pairs (END 0, INNER 3). Words: why, time, hide, inside.
20. `vow:EY` — 3 pairs (END 0, INNER 3). Words: ave, baby, cocaine, lame.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 5 pair sides, mostly spelling via spelling phonetic key, often with pick (4)
- backwood — 2 pair sides, mostly spelling via spelling phonetic key, often with hood (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- skooly — 2 pair sides, mostly vowel via spelling phonetic key, often with only (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- flauge — 1 pair sides, mostly spelling via spelling phonetic key, often with gone (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Skooly | 21 Guns | 38 | 38 | 213 | loose |
