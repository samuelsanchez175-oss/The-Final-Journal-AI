# Luxlie rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Luxlie
- Songs: 1
- Bars kept (Luxlie lyric lines): 16
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Luxlie.
- Credit strings: Luxlie.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 79
- REPEAT pairs, recorded separately: 5
- END rhymes: 5
- INNER rhymes: 74

By match:

- PERFECT: 2 (END 0, INNER 2)
- SLANT: 30 (END 4, INNER 26)
- ASSONANCE: 47 (END 1, INNER 46)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 2
- MED: 73
- LOW: 4

## Core

- Core Y: 79
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 28 (35.4%)
- vowel: 47 (59.5%)
- spelling: 4 (5.1%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 12 pairs (END 0, INNER 12). Words: result, dumpin, love, hundred, fucked, guns, some, fuckin.
2. `vow:IH` — 12 pairs (END 0, INNER 12). Words: lil, bitch, opinions, think, invisible.
3. `vow:IY` — 6 pairs (END 0, INNER 6). Words: ceiling, beat, bougie, nobody, these.
4. `vow:AA` — 5 pairs (END 0, INNER 5). Words: box, narcos, backyard, not, got, lot, heart, hot.
5. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: heart, got, lot, hot.
6. `slant:AE:nas` — 3 pairs (END 3, INNER 0). Words: man, kanye, damn.
7. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: had, man, kanye, damn.
8. `vow:EH` — 3 pairs (END 0, INNER 3). Words: 'member, letter, head, perfect.
9. `vow:EY` — 3 pairs (END 1, INNER 2). Words: make, away, stains, chase.
10. `slant:AE:fric-stop` — 2 pairs (END 0, INNER 2). Words: have, back, rapper.
11. `slant:AH:nas-stop` — 2 pairs (END 0, INNER 2). Words: plug, done, some.
12. `slant:EH:stop` — 2 pairs (END 0, INNER 2). Words: head, letter, perfect.
13. `slant:IH:liq-sib` — 2 pairs (END 0, INNER 2). Words: lil, bitch.
14. `vow:AW` — 2 pairs (END 0, INNER 2). Words: thousand, 'bout, county.
15. `vow:AY` — 2 pairs (END 0, INNER 2). Words: like, times.
16. `cmu:AA-T` — 1 pairs (END 0, INNER 1). Words: got, lot.
17. `cmu:IY` — 1 pairs (END 0, INNER 1). Words: bougie, nobody.
18. `slant:AA:sib` — 1 pairs (END 0, INNER 1). Words: box, narcos.
19. `slant:AE:nas-sib` — 1 pairs (END 1, INNER 0). Words: cash, man.
20. `slant:AE:stop` — 1 pairs (END 0, INNER 1). Words: back, rapper.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- kanye — 3 pair sides, mostly spelling via spelling phonetic key, often with man (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with beat (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Luxlie | All shit remember | 16 | 5 | 74 | loose |
