# That Mexican OT rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: That Mexican OT
- Songs: 1
- Bars kept (That Mexican OT lyric lines): 31
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: That Mexican OT.
- Credit strings: That Mexican OT.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 257
- REPEAT pairs, recorded separately: 28
- END rhymes: 32
- INNER rhymes: 225

By match:

- PERFECT: 13 (END 0, INNER 13)
- SLANT: 102 (END 4, INNER 98)
- ASSONANCE: 141 (END 27, INNER 114)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 13
- MED: 230
- LOW: 14

## Core

- Core Y: 257
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 100 (38.9%)
- vowel: 141 (54.9%)
- spelling: 15 (5.8%)
- multi: 1 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 52 pairs (END 18, INNER 34). Words: bitch, blitz, livin, fitness, finished, ignition, dishes, switches.
2. `vow:EH` — 21 pairs (END 0, INNER 21). Words: steppin, send, let's, swear, deadly, seven, checkin, when.
3. `vow:AE` — 18 pairs (END 0, INNER 18). Words: stand, cadillac, saddle, last, ass, dan, can't, rattle.
4. `vow:OW` — 18 pairs (END 8, INNER 10). Words: ho, cantaloupe, broke, zone, antidote, go, don't, show.
5. `vow:AH` — 10 pairs (END 0, INNER 10). Words: somethin, fuck, sucked, thump, junkies, money, gun, front.
6. `slant:IH:sib-stop` — 8 pairs (END 0, INNER 8). Words: bitch, shit, blitz, dick, big, hit, kick.
7. `slant:AH:nas-stop` — 7 pairs (END 0, INNER 7). Words: money, fuck, what, gun, front.
8. `vow:IY` — 7 pairs (END 0, INNER 7). Words: thirty, jeans, feel, mean, these, please, see, hear.
9. `cmu:AH-M` — 6 pairs (END 0, INNER 6). Words: some, come, 'em.
10. `slant:AH:stop` — 6 pairs (END 0, INNER 6). Words: fuck, trunk, front, thump, what, sucked.
11. `slant:EY:sib-stop` — 6 pairs (END 0, INNER 6). Words: make, ain't, chains, snakes, age.
12. `cmu:OW` — 5 pairs (END 0, INNER 5). Words: ho, show, potato.
13. `slant:EH:nas-stop` — 5 pairs (END 0, INNER 5). Words: when, spent, get, beg.
14. `slant:IH:nas-sib` — 5 pairs (END 0, INNER 5). Words: bitch, ching, i'ma, him.
15. `slant:IH:sib` — 5 pairs (END 1, INNER 4). Words: dishes, switches, bitch, business.
16. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: big, shit, dick, lik, hit, nigga, built.
17. `vow:EY` — 5 pairs (END 0, INNER 5). Words: say, ain't, make, chains.
18. `slant:AE:nas-stop` — 4 pairs (END 0, INNER 4). Words: dan, banned, can't, stand, cadillac.
19. `slant:AE:stop` — 4 pairs (END 0, INNER 4). Words: can't, banned, last, stand, crank, band.
20. `slant:AH:nas-sib` — 4 pairs (END 0, INNER 4). Words: much, some, come.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 6 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with antidote (1)
- lik — 1 pair sides, mostly spelling via spelling phonetic key, often with big (1)
- swaggin — 1 pair sides, mostly spelling via spelling phonetic key, often with wagon (1)
- tes — 1 pair sides, mostly spelling via spelling phonetic key, often with when (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with hear (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with shit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| That Mexican OT | Business | 31 | 32 | 225 | loose |
