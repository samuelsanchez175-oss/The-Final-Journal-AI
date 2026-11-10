# Young Stoner Life rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Young Stoner Life, Young Stoner Life & Gunna, Young Stoner Life & Young Thug, Young Stoner Life, Yak Gotti & Sheck Wes, Young Stoner Life, Young Thug & Gunna, Young Stoner Life, Young Thug & Meek Mill
- Songs: 544
- Bars kept (Young Stoner Life lyric lines): 23989
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 71. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: Explosion (6), Mack Truck (5), My City (Remix) (3), No Surprise (3), Paid the Fine (6), Pots N Pans (9), Proud of You (4), Really Be Slime (4), Ski (6), Slam the Door (4), Solid (6), Superstar (4), That Go! (6), Trance (2), Yessirskii (3)
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 44
- Canonical name: Young Stoner Life.
- Credit strings: Young Stoner Life; Young Stoner Life & Gunna; Young Stoner Life & Young Thug; Young Stoner Life, Yak Gotti & Sheck Wes; Young Stoner Life, Young Thug & Gunna; Young Stoner Life, Young Thug & Meek Mill.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 139607
- REPEAT pairs, recorded separately: 15793
- END rhymes: 27920
- INNER rhymes: 111687

By match:

- PERFECT: 11242 (END 3576, INNER 7666)
- SLANT: 60293 (END 11683, INNER 48610)
- ASSONANCE: 66767 (END 12224, INNER 54543)
- MULTI: 1305 (END 437, INNER 868)

By confidence:

- HIGH: 11663
- MED: 119715
- LOW: 8229

## Core

- Core Y: 137607
- Core N among rhyme pairs: 2000

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 64439 (46.2%)
- vowel: 66767 (47.8%)
- spelling: 7096 (5.1%)
- multi: 1305 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 5 songs
- loose: 539 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- Young Stoner Life & Young Thug | Came and Saw | 49 lyric lines
- Young Stoner Life & Young Thug | Moon Man | 34 lyric lines
- Young Stoner Life & Young Thug | My City (Remix) | 49 lyric lines
- Young Stoner Life & Young Thug | No Surprise | 43 lyric lines
- Young Stoner Life, Young Thug & Gunna | Paid the Fine | 61 lyric lines
- Young Stoner Life, Young Thug & Gunna | Ski | 33 lyric lines
- Young Stoner Life, Young Thug & Gunna | Slatty | 65 lyric lines
- Young Stoner Life | Trance | 27 lyric lines

## Top 20 families

