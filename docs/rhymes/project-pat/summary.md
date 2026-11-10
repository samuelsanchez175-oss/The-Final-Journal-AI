# Project Pat rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Project Pat
- Songs: 1
- Bars kept (Project Pat lyric lines): 35
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Project Pat.
- Credit strings: Project Pat.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 309
- REPEAT pairs, recorded separately: 31
- END rhymes: 36
- INNER rhymes: 273

By match:

- PERFECT: 47 (END 13, INNER 34)
- SLANT: 149 (END 18, INNER 131)
- ASSONANCE: 111 (END 5, INNER 106)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 41
- MED: 253
- LOW: 15

## Core

- Core Y: 306
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 176 (57.0%)
- vowel: 111 (35.9%)
- spelling: 20 (6.5%)
- multi: 2 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 36 pairs (END 4, INNER 32). Words: pockets, stoppin, clock, started, got, coppin, not, want.
2. `vow:AE` — 20 pairs (END 0, INNER 20). Words: ass, spank, act, have, ballin, bands, fast, snatch.
3. `vow:IY` — 20 pairs (END 0, INNER 20). Words: thirty, jeans, meet, three, teeth, these, keep, millimeter.
4. `slant:AA:stop` — 14 pairs (END 2, INNER 12). Words: got, stop, plot, clock, opp, op, not, want.
5. `cmu:EH-D` — 12 pairs (END 8, INNER 4). Words: dead, fed, cred, lead, head.
6. `slant:AH:nas` — 10 pairs (END 0, INNER 10). Words: runnin, money, run, tummy, drum, son, done, fun.
7. `cmu:AH-N` — 9 pairs (END 0, INNER 9). Words: done, fun, gun, son, run.
8. `slant:EH:sib-stop` — 9 pairs (END 6, INNER 3). Words: feds, together, dead, lead, get, head, fed, cred.
9. `vow:IH` — 9 pairs (END 0, INNER 9). Words: years, pistol, fiendin, clip, bitch, king, shit, kid.
10. `vow:OW` — 9 pairs (END 0, INNER 9). Words: loaded, go, gold, know, no, don't, blow, bro.
11. `slant:AA:nas-stop` — 8 pairs (END 2, INNER 6). Words: stop, poppin, stoppin, got, gonna, opp, op, coppin.
12. `slant:AE:sib-stop` — 8 pairs (END 0, INNER 8). Words: ass, bad, bag, grab, fast, snatch, black.
13. `vow:AH` — 7 pairs (END 0, INNER 7). Words: fuckin, what's, funk, blood, cousin, young, money.
14. `slant:AA:sib` — 6 pairs (END 1, INNER 5). Words: pockets, bottles, models, swallows, cops.
15. `slant:AA:sib-stop` — 6 pairs (END 2, INNER 4). Words: props, cops, stop, op, opp.
16. `cmu:AA-P` — 5 pairs (END 1, INNER 4). Words: stop, op, opp.
17. `cmu:OW` — 5 pairs (END 0, INNER 5). Words: slow, blow, bro, know, go.
18. `slant:AA:nas-sib` — 5 pairs (END 1, INNER 4). Words: cops, stoppin, props, poppin, coppin.
19. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: fuck, young, fuckin, funk, money, blood.
20. `slant:EH:fric-stop` — 5 pairs (END 1, INNER 4). Words: ever, get, lead, steph.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- cred — 7 pair sides, mostly spelling via spelling phonetic key, often with dead (2)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- fiendin — 4 pair sides, mostly vowel via spelling phonetic key, often with clip (1)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with clip (1)
- twerkin — 3 pair sides, mostly spelling via spelling phonetic key, often with hurtin (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- balmain — 2 pair sides, mostly spelling via spelling phonetic key, often with ballin (2)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with keep (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Project Pat | 30 Clip | 35 | 36 | 273 | loose |
