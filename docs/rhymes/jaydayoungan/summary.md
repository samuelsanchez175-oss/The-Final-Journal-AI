# JayDaYoungan rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: JayDaYoungan
- Songs: 1
- Bars kept (JayDaYoungan lyric lines): 34
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: JayDaYoungan.
- Credit strings: JayDaYoungan.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 235
- REPEAT pairs, recorded separately: 25
- END rhymes: 64
- INNER rhymes: 171

By match:

- PERFECT: 33 (END 16, INNER 17)
- SLANT: 80 (END 11, INNER 69)
- ASSONANCE: 122 (END 37, INNER 85)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 33
- MED: 200
- LOW: 2

## Core

- Core Y: 235
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 110 (46.8%)
- vowel: 122 (51.9%)
- spelling: 3 (1.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 40 pairs (END 14, INNER 26). Words: don't, know, go, cold, close, slow, control, hope.
2. `vow:EH` — 31 pairs (END 14, INNER 17). Words: against, left, bentley, when, smell, careful, gettin, get.
3. `vow:IY` — 30 pairs (END 9, INNER 21). Words: bleedin, even, see, deep, secret, mean, v, speed.
4. `cmu:OW` — 13 pairs (END 10, INNER 3). Words: know, go, slow, glow.
5. `slant:EH:nas-stop` — 8 pairs (END 0, INNER 8). Words: when, get, let, gettin, already, head, ten.
6. `slant:IY:nas-stop` — 8 pairs (END 4, INNER 4). Words: mean, keep, deep, seen, bleedin, need, speed, lyin.
7. `vow:AY` — 6 pairs (END 0, INNER 6). Words: why, grind, cryin, pipe, i'll, sometimes, like.
8. `cmu:EH-L` — 4 pairs (END 4, INNER 0). Words: hell, smell, tell.
9. `slant:EH:fric-liq` — 4 pairs (END 0, INNER 4). Words: ever, tell, hell, there, smell.
10. `slant:EH:liq` — 4 pairs (END 4, INNER 0). Words: there, smell, tell, hell.
11. `vow:AH` — 4 pairs (END 0, INNER 4). Words: somethin, love, cut, done, wonder, trust.
12. `cmu:AY` — 3 pairs (END 0, INNER 3). Words: why, lie.
13. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: cut, done, wonder, one, someone.
14. `slant:AH:stop` — 3 pairs (END 0, INNER 3). Words: fuck, what, cut, trust.
15. `slant:EH:sib-stop` — 3 pairs (END 0, INNER 3). Words: guess, let, get, head.
16. `slant:EH:stop` — 3 pairs (END 0, INNER 3). Words: get, read, head, let.
17. `slant:IH:fric-stop` — 3 pairs (END 0, INNER 3). Words: shit, give.
18. `slant:IY:fric-nas` — 3 pairs (END 0, INNER 3). Words: leave, seein, even, mean, believe.
19. `vow:EY` — 3 pairs (END 0, INNER 3). Words: ain't, always, make, say.
20. `vow:IH` — 3 pairs (END 0, INNER 3). Words: thinkin, shit, give.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with speed (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| JayDaYoungan | Broken Promises | 34 | 64 | 171 | loose |
