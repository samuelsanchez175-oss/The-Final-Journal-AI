# KAIBA rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: KAIBA
- Songs: 1
- Bars kept (KAIBA lyric lines): 31
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: KAIBA.
- Credit strings: KAIBA.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 131
- REPEAT pairs, recorded separately: 12
- END rhymes: 38
- INNER rhymes: 93

By match:

- PERFECT: 19 (END 12, INNER 7)
- SLANT: 56 (END 8, INNER 48)
- ASSONANCE: 54 (END 18, INNER 36)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 21
- MED: 87
- LOW: 23

## Core

- Core Y: 112
- Core N among rhyme pairs: 19

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 71 (54.2%)
- vowel: 54 (41.2%)
- spelling: 4 (3.1%)
- multi: 2 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 19 pairs (END 15, INNER 4). Words: henny, xanny, molly, daddy, gucci, family, shady, ferrari.
2. `cmu:AE-K` — 12 pairs (END 12, INNER 0). Words: back, black, pack, crack.
3. `vow:AE` — 12 pairs (END 3, INNER 9). Words: fast, back, can’t, family, crack, daddy, man, black.
4. `slant:AE:sib-stop` — 8 pairs (END 0, INNER 8). Words: gas, racks, back, black, fast, pack, crack.
5. `vow:AA` — 7 pairs (END 0, INNER 7). Words: molly, poppin, ferrari, dropping, shoppin, rocking.
6. `slant:AE:nas-stop` — 6 pairs (END 0, INNER 6). Words: man, can, back, mac, black, had.
7. `vow:IH` — 6 pairs (END 0, INNER 6). Words: bitch, sippin, think, rich, big, living.
8. `slant:ER:sib-stop` — 5 pairs (END 4, INNER 1). Words: herb, reverse, earth, shirt, curse.
9. `slant:AA:liq-stop` — 4 pairs (END 0, INNER 4). Words: not, follow, pop, ferrari, molly.
10. `cmu:UW` — 3 pairs (END 0, INNER 3). Words: threw, blew, two.
11. `slant:AE:stop` — 3 pairs (END 0, INNER 3). Words: daddy, had, mac.
12. `slant:EH:nas` — 3 pairs (END 0, INNER 3). Words: henny, many, em, dem.
13. `slant:IH:sib-stop` — 3 pairs (END 0, INNER 3). Words: bitch, big, shit.
14. `vow:OW` — 3 pairs (END 0, INNER 3). Words: don’t, told, smokin, dope.
15. `vow:UW` — 3 pairs (END 0, INNER 3). Words: goofy, two, blew, booty.
16. `cmu:IH-CH` — 2 pairs (END 0, INNER 2). Words: bitch, rich.
17. `multi:AA-P-IH-NG` — 2 pairs (END 0, INNER 2). Words: poppin, dropping, shoppin.
18. `slant:AA:liq` — 2 pairs (END 1, INNER 1). Words: ferrari, follow, molly.
19. `slant:AA:nas` — 2 pairs (END 0, INNER 2). Words: rocking, poppin, shoppin.
20. `slant:AA:nas-stop` — 2 pairs (END 0, INNER 2). Words: pop, poppin, dropping.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- henny — 17 pair sides, mostly vowel via spelling phonetic key, often with daddy (3)
- xanny — 6 pair sides, mostly vowel via spelling phonetic key, often with molly (2)
- cuz — 1 pair sides, mostly spelling via spelling phonetic key, often with one (1)
- dem — 1 pair sides, mostly spelling via spelling phonetic key, often with henny (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| KAIBA | Overdose (Remix) | 31 | 38 | 93 | loose |
