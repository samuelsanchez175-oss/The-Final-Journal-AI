# Giggs rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Giggs
- Songs: 1
- Bars kept (Giggs lyric lines): 43
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Giggs.
- Credit strings: Giggs.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 222
- REPEAT pairs, recorded separately: 8
- END rhymes: 47
- INNER rhymes: 175

By match:

- PERFECT: 16 (END 8, INNER 8)
- SLANT: 85 (END 20, INNER 65)
- ASSONANCE: 118 (END 16, INNER 102)
- MULTI: 3 (END 3, INNER 0)

By confidence:

- HIGH: 19
- MED: 194
- LOW: 9

## Core

- Core Y: 221
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 93 (41.9%)
- vowel: 118 (53.2%)
- spelling: 8 (3.6%)
- multi: 3 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 30 pairs (END 8, INNER 22). Words: got, starve, sparks, stars, not, heart, parked, entourage.
2. `vow:EH` — 20 pairs (END 0, INNER 20). Words: pretentious, left, where, questions, extensions, general, let, extended.
3. `vow:OW` — 20 pairs (END 0, INNER 20). Words: don't, no, those, low, over, know, lovin, bro.
4. `vow:AH` — 12 pairs (END 4, INNER 8). Words: fuck, trust, london, somethin, numbers, double, gun, thumb.
5. `slant:AH:nas` — 11 pairs (END 8, INNER 3). Words: hummin, thumb, bun, comin, somethin, gun, london, drummin.
6. `vow:AY` — 11 pairs (END 3, INNER 8). Words: vibes, dubai, drivin, by, five, might, like, guys.
7. `vow:IH` — 9 pairs (END 0, INNER 9). Words: isn't, fifty, hit, stickin, winnin, clip, diss, him.
8. `slant:AA:sib-stop` — 5 pairs (END 0, INNER 5). Words: got, entourage, camouflage, shots, mascots.
9. `vow:EY` — 5 pairs (END 0, INNER 5). Words: fake, gave, spray, play, say, layin, stay.
10. `vow:IY` — 5 pairs (END 0, INNER 5). Words: see, leave, these, please, green.
11. `vow:AE` — 4 pairs (END 1, INNER 3). Words: last, staff, chance, ran, laugh.
12. `cmu:AY-D` — 3 pairs (END 3, INNER 0). Words: side, unidentified, slide.
13. `multi:AH-M-IH-NG` — 3 pairs (END 3, INNER 0). Words: hummin, comin, drummin.
14. `slant:AA:sib` — 3 pairs (END 3, INNER 0). Words: sparks, stars, charts, parts.
15. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: got, heart, parked, start.
16. `slant:AY:fric-stop` — 3 pairs (END 0, INNER 3). Words: five, terrified, might, like.
17. `slant:AY:stop` — 3 pairs (END 0, INNER 3). Words: right, unidentified, slide, might, like.
18. `slant:EH:liq-stop` — 3 pairs (END 0, INNER 3). Words: general, twenty, mental, meant, get, hair.
19. `slant:EH:nas-stop` — 3 pairs (END 0, INNER 3). Words: get, when, gettin.
20. `slant:IH:fric-stop` — 3 pairs (END 0, INNER 3). Words: wifey, trip, fifty, give.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- wifey — 4 pair sides, mostly spelling via spelling phonetic key, often with fifty (1)
- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with hit (1)
- dawgs — 1 pair sides, mostly spelling via spelling phonetic key, often with cross (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- glocks — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Giggs | By Chance | 43 | 47 | 175 | loose |
