# Beece Daytona rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Beece Daytona
- Songs: 1
- Bars kept (Beece Daytona lyric lines): 45
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Beece Daytona.
- Credit strings: Beece Daytona.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 277
- REPEAT pairs, recorded separately: 45
- END rhymes: 64
- INNER rhymes: 213

By match:

- PERFECT: 31 (END 8, INNER 23)
- SLANT: 112 (END 31, INNER 81)
- ASSONANCE: 132 (END 25, INNER 107)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 33
- MED: 222
- LOW: 22

## Core

- Core Y: 272
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 124 (44.8%)
- vowel: 132 (47.7%)
- spelling: 19 (6.9%)
- multi: 2 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 38 pairs (END 12, INNER 26). Words: hit, chickens, wishes, giving, dishes, big, suspicious, digits.
2. `vow:AA` — 29 pairs (END 4, INNER 25). Words: soft, hard, robbers, got, robbing, god, boulevard, block.
3. `slant:AA:stop` — 28 pairs (END 12, INNER 16). Words: god, hard, got, squad, boulevard, block, lot, bond.
4. `vow:OW` — 27 pairs (END 5, INNER 22). Words: don't, go, bro, toasters, coca, won't, choke, sosa.
5. `slant:IH:nas-sib` — 10 pairs (END 3, INNER 7). Words: bitch, i'ma, mission, king, dishes, wishes, suspicious.
6. `cmu:IY` — 9 pairs (END 0, INNER 9). Words: d, dee, probably, sea.
7. `vow:AE` — 9 pairs (END 0, INNER 9). Words: hands, can, bags, trap, strapped, act, have, gang.
8. `cmu:AA-R-D` — 7 pairs (END 4, INNER 3). Words: hard, boulevard.
9. `slant:IH:sib` — 7 pairs (END 6, INNER 1). Words: dishes, wishes, suspicious, digits, chickens, niggas.
10. `slant:IH:stop` — 7 pairs (END 1, INNER 6). Words: nigga, hit, slip, bullshit, big, whip.
11. `cmu:OW` — 5 pairs (END 3, INNER 2). Words: bo, go, lo, no, though.
12. `slant:OW:sib-stop` — 5 pairs (END 3, INNER 2). Words: sosa, coca, choke, mocha, stroker, explode.
13. `slant:OW:stop` — 5 pairs (END 3, INNER 2). Words: choke, stroker, coca, mocha.
14. `vow:AH` — 5 pairs (END 0, INNER 5). Words: bunched, one, nothing, gun, what, young, guns.
15. `vow:EY` — 5 pairs (END 0, INNER 5). Words: james, cake, say, later, taped, ain't, make.
16. `vow:IY` — 5 pairs (END 0, INNER 5). Words: keep, d, dee, probably, sea.
17. `slant:IH:nas-stop` — 4 pairs (END 0, INNER 4). Words: thing, slip, hit, bullshit, slipping.
18. `slant:IH:sib-stop` — 4 pairs (END 0, INNER 4). Words: bitch, whip, niggas, nigga, kick.
19. `vow:AY` — 4 pairs (END 0, INNER 4). Words: like, why, grind.
20. `vow:UW` — 4 pairs (END 4, INNER 0). Words: pluto, ju, oozo's.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- stroker — 5 pair sides, mostly spelling via spelling phonetic key, often with coca (1)
- nigga — 5 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- oblock — 3 pair sides, mostly spelling via spelling phonetic key, often with block (2)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with chickens (1)
- gots — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- totas — 2 pair sides, mostly vowel via spelling phonetic key, often with mocha (1)
- oozos — 1 pair sides, mostly vowel via spelling phonetic key, often with pluto (1)
- beece — 1 pair sides, mostly spelling via spelling phonetic key, often with well (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Beece Daytona | Boulevard | 45 | 64 | 213 | loose |
