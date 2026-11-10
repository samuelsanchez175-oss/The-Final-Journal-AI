# Q Money rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Q Money
- Songs: 4
- Bars kept (Q Money lyric lines): 238
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Q Money.
- Credit strings: Q Money.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1657
- REPEAT pairs, recorded separately: 170
- END rhymes: 349
- INNER rhymes: 1308

By match:

- PERFECT: 206 (END 70, INNER 136)
- SLANT: 699 (END 133, INNER 566)
- ASSONANCE: 738 (END 139, INNER 599)
- MULTI: 14 (END 7, INNER 7)

By confidence:

- HIGH: 203
- MED: 1341
- LOW: 113

## Core

- Core Y: 1629
- Core N among rhyme pairs: 28

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 799 (48.2%)
- vowel: 738 (44.5%)
- spelling: 106 (6.4%)
- multi: 14 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 4 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 156 pairs (END 28, INNER 128). Words: ticket, chickens, shit, bitches, bitch, flipping, lil, diggin.
2. `vow:OW` — 144 pairs (END 8, INNER 136). Words: don't, no, know, whole, go, cold, fold, gold.
3. `vow:EY` — 105 pairs (END 17, INNER 88). Words: ain't, came, yesterday, arabian, mistakes, breaks, acres, today.
4. `vow:AH` — 99 pairs (END 43, INNER 56). Words: nothing, money, fuck, ugly, fucking, drummond, flunked, luggage.
5. `slant:IH:stop` — 80 pairs (END 23, INNER 57). Words: shit, nigga, brick, dick, pissed, whip, fit, ticket.
6. `vow:IY` — 78 pairs (END 19, INNER 59). Words: freaks, neat, key, field, sheets, see, real, meeting.
7. `vow:AE` — 55 pairs (END 17, INNER 38). Words: can't, average, cannot, had, savage, angle, cashmere, tragic.
8. `slant:IH:sib-stop` — 45 pairs (END 9, INNER 36). Words: bitch, shit, piss, dick, whip, brick, rich, fit.
9. `vow:AA` — 44 pairs (END 4, INNER 40). Words: got, hah, poppin, box, coppin, cost, cause, ironic.
10. `slant:AA:stop` — 43 pairs (END 8, INNER 35). Words: got, want, body, sloppy, lobby, gotta, lotta, not.
11. `cmu:OW` — 42 pairs (END 3, INNER 39). Words: know, go, no, mo, slow, though, hoe, ho.
12. `vow:EH` — 36 pairs (END 2, INNER 34). Words: get, better, lenses, extra, bentley, necklace, blend, barely.
13. `cmu:EY` — 35 pairs (END 28, INNER 7). Words: way, say, today, driveway, away, day, play.
14. `slant:AH:nas-stop` — 31 pairs (END 7, INNER 24). Words: fuck, money, come, some, done, buddy, fucking, fuckin.
15. `slant:EY:nas-stop` — 26 pairs (END 9, INNER 17). Words: came, complain, lane, made, ate, great, hate, eight.
16. `slant:AH:nas` — 24 pairs (END 2, INNER 22). Words: money, some, fuckin, done, come, one, rum, drum.
17. `slant:IH:liq-stop` — 22 pairs (END 3, INNER 19). Words: shit, lil, mill, dick, really, sip, brick, smear.
18. `slant:EY:stop` — 21 pairs (END 2, INNER 19). Words: ain't, steak, ate, hesitate, hate, cake, skate, hater.
19. `cmu:EY-T` — 20 pairs (END 7, INNER 13). Words: hate, skate, great, eight, ate, motivate, estate, hesitate.
20. `slant:EY:sib-stop` — 20 pairs (END 4, INNER 16). Words: face, dates, made, days, cake, mistakes, breaks, steak.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 23 pair sides, mostly spelling via spelling phonetic key, often with shit (7)
- tryna — 13 pair sides, mostly spelling via spelling phonetic key, often with please (3)
- bros — 13 pair sides, mostly spelling via spelling phonetic key, often with gold (2)
- drizzy — 8 pair sides, mostly spelling via spelling phonetic key, often with riches (1)
- iggy — 7 pair sides, mostly spelling via spelling phonetic key, often with dick (2)
- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- shiggy — 6 pair sides, mostly spelling via spelling phonetic key, often with iggy (1)
- drizank — 5 pair sides, mostly vowel via vault phonetic_class, often with angle (2)
- bitchs — 5 pair sides, mostly vowel via spelling phonetic key, often with bitches (1)
- duffle — 4 pair sides, mostly vowel via spelling phonetic key, often with judge (1)
- thugging — 4 pair sides, mostly spelling via spelling phonetic key, often with budging (1)
- bizank — 4 pair sides, mostly vowel via vault phonetic_class, often with tab (1)
- sizank — 4 pair sides, mostly spelling via spelling phonetic key, often with bizank (1)
- constalation — 3 pair sides, mostly spelling via spelling phonetic key, often with station (1)
- bizanger — 3 pair sides, mostly vowel via spelling phonetic key, often with riches (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with blowing (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- sensay — 3 pair sides, mostly spelling via spelling phonetic key, often with say (1)
- sence — 3 pair sides, mostly spelling via spelling phonetic key, often with remember (1)
- shawty — 3 pair sides, mostly spelling via spelling phonetic key, often with four (2)
- compresser — 2 pair sides, mostly vowel via spelling phonetic key, often with stove (2)
- conversating — 2 pair sides, mostly spelling via spelling phonetic key, often with constalation (1)
- stuntin — 2 pair sides, mostly vowel via spelling phonetic key, often with nothing (1)
- wrent — 2 pair sides, mostly spelling via spelling phonetic key, often with sensay (1)
- carti — 2 pair sides, mostly spelling via spelling phonetic key, often with got (1)
- aford — 1 pair sides, mostly vowel via vault phonetic_class, often with feel (1)
- wwant — 1 pair sides, mostly spelling via spelling phonetic key, often with want (1)
- hella — 1 pair sides, mostly spelling via spelling phonetic key, often with sell (1)
- lambo — 1 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- longway — 1 pair sides, mostly spelling via spelling phonetic key, often with lay (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Q Money | Knot | 37 | 31 | 145 | loose |
| Q Money | Neat (Remix) | 125 | 176 | 620 | loose |
| Q Money | Tripp Today | 36 | 69 | 208 | loose |
| Q Money | Whole Ticket | 40 | 73 | 335 | loose |
