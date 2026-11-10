# Taylor Bennett rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Taylor Bennett
- Songs: 1
- Bars kept (Taylor Bennett lyric lines): 46
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Taylor Bennett.
- Credit strings: Taylor Bennett.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 325
- REPEAT pairs, recorded separately: 38
- END rhymes: 40
- INNER rhymes: 285

By match:

- PERFECT: 13 (END 0, INNER 13)
- SLANT: 166 (END 28, INNER 138)
- ASSONANCE: 138 (END 10, INNER 128)
- MULTI: 8 (END 2, INNER 6)

By confidence:

- HIGH: 14
- MED: 267
- LOW: 44

## Core

- Core Y: 318
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 137 (42.2%)
- vowel: 138 (42.5%)
- spelling: 42 (12.9%)
- multi: 8 (2.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 28 pairs (END 0, INNER 28). Words: fuck, one, bunch, puddles, sucked, hundreds, crumbles, what's.
2. `vow:EY` — 26 pairs (END 7, INNER 19). Words: haters, stay, jamaican, trade, race, rape, asian, ain't.
3. `slant:IH:sib-stop` — 23 pairs (END 11, INNER 12). Words: nigga, niggas, bitch, crib, hit, spit, kiss, smith.
4. `vow:EH` — 19 pairs (END 2, INNER 17). Words: friends, pennies, getting, stressing, get, hemy, remy, steady.
5. `vow:IH` — 17 pairs (END 0, INNER 17). Words: bitches, fifties, swim, finnesing, kiss, crib, smith, nickle.
6. `vow:AA` — 16 pairs (END 1, INNER 15). Words: bacardi, cop, want, party, hollows, bars, college, commas.
7. `slant:EH:nas-stop` — 9 pairs (END 0, INNER 9). Words: get, steady, getting, em, remy, hemy, let, when.
8. `slant:ER:stop` — 9 pairs (END 5, INNER 4). Words: curb, word, herb, bird, berserk, third, herbo.
9. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: gotta, not, squad, party, pop, got, bacardi, block.
10. `vow:IY` — 8 pairs (END 0, INNER 8). Words: see, reason, keep, these, peewee, g, mean.
11. `slant:IH:sib` — 7 pairs (END 0, INNER 7). Words: bitch, bitches, snitches, kiss.
12. `slant:AH:nas-stop` — 6 pairs (END 0, INNER 6). Words: fuck, one, money, guap.
13. `slant:EH:stop` — 6 pairs (END 1, INNER 5). Words: get, paycheck, said, steady.
14. `slant:ER:nas-stop` — 6 pairs (END 0, INNER 6). Words: turn, word, burn, herb, bird, curb, herbo.
15. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: nigga, big, shit, dick, spit.
16. `vow:AE` — 6 pairs (END 0, INNER 6). Words: blasting, mad, max, can, crackin.
17. `vow:OW` — 6 pairs (END 0, INNER 6). Words: posted, dope, smoking, don't, know, fofo's, glocks, no.
18. `slant:AH:stop` — 5 pairs (END 0, INNER 5). Words: fuck, dunk, under, sucked, chunk, trunk.
19. `slant:EH:fric-stop` — 5 pairs (END 0, INNER 5). Words: never, get, paycheck, said.
20. `vow:AY` — 5 pairs (END 0, INNER 5). Words: by, ridin, riding, like, while, i'on, might, right.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 21 pair sides, mostly spelling via spelling phonetic key, often with niggas (17)
- niggas — 17 pair sides, mostly spelling via spelling phonetic key, often with nigga (17)
- finnesing — 7 pair sides, mostly vowel via spelling phonetic key, often with stressing (2)
- herbo — 4 pair sides, mostly spelling via spelling phonetic key, often with burn (1)
- snitches — 4 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- brulee — 2 pair sides, mostly spelling via spelling phonetic key, often with money (1)
- guap — 2 pair sides, mostly spelling via spelling phonetic key, often with money (1)
- wacked — 2 pair sides, mostly spelling via spelling phonetic key, often with crackin (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with turn (1)
- dutches — 2 pair sides, mostly spelling via spelling phonetic key, often with snitches (1)
- ttfufun — 1 pair sides, mostly vowel via spelling phonetic key, often with fuck (1)
- fofos — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with dope (1)
- glocks — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- cuffing — 1 pair sides, mostly spelling via spelling phonetic key, often with flying (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Taylor Bennett | Creme Brulee | 46 | 40 | 285 | loose |
