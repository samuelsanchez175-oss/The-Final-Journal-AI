# Nigo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Nigo
- Songs: 1
- Bars kept (Nigo lyric lines): 47
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Nigo.
- Credit strings: Nigo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 196
- REPEAT pairs, recorded separately: 30
- END rhymes: 55
- INNER rhymes: 141

By match:

- PERFECT: 20 (END 10, INNER 10)
- SLANT: 62 (END 14, INNER 48)
- ASSONANCE: 111 (END 31, INNER 80)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 15
- MED: 169
- LOW: 12

## Core

- Core Y: 195
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 65 (33.2%)
- vowel: 111 (56.6%)
- spelling: 17 (8.7%)
- multi: 3 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 44 pairs (END 10, INNER 34). Words: let, sendin, evidence, felon, remember, stressin, tec, flexin.
2. `vow:AY` — 18 pairs (END 9, INNER 9). Words: sky, island, wildin, fives, guys, jivin, like, i'll.
3. `vow:EY` — 17 pairs (END 10, INNER 7). Words: changed, stay, hatin, pay, paid, ain't, crazy, trey.
4. `vow:AA` — 9 pairs (END 0, INNER 9). Words: shots, droppin, knot, knock, opp, mama, robbin, talkin.
5. `vow:IH` — 7 pairs (END 1, INNER 6). Words: big, figures, mr, ins, everything, liquor, lil, since.
6. `cmu:EY` — 6 pairs (END 6, INNER 0). Words: stay, lay, trey, pay.
7. `slant:AY:nas` — 6 pairs (END 4, INNER 2). Words: pilin, timin, jivin, wildin.
8. `slant:EH:stop` — 6 pairs (END 2, INNER 4). Words: president, bread, get, ebk, send, reverend, evident, let.
9. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: fuck, money, fuckin, what, some.
10. `slant:EH:nas` — 5 pairs (END 2, INNER 3). Words: stressin, flexin, gettin, steppin, weapon.
11. `vow:AH` — 5 pairs (END 0, INNER 5). Words: fuck, chuckin, what, comin, uppin, money, motherfuckin.
12. `slant:EY:sib-stop` — 4 pairs (END 2, INNER 2). Words: crazy, chains, ain't, ways, paid, mayday, dayday.
13. `slant:IH:sib-stop` — 4 pairs (END 0, INNER 4). Words: nigga, niggas.
14. `spell:ay` — 4 pairs (END 3, INNER 1). Words: laylay, pay, dayday, mayday, stay.
15. `slant:AH:nas` — 3 pairs (END 1, INNER 2). Words: comin, uppin, money, some, slum, run.
16. `slant:EH:nas-stop` — 3 pairs (END 0, INNER 3). Words: when, send, sendin, bread, tec.
17. `slant:EY:nas-sib` — 3 pairs (END 0, INNER 3). Words: playin, days, always.
18. `vow:AW` — 3 pairs (END 0, INNER 3). Words: clout, now, how.
19. `vow:IY` — 3 pairs (END 0, INNER 3). Words: screamin, beef, sea, nigga.
20. `vow:OW` — 3 pairs (END 1, INNER 2). Words: go, don't, no, bankroll, pole.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- laylay — 5 pair sides, mostly spelling via spelling phonetic key, often with mayday (1)
- nigga — 5 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- dayday — 3 pair sides, mostly spelling via spelling phonetic key, often with mayday (1)
- swole — 2 pair sides, mostly spelling via spelling phonetic key, often with bankroll (1)
- ebk — 1 pair sides, mostly spelling via spelling phonetic key, often with get (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Nigo | Remember | 47 | 55 | 141 | loose |
