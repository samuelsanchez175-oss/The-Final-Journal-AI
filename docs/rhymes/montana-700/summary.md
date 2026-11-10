# Montana 700 rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Montana 700
- Songs: 55
- Bars kept (Montana 700 lyric lines): 2016
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Montana 700.
- Credit strings: Montana 700.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 16508
- REPEAT pairs, recorded separately: 1738
- END rhymes: 2360
- INNER rhymes: 14148

By match:

- PERFECT: 1332 (END 469, INNER 863)
- SLANT: 7473 (END 1122, INNER 6351)
- ASSONANCE: 7635 (END 738, INNER 6897)
- MULTI: 68 (END 31, INNER 37)

By confidence:

- HIGH: 1346
- MED: 14101
- LOW: 1061

## Core

- Core Y: 16402
- Core N among rhyme pairs: 106

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 7787 (47.2%)
- vowel: 7635 (46.3%)
- spelling: 1018 (6.2%)
- multi: 68 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 55 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 1278 pairs (END 93, INNER 1185). Words: ain't, say, day, came, make, way, change, made.
2. `vow:IH` — 1168 pairs (END 114, INNER 1054). Words: shit, still, thinkin, million, him, business, lil, bitch.
3. `vow:OW` — 1155 pairs (END 120, INNER 1035). Words: know, don't, no, go, bro, told, only, sold.
4. `vow:AH` — 923 pairs (END 133, INNER 790). Words: hundred, money, love, somethin, one, what, fuckin, fuck.
5. `vow:EH` — 795 pairs (END 52, INNER 743). Words: get, every, when, never, gettin, send, went, spend.
6. `vow:AE` — 660 pairs (END 33, INNER 627). Words: can't, trap, back, last, ask, can, rap, dallas.
7. `vow:AA` — 439 pairs (END 51, INNER 388). Words: talkin, got, nothin, hard, started, gotta, boss, cost.
8. `vow:IY` — 421 pairs (END 48, INNER 373). Words: see, streets, even, these, real, keep, d, three.
9. `slant:IH:stop` — 420 pairs (END 50, INNER 370). Words: nigga, shit, city, big, ticket, hit, quick, fifty.
10. `vow:AY` — 354 pairs (END 53, INNER 301). Words: like, time, why, ridin, right, buy, i'll, by.
11. `slant:EY:nas-stop` — 264 pairs (END 14, INNER 250). Words: ain't, made, came, game, take, make, same, name.
12. `slant:AE:stop` — 258 pairs (END 44, INNER 214). Words: back, trap, rap, had, can't, bag, flat, bad.
13. `slant:AA:stop` — 241 pairs (END 37, INNER 204). Words: got, gotta, want, pop, everybody, block, not, drop.
14. `slant:AH:nas-stop` — 238 pairs (END 14, INNER 224). Words: money, fuck, what, plug, come, some, one, done.
15. `slant:EH:stop` — 232 pairs (END 18, INNER 214). Words: get, went, better, bread, said, scared, head, dead.
16. `cmu:OW` — 228 pairs (END 26, INNER 202). Words: no, know, go, bro, show, low, blow, slow.
17. `slant:EH:nas-stop` — 211 pairs (END 23, INNER 188). Words: when, get, ten, again, gettin, send, spend, better.
18. `slant:EY:stop` — 191 pairs (END 28, INNER 163). Words: ain't, made, make, take, baby, paid, hate, eight.
19. `slant:IH:sib-stop` — 186 pairs (END 30, INNER 156). Words: nigga, niggas, shit, bitch, rich, city, sit, hit.
20. `slant:AH:nas` — 173 pairs (END 22, INNER 151). Words: money, some, one, come, done, comin, run, fuckin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 384 pair sides, mostly spelling via spelling phonetic key, often with shit (122)
- tryna — 149 pair sides, mostly spelling via spelling phonetic key, often with these (22)
- niggas — 118 pair sides, mostly spelling via spelling phonetic key, often with nigga (82)
- gon — 113 pair sides, mostly spelling via spelling phonetic key, often with dont (19)
- ima — 77 pair sides, mostly spelling via spelling phonetic key, often with shit (10)
- finna — 33 pair sides, mostly vowel via spelling phonetic key, often with nigga (14)
- swole — 14 pair sides, mostly spelling via spelling phonetic key, often with sold (2)
- beezy — 14 pair sides, mostly spelling via spelling phonetic key, often with free (3)
- jeezy — 13 pair sides, mostly vowel via spelling phonetic key, often with money (4)
- migo — 12 pair sides, mostly spelling via spelling phonetic key, often with him (2)
- lyin — 10 pair sides, mostly spelling via spelling phonetic key, often with these (2)
- horry — 10 pair sides, mostly spelling via spelling phonetic key, often with story (4)
- lambo — 9 pair sides, mostly vowel via spelling phonetic key, often with bando (1)
- bogo — 9 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- whipin — 9 pair sides, mostly spelling via spelling phonetic key, often with nothin (2)
- doin — 8 pair sides, mostly spelling via spelling phonetic key, often with goin (5)
- phat — 8 pair sides, mostly spelling via spelling phonetic key, often with back (2)
- meeno — 8 pair sides, mostly spelling via spelling phonetic key, often with know (1)
- thrax — 7 pair sides, mostly spelling via spelling phonetic key, often with back (3)
- fedsll — 7 pair sides, mostly vowel via spelling phonetic key, often with sentence (4)
- wid — 6 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- unc — 6 pair sides, mostly spelling via spelling phonetic key, often with one (2)
- growed — 6 pair sides, mostly cmu via vault phonetic_class, often with done (3)
- kangoo — 6 pair sides, mostly spelling via spelling phonetic key, often with trap (2)
- runtz — 6 pair sides, mostly spelling via spelling phonetic key, often with months (3)
- clayco — 6 pair sides, mostly vowel via spelling phonetic key, often with go (1)
- bando — 5 pair sides, mostly vowel via spelling phonetic key, often with lambo (1)
- turnt — 5 pair sides, mostly cmu via vault phonetic_class, often with burnt (1)
- hunnit — 5 pair sides, mostly spelling via spelling phonetic key, often with jumpin (2)
- nem — 5 pair sides, mostly spelling via spelling phonetic key, often with when (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Montana 700 | (Intro) Open Thoughts | 54 | 58 | 359 | loose |
| Montana 700 | 2am in ATL | 48 | 73 | 357 | loose |
| Montana 700 | 5AM In Miami | 35 | 37 | 248 | loose |
| Montana 700 | 700 Loads | 27 | 14 | 254 | loose |
| Montana 700 | 8 Months In | 31 | 45 | 199 | loose |
| Montana 700 | Add It Up | 29 | 30 | 168 | loose |
| Montana 700 | Ain’t Good Enough | 28 | 24 | 216 | loose |
| Montana 700 | Back Door | 27 | 16 | 178 | loose |
| Montana 700 | Black Trucks | 30 | 34 | 195 | loose |
| Montana 700 | Booked Up | 35 | 31 | 230 | loose |
| Montana 700 | Boosie Flow | 35 | 52 | 207 | loose |
| Montana 700 | Brinks Truck | 40 | 51 | 217 | loose |
| Montana 700 | Call My Bluff | 37 | 33 | 255 | loose |
| Montana 700 | Camp Wisdom Baby | 42 | 68 | 361 | loose |
| Montana 700 | Chains On | 34 | 44 | 294 | loose |
| Montana 700 | Chance After Chance | 41 | 29 | 301 | loose |
| Montana 700 | Check Shit | 56 | 65 | 348 | loose |
| Montana 700 | Clientele | 46 | 51 | 275 | loose |
| Montana 700 | Count a Hunnit | 32 | 19 | 207 | loose |
| Montana 700 | Dirty Game | 32 | 63 | 281 | loose |
| Montana 700 | Dogshit | 40 | 61 | 231 | loose |
| Montana 700 | Foxx Flow | 38 | 51 | 443 | loose |
| Montana 700 | Free Duce | 51 | 48 | 340 | loose |
| Montana 700 | Getting Off | 26 | 35 | 181 | loose |
| Montana 700 | Give Me Strength | 47 | 65 | 385 | loose |
| Montana 700 | How I Came In | 38 | 41 | 289 | loose |
| Montana 700 | Independent | 51 | 51 | 443 | loose |
| Montana 700 | Intro | 44 | 37 | 239 | loose |
| Montana 700 | Intro “Born Hustla” | 43 | 37 | 356 | loose |
| Montana 700 | It’s My Birthday | 40 | 52 | 261 | loose |
| Montana 700 | Joy Road to Camp Wisdom | 34 | 31 | 334 | loose |
| Montana 700 | Junkie | 13 | 22 | 62 | loose |
| Montana 700 | Just Like Me | 33 | 30 | 211 | loose |
| Montana 700 | LL Da Wizard | 37 | 25 | 298 | loose |
| Montana 700 | Let’s Run It | 22 | 38 | 180 | loose |
| Montana 700 | Loyalty Is Real | 32 | 32 | 287 | loose |
| Montana 700 | Mama Detra *Incoming Call* | 14 | 3 | 48 | loose |
| Montana 700 | Million Dollar Run | 36 | 35 | 208 | loose |
| Montana 700 | Motion | 32 | 41 | 323 | loose |
| Montana 700 | On The Road | 36 | 40 | 230 | loose |
| Montana 700 | Pipeline | 21 | 22 | 115 | loose |
| Montana 700 | Pray | 41 | 53 | 275 | loose |
| Montana 700 | Rap & Trap | 22 | 51 | 138 | loose |
| Montana 700 | Real Love | 43 | 47 | 318 | loose |
| Montana 700 | Real Pain | 53 | 55 | 397 | loose |
| Montana 700 | Red Lights | 32 | 51 | 270 | loose |
| Montana 700 | Robert Horry | 54 | 75 | 352 | loose |
| Montana 700 | She Luv Dat | 30 | 28 | 158 | loose |
| Montana 700 | Thinking About Millions | 65 | 96 | 318 | loose |
| Montana 700 | Trap Ain’t Dead | 22 | 28 | 163 | loose |
| Montana 700 | Triple D | 54 | 89 | 354 | loose |
| Montana 700 | Walk With Me | 48 | 42 | 225 | loose |
| Montana 700 | White Ones | 24 | 29 | 144 | loose |
| Montana 700 | Whole Cliff | 31 | 60 | 222 | loose |
| Montana 700 | Wit a Boss | 30 | 22 | 200 | loose |
