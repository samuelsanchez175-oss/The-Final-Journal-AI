# Lil Yachty rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Yachty
- Songs: 1352
- Bars kept (Lil Yachty lyric lines): 51844
- Section headers dropped, not counted as bars: 3
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 51
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 148
- Canonical name: Lil Yachty.
- Credit strings: Lil Yachty.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 302351
- REPEAT pairs, recorded separately: 36951
- END rhymes: 54743
- INNER rhymes: 247608

By match:

- PERFECT: 27110 (END 9542, INNER 17568)
- SLANT: 132879 (END 22617, INNER 110262)
- ASSONANCE: 138155 (END 20688, INNER 117467)
- MULTI: 4207 (END 1896, INNER 2311)

By confidence:

- HIGH: 28836
- MED: 253671
- LOW: 19844

## Core

- Core Y: 296941
- Core N among rhyme pairs: 5410

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 143033 (47.3%)
- vowel: 138155 (45.7%)
- spelling: 16956 (5.6%)
- multi: 4207 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 15 songs
- ABCB: 2 songs
- loose: 1335 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 25481 pairs (END 3060, INNER 22421). Words: bitch, shit, bitches, think, lil, wrist, still, big.
2. `vow:OW` — 18791 pairs (END 2809, INNER 15982). Words: don't, know, no, go, hoes, told, boat, ho.
3. `vow:EH` — 16158 pairs (END 2012, INNER 14146). Words: get, when, never, gettin, friends, left, tell, next.
4. `vow:AE` — 12852 pairs (END 2325, INNER 10527). Words: can't, back, had, have, can, racks, ass, bad.
5. `vow:EY` — 12671 pairs (END 2179, INNER 10492). Words: ain't, say, way, make, baby, play, take, day.
6. `vow:AA` — 11252 pairs (END 1210, INNER 10042). Words: got, want, not, talkin, wanna, hard, poppin, problem.
7. `vow:AY` — 11191 pairs (END 1625, INNER 9566). Words: like, diamonds, why, by, high, time, die, try.
8. `vow:AH` — 10128 pairs (END 1545, INNER 8583). Words: fuck, some, fuckin, love, hundred, what, one, money.
9. `vow:IY` — 10102 pairs (END 1745, INNER 8357). Words: see, these, even, need, keep, three, real, free.
10. `slant:IH:sib-stop` — 7211 pairs (END 1116, INNER 6095). Words: bitch, shit, nigga, niggas, rich, hit, dick, big.
11. `slant:IH:stop` — 7156 pairs (END 921, INNER 6235). Words: nigga, shit, big, hit, dick, stick, whip, wrist.
12. `slant:AA:stop` — 5903 pairs (END 694, INNER 5209). Words: got, not, want, gotta, top, pop, stop, god.
13. `slant:AY:stop` — 3930 pairs (END 394, INNER 3536). Words: like, right, might, ride, white, night, side, inside.
14. `slant:EH:stop` — 3716 pairs (END 541, INNER 3175). Words: get, said, better, let, head, neck, check, twenty.
15. `slant:AE:stop` — 3639 pairs (END 866, INNER 2773). Words: back, had, can't, bag, act, bad, rap, trap.
16. `slant:AH:nas-stop` — 3392 pairs (END 238, INNER 3154). Words: fuck, what, some, money, one, come, run, young.
17. `slant:IH:liq-stop` — 3311 pairs (END 103, INNER 3208). Words: lil, shit, still, really, big, hit, dick, 'til.
18. `vow:UW` — 3145 pairs (END 738, INNER 2407). Words: new, two, who, used, through, move, coupe, shoot.
19. `cmu:OW` — 3130 pairs (END 612, INNER 2518). Words: know, no, go, ho, show, bro, hoe, low.
20. `slant:IH:liq-sib` — 2748 pairs (END 138, INNER 2610). Words: bitch, lil, still, really, rich, 'til, will, switch.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 4169 pair sides, mostly spelling via spelling phonetic key, often with niggas (1025)
- niggas — 1893 pair sides, mostly spelling via spelling phonetic key, often with nigga (1025)
- ima — 1374 pair sides, mostly spelling via spelling phonetic key, often with bitch (284)
- gon — 1139 pair sides, mostly spelling via spelling phonetic key, often with dont (257)
- tryna — 758 pair sides, mostly spelling via spelling phonetic key, often with these (122)
- shawty — 364 pair sides, mostly vowel via spelling phonetic key, often with all (42)
- yachty — 302 pair sides, mostly vowel via spelling phonetic key, often with baby (21)
- finna — 239 pair sides, mostly vowel via spelling phonetic key, often with nigga (78)
- guap — 191 pair sides, mostly spelling via spelling phonetic key, often with fuck (35)
- swag — 152 pair sides, mostly spelling via spelling phonetic key, often with bag (19)
- bros — 150 pair sides, mostly spelling via spelling phonetic key, often with hoes (17)
- geeked — 135 pair sides, mostly spelling via spelling phonetic key, often with need (13)
- wock — 134 pair sides, mostly spelling via spelling phonetic key, often with dont (11)
- tris — 120 pair sides, mostly spelling via spelling phonetic key, often with bitch (16)
- homie — 103 pair sides, mostly spelling via spelling phonetic key, often with over (11)
- imma — 102 pair sides, mostly vowel via spelling phonetic key, often with niggas (33)
- prolly — 91 pair sides, mostly vowel via spelling phonetic key, often with money (6)
- lyin — 91 pair sides, mostly spelling via spelling phonetic key, often with these (14)
- thot — 90 pair sides, mostly spelling via spelling phonetic key, often with got (12)
- slatt — 88 pair sides, mostly spelling via spelling phonetic key, often with back (14)
- bling — 87 pair sides, mostly spelling via spelling phonetic key, often with shit (6)
- dawg — 80 pair sides, mostly spelling via spelling phonetic key, often with all (15)
- opps — 79 pair sides, mostly vowel via spelling phonetic key, often with dont (24)
- xans — 76 pair sides, mostly spelling via spelling phonetic key, often with man (7)
- birkin — 76 pair sides, mostly vowel via spelling phonetic key, often with bitch (14)
- lik — 75 pair sides, mostly spelling via spelling phonetic key, often with bitch (16)
- geekin — 69 pair sides, mostly spelling via spelling phonetic key, often with geek (15)
- titty — 68 pair sides, mostly spelling via spelling phonetic key, often with city (10)
- wraith — 66 pair sides, mostly spelling via spelling phonetic key, often with aint (17)
- crippin — 64 pair sides, mostly vowel via spelling phonetic key, often with trippin (7)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Yachty | **HEAD N HEADACHES** | 37 | 24 | 153 | loose |
| Lil Yachty | 1 Thing | 28 | 38 | 254 | loose |
| Lil Yachty | 1-800-KICKADOE (Remix) | 37 | 64 | 183 | loose |
| Lil Yachty | 10 KT EARRINGS FREESTYLE | 39 | 58 | 164 | loose |
| Lil Yachty | 100 Band Shawty (Remix) | 43 | 42 | 250 | loose |
| Lil Yachty | 100 Round | 40 | 52 | 120 | loose |
| Lil Yachty | 1500 | 39 | 25 | 116 | loose |
| Lil Yachty | 16 YEAR OLD DRANK | 77 | 93 | 431 | loose |
| Lil Yachty | 1Night | 19 | 37 | 57 | AAAA |
| Lil Yachty | 1v1 | 63 | 94 | 531 | loose |
| Lil Yachty | 2 ELONS | 35 | 42 | 229 | loose |
| Lil Yachty | 2 HANDS 2 EYES 10 WHIPS/RENT DUE | 84 | 78 | 570 | loose |
| Lil Yachty | 2 STEP (DOUBLE CUP)* | 55 | 58 | 176 | loose |
| Lil Yachty | 2 Vaults | 48 | 59 | 241 | loose |
| Lil Yachty | 2020 Freestyle* | 20 | 6 | 79 | loose |
| Lil Yachty | 2021 Thoughts | 40 | 67 | 408 | loose |
| Lil Yachty | 22 | 46 | 78 | 137 | loose |
| Lil Yachty | 223 (Remix) | 51 | 76 | 230 | loose |
| Lil Yachty | 23 | 52 | 67 | 153 | loose |
| Lil Yachty | 2AM | 28 | 33 | 125 | loose |
| Lil Yachty | 2MS (Remix) | 7 | 6 | 15 | loose |
| Lil Yachty | 3 SYRUPS | 73 | 90 | 215 | loose |
| Lil Yachty | 30 | 36 | 34 | 133 | loose |
| Lil Yachty | 33 Glizzy | 39 | 48 | 245 | loose |
| Lil Yachty | 36 | 19 | 17 | 44 | loose |
| Lil Yachty | 3AM Freestyle* | 4 | 1 | 23 | loose |
| Lil Yachty | 4 AND A 5 | 24 | 13 | 66 | loose |
| Lil Yachty | 40/40 | 16 | 26 | 117 | loose |
| Lil Yachty | 4Real | 45 | 57 | 80 | loose |
| Lil Yachty | 50 Strong | 41 | 15 | 115 | loose |
| Lil Yachty | 59 Simpsons | 55 | 39 | 271 | loose |
| Lil Yachty | 6 AM Freestyle | 40 | 38 | 188 | loose |
| Lil Yachty | 66 | 26 | 20 | 106 | loose |
| Lil Yachty | 6GS | 49 | 55 | 289 | loose |
| Lil Yachty | 75 Second Interlude* | 20 | 16 | 121 | loose |
| Lil Yachty | 90's Babies | 38 | 32 | 135 | loose |
| Lil Yachty | 90's Baby | 67 | 81 | 260 | loose |
| Lil Yachty | 945 (GAS GAS) | 6 | 2 | 28 | loose |
| Lil Yachty | :(failure(: | 16 | 1 | 136 | loose |
| Lil Yachty | A Cold Sunday | 33 | 19 | 234 | loose |
| Lil Yachty | A Little | 24 | 33 | 126 | loose |
| Lil Yachty | A Safe Place Podcast Intro/Outro Ep. w/Lil Baby | 6 | 5 | 9 | loose |
| Lil Yachty | A&M | 41 | 49 | 160 | loose |
| Lil Yachty | A-Team (You Ain’t Safe) | 42 | 55 | 277 | loose |
| Lil Yachty | AINT IT | 28 | 25 | 139 | loose |
| Lil Yachty | ALL MY LIFE IM GEEKED UP | 35 | 45 | 171 | loose |
| Lil Yachty | ALL THE SAME | 53 | 30 | 228 | loose |
| Lil Yachty | ALL U NEED TO KNOW | 18 | 24 | 42 | loose |
| Lil Yachty | ALONE | 13 | 6 | 51 | loose |
| Lil Yachty | AM Floater | 20 | 12 | 86 | loose |
| Lil Yachty | AMBER ROSE | 54 | 64 | 299 | loose |
| Lil Yachty | AMP FRESHMAN CYPHER 2023 | 200 | 156 | 1251 | loose |
| Lil Yachty | ANIMOSITY | 38 | 37 | 237 | loose |
| Lil Yachty | Accomplishments | 60 | 59 | 287 | loose |
| Lil Yachty | Act Up | 46 | 53 | 282 | loose |
| Lil Yachty | Adore Me | 52 | 53 | 149 | loose |
| Lil Yachty | Africa | 35 | 28 | 127 | loose |
| Lil Yachty | After the Afterparty | 35 | 23 | 148 | loose |
| Lil Yachty | Afterparty | 51 | 69 | 253 | loose |
| Lil Yachty | Ain’t Fair | 55 | 57 | 142 | loose |
| Lil Yachty | Ain’t My Fault (Remix) | 50 | 20 | 155 | loose |
| Lil Yachty | Airport Security | 34 | 33 | 186 | loose |
| Lil Yachty | All Around Me | 43 | 28 | 177 | loose |
| Lil Yachty | All Around The World | 32 | 49 | 316 | loose |
| Lil Yachty | All Day | 41 | 43 | 108 | loose |
| Lil Yachty | All For You | 13 | 11 | 26 | loose |
| Lil Yachty | All Girls Are the Same (Remix) | 44 | 52 | 192 | loose |
| Lil Yachty | All I Do Is Syrup Sip | 42 | 16 | 99 | loose |
| Lil Yachty | All In | 94 | 117 | 373 | loose |
| Lil Yachty | All Stars Freestyle | 59 | 66 | 345 | loose |
| Lil Yachty | All The Parties | 61 | 72 | 267 | loose |
| Lil Yachty | All Times | 8 | 5 | 34 | loose |
| Lil Yachty | All You Had To Say | 36 | 29 | 111 | loose |
| Lil Yachty | Alot On My Mind, I Been Thinking | 44 | 41 | 84 | loose |
| Lil Yachty | Always Been | 35 | 62 | 94 | loose |
| Lil Yachty | Amazin | 76 | 115 | 320 | loose |
| Lil Yachty | Anarchy | 41 | 59 | 133 | loose |
| Lil Yachty | Another Late Night | 42 | 24 | 291 | loose |
| Lil Yachty | Armageddon | 20 | 37 | 105 | loose |
| Lil Yachty | Art Show | 32 | 23 | 93 | loose |
| Lil Yachty | Asshole | 33 | 17 | 128 | loose |
| Lil Yachty | Atlanta House Freestyle | 94 | 131 | 533 | loose |
| Lil Yachty | Attached | 34 | 72 | 154 | loose |
| Lil Yachty | Away From Home | 77 | 164 | 471 | loose |
| Lil Yachty | Awful Lot Of | 71 | 88 | 554 | loose |
| Lil Yachty | Aww Yeah | 34 | 20 | 173 | loose |
| Lil Yachty | Ay3 | 40 | 48 | 141 | loose |
| Lil Yachty | B4 DA BOAT | 63 | 71 | 263 | loose |
| Lil Yachty | B4 DA BOAT PT. 2 | 74 | 61 | 398 | loose |
| Lil Yachty | BABY DADDY | 51 | 65 | 205 | loose |
| Lil Yachty | BANG x3 | 29 | 21 | 143 | loose |
| Lil Yachty | BANK TELLER | 37 | 46 | 274 | loose |
| Lil Yachty | BAR FOR BAR | 55 | 54 | 554 | loose |
| Lil Yachty | BEST MAN | 27 | 26 | 250 | loose |
| Lil Yachty | BIG CHIP | 33 | 26 | 145 | loose |
| Lil Yachty | BIGGAVEL | 53 | 87 | 303 | loose |
| Lil Yachty | BIGGEST ALLEY OOP | 40 | 60 | 220 | loose |
| Lil Yachty | BLUE SKY | 23 | 15 | 117 | loose |
| Lil Yachty | BOOM! | 60 | 92 | 257 | loose |
| Lil Yachty | BREAK IT DOWN | 33 | 25 | 106 | loose |
| Lil Yachty | BREAK THE BANK | 68 | 123 | 395 | loose |
| Lil Yachty | BUST A BIRD | 24 | 18 | 152 | loose |
| Lil Yachty | BUZZIN’ | 26 | 26 | 133 | loose |
| Lil Yachty | Bachelor | 50 | 37 | 154 | loose |
| Lil Yachty | Back | 37 | 57 | 183 | loose |
| Lil Yachty | Back & Forth (Stumblin’) | 36 | 75 | 154 | loose |
| Lil Yachty | Back Breaker (Demo) | 15 | 16 | 36 | loose |
| Lil Yachty | Back Door | 22 | 10 | 80 | loose |
| Lil Yachty | Back In This Shit | 46 | 43 | 393 | loose |
| Lil Yachty | Back That Shit Up | 26 | 32 | 61 | loose |
| Lil Yachty | BackOutsideBoyz | 32 | 55 | 174 | loose |
| Lil Yachty | Backwhen | 39 | 19 | 125 | loose |
| Lil Yachty | Bad Boy | 39 | 37 | 122 | loose |
| Lil Yachty | Bad Cameo | 10 | 3 | 22 | loose |
| Lil Yachty | Bae Bae | 39 | 23 | 199 | loose |
| Lil Yachty | Bagg | 81 | 97 | 209 | loose |
| Lil Yachty | Bahamas | 95 | 75 | 382 | loose |
| Lil Yachty | Bali | 33 | 42 | 189 | loose |
| Lil Yachty | Ball on You | 29 | 34 | 103 | loose |
| Lil Yachty | Baller | 47 | 47 | 351 | loose |
| Lil Yachty | Ballin Like a Piston | 50 | 69 | 196 | loose |
| Lil Yachty | Ballin’ Like a Piston 3 | 44 | 32 | 172 | loose |
| Lil Yachty | Balmain Jeans | 26 | 20 | 64 | loose |
| Lil Yachty | Bands | 11 | 9 | 62 | loose |
| Lil Yachty | Bang on a Pussy* | 19 | 12 | 95 | loose |
| Lil Yachty | Bankrupt (Remix) | 57 | 54 | 334 | loose |
| Lil Yachty | Bar for Bar Pt. 2 | 56 | 53 | 394 | loose |
| Lil Yachty | Barneys | 32 | 38 | 255 | loose |
| Lil Yachty | Batman & Robbin | 35 | 24 | 115 | loose |
| Lil Yachty | Battle of the Bands (I’m Back) | 26 | 21 | 111 | loose |
| Lil Yachty | Be Happy Good Vibes | 13 | 4 | 38 | loose |
| Lil Yachty | Beach Front | 15 | 2 | 38 | loose |
| Lil Yachty | Beats 1 Freestyle | 38 | 31 | 229 | loose |
| Lil Yachty | Beautiful Day | 58 | 55 | 151 | loose |
| Lil Yachty | Beautiful Timing | 26 | 50 | 208 | loose |
| Lil Yachty | Been Dat | 33 | 13 | 62 | loose |
| Lil Yachty | Been Thru a Lot | 74 | 80 | 154 | loose |
| Lil Yachty | Believe | 65 | 71 | 123 | loose |
| Lil Yachty | Believing | 24 | 18 | 51 | loose |
| Lil Yachty | Bentley Coupe | 65 | 55 | 293 | loose |
| Lil Yachty | Best Life | 24 | 12 | 78 | loose |
| Lil Yachty | Bestfriend | 35 | 25 | 176 | loose |
| Lil Yachty | Better | 33 | 29 | 107 | loose |
| Lil Yachty | Better Than Before | 28 | 26 | 105 | loose |
| Lil Yachty | Big Body | 61 | 47 | 225 | loose |
| Lil Yachty | Big Scientist | 23 | 27 | 153 | loose |
| Lil Yachty | Big Shit | 17 | 16 | 123 | loose |
| Lil Yachty | Big Spender | 68 | 99 | 285 | loose |
| Lil Yachty | Bird Trap | 15 | 8 | 67 | loose |
| Lil Yachty | Bitch I’m Awesome | 31 | 28 | 159 | loose |
| Lil Yachty | Bitches on Bitches | 36 | 40 | 92 | loose |
| Lil Yachty | Bitcoin | 27 | 26 | 192 | loose |
| Lil Yachty | Bitter | 22 | 29 | 207 | loose |
| Lil Yachty | Bitter Sweet | 15 | 10 | 113 | loose |
| Lil Yachty | Black Jesus | 60 | 53 | 286 | loose |
| Lil Yachty | Blame It On Your Love (Demo) | 30 | 16 | 76 | loose |
| Lil Yachty | Blessed* | 21 | 28 | 105 | loose |
| Lil Yachty | Blind | 30 | 30 | 161 | loose |
| Lil Yachty | Blind Em | 45 | 80 | 348 | loose |
| Lil Yachty | Blood Brothers | 56 | 90 | 112 | loose |
| Lil Yachty | Blood In My Eyes | 18 | 12 | 53 | loose |
| Lil Yachty | Blowing Up | 23 | 8 | 64 | loose |
| Lil Yachty | Blue Hundreds | 26 | 21 | 94 | loose |
| Lil Yachty | Boat 4 Vegas | 70 | 106 | 366 | loose |
| Lil Yachty | Boat Feb 5th 6* | 13 | 18 | 49 | loose |
| Lil Yachty | Boat Interlude | 40 | 69 | 313 | loose |
| Lil Yachty | Boat Skirrt | 22 | 12 | 167 | loose |
| Lil Yachty | Boat Time | 35 | 11 | 174 | loose |
| Lil Yachty | Bobble Head | 36 | 34 | 168 | loose |
| Lil Yachty | BodyRock | 24 | 13 | 55 | loose |
| Lil Yachty | Boogeyman Boat | 41 | 59 | 137 | loose |
| Lil Yachty | Boomerang | 31 | 38 | 131 | loose |
| Lil Yachty | Boost Mobile Flip Phone | 20 | 26 | 39 | loose |
| Lil Yachty | Bootsy Collins | 46 | 51 | 151 | loose |
| Lil Yachty | Born From Pain | 38 | 35 | 162 | loose |
| Lil Yachty | Break Down | 56 | 65 | 205 | loose |
| Lil Yachty | Breathe Deeper (Lil Yachty Remix) | 70 | 73 | 288 | loose |
| Lil Yachty | Bring Dat Bag Out | 22 | 30 | 123 | loose |
| Lil Yachty | Bring It Back | 37 | 18 | 75 | loose |
| Lil Yachty | Broccoli | 57 | 41 | 322 | loose |
| Lil Yachty | Buckle Down | 37 | 19 | 138 | loose |
| Lil Yachty | Bummy | 18 | 23 | 51 | loose |
| Lil Yachty | Bury Me (Remix) | 51 | 63 | 284 | loose |
| Lil Yachty | Bussin Baby | 28 | 39 | 135 | loose |
| Lil Yachty | Bust Down | 43 | 41 | 124 | loose |
| Lil Yachty | Buzz of 16 (Buzzin Remix) | 32 | 30 | 84 | loose |
| Lil Yachty | Bye Felicia | 36 | 54 | 227 | loose |
| Lil Yachty | ByeGonez | 61 | 88 | 291 | loose |
| Lil Yachty | CALL MY PHONE | 20 | 17 | 107 | loose |
| Lil Yachty | CAUGHT FIRE | 44 | 92 | 211 | loose |
| Lil Yachty | CHOP IN THE TRUNK | 28 | 21 | 153 | loose |
| Lil Yachty | COKE WHITE | 45 | 34 | 118 | loose |
| Lil Yachty | COPY, OK COOL | 78 | 84 | 337 | loose |
| Lil Yachty | CORTEX | 47 | 50 | 263 | loose |
| Lil Yachty | COUNT ME IN | 45 | 31 | 170 | loose |
| Lil Yachty | COUNTRY GRAMMAR | 38 | 41 | 288 | loose |
| Lil Yachty | CRETE CYPHER INTRO | 63 | 93 | 518 | loose |
| Lil Yachty | Calling For You | 82 | 71 | 335 | loose |
| Lil Yachty | Calm Down Boat | 61 | 61 | 397 | loose |
| Lil Yachty | Cam Reddish | 24 | 33 | 76 | loose |
| Lil Yachty | Came Up* | 6 | 3 | 28 | loose |
| Lil Yachty | Can We | 19 | 18 | 62 | loose |
| Lil Yachty | Can’t Be Crete Boy | 67 | 97 | 561 | loose |
| Lil Yachty | Can’t Go | 19 | 20 | 102 | loose |
| Lil Yachty | Can’t Hold Me Down | 55 | 87 | 216 | loose |
| Lil Yachty | Can’t Stop, Won’t Stop | 47 | 31 | 124 | loose |
| Lil Yachty | Casper | 51 | 72 | 161 | loose |
| Lil Yachty | Cat Piss | 49 | 49 | 208 | loose |
| Lil Yachty | Catch Up (Osama) | 41 | 45 | 167 | loose |
| Lil Yachty | Certified | 20 | 22 | 70 | loose |
| Lil Yachty | Chain a Pound* | 33 | 66 | 135 | loose |
| Lil Yachty | Chained to the Rhythm (BoatMix) | 41 | 11 | 96 | loose |
| Lil Yachty | Championship Rings | 21 | 31 | 44 | loose |
| Lil Yachty | Chanel Drip | 41 | 48 | 151 | loose |
| Lil Yachty | Changed | 44 | 82 | 75 | AAAA |
| Lil Yachty | Charlie | 38 | 16 | 183 | loose |
| Lil Yachty | Charmin’ | 31 | 38 | 79 | loose |
| Lil Yachty | Check Up | 30 | 12 | 109 | loose |
| Lil Yachty | Child Boy (Freestyle) | 33 | 32 | 194 | loose |
| Lil Yachty | Chill Baby | 20 | 7 | 91 | loose |
| Lil Yachty | ChoppaSickoIgloo | 27 | 21 | 113 | loose |
| Lil Yachty | Christmas Lights (Remix) | 55 | 35 | 130 | loose |
| Lil Yachty | Chrome Pliers | 49 | 43 | 282 | loose |
| Lil Yachty | Circo Loco | 54 | 54 | 272 | loose |
| Lil Yachty | City Girls | 42 | 36 | 223 | loose |
| Lil Yachty | Clear The Room | 17 | 8 | 58 | loose |
| Lil Yachty | Cocky | 29 | 33 | 126 | loose |
| Lil Yachty | Codeine Cowboy | 15 | 29 | 24 | loose |
| Lil Yachty | Coffee Cup | 41 | 78 | 222 | loose |
| Lil Yachty | Coffin | 42 | 26 | 160 | loose |
| Lil Yachty | Coke Zero | 30 | 30 | 107 | loose |
| Lil Yachty | Cold Like a Sprite Soda | 4 | 3 | 1 | loose |
| Lil Yachty | Coldhearted | 49 | 60 | 282 | loose |
| Lil Yachty | Cole Bennett* | 9 | 5 | 31 | loose |
| Lil Yachty | Colorful Shit | 42 | 67 | 243 | loose |
| Lil Yachty | Come On Now | 32 | 32 | 227 | loose |
| Lil Yachty | Come Up | 49 | 80 | 165 | loose |
| Lil Yachty | Come to Coulda Been | 23 | 19 | 68 | loose |
| Lil Yachty | Computer Love | 18 | 15 | 80 | loose |
| Lil Yachty | Concrete Boys | 30 | 28 | 121 | loose |
| Lil Yachty | Concrete Boys Freestyle | Media Day Freestyle #06 | 214 | 239 | 1480 | loose |
| Lil Yachty | Concrete Goonies | 39 | 38 | 220 | loose |
| Lil Yachty | Conflicted | 20 | 26 | 105 | loose |
| Lil Yachty | Confused* | 9 | 3 | 21 | loose |
| Lil Yachty | Congratulations | 45 | 47 | 226 | loose |
| Lil Yachty | Countdown (Homecoming Live) | 29 | 16 | 93 | loose |
| Lil Yachty | Countin’ Caskets (Version 2) | 6 | 6 | 26 | loose |
| Lil Yachty | Courtside Choppas | 37 | 41 | 125 | loose |
| Lil Yachty | Crazy | 56 | 73 | 258 | loose |
| Lil Yachty | Crete Freestyle | 65 | 63 | 243 | loose |
| Lil Yachty | Crete Music Vol. 1 | 80 | 90 | 682 | loose |
| Lil Yachty | Crunk Ain’t Dead Mob | 50 | 38 | 348 | loose |
| Lil Yachty | Crush on You | 23 | 31 | 108 | loose |
| Lil Yachty | Cry Me A River | 36 | 37 | 201 | loose |
| Lil Yachty | Cut It | 21 | 24 | 46 | loose |
| Lil Yachty | DADDY ISSUES | 6 | 4 | 27 | loose |
| Lil Yachty | DAILY BREAD | 34 | 39 | 218 | loose |
| Lil Yachty | DAMN HOMIE | 48 | 75 | 406 | loose |
| Lil Yachty | DAS CAP | 39 | 23 | 166 | loose |
| Lil Yachty | DC&BOAT QC 1 | 43 | 58 | 248 | loose |
| Lil Yachty | DEMI | 37 | 47 | 165 | loose |
| Lil Yachty | DIAMONDS DANCING | 29 | 15 | 154 | loose |
| Lil Yachty | DIAMONDZ N CASH | 72 | 74 | 265 | loose |
| Lil Yachty | DIDNT I | 53 | 78 | 246 | loose |
| Lil Yachty | DIE FOR MINE | 79 | 98 | 502 | loose |
| Lil Yachty | DN Freestyle | 43 | 43 | 261 | loose |
| Lil Yachty | DN Freestyle 2 | 52 | 48 | 115 | loose |
| Lil Yachty | DOUBLECHECK | 23 | 15 | 134 | loose |
| Lil Yachty | DOWN | 41 | 52 | 181 | loose |
| Lil Yachty | DRAFTBOAT_1 | 49 | 48 | 201 | loose |
| Lil Yachty | Da Fuxk (Remix) | 157 | 152 | 1053 | loose |
| Lil Yachty | Damn | 10 | 27 | 111 | AAAA |
| Lil Yachty | Dan Bilzerian | 35 | 34 | 121 | loose |
| Lil Yachty | Dark Freestyle | 23 | 24 | 105 | loose |
| Lil Yachty | Daylight | 48 | 27 | 179 | loose |
| Lil Yachty | Dead Jugg | 19 | 25 | 61 | loose |
| Lil Yachty | Dead Man Walking | 26 | 21 | 92 | loose |
| Lil Yachty | Dead to Me | 36 | 51 | 324 | loose |
| Lil Yachty | Deep Down | 25 | 9 | 160 | loose |
| Lil Yachty | Demon Time | 79 | 67 | 436 | loose |
| Lil Yachty | Diamond Dancing | 33 | 32 | 296 | loose |
| Lil Yachty | Diamonds | 27 | 16 | 92 | loose |
| Lil Yachty | Die By Myself | 40 | 34 | 209 | loose |
| Lil Yachty | Die By Myself 2 | 44 | 70 | 171 | loose |
| Lil Yachty | Die By Myself 3 | 46 | 43 | 174 | loose |
| Lil Yachty | Die For Me | 34 | 29 | 113 | loose |
| Lil Yachty | Different Colors | 30 | 31 | 149 | loose |
| Lil Yachty | Dinner’s Ready | 26 | 24 | 188 | loose |
| Lil Yachty | Dip (Remix) | 23 | 12 | 64 | loose |
| Lil Yachty | DipSet | 45 | 34 | 227 | loose |
| Lil Yachty | Dirty Mouth | 86 | 59 | 248 | loose |
| Lil Yachty | Dirty Stick | 59 | 91 | 284 | loose |
| Lil Yachty | Do It | 33 | 24 | 130 | loose |
| Lil Yachty | Do Not Disturb | 52 | 52 | 192 | loose |
| Lil Yachty | Does It Again | 32 | 46 | 214 | loose |
| Lil Yachty | Done | 48 | 35 | 131 | loose |
| Lil Yachty | Don’t Dance No More* | 12 | 4 | 32 | loose |
| Lil Yachty | Don’t Even Bother | 35 | 57 | 303 | loose |
| Lil Yachty | Don’t Flex | 32 | 33 | 105 | loose |
| Lil Yachty | Don’t Forget | 28 | 22 | 111 | loose |
| Lil Yachty | Don’t Love Me / Bentley Bentayga* | 22 | 30 | 117 | loose |
| Lil Yachty | Don’t Play With Them Freestyle | 57 | 76 | 331 | loose |
| Lil Yachty | Don’t Wanna Lose Me | 27 | 15 | 131 | loose |
| Lil Yachty | Don’t Worry | 19 | 15 | 61 | loose |
| Lil Yachty | Doodleverse | 28 | 28 | 129 | loose |
| Lil Yachty | Dookie Shoe | 41 | 56 | 317 | loose |
| Lil Yachty | Down Bitches Only | 14 | 16 | 56 | loose |
| Lil Yachty | Dream (Move My Feet) | 4 | 2 | 4 | loose |
| Lil Yachty | Dream Girl | 36 | 26 | 86 | loose |
| Lil Yachty | Dreamboat Freestyle | 40 | 31 | 139 | loose |
| Lil Yachty | Drip from My Walk (Remix) | 48 | 51 | 175 | loose |
| Lil Yachty | Drip or Drown (Remix) | 67 | 107 | 323 | loose |
| Lil Yachty | Drippin` | 29 | 23 | 212 | loose |
| Lil Yachty | Dry Throat Freestyle | 10 | 8 | 43 | loose |
| Lil Yachty | Dying Over Me | 23 | 26 | 101 | loose |
| Lil Yachty | Dynamic Duo | 79 | 101 | 534 | loose |
| Lil Yachty | E-ER | 69 | 86 | 265 | loose |
| Lil Yachty | EA | 29 | 16 | 139 | loose |
| Lil Yachty | EAST WEST | 34 | 41 | 116 | loose |
| Lil Yachty | EVSS | 21 | 14 | 95 | loose |
| Lil Yachty | Earth | 74 | 35 | 180 | loose |
| Lil Yachty | Eastside | 32 | 22 | 155 | loose |
| Lil Yachty | Easty | 33 | 29 | 284 | loose |
| Lil Yachty | Easy | 27 | 27 | 95 | loose |
| Lil Yachty | Easy Peasy | 47 | 75 | 217 | loose |
| Lil Yachty | Ego* | 29 | 17 | 150 | loose |
| Lil Yachty | Endless | 43 | 57 | 272 | loose |
| Lil Yachty | Everybody Love To Get High | 34 | 50 | 200 | loose |
| Lil Yachty | Everyday We Lit (Remix) | 35 | 47 | 172 | loose |
| Lil Yachty | Everything Good, Everything Right | 34 | 25 | 58 | loose |
| Lil Yachty | Expensive | 54 | 43 | 170 | loose |
| Lil Yachty | Eye | 15 | 13 | 54 | loose |
| Lil Yachty | Eye Pray | 66 | 63 | 238 | loose |
| Lil Yachty | F1 | 27 | 16 | 150 | loose |
| Lil Yachty | FAMILY BUSINESS | 62 | 92 | 597 | loose |
| Lil Yachty | FAR AWAY | 16 | 5 | 45 | loose |
| Lil Yachty | FLEX | 22 | 16 | 170 | loose |
| Lil Yachty | FORGET YALL | 30 | 26 | 236 | loose |
| Lil Yachty | FORNICATE | 54 | 51 | 448 | loose |
| Lil Yachty | FREE DA GRIM REAPER FREESTYLE | 34 | 32 | 221 | loose |
| Lil Yachty | FREE ROCKY FREESTYLE | 47 | 40 | 187 | loose |
| Lil Yachty | FRIDAY | 45 | 22 | 216 | loose |
| Lil Yachty | FRIENDS DON’T HURT FRIENDS | 53 | 39 | 270 | loose |
| Lil Yachty | FTN | 73 | 80 | 339 | loose |
| Lil Yachty | FUK EM | 24 | 17 | 77 | loose |
| Lil Yachty | FWM | 40 | 54 | 268 | loose |
| Lil Yachty | FYI (Know Now) | 31 | 28 | 146 | loose |
| Lil Yachty | Face Down | 41 | 38 | 140 | loose |
| Lil Yachty | Facts | 31 | 25 | 93 | loose |
| Lil Yachty | Faizon | 21 | 18 | 129 | loose |
| Lil Yachty | Fake Love | 31 | 12 | 75 | loose |
| Lil Yachty | Faking It | 34 | 22 | 145 | loose |
| Lil Yachty | Fallin’ in Luv | 34 | 43 | 87 | loose |
| Lil Yachty | Fallout | 45 | 48 | 171 | loose |
| Lil Yachty | Family | 28 | 24 | 102 | loose |
| Lil Yachty | Faneto (Remix) | 5 | 0 | 22 | loose |
| Lil Yachty | Fasho Dat | 58 | 40 | 200 | loose |
| Lil Yachty | Fck Em | 5 | 1 | 9 | ABCB |
| Lil Yachty | February 17th Freestyle | 28 | 11 | 125 | loose |
| Lil Yachty | Feel Da Fonk | 22 | 16 | 117 | loose |
| Lil Yachty | Feels Like 2016 | 23 | 27 | 64 | loose |
| Lil Yachty | Feline (Original) | 36 | 52 | 189 | loose |
| Lil Yachty | Fell in Love with Money | 43 | 65 | 140 | loose |
| Lil Yachty | Ferrari Music | 40 | 38 | 322 | loose |
| Lil Yachty | Fifty-Nines Freestyle | 41 | 76 | 250 | loose |
| Lil Yachty | Fight Night Round 3 | 60 | 78 | 432 | loose |
| Lil Yachty | Fighter Jet | 37 | 32 | 197 | loose |
| Lil Yachty | Fill Up My Cup | 29 | 34 | 83 | loose |
| Lil Yachty | Final Form | 38 | 76 | 215 | loose |
| Lil Yachty | Fineto | 37 | 38 | 132 | loose |
| Lil Yachty | Fires | 36 | 52 | 201 | loose |
| Lil Yachty | First M Freestyle | 27 | 27 | 250 | loose |
| Lil Yachty | Flawless Victory | 69 | 113 | 562 | loose |
| Lil Yachty | Flex On Em (Remix) | 42 | 32 | 289 | loose |
| Lil Yachty | Flex Up | 36 | 18 | 246 | loose |
| Lil Yachty | Flexin on My Ex’s | 27 | 26 | 77 | loose |
| Lil Yachty | Flexing | 37 | 23 | 118 | loose |
| Lil Yachty | Flintana | 62 | 137 | 465 | loose |
| Lil Yachty | Flip Phone Trappin’ | 62 | 73 | 191 | loose |
| Lil Yachty | Float With Me | 40 | 26 | 112 | loose |
| Lil Yachty | Floss Everyday | 36 | 22 | 89 | loose |
| Lil Yachty | Flowers | 13 | 17 | 26 | loose |
| Lil Yachty | Flu Flamming (Remix) | 30 | 27 | 197 | loose |
| Lil Yachty | Follies (Original) | 21 | 20 | 142 | loose |
| Lil Yachty | For Hot 97 | 106 | 95 | 384 | loose |
| Lil Yachty | For Nothing | 29 | 9 | 89 | loose |
| Lil Yachty | For The Soul | 24 | 42 | 130 | loose |
| Lil Yachty | Foreign (Bad Bitches) | 28 | 21 | 129 | loose |
| Lil Yachty | Foreign Sheets | 56 | 52 | 271 | loose |
| Lil Yachty | Forever | 62 | 80 | 259 | loose |
| Lil Yachty | Forever World | 39 | 48 | 122 | loose |
| Lil Yachty | Forever Young | 26 | 26 | 98 | loose |
| Lil Yachty | Forgot I Was Famous | 43 | 46 | 195 | loose |
| Lil Yachty | Forreal | 37 | 28 | 227 | loose |
| Lil Yachty | Fortnite | 70 | 77 | 158 | loose |
| Lil Yachty | Found Myself (Remix) | 46 | 58 | 217 | loose |
| Lil Yachty | Freak of the Week | 33 | 41 | 116 | loose |
| Lil Yachty | Free K$upreme Freestyle | 35 | 25 | 168 | loose |
| Lil Yachty | Free The Lord | 35 | 40 | 127 | loose |
| Lil Yachty | Freeway Freestyle | 28 | 27 | 82 | loose |
| Lil Yachty | Fresh Off A Boat | 48 | 54 | 124 | loose |
| Lil Yachty | Friendly | 40 | 29 | 223 | loose |
| Lil Yachty | From Down Bad | 40 | 29 | 117 | loose |
| Lil Yachty | From The D to the A | 65 | 72 | 426 | loose |
| Lil Yachty | From the D to the A 2 | 56 | 71 | 350 | loose |
| Lil Yachty | Fuck All The Time | 10 | 14 | 21 | loose |
| Lil Yachty | Fuck Fame | 56 | 50 | 395 | loose |
| Lil Yachty | Fuck Up My Flow | 27 | 34 | 100 | loose |
| Lil Yachty | Fuck Up a Sack | 26 | 53 | 117 | loose |
| Lil Yachty | Fuck What You Sayin’ | 51 | 54 | 156 | loose |
| Lil Yachty | Fuck the D to the A | 63 | 66 | 367 | loose |
| Lil Yachty | Fuck ’Em | 36 | 13 | 103 | loose |
| Lil Yachty | Fucked A Fan (Demo) | 22 | 21 | 307 | loose |
| Lil Yachty | Fucked Over | 19 | 14 | 52 | loose |
| Lil Yachty | G.I. Joe | 53 | 47 | 144 | loose |
| Lil Yachty | G6 | 40 | 34 | 204 | loose |
| Lil Yachty | GEEKIN | 42 | 71 | 175 | loose |
| Lil Yachty | GET MONEY BROS. | 40 | 59 | 228 | loose |
| Lil Yachty | GHINI | 24 | 18 | 130 | loose |
| Lil Yachty | GO CRAZY FREESTYLE | 24 | 15 | 177 | loose |
| Lil Yachty | Games | 27 | 11 | 98 | loose |
| Lil Yachty | Gang Shit | 54 | 77 | 202 | loose |
| Lil Yachty | Gatsby | 29 | 27 | 99 | loose |
| Lil Yachty | Get Along | 68 | 90 | 294 | loose |
| Lil Yachty | Get Back! | 15 | 12 | 72 | loose |
| Lil Yachty | Get Dripped | 54 | 61 | 145 | loose |
| Lil Yachty | Get It Bussin | 41 | 42 | 216 | loose |
| Lil Yachty | Get Loose | 44 | 55 | 202 | loose |
| Lil Yachty | Get Low | 16 | 11 | 119 | loose |
| Lil Yachty | Get There | 27 | 35 | 77 | loose |
| Lil Yachty | Get Ur Freak On | 51 | 54 | 382 | loose |
| Lil Yachty | Gettin’ Outta Hand | 31 | 16 | 206 | loose |
| Lil Yachty | Ghetto Boy Shit | 53 | 78 | 443 | loose |
| Lil Yachty | Gimme Da Lite | 20 | 27 | 92 | loose |
| Lil Yachty | Gimme Dat | 27 | 15 | 129 | loose |
| Lil Yachty | Gimmicks | 31 | 37 | 208 | loose |
| Lil Yachty | Gimmie My Respect | 48 | 40 | 187 | loose |
| Lil Yachty | Ginger Shot | 30 | 47 | 115 | loose |
| Lil Yachty | Gingerbread Man | 29 | 24 | 67 | loose |
| Lil Yachty | Give It All | 31 | 18 | 108 | loose |
| Lil Yachty | Glacier Boyz Freestyle* | 34 | 51 | 219 | loose |
| Lil Yachty | Go Krazy, Go Stupid Freestyle | 40 | 41 | 238 | loose |
| Lil Yachty | Go On | 48 | 62 | 170 | loose |
| Lil Yachty | Go Round | 16 | 5 | 48 | loose |
| Lil Yachty | Go To The Moon | 51 | 99 | 236 | loose |
| Lil Yachty | Go! (Remix) | 25 | 18 | 93 | loose |
| Lil Yachty | Going Out Sad | 38 | 49 | 150 | loose |
| Lil Yachty | Gon’ Blow (KENC&BOAT) | 19 | 28 | 167 | loose |
| Lil Yachty | Good Day | 26 | 30 | 137 | loose |
| Lil Yachty | Good Morning (Remix) | 57 | 54 | 419 | loose |
| Lil Yachty | Good Night | 9 | 7 | 25 | loose |
| Lil Yachty | Gotta Let Go | 43 | 52 | 120 | loose |
| Lil Yachty | Greed | 30 | 22 | 159 | loose |
| Lil Yachty | Green Light | 42 | 42 | 131 | loose |
| Lil Yachty | Gremlin (Wheezy) | 23 | 27 | 82 | loose |
| Lil Yachty | Guacamole | 35 | 45 | 75 | loose |
| Lil Yachty | Guap Boys 2 (Money $ymbol) [Original]* | 20 | 13 | 33 | loose |
| Lil Yachty | Gucci Flip Flops | 25 | 35 | 267 | loose |
| Lil Yachty | Gutta | 40 | 47 | 167 | loose |
| Lil Yachty | HA | 38 | 52 | 186 | loose |
| Lil Yachty | HAF | 23 | 48 | 166 | loose |
| Lil Yachty | HAHAHA | 54 | 66 | 441 | loose |
| Lil Yachty | HATRED | 50 | 84 | 200 | loose |
| Lil Yachty | HELLCAT REMIX | 35 | 35 | 142 | loose |
| Lil Yachty | HOT HAM | 68 | 98 | 274 | loose |
| Lil Yachty | Half Doin Dope | 97 | 129 | 710 | loose |
| Lil Yachty | Halftime | 46 | 65 | 219 | loose |
| Lil Yachty | Halo | 20 | 8 | 125 | loose |
| Lil Yachty | Halo Effect | 33 | 51 | 122 | loose |
| Lil Yachty | Handle It | 43 | 40 | 181 | loose |
| Lil Yachty | Hang Out the Window | 39 | 28 | 130 | loose |
| Lil Yachty | Hard Enough | 42 | 36 | 241 | loose |
| Lil Yachty | Hasselhoff | 33 | 21 | 153 | loose |
| Lil Yachty | Hate It or Love It | 32 | 56 | 231 | loose |
| Lil Yachty | Hate Me | 66 | 43 | 312 | loose |
| Lil Yachty | Heat Seekers | 19 | 24 | 111 | loose |
| Lil Yachty | Hella Os | 55 | 59 | 110 | loose |
| Lil Yachty | Hellcat Kenny (Original) | 34 | 31 | 173 | loose |
| Lil Yachty | Here @lilyachty Tell me if you like these lyrics (: | 7 | 4 | 10 | loose |
| Lil Yachty | Here We Go | 30 | 17 | 97 | loose |
| Lil Yachty | Here We Go Again | 28 | 30 | 171 | loose |
| Lil Yachty | Hey Arnold (Remix) | 64 | 70 | 188 | loose |
| Lil Yachty | Hey Julie! | 33 | 22 | 125 | loose |
| Lil Yachty | Hi Roller /Demon Time | 13 | 2 | 85 | loose |
| Lil Yachty | High Rank | 46 | 63 | 362 | loose |
| Lil Yachty | Higher | 29 | 20 | 48 | loose |
| Lil Yachty | Highlife | 30 | 31 | 61 | loose |
| Lil Yachty | Highschool Dreams | 16 | 5 | 52 | loose |
| Lil Yachty | Hightop Shoes | 35 | 35 | 192 | loose |
| Lil Yachty | Hip Hopper | 44 | 32 | 232 | loose |
| Lil Yachty | History | 67 | 107 | 269 | loose |
| Lil Yachty | Hit Bout It | 59 | 94 | 496 | loose |
| Lil Yachty | Hmmm | 49 | 53 | 155 | loose |
| Lil Yachty | Hoe House | 47 | 40 | 194 | loose |
| Lil Yachty | Hoemita | 48 | 36 | 184 | loose |
| Lil Yachty | Hold Up (Dough Up) | 41 | 40 | 160 | loose |
| Lil Yachty | Holiday | 46 | 35 | 225 | loose |
| Lil Yachty | Holla Back* | 12 | 11 | 68 | loose |
| Lil Yachty | Hollywood | 33 | 23 | 107 | loose |
| Lil Yachty | Homicide Boat | 42 | 61 | 160 | loose |
| Lil Yachty | Homie Bitch | 52 | 49 | 176 | loose |
| Lil Yachty | Honey Pack (Remix) | 48 | 58 | 287 | loose |
| Lil Yachty | Honor | 58 | 48 | 183 | loose |
| Lil Yachty | Honor Roll | 36 | 42 | 87 | loose |
| Lil Yachty | Hoop Dreams | 21 | 8 | 137 | loose |
| Lil Yachty | Hot Girl Summer | 45 | 42 | 343 | loose |
| Lil Yachty | How Far Will I Go | 72 | 50 | 387 | loose |
| Lil Yachty | How It Feel | 59 | 83 | 315 | loose |
| Lil Yachty | How We Pop It* | 40 | 45 | 285 | loose |
| Lil Yachty | How You Feel? (Freestyle) | 57 | 83 | 243 | loose |
| Lil Yachty | How’d It Happen? | 41 | 20 | 51 | loose |
| Lil Yachty | Huge | 14 | 4 | 29 | loose |
| Lil Yachty | Hurricane (Lil Yachty Reference) | 46 | 36 | 340 | loose |
| Lil Yachty | Hybrid | 71 | 94 | 494 | loose |
| Lil Yachty | Hyenas | 77 | 34 | 382 | loose |
| Lil Yachty | Hype Me Up (Remix) | 44 | 40 | 140 | loose |
| Lil Yachty | I DONT TRUST MY BITCH / OLD RED | 66 | 82 | 300 | loose |
| Lil Yachty | I Did This To Myself | 28 | 9 | 83 | loose |
| Lil Yachty | I Do It 4 | 25 | 27 | 72 | loose |
| Lil Yachty | I Don’t Care... | 59 | 67 | 455 | loose |
| Lil Yachty | I Don’t Fuck with Niggas | 21 | 9 | 44 | loose |
| Lil Yachty | I Got It | 38 | 51 | 224 | loose |
| Lil Yachty | I Got The Baag | 32 | 37 | 272 | loose |
| Lil Yachty | I Got Um | 23 | 12 | 88 | loose |
| Lil Yachty | I Know Sum | 22 | 18 | 76 | loose |
| Lil Yachty | I Love You (No Need To Flex) | 16 | 9 | 47 | loose |
| Lil Yachty | I Love You A Lot | 14 | 9 | 89 | loose |
| Lil Yachty | I Made It | 34 | 14 | 88 | loose |
| Lil Yachty | I Need A Thug | 32 | 35 | 173 | loose |
| Lil Yachty | I Need My Money | 15 | 19 | 66 | loose |
| Lil Yachty | I Think I’m Gunna | 23 | 50 | 134 | loose |
| Lil Yachty | I Win | 35 | 33 | 67 | loose |
| Lil Yachty | I Wonder What’s Wrong (Lil Yachty Version) | 19 | 22 | 132 | loose |
| Lil Yachty | IDK | 46 | 51 | 157 | loose |
| Lil Yachty | IF I WASN’T RAPPIN | 62 | 106 | 438 | loose |
| Lil Yachty | ILY XL | 23 | 51 | 223 | AAAA |
| Lil Yachty | IN DIS WORLD | 53 | 47 | 201 | loose |
| Lil Yachty | ION KNOW YALL | 49 | 45 | 186 | loose |
| Lil Yachty | IT’S US | 33 | 24 | 139 | loose |
| Lil Yachty | IVE OFFICIALLY LOST ViSiON!!!! | 35 | 30 | 143 | loose |
| Lil Yachty | Ice | 69 | 69 | 330 | loose |
| Lil Yachty | Ice Tray | 42 | 69 | 133 | loose |
| Lil Yachty | Ice Water | 45 | 20 | 170 | loose |
| Lil Yachty | If You Down | 29 | 19 | 67 | loose |
| Lil Yachty | If You Move On I Still Love You | 36 | 35 | 183 | loose |
| Lil Yachty | If You Were Mine | 22 | 15 | 105 | loose |
| Lil Yachty | Illuminati | 27 | 23 | 121 | loose |
| Lil Yachty | Im The Shit Freestyle | 42 | 34 | 213 | loose |
| Lil Yachty | Imposters | 40 | 39 | 164 | loose |
| Lil Yachty | In Grey | 18 | 11 | 46 | loose |
| Lil Yachty | In My Car | 65 | 114 | 237 | loose |
| Lil Yachty | In My Foreign | 31 | 32 | 147 | loose |
| Lil Yachty | In My Stussy’s | 36 | 39 | 155 | loose |
| Lil Yachty | In NY | 32 | 37 | 143 | loose |
| Lil Yachty | India (Oh Love) | 24 | 22 | 62 | loose |
| Lil Yachty | Inna Bag (Remix) | 73 | 88 | 588 | loose |
| Lil Yachty | Interesting | 59 | 74 | 527 | loose |
| Lil Yachty | Interlude | 15 | 13 | 72 | loose |
| Lil Yachty | International* | 4 | 0 | 11 | loose |
| Lil Yachty | Intro | 45 | 37 | 141 | loose |
| Lil Yachty | Intro Intro | 51 | 28 | 282 | loose |
| Lil Yachty | Ion Know Shit About My Opps | 32 | 12 | 100 | loose |
| Lil Yachty | Ion Need Sleep | 26 | 22 | 119 | loose |
| Lil Yachty | It Takes Two | 53 | 29 | 179 | loose |
| Lil Yachty | Its In Me | 35 | 30 | 160 | loose |
| Lil Yachty | Its Us | 37 | 33 | 178 | loose |
| Lil Yachty | It’s Never Real* | 26 | 7 | 109 | loose |
| Lil Yachty | It’s Whatever | 48 | 61 | 343 | loose |
| Lil Yachty | I’ll Be Damned | 54 | 58 | 192 | loose |
| Lil Yachty | I’m Crazy | 68 | 78 | 242 | loose |
| Lil Yachty | I’m Da Man | 34 | 39 | 181 | loose |
| Lil Yachty | I’m Gone | 25 | 37 | 114 | loose |
| Lil Yachty | I’m Ready | 29 | 25 | 197 | loose |
| Lil Yachty | I’m Sorry | 20 | 14 | 36 | loose |
| Lil Yachty | I’m in love with you girl | 7 | 1 | 10 | loose |
| Lil Yachty | I’m the Mac | 25 | 27 | 70 | loose |
| Lil Yachty | J balli - ice (remix)- ft lil yachty & tfemi | 44 | 43 | 166 | loose |
| Lil Yachty | JACKRABBIT | 36 | 41 | 336 | loose |
| Lil Yachty | JEFF & LITA | 71 | 121 | 477 | loose |
| Lil Yachty | JITTER BUG | 29 | 29 | 137 | loose |
| Lil Yachty | JORDAN BELFORT | 23 | 7 | 115 | loose |
| Lil Yachty | Jack Wit’ A Bean | 36 | 42 | 182 | loose |
| Lil Yachty | Jeff Gordon | 27 | 23 | 183 | loose |
| Lil Yachty | Jesse Owens | 19 | 27 | 70 | loose |
| Lil Yachty | Jewels | 45 | 47 | 125 | loose |
| Lil Yachty | Jimmy Dean | 30 | 34 | 161 | loose |
| Lil Yachty | Jobs | 25 | 17 | 93 | loose |
| Lil Yachty | John Madden | 43 | 65 | 314 | loose |
| Lil Yachty | Johnny Dang* | 14 | 9 | 66 | loose |
| Lil Yachty | Josie’s Song | 27 | 17 | 73 | loose |
| Lil Yachty | Judgement Free | 26 | 10 | 95 | loose |
| Lil Yachty | Jumanji | 20 | 37 | 55 | loose |
| Lil Yachty | Jumbotron Shit Poppin | 28 | 43 | 194 | loose |
| Lil Yachty | Jump Off a Jet | 40 | 21 | 201 | loose |
| Lil Yachty | Jump On It | 42 | 32 | 182 | loose |
| Lil Yachty | Just How I’m Feelin’ | 43 | 56 | 431 | loose |
| Lil Yachty | Just Want You (Remix) | 35 | 31 | 84 | loose |
| Lil Yachty | Juug | 33 | 32 | 140 | loose |
| Lil Yachty | KARDASHIANS | 53 | 94 | 610 | loose |
| Lil Yachty | KILLA KILLA | 37 | 34 | 284 | loose |
| Lil Yachty | Kane & Take | 16 | 3 | 91 | loose |
| Lil Yachty | Kane and Take | 70 | 79 | 423 | loose |
| Lil Yachty | Keep Dropping The Beat | 67 | 132 | 424 | loose |
| Lil Yachty | Keep Going | 33 | 37 | 88 | loose |
| Lil Yachty | Keep It Real | 38 | 33 | 50 | loose |
| Lil Yachty | Keri Hilson / Shootout | 79 | 88 | 440 | loose |
| Lil Yachty | Kevin (VeeVeeVee) | 40 | 53 | 129 | loose |
| Lil Yachty | Keys To Success | 28 | 19 | 107 | loose |
| Lil Yachty | Kill Bill II | 94 | 60 | 319 | loose |
| Lil Yachty | Killin’ Time | 55 | 60 | 271 | loose |
| Lil Yachty | King Alfred | 35 | 27 | 161 | loose |
| Lil Yachty | King Boat | 26 | 19 | 175 | loose |
| Lil Yachty | King of Teens | 22 | 40 | 152 | loose |
| Lil Yachty | Kiss the Money | 49 | 38 | 143 | loose |
| Lil Yachty | Kit Kat | 39 | 54 | 145 | loose |
| Lil Yachty | Knew Better | 115 | 132 | 655 | loose |
| Lil Yachty | Knew This | 30 | 24 | 188 | loose |
| Lil Yachty | Know I’ma Get It | 51 | 56 | 169 | loose |
| Lil Yachty | Know That | 47 | 41 | 219 | loose |
| Lil Yachty | Know What To Do | 36 | 38 | 198 | loose |
| Lil Yachty | Knuck If You Buck | 45 | 42 | 110 | loose |
| Lil Yachty | Kourtside | 68 | 73 | 365 | loose |
| Lil Yachty | Krazy up | 29 | 32 | 142 | loose |
| Lil Yachty | KrispyBoat | 63 | 101 | 504 | loose |
| Lil Yachty | Kryptonite | 54 | 105 | 144 | loose |
| Lil Yachty | LA | 39 | 40 | 102 | loose |
| Lil Yachty | LA Day | 31 | 34 | 75 | loose |
| Lil Yachty | LA REID | 22 | 17 | 64 | loose |
| Lil Yachty | LAST MISSION (Nun Of My Business) | 29 | 54 | 161 | loose |
| Lil Yachty | LONG LIVE | 27 | 34 | 119 | loose |
| Lil Yachty | LONG LIVE MY ANGELS | 38 | 36 | 155 | loose |
| Lil Yachty | LOTUS FLOWER BOMB | 28 | 23 | 184 | loose |
| Lil Yachty | Lady in Yellow | 26 | 24 | 91 | loose |
| Lil Yachty | Landline | 39 | 40 | 137 | loose |
| Lil Yachty | Last Minute | 47 | 100 | 341 | loose |
| Lil Yachty | Latest and Greatest | 32 | 41 | 137 | loose |
| Lil Yachty | Lawyer Fees | 32 | 39 | 283 | loose |
| Lil Yachty | Lean Then Dip | 22 | 30 | 100 | loose |
| Lil Yachty | Lego Ring | 17 | 10 | 35 | loose |
| Lil Yachty | Lemon Head | 38 | 55 | 249 | loose |
| Lil Yachty | Let Me Fuck | 18 | 9 | 64 | loose |
| Lil Yachty | Lets Get On Dey Ass | 32 | 22 | 69 | loose |
| Lil Yachty | Let’s Be Honest | 37 | 25 | 93 | loose |
| Lil Yachty | Let’s Get Rich | 37 | 56 | 183 | loose |
| Lil Yachty | Lexy Sove | 36 | 47 | 172 | loose |
| Lil Yachty | Li Gangsta | 40 | 34 | 95 | loose |
| Lil Yachty | Li Moe Remix | 39 | 27 | 174 | loose |
| Lil Yachty | Life Goes On | 37 | 15 | 126 | loose |
| Lil Yachty | Life is Proper | 22 | 28 | 55 | loose |
| Lil Yachty | Lifelike | 58 | 33 | 149 | loose |
| Lil Yachty | Lifestyle | 21 | 13 | 59 | loose |
| Lil Yachty | Light | 80 | 103 | 337 | loose |
| Lil Yachty | Lights Out | 46 | 41 | 168 | loose |
| Lil Yachty | Like Wassup (Remix) | 42 | 23 | 113 | loose |
| Lil Yachty | Like You Say You Do | 19 | 18 | 99 | loose |
| Lil Yachty | Like a Star | 35 | 29 | 136 | loose |
| Lil Yachty | Lil Bitch (Remix) | 90 | 106 | 350 | loose |
| Lil Yachty | Lil Boat | 20 | 39 | 197 | AAAA |
| Lil Yachty | Lil Diamond Boy | 28 | 0 | 63 | loose |
| Lil Yachty | Lil Mega Minion | 21 | 18 | 70 | loose |
| Lil Yachty | Lil Yachty Meets Digital Nas | 30 | 8 | 84 | loose |
| Lil Yachty | Lil Yachty | Funk Flex | #Freestyle091 | 34 | 44 | 269 | loose |
| Lil Yachty | Linger Freestyle | 35 | 30 | 152 | loose |
| Lil Yachty | Lit | 18 | 10 | 37 | loose |
| Lil Yachty | Litty | 18 | 24 | 100 | loose |
| Lil Yachty | Live Forever | 29 | 19 | 106 | loose |
| Lil Yachty | Livestream | 46 | 43 | 147 | loose |
| Lil Yachty | Living Legend | 32 | 17 | 196 | loose |
| Lil Yachty | Livin’ Life | 34 | 18 | 122 | loose |
| Lil Yachty | Llarkelly (Remix) | 45 | 41 | 153 | loose |
| Lil Yachty | Loaded Up | 47 | 61 | 215 | loose |
| Lil Yachty | Loco | 31 | 13 | 214 | loose |
| Lil Yachty | Lollipop | 51 | 33 | 132 | loose |
| Lil Yachty | Lonely Nights | 22 | 20 | 112 | loose |
| Lil Yachty | Look on Your Face | 53 | 49 | 182 | loose |
| Lil Yachty | Lord of the Beans | 63 | 84 | 430 | loose |
| Lil Yachty | Loso Boat | 55 | 52 | 209 | loose |
| Lil Yachty | Lost Files Intro | 34 | 36 | 173 | loose |
| Lil Yachty | Lost It | 44 | 42 | 253 | loose |
| Lil Yachty | Love I Can Borrow | 16 | 10 | 28 | loose |
| Lil Yachty | Love Jones | 19 | 18 | 79 | loose |
| Lil Yachty | Love Lost (Lessons) | 22 | 15 | 106 | loose |
| Lil Yachty | Love Music | 21 | 16 | 62 | loose |
| Lil Yachty | Loving Me | 32 | 34 | 61 | loose |
| Lil Yachty | Low | 20 | 35 | 103 | AAAA |
| Lil Yachty | Low End | 45 | 48 | 142 | loose |
| Lil Yachty | Loyalty Over Everything | 12 | 14 | 67 | loose |
| Lil Yachty | Luck | 48 | 90 | 187 | loose |
| Lil Yachty | Luminous* | 4 | 0 | 8 | loose |
| Lil Yachty | Lunch Break Freestyle | 83 | 125 | 700 | loose |
| Lil Yachty | Lying | 38 | 26 | 197 | loose |
| Lil Yachty | M.O.B. | 48 | 64 | 342 | loose |
| Lil Yachty | M.O.N.E.Y | 12 | 7 | 53 | loose |
| Lil Yachty | MAKE YOU MINE | 16 | 16 | 24 | loose |
| Lil Yachty | MICKEY | 47 | 58 | 177 | loose |
| Lil Yachty | MILLIONAIRE | 73 | 78 | 382 | loose |
| Lil Yachty | MO JAMS | 114 | 118 | 545 | loose |
| Lil Yachty | MONEY BAGS FREESTYLE | 39 | 47 | 214 | loose |
| Lil Yachty | MY LIFE | 23 | 24 | 166 | loose |
| Lil Yachty | MaC Truck | 26 | 34 | 341 | loose |
| Lil Yachty | Made Martian | 75 | 105 | 330 | loose |
| Lil Yachty | Made Men | 22 | 14 | 123 | loose |
| Lil Yachty | Made of Glass | 23 | 21 | 153 | loose |
| Lil Yachty | Magic in the Hamptons | 34 | 28 | 183 | loose |
| Lil Yachty | Magical Poof | 51 | 50 | 188 | loose |
| Lil Yachty | Major Distribution | 42 | 31 | 254 | loose |
| Lil Yachty | Make It Hot | 20 | 16 | 67 | loose |
| Lil Yachty | Make Me Better* | 4 | 5 | 16 | AAAA |
| Lil Yachty | Make a Hit | 41 | 40 | 239 | loose |
| Lil Yachty | Mamacita | 31 | 32 | 216 | loose |
| Lil Yachty | Man of the Year | 48 | 31 | 269 | loose |
| Lil Yachty | Marmalade | 59 | 64 | 280 | loose |
| Lil Yachty | Marshall Mathers | 19 | 38 | 183 | AAAA |
| Lil Yachty | Mase in ’97 | 44 | 53 | 209 | loose |
| Lil Yachty | Maserati (Mahzi Freestyle) | 32 | 30 | 133 | loose |
| Lil Yachty | Maybach Music | 19 | 17 | 36 | loose |
| Lil Yachty | Maybelline | 39 | 62 | 169 | loose |
| Lil Yachty | Meditation 2 | 48 | 29 | 112 | loose |
| Lil Yachty | Menace | 38 | 49 | 186 | loose |
| Lil Yachty | Menace 2 | 64 | 120 | 247 | loose |
| Lil Yachty | Menu Song (Lil Yachty Remix) | 21 | 11 | 123 | loose |
| Lil Yachty | Metal Gear | 15 | 14 | 147 | loose |
| Lil Yachty | Midnight | 31 | 16 | 131 | loose |
| Lil Yachty | Midnight Hour | 30 | 18 | 100 | loose |
| Lil Yachty | Mini Mart | 13 | 6 | 28 | loose |
| Lil Yachty | Minnesota | 22 | 11 | 150 | loose |
| Lil Yachty | Missing Man | 18 | 14 | 59 | loose |
| Lil Yachty | Mister Nice Guy | 37 | 31 | 167 | loose |
| Lil Yachty | Mixtape | 69 | 53 | 308 | loose |
| Lil Yachty | Mob Ties | 40 | 43 | 136 | loose |
| Lil Yachty | Moments in Time | 27 | 30 | 45 | loose |
| Lil Yachty | Momma (Outro) | 35 | 10 | 157 | loose |
| Lil Yachty | Money Don’t Make The Man | 19 | 9 | 54 | loose |
| Lil Yachty | Money Shower | 51 | 42 | 161 | loose |
| Lil Yachty | Money Team | 30 | 36 | 196 | loose |
| Lil Yachty | Money on the Floor | 29 | 16 | 124 | loose |
| Lil Yachty | Monta | 35 | 17 | 209 | loose |
| Lil Yachty | Mood | 40 | 22 | 98 | loose |
| Lil Yachty | Mood Swings | 17 | 18 | 88 | loose |
| Lil Yachty | Mossed | 22 | 11 | 112 | loose |
| Lil Yachty | Most Wanted | 31 | 30 | 84 | loose |
| Lil Yachty | Motivated | 40 | 56 | 98 | loose |
| Lil Yachty | Motivation | 56 | 46 | 214 | loose |
| Lil Yachty | Motorbike | 39 | 35 | 112 | loose |
| Lil Yachty | Move Along | 57 | 58 | 439 | loose |
| Lil Yachty | Move Wit Tha Mac | 30 | 59 | 68 | AAAA |
| Lil Yachty | Moving* | 8 | 4 | 11 | loose |
| Lil Yachty | Movin’ Up | 35 | 35 | 119 | loose |
| Lil Yachty | Mr. Fortunate | 72 | 97 | 334 | loose |
| Lil Yachty | Murda | 29 | 30 | 108 | loose |
| Lil Yachty | Mush Mouf | 20 | 33 | 133 | loose |
| Lil Yachty | Mutombo | 25 | 7 | 153 | loose |
| Lil Yachty | My Ass | 34 | 18 | 116 | loose |
| Lil Yachty | My Business | 45 | 40 | 163 | loose |
| Lil Yachty | My Circle | 36 | 27 | 205 | loose |
| Lil Yachty | My Lady | 35 | 52 | 115 | loose |
| Lil Yachty | My Level | 49 | 32 | 349 | loose |
| Lil Yachty | My Lil Stoney / Stoney Pt. 2 | 33 | 18 | 132 | loose |
| Lil Yachty | My Slime | 26 | 54 | 121 | loose |
| Lil Yachty | My Soul | 9 | 6 | 21 | loose |
| Lil Yachty | Můj příběh | 37 | 26 | 520 | loose |
| Lil Yachty | M’s | 21 | 21 | 111 | loose |
| Lil Yachty | N**** AINT CLOSE | 43 | 45 | 59 | loose |
| Lil Yachty | NAME IT AFTER ME | 55 | 66 | 442 | loose |
| Lil Yachty | NASCAR | 30 | 12 | 89 | loose |
| Lil Yachty | NBA JAM | 44 | 46 | 356 | loose |
| Lil Yachty | NBAYOUNGBOAT | 59 | 67 | 389 | loose |
| Lil Yachty | NDA | 33 | 25 | 164 | loose |
| Lil Yachty | NIGHTS | 31 | 29 | 163 | loose |
| Lil Yachty | NIKE | 6 | 1 | 11 | loose |
| Lil Yachty | NOSTALGIA | 53 | 42 | 164 | loose |
| Lil Yachty | NOT DA 2 | 33 | 20 | 204 | loose |
| Lil Yachty | Nada | 42 | 31 | 118 | loose |
| Lil Yachty | Neck Shine | 41 | 30 | 270 | loose |
| Lil Yachty | Neon | 30 | 38 | 75 | loose |
| Lil Yachty | Neon Lights | 82 | 105 | 509 | loose |
| Lil Yachty | Nerves | 25 | 25 | 85 | loose |
| Lil Yachty | Never Did Coke | 67 | 72 | 399 | loose |
| Lil Yachty | Never Enough | 51 | 54 | 122 | loose |
| Lil Yachty | Never Heard of You | 28 | 25 | 143 | loose |
| Lil Yachty | Never Lose Me (Remix) | 49 | 59 | 171 | loose |
| Lil Yachty | Never Switch Up | 17 | 8 | 74 | loose |
| Lil Yachty | Never Want It All | 26 | 14 | 125 | loose |
| Lil Yachty | New Day | 75 | 82 | 321 | loose |
| Lil Yachty | New Goin’ In | 43 | 28 | 222 | loose |
| Lil Yachty | New Species | 49 | 49 | 136 | loose |
| Lil Yachty | New Swag | 36 | 27 | 170 | loose |
| Lil Yachty | New Watch Alert | 63 | 49 | 461 | loose |
| Lil Yachty | Next Up | 59 | 72 | 293 | loose |
| Lil Yachty | Nigga Like Me | 22 | 19 | 88 | loose |
| Lil Yachty | Night Call | 72 | 71 | 246 | loose |
| Lil Yachty | No Cap | 51 | 57 | 181 | loose |
| Lil Yachty | No Clue (Remix) | 62 | 69 | 156 | loose |
| Lil Yachty | No Coach | 41 | 45 | 143 | loose |
| Lil Yachty | No Competition | 44 | 41 | 212 | loose |
| Lil Yachty | No Fighting | 45 | 37 | 178 | loose |
| Lil Yachty | No Going Steady | 30 | 30 | 201 | loose |
| Lil Yachty | No Hook | 60 | 84 | 200 | loose |
| Lil Yachty | No Hook Pt. 2 | 49 | 43 | 131 | loose |
| Lil Yachty | No More | 16 | 2 | 76 | loose |
| Lil Yachty | No More Beatboxing Freestyle | 55 | 59 | 412 | loose |
| Lil Yachty | No Regrets | 36 | 32 | 163 | loose |
| Lil Yachty | No Sirski | 29 | 28 | 108 | loose |
| Lil Yachty | No Smoke | 36 | 48 | 126 | loose |
| Lil Yachty | No Tilt | 60 | 81 | 198 | loose |
| Lil Yachty | No Vegetables | 27 | 43 | 183 | loose |
| Lil Yachty | Nobody | 34 | 38 | 223 | loose |
| Lil Yachty | Nolia | 69 | 82 | 181 | loose |
| Lil Yachty | Not Bluffin | 18 | 32 | 108 | loose |
| Lil Yachty | Not My Bro | 21 | 46 | 112 | loose |
| Lil Yachty | Not Regular | 44 | 51 | 240 | loose |
| Lil Yachty | Nothing In The Whole Wide World | 48 | 69 | 381 | loose |
| Lil Yachty | Now You Know | 25 | 12 | 63 | loose |
| Lil Yachty | Number 9 | 21 | 8 | 62 | loose |
| Lil Yachty | NēoN DeReK JeTëR | 33 | 22 | 111 | loose |
| Lil Yachty | OBVIOUS | 25 | 17 | 71 | loose |
| Lil Yachty | OLD SKOOL WHOOP | 81 | 50 | 209 | loose |
| Lil Yachty | ON MY MOTHER FREESTYLE | 39 | 46 | 250 | loose |
| Lil Yachty | ON THE RADAR CONCRETE CYPHER | 109 | 162 | 936 | loose |
| Lil Yachty | ONE TIME | 97 | 113 | 664 | loose |
| Lil Yachty | OOPS | 41 | 56 | 261 | loose |
| Lil Yachty | OPRAH’S BANK | 11 | 7 | 54 | loose |
| Lil Yachty | OUT RAP US (Crete x CBFW) | 45 | 57 | 437 | loose |
| Lil Yachty | OUTTAMYMIND! | 50 | 38 | 192 | loose |
| Lil Yachty | Obvious, Obviously | 3 | 1 | 2 | loose |
| Lil Yachty | Oh Damn | 52 | 46 | 172 | loose |
| Lil Yachty | Oh Lord | 21 | 15 | 53 | loose |
| Lil Yachty | Oh Oh | 9 | 2 | 18 | loose |
| Lil Yachty | Oh Yeah | 36 | 39 | 84 | loose |
| Lil Yachty | Ok Ok | 50 | 53 | 262 | loose |
| Lil Yachty | Old School Chevy | 40 | 54 | 215 | loose |
| Lil Yachty | On Me | 52 | 51 | 159 | loose |
| Lil Yachty | On That Back (Freestyle) | 66 | 99 | 285 | loose |
| Lil Yachty | On The Level (Kerwin Frost Telethon) | 6 | 1 | 6 | loose |
| Lil Yachty | On The Radar Freestyle | 42 | 43 | 222 | loose |
| Lil Yachty | On Top | 25 | 18 | 32 | loose |
| Lil Yachty | On Your Mind | 28 | 17 | 119 | loose |
| Lil Yachty | On the Water (Remix) | 40 | 31 | 194 | loose |
| Lil Yachty | Once Again | 75 | 53 | 434 | loose |
| Lil Yachty | One Night | 27 | 34 | 83 | loose |
| Lil Yachty | One Of Those Days | 22 | 27 | 118 | loose |
| Lil Yachty | One Take | 36 | 16 | 97 | loose |
| Lil Yachty | One Way! (Remix) | 22 | 8 | 56 | loose |
| Lil Yachty | Only In My Dreams | 21 | 8 | 94 | loose |
| Lil Yachty | OpenDoors | 50 | 35 | 181 | loose |
| Lil Yachty | Opps Strugglin | 29 | 33 | 199 | loose |
| Lil Yachty | Oprah’s Bank Account | 42 | 35 | 176 | loose |
| Lil Yachty | Or Sum | 18 | 21 | 156 | loose |
| Lil Yachty | Oreo | 48 | 43 | 263 | loose |
| Lil Yachty | Otha Shit (Interlude) | 12 | 25 | 61 | AAAA |
| Lil Yachty | Out Late | 20 | 8 | 32 | loose |
| Lil Yachty | Out My Face (My Baby) | 51 | 49 | 203 | loose |
| Lil Yachty | Out Of My Body | 36 | 44 | 131 | loose |
| Lil Yachty | Out of Sight | 36 | 35 | 111 | loose |
| Lil Yachty | PAWG | 26 | 25 | 128 | loose |
| Lil Yachty | PIMP TALK | 24 | 32 | 132 | loose |
| Lil Yachty | PIMPIN AINT EASY | 30 | 39 | 70 | loose |
| Lil Yachty | PISSED OFF | 42 | 42 | 180 | loose |
| Lil Yachty | PLAYA WALKIN | 32 | 28 | 195 | loose |
| Lil Yachty | POINT ME TO IT | 39 | 47 | 185 | loose |
| Lil Yachty | POLAND REMIX | 18 | 3 | 192 | loose |
| Lil Yachty | POP | 13 | 5 | 53 | loose |
| Lil Yachty | POP OUT | 47 | 29 | 169 | loose |
| Lil Yachty | POP YO SHI TWIN | 37 | 21 | 197 | loose |
| Lil Yachty | POPOVICH FREESTYLE | 34 | 61 | 348 | loose |
| Lil Yachty | POSTHUMOUS FORGIVENESS | 38 | 34 | 356 | loose |
| Lil Yachty | PRIX FREESTYLE | 45 | 38 | 181 | loose |
| Lil Yachty | PUSH IT | 64 | 39 | 479 | loose |
| Lil Yachty | Pakks In (Freestyle) | 56 | 46 | 258 | loose |
| Lil Yachty | Pardon Me | 64 | 81 | 260 | loose |
| Lil Yachty | Part Of The Plan | 32 | 40 | 151 | loose |
| Lil Yachty | Passcode | 12 | 25 | 74 | loose |
| Lil Yachty | Past Tense* | 15 | 15 | 81 | loose |
| Lil Yachty | Pay My Fee Freestyle | 44 | 34 | 240 | loose |
| Lil Yachty | Peanut Butter Coupe* | 31 | 55 | 222 | loose |
| Lil Yachty | Peek a Boo | 68 | 61 | 216 | loose |
| Lil Yachty | Perfect | 45 | 28 | 144 | loose |
| Lil Yachty | Perplexing Pegasus (Freestyle) | 14 | 14 | 23 | loose |
| Lil Yachty | Pesos | 19 | 10 | 58 | loose |
| Lil Yachty | Phone Tap Freestyle | 40 | 83 | 194 | loose |
| Lil Yachty | Pick It Up | 44 | 49 | 145 | loose |
| Lil Yachty | Pieces | 52 | 67 | 270 | loose |
| Lil Yachty | Piggy Bank | 34 | 34 | 128 | loose |
| Lil Yachty | Piling Up | 28 | 31 | 142 | loose |
| Lil Yachty | Ping Pong | 5 | 1 | 22 | ABCB |
| Lil Yachty | Pistols Close | 31 | 49 | 118 | loose |
| Lil Yachty | Places + Faces | 27 | 33 | 128 | loose |
| Lil Yachty | Plastic | 66 | 124 | 582 | loose |
| Lil Yachty | Play | 22 | 31 | 275 | loose |
| Lil Yachty | Play Your Position | 54 | 87 | 228 | loose |
| Lil Yachty | Pointless | 57 | 35 | 190 | loose |
| Lil Yachty | Poland | 9 | 8 | 11 | loose |
| Lil Yachty | Polar Opposites | 38 | 48 | 140 | loose |
| Lil Yachty | Powerball | 45 | 66 | 228 | loose |
| Lil Yachty | Pretend | 44 | 54 | 110 | loose |
| Lil Yachty | Pretender | 35 | 21 | 58 | loose |
| Lil Yachty | Pretty Boy | 21 | 23 | 71 | loose |
| Lil Yachty | Pretty Boy Millionaires 2 Intro | 32 | 28 | 128 | loose |
| Lil Yachty | Primetime | 40 | 32 | 169 | loose |
| Lil Yachty | Priorities | 34 | 30 | 107 | loose |
| Lil Yachty | Private | 38 | 18 | 215 | loose |
| Lil Yachty | Privileged Rappers | 31 | 48 | 225 | loose |
| Lil Yachty | Psych Out | 15 | 8 | 106 | loose |
| Lil Yachty | Purple Hearts (With Lil Yachty) | 24 | 23 | 84 | loose |
| Lil Yachty | Pussy & Millions | 70 | 105 | 269 | loose |
| Lil Yachty | Pussy Talk* | 5 | 2 | 19 | loose |
| Lil Yachty | Put Em Out | 35 | 24 | 391 | loose |
| Lil Yachty | R.I.P. Lil Pete* | 13 | 14 | 68 | loose |
| Lil Yachty | REACH THE SUNSHINE. | 24 | 12 | 32 | loose |
| Lil Yachty | REAL LIFE | 37 | 38 | 211 | loose |
| Lil Yachty | RED | 24 | 30 | 155 | loose |
| Lil Yachty | RED PILL / BLUE PILL | 20 | 31 | 116 | loose |
| Lil Yachty | REDMERCEDES (Remix) | 54 | 43 | 258 | loose |
| Lil Yachty | RESPECT ME | 13 | 7 | 89 | loose |
| Lil Yachty | REUNION | 40 | 51 | 231 | loose |
| Lil Yachty | RICHEST | 63 | 86 | 340 | loose |
| Lil Yachty | RIDE! | 39 | 35 | 169 | loose |
| Lil Yachty | ROAMIN | 31 | 29 | 129 | loose |
| Lil Yachty | ROUND N ROUND | 36 | 24 | 117 | loose |
| Lil Yachty | RUBBERBANDMAN/SANDMAN | 15 | 4 | 77 | loose |
| Lil Yachty | RUN IN DA BANK | 32 | 33 | 119 | loose |
| Lil Yachty | Raccs Up | 32 | 26 | 247 | loose |
| Lil Yachty | Rackies | 33 | 41 | 102 | loose |
| Lil Yachty | Rain | 27 | 36 | 334 | loose |
| Lil Yachty | Rainbow | 42 | 59 | 111 | loose |
| Lil Yachty | Raising Canes | 35 | 47 | 509 | loose |
| Lil Yachty | Ran Up A Check | 61 | 40 | 175 | loose |
| Lil Yachty | Range Rover Sports Truck | 35 | 35 | 131 | loose |
| Lil Yachty | Rap Like Me | 58 | 80 | 324 | loose |
| Lil Yachty | Rapper Warrior Ninja (The Eric Andre Show) | 29 | 5 | 71 | loose |
| Lil Yachty | Raps About Nothin | 15 | 5 | 126 | loose |
| Lil Yachty | Rari | 46 | 66 | 134 | loose |
| Lil Yachty | Real Nigga | 51 | 24 | 222 | loose |
| Lil Yachty | Real Snakes | 37 | 46 | 208 | loose |
| Lil Yachty | Real Talk | 13 | 21 | 100 | loose |
| Lil Yachty | Realest From Philly | 62 | 68 | 322 | loose |
| Lil Yachty | Really Them Boys | 44 | 72 | 231 | loose |
| Lil Yachty | Red Button | 43 | 146 | 290 | AAAA |
| Lil Yachty | Red Carpet | 15 | 13 | 48 | loose |
| Lil Yachty | Reese’s Puffs Rap (The REE-MIX) | 13 | 17 | 63 | loose |
| Lil Yachty | Remember December | 84 | 123 | 231 | loose |
| Lil Yachty | Respect My Name | 30 | 33 | 106 | loose |
| Lil Yachty | Revenge | 41 | 22 | 114 | loose |
| Lil Yachty | Rewind | 29 | 23 | 45 | loose |
| Lil Yachty | Rich Sinners | 47 | 42 | 331 | loose |
| Lil Yachty | Richer Than Alla My Opps | 27 | 39 | 178 | loose |
| Lil Yachty | Richie Rich* | 11 | 7 | 38 | loose |
| Lil Yachty | Ride Out | 56 | 68 | 240 | loose |
| Lil Yachty | Ride the Boat | 19 | 15 | 41 | loose |
| Lil Yachty | Ridin Round | 32 | 23 | 246 | loose |
| Lil Yachty | Right Now (Teen Remix) | 58 | 36 | 266 | loose |
| Lil Yachty | Right from Wrong | 42 | 33 | 92 | loose |
| Lil Yachty | Riley from the Boondocks | 47 | 56 | 159 | loose |
| Lil Yachty | Road Runner | 67 | 61 | 294 | loose |
| Lil Yachty | Robbery | 45 | 89 | 124 | loose |
| Lil Yachty | Rocc Climbing | 67 | 102 | 456 | loose |
| Lil Yachty | Rose Gold on My Teeth | 25 | 17 | 92 | loose |
| Lil Yachty | Rover | 25 | 34 | 77 | loose |
| Lil Yachty | Royal Rumble | 95 | 106 | 721 | loose |
| Lil Yachty | Rudenezz | 43 | 56 | 135 | loose |
| Lil Yachty | Rule #1 | 69 | 126 | 250 | loose |
| Lil Yachty | Run Away From The Rabbit | 25 | 16 | 64 | loose |
| Lil Yachty | Run Down | 95 | 125 | 708 | loose |
| Lil Yachty | Run It | 19 | 26 | 44 | loose |
| Lil Yachty | Run My Sack Up 2 | 24 | 23 | 120 | loose |
| Lil Yachty | Run Wit da Sack | 31 | 32 | 159 | loose |
| Lil Yachty | Run/Running | 42 | 26 | 127 | loose |
| Lil Yachty | Runnin Wit a Sack | 43 | 38 | 216 | loose |
| Lil Yachty | Running With a Ghost | 41 | 45 | 131 | loose |
| Lil Yachty | SAATS | 44 | 35 | 124 | loose |
| Lil Yachty | SB 2021 | 61 | 57 | 427 | loose |
| Lil Yachty | SB5 | 81 | 131 | 314 | loose |
| Lil Yachty | SELF MADE | 19 | 32 | 98 | loose |
| Lil Yachty | SHIT TALKIN | 28 | 25 | 212 | loose |
| Lil Yachty | SIDE EFFExT | 72 | 94 | 260 | loose |
| Lil Yachty | SKRT | 38 | 26 | 276 | loose |
| Lil Yachty | SLIDE | 39 | 35 | 255 | loose |
| Lil Yachty | SMOKING IN THE RAIN | 19 | 28 | 69 | loose |
| Lil Yachty | SOD (Original) | 40 | 35 | 196 | loose |
| Lil Yachty | SOLO STEPPIN CRETE BOY | 44 | 48 | 287 | loose |
| Lil Yachty | STARTING 2 GEEK | 13 | 10 | 11 | loose |
| Lil Yachty | STR8 | 27 | 33 | 102 | loose |
| Lil Yachty | STUPID | 56 | 72 | 270 | loose |
| Lil Yachty | STYLISTICS | 39 | 58 | 535 | loose |
| Lil Yachty | SUMMER SUPERSTARS | 60 | 50 | 541 | loose |
| Lil Yachty | SUPERBOY | 29 | 14 | 176 | loose |
| Lil Yachty | SYDNEY | 53 | 74 | 327 | loose |
| Lil Yachty | Sad | 41 | 29 | 141 | loose |
| Lil Yachty | Safe | 31 | 33 | 81 | loose |
| Lil Yachty | Safe House | 46 | 69 | 137 | loose |
| Lil Yachty | Saibaman | 52 | 62 | 265 | loose |
| Lil Yachty | SaintLaurentYSL | 33 | 23 | 138 | loose |
| Lil Yachty | Same Problems? | 40 | 73 | 176 | loose |
| Lil Yachty | Sampha Flow | 35 | 51 | 237 | loose |
| Lil Yachty | Sandwich | 35 | 43 | 188 | loose |
| Lil Yachty | Santi | 29 | 17 | 96 | loose |
| Lil Yachty | Save The Savior | 26 | 33 | 134 | loose |
| Lil Yachty | Saving You | 36 | 42 | 95 | loose |
| Lil Yachty | Say My Name | 35 | 32 | 186 | loose |
| Lil Yachty | Say So | 25 | 22 | 43 | loose |
| Lil Yachty | Say Ya Grace | 0 | 0 | 0 | loose |
| Lil Yachty | Sbohem a šáteček | 20 | 13 | 305 | loose |
| Lil Yachty | Scratched My Rolls | 62 | 78 | 420 | loose |
| Lil Yachty | Seals (Remix) | 10 | 1 | 6 | loose |
| Lil Yachty | Seals (Reprise) [Album] | 15 | 5 | 20 | loose |
| Lil Yachty | Seals Dekline | 26 | 41 | 288 | loose |
| Lil Yachty | Search & Rescue | 37 | 21 | 142 | loose |
| Lil Yachty | Season | 33 | 54 | 160 | loose |
| Lil Yachty | See Ya Later | 12 | 12 | 36 | loose |
| Lil Yachty | Serena | 34 | 53 | 227 | loose |
| Lil Yachty | Set It Off | 37 | 49 | 101 | loose |
| Lil Yachty | Set It Off Freestyle | 76 | 89 | 535 | loose |
| Lil Yachty | Sex Mula / Pete | 74 | 107 | 524 | loose |
| Lil Yachty | Sh%t 2 Lose | 63 | 86 | 222 | loose |
| Lil Yachty | Shame | 45 | 38 | 306 | loose |
| Lil Yachty | Share It | 44 | 66 | 152 | loose |
| Lil Yachty | She All About the Shmoney (Remix) | 43 | 46 | 374 | loose |
| Lil Yachty | Shining Diamond In Daylight (Concrete Boys PT. II) | 30 | 30 | 127 | loose |
| Lil Yachty | ShipTrip | 38 | 28 | 192 | loose |
| Lil Yachty | Shit Crazy | 25 | 26 | 125 | loose |
| Lil Yachty | Shit Show | 36 | 56 | 317 | loose |
| Lil Yachty | Shoe Lace | 59 | 72 | 380 | loose |
| Lil Yachty | Shoot It Up | 23 | 11 | 126 | loose |
| Lil Yachty | Shoot Out the Roof | 34 | 21 | 257 | loose |
| Lil Yachty | Shooters With Me | 54 | 121 | 133 | loose |
| Lil Yachty | Shooters on Shooters | 21 | 17 | 169 | loose |
| Lil Yachty | Shootin Craps | 34 | 43 | 158 | loose |
| Lil Yachty | Shopping Kart | 22 | 16 | 181 | loose |
| Lil Yachty | Should I Be | 10 | 5 | 46 | loose |
| Lil Yachty | Showtime | 30 | 7 | 158 | loose |
| Lil Yachty | Shyne | 38 | 43 | 191 | loose |
| Lil Yachty | Silver Lining | 101 | 93 | 634 | loose |
| Lil Yachty | Silver Lining Boyz | 30 | 32 | 162 | loose |
| Lil Yachty | Sista Wives | 44 | 43 | 492 | loose |
| Lil Yachty | Skit | 11 | 2 | 55 | loose |
| Lil Yachty | Skraper | 43 | 60 | 98 | loose |
| Lil Yachty | Slat | 14 | 23 | 45 | AAAA |
| Lil Yachty | Slatt Talk | 36 | 45 | 119 | loose |
| Lil Yachty | Slide Music 2 | 49 | 57 | 295 | loose |
| Lil Yachty | Slime | 28 | 41 | 159 | loose |
| Lil Yachty | Slime Them | 47 | 77 | 106 | loose |
| Lil Yachty | Slob On My Knob | 21 | 30 | 102 | loose |
| Lil Yachty | Small Circle | 18 | 15 | 70 | loose |
| Lil Yachty | Snapchat | 51 | 38 | 146 | loose |
| Lil Yachty | So Many People | 24 | 10 | 83 | loose |
| Lil Yachty | Soat | 27 | 19 | 66 | loose |
| Lil Yachty | Solange Hair | 39 | 43 | 198 | loose |
| Lil Yachty | Solid | 18 | 13 | 79 | loose |
| Lil Yachty | Solitaire | 30 | 19 | 223 | loose |
| Lil Yachty | Some More | 15 | 14 | 92 | loose |
| Lil Yachty | Something Ether | 42 | 37 | 164 | loose |
| Lil Yachty | Sorry (Stop, Go) | 17 | 34 | 172 | loose |
| Lil Yachty | Sorry Not Sorry | 61 | 68 | 448 | loose |
| Lil Yachty | Sound Like Who? (Remix) | 45 | 40 | 404 | loose |
| Lil Yachty | Speed Me Up | 48 | 44 | 225 | loose |
| Lil Yachty | Speed Me Up Ultimate Mix | 50 | 64 | 240 | loose |
| Lil Yachty | Speedin! | 42 | 58 | 114 | loose |
| Lil Yachty | Split / Whole Time | 83 | 69 | 316 | loose |
| Lil Yachty | Splurge | 59 | 72 | 188 | loose |
| Lil Yachty | Spoiled Rotten* | 4 | 0 | 10 | loose |
| Lil Yachty | Sprinkle | 19 | 27 | 104 | loose |
| Lil Yachty | Stack It Up | 32 | 34 | 120 | loose |
| Lil Yachty | Stakin | 40 | 40 | 158 | loose |
| Lil Yachty | Start Over | 53 | 53 | 299 | loose |
| Lil Yachty | Start the Par-dee | 25 | 15 | 100 | loose |
| Lil Yachty | Static | 45 | 36 | 165 | loose |
| Lil Yachty | Step in My Shoes | 33 | 37 | 209 | loose |
| Lil Yachty | Sticks 2 | 62 | 93 | 171 | loose |
| Lil Yachty | Sticks In My Ricks | 21 | 20 | 111 | loose |
| Lil Yachty | Still | 32 | 75 | 175 | loose |
| Lil Yachty | Still Don’t | 21 | 13 | 117 | loose |
| Lil Yachty | Still Gon Go | 35 | 39 | 274 | loose |
| Lil Yachty | Still Here (Lost It) | 66 | 57 | 305 | loose |
| Lil Yachty | Still On 8 Mile | 59 | 52 | 428 | loose |
| Lil Yachty | Still Pull Up If I Die (On a Flight with Yeat & Yachty) | 16 | 4 | 27 | loose |
| Lil Yachty | Still ’Bout Action | 70 | 82 | 286 | loose |
| Lil Yachty | Stoner | 33 | 35 | 148 | loose |
| Lil Yachty | Stoney | 30 | 29 | 56 | loose |
| Lil Yachty | Stop Messin’ With Me Cops | 43 | 46 | 169 | loose |
| Lil Yachty | Story Time* | 16 | 8 | 56 | loose |
| Lil Yachty | Straight Clonez | 24 | 16 | 118 | loose |
| Lil Yachty | Strawberry Beads Freestyle | 39 | 35 | 109 | loose |
| Lil Yachty | Street Punk | 49 | 65 | 181 | loose |
| Lil Yachty | Strike (Holster) | 26 | 33 | 148 | loose |
| Lil Yachty | Strub Tha Ground | 50 | 23 | 119 | loose |
| Lil Yachty | Strut | 60 | 81 | 401 | loose |
| Lil Yachty | Studdering | 4 | 1 | 9 | loose |
| Lil Yachty | Stunna Shades (Mixtape Version) | 34 | 30 | 183 | loose |
| Lil Yachty | Stunt Double | 24 | 19 | 177 | loose |
| Lil Yachty | Stuntin | 20 | 10 | 129 | loose |
| Lil Yachty | Sub-Zero* | 7 | 10 | 23 | loose |
| Lil Yachty | Such Ease | 24 | 20 | 82 | loose |
| Lil Yachty | Sucka | 51 | 36 | 158 | loose |
| Lil Yachty | Sum More | 52 | 57 | 202 | loose |
| Lil Yachty | Summer ’16 | 55 | 72 | 385 | loose |
| Lil Yachty | Summer16 | 2 | 0 | 7 | loose |
| Lil Yachty | Summertime | 16 | 7 | 41 | loose |
| Lil Yachty | Surrender | 14 | 16 | 78 | loose |
| Lil Yachty | SwajjurKicks | 18 | 12 | 116 | loose |
| Lil Yachty | Sway | 51 | 28 | 136 | loose |
| Lil Yachty | Sway In The Morning Freestyle (7/20/16) | 13 | 15 | 57 | loose |
| Lil Yachty | T.D | 100 | 126 | 539 | loose |
| Lil Yachty | TALK TO ME NICE | 42 | 49 | 186 | loose |
| Lil Yachty | TERMINATOR | 59 | 73 | 188 | loose |
| Lil Yachty | TESLA | 33 | 29 | 121 | loose |
| Lil Yachty | THE EMANCIPATION | 52 | 32 | 288 | loose |
| Lil Yachty | THE zone~ | 26 | 26 | 99 | loose |
| Lil Yachty | TOKYO DRIFT | 25 | 40 | 156 | loose |
| Lil Yachty | TOO DAMN HIGH | 23 | 8 | 144 | loose |
| Lil Yachty | TOP OPTION BOYZ | 47 | 84 | 381 | loose |
| Lil Yachty | TRICERATOPS | 61 | 83 | 521 | loose |
| Lil Yachty | TUNDE | 25 | 19 | 49 | loose |
| Lil Yachty | Take Care | 27 | 34 | 136 | loose |
| Lil Yachty | Take It From Me | 25 | 28 | 98 | loose |
| Lil Yachty | Take a Hike* | 17 | 21 | 88 | loose |
| Lil Yachty | Takeover | 57 | 72 | 238 | loose |
| Lil Yachty | Talk Too Much (Remix) | 31 | 16 | 33 | loose |
| Lil Yachty | Talking Shit* | 33 | 22 | 182 | loose |
| Lil Yachty | Tasmanian Devil (He Dead) | 53 | 77 | 133 | loose |
| Lil Yachty | Tatted Asf | 28 | 39 | 120 | loose |
| Lil Yachty | Tatted on My Sleeve (On Me) | 37 | 36 | 108 | loose |
| Lil Yachty | Taylor Port Junkie | 49 | 25 | 247 | loose |
| Lil Yachty | Team Hero | 35 | 40 | 178 | loose |
| Lil Yachty | Tears* | 22 | 19 | 81 | loose |
| Lil Yachty | Teen Spirit | 22 | 12 | 107 | loose |
| Lil Yachty | Tell Me | 47 | 33 | 142 | loose |
| Lil Yachty | Ten Deep | 31 | 47 | 156 | AAAA |
| Lil Yachty | Thank God I Made It In Rap/Came From The Dirt* | 31 | 37 | 164 | loose |
| Lil Yachty | Thank You Freestyle | 48 | 41 | 239 | loose |
| Lil Yachty | That Way | 64 | 108 | 236 | loose |
| Lil Yachty | The Alchemist. | 25 | 17 | 72 | loose |
| Lil Yachty | The Birds & The Bees | 32 | 22 | 151 | loose |
| Lil Yachty | The Cave: Season 1 - Episode 9 | 29 | 28 | 156 | loose |
| Lil Yachty | The Deep End | 16 | 5 | 78 | loose |
| Lil Yachty | The Lonely Sailor* | 11 | 6 | 45 | loose |
| Lil Yachty | The Middle/The Centre | 13 | 9 | 93 | loose |
| Lil Yachty | The Paradigm | 10 | 13 | 48 | loose |
| Lil Yachty | The Race Freestyle | 30 | 41 | 198 | loose |
| Lil Yachty | The Run Around | 63 | 62 | 153 | loose |
| Lil Yachty | The Sauce | 6 | 2 | 2 | loose |
| Lil Yachty | The Scientist (Cover) | 41 | 13 | 160 | loose |
| Lil Yachty | The Secret Recipe | 62 | 129 | 611 | loose |
| Lil Yachty | The Shoe Fits | 89 | 92 | 566 | loose |
| Lil Yachty | The Way She Move | 29 | 27 | 91 | loose |
| Lil Yachty | The Wrap | 18 | 20 | 83 | loose |
| Lil Yachty | They Don’t Know (Fuck SKT) | 2 | 1 | 2 | loose |
| Lil Yachty | They Know What’s Up | 26 | 40 | 149 | loose |
| Lil Yachty | They Lookin | 38 | 44 | 74 | loose |
| Lil Yachty | Things Are Changing (Original) | 43 | 34 | 186 | loose |
| Lil Yachty | Think I’m In Love | 22 | 6 | 57 | loose |
| Lil Yachty | Thinking About Drilling | 19 | 10 | 119 | loose |
| Lil Yachty | This Bitch | 32 | 20 | 162 | loose |
| Lil Yachty | This That One | 78 | 93 | 499 | loose |
| Lil Yachty | This n That | 68 | 46 | 256 | loose |
| Lil Yachty | Thousand Islands | 48 | 77 | 277 | loose |
| Lil Yachty | Three Six Talk | 55 | 113 | 334 | loose |
| Lil Yachty | Through The Night | 21 | 13 | 93 | loose |
| Lil Yachty | Tied In | 34 | 26 | 135 | loose |
| Lil Yachty | Till the Morning | 44 | 33 | 224 | loose |
| Lil Yachty | Time Line | 32 | 15 | 94 | loose |
| Lil Yachty | Tip Toe | 52 | 69 | 220 | loose |
| Lil Yachty | Tired | 38 | 37 | 323 | loose |
| Lil Yachty | Toe Tag | 87 | 102 | 347 | loose |
| Lil Yachty | Tony! | 59 | 77 | 184 | loose |
| Lil Yachty | Took Time | 17 | 20 | 73 | loose |
| Lil Yachty | Toothache | 42 | 48 | 183 | loose |
| Lil Yachty | Top Down | 26 | 18 | 90 | loose |
| Lil Yachty | Top Floor | 23 | 18 | 103 | loose |
| Lil Yachty | Top Notch | 53 | 62 | 288 | loose |
| Lil Yachty | Torture | 68 | 71 | 137 | loose |
| Lil Yachty | Toting | 32 | 43 | 155 | loose |
| Lil Yachty | Trance | 43 | 34 | 113 | loose |
| Lil Yachty | Transport Me | 49 | 36 | 132 | loose |
| Lil Yachty | Treacherous Twins | 40 | 31 | 245 | loose |
| Lil Yachty | Treat Ya Self | 36 | 34 | 179 | loose |
| Lil Yachty | Trifling | 45 | 85 | 180 | loose |
| Lil Yachty | Trippin | 22 | 8 | 64 | loose |
| Lil Yachty | Trippin 2 Hard (R. Kelly Vibe) | 37 | 29 | 199 | loose |
| Lil Yachty | Trippy Bounce | 81 | 93 | 373 | loose |
| Lil Yachty | Truck Loads | 51 | 49 | 188 | loose |
| Lil Yachty | Trust Me | 25 | 27 | 80 | loose |
| Lil Yachty | Turnt to the Max | 54 | 46 | 214 | loose |
| Lil Yachty | Turtle Pie | 35 | 54 | 233 | loose |
| Lil Yachty | Tweaking Geekin | 20 | 21 | 99 | loose |
| Lil Yachty | Tweakin’ | 28 | 35 | 182 | loose |
| Lil Yachty | Twerkulator | 32 | 22 | 115 | loose |
| Lil Yachty | Twi$ted | 58 | 51 | 309 | loose |
| Lil Yachty | Twice | 38 | 21 | 79 | loose |
| Lil Yachty | Two Percs | 20 | 61 | 104 | AAAA |
| Lil Yachty | Two Seater | 38 | 39 | 159 | loose |
| Lil Yachty | U Can’t Tell Me | 54 | 61 | 167 | loose |
| Lil Yachty | Ugly | 20 | 3 | 125 | loose |
| Lil Yachty | Under the Sea | 47 | 66 | 93 | loose |
| Lil Yachty | Underdog | 40 | 35 | 144 | loose |
| Lil Yachty | Undertaker* | 34 | 49 | 186 | loose |
| Lil Yachty | Ungrateful | 21 | 17 | 124 | loose |
| Lil Yachty | Uno vs. Yachty Freestyle | 78 | 82 | 286 | loose |
| Lil Yachty | Untitled Lil Yachty Song | 4 | 6 | 14 | AAAA |
| Lil Yachty | Untouchable | 25 | 33 | 130 | loose |
| Lil Yachty | Up Next | 18 | 16 | 302 | loose |
| Lil Yachty | Up Next 2 | 79 | 81 | 351 | loose |
| Lil Yachty | Up Next 3 | 65 | 71 | 399 | loose |
| Lil Yachty | Up Now | 74 | 71 | 401 | loose |
| Lil Yachty | Up There Music | 27 | 33 | 113 | loose |
| Lil Yachty | Ups & Downs | 66 | 48 | 164 | loose |
| Lil Yachty | VENICE | 27 | 45 | 149 | loose |
| Lil Yachty | Valedictorian | 27 | 20 | 253 | loose |
| Lil Yachty | Van Gogh | 68 | 77 | 298 | loose |
| Lil Yachty | Verses I’m Proud Of Part 1 | 17 | 28 | 111 | loose |
| Lil Yachty | Verses I’m Proud Of Part 10 | 22 | 23 | 169 | loose |
| Lil Yachty | Verses I’m Proud Of Part 2 | 17 | 27 | 89 | loose |
| Lil Yachty | Verses I’m Proud Of Part 4 | 11 | 3 | 72 | loose |
| Lil Yachty | Verses I’m Proud Of Part 5 | 26 | 36 | 153 | loose |
| Lil Yachty | Verses I’m Proud Of Part 7 | 12 | 6 | 55 | loose |
| Lil Yachty | Verses I’m Proud Of Part 8 | 16 | 10 | 238 | loose |
| Lil Yachty | Video Vixen* | 9 | 10 | 28 | loose |
| Lil Yachty | Virginia Beach | 40 | 44 | 253 | loose |
| Lil Yachty | Virginia Creeper | 25 | 31 | 141 | loose |
| Lil Yachty | Virgo World | 26 | 26 | 136 | loose |
| Lil Yachty | Virus | 69 | 93 | 274 | loose |
| Lil Yachty | Voicemail #2 (PASSPORT) | 4 | 1 | 16 | loose |
| Lil Yachty | WE SAW THE SUN! | 22 | 22 | 68 | loose |
| Lil Yachty | WE’RE BACK | 85 | 109 | 302 | loose |
| Lil Yachty | WHAT (Remix) | 75 | 89 | 230 | loose |
| Lil Yachty | WHOLE lotta GUAP | 50 | 46 | 141 | loose |
| Lil Yachty | WIPED | 42 | 47 | 253 | loose |
| Lil Yachty | WITH YOU | 23 | 12 | 75 | loose |
| Lil Yachty | WOMBO | 41 | 47 | 207 | loose |
| Lil Yachty | WTFFF | 86 | 77 | 290 | loose |
| Lil Yachty | WTW | 62 | 83 | 287 | loose |
| Lil Yachty | WWTW | 28 | 32 | 117 | loose |
| Lil Yachty | WYD Now? (10 Minute Version) [Open Verse Mashup] | 158 | 120 | 530 | loose |
| Lil Yachty | Wake Up | 37 | 16 | 149 | loose |
| Lil Yachty | Walk In My Shoes (Original) | 38 | 45 | 125 | loose |
| Lil Yachty | Walked Down | 44 | 51 | 298 | loose |
| Lil Yachty | Walked In Ready | 39 | 33 | 115 | loose |
| Lil Yachty | Wanna Be Us | 40 | 29 | 98 | loose |
| Lil Yachty | Want Me | 34 | 65 | 151 | loose |
| Lil Yachty | Wanted More | 20 | 16 | 55 | loose |
| Lil Yachty | War Ready | 24 | 18 | 159 | loose |
| Lil Yachty | Warriors | 30 | 32 | 150 | loose |
| Lil Yachty | Washed Away | 23 | 16 | 68 | loose |
| Lil Yachty | Wat U Mean (Remix) | 58 | 36 | 162 | loose |
| Lil Yachty | Watch Me | 46 | 55 | 184 | loose |
| Lil Yachty | Water On The Window Freestyle | 54 | 54 | 300 | loose |
| Lil Yachty | Water on My Face | 35 | 25 | 128 | loose |
| Lil Yachty | Wavy Crete | 44 | 57 | 577 | loose |
| Lil Yachty | Way Back* | 10 | 11 | 42 | loose |
| Lil Yachty | Way More Fun | 22 | 13 | 167 | loose |
| Lil Yachty | We Ball Forever | 34 | 20 | 286 | loose |
| Lil Yachty | We Did It | 33 | 17 | 45 | loose |
| Lil Yachty | We Do Not Party | 21 | 9 | 58 | loose |
| Lil Yachty | We Goin’ Up | 34 | 31 | 108 | loose |
| Lil Yachty | We Gon’ Roll With Yachty | 0 | 0 | 0 | loose |
| Lil Yachty | We Got It | 55 | 33 | 246 | loose |
| Lil Yachty | We Next | 43 | 36 | 136 | loose |
| Lil Yachty | We Outta Here! | 69 | 78 | 199 | loose |
| Lil Yachty | Weak Hearted Won’t Last | 48 | 53 | 170 | loose |
| Lil Yachty | Westside | 46 | 71 | 221 | loose |
| Lil Yachty | Wet Like a Boat | 76 | 135 | 286 | loose |
| Lil Yachty | What About The Word | 21 | 16 | 30 | loose |
| Lil Yachty | What Would Pluto Do | 50 | 68 | 185 | loose |
| Lil Yachty | What’s My Name | 44 | 37 | 132 | loose |
| Lil Yachty | When I Get On | 16 | 2 | 172 | loose |
| Lil Yachty | When We Die (Can We Still Get High?) | 18 | 11 | 109 | loose |
| Lil Yachty | When You Want It (Need It)* | 4 | 0 | 18 | loose |
| Lil Yachty | Where Did I Go Wrong | 15 | 11 | 59 | loose |
| Lil Yachty | Where Do We Go | 22 | 25 | 48 | loose |
| Lil Yachty | Whew’ Chile | 37 | 41 | 189 | loose |
| Lil Yachty | Whip It Up | 16 | 17 | 46 | loose |
| Lil Yachty | Whippin | 35 | 52 | 109 | loose |
| Lil Yachty | White Flaggin’ | 27 | 32 | 168 | loose |
| Lil Yachty | White Tee Freestyle (Phil Jackson) | 41 | 36 | 203 | loose |
| Lil Yachty | Who Run It (Remix) | 104 | 141 | 424 | loose |
| Lil Yachty | Who Want the Smoke? | 61 | 71 | 262 | loose |
| Lil Yachty | Who? | 63 | 74 | 329 | loose |
| Lil Yachty | Whole Lotta | 103 | 112 | 346 | loose |
| Lil Yachty | Why? (Interlude) | 11 | 5 | 10 | loose |
| Lil Yachty | Wick Man | 43 | 84 | 310 | loose |
| Lil Yachty | Wintertime On A Boat | 41 | 45 | 170 | loose |
| Lil Yachty | Wit It | 57 | 79 | 358 | loose |
| Lil Yachty | With Me | 37 | 64 | 244 | loose |
| Lil Yachty | With My Team (Remix) | 67 | 54 | 163 | loose |
| Lil Yachty | With the Shits | 30 | 27 | 129 | loose |
| Lil Yachty | Wizard Of Oz | 27 | 35 | 148 | loose |
| Lil Yachty | Wock in Stock | 28 | 32 | 192 | loose |
| Lil Yachty | Wocky My Lover | 67 | 82 | 468 | loose |
| Lil Yachty | Won’t Diss You | 55 | 80 | 127 | loose |
| Lil Yachty | Woo | 31 | 42 | 125 | loose |
| Lil Yachty | Wop (Remix) | 40 | 37 | 214 | loose |
| Lil Yachty | Worry No More | 37 | 19 | 105 | loose |
| Lil Yachty | Worth It | 31 | 15 | 97 | loose |
| Lil Yachty | Wrist Thunderstorm | 61 | 103 | 197 | loose |
| Lil Yachty | Wrist Work | 25 | 19 | 137 | loose |
| Lil Yachty | Wu Tang | 17 | 15 | 30 | loose |
| Lil Yachty | X FCKED IT UP FOR THE BIRKINS | 46 | 57 | 235 | loose |
| Lil Yachty | X Men | 56 | 63 | 169 | loose |
| Lil Yachty | XXL Freshman Freestyle: Lil Yachty | 12 | 5 | 88 | loose |
| Lil Yachty | XXL Freshmen 2016 Cypher - Part 2 | 83 | 82 | 291 | loose |
| Lil Yachty | YAE ENERGY | 36 | 18 | 208 | loose |
| Lil Yachty | YELLOW | 22 | 32 | 130 | loose |
| Lil Yachty | YES | 50 | 31 | 225 | loose |
| Lil Yachty | YNGTC | 65 | 39 | 313 | loose |
| Lil Yachty | Yacht Club | 45 | 66 | 276 | loose |
| Lil Yachty | Yah Yah | 4 | 0 | 35 | loose |
| Lil Yachty | Yea | 29 | 21 | 105 | loose |
| Lil Yachty | Yeah Yeah | 45 | 44 | 107 | loose |
| Lil Yachty | Yeah Yeah Yeah* | 5 | 1 | 24 | loose |
| Lil Yachty | Yes Indeed (Remix)* | 8 | 6 | 22 | loose |
| Lil Yachty | Yo Bad | 36 | 40 | 127 | loose |
| Lil Yachty | Yoshimitsu | 30 | 60 | 205 | loose |
| Lil Yachty | You Ain’t Smokin’ | 33 | 40 | 253 | loose |
| Lil Yachty | You Can’t | 25 | 19 | 60 | loose |
| Lil Yachty | You Gon See | 22 | 7 | 75 | loose |
| Lil Yachty | You Hate | 65 | 44 | 301 | loose |
| Lil Yachty | You Make It Easy | 17 | 11 | 58 | loose |
| Lil Yachty | You Not Gang (Remix) | 54 | 39 | 129 | loose |
| Lil Yachty | You Played Me | 21 | 15 | 74 | loose |
| Lil Yachty | Young & Invincible | 20 | 31 | 66 | loose |
| Lil Yachty | Young Dumb & Broke (Remix) | 47 | 30 | 150 | loose |
| Lil Yachty | Young Nigga | 77 | 73 | 312 | loose |
| Lil Yachty | Young Nigga Theme Song | 27 | 39 | 88 | loose |
| Lil Yachty | ZIAS Hit Bout It Reaction Freestyle | 56 | 86 | 146 | loose |
| Lil Yachty | Zion | 55 | 57 | 227 | loose |
| Lil Yachty | Zobamambafoo | 67 | 103 | 330 | loose |
| Lil Yachty | Zooted Up | 27 | 44 | 88 | loose |
| Lil Yachty | beans | 32 | 36 | 77 | loose |
| Lil Yachty | clap for him | 39 | 50 | 230 | loose |
| Lil Yachty | drive ME crazy! | 31 | 17 | 271 | loose |
| Lil Yachty | feel it in the air | 33 | 29 | 157 | loose |
| Lil Yachty | flex fm (freddit) | 4 | 0 | 10 | loose |
| Lil Yachty | hector’s luh remixes | 42 | 33 | 222 | loose |
| Lil Yachty | high3r | 53 | 75 | 230 | loose |
| Lil Yachty | i need meds | 45 | 48 | 235 | loose |
| Lil Yachty | iRun | 37 | 32 | 136 | loose |
| Lil Yachty | iSpy | 60 | 64 | 358 | loose |
| Lil Yachty | love me forever | 15 | 9 | 46 | loose |
| Lil Yachty | pRETTy | 23 | 13 | 109 | loose |
| Lil Yachty | paint THE sky | 17 | 10 | 44 | loose |
| Lil Yachty | problem (radio edit) | 58 | 18 | 355 | loose |
| Lil Yachty | running out of time | 20 | 6 | 56 | loose |
| Lil Yachty | sAy sOMETHINg | 32 | 16 | 133 | loose |
| Lil Yachty | sHouLd i B? | 23 | 11 | 91 | loose |
| Lil Yachty | scared | 15 | 13 | 64 | loose |
| Lil Yachty | she ready | 37 | 27 | 202 | loose |
| Lil Yachty | stayinit | 9 | 4 | 27 | loose |
| Lil Yachty | stuck | 23 | 37 | 74 | loose |
| Lil Yachty | tOlD mE | 63 | 99 | 329 | loose |
| Lil Yachty | the BLACK seminole. | 17 | 9 | 71 | loose |
| Lil Yachty | the ride- | 20 | 33 | 91 | loose |
| Lil Yachty | who knew | 24 | 9 | 150 | loose |
| Lil Yachty | “Get In Wit Me” Freestyle | 74 | 79 | 717 | loose |
