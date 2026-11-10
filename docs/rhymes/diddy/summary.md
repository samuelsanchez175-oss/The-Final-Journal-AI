# Diddy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Diddy
- Songs: 1
- Bars kept (Diddy lyric lines): 60
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Diddy.
- Credit strings: Diddy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 361
- REPEAT pairs, recorded separately: 35
- END rhymes: 70
- INNER rhymes: 291

By match:

- PERFECT: 34 (END 22, INNER 12)
- SLANT: 138 (END 22, INNER 116)
- ASSONANCE: 188 (END 26, INNER 162)
- MULTI: 1 (END 0, INNER 1)

By confidence:

- HIGH: 32
- MED: 316
- LOW: 13

## Core

- Core Y: 359
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 158 (43.8%)
- vowel: 188 (52.1%)
- spelling: 14 (3.9%)
- multi: 1 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 67 pairs (END 13, INNER 54). Words: when, flesh, get, left, else, heaven, never, test.
2. `vow:EY` — 30 pairs (END 12, INNER 18). Words: pray, baby, play, stay, gave, away, game, failed.
3. `vow:IY` — 27 pairs (END 0, INNER 27). Words: speedin, feedin, streets, pieces, east, cream, cleaned, leavin.
4. `vow:AY` — 19 pairs (END 0, INNER 19). Words: sometimes, nights, like, diamonds, life, fightin, cried, shine.
5. `vow:AA` — 16 pairs (END 1, INNER 15). Words: gotta, dark, parties, wasn't, toxic, god, garden, chopper.
6. `slant:EH:stop` — 15 pairs (END 11, INNER 4). Words: left, best, get, rest, test, blessed, married, blend.
7. `cmu:EH-S-T` — 10 pairs (END 10, INNER 0). Words: best, manifest, test, blessed, rest, impressed.
8. `vow:AE` — 10 pairs (END 0, INNER 10). Words: action, can, stand, jackson, cap, ballin, lamb, sand.
9. `vow:OW` — 10 pairs (END 0, INNER 10). Words: go, don't, whole, no, won't, only, coke, holdin.
10. `slant:IY:sib-stop` — 8 pairs (END 0, INNER 8). Words: feet, east, streets, obese, piece, reese.
11. `slant:EH:sib-stop` — 7 pairs (END 4, INNER 3). Words: stress, manifest, get, squares, married, blessed, impressed, jets.
12. `cmu:EY` — 6 pairs (END 6, INNER 0). Words: stay, away, play, pray.
13. `slant:AE:nas-stop` — 6 pairs (END 0, INNER 6). Words: can, stand, fat, can't, cap.
14. `slant:EY:nas-stop` — 6 pairs (END 1, INNER 5). Words: pain, baby, ain't, game, made.
15. `slant:IY:sib` — 6 pairs (END 1, INNER 5). Words: streets, obese, piece, reese.
16. `slant:AY:stop` — 5 pairs (END 0, INNER 5). Words: like, cried, mighty, night, find.
17. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: chopper, got, gotta, body, hockey, rod.
18. `slant:AY:nas-stop` — 4 pairs (END 0, INNER 4). Words: shine, sign, night, cried, like, mighty.
19. `slant:IH:liq-nas` — 4 pairs (END 0, INNER 4). Words: lil, ring, ting, still.
20. `cmu:EY-S` — 3 pairs (END 3, INNER 0). Words: space, face, base.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- leray — 5 pair sides, mostly spelling via spelling phonetic key, often with married (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with turn (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with only (1)
- fam — 1 pair sides, mostly spelling via spelling phonetic key, often with lamb (1)
- hort — 1 pair sides, mostly spelling via spelling phonetic key, often with more (1)
- derif — 1 pair sides, mostly spelling via spelling phonetic key, often with theres (1)
- bezel — 1 pair sides, mostly vowel via spelling phonetic key, often with never (1)
- facetime — 1 pair sides, mostly vowel via spelling phonetic key, often with have (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Diddy | Another One Of Me | 60 | 70 | 291 | loose |
