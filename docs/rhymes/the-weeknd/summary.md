# The Weeknd rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: The Weeknd
- Songs: 3
- Bars kept (The Weeknd lyric lines): 104
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: The Weeknd.
- Credit strings: The Weeknd.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 683
- REPEAT pairs, recorded separately: 96
- END rhymes: 77
- INNER rhymes: 606

By match:

- PERFECT: 70 (END 14, INNER 56)
- SLANT: 232 (END 16, INNER 216)
- ASSONANCE: 379 (END 45, INNER 334)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 67
- MED: 471
- LOW: 145

## Core

- Core Y: 586
- Core N among rhyme pairs: 97

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 251 (36.7%)
- vowel: 379 (55.5%)
- spelling: 51 (7.5%)
- multi: 2 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 103 pairs (END 6, INNER 97). Words: no, claro, chingo, hablo, cuando, llamo, otro, valgo.
2. `vow:IY` — 61 pairs (END 6, INNER 55). Words: streets, te, see, feedin, east, dia, peak, rico.
3. `vow:AA` — 57 pairs (END 8, INNER 49). Words: la, popular, con, top, claro, amore, everybody, parties.
4. `vow:EH` — 47 pairs (END 5, INNER 42). Words: else, get, heaven, hell, never, bellas, emirates, there's.
5. `vow:EY` — 37 pairs (END 12, INNER 25). Words: play, baby, pray, taste, stay, away, game, fame.
6. `vow:AY` — 31 pairs (END 8, INNER 23). Words: life, lights, time's, by, try, like, diamonds, lie.
7. `vow:AE` — 25 pairs (END 0, INNER 25). Words: stand, pacto, amor, can't, sand, action, can, jackson.
8. `cmu:IY` — 20 pairs (END 0, INNER 20). Words: te, si, mi, ve, de, paparazzi, probably.
9. `slant:AE:nas-stop` — 13 pairs (END 0, INNER 13). Words: can, fat, mak, mami, tambi, hacer, amor, fam.
10. `slant:EH:liq-nas` — 13 pairs (END 0, INNER 13). Words: el, n, l, cara, again, m, pena, en.
11. `slant:AH:nas-sib` — 12 pairs (END 0, INNER 12). Words: another, one, come, un, mujer.
12. `vow:AH` — 10 pairs (END 0, INNER 10). Words: runnin, what, floodin, fuckin, another, come, one, fuck.
13. `slant:EY:nas-stop` — 9 pairs (END 2, INNER 7). Words: pain, baby, game, ain't, made, take, fame.
14. `slant:EH:liq-sib` — 8 pairs (END 0, INNER 8). Words: el, s, bellas, del, es, leray, there's, tell.
15. `cmu:AY` — 7 pairs (END 1, INNER 6). Words: y, high, bye, by, try.
16. `cmu:OW` — 7 pairs (END 0, INNER 7). Words: no, solo, segundo, vo, go, know.
17. `slant:EH:nas` — 7 pairs (END 2, INNER 5). Words: again, m, pena, n.
18. `slant:EH:nas-stop` — 7 pairs (END 0, INNER 7). Words: prendo, n, beb, en, get, again, pena, gettin.
19. `slant:IY:sib-stop` — 7 pairs (END 0, INNER 7). Words: feet, reese, streets, east, beats, speed, peak.
20. `cmu:EY` — 6 pairs (END 6, INNER 0). Words: stay, away, play, pray.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- culo — 13 pair sides, mostly vowel via spelling phonetic key, often with enchulo (1)
- puedo — 13 pair sides, mostly vowel via spelling phonetic key, often with claro (2)
- llamo — 12 pair sides, mostly vowel via spelling phonetic key, often with claro (2)
- chingo — 12 pair sides, mostly vowel via spelling phonetic key, often with claro (2)
- valgo — 11 pair sides, mostly vowel via spelling phonetic key, often with chingamo (1)
- hablo — 11 pair sides, mostly vowel via spelling phonetic key, often with claro (2)
- cuando — 11 pair sides, mostly vowel via spelling phonetic key, often with claro (2)
- otro — 9 pair sides, mostly vowel via spelling phonetic key, often with wont (1)
- enchulo — 7 pair sides, mostly vowel via spelling phonetic key, often with culo (1)
- rompiendo — 7 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- chingamo — 6 pair sides, mostly vowel via spelling phonetic key, often with enchulo (1)
- prendo — 6 pair sides, mostly spelling via spelling phonetic key, often with en (2)
- falso — 6 pair sides, mostly vowel via spelling phonetic key, often with solo (1)
- leray — 4 pair sides, mostly spelling via spelling phonetic key, often with married (1)
- beb — 4 pair sides, mostly spelling via spelling phonetic key, often with el (1)
- hacer — 4 pair sides, mostly spelling via spelling phonetic key, often with mami (1)
- shawty — 4 pair sides, mostly vowel via spelling phonetic key, often with free (1)
- botone — 3 pair sides, mostly spelling via spelling phonetic key, often with corazone (1)
- gastes — 3 pair sides, mostly vowel via spelling phonetic key, often with lambiendote (1)
- nota — 3 pair sides, mostly spelling via spelling phonetic key, often with doler (1)
- fam — 2 pair sides, mostly spelling via spelling phonetic key, often with lamb (1)
- corazone — 2 pair sides, mostly multi via spelling phonetic key, often with botone (1)
- lambiendote — 2 pair sides, mostly vowel via spelling phonetic key, often with gastes (1)
- amarte — 2 pair sides, mostly vowel via spelling phonetic key, often with lambiendote (1)
- doler — 2 pair sides, mostly vowel via spelling phonetic key, often with corazone (1)
- mami — 2 pair sides, mostly spelling via spelling phonetic key, often with tambi (1)
- tambi — 2 pair sides, mostly spelling via spelling phonetic key, often with mami (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with camino (1)
- roleplay — 1 pair sides, mostly spelling via spelling phonetic key, often with play (1)
- hort — 1 pair sides, mostly spelling via spelling phonetic key, often with more (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| The Weeknd | Another One Of Me (Version 13) | 24 | 8 | 133 | loose |
| The Weeknd | Another One of Me (Anuel Version)* | 47 | 43 | 368 | loose |
| The Weeknd | Popular | 33 | 26 | 105 | loose |
