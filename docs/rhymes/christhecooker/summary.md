# ChrisTheCooker rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: ChrisTheCooker
- Songs: 1
- Bars kept (ChrisTheCooker lyric lines): 32
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: ChrisTheCooker.
- Credit strings: ChrisTheCooker.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 82
- REPEAT pairs, recorded separately: 5
- END rhymes: 17
- INNER rhymes: 65

By match:

- PERFECT: 4 (END 0, INNER 4)
- SLANT: 28 (END 7, INNER 21)
- ASSONANCE: 50 (END 10, INNER 40)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 2
- MED: 77
- LOW: 3

## Core

- Core Y: 82
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 27 (32.9%)
- vowel: 50 (61.0%)
- spelling: 5 (6.1%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 8 pairs (END 0, INNER 8). Words: when, gets, getting, breakfast, steady, where, better, prepare.
2. `vow:AA` — 6 pairs (END 2, INNER 4). Words: mom, hard, dark, dogs, commas, caught, stocks, cards.
3. `vow:AE` — 6 pairs (END 3, INNER 3). Words: camry, acura’s, panic, had, past, family, plan, back.
4. `vow:AW` — 6 pairs (END 3, INNER 3). Words: now, around, down, handouts.
5. `vow:EY` — 6 pairs (END 0, INNER 6). Words: crazy, ain’t, stay, way, always, playing, same, taking.
6. `vow:IY` — 5 pairs (END 0, INNER 5). Words: see, street, field, seen, real.
7. `slant:AE:nas-stop` — 4 pairs (END 1, INNER 3). Words: stand, ran, plan, back, man.
8. `vow:AH` — 4 pairs (END 1, INNER 3). Words: rush, lunch, fucked, numbers, one.
9. `vow:AY` — 4 pairs (END 1, INNER 3). Words: time, lights, right, behind, find, inside.
10. `vow:IH` — 3 pairs (END 0, INNER 3). Words: different, since, slippin, still.
11. `slant:AA:sib` — 2 pairs (END 1, INNER 1). Words: honda’s, commas, dogs, stocks.
12. `slant:EH:liq-nas` — 2 pairs (END 0, INNER 2). Words: when, where.
13. `slant:EH:liq-stop` — 2 pairs (END 0, INNER 2). Words: said, where, better, prepare.
14. `slant:EH:nas-stop` — 2 pairs (END 0, INNER 2). Words: when, said.
15. `slant:IY:liq-stop` — 2 pairs (END 0, INNER 2). Words: real, street, field.
16. `vow:OW` — 2 pairs (END 0, INNER 2). Words: go, home.
17. `cmu:EY` — 1 pairs (END 0, INNER 1). Words: stay, play.
18. `cmu:IH-T` — 1 pairs (END 0, INNER 1). Words: hit, shit.
19. `slant:AA:stop` — 1 pairs (END 1, INNER 0). Words: hard, dark.
20. `slant:AE:liq` — 1 pairs (END 1, INNER 0). Words: family, camry.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with commas (1)
- cuz — 2 pair sides, mostly spelling via spelling phonetic key, often with other (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| ChrisTheCooker | Who Run It (Freestlye) - GHerbo #WhoRunItChallenge | 32 | 17 | 65 | loose |
