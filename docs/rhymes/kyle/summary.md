# KYLE rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: KYLE
- Songs: 1
- Bars kept (KYLE lyric lines): 54
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: KYLE.
- Credit strings: KYLE.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 402
- REPEAT pairs, recorded separately: 34
- END rhymes: 96
- INNER rhymes: 306

By match:

- PERFECT: 38 (END 12, INNER 26)
- SLANT: 109 (END 19, INNER 90)
- ASSONANCE: 241 (END 64, INNER 177)
- MULTI: 14 (END 1, INNER 13)

By confidence:

- HIGH: 49
- MED: 340
- LOW: 13

## Core

- Core Y: 401
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 132 (32.8%)
- vowel: 241 (60.0%)
- spelling: 15 (3.7%)
- multi: 14 (3.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 68 pairs (END 35, INNER 33). Words: see, need, even, libra, knievel, reefer, zebra, liter.
2. `vow:OW` — 57 pairs (END 8, INNER 49). Words: don't, know, goes, shows, coasters, oprah, focus, cold.
3. `vow:AY` — 34 pairs (END 12, INNER 22). Words: eye, spy, likes, wife, mind, high, miles, fine.
4. `vow:EY` — 28 pairs (END 6, INNER 22). Words: ain't, always, ain’t, away, angel, soleil, place, babe.
5. `vow:IH` — 21 pairs (END 3, INNER 18). Words: since, think, vision, kids, shit, still, lil, pill.
6. `vow:EH` — 14 pairs (END 0, INNER 14). Words: text, headed, gettin, well, when, let's, end, friend.
7. `cmu:AY` — 13 pairs (END 6, INNER 7). Words: eye, spy, high, lie, reply, fly.
8. `vow:AA` — 11 pairs (END 0, INNER 11). Words: cause, wanting, nothin, far, watching, wanna, want, dropping.
9. `slant:IY:liq-stop` — 8 pairs (END 4, INNER 4). Words: here, real, need, delete, rita, freak, feel.
10. `slant:IY:stop` — 8 pairs (END 5, INNER 3). Words: need, delete, freak, rita, liter.
11. `cmu:EY` — 7 pairs (END 2, INNER 5). Words: away, throwaway, day, pray, say, stay.
12. `multi:EH-V-ER` — 7 pairs (END 0, INNER 7). Words: ever, never, forever, hold never, forever ever, means forever, ain’t never, don’t ever.
13. `slant:AE:nas-stop` — 6 pairs (END 0, INNER 6). Words: can, back, black, happy, kodak, man.
14. `slant:EH:fric-stop` — 6 pairs (END 0, INNER 6). Words: get, ever, never, forever, said.
15. `slant:EH:nas-stop` — 5 pairs (END 0, INNER 5). Words: when, many, get, went, end, said.
16. `slant:OW:stop` — 5 pairs (END 1, INNER 4). Words: don't, otay, post, note, scope, posted.
17. `slant:EH:fric-nas` — 4 pairs (END 0, INNER 4). Words: many, never, ever, forever, when.
18. `slant:IY:liq` — 4 pairs (END 3, INNER 1). Words: here, real, zebra, libra, feel.
19. `slant:IY:sib-stop` — 4 pairs (END 0, INNER 4). Words: she’s, these, need, liter, delete, freak.
20. `slant:OW:nas-stop` — 4 pairs (END 0, INNER 4). Words: coastin, gon, post, posted, note, don't.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- otay — 5 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- spliff — 2 pair sides, mostly vowel via spelling phonetic key, often with pill (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with note (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- codeine — 1 pair sides, mostly spelling via spelling phonetic key, often with smokin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| KYLE | iSpy (Remix) | 54 | 96 | 306 | loose |
