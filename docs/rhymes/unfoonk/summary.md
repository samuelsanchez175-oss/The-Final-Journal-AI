# Unfoonk rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Unfoonk
- Songs: 36
- Bars kept (Unfoonk lyric lines): 1302
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 3
- Canonical name: Unfoonk.
- Credit strings: Unfoonk.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 8200
- REPEAT pairs, recorded separately: 782
- END rhymes: 1126
- INNER rhymes: 7074

By match:

- PERFECT: 581 (END 161, INNER 420)
- SLANT: 3556 (END 414, INNER 3142)
- ASSONANCE: 3996 (END 529, INNER 3467)
- MULTI: 67 (END 22, INNER 45)

By confidence:

- HIGH: 586
- MED: 7132
- LOW: 482

## Core

- Core Y: 8105
- Core N among rhyme pairs: 95

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 3687 (45.0%)
- vowel: 3996 (48.7%)
- spelling: 450 (5.5%)
- multi: 67 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 36 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 620 pairs (END 54, INNER 566). Words: shit, different, bitches, bitch, hit, didn't, think, him.
2. `vow:EH` — 578 pairs (END 77, INNER 501). Words: went, get, tell, when, every, gettin, second, said.
3. `vow:EY` — 483 pairs (END 60, INNER 423). Words: ain't, say, baby, way, play, everyday, stay, came.
4. `vow:OW` — 422 pairs (END 41, INNER 381). Words: don't, know, no, told, go, broke, don’t, won't.
5. `vow:AA` — 405 pairs (END 36, INNER 369). Words: got, want, nothin, hard, fox, gotta, heart, mob.
6. `vow:AY` — 349 pairs (END 86, INNER 263). Words: like, die, slime, why, right, lie, ridin, try.
7. `vow:AE` — 331 pairs (END 65, INNER 266). Words: can't, back, family, had, can, havin, bag, ass.
8. `vow:AH` — 302 pairs (END 33, INNER 269). Words: some, one, hundred, fuck, love, number, money, brothers.
9. `vow:IY` — 253 pairs (END 27, INNER 226). Words: see, even, these, real, keep, need, streets, b.
10. `slant:AA:stop` — 239 pairs (END 14, INNER 225). Words: got, gotta, god, want, mob, block, heart, lot.
11. `slant:IH:stop` — 158 pairs (END 10, INNER 148). Words: nigga, shit, big, hit, bigger, city, ticket, stick.
12. `slant:AE:stop` — 110 pairs (END 24, INNER 86). Words: back, had, bag, can't, whacked, crack, trap, rat.
13. `vow:AW` — 101 pairs (END 18, INNER 83). Words: now, how, down, 'bout, thousand, around, clout, round.
14. `slant:EH:liq-stop` — 97 pairs (END 6, INNER 91). Words: tell, get, let, said, scary, very, buried, check.
15. `slant:AA:nas-stop` — 95 pairs (END 5, INNER 90). Words: wanna, got, mama, mob, momma, god, sharpen, block.
16. `slant:EH:stop` — 94 pairs (END 13, INNER 81). Words: get, check, said, went, better, let, left, jet.
17. `slant:EH:nas-stop` — 91 pairs (END 3, INNER 88). Words: when, get, said, went, again, check, any, many.
18. `vow:AO` — 85 pairs (END 21, INNER 64). Words: all, talking, talk, cross, mornin, lost, walked, call.
19. `slant:AH:nas-stop` — 84 pairs (END 2, INNER 82). Words: fuck, what, some, money, done, one, come, young.
20. `slant:IH:liq-stop` — 84 pairs (END 3, INNER 81). Words: really, shit, lil, big, still, hit, mil, bigger.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 119 pair sides, mostly spelling via spelling phonetic key, often with shit (28)
- niggas — 54 pair sides, mostly spelling via spelling phonetic key, often with nigga (27)
- tryna — 35 pair sides, mostly spelling via spelling phonetic key, often with feel (5)
- ima — 28 pair sides, mostly spelling via spelling phonetic key, often with shit (7)
- gon — 21 pair sides, mostly spelling via spelling phonetic key, often with dont (8)
- opps — 13 pair sides, mostly vowel via spelling phonetic key, often with know (4)
- dolo — 10 pair sides, mostly vowel via spelling phonetic key, often with solo (2)
- bruh — 9 pair sides, mostly spelling via spelling phonetic key, often with brother (3)
- dawg — 8 pair sides, mostly spelling via spelling phonetic key, often with outlaw (1)
- slatt — 8 pair sides, mostly spelling via spelling phonetic key, often with back (3)
- bap — 7 pair sides, mostly spelling via spelling phonetic key, often with trap (2)
- slimes — 7 pair sides, mostly vowel via spelling phonetic key, often with ima (1)
- homie — 7 pair sides, mostly spelling via spelling phonetic key, often with hogtied (2)
- raq — 6 pair sides, mostly spelling via spelling phonetic key, often with back (2)
- glizzy — 6 pair sides, mostly spelling via spelling phonetic key, often with close (1)
- thot — 6 pair sides, mostly spelling via spelling phonetic key, often with spot (1)
- icey — 6 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- apeshit — 5 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- lyin — 5 pair sides, mostly spelling via spelling phonetic key, often with real (1)
- hittas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- benji — 5 pair sides, mostly spelling via spelling phonetic key, often with benz (1)
- triller — 5 pair sides, mostly spelling via spelling phonetic key, often with lil (2)
- celly — 5 pair sides, mostly vowel via spelling phonetic key, often with jelly (1)
- numero — 5 pair sides, mostly vowel via spelling phonetic key, often with some (1)
- payed — 5 pair sides, mostly spelling via spelling phonetic key, often with face (2)
- youngin — 4 pair sides, mostly spelling via spelling phonetic key, often with bean (1)
- reon — 4 pair sides, mostly spelling via spelling phonetic key, often with wet (1)
- killas — 4 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- snafae — 4 pair sides, mostly spelling via spelling phonetic key, often with after (1)
- throu — 4 pair sides, mostly vowel via spelling phonetic key, often with now (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Unfoonk | 3rd Eye | 36 | 52 | 170 | loose |
| Unfoonk | 911 | 42 | 42 | 211 | loose |
| Unfoonk | Another Bloody Summer | 45 | 31 | 164 | loose |
| Unfoonk | Ape Shit | 34 | 50 | 242 | loose |
| Unfoonk | Bait Em In | 30 | 15 | 139 | loose |
| Unfoonk | DEA | 36 | 25 | 263 | loose |
| Unfoonk | Everyday (2020)* | 22 | 23 | 151 | loose |
| Unfoonk | Goyard Bag | 1 | 0 | 0 | loose |
| Unfoonk | Hit Different | 40 | 53 | 329 | loose |
| Unfoonk | Hoop Dreams | 38 | 31 | 227 | loose |
| Unfoonk | I Had | 49 | 41 | 280 | loose |
| Unfoonk | LA (Astrology)* | 10 | 5 | 24 | loose |
| Unfoonk | Make You Better | 30 | 21 | 116 | loose |
| Unfoonk | Mind Right (Interlude) | 27 | 17 | 195 | loose |
| Unfoonk | Mob Ties | 37 | 53 | 202 | loose |
| Unfoonk | Mob Ties Remix | 57 | 51 | 351 | loose |
| Unfoonk | Monsta | 35 | 25 | 131 | loose |
| Unfoonk | My Pain | 55 | 29 | 412 | loose |
| Unfoonk | Need Prescription (Original) | 27 | 42 | 144 | loose |
| Unfoonk | Never Going Back | 44 | 36 | 232 | loose |
| Unfoonk | Private | 20 | 15 | 82 | loose |
| Unfoonk | Real | 36 | 29 | 129 | loose |
| Unfoonk | Running Out of Patience | 40 | 20 | 291 | loose |
| Unfoonk | Russian Roulette | 30 | 22 | 94 | loose |
| Unfoonk | Silent | 33 | 30 | 196 | loose |
| Unfoonk | Smoke N Mirrors | 42 | 29 | 188 | loose |
| Unfoonk | So Slime | 106 | 110 | 534 | loose |
| Unfoonk | Streets Don’t Love Nobody | 37 | 44 | 207 | loose |
| Unfoonk | Take a Trip | 62 | 57 | 305 | loose |
| Unfoonk | Temperature | 23 | 9 | 160 | loose |
| Unfoonk | The Truth | 39 | 38 | 257 | loose |
| Unfoonk | Thinkin’ About Eternity* | 41 | 22 | 235 | loose |
| Unfoonk | Trial | 20 | 8 | 95 | loose |
| Unfoonk | Unsafe | 22 | 25 | 54 | loose |
| Unfoonk | What It Do | 31 | 12 | 159 | loose |
| Unfoonk | Wheezy | 25 | 14 | 105 | loose |
