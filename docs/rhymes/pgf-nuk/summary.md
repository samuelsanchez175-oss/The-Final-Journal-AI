# PGF Nuk rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: PGF Nuk
- Songs: 3
- Bars kept (PGF Nuk lyric lines): 163
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: PGF Nuk.
- Credit strings: PGF Nuk.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1107
- REPEAT pairs, recorded separately: 133
- END rhymes: 205
- INNER rhymes: 902

By match:

- PERFECT: 117 (END 38, INNER 79)
- SLANT: 516 (END 101, INNER 415)
- ASSONANCE: 462 (END 65, INNER 397)
- MULTI: 12 (END 1, INNER 11)

By confidence:

- HIGH: 124
- MED: 925
- LOW: 58

## Core

- Core Y: 1095
- Core N among rhyme pairs: 12

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 583 (52.7%)
- vowel: 462 (41.7%)
- spelling: 50 (4.5%)
- multi: 12 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 82 pairs (END 4, INNER 78). Words: like, why, die, fly, time, times, lights, behind.
2. `vow:AH` — 71 pairs (END 18, INNER 53). Words: hundred, what, blunts, guns, done, fuck, couple, bussin.
3. `vow:AA` — 56 pairs (END 6, INNER 50). Words: nothin, want, shots, got, knock, box, talkin, hard.
4. `vow:EY` — 51 pairs (END 0, INNER 51). Words: ain't, make, day, stay, say, lay, cake, tape.
5. `vow:OW` — 51 pairs (END 4, INNER 47). Words: don't, know, bro, no, opps, go, whole, over.
6. `vow:IH` — 46 pairs (END 4, INNER 42). Words: switches, fifty, think, richest, him, wicked, shit, fitted.
7. `slant:IH:stop` — 36 pairs (END 5, INNER 31). Words: nigga, shit, nick, city, hit, wicked, sticky, big.
8. `slant:AA:stop` — 34 pairs (END 0, INNER 34). Words: got, want, hop, everybody, copped, block, opp, roddy.
9. `vow:IY` — 32 pairs (END 12, INNER 20). Words: see, need, demons, scenic, even, street, hear, g.
10. `cmu:OW` — 25 pairs (END 0, INNER 25). Words: no, know, go, blow, though, bro, lo.
11. `slant:IH:sib-stop` — 25 pairs (END 5, INNER 20). Words: hit, bitch, shit, busy, flipped, fish, miss, diss.
12. `slant:AH:nas-stop` — 23 pairs (END 3, INNER 20). Words: what, done, come, fuck, drug, run, fun, shut.
13. `vow:EH` — 20 pairs (END 1, INNER 19). Words: every, trenches, when, accidental, get, remember, gettin, better.
14. `slant:AY:stop` — 19 pairs (END 0, INNER 19). Words: like, ride, light, hype, pipe, right, bite, find.
15. `vow:AW` — 19 pairs (END 14, INNER 5). Words: house, now, surroundings, pounds, ground, down, around, opps.
16. `vow:AE` — 18 pairs (END 1, INNER 17). Words: passes, wagons, actin, had, can't, paddy, act, back.
17. `slant:IH:sib` — 17 pairs (END 8, INNER 9). Words: bitch, switches, miss, rich, fish, wish, diss, switch.
18. `slant:AW:sib-stop` — 16 pairs (END 9, INNER 7). Words: bounce, account, ground, house, mouth, round, 'bout, pounds.
19. `slant:AY:nas-stop` — 15 pairs (END 0, INNER 15). Words: like, time, iron, flight, slide, lighter, light, ride.
20. `slant:AH:nas-sib` — 14 pairs (END 2, INNER 12). Words: guns, done, some, brother, touch, come, much, money.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 13 pair sides, mostly spelling via spelling phonetic key, often with hit (3)
- opps — 11 pair sides, mostly vowel via spelling phonetic key, often with both (2)
- tryna — 9 pair sides, mostly spelling via spelling phonetic key, often with keep (1)
- swerv — 5 pair sides, mostly spelling via spelling phonetic key, often with nerve (1)
- foenem — 4 pair sides, mostly spelling via spelling phonetic key, often with gon (4)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with foenem (4)
- herbo — 4 pair sides, mostly vowel via spelling phonetic key, often with world (1)
- blickin — 3 pair sides, mostly spelling via spelling phonetic key, often with stick (2)
- thots — 2 pair sides, mostly spelling via spelling phonetic key, often with opps (2)
- verybody — 2 pair sides, mostly vowel via spelling phonetic key, often with forty (1)
- nem — 2 pair sides, mostly spelling via spelling phonetic key, often with when (1)
- scoomin — 2 pair sides, mostly spelling via spelling phonetic key, often with broom (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with kill (1)
- fah — 2 pair sides, mostly spelling via spelling phonetic key, often with have (1)
- raq — 1 pair sides, mostly spelling via spelling phonetic key, often with have (1)
- glizzies — 1 pair sides, mostly spelling via spelling phonetic key, often with switches (1)
- mooda — 1 pair sides, mostly spelling via spelling phonetic key, often with broom (1)
- glizzy — 1 pair sides, mostly spelling via spelling phonetic key, often with switch (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| PGF Nuk | Bounce | 67 | 84 | 264 | loose |
| PGF Nuk | Hot Summer | 33 | 49 | 202 | loose |
| PGF Nuk | Waddup (Swervo Mix) | 63 | 72 | 436 | loose |
