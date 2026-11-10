# Lil Bibby rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Bibby
- Songs: 15
- Bars kept (Lil Bibby lyric lines): 872
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lil Bibby.
- Credit strings: Lil Bibby.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 5657
- REPEAT pairs, recorded separately: 782
- END rhymes: 985
- INNER rhymes: 4672

By match:

- PERFECT: 503 (END 120, INNER 383)
- SLANT: 2493 (END 442, INNER 2051)
- ASSONANCE: 2560 (END 376, INNER 2184)
- MULTI: 101 (END 47, INNER 54)

By confidence:

- HIGH: 542
- MED: 4638
- LOW: 477

## Core

- Core Y: 5547
- Core N among rhyme pairs: 110

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 2567 (45.4%)
- vowel: 2560 (45.3%)
- spelling: 429 (7.6%)
- multi: 101 (1.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 15 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 412 pairs (END 75, INNER 337). Words: bitches, shit, bitch, think, clips, since, wrist, dick.
2. `vow:OW` — 407 pairs (END 52, INNER 355). Words: don't, know, no, smoke, go, over, throw, hoes.
3. `vow:AE` — 355 pairs (END 70, INNER 285). Words: facts, savage, can't, back, rappin, ass, have, trap.
4. `vow:EH` — 286 pairs (END 77, INNER 209). Words: essex, check, reckless, send, gettin, when, felons, get.
5. `vow:EY` — 256 pairs (END 14, INNER 242). Words: ain't, say, stay, hatin, fake, take, name, play.
6. `slant:IH:stop` — 212 pairs (END 28, INNER 184). Words: nigga, shit, bibby, dick, big, city, hit, flip.
7. `vow:AA` — 210 pairs (END 15, INNER 195). Words: got, hard, want, rollin, nothin, shots, condo, block.
8. `vow:AH` — 198 pairs (END 20, INNER 178). Words: couple, something, fuck, somethin, young, what, some, money.
9. `slant:IH:sib-stop` — 196 pairs (END 45, INNER 151). Words: nigga, niggas, bitch, shit, dick, bibby, whip, gon.
10. `vow:IY` — 176 pairs (END 6, INNER 170). Words: see, louie, even, here, these, need, v, c.
11. `slant:AA:stop` — 148 pairs (END 11, INNER 137). Words: got, block, gotta, squad, glock, stop, hard, hot.
12. `cmu:OW` — 124 pairs (END 20, INNER 104). Words: know, no, go, blow, throw, ho, show, bro.
13. `slant:IH:liq-stop` — 115 pairs (END 8, INNER 107). Words: shit, kill, still, lil, bibby, killed, city, hit.
14. `slant:AH:nas` — 113 pairs (END 27, INNER 86). Words: young, money, come, run, some, one, done, funny.
15. `vow:AY` — 110 pairs (END 17, INNER 93). Words: like, by, time, buy, silent, ridin, diamonds, lights.
16. `slant:AH:nas-stop` — 83 pairs (END 3, INNER 80). Words: fuck, what, come, money, young, one, hut, run.
17. `slant:AE:stop` — 79 pairs (END 15, INNER 64). Words: trap, back, rap, pack, had, panic, act, can't.
18. `vow:UW` — 61 pairs (END 17, INNER 44). Words: new, shoot, shooters, who, move, through, movie, goons.
19. `slant:AA:sib-stop` — 56 pairs (END 7, INNER 49). Words: cause, got, gotta, watch, shots, ross, not, drop.
20. `slant:AE:nas-stop` — 53 pairs (END 7, INNER 46). Words: man, can, back, damn, black, track, bad, gang.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 203 pair sides, mostly spelling via spelling phonetic key, often with niggas (83)
- niggas — 127 pair sides, mostly spelling via spelling phonetic key, often with nigga (83)
- gon — 29 pair sides, mostly spelling via spelling phonetic key, often with dont (5)
- tryna — 24 pair sides, mostly spelling via spelling phonetic key, often with these (4)
- dolo — 13 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- imma — 11 pair sides, mostly vowel via spelling phonetic key, often with nigga (9)
- ima — 10 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- hunnids — 9 pair sides, mostly vowel via spelling phonetic key, often with thumbin (3)
- hemi — 8 pair sides, mostly spelling via spelling phonetic key, often with remy (1)
- opps — 7 pair sides, mostly vowel via spelling phonetic key, often with know (3)
- hunnid — 7 pair sides, mostly vowel via spelling phonetic key, often with hunnids (3)
- herbo — 6 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- shawty — 6 pair sides, mostly spelling via spelling phonetic key, often with call (2)
- kushy — 6 pair sides, mostly vowel via spelling phonetic key, often with see (2)
- posers — 6 pair sides, mostly spelling via spelling phonetic key, often with loafers (1)
- snitches — 6 pair sides, mostly spelling via spelling phonetic key, often with bitches (1)
- baretta — 5 pair sides, mostly vowel via spelling phonetic key, often with trap (2)
- spazzin — 5 pair sides, mostly vowel via vault phonetic_class, often with cashin (1)
- 40cal — 5 pair sides, mostly spelling via spelling phonetic key, often with bad (2)
- youon — 5 pair sides, mostly spelling via spelling phonetic key, often with beam (2)
- crammy — 5 pair sides, mostly vowel via spelling phonetic key, often with candy (1)
- choppas — 5 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- shorties — 5 pair sides, mostly cmu via vault phonetic_class, often with sixteen (2)
- xmen — 5 pair sides, mostly spelling via spelling phonetic key, often with mess (1)
- nin — 5 pair sides, mostly spelling via spelling phonetic key, often with give (1)
- freestyling — 4 pair sides, mostly spelling via spelling phonetic key, often with stylin (1)
- dyking — 4 pair sides, mostly spelling via spelling phonetic key, often with tellin (1)
- guap — 4 pair sides, mostly spelling via spelling phonetic key, often with come (2)
- likea — 4 pair sides, mostly spelling via spelling phonetic key, often with see (1)
- dawg — 4 pair sides, mostly spelling via spelling phonetic key, often with call (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Bibby | Ain’t Heard Bout You | 64 | 92 | 263 | loose |
| Lil Bibby | Ain’t Heard Bout You (Kill Shit Pt.2) | 38 | 59 | 233 | loose |
| Lil Bibby | Better Dayz | 57 | 54 | 370 | loose |
| Lil Bibby | Donations | 67 | 87 | 392 | loose |
| Lil Bibby | Facts | 31 | 60 | 182 | loose |
| Lil Bibby | Fake Niggas | 67 | 67 | 424 | loose |
| Lil Bibby | Game Over | 67 | 102 | 307 | loose |
| Lil Bibby | I’m Rolling (Remix) | 109 | 90 | 501 | loose |
| Lil Bibby | Know Something | 66 | 49 | 451 | loose |
| Lil Bibby | Lettin Up | 55 | 54 | 246 | loose |
| Lil Bibby | My Hood | 32 | 35 | 239 | loose |
| Lil Bibby | Shout Out | 88 | 96 | 363 | loose |
| Lil Bibby | Sleeping on the Floor | 41 | 70 | 368 | loose |
| Lil Bibby | Squad | 37 | 30 | 165 | loose |
| Lil Bibby | We Ready For Dis Shit | 53 | 40 | 168 | loose |
