# Future rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Future
- Songs: 756
- Bars kept (Future lyric lines): 30648
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 25
- Canonical name: Future.
- Credit strings: Future.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 166786
- REPEAT pairs, recorded separately: 26316
- END rhymes: 27705
- INNER rhymes: 139081

By match:

- PERFECT: 12878 (END 3429, INNER 9449)
- SLANT: 69638 (END 11082, INNER 58556)
- ASSONANCE: 82210 (END 12615, INNER 69595)
- MULTI: 2060 (END 579, INNER 1481)

By confidence:

- HIGH: 13640
- MED: 143699
- LOW: 9447

## Core

- Core Y: 164130
- Core N among rhyme pairs: 2656

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 74426 (44.6%)
- vowel: 82210 (49.3%)
- spelling: 8090 (4.9%)
- multi: 2060 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- ABCB: 2 songs
- AABA: 1 songs
- loose: 752 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 11495 pairs (END 1506, INNER 9989). Words: bitch, bitches, shit, think, wrist, hit, lil, million.
2. `vow:EH` — 10030 pairs (END 1312, INNER 8718). Words: get, when, gettin, never, went, every, tell, left.
3. `vow:OW` — 9897 pairs (END 1215, INNER 8682). Words: don't, no, know, go, told, hoes, dope, ho.
4. `vow:EY` — 9681 pairs (END 1573, INNER 8108). Words: ain't, way, say, day, take, make, made, play.
5. `vow:AE` — 8316 pairs (END 1545, INNER 6771). Words: can't, back, had, can, bands, have, cash, bad.
6. `vow:AA` — 8295 pairs (END 948, INNER 7347). Words: got, want, nothin, hard, gotta, poppin, wanna, not.
7. `vow:AH` — 6196 pairs (END 680, INNER 5516). Words: fuck, some, hundred, money, love, one, what, drugs.
8. `vow:IY` — 5948 pairs (END 1181, INNER 4767). Words: see, these, even, keep, streets, need, three, here.
9. `vow:AY` — 5928 pairs (END 1030, INNER 4898). Words: like, diamonds, by, buy, high, time, fly, try.
10. `slant:AA:stop` — 4044 pairs (END 358, INNER 3686). Words: got, gotta, want, top, not, block, bought, pop.
11. `slant:IH:stop` — 2733 pairs (END 371, INNER 2362). Words: nigga, shit, hit, big, city, wrist, whip, stick.
12. `slant:AH:nas-stop` — 2319 pairs (END 82, INNER 2237). Words: fuck, money, what, some, one, come, done, young.
13. `vow:UW` — 2223 pairs (END 595, INNER 1628). Words: new, two, through, who, future, coupe, pluto, blue.
14. `slant:IH:sib-stop` — 2185 pairs (END 505, INNER 1680). Words: bitch, nigga, niggas, shit, hit, rich, big, switch.
15. `cmu:OW` — 1976 pairs (END 313, INNER 1663). Words: no, know, go, ho, show, blow, though, low.
16. `slant:EH:stop` — 1892 pairs (END 247, INNER 1645). Words: get, better, went, check, head, let, ready, said.
17. `vow:AO` — 1739 pairs (END 324, INNER 1415). Words: all, call, lost, talk, foreign, talking, more, dog.
18. `slant:AE:stop` — 1734 pairs (END 320, INNER 1414). Words: back, had, can't, bad, bag, trap, matter, black.
19. `slant:EH:nas-stop` — 1604 pairs (END 98, INNER 1506). Words: when, get, again, gettin, let, many, ten, went.
20. `slant:AH:nas` — 1583 pairs (END 129, INNER 1454). Words: money, some, one, come, young, done, comin, runnin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 1790 pair sides, mostly spelling via spelling phonetic key, often with niggas (457)
- niggas — 738 pair sides, mostly spelling via spelling phonetic key, often with nigga (457)
- gon — 703 pair sides, mostly spelling via spelling phonetic key, often with dont (150)
- ima — 609 pair sides, mostly spelling via spelling phonetic key, often with bitch (81)
- tryna — 513 pair sides, mostly spelling via spelling phonetic key, often with these (66)
- shawty — 252 pair sides, mostly vowel via spelling phonetic key, often with all (20)
- swag — 145 pair sides, mostly spelling via spelling phonetic key, often with cant (10)
- rari — 95 pair sides, mostly spelling via spelling phonetic key, often with back (11)
- codeine — 93 pair sides, mostly vowel via spelling phonetic key, often with dope (15)
- thot — 82 pair sides, mostly spelling via spelling phonetic key, often with got (16)
- xans — 79 pair sides, mostly spelling via spelling phonetic key, often with bands (11)
- migo — 79 pair sides, mostly vowel via spelling phonetic key, often with go (9)
- wraith — 77 pair sides, mostly spelling via spelling phonetic key, often with face (9)
- bando — 76 pair sides, mostly vowel via spelling phonetic key, often with had (8)
- geeked — 72 pair sides, mostly spelling via spelling phonetic key, often with keep (5)
- imma — 71 pair sides, mostly vowel via spelling phonetic key, often with nigga (29)
- dawg — 66 pair sides, mostly spelling via spelling phonetic key, often with all (24)
- chapo — 62 pair sides, mostly vowel via spelling phonetic key, often with pablo (5)
- lambo — 53 pair sides, mostly vowel via spelling phonetic key, often with no (7)
- homie — 48 pair sides, mostly spelling via spelling phonetic key, often with gon (9)
- presi — 47 pair sides, mostly spelling via spelling phonetic key, often with fetti (4)
- freeband — 47 pair sides, mostly spelling via spelling phonetic key, often with freebandz (26)
- bling — 46 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- burberry — 45 pair sides, mostly vowel via spelling phonetic key, often with pussy (4)
- finessing — 42 pair sides, mostly spelling via spelling phonetic key, often with going (2)
- bezel — 40 pair sides, mostly vowel via spelling phonetic key, often with forever (4)
- xanny — 38 pair sides, mostly vowel via spelling phonetic key, often with cant (3)
- fetti — 37 pair sides, mostly spelling via spelling phonetic key, often with get (10)
- cuz — 37 pair sides, mostly spelling via spelling phonetic key, often with love (7)
- brazy — 36 pair sides, mostly vowel via spelling phonetic key, often with rusty (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Future | #1 (Intro) | 13 | 3 | 29 | loose |
| Future | 10 Black Cars (Skrrr) | 57 | 44 | 192 | loose |
| Future | 10 Years | 52 | 45 | 200 | loose |
| Future | 100 Shooters | 45 | 58 | 279 | loose |
| Future | 2 Clever (Forever) | 81 | 96 | 205 | loose |
| Future | 20 Hoes | 40 | 29 | 202 | loose |
| Future | 200 | 43 | 28 | 156 | loose |
| Future | 2018 | 71 | 87 | 258 | loose |
| Future | 2Pac | 32 | 24 | 159 | loose |
| Future | 31 DAYS | 78 | 116 | 221 | loose |
| Future | 4 My People | 50 | 46 | 263 | loose |
| Future | 4 da Gang | 53 | 70 | 296 | loose |
| Future | 56 Nights | 59 | 50 | 220 | loose |
| Future | 600 Days No Sleep | 27 | 15 | 156 | loose |
| Future | 7 AM Freestyle | 50 | 69 | 129 | loose |
| Future | 712PM | 38 | 43 | 449 | loose |
| Future | AFFILIATED | 36 | 25 | 333 | loose |
| Future | APE Freestyle | 40 | 18 | 78 | loose |
| Future | AYE SAY GANG | 39 | 38 | 359 | loose |
| Future | Absolutely Going Brazy | 43 | 46 | 121 | loose |
| Future | Abu Astronaut Status (Outro) | 12 | 5 | 25 | loose |
| Future | Abu Turn Up (Intro) | 11 | 4 | 42 | loose |
| Future | Abu’s Boomin | 12 | 5 | 60 | loose |
| Future | Accepting My Flaws | 76 | 120 | 446 | loose |
| Future | After That | 45 | 62 | 271 | loose |
| Future | Afterlife | 51 | 83 | 305 | loose |
| Future | Ain Nun | 46 | 57 | 316 | loose |
| Future | Aintchu | 36 | 3 | 166 | loose |
| Future | Ain’t Coming Back | 43 | 47 | 192 | loose |
| Future | Ain’t Livin Right | 55 | 68 | 166 | loose |
| Future | Ain’t Neva Seen | 32 | 26 | 168 | loose |
| Future | Ain’t No Love | 44 | 76 | 219 | loose |
| Future | Ain’t No Time | 32 | 34 | 206 | loose |
| Future | Ain’t Tryin | 26 | 48 | 132 | loose |
| Future | Al Sharpton | 79 | 87 | 265 | loose |
| Future | Alice | 28 | 18 | 75 | loose |
| Future | All Bad | 70 | 60 | 248 | loose |
| Future | All I Ever Wanted | 24 | 28 | 103 | loose |
| Future | All I Want Is Some Money | 29 | 17 | 224 | loose |
| Future | All Me | 31 | 9 | 160 | loose |
| Future | All My Bitch Rockin’ (Vintage Celine) | 33 | 62 | 137 | loose |
| Future | All My Life | 40 | 39 | 228 | loose |
| Future | All My Voodoo | 41 | 39 | 293 | loose |
| Future | All Outta State | 48 | 31 | 249 | loose |
| Future | All Right | 26 | 12 | 96 | loose |
| Future | All The Time | 28 | 25 | 278 | loose |
| Future | All da Smoke | 54 | 46 | 218 | loose |
| Future | All to Myself | 48 | 55 | 128 | loose |
| Future | Always Be My Fault | 31 | 20 | 41 | loose |
| Future | Amazing (Interlude) | 23 | 6 | 28 | loose |
| Future | Another Bloody Summer | 45 | 31 | 164 | loose |
| Future | Appetite | 42 | 21 | 192 | loose |
| Future | Argentiny | 49 | 43 | 175 | loose |
| Future | Asshole | 55 | 52 | 374 | loose |
| Future | Astronaut Chick | 44 | 48 | 315 | loose |
| Future | Astronauts | 54 | 57 | 325 | loose |
| Future | Attack | 38 | 29 | 181 | loose |
| Future | BACK TO THE BASICS | 30 | 26 | 154 | loose |
| Future | BAD BITCH PARTY | 45 | 64 | 268 | loose |
| Future | BIG 3 ATL | 77 | 90 | 349 | loose |
| Future | BRAZZIER | 48 | 79 | 364 | loose |
| Future | Baby Sasuke | 45 | 60 | 231 | loose |
| Future | Back of the Ghost | 58 | 45 | 176 | loose |
| Future | Back on Wall | 42 | 27 | 135 | loose |
| Future | Bad Habit | 18 | 6 | 88 | loose |
| Future | Bad Habits* | 3 | 3 | 22 | loose |
| Future | Bad for Your Health* | 3 | 0 | 5 | loose |
| Future | Bag | 54 | 58 | 66 | loose |
| Future | Ball Forever | 33 | 38 | 196 | loose |
| Future | Ballin’ | 44 | 29 | 182 | loose |
| Future | Ballin’, Flexin’ | 39 | 13 | 212 | loose |
| Future | Bankroll | 52 | 57 | 241 | loose |
| Future | Baptiize | 47 | 52 | 350 | loose |
| Future | Be Encouraged | 22 | 24 | 128 | loose |
| Future | Be Yourself | 27 | 31 | 132 | loose |
| Future | Beat It | 41 | 58 | 226 | loose |
| Future | Beat The Case* | 7 | 4 | 23 | loose |
| Future | Because of You | 45 | 70 | 173 | loose |
| Future | Benz Friendz (Whatchutola) | 73 | 27 | 538 | loose |
| Future | Best 2 Shine | 41 | 48 | 279 | loose |
| Future | Big Dawg* | 7 | 3 | 10 | loose |
| Future | Big Moment | 59 | 85 | 436 | loose |
| Future | Big Rube Speaks | 21 | 15 | 139 | loose |
| Future | Bigger Picture | 37 | 39 | 321 | loose |
| Future | Birds Eye View | 65 | 135 | 208 | loose |
| Future | Birds Take A Bath | 67 | 53 | 115 | loose |
| Future | Birthday | 37 | 27 | 101 | loose |
| Future | Birthday Wars | 32 | 36 | 190 | loose |
| Future | Bishop Certified Legendary Speaks (Interlude) | 15 | 4 | 61 | loose |
| Future | Bitches Ain’t Shit | 60 | 59 | 233 | loose |
| Future | Bitches Gone Tell | 33 | 11 | 129 | loose |
| Future | Black Jew | 33 | 34 | 119 | loose |
| Future | Blast Off | 50 | 52 | 181 | loose |
| Future | Blood on the Money | 64 | 37 | 247 | loose |
| Future | Blood, Sweat, Tears | 31 | 16 | 165 | loose |
| Future | Blow | 65 | 32 | 234 | loose |
| Future | Blow a Bag | 43 | 24 | 181 | loose |
| Future | Boom Boom Boom | 38 | 39 | 167 | loose |
| Future | Bosses | 34 | 38 | 216 | loose |
| Future | Bought a Bad Bitch | 71 | 67 | 254 | loose |
| Future | Brain On Drugz | 25 | 8 | 83 | loose |
| Future | Break a Brick | 31 | 33 | 119 | loose |
| Future | Break the Rules | 29 | 30 | 257 | loose |
| Future | Brett Montana | 22 | 21 | 59 | loose |
| Future | Brinks Truck | 39 | 24 | 180 | loose |
| Future | Build a Bitch | 28 | 25 | 172 | loose |
| Future | Built to Last | 52 | 83 | 243 | loose |
| Future | Bum Bum Tam Tam (Mixed) | 18 | 12 | 76 | loose |
| Future | Bust Down | 24 | 29 | 72 | loose |
| Future | Bust a Move | 69 | 104 | 307 | loose |
| Future | Bustin’ Out | 72 | 51 | 173 | loose |
| Future | Buy Love | 34 | 26 | 137 | loose |
| Future | Bye Bye | 30 | 40 | 181 | loose |
| Future | CHICKENS | 55 | 52 | 321 | loose |
| Future | CRY FOR YOU* | 4 | 1 | 7 | loose |
| Future | CUDDLE MY WRIST | 50 | 68 | 206 | loose |
| Future | California Girls | 24 | 10 | 80 | loose |
| Future | Call Me Bart | 51 | 58 | 302 | loose |
| Future | Call the Coroner | 22 | 33 | 155 | loose |
| Future | Came from Nothing | 38 | 19 | 130 | loose |
| Future | Came to the Party | 30 | 30 | 181 | loose |
| Future | Can’t Make This Up | 64 | 57 | 260 | loose |
| Future | Can’t Say Sorry | 24 | 14 | 155 | loose |
| Future | Cast a Spell | 48 | 48 | 241 | loose |
| Future | Cee-Lo | 33 | 27 | 139 | loose |
| Future | Chain Cost a House (Demo) | 31 | 6 | 79 | loose |
| Future | Championship Music (Remix) | 40 | 38 | 219 | loose |
| Future | Chanel Harmony | 22 | 4 | 33 | loose |
| Future | Change Her Life | 68 | 96 | 277 | loose |
| Future | Charged Up | 19 | 4 | 69 | loose |
| Future | Check My Swagg (Original) | 39 | 40 | 192 | loose |
| Future | Chop Chop | 55 | 54 | 339 | loose |
| Future | Chosen One | 31 | 29 | 191 | loose |
| Future | Cinderella | 43 | 84 | 133 | loose |
| Future | Cinderella AI Remaster | 21 | 17 | 53 | loose |
| Future | Cinderella [Demo] | 5 | 6 | 30 | AABA |
| Future | Claustrophobic | 49 | 51 | 284 | loose |
| Future | Club On Smash | 32 | 8 | 153 | loose |
| Future | Code We Honor | 46 | 62 | 253 | loose |
| Future | Code of Silence | 23 | 24 | 98 | loose |
| Future | Codeine Crazy | 103 | 102 | 347 | loose |
| Future | Colossal | 55 | 64 | 216 | loose |
| Future | Come On Over | 23 | 4 | 26 | loose |
| Future | Comin Out Strong | 53 | 42 | 256 | loose |
| Future | Coming Home | 41 | 18 | 89 | loose |
| Future | Conceited | 46 | 102 | 301 | loose |
| Future | Count Up | 44 | 29 | 162 | loose |
| Future | Coupe | 28 | 38 | 136 | loose |
| Future | Covered In Blood | 32 | 32 | 100 | loose |
| Future | Covered N Money | 52 | 51 | 207 | loose |
| Future | Crazy Clientele | 34 | 44 | 239 | loose |
| Future | Crossed Out | 29 | 19 | 173 | loose |
| Future | Crowd Surf | 19 | 8 | 143 | loose |
| Future | Crushed Up | 31 | 34 | 106 | loose |
| Future | Crying In Magic* | 10 | 2 | 29 | loose |
| Future | Cum | 33 | 9 | 88 | loose |
| Future | D4L | 41 | 22 | 163 | loose |
| Future | DEAD (Demo) | 55 | 45 | 209 | loose |
| Future | DNA | 34 | 13 | 174 | loose |
| Future | DOH DOH | 45 | 75 | 265 | loose |
| Future | Damage | 56 | 26 | 156 | loose |
| Future | Day One | 45 | 29 | 183 | loose |
| Future | Daytona | 56 | 32 | 284 | loose |
| Future | Dead People | 42 | 36 | 230 | loose |
| Future | Dead Prez | 35 | 40 | 78 | loose |
| Future | Deeper Than the Ocean | 42 | 25 | 116 | loose |
| Future | Dem | 32 | 14 | 177 | loose |
| Future | Diamonds Dancing (Demo) | 29 | 8 | 149 | loose |
| Future | Diamonds from Africa | 52 | 64 | 217 | loose |
| Future | Different | 47 | 49 | 271 | loose |
| Future | Directional | 15 | 1 | 32 | loose |
| Future | Dirty Sprite | 38 | 27 | 179 | loose |
| Future | Do It To Em | 25 | 12 | 98 | loose |
| Future | Dominican & Colombian | 5 | 1 | 15 | ABCB |
| Future | Doo Wop | 43 | 57 | 258 | loose |
| Future | Dope Fiend | 56 | 39 | 122 | loose |
| Future | Double Cup & Molly | 48 | 38 | 215 | loose |
| Future | Down & Out (Demo) | 34 | 15 | 159 | loose |
| Future | Draco | 82 | 88 | 186 | loose |
| Future | Drankin N Smokin | 42 | 50 | 256 | loose |
| Future | Drink N Dance | 32 | 19 | 128 | loose |
| Future | Drip on Me | 45 | 53 | 165 | loose |
| Future | Drippin (How U Luv That) | 37 | 26 | 147 | loose |
| Future | Drive Itself | 40 | 52 | 347 | loose |
| Future | Drug Lord | 36 | 29 | 144 | loose |
| Future | Déjà Vu (Remix) | 6 | 7 | 16 | loose |
| Future | E | 47 | 28 | 146 | loose |
| Future | Easter Pink | 47 | 32 | 287 | loose |
| Future | Eat Dat Up | 27 | 15 | 65 | loose |
| Future | Esse | 47 | 47 | 227 | loose |
| Future | Everybody | 42 | 48 | 270 | loose |
| Future | Everyday Hustle | 75 | 71 | 377 | loose |
| Future | Everything Ours | 31 | 39 | 124 | loose |
| Future | Extra | 27 | 14 | 134 | loose |
| Future | Extra Luv | 47 | 19 | 128 | loose |
| Future | Eye To Eye | 35 | 17 | 266 | loose |
| Future | F&N | 53 | 60 | 261 | loose |
| Future | FOR A NUT | 42 | 35 | 205 | loose |
| Future | FRESH FOR THE ISLAND* | 7 | 5 | 22 | loose |
| Future | Faceshot | 43 | 49 | 185 | loose |
| Future | Fall In Love | 22 | 15 | 102 | loose |
| Future | Fears* | 11 | 2 | 46 | loose |
| Future | Feds Did a Sweep | 67 | 74 | 137 | loose |
| Future | Feed Me Dope | 36 | 24 | 193 | loose |
| Future | Feeling I Get | 51 | 20 | 258 | loose |
| Future | Feeling I Give | 15 | 4 | 33 | loose |
| Future | Fetti | 50 | 54 | 120 | loose |
| Future | Fettuccine | 45 | 49 | 233 | loose |
| Future | Fine China | 28 | 33 | 120 | loose |
| Future | Fine Shyt | 67 | 48 | 633 | loose |
| Future | Finessin | 30 | 16 | 239 | loose |
| Future | First Class Flights | 33 | 50 | 212 | loose |
| Future | First Off | 47 | 38 | 277 | loose |
| Future | Fishscale | 38 | 25 | 211 | loose |
| Future | Flip | 49 | 38 | 182 | loose |
| Future | Fly Shit Only | 41 | 22 | 190 | loose |
| Future | Forever Eva | 67 | 24 | 349 | loose |
| Future | Fo’ Real | 37 | 24 | 180 | loose |
| Future | Freak Hoe | 27 | 39 | 177 | loose |
| Future | Free at Last | 3 | 0 | 6 | loose |
| Future | Freeband Bandit | 42 | 44 | 288 | loose |
| Future | Freeband Gang | 13 | 7 | 95 | loose |
| Future | Freeband Taliban | 66 | 109 | 182 | loose |
| Future | Freebandz | 44 | 30 | 242 | loose |
| Future | Fresh Air | 37 | 12 | 128 | loose |
| Future | Fresh Out The Booth | 9 | 5 | 22 | loose |
| Future | Fresh for the Love | 50 | 32 | 262 | loose |
| Future | Fried (She a Vibe) | 47 | 33 | 288 | loose |
| Future | Friends | 28 | 32 | 55 | loose |
| Future | Fuck Up Some Commas | 41 | 29 | 257 | loose |
| Future | Fuck You Gone Tell | 30 | 0 | 422 | loose |
| Future | Fuck You Mean (WTFYM Original) | 71 | 76 | 428 | loose |
| Future | Fuck You Thought | 33 | 18 | 74 | loose |
| Future | Fuck on You | 17 | 20 | 46 | loose |
| Future | Fuk Is U Doin’ | 38 | 46 | 83 | loose |
| Future | Future Back | 27 | 26 | 116 | loose |
| Future | Future Speaks (1) | 8 | 2 | 16 | loose |
| Future | GOLD STACKS | 33 | 38 | 256 | loose |
| Future | GTA | 37 | 31 | 149 | loose |
| Future | Game Time | 42 | 48 | 144 | loose |
| Future | Gang Gang Anyway | 27 | 38 | 178 | loose |
| Future | Gangland | 60 | 41 | 223 | loose |
| Future | Georgia | 28 | 26 | 129 | loose |
| Future | Gettin’ It In | 44 | 36 | 131 | loose |
| Future | Gettin’ Outta Hand | 31 | 16 | 206 | loose |
| Future | Glove | 29 | 11 | 69 | loose |
| Future | Go Harder | 44 | 37 | 311 | loose |
| Future | Goin Dummi | 33 | 33 | 173 | loose |
| Future | Goin’ In, Goin’ Out | 20 | 4 | 38 | loose |
| Future | Gone To The Moon | 56 | 67 | 67 | loose |
| Future | Good Dope | 33 | 32 | 126 | loose |
| Future | Good Look | 26 | 14 | 142 | loose |
| Future | Good Morning | 26 | 14 | 99 | loose |
| Future | Gorgeous | 36 | 27 | 114 | loose |
| Future | Got Her Thirsty | 43 | 17 | 162 | loose |
| Future | Government Official | 32 | 23 | 221 | loose |
| Future | Gracious | 28 | 21 | 89 | loose |
| Future | Graduated | 11 | 9 | 70 | loose |
| Future | Grandma | 18 | 6 | 94 | loose |
| Future | Group Home | 51 | 27 | 216 | loose |
| Future | Groupies | 48 | 36 | 146 | loose |
| Future | Guap on Me | 66 | 102 | 201 | loose |
| Future | Gunpowder | 44 | 30 | 264 | loose |
| Future | HATE THE REAL ME | 43 | 18 | 146 | loose |
| Future | HOLY GHOST | 43 | 52 | 356 | loose |
| Future | Hallucinating | 33 | 41 | 124 | loose |
| Future | Hands On U | 38 | 13 | 210 | loose |
| Future | Hard | 42 | 49 | 228 | loose |
| Future | Hard Work Pays Off | 40 | 31 | 184 | loose |
| Future | Hard to Choose One | 50 | 70 | 196 | loose |
| Future | Hardly | 41 | 18 | 184 | loose |
| Future | Harlem Shake | 19 | 9 | 49 | loose |
| Future | Hate in Your Soul | 41 | 17 | 157 | loose |
| Future | Hater Shit | 38 | 39 | 179 | loose |
| Future | Heart in Pieces | 62 | 75 | 336 | loose |
| Future | Helluva Nigga | 54 | 70 | 243 | loose |
| Future | HiTek Tek | 47 | 48 | 208 | loose |
| Future | High Demand | 44 | 43 | 144 | loose |
| Future | Hit Licks | 49 | 32 | 189 | loose |
| Future | Hit My Line | 61 | 55 | 164 | loose |
| Future | Hittas* | 4 | 0 | 4 | loose |
| Future | Hoes Go Crazy | 21 | 11 | 69 | loose |
| Future | Hold Up | 41 | 12 | 42 | loose |
| Future | Hollywood | 5 | 4 | 16 | AAAA |
| Future | Homicide | 42 | 28 | 248 | loose |
| Future | Honest | 38 | 10 | 174 | loose |
| Future | How Can I Not | 36 | 52 | 358 | loose |
| Future | How It Feel | 98 | 68 | 294 | loose |
| Future | How It Was | 50 | 45 | 177 | loose |
| Future | Hustle | 54 | 37 | 193 | loose |
| Future | I Be U | 36 | 17 | 71 | loose |
| Future | I Been Drinking | 33 | 29 | 131 | loose |
| Future | I Can’t Believe It (Moving On) | 20 | 17 | 81 | loose |
| Future | I Can’t Wait (Show Off) | 36 | 25 | 116 | loose |
| Future | I Don’t Wanna Break Up | 54 | 72 | 292 | loose |
| Future | I Got Yo Bitch | 49 | 35 | 203 | loose |
| Future | I Hate What Happened | 44 | 50 | 262 | loose |
| Future | I Need That (Vice Versa) | 33 | 33 | 233 | loose |
| Future | I Serve the Base | 48 | 27 | 132 | loose |
| Future | I Thank U | 32 | 18 | 69 | loose |
| Future | I Won | 36 | 18 | 144 | loose |
| Future | I won me a trophy | 27 | 18 | 65 | loose |
| Future | I.C.W.N.T. (Freestyle) | 40 | 43 | 224 | loose |
| Future | Ice Attack | 43 | 21 | 238 | loose |
| Future | Icy Icy | 46 | 33 | 197 | loose |
| Future | If I Could | 45 | 58 | 277 | loose |
| Future | If You Knew What It Took | 34 | 18 | 168 | loose |
| Future | Im Good | 45 | 44 | 189 | loose |
| Future | In Abundance | 46 | 27 | 186 | loose |
| Future | In Her Mouth | 33 | 25 | 199 | loose |
| Future | In My Heart* | 14 | 6 | 56 | loose |
| Future | In Out Time | 40 | 17 | 152 | loose |
| Future | In The Strip Club | 41 | 24 | 98 | loose |
| Future | Incredible | 52 | 30 | 154 | loose |
| Future | Inside the Mattress | 54 | 47 | 200 | loose |
| Future | Inspiration | 20 | 9 | 79 | loose |
| Future | Intro (1000) | 8 | 0 | 31 | loose |
| Future | Ion Wanna Die | 55 | 51 | 328 | loose |
| Future | Itchin’ | 30 | 42 | 84 | loose |
| Future | I’M DAT NIGGA | 65 | 65 | 323 | loose |
| Future | I’M ON ONE | 48 | 53 | 221 | loose |
| Future | I’ll Be Yours | 31 | 11 | 78 | loose |
| Future | I’m So Groovy | 84 | 43 | 115 | loose |
| Future | I’m Trippin’ | 59 | 41 | 295 | loose |
| Future | I’m the One | 34 | 29 | 126 | loose |
| Future | JUST THE BEGINNING | 64 | 46 | 172 | loose |
| Future | Jealous | 30 | 44 | 89 | loose |
| Future | Jersey | 36 | 44 | 126 | loose |
| Future | Jet Lag | 66 | 66 | 241 | loose |
| Future | Jordan Diddy | 49 | 29 | 195 | loose |
| Future | Jumpin on a Jet | 28 | 17 | 81 | loose |
| Future | Just Get This Money | 42 | 39 | 243 | loose |
| Future | Just Like Bruddas | 38 | 20 | 187 | loose |
| Future | Just Like Chapo | 62 | 90 | 357 | loose |
| Future | Just Like I Want | 39 | 13 | 252 | loose |
| Future | Just Wait On It | 62 | 48 | 204 | loose |
| Future | KEEP IT BURNIN | 54 | 40 | 276 | loose |
| Future | Karate Chop | 45 | 42 | 157 | loose |
| Future | Karate Shop | 5 | 1 | 6 | loose |
| Future | Karma | 54 | 48 | 195 | loose |
| Future | Keep Goin’ | 9 | 2 | 22 | loose |
| Future | Keep Quiet | 50 | 48 | 219 | loose |
| Future | Keep on Shinin’ | 49 | 31 | 203 | loose |
| Future | Kendall Jenner* | 5 | 5 | 17 | loose |
| Future | Keys | 22 | 18 | 101 | loose |
| Future | Kick | 30 | 24 | 115 | loose |
| Future | Kno the Meaning | 62 | 37 | 232 | loose |
| Future | Knock His Head Off | 33 | 16 | 296 | loose |
| Future | Konnichiwa | 34 | 35 | 323 | loose |
| Future | Krazy but True | 33 | 13 | 164 | loose |
| Future | Ku Klux Klan | 55 | 98 | 140 | loose |
| Future | LIKE ME | 32 | 23 | 242 | loose |
| Future | LIKE THAT (Remix) [Original] | 29 | 25 | 142 | loose |
| Future | LIL DEMON | 37 | 40 | 56 | loose |
| Future | LOST MY DOG | 22 | 19 | 126 | loose |
| Future | LOVE YOU BETTER | 12 | 2 | 53 | loose |
| Future | Last Breath | 59 | 46 | 258 | loose |
| Future | Last Name | 45 | 71 | 219 | loose |
| Future | Lay Up | 55 | 36 | 152 | loose |
| Future | Layover | 43 | 31 | 274 | loose |
| Future | Let This Money Go | 55 | 36 | 223 | loose |
| Future | Lie (No Lie) | 45 | 43 | 182 | loose |
| Future | Lie to Me | 50 | 46 | 173 | loose |
| Future | Life Is Good | 56 | 79 | 397 | loose |
| Future | Life Of A G | 31 | 14 | 190 | loose |
| Future | Like Ohh | 51 | 44 | 145 | loose |
| Future | Like That | 65 | 52 | 269 | loose |
| Future | Lil Haiti Baby | 65 | 37 | 451 | loose |
| Future | Lil Mexico Lingo | 28 | 32 | 121 | loose |
| Future | Lil One | 38 | 20 | 114 | loose |
| Future | Lined Up | 50 | 36 | 192 | loose |
| Future | Long Time Coming | 37 | 19 | 149 | loose |
| Future | Look Ahead | 45 | 36 | 155 | loose |
| Future | Look What U Started | 38 | 49 | 486 | loose |
| Future | Lookin Exotic | 44 | 55 | 230 | loose |
| Future | Lose It All Today | 26 | 10 | 24 | loose |
| Future | Love Thy Enemies | 16 | 6 | 46 | loose |
| Future | Low Life | 68 | 60 | 269 | loose |
| Future | Luv Bad Bitches | 24 | 10 | 76 | loose |
| Future | MADE MY HOE FAINT | 28 | 12 | 161 | loose |
| Future | MASSAGING ME | 34 | 15 | 152 | loose |
| Future | MJ | 14 | 10 | 59 | loose |
| Future | Mad Luv | 55 | 61 | 158 | loose |
| Future | Made Man* | 7 | 1 | 13 | loose |
| Future | Made Myself a Boss | 37 | 35 | 184 | loose |
| Future | Made Sexy* | 22 | 15 | 66 | loose |
| Future | Magic | 39 | 27 | 150 | loose |
| Future | Magic Don Juan (Princess Diana) | 58 | 37 | 296 | loose |
| Future | Maison Margiela | 39 | 37 | 142 | loose |
| Future | Maniac | 60 | 58 | 115 | loose |
| Future | March Madness | 48 | 58 | 155 | loose |
| Future | Mark McGwire | 28 | 9 | 143 | loose |
| Future | Marni On Me | 42 | 84 | 112 | loose |
| Future | Mask Off | 35 | 35 | 97 | loose |
| Future | Massage in My Room | 32 | 33 | 65 | loose |
| Future | Match My Speed | 59 | 24 | 205 | loose |
| Future | Maybach | 84 | 71 | 237 | loose |
| Future | Might as Well | 60 | 49 | 160 | loose |
| Future | Mile High Memories | 30 | 24 | 134 | loose |
| Future | Million Dollar Play | 49 | 56 | 200 | loose |
| Future | Mind Blown | 39 | 44 | 196 | loose |
| Future | Mind Right | 27 | 27 | 152 | loose |
| Future | Mink Flow | 53 | 58 | 212 | loose |
| Future | Missing | 45 | 29 | 210 | loose |
| Future | Mogul Mode (Ready to Shoot) | 68 | 76 | 368 | loose |
| Future | Molly And Xan* | 4 | 1 | 7 | loose |
| Future | Moment of Clarity | 66 | 87 | 233 | loose |
| Future | Monaco | 15 | 9 | 56 | loose |
| Future | Money Forever | 50 | 44 | 276 | loose |
| Future | Money Over Everything | 39 | 44 | 182 | loose |
| Future | Money Train | 36 | 42 | 141 | loose |
| Future | Monster | 35 | 29 | 256 | loose |
| Future | Motion Picture | 40 | 36 | 222 | loose |
| Future | Move That Dope | 86 | 62 | 437 | loose |
| Future | Move That Dope (Radio Edit) | 24 | 4 | 144 | loose |
| Future | Much More | 50 | 28 | 202 | loose |
| Future | My Collection | 50 | 42 | 228 | loose |
| Future | My Favorite | 4 | 1 | 8 | loose |
| Future | My Ho 2 | 37 | 37 | 178 | loose |
| Future | My Legacy | 59 | 94 | 167 | loose |
| Future | My Momma | 46 | 30 | 320 | loose |
| Future | My Savages | 61 | 47 | 279 | loose |
| Future | My Wrath | 66 | 27 | 431 | loose |
| Future | NASA | 27 | 12 | 121 | loose |
| Future | NO SECURITY | 34 | 25 | 215 | loose |
| Future | Name Hold Weight | 37 | 44 | 221 | loose |
| Future | Neglected | 40 | 48 | 157 | loose |
| Future | Neva End | 41 | 35 | 211 | loose |
| Future | Neva Missa Lost | 43 | 23 | 138 | loose |
| Future | Never Be The Same | 44 | 36 | 208 | loose |
| Future | Never Been This High | 38 | 27 | 249 | loose |
| Future | Never Coming Back To Earth* | 45 | 26 | 175 | loose |
| Future | Never Forget | 35 | 55 | 194 | loose |
| Future | Never Gon Lose | 65 | 74 | 283 | loose |
| Future | Never Satisfied | 29 | 33 | 118 | loose |
| Future | Never Seen These | 27 | 10 | 114 | loose |
| Future | Never Stop | 68 | 141 | 403 | loose |
| Future | Never There | 31 | 24 | 101 | loose |
| Future | New Illuminati | 34 | 9 | 64 | loose |
| Future | News or Something | 45 | 49 | 269 | loose |
| Future | Nights Like This | 37 | 23 | 148 | loose |
| Future | No Basic | 42 | 23 | 166 | loose |
| Future | No Brainer | 34 | 25 | 170 | loose |
| Future | No Cap | 53 | 60 | 202 | loose |
| Future | No Charge | 26 | 15 | 121 | loose |
| Future | No Compadre | 55 | 37 | 178 | loose |
| Future | No Issue | 52 | 50 | 217 | loose |
| Future | No Love | 44 | 24 | 66 | loose |
| Future | No Matter What | 40 | 18 | 174 | loose |
| Future | No Misery | 24 | 22 | 141 | loose |
| Future | No More | 20 | 22 | 97 | loose |
| Future | No Shame | 30 | 29 | 112 | loose |
| Future | No Sleep (Intro) | 30 | 15 | 150 | loose |
| Future | No Wallet | 45 | 49 | 247 | loose |
| Future | Nobody Knows My Struggle | 37 | 23 | 151 | loose |
| Future | Nothing Is Promised | 42 | 21 | 152 | loose |
| Future | Notice Me | 29 | 4 | 217 | loose |
| Future | Now | 43 | 14 | 218 | loose |
| Future | Nowhere | 45 | 81 | 157 | loose |
| Future | Nunbout U | 72 | 94 | 186 | loose |
| Future | OATH | 26 | 48 | 278 | loose |
| Future | OCEAN | 63 | 58 | 501 | loose |
| Future | Obama (Original) | 40 | 49 | 185 | loose |
| Future | Off Dat | 47 | 72 | 255 | loose |
| Future | Off the Hinge | 29 | 40 | 253 | loose |
| Future | Oh Yeah | 49 | 41 | 77 | loose |
| Future | Old Hundreds | 36 | 38 | 195 | loose |
| Future | On 2 Us | 34 | 23 | 155 | loose |
| Future | On Purpose | 37 | 27 | 158 | loose |
| Future | One Big Family | 68 | 81 | 283 | loose |
| Future | One Helluva Night | 48 | 37 | 122 | loose |
| Future | One Minute | 36 | 47 | 309 | loose |
| Future | One Two | 37 | 28 | 143 | loose |
| Future | One of My | 30 | 17 | 93 | loose |
| Future | Ones | 3 | 0 | 7 | loose |
| Future | Oooooh | 42 | 17 | 178 | loose |
| Future | Opps* | 3 | 0 | 6 | loose |
| Future | Osama (O’s) | 47 | 25 | 164 | loose |
| Future | Out Da Mudd | 45 | 49 | 204 | loose |
| Future | Out Of My Hands | 49 | 41 | 416 | loose |
| Future | Outer Space Bih | 28 | 32 | 115 | loose |
| Future | Outta Here | 47 | 58 | 212 | loose |
| Future | Outta Time | 32 | 24 | 145 | loose |
| Future | Over Your Head | 45 | 77 | 397 | loose |
| Future | Overdose | 34 | 36 | 157 | loose |
| Future | Overload | 54 | 111 | 145 | loose |
| Future | Oxy | 49 | 76 | 114 | loose |
| Future | PIE | 37 | 23 | 145 | loose |
| Future | PINK N BLUE | 65 | 89 | 355 | loose |
| Future | PLUTOSKI | 45 | 32 | 89 | loose |
| Future | POA | 83 | 68 | 163 | loose |
| Future | PRESS THE BUTTON | 58 | 58 | 276 | loose |
| Future | PUFFIN ON ZOOTIEZ | 55 | 58 | 274 | loose |
| Future | Pajamas | 48 | 28 | 165 | loose |
| Future | Paparazzi (Dab) | 41 | 45 | 118 | loose |
| Future | Parachute | 54 | 16 | 146 | loose |
| Future | Paradise | 35 | 60 | 178 | loose |
| Future | Pass the Plate | 39 | 30 | 161 | loose |
| Future | Patek | 100 | 175 | 445 | loose |
| Future | Patek Water | 38 | 33 | 247 | loose |
| Future | Peacoat | 40 | 23 | 125 | loose |
| Future | Perkies | 89 | 94 | 252 | loose |
| Future | Perkys Calling | 45 | 45 | 277 | loose |
| Future | Permanent Scar | 56 | 56 | 219 | loose |
| Future | Pesos (Dinero) | 61 | 89 | 230 | loose |
| Future | Photo Copied | 35 | 13 | 119 | loose |
| Future | Pink Molly* | 4 | 2 | 21 | loose |
| Future | Plastic | 49 | 74 | 113 | loose |
| Future | Please Tell Me | 48 | 39 | 119 | loose |
| Future | Plenty of Pot | 19 | 14 | 92 | loose |
| Future | Pluto’s Ballad | 30 | 24 | 277 | loose |
| Future | Poetry | 53 | 46 | 151 | loose |
| Future | Politics | 35 | 27 | 145 | loose |
| Future | Pop Them Bands | 48 | 38 | 129 | loose |
| Future | Poppin’ Tags | 45 | 25 | 249 | loose |
| Future | Possessed | 21 | 15 | 109 | loose |
| Future | Posted with Demons | 47 | 36 | 245 | loose |
| Future | Power Of That P | 38 | 16 | 236 | loose |
| Future | Pray for a Key | 33 | 31 | 218 | loose |
| Future | Program | 39 | 6 | 153 | loose |
| Future | Promise U That | 41 | 13 | 206 | loose |
| Future | Purple Coming In | 55 | 25 | 119 | loose |
| Future | Purple Reign | 49 | 71 | 239 | loose |
| Future | Put It On The Bible* | 58 | 56 | 202 | loose |
| Future | RACKS BLUE | 31 | 35 | 181 | loose |
| Future | READY TO COOK UP | 27 | 29 | 207 | loose |
| Future | RED LIGHT | 48 | 35 | 239 | loose |
| Future | Rack It | 41 | 38 | 240 | loose |
| Future | Radical | 28 | 20 | 104 | loose |
| Future | Radio | 35 | 47 | 234 | loose |
| Future | Ran Outta Fanta | 35 | 12 | 193 | loose |
| Future | Ransom | 80 | 98 | 354 | loose |
| Future | Raw Fish* | 12 | 13 | 36 | loose |
| Future | Reach Your Heart | 35 | 49 | 180 | loose |
| Future | Ready For War | 25 | 21 | 109 | loose |
| Future | Real (Ghost) | 29 | 25 | 91 | loose |
| Future | Real Baby Pluto | 59 | 56 | 519 | loose |
| Future | Real Love | 57 | 39 | 274 | loose |
| Future | Real Sisters | 35 | 18 | 137 | loose |
| Future | Real and True | 37 | 31 | 158 | loose |
| Future | Realer n Realer | 44 | 58 | 200 | loose |
| Future | Red Bentley | 56 | 66 | 506 | loose |
| Future | Red Carpet | 38 | 21 | 40 | loose |
| Future | Red Leather | 116 | 130 | 582 | loose |
| Future | Regular Party | 27 | 18 | 163 | loose |
| Future | Rehab (Amy Winehouse) | 40 | 52 | 189 | loose |
| Future | Rent Money | 70 | 54 | 363 | loose |
| Future | Reward It* | 19 | 12 | 93 | loose |
| Future | Rich $ex | 49 | 40 | 217 | loose |
| Future | Rider | 38 | 15 | 176 | loose |
| Future | Ridin Strikers | 56 | 32 | 278 | loose |
| Future | Right 4 You | 44 | 18 | 128 | loose |
| Future | Right At The Store | 18 | 15 | 68 | loose |
| Future | Rings On Me | 69 | 84 | 332 | loose |
| Future | Road to Riches | 28 | 19 | 238 | loose |
| Future | Rock Star | 45 | 29 | 221 | loose |
| Future | Rocket Ship | 21 | 30 | 135 | loose |
| Future | Rockstar (2014) | 17 | 17 | 123 | loose |
| Future | Rockstar Chainz | 35 | 20 | 212 | loose |
| Future | Rockstar Life* | 15 | 6 | 45 | loose |
| Future | Rocky | 32 | 23 | 350 | loose |
| Future | Rotation | 33 | 32 | 150 | loose |
| Future | Run Up | 42 | 33 | 283 | loose |
| Future | Runnin Outta Time | 40 | 48 | 179 | loose |
| Future | Running Through A Check | 42 | 48 | 125 | loose |
| Future | SKI | 45 | 46 | 186 | loose |
| Future | SOME MORE | 53 | 74 | 242 | loose |
| Future | SOUTH OF FRANCE | 20 | 16 | 155 | loose |
| Future | STAYED DOWN | 32 | 29 | 137 | loose |
| Future | SURFING A TSUNAMI | 50 | 83 | 273 | loose |
| Future | Salute | 56 | 44 | 250 | loose |
| Future | Same Accord | 34 | 42 | 76 | loose |
| Future | Same Damn Time | 50 | 48 | 252 | loose |
| Future | Same MF | 31 | 12 | 122 | loose |
| Future | Saw You* | 4 | 3 | 5 | loose |
| Future | Scammalot | 31 | 24 | 126 | loose |
| Future | Scrape | 55 | 46 | 121 | loose |
| Future | Secure the Bag | 40 | 24 | 245 | loose |
| Future | Seein’ Demons | 34 | 19 | 88 | loose |
| Future | Seen it All | 46 | 23 | 292 | loose |
| Future | Selfish | 24 | 22 | 62 | loose |
| Future | Servin Killa Kam | 48 | 59 | 245 | loose |
| Future | Seven Rings | 39 | 29 | 169 | loose |
| Future | Sh!t | 53 | 38 | 162 | loose |
| Future | She Never Been to Pluto | 79 | 89 | 334 | loose |
| Future | Shit (Remix) | 66 | 32 | 376 | loose |
| Future | Shoot Out The Coupe | 48 | 50 | 148 | loose |
| Future | Shopping Spree | 62 | 47 | 135 | loose |
| Future | Shorty | 42 | 13 | 86 | loose |
| Future | Shorty My Twin | 9 | 4 | 15 | loose |
| Future | Shotgun | 37 | 33 | 186 | loose |
| Future | Show Money | 42 | 30 | 287 | loose |
| Future | Show My Chain Some Love | 30 | 20 | 151 | loose |
| Future | Show of Hands | 56 | 76 | 313 | loose |
| Future | Showed Up | 32 | 19 | 175 | loose |
| Future | Side Effects | 22 | 6 | 86 | loose |
| Future | Sir (Demo) | 36 | 0 | 138 | loose |
| Future | Skydwella | 44 | 26 | 327 | loose |
| Future | Slave Master | 45 | 20 | 154 | loose |
| Future | Sleeping on the Floor | 60 | 55 | 244 | loose |
| Future | Slimed In | 55 | 24 | 210 | loose |
| Future | Smacked Silly (Rack City Freestyle) | 68 | 47 | 566 | loose |
| Future | Smoke & Mirrors | 27 | 17 | 162 | loose |
| Future | Smoke Tony | 35 | 34 | 175 | loose |
| Future | Snow in Skyami | 29 | 48 | 256 | loose |
| Future | So Cold | 35 | 42 | 221 | loose |
| Future | Solitaires | 52 | 82 | 270 | loose |
| Future | Solo | 37 | 23 | 198 | loose |
| Future | Sorry | 108 | 99 | 509 | loose |
| Future | Space Cadets | 36 | 34 | 114 | loose |
| Future | Spaz On Y’all | 49 | 46 | 273 | loose |
| Future | Special | 50 | 37 | 195 | loose |
| Future | Spicy Chicken | 63 | 114 | 203 | loose |
| Future | Splurge | 42 | 83 | 270 | loose |
| Future | St. Lucia | 45 | 46 | 285 | loose |
| Future | Stains | 32 | 33 | 176 | loose |
| Future | Stand | 59 | 35 | 183 | loose |
| Future | Stars In The Ceiling | 52 | 28 | 217 | loose |
| Future | Statistics | 54 | 41 | 330 | loose |
| Future | Stick Talk | 32 | 13 | 143 | loose |
| Future | Stick to the Models | 46 | 51 | 212 | loose |
| Future | Straight Up | 37 | 21 | 146 | loose |
| Future | Streets Don’t Love | 44 | 30 | 167 | loose |
| Future | Streets Made Me A King | 32 | 19 | 192 | loose |
| Future | Stripes Like Burberry | 68 | 56 | 426 | loose |
| Future | Struggles | 24 | 28 | 28 | loose |
| Future | Stupid AP | 12 | 3 | 20 | loose |
| Future | Styrofoam | 36 | 18 | 93 | loose |
| Future | Substitute Everything | 32 | 25 | 172 | loose |
| Future | Suffocate | 22 | 21 | 73 | loose |
| Future | Super Trapper | 41 | 57 | 245 | loose |
| Future | Superbad | 13 | 8 | 42 | loose |
| Future | Superhero | 90 | 110 | 423 | loose |
| Future | Surf The World | 11 | 6 | 45 | loose |
| Future | Surrounded by Demons* | 8 | 4 | 36 | loose |
| Future | Swap It Out | 43 | 49 | 203 | loose |
| Future | T-Shirt | 32 | 17 | 210 | loose |
| Future | TEFLON DON | 44 | 37 | 208 | loose |
| Future | THE WAY THINGS GOING | 38 | 49 | 220 | loose |
| Future | TOLD MY | 21 | 27 | 129 | loose |
| Future | TOO FAST | 48 | 49 | 211 | loose |
| Future | TRIM (Original) | 50 | 48 | 250 | loose |
| Future | TSUNAMI (Remix) | 77 | 85 | 228 | loose |
| Future | Take Money | 43 | 49 | 291 | loose |
| Future | Take This 4 Granted | 30 | 26 | 126 | loose |
| Future | Take You Back | 28 | 19 | 47 | loose |
| Future | Talk Shit Like a Preacher | 37 | 68 | 76 | loose |
| Future | Tank Top Pluto | 29 | 28 | 101 | loose |
| Future | Temptation | 41 | 30 | 112 | loose |
| Future | Testify | 42 | 48 | 179 | loose |
| Future | That’s It | 49 | 34 | 243 | loose |
| Future | That’s a Check | 57 | 53 | 230 | loose |
| Future | The Future is Now | 20 | 28 | 82 | loose |
| Future | The Intro (Monster) | 3 | 0 | 9 | loose |
| Future | The Matrix (Back to the Basics) | 29 | 48 | 125 | loose |
| Future | The Percocet & Stripper Joint | 29 | 19 | 163 | loose |
| Future | The Way It Go | 50 | 46 | 304 | loose |
| Future | Thinkin’ About Eternity* | 41 | 22 | 235 | loose |
| Future | This Sunday | 41 | 28 | 257 | loose |
| Future | Thought It Was a Drought | 60 | 45 | 216 | loose |
| Future | Three | 53 | 38 | 295 | loose |
| Future | Three Zips | 11 | 7 | 14 | loose |
| Future | Throw Away | 53 | 45 | 220 | loose |
| Future | Throw Away Money | 57 | 42 | 247 | loose |
| Future | Thug Song | 37 | 33 | 291 | loose |
| Future | Thursday | 44 | 46 | 90 | loose |
| Future | Tic Tac | 54 | 80 | 319 | loose |
| Future | Tie My Shoes | 37 | 20 | 183 | loose |
| Future | Tomato Interior | 43 | 40 | 170 | loose |
| Future | Tony Montana | 44 | 49 | 211 | loose |
| Future | Too Comfortable | 48 | 40 | 181 | loose |
| Future | Too Crazy | 146 | 104 | 465 | loose |
| Future | Too Excited | 53 | 24 | 161 | loose |
| Future | Too Faded | 52 | 43 | 173 | loose |
| Future | Touch the Sky | 37 | 39 | 179 | loose |
| Future | Trance | 45 | 37 | 222 | loose |
| Future | Transform | 40 | 30 | 134 | loose |
| Future | Transformer | 41 | 47 | 239 | loose |
| Future | Translator | 20 | 23 | 130 | loose |
| Future | Trap Around The World | 31 | 34 | 173 | loose |
| Future | Trap Niggas | 34 | 40 | 167 | loose |
| Future | Trapped in the Sun | 39 | 52 | 106 | loose |
| Future | Trench Coat | 22 | 5 | 81 | loose |
| Future | Trending Topic | 44 | 47 | 171 | loose |
| Future | Tricks on Me | 47 | 36 | 292 | loose |
| Future | Trillionaire | 53 | 53 | 197 | loose |
| Future | True Story Intro | 11 | 2 | 26 | loose |
| Future | Truth Gonna Hurt You | 43 | 30 | 91 | loose |
| Future | Turn On The Lights [Mike WiLL Remix] | 63 | 39 | 168 | loose |
| Future | Turn On the Lights | 45 | 37 | 147 | loose |
| Future | Turn on Me | 60 | 49 | 255 | loose |
| Future | Tycoon | 39 | 92 | 167 | loose |
| Future | Type Shit | 58 | 41 | 466 | loose |
| Future | Unconditional Love | 34 | 25 | 125 | loose |
| Future | Undefeated | 66 | 85 | 219 | loose |
| Future | Undressed | 5 | 3 | 0 | ABCB |
| Future | Unicorn Purp | 48 | 63 | 426 | loose |
| Future | Up the River | 42 | 47 | 222 | loose |
| Future | Upper Echelon | 58 | 50 | 201 | loose |
| Future | Use Me | 37 | 19 | 129 | loose |
| Future | Used to This | 35 | 26 | 179 | loose |
| Future | Usual | 71 | 58 | 284 | loose |
| Future | VOODOO | 36 | 29 | 207 | loose |
| Future | Vacation | 8 | 1 | 54 | loose |
| Future | WAIT FOR U | 42 | 39 | 243 | loose |
| Future | WAIT FOR U (Mixed) [June 2022] | 10 | 1 | 30 | loose |
| Future | WE JUS WANNA GET HIGH | 31 | 35 | 253 | loose |
| Future | WHEN I THINK ABOUT IT | 34 | 37 | 156 | loose |
| Future | WIFI LIT | 43 | 74 | 193 | loose |
| Future | WORST DAY | 38 | 30 | 192 | loose |
| Future | WRLD on Drugs | 51 | 30 | 117 | loose |
| Future | WTFYM | 63 | 80 | 150 | loose |
| Future | Walk On Minks | 55 | 43 | 180 | loose |
| Future | Walked Into Space | 45 | 38 | 261 | loose |
| Future | Watch This | 45 | 54 | 293 | loose |
| Future | Way Longer (What the Fuck Is Wrong With These Niggas) | 22 | 13 | 94 | loose |
| Future | We Don’t Trust You | 52 | 51 | 247 | loose |
| Future | We Got It (Evidence) | 21 | 35 | 73 | loose |
| Future | We Made Our Own | 43 | 33 | 223 | loose |
| Future | We On Top | 43 | 49 | 279 | loose |
| Future | We Still Don’t Trust You | 11 | 6 | 22 | loose |
| Future | We Winnin | 42 | 67 | 266 | loose |
| Future | Weight Up | 41 | 47 | 164 | loose |
| Future | Wesley Presley | 33 | 24 | 142 | loose |
| Future | What Is It | 34 | 27 | 136 | loose |
| Future | What Is Pluto? (Outro) | 6 | 1 | 21 | loose |
| Future | What It Do | 28 | 28 | 78 | loose |
| Future | What It Is | 46 | 52 | 186 | loose |
| Future | What You Say | 48 | 28 | 322 | loose |
| Future | What’s Up With That | 35 | 34 | 159 | loose |
| Future | What’s Wrong | 36 | 15 | 202 | loose |
| Future | When I Was Broke | 48 | 27 | 137 | loose |
| Future | Wheneva U Get Thru | 18 | 21 | 73 | loose |
| Future | Where I Came From | 37 | 10 | 98 | loose |
| Future | Where My Twin @ | 37 | 28 | 153 | loose |
| Future | Where Ya At | 50 | 36 | 346 | loose |
| Future | Where Ya From | 45 | 62 | 143 | loose |
| Future | Whip Game | 28 | 14 | 102 | loose |
| Future | White and Green | 40 | 47 | 205 | loose |
| Future | Who Knew | 16 | 17 | 80 | loose |
| Future | Whole Lotta | 7 | 2 | 2 | loose |
| Future | Whole Lotta Racks | 41 | 29 | 106 | loose |
| Future | Wicked | 36 | 30 | 133 | loose |
| Future | Woah* | 39 | 18 | 77 | loose |
| Future | Wolf | 36 | 15 | 197 | loose |
| Future | Word To My Muva | 45 | 48 | 204 | loose |
| Future | XanaX Damage | 14 | 5 | 52 | loose |
| Future | Xanny Family | 25 | 28 | 161 | loose |
| Future | YSL Cheetah | 39 | 40 | 230 | loose |
| Future | Yeah Yeah | 37 | 31 | 226 | loose |
| Future | You Deserve It | 40 | 28 | 131 | loose |
| Future | You Wonder | 36 | 47 | 288 | loose |
| Future | You da Baddest | 49 | 88 | 223 | loose |
| Future | Young Metro | 44 | 54 | 204 | loose |
| Future | You’ll Never Understand (From Another Planet) | 20 | 12 | 97 | loose |
| Future | Zoom | 77 | 40 | 324 | loose |