1. `vow:IH` — 9803 pairs (END 1487, INNER 8316). Words: bitch, bitches, shit, think, wrist, lil, big, still.
2. `vow:OW` — 9139 pairs (END 1390, INNER 7749). Words: don't, know, no, go, told, ho, hoes, show.
3. `vow:EY` — 8222 pairs (END 1711, INNER 6511). Words: ain't, way, say, play, day, baby, take, make.
4. `vow:EH` — 7023 pairs (END 984, INNER 6039). Words: get, when, gettin, never, tell, went, left, every.
5. `vow:AE` — 6669 pairs (END 1490, INNER 5179). Words: can't, back, racks, had, can, bad, havin, bands.
6. `vow:AA` — 6451 pairs (END 917, INNER 5534). Words: got, want, nothin, talkin, not, hard, top, gotta.
7. `vow:AY` — 5352 pairs (END 1060, INNER 4292). Words: like, diamonds, high, time, why, by, try, right.
8. `vow:IY` — 5058 pairs (END 1208, INNER 3850). Words: see, these, even, need, keep, streets, three, shawty.
9. `vow:AH` — 4727 pairs (END 671, INNER 4056). Words: hundred, fuck, some, fuckin, love, money, one, fucked.
10. `slant:AA:stop` — 3613 pairs (END 324, INNER 3289). Words: got, gotta, want, not, top, block, pop, body.
11. `slant:IH:stop` — 2720 pairs (END 404, INNER 2316). Words: nigga, shit, big, hit, dick, stick, drip, city.
12. `slant:IH:sib-stop` — 2356 pairs (END 402, INNER 1954). Words: bitch, shit, nigga, niggas, rich, dick, hit, big.
13. `slant:AE:stop` — 1943 pairs (END 465, INNER 1478). Words: back, had, bag, can't, bad, slatt, trap, black.
14. `slant:EH:stop` — 1653 pairs (END 228, INNER 1425). Words: get, better, check, head, went, let, neck, said.
15. `cmu:OW` — 1631 pairs (END 213, INNER 1418). Words: know, no, go, ho, show, low, throw, bro.
16. `slant:AH:nas-stop` — 1546 pairs (END 83, INNER 1463). Words: fuck, some, what, money, come, one, done, young.
17. `vow:AO` — 1421 pairs (END 316, INNER 1105). Words: all, lost, call, walk, talking, foreign, talk, water.
18. `slant:AY:stop` — 1406 pairs (END 176, INNER 1230). Words: like, right, ride, might, inside, white, side, night.
19. `slant:IH:liq-stop` — 1386 pairs (END 94, INNER 1292). Words: lil, shit, still, hit, big, 'til, really, dick.
20. `slant:AH:nas` — 1352 pairs (END 127, INNER 1225). Words: money, some, young, one, come, done, fuckin, gunna.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 1287 pair sides, mostly spelling via spelling phonetic key, often with shit (273)
- ima — 772 pair sides, mostly spelling via spelling phonetic key, often with bitch (130)
- gon — 619 pair sides, mostly spelling via spelling phonetic key, often with dont (183)
- tryna — 475 pair sides, mostly spelling via spelling phonetic key, often with these (71)
- niggas — 406 pair sides, mostly spelling via spelling phonetic key, often with nigga (244)
- shawty — 259 pair sides, mostly vowel via spelling phonetic key, often with money (20)
- slatt — 145 pair sides, mostly spelling via spelling phonetic key, often with slatty (44)
- gunna — 137 pair sides, mostly spelling via spelling phonetic key, often with wunna (29)
- thot — 116 pair sides, mostly spelling via spelling phonetic key, often with got (18)
- bros — 80 pair sides, mostly spelling via spelling phonetic key, often with hoes (9)
- wunna — 79 pair sides, mostly spelling via spelling phonetic key, often with gunna (29)
- thugger — 74 pair sides, mostly spelling via spelling phonetic key, often with fuck (9)
- wraith — 73 pair sides, mostly spelling via spelling phonetic key, often with gate (8)
- swag — 72 pair sides, mostly spelling via spelling phonetic key, often with back (5)
- wheezy — 68 pair sides, mostly spelling via spelling phonetic key, often with need (4)
- geeked — 61 pair sides, mostly spelling via spelling phonetic key, often with these (8)
- slatty — 60 pair sides, mostly spelling via spelling phonetic key, often with slatt (44)
- lyin — 53 pair sides, mostly spelling via spelling phonetic key, often with these (6)
- dawg — 52 pair sides, mostly spelling via spelling phonetic key, often with all (14)
- birkin — 52 pair sides, mostly vowel via spelling phonetic key, often with bitch (15)
- homie — 50 pair sides, mostly spelling via spelling phonetic key, often with gon (11)
- opps — 46 pair sides, mostly vowel via spelling phonetic key, often with dont (18)
- keed — 44 pair sides, mostly spelling via spelling phonetic key, often with these (6)
- rari — 44 pair sides, mostly spelling via spelling phonetic key, often with bad (8)
- blicky — 37 pair sides, mostly spelling via spelling phonetic key, often with city (3)
- titty — 36 pair sides, mostly spelling via spelling phonetic key, often with city (8)
- slimes — 35 pair sides, mostly spelling via spelling phonetic key, often with him (5)
- jag — 35 pair sides, mostly spelling via spelling phonetic key, often with bag (3)
- finna — 34 pair sides, mostly spelling via spelling phonetic key, often with nigga (10)
- drac — 30 pair sides, mostly spelling via spelling phonetic key, often with can (4)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Young Stoner Life | $$$ (dollar sign) | 35 | 49 | 254 | loose |
| Young Stoner Life | 1 Diamond Missing | 42 | 47 | 184 | loose |
| Young Stoner Life | 10,000 Slimes | 60 | 54 | 221 | loose |
| Young Stoner Life | 100 Degrees | 34 | 51 | 189 | loose |
| Young Stoner Life | 150 | 24 | 25 | 86 | loose |
| Young Stoner Life | 2 Bitches (Danny Glover) | 48 | 53 | 264 | loose |
| Young Stoner Life | 2 Cups Stuffed | 26 | 19 | 121 | loose |
| Young Stoner Life | 200 | 43 | 28 | 156 | loose |
| Young Stoner Life | 200 FOR LUNCH | 46 | 110 | 210 | AAAA |
| Young Stoner Life | 25k jacket | 42 | 35 | 312 | loose |
| Young Stoner Life | 27 | 37 | 25 | 160 | loose |
| Young Stoner Life | 3 Headed Snake | 100 | 184 | 407 | loose |
| Young Stoner Life | 3 WISHES | 24 | 62 | 259 | loose |
| Young Stoner Life | 30 for 30 | 36 | 43 | 217 | loose |
| Young Stoner Life | 3rd Eye | 36 | 52 | 170 | loose |
| Young Stoner Life | 3roken Soul | 32 | 62 | 233 | loose |
| Young Stoner Life | 4 da Gang | 54 | 69 | 307 | loose |
| Young Stoner Life | 600 Days No Sleep | 27 | 15 | 156 | loose |
| Young Stoner Life | 730 | 42 | 34 | 250 | loose |
| Young Stoner Life | 808s. | 53 | 53 | 213 | loose |
| Young Stoner Life | 911 | 33 | 35 | 262 | loose |
| Young Stoner Life | A$$ | 45 | 64 | 175 | loose |
| Young Stoner Life | ADDYS | 43 | 29 | 234 | loose |
| Young Stoner Life | ALL STARS | 52 | 67 | 366 | loose |
| Young Stoner Life | ALMIGHTY DØLLA | 29 | 52 | 184 | loose |
| Young Stoner Life | ARGENTINA | 19 | 19 | 237 | loose |
| Young Stoner Life | ATM | 27 | 18 | 149 | loose |
| Young Stoner Life | About The Money | 58 | 38 | 327 | loose |
| Young Stoner Life | Abracadabra | 43 | 51 | 222 | loose |
| Young Stoner Life | Accident | 27 | 34 | 214 | loose |
| Young Stoner Life | Add a Lil Drip | 23 | 17 | 102 | loose |
| Young Stoner Life | Admit It | 64 | 107 | 262 | loose |
| Young Stoner Life | Again | 48 | 25 | 200 | loose |
| Young Stoner Life | Ain’t Livin Right | 55 | 68 | 166 | loose |
| Young Stoner Life | Ain’t Seen My Face | 54 | 115 | 189 | loose |
| Young Stoner Life | Ain’t Trippin | 38 | 42 | 122 | loose |
| Young Stoner Life | All By My Lonely | 62 | 92 | 272 | loose |
| Young Stoner Life | All Day | 45 | 61 | 296 | loose |
| Young Stoner Life | All I Know | 34 | 96 | 242 | loose |
| Young Stoner Life | All I Wanna Know | 57 | 34 | 226 | loose |
| Young Stoner Life | All Night | 55 | 95 | 262 | loose |
| Young Stoner Life | All Star | 24 | 41 | 290 | loose |
| Young Stoner Life | All Your Time | 35 | 47 | 149 | loose |
| Young Stoner Life | All da Smoke | 54 | 46 | 214 | loose |
| Young Stoner Life | All of it | 57 | 68 | 244 | loose |
| Young Stoner Life | Almighty | 40 | 66 | 247 | loose |
| Young Stoner Life | Alone | 71 | 103 | 181 | loose |
| Young Stoner Life | Alphabet Boys | 24 | 27 | 114 | loose |
| Young Stoner Life | Amazing | 70 | 72 | 297 | loose |
| Young Stoner Life | Animal | 39 | 17 | 97 | loose |
| Young Stoner Life | Another Wave | 54 | 75 | 146 | loose |
| Young Stoner Life | Anybody | 54 | 35 | 194 | loose |
| Young Stoner Life | Ape Shit | 33 | 50 | 242 | loose |
| Young Stoner Life | At The Hotel | 82 | 151 | 252 | loose |
| Young Stoner Life | At the Spot | 36 | 24 | 278 | loose |
| Young Stoner Life | Aubrey | 33 | 21 | 197 | loose |
| Young Stoner Life | Audemar | 56 | 129 | 150 | loose |
| Young Stoner Life | Austin Powers | 40 | 40 | 212 | loose |
| Young Stoner Life | Award | 57 | 88 | 225 | loose |
| Young Stoner Life | BIGGER THAN LIFE | 17 | 13 | 90 | loose |
| Young Stoner Life | BLAKK TRUKK | 44 | 54 | 216 | loose |
| Young Stoner Life | BLINDFOLD | 56 | 108 | 247 | loose |
| Young Stoner Life | BLONDE P*NK | 35 | 13 | 187 | loose |
| Young Stoner Life | BOUNTY | 25 | 30 | 182 | loose |
| Young Stoner Life | BTTR & BTTR | 37 | 36 | 127 | loose |
| Young Stoner Life | BURGERS N FRIES | 59 | 64 | 287 | loose |
| Young Stoner Life | Baby | 39 | 49 | 181 | loose |
| Young Stoner Life | Baby Birkin | 58 | 107 | 236 | loose |
| Young Stoner Life | Bachelor | 52 | 54 | 154 | loose |
| Young Stoner Life | Back Board | 56 | 72 | 233 | loose |
| Young Stoner Life | Back Bone | 47 | 38 | 309 | loose |
| Young Stoner Life | Backwoods at Westway | 55 | 63 | 289 | loose |
| Young Stoner Life | Bad | 25 | 22 | 82 | loose |
| Young Stoner Life | Bad Bad Bad | 47 | 61 | 246 | loose |
| Young Stoner Life | Bad Boy | 32 | 34 | 210 | loose |
| Young Stoner Life | Bad Girl | 18 | 10 | 54 | loose |
| Young Stoner Life | Baddies | 24 | 14 | 122 | loose |
| Young Stoner Life | Bag Drop | 24 | 23 | 101 | loose |
| Young Stoner Life | Bags To The Sky | 36 | 33 | 245 | loose |
| Young Stoner Life | Baguette | 52 | 89 | 220 | loose |
| Young Stoner Life | Baguettes | 27 | 28 | 194 | loose |
| Young Stoner Life | Bait Em In | 29 | 15 | 139 | loose |
| Young Stoner Life | Balenciaga | 49 | 35 | 213 | loose |
| Young Stoner Life | Ballet | 43 | 38 | 227 | loose |
| Young Stoner Life | Bangin N Hangin | 21 | 31 | 139 | loose |
| Young Stoner Life | Banking On Me | 42 | 70 | 189 | loose |
| Young Stoner Life | Basically Fr | 43 | 50 | 241 | loose |
| Young Stoner Life | Be With Them | 24 | 34 | 304 | loose |
| Young Stoner Life | Beast | 44 | 44 | 246 | loose |
| Young Stoner Life | Beat Da Feds | 24 | 15 | 140 | loose |
| Young Stoner Life | Beat the Case | 53 | 73 | 135 | loose |
| Young Stoner Life | Believe In Me | 78 | 104 | 197 | loose |
| Young Stoner Life | Believe That | 41 | 37 | 228 | loose |
| Young Stoner Life | Belly | 64 | 93 | 315 | loose |
| Young Stoner Life | Belly of the Beast | 53 | 99 | 191 | loose |
| Young Stoner Life | Bench Pressin’ | 52 | 85 | 186 | loose |
| Young Stoner Life | Best Friend | 43 | 30 | 289 | loose |
| Young Stoner Life | Best Move | 35 | 35 | 163 | loose |
| Young Stoner Life | Better Days | 55 | 85 | 199 | loose |
| Young Stoner Life | Betty Boop | 44 | 37 | 268 | loose |
| Young Stoner Life | Big Apple | 30 | 26 | 169 | loose |
| Young Stoner Life | Big Bag | 55 | 42 | 280 | loose |
| Young Stoner Life | Big Eye | 32 | 22 | 90 | loose |
| Young Stoner Life | Big Order | 56 | 47 | 296 | loose |
| Young Stoner Life | Big Racks | 58 | 72 | 210 | loose |
| Young Stoner Life | Big Slimes | 81 | 111 | 404 | loose |
| Young Stoner Life | Big Tipper | 58 | 30 | 426 | loose |
| Young Stoner Life | Biggest Opp | 79 | 79 | 361 | loose |
| Young Stoner Life | Biggest Since Michael Jack | 51 | 57 | 336 | loose |
| Young Stoner Life | Billboard | 82 | 106 | 340 | loose |
| Young Stoner Life | Birkin | 51 | 66 | 196 | loose |
| Young Stoner Life | Birthday | 45 | 30 | 198 | loose |
| Young Stoner Life | Birthday Boy | 31 | 25 | 67 | loose |
| Young Stoner Life | Bittersweet | 44 | 96 | 357 | loose |
| Young Stoner Life | Black Friday | 36 | 46 | 301 | loose |
| Young Stoner Life | Black Out | 1 | 0 | 1 | loose |
| Young Stoner Life | Blackout | 54 | 58 | 190 | loose |
| Young Stoner Life | Blaming Jesus | 37 | 38 | 100 | loose |
| Young Stoner Life | Blicky Blicky | 47 | 61 | 64 | loose |
| Young Stoner Life | Blind | 30 | 30 | 161 | loose |
| Young Stoner Life | BloodSucker. | 30 | 45 | 125 | loose |
| Young Stoner Life | Bloodshed | 22 | 27 | 205 | loose |
| Young Stoner Life | Blue Hunnids | 39 | 48 | 145 | loose |
| Young Stoner Life | Blur | 33 | 33 | 215 | loose |
| Young Stoner Life | Boondocks | 34 | 50 | 190 | loose |
| Young Stoner Life | Born in It | 46 | 46 | 238 | loose |
| Young Stoner Life | Boy Back | 45 | 68 | 249 | loose |
| Young Stoner Life | Bread Winners | 66 | 73 | 187 | loose |
| Young Stoner Life | Bubbly | 62 | 111 | 283 | loose |
| Young Stoner Life | Bullets With Names | 58 | 75 | 261 | loose |
| Young Stoner Life | Business Is Business | 55 | 143 | 195 | loose |
| Young Stoner Life | Buss Down | 45 | 46 | 136 | loose |
| Young Stoner Life | Buy The Building | 31 | 37 | 245 | loose |
| Young Stoner Life | Bvlgari | 94 | 89 | 559 | loose |
| Young Stoner Life | By The Police | 48 | 37 | 312 | loose |
| Young Stoner Life | CAYENNE | 48 | 66 | 228 | loose |
| Young Stoner Life | CHAINZ & CORVETTEZ | 29 | 38 | 164 | loose |
| Young Stoner Life | COOLER THAN A BITCH | 50 | 65 | 287 | loose |
| Young Stoner Life | Calling Your Name | 70 | 93 | 203 | loose |
| Young Stoner Life | Came From Nun | 47 | 81 | 153 | loose |
| Young Stoner Life | Cancun | 40 | 29 | 70 | loose |
| Young Stoner Life | Can’t Fall Victim | 40 | 37 | 185 | loose |
| Young Stoner Life | Can’t Imagine | 25 | 53 | 107 | loose |
| Young Stoner Life | Can’t Sleep | 59 | 96 | 205 | loose |
| Young Stoner Life | Can’t Tell | 94 | 73 | 408 | loose |
| Young Stoner Life | Cap Ain’t Nothing | 49 | 46 | 328 | loose |
| Young Stoner Life | Car Sick | 64 | 112 | 290 | loose |
| Young Stoner Life | Cars Bring Me Out | 56 | 71 | 402 | loose |
| Young Stoner Life | Cartier Gucci Scarf | 64 | 50 | 221 | loose |
| Young Stoner Life | Cash War | 44 | 91 | 209 | loose |
| Young Stoner Life | Catch Me I’m Falling | 43 | 44 | 214 | loose |
| Young Stoner Life | Catching the Vybe | 31 | 28 | 68 | loose |
| Young Stoner Life | Caught With a Stick | 41 | 59 | 179 | loose |
| Young Stoner Life | Cha Ney Ney | 46 | 21 | 240 | loose |
| Young Stoner Life | Chains Choking Me | 51 | 46 | 254 | loose |
| Young Stoner Life | Chances | 38 | 45 | 143 | loose |
| Young Stoner Life | Chanel (Go Get It) | 66 | 105 | 279 | loose |
| Young Stoner Life | Chariot | 100 | 152 | 303 | loose |
| Young Stoner Life | Check | 52 | 46 | 223 | loose |
| Young Stoner Life | Chew | 38 | 53 | 160 | loose |
| Young Stoner Life | Child | 42 | 57 | 183 | loose |
| Young Stoner Life | Chill Øut | 40 | 39 | 267 | loose |
| Young Stoner Life | Chit Chat | 51 | 66 | 287 | loose |
| Young Stoner Life | Choppa Won’t Miss | 48 | 63 | 173 | loose |
| Young Stoner Life | Chrome Heart Wave | 18 | 18 | 122 | loose |
| Young Stoner Life | Circle of Bosses | 60 | 82 | 204 | loose |
| Young Stoner Life | City Girls | 43 | 39 | 236 | loose |
| Young Stoner Life | Classy Girl | 27 | 36 | 104 | loose |
| Young Stoner Life | Classy N Shit | 26 | 26 | 79 | loose |
| Young Stoner Life | Climax | 50 | 54 | 113 | loose |
| Young Stoner Life | Close Friends | 41 | 39 | 160 | loose |
| Young Stoner Life | Club Outside | 39 | 29 | 286 | loose |
| Young Stoner Life | Cocoon | 53 | 38 | 121 | loose |
| Young Stoner Life | Codeine | 57 | 149 | 294 | loose |
| Young Stoner Life | Cold World | 34 | 41 | 142 | loose |
| Young Stoner Life | Como Te Llama | 19 | 7 | 110 | loose |
| Young Stoner Life | Confetti (Intro) | 40 | 63 | 151 | loose |
| Young Stoner Life | Constantly Hating | 78 | 59 | 331 | loose |
| Young Stoner Life | Consummate | 33 | 30 | 200 | loose |
| Young Stoner Life | Contagious | 34 | 52 | 203 | loose |
| Young Stoner Life | Cookies | 45 | 29 | 153 | loose |
| Young Stoner Life | Countin Up | 34 | 39 | 186 | loose |
| Young Stoner Life | Crakkin (The Øne) | 27 | 51 | 92 | loose |
| Young Stoner Life | Crocodile Skin | 29 | 15 | 146 | loose |
| Young Stoner Life | Cruise Ship | 37 | 45 | 153 | loose |
| Young Stoner Life | Currency Chaser | 30 | 35 | 243 | loose |
| Young Stoner Life | Cuttin | 43 | 34 | 247 | loose |
| Young Stoner Life | DEA | 36 | 25 | 263 | loose |
| Young Stoner Life | DIRTY DIANA | 41 | 100 | 116 | loose |
| Young Stoner Life | DIVINE | 22 | 11 | 43 | loose |
| Young Stoner Life | DO BETTER | 38 | 66 | 176 | loose |
| Young Stoner Life | DOLLAZ ON MY HEAD | 45 | 81 | 379 | loose |
| Young Stoner Life | DON’T PLAY AROUND | 49 | 49 | 317 | loose |
| Young Stoner Life | Da Fuck | 61 | 70 | 233 | loose |
| Young Stoner Life | Daddy’s Birthday | 50 | 42 | 229 | loose |
| Young Stoner Life | Day Before | 38 | 47 | 278 | loose |
| Young Stoner Life | Dead Doc | 49 | 42 | 253 | loose |
| Young Stoner Life | Dead Fo Real | 40 | 29 | 204 | loose |
| Young Stoner Life | Deep End | 35 | 35 | 242 | loose |
| Young Stoner Life | Deeper Than the Ocean | 59 | 108 | 177 | loose |
| Young Stoner Life | Definitely | 40 | 34 | 192 | loose |
| Young Stoner Life | Demon Time | 56 | 68 | 380 | loose |
| Young Stoner Life | Derek Fisher | 32 | 52 | 239 | loose |
| Young Stoner Life | Designer | 45 | 68 | 196 | loose |
| Young Stoner Life | Desire | 41 | 39 | 242 | loose |
| Young Stoner Life | Diamonds | 53 | 66 | 205 | loose |
| Young Stoner Life | Diamonds Dancing | 45 | 70 | 185 | loose |
| Young Stoner Life | Did That | 29 | 39 | 142 | loose |
| Young Stoner Life | Die Slow | 59 | 33 | 312 | loose |
| Young Stoner Life | Die Today | 31 | 30 | 174 | loose |
| Young Stoner Life | Digits | 35 | 24 | 150 | loose |
| Young Stoner Life | Dior | 40 | 21 | 106 | loose |
| Young Stoner Life | Dirty Games | 61 | 45 | 179 | loose |
| Young Stoner Life | Dirty Shoes | 44 | 34 | 291 | loose |
| Young Stoner Life | Do U Love Me | 58 | 58 | 235 | loose |
| Young Stoner Life | Dodge the Hate | 53 | 101 | 112 | loose |
| Young Stoner Life | Dollar Signs | 44 | 39 | 133 | loose |
| Young Stoner Life | Don’t Call Me | 40 | 36 | 132 | loose |
| Young Stoner Life | Don’t Do No Playing | 33 | 29 | 145 | loose |
| Young Stoner Life | Don’t Give Up | 53 | 131 | 129 | loose |
| Young Stoner Life | Don’t Need You | 52 | 107 | 167 | loose |
| Young Stoner Life | Don’t Play With It | 53 | 44 | 171 | loose |
| Young Stoner Life | Don’t Stop | 29 | 30 | 137 | loose |
| Young Stoner Life | Don’t Wanna Leave | 36 | 19 | 286 | loose |
| Young Stoner Life | Double | 80 | 122 | 346 | loose |
| Young Stoner Life | Dragon | 45 | 35 | 195 | loose |
| Young Stoner Life | Dream | 45 | 48 | 162 | loose |
| Young Stoner Life | Dreams Rarely Do Come True | 64 | 46 | 342 | loose |
| Young Stoner Life | Drip Nation | 53 | 128 | 337 | loose |
| Young Stoner Life | Drip Too Hard | 32 | 43 | 185 | loose |
| Young Stoner Life | Drip on Me | 45 | 53 | 165 | loose |
| Young Stoner Life | Drip or Drown (Remix) | 67 | 107 | 323 | loose |
| Young Stoner Life | Drippin’ | 49 | 44 | 281 | loose |
| Young Stoner Life | Duality | 26 | 37 | 238 | loose |
| Young Stoner Life | EA | 45 | 36 | 145 | loose |
| Young Stoner Life | EAT | 39 | 74 | 272 | loose |
| Young Stoner Life | EVERYTHING SLATT | 37 | 35 | 91 | loose |
| Young Stoner Life | Eaters | 68 | 48 | 221 | loose |
| Young Stoner Life | Ecstasy | 34 | 36 | 160 | loose |
| Young Stoner Life | Elbow | 56 | 67 | 241 | loose |
| Young Stoner Life | Emotional | 29 | 30 | 174 | loose |
| Young Stoner Life | Encore. | 25 | 33 | 196 | loose |
| Young Stoner Life | Enough of Me | 29 | 43 | 114 | loose |
| Young Stoner Life | Escalade | 33 | 61 | 215 | loose |
| Young Stoner Life | Every Night | 75 | 71 | 266 | loose |
| Young Stoner Life | Everything | 33 | 13 | 180 | loose |
| Young Stoner Life | Ew | 30 | 49 | 168 | loose |
| Young Stoner Life | F Cancer (Boosie) | 70 | 75 | 401 | loose |
| Young Stoner Life | F.O.F.G. | 33 | 67 | 284 | loose |
| Young Stoner Life | FEEFA | 44 | 62 | 287 | loose |
| Young Stoner Life | FEIGNING | 34 | 68 | 193 | loose |
| Young Stoner Life | FERRARI | 32 | 19 | 107 | loose |
| Young Stoner Life | FLAWS | 28 | 29 | 160 | loose |
| Young Stoner Life | FOR A NUT | 42 | 35 | 205 | loose |
| Young Stoner Life | FRANCHISE | 51 | 42 | 283 | loose |
| Young Stoner Life | FUCKED UP | 22 | 28 | 126 | loose |
| Young Stoner Life | Faces | 36 | 31 | 190 | loose |
| Young Stoner Life | Fall Threw | 54 | 75 | 116 | loose |
| Young Stoner Life | Family | 66 | 56 | 169 | loose |
| Young Stoner Life | Family Don’t Matter | 63 | 40 | 257 | loose |
| Young Stoner Life | Fatigue | 56 | 67 | 217 | loose |
| Young Stoner Life | Fear of God | 49 | 38 | 179 | loose |
| Young Stoner Life | Feed Me Dope | 36 | 24 | 193 | loose |
| Young Stoner Life | Feed The Fam | 38 | 82 | 217 | AAAA |
| Young Stoner Life | Feel It | 51 | 54 | 202 | loose |
| Young Stoner Life | Feel My Pain | 63 | 104 | 179 | loose |
| Young Stoner Life | Feelin’ Amazing | 27 | 37 | 78 | loose |
| Young Stoner Life | Feels | 31 | 38 | 124 | loose |
| Young Stoner Life | Feinding | 37 | 42 | 97 | loose |
| Young Stoner Life | Fernando Mendoza | 28 | 31 | 63 | loose |
| Young Stoner Life | Fetish | 51 | 48 | 244 | loose |
| Young Stoner Life | Fifth Day Dead | 34 | 44 | 190 | loose |
| Young Stoner Life | Fighting Demons | 37 | 37 | 289 | loose |
| Young Stoner Life | Fighting Depression | 65 | 74 | 313 | loose |
| Young Stoner Life | Finally Free | 32 | 51 | 159 | loose |
| Young Stoner Life | Flexin | 41 | 53 | 185 | loose |
| Young Stoner Life | Floyd Mayweather | 95 | 170 | 450 | loose |
| Young Stoner Life | Flying Saucer | 19 | 4 | 71 | loose |
| Young Stoner Life | For My People | 71 | 88 | 191 | loose |
| Young Stoner Life | For Sale | 54 | 36 | 200 | loose |
| Young Stoner Life | For Y’all | 57 | 47 | 214 | loose |
| Young Stoner Life | For the Love of Money | 59 | 74 | 145 | loose |
| Young Stoner Life | Fox 5 | 44 | 39 | 269 | loose |
| Young Stoner Life | Freak N You | 44 | 55 | 130 | loose |
| Young Stoner Life | Freaky | 55 | 52 | 310 | loose |
| Young Stoner Life | Freaky Girl | 36 | 36 | 134 | loose |
| Young Stoner Life | Free The Goat | 49 | 101 | 221 | loose |
| Young Stoner Life | Freestyle | 35 | 47 | 196 | loose |
| Young Stoner Life | Friend Zone | 52 | 43 | 218 | loose |
| Young Stoner Life | Friends With Benefits | 43 | 41 | 201 | loose |
| Young Stoner Life | From Nun | 35 | 41 | 192 | loose |
| Young Stoner Life | From a Man | 46 | 43 | 290 | loose |
| Young Stoner Life | From the Heart | 43 | 32 | 228 | loose |
| Young Stoner Life | Fucking Told U | 37 | 52 | 131 | loose |
| Young Stoner Life | FØURS | 53 | 112 | 187 | loose |
| Young Stoner Life, Yak Gotti & Sheck Wes | GFU | 82 | 39 | 105 | loose |
| Young Stoner Life | I Like | 48 | 21 | 91 | loose |
| Young Stoner Life & Young Thug | Mack Truck | 40 | 14 | 213 | loose |
| Young Stoner Life & Young Thug | Mil in Vegas | 47 | 28 | 237 | loose |
| Young Stoner Life & Young Thug | Mob Ties Remix | 93 | 50 | 164 | loose |
| Young Stoner Life & Young Thug | Moon Man | 34 | 13 | 179 | loose |
| Young Stoner Life & Young Thug | My City (Remix) | 49 | 32 | 399 | loose |
| Young Stoner Life | NOT A TELFAR | 29 | 18 | 94 | loose |
| Young Stoner Life | NOTHING 4 FREE | 55 | 91 | 280 | loose |
| Young Stoner Life | Niggas Ain’t Safe | 56 | 69 | 276 | loose |
| Young Stoner Life | Nightgown. | 28 | 44 | 216 | loose |
| Young Stoner Life | Ninja | 65 | 44 | 311 | loose |
| Young Stoner Life | No Cap | 52 | 60 | 201 | loose |
| Young Stoner Life | No Choice | 38 | 35 | 108 | loose |
| Young Stoner Life | No Dealings | 48 | 51 | 166 | loose |
| Young Stoner Life | No Debate | 32 | 61 | 163 | loose |
| Young Stoner Life | No Joke | 47 | 71 | 230 | loose |
| Young Stoner Life | No Limit | 56 | 33 | 191 | loose |
| Young Stoner Life | No Love | 47 | 86 | 152 | loose |
| Young Stoner Life | No Pass | 30 | 29 | 226 | loose |
| Young Stoner Life | No Rush | 31 | 18 | 110 | loose |
| Young Stoner Life | No Such Thing | 24 | 33 | 159 | loose |
| Young Stoner Life | Nobody on E | 49 | 63 | 218 | loose |
| Young Stoner Life | Not @ All. | 5 | 0 | 11 | loose |
| Young Stoner Life | NotASong. | 50 | 45 | 272 | loose |
| Young Stoner Life | Nothing 2 Something | 50 | 69 | 168 | loose |
| Young Stoner Life | Nothing Cheap | 36 | 16 | 176 | loose |
| Young Stoner Life | Noticed | 48 | 58 | 227 | loose |
| Young Stoner Life, Young Thug & Gunna | Paid the Fine | 61 | 26 | 347 | loose |
| Young Stoner Life | Pots N Pans | 78 | 62 | 347 | loose |
| Young Stoner Life & Young Thug | Proud of You | 55 | 33 | 132 | loose |
| Young Stoner Life | Really Be Slime | 67 | 37 | 194 | loose |
| Young Stoner Life | Reckless | 25 | 11 | 35 | loose |
| Young Stoner Life, Young Thug & Gunna | Ski | 33 | 27 | 251 | loose |
| Young Stoner Life, Young Thug & Gunna | Slam the Door | 58 | 19 | 221 | loose |
| Young Stoner Life, Young Thug & Gunna | Slatty | 65 | 42 | 262 | loose |
| Young Stoner Life, Young Thug & Gunna | Solid | 72 | 39 | 256 | loose |
| Young Stoner Life & Young Thug | Superstar | 23 | 15 | 126 | loose |
| Young Stoner Life | THE WORLD IS YOURS | 23 | 5 | 126 | loose |
| Young Stoner Life | THIS YEAR (Blessings) [Remix] | 23 | 21 | 41 | loose |
| Young Stoner Life | THUG INTERLUDE | 13 | 2 | 28 | loose |
| Young Stoner Life | TOP FLOOR | 45 | 54 | 184 | loose |
| Young Stoner Life, Young Thug & Gunna | Take It to Trial | 50 | 43 | 284 | loose |
| Young Stoner Life | Tezzus & diamond* | 70 | 72 | 242 | loose |
| Young Stoner Life | Tezzus Mane La’Flair | 30 | 25 | 167 | loose |
| Young Stoner Life | Thank You Lord | 37 | 11 | 108 | loose |
| Young Stoner Life | The Half | 45 | 38 | 199 | loose |
| Young Stoner Life | The London | 56 | 41 | 244 | loose |
| Young Stoner Life | The One | 74 | 126 | 232 | loose |
| Young Stoner Life | The War | 50 | 41 | 255 | loose |
| Young Stoner Life | They Copy | 58 | 99 | 273 | loose |
| Young Stoner Life | Thief in the Night | 74 | 101 | 245 | loose |
| Young Stoner Life | Think About It | 48 | 24 | 169 | loose |
| Young Stoner Life | Thinking | 46 | 88 | 131 | loose |
| Young Stoner Life | This Is America | 51 | 15 | 56 | loose |
| Young Stoner Life | Thou Wow | 21 | 18 | 139 | loose |
| Young Stoner Life | Three | 53 | 38 | 295 | loose |
| Young Stoner Life | Throw Sum Mo | 47 | 56 | 206 | loose |
| Young Stoner Life | Throwing Shade | 59 | 113 | 212 | loose |
| Young Stoner Life | Thug Luv | 16 | 19 | 94 | loose |
| Young Stoner Life | Thugger | 47 | 43 | 135 | loose |
| Young Stoner Life | Tick Tock | 49 | 88 | 206 | loose |
| Young Stoner Life | Tighten Up | 61 | 76 | 265 | loose |
| Young Stoner Life | Till the Morning | 44 | 33 | 224 | loose |
| Young Stoner Life | Tip Top | 58 | 94 | 304 | loose |
| Young Stoner Life | To the Moon | 38 | 80 | 189 | loose |
| Young Stoner Life | Toast Up | 36 | 68 | 203 | loose |
| Young Stoner Life | Told Em | 49 | 45 | 129 | loose |
| Young Stoner Life | Tomorrow ’Til Infinity | 49 | 48 | 210 | loose |
| Young Stoner Life | Tonight | 40 | 39 | 247 | loose |
| Young Stoner Life | Too Humble | 43 | 67 | 214 | loose |
| Young Stoner Life | Too Many | 32 | 43 | 112 | loose |
| Young Stoner Life | Took Off | 36 | 18 | 200 | loose |
| Young Stoner Life | Top | 39 | 62 | 118 | loose |
| Young Stoner Life | Top 5 | 46 | 53 | 290 | loose |
| Young Stoner Life | Top Off | 58 | 94 | 156 | loose |
| Young Stoner Life | Top Rope | 37 | 18 | 168 | loose |
| Young Stoner Life | Toxicity | 30 | 27 | 237 | loose |
| Young Stoner Life | Trance | 27 | 8 | 337 | loose |
| Young Stoner Life | Trap Back | 42 | 55 | 196 | loose |
| Young Stoner Life | Trap House (Remix) | 65 | 61 | 199 | loose |
| Young Stoner Life | Trap Trap Trap | 53 | 31 | 306 | loose |
| Young Stoner Life | Traplanta | 33 | 25 | 198 | loose |
| Young Stoner Life | Trashcan | 23 | 19 | 130 | loose |
| Young Stoner Life | Trial | 20 | 8 | 95 | loose |
| Young Stoner Life | Trippin | 27 | 36 | 141 | loose |
| Young Stoner Life | Truly Be Missed | 47 | 42 | 220 | loose |
| Young Stoner Life | Tryna Get Me | 45 | 34 | 164 | loose |
| Young Stoner Life | Tryna’ Tell U* | 37 | 29 | 115 | loose |
| Young Stoner Life | Tsunami | 56 | 62 | 160 | loose |
| Young Stoner Life | Turks | 56 | 87 | 348 | loose |
| Young Stoner Life | Twisted | 39 | 15 | 251 | loose |
| Young Stoner Life | U Ain’t Slime Enough | 60 | 61 | 300 | loose |
| Young Stoner Life | U N I | 39 | 54 | 157 | loose |
| Young Stoner Life | UE | 37 | 35 | 145 | loose |
| Young Stoner Life | UY SCUTI | 86 | 103 | 277 | loose |
| Young Stoner Life | Uberman 2 Intro | 63 | 59 | 156 | loose |
| Young Stoner Life | Udiggwhatimsayin | 45 | 50 | 210 | loose |
| Young Stoner Life | Umbrella | 32 | 48 | 208 | loose |
| Young Stoner Life | Uncle M | 21 | 22 | 151 | loose |
| Young Stoner Life | Underdog | 38 | 63 | 224 | loose |
| Young Stoner Life | Understood | 72 | 71 | 336 | loose |
| Young Stoner Life | Unicorn Purp | 48 | 63 | 426 | loose |
| Young Stoner Life | United | 25 | 53 | 216 | loose |
| Young Stoner Life | Up | 83 | 117 | 328 | loose |
| Young Stoner Life | Up to Something | 45 | 60 | 130 | loose |
| Young Stoner Life | VENOM | 27 | 30 | 127 | loose |
| Young Stoner Life | Vetements Jeans | 37 | 37 | 89 | loose |
| Young Stoner Life | Vibes on Vibes | 56 | 74 | 212 | loose |
| Young Stoner Life | Vibez | 22 | 21 | 59 | loose |
| Young Stoner Life | W Y O (What You On) | 50 | 63 | 219 | loose |
| Young Stoner Life | WHITE OPS | 47 | 46 | 115 | loose |
| Young Stoner Life | WUNNA | 37 | 54 | 144 | loose |
| Young Stoner Life | WUNNA FLO | 49 | 71 | 204 | loose |
| Young Stoner Life | WYD2 | 21 | 19 | 188 | loose |
| Young Stoner Life | Wait For It | 20 | 8 | 82 | loose |
| Young Stoner Life | Waitin on Me to Fall | 51 | 75 | 139 | loose |
| Young Stoner Life | Wake & Cake | 24 | 13 | 151 | loose |
| Young Stoner Life | Wake Up | 65 | 105 | 207 | loose |
| Young Stoner Life | Walk Down | 43 | 47 | 204 | loose |
| Young Stoner Life | Wanna See You | 40 | 38 | 244 | loose |
| Young Stoner Life | Want It All | 40 | 56 | 194 | loose |
| Young Stoner Life | Want Me Dead | 56 | 94 | 305 | loose |
| Young Stoner Life | Warrior | 69 | 40 | 108 | loose |
| Young Stoner Life | Wat U On | 44 | 56 | 200 | loose |
| Young Stoner Life | Water By G | 30 | 23 | 96 | loose |
| Young Stoner Life | Water Water | 40 | 41 | 110 | loose |
| Young Stoner Life | Wavy | 51 | 51 | 293 | loose |
| Young Stoner Life | We Ball | 63 | 83 | 322 | loose |
| Young Stoner Life | We Dead | 23 | 18 | 325 | loose |
| Young Stoner Life | We Get It | 59 | 73 | 243 | loose |
| Young Stoner Life | We Gonna Make It Happen | 36 | 59 | 244 | loose |
| Young Stoner Life | We On | 69 | 51 | 123 | loose |
| Young Stoner Life | We Should | 38 | 57 | 303 | loose |
| Young Stoner Life | Webbie | 78 | 133 | 267 | loose |
| Young Stoner Life | Weird | 67 | 49 | 274 | loose |
| Young Stoner Life | Went Thru It | 36 | 18 | 216 | loose |
| Young Stoner Life | Wet Like a Boat | 74 | 133 | 278 | loose |
| Young Stoner Life | Whaddup Jesus | 40 | 28 | 234 | loose |
| Young Stoner Life | What I Do | 48 | 38 | 154 | loose |
| Young Stoner Life | What It Do | 31 | 12 | 159 | loose |
| Young Stoner Life | Whatever | 53 | 37 | 280 | loose |
| Young Stoner Life | What’s Up Mami | 61 | 68 | 375 | loose |
| Young Stoner Life | What’s the Move | 64 | 79 | 267 | loose |
| Young Stoner Life | When We Ride | 27 | 15 | 178 | loose |
| Young Stoner Life | Where I’m From | 24 | 25 | 166 | loose |
| Young Stoner Life | Whippin It | 32 | 30 | 213 | loose |
| Young Stoner Life | Who Want It Freestyle | 72 | 57 | 270 | loose |
| Young Stoner Life | Who You Foolin | 38 | 96 | 148 | loose |
| Young Stoner Life | Whoopty Doo | 54 | 35 | 142 | loose |
| Young Stoner Life | Why | 21 | 33 | 99 | loose |
| Young Stoner Life | Why Order | 37 | 31 | 208 | loose |
| Young Stoner Life | Why Why | 36 | 34 | 203 | loose |
| Young Stoner Life | Win Win Win | 37 | 34 | 46 | loose |
| Young Stoner Life | Winning Again* | 4 | 6 | 1 | AAAA |
| Young Stoner Life | Wish Me Well | 33 | 17 | 138 | loose |
| Young Stoner Life | Wishful Thinking Interlude | 18 | 8 | 38 | loose |
| Young Stoner Life | Wishy Washy | 51 | 115 | 121 | loose |
| Young Stoner Life | Wit Da Racks | 79 | 124 | 343 | loose |
| Young Stoner Life | Wit It | 29 | 42 | 193 | loose |
| Young Stoner Life | With That | 30 | 34 | 145 | loose |
| Young Stoner Life | With Them | 49 | 56 | 299 | loose |
| Young Stoner Life | Woah Woah | 41 | 50 | 205 | loose |
| Young Stoner Life | WokStar | 34 | 16 | 170 | loose |
| Young Stoner Life | Wood Would | 32 | 27 | 175 | loose |
| Young Stoner Life | Wop (Remix) | 38 | 37 | 220 | loose |
| Young Stoner Life | World Is Yours | 41 | 66 | 191 | loose |
| Young Stoner Life | Worry Bout Yours. | 38 | 37 | 171 | loose |
| Young Stoner Life | Worst or Better | 28 | 25 | 133 | loose |
| Young Stoner Life | Worth It | 46 | 55 | 220 | loose |
| Young Stoner Life | Wreccless | 65 | 115 | 219 | loose |
| Young Stoner Life | Wyclef Jean | 57 | 35 | 166 | loose |
| Young Stoner Life | YEET | 39 | 48 | 239 | loose |
| Young Stoner Life | YELL OH | 42 | 58 | 221 | loose |
| Young Stoner Life | YRN | 41 | 35 | 266 | loose |
| Young Stoner Life | YSL | 30 | 10 | 129 | loose |
| Young Stoner Life | Yacht Club | 42 | 17 | 137 | loose |
| Young Stoner Life | Yank It | 40 | 42 | 167 | loose |
| Young Stoner Life | Yao Ming | 33 | 37 | 310 | loose |
| Young Stoner Life | Yara Yara Phønk | 42 | 62 | 243 | loose |
| Young Stoner Life | Ye | 28 | 35 | 127 | loose |
| Young Stoner Life | Yea Yea Yea | 37 | 27 | 185 | loose |
| Young Stoner Life | Yeah, Yeah (1017 Thug) | 55 | 63 | 230 | loose |
| Young Stoner Life | Yes You Can | 32 | 53 | 151 | loose |
| Young Stoner Life | Yessirskii | 15 | 4 | 34 | loose |
| Young Stoner Life | You Said | 81 | 71 | 330 | loose |
| Young Stoner Life & Gunna | Young Stoner Life & Gunna — Came Out | 32 | 16 | 157 | loose |
| Young Stoner Life & Gunna | Young Stoner Life & Gunna — Explosion | 47 | 48 | 239 | loose |
| Young Stoner Life & Young Thug | Young Stoner Life & Young Thug — Came and Saw | 49 | 40 | 174 | loose |
| Young Stoner Life & Young Thug | Young Stoner Life & Young Thug — No Surprise | 43 | 30 | 218 | loose |
| Young Stoner Life | Young Stoner Life — Came Out | 40 | 55 | 172 | loose |
| Young Stoner Life | Young Stoner Life — Came and Saw | 48 | 61 | 177 | loose |
| Young Stoner Life | Young Stoner Life — Explosion | 43 | 71 | 268 | loose |
| Young Stoner Life | Young Stoner Life — No Surprise | 43 | 45 | 205 | loose |
| Young Stoner Life | Young Stoner Life — That Go! | 69 | 78 | 371 | loose |
| Young Stoner Life, Young Thug & Meek Mill | Young Stoner Life, Young Thug & Meek Mill — That Go! | 76 | 63 | 398 | loose |
| Young Stoner Life | Youngsta | 64 | 62 | 264 | loose |
| Young Stoner Life | Yuck | 69 | 71 | 387 | loose |
| Young Stoner Life | Zaza | 60 | 58 | 276 | loose |
| Young Stoner Life | Zoned Out | 47 | 46 | 156 | loose |
| Young Stoner Life | Zoom | 20 | 37 | 97 | loose |
| Young Stoner Life | alright | 27 | 35 | 166 | loose |
| Young Stoner Life | at my purest | 40 | 51 | 275 | loose |
| Young Stoner Life | back at it | 37 | 53 | 150 | loose |
| Young Stoner Life | back in the a | 38 | 59 | 114 | loose |
| Young Stoner Life | back to the moon | 63 | 108 | 404 | loose |
| Young Stoner Life | believer | 41 | 37 | 146 | loose |
| Young Stoner Life | blackjack | 26 | 33 | 187 | loose |
| Young Stoner Life | bloom | 66 | 100 | 208 | loose |
| Young Stoner Life | born rich | 30 | 49 | 138 | loose |
| Young Stoner Life | bottom | 50 | 101 | 151 | loose |
| Young Stoner Life | bottom to top | 55 | 103 | 180 | loose |
| Young Stoner Life | bread & butter | 49 | 68 | 364 | loose |
| Young Stoner Life | bstroy socks | 42 | 88 | 178 | loose |
| Young Stoner Life | bunda | 17 | 16 | 104 | loose |
| Young Stoner Life | ca$h $hit | 37 | 49 | 193 | loose |
| Young Stoner Life | can’t leave without it | 75 | 60 | 394 | loose |
| Young Stoner Life | cause + effect | 34 | 33 | 136 | loose |
| Young Stoner Life | chosen | 47 | 78 | 201 | loose |
| Young Stoner Life | clear my rain | 40 | 73 | 191 | loose |
| Young Stoner Life | cocaine* | 17 | 9 | 91 | loose |
| Young Stoner Life | collage | 45 | 77 | 157 | loose |
| Young Stoner Life | conscience | 31 | 47 | 291 | loose |
| Young Stoner Life | contour | 26 | 30 | 103 | loose |
| Young Stoner Life | crystal clear | 25 | 28 | 113 | loose |
| Young Stoner Life | die alone | 52 | 41 | 221 | loose |
| Young Stoner Life | down (one kount) | 38 | 57 | 137 | loose |
| Young Stoner Life | flooded | 36 | 66 | 242 | loose |
| Young Stoner Life | forever be mine | 44 | 63 | 167 | loose |
| Young Stoner Life | freak | 35 | 29 | 153 | loose |
| Young Stoner Life | new world | 24 | 18 | 87 | loose |
| Young Stoner Life | no sense | 30 | 35 | 205 | loose |
| Young Stoner Life | the time | 32 | 76 | 283 | loose |
| Young Stoner Life | thought i was playing | 39 | 44 | 289 | loose |
| Young Stoner Life | time reveals, be careful what you wish for | 63 | 82 | 496 | loose |
| Young Stoner Life | today i did good | 29 | 55 | 225 | loose |
| Young Stoner Life | too easy | 29 | 42 | 271 | loose |
| Young Stoner Life | treesh | 28 | 24 | 149 | loose |
| Young Stoner Life | trio | 29 | 34 | 226 | loose |
| Young Stoner Life | turned your back | 45 | 45 | 373 | loose |
| Young Stoner Life | umean | 31 | 79 | 149 | AAAA |
| Young Stoner Life | vector | 19 | 7 | 45 | loose |
| Young Stoner Life | wgft | 28 | 52 | 194 | AAAA |
| Young Stoner Life | whatsapp (wassam) | 43 | 53 | 248 | loose |
| Young Stoner Life | who you gon call | 26 | 38 | 148 | loose |
| Young Stoner Life | won’t stop | 34 | 61 | 324 | loose |
| Young Stoner Life | wya | 28 | 15 | 143 | loose |
| Young Stoner Life | ‎alotta cake | 47 | 43 | 190 | loose |
| Young Stoner Life | ‎you & me | 30 | 57 | 128 | loose |
