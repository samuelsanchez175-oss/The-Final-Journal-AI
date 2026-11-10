# Cardi B rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Cardi B
- Songs: 222
- Bars kept (Cardi B lyric lines): 8459
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 17
- Canonical name: Cardi B.
- Credit strings: Cardi B.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 47706
- REPEAT pairs, recorded separately: 7259
- END rhymes: 6996
- INNER rhymes: 40710

By match:

- PERFECT: 4611 (END 1102, INNER 3509)
- SLANT: 20987 (END 3063, INNER 17924)
- ASSONANCE: 21496 (END 2628, INNER 18868)
- MULTI: 612 (END 203, INNER 409)

By confidence:

- HIGH: 4502
- MED: 38426
- LOW: 4778

## Core

- Core Y: 45847
- Core N among rhyme pairs: 1859

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 22113 (46.4%)
- vowel: 21496 (45.1%)
- spelling: 3485 (7.3%)
- multi: 612 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- ABCB: 1 songs
- loose: 220 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 3625 pairs (END 333, INNER 3292). Words: don't, know, no, hoes, go, como, told, lo.
2. `vow:IH` — 3535 pairs (END 405, INNER 3130). Words: bitches, bitch, shit, think, little, really, give, him.
3. `vow:EH` — 2500 pairs (END 239, INNER 2261). Words: get, when, never, getting, best, said, gettin, tell.
4. `vow:EY` — 2059 pairs (END 279, INNER 1780). Words: ain't, say, make, way, baby, take, play, day.
5. `vow:AA` — 2029 pairs (END 225, INNER 1804). Words: got, want, la, talkin, not, poppin, wanna, hard.
6. `vow:AE` — 1743 pairs (END 198, INNER 1545). Words: can't, ass, back, had, have, bad, can, actin.
7. `vow:IY` — 1694 pairs (END 195, INNER 1499). Words: see, even, these, need, b, de, keep, here.
8. `vow:AH` — 1483 pairs (END 211, INNER 1272). Words: fuck, some, what, love, fuckin, money, fucking, somethin.
9. `vow:AY` — 1415 pairs (END 252, INNER 1163). Words: like, why, time, diamonds, y, find, by, buy.
10. `slant:AA:stop` — 1054 pairs (END 106, INNER 948). Words: got, not, gotta, want, body, cardi, pop, top.
11. `slant:IH:stop` — 906 pairs (END 118, INNER 788). Words: nigga, shit, hit, dick, big, city, lit, pretty.
12. `slant:IH:sib-stop` — 849 pairs (END 163, INNER 686). Words: bitch, shit, dick, nigga, niggas, hit, big, lit.
13. `slant:EH:stop` — 657 pairs (END 103, INNER 554). Words: get, let, said, check, better, wet, head, neck.
14. `slant:AH:nas-stop` — 631 pairs (END 37, INNER 594). Words: fuck, money, some, what, come, one, run, fuckin.
15. `cmu:OW` — 600 pairs (END 103, INNER 497). Words: know, no, go, show, though, ho, lo, blow.
16. `cmu:IY` — 580 pairs (END 13, INNER 567). Words: de, te, t, mi, e, c, ti, d.
17. `slant:AE:stop` — 550 pairs (END 100, INNER 450). Words: back, bag, bad, can't, mad, had, fact, fat.
18. `slant:EH:liq-stop` — 544 pairs (END 27, INNER 517). Words: get, tell, let, where, swear, said, there, check.
19. `slant:EH:nas-stop` — 473 pairs (END 18, INNER 455). Words: when, get, let, again, m, gettin, wet, better.
20. `vow:UW` — 458 pairs (END 110, INNER 348). Words: who, new, que, two, used, music, una, move.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 410 pair sides, mostly spelling via spelling phonetic key, often with shit (104)
- gon — 225 pair sides, mostly spelling via spelling phonetic key, often with hoes (59)
- ima — 194 pair sides, mostly spelling via spelling phonetic key, often with bitch (41)
- niggas — 130 pair sides, mostly spelling via spelling phonetic key, often with nigga (63)
- cardi — 121 pair sides, mostly spelling via spelling phonetic key, often with party (10)
- tryna — 97 pair sides, mostly spelling via spelling phonetic key, often with hear (9)
- quiero — 95 pair sides, mostly vowel via spelling phonetic key, often with no (12)
- cuando — 95 pair sides, mostly vowel via spelling phonetic key, often with no (8)
- tengo — 82 pair sides, mostly vowel via spelling phonetic key, often with el (10)
- eso — 69 pair sides, mostly spelling via spelling phonetic key, often with ella (8)
- leche — 56 pair sides, mostly spelling via spelling phonetic key, often with ella (8)
- mwen — 50 pair sides, mostly spelling via spelling phonetic key, often with bizwen (9)
- tanto — 40 pair sides, mostly vowel via spelling phonetic key, often with no (4)
- dem — 39 pair sides, mostly spelling via spelling phonetic key, often with deh (7)
- biffy — 39 pair sides, mostly spelling via spelling phonetic key, often with biff (16)
- beb — 37 pair sides, mostly spelling via spelling phonetic key, often with leche (6)
- bardi — 37 pair sides, mostly spelling via spelling phonetic key, often with body (14)
- papi — 36 pair sides, mostly spelling via spelling phonetic key, often with mami (13)
- cuerpo — 35 pair sides, mostly vowel via spelling phonetic key, often with como (3)
- wraith — 34 pair sides, mostly spelling via spelling phonetic key, often with aint (6)
- otro — 33 pair sides, mostly vowel via spelling phonetic key, often with mo (3)
- guap — 29 pair sides, mostly spelling via spelling phonetic key, often with some (16)
- mami — 29 pair sides, mostly spelling via spelling phonetic key, often with papi (13)
- culo — 28 pair sides, mostly vowel via spelling phonetic key, often with como (3)
- eche — 28 pair sides, mostly spelling via spelling phonetic key, often with ella (4)
- hago — 27 pair sides, mostly vowel via spelling phonetic key, often with quiero (4)
- swag — 27 pair sides, mostly spelling via spelling phonetic key, often with bag (9)
- menea — 26 pair sides, mostly spelling via spelling phonetic key, often with ella (4)
- acuerdo — 25 pair sides, mostly vowel via spelling phonetic key, often with mo (4)
- bros — 24 pair sides, mostly spelling via spelling phonetic key, often with hoes (3)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Cardi B | 11/18/19 Freestyle | 21 | 33 | 138 | loose |
| Cardi B | 31 contributors | 53 | 70 | 266 | loose |
| Cardi B | A Job Is A Job | 93 | 65 | 510 | loose |
| Cardi B | AH HA | 49 | 31 | 250 | loose |
| Cardi B | ASS | 46 | 32 | 137 | loose |
| Cardi B | Ahora Dice (Real Hasta La Muerte Remix) | 87 | 93 | 596 | loose |
| Cardi B | Arrebenta* | 10 | 2 | 48 | loose |
| Cardi B | Atlanta | 26 | 12 | 399 | loose |
| Cardi B | Automatic | 29 | 34 | 173 | loose |
| Cardi B | B.O.N | 38 | 47 | 197 | loose |
| Cardi B | BIG PAPER | 41 | 58 | 343 | loose |
| Cardi B | BODAKCHEEBA | 45 | 22 | 78 | loose |
| Cardi B | Back It Up | 34 | 28 | 197 | loose |
| Cardi B | Back to the Crib | 52 | 39 | 119 | loose |
| Cardi B | Backin’ It Up | 50 | 42 | 264 | loose |
| Cardi B | Bardi Doll | 8 | 4 | 38 | loose |
| Cardi B | Bartier Cardi | 64 | 70 | 202 | loose |
| Cardi B | Be Careful | 51 | 30 | 248 | loose |
| Cardi B | Best Life | 67 | 73 | 455 | loose |
| Cardi B | Bet It | 50 | 71 | 322 | loose |
| Cardi B | Bet You Wanna | 34 | 39 | 112 | loose |
| Cardi B | Better Than You | 76 | 58 | 359 | loose |
| Cardi B | Bickenhead | 53 | 45 | 304 | loose |
| Cardi B | Big One* | 16 | 23 | 87 | loose |
| Cardi B | Bitter (Narration By Cardi B) | 64 | 37 | 283 | loose |
| Cardi B | Bodak Yellow (Remix) | 42 | 46 | 236 | loose |
| Cardi B | Boddega Baddie (Live From SNL) | 7 | 3 | 78 | loose |
| Cardi B | Bodega Baddie | 24 | 12 | 166 | loose |
| Cardi B | Bongos | 69 | 77 | 312 | loose |
| Cardi B | Boom Boom (Remix) | 59 | 63 | 178 | loose |
| Cardi B | Booty* | 20 | 8 | 95 | loose |
| Cardi B | Broke* | 22 | 14 | 80 | loose |
| Cardi B | Bronx Season | 50 | 51 | 299 | loose |
| Cardi B | Burn Up (Burn Away Remix) (Bonus Track) | 25 | 7 | 57 | loose |
| Cardi B | CHAMPAGNE ROSÉ | 44 | 41 | 95 | loose |
| Cardi B | CRASHOUT | 42 | 16 | 239 | loose |
| Cardi B | Cardi B Money REMIX (FIRE) | 25 | 14 | 93 | loose |
| Cardi B | Cardi Blade 2 / 145 BPM | 4 | 0 | 4 | loose |
| Cardi B | Cheap Ass Weave | 50 | 45 | 293 | loose |
| Cardi B | Check Please | 24 | 12 | 213 | loose |
| Cardi B | Clean it Up | 4 | 1 | 22 | loose |
| Cardi B | Clout | 68 | 85 | 207 | loose |
| Cardi B | Coronao Now (Remix) [Versión Original] | 23 | 24 | 87 | loose |
| Cardi B | Coronavirus | 8 | 0 | 4 | loose |
| Cardi B | Coupon (Remix) | 60 | 102 | 313 | loose |
| Cardi B | Cute (Remix) | 47 | 45 | 171 | loose |
| Cardi B | DESPECHÁ RMX | 41 | 28 | 229 | loose |
| Cardi B | DOUGIE?(lilnREMIX)ft.Cari | 22 | 18 | 108 | loose |
| Cardi B | Danielle’s Interlude | 18 | 7 | 115 | loose |
| Cardi B | Dead | 67 | 56 | 415 | loose |
| Cardi B | Diamonds* | 3 | 1 | 3 | loose |
| Cardi B | Dinero | 44 | 34 | 186 | loose |
| Cardi B | Do Me Dat Remix (Region Liberty Records / Atlantic Records) | 2 | 0 | 7 | loose |
| Cardi B | Don’t Do Too Much | 34 | 21 | 58 | loose |
| Cardi B | Don’t Stop | 36 | 39 | 155 | loose |
| Cardi B | Drip | 78 | 114 | 287 | loose |
| Cardi B | Earthquake* | 7 | 2 | 58 | loose |
| Cardi B | Enough (Miami) | 47 | 53 | 226 | loose |
| Cardi B | Enough (Miami) [Acapella] | 12 | 2 | 38 | loose |
| Cardi B | Enough (Miami) [Bronx Drill Mix] | 11 | 4 | 24 | loose |
| Cardi B | ErrTime | 32 | 48 | 197 | loose |
| Cardi B | Everything | 47 | 40 | 251 | loose |
| Cardi B | FLEXING BITCHES | 3 | 1 | 12 | loose |
| Cardi B | FREAKY | 45 | 31 | 213 | loose |
| Cardi B | Finesse (Remix) | 41 | 24 | 111 | loose |
| Cardi B | First Cypher Round | 35 | 39 | 164 | loose |
| Cardi B | Foreva | 39 | 48 | 221 | loose |
| Cardi B | Fuck Me Up | 8 | 1 | 0 | loose |
| Cardi B | GOSHA (Remix) | 21 | 11 | 85 | loose |
| Cardi B | Get Up 10 | 76 | 90 | 407 | loose |
| Cardi B | Gimme Head Too | 29 | 16 | 230 | loose |
| Cardi B | Girls | 36 | 13 | 70 | loose |
| Cardi B | Girls Like You (Remix) | 37 | 13 | 154 | loose |
| Cardi B | Gone Be There | 32 | 16 | 251 | loose |
| Cardi B | Got Me Fucked Up (Skit) | 13 | 3 | 44 | loose |
| Cardi B | Hands | 3 | 0 | 13 | loose |
| Cardi B | Heaven on My Mind | 35 | 16 | 62 | loose |
| Cardi B | Hectic | 39 | 34 | 211 | loose |
| Cardi B | Hello | 32 | 12 | 79 | loose |
| Cardi B | Her Perspective (Skit) | 17 | 3 | 133 | loose |
| Cardi B | Higher Love | 28 | 16 | 86 | loose |
| Cardi B | Hot Shit | 58 | 70 | 345 | loose |
| Cardi B | How I Do | 36 | 35 | 100 | loose |
| Cardi B | I Do | 38 | 17 | 158 | loose |
| Cardi B | I Gotta Hurt You | 24 | 7 | 17 | loose |
| Cardi B | I Just Wanna Know | 57 | 72 | 257 | loose |
| Cardi B | I Like It | 70 | 51 | 441 | loose |
| Cardi B | I Needa Hard Hitta (Cardi B Sample) | 37 | 28 | 119 | loose |
| Cardi B | Imaginary Playerz | 67 | 61 | 330 | loose |
| Cardi B | Intro (Skit) | 7 | 0 | 13 | loose |
| Cardi B | Intro / Cardi B Interlude | 39 | 21 | 234 | loose |
| Cardi B | Intro Baile Funk (Ao Vivo) | 11 | 2 | 32 | loose |
| Cardi B | Invasion of Privacy (Song for Kulture’s 1st Birthday) | 20 | 15 | 114 | loose |
| Cardi B | Island Girls | 50 | 16 | 177 | loose |
| Cardi B | JEALOUSY | 79 | 94 | 351 | loose |
| Cardi B | Just | 21 | 7 | 21 | loose |
| Cardi B | Kamasutra | 45 | 54 | 216 | loose |
| Cardi B | Killin You Hoes | 59 | 44 | 352 | loose |
| Cardi B | Kissing me | 55 | 52 | 237 | loose |
| Cardi B | Kitty Kat Queen | 30 | 22 | 191 | loose |
| Cardi B | Know the difference | 56 | 40 | 350 | loose |
| Cardi B | La Bebé (Remix) | 69 | 59 | 867 | loose |
| Cardi B | La Bebé Remix (Reggaetón Version) | 4 | 0 | 25 | loose |
| Cardi B | La Modelo | 28 | 13 | 200 | loose |
| Cardi B | Last Christmas (Cardi B’s Version) | 4 | 1 | 15 | loose |
| Cardi B | Leave That Bitch Alone | 48 | 22 | 125 | loose |
| Cardi B | Lick | 49 | 50 | 120 | loose |
| Cardi B | Life could b sweet! | 53 | 36 | 177 | loose |
| Cardi B | Like What (Freestyle) | 49 | 36 | 261 | loose |
| Cardi B | Lit Thot | 32 | 38 | 146 | loose |
| Cardi B | Look at Me | 51 | 55 | 122 | loose |
| Cardi B | Mad* | 5 | 3 | 26 | ABCB |
| Cardi B | Magnet | 44 | 6 | 322 | loose |
| Cardi B | Man Of Lazy Days | 10 | 4 | 88 | loose |
| Cardi B | Man Of Your Word | 38 | 37 | 220 | loose |
| Cardi B | Me Gusta | 35 | 10 | 228 | loose |
| Cardi B | Mi Mami | 25 | 7 | 298 | loose |
| Cardi B | Money | 56 | 43 | 204 | loose |
| Cardi B | Money Bag | 34 | 27 | 185 | loose |
| Cardi B | Money Mwaka | 41 | 20 | 231 | loose |
| Cardi B | Moon | 30 | 19 | 124 | loose |
| Cardi B | MotorSport | 98 | 114 | 392 | loose |
| Cardi B | Munch (Feelin’ U) (Remix) | 20 | 18 | 104 | loose |
| Cardi B | Nagito Wap | 17 | 8 | 50 | loose |
| Cardi B | Name it | 5 | 2 | 18 | loose |
| Cardi B | Never Give Up | 31 | 18 | 73 | loose |
| Cardi B | Never Lose Me (SZA & Cardi B Remix) | 55 | 70 | 211 | loose |
| Cardi B | New Rules X Burn X Bodak Yellow | 35 | 18 | 167 | loose |
| Cardi B | Nice Guy | 43 | 42 | 190 | loose |
| Cardi B | Nihmussy | 22 | 8 | 104 | loose |
| Cardi B | No Limit | 49 | 55 | 315 | loose |
| Cardi B | No Limit Remix (Video Version) | 89 | 97 | 419 | loose |
| Cardi B | No Love (Extended) | 51 | 32 | 189 | loose |
| Cardi B | No One in The World | 27 | 15 | 91 | loose |
| Cardi B | Nobody* | 11 | 5 | 47 | loose |
| Cardi B | Not My Fault | 12 | 28 | 85 | AAAA |
| Cardi B | On Dat Money | 43 | 38 | 191 | loose |
| Cardi B | On Fleek | 30 | 28 | 83 | loose |
| Cardi B | On Me | 61 | 65 | 271 | loose |
| Cardi B | On My Back | 35 | 18 | 106 | loose |
| Cardi B | On The News | 56 | 29 | 310 | loose |
| Cardi B | Outro (Skit) | 4 | 0 | 15 | loose |
| Cardi B | Outside | 58 | 24 | 309 | loose |
| Cardi B | PUT EM IN THE FRIDGE | 33 | 27 | 382 | loose |
| Cardi B | Patek (Remix) | 6 | 1 | 32 | loose |
| Cardi B | Pick It Up | 33 | 29 | 152 | loose |
| Cardi B | Please Me | 31 | 13 | 89 | loose |
| Cardi B | Pocket | 45 | 36 | 128 | loose |
| Cardi B | Point Me 2 | 52 | 31 | 401 | loose |
| Cardi B | Pop Off | 56 | 56 | 280 | loose |
| Cardi B | Poppin’* | 23 | 14 | 90 | loose |
| Cardi B | Press | 50 | 101 | 187 | loose |
| Cardi B | Pretty & Petty | 59 | 34 | 221 | loose |
| Cardi B | Principal | 29 | 16 | 169 | loose |
| Cardi B | Pull Up | 58 | 54 | 249 | loose |
| Cardi B | Puntería | 33 | 17 | 277 | loose |
| Cardi B | Put It On Da Floor Again | 49 | 43 | 318 | loose |
| Cardi B | Put It On Da Floor Again [Mixed] | 4 | 1 | 20 | loose |
| Cardi B | Put It On Da Floor Remix | 37 | 61 | 341 | loose |
| Cardi B | Red Barz | 41 | 71 | 343 | loose |
| Cardi B | Resep Rendang Daging Sapi, Menu Lebaran Spesial Tahun Ini | 3 | 1 | 6 | loose |
| Cardi B | Respect* | 20 | 14 | 60 | loose |
| Cardi B | Right Now | 62 | 64 | 234 | loose |
| Cardi B | Ring | 37 | 19 | 181 | loose |
| Cardi B | Rodeo | 25 | 20 | 129 | loose |
| Cardi B | Rollin | 35 | 21 | 116 | loose |
| Cardi B | Rumors | 53 | 45 | 137 | loose |
| Cardi B | STANCE PLAYAZ | 12 | 7 | 57 | loose |
| Cardi B | Safe | 34 | 19 | 162 | loose |
| Cardi B | Salute | 50 | 53 | 193 | loose |
| Cardi B | Sauce Boyz | 22 | 20 | 114 | loose |
| Cardi B | Selfish | 31 | 17 | 85 | loose |
| Cardi B | Shake It | 53 | 47 | 176 | loose |
| Cardi B | She Bad | 50 | 41 | 257 | loose |
| Cardi B | She a Bad One (Remix) | 48 | 32 | 213 | loose |
| Cardi B | Shower Tears | 40 | 38 | 240 | loose |
| Cardi B | Sick 16 (Freestyle) | 70 | 63 | 273 | loose |
| Cardi B | South of the Border | 49 | 37 | 173 | loose |
| Cardi B | Stefania (Version Eurovision 2023) | 17 | 12 | 25 | loose |
| Cardi B | Stripper Hoe | 41 | 78 | 242 | loose |
| Cardi B | Stylin’ | 44 | 24 | 210 | loose |
| Cardi B | Super Bowl LIV Halftime Show | 140 | 58 | 474 | loose |
| Cardi B | Taki Taki | 41 | 38 | 278 | loose |
| Cardi B | The Good | 30 | 8 | 84 | loose |
| Cardi B | The Gopuff Quartertime Show | 19 | 7 | 68 | loose |
| Cardi B | The Seaweed Sway | 17 | 18 | 55 | loose |
| Cardi B | Thotiana (Cardi B Remix) | 54 | 25 | 221 | loose |
| Cardi B | Thru Your Phone | 40 | 27 | 162 | loose |
| Cardi B | Titty Renovation. | 23 | 13 | 36 | loose |
| Cardi B | Tomorrow 2 | 54 | 29 | 442 | loose |
| Cardi B | Toot It Up | 31 | 16 | 161 | loose |
| Cardi B | Trick | 25 | 2 | 205 | loose |
| Cardi B | Trophies | 52 | 19 | 304 | loose |
| Cardi B | Trust Issues | 35 | 44 | 156 | loose |
| Cardi B | Twerk | 40 | 31 | 259 | loose |
| Cardi B | Type Shit | 59 | 79 | 371 | loose |
| Cardi B | UP CARDI B FREESTYLE | 25 | 26 | 80 | loose |
| Cardi B | Um Yea | 50 | 80 | 324 | loose |
| Cardi B | Up | 35 | 40 | 220 | loose |
| Cardi B | Up / WAP (Live at the 63rd Grammy Awards) | 51 | 21 | 160 | loose |
| Cardi B | WAB (Wet As Biffy) | 48 | 34 | 274 | loose |
| Cardi B | WAP | 65 | 59 | 361 | loose |
| Cardi B | WAP Freemix | 18 | 5 | 49 | loose |
| Cardi B | Wanna Be (Remix) | 79 | 63 | 366 | loose |
| Cardi B | Want My Love Back | 37 | 27 | 103 | loose |
| Cardi B | Washpoppin | 31 | 15 | 144 | loose |
| Cardi B | Welcome to the Bronx (Skit) | 4 | 1 | 13 | loose |
| Cardi B | Wet* | 13 | 16 | 61 | loose |
| Cardi B | What A Girl Likes | 23 | 23 | 104 | loose |
| Cardi B | What The Deal Is? | 26 | 17 | 160 | loose |
| Cardi B | What’s Goin On | 46 | 43 | 150 | loose |
| Cardi B | Where You At | 20 | 10 | 14 | loose |
| Cardi B | Who Want the Smoke? | 61 | 71 | 262 | loose |
| Cardi B | Wild Side | 49 | 35 | 149 | loose |
| Cardi B | Wish Wish | 40 | 46 | 348 | loose |
| Cardi B | With That | 35 | 53 | 191 | loose |
| Cardi B | Workin | 18 | 5 | 46 | loose |
| Cardi B | Writing on the Wall | 45 | 24 | 272 | loose |
| Cardi B | YES | 50 | 31 | 225 | loose |
| Cardi B | dead to me | 46 | 16 | 97 | loose |
| Cardi B | fairytale | 48 | 22 | 172 | loose |
| Cardi B | something for the world (Second Anniversary Edition) | 41 | 18 | 78 | loose |
