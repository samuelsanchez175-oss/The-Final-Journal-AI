# Post Malone rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Post Malone
- Songs: 4
- Bars kept (Post Malone lyric lines): 107
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Post Malone.
- Credit strings: Post Malone.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 502
- REPEAT pairs, recorded separately: 51
- END rhymes: 91
- INNER rhymes: 411

By match:

- PERFECT: 35 (END 8, INNER 27)
- SLANT: 197 (END 38, INNER 159)
- ASSONANCE: 263 (END 38, INNER 225)
- MULTI: 7 (END 7, INNER 0)

By confidence:

- HIGH: 38
- MED: 449
- LOW: 15

## Core

- Core Y: 495
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 220 (43.8%)
- vowel: 263 (52.4%)
- spelling: 12 (2.4%)
- multi: 7 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 4 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 43 pairs (END 9, INNER 34). Words: ta, hard, got, rockstar, poppin, superstars, bra, cars.
2. `vow:AY` — 43 pairs (END 20, INNER 23). Words: die, lied, lying, high, deny, like, by, nights.
3. `slant:AA:liq-stop` — 42 pairs (END 7, INNER 35). Words: rockstar, car, hard, got, chart, hot, star, cop.
4. `vow:EY` — 40 pairs (END 0, INNER 40). Words: say, ain't, table, sayin, away, patience, waitin, veins.
5. `vow:OW` — 37 pairs (END 0, INNER 37). Words: know, don't, sold, no, frozen, over, broken, show.
6. `vow:EH` — 32 pairs (END 2, INNER 30). Words: when, getting, arrested, remember, said, rest, best, forget.
7. `vow:AE` — 28 pairs (END 7, INNER 21). Words: band, pants, bad, savage, actin, damn, grab, man.
8. `slant:AA:stop` — 15 pairs (END 1, INNER 14). Words: not, hot, tart, hard, chart, cop, got, pop.
9. `vow:IH` — 11 pairs (END 0, INNER 11). Words: didn't, bitches, window, askin, livin, really, different, bitch.
10. `slant:AY:nas-stop` — 10 pairs (END 4, INNER 6). Words: lying, lied, like, daylight, crying, side, time, tired.
11. `vow:AH` — 10 pairs (END 0, INNER 10). Words: fuckin, vulnerable, fucking, love, nothing's, brothers, jumpin, club.
12. `cmu:OW` — 9 pairs (END 1, INNER 8). Words: know, low, no, though, show, go.
13. `cmu:AA-R` — 8 pairs (END 3, INNER 5). Words: rockstar, star, car.
14. `multi:AY-IH-NG` — 6 pairs (END 6, INNER 0). Words: crying, lying, flying, trying.
15. `slant:AY:stop` — 6 pairs (END 1, INNER 5). Words: lied, like, sight, daylight, light.
16. `slant:EH:nas-stop` — 6 pairs (END 0, INNER 6). Words: when, forget, surrender, said, friend, henny.
17. `vow:IY` — 6 pairs (END 0, INNER 6). Words: treating, tv, feeling, see, vip, need, secrets, probably.
18. `cmu:AY` — 5 pairs (END 3, INNER 2). Words: die, high, by, deny.
19. `slant:AE:nas-stop` — 5 pairs (END 2, INNER 3). Words: man, band, had, ran, grab, cakin, snack.
20. `slant:AO:liq-stop` — 5 pairs (END 0, INNER 5). Words: all, brought, called, thought.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- grra — 4 pair sides, mostly vowel via spelling phonetic key, often with crankdat (1)
- drankin — 3 pair sides, mostly spelling via spelling phonetic key, often with fuckin (1)
- wifey — 3 pair sides, mostly spelling via spelling phonetic key, often with kiss (1)
- crankdat — 2 pair sides, mostly vowel via spelling phonetic key, often with band (1)
- cakin — 2 pair sides, mostly spelling via spelling phonetic key, often with snack (1)
- rasta — 1 pair sides, mostly spelling via spelling phonetic key, often with gas (1)
- shottas — 1 pair sides, mostly spelling via spelling phonetic key, often with gas (1)
- prolly — 1 pair sides, mostly vowel via spelling phonetic key, often with tv (1)
- henny — 1 pair sides, mostly spelling via spelling phonetic key, often with friend (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Post Malone | Die For Me | 51 | 54 | 191 | loose |
| Post Malone | Rockstar (Crankdat Remix) | 5 | 3 | 11 | loose |
| Post Malone | rockstar | 40 | 29 | 177 | loose |
| Post Malone | rockstar (Clean Radio Edit) | 11 | 5 | 32 | loose |
