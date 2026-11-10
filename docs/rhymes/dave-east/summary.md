# Dave East rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Dave East
- Songs: 5
- Bars kept (Dave East lyric lines): 274
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Dave East.
- Credit strings: Dave East.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1976
- REPEAT pairs, recorded separately: 212
- END rhymes: 329
- INNER rhymes: 1647

By match:

- PERFECT: 233 (END 65, INNER 168)
- SLANT: 743 (END 129, INNER 614)
- ASSONANCE: 986 (END 135, INNER 851)
- MULTI: 14 (END 0, INNER 14)

By confidence:

- HIGH: 236
- MED: 1635
- LOW: 105

## Core

- Core Y: 1943
- Core N among rhyme pairs: 33

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 896 (45.3%)
- vowel: 986 (49.9%)
- spelling: 80 (4.0%)
- multi: 14 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 5 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 276 pairs (END 39, INNER 237). Words: go, don't, no, know, only, told, home, sold.
2. `vow:IH` — 129 pairs (END 26, INNER 103). Words: shit, million, bitches, dicks, spin, kitchen, rich, serious.
3. `vow:AA` — 123 pairs (END 14, INNER 109). Words: got, talkin, spot, park, block, bodies, partner, cars.
4. `slant:AA:stop` — 105 pairs (END 26, INNER 79). Words: got, block, spot, gotta, glock, drop, lot, knock.
5. `vow:EY` — 86 pairs (END 4, INNER 82). Words: ain't, take, make, say, dolce, name, takin, impatient.
6. `vow:EH` — 66 pairs (END 9, INNER 57). Words: when, many, gettin, get, confession, remember, special, fendi.
7. `vow:AH` — 65 pairs (END 16, INNER 49). Words: bundles, month, humble, coming, dust, covers, pumper, dumping.
8. `vow:IY` — 63 pairs (END 9, INNER 54). Words: see, reason, even, seems, three, dreams, real, streets.
9. `vow:AY` — 57 pairs (END 7, INNER 50). Words: like, might, why, by, right, time, lie, five.
10. `vow:AE` — 48 pairs (END 4, INNER 44). Words: can't, mans, have, bagging, half, trap, hands, gang.
11. `cmu:AA-T` — 35 pairs (END 14, INNER 21). Words: got, spot, shot, lot, hot, rot, pot, not.
12. `vow:UW` — 34 pairs (END 3, INNER 31). Words: move, cuban, coupes, boo, blew, through, few, two.
13. `cmu:OW` — 33 pairs (END 6, INNER 27). Words: know, no, go, blow, though, low, owe, co.
14. `slant:IH:stop` — 32 pairs (END 9, INNER 23). Words: nigga, shit, wicked, limit, hit, city, kick, rib.
15. `cmu:AY` — 31 pairs (END 18, INNER 13). Words: lie, why, die, try, buy, high, tri, by.
16. `slant:AA:liq-stop` — 31 pairs (END 0, INNER 31). Words: got, dollar, star, car, block, far, molly, glock.
17. `slant:IH:sib-stop` — 23 pairs (END 9, INNER 14). Words: bitch, shit, rich, switch, strip, stick, rib, crib.
18. `vow:AO` — 23 pairs (END 1, INNER 22). Words: all, foreign, wars, losses, balls, long, borin, called.
19. `slant:EH:stop` — 22 pairs (END 1, INNER 21). Words: get, pressed, respect, head, let, credit, neglect, felt.
20. `slant:EH:nas-stop` — 20 pairs (END 0, INNER 20). Words: when, get, went, already, n, many, ten, fendi.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 16 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- gon — 14 pair sides, mostly spelling via spelling phonetic key, often with reason (3)
- herbo — 9 pair sides, mostly vowel via spelling phonetic key, often with turbo (2)
- wraith — 7 pair sides, mostly spelling via spelling phonetic key, often with space (2)
- grippy — 7 pair sides, mostly vowel via spelling phonetic key, often with already (1)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with kids (1)
- pumper — 6 pair sides, mostly vowel via spelling phonetic key, often with other (1)
- switchy — 6 pair sides, mostly vowel via spelling phonetic key, often with already (1)
- dolo — 5 pair sides, mostly multi via spelling phonetic key, often with polo (2)
- tryna — 4 pair sides, mostly spelling via spelling phonetic key, often with treat (2)
- pics — 4 pair sides, mostly vowel via spelling phonetic key, often with shit (2)
- drippy — 4 pair sides, mostly vowel via spelling phonetic key, often with fendi (2)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with rich (1)
- gabbana — 2 pair sides, mostly vowel via spelling phonetic key, often with back (1)
- blixky — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- jocs — 2 pair sides, mostly vowel via spelling phonetic key, often with told (1)
- fazo — 2 pair sides, mostly spelling via spelling phonetic key, often with gang (1)
- locs — 2 pair sides, mostly spelling via spelling phonetic key, often with folks (1)
- celly — 2 pair sides, mostly spelling via spelling phonetic key, often with rare (1)
- wiffles — 1 pair sides, mostly vowel via spelling phonetic key, often with kitchen (1)
- dyin — 1 pair sides, mostly spelling via spelling phonetic key, often with flyin (1)
- buncha — 1 pair sides, mostly spelling via spelling phonetic key, often with much (1)
- millitant — 1 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- piguet — 1 pair sides, mostly spelling via spelling phonetic key, often with fifty (1)
- hunnid — 1 pair sides, mostly spelling via spelling phonetic key, often with trunk (1)
- sniffers — 1 pair sides, mostly vowel via spelling phonetic key, often with fittest (1)
- def — 1 pair sides, mostly spelling via spelling phonetic key, often with already (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Dave East | Do It For | 42 | 68 | 246 | loose |
| Dave East | Go Off | 60 | 70 | 424 | loose |
| Dave East | Militant (Many Men)* | 57 | 41 | 248 | loose |
| Dave East | My Trap | 55 | 81 | 302 | loose |
| Dave East | No Hook | 60 | 69 | 427 | loose |
