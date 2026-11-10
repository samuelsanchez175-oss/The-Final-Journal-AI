# Lil Pete rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Pete
- Songs: 1
- Bars kept (Lil Pete lyric lines): 42
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lil Pete.
- Credit strings: Lil Pete.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 302
- REPEAT pairs, recorded separately: 25
- END rhymes: 49
- INNER rhymes: 253

By match:

- PERFECT: 9 (END 1, INNER 8)
- SLANT: 123 (END 19, INNER 104)
- ASSONANCE: 170 (END 29, INNER 141)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 7
- MED: 278
- LOW: 17

## Core

- Core Y: 292
- Core N among rhyme pairs: 10

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 122 (40.4%)
- vowel: 170 (56.3%)
- spelling: 10 (3.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 40 pairs (END 7, INNER 33). Words: when, weapon, intercepted, heads, jealous, careful, send, invented.
2. `vow:AH` — 36 pairs (END 13, INNER 23). Words: hundred, loved, publishing, rugby, son, ugly, touched, fuck.
3. `vow:IH` — 19 pairs (END 0, INNER 19). Words: shit, birkin, bitch, sippin, think, quickly, niggas'll, fifty.
4. `vow:AE` — 15 pairs (END 4, INNER 11). Words: bag, past, can't, bags, brand, apple, bad, trap.
5. `vow:ER` — 15 pairs (END 5, INNER 10). Words: lurkin, perc, misinterpret, burnin, verses, person, hurt, worker.
6. `vow:OW` — 15 pairs (END 0, INNER 15). Words: know, don't, road, opps, whole, no, shoulders, grower.
7. `vow:AY` — 9 pairs (END 0, INNER 9). Words: buy, side, rival, writing, slime, like, life, michael.
8. `vow:IY` — 9 pairs (END 0, INNER 9). Words: streaming, see, these, feelings, meet, real, keep, weed.
9. `slant:EH:nas-stop` — 8 pairs (END 0, INNER 8). Words: when, said, get, better, gettin, forget, send.
10. `slant:AE:stop` — 7 pairs (END 2, INNER 5). Words: bag, bad, daddy, brand, can't, past, lab, pack.
11. `vow:EY` — 7 pairs (END 0, INNER 7). Words: snakes, k, plays, hate, made, always, fail, days.
12. `slant:AH:nas-sib` — 6 pairs (END 0, INNER 6). Words: another, some, touch, one, son, judge.
13. `slant:AE:nas-stop` — 5 pairs (END 1, INNER 4). Words: gang, tago, can, mad, had.
14. `slant:IY:sib-stop` — 5 pairs (END 0, INNER 5). Words: keep, these, weed, please.
15. `slant:AE:sib-stop` — 4 pairs (END 0, INNER 4). Words: catch, grass, had, bag, addy.
16. `slant:AH:sib-stop` — 4 pairs (END 3, INNER 1). Words: judge, fuck, lucky, touch.
17. `slant:AY:nas-stop` — 4 pairs (END 0, INNER 4). Words: carolina, inside, slime, side, like, time.
18. `slant:EH:stop` — 4 pairs (END 2, INNER 2). Words: invented, get, said, intercepted, send, sent.
19. `cmu:EY-Z` — 3 pairs (END 0, INNER 3). Words: days, always, plays.
20. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: fuck, what, come, some, one.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- birkin — 7 pair sides, mostly vowel via spelling phonetic key, often with bitch (2)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- tago — 2 pair sides, mostly spelling via spelling phonetic key, often with gang (2)
- opps — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- niggasll — 2 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)
- intellegent — 1 pair sides, mostly spelling via spelling phonetic key, often with sent (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with these (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with all (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Pete | Road Runnin’ | 42 | 49 | 253 | loose |
