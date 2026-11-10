# DJ Showtime rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Showtime
- Songs: 1
- Bars kept (DJ Showtime lyric lines): 70
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DJ Showtime.
- Credit strings: DJ Showtime.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 484
- REPEAT pairs, recorded separately: 115
- END rhymes: 101
- INNER rhymes: 383

By match:

- PERFECT: 39 (END 7, INNER 32)
- SLANT: 203 (END 43, INNER 160)
- ASSONANCE: 223 (END 40, INNER 183)
- MULTI: 19 (END 11, INNER 8)

By confidence:

- HIGH: 57
- MED: 418
- LOW: 9

## Core

- Core Y: 483
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 233 (48.1%)
- vowel: 223 (46.1%)
- spelling: 9 (1.9%)
- multi: 19 (3.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 83 pairs (END 14, INNER 69). Words: tubman, runnin, trust, funds, drunk, money, done, ugly.
2. `vow:EY` — 49 pairs (END 11, INNER 38). Words: slave, plantation, runaway, male, ain't, slavery, james, away.
3. `slant:AH:nas` — 43 pairs (END 7, INNER 36). Words: some, runnin, dumb, hung, done, money, son, coming.
4. `vow:EH` — 34 pairs (END 6, INNER 28). Words: vent, harriet, said, rescued, tear, sentence, sent, went.
5. `cmu:AH-N` — 22 pairs (END 3, INNER 19). Words: done, son, run, gun, won.
6. `slant:EH:stop` — 20 pairs (END 0, INNER 20). Words: get, harriet, kept, shed, sweat, vent, went, left.
7. `vow:AE` — 18 pairs (END 0, INNER 18). Words: standin, can't, had, black, master, actin, toussaint, family.
8. `vow:AY` — 17 pairs (END 7, INNER 10). Words: grind, like, life, behind, fly, fight, survive, rise.
9. `slant:AH:fric-nas` — 11 pairs (END 3, INNER 8). Words: love, done, enough, run, young, won, dumb.
10. `slant:AY:nas-stop` — 11 pairs (END 7, INNER 4). Words: line, fight, grind, iron, like, behind.
11. `slant:EH:liq-stop` — 11 pairs (END 2, INNER 9). Words: tear, get, shed, bloodshed, care, sweat.
12. `slant:AY:fric-nas` — 10 pairs (END 7, INNER 3). Words: line, life, survive, iron.
13. `slant:AY:fric-stop` — 9 pairs (END 4, INNER 5). Words: life, fight, tired, survive.
14. `multi:EY-SH-AH-N` — 8 pairs (END 8, INNER 0). Words: plantation, salvation, foundation.
15. `slant:AE:nas-stop` — 8 pairs (END 0, INNER 8). Words: ran, had, can't, back, gang.
16. `slant:AH:nas-stop` — 8 pairs (END 2, INNER 6). Words: club, done, young, dumb, run, drunk, runnin, kunta.
17. `vow:IH` — 8 pairs (END 1, INNER 7). Words: virginia, years, till, still, build, things, bit, hit.
18. `cmu:EY` — 7 pairs (END 3, INNER 4). Words: today, runaway, away, 'way.
19. `slant:AY:stop` — 6 pairs (END 0, INNER 6). Words: like, right, sniper, society.
20. `slant:IH:nas-stop` — 6 pairs (END 0, INNER 6). Words: hit, him.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- kunta — 3 pair sides, mostly spelling via spelling phonetic key, often with tubman (1)
- finna — 3 pair sides, mostly spelling via spelling phonetic key, often with him (3)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- kinte — 1 pair sides, mostly spelling via spelling phonetic key, often with kunta (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with long (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Showtime | Harriet Tubman | 70 | 101 | 383 | loose |
