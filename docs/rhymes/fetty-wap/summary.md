# Fetty Wap rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Fetty Wap
- Songs: 563
- Bars kept (Fetty Wap lyric lines): 20282
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 40
- Canonical name: Fetty Wap.
- Credit strings: Fetty Wap.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 106259
- REPEAT pairs, recorded separately: 19995
- END rhymes: 18090
- INNER rhymes: 88169

By match:

- PERFECT: 10135 (END 2823, INNER 7312)
- SLANT: 46725 (END 7737, INNER 38988)
- ASSONANCE: 48297 (END 7230, INNER 41067)
- MULTI: 1102 (END 300, INNER 802)

By confidence:

- HIGH: 10175
- MED: 89120
- LOW: 6964

## Core

- Core Y: 104237
- Core N among rhyme pairs: 2022

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 50907 (47.9%)
- vowel: 48297 (45.5%)
- spelling: 5953 (5.6%)
- multi: 1102 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 2 songs
- loose: 561 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 7928 pairs (END 1425, INNER 6503). Words: baby, ain't, way, say, play, stay, make, ain’t.
2. `vow:OW` — 6512 pairs (END 701, INNER 5811). Words: know, don't, no, go, only, show, don’t, roll.
3. `vow:IH` — 6146 pairs (END 799, INNER 5347). Words: shit, bitch, bitches, think, hit, different, really, million.
4. `vow:EH` — 5322 pairs (END 505, INNER 4817). Words: get, when, never, remember, let, gettin, tell, spend.
5. `vow:AE` — 4171 pairs (END 752, INNER 3419). Words: bands, can't, back, can, had, have, cash, ass.
6. `vow:AA` — 4046 pairs (END 433, INNER 3613). Words: got, want, cause, hard, wanna, cars, nothin, talkin.
7. `vow:AY` — 3764 pairs (END 737, INNER 3027). Words: like, why, high, time, diamonds, right, by, try.
8. `vow:IY` — 3541 pairs (END 591, INNER 2950). Words: see, need, these, even, keep, streets, shawty, free.
9. `vow:AH` — 3189 pairs (END 364, INNER 2825). Words: love, what, fuck, money, hundred, some, couple, nothing.
10. `slant:AA:stop` — 2219 pairs (END 236, INNER 1983). Words: got, want, gotta, drop, block, top, not, squad.
11. `slant:EY:stop` — 2140 pairs (END 447, INNER 1693). Words: baby, make, take, babe, made, hate, ain't, straight.
12. `slant:IH:stop` — 2109 pairs (END 418, INNER 1691). Words: nigga, shit, hit, big, whip, dick, quick, flip.
13. `cmu:OW` — 1701 pairs (END 347, INNER 1354). Words: know, go, no, show, though, throw, blow, low.
14. `slant:IH:sib-stop` — 1654 pairs (END 430, INNER 1224). Words: bitch, nigga, niggas, shit, hit, rich, dick, whip.
15. `slant:EY:sib-stop` — 1346 pairs (END 432, INNER 914). Words: baby, crazy, always, face, make, place, days, ways.
16. `vow:UW` — 1340 pairs (END 364, INNER 976). Words: zoo, through, new, move, who, coupe, two, used.
17. `slant:EH:stop` — 1283 pairs (END 155, INNER 1128). Words: get, said, let, better, fetty, check, ready, head.
18. `slant:EH:nas-stop` — 1239 pairs (END 29, INNER 1210). Words: when, get, let, em, remy, said, many, better.
19. `slant:AY:stop` — 1235 pairs (END 304, INNER 931). Words: like, right, ride, light, night, might, type, side.
20. `slant:EY:nas-stop` — 1234 pairs (END 203, INNER 1031). Words: baby, name, make, take, came, chain, ain't, same.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 1316 pair sides, mostly spelling via spelling phonetic key, often with niggas (370)
- ima — 662 pair sides, mostly spelling via spelling phonetic key, often with bitch (69)
- niggas — 599 pair sides, mostly spelling via spelling phonetic key, often with nigga (370)
- tryna — 347 pair sides, mostly spelling via spelling phonetic key, often with these (47)
- gon — 343 pair sides, mostly spelling via spelling phonetic key, often with dont (97)
- wap — 215 pair sides, mostly spelling via spelling phonetic key, often with man (23)
- shawty — 189 pair sides, mostly vowel via spelling phonetic key, often with baby (43)
- bando — 135 pair sides, mostly vowel via spelling phonetic key, often with go (21)
- imma — 130 pair sides, mostly vowel via spelling phonetic key, often with nigga (45)
- rari — 90 pair sides, mostly spelling via spelling phonetic key, often with bad (8)
- zoovie — 79 pair sides, mostly spelling via spelling phonetic key, often with movie (8)
- bling — 67 pair sides, mostly spelling via spelling phonetic key, often with bitch (10)
- guap — 66 pair sides, mostly spelling via spelling phonetic key, often with money (11)
- quiero — 54 pair sides, mostly vowel via spelling phonetic key, often with dinero (5)
- homie — 52 pair sides, mostly spelling via spelling phonetic key, often with broke (5)
- bros — 52 pair sides, mostly spelling via spelling phonetic key, often with know (12)
- stongo — 52 pair sides, mostly vowel via spelling phonetic key, often with fatto (12)
- tengo — 48 pair sides, mostly vowel via spelling phonetic key, often with en (4)
- lambo — 46 pair sides, mostly vowel via spelling phonetic key, often with go (6)
- dinero — 44 pair sides, mostly vowel via spelling phonetic key, often with quiero (5)
- quanno — 42 pair sides, mostly vowel via spelling phonetic key, often with stongo (12)
- fatto — 41 pair sides, mostly vowel via spelling phonetic key, often with stongo (12)
- zoowap — 36 pair sides, mostly spelling via spelling phonetic key, often with trap (10)
- swerving — 36 pair sides, mostly spelling via spelling phonetic key, often with serving (3)
- zoovier — 35 pair sides, mostly spelling via spelling phonetic key, often with move (4)
- zoogang — 34 pair sides, mostly spelling via spelling phonetic key, often with thang (9)
- gritt — 31 pair sides, mostly spelling via spelling phonetic key, often with nitt (11)
- zoovy — 31 pair sides, mostly vowel via spelling phonetic key, often with monty (6)
- stuntin — 31 pair sides, mostly spelling via spelling phonetic key, often with nothin (7)
- cuando — 30 pair sides, mostly vowel via spelling phonetic key, often with lo (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Fetty Wap | $ave Dat Money | 90 | 61 | 440 | loose |
| Fetty Wap | 0-100 (Freestyle) | 25 | 30 | 154 | loose |
| Fetty Wap | 1 & Only | 35 | 15 | 109 | loose |
| Fetty Wap | 100 Band Jugg | 50 | 38 | 61 | loose |
| Fetty Wap | 100 Degrees | 12 | 27 | 87 | loose |
| Fetty Wap | 100k | 28 | 19 | 40 | loose |
| Fetty Wap | 1738 | 25 | 8 | 70 | loose |
| Fetty Wap | 188 | 22 | 13 | 52 | loose |
| Fetty Wap | 1Hunnid (Remix) | 35 | 48 | 162 | loose |
| Fetty Wap | 2030 | 35 | 25 | 158 | loose |
| Fetty Wap | 21 | 4 | 0 | 52 | loose |
| Fetty Wap | 3rd Quarter (Freestyle) | 31 | 36 | 209 | loose |
| Fetty Wap | 420 | 26 | 46 | 184 | loose |
| Fetty Wap | 6 AM | 42 | 53 | 291 | loose |
| Fetty Wap | 679 | 57 | 25 | 215 | loose |
| Fetty Wap | 679 & No Diggity | 21 | 11 | 64 | loose |
| Fetty Wap | 679 Freestyle | 16 | 13 | 88 | loose |
| Fetty Wap | About You | 30 | 32 | 218 | loose |
| Fetty Wap | Act a Fool | 45 | 27 | 105 | loose |
| Fetty Wap | Active | 29 | 16 | 97 | loose |
| Fetty Wap | Addicted | 44 | 27 | 166 | loose |
| Fetty Wap | Again | 50 | 42 | 177 | loose |
| Fetty Wap | Air It Out | 32 | 39 | 117 | loose |
| Fetty Wap | All For You | 29 | 15 | 100 | loose |
| Fetty Wap | All Night | 42 | 31 | 169 | loose |
| Fetty Wap | All in My Head (Flex) | 31 | 12 | 64 | loose |
| Fetty Wap | Always | 16 | 4 | 107 | loose |
| Fetty Wap | Angel | 39 | 32 | 174 | loose |
| Fetty Wap | Anyway / Everyday | 42 | 50 | 117 | loose |
| Fetty Wap | Aroma | 36 | 40 | 151 | loose |
| Fetty Wap | Around the World | 30 | 18 | 49 | loose |
| Fetty Wap | Asking 4 It | 27 | 20 | 103 | loose |
| Fetty Wap | At Peace | 22 | 8 | 135 | loose |
| Fetty Wap | Attachment | 42 | 35 | 265 | loose |
| Fetty Wap | Aye | 80 | 96 | 181 | loose |
| Fetty Wap | Baby | 38 | 48 | 151 | loose |
| Fetty Wap | Back It Up | 30 | 32 | 120 | loose |
| Fetty Wap | Back of the Wraith | 27 | 32 | 61 | loose |
| Fetty Wap | Bad Girlz | 58 | 26 | 248 | loose |
| Fetty Wap | Bad Lil Bitch | 36 | 27 | 245 | loose |
| Fetty Wap | Bahamas | 47 | 46 | 192 | loose |
| Fetty Wap | Bandz | 38 | 40 | 232 | loose |
| Fetty Wap | Bang My Head (Remix) | 33 | 31 | 89 | loose |
| Fetty Wap | Bank Account | 38 | 23 | 61 | loose |
| Fetty Wap | Bankroll | 34 | 43 | 127 | loose |
| Fetty Wap | Beat Go | 27 | 15 | 128 | loose |
| Fetty Wap | Beat It | 49 | 86 | 105 | loose |
| Fetty Wap | Beautiful | 34 | 33 | 146 | loose |
| Fetty Wap | Before I Blew | 50 | 31 | 189 | loose |
| Fetty Wap | Believe It | 34 | 33 | 137 | loose |
| Fetty Wap | Benz | 25 | 10 | 54 | loose |
| Fetty Wap | Better | 31 | 21 | 158 | loose |
| Fetty Wap | Better Days | 29 | 34 | 118 | loose |
| Fetty Wap | Big ZooWap | 1 | 0 | 4 | loose |
| Fetty Wap | Birthday | 23 | 22 | 107 | loose |
| Fetty Wap | Black & Decker | 39 | 51 | 187 | loose |
| Fetty Wap | Black Friday | 21 | 15 | 16 | loose |
| Fetty Wap | Bling Blaow | 72 | 64 | 301 | loose |
| Fetty Wap | Blue Band Weirdo | 39 | 53 | 172 | loose |
| Fetty Wap | Bodega (Remix) | 29 | 20 | 76 | loose |
| Fetty Wap | Body on Me (Remix) | 32 | 16 | 95 | loose |
| Fetty Wap | Boomin | 31 | 31 | 99 | loose |
| Fetty Wap | Boots | 28 | 25 | 119 | loose |
| Fetty Wap | Boo’d Up (Zoo Mix) | 31 | 20 | 134 | loose |
| Fetty Wap | Born For Greatness | 37 | 61 | 225 | loose |
| Fetty Wap | BossDon | 37 | 75 | 266 | loose |
| Fetty Wap | Brand New | 18 | 4 | 50 | loose |
| Fetty Wap | Brand New Day | 61 | 57 | 286 | loose |
| Fetty Wap | Bricks | 28 | 41 | 150 | loose |
| Fetty Wap | Broadway | 39 | 32 | 145 | loose |
| Fetty Wap | Broken | 37 | 16 | 207 | loose |
| Fetty Wap | Bruce Wayne | 17 | 25 | 53 | loose |
| Fetty Wap | Buddy | 39 | 34 | 179 | loose |
| Fetty Wap | Cake Team | 43 | 48 | 182 | loose |
| Fetty Wap | Cake Up | 35 | 35 | 189 | loose |
| Fetty Wap | Cali | 29 | 24 | 117 | loose |
| Fetty Wap | Candy Lady (Freestyle) | 42 | 38 | 196 | loose |
| Fetty Wap | Candy Land | 38 | 35 | 154 | loose |
| Fetty Wap | Cash Green | 33 | 39 | 246 | loose |
| Fetty Wap | Cashout | 53 | 36 | 208 | loose |
| Fetty Wap | Celebration | 25 | 30 | 145 | loose |
| Fetty Wap | Change Your Life | 32 | 28 | 130 | loose |
| Fetty Wap | Chat Shit, Get Banged | 44 | 33 | 139 | loose |
| Fetty Wap | Check | 37 | 60 | 252 | loose |
| Fetty Wap | Chipotle | 38 | 32 | 204 | loose |
| Fetty Wap | City G.O.D | 44 | 32 | 148 | loose |
| Fetty Wap | Classic (Remix) | 28 | 30 | 38 | loose |
| Fetty Wap | Clearly | 34 | 12 | 116 | loose |
| Fetty Wap | Cold Summer | 39 | 30 | 270 | loose |
| Fetty Wap | Cologne | 25 | 14 | 130 | loose |
| Fetty Wap | Computers (Freestyle) | 83 | 110 | 223 | loose |
| Fetty Wap | Cook Up | 26 | 22 | 174 | loose |
| Fetty Wap | Could You Believe It | 33 | 31 | 130 | loose |
| Fetty Wap | Could you believe it - Fetty wap | 11 | 9 | 24 | loose |
| Fetty Wap | Couple Bands | 39 | 38 | 112 | loose |
| Fetty Wap | Couple Bandz (Remix) | 38 | 54 | 169 | loose |
| Fetty Wap | Crew Freestyle | 33 | 26 | 285 | loose |
| Fetty Wap | Cuban Links (ZooMix) | 43 | 34 | 291 | loose |
| Fetty Wap | D.A.M. | 44 | 60 | 174 | loose |
| Fetty Wap | D.O.A. | 29 | 21 | 134 | loose |
| Fetty Wap | Daddy Holding | 48 | 45 | 327 | loose |
| Fetty Wap | Damn Chainz | 38 | 30 | 158 | loose |
| Fetty Wap | Damn Thang | 74 | 71 | 206 | loose |
| Fetty Wap | Dangerous Love | 44 | 39 | 334 | loose |
| Fetty Wap | Death Before Dishonor | 47 | 62 | 110 | loose |
| Fetty Wap | Decline (Remix) | 37 | 38 | 150 | loose |
| Fetty Wap | Departure | 42 | 34 | 233 | loose |
| Fetty Wap | Diamond | 42 | 55 | 108 | loose |
| Fetty Wap | Diamonds In My Chain | 48 | 79 | 297 | loose |
| Fetty Wap | Different Now | 33 | 28 | 151 | loose |
| Fetty Wap | Dip Dip (Freestyle) | 39 | 23 | 240 | loose |
| Fetty Wap | Do Anything | 44 | 41 | 137 | loose |
| Fetty Wap | Don’t Know What To Do | 18 | 13 | 98 | loose |
| Fetty Wap | Don’t Love Me | 38 | 31 | 269 | loose |
| Fetty Wap | Dope Boy | 34 | 26 | 77 | loose |
| Fetty Wap | Dressed Up | 10 | 6 | 71 | loose |
| Fetty Wap | Drill Zoo | 43 | 38 | 161 | loose |
| Fetty Wap | Dysfunctional | 26 | 36 | 102 | loose |
| Fetty Wap | Eastside Mz | 67 | 79 | 277 | loose |
| Fetty Wap | Easy Does It | 47 | 42 | 194 | loose |
| Fetty Wap | Enemies | 42 | 49 | 228 | loose |
| Fetty Wap | Envolviendo* | 6 | 1 | 76 | loose |
| Fetty Wap | Every Weekend | 20 | 10 | 64 | loose |
| Fetty Wap | Everyday | 37 | 47 | 143 | loose |
| Fetty Wap | F.L.Y. | 48 | 43 | 93 | loose |
| Fetty Wap | FMF 4 | 28 | 11 | 179 | loose |
| Fetty Wap | FWY | 43 | 16 | 176 | loose |
| Fetty Wap | Far away | 29 | 30 | 127 | loose |
| Fetty Wap | Favorite Girl | 38 | 26 | 130 | loose |
| Fetty Wap | Federal Pain | 21 | 19 | 187 | loose |
| Fetty Wap | Feel Me | 24 | 14 | 146 | loose |
| Fetty Wap | Feeling | 16 | 10 | 134 | loose |
| Fetty Wap | Feels Great | 29 | 20 | 90 | loose |
| Fetty Wap | Feels Right | 53 | 38 | 111 | loose |
| Fetty Wap | Fell In | 25 | 20 | 104 | loose |
| Fetty Wap | Ferrari Music (Freestyle) | 39 | 26 | 218 | loose |
| Fetty Wap | Fetti | 61 | 61 | 254 | loose |
| Fetty Wap | Fetty Wap Speaks [2] | 11 | 5 | 28 | loose |
| Fetty Wap | Find A Way | 27 | 18 | 114 | loose |
| Fetty Wap | Fine Wine | 37 | 32 | 86 | loose |
| Fetty Wap | Fine(Bad as hell) | 42 | 35 | 171 | loose |
| Fetty Wap | Firefly | 23 | 17 | 74 | loose |
| Fetty Wap | First Day Out | 27 | 17 | 268 | loose |
| Fetty Wap | First Thing | 31 | 20 | 179 | loose |
| Fetty Wap | Flicka Da Wrist (Remix) | 85 | 77 | 368 | loose |
| Fetty Wap | Flip Phone | 35 | 37 | 174 | loose |
| Fetty Wap | Flossin’ (Freestyle) | 47 | 53 | 148 | loose |
| Fetty Wap | Fool for You | 30 | 14 | 169 | loose |
| Fetty Wap | For My Team | 33 | 22 | 129 | loose |
| Fetty Wap | For The Moment | 44 | 44 | 271 | loose |
| Fetty Wap | For The Money* | 8 | 5 | 11 | loose |
| Fetty Wap | Forever (71943509) | 30 | 27 | 114 | loose |
| Fetty Wap | Freaky | 56 | 82 | 175 | loose |
| Fetty Wap | Free Gucci | 45 | 63 | 262 | loose |
| Fetty Wap | Free Gucci, Pt. 2 | 46 | 37 | 181 | loose |
| Fetty Wap | Fresh N Clean | 29 | 17 | 199 | loose |
| Fetty Wap | Friends | 51 | 47 | 318 | loose |
| Fetty Wap | From the Zoo | 54 | 58 | 180 | loose |
| Fetty Wap | Fuck Em | 30 | 12 | 138 | loose |
| Fetty Wap | Fuss & Fight | 31 | 44 | 69 | loose |
| Fetty Wap | Gang | 31 | 44 | 102 | loose |
| Fetty Wap | Gangsta Love | 38 | 32 | 201 | loose |
| Fetty Wap | Get Back | 32 | 18 | 170 | loose |
| Fetty Wap | Get Down | 15 | 10 | 75 | loose |
| Fetty Wap | Getchu | 18 | 2 | 106 | loose |
| Fetty Wap | Girl Version 679 | 37 | 16 | 108 | loose |
| Fetty Wap | Give Me Your Love | 27 | 37 | 111 | loose |
| Fetty Wap | Go Hard Boyz (Banshee) | 39 | 16 | 98 | loose |
| Fetty Wap | Go Up | 19 | 6 | 115 | loose |
| Fetty Wap | Going Crazy | 34 | 38 | 207 | loose |
| Fetty Wap | Gold Slugs | 48 | 14 | 171 | loose |
| Fetty Wap | Gorilla Glue | 32 | 26 | 163 | loose |
| Fetty Wap | Got A Bag | 28 | 27 | 194 | loose |
| Fetty Wap | Got A Thang | 37 | 63 | 270 | loose |
| Fetty Wap | Got Me | 39 | 43 | 138 | loose |
| Fetty Wap | Gotta Blast | 35 | 38 | 199 | loose |
| Fetty Wap | Gotta Have You | 38 | 42 | 204 | loose |
| Fetty Wap | Grandma | 24 | 23 | 88 | loose |
| Fetty Wap | Greatest | 26 | 16 | 170 | loose |
| Fetty Wap | Grind | 30 | 10 | 91 | loose |
| Fetty Wap | Gucci | 40 | 40 | 282 | loose |
| Fetty Wap | Gucci Zoo | 46 | 43 | 354 | loose |
| Fetty Wap | Guessing | 9 | 7 | 65 | loose |
| Fetty Wap | Handgun | 28 | 22 | 77 | loose |
| Fetty Wap | Hate You | 37 | 28 | 147 | loose |
| Fetty Wap | Heard Of Me | 34 | 52 | 126 | loose |
| Fetty Wap | Heavenly Sent | 50 | 44 | 146 | loose |
| Fetty Wap | Hell of a Night | 54 | 27 | 214 | loose |
| Fetty Wap | Her (Remix) | 27 | 11 | 156 | loose |
| Fetty Wap | Hi-Tech | 24 | 28 | 110 | loose |
| Fetty Wap | High | 22 | 12 | 123 | loose |
| Fetty Wap | High Thoughts | 36 | 52 | 104 | loose |
| Fetty Wap | History | 33 | 26 | 143 | loose |
| Fetty Wap | History of Rap 6 | 87 | 42 | 293 | loose |
| Fetty Wap | Hit Some Corners | 37 | 45 | 137 | loose |
| Fetty Wap | Hold On | 18 | 6 | 42 | loose |
| Fetty Wap | Homies | 31 | 32 | 198 | loose |
| Fetty Wap | Hood Rich | 37 | 48 | 209 | loose |
| Fetty Wap | Hot Niggas (Remy Mix) | 51 | 47 | 165 | loose |
| Fetty Wap | How Many | 52 | 70 | 337 | loose |
| Fetty Wap | How We Do Things | 32 | 41 | 116 | loose |
| Fetty Wap | I Adore You | 43 | 23 | 126 | loose |
| Fetty Wap | I Be on It | 27 | 3 | 161 | loose |
| Fetty Wap | I Don’t Love Her (Freestyle) | 31 | 41 | 138 | loose |
| Fetty Wap | I Got It | 23 | 12 | 73 | loose |
| Fetty Wap | I Need You | 34 | 55 | 143 | loose |
| Fetty Wap | I Remember/Dear Zavier | 97 | 152 | 548 | loose |
| Fetty Wap | I Swear | 35 | 33 | 153 | loose |
| Fetty Wap | I Think I Love Her | 34 | 26 | 104 | loose |
| Fetty Wap | I Wonder | 21 | 9 | 33 | loose |
| Fetty Wap | Ice Cream | 47 | 22 | 213 | loose |
| Fetty Wap | If It’s You | 38 | 70 | 157 | loose |
| Fetty Wap | In My Bag | 52 | 78 | 309 | loose |
| Fetty Wap | In My Ways | 46 | 50 | 112 | loose |
| Fetty Wap | In Your Eyes | 42 | 17 | 280 | loose |
| Fetty Wap | In the Kitchen (Remix) | 44 | 69 | 156 | loose |
| Fetty Wap | Instagram | 44 | 18 | 204 | loose |
| Fetty Wap | Instant Friend | 37 | 6 | 84 | loose |
| Fetty Wap | Interlude (King Zoo Call) | 15 | 5 | 73 | loose |
| Fetty Wap | Into Her | 34 | 19 | 55 | loose |
| Fetty Wap | Intro | 16 | 3 | 50 | loose |
| Fetty Wap | Intro / Fetty Wap Skit | 24 | 35 | 103 | loose |
| Fetty Wap | Island Boy | 35 | 73 | 159 | loose |
| Fetty Wap | Island Boyz | 43 | 48 | 340 | loose |
| Fetty Wap | Island on My Chain | 46 | 63 | 209 | loose |
| Fetty Wap | It’s Me | 24 | 17 | 126 | loose |
| Fetty Wap | I’m Ballin | 32 | 18 | 175 | loose |
| Fetty Wap | I’m From Jersey | 41 | 23 | 169 | loose |
| Fetty Wap | I’m Juugin | 39 | 19 | 157 | loose |
| Fetty Wap | I’m Straight | 25 | 18 | 109 | loose |
| Fetty Wap | Jack Boy | 22 | 15 | 66 | loose |
| Fetty Wap | Jackpot | 45 | 35 | 140 | loose |
| Fetty Wap | Jamaica | 48 | 47 | 164 | loose |
| Fetty Wap | Jamaican Trainer (Skit) | 14 | 2 | 13 | loose |
| Fetty Wap | Jealous | 44 | 44 | 178 | loose |
| Fetty Wap | Jet Li | 21 | 42 | 375 | loose |
| Fetty Wap | Jigga Bop | 55 | 50 | 139 | loose |
| Fetty Wap | Jimmy Choo | 31 | 7 | 136 | loose |
| Fetty Wap | Jugg | 35 | 1 | 84 | loose |
| Fetty Wap | Jugg to Finesse | 38 | 20 | 136 | loose |
| Fetty Wap | June 7th (Momma made a star) | 37 | 39 | 156 | loose |
| Fetty Wap | Just a Warning | 36 | 28 | 126 | loose |
| Fetty Wap | Just for You | 42 | 39 | 72 | loose |
| Fetty Wap | K.M | 31 | 20 | 173 | loose |
| Fetty Wap | KEKE | 45 | 23 | 209 | loose |
| Fetty Wap | Keep It 100 | 48 | 31 | 86 | loose |
| Fetty Wap | Khia | 50 | 69 | 179 | loose |
| Fetty Wap | King Is on His Way | 25 | 25 | 106 | loose |
| Fetty Wap | King Me | 36 | 27 | 145 | loose |
| Fetty Wap | King Zoo | 61 | 78 | 289 | loose |
| Fetty Wap | KissWowie | 22 | 39 | 39 | loose |
| Fetty Wap | Klassic | 22 | 12 | 136 | loose |
| Fetty Wap | Klassy | 12 | 7 | 55 | loose |
| Fetty Wap | Know My Name | 42 | 22 | 231 | loose |
| Fetty Wap | Know Shit (Remix) | 62 | 51 | 504 | loose |
| Fetty Wap | Know You Freestyle (Slow Down Gmixx) | 21 | 15 | 52 | loose |
| Fetty Wap | L.A.X. | 31 | 48 | 190 | loose |
| Fetty Wap | L.K.M | 27 | 17 | 119 | loose |
| Fetty Wap | LO PRIMERO | 31 | 30 | 490 | loose |
| Fetty Wap | LYG | 34 | 38 | 184 | loose |
| Fetty Wap | Late Night Jawn | 30 | 26 | 174 | loose |
| Fetty Wap | Late Night Jawn Pt.2 | 22 | 25 | 110 | loose |
| Fetty Wap | Lately | 41 | 9 | 164 | loose |
| Fetty Wap | Leck | 23 | 21 | 61 | loose |
| Fetty Wap | Leck [Rasster Remix] | 7 | 1 | 3 | loose |
| Fetty Wap | Lemonade (ZooMix) | 17 | 12 | 60 | loose |
| Fetty Wap | Let It Bang | 24 | 7 | 108 | loose |
| Fetty Wap | Let It Pop | 32 | 23 | 179 | loose |
| Fetty Wap | Let It Snow | 47 | 86 | 134 | loose |
| Fetty Wap | Let Me Spoil You | 28 | 12 | 68 | loose |
| Fetty Wap | Like Me (Remix) | 78 | 47 | 291 | loose |
| Fetty Wap | Like a Star | 36 | 25 | 106 | loose |
| Fetty Wap | Like a Taylor | 35 | 38 | 482 | loose |
| Fetty Wap | Lil Sexy | 34 | 25 | 149 | loose |
| Fetty Wap | Locked In | 41 | 24 | 162 | loose |
| Fetty Wap | Look At Me | 38 | 49 | 348 | loose |
| Fetty Wap | Losing Control | 32 | 8 | 110 | loose |
| Fetty Wap | Lost Friends | 36 | 34 | 230 | loose |
| Fetty Wap | Lotto | 30 | 42 | 173 | loose |
| Fetty Wap | Lov | 54 | 52 | 293 | loose |
| Fetty Wap | Love | 24 | 4 | 113 | loose |
| Fetty Wap | Love Me or Leave Me | 21 | 11 | 56 | loose |
| Fetty Wap | Love The Way | 38 | 23 | 178 | loose |
| Fetty Wap | Lovers & Friends | 46 | 33 | 124 | loose |
| Fetty Wap | Low key | 44 | 22 | 132 | loose |
| Fetty Wap | Ma famille | 27 | 13 | 159 | loose |
| Fetty Wap | Magic | 31 | 55 | 119 | loose |
| Fetty Wap | Make It | 43 | 34 | 218 | loose |
| Fetty Wap | Make You Feel Good | 21 | 39 | 149 | AAAA |
| Fetty Wap | Make You Mine (Smile)* | 39 | 53 | 148 | loose |
| Fetty Wap | Make You Smile | 37 | 23 | 126 | loose |
| Fetty Wap | Merry Xmas | 44 | 58 | 137 | loose |
| Fetty Wap | Milan | 37 | 15 | 158 | loose |
| Fetty Wap | Mona Lisa | 28 | 23 | 84 | loose |
| Fetty Wap | Money | 47 | 38 | 252 | loose |
| Fetty Wap | Money In The Bank | 32 | 15 | 133 | loose |
| Fetty Wap | Money Luv | 16 | 20 | 82 | loose |
| Fetty Wap | Mr Walker | 17 | 8 | 40 | loose |
| Fetty Wap | Murder She Wrote | 44 | 24 | 164 | loose |
| Fetty Wap | Must Be Nice | 10 | 0 | 9 | loose |
| Fetty Wap | My Environment | 63 | 56 | 200 | loose |
| Fetty Wap | My Moment | 36 | 39 | 168 | loose |
| Fetty Wap | My Squad | 16 | 9 | 110 | loose |
| Fetty Wap | My Way (Remix) | 44 | 49 | 167 | loose |
| Fetty Wap | My Wrist | 26 | 6 | 110 | loose |
| Fetty Wap | Mystique | 15 | 2 | 113 | loose |
| Fetty Wap | N LUV | 33 | 37 | 179 | loose |
| Fetty Wap | NAPOLI QUEEN | 28 | 33 | 245 | loose |
| Fetty Wap | Nasty | 21 | 15 | 125 | loose |
| Fetty Wap | Nasty Jawn | 33 | 21 | 147 | loose |
| Fetty Wap | Neuman Marcus | 34 | 32 | 162 | loose |
| Fetty Wap | Never Fold | 48 | 40 | 133 | loose |
| Fetty Wap | Never Tell | 33 | 21 | 145 | loose |
| Fetty Wap | Never Thought | 35 | 12 | 119 | loose |
| Fetty Wap | Nice of the princess | 10 | 4 | 16 | loose |
| Fetty Wap | Nigga Like Me | 35 | 27 | 144 | loose |
| Fetty Wap | Nights Like This Cover | 18 | 14 | 92 | loose |
| Fetty Wap | No Choice | 24 | 16 | 131 | loose |
| Fetty Wap | No Days Off | 40 | 36 | 233 | loose |
| Fetty Wap | No Guidance ZooMix | 32 | 29 | 95 | loose |
| Fetty Wap | No One Told Us (Extended Version) | 36 | 36 | 190 | loose |
| Fetty Wap | No Time to Waste | 28 | 15 | 207 | loose |
| Fetty Wap | No Turnin Down | 8 | 1 | 23 | loose |
| Fetty Wap | No Type (Remix) | 40 | 30 | 181 | loose |
| Fetty Wap | Nobody Else | 34 | 18 | 243 | loose |
| Fetty Wap | Nobody’s Better | 36 | 18 | 101 | loose |
| Fetty Wap | Northern Lights | 52 | 90 | 302 | loose |
| Fetty Wap | Not F**kin Aroun | 32 | 16 | 226 | loose |
| Fetty Wap | Not Poppin’ | 35 | 32 | 223 | loose |
| Fetty Wap | Nun Else | 25 | 27 | 77 | loose |
| Fetty Wap | On Me | 38 | 11 | 146 | loose |
| Fetty Wap | On Sight | 39 | 9 | 115 | loose |
| Fetty Wap | On a Car | 20 | 27 | 91 | loose |
| Fetty Wap | One Eyed Willie | 31 | 30 | 218 | loose |
| Fetty Wap | One I Want | 33 | 21 | 58 | loose |
| Fetty Wap | One Night (Remix) | 8 | 0 | 17 | loose |
| Fetty Wap | One Night Only | 57 | 60 | 331 | loose |
| Fetty Wap | One Time | 29 | 19 | 91 | loose |
| Fetty Wap | Oochy Wally | 24 | 29 | 136 | loose |
| Fetty Wap | Out da Pot | 24 | 23 | 94 | loose |
| Fetty Wap | Out the Hood | 20 | 24 | 133 | loose |
| Fetty Wap | Outro | 5 | 0 | 28 | loose |
| Fetty Wap | Outside | 15 | 11 | 127 | loose |
| Fetty Wap | Ouu | 50 | 42 | 230 | loose |
| Fetty Wap | Over Night | 35 | 31 | 188 | loose |
| Fetty Wap | P.T.S.A. | 23 | 22 | 48 | loose |
| Fetty Wap | PARTY GIRL | 36 | 8 | 180 | loose |
| Fetty Wap | PNP | 20 | 15 | 58 | loose |
| Fetty Wap | Pain makes my life | 10 | 1 | 98 | loose |
| Fetty Wap | Paparazzi | 29 | 22 | 127 | loose |
| Fetty Wap | Paterson Legend | 44 | 43 | 350 | loose |
| Fetty Wap | Patience | 26 | 21 | 146 | loose |
| Fetty Wap | Patron & Percocet | 33 | 26 | 101 | loose |
| Fetty Wap | Pickin Up Bags | 38 | 37 | 239 | loose |
| Fetty Wap | Pickled Ketchup & Broccoli Beans | 31 | 35 | 116 | loose |
| Fetty Wap | Play Off | 30 | 46 | 118 | loose |
| Fetty Wap | Playa No More | 26 | 16 | 73 | loose |
| Fetty Wap | Pop Out | 16 | 19 | 112 | loose |
| Fetty Wap | Post To Be [Cake-Mix] | 46 | 29 | 187 | loose |
| Fetty Wap | Power | 38 | 18 | 124 | loose |
| Fetty Wap | Pretty Girl Dance Pt. 2 | 41 | 17 | 178 | loose |
| Fetty Wap | Pretty Thang | 26 | 17 | 121 | loose |
| Fetty Wap | Priceless | 38 | 18 | 88 | loose |
| Fetty Wap | Private Party | 17 | 37 | 42 | loose |
| Fetty Wap | Promise | 35 | 23 | 112 | loose |
| Fetty Wap | Promises | 33 | 47 | 141 | loose |
| Fetty Wap | Pull Up wit ah Stick (Freestyle) | 48 | 77 | 141 | loose |
| Fetty Wap | Pussy Poppers Mix #1 | 95 | 91 | 430 | loose |
| Fetty Wap | Queen | 35 | 9 | 211 | loose |
| Fetty Wap | Queen of the Zoo | 32 | 17 | 95 | loose |
| Fetty Wap | Questions | 44 | 41 | 124 | loose |
| Fetty Wap | RGF | 10 | 5 | 27 | loose |
| Fetty Wap | RGF Island (Remix) | 57 | 55 | 291 | loose |
| Fetty Wap | Ransom Remix Ft. Fetty Wap | 49 | 41 | 288 | loose |
| Fetty Wap | Ransom Zoo Mix | 31 | 32 | 210 | loose |
| Fetty Wap | Real Love | 31 | 15 | 133 | loose |
| Fetty Wap | Real Ones | 49 | 40 | 376 | loose |
| Fetty Wap | Really Really | 39 | 31 | 142 | loose |
| Fetty Wap | Reasons | 31 | 22 | 124 | loose |
| Fetty Wap | Reload | 27 | 10 | 111 | loose |
| Fetty Wap | Remaining Questions from Trap Queen | 25 | 7 | 181 | loose |
| Fetty Wap | Remember Me | 20 | 7 | 143 | loose |
| Fetty Wap | Remix’n a Bricc | 44 | 45 | 286 | loose |
| Fetty Wap | Rewind | 46 | 31 | 136 | loose |
| Fetty Wap | Rich Today (Remix) | 72 | 93 | 265 | loose |
| Fetty Wap | Ride | 29 | 10 | 334 | loose |
| Fetty Wap | Ride Or Die | 24 | 18 | 134 | loose |
| Fetty Wap | Rider | 54 | 56 | 270 | loose |
| Fetty Wap | Right Back | 32 | 25 | 174 | loose |
| Fetty Wap | Right Back to You | 29 | 17 | 64 | loose |
| Fetty Wap | RnB Shit | 19 | 4 | 56 | loose |
| Fetty Wap | Rock My Chain | 24 | 12 | 84 | loose |
| Fetty Wap | Rockstar (GMix) | 33 | 7 | 122 | loose |
| Fetty Wap | Rodeo | 29 | 16 | 117 | loose |
| Fetty Wap | Roll Sum Up | 45 | 34 | 131 | loose |
| Fetty Wap | Roll Up | 25 | 21 | 61 | loose |
| Fetty Wap | Rollin Dank | 44 | 21 | 209 | loose |
| Fetty Wap | Rover ZooMix | 35 | 18 | 123 | loose |
| Fetty Wap | Run Away | 16 | 12 | 37 | loose |
| Fetty Wap | Run It Up | 66 | 74 | 238 | loose |
| Fetty Wap | Run Ya Bands Up | 68 | 53 | 290 | loose |
| Fetty Wap | SHOTTAZ | 40 | 47 | 149 | loose |
| Fetty Wap | SUMN QUICK® | 28 | 15 | 103 | loose |
| Fetty Wap | Same Old Love (Remix) | 22 | 9 | 105 | loose |
| Fetty Wap | Santa | 18 | 6 | 105 | loose |
| Fetty Wap | Savage | 41 | 62 | 189 | loose |
| Fetty Wap | Say When | 32 | 6 | 119 | loose |
| Fetty Wap | Selling Dreams | 56 | 58 | 157 | loose |
| Fetty Wap | Shake Dat Azz Freestyle | 41 | 27 | 111 | loose |
| Fetty Wap | She Bad | 46 | 51 | 102 | loose |
| Fetty Wap | She Know | 50 | 53 | 160 | loose |
| Fetty Wap | She Wanna | 38 | 18 | 71 | loose |
| Fetty Wap | Shit I Like | 56 | 127 | 263 | AAAA |
| Fetty Wap | Shorty | 42 | 15 | 132 | loose |
| Fetty Wap | Show Love | 57 | 22 | 360 | loose |
| Fetty Wap | Show You | 41 | 51 | 203 | loose |
| Fetty Wap | Sittin In The Trap | 27 | 37 | 128 | loose |
| Fetty Wap | Slide | 36 | 32 | 167 | loose |
| Fetty Wap | So Different | 23 | 8 | 80 | loose |
| Fetty Wap | So Icy (Freestyle) | 47 | 18 | 207 | loose |
| Fetty Wap | Sojo Spa | 53 | 23 | 118 | loose |
| Fetty Wap | Some Fetty (Demo) | 30 | 21 | 94 | loose |
| Fetty Wap | Somebody (Remix) | 37 | 22 | 154 | loose |
| Fetty Wap | Sometimes | 16 | 10 | 60 | loose |
| Fetty Wap | Sorry | 20 | 22 | 60 | loose |
| Fetty Wap | Spaceship | 52 | 79 | 238 | loose |
| Fetty Wap | Speed | 45 | 45 | 131 | loose |
| Fetty Wap | Spend the Night | 45 | 30 | 111 | loose |
| Fetty Wap | Spin the Block | 20 | 8 | 136 | loose |
| Fetty Wap | Spot Back | 28 | 25 | 76 | loose |
| Fetty Wap | Squad Or Nah | 22 | 16 | 91 | loose |
| Fetty Wap | Squeezed Up Remix | 71 | 139 | 478 | loose |
| Fetty Wap | Stack Some Bands | 22 | 18 | 123 | loose |
| Fetty Wap | Star Struck | 25 | 28 | 115 | loose |
| Fetty Wap | Start It Up | 24 | 5 | 97 | loose |
| Fetty Wap | Stay Down | 24 | 7 | 83 | loose |
| Fetty Wap | Still Here | 24 | 34 | 100 | loose |
| Fetty Wap | Still Selling Dope | 30 | 33 | 258 | loose |
| Fetty Wap | Stoop Kids | 46 | 65 | 113 | loose |
| Fetty Wap | Strappped Up Shawty | 32 | 16 | 119 | loose |
| Fetty Wap | Strawberry Kush | 24 | 17 | 126 | loose |
| Fetty Wap | Summer Time | 38 | 62 | 143 | loose |
| Fetty Wap | Surfboard | 26 | 50 | 89 | loose |
| Fetty Wap | Sweet Yamz | 17 | 14 | 25 | loose |
| Fetty Wap | Swing My Arms (Remix) | 33 | 39 | 103 | loose |
| Fetty Wap | Switched Up | 40 | 37 | 133 | loose |
| Fetty Wap | THE GRAM | 30 | 21 | 198 | loose |
| Fetty Wap | Takin Off | 26 | 39 | 88 | loose |
| Fetty Wap | Talk My Shit | 54 | 36 | 209 | loose |
| Fetty Wap | Talkin’ Like This | 39 | 69 | 110 | loose |
| Fetty Wap | Teach Me | 35 | 36 | 168 | loose |
| Fetty Wap | Teal is Dead | 39 | 31 | 84 | loose |
| Fetty Wap | Tell Me | 25 | 13 | 162 | loose |
| Fetty Wap | Tell Me What You Want | 33 | 44 | 69 | loose |
| Fetty Wap | Text Me | 43 | 24 | 118 | loose |
| Fetty Wap | Text Ur Number | 39 | 27 | 128 | loose |
| Fetty Wap | That Work | 56 | 44 | 270 | loose |
| Fetty Wap | That’s Facts | 50 | 36 | 196 | loose |
| Fetty Wap | The Agreement | 54 | 104 | 200 | loose |
| Fetty Wap | The Father, The Sun (Rap Remix) | 39 | 31 | 222 | loose |
| Fetty Wap | The Hood | 57 | 59 | 283 | loose |
| Fetty Wap | The Mack | 44 | 13 | 104 | loose |
| Fetty Wap | The Move | 42 | 15 | 72 | loose |
| Fetty Wap | The One | 35 | 40 | 176 | loose |
| Fetty Wap | The Race Freestyle | 45 | 69 | 223 | loose |
| Fetty Wap | The Truth | 36 | 24 | 189 | loose |
| Fetty Wap | The Zoo | 59 | 45 | 200 | loose |
| Fetty Wap | There She Go | 58 | 36 | 136 | loose |
| Fetty Wap | They Know | 33 | 49 | 96 | loose |
| Fetty Wap | They Know My Name | 39 | 64 | 220 | loose |
| Fetty Wap | Thigh life | 5 | 0 | 5 | loose |
| Fetty Wap | Things You Like | 32 | 18 | 162 | loose |
| Fetty Wap | Thinkin’ Bout You | 24 | 13 | 114 | loose |
| Fetty Wap | Thoughts | 27 | 52 | 96 | loose |
| Fetty Wap | Throw It Back | 32 | 32 | 185 | loose |
| Fetty Wap | Tidal X: 1015 | 344 | 304 | 1448 | loose |
| Fetty Wap | Tim Duncan | 56 | 41 | 248 | loose |
| Fetty Wap | Time | 38 | 35 | 135 | loose |
| Fetty Wap | To The Moon | 40 | 86 | 114 | loose |
| Fetty Wap | Toast Up (Zoo Mix) | 40 | 33 | 221 | loose |
| Fetty Wap | Tonight | 37 | 44 | 142 | loose |
| Fetty Wap | Too Fast | 32 | 24 | 148 | loose |
| Fetty Wap | Too Much | 57 | 22 | 158 | loose |
| Fetty Wap | Too Paid | 60 | 53 | 412 | loose |
| Fetty Wap | Touchdown | 27 | 16 | 109 | loose |
| Fetty Wap | Tourin | 38 | 27 | 157 | loose |
| Fetty Wap | Trap Luv | 26 | 15 | 115 | loose |
| Fetty Wap | Trap Niggas Freestyle | 44 | 41 | 230 | loose |
| Fetty Wap | Trap Queen | 42 | 46 | 175 | loose |
| Fetty Wap | Trap Queen Cover/Remix | 58 | 56 | 256 | loose |
| Fetty Wap | Trap Queen Freestyle | 24 | 30 | 101 | loose |
| Fetty Wap | Trap Queen/Again/My Way (Remix) | 49 | 29 | 146 | loose |
| Fetty Wap | Trap Royalty (Extended Version) | 15 | 5 | 28 | loose |
| Fetty Wap | Trippin Baby | 28 | 18 | 124 | loose |
| Fetty Wap | Tuesday (Remix) | 57 | 31 | 177 | loose |
| Fetty Wap | Tupac 2.0 | 46 | 46 | 169 | loose |
| Fetty Wap | U Here Tonight | 34 | 20 | 77 | loose |
| Fetty Wap | Undeniable | 21 | 3 | 105 | loose |
| Fetty Wap | Unstoppable | 58 | 53 | 275 | loose |
| Fetty Wap | Urus Pt. 1 | 35 | 46 | 114 | loose |
| Fetty Wap | Urus Pt. 2 | 27 | 29 | 65 | loose |
| Fetty Wap | Valet (Remix) | 45 | 32 | 186 | loose |
| Fetty Wap | Vibes | 24 | 19 | 83 | loose |
| Fetty Wap | Victor Cruz | 40 | 47 | 124 | loose |
| Fetty Wap | WHAT U NEED? | 19 | 10 | 124 | loose |
| Fetty Wap | WYA | 29 | 36 | 228 | loose |
| Fetty Wap | WYD | 36 | 26 | 90 | loose |
| Fetty Wap | Wake Up | 29 | 20 | 165 | loose |
| Fetty Wap | Walk (Remix) | 48 | 42 | 165 | loose |
| Fetty Wap | Walk Thru Remix | 39 | 36 | 124 | loose |
| Fetty Wap | Want To (Birthday Song) | 27 | 26 | 162 | loose |
| Fetty Wap | Wap Thru | 19 | 8 | 72 | loose |
| Fetty Wap | Watching Me | 26 | 34 | 76 | loose |
| Fetty Wap | Wavy | 20 | 19 | 26 | loose |
| Fetty Wap | Wawa | 37 | 50 | 119 | loose |
| Fetty Wap | Way Past 12 | 32 | 58 | 186 | loose |
| Fetty Wap | Way You Are | 53 | 48 | 173 | loose |
| Fetty Wap | We Da Squad | 28 | 14 | 79 | loose |
| Fetty Wap | We Gon Fight (Remix) | 39 | 25 | 125 | loose |
| Fetty Wap | We The Shit | 37 | 9 | 102 | loose |
| Fetty Wap | Westin | 48 | 50 | 195 | loose |
| Fetty Wap | Westside | 42 | 14 | 195 | loose |
| Fetty Wap | What It Be Like | 48 | 118 | 165 | loose |
| Fetty Wap | What We Do | 15 | 18 | 90 | loose |
| Fetty Wap | What You Know About Loyalty | 47 | 50 | 284 | loose |
| Fetty Wap | Whateva | 47 | 27 | 133 | loose |
| Fetty Wap | What’s My Name | 38 | 35 | 198 | loose |
| Fetty Wap | When I See Ya | 35 | 7 | 110 | loose |
| Fetty Wap | When You Say | 27 | 58 | 136 | loose |
| Fetty Wap | Whip It | 28 | 23 | 74 | loose |
| Fetty Wap | Whip My Wrist | 41 | 69 | 236 | loose |
| Fetty Wap | White Linen | 42 | 31 | 193 | loose |
| Fetty Wap | White Roses | 31 | 14 | 109 | loose |
| Fetty Wap | Why You Mad | 34 | 45 | 238 | loose |
| Fetty Wap | With It or What | 38 | 15 | 175 | loose |
| Fetty Wap | With My Wing | 32 | 19 | 168 | loose |
| Fetty Wap | With U | 43 | 20 | 75 | loose |
| Fetty Wap | With You | 46 | 55 | 136 | loose |
| Fetty Wap | Wonder | 29 | 9 | 41 | loose |
| Fetty Wap | Word On The Streets | 51 | 60 | 214 | loose |
| Fetty Wap | Worry ’Bout It | 37 | 14 | 133 | loose |
| Fetty Wap | XO (Freestyle) | 15 | 16 | 48 | loose |
| Fetty Wap | XXL Freshman Freestyle | 9 | 10 | 32 | loose |
| Fetty Wap | XXL Freshmen 2015 Cypher - Part 3 | 46 | 32 | 225 | loose |
| Fetty Wap | Yomi | 24 | 20 | 111 | loose |
| Fetty Wap | Yoshi | 20 | 6 | 93 | loose |
| Fetty Wap | You Don’t Know | 44 | 56 | 279 | loose |
| Fetty Wap | You Don’t Know My Name | 29 | 29 | 103 | loose |
| Fetty Wap | Young Niggas | 48 | 121 | 305 | loose |
| Fetty Wap | Your Number (Fetty Remix) | 32 | 24 | 117 | loose |
| Fetty Wap | YungLan Freestyle | 43 | 38 | 185 | loose |
| Fetty Wap | Z O O | 40 | 29 | 181 | loose |
| Fetty Wap | Zaps | 33 | 26 | 278 | loose |
| Fetty Wap | Zones | 48 | 47 | 220 | loose |
| Fetty Wap | Zoo (2019) | 76 | 49 | 234 | loose |
| Fetty Wap | ZooGang | 29 | 19 | 166 | loose |
| Fetty Wap | ZooWap | 32 | 16 | 56 | loose |
| Fetty Wap | Zoogang Freestyle | 40 | 30 | 142 | loose |
| Fetty Wap | Zooted | 24 | 38 | 96 | loose |
| Fetty Wap | Zoovie Zoo | 66 | 37 | 223 | loose |
| Fetty Wap | Zoovier | 43 | 74 | 293 | loose |
| Fetty Wap | superhuman | 25 | 12 | 106 | loose |
| Fetty Wap | Ándale | 26 | 32 | 94 | loose |
