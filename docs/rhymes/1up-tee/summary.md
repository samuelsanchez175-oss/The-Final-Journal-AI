# 1Up Tee rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 1Up Tee
- Songs: 1
- Bars kept (1Up Tee lyric lines): 54
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: 1Up Tee.
- Credit strings: 1Up Tee.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 451
- REPEAT pairs, recorded separately: 63
- END rhymes: 61
- INNER rhymes: 390

By match:

- PERFECT: 39 (END 9, INNER 30)
- SLANT: 190 (END 29, INNER 161)
- ASSONANCE: 220 (END 23, INNER 197)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 36
- MED: 389
- LOW: 26

## Core

- Core Y: 444
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 205 (45.5%)
- vowel: 220 (48.8%)
- spelling: 24 (5.3%)
- multi: 2 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 49 pairs (END 0, INNER 49). Words: bitches, shit, kids, still, kid, bitch, livin, hittin.
2. `vow:EY` — 28 pairs (END 0, INNER 28). Words: ain't, make, paid, say, away, waitin, statements, gave.
3. `vow:AH` — 26 pairs (END 4, INNER 22). Words: fucked, sucked, stunts, puttin, young, month, strugglin, ones.
4. `slant:IH:sib-stop` — 24 pairs (END 1, INNER 23). Words: bitch, shit, niggas, nigga, hit, rich, hits, crib.
5. `slant:UH:stop` — 20 pairs (END 0, INNER 20). Words: good, took, overcooked, overlooked, book, look, hood, should.
6. `vow:IY` — 20 pairs (END 0, INNER 20). Words: real, homebody, see, even, cheated, screamin, treat, classy.
7. `vow:AY` — 18 pairs (END 4, INNER 14). Words: like, grindin, lines, try, finally, time, why, writin.
8. `vow:AA` — 17 pairs (END 3, INNER 14). Words: artist, smart, party, olive, karma, got, hearted, body.
9. `vow:OW` — 17 pairs (END 0, INNER 17). Words: know, don't, home, holes, owe, bro, show, ho.
10. `vow:EH` — 16 pairs (END 0, INNER 16). Words: gettin, when, rent, bread, sell, yellin, bentley, never.
11. `slant:AH:nas` — 11 pairs (END 0, INNER 11). Words: dumb, young, one, puttin, done.
12. `cmu:IH-T` — 10 pairs (END 0, INNER 10). Words: shit, lit, hit, jugg.
13. `vow:AO` — 9 pairs (END 5, INNER 4). Words: forbes, often, galore, forward, author, y'all, call, bored.
14. `slant:AE:stop` — 8 pairs (END 3, INNER 5). Words: nap, bad, pussycat, black, rap, back, cracked.
15. `slant:AY:nas` — 8 pairs (END 8, INNER 0). Words: time, mine, shinin, grindin.
16. `slant:IH:liq-stop` — 8 pairs (END 0, INNER 8). Words: really, shit, still, kid, hit, jugg, lit.
17. `slant:IH:sib` — 8 pairs (END 0, INNER 8). Words: bitches, figures, six, bitch, kids, hits, riches.
18. `vow:AW` — 8 pairs (END 7, INNER 1). Words: bounties, flowers, allowance, housing, power, how, 'round, down.
19. `slant:AA:stop` — 7 pairs (END 0, INNER 7). Words: smart, hearted, got, heart, want, artist.
20. `slant:EH:nas-stop` — 6 pairs (END 0, INNER 6). Words: get, when, gettin, bread, 'nem, many.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with niggas (5)
- jugg — 8 pair sides, mostly cmu via vault phonetic_class, often with bitch (2)
- homebody — 7 pair sides, mostly vowel via spelling phonetic key, often with see (1)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)
- ramen — 3 pair sides, mostly spelling via spelling phonetic key, often with often (1)
- wifey — 3 pair sides, mostly spelling via spelling phonetic key, often with say (1)
- swere — 3 pair sides, mostly spelling via spelling phonetic key, often with get (1)
- dyin — 1 pair sides, mostly spelling via spelling phonetic key, often with pullin (1)
- nem — 1 pair sides, mostly spelling via spelling phonetic key, often with get (1)
- slimier — 1 pair sides, mostly spelling via spelling phonetic key, often with wifey (1)
- punchlines — 1 pair sides, mostly spelling via spelling phonetic key, often with millies (1)
- millies — 1 pair sides, mostly spelling via spelling phonetic key, often with punchlines (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with here (1)
- swerv — 1 pair sides, mostly spelling via spelling phonetic key, often with herbo (1)
- herbo — 1 pair sides, mostly spelling via spelling phonetic key, often with swerv (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 1Up Tee | GooD KarMa (Remix) | 54 | 61 | 390 | loose |
