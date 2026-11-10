# Normani rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Normani
- Songs: 1
- Bars kept (Normani lyric lines): 34
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Normani.
- Credit strings: Normani.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 184
- REPEAT pairs, recorded separately: 29
- END rhymes: 44
- INNER rhymes: 140

By match:

- PERFECT: 39 (END 20, INNER 19)
- SLANT: 59 (END 11, INNER 48)
- ASSONANCE: 85 (END 12, INNER 73)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 40
- MED: 138
- LOW: 6

## Core

- Core Y: 182
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 94 (51.1%)
- vowel: 85 (46.2%)
- spelling: 4 (2.2%)
- multi: 1 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 21 pairs (END 2, INNER 19). Words: no, won't, know, don't, both, home.
2. `vow:AY` — 19 pairs (END 9, INNER 10). Words: sometimes, drive, shy, sky, guys, lie, spider, fly.
3. `cmu:UH-K` — 15 pairs (END 6, INNER 9). Words: took, book, cook, crook, hook, look.
4. `vow:EH` — 14 pairs (END 0, INNER 14). Words: there's, ex, tell, eh, bed, ever, instead, read.
5. `vow:EY` — 13 pairs (END 0, INNER 13). Words: motivation, baby, stay, break, innovation, say, take.
6. `slant:UH:stop` — 11 pairs (END 10, INNER 1). Words: good, hook, hood, crook, cook, wood, book, took.
7. `cmu:AY` — 10 pairs (END 6, INNER 4). Words: shy, lie, sky, high, fly.
8. `slant:EH:liq-stop` — 8 pairs (END 0, INNER 8). Words: tell, get, chanel, better, swear, read, let, bed.
9. `cmu:UH-D` — 6 pairs (END 6, INNER 0). Words: good, hood, wood, understood.
10. `slant:EY:stop` — 6 pairs (END 0, INNER 6). Words: baby, take, late, make, naked, break.
11. `vow:AE` — 6 pairs (END 0, INNER 6). Words: rap, past, savage, hangin, bags, brand.
12. `vow:AW` — 6 pairs (END 1, INNER 5). Words: about, now, ground.
13. `slant:EH:fric-stop` — 5 pairs (END 0, INNER 5). Words: ever, every, bed, get, let, instead.
14. `cmu:OW` — 3 pairs (END 0, INNER 3). Words: know, no.
15. `vow:IY` — 3 pairs (END 0, INNER 3). Words: flirty, every, baby, libra, each.
16. `cmu:EH-D` — 2 pairs (END 1, INNER 1). Words: bed, instead.
17. `slant:AA:stop` — 2 pairs (END 0, INNER 2). Words: got, drop, top.
18. `slant:AH:nas-stop` — 2 pairs (END 0, INNER 2). Words: what, one, come.
19. `slant:AY:sib` — 2 pairs (END 0, INNER 2). Words: guys, slides, sometimes.
20. `slant:AY:sib-stop` — 2 pairs (END 0, INNER 2). Words: spider, slides, guys.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with give (2)
- flirty — 2 pair sides, mostly vowel via spelling phonetic key, often with every (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with home (1)
- capeesh — 1 pair sides, mostly spelling via spelling phonetic key, often with bags (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Normani | Motivation (Savage Remix) | 34 | 44 | 140 | loose |
