# Sean Kingston rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Sean Kingston
- Songs: 1
- Bars kept (Sean Kingston lyric lines): 41
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Sean Kingston.
- Credit strings: Sean Kingston.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 193
- REPEAT pairs, recorded separately: 22
- END rhymes: 34
- INNER rhymes: 159

By match:

- PERFECT: 26 (END 8, INNER 18)
- SLANT: 84 (END 11, INNER 73)
- ASSONANCE: 82 (END 14, INNER 68)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 26
- MED: 157
- LOW: 10

## Core

- Core Y: 192
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 100 (51.8%)
- vowel: 82 (42.5%)
- spelling: 10 (5.2%)
- multi: 1 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 16 pairs (END 0, INNER 16). Words: know, don't, holdin, won't, go, no, hope, lambo.
2. `vow:EY` — 15 pairs (END 5, INNER 10). Words: way, say, faithful, away, face, favor, straight, day.
3. `vow:AY` — 11 pairs (END 5, INNER 6). Words: times, why, by, time, sometimes, butterfly, sides, terrified.
4. `slant:AE:stop` — 8 pairs (END 2, INNER 6). Words: back, can't, rap, tap, lap, lambo, past, 'raq.
5. `vow:AE` — 7 pairs (END 1, INNER 6). Words: last, havin, past, cash, bag, can, back.
6. `vow:EH` — 7 pairs (END 0, INNER 7). Words: fellas, get, many, left, let, air, m's, tesla.
7. `vow:IY` — 7 pairs (END 3, INNER 4). Words: feel, tv, demons, sixteen, creepin, see, need.
8. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: know, go, no.
9. `cmu:UH-D` — 6 pairs (END 0, INNER 6). Words: could, good, hood, wood.
10. `slant:AH:sib-stop` — 6 pairs (END 0, INNER 6). Words: what, other, buss, fuck, much, duck.
11. `slant:EH:liq-stop` — 6 pairs (END 0, INNER 6). Words: let, tell, get, air, umbrella.
12. `slant:UH:stop` — 6 pairs (END 0, INNER 6). Words: look, hood, book, good, could, took.
13. `cmu:EY` — 5 pairs (END 5, INNER 0). Words: stay, day, away, runaway.
14. `slant:AH:fric-stop` — 5 pairs (END 0, INNER 5). Words: love, what, fuck, duck, thug.
15. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: what, some, run, someone, money, fuck, jump.
16. `vow:AH` — 5 pairs (END 0, INNER 5). Words: struggle, couple, what, run, some, someone.
17. `vow:UH` — 5 pairs (END 0, INNER 5). Words: lookin, could, backwoods, good, look.
18. `slant:EH:liq` — 4 pairs (END 1, INNER 3). Words: hella, umbrella, air, tell.
19. `vow:AA` — 4 pairs (END 0, INNER 4). Words: darkest, scarred, problem, ma, nothin.
20. `slant:AH:stop` — 3 pairs (END 0, INNER 3). Words: what, duck, fuck, thug.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- hella — 4 pair sides, mostly spelling via spelling phonetic key, often with tell (1)
- raq — 2 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- lambo — 2 pair sides, mostly vowel via spelling phonetic key, often with throw (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with finger (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with all (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Sean Kingston | Darkest Times | 41 | 34 | 159 | loose |
