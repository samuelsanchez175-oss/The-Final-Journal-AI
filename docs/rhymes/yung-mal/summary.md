# Yung Mal rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Yung Mal
- Songs: 1
- Bars kept (Yung Mal lyric lines): 51
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Yung Mal.
- Credit strings: Yung Mal.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 463
- REPEAT pairs, recorded separately: 37
- END rhymes: 85
- INNER rhymes: 378

By match:

- PERFECT: 29 (END 1, INNER 28)
- SLANT: 213 (END 26, INNER 187)
- ASSONANCE: 213 (END 56, INNER 157)
- MULTI: 8 (END 2, INNER 6)

By confidence:

- HIGH: 29
- MED: 373
- LOW: 61

## Core

- Core Y: 452
- Core N among rhyme pairs: 11

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 187 (40.4%)
- vowel: 213 (46.0%)
- spelling: 55 (11.9%)
- multi: 8 (1.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 67 pairs (END 37, INNER 30). Words: even, people, equal, teachers, g, adidas, creepin, heater.
2. `vow:IH` — 60 pairs (END 9, INNER 51). Words: shit, him, simple, trippin, wings, pimple, fifty, builder.
3. `slant:AA:stop` — 34 pairs (END 0, INNER 34). Words: got, god, top, chopper, glock, gotta, bob, party.
4. `slant:IH:stop` — 25 pairs (END 1, INNER 24). Words: nigga, shit, kick, blicky, hit, sit, fifty, didn't.
5. `vow:AH` — 22 pairs (END 8, INNER 14). Words: what's, guns, money, ugly, slums, somethin, another, hung.
6. `slant:AH:nas` — 21 pairs (END 5, INNER 16). Words: runnin, money, comin, young, somethin, run, hung, some.
7. `vow:AA` — 21 pairs (END 1, INNER 20). Words: got, top, project, cars, started, rocks, parked, spot.
8. `slant:IH:sib-stop` — 16 pairs (END 2, INNER 14). Words: niggas, nigga, kiss, bitch, shit, sit, builder, pills.
9. `vow:EH` — 13 pairs (END 1, INNER 12). Words: get, tesla, level, help, where, independent, stressin, benz.
10. `vow:OW` — 10 pairs (END 0, INNER 10). Words: know, don't, no, hoes, rolls, herbo, whole, hold.
11. `slant:AH:nas-stop` — 9 pairs (END 0, INNER 9). Words: hung, numb, mug, thug, drug, young, fuck.
12. `slant:IY:liq` — 9 pairs (END 6, INNER 3). Words: people, equal, regal, feel, sequel, ear.
13. `slant:IH:liq-sib` — 8 pairs (END 1, INNER 7). Words: bitch, lil, still, pills, switch, hill, year, kiss.
14. `slant:IH:nas-stop` — 8 pairs (END 2, INNER 6). Words: him, shit, kick, blicky, hit.
15. `vow:AE` — 8 pairs (END 0, INNER 8). Words: taxes, pack, last, back, laugh, candler, adderall, ass.
16. `slant:EH:fric-stop` — 6 pairs (END 0, INNER 6). Words: never, better, get, ever.
17. `slant:IY:stop` — 6 pairs (END 2, INNER 4). Words: keep, league, geeked, heater, need.
18. `vow:EY` — 6 pairs (END 0, INNER 6). Words: jay, chase, racist, face, bracelet, waitin, gave.
19. `vow:AY` — 5 pairs (END 0, INNER 5). Words: why, try, tried, stripes, night, like.
20. `cmu:IH-L` — 4 pairs (END 0, INNER 4). Words: still, kill, hill, lil.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 28 pair sides, mostly spelling via spelling phonetic key, often with shit (10)
- niggas — 12 pair sides, mostly spelling via spelling phonetic key, often with nigga (9)
- creepers — 8 pair sides, mostly spelling via spelling phonetic key, often with jeepers (2)
- jeepers — 6 pair sides, mostly spelling via spelling phonetic key, often with creepers (2)
- blicky — 5 pair sides, mostly spelling via spelling phonetic key, often with kick (1)
- geeked — 4 pair sides, mostly spelling via spelling phonetic key, often with league (1)
- peopl — 3 pair sides, mostly spelling via spelling phonetic key, often with people (2)
- herbo — 3 pair sides, mostly spelling via spelling phonetic key, often with curb (1)
- swervin — 2 pair sides, mostly spelling via spelling phonetic key, often with earn (1)
- giv — 2 pair sides, mostly spelling via spelling phonetic key, often with kiss (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with hoes (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with deal (1)
- adderall — 1 pair sides, mostly vowel via spelling phonetic key, often with pack (1)
- spinned — 1 pair sides, mostly vowel via spelling phonetic key, often with give (1)
- lambo — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Yung Mal | Wassup With Me | 51 | 85 | 378 | loose |
