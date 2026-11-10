# Rich Homie Quan rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rich Homie Quan
- Songs: 1
- Bars kept (Rich Homie Quan lyric lines): 47
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Rich Homie Quan.
- Credit strings: Rich Homie Quan.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 304
- REPEAT pairs, recorded separately: 63
- END rhymes: 57
- INNER rhymes: 247

By match:

- PERFECT: 42 (END 7, INNER 35)
- SLANT: 128 (END 20, INNER 108)
- ASSONANCE: 133 (END 29, INNER 104)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 42
- MED: 252
- LOW: 10

## Core

- Core Y: 299
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 165 (54.3%)
- vowel: 133 (43.8%)
- spelling: 5 (1.6%)
- multi: 1 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 56 pairs (END 26, INNER 30). Words: ransom, can't, had, bananas, braggin, answer, naggin, fact.
2. `vow:OW` — 23 pairs (END 0, INNER 23). Words: don't, no, know, go, totin, hold, o.
3. `vow:AA` — 18 pairs (END 0, INNER 18). Words: problems, pockets, got, revolvin, solve, want, stop, nothin.
4. `cmu:OW` — 17 pairs (END 0, INNER 17). Words: know, no, go, o.
5. `cmu:AO-R` — 15 pairs (END 3, INNER 12). Words: before, galore, more, shore, pour, four.
6. `slant:AO:liq` — 14 pairs (END 2, INNER 12). Words: all, before, galore, more, shore.
7. `slant:AE:stop` — 13 pairs (END 8, INNER 5). Words: strapped, act, can't, had, back, stacked, wrap, fact.
8. `vow:IH` — 12 pairs (END 0, INNER 12). Words: millions, listen, i'mma, nigga, lil, strippin, shiverin, gon.
9. `slant:AA:nas-stop` — 9 pairs (END 0, INNER 9). Words: got, momma, wanna, block, gotta.
10. `slant:AE:nas-stop` — 6 pairs (END 0, INNER 6). Words: man, can't, had, ran, trap, cappin, cap.
11. `slant:AE:sib-stop` — 6 pairs (END 3, INNER 3). Words: dash, mad, cash, had, class, back, pad.
12. `slant:AH:nas` — 6 pairs (END 0, INNER 6). Words: money, some, young, fuckin.
13. `slant:IY:stop` — 6 pairs (END 0, INNER 6). Words: speak, sleep, eat, need.
14. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: fuck, money, some, young, one.
15. `slant:AO:liq-stop` — 5 pairs (END 2, INNER 3). Words: court, galore, before, more.
16. `vow:AH` — 5 pairs (END 0, INNER 5). Words: stuffed, fuck, some, young, money.
17. `vow:AO` — 5 pairs (END 2, INNER 3). Words: court, all, mornin, four, pour.
18. `slant:IH:nas-sib` — 4 pairs (END 0, INNER 4). Words: bitch, bring, askin.
19. `slant:IY:sib-stop` — 4 pairs (END 0, INNER 4). Words: these, sleep, speak, eat, need.
20. `vow:AY` — 4 pairs (END 0, INNER 4). Words: like, ridin, fly.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 6 pair sides, mostly spelling via vault phonetic_class, often with dont (3)
- swervin — 5 pair sides, mostly vowel via vault phonetic_class, often with cant (2)
- karats — 3 pair sides, mostly vowel via spelling phonetic key, often with dash (1)
- nigga — 3 pair sides, mostly vowel via spelling phonetic key, often with imma (2)
- imma — 2 pair sides, mostly vowel via spelling phonetic key, often with nigga (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rich Homie Quan | Ya Ya | 47 | 57 | 247 | loose |
