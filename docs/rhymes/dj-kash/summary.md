# DJ Kash rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Kash
- Songs: 1
- Bars kept (DJ Kash lyric lines): 44
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DJ Kash.
- Credit strings: DJ Kash.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 335
- REPEAT pairs, recorded separately: 44
- END rhymes: 78
- INNER rhymes: 257

By match:

- PERFECT: 37 (END 16, INNER 21)
- SLANT: 167 (END 50, INNER 117)
- ASSONANCE: 131 (END 12, INNER 119)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 36
- MED: 280
- LOW: 19

## Core

- Core Y: 331
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 188 (56.1%)
- vowel: 131 (39.1%)
- spelling: 16 (4.8%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 39 pairs (END 0, INNER 39). Words: don't, no, know, gold, go, whole, phone, joke.
2. `vow:AY` — 38 pairs (END 10, INNER 28). Words: mind, fi, lie, time, lights, line, showtime, like.
3. `slant:AY:nas-stop` — 30 pairs (END 14, INNER 16). Words: mind, like, line, ride, time, nine, mine, shine.
4. `slant:AY:nas` — 19 pairs (END 17, INNER 2). Words: time, line, showtime, nine, whine, mine, sign, fine.
5. `vow:AA` — 15 pairs (END 0, INNER 15). Words: heart, body, 'marco, shots, compound, yah, want, pon.
6. `cmu:OW` — 13 pairs (END 0, INNER 13). Words: know, go, no, slow, toe, show.
7. `slant:AY:liq-nas` — 13 pairs (END 0, INNER 13). Words: i'll, line, time, mine, fine, whine.
8. `cmu:AY-N` — 12 pairs (END 12, INNER 0). Words: mine, nine, line, sign, fine, whine.
9. `vow:IY` — 11 pairs (END 0, INNER 11). Words: freaky, shawty, di, mi, here, queen, goalie.
10. `slant:AW:nas-stop` — 10 pairs (END 10, INNER 0). Words: down, 'round, round, sound, crown.
11. `slant:IH:nas-stop` — 10 pairs (END 0, INNER 10). Words: thing, bring, liquor, twitter, tip, skin, dig, i'ma.
12. `slant:AH:fric-nas` — 7 pairs (END 0, INNER 7). Words: love, come, done, enough.
13. `vow:IH` — 7 pairs (END 2, INNER 5). Words: things, little, hit, liquor, bring, thing, twitter.
14. `vow:EY` — 6 pairs (END 0, INNER 6). Words: say, wait, place, hate, make, baby.
15. `slant:AY:stop` — 5 pairs (END 2, INNER 3). Words: mind, ride, brighter, bright, right.
16. `vow:AH` — 5 pairs (END 0, INNER 5). Words: must, bumper, touch, come, buss.
17. `vow:AW` — 5 pairs (END 0, INNER 5). Words: how, down, round, sound, crown, 'round.
18. `slant:AY:liq-stop` — 4 pairs (END 0, INNER 4). Words: like, i'll.
19. `slant:EH:liq-stop` — 4 pairs (END 0, INNER 4). Words: tell, get, head, tear.
20. `slant:AH:nas` — 3 pairs (END 0, INNER 3). Words: come, done.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with bring (1)
- shawty — 4 pair sides, mostly vowel via spelling phonetic key, often with freaky (3)
- gyal — 2 pair sides, mostly spelling via spelling phonetic key, often with queen (2)
- gwan — 2 pair sides, mostly spelling via spelling phonetic key, often with dance (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Kash | Slow Whine | 44 | 78 | 257 | loose |
