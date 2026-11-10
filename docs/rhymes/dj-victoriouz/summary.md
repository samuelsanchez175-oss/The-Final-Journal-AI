# DJ Victoriouz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Victoriouz
- Songs: 1
- Bars kept (DJ Victoriouz lyric lines): 42
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DJ Victoriouz.
- Credit strings: DJ Victoriouz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 128
- REPEAT pairs, recorded separately: 23
- END rhymes: 27
- INNER rhymes: 101

By match:

- PERFECT: 15 (END 5, INNER 10)
- SLANT: 62 (END 11, INNER 51)
- ASSONANCE: 51 (END 11, INNER 40)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 14
- MED: 108
- LOW: 6

## Core

- Core Y: 127
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 71 (55.5%)
- vowel: 51 (39.8%)
- spelling: 6 (4.7%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 15 pairs (END 0, INNER 15). Words: don't, no, go, know, only, roll, tote.
2. `vow:AW` — 10 pairs (END 8, INNER 2). Words: now, house, around, down, mouth, pounds.
3. `slant:IH:liq-stop` — 9 pairs (END 0, INNER 9). Words: hit, still, shit, kill, lil, flip, will.
4. `vow:EY` — 9 pairs (END 0, INNER 9). Words: ain't, play, say, names, games, change.
5. `slant:AA:stop` — 8 pairs (END 2, INNER 6). Words: squad, robbed, stop, gotta, block, hot.
6. `vow:AE` — 6 pairs (END 3, INNER 3). Words: mans, stash, have, lames, hammers, cash, catch, flash.
7. `vow:IH` — 5 pairs (END 0, INNER 5). Words: limit, chris, kill, lil, switch, witness, bitch.
8. `cmu:AO-L` — 4 pairs (END 1, INNER 3). Words: all, ball, call.
9. `slant:IH:liq-sib` — 4 pairs (END 0, INNER 4). Words: chris, kill, switch, lil.
10. `slant:IH:sib-stop` — 4 pairs (END 1, INNER 3). Words: shit, switch, chris, hit.
11. `cmu:AE-SH` — 3 pairs (END 3, INNER 0). Words: stash, cash, flash.
12. `slant:AE:sib` — 3 pairs (END 0, INNER 3). Words: catch, hammers, mans, cash, flash.
13. `slant:AE:sib-stop` — 3 pairs (END 0, INNER 3). Words: cash, trap, mad.
14. `slant:AW:nas-sib` — 3 pairs (END 1, INNER 2). Words: down, mouth, house.
15. `slant:OW:nas-stop` — 3 pairs (END 0, INNER 3). Words: gon, don't, tote.
16. `vow:EH` — 3 pairs (END 0, INNER 3). Words: gettin, flexin, get, left, red.
17. `slant:AH:nas-sib` — 2 pairs (END 0, INNER 2). Words: money, much.
18. `slant:AH:stop` — 2 pairs (END 0, INNER 2). Words: fuck, what.
19. `slant:AW:nas-stop` — 2 pairs (END 2, INNER 0). Words: around, down.
20. `slant:AW:sib` — 2 pairs (END 1, INNER 1). Words: house, mouth.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- cuz — 1 pair sides, mostly spelling via spelling phonetic key, often with fuck (1)
- lames — 1 pair sides, mostly vowel via spelling phonetic key, often with have (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with killas (1)
- killas — 1 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- opps — 1 pair sides, mostly spelling via spelling phonetic key, often with glocks (1)
- glocks — 1 pair sides, mostly spelling via spelling phonetic key, often with opps (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Victoriouz | Small Circle | 42 | 27 | 101 | loose |
