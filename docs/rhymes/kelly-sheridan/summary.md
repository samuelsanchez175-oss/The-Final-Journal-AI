# Kelly Sheridan rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Kelly Sheridan
- Songs: 1
- Bars kept (Kelly Sheridan lyric lines): 18
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Kelly Sheridan.
- Credit strings: Kelly Sheridan.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 72
- REPEAT pairs, recorded separately: 8
- END rhymes: 3
- INNER rhymes: 69

By match:

- PERFECT: 2 (END 0, INNER 2)
- SLANT: 19 (END 2, INNER 17)
- ASSONANCE: 51 (END 1, INNER 50)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 1
- MED: 70
- LOW: 1

## Core

- Core Y: 71
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 20 (27.8%)
- vowel: 51 (70.8%)
- spelling: 1 (1.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 25 pairs (END 0, INNER 25). Words: princess, king, kingdom, little, quickly, lived, different, lives.
2. `vow:EH` — 9 pairs (END 1, INNER 8). Words: erika, parents, second, every, very, identical, met, care.
3. `vow:AH` — 5 pairs (END 0, INNER 5). Words: something, loved, much, what, struck, young.
4. `slant:AH:nas-stop` — 3 pairs (END 1, INNER 2). Words: what, young, run, struck.
5. `vow:IY` — 3 pairs (END 0, INNER 3). Words: people, needed, queen, seeking.
6. `slant:EH:fric-liq` — 2 pairs (END 0, INNER 2). Words: care, every, never.
7. `slant:EY:nas-stop` — 2 pairs (END 0, INNER 2). Words: same, baby.
8. `vow:AA` — 2 pairs (END 0, INNER 2). Words: started, wasn't, shocked.
9. `vow:AE` — 2 pairs (END 0, INNER 2). Words: anneliese, have, had, bankrupt.
10. `vow:AY` — 2 pairs (END 0, INNER 2). Words: surprising, mine, nearby, wife.
11. `vow:EY` — 2 pairs (END 0, INNER 2). Words: baby, named, able, fate.
12. `cmu:AW` — 1 pairs (END 0, INNER 1). Words: now, how.
13. `slant:AH:stop` — 1 pairs (END 1, INNER 0). Words: what, struck.
14. `slant:AO:liq-stop` — 1 pairs (END 0, INNER 1). Words: pauper, all.
15. `slant:AO:stop` — 1 pairs (END 0, INNER 1). Words: daughter, pauper.
16. `slant:AY:nas-sib` — 1 pairs (END 0, INNER 1). Words: mine, miners.
17. `slant:EH:fric-stop` — 1 pairs (END 0, INNER 1). Words: never, met.
18. `slant:EH:liq-stop` — 1 pairs (END 0, INNER 1). Words: care, met.
19. `slant:ER:liq-stop` — 1 pairs (END 0, INNER 1). Words: girl, worried.
20. `slant:EY:fric-stop` — 1 pairs (END 0, INNER 1). Words: take, save.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- anneliese — 1 pair sides, mostly vowel via spelling phonetic key, often with have (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Kelly Sheridan | Introduction To “Barbie As The Princess And The Pauper” | 18 | 3 | 69 | loose |
