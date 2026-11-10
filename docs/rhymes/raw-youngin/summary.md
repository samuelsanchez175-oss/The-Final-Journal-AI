# Raw Youngin rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Raw Youngin
- Songs: 1
- Bars kept (Raw Youngin lyric lines): 34
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Raw Youngin.
- Credit strings: Raw Youngin.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 226
- REPEAT pairs, recorded separately: 21
- END rhymes: 62
- INNER rhymes: 164

By match:

- PERFECT: 22 (END 8, INNER 14)
- SLANT: 86 (END 21, INNER 65)
- ASSONANCE: 118 (END 33, INNER 85)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 21
- MED: 197
- LOW: 8

## Core

- Core Y: 223
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 102 (45.1%)
- vowel: 118 (52.2%)
- spelling: 6 (2.7%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:UW` — 41 pairs (END 27, INNER 14). Words: gon, shoot, booth, cubans, spook, jus, lose, futons.
2. `vow:EH` — 23 pairs (END 0, INNER 23). Words: tellin, entry, when, twenty, gettin, tell, ten, better.
3. `vow:IY` — 15 pairs (END 6, INNER 9). Words: see, streets, weeks, thirteen, lease, nobody, these, leak.
4. `vow:EY` — 12 pairs (END 0, INNER 12). Words: ain't, say, take, hate, raisin, face, stay, play.
5. `vow:OW` — 8 pairs (END 0, INNER 8). Words: whole, don't, dolo, herbo, no, go, yolo, o.
6. `cmu:UW` — 7 pairs (END 5, INNER 2). Words: gon, achoo, flu, blue, jus.
7. `slant:AA:stop` — 7 pairs (END 0, INNER 7). Words: got, glock, doc, caught, block.
8. `slant:UW:sib-stop` — 7 pairs (END 3, INNER 4). Words: booth, shoot, spook, lose, used, shooters.
9. `vow:AE` — 7 pairs (END 0, INNER 7). Words: hand, traffic, pass, havin, trap, gang, lap, salad.
10. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: no, o, throw, go, show.
11. `slant:EH:nas-stop` — 6 pairs (END 0, INNER 6). Words: better, ten, twenty, when, set, many, gettin.
12. `slant:UW:sib` — 6 pairs (END 4, INNER 2). Words: booth, abuse, use, lose, shooters, futons, croutons.
13. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: hate, ain't, take.
14. `slant:EH:liq-nas` — 4 pairs (END 0, INNER 4). Words: tell, when, tellin, ten.
15. `slant:UW:fric-sib` — 4 pairs (END 4, INNER 0). Words: roof, booth, abuse, use.
16. `vow:AH` — 4 pairs (END 0, INNER 4). Words: fuckin, fuck, sons, what, love, young.
17. `cmu:IY` — 3 pairs (END 1, INNER 2). Words: see, nobody, e.
18. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: had, damn, gang, lap.
19. `slant:AH:nas-sib` — 3 pairs (END 1, INNER 2). Words: come, much, sons, done, another, run.
20. `slant:EH:liq-stop` — 3 pairs (END 0, INNER 3). Words: better, tell, twenty, entry.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 16 pair sides, mostly vowel via vault phonetic_class, often with booth (4)
- dolo — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- herbo — 2 pair sides, mostly vowel via spelling phonetic key, often with dolo (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with figure (1)
- kyrie — 1 pair sides, mostly spelling via spelling phonetic key, often with steel (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Raw Youngin | Out Tha Blue | 34 | 62 | 164 | loose |
