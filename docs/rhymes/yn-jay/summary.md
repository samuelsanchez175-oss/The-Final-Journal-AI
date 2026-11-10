# YN Jay rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: YN Jay
- Songs: 2
- Bars kept (YN Jay lyric lines): 133
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: YN Jay.
- Credit strings: YN Jay.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 888
- REPEAT pairs, recorded separately: 201
- END rhymes: 167
- INNER rhymes: 721

By match:

- PERFECT: 60 (END 16, INNER 44)
- SLANT: 392 (END 71, INNER 321)
- ASSONANCE: 427 (END 75, INNER 352)
- MULTI: 9 (END 5, INNER 4)

By confidence:

- HIGH: 62
- MED: 756
- LOW: 70

## Core

- Core Y: 864
- Core N among rhyme pairs: 24

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 395 (44.5%)
- vowel: 427 (48.1%)
- spelling: 57 (6.4%)
- multi: 9 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 126 pairs (END 42, INNER 84). Words: ain't, jamaican, cases, jay, racist, faces, lazy, label.
2. `vow:AA` — 67 pairs (END 0, INNER 67). Words: got, pockets, not, hard, want, bobbin, toxic, pops.
3. `vow:IH` — 48 pairs (END 2, INNER 46). Words: bitch, different, shit, bitches, kids, hit, chicken, really.
4. `vow:IY` — 39 pairs (END 15, INNER 24). Words: dababy, see, three, lazy, free, louie, prolly, sixteen.
5. `slant:EY:stop` — 32 pairs (END 21, INNER 11). Words: make, take, hate, nominated, skated, ain't, tolerate, ate.
6. `slant:IH:sib-stop` — 31 pairs (END 1, INNER 30). Words: bitch, hit, shit, dick, missed, miss, babysitter, whip.
7. `vow:AH` — 25 pairs (END 0, INNER 25). Words: hundred, done, double, jump, much, club, running, must've.
8. `vow:AY` — 25 pairs (END 0, INNER 25). Words: like, why, high, die, riding, white, diamonds, might.
9. `slant:AH:nas-stop` — 22 pairs (END 0, INNER 22). Words: fuck, some, money, nut, club, one, nun, ton.
10. `vow:AE` — 21 pairs (END 0, INNER 21). Words: can't, ass, asking, cannot, sample, man, stab, bag.
11. `vow:ER` — 21 pairs (END 11, INNER 10). Words: first, work, thirsty, percs, certain, perc.
12. `vow:AO` — 20 pairs (END 3, INNER 17). Words: ordered, calling, reportin, oranges, door, more, thought, before.
13. `slant:AA:stop` — 17 pairs (END 0, INNER 17). Words: got, want, nod, popped, start, not, hard, hot.
14. `slant:AE:stop` — 17 pairs (END 0, INNER 17). Words: dababy, stacked, trap, pack, stack, trapped, baggie, cat.
15. `slant:EY:sib-stop` — 16 pairs (END 9, INNER 7). Words: race, hate, face, lace, pape, crazy, lazy, bake.
16. `cmu:OW` — 13 pairs (END 0, INNER 13). Words: no, bro, know, show.
17. `vow:OW` — 13 pairs (END 0, INNER 13). Words: don't, know, gold, roll, show, jojo, most, wock.
18. `slant:IH:stop` — 12 pairs (END 3, INNER 9). Words: nigga, hit, shit, dick, big, whip, babysitter, pick.
19. `slant:IY:stop` — 11 pairs (END 2, INNER 9). Words: yerc, need, street, deep, yerky, feet, speed, weed.
20. `vow:EH` — 11 pairs (END 0, INNER 11). Words: getting, second, get, left, head, level, went, where.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- dababy — 23 pair sides, mostly vowel via spelling phonetic key, often with lazy (4)
- yerc — 12 pair sides, mostly spelling via spelling phonetic key, often with lean (4)
- perkies — 7 pair sides, mostly spelling via spelling phonetic key, often with perky (3)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with hit (2)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with these (1)
- thots — 4 pair sides, mostly spelling via spelling phonetic key, often with glocks (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with gas (3)
- prolly — 3 pair sides, mostly vowel via spelling phonetic key, often with money (1)
- glocks — 3 pair sides, mostly spelling via spelling phonetic key, often with rocks (1)
- danc — 3 pair sides, mostly spelling via spelling phonetic key, often with dance (3)
- vlone — 2 pair sides, mostly spelling via spelling phonetic key, often with only (1)
- jojo — 2 pair sides, mostly spelling via spelling phonetic key, often with vlone (1)
- dooney — 2 pair sides, mostly spelling via spelling phonetic key, often with money (1)
- imma — 2 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)
- yerky — 2 pair sides, mostly spelling via spelling phonetic key, often with yerc (2)
- doonie — 1 pair sides, mostly spelling via spelling phonetic key, often with duty (1)
- bombaclot — 1 pair sides, mostly spelling via spelling phonetic key, often with got (1)
- wock — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- opps — 1 pair sides, mostly spelling via spelling phonetic key, often with thots (1)
- titties — 1 pair sides, mostly spelling via spelling phonetic key, often with lips (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with ton (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| YN Jay | 2 Much Pape | 59 | 112 | 368 | loose |
| YN Jay | Perc & Sex (Remix) | 74 | 55 | 353 | loose |
