# Big Flock rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Big Flock
- Songs: 1
- Bars kept (Big Flock lyric lines): 32
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Big Flock.
- Credit strings: Big Flock.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 230
- REPEAT pairs, recorded separately: 34
- END rhymes: 34
- INNER rhymes: 196

By match:

- PERFECT: 13 (END 7, INNER 6)
- SLANT: 130 (END 17, INNER 113)
- ASSONANCE: 80 (END 9, INNER 71)
- MULTI: 7 (END 1, INNER 6)

By confidence:

- HIGH: 16
- MED: 199
- LOW: 15

## Core

- Core Y: 229
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 126 (54.8%)
- vowel: 80 (34.8%)
- spelling: 17 (7.4%)
- multi: 7 (3.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 25 pairs (END 0, INNER 25). Words: ain't, paint, baby, scrape, toothpaste, make, kkk, stay.
2. `vow:AH` — 24 pairs (END 9, INNER 15). Words: cuttin, something, bun, drum, son, sucking, love, klux.
3. `slant:IH:sib-stop` — 15 pairs (END 4, INNER 11). Words: bitch, big, nigga, niggas, hip, clip.
4. `vow:AE` — 15 pairs (END 0, INNER 15). Words: savage, black, back, commander, man, tag, can't, van.
5. `slant:AA:stop` — 13 pairs (END 1, INNER 12). Words: got, cock, hop, swapped, glock, lot, block, flock.
6. `slant:AE:nas-stop` — 13 pairs (END 0, INNER 13). Words: black, jackie, klan, chan, man, tag, van, gang.
7. `slant:AH:nas-sib` — 12 pairs (END 0, INNER 12). Words: brother, mother, other, bun, drum, honey, son.
8. `slant:EY:stop` — 10 pairs (END 0, INNER 10). Words: toothpaste, babe, ain't, baby, escape, hate, awake, ape.
9. `slant:AH:nas` — 7 pairs (END 1, INNER 6). Words: drum, honey, bun, son, running, something, cumberbun.
10. `slant:IH:stop` — 7 pairs (END 0, INNER 7). Words: nigga, big, hip, clip, shit.
11. `vow:IH` — 7 pairs (END 0, INNER 7). Words: killed, big, kicking, years, bitch, clip, shit.
12. `multi:AH-DH-ER` — 6 pairs (END 0, INNER 6). Words: ass mother, find other, brother, mother, other, shoot brother.
13. `slant:AH:nas-stop` — 6 pairs (END 5, INNER 1). Words: gutter, son, cuttin, young, tuck, bun, buttercup.
14. `slant:AA:nas-stop` — 5 pairs (END 0, INNER 5). Words: mama, got, cock, hop, lot.
15. `slant:AE:nas` — 5 pairs (END 5, INNER 0). Words: gang, chan, man, klan.
16. `slant:EY:sib-stop` — 5 pairs (END 0, INNER 5). Words: face, ape, babe, scrape, toothpaste, baby.
17. `cmu:AE-N` — 3 pairs (END 3, INNER 0). Words: klan, chan, man.
18. `slant:AA:sib-stop` — 3 pairs (END 0, INNER 3). Words: fox, glock, flock.
19. `slant:AE:stop` — 3 pairs (END 0, INNER 3). Words: black, jackie, tag.
20. `slant:AH:fric-nas` — 3 pairs (END 0, INNER 3). Words: love, young, some.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 11 pair sides, mostly spelling via spelling phonetic key, often with niggas (6)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- cumberbun — 3 pair sides, mostly spelling via spelling phonetic key, often with something (1)
- glocka — 2 pair sides, mostly spelling via spelling phonetic key, often with glock (2)
- camo — 1 pair sides, mostly multi via spelling phonetic key, often with ammo (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Big Flock | Black KKK | 32 | 34 | 196 | loose |
