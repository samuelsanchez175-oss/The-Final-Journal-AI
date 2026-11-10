# Derez De’Shon rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Derez De’Shon
- Songs: 1
- Bars kept (Derez De’Shon lyric lines): 31
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Derez De’Shon.
- Credit strings: Derez De’Shon.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 269
- REPEAT pairs, recorded separately: 30
- END rhymes: 33
- INNER rhymes: 236

By match:

- PERFECT: 12 (END 1, INNER 11)
- SLANT: 124 (END 5, INNER 119)
- ASSONANCE: 133 (END 27, INNER 106)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 12
- MED: 228
- LOW: 29

## Core

- Core Y: 266
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 110 (40.9%)
- vowel: 133 (49.4%)
- spelling: 26 (9.7%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 42 pairs (END 8, INNER 34). Words: odds, cost, hard, wanna, large, god, yard, start.
2. `vow:IH` — 33 pairs (END 16, INNER 17). Words: prescription, forgiveness, bitch, prison, him, miss, trippin, livin.
3. `vow:EY` — 17 pairs (END 1, INNER 16). Words: changed, day, came, hated, gave, weigh, stayed, wake.
4. `vow:EH` — 16 pairs (END 1, INNER 15). Words: prayers, when, send, derez, de'shon, self, head, chariot.
5. `slant:AA:sib-stop` — 12 pairs (END 3, INNER 9). Words: hard, large, yard, odds, god, charge, apart, cars.
6. `slant:AA:sib` — 11 pairs (END 0, INNER 11). Words: odds, cars, scars, cards, large, regardless.
7. `slant:IY:nas-stop` — 11 pairs (END 0, INNER 11). Words: tryna, beat, beater, beaker.
8. `slant:IY:sib-stop` — 10 pairs (END 0, INNER 10). Words: these, beat, streets, beater, beaker.
9. `slant:EH:sib-stop` — 9 pairs (END 0, INNER 9). Words: derez, scared, head, meds, prayers, chariot, buried.
10. `vow:OW` — 9 pairs (END 1, INNER 8). Words: don't, flow, smoke, ho, bankroll, told, won't.
11. `vow:IY` — 8 pairs (END 0, INNER 8). Words: g, keep, these, feelin, streets, free, see, beat.
12. `slant:EH:fric-stop` — 6 pairs (END 0, INNER 6). Words: never, let, dead, every, get.
13. `slant:IY:fric-stop` — 6 pairs (END 0, INNER 6). Words: believe, beat, beater, beaker.
14. `slant:EH:stop` — 5 pairs (END 0, INNER 5). Words: send, scared, chariot, let, dead, head, buried.
15. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: hated, stayed, wake, played, baby, eighty.
16. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: hard, apart, god, cost, yard.
17. `slant:IY:liq-stop` — 4 pairs (END 0, INNER 4). Words: feel, beat, beater.
18. `slant:IY:stop` — 4 pairs (END 0, INNER 4). Words: beat, beater, beaker, keep.
19. `cmu:AO-L` — 3 pairs (END 1, INNER 2). Words: wall, fall, tall.
20. `slant:EH:liq-sib` — 3 pairs (END 0, INNER 3). Words: swear, prayers, derez.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 16 pair sides, mostly spelling via spelling phonetic key, often with beat (9)
- derez — 10 pair sides, mostly spelling via spelling phonetic key, often with chariot (2)
- meds — 2 pair sides, mostly spelling via spelling phonetic key, often with head (2)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with til (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Derez De’Shon | Beat The Odds | 31 | 33 | 236 | loose |
