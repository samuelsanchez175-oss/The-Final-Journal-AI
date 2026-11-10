# B-Lovee rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: B-Lovee
- Songs: 1
- Bars kept (B-Lovee lyric lines): 56
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: B-Lovee.
- Credit strings: B-Lovee.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 307
- REPEAT pairs, recorded separately: 44
- END rhymes: 52
- INNER rhymes: 255

By match:

- PERFECT: 33 (END 5, INNER 28)
- SLANT: 137 (END 22, INNER 115)
- ASSONANCE: 136 (END 24, INNER 112)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 32
- MED: 260
- LOW: 15

## Core

- Core Y: 301
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 160 (52.1%)
- vowel: 136 (44.3%)
- spelling: 10 (3.3%)
- multi: 1 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 42 pairs (END 12, INNER 30). Words: ain't, waste, flame, basic, waitin, day, aim, way.
2. `vow:OW` — 37 pairs (END 12, INNER 25). Words: don't, though, know, those, slow, potholes, roast, post.
3. `slant:AE:stop` — 30 pairs (END 7, INNER 23). Words: act, bad, jatty, ratty, bag, kappa, rapper, nap.
4. `vow:AE` — 30 pairs (END 0, INNER 30). Words: actin, gangster, bad, can't, ask, past, spank, fans.
5. `slant:AA:stop` — 24 pairs (END 0, INNER 24). Words: not, want, got, gotta, start, pop, block, opp.
6. `cmu:OW` — 18 pairs (END 0, INNER 18). Words: though, ho, no, go, know, slow.
7. `slant:AY:fric-stop` — 8 pairs (END 1, INNER 7). Words: life, like, might, night.
8. `slant:AE:nas-stop` — 7 pairs (END 0, INNER 7). Words: cappin, can, nap, mad, slap, rapper, kappa, add.
9. `vow:AA` — 7 pairs (END 0, INNER 7). Words: droppin, pops, knocked, r, got, start, rock, mama.
10. `slant:AA:liq-stop` — 6 pairs (END 0, INNER 6). Words: r, knock, stop, got, start.
11. `slant:EY:stop` — 6 pairs (END 4, INNER 2). Words: basic, waste, ain't, taste, shake.
12. `vow:EH` — 6 pairs (END 0, INNER 6). Words: never, jealous, stressed, tense, l, tens, better.
13. `slant:EY:sib-stop` — 5 pairs (END 5, INNER 0). Words: chase, waste, shake, basic, taste, face.
14. `slant:AA:sib-stop` — 4 pairs (END 0, INNER 4). Words: watch, got, pop, pot.
15. `slant:EY:nas-stop` — 4 pairs (END 1, INNER 3). Words: ain't, rainin, flame, shake, baby.
16. `vow:AY` — 4 pairs (END 0, INNER 4). Words: y, like, why, ride, time.
17. `vow:IH` — 4 pairs (END 0, INNER 4). Words: think, lil, hit, livin, still.
18. `slant:AA:nas-stop` — 3 pairs (END 0, INNER 3). Words: not, wanna, rock, mama, benihana, got.
19. `slant:AE:sib-stop` — 3 pairs (END 0, INNER 3). Words: catch, bad, slap, rapper.
20. `slant:AY:stop` — 3 pairs (END 0, INNER 3). Words: like, ride, might, night.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- jatty — 7 pair sides, mostly spelling via spelling phonetic key, often with act (2)
- glocks — 2 pair sides, mostly vowel via spelling phonetic key, often with slow (1)
- vatos — 1 pair sides, mostly multi via spelling phonetic key, often with patos (1)
- patos — 1 pair sides, mostly multi via spelling phonetic key, often with vatos (1)
- thot — 1 pair sides, mostly spelling via spelling phonetic key, often with got (1)
- migo — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with give (1)
- finsta — 1 pair sides, mostly spelling via spelling phonetic key, often with think (1)
- gangbang — 1 pair sides, mostly vowel via spelling phonetic key, often with fans (1)
- swervo — 1 pair sides, mostly vowel via spelling phonetic key, often with slow (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with dick (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| B-Lovee | My Everything (Part III) | 56 | 52 | 255 | loose |
