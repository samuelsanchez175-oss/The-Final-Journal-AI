# DJ Khaled rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Khaled
- Songs: 9
- Bars kept (DJ Khaled lyric lines): 437
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 3
- Canonical name: DJ Khaled.
- Credit strings: DJ Khaled.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 2780
- REPEAT pairs, recorded separately: 330
- END rhymes: 471
- INNER rhymes: 2309

By match:

- PERFECT: 272 (END 95, INNER 177)
- SLANT: 1083 (END 191, INNER 892)
- ASSONANCE: 1407 (END 179, INNER 1228)
- MULTI: 18 (END 6, INNER 12)

By confidence:

- HIGH: 266
- MED: 2374
- LOW: 140

## Core

- Core Y: 2757
- Core N among rhyme pairs: 23

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1214 (43.7%)
- vowel: 1407 (50.6%)
- spelling: 141 (5.1%)
- multi: 18 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 9 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 241 pairs (END 37, INNER 204). Words: bitches, bitch, gifted, shit, different, since, lil, drippin.
2. `vow:OW` — 229 pairs (END 11, INNER 218). Words: don't, go, no, know, told, broke, ho, hoes.
3. `vow:AA` — 223 pairs (END 29, INNER 194). Words: got, arms, want, patek, talkin, heart, hard, problems.
4. `vow:EH` — 160 pairs (END 35, INNER 125). Words: get, when, best, never, let, gettin, flesh, nest.
5. `slant:AA:stop` — 118 pairs (END 11, INNER 107). Words: got, patek, want, not, body, pocket, hard, everybody.
6. `vow:AY` — 108 pairs (END 9, INNER 99). Words: like, bae, sometimes, mind, try, buy, shine, y.
7. `vow:IY` — 103 pairs (END 8, INNER 95). Words: see, t, even, streets, these, eatin, free, here.
8. `vow:AH` — 100 pairs (END 20, INNER 80). Words: khaled, one, done, money, punctured, fuck, ugly, bust.
9. `vow:EY` — 91 pairs (END 3, INNER 88). Words: ain't, play, say, way, make, brakes, came, baby.
10. `vow:AE` — 63 pairs (END 5, INNER 58). Words: can't, had, gang, after, standin, catch, back, talents.
11. `slant:IH:stop` — 62 pairs (END 17, INNER 45). Words: nigga, shit, sit, stick, pick, lit, wrist, big.
12. `cmu:OW` — 52 pairs (END 7, INNER 45). Words: go, know, no, though, show, slow, throw, o.
13. `slant:IH:sib-stop` — 47 pairs (END 15, INNER 32). Words: bitch, shit, dick, nigga, niggas, sis, lit, city.
14. `slant:EH:stop` — 35 pairs (END 9, INNER 26). Words: get, ready, fetty, steady, better, let, check, step.
15. `slant:IH:liq-stop` — 35 pairs (END 1, INNER 34). Words: still, shit, mille, dick, kill, lil, pick, 'til.
16. `slant:AA:liq-stop` — 28 pairs (END 13, INNER 15). Words: car, afar, hard, star, r, fart, bought, got.
17. `slant:AA:nas-stop` — 28 pairs (END 1, INNER 27). Words: got, wanna, stop, want, echelon, poppin, bratchet, gotta.
18. `slant:AY:stop` — 28 pairs (END 4, INNER 24). Words: like, died, tight, starlight, lied, inside, rider, find.
19. `vow:AO` — 26 pairs (END 1, INNER 25). Words: sport, porsche, all, call, crossing, coffin, forth, boardin.
20. `slant:OW:nas-stop` — 25 pairs (END 0, INNER 25). Words: don't, gon, phone, won't, hope, homi, cologne, broke.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 24 pair sides, mostly spelling via spelling phonetic key, often with shit (6)
- gon — 23 pair sides, mostly spelling via spelling phonetic key, often with dont (13)
- peds — 9 pair sides, mostly vowel via spelling phonetic key, often with best (1)
- niggas — 8 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)
- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with bitch (3)
- tecs — 7 pair sides, mostly spelling via spelling phonetic key, often with mets (1)
- drac — 6 pair sides, mostly spelling via spelling phonetic key, often with half (1)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with real (1)
- imma — 5 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- bling — 5 pair sides, mostly spelling via spelling phonetic key, often with stoppin (1)
- bratchet — 5 pair sides, mostly cmu via vault phonetic_class, often with drop (1)
- wraith — 5 pair sides, mostly spelling via spelling phonetic key, often with paper (2)
- hol — 4 pair sides, mostly vowel via vault phonetic_class, often with bust (2)
- blicky — 4 pair sides, mostly vowel via spelling phonetic key, often with t (1)
- bap — 4 pair sides, mostly spelling via spelling phonetic key, often with half (1)
- shawty — 4 pair sides, mostly spelling via spelling phonetic key, often with small (1)
- juvie — 3 pair sides, mostly spelling via spelling phonetic key, often with young (1)
- finna — 3 pair sides, mostly vowel via spelling phonetic key, often with ima (1)
- bronem — 3 pair sides, mostly spelling via spelling phonetic key, often with over (1)
- foenem — 3 pair sides, mostly spelling via spelling phonetic key, often with over (1)
- trapathon — 3 pair sides, mostly spelling via spelling phonetic key, often with triathlon (1)
- piguet — 2 pair sides, mostly spelling via spelling phonetic key, often with digging (1)
- hublot — 2 pair sides, mostly spelling via spelling phonetic key, often with not (1)
- boujee — 2 pair sides, mostly spelling via spelling phonetic key, often with down (1)
- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with screamin (1)
- phlavz — 2 pair sides, mostly vowel via spelling phonetic key, often with drac (1)
- baddest — 2 pair sides, mostly spelling via spelling phonetic key, often with biggest (2)
- kanye — 2 pair sides, mostly spelling via spelling phonetic key, often with gang (1)
- homi — 1 pair sides, mostly spelling via spelling phonetic key, often with hope (1)
- amcs — 1 pair sides, mostly vowel via spelling phonetic key, often with catch (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Khaled | Down for Life | 70 | 40 | 242 | loose |
| DJ Khaled | IT AIN’T SAFE | 40 | 43 | 363 | loose |
| DJ Khaled | Iced Out My Arms | 72 | 99 | 272 | loose |
| DJ Khaled | KEEP GOING | 48 | 42 | 277 | loose |
| DJ Khaled | LET IT GO | 33 | 36 | 237 | loose |
| DJ Khaled | Pick These Hoes Apart | 59 | 80 | 244 | loose |
| DJ Khaled | Pull a Caper | 39 | 25 | 174 | loose |
| DJ Khaled | WAY PAST LUCK | 37 | 60 | 153 | loose |
| DJ Khaled | Wish Wish | 39 | 46 | 347 | loose |
