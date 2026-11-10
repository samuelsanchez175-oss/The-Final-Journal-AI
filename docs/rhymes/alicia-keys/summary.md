# Alicia Keys rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Alicia Keys
- Songs: 1
- Bars kept (Alicia Keys lyric lines): 51
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Alicia Keys.
- Credit strings: Alicia Keys.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 308
- REPEAT pairs, recorded separately: 69
- END rhymes: 65
- INNER rhymes: 243

By match:

- PERFECT: 24 (END 6, INNER 18)
- SLANT: 149 (END 47, INNER 102)
- ASSONANCE: 134 (END 11, INNER 123)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 24
- MED: 276
- LOW: 8

## Core

- Core Y: 306
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 166 (53.9%)
- vowel: 134 (43.5%)
- spelling: 7 (2.3%)
- multi: 1 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 41 pairs (END 5, INNER 36). Words: like, apply, headlights, time, lights, find, remind, by.
2. `slant:AH:fric-nas` — 29 pairs (END 17, INNER 12). Words: love, done, some, money.
3. `vow:EH` — 24 pairs (END 1, INNER 23). Words: seconds, else, tears, when, helped, get, let, help.
4. `vow:IY` — 24 pairs (END 1, INNER 23). Words: freakin, even, treat, heat, reasons, nobody, season, ptsd.
5. `slant:AH:fric-stop` — 21 pairs (END 17, INNER 4). Words: love, what, hug, tub, thug.
6. `slant:AY:stop` — 16 pairs (END 1, INNER 15). Words: like, denied, inside, tried, fight, died, wipe, remind.
7. `cmu:OW` — 13 pairs (END 0, INNER 13). Words: show, lo, o, know, go.
8. `vow:OW` — 11 pairs (END 0, INNER 11). Words: show, don't, roses, go, home, opps, coldhearted, opened.
9. `slant:EH:fric-stop` — 10 pairs (END 0, INNER 10). Words: never, get, 'head, every, red.
10. `vow:IH` — 9 pairs (END 4, INNER 5). Words: kill, winnin, trippin, years, fears, bill, pill, deer.
11. `slant:AY:nas-stop` — 8 pairs (END 1, INNER 7). Words: time, like, denied, tried.
12. `vow:AE` — 8 pairs (END 0, INNER 8). Words: back, grandma, rather, act, haven't, can't, happy, man.
13. `vow:AH` — 8 pairs (END 0, INNER 8). Words: love, runnin, nothing, money.
14. `slant:AH:nas` — 7 pairs (END 3, INNER 4). Words: done, some, runnin.
15. `slant:AH:nas-stop` — 7 pairs (END 1, INNER 6). Words: some, come, tub, hug, thug, what, done.
16. `vow:EY` — 7 pairs (END 0, INNER 7). Words: ain't, crazy, say, day, paid.
17. `slant:AY:sib-stop` — 5 pairs (END 1, INNER 4). Words: ties, like, denied, tried.
18. `slant:AE:stop` — 4 pairs (END 0, INNER 4). Words: crashed, passionate, bask, haven't, can't.
19. `cmu:IH-L` — 3 pairs (END 3, INNER 0). Words: pill, kill, bill.
20. `slant:EH:liq-nas` — 3 pairs (END 0, INNER 3). Words: when, bear, there.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with season (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with still (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with show (1)
- coldhearted — 1 pair sides, mostly vowel via spelling phonetic key, often with opened (1)
- ove — 1 pair sides, mostly spelling via spelling phonetic key, often with gon (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Alicia Keys | Show Me Love (Remix) | 51 | 65 | 243 | loose |
