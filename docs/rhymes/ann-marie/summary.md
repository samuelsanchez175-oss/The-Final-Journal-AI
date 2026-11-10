# Ann Marie rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ann Marie
- Songs: 2
- Bars kept (Ann Marie lyric lines): 81
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Ann Marie.
- Credit strings: Ann Marie.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 536
- REPEAT pairs, recorded separately: 53
- END rhymes: 106
- INNER rhymes: 430

By match:

- PERFECT: 52 (END 13, INNER 39)
- SLANT: 275 (END 59, INNER 216)
- ASSONANCE: 209 (END 34, INNER 175)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 50
- MED: 473
- LOW: 13

## Core

- Core Y: 534
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 314 (58.6%)
- vowel: 209 (39.0%)
- spelling: 13 (2.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AY:stop` — 42 pairs (END 8, INNER 34). Words: like, type, right, quiet, excited, denied, tried, inside.
2. `vow:AY` — 42 pairs (END 5, INNER 37). Words: like, eye, high, signs, violent, surprised, behind, time.
3. `vow:OW` — 37 pairs (END 2, INNER 35). Words: know, don't, go, home, bro, won't, soldier, told.
4. `vow:EH` — 32 pairs (END 0, INNER 32). Words: potential, gettin, where, mention, when, west, staring, every.
5. `slant:AY:nas-stop` — 29 pairs (END 9, INNER 20). Words: mine, time, like, valentine, right, line, type, wide.
6. `vow:IY` — 28 pairs (END 15, INNER 13). Words: needs, knee, need, cheated, feel, freak, g, complete.
7. `vow:EY` — 23 pairs (END 4, INNER 19). Words: ain't, make, way, baby, babe, today, play, stay.
8. `vow:AW` — 21 pairs (END 8, INNER 13). Words: now, around, down, about, 'bout, sound, foul, clown.
9. `slant:IY:stop` — 15 pairs (END 8, INNER 7). Words: complete, need, freak, asleep, cheated, petite, freaky.
10. `slant:AW:sib-stop` — 12 pairs (END 8, INNER 4). Words: about, couch, house, pouch, doubt, without, scout, mouth.
11. `slant:EH:liq-stop` — 10 pairs (END 0, INNER 10). Words: where, bed, yet, let, get, met.
12. `cmu:AY-D` — 9 pairs (END 3, INNER 6). Words: outside, tried, denied, inside, southside, wide, side, ride.
13. `slant:AH:nas-stop` — 9 pairs (END 0, INNER 9). Words: what, come, money, some, done, fuck, one.
14. `slant:EH:fric-stop` — 9 pairs (END 0, INNER 9). Words: let, get, every, ever, whatever, never, yet, met.
15. `slant:EH:nas-stop` — 9 pairs (END 0, INNER 9). Words: when, gettin, let, plenty, get, wet.
16. `vow:AE` — 9 pairs (END 0, INNER 9). Words: handle, act, can't, mad, can, ann, have, family.
17. `cmu:OW` — 8 pairs (END 1, INNER 7). Words: go, know, show, bro, no.
18. `slant:AO:liq-stop` — 8 pairs (END 7, INNER 1). Words: all, call, taught, doggy, naughty, audi, talk.
19. `cmu:AO-L` — 6 pairs (END 1, INNER 5). Words: all, call, tall.
20. `slant:AE:nas-stop` — 6 pairs (END 0, INNER 6). Words: can, mad, can't, damn, back, stand.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with slip (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with phone (2)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with scream (1)
- lambo — 3 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with hit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ann Marie | DND | 30 | 32 | 176 | loose |
| Ann Marie | Stress Relief | 51 | 74 | 254 | loose |
