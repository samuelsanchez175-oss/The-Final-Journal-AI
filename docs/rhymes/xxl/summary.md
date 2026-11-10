# XXL rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: XXL
- Songs: 2
- Bars kept (XXL lyric lines): 129
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: XXL.
- Credit strings: XXL.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 695
- REPEAT pairs, recorded separately: 85
- END rhymes: 132
- INNER rhymes: 563

By match:

- PERFECT: 44 (END 12, INNER 32)
- SLANT: 337 (END 67, INNER 270)
- ASSONANCE: 309 (END 49, INNER 260)
- MULTI: 5 (END 4, INNER 1)

By confidence:

- HIGH: 47
- MED: 600
- LOW: 48

## Core

- Core Y: 686
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 340 (48.9%)
- vowel: 309 (44.5%)
- spelling: 41 (5.9%)
- multi: 5 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 61 pairs (END 5, INNER 56). Words: told, folks, know, don't, no, kobe, smokin, blow.
2. `vow:AE` — 52 pairs (END 11, INNER 41). Words: past, halves, man, had, handle, package, mask, actin.
3. `vow:IH` — 37 pairs (END 3, INNER 34). Words: bitch, bitches, lil, business, thinking, rings, six, shit.
4. `vow:AH` — 33 pairs (END 6, INNER 27). Words: nothing, money, ugly, butts, hundreds, hungry, couple, fuckin.
5. `vow:EH` — 29 pairs (END 3, INNER 26). Words: gettin, felt, when, twenty, lenox, freshman, character, question.
6. `slant:AA:stop` — 21 pairs (END 1, INNER 20). Words: got, knock, drop, shot, art, pocket, washed, heart.
7. `vow:EY` — 20 pairs (END 0, INNER 20). Words: ain't, sailing, chains, always, say, takes, day, take.
8. `vow:IY` — 20 pairs (END 8, INNER 12). Words: eat, three, g, cheeks, week, streets, eating, see.
9. `slant:IH:liq-sib` — 19 pairs (END 0, INNER 19). Words: bitch, lil, wiz, tierra, really, still.
10. `vow:AA` — 18 pairs (END 2, INNER 16). Words: starvin, watched, echelon, washed, car, sorry, mom, harlem.
11. `slant:AE:stop` — 17 pairs (END 6, INNER 11). Words: back, mask, panic, jab, clapped, clack, wrap, nap.
12. `slant:AH:nas-stop` — 17 pairs (END 0, INNER 17). Words: fuck, motherfuckin, one, young, money, truck, what, cut.
13. `vow:AY` — 13 pairs (END 3, INNER 10). Words: diamonds, like, die, finals, shining, ties, why, white.
14. `slant:IH:sib-stop` — 12 pairs (END 0, INNER 12). Words: bitch, shit, nigga, click, dick, nigga's, wiz, pick.
15. `slant:AE:nas-sib` — 11 pairs (END 1, INNER 10). Words: ass, man, damn, grams, cam, van, catch, fazo.
16. `slant:AE:nas-stop` — 11 pairs (END 0, INNER 11). Words: had, can, man, panic, planet, back, kodak, gang.
17. `slant:AE:sib-stop` — 11 pairs (END 5, INNER 6). Words: gas, ass, last, black, wrap, nap, past, jab.
18. `slant:EH:stop` — 11 pairs (END 5, INNER 6). Words: ready, fetty, get, let, disrespect, character, america, scared.
19. `slant:IH:stop` — 9 pairs (END 3, INNER 6). Words: nigga, hit, shit, dick, fisker, kissed, picked, pick.
20. `slant:OW:liq-stop` — 9 pairs (END 3, INNER 6). Words: roll, yola, road, told, boat, soda, shoulder, hol.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- swishers — 4 pair sides, mostly vowel via spelling phonetic key, often with bitch (2)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- hol — 4 pair sides, mostly spelling via spelling phonetic key, often with rollie (2)
- holey — 4 pair sides, mostly spelling via spelling phonetic key, often with only (1)
- karats — 4 pair sides, mostly cmu via vault phonetic_class, often with much (1)
- lowkey — 4 pair sides, mostly vowel via spelling phonetic key, often with down (2)
- fisker — 3 pair sides, mostly spelling via spelling phonetic key, often with dick (1)
- swervin — 3 pair sides, mostly spelling via spelling phonetic key, often with irving (1)
- fazo — 3 pair sides, mostly spelling via spelling phonetic key, often with man (1)
- tierra — 2 pair sides, mostly spelling via spelling phonetic key, often with click (1)
- prezi — 2 pair sides, mostly spelling via spelling phonetic key, often with when (2)
- homies — 2 pair sides, mostly spelling via spelling phonetic key, often with folks (2)
- stuntin — 1 pair sides, mostly vowel via spelling phonetic key, often with nothing (1)
- shrooms — 1 pair sides, mostly spelling via spelling phonetic key, often with room (1)
- guap — 1 pair sides, mostly spelling via spelling phonetic key, often with one (1)
- balenciaga — 1 pair sides, mostly vowel via spelling phonetic key, often with trap (1)
- nas — 1 pair sides, mostly spelling via spelling phonetic key, often with had (1)
- herbo — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- kyrie — 1 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with vito (1)
- tatted — 1 pair sides, mostly vowel via spelling phonetic key, often with have (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| XXL | XXL Freshmen 2016 Cypher - Part 2 | 82 | 83 | 293 | loose |
| XXL | XXL Freshmen 2016 Cypher - Part 3 | 47 | 49 | 270 | loose |
