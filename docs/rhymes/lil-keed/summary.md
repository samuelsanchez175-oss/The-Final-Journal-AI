# Lil Keed rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Keed
- Songs: 478
- Bars kept (Lil Keed lyric lines): 19122
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 26
- Canonical name: Lil Keed.
- Credit strings: Lil Keed.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 105035
- REPEAT pairs, recorded separately: 12650
- END rhymes: 19263
- INNER rhymes: 85772

By match:

- PERFECT: 8563 (END 2457, INNER 6106)
- SLANT: 45360 (END 8015, INNER 37345)
- ASSONANCE: 50231 (END 8490, INNER 41741)
- MULTI: 881 (END 301, INNER 580)

By confidence:

- HIGH: 8632
- MED: 89294
- LOW: 7109

## Core

- Core Y: 103128
- Core N among rhyme pairs: 1907

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 47871 (45.6%)
- vowel: 50231 (47.8%)
- spelling: 6052 (5.8%)
- multi: 881 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- loose: 477 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 8430 pairs (END 1044, INNER 7386). Words: don't, know, no, go, told, ho, hoes, whole.
2. `vow:IH` — 7271 pairs (END 1098, INNER 6173). Words: bitch, shit, bitches, lil, think, big, wrist, hit.
3. `vow:EY` — 5722 pairs (END 1148, INNER 4574). Words: ain't, say, play, way, make, day, baby, came.
4. `vow:EH` — 5011 pairs (END 683, INNER 4328). Words: get, gettin, when, never, went, left, bentley, tell.
5. `vow:AE` — 4989 pairs (END 874, INNER 4115). Words: can't, racks, back, bands, had, can, bad, man.
6. `vow:AA` — 4678 pairs (END 585, INNER 4093). Words: got, want, talkin, nothin, not, wanna, top, hard.
7. `vow:AY` — 4156 pairs (END 771, INNER 3385). Words: like, diamonds, why, high, by, time, try, fire.
8. `vow:AH` — 3574 pairs (END 598, INNER 2976). Words: some, fuck, hundred, fuckin, money, what, come, love.
9. `vow:IY` — 3504 pairs (END 835, INNER 2669). Words: see, these, even, need, real, keep, streets, g.
10. `slant:AA:stop` — 2918 pairs (END 298, INNER 2620). Words: got, block, not, gotta, top, want, glock, drop.
11. `slant:IH:stop` — 2664 pairs (END 238, INNER 2426). Words: nigga, shit, big, hit, drip, dick, stick, wrist.
12. `slant:IH:sib-stop` — 1888 pairs (END 343, INNER 1545). Words: bitch, shit, nigga, niggas, rich, hit, big, dick.
13. `cmu:OW` — 1549 pairs (END 126, INNER 1423). Words: know, no, go, ho, show, hoe, blow, throw.
14. `slant:AE:stop` — 1199 pairs (END 261, INNER 938). Words: back, had, can't, bad, bag, cap, slatt, trap.
15. `slant:AH:nas-stop` — 1189 pairs (END 63, INNER 1126). Words: fuck, some, what, money, come, one, young, truck.
16. `slant:EH:stop` — 1185 pairs (END 149, INNER 1036). Words: get, head, better, check, went, said, let, red.
17. `slant:IH:liq-stop` — 1100 pairs (END 49, INNER 1051). Words: lil, shit, hit, still, drip, big, really, kill.
18. `slant:IH:nas-stop` — 1061 pairs (END 78, INNER 983). Words: shit, him, i'ma, hit, big, drip, thing, bring.
19. `vow:UW` — 948 pairs (END 370, INNER 578). Words: new, two, through, who, blue, coupe, shooters, shoot.
20. `slant:AY:stop` — 933 pairs (END 101, INNER 832). Words: like, ride, right, white, side, vibe, might, night.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 1425 pair sides, mostly spelling via spelling phonetic key, often with shit (305)
- gon — 545 pair sides, mostly spelling via spelling phonetic key, often with dont (138)
- niggas — 462 pair sides, mostly spelling via spelling phonetic key, often with nigga (249)
- ima — 443 pair sides, mostly spelling via spelling phonetic key, often with bitch (60)
- tryna — 397 pair sides, mostly spelling via spelling phonetic key, often with these (83)
- keed — 190 pair sides, mostly spelling via spelling phonetic key, often with these (18)
- slatt — 127 pair sides, mostly spelling via spelling phonetic key, often with back (16)
- shawty — 114 pair sides, mostly vowel via spelling phonetic key, often with all (14)
- thot — 107 pair sides, mostly spelling via spelling phonetic key, often with know (19)
- dawg — 81 pair sides, mostly spelling via spelling phonetic key, often with all (9)
- bros — 71 pair sides, mostly spelling via spelling phonetic key, often with know (12)
- wraith — 66 pair sides, mostly spelling via spelling phonetic key, often with face (7)
- geeked — 59 pair sides, mostly spelling via spelling phonetic key, often with these (7)
- blicky — 55 pair sides, mostly spelling via spelling phonetic key, often with shit (5)
- gotit — 52 pair sides, mostly spelling via spelling phonetic key, often with dont (15)
- xans — 43 pair sides, mostly spelling via spelling phonetic key, often with man (7)
- brazy — 43 pair sides, mostly vowel via spelling phonetic key, often with crazy (5)
- glocks — 42 pair sides, mostly vowel via spelling phonetic key, often with know (16)
- slimes — 41 pair sides, mostly spelling via spelling phonetic key, often with sticks (5)
- lyin — 41 pair sides, mostly spelling via spelling phonetic key, often with these (8)
- opps — 40 pair sides, mostly vowel via spelling phonetic key, often with know (10)
- homie — 38 pair sides, mostly spelling via spelling phonetic key, often with gon (6)
- stickbaby — 38 pair sides, mostly vowel via spelling phonetic key, often with nigga (11)
- dyin — 37 pair sides, mostly spelling via spelling phonetic key, often with lyin (7)
- slatty — 36 pair sides, mostly vowel via spelling phonetic key, often with slatt (5)
- sono — 33 pair sides, mostly vowel via spelling phonetic key, often with io (5)
- swag — 31 pair sides, mostly spelling via spelling phonetic key, often with back (4)
- jag — 30 pair sides, mostly spelling via spelling phonetic key, often with ass (4)
- ysl — 30 pair sides, mostly spelling via spelling phonetic key, often with real (16)
- henny — 28 pair sides, mostly vowel via spelling phonetic key, often with money (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Keed | 27 | 37 | 25 | 160 | loose |
| Lil Keed | 360 | 36 | 46 | 190 | loose |
| Lil Keed | 5 Star Residence | 29 | 41 | 186 | loose |
| Lil Keed | 6 Figures | 49 | 60 | 205 | loose |
| Lil Keed | 75-85 North | 41 | 34 | 169 | loose |
| Lil Keed | <img src="https://images.genius.com/0f77deb60bdc3874bf04bd98372db57a.300x300x1.jpg" alt="Fetish (Remix)" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Fetish (Remix)Lil Keed53.5K | 47 | 56 | 255 | loose |
| Lil Keed | <img src="https://images.genius.com/29d1176d5b0c5fe4a49489ee2cfeee42.300x300x1.png" alt="Brotherly Love" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Brotherly LoveLil Gotit91.7K | 47 | 75 | 249 | loose |
| Lil Keed | <img src="https://images.genius.com/33c52a00b694afff704c64a80dad42c2.300x300x1.png" alt="Big Tipper" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Big TipperYoung Thug133.1K | 58 | 30 | 426 | loose |
| Lil Keed | <img src="https://images.genius.com/493dfbd6ef1ba8693e12cc35a15ec004.300x300x1.png" alt="Heavy Metal" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Heavy MetalLil Uzi Vert137.5K | 68 | 70 | 430 | loose |
| Lil Keed | <img src="https://images.genius.com/4edfd3dc0dc69a467c68ebd239be7456.300x300x1.jpg" alt="Anybody" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>AnybodyLil Keed88.9K | 29 | 16 | 136 | loose |
| Lil Keed | <img src="https://images.genius.com/4edfd3dc0dc69a467c68ebd239be7456.300x300x1.jpg" alt="HBS" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>HBSLil Keed145.4K | 19 | 21 | 50 | loose |
| Lil Keed | <img src="https://images.genius.com/4edfd3dc0dc69a467c68ebd239be7456.300x300x1.jpg" alt="Million Dollar Mansion" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Million Dollar MansionLil Keed67.8K | 3 | 1 | 16 | loose |
| Lil Keed | <img src="https://images.genius.com/4edfd3dc0dc69a467c68ebd239be7456.300x300x1.jpg" alt="Snake" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>SnakeLil Keed115.9K | 16 | 23 | 86 | loose |
| Lil Keed | <img src="https://images.genius.com/75b3937c54481910f5b054cd75ef1a41.300x300x1.png" alt="Nameless" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>NamelessLil Keed304.3K | 43 | 36 | 144 | loose |
| Lil Keed | <img src="https://images.genius.com/91701e29093f86208261170dadc9940c.300x300x1.png" alt="She Know" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>She KnowLil Keed49.9K | 10 | 5 | 25 | loose |
| Lil Keed | <img src="https://images.genius.com/91701e29093f86208261170dadc9940c.300x300x1.png" alt="Wavy (Remix)" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Wavy (Remix)Lil Keed51.8K | 46 | 66 | 284 | loose |
| Lil Keed | <img src="https://images.genius.com/9ce08a70d411ef0ef379f51072ef8d39.300x300x1.png" alt="Fetish" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>FetishLil Keed48K | 2 | 0 | 3 | loose |
| Lil Keed | <img src="https://images.genius.com/9ce08a70d411ef0ef379f51072ef8d39.300x300x1.png" alt="Freak" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>FreakLil Keed107.9K | 38 | 30 | 146 | loose |
| Lil Keed | <img src="https://images.genius.com/abe9654778890d11ec0db9dbfa616588.300x300x1.jpg" alt="Oh My God" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Oh My GodLil Keed77.4K | 44 | 44 | 135 | loose |
| Lil Keed | <img src="https://images.genius.com/b0d14fb12623486bf07c8120e5c6e3ab.300x300x1.png" alt="Bookoo Bucks" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Bookoo BucksNasty C, Lil Gotit & Lil Keed39.4K | 57 | 77 | 211 | loose |
| Lil Keed | <img src="https://images.genius.com/c14f619c07983edecc026ea41c632262.300x300x1.png" alt="Pull Up" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Pull UpLil Keed88K | 39 | 73 | 147 | loose |
| Lil Keed | <img src="https://images.genius.com/e4487f7633b63b193525a2c9d304020f.300x300x1.png" alt="It’s Up Freestyle" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>It’s Up FreestyleLil Keed130.3K | 54 | 29 | 272 | loose |
| Lil Keed | <img src="https://images.genius.com/e936a9d7e2f127b7ca105467cb400cbb.300x300x1.png" alt="XXL Freshmen 2020 Cypher - Part 1" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>XXL Freshmen 2020 Cypher - Part 1XXL38.8K | 60 | 58 | 293 | loose |
| Lil Keed | A-Team (You Ain’t Safe) | 42 | 55 | 277 | loose |
| Lil Keed | Abandoned | 32 | 27 | 154 | loose |
| Lil Keed | Abundance | 36 | 53 | 158 | loose |
| Lil Keed | Accomplishments | 60 | 59 | 287 | loose |
| Lil Keed | Add a Lil Drip | 23 | 17 | 102 | loose |
| Lil Keed | Ah-Choo | 42 | 29 | 128 | loose |
| Lil Keed | Ain’t Mad At You | 28 | 23 | 180 | loose |
| Lil Keed | Ain’t Seen My Face | 54 | 115 | 189 | loose |
| Lil Keed | All By My Lonely | 62 | 92 | 272 | loose |
| Lil Keed | All Day | 45 | 61 | 296 | loose |
| Lil Keed | All Eyes | 41 | 23 | 195 | loose |
| Lil Keed | All I Wanna Know | 57 | 34 | 226 | loose |
| Lil Keed | All In | 32 | 30 | 99 | loose |
| Lil Keed | All Pockets | 30 | 11 | 153 | loose |
| Lil Keed | All Times | 28 | 30 | 143 | loose |
| Lil Keed | Amber Rolls | 45 | 40 | 216 | loose |
| Lil Keed | BMP | 41 | 47 | 128 | loose |
| Lil Keed | BUSY | 61 | 74 | 175 | loose |
| Lil Keed | Baby Boy | 35 | 24 | 192 | loose |
| Lil Keed | Back Board | 56 | 72 | 233 | loose |
| Lil Keed | Back Breaker (Break Ha Back) | 44 | 27 | 139 | loose |
| Lil Keed | Back of the Royce | 27 | 31 | 108 | loose |
| Lil Keed | Backends | 40 | 38 | 240 | loose |
| Lil Keed | Bag | 57 | 105 | 140 | loose |
| Lil Keed | Bags To The Sky | 36 | 33 | 245 | loose |
| Lil Keed | Bait Em In | 29 | 15 | 139 | loose |
| Lil Keed | Balenciaga | 49 | 35 | 213 | loose |
| Lil Keed | Balenciaga Boots | 28 | 21 | 120 | loose |
| Lil Keed | Bandage | 26 | 43 | 121 | loose |
| Lil Keed | Bangin N Hangin | 21 | 31 | 139 | loose |
| Lil Keed | Bankroll | 45 | 60 | 263 | loose |
| Lil Keed | Be Slime | 45 | 69 | 156 | loose |
| Lil Keed | Be Your Man | 32 | 29 | 150 | loose |
| Lil Keed | Because of Me | 61 | 43 | 258 | loose |
| Lil Keed | Belaire | 31 | 21 | 88 | loose |
| Lil Keed | Best Thot | 36 | 19 | 191 | loose |
| Lil Keed | Betty Boop | 44 | 37 | 268 | loose |
| Lil Keed | Big Bag | 55 | 42 | 280 | loose |
| Lil Keed | Big B’s | 66 | 52 | 210 | loose |
| Lil Keed | Big Dog* | 7 | 1 | 46 | loose |
| Lil Keed | Big Eye | 32 | 22 | 90 | loose |
| Lil Keed | Big Like Hummer | 27 | 8 | 68 | loose |
| Lil Keed | Big Order | 56 | 47 | 296 | loose |
| Lil Keed | Birthed Me | 26 | 23 | 96 | loose |
| Lil Keed | Blackout | 53 | 58 | 191 | loose |
| Lil Keed | Blicks That | 51 | 77 | 226 | loose |
| Lil Keed | Blicky Blicky | 47 | 61 | 64 | loose |
| Lil Keed | Blind Can’t Lead the Blind | 26 | 26 | 127 | loose |
| Lil Keed | Block Life | 39 | 52 | 177 | loose |
| Lil Keed | Blood Diamonds | 59 | 45 | 203 | loose |
| Lil Keed | Bloodline | 13 | 27 | 91 | loose |
| Lil Keed | Blue Slimes | 91 | 124 | 369 | loose |
| Lil Keed | Blue Strips | 29 | 42 | 200 | loose |
| Lil Keed | Bobble Head | 36 | 34 | 168 | loose |
| Lil Keed | Bonker | 46 | 29 | 245 | loose |
| Lil Keed | Bossman | 35 | 11 | 195 | loose |
| Lil Keed | Break Down | 56 | 65 | 205 | loose |
| Lil Keed | Bring My Slut | 39 | 23 | 129 | loose |
| Lil Keed | Broad Day | 37 | 34 | 138 | loose |
| Lil Keed | Burnt | 11 | 2 | 15 | loose |
| Lil Keed | Bury My Pain | 36 | 54 | 210 | loose |
| Lil Keed | Came From Nothing | 40 | 15 | 261 | loose |
| Lil Keed | Came Out | 40 | 55 | 172 | loose |
| Lil Keed | Cameo | 37 | 31 | 183 | loose |
| Lil Keed | Can He Breathe | 37 | 18 | 195 | loose |
| Lil Keed | Can’t Dress Me | 38 | 56 | 417 | loose |
| Lil Keed | Can’t Fall Victim | 40 | 37 | 185 | loose |
| Lil Keed | Can’t Give Up | 38 | 34 | 98 | loose |
| Lil Keed | Can’t Trust You | 34 | 25 | 148 | loose |
| Lil Keed | Cap Zone | 53 | 42 | 246 | loose |
| Lil Keed | Cash Brothers | 47 | 82 | 187 | loose |
| Lil Keed | Cash Out | 55 | 44 | 206 | loose |
| Lil Keed | Cat Got His Tongue | 49 | 47 | 282 | loose |
| Lil Keed | Catch a Sin | 47 | 43 | 125 | loose |
| Lil Keed | Champion | 36 | 33 | 78 | loose |
| Lil Keed | Chancing (Keep It 100) | 46 | 27 | 171 | loose |
| Lil Keed | Cheesecake | 49 | 35 | 215 | loose |
| Lil Keed | Child | 42 | 57 | 183 | loose |
| Lil Keed | Children | 17 | 21 | 64 | loose |
| Lil Keed | Chopstick | 31 | 33 | 110 | loose |
| Lil Keed | Churches Peppers | 58 | 87 | 210 | loose |
| Lil Keed | Clean the Block | 43 | 32 | 157 | loose |
| Lil Keed | Clear | 38 | 28 | 181 | loose |
| Lil Keed | Closer Than Ever | 28 | 28 | 155 | loose |
| Lil Keed | Coco Crazy (Proof) | 37 | 41 | 340 | loose |
| Lil Keed | Cocoon | 53 | 38 | 121 | loose |
| Lil Keed | Cold World | 34 | 41 | 142 | loose |
| Lil Keed | Come Wit It | 43 | 30 | 115 | loose |
| Lil Keed | Control The Streets | 20 | 10 | 114 | loose |
| Lil Keed | Conversations | 76 | 92 | 215 | loose |
| Lil Keed | Costly | 48 | 30 | 186 | loose |
| Lil Keed | Couldn’t Make It | 32 | 14 | 107 | loose |
| Lil Keed | Count My Blessings | 36 | 37 | 185 | loose |
| Lil Keed | Crook | 38 | 51 | 132 | loose |
| Lil Keed | Crows (Unreleased) | 66 | 41 | 136 | loose |
| Lil Keed | Crunch Time | 45 | 52 | 148 | loose |
| Lil Keed | Currency Chaser | 30 | 35 | 243 | loose |
| Lil Keed | Curry 30 | 12 | 9 | 20 | loose |
| Lil Keed | Cuttin | 43 | 34 | 247 | loose |
| Lil Keed | Dead Doc | 49 | 42 | 253 | loose |
| Lil Keed | Dead On The Spot | 37 | 26 | 150 | loose |
| Lil Keed | Dead Wrong | 46 | 21 | 123 | loose |
| Lil Keed | Definitely | 40 | 34 | 192 | loose |
| Lil Keed | Designer Talk | 60 | 76 | 185 | loose |
| Lil Keed | Diamond Dancing | 33 | 32 | 296 | loose |
| Lil Keed | Diamond Face | 40 | 50 | 182 | loose |
| Lil Keed | Diamonds | 42 | 30 | 218 | loose |
| Lil Keed | Dirty Dancer | 47 | 61 | 163 | loose |
| Lil Keed | Dive Deep | 39 | 26 | 119 | loose |
| Lil Keed | Django (Hustle n Flow) | 37 | 28 | 118 | loose |
| Lil Keed | Do One | 42 | 52 | 155 | loose |
| Lil Keed | Dodgin’ and Runnin’ | 27 | 27 | 185 | loose |
| Lil Keed | Doggy Ish | 35 | 51 | 175 | loose |
| Lil Keed | Dollar Signs | 46 | 39 | 135 | loose |
| Lil Keed | Don’t Do No Playing | 33 | 30 | 143 | loose |
| Lil Keed | Don’t He | 37 | 15 | 129 | loose |
| Lil Keed | Don’t Stop | 29 | 30 | 137 | loose |
| Lil Keed | Don’t Want Nun’ | 34 | 26 | 198 | loose |
| Lil Keed | Dragon | 45 | 35 | 195 | loose |
| Lil Keed | Drip Babies | 63 | 82 | 229 | loose |
| Lil Keed | Drip Day N Night | 52 | 63 | 295 | loose |
| Lil Keed | Drip On Yo’ | 46 | 40 | 193 | loose |
| Lil Keed | Dripped In Bathing Ape | 39 | 53 | 99 | loose |
| Lil Keed | Drippin’ On ’Em | 25 | 20 | 110 | loose |
| Lil Keed | Drop the Top | 39 | 46 | 169 | loose |
| Lil Keed | Droppin’ No Dime | 50 | 25 | 130 | loose |
| Lil Keed | Drown | 51 | 82 | 221 | loose |
| Lil Keed | Drown a Fish | 29 | 64 | 138 | AAAA |
| Lil Keed | Dummy | 12 | 15 | 65 | loose |
| Lil Keed | Duse N Juice | 30 | 24 | 122 | loose |
| Lil Keed | Early* | 15 | 7 | 39 | loose |
| Lil Keed | Eat Dat Up | 25 | 17 | 61 | loose |
| Lil Keed | Emotional | 29 | 30 | 174 | loose |
| Lil Keed | Enemies | 6 | 10 | 12 | loose |
| Lil Keed | Exactly | 17 | 15 | 89 | loose |
| Lil Keed | Excite You | 44 | 52 | 143 | loose |
| Lil Keed | Exit | 44 | 66 | 236 | loose |
| Lil Keed | FOP (Fresh Out Pandemic) | 44 | 38 | 294 | loose |
| Lil Keed | Faithfully | 52 | 39 | 158 | loose |
| Lil Keed | Fear of God | 48 | 36 | 178 | loose |
| Lil Keed | Feel My Shine | 45 | 55 | 164 | loose |
| Lil Keed | Feelings Changed | 33 | 18 | 119 | loose |
| Lil Keed | Fierce | 57 | 77 | 258 | loose |
| Lil Keed | Fillin’ His Shoes (Best Life) | 24 | 28 | 136 | loose |
| Lil Keed | First Born | 48 | 27 | 313 | loose |
| Lil Keed | Flashy | 25 | 28 | 191 | loose |
| Lil Keed | Flip The Switch | 22 | 43 | 130 | loose |
| Lil Keed | Flossin On Niggas | 29 | 35 | 176 | loose |
| Lil Keed | Follow the Leader | 58 | 63 | 218 | loose |
| Lil Keed | For the Racks | 51 | 58 | 199 | loose |
| Lil Keed | Foreign Sheets | 56 | 52 | 271 | loose |
| Lil Keed | Forrest Gump | 40 | 31 | 170 | loose |
| Lil Keed | Forse sbaglio* | 45 | 22 | 532 | loose |
| Lil Keed | Fox 5 | 44 | 39 | 269 | loose |
| Lil Keed | Freestyle (Waterslide) | 71 | 77 | 236 | loose |
| Lil Keed | Friday High | 51 | 34 | 226 | loose |
| Lil Keed | Friend Zone | 52 | 43 | 218 | loose |
| Lil Keed | From the Heart | 33 | 52 | 136 | loose |
| Lil Keed | Fuck All That | 45 | 57 | 222 | loose |
| Lil Keed | Fuck the Pigs | 28 | 38 | 153 | loose |
| Lil Keed | Funeral Gang | 38 | 34 | 163 | loose |
| Lil Keed | G5 | 51 | 51 | 220 | loose |
| Lil Keed | GTA 2 | 41 | 26 | 176 | loose |
| Lil Keed | Game Time | 26 | 17 | 98 | loose |
| Lil Keed | Gang Shit | 51 | 42 | 137 | loose |
| Lil Keed | Gang Shit, No Lame Shit | 22 | 9 | 112 | loose |
| Lil Keed | Get Money | 39 | 38 | 171 | loose |
| Lil Keed | Get N Dere Gang | 53 | 49 | 216 | loose |
| Lil Keed | Give Em Hell | 34 | 32 | 270 | loose |
| Lil Keed | Go Brazy | 36 | 70 | 187 | loose |
| Lil Keed | Go See | 25 | 19 | 162 | loose |
| Lil Keed | Go Up | 36 | 33 | 156 | loose |
| Lil Keed | Goat | 18 | 7 | 69 | loose |
| Lil Keed | Goin Up | 57 | 31 | 140 | loose |
| Lil Keed | Going Crazy | 24 | 50 | 164 | loose |
| Lil Keed | Gone Feel Me | 40 | 36 | 131 | loose |
| Lil Keed | Good Luck | 35 | 18 | 195 | loose |
| Lil Keed | Gotta Get Touched | 56 | 32 | 234 | loose |
| Lil Keed | Grandparents | 46 | 45 | 322 | loose |
| Lil Keed | Groceries | 41 | 65 | 145 | loose |
| Lil Keed | Gucci Steppin | 23 | 17 | 116 | loose |
| Lil Keed | Gun Sounds | 64 | 49 | 190 | loose |
| Lil Keed | Gunna | 45 | 41 | 112 | loose |
| Lil Keed | Gutta Bitch | 21 | 7 | 92 | loose |
| Lil Keed | HEY! | 38 | 29 | 251 | loose |
| Lil Keed | Handle That Business | 38 | 23 | 182 | loose |
| Lil Keed | Handy | 50 | 76 | 185 | loose |
| Lil Keed | Harry Potter | 27 | 10 | 126 | loose |
| Lil Keed | Hate On | 24 | 20 | 71 | loose |
| Lil Keed | Heartbreaker | 17 | 15 | 50 | loose |
| Lil Keed | Helicopters (Original) | 49 | 40 | 207 | loose |
| Lil Keed | Hell Yeah | 32 | 37 | 150 | loose |
| Lil Keed | Here | 44 | 32 | 100 | loose |
| Lil Keed | Hey Hey | 51 | 43 | 140 | loose |
| Lil Keed | Hibachi | 29 | 17 | 138 | loose |
| Lil Keed | High End | 42 | 57 | 197 | loose |
| Lil Keed | High Horse | 91 | 85 | 171 | loose |
| Lil Keed | Higher N Higher | 45 | 62 | 180 | loose |
| Lil Keed | Hightop Shoes | 35 | 35 | 192 | loose |
| Lil Keed | Hitman | 45 | 83 | 228 | loose |
| Lil Keed | Hocus Pocus | 61 | 72 | 395 | loose |
| Lil Keed | Hoe Taker | 37 | 41 | 119 | loose |
| Lil Keed | Hold On Pause | 36 | 36 | 185 | loose |
| Lil Keed | Homicide | 41 | 45 | 167 | loose |
| Lil Keed | Honolulu | 34 | 16 | 139 | loose |
| Lil Keed | HoodBaby Language | 42 | 34 | 103 | loose |
| Lil Keed | Hoodmama | 29 | 19 | 93 | loose |
| Lil Keed | Hot for Me | 45 | 37 | 190 | loose |
| Lil Keed | Hottest | 51 | 29 | 288 | loose |
| Lil Keed | How Bout U | 40 | 60 | 169 | loose |
| Lil Keed | How Many | 47 | 48 | 164 | loose |
| Lil Keed | How You Do That | 43 | 26 | 126 | loose |
| Lil Keed | How many times (UNRELEASED) | 46 | 35 | 187 | loose |
| Lil Keed | Hunnid Bandz | 41 | 52 | 304 | loose |
| Lil Keed | Hush Mouth | 37 | 49 | 256 | loose |
| Lil Keed | I Am Sorry (432 Hz) | 36 | 24 | 140 | loose |
| Lil Keed | I Do The Most | 23 | 23 | 75 | loose |
| Lil Keed | I Got | 41 | 49 | 98 | loose |
| Lil Keed | I Got Love | 36 | 51 | 165 | loose |
| Lil Keed | I Put A | 45 | 48 | 211 | loose |
| Lil Keed | I Want More | 29 | 33 | 91 | loose |
| Lil Keed | I Want To Ball (Tears) | 71 | 67 | 128 | loose |
| Lil Keed | IN MY H3AD | 38 | 23 | 248 | loose |
| Lil Keed | Ice | 33 | 11 | 187 | loose |
| Lil Keed | Ice On Me | 61 | 40 | 170 | loose |
| Lil Keed | Imposters | 40 | 39 | 164 | loose |
| Lil Keed | Indonesian Plate | 29 | 27 | 104 | loose |
| Lil Keed | Inhale Exhale | 50 | 58 | 118 | loose |
| Lil Keed | Insane | 45 | 73 | 162 | loose |
| Lil Keed | Insurance | 32 | 16 | 165 | loose |
| Lil Keed | Intro (TOC3) | 35 | 14 | 156 | loose |
| Lil Keed | Is What It Is | 33 | 21 | 107 | loose |
| Lil Keed | Is You Down | 37 | 27 | 165 | loose |
| Lil Keed | It’s Up Freestyle (Streaming Version) | 7 | 3 | 22 | loose |
| Lil Keed | It’s Yo Vibe | 23 | 26 | 37 | loose |
| Lil Keed | I’ll Be A Gent | 55 | 70 | 190 | loose |
| Lil Keed | I’m Good | 45 | 27 | 195 | loose |
| Lil Keed | I’m On It | 57 | 35 | 188 | loose |
| Lil Keed | I’m so Sorry | 37 | 65 | 162 | loose |
| Lil Keed | Jackboy | 53 | 30 | 242 | loose |
| Lil Keed | Jealousy | 43 | 26 | 210 | loose |
| Lil Keed | Jefferey | 34 | 58 | 245 | loose |
| Lil Keed | Juice | 35 | 31 | 130 | loose |
| Lil Keed | Just Thuggin’* | 30 | 14 | 105 | loose |
| Lil Keed | Just a Dream | 44 | 70 | 247 | loose |
| Lil Keed | Juvenile Delinquent | 65 | 72 | 197 | loose |
| Lil Keed | Kawasaki | 31 | 41 | 208 | loose |
| Lil Keed | KeedToven | 30 | 17 | 151 | loose |
| Lil Keed | Kick Back | 37 | 46 | 265 | loose |
| Lil Keed | Kiss Em Peace | 38 | 39 | 168 | loose |
| Lil Keed | Knocked Off | 57 | 60 | 224 | loose |
| Lil Keed | Know What to Do With It | 50 | 44 | 186 | loose |
| Lil Keed | Leave Us | 35 | 40 | 146 | loose |
| Lil Keed | Leveled Up | 30 | 20 | 177 | loose |
| Lil Keed | Like Dat | 46 | 37 | 244 | loose |
| Lil Keed | Litty | 48 | 28 | 272 | loose |
| Lil Keed | Location | 67 | 62 | 275 | loose |
| Lil Keed | Long Way To Go | 37 | 44 | 187 | loose |
| Lil Keed | Lost My Trust | 34 | 28 | 173 | loose |
| Lil Keed | Love Me Again (Remix) | 59 | 45 | 189 | loose |
| Lil Keed | Low Number (Don’t Love Her) | 44 | 18 | 164 | loose |
| Lil Keed | Loyal | 10 | 11 | 81 | loose |
| Lil Keed | MAMA | 28 | 27 | 176 | loose |
| Lil Keed | Mack 11 | 37 | 46 | 154 | loose |
| Lil Keed | Major Status | 41 | 112 | 257 | loose |
| Lil Keed | Make U Proud | 60 | 77 | 190 | loose |
| Lil Keed | Mama Sad | 33 | 68 | 104 | loose |
| Lil Keed | Maniac Thoughts | 44 | 47 | 279 | loose |
| Lil Keed | Maybach | 38 | 29 | 271 | loose |
| Lil Keed | Maybelline | 38 | 62 | 168 | loose |
| Lil Keed | Millions & Billions | 61 | 67 | 253 | loose |
| Lil Keed | Minaj | 39 | 68 | 166 | loose |
| Lil Keed | Misfit | 38 | 33 | 173 | loose |
| Lil Keed | Mix Match | 12 | 3 | 25 | loose |
| Lil Keed | Mobster | 76 | 123 | 531 | loose |
| Lil Keed | Monsta | 35 | 25 | 131 | loose |
| Lil Keed | Monster | 45 | 24 | 178 | loose |
| Lil Keed | Mosh Pit (2020) | 32 | 38 | 186 | loose |
| Lil Keed | Move It | 60 | 62 | 145 | loose |
| Lil Keed | Mozzarella | 32 | 51 | 263 | loose |
| Lil Keed | Ms Butterworth | 43 | 61 | 167 | loose |
| Lil Keed | Mudd on Me | 30 | 29 | 180 | loose |
| Lil Keed | Murder Rate | 52 | 65 | 207 | loose |
| Lil Keed | Muso Kuso | 30 | 20 | 267 | loose |
| Lil Keed | My Way | 26 | 53 | 162 | loose |
| Lil Keed | NBA | 41 | 72 | 266 | loose |
| Lil Keed | Nasty | 42 | 36 | 164 | loose |
| Lil Keed | No Cap | 46 | 47 | 213 | loose |
| Lil Keed | No Dealings | 47 | 50 | 166 | loose |
| Lil Keed | No Fear | 64 | 91 | 116 | loose |
| Lil Keed | No Fifties (Remix) | 48 | 67 | 175 | loose |
| Lil Keed | No Gimmick | 36 | 37 | 106 | loose |
| Lil Keed | No Heart | 38 | 28 | 258 | loose |
| Lil Keed | No Reason | 64 | 40 | 310 | loose |
| Lil Keed | Nose Running | 29 | 9 | 78 | loose |
| Lil Keed | Noticed | 48 | 58 | 227 | loose |
| Lil Keed | Now We Getting Money | 62 | 61 | 246 | loose |
| Lil Keed | ORANGE PRINT | 43 | 42 | 198 | loose |
| Lil Keed | Obama Coupe | 37 | 15 | 241 | loose |
| Lil Keed | Off Land | 62 | 59 | 278 | loose |
| Lil Keed | Off Rip | 48 | 73 | 177 | loose |
| Lil Keed | Off-White | 59 | 54 | 406 | loose |
| Lil Keed | Oh Ya | 53 | 56 | 162 | loose |
| Lil Keed | On Everything | 43 | 40 | 159 | loose |
| Lil Keed | On It | 67 | 70 | 339 | loose |
| Lil Keed | On My Mommy* | 21 | 9 | 60 | loose |
| Lil Keed | Ooh Ooh | 61 | 82 | 239 | loose |
| Lil Keed | Our Time | 39 | 44 | 234 | loose |
| Lil Keed | Out The Van | 48 | 57 | 121 | loose |
| Lil Keed | Overload | 46 | 44 | 256 | loose |
| Lil Keed | Pain | 29 | 27 | 134 | loose |
| Lil Keed | Pain On Me | 29 | 21 | 65 | loose |
| Lil Keed | Parachute | 44 | 55 | 160 | loose |
| Lil Keed | Party | 30 | 21 | 220 | loose |
| Lil Keed | Pass It Out | 44 | 47 | 245 | loose |
| Lil Keed | Pass That Blick* | 15 | 4 | 32 | loose |
| Lil Keed | Pay What You Weigh | 35 | 33 | 177 | loose |
| Lil Keed | Phantom Vibes | 46 | 32 | 134 | loose |
| Lil Keed | Player | 47 | 72 | 330 | loose |
| Lil Keed | Playground | 28 | 31 | 82 | loose |
| Lil Keed | Pocket Watching | 34 | 31 | 200 | loose |
| Lil Keed | Pop My Shit (Remix) | 79 | 70 | 337 | loose |
| Lil Keed | Proud of Me | 62 | 76 | 145 | loose |
| Lil Keed | Purge | 51 | 21 | 110 | loose |
| Lil Keed | Put ’Em On | 32 | 18 | 162 | loose |
| Lil Keed | Rack To The Tater | 40 | 38 | 276 | loose |
| Lil Keed | Range Rover Sports Truck | 35 | 35 | 131 | loose |
| Lil Keed | Rappin Shit | 36 | 42 | 203 | loose |
| Lil Keed | Real Block Boy | 22 | 25 | 136 | loose |
| Lil Keed | Real Hood Baby | 49 | 47 | 189 | loose |
| Lil Keed | Real Life | 26 | 52 | 95 | loose |
| Lil Keed | Real Slime | 29 | 32 | 132 | loose |
| Lil Keed | Realest One | 41 | 48 | 220 | loose |
| Lil Keed | Really Redd | 32 | 48 | 218 | loose |
| Lil Keed | Red Bottoms | 43 | 54 | 176 | loose |
| Lil Keed | Red Eyes | 46 | 43 | 145 | loose |
| Lil Keed | Red Hot | 32 | 39 | 120 | loose |
| Lil Keed | Relapse Game | 47 | 66 | 272 | loose |
| Lil Keed | Repaid | 37 | 34 | 226 | loose |
| Lil Keed | Rich Shit | 30 | 23 | 238 | loose |
| Lil Keed | Ride Wit You | 35 | 35 | 115 | loose |
| Lil Keed | Right 1 | 33 | 40 | 181 | loose |
| Lil Keed | Rockstar | 38 | 40 | 135 | loose |
| Lil Keed | Rockstar Lifestyle | 45 | 30 | 261 | loose |
| Lil Keed | Rolls (Rozey) | 62 | 78 | 424 | loose |
| Lil Keed | Rolls Royce Truck* | 9 | 9 | 43 | loose |
| Lil Keed | Run Down | 23 | 24 | 123 | loose |
| Lil Keed | Runnin Bands | 48 | 43 | 249 | loose |
| Lil Keed | SHE SAID | 27 | 16 | 167 | loose |
| Lil Keed | SRT | 30 | 70 | 144 | loose |
| Lil Keed | Saliva | 34 | 39 | 190 | loose |
| Lil Keed | Sauce | 29 | 23 | 209 | loose |
| Lil Keed | Say Something | 64 | 34 | 270 | loose |
| Lil Keed | Scotty | 38 | 45 | 208 | loose |
| Lil Keed | Self Employed | 35 | 53 | 218 | loose |
| Lil Keed | Shoot Sumn | 15 | 7 | 34 | loose |
| Lil Keed | Shoulda Been | 35 | 36 | 204 | loose |
| Lil Keed | Show Me What You Got | 39 | 34 | 204 | loose |
| Lil Keed | Shut Up | 56 | 80 | 303 | loose |
| Lil Keed | Shyne | 47 | 39 | 152 | loose |
| Lil Keed | Slatt Luv | 42 | 40 | 179 | loose |
| Lil Keed | Slatt Rock | 58 | 50 | 235 | loose |
| Lil Keed | Slime | 41 | 52 | 242 | loose |
| Lil Keed | Slime Glocks | 47 | 36 | 204 | loose |
| Lil Keed | Slime Lingo | 44 | 49 | 306 | loose |
| Lil Keed | Slime Mobb | 34 | 18 | 195 | loose |
| Lil Keed | Slimes On The Scene | 37 | 18 | 270 | loose |
| Lil Keed | Smack On God | 25 | 21 | 111 | loose |
| Lil Keed | Snakes On My Collar | 50 | 88 | 245 | loose |
| Lil Keed | Sneakin And Geekin | 28 | 20 | 92 | loose |
| Lil Keed | Snowfall | 42 | 51 | 137 | loose |
| Lil Keed | So Many Times | 38 | 37 | 149 | loose |
| Lil Keed | Solid | 57 | 78 | 202 | loose |
| Lil Keed | Some Playas | 29 | 39 | 120 | loose |
| Lil Keed | Southside | 48 | 97 | 233 | loose |
| Lil Keed | Space Coupe | 36 | 23 | 149 | loose |
| Lil Keed | Spaz On ’Em* | 18 | 17 | 108 | loose |
| Lil Keed | Stop It | 30 | 20 | 152 | loose |
| Lil Keed | Stupid Shit | 39 | 63 | 190 | loose |
| Lil Keed | Swap It Out | 49 | 60 | 280 | loose |
| Lil Keed | TOKYO | 39 | 25 | 206 | loose |
| Lil Keed | TURN UP BURN UP | 16 | 17 | 94 | loose |
| Lil Keed | Take It There | 30 | 20 | 84 | loose |
| Lil Keed | Taki | 38 | 30 | 173 | loose |
| Lil Keed | Tartar Sauce | 65 | 55 | 210 | loose |
| Lil Keed | Tekashi | 39 | 25 | 127 | loose |
| Lil Keed | Tellin’ Ya | 57 | 78 | 185 | loose |
| Lil Keed | Thank You Lord | 37 | 11 | 108 | loose |
| Lil Keed | The Jungle | 33 | 21 | 179 | loose |
| Lil Keed | Think About It | 48 | 24 | 169 | loose |
| Lil Keed | Threshold | 21 | 15 | 166 | loose |
| Lil Keed | Throw Dat Ass | 30 | 31 | 162 | loose |
| Lil Keed | Thug Luv | 16 | 19 | 94 | loose |
| Lil Keed | Thugger | 47 | 43 | 135 | loose |
| Lil Keed | Tied In | 24 | 14 | 195 | loose |
| Lil Keed | Tighten Up | 61 | 76 | 265 | loose |
| Lil Keed | Till | 38 | 25 | 144 | loose |
| Lil Keed | Tip Top | 59 | 94 | 309 | loose |
| Lil Keed | Tony Romo | 41 | 43 | 130 | loose |
| Lil Keed | Too Official | 55 | 89 | 216 | loose |
| Lil Keed | Top Spot | 49 | 48 | 254 | loose |
| Lil Keed | Top of the Mountain | 27 | 19 | 112 | loose |
| Lil Keed | Tortise | 16 | 8 | 27 | loose |
| Lil Keed | Trains | 36 | 33 | 340 | loose |
| Lil Keed | Trap Museum | 59 | 86 | 272 | loose |
| Lil Keed | Traplanta | 33 | 25 | 198 | loose |
| Lil Keed | Trick a Nigga* | 19 | 22 | 144 | loose |
| Lil Keed | Trippin | 27 | 36 | 141 | loose |
| Lil Keed | Truth or Dare | 34 | 29 | 214 | loose |
| Lil Keed | Twisted | 39 | 15 | 251 | loose |
| Lil Keed | Twisting Our Fingers | 68 | 67 | 324 | loose |
| Lil Keed | Undecided | 23 | 22 | 144 | loose |
| Lil Keed | Undefeated | 66 | 85 | 219 | loose |
| Lil Keed | Unfortunately | 38 | 24 | 179 | loose |
| Lil Keed | Vibez’N | 36 | 25 | 175 | loose |
| Lil Keed | Virus | 69 | 93 | 274 | loose |
| Lil Keed | Wall to Wall | 28 | 27 | 117 | loose |
| Lil Keed | Wanna See You | 40 | 38 | 244 | loose |
| Lil Keed | Want It All | 40 | 56 | 194 | loose |
| Lil Keed | Warrior | 58 | 102 | 269 | loose |
| Lil Keed | Water By G | 30 | 23 | 96 | loose |
| Lil Keed | Wave Flow | 54 | 33 | 232 | loose |
| Lil Keed | Wavy | 19 | 12 | 86 | loose |
| Lil Keed | Way Way Up | 25 | 14 | 127 | loose |
| Lil Keed | We Bout | 53 | 41 | 189 | loose |
| Lil Keed | Wet Like a Boat | 76 | 135 | 286 | loose |
| Lil Keed | Wet N Wild | 34 | 20 | 122 | loose |
| Lil Keed | What I Do | 48 | 38 | 154 | loose |
| Lil Keed | What’s Up? | 38 | 25 | 281 | loose |
| Lil Keed | Wheels Fall Off* | 17 | 21 | 78 | loose |
| Lil Keed | Where I’m From | 24 | 25 | 166 | loose |
| Lil Keed | Who Gon’?* | 17 | 18 | 86 | loose |
| Lil Keed | Why | 21 | 33 | 99 | loose |
| Lil Keed | Wifey | 7 | 2 | 8 | loose |
| Lil Keed | Wild Life | 36 | 38 | 178 | loose |
| Lil Keed | Wish Me Well | 33 | 17 | 138 | loose |
| Lil Keed | Wit A Bottle (Remix) | 47 | 54 | 183 | loose |
| Lil Keed | Woah | 43 | 59 | 171 | loose |
| Lil Keed | Wolves | 38 | 21 | 138 | loose |
| Lil Keed | Wop | 28 | 32 | 134 | loose |
| Lil Keed | Work! | 37 | 33 | 120 | loose |
| Lil Keed | Worst or Better | 28 | 25 | 133 | loose |
| Lil Keed | XXL Freshman Freestyle: Lil Keed | 5 | 1 | 15 | loose |
| Lil Keed | YN | 29 | 26 | 148 | loose |
| Lil Keed | Yank It | 40 | 42 | 167 | loose |
| Lil Keed | Yeah Yeah | 70 | 73 | 265 | loose |
| Lil Keed | You Do The Math | 40 | 40 | 187 | loose |
| Lil Keed | Young Dro | 56 | 45 | 169 | loose |
| Lil Keed | Young Nigga | 45 | 31 | 120 | loose |
| Lil Keed | Young Nigga Shit | 37 | 29 | 219 | loose |
| Lil Keed | Zaza | 60 | 58 | 276 | loose |
| Lil Keed | Zoned Out | 47 | 46 | 156 | loose |
| Lil Keed | alien autopsy | 39 | 32 | 151 | loose |
| Lil Keed | i wouldn’t | 34 | 29 | 203 | loose |
| Lil Keed | throwback thursday | 41 | 32 | 251 | loose |
