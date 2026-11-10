# Yung Gravy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Yung Gravy
- Songs: 2
- Bars kept (Yung Gravy lyric lines): 72
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Yung Gravy.
- Credit strings: Yung Gravy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 343
- REPEAT pairs, recorded separately: 44
- END rhymes: 70
- INNER rhymes: 273

By match:

- PERFECT: 36 (END 17, INNER 19)
- SLANT: 137 (END 17, INNER 120)
- ASSONANCE: 164 (END 34, INNER 130)
- MULTI: 6 (END 2, INNER 4)

By confidence:

- HIGH: 30
- MED: 286
- LOW: 27

## Core

- Core Y: 328
- Core N among rhyme pairs: 15

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 151 (44.0%)
- vowel: 164 (47.8%)
- spelling: 22 (6.4%)
- multi: 6 (1.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 44 pairs (END 3, INNER 41). Words: finessin, bitch, killin, pistol, spill, bitches, since, kids.
2. `vow:AA` — 38 pairs (END 16, INNER 22). Words: nothin, got, poppin, partner, potter, opp, ra, project.
3. `vow:EY` — 22 pairs (END 5, INNER 17). Words: play, baby, david, chains, game, lame, ain't, pesos.
4. `slant:IH:sib-stop` — 17 pairs (END 2, INNER 15). Words: bitch, lips, whip, rich, drip, dip, hit, lick.
5. `vow:OW` — 16 pairs (END 3, INNER 13). Words: go, don't, petco, hoes, hola, hello, lambo, show.
6. `slant:AA:stop` — 12 pairs (END 0, INNER 12). Words: got, hopped, drop, opp, potter, lotta, chop, body.
7. `vow:AE` — 11 pairs (END 2, INNER 9). Words: pat, relaxin, splashin, alaskan, action, passion, ass, passin.
8. `vow:EH` — 11 pairs (END 3, INNER 8). Words: geckos, elmo, velvet, red, get, better, let, petco.
9. `slant:AH:nas-stop` — 10 pairs (END 0, INNER 10). Words: one, blunt, what, guap, some, come, fuck, run.
10. `vow:AH` — 10 pairs (END 1, INNER 9). Words: fuckin, blunt, some, what, couple, front, truck, bust.
11. `cmu:EY` — 9 pairs (END 9, INNER 0). Words: today, spray, chevrolet, bay.
12. `slant:AE:nas` — 9 pairs (END 4, INNER 5). Words: passin, splashin, alaskan, passion, relaxin, packin, bang, action.
13. `cmu:IH-N` — 7 pairs (END 0, INNER 7). Words: finessin, fuckin, nothin.
14. `slant:AO:liq-stop` — 6 pairs (END 0, INNER 6). Words: water, all, dawg, y'all.
15. `slant:EH:liq-stop` — 6 pairs (END 0, INNER 6). Words: ahead, get, harry, mary, tell.
16. `slant:EH:stop` — 6 pairs (END 1, INNER 5). Words: let, get, better, petco, head, endo, ahead.
17. `slant:EY:nas-stop` — 6 pairs (END 2, INNER 4). Words: baby, take, aim, sayin, same, wayne.
18. `slant:AH:nas` — 5 pairs (END 0, INNER 5). Words: one, fuckin, run, some, runnin, numb.
19. `slant:EY:nas` — 5 pairs (END 4, INNER 1). Words: blaine, wayne, game, same, lame, aim.
20. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: hit, crib, lick, stick.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- finessin — 18 pair sides, mostly vowel via spelling phonetic key, often with spill (5)
- petco — 6 pair sides, mostly vowel via spelling phonetic key, often with go (3)
- chainz — 3 pair sides, mostly spelling via spelling phonetic key, often with wayne (1)
- undressin — 2 pair sides, mostly multi via spelling phonetic key, often with finessin (2)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with sosa (1)
- lambo — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- hooptie — 2 pair sides, mostly spelling via spelling phonetic key, often with groupies (1)
- guap — 2 pair sides, mostly spelling via spelling phonetic key, often with run (1)
- finna — 2 pair sides, mostly spelling via spelling phonetic key, often with killin (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with yall (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Yung Gravy | Drip on My Dresser | 50 | 42 | 166 | loose |
| Yung Gravy | Tampa Bay Bustdown | 22 | 28 | 107 | loose |
