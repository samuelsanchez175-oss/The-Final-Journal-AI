# Bay Swag rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bay Swag
- Songs: 2
- Bars kept (Bay Swag lyric lines): 83
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bay Swag.
- Credit strings: Bay Swag.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 772
- REPEAT pairs, recorded separately: 46
- END rhymes: 97
- INNER rhymes: 675

By match:

- PERFECT: 60 (END 9, INNER 51)
- SLANT: 304 (END 42, INNER 262)
- ASSONANCE: 395 (END 42, INNER 353)
- MULTI: 13 (END 4, INNER 9)

By confidence:

- HIGH: 69
- MED: 659
- LOW: 44

## Core

- Core Y: 761
- Core N among rhyme pairs: 11

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 328 (42.5%)
- vowel: 395 (51.2%)
- spelling: 36 (4.7%)
- multi: 13 (1.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 124 pairs (END 21, INNER 103). Words: ain't, say, way, fainted, famous, patriot, take, day.
2. `vow:EH` — 65 pairs (END 4, INNER 61). Words: whatever, competitive, said, went, m's, left, legend, spend.
3. `vow:IH` — 62 pairs (END 7, INNER 55). Words: tinted, richard, business, bitches, shit, bitch, didn't, big.
4. `vow:OW` — 57 pairs (END 0, INNER 57). Words: don't, no, told, know, rolex, bro, broke, bankrolls.
5. `slant:EH:stop` — 27 pairs (END 5, INNER 22). Words: ready, fetty, edd, ed, eddy, said, send, credit.
6. `vow:IY` — 26 pairs (END 6, INNER 20). Words: even, machete, beams, fiends, streets, seen, deal, leave.
7. `vow:AA` — 22 pairs (END 0, INNER 22). Words: got, started, sharp, flockin, glock, want, mama, compact.
8. `slant:EY:sib` — 19 pairs (END 9, INNER 10). Words: laser, face, stages, acres, h, razors, neighbors, blazers.
9. `slant:IH:stop` — 19 pairs (END 4, INNER 15). Words: big, shit, dick, lit, crib, tinted, rick, trick.
10. `slant:AA:stop` — 18 pairs (END 0, INNER 18). Words: got, pop, rock, glock, want, patek, spot, gotta.
11. `slant:EH:nas-stop` — 17 pairs (END 1, INNER 16). Words: when, n, get, fetty, spend, benny, ready, send.
12. `slant:EY:sib-stop` — 17 pairs (END 6, INNER 11). Words: laser, made, racer, hater, tracer, paper, take, late.
13. `slant:IH:sib-stop` — 15 pairs (END 0, INNER 15). Words: bitch, rich, big, tris, shit, dick, trick, lit.
14. `cmu:OW` — 13 pairs (END 0, INNER 13). Words: know, no, bro, go, studio.
15. `slant:EH:sib-stop` — 13 pairs (END 0, INNER 13). Words: messy, get, tens, fetty, ready, stretch, s, spend.
16. `slant:AY:stop` — 11 pairs (END 0, INNER 11). Words: outside, like, night, hide, ride, find, fight, flight.
17. `vow:AY` — 11 pairs (END 0, INNER 11). Words: find, mind, lifeless, high, like, life, five, ride.
18. `slant:AY:fric-stop` — 10 pairs (END 0, INNER 10). Words: alive, live, ride, life, night, like, hide, fight.
19. `vow:AH` — 9 pairs (END 0, INNER 9). Words: once, some, fuck, fucking, bust, trucks, comin, money.
20. `slant:IH:liq-stop` — 8 pairs (END 0, INNER 8). Words: really, pillow, dick, shit, big, trick, lit, drill.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tris — 7 pair sides, mostly spelling via spelling phonetic key, often with big (1)
- edd — 6 pair sides, mostly spelling via spelling phonetic key, often with ed (1)
- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with win (2)
- bros — 4 pair sides, mostly spelling via spelling phonetic key, often with chrome (1)
- tryna — 4 pair sides, mostly spelling via spelling phonetic key, often with clean (1)
- shitted — 3 pair sides, mostly spelling via spelling phonetic key, often with business (1)
- tazer — 3 pair sides, mostly spelling via spelling phonetic key, often with ass (2)
- benzs — 3 pair sides, mostly vowel via spelling phonetic key, often with when (2)
- quagen — 2 pair sides, mostly vowel via spelling phonetic key, often with after (1)
- beamers — 2 pair sides, mostly vowel via spelling phonetic key, often with machete (1)
- turnt — 1 pair sides, mostly spelling via vault phonetic_class, often with burnt (1)
- herbo — 1 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- rari — 1 pair sides, mostly spelling via spelling phonetic key, often with ass (1)
- tellies — 1 pair sides, mostly multi via spelling phonetic key, often with teddies (1)
- teddies — 1 pair sides, mostly multi via spelling phonetic key, often with tellies (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with bros (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bay Swag | Layderr | 46 | 56 | 345 | loose |
| Bay Swag | Quagen | 37 | 41 | 330 | loose |
