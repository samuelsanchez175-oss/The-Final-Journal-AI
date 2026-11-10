# Neek Bucks rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Neek Bucks
- Songs: 2
- Bars kept (Neek Bucks lyric lines): 111
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Neek Bucks.
- Credit strings: Neek Bucks.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 915
- REPEAT pairs, recorded separately: 103
- END rhymes: 146
- INNER rhymes: 769

By match:

- PERFECT: 100 (END 25, INNER 75)
- SLANT: 389 (END 61, INNER 328)
- ASSONANCE: 426 (END 60, INNER 366)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 97
- MED: 761
- LOW: 57

## Core

- Core Y: 909
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 435 (47.5%)
- vowel: 426 (46.6%)
- spelling: 54 (5.9%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 150 pairs (END 39, INNER 111). Words: way, day, ain't, fake, play, say, pay, paid.
2. `vow:EH` — 56 pairs (END 0, INNER 56). Words: end, when, there's, remember, get, let's, dwelling, getting.
3. `vow:OW` — 49 pairs (END 2, INNER 47). Words: know, don't, bro, pros, go, going, posted, whole.
4. `slant:EY:stop` — 37 pairs (END 17, INNER 20). Words: separate, take, paid, fake, make, wake, state, educated.
5. `vow:AY` — 37 pairs (END 0, INNER 37). Words: by, times, behind, right, guys, high, time, fly.
6. `slant:AE:stop` — 31 pairs (END 12, INNER 19). Words: back, rap, flat, black, whack, had, whacked, bap.
7. `vow:IH` — 30 pairs (END 0, INNER 30). Words: shit, years, think, interfering, thinking, him, hit, killers.
8. `vow:AE` — 27 pairs (END 6, INNER 21). Words: can't, rap, facts, back, anger, black, racks, matte.
9. `vow:AA` — 25 pairs (END 1, INNER 24). Words: block, nothin, got, monster, lot, chops, cops, watch.
10. `cmu:OW` — 20 pairs (END 1, INNER 19). Words: bro, know, go, no.
11. `slant:AO:liq-stop` — 20 pairs (END 3, INNER 17). Words: all, dawg, taught, talk, call, tall, ball, small.
12. `vow:AH` — 18 pairs (END 5, INNER 13). Words: hustlin, humble, money, somethin, onion, couple, ducked, love.
13. `vow:IY` — 18 pairs (END 1, INNER 17). Words: fiends, pieces, streets, reason, leave, speak, beatin, see.
14. `cmu:EY` — 14 pairs (END 6, INNER 8). Words: pay, play, way, dikembe, day, say, hay.
15. `slant:EH:nas-stop` — 14 pairs (END 0, INNER 14). Words: ten, when, get, end, getting, spread, went, dead.
16. `slant:IH:liq-stop` — 14 pairs (END 0, INNER 14). Words: shit, still, really, wit, milli, built, whit, year.
17. `vow:AO` — 14 pairs (END 6, INNER 8). Words: default, corner, talk, all, before, dawgs, long, walk.
18. `slant:IH:nas-stop` — 12 pairs (END 0, INNER 12). Words: him, big, sit, hit, thing, whit, shit, wit.
19. `cmu:AO-L` — 10 pairs (END 0, INNER 10). Words: all, call, tall, ball, small, fall.
20. `slant:EH:sib-stop` — 10 pairs (END 0, INNER 10). Words: get, let's, ls, feds, guess, better, fed, spread.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- dawg — 11 pair sides, mostly spelling via spelling phonetic key, often with all (6)
- gon — 11 pair sides, mostly spelling via spelling phonetic key, often with whole (5)
- tryna — 11 pair sides, mostly spelling via spelling phonetic key, often with these (4)
- dikembe — 10 pair sides, mostly vowel via vault phonetic_class, often with day (2)
- nigga — 9 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- bap — 5 pair sides, mostly spelling via spelling phonetic key, often with black (2)
- dawgs — 3 pair sides, mostly vowel via spelling phonetic key, often with fall (1)
- bros — 3 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- zaza — 2 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- conversate — 1 pair sides, mostly vowel via spelling phonetic key, often with posted (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with will (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Neek Bucks | Default | 60 | 59 | 456 | loose |
| Neek Bucks | One Day | 51 | 87 | 313 | loose |
