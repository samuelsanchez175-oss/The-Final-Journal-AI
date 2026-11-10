# Mudbaby Ru rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Mudbaby Ru
- Songs: 1
- Bars kept (Mudbaby Ru lyric lines): 72
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Mudbaby Ru.
- Credit strings: Mudbaby Ru.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 745
- REPEAT pairs, recorded separately: 45
- END rhymes: 102
- INNER rhymes: 643

By match:

- PERFECT: 97 (END 27, INNER 70)
- SLANT: 322 (END 47, INNER 275)
- ASSONANCE: 326 (END 28, INNER 298)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 96
- MED: 625
- LOW: 24

## Core

- Core Y: 739
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 400 (53.7%)
- vowel: 326 (43.8%)
- spelling: 19 (2.6%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 67 pairs (END 17, INNER 50). Words: three, sheets, d, these, beatin, bp, see, streets.
2. `vow:AY` — 47 pairs (END 0, INNER 47). Words: like, why, by, terrorizin, drive, fire, slide, time.
3. `slant:AA:stop` — 41 pairs (END 0, INNER 41). Words: not, cop, gotta, got, cock, chopped, knocked, smart.
4. `vow:AA` — 40 pairs (END 1, INNER 39). Words: not, wasn't, bronx, cops, poppin, got, barbers, nardo.
5. `vow:OW` — 32 pairs (END 7, INNER 25). Words: though, don't, cargos, know, herbo, no, hoes, only.
6. `vow:AH` — 30 pairs (END 0, INNER 30). Words: number, hundred, fuck, some, one, what, fucks, jump.
7. `cmu:IY-Z` — 28 pairs (END 12, INNER 16). Words: cheese, these, pleas, freeze, g's, skis, squeeze, knees.
8. `vow:IH` — 24 pairs (END 0, INNER 24). Words: think, since, fifty, bitch, missin, lil, shit, chillin.
9. `vow:EH` — 22 pairs (END 0, INNER 22). Words: left, gettin, step, steppin, lebron, there, yellin, bet.
10. `vow:EY` — 22 pairs (END 2, INNER 20). Words: ain't, say, play, take, aim, made, brain, safety.
11. `slant:AA:liq-stop` — 21 pairs (END 0, INNER 21). Words: car, far, not, got, bar, r, hard, nardo.
12. `cmu:AY` — 15 pairs (END 5, INNER 10). Words: by, why, eye, lie, spotify, guy, samurai.
13. `slant:IY:sib` — 15 pairs (END 10, INNER 5). Words: vietnamese, cheese, jesus, easy, freeze, these, squeeze, please.
14. `vow:AE` — 15 pairs (END 1, INNER 14). Words: sand, ass, hand, family, faster, man, ask, back.
15. `cmu:OW` — 14 pairs (END 7, INNER 7). Words: though, know, ho, fargo, go, ceo, show, blow.
16. `slant:IH:sib-stop` — 14 pairs (END 1, INNER 13). Words: bitch, shit, nigga, niggas, whip, fit, quick, trigger.
17. `slant:IH:stop` — 14 pairs (END 0, INNER 14). Words: shit, nigga, whip, quick, stick, hit, dealership, fit.
18. `vow:UW` — 14 pairs (END 0, INNER 14). Words: juice, who, threw, boo, shoot, salute, puke, roof.
19. `slant:IH:liq-stop` — 13 pairs (END 0, INNER 13). Words: lil, shit, still, gillie, trigger, billie, fit, quick.
20. `slant:IY:nas-sib` — 11 pairs (END 4, INNER 7). Words: jean, beach, fleas, beam, team, between, green, please.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- ima — 6 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- herbo — 5 pair sides, mostly vowel via spelling phonetic key, often with though (2)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- boolin — 2 pair sides, mostly spelling via spelling phonetic key, often with school (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with mon (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with screamin (1)
- glizzy — 1 pair sides, mostly vowel via spelling phonetic key, often with g (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Mudbaby Ru | Gun Class II | 72 | 102 | 643 | loose |
