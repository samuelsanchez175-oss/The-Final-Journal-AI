# 1WayFrank rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 1WayFrank
- Songs: 1
- Bars kept (1WayFrank lyric lines): 68
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: 1WayFrank.
- Credit strings: 1WayFrank.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 331
- REPEAT pairs, recorded separately: 37
- END rhymes: 81
- INNER rhymes: 250

By match:

- PERFECT: 32 (END 11, INNER 21)
- SLANT: 107 (END 15, INNER 92)
- ASSONANCE: 186 (END 54, INNER 132)
- MULTI: 6 (END 1, INNER 5)

By confidence:

- HIGH: 31
- MED: 275
- LOW: 25

## Core

- Core Y: 320
- Core N among rhyme pairs: 11

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 115 (34.7%)
- vowel: 186 (56.2%)
- spelling: 24 (7.3%)
- multi: 6 (1.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 42 pairs (END 19, INNER 23). Words: family, masked, mattress, snappin, cabinets, grammy, have, had.
2. `vow:AH` — 33 pairs (END 16, INNER 17). Words: hustler, young, ruffles, brothers, love, busta, hustle, duffles.
3. `vow:IY` — 28 pairs (END 11, INNER 17). Words: need, dreams, fiends, cd, believe, reeboks, i'ma, green.
4. `vow:EY` — 24 pairs (END 4, INNER 20). Words: make, day, say, game, someday, jay, dale, wait.
5. `vow:IH` — 23 pairs (END 0, INNER 23). Words: nigga, imma, licks, bills, consistent, livin, rich, bringing.
6. `vow:OW` — 15 pairs (END 0, INNER 15). Words: clothes, no, go, know, told, posted, grown, alone.
7. `cmu:EY` — 10 pairs (END 1, INNER 9). Words: say, day, jay, someday, pay.
8. `slant:AH:nas` — 8 pairs (END 1, INNER 7). Words: comin, one, come, son, young, money, summer.
9. `slant:EH:nas-stop` — 8 pairs (END 0, INNER 8). Words: get, when, gettin, met, em.
10. `vow:AY` — 8 pairs (END 4, INNER 4). Words: ridin, grind, line, childish, why, time, flyin, dry.
11. `slant:AA:stop` — 7 pairs (END 0, INNER 7). Words: block, hot, hotter, god, got, locked, shot, stop.
12. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: nigga, rip, hit, big, city.
13. `slant:AE:nas` — 5 pairs (END 1, INNER 4). Words: snatchin, snappin, happen, trappin, rappin.
14. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: fuck, one, plug, run, come, money.
15. `slant:AY:nas` — 5 pairs (END 4, INNER 1). Words: flyin, time, line, ridin.
16. `spell:ay` — 5 pairs (END 2, INNER 3). Words: gunplay, say, jay, day, someday.
17. `vow:EH` — 5 pairs (END 0, INNER 5). Words: gettin, when, where, menace.
18. `cmu:IY` — 4 pairs (END 3, INNER 1). Words: see, tv, cd, i'ma, d.
19. `multi:AE-P-IH-NG` — 4 pairs (END 1, INNER 3). Words: trappin, snappin, rappin.
20. `slant:AA:sib-stop` — 4 pairs (END 0, INNER 4). Words: watch, block, rocks, hot, hotter.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 12 pair sides, mostly spelling via spelling phonetic key, often with imma (6)
- imma — 7 pair sides, mostly vowel via spelling phonetic key, often with nigga (6)
- duffles — 5 pair sides, mostly vowel via spelling phonetic key, often with hustle (1)
- gunplay — 5 pair sides, mostly spelling via spelling phonetic key, often with say (2)
- ima — 4 pair sides, mostly vowel via vault phonetic_class, often with team (1)
- finell — 2 pair sides, mostly spelling via spelling phonetic key, often with shell (1)
- feinin — 2 pair sides, mostly spelling via spelling phonetic key, often with struglin (1)
- struglin — 2 pair sides, mostly spelling via spelling phonetic key, often with feinin (1)
- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with flyin (1)
- creezy — 1 pair sides, mostly spelling via spelling phonetic key, often with cheese (1)
- enell — 1 pair sides, mostly spelling via spelling phonetic key, often with finell (1)
- shootas — 1 pair sides, mostly spelling via spelling phonetic key, often with gas (1)
- keke — 1 pair sides, mostly spelling via spelling phonetic key, often with met (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with gon (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 1WayFrank | Make it Happen | 68 | 81 | 250 | loose |
