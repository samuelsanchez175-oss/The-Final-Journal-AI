# The Kid LAROI rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: The Kid LAROI
- Songs: 4
- Bars kept (The Kid LAROI lyric lines): 131
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: The Kid LAROI.
- Credit strings: The Kid LAROI.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1216
- REPEAT pairs, recorded separately: 116
- END rhymes: 196
- INNER rhymes: 1020

By match:

- PERFECT: 99 (END 26, INNER 73)
- SLANT: 452 (END 76, INNER 376)
- ASSONANCE: 657 (END 90, INNER 567)
- MULTI: 8 (END 4, INNER 4)

By confidence:

- HIGH: 104
- MED: 1072
- LOW: 40

## Core

- Core Y: 1201
- Core N among rhyme pairs: 15

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 524 (43.1%)
- vowel: 657 (54.0%)
- spelling: 27 (2.2%)
- multi: 8 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 4 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 212 pairs (END 40, INNER 172). Words: don't, know, no, hoes, go, told, 'posed, road.
2. `vow:EH` — 83 pairs (END 11, INNER 72). Words: when, sex, myself, hectic, send, get, attention, check.
3. `vow:EY` — 81 pairs (END 4, INNER 77). Words: way, ain't, same, make, change, say, day, chains.
4. `vow:IY` — 77 pairs (END 25, INNER 52). Words: leave, demons, penis, screamin, tweakin, these, hear, need.
5. `vow:IH` — 58 pairs (END 2, INNER 56). Words: shit, kids, crib, bitch, thinkin, think, rich, bitches.
6. `vow:AH` — 42 pairs (END 3, INNER 39). Words: hundred, bust, some, nothing, fuck, what, one, uncle.
7. `slant:OW:stop` — 36 pairs (END 13, INNER 23). Words: 'posed, told, road, fold, showed, older, old, mold.
8. `vow:AA` — 29 pairs (END 2, INNER 27). Words: got, cars, job, god, stars, bars, dollar, costs.
9. `vow:AE` — 27 pairs (END 2, INNER 25). Words: back, cappin, can't, happened, rappin, magic, have, gang.
10. `slant:EH:fric-stop` — 22 pairs (END 0, INNER 22). Words: get, never, every, letter, effective, head, ahead, deck.
11. `slant:EH:stop` — 22 pairs (END 4, INNER 18). Words: get, detect, kept, yet, collect, letter, head, left.
12. `vow:AY` — 20 pairs (END 0, INNER 20). Words: bae, high, like, time, times, hype, fightin, right.
13. `cmu:OW` — 19 pairs (END 0, INNER 19). Words: know, no, go, bro, toe, ago, o, ho.
14. `slant:IH:sib-stop` — 17 pairs (END 1, INNER 16). Words: shit, bitch, kid, fridge, rich, big, issue, miss.
15. `slant:IY:fric-stop` — 14 pairs (END 8, INNER 6). Words: leave, need, meet, believe, repeat, eat, street.
16. `slant:OW:sib-stop` — 14 pairs (END 9, INNER 5). Words: hoes, 'posed, boulders, road, told, expose, rolls, shows.
17. `vow:AO` — 14 pairs (END 1, INNER 13). Words: long, record, lost, all, saw, frauds, stories, floors.
18. `slant:EY:nas` — 11 pairs (END 5, INNER 6). Words: same, gain, maintain, frame, name, lane, game, plane.
19. `slant:OW:liq-sib` — 11 pairs (END 4, INNER 7). Words: soul, hoes, rolls, toes, bros, shows, expose, pose.
20. `slant:IH:stop` — 10 pairs (END 2, INNER 8). Words: shit, crib, kid, hit, nigga, big.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- bros — 11 pair sides, mostly vowel via spelling phonetic key, often with hundred (2)
- gon — 6 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- thes — 5 pair sides, mostly spelling via spelling phonetic key, often with tell (1)
- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with give (1)
- shawty — 4 pair sides, mostly vowel via spelling phonetic key, often with every (1)
- cellmate — 4 pair sides, mostly vowel via spelling phonetic key, often with never (2)
- weeknd — 2 pair sides, mostly spelling via spelling phonetic key, often with seventeen (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with six (1)
- thuggin — 1 pair sides, mostly vowel via spelling phonetic key, often with hunnid (1)
- hunnid — 1 pair sides, mostly vowel via spelling phonetic key, often with thuggin (1)
- swerv — 1 pair sides, mostly spelling via spelling phonetic key, often with curve (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with talk (1)
- conversate — 1 pair sides, mostly vowel via spelling phonetic key, often with posed (1)
- stuntin — 1 pair sides, mostly vowel via spelling phonetic key, often with nothing (1)
- urus — 1 pair sides, mostly vowel via spelling phonetic key, often with bust (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| The Kid LAROI | All The Same* | 24 | 20 | 168 | loose |
| The Kid LAROI | DON’T LEAVE ME | 35 | 53 | 297 | loose |
| The Kid LAROI | Posed To | 31 | 72 | 288 | loose |
| The Kid LAROI | THANK GOD (Unreleased) | 41 | 51 | 267 | loose |
