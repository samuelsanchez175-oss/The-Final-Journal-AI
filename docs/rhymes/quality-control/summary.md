# Quality Control rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Quality Control
- Songs: 1573
- Bars kept (Quality Control lyric lines): 70597
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 125
- Canonical name: Quality Control.
- Credit strings: Quality Control.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 436074
- REPEAT pairs, recorded separately: 47766
- END rhymes: 79494
- INNER rhymes: 356580

By match:

- PERFECT: 35242 (END 10701, INNER 24541)
- SLANT: 187538 (END 32728, INNER 154810)
- ASSONANCE: 208612 (END 34449, INNER 174163)
- MULTI: 4682 (END 1616, INNER 3066)

By confidence:

- HIGH: 36654
- MED: 371919
- LOW: 27501

## Core

- Core Y: 429149
- Core N among rhyme pairs: 6925

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 199039 (45.6%)
- vowel: 208612 (47.8%)
- spelling: 23741 (5.4%)
- multi: 4682 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 5 songs
- loose: 1568 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 35618 pairs (END 4997, INNER 30621). Words: bitch, bitches, shit, think, wrist, still, lil, hit.
2. `vow:OW` — 27148 pairs (END 3575, INNER 23573). Words: don't, know, no, go, told, hoes, ho, broke.
3. `vow:AE` — 23121 pairs (END 4647, INNER 18474). Words: can't, back, had, can, racks, have, bag, ass.
4. `vow:EY` — 23042 pairs (END 4310, INNER 18732). Words: ain't, say, way, make, play, take, baby, day.
5. `vow:EH` — 22897 pairs (END 3202, INNER 19695). Words: get, when, never, gettin, tell, left, went, let.
6. `vow:AA` — 19417 pairs (END 2691, INNER 16726). Words: got, want, talkin, hard, nothin, not, gotta, poppin.
7. `vow:AH` — 15443 pairs (END 2306, INNER 13137). Words: hundred, fuck, money, some, one, what, fuckin, come.
8. `vow:AY` — 13887 pairs (END 2440, INNER 11447). Words: like, diamonds, why, by, time, try, buy, die.
9. `vow:IY` — 13867 pairs (END 2527, INNER 11340). Words: see, these, even, keep, need, streets, three, free.
10. `slant:AA:stop` — 10444 pairs (END 1186, INNER 9258). Words: got, gotta, want, not, block, top, drop, pop.
11. `slant:IH:stop` — 10128 pairs (END 1355, INNER 8773). Words: nigga, shit, hit, big, dick, city, stick, wrist.
12. `slant:IH:sib-stop` — 9004 pairs (END 1677, INNER 7327). Words: bitch, shit, nigga, niggas, rich, hit, big, dick.
13. `slant:AE:stop` — 5864 pairs (END 1299, INNER 4565). Words: back, had, bag, can't, trap, bad, act, mad.
14. `slant:AH:nas-stop` — 5358 pairs (END 339, INNER 5019). Words: fuck, what, money, some, one, come, young, done.
15. `slant:EH:stop` — 5109 pairs (END 713, INNER 4396). Words: get, let, better, check, head, said, neck, went.
16. `cmu:OW` — 4866 pairs (END 705, INNER 4161). Words: know, no, go, ho, show, bro, low, blow.
17. `slant:IH:liq-stop` — 4484 pairs (END 219, INNER 4265). Words: shit, lil, still, really, hit, big, 'til, kill.
18. `vow:AO` — 4212 pairs (END 811, INNER 3401). Words: all, call, talking, lost, wanted, talk, water, walk.
19. `slant:AE:nas-stop` — 4207 pairs (END 470, INNER 3737). Words: can, man, back, had, gang, can't, ran, bad.
20. `slant:AH:nas` — 4204 pairs (END 634, INNER 3570). Words: money, some, young, one, come, done, run, runnin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 6275 pair sides, mostly spelling via spelling phonetic key, often with niggas (1565)
- niggas — 2635 pair sides, mostly spelling via spelling phonetic key, often with nigga (1565)
- ima — 2059 pair sides, mostly spelling via spelling phonetic key, often with bitch (313)
- gon — 1755 pair sides, mostly spelling via spelling phonetic key, often with dont (499)
- tryna — 1446 pair sides, mostly spelling via spelling phonetic key, often with these (143)
- migo — 501 pair sides, mostly spelling via spelling phonetic key, often with nigga (75)
- bando — 405 pair sides, mostly vowel via spelling phonetic key, often with no (37)
- shawty — 358 pair sides, mostly vowel via spelling phonetic key, often with all (36)
- quavo — 328 pair sides, mostly spelling via spelling phonetic key, often with know (21)
- wraith — 289 pair sides, mostly spelling via spelling phonetic key, often with aint (26)
- bros — 195 pair sides, mostly spelling via spelling phonetic key, often with know (17)
- migos — 184 pair sides, mostly spelling via spelling phonetic key, often with nigga (71)
- huncho — 179 pair sides, mostly vowel via spelling phonetic key, often with no (25)
- dawg — 168 pair sides, mostly spelling via spelling phonetic key, often with all (31)
- thot — 165 pair sides, mostly spelling via spelling phonetic key, often with got (17)
- swag — 165 pair sides, mostly spelling via spelling phonetic key, often with bag (10)
- birkin — 154 pair sides, mostly vowel via spelling phonetic key, often with bitch (45)
- rari — 152 pair sides, mostly spelling via spelling phonetic key, often with bad (14)
- lyin — 148 pair sides, mostly spelling via spelling phonetic key, often with these (16)
- finna — 144 pair sides, mostly vowel via spelling phonetic key, often with nigga (58)
- opps — 128 pair sides, mostly vowel via spelling phonetic key, often with dont (37)
- geeked — 123 pair sides, mostly spelling via spelling phonetic key, often with sleep (8)
- bruh — 113 pair sides, mostly spelling via spelling phonetic key, often with what (16)
- lambo — 111 pair sides, mostly vowel via spelling phonetic key, often with go (20)
- pics — 100 pair sides, mostly vowel via spelling phonetic key, often with bitch (17)
- glizzy — 92 pair sides, mostly vowel via spelling phonetic key, often with bitch (6)
- bling — 92 pair sides, mostly spelling via spelling phonetic key, often with bitch (9)
- cuffing — 92 pair sides, mostly spelling via spelling phonetic key, often with working (6)
- blicky — 88 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- geekin — 85 pair sides, mostly spelling via spelling phonetic key, often with sneakin (23)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Quality Control | 05:47 | 45 | 74 | 305 | loose |
| Quality Control | 1 Night | 31 | 43 | 236 | loose |
| Quality Control | 1.5 | 40 | 87 | 203 | loose |
| Quality Control | 100 Bands | 51 | 56 | 257 | loose |
| Quality Control | 100 Racks | 50 | 75 | 130 | loose |
| Quality Control | 100 Round | 40 | 52 | 120 | loose |
| Quality Control | 100 Shots | 26 | 37 | 160 | loose |
| Quality Control | 1017 | 37 | 26 | 151 | loose |
| Quality Control | 11.11 | 39 | 68 | 239 | loose |
| Quality Control | 12 Bricks | 44 | 24 | 88 | loose |
| Quality Control | 12th Street | 32 | 40 | 256 | loose |
| Quality Control | 16 YEAR OLD DRANK | 77 | 93 | 431 | loose |
| Quality Control | 1st N 3rd | 82 | 86 | 338 | loose |
| Quality Control | 1st Place | 50 | 57 | 311 | loose |
| Quality Control | 2 Bars | 26 | 25 | 122 | loose |
| Quality Control | 2 Birds 1 Stone | 39 | 47 | 163 | loose |
| Quality Control | 2 Choices | 47 | 41 | 363 | loose |
| Quality Control | 2 HANDS 2 EYES 10 WHIPS/RENT DUE | 84 | 78 | 570 | loose |
| Quality Control | 2 Many Bitches | 34 | 50 | 102 | loose |
| Quality Control | 2 Seater | 63 | 73 | 340 | loose |
| Quality Control | 2 Souls on Fire | 20 | 23 | 95 | loose |
| Quality Control | 2 The Hard Way | 34 | 27 | 183 | loose |
| Quality Control | 2.30 | 41 | 28 | 183 | loose |
| Quality Control | 2040 | 74 | 85 | 394 | loose |
| Quality Control | 285 | 51 | 44 | 219 | loose |
| Quality Control | 3 Headed Goat | 47 | 39 | 281 | loose |
| Quality Control | 3 Mics | 46 | 25 | 206 | loose |
| Quality Control | 3 SYRUPS | 73 | 90 | 215 | loose |
| Quality Control | 3 Way (Intro) | 74 | 110 | 381 | loose |
| Quality Control | 304 | 39 | 38 | 208 | loose |
| Quality Control | 350 | 58 | 57 | 505 | loose |
| Quality Control | 3rd Eye | 25 | 17 | 223 | loose |
| Quality Control | 4 Phones | 57 | 70 | 240 | loose |
| Quality Control | 4 Season | 20 | 10 | 221 | loose |
| Quality Control | 40/40 | 16 | 26 | 117 | loose |
| Quality Control | 5500 Degrees | 69 | 69 | 631 | loose |
| Quality Control | 5AM | 28 | 36 | 230 | loose |
| Quality Control | 5BRAZY REMIX | 38 | 35 | 230 | loose |
| Quality Control | 66 | 26 | 20 | 106 | loose |
| Quality Control | 9 on Me | 31 | 8 | 155 | loose |
| Quality Control | 90's Baby | 27 | 22 | 124 | loose |
| Quality Control | 99 | 34 | 17 | 249 | loose |
| Quality Control | 9To5 | 47 | 50 | 188 | loose |
| Quality Control | :(failure(: | 16 | 1 | 136 | loose |
| Quality Control | A Cold Sunday | 33 | 19 | 234 | loose |
| Quality Control | A Letter To You | 42 | 27 | 175 | loose |
| Quality Control | A-Town | 28 | 16 | 198 | loose |
| Quality Control | A.S.A.P | 37 | 52 | 265 | loose |
| Quality Control | ALL THE SAME | 53 | 30 | 228 | loose |
| Quality Control | ANIMOSITY | 38 | 37 | 237 | loose |
| Quality Control | APESHIT | 70 | 58 | 219 | loose |
| Quality Control | ARP | 42 | 24 | 503 | loose |
| Quality Control | ATM | 26 | 18 | 149 | loose |
| Quality Control | Above Water | 33 | 50 | 276 | loose |
| Quality Control | Act Like Them | 56 | 100 | 370 | loose |
| Quality Control | Act Up | 46 | 53 | 282 | loose |
| Quality Control | Active | 55 | 76 | 186 | loose |
| Quality Control | Add It Up | 54 | 51 | 240 | loose |
| Quality Control | Addicted to Gangsta | 41 | 60 | 159 | loose |
| Quality Control | Adios | 36 | 46 | 113 | loose |
| Quality Control | Afford It | 19 | 14 | 57 | loose |
| Quality Control | After Dark | 37 | 40 | 205 | loose |
| Quality Control | Ahora Me Llama (Remix) | 51 | 27 | 461 | loose |
| Quality Control | Aight | 36 | 54 | 146 | loose |
| Quality Control | Aim for the Moon | 41 | 32 | 169 | loose |
| Quality Control | Ain’t Enough | 28 | 13 | 230 | loose |
| Quality Control | Ain’t Mine | 67 | 77 | 268 | loose |
| Quality Control | Ain’t No Love | 42 | 35 | 333 | loose |
| Quality Control | Ain’t Nuthin | 51 | 72 | 158 | loose |
| Quality Control | Ain’t Workin’ Dat Move | 45 | 29 | 247 | loose |
| Quality Control | All Around Me | 43 | 28 | 177 | loose |
| Quality Control | All Ass | 47 | 61 | 184 | loose |
| Quality Control | All Dis Money | 48 | 55 | 222 | loose |
| Quality Control | All Dz Chainz | 36 | 56 | 361 | loose |
| Quality Control | All Facts No Fiction | 38 | 41 | 243 | loose |
| Quality Control | All Good | 55 | 84 | 303 | loose |
| Quality Control | All I Do Is Juug | 31 | 15 | 81 | loose |
| Quality Control | All I Ever Wanted | 30 | 19 | 93 | loose |
| Quality Control | All In | 44 | 42 | 349 | loose |
| Quality Control | All My Life | 40 | 39 | 228 | loose |
| Quality Control | All On Me | 70 | 146 | 599 | loose |
| Quality Control | All Over Me | 49 | 37 | 147 | loose |
| Quality Control | All Stars | 38 | 32 | 194 | loose |
| Quality Control | All The Money | 24 | 20 | 77 | loose |
| Quality Control | All You Had To Say | 36 | 29 | 111 | loose |
| Quality Control | All of a Sudden | 48 | 73 | 170 | loose |
| Quality Control | Alley Oop | 48 | 63 | 178 | loose |
| Quality Control | American Gangsta | 42 | 49 | 202 | loose |
| Quality Control | Annihilate (Spider-Man: Across the Spider-Verse) | 50 | 38 | 177 | loose |
| Quality Control | Antidope | 44 | 34 | 185 | loose |
| Quality Control | Antisocial | 41 | 28 | 234 | loose |
| Quality Control | Anything Goes | 36 | 28 | 132 | loose |
| Quality Control | Anyway | 72 | 105 | 268 | loose |
| Quality Control | Aquafina | 28 | 23 | 94 | loose |
| Quality Control | Aries (YuGo), Pt. 2 | 80 | 80 | 219 | loose |
| Quality Control | Asking for Money | 51 | 74 | 306 | loose |
| Quality Control | Asshole | 33 | 17 | 128 | loose |
| Quality Control | Attention | 36 | 27 | 254 | loose |
| Quality Control | Austin Powers | 40 | 40 | 212 | loose |
| Quality Control | Auto Pilot | 86 | 123 | 248 | loose |
| Quality Control | Avalanche | 93 | 127 | 488 | loose |
| Quality Control | BABY DADDY | 51 | 65 | 205 | loose |
| Quality Control | BBL | 19 | 21 | 144 | loose |
| Quality Control | BBO (Bad Bitches Only) | 48 | 40 | 259 | loose |
| Quality Control | BIG BRO | 32 | 21 | 153 | loose |
| Quality Control | BIG GOD | 39 | 34 | 291 | loose |
| Quality Control | BIG TIME | 32 | 19 | 183 | loose |
| Quality Control | BIGGEST ALLEY OOP | 40 | 60 | 220 | loose |
| Quality Control | BILLS PAID | 49 | 39 | 265 | loose |
| Quality Control | BLACK OPS | 41 | 64 | 240 | loose |
| Quality Control | BOOM! | 60 | 92 | 257 | loose |
| Quality Control | BUBBLE GUM | 32 | 25 | 134 | loose |
| Quality Control | BUCK THE SYSTEM | 58 | 98 | 392 | loose |
| Quality Control | BUCUM | 29 | 9 | 141 | loose |
| Quality Control | BUZZIN’ | 26 | 26 | 133 | loose |
| Quality Control | Baby | 47 | 53 | 367 | loose |
| Quality Control | Baby Sitter | 42 | 37 | 294 | loose |
| Quality Control | Bachelor | 63 | 99 | 310 | loose |
| Quality Control | Back Door | 42 | 43 | 364 | loose |
| Quality Control | Back On | 39 | 51 | 249 | loose |
| Quality Control | Back On The Road | 25 | 21 | 312 | loose |
| Quality Control | Back Where It Begins | 41 | 42 | 164 | loose |
| Quality Control | Back and Forth | 35 | 65 | 304 | loose |
| Quality Control | Back to the Bando | 43 | 54 | 199 | loose |
| Quality Control | Bad Bad Bad | 47 | 61 | 246 | loose |
| Quality Control | Bad Bitch | 29 | 51 | 197 | loose |
| Quality Control | Bad Cameo | 10 | 3 | 22 | loose |
| Quality Control | Bad and Boujee | 98 | 107 | 286 | loose |
| Quality Control | Baddest | 20 | 20 | 96 | loose |
| Quality Control | Bails | 36 | 38 | 187 | loose |
| Quality Control | Bait | 32 | 53 | 228 | loose |
| Quality Control | Bakers Man | 19 | 27 | 119 | loose |
| Quality Control | Balenciaga Challenge | 51 | 55 | 145 | loose |
| Quality Control | Ball Player | 54 | 39 | 148 | loose |
| Quality Control | Balls to the Wall | 16 | 24 | 81 | loose |
| Quality Control | Bando | 55 | 59 | 149 | loose |
| Quality Control | Bando to Mansion | 39 | 88 | 174 | loose |
| Quality Control | Bandz In The Bank | 50 | 43 | 161 | loose |
| Quality Control | Bank | 49 | 79 | 153 | loose |
| Quality Control | Bars | 104 | 193 | 650 | loose |
| Quality Control | Bars Into Captions | 62 | 93 | 241 | loose |
| Quality Control | Be Something | 47 | 67 | 318 | loose |
| Quality Control | Beast | 73 | 104 | 189 | loose |
| Quality Control | Been Here Before | 36 | 27 | 152 | loose |
| Quality Control | Been Thuggin | 23 | 10 | 118 | loose |
| Quality Control | Believe (Kende Remix) | 63 | 70 | 122 | loose |
| Quality Control | Belly | 64 | 93 | 315 | loose |
| Quality Control | Belt Line | 22 | 11 | 182 | loose |
| Quality Control | Best Behavior | 42 | 58 | 170 | loose |
| Quality Control | Best Man | 45 | 44 | 192 | loose |
| Quality Control | Best of Me | 41 | 57 | 330 | loose |
| Quality Control | Better | 33 | 29 | 107 | loose |
| Quality Control | BiPolar | 41 | 43 | 179 | loose |
| Quality Control | Big 14 | 40 | 63 | 301 | loose |
| Quality Control | Big Bag | 31 | 19 | 221 | loose |
| Quality Control | Big Bucks | 42 | 63 | 205 | loose |
| Quality Control | Big Drip (Remix) | 76 | 82 | 206 | loose |
| Quality Control | Big FlexHer | 46 | 30 | 287 | loose |
| Quality Control | Big On Big | 61 | 74 | 267 | loose |
| Quality Control | Big Rocks | 29 | 57 | 97 | loose |
| Quality Control | Big Stunna | 40 | 35 | 259 | loose |
| Quality Control | Big Tymers | 42 | 36 | 220 | loose |
| Quality Control | Birds | 49 | 40 | 215 | loose |
| Quality Control | Birthday | 56 | 61 | 330 | loose |
| Quality Control | Black & Chinese | 39 | 33 | 166 | loose |
| Quality Control | Black Jesus | 60 | 53 | 286 | loose |
| Quality Control | Bless Em | 37 | 61 | 274 | loose |
| Quality Control | Blow Like a Whistle | 44 | 59 | 230 | loose |
| Quality Control | Blue Cheese | 66 | 81 | 275 | loose |
| Quality Control | Boat Skirrt | 22 | 12 | 167 | loose |
| Quality Control | Body Parts | 57 | 69 | 359 | loose |
| Quality Control | Bon Appétit | 46 | 40 | 100 | loose |
| Quality Control | Boss Bitch | 45 | 50 | 178 | loose |
| Quality Control | Boss Up | 55 | 43 | 388 | loose |
| Quality Control | Bosses Don’t Speak | 62 | 100 | 234 | loose |
| Quality Control | Bouncy | 40 | 47 | 127 | loose |
| Quality Control | Bows | 38 | 61 | 148 | loose |
| Quality Control | Brand New | 31 | 26 | 177 | loose |
| Quality Control | Break the Bank | 40 | 61 | 180 | loose |
| Quality Control | Brick Talk | 23 | 27 | 130 | loose |
| Quality Control | Bring It Back | 37 | 18 | 75 | loose |
| Quality Control | Broke ASF | 41 | 31 | 271 | loose |
| Quality Control | Broke Boy | 28 | 21 | 173 | loose |
| Quality Control | Broke Leg | 46 | 50 | 283 | loose |
| Quality Control | Broke Niggas | 52 | 43 | 267 | loose |
| Quality Control | Broke or Rich 2 | 26 | 26 | 158 | loose |
| Quality Control | Brown Paper Bag | 63 | 99 | 205 | loose |
| Quality Control | Bruce Wayne (Outro) | 44 | 49 | 183 | loose |
| Quality Control | Bruised Up | 39 | 38 | 365 | loose |
| Quality Control | Built Like Me | 52 | 42 | 233 | loose |
| Quality Control | Burnt Out | 37 | 43 | 226 | loose |
| Quality Control | Business Is Business | 55 | 143 | 195 | loose |
| Quality Control | Bussdown | 53 | 47 | 200 | loose |
| Quality Control | Buy U Diamonds | 56 | 42 | 191 | loose |
| Quality Control | By Myself | 54 | 69 | 284 | loose |
| Quality Control | Bye Felicia | 34 | 48 | 80 | loose |
| Quality Control | CC | 65 | 121 | 340 | loose |
| Quality Control | CFWM | 22 | 27 | 141 | loose |
| Quality Control | CHAMPAGNE ROSÉ | 44 | 41 | 95 | loose |
| Quality Control | CHANGES | 34 | 53 | 219 | loose |
| Quality Control | COKE WHITE | 45 | 34 | 118 | loose |
| Quality Control | COPY, OK COOL | 79 | 84 | 337 | loose |
| Quality Control | COUNT ME IN | 45 | 31 | 170 | loose |
| Quality Control | CRACK THE CODE | 45 | 71 | 252 | loose |
| Quality Control | CRETE CYPHER INTRO | 63 | 93 | 518 | loose |
| Quality Control | CRU | 36 | 42 | 156 | loose |
| Quality Control | CRUNKSTARZ | 26 | 21 | 87 | loose |
| Quality Control | CTHP | 28 | 12 | 193 | loose |
| Quality Control | CUFFED UP | 18 | 15 | 17 | loose |
| Quality Control | California Breeze | 57 | 52 | 323 | loose |
| Quality Control | California Rain | 30 | 25 | 49 | loose |
| Quality Control | Call Casting | 76 | 137 | 163 | loose |
| Quality Control | Came From Nothin’ | 32 | 33 | 162 | loose |
| Quality Control | Came To Party | 75 | 115 | 466 | loose |
| Quality Control | Came a Long Way | 42 | 89 | 295 | loose |
| Quality Control | Came from Nothing | 53 | 60 | 234 | loose |
| Quality Control | Came from Scratch | 37 | 89 | 172 | loose |
| Quality Control | Camera Flash | 44 | 54 | 335 | loose |
| Quality Control | Can I Vent | 25 | 10 | 158 | loose |
| Quality Control | Cancer Stick No Pressure | 135 | 166 | 608 | loose |
| Quality Control | Can’t Be Crete Boy | 67 | 97 | 561 | loose |
| Quality Control | Can’t Believe It | 62 | 85 | 217 | loose |
| Quality Control | Can’t Explain | 44 | 46 | 433 | loose |
| Quality Control | Can’t Go | 19 | 20 | 102 | loose |
| Quality Control | Can’t Go Out Sad | 76 | 110 | 311 | loose |
| Quality Control | Can’t Have One | 54 | 55 | 220 | loose |
| Quality Control | Can’t Let You Go | 26 | 23 | 104 | loose |
| Quality Control | Can’t Stand | 16 | 14 | 55 | loose |
| Quality Control | Can’t Talk About It | 43 | 43 | 382 | loose |
| Quality Control | Can’t Talk To Me | 44 | 48 | 208 | loose |
| Quality Control | Cap | 52 | 51 | 174 | loose |
| Quality Control | Carbon | 24 | 11 | 131 | loose |
| Quality Control | Careless | 35 | 32 | 171 | loose |
| Quality Control | Carlos Story | 28 | 18 | 181 | loose |
| Quality Control | Cash | 66 | 55 | 108 | loose |
| Quality Control | Casper | 51 | 72 | 161 | loose |
| Quality Control | Catch the Sun | 40 | 49 | 262 | loose |
| Quality Control | Cday Freestyle | 58 | 68 | 141 | loose |
| Quality Control | Celean | 28 | 5 | 123 | loose |
| Quality Control | Certified | 20 | 22 | 70 | loose |
| Quality Control | Championship (Remix) | 34 | 23 | 142 | loose |
| Quality Control | Chance | 33 | 29 | 131 | loose |
| Quality Control | Chances | 65 | 142 | 308 | loose |
| Quality Control | Chances Make Champions | 31 | 38 | 258 | loose |
| Quality Control | Change | 32 | 37 | 363 | loose |
| Quality Control | Chapter 1 | 59 | 76 | 323 | loose |
| Quality Control | Charles Barkley | 43 | 18 | 241 | loose |
| Quality Control | Charmin’ | 31 | 38 | 79 | loose |
| Quality Control | Chase the Money | 63 | 72 | 341 | loose |
| Quality Control | Chastised | 38 | 38 | 171 | loose |
| Quality Control | Check | 44 | 49 | 147 | loose |
| Quality Control | Check Out My Dab | 35 | 42 | 74 | loose |
| Quality Control | China Town | 44 | 46 | 251 | loose |
| Quality Control | Chirp | 55 | 100 | 240 | loose |
| Quality Control | Chirpin’ | 46 | 61 | 245 | loose |
| Quality Control | Chocolate | 66 | 112 | 312 | loose |
| Quality Control | Chopsticks | 35 | 46 | 188 | loose |
| Quality Control | Chose Me | 33 | 30 | 374 | loose |
| Quality Control | Churches | 40 | 18 | 122 | loose |
| Quality Control | Circle of Bosses | 60 | 82 | 204 | loose |
| Quality Control | City on Lock | 35 | 29 | 232 | loose |
| Quality Control | Class of 2024 | 30 | 25 | 282 | loose |
| Quality Control | Clear the Air | 27 | 24 | 212 | loose |
| Quality Control | Click | 49 | 61 | 283 | loose |
| Quality Control | Close Friends | 41 | 39 | 160 | loose |
| Quality Control | Clout | 68 | 85 | 207 | loose |
| Quality Control | Cocaina | 48 | 63 | 234 | loose |
| Quality Control | Codeine | 26 | 20 | 188 | loose |
| Quality Control | Coffin | 42 | 26 | 160 | loose |
| Quality Control | Cold World | 49 | 43 | 234 | loose |
| Quality Control | Come Here | 37 | 43 | 312 | loose |
| Quality Control | Come On | 43 | 51 | 277 | loose |
| Quality Control | Come Outside | 36 | 26 | 261 | loose |
| Quality Control | Commando | 86 | 130 | 570 | loose |
| Quality Control | Commercial | 82 | 98 | 370 | loose |
| Quality Control | Computers (Freestyle) | 43 | 83 | 276 | AAAA |
| Quality Control | Concrete Boys | 30 | 28 | 121 | loose |
| Quality Control | Concrete Goonies | 39 | 38 | 220 | loose |
| Quality Control | Congratulations | 42 | 57 | 142 | loose |
| Quality Control | Consistent | 64 | 123 | 233 | loose |
| Quality Control | Contraband | 62 | 99 | 205 | loose |
| Quality Control | Conversation | 42 | 33 | 136 | loose |
| Quality Control | Cook It Up | 43 | 40 | 153 | loose |
| Quality Control | Coppers and Robbers | 78 | 141 | 284 | loose |
| Quality Control | Copy Me | 64 | 41 | 302 | loose |
| Quality Control | Cost To Be Alive | 47 | 62 | 370 | loose |
| Quality Control | Countdown | 33 | 21 | 236 | loose |
| Quality Control | Crazy | 74 | 78 | 372 | loose |
| Quality Control | Crazy Dream | 62 | 36 | 295 | loose |
| Quality Control | Crazy World | 44 | 61 | 364 | loose |
| Quality Control | Cross the Country | 125 | 156 | 738 | loose |
| Quality Control | Crown the Kings | 62 | 88 | 291 | loose |
| Quality Control | Crunk Ain’t Dead | 45 | 26 | 105 | loose |
| Quality Control | Crush a Lot | 53 | 40 | 218 | loose |
| Quality Control | Crypto | 49 | 52 | 211 | loose |
| Quality Control | Cuban Link | 43 | 26 | 309 | loose |
| Quality Control | Culture | 61 | 83 | 165 | loose |
| Quality Control | Culture National Anthem (Outro) | 53 | 71 | 207 | loose |
| Quality Control | Curb Service | 23 | 32 | 130 | loose |
| Quality Control | D.O.P.E. | 52 | 46 | 149 | loose |
| Quality Control | DAILY BREAD | 34 | 39 | 218 | loose |
| Quality Control | DARK BROTHERHOOD | 40 | 64 | 281 | loose |
| Quality Control | DAS CAP | 39 | 23 | 166 | loose |
| Quality Control | DIALED IN | 39 | 38 | 221 | loose |
| Quality Control | DIE FOR MINE | 79 | 98 | 502 | loose |
| Quality Control | DN Freestyle | 43 | 43 | 261 | loose |
| Quality Control | DND | 21 | 18 | 123 | loose |
| Quality Control | DOD | 30 | 31 | 237 | loose |
| Quality Control | DPWM | 23 | 20 | 138 | loose |
| Quality Control | Da Spot | 21 | 40 | 148 | AAAA |
| Quality Control | Da Truth | 23 | 49 | 170 | loose |
| Quality Control | Dab | 88 | 124 | 376 | loose |
| Quality Control | Dab Daddy | 47 | 80 | 250 | loose |
| Quality Control | Dancin’ on Me | 30 | 8 | 103 | loose |
| Quality Control | Danger | 47 | 64 | 150 | loose |
| Quality Control | Dark Nights (Remix) | 53 | 53 | 396 | loose |
| Quality Control | Darth Vader | 42 | 49 | 315 | loose |
| Quality Control | Dat Way | 59 | 55 | 299 | loose |
| Quality Control | Dates | 47 | 42 | 167 | loose |
| Quality Control | Days Off | 32 | 39 | 160 | loose |
| Quality Control | Days of the Week | 62 | 88 | 409 | loose |
| Quality Control | Dead Fresh | 37 | 36 | 302 | loose |
| Quality Control | Dead Friends | 51 | 46 | 132 | loose |
| Quality Control | Dead Man Walking | 26 | 21 | 92 | loose |
| Quality Control | Deadz | 45 | 83 | 241 | loose |
| Quality Control | Dealer | 29 | 24 | 180 | loose |
| Quality Control | Decline | 52 | 85 | 440 | loose |
| Quality Control | Deep End | 34 | 34 | 241 | loose |
| Quality Control | Demon Time | 79 | 67 | 436 | loose |
| Quality Control | Dennis Rodman | 46 | 24 | 298 | loose |
| Quality Control | Derek Fisher | 32 | 52 | 239 | loose |
| Quality Control | Designer | 31 | 37 | 279 | loose |
| Quality Control | Designer Drugz | 58 | 77 | 132 | loose |
| Quality Control | Diamonds | 23 | 29 | 126 | loose |
| Quality Control | Different Colors | 30 | 32 | 198 | loose |
| Quality Control | Different Day | 28 | 38 | 229 | loose |
| Quality Control | Dig Up The Dead | 35 | 86 | 288 | AAAA |
| Quality Control | DipSet | 45 | 34 | 227 | loose |
| Quality Control | Dirk Nowitzki | 29 | 28 | 72 | loose |
| Quality Control | Dirty | 27 | 4 | 159 | loose |
| Quality Control | Dirty Mouth | 86 | 59 | 248 | loose |
| Quality Control | Dirty Stick | 47 | 67 | 262 | loose |
| Quality Control | Disciples | 33 | 33 | 191 | loose |
| Quality Control | Disrespectful | 60 | 32 | 192 | loose |
| Quality Control | Dive In | 36 | 26 | 130 | loose |
| Quality Control | Do Better | 65 | 45 | 286 | loose |
| Quality Control | Do It (Remix) | 95 | 90 | 320 | loose |
| Quality Control | Do It On The Tip | 46 | 31 | 320 | loose |
| Quality Control | Do Not Disturb | 52 | 52 | 192 | loose |
| Quality Control | Do What I Wanna Do | 97 | 94 | 328 | loose |
| Quality Control | Do What It Do | 16 | 12 | 44 | loose |
| Quality Control | Do or Die | 20 | 29 | 220 | loose |
| Quality Control | Don’t Even Bother | 35 | 57 | 303 | loose |
| Quality Control | Don’t Forget | 28 | 22 | 111 | loose |
| Quality Control | Don’t Know | 26 | 13 | 125 | loose |
| Quality Control | Don’t Like | 36 | 63 | 253 | loose |
| Quality Control | Don’t Lose Me | 59 | 113 | 129 | loose |
| Quality Control | Don’t Love You | 35 | 23 | 221 | loose |
| Quality Control | Don’t Need Much | 29 | 15 | 66 | loose |
| Quality Control | Don’t Rate Me | 42 | 25 | 215 | loose |
| Quality Control | Don’t Sleep | 44 | 48 | 332 | loose |
| Quality Control | Door Lock | 40 | 27 | 182 | loose |
| Quality Control | Dope | 4 | 0 | 2 | loose |
| Quality Control | Dope Boy Phone | 37 | 39 | 176 | loose |
| Quality Control | Dope In My Sock | 31 | 31 | 170 | loose |
| Quality Control | Dope Talk | 50 | 60 | 345 | loose |
| Quality Control | Double CC’s | 49 | 49 | 287 | loose |
| Quality Control | Double Down | 44 | 63 | 416 | loose |
| Quality Control | Double Trouble | 37 | 33 | 175 | loose |
| Quality Control | Down For Too Long | 24 | 18 | 139 | loose |
| Quality Control | Down Like That | 40 | 44 | 211 | loose |
| Quality Control | Downfall | 64 | 39 | 342 | loose |
| Quality Control | Dr Dolittle | 37 | 31 | 127 | loose |
| Quality Control | Drama | 67 | 78 | 200 | loose |
| Quality Control | Dramatic | 55 | 51 | 257 | loose |
| Quality Control | Dreams 2 Reality | 58 | 48 | 397 | loose |
| Quality Control | Drip | 78 | 114 | 287 | loose |
| Quality Control | Drip Check | 22 | 30 | 205 | loose |
| Quality Control | Drip Like Dis | 77 | 99 | 472 | loose |
| Quality Control | Drip Like This | 28 | 26 | 129 | loose |
| Quality Control | Drip Too Hard | 33 | 43 | 188 | loose |
| Quality Control | Drippin | 43 | 31 | 135 | loose |
| Quality Control | Drop A Tear | 51 | 29 | 181 | loose |
| Quality Control | Drop It Off | 37 | 28 | 165 | loose |
| Quality Control | Drug Dealer | 21 | 24 | 77 | loose |
| Quality Control | Drugs Only (Remix) | 64 | 40 | 216 | loose |
| Quality Control | Drugs Talkin | 46 | 99 | 133 | loose |
| Quality Control | Dubai Shit | 41 | 35 | 115 | loose |
| Quality Control | Due 4A Win | 37 | 35 | 425 | loose |
| Quality Control | Due2DaFact | 55 | 71 | 255 | loose |
| Quality Control | Dum, Dumb, and Dumber | 104 | 108 | 303 | loose |
| Quality Control | Dynamic Duo | 79 | 101 | 534 | loose |
| Quality Control | EAST POINT PRAYER | 44 | 49 | 245 | loose |
| Quality Control | Early Morning Trappin | 48 | 52 | 171 | loose |
| Quality Control | Easy | 31 | 38 | 116 | loose |
| Quality Control | Eat Or Starve | 38 | 21 | 154 | loose |
| Quality Control | Emmitt Smith | 60 | 51 | 231 | loose |
| Quality Control | Emoji A Chain | 52 | 69 | 258 | loose |
| Quality Control | Emotionally Scarred | 51 | 46 | 386 | loose |
| Quality Control | End of Discussion | 71 | 81 | 183 | loose |
| Quality Control | Enough/Better | 61 | 41 | 240 | loose |
| Quality Control | Envy | 21 | 9 | 133 | loose |
| Quality Control | Errbody | 88 | 125 | 515 | loose |
| Quality Control | Everlasting | 37 | 14 | 166 | loose |
| Quality Control | Everything | 39 | 53 | 317 | loose |
| Quality Control | Everything Good, Everything Right | 34 | 25 | 58 | loose |
| Quality Control | Ex For A Reason | 49 | 37 | 194 | loose |
| Quality Control | Exotic | 52 | 68 | 213 | loose |
| Quality Control | Expensive | 52 | 38 | 143 | loose |
| Quality Control | Extra | 30 | 18 | 103 | loose |
| Quality Control | Eye 2 Eye | 46 | 77 | 169 | loose |
| Quality Control | F Cancer (Boosie) | 70 | 75 | 401 | loose |
| Quality Control | F U 2x | 52 | 79 | 260 | loose |
| Quality Control | F*ck 12 | 43 | 22 | 126 | loose |
| Quality Control | F.A.N. | 39 | 33 | 286 | loose |
| Quality Control | FALLING OFF | 32 | 36 | 274 | loose |
| Quality Control | FEMA | 37 | 36 | 176 | loose |
| Quality Control | FLEX | 22 | 16 | 170 | loose |
| Quality Control | FLIP DA SWITCH | 36 | 22 | 272 | loose |
| Quality Control | FLIP THE SWITCH | 38 | 50 | 141 | loose |
| Quality Control | FLY | 28 | 29 | 132 | loose |
| Quality Control | FORGET YALL | 30 | 26 | 236 | loose |
| Quality Control | FORGIVE ME | 31 | 34 | 186 | loose |
| Quality Control | FR | 42 | 24 | 236 | loose |
| Quality Control | FUCK 12 | 56 | 60 | 224 | loose |
| Quality Control | FUCKEMx3 | 70 | 59 | 331 | loose |
| Quality Control | FULLY LOADED | 38 | 68 | 197 | loose |
| Quality Control | FWM | 40 | 54 | 268 | loose |
| Quality Control | FYI (Know Now) | 31 | 28 | 146 | loose |
| Quality Control | Faith | 29 | 54 | 145 | loose |
| Quality Control | Faizon | 21 | 18 | 129 | loose |
| Quality Control | Fake Luv | 19 | 15 | 97 | loose |
| Quality Control | Falisha | 64 | 35 | 233 | loose |
| Quality Control | Fall Back | 69 | 65 | 421 | loose |
| Quality Control | Fall Threw | 54 | 75 | 116 | loose |
| Quality Control | Fallin’ in Luv | 34 | 43 | 87 | loose |
| Quality Control | Famous | 50 | 40 | 100 | loose |
| Quality Control | Fantasy | 64 | 166 | 286 | loose |
| Quality Control | Far Gone | 54 | 95 | 168 | loose |
| Quality Control | Fasho Dat | 58 | 40 | 200 | loose |
| Quality Control | Fasho Fasho | 45 | 49 | 153 | loose |
| Quality Control | Father of 4 | 52 | 52 | 265 | loose |
| Quality Control | Favorite Girl | 33 | 39 | 98 | loose |
| Quality Control | Faze Me | 40 | 11 | 288 | loose |
| Quality Control | Fear Of God | 39 | 13 | 332 | loose |
| Quality Control | Feed Me Dope | 36 | 24 | 193 | loose |
| Quality Control | Feel The Fiyaaaah | 64 | 68 | 261 | loose |
| Quality Control | Feel This | 35 | 24 | 194 | loose |
| Quality Control | Feels Good 2 Be Rich | 38 | 23 | 149 | loose |
| Quality Control | Feels Good 2 Be Rich Intro | 4 | 1 | 12 | loose |
| Quality Control | Female Goat (Remix) | 64 | 91 | 398 | loose |
| Quality Control | Fendi Drip | 47 | 41 | 253 | loose |
| Quality Control | Field | 47 | 61 | 371 | loose |
| Quality Control | Fight Night | 45 | 28 | 222 | loose |
| Quality Control | Fight Night Round 3 | 60 | 78 | 432 | loose |
| Quality Control | Final Form | 38 | 76 | 215 | loose |
| Quality Control | Finally Rich | 63 | 45 | 163 | loose |
| Quality Control | Finesser | 48 | 44 | 211 | loose |
| Quality Control | First 48 | 43 | 33 | 156 | loose |
| Quality Control | First Class | 49 | 62 | 213 | loose |
| Quality Control | First Day Out | 36 | 41 | 192 | loose |
| Quality Control | Fit In | 50 | 76 | 314 | loose |
| Quality Control | FlEXiBle | 37 | 46 | 156 | loose |
| Quality Control | Flewed Out | 53 | 70 | 266 | loose |
| Quality Control | Flex Up | 36 | 18 | 246 | loose |
| Quality Control | Flights | 48 | 80 | 259 | loose |
| Quality Control | Flood Watch | 58 | 63 | 268 | loose |
| Quality Control | Flooded | 79 | 138 | 187 | loose |
| Quality Control | Fly With A Fish | 23 | 41 | 162 | loose |
| Quality Control | Flying Coach | 67 | 106 | 289 | loose |
| Quality Control | Focused | 46 | 23 | 253 | loose |
| Quality Control | For Hot 97 | 107 | 94 | 388 | loose |
| Quality Control | For Keeps | 35 | 52 | 249 | loose |
| Quality Control | For Trappers Only | 29 | 22 | 270 | loose |
| Quality Control | For You | 60 | 52 | 182 | loose |
| Quality Control | For the Night | 43 | 54 | 219 | loose |
| Quality Control | Forest Whitaker | 42 | 29 | 195 | loose |
| Quality Control | Forever | 41 | 33 | 262 | loose |
| Quality Control | Forever Slime | 42 | 59 | 242 | loose |
| Quality Control | Forever World | 39 | 48 | 122 | loose |
| Quality Control | Forever Young | 26 | 26 | 98 | loose |
| Quality Control | Forget That | 53 | 44 | 328 | loose |
| Quality Control | Freak No More | 60 | 47 | 323 | loose |
| Quality Control | Freaky | 45 | 39 | 349 | loose |
| Quality Control | Free Offset (Freestyle) | 56 | 72 | 161 | loose |
| Quality Control | Free Promo | 60 | 81 | 316 | loose |
| Quality Control | Freestyle | 84 | 104 | 220 | loose |
| Quality Control | French Drip | 25 | 15 | 117 | loose |
| Quality Control | Friendly | 40 | 29 | 223 | loose |
| Quality Control | From Down Bad | 40 | 29 | 117 | loose |
| Quality Control | From Now On | 68 | 72 | 378 | loose |
| Quality Control | From The City | 40 | 34 | 198 | loose |
| Quality Control | From the Streets | 31 | 24 | 207 | loose |
| Quality Control | Frosted Flakes | 63 | 107 | 290 | loose |
| Quality Control | Froze Up | 36 | 14 | 281 | loose |
| Quality Control | Frozen | 53 | 33 | 412 | loose |
| Quality Control | Fuck Dat Nigga | 64 | 81 | 285 | loose |
| Quality Control | Fuck Em | 48 | 14 | 192 | loose |
| Quality Control | Fuck On U | 35 | 10 | 160 | loose |
| Quality Control | Fuck Up The Pot | 43 | 84 | 206 | loose |
| Quality Control | Fuck Up the City | 53 | 72 | 161 | loose |
| Quality Control | Fuck the Rap Game (Remix) | 65 | 55 | 320 | loose |
| Quality Control | Fucked Over | 19 | 14 | 52 | loose |
| Quality Control | Fucked Up The Kitchen | 40 | 47 | 116 | loose |
| Quality Control | Fucking Up Profits | 66 | 101 | 238 | loose |
| Quality Control | Fueled Up | 43 | 71 | 133 | loose |
| Quality Control | Future | 34 | 52 | 131 | loose |
| Quality Control | G.I. Joe | 53 | 47 | 144 | loose |
| Quality Control | GET MONEY BROS. | 40 | 59 | 228 | loose |
| Quality Control | GHETTO GOSPEL | 46 | 72 | 308 | loose |
| Quality Control | GIVE IT TO EM | 38 | 29 | 135 | loose |
| Quality Control | GO ALL THE WAY | 26 | 16 | 51 | loose |
| Quality Control | GUMMO (Remix) | 60 | 107 | 316 | loose |
| Quality Control | Galaxy | 34 | 40 | 170 | loose |
| Quality Control | Games | 27 | 11 | 98 | loose |
| Quality Control | Gang | 29 | 25 | 101 | loose |
| Quality Control | Gang Gang | 41 | 46 | 140 | loose |
| Quality Control | Gang Signs | 41 | 38 | 303 | loose |
| Quality Control | Gangsta Rap | 26 | 31 | 127 | loose |
| Quality Control | Gargoyle | 63 | 67 | 135 | loose |
| Quality Control | Gas Station Love | 37 | 11 | 114 | loose |
| Quality Control | Georgia Ways | 30 | 21 | 135 | loose |
| Quality Control | Get Along | 68 | 90 | 294 | loose |
| Quality Control | Get Down | 61 | 64 | 286 | loose |
| Quality Control | Get Dripped | 53 | 61 | 145 | loose |
| Quality Control | Get Em In | 61 | 59 | 228 | loose |
| Quality Control | Get Money | 46 | 48 | 300 | loose |
| Quality Control | Get Out | 14 | 4 | 101 | loose |
| Quality Control | Get Rich | 54 | 75 | 341 | loose |
| Quality Control | Get Right Witcha | 58 | 94 | 208 | loose |
| Quality Control | Get Ugly | 47 | 51 | 210 | loose |
| Quality Control | Ghetto Boy Shit | 53 | 78 | 443 | loose |
| Quality Control | Ghost Busters | 55 | 73 | 225 | loose |
| Quality Control | Ghostface Killers | 57 | 51 | 359 | loose |
| Quality Control | Giannis | 46 | 39 | 342 | loose |
| Quality Control | Gimmie My Respect | 48 | 40 | 187 | loose |
| Quality Control | Girls Gone Wild | 33 | 24 | 166 | loose |
| Quality Control | Girls Have Fun | 41 | 74 | 191 | loose |
| Quality Control | Give It a Try | 30 | 24 | 134 | loose |
| Quality Control | Give No Fxk | 38 | 28 | 252 | loose |
| Quality Control | Global | 38 | 51 | 189 | loose |
| Quality Control | Go | 21 | 39 | 118 | loose |
| Quality Control | Go Get Em | 54 | 92 | 312 | loose |
| Quality Control | Go Hard | 69 | 59 | 423 | loose |
| Quality Control | Go Krazy, Go Stupid Freestyle | 40 | 41 | 238 | loose |
| Quality Control | Go Off | 45 | 25 | 155 | loose |
| Quality Control | Go The Distance | 30 | 37 | 161 | loose |
| Quality Control | God Bless The 6 | 68 | 68 | 335 | loose |
| Quality Control | Goin Crazy | 46 | 47 | 231 | loose |
| Quality Control | Goin Krazy | 17 | 6 | 93 | loose |
| Quality Control | Going For It | 49 | 39 | 204 | loose |
| Quality Control | Goin’ Down | 23 | 28 | 235 | loose |
| Quality Control | Golden | 35 | 34 | 270 | loose |
| Quality Control | Golden Child | 35 | 13 | 381 | loose |
| Quality Control | Gone | 42 | 30 | 273 | loose |
| Quality Control | Good Day | 26 | 30 | 137 | loose |
| Quality Control | Good Dope | 40 | 105 | 215 | AAAA |
| Quality Control | Good Drank | 61 | 59 | 276 | loose |
| Quality Control | Good Love | 47 | 39 | 122 | loose |
| Quality Control | Grab A... | 43 | 44 | 152 | loose |
| Quality Control | Grace | 79 | 80 | 380 | loose |
| Quality Control | Greatness | 47 | 88 | 228 | loose |
| Quality Control | Grew Up in the Streets | 28 | 14 | 128 | loose |
| Quality Control | Grindin | 44 | 33 | 151 | loose |
| Quality Control | Gu Wop | 1 | 0 | 4 | loose |
| Quality Control | Guaranteed | 39 | 31 | 310 | loose |
| Quality Control | Gucci | 33 | 66 | 283 | loose |
| Quality Control | Gucci On My | 66 | 88 | 267 | loose |
| Quality Control | Guwop | 86 | 100 | 299 | loose |
| Quality Control | HAD ENOUGH | 43 | 52 | 159 | loose |
| Quality Control | HELL NAH | 41 | 58 | 240 | loose |
| Quality Control | HIDE THEY HAND | 24 | 37 | 274 | loose |
| Quality Control | HIGHEST IN THE ROOM (REMIX) | 53 | 60 | 198 | loose |
| Quality Control | HIM | 25 | 24 | 274 | loose |
| Quality Control | HIT DIFF | 37 | 55 | 284 | loose |
| Quality Control | HOTEL LOBBY (Unc & Phew) | 37 | 46 | 193 | loose |
| Quality Control | HOW BOUT THAT? | 40 | 49 | 74 | loose |
| Quality Control | HUNCHO DREAMS | 70 | 34 | 186 | loose |
| Quality Control | Had To Ask | 33 | 71 | 299 | loose |
| Quality Control | Handle My Business | 80 | 140 | 407 | loose |
| Quality Control | Handsome and Wealthy | 45 | 36 | 175 | loose |
| Quality Control | Hannah Montana | 33 | 37 | 211 | loose |
| Quality Control | Harley | 32 | 23 | 88 | loose |
| Quality Control | Hate It or Love It | 60 | 74 | 218 | loose |
| Quality Control | Hate Me | 66 | 43 | 312 | loose |
| Quality Control | Hats Off | 96 | 101 | 393 | loose |
| Quality Control | Having Our Way | 84 | 160 | 408 | loose |
| Quality Control | Heard You | 30 | 40 | 95 | loose |
| Quality Control | Heartless | 35 | 25 | 185 | loose |
| Quality Control | Heat | 35 | 29 | 100 | loose |
| Quality Control | Heatin Up | 69 | 92 | 402 | loose |
| Quality Control | Hell Yeah | 42 | 79 | 273 | loose |
| Quality Control | Hella | 29 | 16 | 116 | loose |
| Quality Control | Hellcat | 48 | 44 | 208 | loose |
| Quality Control | Heyy | 60 | 40 | 315 | loose |
| Quality Control | Higher We Go (Intro) | 72 | 123 | 215 | loose |
| Quality Control | Highway 85 | 66 | 45 | 366 | loose |
| Quality Control | Himothy | 48 | 75 | 442 | loose |
| Quality Control | Hit | 47 | 64 | 232 | loose |
| Quality Control | Hit Bout It | 60 | 91 | 489 | loose |
| Quality Control | Hit Em | 48 | 43 | 198 | loose |
| Quality Control | Hoe on a Mission | 68 | 69 | 297 | loose |
| Quality Control | Hold Me | 37 | 49 | 118 | loose |
| Quality Control | Holiday | 46 | 35 | 225 | loose |
| Quality Control | Holy Steppin’ | 41 | 49 | 380 | loose |
| Quality Control | Homicide Boat | 42 | 61 | 160 | loose |
| Quality Control | Homies | 42 | 37 | 183 | loose |
| Quality Control | Honey Bun | 30 | 17 | 120 | loose |
| Quality Control | Hook Up | 65 | 70 | 216 | loose |
| Quality Control | Hoop | 42 | 49 | 138 | loose |
| Quality Control | Hot Boy | 45 | 36 | 178 | loose |
| Quality Control | Hot Girl Summer | 45 | 42 | 343 | loose |
| Quality Control | Hot Summer | 59 | 75 | 271 | loose |
| Quality Control | Hotpocket | 32 | 46 | 206 | loose |
| Quality Control | How | 52 | 84 | 366 | loose |
| Quality Control | How Did I Get Here | 85 | 97 | 317 | loose |
| Quality Control | How Does It Feel | 25 | 34 | 168 | loose |
| Quality Control | How I Know | 36 | 52 | 191 | loose |
| Quality Control | How It Feels | 46 | 40 | 373 | loose |
| Quality Control | How I’m Feelin | 54 | 53 | 308 | loose |
| Quality Control | How Many Times | 36 | 37 | 305 | loose |
| Quality Control | How U Feel | 44 | 38 | 140 | loose |
| Quality Control | How to Pimp a Nigga | 32 | 18 | 210 | loose |
| Quality Control | Human Nature | 25 | 34 | 279 | loose |
| Quality Control | Humble | 51 | 81 | 386 | loose |
| Quality Control | Huncho Jack | 57 | 90 | 98 | loose |
| Quality Control | Hunnits Trynna Run | 33 | 20 | 240 | loose |
| Quality Control | Hurricane | 54 | 40 | 317 | loose |
| Quality Control | Hurry | 41 | 39 | 157 | loose |
| Quality Control | Hurtin | 42 | 31 | 254 | loose |
| Quality Control | Hurts Like Hell | 47 | 51 | 105 | loose |
| Quality Control | Hybrid | 71 | 94 | 494 | loose |
| Quality Control | I AIN’T WORRIED BOUT IT | 25 | 16 | 223 | loose |
| Quality Control | I Ain’t Mad At Ya | 37 | 32 | 256 | loose |
| Quality Control | I Am | 48 | 58 | 215 | loose |
| Quality Control | I Am Not Perfect | 31 | 48 | 295 | loose |
| Quality Control | I DID IT | 49 | 45 | 227 | loose |
| Quality Control | I Do It | 56 | 87 | 191 | loose |
| Quality Control | I GET CRUNK | 23 | 28 | 155 | loose |
| Quality Control | I Get the Bag | 75 | 133 | 272 | loose |
| Quality Control | I Heard | 79 | 88 | 324 | loose |
| Quality Control | I Know | 37 | 17 | 303 | loose |
| Quality Control | I Look Good | 26 | 25 | 86 | loose |
| Quality Control | I Need A Thug | 32 | 35 | 173 | loose |
| Quality Control | I Need You | 26 | 26 | 205 | loose |
| Quality Control | I Promise | 40 | 45 | 382 | loose |
| Quality Control | I Really Do This | 31 | 39 | 206 | loose |
| Quality Control | I Remember | 25 | 42 | 190 | loose |
| Quality Control | I Suppose | 32 | 62 | 208 | loose |
| Quality Control | ICE | 32 | 32 | 234 | loose |
| Quality Control | IDK | 46 | 51 | 157 | loose |
| Quality Control | IF I WASN’T RAPPIN | 62 | 106 | 438 | loose |
| Quality Control | ISOLIT | 36 | 27 | 101 | loose |
| Quality Control | ITS ON ME | 35 | 57 | 212 | loose |
| Quality Control | IVE OFFICIALLY LOST ViSiON!!!! | 35 | 30 | 143 | loose |
| Quality Control | Ice On | 33 | 24 | 151 | loose |
| Quality Control | Ice Tray | 42 | 69 | 133 | loose |
| Quality Control | Iced Out My Arms | 71 | 99 | 272 | loose |
| Quality Control | Idol | 40 | 55 | 255 | loose |
| Quality Control | If I Fall | 58 | 70 | 165 | loose |
| Quality Control | If I Got It | 42 | 46 | 140 | loose |
| Quality Control | If You Want To | 57 | 65 | 406 | loose |
| Quality Control | Important | 44 | 59 | 100 | loose |
| Quality Control | In A Hurry | 36 | 31 | 308 | loose |
| Quality Control | In A Minute | 48 | 70 | 514 | loose |
| Quality Control | In Grey | 18 | 11 | 46 | loose |
| Quality Control | In My DM | 73 | 137 | 431 | loose |
| Quality Control | In My Feelings | 48 | 34 | 170 | loose |
| Quality Control | In My Stussy’s | 36 | 39 | 155 | loose |
| Quality Control | In My Thoughts | 47 | 40 | 370 | loose |
| Quality Control | In N Out | 38 | 47 | 218 | loose |
| Quality Control | In Too Deep | 41 | 22 | 238 | loose |
| Quality Control | Independent | 42 | 33 | 189 | loose |
| Quality Control | Infatuation | 38 | 51 | 205 | loose |
| Quality Control | Insecurities | 37 | 69 | 292 | loose |
| Quality Control | Insomnia | 61 | 66 | 153 | loose |
| Quality Control | Integration | 47 | 55 | 265 | loose |
| Quality Control | Intentions | 32 | 33 | 152 | loose |
| Quality Control | Interlude | 15 | 13 | 72 | loose |
| Quality Control | Interview | 60 | 69 | 234 | loose |
| Quality Control | Intro | 45 | 37 | 141 | loose |
| Quality Control | Intro No Label II | 96 | 107 | 486 | loose |
| Quality Control | It’s All on U | 61 | 139 | 296 | loose |
| Quality Control | I’m A Dick | 23 | 23 | 73 | loose |
| Quality Control | I’m Better | 38 | 24 | 136 | loose |
| Quality Control | I’m Sorry | 20 | 14 | 36 | loose |
| Quality Control | I’m Straight | 43 | 42 | 358 | loose |
| Quality Control | I’m the Mac | 25 | 27 | 70 | loose |
| Quality Control | I’m the One | 51 | 40 | 269 | loose |
| Quality Control | JAMBALAYA | 23 | 55 | 114 | loose |
| Quality Control | JEFF & LITA | 71 | 121 | 477 | loose |
| Quality Control | JT Coming | 29 | 24 | 157 | loose |
| Quality Control | JT First Day Out | 69 | 74 | 418 | loose |
| Quality Control | JUST SAY THAT | 46 | 25 | 198 | loose |
| Quality Control | Jane | 67 | 96 | 233 | loose |
| Quality Control | Jewel Baby (TYCOON$ Original)* | 11 | 4 | 64 | loose |
| Quality Control | Jobs | 25 | 17 | 93 | loose |
| Quality Control | John Wick | 80 | 110 | 373 | loose |
| Quality Control | Joyride | 27 | 30 | 95 | loose |
| Quality Control | Jumpin’ Like Jordan | 55 | 76 | 202 | loose |
| Quality Control | Just How I’m Feelin’ | 43 | 56 | 431 | loose |
| Quality Control | Just Wait On It | 50 | 54 | 172 | loose |
| Quality Control | Just for Tonight | 47 | 33 | 270 | loose |
| Quality Control | K4KK | 37 | 53 | 196 | loose |
| Quality Control | KEEP THAT SHIT | 32 | 19 | 142 | loose |
| Quality Control | Keep Coming | 30 | 42 | 151 | loose |
| Quality Control | Keep It 100 | 48 | 31 | 86 | loose |
| Quality Control | Kelly Price | 67 | 125 | 253 | loose |
| Quality Control | Ken Nyugen | 28 | 28 | 175 | loose |
| Quality Control | Kick It | 35 | 25 | 181 | loose |
| Quality Control | Kick the Door Down | 51 | 40 | 191 | loose |
| Quality Control | Kidding Me | 49 | 46 | 204 | loose |
| Quality Control | Killin’ Time | 55 | 60 | 271 | loose |
| Quality Control | King of Teens | 22 | 40 | 152 | loose |
| Quality Control | Kitty Talk | 37 | 28 | 153 | loose |
| Quality Control | Know It’s Me | 32 | 24 | 235 | loose |
| Quality Control | Know My Rights | 54 | 83 | 268 | loose |
| Quality Control | LA REID | 22 | 17 | 64 | loose |
| Quality Control | LAMB TALK | 44 | 40 | 180 | loose |
| Quality Control | LETTER TO MY SON | 31 | 26 | 136 | loose |
| Quality Control | LIKE ME | 33 | 23 | 237 | loose |
| Quality Control | LIL ANGEL “SHE HER” | 32 | 29 | 168 | loose |
| Quality Control | LOSE IT | 61 | 56 | 179 | loose |
| Quality Control | LOST | 49 | 49 | 166 | loose |
| Quality Control | La La | 35 | 48 | 424 | loose |
| Quality Control | Lady in Yellow | 26 | 24 | 91 | loose |
| Quality Control | Lafamilia | 29 | 5 | 213 | loose |
| Quality Control | Large | 31 | 22 | 165 | loose |
| Quality Control | Last Memory | 46 | 92 | 172 | loose |
| Quality Control | Last Real Trap Rapper | 50 | 55 | 331 | loose |
| Quality Control | Laugh | 31 | 43 | 134 | loose |
| Quality Control | Lawyer Fees | 32 | 39 | 283 | loose |
| Quality Control | Lead the Wave | 58 | 92 | 182 | loose |
| Quality Control | Leaked | 47 | 29 | 225 | loose |
| Quality Control | Leave Em Alone | 34 | 22 | 180 | loose |
| Quality Control | Legacy | 82 | 82 | 349 | loose |
| Quality Control | Legend | 37 | 23 | 247 | loose |
| Quality Control | Legends | 70 | 70 | 333 | loose |
| Quality Control | Lemon Head | 38 | 55 | 249 | loose |
| Quality Control | Lemon Pepper | 37 | 24 | 275 | loose |
| Quality Control | Lets Get On Dey Ass | 32 | 22 | 69 | loose |
| Quality Control | Letter To Dolph | 39 | 29 | 194 | loose |
| Quality Control | Let’s Do It | 46 | 42 | 369 | loose |
| Quality Control | Let’s Get It | 23 | 10 | 115 | loose |
| Quality Control | Lexy Sove | 36 | 47 | 172 | loose |
| Quality Control | Lick | 46 | 73 | 283 | loose |
| Quality Control | Lie | 29 | 68 | 76 | loose |
| Quality Control | Life | 50 | 56 | 331 | loose |
| Quality Control | Life Goes On | 54 | 92 | 288 | loose |
| Quality Control | Life Is Good (Remix) | 115 | 144 | 879 | loose |
| Quality Control | Life So Hard | 55 | 52 | 302 | loose |
| Quality Control | Light It Up | 77 | 119 | 297 | loose |
| Quality Control | Like That | 58 | 54 | 307 | loose |
| Quality Control | Like a Star | 35 | 29 | 136 | loose |
| Quality Control | Lil Diamond Boy | 28 | 0 | 63 | loose |
| Quality Control | Lil Mama | 42 | 58 | 89 | loose |
| Quality Control | Listen Up | 51 | 70 | 361 | loose |
| Quality Control | Lit AF | 35 | 20 | 121 | loose |
| Quality Control | Live From The 3 | 35 | 39 | 78 | loose |
| Quality Control | Live It Up | 29 | 10 | 38 | loose |
| Quality Control | Live Like Dis | 36 | 42 | 236 | loose |
| Quality Control | Live Off My Closet | 56 | 66 | 355 | loose |
| Quality Control | Living Life | 39 | 32 | 245 | loose |
| Quality Control | Lobby Runners (Intro) | 16 | 4 | 58 | loose |
| Quality Control | Lonely Top | 49 | 41 | 209 | loose |
| Quality Control | Long Nights | 34 | 40 | 241 | loose |
| Quality Control | Long Time | 36 | 44 | 97 | loose |
| Quality Control | Longtime | 1 | 0 | 0 | loose |
| Quality Control | Look @ This | 28 | 28 | 177 | loose |
| Quality Control | Look At Me | 50 | 32 | 65 | loose |
| Quality Control | Look at My Dab | 60 | 113 | 240 | loose |
| Quality Control | Lord of the Beans | 63 | 84 | 430 | loose |
| Quality Control | Lost It | 84 | 110 | 286 | loose |
| Quality Control | Lost Y’all Mind | 36 | 53 | 217 | loose |
| Quality Control | Love In The City | 33 | 32 | 181 | loose |
| Quality Control | Love Jones | 19 | 18 | 79 | loose |
| Quality Control | Love Music | 21 | 16 | 62 | loose |
| Quality Control | Love Myself | 31 | 44 | 100 | loose |
| Quality Control | Low Down | 50 | 73 | 295 | loose |
| Quality Control | Lowest | 73 | 76 | 270 | loose |
| Quality Control | Luh Mo’ Love | 32 | 6 | 92 | loose |
| Quality Control | Luv Syrup | 37 | 15 | 297 | loose |
| Quality Control | Lying | 44 | 67 | 370 | loose |
| Quality Control | M&M’s | 53 | 28 | 98 | loose |
| Quality Control | M.O.B. | 47 | 65 | 343 | loose |
| Quality Control | MICKEY | 48 | 58 | 179 | loose |
| Quality Control | MILLIONAIRE | 73 | 78 | 382 | loose |
| Quality Control | MONEY BANDANA | 42 | 81 | 378 | loose |
| Quality Control | MY LIFE | 23 | 24 | 166 | loose |
| Quality Control | Mac 10 | 40 | 45 | 186 | loose |
| Quality Control | Mad 304 | 17 | 9 | 118 | loose |
| Quality Control | Mad Stalkers | 50 | 67 | 242 | loose |
| Quality Control | Made It | 60 | 113 | 172 | loose |
| Quality Control | Made Man | 41 | 18 | 338 | loose |
| Quality Control | Made Men | 47 | 85 | 285 | loose |
| Quality Control | Made of Glass | 23 | 21 | 153 | loose |
| Quality Control | Magellanic | 32 | 57 | 289 | loose |
| Quality Control | Magic City | 41 | 54 | 161 | loose |
| Quality Control | Mahomes | 78 | 88 | 553 | loose |
| Quality Control | Major Bag Alert | 54 | 44 | 196 | loose |
| Quality Control | Make A Way | 50 | 50 | 163 | loose |
| Quality Control | Make It Out | 48 | 63 | 488 | loose |
| Quality Control | Make It Work (Remix) | 43 | 59 | 143 | loose |
| Quality Control | Malibu | 93 | 138 | 497 | loose |
| Quality Control | Mama Told Me | 28 | 18 | 146 | loose |
| Quality Control | Mama We Made It | 62 | 120 | 171 | loose |
| Quality Control | Man of My Word | 57 | 74 | 287 | loose |
| Quality Control | Married to the Money | 25 | 32 | 133 | loose |
| Quality Control | Marry The Trap | 31 | 30 | 236 | loose |
| Quality Control | Martian (Intro) | 56 | 64 | 234 | loose |
| Quality Control | Master P Intro | 16 | 4 | 53 | loose |
| Quality Control | Me or Sum | 74 | 57 | 438 | loose |
| Quality Control | Medical | 34 | 38 | 221 | loose |
| Quality Control | Mediterranean | 44 | 50 | 284 | loose |
| Quality Control | Memoirs | 44 | 43 | 282 | loose |
| Quality Control | Menace | 38 | 49 | 186 | loose |
| Quality Control | Menace 2 | 64 | 120 | 247 | loose |
| Quality Control | Merch Madness | 28 | 19 | 181 | loose |
| Quality Control | Messy | 32 | 52 | 160 | loose |
| Quality Control | Middle of the Summer | 40 | 28 | 272 | loose |
| Quality Control | Midnight | 31 | 16 | 131 | loose |
| Quality Control | Migo Dreams | 58 | 47 | 208 | loose |
| Quality Control | Migo Lingo Freestyle | 69 | 60 | 339 | loose |
| Quality Control | Migo Montana | 42 | 50 | 122 | loose |
| Quality Control | Migos Origin | 63 | 74 | 320 | loose |
| Quality Control | Millionaire Dick | 23 | 13 | 155 | loose |
| Quality Control | Mind Yo Business | 29 | 34 | 135 | loose |
| Quality Control | Mink | 27 | 27 | 169 | loose |
| Quality Control | Minnesota (Remix) | 65 | 51 | 342 | loose |
| Quality Control | Minute | 49 | 77 | 214 | loose |
| Quality Control | Mirror Mirror | 48 | 38 | 263 | loose |
| Quality Control | Missing Man | 18 | 14 | 59 | loose |
| Quality Control | Mixy | 59 | 72 | 240 | loose |
| Quality Control | Modern Day | 96 | 131 | 401 | loose |
| Quality Control | Modern Slavery | 38 | 24 | 120 | loose |
| Quality Control | Moments in Time | 27 | 30 | 45 | loose |
| Quality Control | Momma (Outro) | 35 | 10 | 157 | loose |
| Quality Control | Momma Mil | 26 | 34 | 221 | loose |
| Quality Control | Momma We Rich | 32 | 30 | 185 | loose |
| Quality Control | Money | 45 | 62 | 152 | loose |
| Quality Control | Money Forever | 67 | 116 | 319 | loose |
| Quality Control | Money On My Head | 49 | 54 | 312 | loose |
| Quality Control | Moolah | 29 | 20 | 92 | loose |
| Quality Control | Moon Rock | 39 | 44 | 211 | loose |
| Quality Control | Motion | 40 | 40 | 278 | loose |
| Quality Control | MotorSport | 98 | 114 | 392 | loose |
| Quality Control | Motorcycle Patches | 47 | 67 | 180 | loose |
| Quality Control | Move | 60 | 85 | 379 | loose |
| Quality Control | Movie | 49 | 45 | 202 | loose |
| Quality Control | Movin’ Too Fast | 47 | 46 | 352 | loose |
| Quality Control | Movin’ Up | 35 | 35 | 119 | loose |
| Quality Control | Mrs. Trendsetter | 44 | 41 | 346 | loose |
| Quality Control | MuhFuckn Tired | 78 | 153 | 367 | loose |
| Quality Control | Murda | 29 | 30 | 108 | loose |
| Quality Control | Muscle | 26 | 38 | 121 | loose |
| Quality Control | Muñekita | 47 | 28 | 285 | loose |
| Quality Control | My Business | 45 | 40 | 163 | loose |
| Quality Control | My Choppa Hate Niggas | 33 | 24 | 183 | loose |
| Quality Control | My Dawg | 88 | 89 | 293 | loose |
| Quality Control | My Drip | 49 | 94 | 124 | loose |
| Quality Control | My Hoes Got Money | 31 | 21 | 143 | loose |
| Quality Control | My Home | 44 | 64 | 185 | loose |
| Quality Control | My Hood | 36 | 54 | 284 | loose |
| Quality Control | My Jeans | 30 | 31 | 94 | loose |
| Quality Control | My Kind | 58 | 26 | 573 | loose |
| Quality Control | My Line | 41 | 51 | 178 | loose |
| Quality Control | My Momma | 40 | 17 | 133 | loose |
| Quality Control | My Nigga | 27 | 17 | 118 | loose |
| Quality Control | My Problems | 40 | 47 | 298 | loose |
| Quality Control | My Shawty | 52 | 37 | 159 | loose |
| Quality Control | NADEAN | 46 | 36 | 336 | loose |
| Quality Control | NBAYOUNGBOAT | 59 | 67 | 389 | loose |
| Quality Control | NOBODY NEEDS NOBODY | 29 | 17 | 196 | loose |
| Quality Control | NOT DA 2 | 33 | 20 | 204 | loose |
| Quality Control | Narcos | 61 | 58 | 282 | loose |
| Quality Control | Narcs | 48 | 81 | 195 | loose |
| Quality Control | Narkedo Speaks | 10 | 1 | 37 | loose |
| Quality Control | Nasty (Who Dat) | 33 | 31 | 149 | loose |
| Quality Control | Nasty Girl | 65 | 74 | 238 | loose |
| Quality Control | Naw For Real | 51 | 51 | 219 | loose |
| Quality Control | Nawf On Da Map | 38 | 32 | 102 | loose |
| Quality Control | Nawfside | 52 | 63 | 228 | loose |
| Quality Control | Need It | 65 | 132 | 278 | loose |
| Quality Control | Neighborhood Scientists | 30 | 30 | 233 | loose |
| Quality Control | Nervous | 83 | 94 | 181 | loose |
| Quality Control | Net Worth | 32 | 35 | 206 | loose |
| Quality Control | Never Did Coke | 68 | 72 | 399 | loose |
| Quality Control | Never Hating | 48 | 39 | 272 | loose |
| Quality Control | Never Landing | 24 | 24 | 314 | loose |
| Quality Control | Never Needed No Help | 36 | 28 | 151 | loose |
| Quality Control | Never Recover | 83 | 163 | 429 | loose |
| Quality Control | Never Sleep | 51 | 95 | 258 | loose |
| Quality Control | Never Switch Up | 17 | 8 | 74 | loose |
| Quality Control | New Atlanta | 87 | 90 | 347 | loose |
| Quality Control | New Freezer | 40 | 40 | 130 | loose |
| Quality Control | New To You | 42 | 48 | 213 | loose |
| Quality Control | New Trip | 47 | 52 | 184 | loose |
| Quality Control | New Wrist | 30 | 35 | 53 | loose |
| Quality Control | Next Up | 59 | 72 | 293 | loose |
| Quality Control | Niggas Like Us | 27 | 48 | 89 | loose |
| Quality Control | Night Call | 71 | 71 | 246 | loose |
| Quality Control | Night Like This | 36 | 28 | 146 | loose |
| Quality Control | Night Time | 28 | 17 | 103 | loose |
| Quality Control | Nightmare | 29 | 38 | 139 | loose |
| Quality Control | No Bars | 57 | 42 | 306 | loose |
| Quality Control | No Blanks | 61 | 118 | 202 | loose |
| Quality Control | No Brainer | 47 | 32 | 130 | loose |
| Quality Control | No Ceilings | 37 | 26 | 100 | loose |
| Quality Control | No Choice | 38 | 35 | 108 | loose |
| Quality Control | No Complaints | 64 | 123 | 147 | loose |
| Quality Control | No Flash | 20 | 10 | 189 | loose |
| Quality Control | No Fly Zone | 57 | 75 | 504 | loose |
| Quality Control | No Friends | 44 | 53 | 349 | loose |
| Quality Control | No Fuckin Wit | 38 | 22 | 163 | loose |
| Quality Control | No Honorable Mention | 73 | 95 | 238 | loose |
| Quality Control | No Hook | 85 | 48 | 637 | loose |
| Quality Control | No Instagram | 30 | 53 | 211 | loose |
| Quality Control | No More | 16 | 2 | 76 | loose |
| Quality Control | No More Bitches | 34 | 51 | 218 | loose |
| Quality Control | No Pressure | 28 | 13 | 135 | loose |
| Quality Control | No Privacy | 32 | 24 | 209 | loose |
| Quality Control | No Question | 64 | 68 | 178 | loose |
| Quality Control | No Sucker | 65 | 104 | 274 | loose |
| Quality Control | No Time (Broke Nigga) | 32 | 20 | 128 | loose |
| Quality Control | No Y | 14 | 7 | 98 | loose |
| Quality Control | Nolia | 69 | 82 | 181 | loose |
| Quality Control | NonChalant | 26 | 14 | 41 | loose |
| Quality Control | None to Me | 33 | 14 | 154 | loose |
| Quality Control | North Star | 62 | 71 | 282 | loose |
| Quality Control | Not Done Yet | 20 | 14 | 85 | loose |
| Quality Control | Not Finished | 51 | 74 | 482 | loose |
| Quality Control | Not My Bro | 21 | 46 | 112 | loose |
| Quality Control | Not Out | 51 | 54 | 205 | loose |
| Quality Control | Not Ya Main | 32 | 17 | 160 | loose |
| Quality Control | Notha Level | 52 | 82 | 347 | loose |
| Quality Control | Nothing Changed | 49 | 100 | 333 | loose |
| Quality Control | Notice Me | 38 | 51 | 113 | loose |
| Quality Control | Numb | 37 | 41 | 217 | loose |
| Quality Control | OG Mac | 18 | 24 | 164 | loose |
| Quality Control | OKAY | 29 | 28 | 137 | loose |
| Quality Control | ON THE RADAR CONCRETE CYPHER | 109 | 162 | 936 | loose |
| Quality Control | OOPS | 41 | 56 | 261 | loose |
| Quality Control | Off My Chest | 35 | 38 | 220 | loose |
| Quality Control | Off White VLONE | 40 | 52 | 284 | loose |
| Quality Control | Off the Road to the Trap | 34 | 73 | 247 | loose |
| Quality Control | Oh | 36 | 27 | 146 | loose |
| Quality Control | Oh My Dis Side | 75 | 81 | 160 | loose |
| Quality Control | Oh Okay | 59 | 72 | 190 | loose |
| Quality Control | Oh Yea | 20 | 18 | 34 | loose |
| Quality Control | Ohhhh | 32 | 41 | 168 | loose |
| Quality Control | On Fleek | 70 | 142 | 211 | loose |
| Quality Control | On Go | 36 | 27 | 121 | loose |
| Quality Control | On Me | 31 | 56 | 287 | loose |
| Quality Control | On My Lawyer | 41 | 36 | 214 | loose |
| Quality Control | On My Pradas | 29 | 21 | 110 | loose |
| Quality Control | On My Soul | 65 | 92 | 231 | loose |
| Quality Control | On My Way | 55 | 54 | 193 | loose |
| Quality Control | On The Edge | 24 | 5 | 276 | loose |
| Quality Control | On U | 30 | 16 | 80 | loose |
| Quality Control | On the Low | 30 | 22 | 126 | loose |
| Quality Control | On the Regular | 51 | 71 | 164 | loose |
| Quality Control | On the Road | 45 | 36 | 285 | loose |
| Quality Control | Once Again | 75 | 53 | 434 | loose |
| Quality Control | One Night | 44 | 71 | 130 | loose |
| Quality Control | One Of One | 41 | 46 | 434 | loose |
| Quality Control | One Shot | 38 | 39 | 251 | loose |
| Quality Control | One Shot, Two Shot | 29 | 44 | 141 | loose |
| Quality Control | One Time | 74 | 94 | 312 | loose |
| Quality Control | One of Them Nights | 31 | 36 | 166 | loose |
| Quality Control | One of Them Ones | 56 | 44 | 320 | loose |
| Quality Control | Only Thing Changed | 21 | 32 | 88 | loose |
| Quality Control | Only You | 50 | 39 | 279 | loose |
| Quality Control | Open It Up | 54 | 78 | 280 | loose |
| Quality Control | Oprah’s Bank Account | 42 | 35 | 176 | loose |
| Quality Control | Option | 49 | 41 | 225 | loose |
| Quality Control | Otha Boy | 27 | 16 | 226 | loose |
| Quality Control | Otha Shit (Interlude) | 12 | 25 | 61 | AAAA |
| Quality Control | Ounces | 58 | 36 | 349 | loose |
| Quality Control | Our Year | 31 | 56 | 166 | loose |
| Quality Control | Out | 29 | 41 | 291 | loose |
| Quality Control | Out Late | 20 | 8 | 32 | loose |
| Quality Control | Out Yo Way | 60 | 43 | 232 | loose |
| Quality Control | Out the Gym | 78 | 68 | 336 | loose |
| Quality Control | Out the Mud | 34 | 35 | 138 | loose |
| Quality Control | Outfit | 77 | 151 | 363 | loose |
| Quality Control | Outta Proportion | 42 | 25 | 175 | loose |
| Quality Control | Ouu Ouu | 33 | 21 | 232 | loose |
| Quality Control | Over Active | 33 | 52 | 310 | loose |
| Quality Control | Over It | 39 | 38 | 156 | loose |
| Quality Control | PARTY | 58 | 81 | 228 | loose |
| Quality Control | PASS OUT | 58 | 84 | 200 | loose |
| Quality Control | PFK | 46 | 23 | 163 | loose |
| Quality Control | PICK UP | 41 | 61 | 247 | loose |
| Quality Control | PIMPIN AINT EASY | 30 | 39 | 70 | loose |
| Quality Control | PINK AND BLUE | 31 | 20 | 130 | loose |
| Quality Control | PLAYA WALKIN | 32 | 28 | 195 | loose |
| Quality Control | PLEASURES | 47 | 27 | 183 | loose |
| Quality Control | POINT ME TO IT | 39 | 47 | 185 | loose |
| Quality Control | PUSH IT | 64 | 39 | 479 | loose |
| Quality Control | Pablo Remix | 54 | 54 | 315 | loose |
| Quality Control | Pack Gone Missing | 61 | 46 | 290 | loose |
| Quality Control | Pamela | 31 | 53 | 151 | loose |
| Quality Control | Pandemic Boys | 49 | 58 | 362 | loose |
| Quality Control | Panties and Bra | 27 | 17 | 68 | loose |
| Quality Control | Paper Cuts | 32 | 60 | 299 | loose |
| Quality Control | Pardon Me | 64 | 81 | 260 | loose |
| Quality Control | Pastor | 46 | 79 | 403 | loose |
| Quality Control | Patek Water | 39 | 33 | 242 | loose |
| Quality Control | Patty Cake | 38 | 58 | 187 | loose |
| Quality Control | Payola | 46 | 58 | 179 | loose |
| Quality Control | Peek a Boo | 68 | 61 | 216 | loose |
| Quality Control | People’s Elbow | 49 | 96 | 221 | loose |
| Quality Control | Perfect | 57 | 42 | 456 | loose |
| Quality Control | Perfect Time | 44 | 64 | 133 | loose |
| Quality Control | Perfect Timing | 47 | 72 | 320 | loose |
| Quality Control | Period (We Live) | 38 | 25 | 182 | loose |
| Quality Control | Phone Line | 49 | 39 | 126 | loose |
| Quality Control | Phone Ringing | 25 | 27 | 148 | loose |
| Quality Control | Picasso | 76 | 138 | 308 | loose |
| Quality Control | Pickin’ Sides | 32 | 41 | 356 | loose |
| Quality Control | Pineapple | 30 | 19 | 187 | loose |
| Quality Control | Pink Slip | 51 | 43 | 244 | loose |
| Quality Control | Pink Toes | 67 | 125 | 422 | loose |
| Quality Control | Pipe Down | 41 | 51 | 134 | loose |
| Quality Control | Pipe It Up | 48 | 52 | 195 | loose |
| Quality Control | Piped Up (Streets On Lock 2) | 30 | 13 | 83 | loose |
| Quality Control | Pistol | 41 | 36 | 259 | loose |
| Quality Control | Piñata | 32 | 35 | 137 | loose |
| Quality Control | Plan B | 74 | 117 | 210 | loose |
| Quality Control | Plastic | 66 | 124 | 582 | loose |
| Quality Control | Playa Playa | 61 | 57 | 399 | loose |
| Quality Control | Please | 67 | 71 | 468 | loose |
| Quality Control | Plenty | 64 | 62 | 388 | loose |
| Quality Control | Plug | 45 | 57 | 233 | loose |
| Quality Control | Plug Walk | 31 | 21 | 90 | loose |
| Quality Control | Pointers | 47 | 50 | 145 | loose |
| Quality Control | Poland | 9 | 8 | 11 | loose |
| Quality Control | Pop It | 51 | 63 | 212 | loose |
| Quality Control | Pop Out | 57 | 74 | 549 | loose |
| Quality Control | Pop Out Again | 53 | 89 | 312 | loose |
| Quality Control | Pop Shit | 92 | 138 | 239 | loose |
| Quality Control | Pop That | 74 | 54 | 340 | loose |
| Quality Control | Portland | 59 | 58 | 303 | loose |
| Quality Control | Position to Win | 56 | 66 | 152 | loose |
| Quality Control | Potato Loaded | 27 | 49 | 202 | loose |
| Quality Control | Pour Out The Seal | 31 | 17 | 140 | loose |
| Quality Control | Power | 33 | 56 | 282 | loose |
| Quality Control | Pray for the Drip | 49 | 55 | 167 | loose |
| Quality Control | Pretty Little Lady | 66 | 96 | 296 | loose |
| Quality Control | Priceless | 46 | 49 | 163 | loose |
| Quality Control | Priorities | 34 | 30 | 107 | loose |
| Quality Control | Problems | 61 | 60 | 372 | loose |
| Quality Control | Projects | 41 | 45 | 303 | loose |
| Quality Control | Pronto | 48 | 40 | 216 | loose |
| Quality Control | Prospect | 66 | 97 | 216 | loose |
| Quality Control | Prosper | 34 | 26 | 130 | loose |
| Quality Control | Protect My Millions | 54 | 46 | 312 | loose |
| Quality Control | Pull Up | 32 | 37 | 116 | loose |
| Quality Control | Pumped Up Kicks | 46 | 21 | 294 | loose |
| Quality Control | Pure Cocaine | 40 | 39 | 239 | loose |
| Quality Control | Pure Water | 47 | 39 | 236 | loose |
| Quality Control | Pussy Talk | 49 | 59 | 196 | loose |
| Quality Control | Put a Date on It | 64 | 49 | 210 | loose |
| Quality Control | Pyrex | 42 | 46 | 333 | loose |
| Quality Control | QC Addiction | 68 | 71 | 236 | loose |
| Quality Control | Quarter Milli | 51 | 61 | 219 | loose |
| Quality Control | Quarter Million Dollars | 28 | 28 | 171 | loose |
| Quality Control | Quit Playin’ | 35 | 20 | 182 | loose |
| Quality Control | R.I.P | 31 | 9 | 159 | loose |
| Quality Control | RACE TO AN M | 31 | 61 | 273 | loose |
| Quality Control | RAF | 113 | 155 | 313 | loose |
| Quality Control | RAW SHIT | 71 | 95 | 273 | loose |
| Quality Control | REACH THE SUNSHINE. | 24 | 12 | 32 | loose |
| Quality Control | RERUN | 39 | 39 | 237 | loose |
| Quality Control | RESPECT | 47 | 60 | 376 | loose |
| Quality Control | RIP FOLLIES | 41 | 55 | 185 | loose |
| Quality Control | RNS | 37 | 21 | 120 | loose |
| Quality Control | RUNNING OUTTA LOVE | 22 | 23 | 74 | loose |
| Quality Control | Rac Racing | 46 | 24 | 194 | loose |
| Quality Control | Racks 2 Skinny | 69 | 77 | 231 | loose |
| Quality Control | Racks In | 22 | 21 | 105 | loose |
| Quality Control | Racks Out | 34 | 37 | 115 | loose |
| Quality Control | Racks Today | 34 | 25 | 119 | loose |
| Quality Control | Rags2Riches 2 | 52 | 64 | 204 | loose |
| Quality Control | Ran It Up | 47 | 34 | 190 | loose |
| Quality Control | Ran Out | 34 | 27 | 150 | loose |
| Quality Control | Range Rover Sports Truck | 35 | 35 | 131 | loose |
| Quality Control | Rap Game | 42 | 36 | 257 | loose |
| Quality Control | Rap Saved Me | 59 | 103 | 154 | loose |
| Quality Control | Rap Shit | 35 | 33 | 228 | loose |
| Quality Control | Rapper Weed | 33 | 57 | 234 | loose |
| Quality Control | Raw ASL | 37 | 30 | 252 | loose |
| Quality Control | Ready | 43 | 61 | 232 | loose |
| Quality Control | Ready For War | 47 | 50 | 157 | loose |
| Quality Control | Real & Fake | 44 | 35 | 287 | loose |
| Quality Control | Real As It Gets | 59 | 95 | 341 | loose |
| Quality Control | Real Niggaz (Remix) | 28 | 21 | 145 | loose |
| Quality Control | Real One | 28 | 46 | 145 | loose |
| Quality Control | Real Shit | 39 | 54 | 551 | loose |
| Quality Control | Real Spill | 47 | 51 | 486 | loose |
| Quality Control | Real Street Nigga | 46 | 53 | 249 | loose |
| Quality Control | Real Type | 37 | 36 | 262 | loose |
| Quality Control | Realist in It | 63 | 83 | 375 | loose |
| Quality Control | Really Did It | 36 | 38 | 200 | loose |
| Quality Control | Recognition | 56 | 80 | 211 | loose |
| Quality Control | Record Straight | 27 | 21 | 155 | loose |
| Quality Control | Red Carpet | 15 | 13 | 48 | loose |
| Quality Control | Red Flowers | 24 | 44 | 169 | loose |
| Quality Control | Red Room | 79 | 197 | 295 | loose |
| Quality Control | Redbone | 25 | 29 | 225 | loose |
| Quality Control | Remember | 38 | 28 | 175 | loose |
| Quality Control | Remix | 53 | 56 | 190 | loose |
| Quality Control | Ric Flair Drip | 34 | 20 | 167 | loose |
| Quality Control | Rich Baby Mama | 38 | 32 | 244 | loose |
| Quality Control | Rich Nigga Shit | 33 | 33 | 142 | loose |
| Quality Control | Rich Nigga Still Trappin’ | 46 | 65 | 330 | loose |
| Quality Control | Rich Nigga Timeline | 100 | 89 | 471 | loose |
| Quality Control | Rich Off Grass (Remix) | 28 | 52 | 167 | loose |
| Quality Control | Rich Off Pain | 50 | 72 | 331 | loose |
| Quality Control | Rich Than Famous (Intro) | 17 | 9 | 124 | loose |
| Quality Control | Rich Then Famous (Intro) | 30 | 39 | 188 | loose |
| Quality Control | Richer | 43 | 34 | 426 | loose |
| Quality Control | Richer Than Rappers | 37 | 52 | 151 | loose |
| Quality Control | Rick Owens | 11 | 6 | 83 | loose |
| Quality Control | Ride | 52 | 88 | 422 | loose |
| Quality Control | Ride Home | 37 | 22 | 132 | loose |
| Quality Control | Ride My Wave | 48 | 39 | 306 | loose |
| Quality Control | Ride or Die | 26 | 15 | 143 | loose |
| Quality Control | Rider | 55 | 29 | 251 | loose |
| Quality Control | Right Now | 42 | 34 | 323 | loose |
| Quality Control | Right On | 45 | 46 | 426 | loose |
| Quality Control | Right from Wrong | 42 | 33 | 92 | loose |
| Quality Control | Riley from the Boondocks | 47 | 56 | 159 | loose |
| Quality Control | Ring Ring | 40 | 43 | 129 | loose |
| Quality Control | Rinky Dinky | 28 | 14 | 292 | loose |
| Quality Control | Riot | 49 | 68 | 213 | loose |
| Quality Control | Roadrunner | 94 | 123 | 346 | loose |
| Quality Control | Rob Who | 34 | 17 | 279 | loose |
| Quality Control | Rocket Power | 36 | 57 | 190 | loose |
| Quality Control | Rockets | 41 | 54 | 159 | loose |
| Quality Control | Rocky Balboa | 50 | 40 | 176 | loose |
| Quality Control | Rodeo | 39 | 28 | 200 | loose |
| Quality Control | Roger That | 34 | 35 | 62 | loose |
| Quality Control | Role Model | 24 | 26 | 129 | loose |
| Quality Control | Rose Gold | 35 | 65 | 286 | loose |
| Quality Control | Run Away From The Rabbit | 25 | 16 | 64 | loose |
| Quality Control | Run It Up | 86 | 116 | 453 | loose |
| Quality Control | Run Up the Racks | 32 | 14 | 126 | loose |
| Quality Control | Run/Running | 42 | 26 | 127 | loose |
| Quality Control | Runnin | 45 | 47 | 206 | loose |
| Quality Control | Running This Shit | 35 | 23 | 284 | loose |
| Quality Control | Running With a Ghost | 41 | 45 | 131 | loose |
| Quality Control | Russian Roulette | 49 | 25 | 365 | loose |
| Quality Control | SB 2021 | 61 | 57 | 427 | loose |
| Quality Control | SB5 | 81 | 131 | 314 | loose |
| Quality Control | SELF MADE | 19 | 32 | 98 | loose |
| Quality Control | SHINE | 35 | 39 | 191 | loose |
| Quality Control | SOLDIERS STEPPIN | 34 | 31 | 132 | loose |
| Quality Control | SOLO STEPPIN CRETE BOY | 44 | 48 | 287 | loose |
| Quality Control | SPIN | 50 | 53 | 191 | loose |
| Quality Control | SRGYRN | 39 | 44 | 216 | loose |
| Quality Control | STADIUM | 29 | 57 | 217 | loose |
| Quality Control | STAYING ALIVE | 32 | 34 | 188 | loose |
| Quality Control | STFU Freestyle | 28 | 15 | 53 | loose |
| Quality Control | SWING | 47 | 29 | 158 | loose |
| Quality Control | Sacrifices | 70 | 92 | 377 | loose |
| Quality Control | Sadam Usane | 36 | 37 | 180 | loose |
| Quality Control | Saint | 27 | 22 | 52 | loose |
| Quality Control | Saint Laurent Mask | 39 | 32 | 96 | loose |
| Quality Control | SaintLaurentYSL | 33 | 23 | 138 | loose |
| Quality Control | Same Thing | 38 | 64 | 217 | loose |
| Quality Control | Saran Wrap | 30 | 20 | 223 | loose |
| Quality Control | Savages Only | 62 | 76 | 284 | loose |
| Quality Control | Save That | 31 | 42 | 163 | loose |
| Quality Control | Save The Savior | 26 | 33 | 134 | loose |
| Quality Control | Savior | 30 | 32 | 94 | loose |
| Quality Control | Say My Name | 35 | 32 | 186 | loose |
| Quality Control | Say So | 32 | 28 | 248 | loose |
| Quality Control | Say Twin | 39 | 36 | 86 | loose |
| Quality Control | Scooby & Shaggy | 66 | 129 | 297 | loose |
| Quality Control | Seals Pills | 32 | 43 | 205 | loose |
| Quality Control | Season | 42 | 35 | 240 | loose |
| Quality Control | Secrets | 47 | 49 | 170 | loose |
| Quality Control | Section 8 | 52 | 36 | 231 | loose |
| Quality Control | See Bout It | 46 | 52 | 219 | loose |
| Quality Control | See What I’m Saying (Intro) | 25 | 18 | 123 | loose |
| Quality Control | Seen a Lot | 39 | 39 | 100 | loose |
| Quality Control | Seize the Block | 47 | 90 | 278 | loose |
| Quality Control | Seizure | 53 | 66 | 143 | loose |
| Quality Control | Send Me Pack | 34 | 33 | 182 | loose |
| Quality Control | Servin | 47 | 32 | 242 | loose |
| Quality Control | Set The Record Straight | 37 | 26 | 163 | loose |
| Quality Control | Set Up Shop (Remix) | 44 | 38 | 282 | loose |
| Quality Control | Sex Lies | 34 | 44 | 235 | loose |
| Quality Control | Shai Gilly | 38 | 52 | 257 | loose |
| Quality Control | Shake the Room | 37 | 46 | 91 | loose |
| Quality Control | Shawn Kemp | 61 | 62 | 244 | loose |
| Quality Control | She Ain’t Goin’ | 37 | 26 | 165 | loose |
| Quality Control | She Flexin’ | 32 | 24 | 130 | loose |
| Quality Control | She For Keeps | 45 | 29 | 206 | loose |
| Quality Control | She Gon Wink | 47 | 95 | 118 | loose |
| Quality Control | She Know It | 40 | 31 | 132 | loose |
| Quality Control | Sheesh 2 | 40 | 33 | 194 | loose |
| Quality Control | Shiest Talk | 44 | 61 | 289 | loose |
| Quality Control | Shinin | 36 | 52 | 241 | loose |
| Quality Control | Shmoney | 59 | 42 | 300 | loose |
| Quality Control | Shmoney Never Stop | 42 | 50 | 328 | loose |
| Quality Control | Shoot Out the Roof | 33 | 22 | 255 | loose |
| Quality Control | Shooters Inside My Crib | 21 | 41 | 140 | loose |
| Quality Control | Shot Caller | 50 | 51 | 273 | loose |
| Quality Control | Shoulder | 27 | 54 | 189 | loose |
| Quality Control | Show Me | 40 | 34 | 187 | loose |
| Quality Control | Show Sum | 20 | 20 | 212 | loose |
| Quality Control | Sick Wit It | 32 | 23 | 168 | loose |
| Quality Control | Sides | 32 | 44 | 244 | loose |
| Quality Control | Sideways | 27 | 15 | 134 | loose |
| Quality Control | Silk and Cologne | 37 | 31 | 131 | loose |
| Quality Control | Silver Lining | 101 | 93 | 634 | loose |
| Quality Control | Since Day 1 | 39 | 69 | 183 | loose |
| Quality Control | Sink or Swim | 27 | 22 | 89 | loose |
| Quality Control | Sippin | 20 | 24 | 112 | loose |
| Quality Control | Skerr | 27 | 18 | 170 | loose |
| Quality Control | Slam Dunk | 36 | 19 | 131 | loose |
| Quality Control | Slanging | 43 | 35 | 185 | loose |
| Quality Control | Sleazy Flow (Remix) | 41 | 52 | 408 | loose |
| Quality Control | Sleep Walking | 38 | 35 | 189 | loose |
| Quality Control | Slide | 38 | 39 | 197 | loose |
| Quality Control | Slide On Em | 44 | 39 | 227 | loose |
| Quality Control | Slidin | 48 | 77 | 205 | loose |
| Quality Control | Slimy As Me | 28 | 35 | 177 | loose |
| Quality Control | Slippery | 74 | 88 | 350 | loose |
| Quality Control | Slow Mo | 60 | 114 | 335 | loose |
| Quality Control | Small Things | 39 | 32 | 164 | loose |
| Quality Control | Snake Niggas | 52 | 75 | 170 | loose |
| Quality Control | Sneakin N Geekin | 56 | 63 | 310 | loose |
| Quality Control | Snitching | 87 | 68 | 280 | loose |
| Quality Control | Sno Cone | 43 | 60 | 321 | loose |
| Quality Control | Snowman | 38 | 28 | 358 | loose |
| Quality Control | So Many People | 25 | 10 | 86 | loose |
| Quality Control | So Sorry | 52 | 58 | 292 | loose |
| Quality Control | Soakin Wet | 39 | 90 | 114 | loose |
| Quality Control | Social Distancing | 36 | 27 | 213 | loose |
| Quality Control | Solar Freestyle | 44 | 70 | 249 | loose |
| Quality Control | Solid | 33 | 22 | 405 | loose |
| Quality Control | Solitaire | 30 | 19 | 223 | loose |
| Quality Control | Something | 22 | 15 | 67 | loose |
| Quality Control | Something Ether | 43 | 37 | 164 | loose |
| Quality Control | Sorry | 58 | 81 | 375 | loose |
| Quality Control | Sorry Not Sorry | 61 | 68 | 448 | loose |
| Quality Control | Soul Plane | 56 | 111 | 276 | loose |
| Quality Control | South Africa | 45 | 59 | 210 | loose |
| Quality Control | South Beach | 46 | 52 | 93 | loose |
| Quality Control | Southside | 54 | 57 | 163 | loose |
| Quality Control | Space Cadet | 30 | 39 | 122 | loose |
| Quality Control | Spazz | 53 | 71 | 177 | loose |
| Quality Control | Spin Again | 26 | 16 | 67 | loose |
| Quality Control | Splashin | 39 | 36 | 176 | loose |
| Quality Control | Split / Whole Time | 82 | 69 | 319 | loose |
| Quality Control | Spray the Champagne | 34 | 49 | 125 | loose |
| Quality Control | Sprinkle | 19 | 27 | 104 | loose |
| Quality Control | St Tropez | 63 | 79 | 559 | loose |
| Quality Control | Stain | 60 | 101 | 333 | loose |
| Quality Control | Stand On It | 39 | 29 | 313 | loose |
| Quality Control | Star Of The Show | 43 | 48 | 213 | loose |
| Quality Control | Startender | 47 | 41 | 189 | loose |
| Quality Control | Starter Kit | 32 | 35 | 305 | loose |
| Quality Control | Stay Down | 48 | 35 | 247 | loose |
| Quality Control | Stendo | 38 | 41 | 187 | loose |
| Quality Control | Step 1 | 39 | 23 | 358 | loose |
| Quality Control | Stick On Me | 60 | 73 | 232 | loose |
| Quality Control | Stiff Gang | 76 | 68 | 347 | loose |
| Quality Control | Still Hood | 63 | 57 | 325 | loose |
| Quality Control | Still Runnin | 60 | 73 | 426 | loose |
| Quality Control | Stir Fry | 40 | 50 | 279 | loose |
| Quality Control | Stoney | 30 | 29 | 56 | loose |
| Quality Control | Stop Playin | 37 | 25 | 169 | loose |
| Quality Control | Story I Tell | 63 | 84 | 270 | loose |
| Quality Control | Straightenin | 86 | 129 | 360 | loose |
| Quality Control | Street Nigga Sacrifice | 40 | 39 | 249 | loose |
| Quality Control | Street Talk | 29 | 12 | 262 | loose |
| Quality Control | Streets Colder | 30 | 38 | 263 | loose |
| Quality Control | Streets Need Us (Outro) | 73 | 111 | 259 | loose |
| Quality Control | Streets On Lock (Intro) | 4 | 1 | 4 | loose |
| Quality Control | Strike (Holster) | 26 | 33 | 148 | loose |
| Quality Control | Stripper Bowl | 64 | 45 | 223 | loose |
| Quality Control | Struggle | 60 | 53 | 376 | loose |
| Quality Control | Stuff | 50 | 65 | 274 | loose |
| Quality Control | Stunt Double | 24 | 19 | 177 | loose |
| Quality Control | Style Stealer | 27 | 26 | 128 | loose |
| Quality Control | Such Ease | 24 | 20 | 82 | loose |
| Quality Control | Sum 2 Prove | 65 | 66 | 415 | loose |
| Quality Control | Sum More | 51 | 56 | 202 | loose |
| Quality Control | Supastars | 58 | 55 | 240 | loose |
| Quality Control | Superman | 60 | 65 | 533 | loose |
| Quality Control | Surrender | 14 | 16 | 78 | loose |
| Quality Control | Survive Da Motion | 35 | 31 | 120 | loose |
| Quality Control | Swang | 33 | 23 | 206 | loose |
| Quality Control | Sway With Me | 43 | 48 | 95 | loose |
| Quality Control | Sweet Tooth | 39 | 34 | 190 | loose |
| Quality Control | Swerve | 41 | 56 | 126 | loose |
| Quality Control | T-Shirt | 47 | 56 | 248 | loose |
| Quality Control | T.D | 100 | 126 | 539 | loose |
| Quality Control | TALK TO ME NICE | 42 | 49 | 186 | loose |
| Quality Control | TESLA | 33 | 29 | 121 | loose |
| Quality Control | THE zone~ | 26 | 26 | 99 | loose |
| Quality Control | TIC TOC | 35 | 49 | 209 | loose |
| Quality Control | TOP OPTION BOYZ | 47 | 84 | 381 | loose |
| Quality Control | TRAPPER (Remix) | 65 | 96 | 473 | loose |
| Quality Control | TRUST ME | 82 | 84 | 383 | loose |
| Quality Control | Taco Tuesday | 27 | 43 | 96 | loose |
| Quality Control | Take Her | 71 | 62 | 179 | loose |
| Quality Control | Take My Soul | 44 | 64 | 180 | loose |
| Quality Control | Take Yo Man | 48 | 33 | 197 | loose |
| Quality Control | Talk About It | 35 | 37 | 236 | loose |
| Quality Control | Talkin That Shit | 16 | 33 | 102 | loose |
| Quality Control | Talkin’ Bout Nun | 34 | 20 | 231 | loose |
| Quality Control | Taste | 61 | 98 | 294 | loose |
| Quality Control | Tats on My Face | 66 | 144 | 141 | loose |
| Quality Control | Tell Me What You Like | 25 | 6 | 69 | loose |
| Quality Control | Ten Plus Ten | 60 | 73 | 338 | loose |
| Quality Control | Tend to the Money | 41 | 37 | 215 | loose |
| Quality Control | Tequila Me | 20 | 9 | 82 | loose |
| Quality Control | Testament | 61 | 93 | 496 | loose |
| Quality Control | Thank You God (Outro) | 51 | 60 | 188 | loose |
| Quality Control | That Ain’t Me | 37 | 29 | 351 | loose |
| Quality Control | That Bag | 46 | 54 | 174 | loose |
| Quality Control | That’s Facts | 55 | 37 | 465 | loose |
| Quality Control | That’s My Bitch | 28 | 32 | 141 | loose |
| Quality Control | That’s Tuff | 33 | 25 | 92 | loose |
| Quality Control | The Alchemist. | 25 | 17 | 72 | loose |
| Quality Control | The Bigger Picture | 99 | 137 | 549 | loose |
| Quality Control | The Difference | 49 | 48 | 120 | loose |
| Quality Control | The Load | 66 | 90 | 357 | loose |
| Quality Control | The New Kid | 45 | 70 | 360 | loose |
| Quality Control | The Real 1 | 28 | 16 | 187 | loose |
| Quality Control | The Secret Recipe | 62 | 129 | 611 | loose |
| Quality Control | They Can’t FWM | 32 | 28 | 210 | loose |
| Quality Control | They Gave the Wrong Young Nigga Money | 48 | 47 | 178 | loose |
| Quality Control | Thick & Pretty | 75 | 90 | 206 | loose |
| Quality Control | Thinkin Out Loud | 39 | 46 | 152 | loose |
| Quality Control | This That One | 79 | 93 | 499 | loose |
| Quality Control | This That Typa | 40 | 77 | 406 | loose |
| Quality Control | This Week | 56 | 45 | 254 | loose |
| Quality Control | Thousand Times | 51 | 45 | 310 | loose |
| Quality Control | Three Six Talk | 55 | 113 | 334 | loose |
| Quality Control | Throat Baby (Go Baby) [Remix] | 70 | 48 | 360 | loose |
| Quality Control | Through the Fire | 49 | 41 | 157 | loose |
| Quality Control | Throwing Shade | 59 | 113 | 212 | loose |
| Quality Control | Tighten Up | 35 | 29 | 167 | loose |
| Quality Control | Till the Morning | 44 | 33 | 224 | loose |
| Quality Control | Time | 50 | 39 | 327 | loose |
| Quality Control | Time After Time | 33 | 25 | 139 | loose |
| Quality Control | Time Is Money (Remix) | 40 | 23 | 109 | loose |
| Quality Control | Time To Heal | 25 | 32 | 149 | loose |
| Quality Control | Time for Me | 64 | 76 | 303 | loose |
| Quality Control | To The Bone | 73 | 132 | 434 | loose |
| Quality Control | To the Top | 56 | 61 | 199 | loose |
| Quality Control | Tony Starks | 28 | 41 | 193 | loose |
| Quality Control | Too Hotty | 83 | 116 | 324 | loose |
| Quality Control | Too Much | 39 | 37 | 164 | loose |
| Quality Control | Too Much Ice | 43 | 43 | 162 | loose |
| Quality Control | Too Much Jewelry | 45 | 54 | 255 | loose |
| Quality Control | Too Much Shaft | 17 | 13 | 66 | loose |
| Quality Control | Too Playa | 89 | 61 | 413 | loose |
| Quality Control | Took A Risk | 40 | 51 | 275 | loose |
| Quality Control | Tools | 45 | 89 | 264 | loose |
| Quality Control | Tootsies | 35 | 51 | 170 | loose |
| Quality Control | Top Down | 26 | 18 | 90 | loose |
| Quality Control | Top Down on da NAWF | 54 | 43 | 244 | loose |
| Quality Control | Top Notch | 53 | 62 | 288 | loose |
| Quality Control | Top Priority | 51 | 46 | 451 | loose |
| Quality Control | Touchdown | 63 | 47 | 314 | loose |
| Quality Control | Tough | 37 | 20 | 137 | loose |
| Quality Control | Toxic | 22 | 15 | 133 | loose |
| Quality Control | Trance (Walk It Down) | 42 | 35 | 188 | loose |
| Quality Control | Transport Me | 49 | 36 | 132 | loose |
| Quality Control | Transporter | 55 | 86 | 263 | loose |
| Quality Control | Trap | 63 | 58 | 170 | loose |
| Quality Control | Trap 2 Rap (Intro) | 24 | 17 | 165 | loose |
| Quality Control | Trap Dab | 102 | 142 | 410 | loose |
| Quality Control | Trap Dab 2 (Intro) | 101 | 136 | 404 | loose |
| Quality Control | Trap Funk | 51 | 44 | 370 | loose |
| Quality Control | Trap Paris | 48 | 50 | 116 | loose |
| Quality Control | Trap Problems | 40 | 49 | 285 | loose |
| Quality Control | Trap Star | 46 | 62 | 184 | loose |
| Quality Control | Trap Still Jumpin’ | 36 | 22 | 106 | loose |
| Quality Control | Trap Stories | 40 | 19 | 275 | loose |
| Quality Control | Trap-A-Holics | 40 | 17 | 244 | loose |
| Quality Control | Trappa Rappa | 43 | 84 | 301 | loose |
| Quality Control | Trapping Ain’t Dead | 31 | 11 | 231 | loose |
| Quality Control | Trauma Kit | 41 | 69 | 284 | loose |
| Quality Control | Trippin | 73 | 100 | 317 | loose |
| Quality Control | Trouble | 64 | 68 | 335 | loose |
| Quality Control | TruckHead | 57 | 79 | 393 | loose |
| Quality Control | Trust | 37 | 39 | 199 | loose |
| Quality Control | Trust Nobody | 34 | 38 | 162 | loose |
| Quality Control | Trust the Process | 38 | 51 | 314 | loose |
| Quality Control | Try To Love | 31 | 26 | 243 | loose |
| Quality Control | Turn Me Up | 37 | 46 | 272 | loose |
| Quality Control | Turn Yo Clic Up | 46 | 74 | 340 | loose |
| Quality Control | Twerk | 40 | 31 | 259 | loose |
| Quality Control | Twerkulator | 32 | 22 | 115 | loose |
| Quality Control | Twice | 38 | 21 | 79 | loose |
| Quality Control | Two Cups | 57 | 56 | 345 | loose |
| Quality Control | Two Infinity Links | 39 | 41 | 246 | loose |
| Quality Control | U Guessed It | 29 | 10 | 102 | loose |
| Quality Control | U Played | 45 | 60 | 219 | loose |
| Quality Control | U-Digg | 59 | 64 | 764 | loose |
| Quality Control | UP THE SMOKE | 55 | 113 | 247 | loose |
| Quality Control | UP YO STANDARDS | 23 | 20 | 123 | loose |
| Quality Control | UPPING MY RANK | 44 | 75 | 342 | loose |
| Quality Control | Um Yea | 50 | 80 | 324 | loose |
| Quality Control | Uncle Al | 39 | 20 | 121 | loose |
| Quality Control | Undefeated | 38 | 49 | 227 | loose |
| Quality Control | Underdog | 37 | 62 | 224 | loose |
| Quality Control | Underrated | 44 | 65 | 261 | loose |
| Quality Control | Understand Me | 48 | 40 | 126 | loose |
| Quality Control | Unleash The Kraken | 22 | 11 | 79 | loose |
| Quality Control | Unleashed | 37 | 46 | 161 | loose |
| Quality Control | Up | 44 | 49 | 177 | loose |
| Quality Control | Up Next 2 | 79 | 81 | 351 | loose |
| Quality Control | Up Next 3 | 66 | 73 | 387 | loose |
| Quality Control | Up There Music | 27 | 33 | 113 | loose |
| Quality Control | Up the Side | 60 | 85 | 431 | loose |
| Quality Control | Us vs. Them | 45 | 88 | 262 | loose |
| Quality Control | VICIOUS CYCLE | 37 | 31 | 336 | loose |
| Quality Control | VVS | 23 | 18 | 110 | loose |
| Quality Control | Vacation | 31 | 79 | 226 | loose |
| Quality Control | Vaccine | 69 | 119 | 303 | loose |
| Quality Control | Versace (Remix) | 90 | 79 | 298 | loose |
| Quality Control | Violation | 31 | 40 | 352 | loose |
| Quality Control | Violation Freestyle | 39 | 34 | 168 | loose |
| Quality Control | Violence | 17 | 7 | 69 | loose |
| Quality Control | Virgil | 36 | 34 | 194 | loose |
| Quality Control | Virgo World | 26 | 26 | 136 | loose |
| Quality Control | Vision Clear | 48 | 36 | 294 | loose |
| Quality Control | Voice of the Heroes | 52 | 66 | 351 | loose |
| Quality Control | WE SAW THE SUN! | 22 | 22 | 68 | loose |
| Quality Control | WEIGH MY OPTIONS | 35 | 48 | 293 | loose |
| Quality Control | WE’RE BACK | 85 | 109 | 302 | loose |
| Quality Control | WHERE YO DADDY | 25 | 33 | 162 | loose |
| Quality Control | WHO? WHAT! | 56 | 89 | 201 | loose |
| Quality Control | WHOLE lotta GUAP | 50 | 46 | 141 | loose |
| Quality Control | WOA | 62 | 160 | 281 | loose |
| Quality Control | WORKIN ME | 30 | 33 | 91 | loose |
| Quality Control | WTF Wrong | 100 | 163 | 559 | loose |
| Quality Control | WTF! | 47 | 80 | 382 | loose |
| Quality Control | WTFFF | 85 | 79 | 287 | loose |
| Quality Control | WYT | 50 | 42 | 239 | loose |
| Quality Control | Wafi | 37 | 27 | 220 | loose |
| Quality Control | Walk It Talk It | 64 | 83 | 260 | loose |
| Quality Control | Wall To Wall | 43 | 25 | 225 | loose |
| Quality Control | Wallah | 30 | 28 | 207 | loose |
| Quality Control | Wanna Be Me | 50 | 62 | 237 | loose |
| Quality Control | Wanna Be Us | 40 | 29 | 98 | loose |
| Quality Control | Want More | 53 | 42 | 229 | loose |
| Quality Control | Water | 42 | 65 | 129 | loose |
| Quality Control | Water Bitch | 54 | 59 | 244 | loose |
| Quality Control | Water Whip (Solid Foundation) | 38 | 16 | 249 | loose |
| Quality Control | Waterfall Flow | 44 | 52 | 395 | loose |
| Quality Control | We Did It | 33 | 17 | 45 | loose |
| Quality Control | We Getting Money | 39 | 34 | 244 | loose |
| Quality Control | We Outta Here! | 69 | 78 | 199 | loose |
| Quality Control | We Paid | 57 | 58 | 245 | loose |
| Quality Control | We Ready (Remix) | 40 | 25 | 193 | loose |
| Quality Control | We Should | 38 | 57 | 303 | loose |
| Quality Control | We Win | 52 | 72 | 264 | loose |
| Quality Control | We the Ones | 39 | 70 | 195 | loose |
| Quality Control | Weather the Storm | 49 | 70 | 312 | loose |
| Quality Control | West Coast Shit | 45 | 74 | 260 | loose |
| Quality Control | Westside | 46 | 71 | 221 | loose |
| Quality Control | Wet Wet | 51 | 38 | 217 | loose |
| Quality Control | What It Do | 66 | 71 | 172 | loose |
| Quality Control | What It Is | 43 | 86 | 113 | loose |
| Quality Control | What She Like | 71 | 152 | 264 | loose |
| Quality Control | What We Doin’ | 35 | 20 | 146 | loose |
| Quality Control | What You Been Doin | 39 | 52 | 102 | loose |
| Quality Control | What You Doin | 34 | 30 | 130 | loose |
| Quality Control | What You See | 41 | 35 | 251 | loose |
| Quality Control | What You Talmbout | 48 | 41 | 196 | loose |
| Quality Control | What Y’all Doin | 59 | 60 | 323 | loose |
| Quality Control | What a Feeling | 35 | 35 | 159 | loose |
| Quality Control | What the Price | 39 | 27 | 144 | loose |
| Quality Control | Whatchu Gon Do | 39 | 20 | 146 | loose |
| Quality Control | Whats Next | 29 | 60 | 235 | loose |
| Quality Control | When I Shoot | 43 | 65 | 168 | loose |
| Quality Control | When I’m Buyin Em | 49 | 46 | 252 | loose |
| Quality Control | When We Ride | 27 | 15 | 178 | loose |
| Quality Control | When You See It | 77 | 97 | 350 | loose |
| Quality Control | Where Can I Start | 40 | 79 | 160 | loose |
| Quality Control | Where The Cash At? | 41 | 38 | 164 | loose |
| Quality Control | Where U From | 54 | 53 | 126 | loose |
| Quality Control | Where Were You | 64 | 89 | 298 | loose |
| Quality Control | Where the Bag At | 43 | 42 | 204 | loose |
| Quality Control | Whew’ Chile | 37 | 41 | 189 | loose |
| Quality Control | Whistle | 29 | 68 | 240 | loose |
| Quality Control | White Sand | 64 | 72 | 211 | loose |
| Quality Control | Who Came To Party | 69 | 69 | 413 | loose |
| Quality Control | Who Got The Clout | 42 | 27 | 155 | loose |
| Quality Control | Who I Want | 52 | 64 | 295 | loose |
| Quality Control | Who Want the Smoke? | 60 | 71 | 257 | loose |
| Quality Control | Who Wit Me | 33 | 39 | 233 | loose |
| Quality Control | Whole Lotta Ice | 65 | 66 | 297 | loose |
| Quality Control | Whoopty Woop | 50 | 77 | 470 | loose |
| Quality Control | Why Not | 82 | 116 | 329 | loose |
| Quality Control | Why Would U Not | 55 | 25 | 402 | loose |
| Quality Control | Why You Mad | 57 | 44 | 95 | loose |
| Quality Control | Why? (Interlude) | 11 | 5 | 10 | loose |
| Quality Control | Wide Open | 32 | 10 | 107 | loose |
| Quality Control | Wiggle It | 30 | 27 | 208 | loose |
| Quality Control | Wigs | 44 | 61 | 282 | loose |
| Quality Control | Wild Wild West | 64 | 111 | 335 | loose |
| Quality Control | Winnin | 36 | 39 | 117 | loose |
| Quality Control | Wins & Losses | 30 | 13 | 121 | loose |
| Quality Control | Wish | 54 | 31 | 249 | loose |
| Quality Control | Wish Me Well | 29 | 32 | 117 | loose |
| Quality Control | Wish You Would | 37 | 12 | 121 | loose |
| Quality Control | Wishy Washy | 63 | 72 | 379 | loose |
| Quality Control | With You | 30 | 31 | 252 | loose |
| Quality Control | Without You | 34 | 28 | 106 | loose |
| Quality Control | Woah | 58 | 59 | 286 | loose |
| Quality Control | Wock in Stock | 28 | 32 | 192 | loose |
| Quality Control | Woke Up | 39 | 49 | 159 | loose |
| Quality Control | Won’t Diss You | 55 | 80 | 127 | loose |
| Quality Control | Woo | 31 | 42 | 125 | loose |
| Quality Control | Wop Longway Takeoff | 34 | 53 | 191 | loose |
| Quality Control | Word On The Streets | 50 | 41 | 223 | loose |
| Quality Control | Word on the Street | 48 | 69 | 325 | loose |
| Quality Control | Work For It | 41 | 24 | 157 | loose |
| Quality Control | Work Hard | 46 | 44 | 365 | loose |
| Quality Control | Working With | 26 | 17 | 156 | loose |
| Quality Control | World Is Yours | 41 | 66 | 191 | loose |
| Quality Control | World Is Yours 2 (Intro) | 47 | 85 | 80 | loose |
| Quality Control | Worth It | 31 | 15 | 97 | loose |
| Quality Control | Wrist Game | 48 | 47 | 499 | loose |
| Quality Control | Wrist Gone Crazy | 32 | 24 | 199 | loose |
| Quality Control | Wrist Thunderstorm | 61 | 103 | 197 | loose |
| Quality Control | Wrong Thing | 33 | 28 | 109 | loose |
| Quality Control | Wrong Time | 32 | 43 | 242 | loose |
| Quality Control | X Men | 56 | 63 | 169 | loose |
| Quality Control | YAE ENERGY | 36 | 18 | 208 | loose |
| Quality Control | YES | 50 | 31 | 225 | loose |
| Quality Control | YNGTC | 64 | 39 | 315 | loose |
| Quality Control | YRH | 49 | 38 | 192 | loose |
| Quality Control | YRN | 41 | 35 | 266 | loose |
| Quality Control | YRN 2 Intro | 118 | 158 | 581 | loose |
| Quality Control | Yacht Club | 45 | 66 | 276 | loose |
| Quality Control | Yeah Yeah | 45 | 44 | 107 | loose |
| Quality Control | Yeh | 31 | 26 | 204 | loose |
| Quality Control | Yes Indeed | 40 | 64 | 184 | loose |
| Quality Control | You A Foo | 46 | 44 | 184 | loose |
| Quality Control | You Bad | 36 | 19 | 161 | loose |
| Quality Control | You Said | 81 | 71 | 330 | loose |
| Quality Control | You Stay | 67 | 68 | 329 | loose |
| Quality Control | You Wanna See | 101 | 170 | 373 | loose |
| Quality Control | Young Rich Niggas (No Label 2) | 50 | 53 | 166 | loose |
| Quality Control | Young Thug | 16 | 9 | 74 | loose |
| Quality Control | Your Peace | 42 | 40 | 140 | loose |
| Quality Control | Zion | 55 | 57 | 227 | loose |
| Quality Control | can’t leave without it | 75 | 60 | 394 | loose |
| Quality Control | drive ME crazy! | 31 | 17 | 271 | loose |
| Quality Control | fast (Remix) | 46 | 51 | 247 | loose |
| Quality Control | iSpy | 60 | 64 | 358 | loose |
| Quality Control | love me forever | 13 | 9 | 44 | loose |
| Quality Control | pRETTy | 23 | 13 | 109 | loose |
| Quality Control | paint THE sky | 17 | 10 | 44 | loose |
| Quality Control | pick up the phone | 64 | 92 | 177 | loose |
| Quality Control | running out of time | 20 | 6 | 56 | loose |
| Quality Control | sAy sOMETHINg | 32 | 16 | 133 | loose |
| Quality Control | sHouLd i B? | 23 | 11 | 91 | loose |
| Quality Control | she ready | 37 | 27 | 202 | loose |
| Quality Control | the BLACK seminole. | 17 | 9 | 71 | loose |
| Quality Control | the ride- | 20 | 33 | 91 | loose |
