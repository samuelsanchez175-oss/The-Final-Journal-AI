# Boosa Da Shoota rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Boosa Da Shoota
- Songs: 1
- Bars kept (Boosa Da Shoota lyric lines): 35
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Boosa Da Shoota.
- Credit strings: Boosa Da Shoota.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 252
- REPEAT pairs, recorded separately: 34
- END rhymes: 64
- INNER rhymes: 188

By match:

- PERFECT: 34 (END 10, INNER 24)
- SLANT: 97 (END 27, INNER 70)
- ASSONANCE: 119 (END 27, INNER 92)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 36
- MED: 200
- LOW: 16

## Core

- Core Y: 252
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 115 (45.6%)
- vowel: 119 (47.2%)
- spelling: 16 (6.3%)
- multi: 2 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 71 pairs (END 25, INNER 46). Words: dope, go, know, road, cold, ho, sosa, no.
2. `vow:EH` — 25 pairs (END 2, INNER 23). Words: plenty, gresham, texaco, getting, flexin, semi, tec, let.
3. `cmu:OW` — 22 pairs (END 8, INNER 14). Words: go, know, blow, geronimo, ho, no.
4. `slant:IY:sib-stop` — 15 pairs (END 8, INNER 7). Words: speak, g's, piece, fredo, gleesh, meatchi, northeast.
5. `slant:OW:stop` — 15 pairs (END 6, INNER 9). Words: dope, poked, load, road, scope, joke, throat.
6. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: shot, lot, want, gotta, pop, lock, got, rob.
7. `vow:IY` — 8 pairs (END 0, INNER 8). Words: beast, speak, g's, leave, slutty, northeast, fredo, beef.
8. `slant:IY:sib` — 7 pairs (END 4, INNER 3). Words: g's, piece, gleesh, meatchi.
9. `slant:OW:sib-stop` — 7 pairs (END 3, INNER 4). Words: scopes, dope, sosa, road, scope.
10. `slant:EH:nas-stop` — 6 pairs (END 1, INNER 5). Words: let, semi, em, getting, flexin, texaco, tec.
11. `vow:IH` — 6 pairs (END 0, INNER 6). Words: pills, give, bitches, trips, shit, think, kick, him.
12. `vow:AH` — 5 pairs (END 0, INNER 5). Words: fucking, bust, guns, what, bussing, double, fuck.
13. `cmu:AA-T` — 4 pairs (END 0, INNER 4). Words: shot, got, lot.
14. `cmu:EH-T` — 3 pairs (END 0, INNER 3). Words: get, let.
15. `slant:AO:liq` — 3 pairs (END 0, INNER 3). Words: call, four, before, all.
16. `slant:IH:stop` — 3 pairs (END 0, INNER 3). Words: nigga, shit, kick, hit, bullshit.
17. `slant:IY:fric-sib` — 3 pairs (END 2, INNER 1). Words: beef, g's, meatchi.
18. `slant:IY:fric-stop` — 3 pairs (END 2, INNER 1). Words: beef, speak, fredo.
19. `vow:EY` — 3 pairs (END 0, INNER 3). Words: say, taking, ain't.
20. `cmu:AO-L` — 2 pairs (END 0, INNER 2). Words: all, call.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- meatchi — 5 pair sides, mostly spelling via spelling phonetic key, often with gs (2)
- gleesh — 4 pair sides, mostly spelling via spelling phonetic key, often with speak (2)
- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with kick (1)
- tadoe — 1 pair sides, mostly spelling via spelling phonetic key, often with bad (1)
- imma — 1 pair sides, mostly spelling via spelling phonetic key, often with ima (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Boosa Da Shoota | GBSB | 35 | 64 | 188 | loose |
