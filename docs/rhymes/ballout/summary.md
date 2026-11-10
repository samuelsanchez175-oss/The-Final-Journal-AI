# Ballout rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ballout
- Songs: 28
- Bars kept (Ballout lyric lines): 1034
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Ballout.
- Credit strings: Ballout.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 6272
- REPEAT pairs, recorded separately: 1137
- END rhymes: 1211
- INNER rhymes: 5061

By match:

- PERFECT: 557 (END 190, INNER 367)
- SLANT: 2827 (END 583, INNER 2244)
- ASSONANCE: 2776 (END 394, INNER 2382)
- MULTI: 112 (END 44, INNER 68)

By confidence:

- HIGH: 584
- MED: 5296
- LOW: 392

## Core

- Core Y: 6189
- Core N among rhyme pairs: 83

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 3020 (48.2%)
- vowel: 2776 (44.3%)
- spelling: 364 (5.8%)
- multi: 112 (1.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- loose: 27 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 446 pairs (END 66, INNER 380). Words: bitch, shit, bitches, different, six, wrist, big, pills.
2. `vow:OW` — 377 pairs (END 43, INNER 334). Words: don't, no, know, hoes, smokin, dope, go, though.
3. `vow:AE` — 339 pairs (END 58, INNER 281). Words: bands, braggin, can't, man, ballin, aston, gang, cash.
4. `vow:AA` — 295 pairs (END 23, INNER 272). Words: got, want, cars, car, parked, rollin, hard, top.
5. `vow:EH` — 248 pairs (END 12, INNER 236). Words: gettin, get, when, spent, shells, let, flexin, weekend.
6. `vow:EY` — 236 pairs (END 55, INNER 181). Words: ain't, say, baby, play, way, basement, take, cake.
7. `vow:IY` — 200 pairs (END 23, INNER 177). Words: even, these, see, real, three, streets, leanin, t.
8. `slant:AA:stop` — 175 pairs (END 20, INNER 155). Words: got, want, block, not, top, gotta, everybody, god.
9. `vow:AH` — 171 pairs (END 17, INNER 154). Words: some, trust, hundred, fuckin, money, what, fucking, fuck.
10. `slant:AE:nas-stop` — 154 pairs (END 20, INNER 134). Words: man, bad, bag, can, gang, back, hand, damn.
11. `vow:AY` — 147 pairs (END 32, INNER 115). Words: like, high, diamonds, ridin, riding, why, nigga, sky.
12. `slant:IH:sib-stop` — 103 pairs (END 20, INNER 83). Words: bitch, shit, big, hit, nigga, niggas, fish, dick.
13. `slant:IH:stop` — 100 pairs (END 31, INNER 69). Words: nigga, shit, hit, lick, pic, big, crib, click.
14. `cmu:OW` — 89 pairs (END 14, INNER 75). Words: know, no, glo, though, dough, ho, go, slow.
15. `vow:UW` — 83 pairs (END 9, INNER 74). Words: through, who, crew, shooters, gucci, two, blue, shoot.
16. `slant:AH:nas` — 81 pairs (END 18, INNER 63). Words: some, money, anyone, fuckin, one, come, runnin, thumbin.
17. `vow:AW` — 78 pairs (END 26, INNER 52). Words: now, house, down, thousand, how, about, around, count.
18. `slant:IH:liq-sib` — 76 pairs (END 15, INNER 61). Words: bitch, pills, still, lil, will, spill, pill, hill.
19. `vow:AO` — 72 pairs (END 6, INNER 66). Words: shorty, because, all, call, foreign, walking, mornin, false.
20. `slant:AA:liq-stop` — 70 pairs (END 9, INNER 61). Words: car, got, star, r, not, molly, far, party.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 65 pair sides, mostly spelling via spelling phonetic key, often with shit (9)
- ima — 27 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- niggas — 20 pair sides, mostly spelling via spelling phonetic key, often with nigga (8)
- swaggin — 12 pair sides, mostly spelling via spelling phonetic key, often with braggin (6)
- greezy — 11 pair sides, mostly spelling via spelling phonetic key, often with easy (4)
- gon — 10 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- shawty — 10 pair sides, mostly spelling via spelling phonetic key, often with call (2)
- tryna — 10 pair sides, mostly spelling via spelling phonetic key, often with even (2)
- buckah — 10 pair sides, mostly vowel via vault phonetic_class, often with living (2)
- eeny — 10 pair sides, mostly multi via spelling phonetic key, often with meeny (4)
- meeny — 10 pair sides, mostly multi via spelling phonetic key, often with eeny (4)
- tadoe — 9 pair sides, mostly spelling via spelling phonetic key, often with man (4)
- catman — 9 pair sides, mostly spelling via spelling phonetic key, often with man (5)
- 10s — 9 pair sides, mostly cmu via vault phonetic_class, often with braggin (2)
- finna — 8 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- tity — 8 pair sides, mostly multi via spelling phonetic key, often with pretty (2)
- breezing — 8 pair sides, mostly spelling via spelling phonetic key, often with easy (3)
- miny — 8 pair sides, mostly vowel via spelling phonetic key, often with bitch (1)
- dawg — 7 pair sides, mostly spelling via spelling phonetic key, often with because (1)
- ballout — 7 pair sides, mostly spelling via spelling phonetic key, often with balenci (2)
- boi — 7 pair sides, mostly multi via spelling phonetic key, often with boy (7)
- imma — 7 pair sides, mostly vowel via spelling phonetic key, often with nigga (2)
- wiic — 7 pair sides, mostly spelling via spelling phonetic key, often with click (1)
- verty — 6 pair sides, mostly spelling via spelling phonetic key, often with dirty (1)
- chainz — 6 pair sides, mostly spelling via spelling phonetic key, often with james (2)
- saddity — 6 pair sides, mostly multi via spelling phonetic key, often with pretty (2)
- raris — 6 pair sides, mostly spelling via spelling phonetic key, often with actin (1)
- swag — 6 pair sides, mostly spelling via spelling phonetic key, often with bad (2)
- stuntin — 6 pair sides, mostly spelling via spelling phonetic key, often with makin (2)
- miney — 6 pair sides, mostly spelling via spelling phonetic key, often with finna (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ballout | 100 Million | 32 | 51 | 136 | loose |
| Ballout | 1Take | 52 | 41 | 262 | loose |
| Ballout | Ain’t Far | 26 | 21 | 153 | loose |
| Ballout | Back Too Back | 46 | 51 | 93 | loose |
| Ballout | Bad Man | 39 | 50 | 154 | loose |
| Ballout | Ballout Baby (BNNBA3) | 39 | 23 | 121 | loose |
| Ballout | Been Ballin’ | 28 | 29 | 177 | loose |
| Ballout | Country | 39 | 38 | 173 | loose |
| Ballout | Diamonds For Everyone | 26 | 42 | 192 | loose |
| Ballout | Different (Remix) | 38 | 48 | 177 | loose |
| Ballout | Easy | 48 | 48 | 296 | loose |
| Ballout | Favorite | 37 | 55 | 180 | loose |
| Ballout | Flexin | 38 | 55 | 134 | loose |
| Ballout | Forgiatos | 33 | 34 | 268 | loose |
| Ballout | Gang Members | 54 | 60 | 197 | loose |
| Ballout | I Got A Bag | 32 | 67 | 218 | loose |
| Ballout | Lower | 38 | 36 | 314 | loose |
| Ballout | Make You Run | 34 | 43 | 143 | loose |
| Ballout | No Limit | 37 | 29 | 255 | loose |
| Ballout | Pill Party | 43 | 43 | 243 | loose |
| Ballout | Ring Bells | 25 | 36 | 99 | loose |
| Ballout | Sending Nudes | 19 | 34 | 68 | AAAA |
| Ballout | Shorty | 36 | 55 | 222 | loose |
| Ballout | Sky | 39 | 63 | 131 | loose |
| Ballout | Spyder | 48 | 48 | 189 | loose |
| Ballout | The Weekend | 29 | 19 | 96 | loose |
| Ballout | Welcome 2 Ballout World | 44 | 50 | 168 | loose |
| Ballout | Wheel | 35 | 42 | 202 | loose |
