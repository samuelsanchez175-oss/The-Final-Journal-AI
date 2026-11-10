# Nas rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Nas
- Songs: 1
- Bars kept (Nas lyric lines): 49
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Nas.
- Credit strings: Nas.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 383
- REPEAT pairs, recorded separately: 19
- END rhymes: 78
- INNER rhymes: 305

By match:

- PERFECT: 34 (END 8, INNER 26)
- SLANT: 135 (END 25, INNER 110)
- ASSONANCE: 206 (END 43, INNER 163)
- MULTI: 8 (END 2, INNER 6)

By confidence:

- HIGH: 41
- MED: 326
- LOW: 16

## Core

- Core Y: 381
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 152 (39.7%)
- vowel: 206 (53.8%)
- spelling: 17 (4.4%)
- multi: 8 (2.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 65 pairs (END 14, INNER 51). Words: legend, never, get, destiny, successfully, expected, relevance, cells.
2. `vow:EY` — 36 pairs (END 14, INNER 22). Words: replaced, came, determination, nation, pace, age, faces, caucasians.
3. `vow:OW` — 25 pairs (END 0, INNER 25). Words: no, don't, goat, opened, most, tone, o, know.
4. `vow:AY` — 21 pairs (END 12, INNER 9). Words: mind, signed, likes, wipin, buy, like, hype, side.
5. `slant:AY:nas-stop` — 16 pairs (END 5, INNER 11). Words: like, nine, line, tryin, hype, signed, shyne, mind.
6. `vow:AE` — 15 pairs (END 0, INNER 15). Words: rappers, chasin, back, bandwagon, fans, rather, land, pass.
7. `vow:IY` — 10 pairs (END 0, INNER 10). Words: keepin, see, mainstream, here, p, queens, features, g.
8. `vow:AA` — 9 pairs (END 0, INNER 9). Words: bonds, stocks, got, capo, don, escobar.
9. `slant:AY:stop` — 8 pairs (END 2, INNER 6). Words: like, hype, right, knight, type.
10. `multi:EY-SH-AH-N` — 7 pairs (END 2, INNER 5). Words: nation, conversation, determination, interpretation, exploitation.
11. `slant:AY:liq-stop` — 7 pairs (END 1, INNER 6). Words: wiley, like, pile, right, side, wipe, type, while.
12. `slant:EH:sib-stop` — 7 pairs (END 0, INNER 7). Words: get, ed, less, invest, bless, press, ss, together.
13. `vow:AH` — 7 pairs (END 0, INNER 7). Words: culture, love, ones, such, must’ve, fucked, one, run.
14. `vow:AO` — 7 pairs (END 0, INNER 7). Words: all, forth, blogs, y'all, york, saw.
15. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: no, o, know, tomorrow.
16. `cmu:AH-N` — 5 pairs (END 1, INNER 4). Words: one, gun, son, run.
17. `slant:AY:nas` — 5 pairs (END 5, INNER 0). Words: tryin, rhyme, line, nine, shyne.
18. `slant:EH:stop` — 5 pairs (END 0, INNER 5). Words: get, against, left, trajectory, expected, invest, next, went.
19. `cmu:IY` — 4 pairs (END 0, INNER 4). Words: see, g, t, p.
20. `slant:AA:nas-stop` — 4 pairs (END 0, INNER 4). Words: got, don, wanna, capo, glock.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- lyin — 4 pair sides, mostly spelling via spelling phonetic key, often with tryin (1)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with disease (1)
- dyin — 3 pair sides, mostly spelling via spelling phonetic key, often with sayin (2)
- gav — 2 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- kehinde — 2 pair sides, mostly vowel via spelling phonetic key, often with bless (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with figures (1)
- fam — 1 pair sides, mostly spelling via spelling phonetic key, often with rapper (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with mic (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- doin — 1 pair sides, mostly spelling via spelling phonetic key, often with goin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Nas | One Mic, One Gun | 49 | 78 | 305 | loose |
