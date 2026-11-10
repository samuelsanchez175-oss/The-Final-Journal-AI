# 24hrs rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 24hrs
- Songs: 1
- Bars kept (24hrs lyric lines): 33
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: 24hrs.
- Credit strings: 24hrs.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 202
- REPEAT pairs, recorded separately: 36
- END rhymes: 46
- INNER rhymes: 156

By match:

- PERFECT: 7 (END 4, INNER 3)
- SLANT: 96 (END 27, INNER 69)
- ASSONANCE: 97 (END 15, INNER 82)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 6
- MED: 190
- LOW: 6

## Core

- Core Y: 201
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 96 (47.5%)
- vowel: 97 (48.0%)
- spelling: 7 (3.5%)
- multi: 2 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 34 pairs (END 12, INNER 22). Words: shift, think, really, bitch, strips, lips, weird, clips.
2. `vow:EY` — 33 pairs (END 0, INNER 33). Words: ain't, day, fake, baby, takin, take, flame, same.
3. `vow:IY` — 11 pairs (END 0, INNER 11). Words: see, real, evening, these, b, rizzy, baby, feed.
4. `slant:IH:sib-stop` — 10 pairs (END 5, INNER 5). Words: spaceship, bitch, hit, strips, weird, niggas, nigga, lips.
5. `slant:EY:nas-stop` — 8 pairs (END 0, INNER 8). Words: baby, flame, sayin, same, libs, take.
6. `slant:AA:nas-stop` — 7 pairs (END 0, INNER 7). Words: wanna, want, got.
7. `slant:EY:stop` — 7 pairs (END 2, INNER 5). Words: fake, baby, eight, ain't, take.
8. `vow:EH` — 7 pairs (END 3, INNER 4). Words: twenty, pressure, compression, lesson, dressin, press.
9. `slant:IH:sib` — 5 pairs (END 4, INNER 1). Words: serious, clips, ears, lips, niggas, ribs.
10. `vow:OW` — 5 pairs (END 0, INNER 5). Words: know, told, don't, sosa.
11. `vow:AA` — 4 pairs (END 0, INNER 4). Words: want, r, car.
12. `cmu:IH-P-S` — 3 pairs (END 3, INNER 0). Words: strips, lips, clips.
13. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: what, one, fuckin, fuck.
14. `slant:AO:liq-stop` — 3 pairs (END 0, INNER 3). Words: call, talk, thought, all.
15. `slant:EH:nas` — 3 pairs (END 3, INNER 0). Words: lesson, dressin, compression.
16. `slant:EH:nas-sib` — 3 pairs (END 3, INNER 0). Words: press, lesson, dressin, pressure, compression.
17. `slant:IH:liq-sib` — 3 pairs (END 2, INNER 1). Words: mirror, bitch, pill, serious, ears.
18. `slant:IH:stop` — 3 pairs (END 0, INNER 3). Words: hit, shift, spaceship.
19. `slant:IY:liq-sib` — 3 pairs (END 0, INNER 3). Words: these, real, feel, teach.
20. `slant:UW:fric-sib` — 3 pairs (END 3, INNER 0). Words: groovy, jacuzzi, movies.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- libs — 6 pair sides, mostly cmu via vault phonetic_class, often with baby (2)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- bling — 3 pair sides, mostly spelling via spelling phonetic key, often with love (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- louboutin — 1 pair sides, mostly spelling via spelling phonetic key, often with louboutins (1)
- louboutins — 1 pair sides, mostly spelling via spelling phonetic key, often with louboutin (1)
- rizzy — 1 pair sides, mostly vowel via spelling phonetic key, often with baby (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 24hrs | Huh | 33 | 46 | 156 | loose |
