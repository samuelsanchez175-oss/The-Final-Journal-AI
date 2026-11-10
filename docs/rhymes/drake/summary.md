# Drake rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Drake
- Songs: 1211
- Bars kept (Drake lyric lines): 51509
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 96
- Canonical name: Drake.
- Credit strings: Drake.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 294853
- REPEAT pairs, recorded separately: 37268
- END rhymes: 46100
- INNER rhymes: 248753

By match:

- PERFECT: 25814 (END 7370, INNER 18444)
- SLANT: 119369 (END 18308, INNER 101061)
- ASSONANCE: 145548 (END 19087, INNER 126461)
- MULTI: 4122 (END 1335, INNER 2787)

By confidence:

- HIGH: 27421
- MED: 251239
- LOW: 16193

## Core

- Core Y: 289188
- Core N among rhyme pairs: 5665

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 132381 (44.9%)
- vowel: 145548 (49.4%)
- spelling: 12802 (4.3%)
- multi: 4122 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 4 songs
- AABB: 1 songs
- ABBA: 1 songs
- ABCB: 1 songs
- loose: 1204 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 22505 pairs (END 2243, INNER 20262). Words: when, get, never, tell, friends, gettin, where, there's.
2. `vow:IH` — 19932 pairs (END 2450, INNER 17482). Words: shit, think, still, bitches, bitch, things, really, give.
3. `vow:OW` — 17923 pairs (END 2173, INNER 15750). Words: know, don't, no, go, only, over, show, told.
4. `vow:EY` — 17628 pairs (END 2881, INNER 14747). Words: ain't, say, way, make, baby, take, day, play.
5. `vow:AE` — 12914 pairs (END 1738, INNER 11176). Words: back, can't, have, man, can, had, last, ask.
6. `vow:IY` — 11967 pairs (END 1412, INNER 10555). Words: see, even, need, these, people, here, keep, real.
7. `vow:AY` — 11544 pairs (END 2000, INNER 9544). Words: like, why, time, by, mind, high, right, try.
8. `vow:AA` — 10799 pairs (END 1192, INNER 9607). Words: got, want, not, talkin, hard, wanna, started, gotta.
9. `vow:AH` — 9719 pairs (END 1055, INNER 8664). Words: what, love, one, fuck, some, somethin, fuckin, come.
10. `slant:AA:stop` — 4701 pairs (END 474, INNER 4227). Words: got, gotta, not, want, top, body, lot, god.
11. `slant:IH:stop` — 3696 pairs (END 527, INNER 3169). Words: shit, nigga, big, city, hit, dick, quick, crib.
12. `slant:EH:stop` — 3571 pairs (END 452, INNER 3119). Words: get, better, let, said, head, left, check, best.
13. `cmu:OW` — 3382 pairs (END 690, INNER 2692). Words: know, no, go, though, show, o, low, flow.
14. `slant:EH:nas-stop` — 3175 pairs (END 211, INNER 2964). Words: when, get, again, let, said, better, many, gettin.
15. `slant:AY:stop` — 3161 pairs (END 429, INNER 2732). Words: like, right, night, side, ride, might, white, light.
16. `vow:UW` — 3064 pairs (END 602, INNER 2462). Words: new, who, two, through, used, music, future, truth.
17. `slant:AH:nas-stop` — 2983 pairs (END 162, INNER 2821). Words: what, fuck, one, some, money, come, young, done.
18. `slant:AE:stop` — 2950 pairs (END 528, INNER 2422). Words: back, had, can't, bad, act, fact, rap, stand.
19. `slant:EH:liq-stop` — 2948 pairs (END 192, INNER 2756). Words: get, tell, where, there, let, said, well, better.
20. `vow:AO` — 2861 pairs (END 370, INNER 2491). Words: all, more, talking, y'all, lost, call, wanted, talk.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 1639 pair sides, mostly spelling via spelling phonetic key, often with niggas (379)
- niggas — 828 pair sides, mostly spelling via spelling phonetic key, often with nigga (379)
- tryna — 710 pair sides, mostly spelling via spelling phonetic key, often with here (56)
- ima — 638 pair sides, mostly spelling via spelling phonetic key, often with shit (68)
- gon — 569 pair sides, mostly spelling via spelling phonetic key, often with dont (120)
- shawty — 221 pair sides, mostly vowel via spelling phonetic key, often with all (25)
- drizzy — 210 pair sides, mostly vowel via spelling phonetic key, often with see (19)
- weezy — 178 pair sides, mostly vowel via spelling phonetic key, often with baby (23)
- cuz — 123 pair sides, mostly spelling via spelling phonetic key, often with what (14)
- ovo — 117 pair sides, mostly vowel via spelling phonetic key, often with know (26)
- dem — 110 pair sides, mostly spelling via spelling phonetic key, often with tell (10)
- dawg — 86 pair sides, mostly spelling via spelling phonetic key, often with all (30)
- lyin — 81 pair sides, mostly spelling via spelling phonetic key, often with flyin (5)
- quiero — 72 pair sides, mostly vowel via spelling phonetic key, often with no (9)
- prolly — 69 pair sides, mostly vowel via spelling phonetic key, often with really (5)
- homie — 67 pair sides, mostly spelling via spelling phonetic key, often with over (7)
- kanye — 67 pair sides, mostly spelling via spelling phonetic key, often with back (9)
- gyal — 65 pair sides, mostly spelling via spelling phonetic key, often with real (6)
- jeezy — 64 pair sides, mostly vowel via spelling phonetic key, often with gucci (5)
- tings — 59 pair sides, mostly spelling via spelling phonetic key, often with things (3)
- quavo — 57 pair sides, mostly spelling via spelling phonetic key, often with travis (8)
- bling — 56 pair sides, mostly spelling via spelling phonetic key, often with thing (8)
- tengo — 55 pair sides, mostly vowel via spelling phonetic key, often with no (6)
- henny — 54 pair sides, mostly spelling via spelling phonetic key, often with when (9)
- wifey — 53 pair sides, mostly spelling via spelling phonetic key, often with bitch (7)
- blatow — 52 pair sides, mostly spelling via spelling phonetic key, often with blat (22)
- swag — 51 pair sides, mostly spelling via spelling phonetic key, often with back (5)
- imma — 48 pair sides, mostly spelling via spelling phonetic key, often with bring (6)
- bros — 48 pair sides, mostly spelling via spelling phonetic key, often with road (5)
- esto — 46 pair sides, mostly vowel via spelling phonetic key, often with es (8)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Drake | 10 Bands | 36 | 15 | 198 | loose |
| Drake | 100 | 89 | 64 | 419 | loose |
| Drake | 100it Racks | 79 | 98 | 174 | loose |
| Drake | 101010 | 49 | 27 | 142 | loose |
| Drake | 1Xtra Freestyle | 22 | 23 | 113 | loose |
| Drake | 2 Hard 4 The Radio | 50 | 59 | 212 | loose |
| Drake | 2 Mazza | 38 | 32 | 333 | loose |
| Drake | 2 Much | 30 | 12 | 117 | loose |
| Drake | 2 On / Thotful | 70 | 60 | 190 | loose |
| Drake | 20 Hoes (Remix)* | 42 | 43 | 240 | loose |
| Drake | 2011 Juno Awards In Toronto | 6 | 2 | 17 | loose |
| Drake | 2024 Movement Com Freestyle | 12 | 2 | 24 | loose |
| Drake | 24 | 32 | 23 | 88 | loose |
| Drake | 24'S / Rich Flex (Mixed) [March 2023] | 30 | 33 | 136 | loose |
| Drake | 2AM | 51 | 29 | 158 | loose |
| Drake | 3 On | 54 | 48 | 172 | loose |
| Drake | 30 Hours | 73 | 48 | 309 | loose |
| Drake | 30 for 30 Freestyle | 74 | 103 | 413 | loose |
| Drake | 305 to My City | 52 | 21 | 106 | loose |
| Drake | 3AM in the Yams (Original) | 36 | 67 | 123 | loose |
| Drake | 4 My Town (Play Ball) | 64 | 64 | 328 | loose |
| Drake | 416 | 31 | 37 | 111 | loose |
| Drake | 4422 | 10 | 5 | 20 | loose |
| Drake | 4PM in Calabasas | 78 | 90 | 456 | loose |
| Drake | 5AM in Toronto | 60 | 46 | 288 | loose |
| Drake | 6 God | 51 | 30 | 115 | loose |
| Drake | 6 Man | 34 | 29 | 187 | loose |
| Drake | 6PM in New York | 95 | 90 | 649 | loose |
| Drake | 6th Sense | 34 | 36 | 167 | loose |
| Drake | 7/11 (Homecoming Live) | 32 | 14 | 115 | loose |
| Drake | 7969 Santa | 48 | 48 | 166 | loose |
| Drake | 7am On Bridle Path | 84 | 198 | 432 | loose |
| Drake | 8 Out of 10 | 45 | 52 | 273 | loose |
| Drake | 8am in Charlotte | 75 | 117 | 530 | loose |
| Drake | 9 | 41 | 25 | 314 | loose |
| Drake | 9AM in Dallas | 64 | 82 | 404 | loose |
| Drake | <img src="https://images.genius.com/011b9f00d72d0d3841f6bcf9cbc4e83c.300x300x1.png" alt="The Motto" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>The MottoDrake3.9M | 49 | 29 | 275 | loose |
| Drake | <img src="https://images.genius.com/0af93f8023b7f0885a4f1455b4099e8d.300x300x1.png" alt="One Dance" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>One DanceDrake6.4M | 37 | 50 | 148 | loose |
| Drake | <img src="https://images.genius.com/0e3dba170124f70a8ed995e7cf3d42eb.300x300x1.png" alt="Back To Back" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Back To BackDrake5.4M | 56 | 38 | 275 | loose |
| Drake | <img src="https://images.genius.com/0e807f9e10b6b75fb4cce3664dfa87c6.300x300x1.png" alt="Fuckin’ Problems" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Fuckin’ ProblemsA$AP Rocky8.1M | 54 | 45 | 230 | loose |
| Drake | <img src="https://images.genius.com/1929f986016020edb588a245b7509a82.300x300x1.png" alt="Hotline Bling" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Hotline BlingDrake7.4M | 36 | 38 | 103 | loose |
| Drake | <img src="https://images.genius.com/2dc42155625a666c04d14a04a1b9e51e.300x300x1.png" alt="Only" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>OnlyNicki Minaj3.9M | 94 | 82 | 308 | loose |
| Drake | <img src="https://images.genius.com/4a8010f3c0949e44ee30fb718f2445ec.300x300x1.png" alt="Work" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>WorkRihanna8.4M | 56 | 45 | 114 | loose |
| Drake | <img src="https://images.genius.com/539dfa9f85a8848474c27c1aca9fb486.300x300x1.png" alt="Hold On, We’re Going Home" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Hold On, We’re Going HomeDrake5.7M | 17 | 6 | 52 | loose |
| Drake | <img src="https://images.genius.com/552ee994ceab813da08e85f101e64bc9.300x300x1.png" alt="SICKO MODE" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>SICKO MODETravis Scott10.3M | 77 | 107 | 268 | loose |
| Drake | <img src="https://images.genius.com/64df40485baa8d02820789fc543273db.300x300x1.png" alt="Family Matters" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Family MattersDrake5.3M | 138 | 204 | 1390 | loose |
| Drake | <img src="https://images.genius.com/6557cf1d8660623b66f6a6017d75370c.300x300x1.png" alt="All Me" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>All MeDrake4.2M | 105 | 72 | 477 | loose |
| Drake | <img src="https://images.genius.com/a0822204644f5abd6f1c96f200bc643c.300x300x1.png" alt="Marvins Room" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Marvins RoomDrake3.7M | 59 | 36 | 219 | loose |
| Drake | <img src="https://images.genius.com/b19e6eca082dd81ae04da590082ac31e.300x300x1.png" alt="Know Yourself" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Know YourselfDrake5.4M | 54 | 42 | 152 | loose |
| Drake | <img src="https://images.genius.com/b4d6d87f080c362200ce55ed35ec65bb.300x300x1.png" alt="Poetic Justice" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Poetic JusticeKendrick Lamar5M | 69 | 30 | 438 | loose |
| Drake | <img src="https://images.genius.com/b55953177013ca20466401280f855a08.300x300x1.png" alt="From Time" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>From TimeDrake4.1M | 65 | 80 | 343 | loose |
| Drake | <img src="https://images.genius.com/b55953177013ca20466401280f855a08.300x300x1.png" alt="Pound Cake / Paris Morton Music 2" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Pound Cake / Paris Morton Music 2Drake3.9M | 49 | 26 | 218 | loose |
| Drake | <img src="https://images.genius.com/d07c7aca495a624d5d4e0eb11cccd577.300x300x1.png" alt="God’s Plan" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>God’s PlanDrake10.1M | 31 | 28 | 83 | loose |
| Drake | <img src="https://images.genius.com/d07c7aca495a624d5d4e0eb11cccd577.300x300x1.png" alt="In My Feelings" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>In My FeelingsDrake8M | 21 | 10 | 84 | loose |
| Drake | <img src="https://images.genius.com/df15007a623347465eca1126b922afe7.300x300x1.jpg" alt="Fake Love" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Fake LoveDrake3.8M | 27 | 47 | 81 | loose |
| Drake | <img src="https://images.genius.com/e4e1f1e42a17873dce151a2cac6b6562.300x300x1.png" alt="0 to 100 / The Catch Up" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>0 to 100 / The Catch UpDrake3.9M | 93 | 91 | 564 | loose |
| Drake | @Ppr0digy Disstrack | 45 | 54 | 248 | loose |
| Drake | A Keeper | 23 | 24 | 59 | loose |
| Drake | A Little Favour (GQ Freestyle) | 22 | 20 | 142 | loose |
| Drake | A Milli Freestyle | 29 | 17 | 178 | loose |
| Drake | A Night Off | 25 | 10 | 88 | loose |
| Drake | A Scorpio’s Mind | 71 | 65 | 471 | loose |
| Drake | A.D.I.D.A.S. | 27 | 20 | 96 | loose |
| Drake | ALL I NEED | 36 | 21 | 95 | loose |
| Drake | AM 2 PM | 56 | 61 | 551 | loose |
| Drake | ARIPI RELOADED | 21 | 11 | 350 | loose |
| Drake | ATF Radio Freestyle | 54 | 46 | 246 | loose |
| Drake | About the Game | 44 | 23 | 226 | loose |
| Drake | Acapella | 34 | 15 | 203 | loose |
| Drake | Active | 36 | 29 | 99 | loose |
| Drake | After Dark | 40 | 25 | 199 | loose |
| Drake | Against The Wind (The Remorse Original) | 27 | 68 | 186 | loose |
| Drake | Ahí | 36 | 31 | 413 | loose |
| Drake | All Good | 45 | 45 | 193 | loose |
| Drake | All Night Long (OG Mix) | 34 | 32 | 190 | loose |
| Drake | All The Parties | 61 | 72 | 267 | loose |
| Drake | All These People | 38 | 47 | 201 | loose |
| Drake | All This Love | 33 | 26 | 136 | loose |
| Drake | All of the Lights | 36 | 45 | 126 | loose |
| Drake | All the Time | 18 | 13 | 103 | loose |
| Drake | Amazing Shape | 36 | 46 | 182 | loose |
| Drake | Amen | 62 | 37 | 307 | loose |
| Drake | Amen [Double ₳ ‘from The Bay’ Remix] [Mixed] | 27 | 18 | 77 | loose |
| Drake | An Evening I Will Not Forget / Furthest Thing | 55 | 36 | 219 | loose |
| Drake | Another Late Night | 42 | 24 | 291 | loose |
| Drake | Any Time, Any Place / Poetic Justice [Remix] [Mixed] | 8 | 0 | 4 | loose |
| Drake | Anybody Wanna Buy A Heart? | 16 | 7 | 57 | loose |
| Drake | Aripi | 40 | 26 | 364 | loose |
| Drake | As We Speak | 57 | 65 | 276 | loose |
| Drake | Astalavista (2025) | 54 | 73 | 417 | loose |
| Drake | Asthma Team | 37 | 64 | 222 | loose |
| Drake | Aston Martin Music | 80 | 65 | 410 | loose |
| Drake | Away From Home | 77 | 164 | 471 | loose |
| Drake | B.B. King Freestyle | 73 | 100 | 570 | loose |
| Drake | B8 [untitled] | 6 | 1 | 37 | loose |
| Drake | BABY ROYAL | 1 | 0 | 0 | loose |
| Drake | BBL Drizzy (Drake Remix, Prod. Metro Boomin) | 6 | 3 | 29 | loose |
| Drake | BBL Love (Interlude) | 39 | 31 | 133 | loose |
| Drake | BBW | 30 | 30 | 84 | loose |
| Drake | BZNS | 42 | 49 | 472 | loose |
| Drake | Baby Come With Me | 25 | 17 | 72 | loose |
| Drake | Bachelor | 32 | 35 | 90 | loose |
| Drake | Back 2 Back (Yung Lambo Diss) | 115 | 126 | 521 | loose |
| Drake | Back on Road | 30 | 37 | 200 | loose |
| Drake | Back to Back | 15 | 13 | 62 | loose |
| Drake | BackOutsideBoyz | 32 | 55 | 174 | loose |
| Drake | Bad Meaning Good | 45 | 33 | 252 | loose |
| Drake | Bahamas Promises | 22 | 15 | 36 | loose |
| Drake | Bal Harbour | 12 | 12 | 65 | loose |
| Drake | Barry Bonds (Freestyle) | 35 | 33 | 507 | loose |
| Drake | Be In There (Ton Of Em)* | 27 | 20 | 192 | loose |
| Drake | Beautiful Music | 65 | 57 | 328 | loose |
| Drake | BedRock | 59 | 67 | 320 | loose |
| Drake | Bedrock Pt. II (Young Goldie Mix) | 27 | 10 | 104 | loose |
| Drake | Behind Barz (Link Up TV Freestyle) | 63 | 119 | 218 | loose |
| Drake | Believe It Or Not | 31 | 44 | 189 | loose |
| Drake | Believe Me | 78 | 79 | 387 | loose |
| Drake | Belly Shit (Alicia) | 38 | 21 | 82 | loose |
| Drake | Belong to the City (Demo) | 17 | 17 | 29 | loose |
| Drake | Best Friends | 59 | 63 | 359 | loose |
| Drake | Best I Ever Had | 54 | 44 | 318 | loose |
| Drake | Betrayal | 36 | 54 | 176 | loose |
| Drake | Between Us | 46 | 33 | 247 | loose |
| Drake | Big Amount | 79 | 81 | 233 | loose |
| Drake | Big Mood | 52 | 50 | 227 | loose |
| Drake | Big Pun | 25 | 25 | 146 | loose |
| Drake | Big Rings | 39 | 29 | 219 | loose |
| Drake | Bigger Than You | 43 | 25 | 198 | loose |
| Drake | Bitch Is Crazy | 29 | 11 | 89 | loose |
| Drake | Black Magic | 48 | 52 | 202 | loose |
| Drake | Blem | 24 | 17 | 86 | loose |
| Drake | Bless ME | 37 | 18 | 123 | loose |
| Drake | Blessings | 80 | 87 | 430 | loose |
| Drake | Bleu (better with time) | 21 | 17 | 48 | loose |
| Drake | Blind Faith | 33 | 41 | 129 | loose |
| Drake | Blue Green Red | 38 | 42 | 171 | loose |
| Drake | Blue Tint | 34 | 21 | 70 | loose |
| Drake | Body 2 Body (Lovesick) | 15 | 8 | 67 | loose |
| Drake | Born 2 Be Great | 43 | 61 | 186 | loose |
| Drake | Both | 28 | 37 | 158 | loose |
| Drake | Bottom’s Up [Smoothie Blue Remix] | 35 | 53 | 237 | loose |
| Drake | Brand New | 29 | 19 | 71 | loose |
| Drake | Bria’s Interlude | 14 | 13 | 24 | loose |
| Drake | Bricks | 69 | 51 | 185 | loose |
| Drake | Bring It Back | 53 | 50 | 235 | loose |
| Drake | Broke Boys | 58 | 56 | 317 | loose |
| Drake | Bubbly | 62 | 111 | 283 | loose |
| Drake | Buffalo Freestyle | 52 | 64 | 451 | loose |
| Drake | Bullets Don’t Tickle* | 10 | 3 | 29 | loose |
| Drake | Buried Alive Interlude | 47 | 33 | 276 | loose |
| Drake | Buried Alive Interlude, Pt. 2 | 23 | 34 | 97 | loose |
| Drake | Burning Bridges | 35 | 52 | 175 | loose |
| Drake | Buy a Heart | 43 | 31 | 178 | loose |
| Drake | B’s On The Table | 48 | 71 | 214 | loose |
| Drake | CAPO PLAZA | 19 | 12 | 227 | loose |
| Drake | CELIBACY | 34 | 44 | 107 | loose |
| Drake | CHAMPAGNE SPEECH | 12 | 6 | 15 | loose |
| Drake | CN TOWER | 56 | 82 | 286 | loose |
| Drake | CRYING IN CHANEL | 44 | 36 | 147 | loose |
| Drake | Cabaret | 54 | 27 | 274 | loose |
| Drake | Calling For You | 82 | 71 | 335 | loose |
| Drake | Calling My Name | 11 | 5 | 30 | loose |
| Drake | Cameras | 43 | 25 | 156 | loose |
| Drake | Can I | 25 | 10 | 91 | loose |
| Drake | Cannon Ball | 21 | 5 | 70 | loose |
| Drake | Cannonball (Snippet) | 14 | 2 | 60 | loose |
| Drake | Cannonball Remix | 31 | 16 | 146 | loose |
| Drake | Can’t Have Everything | 54 | 68 | 370 | loose |
| Drake | Can’t Hide from Love Freestyle | 47 | 20 | 225 | loose |
| Drake | Can’t Take a Joke | 40 | 35 | 114 | loose |
| Drake | Carry On* | 5 | 4 | 16 | loose |
| Drake | Catboycatastrophe diss track | 23 | 10 | 70 | loose |
| Drake | Cece’s Interlude | 12 | 9 | 29 | loose |
| Drake | Cel U Lar Device | 20 | 2 | 146 | loose |
| Drake | Celebration | 58 | 41 | 186 | loose |
| Drake | Champagne Poetry | 80 | 89 | 444 | loose |
| Drake | Champion | 69 | 63 | 431 | loose |
| Drake | Change Locations | 39 | 42 | 190 | loose |
| Drake | Change Locations Remix | 20 | 12 | 78 | loose |
| Drake | Change You | 38 | 20 | 157 | loose |
| Drake | Charged Up | 59 | 57 | 273 | loose |
| Drake | Cheerios | 32 | 27 | 201 | loose |
| Drake | Cheetah Print | 35 | 14 | 247 | loose |
| Drake | Chef Curry With The Pot | 9 | 2 | 37 | loose |
| Drake | Chemistry | 56 | 61 | 205 | loose |
| Drake | Chicago | 34 | 29 | 113 | loose |
| Drake | Chicago Freestyle | 58 | 70 | 210 | loose |
| Drake | Chicago Freestyle (CHAMOS REMIX) [Mixed] | 2 | 0 | 0 | loose |
| Drake | Child’s Play | 56 | 18 | 241 | loose |
| Drake | Christmaslantavegas | 8 | 1 | 30 | loose |
| Drake | Churchill Downs | 98 | 172 | 727 | loose |
| Drake | Circadian Rhythm | 22 | 14 | 120 | loose |
| Drake | Circo Loco | 54 | 54 | 272 | loose |
| Drake | City Is Mine | 48 | 37 | 410 | loose |
| Drake | Classic | 17 | 4 | 54 | loose |
| Drake | Close 2 Me / Poetic Justice [Mixed] | 5 | 3 | 41 | loose |
| Drake | Closer to My Dreams | 78 | 65 | 519 | loose |
| Drake | Club Paradise | 67 | 43 | 416 | loose |
| Drake | Come Back To Me | 24 | 13 | 56 | loose |
| Drake | Come Closer | 35 | 44 | 126 | loose |
| Drake | Come Real | 23 | 13 | 85 | loose |
| Drake | Come Thru | 40 | 20 | 158 | loose |
| Drake | Come Up | 42 | 33 | 240 | loose |
| Drake | Come Winter | 95 | 72 | 726 | loose |
| Drake | Come and See Me | 37 | 19 | 240 | loose |
| Drake | Comeback Season | 49 | 42 | 225 | loose |
| Drake | Comments on Macklemore’s Post-Grammy Text | 7 | 1 | 39 | loose |
| Drake | Company | 55 | 29 | 297 | loose |
| Drake | Conceited vs Dumbfoundead | 270 | 223 | 1580 | loose |
| Drake | Confusion (Remix) | 15 | 2 | 51 | loose |
| Drake | Congratulations | 63 | 57 | 281 | loose |
| Drake | Connect | 53 | 22 | 206 | loose |
| Drake | Control | 50 | 26 | 209 | loose |
| Drake | Controlla | 42 | 24 | 103 | loose |
| Drake | Courtside Steppers* | 23 | 13 | 50 | loose |
| Drake | Crew Love | 39 | 20 | 118 | loose |
| Drake | Crying In Magic* | 10 | 2 | 29 | loose |
| Drake | Cuff Yo Chick | 42 | 24 | 215 | loose |
| Drake | Currents | 15 | 4 | 28 | loose |
| Drake | D.O.S.E | 55 | 86 | 186 | loose |
| Drake | D4L | 42 | 22 | 162 | loose |
| Drake | DICKO MODE | 66 | 97 | 244 | loose |
| Drake | DIE TRYING | 35 | 77 | 107 | loose |
| Drake | DOG HOUSE | 42 | 37 | 219 | loose |
| Drake | DOLLA SIGN SLIME (Drake Demo) | 28 | 26 | 117 | loose |
| Drake | DRAKE - OVER MY DEAD BODY (NEDARB NAGROM REMIX) | 17 | 9 | 71 | loose |
| Drake | DRAKE with the BRAIDS | 24 | 5 | 102 | loose |
| Drake | DRUNK OFF U | 44 | 53 | 155 | loose |
| Drake | Dawn Of A Young King | 37 | 21 | 108 | loose |
| Drake | Daylight | 48 | 27 | 179 | loose |
| Drake | Days in the East | 68 | 16 | 350 | loose |
| Drake | Days in the West | 42 | 19 | 218 | loose |
| Drake | Dead Presidents Freestyle | 13 | 5 | 259 | loose |
| Drake | Deceiving | 72 | 47 | 347 | loose |
| Drake | Deep Pockets | 45 | 79 | 328 | loose |
| Drake | Demons | 59 | 80 | 281 | loose |
| Drake | Desires | 48 | 46 | 245 | loose |
| Drake | Deuces (Remix) | 115 | 65 | 660 | loose |
| Drake | Diamonds Dancing | 45 | 15 | 145 | loose |
| Drake | Diced Pineapples | 73 | 66 | 447 | loose |
| Drake | Digital Dash | 90 | 92 | 266 | loose |
| Drake | Digital Girl (Remix) | 70 | 67 | 221 | loose |
| Drake | Diplomatic Immunity | 69 | 71 | 472 | loose |
| Drake | Dis Nigga Crazy (Skit) | 25 | 5 | 23 | loose |
| Drake | Disappointed* | 21 | 11 | 58 | loose |
| Drake | Discontinuing Wokhardt (Remix) | 15 | 5 | 73 | loose |
| Drake | Diva (Homecoming Live) | 33 | 24 | 99 | loose |
| Drake | Dizaster vs. DNA | 875 | 782 | 5803 | loose |
| Drake | Djnajndaw | 38 | 13 | 95 | loose |
| Drake | DnF | 50 | 54 | 273 | loose |
| Drake | Do It All | 44 | 24 | 233 | loose |
| Drake | Do It Now | 26 | 30 | 150 | loose |
| Drake | Do Not Disturb | 69 | 97 | 443 | loose |
| Drake | Do What You Do | 54 | 59 | 257 | loose |
| Drake | Doing His Thing | 39 | 34 | 268 | loose |
| Drake | Doing It Wrong | 19 | 6 | 53 | loose |
| Drake | Don’t Let Me Fall Asleep | 24 | 19 | 72 | loose |
| Drake | Don’t Matter to Me | 26 | 15 | 72 | loose |
| Drake | Don’t Run | 47 | 50 | 137 | loose |
| Drake | Don’t Worry | 31 | 21 | 125 | loose |
| Drake | Don’t You Have a Man | 54 | 30 | 269 | loose |
| Drake | Down Hill | 14 | 7 | 44 | loose |
| Drake | Draft Day | 53 | 42 | 307 | loose |
| Drake | Drake & DJ Semtex Interview | 2 | 0 | 9 | loose |
| Drake | Drake Speaks | 5 | 1 | 26 | ABCB |
| Drake | Drake Speaks (The Virgo Mixtape, Vol. 2) | 16 | 2 | 40 | loose |
| Drake | Drama | 37 | 18 | 69 | loose |
| Drake | Dreams Money Can Buy | 49 | 31 | 217 | loose |
| Drake | Drew A Picasso | 61 | 66 | 293 | loose |
| Drake | Duppy Freestyle | 51 | 60 | 273 | loose |
| Drake | Dust | 43 | 43 | 173 | loose |
| Drake | ESPYS: Honorable Mention | 25 | 5 | 111 | loose |
| Drake | EVERY CHANCE I GET | 58 | 86 | 405 | loose |
| Drake | EXPERIMENTAL | 1 | 0 | 0 | loose |
| Drake | Easy | 24 | 18 | 83 | loose |
| Drake | Easy to Please | 40 | 36 | 227 | loose |
| Drake | Ela É do Tipo (Remix) | 24 | 5 | 98 | loose |
| Drake | Ela É do Tipo (Remix) [Ao Vivo] | 3 | 0 | 4 | loose |
| Drake | Elevate | 30 | 53 | 163 | loose |
| Drake | Emotionless | 58 | 73 | 352 | loose |
| Drake | Emperor (Feat. Drake) - Caesars Edition | 66 | 54 | 376 | loose |
| Drake | Empire | 41 | 44 | 187 | loose |
| Drake | Energy | 44 | 18 | 191 | loose |
| Drake | Enjoy Yourself | 34 | 10 | 130 | loose |
| Drake | Enough Said | 42 | 29 | 156 | loose |
| Drake | Eurotrip 3 | 47 | 34 | 608 | loose |
| Drake | Every Girl | 69 | 28 | 338 | loose |
| Drake | Evil Ways | 56 | 153 | 523 | loose |
| Drake | Ex Factor / Nice For What | 22 | 8 | 58 | loose |
| Drake | Exposed (Voyce Diss) | 28 | 15 | 176 | loose |
| Drake | Extra Special | 45 | 31 | 296 | loose |
| Drake | F**kin’ Problems (Clean Version) | 32 | 11 | 109 | loose |
| Drake | F**kin’ Problems [Crizzly Remix] [Mixed] | 6 | 5 | 16 | loose |
| Drake | FANCY BARBIE | 38 | 39 | 229 | loose |
| Drake | FLIP THE SWITCH | 38 | 50 | 141 | loose |
| Drake | FOR ALL THE BARBZ | 27 | 27 | 145 | loose |
| Drake | Facts (Charlie Heat Version) | 50 | 35 | 239 | loose |
| Drake | Faded | 37 | 33 | 248 | loose |
| Drake | Fades Away | 62 | 34 | 118 | loose |
| Drake | Fair Trade | 79 | 53 | 344 | loose |
| Drake | Faith | 47 | 20 | 293 | loose |
| Drake | Faith Pt. 2 | 39 | 22 | 335 | loose |
| Drake | Faithful | 50 | 55 | 150 | loose |
| Drake | Fall for Your Type | 37 | 23 | 188 | loose |
| Drake | Fallen (Remix) | 61 | 46 | 213 | loose |
| Drake | Falling Back | 33 | 13 | 88 | loose |
| Drake | Family Feud | 103 | 150 | 701 | loose |
| Drake | Famous (Video Version) | 61 | 35 | 165 | loose |
| Drake | Fancy | 73 | 38 | 375 | loose |
| Drake | Faygo Creme (Playing With Racks) | 28 | 48 | 189 | loose |
| Drake | Fear | 63 | 67 | 310 | loose |
| Drake | Fear Of Heights | 58 | 40 | 175 | loose |
| Drake | Fed Up | 66 | 56 | 312 | loose |
| Drake | Feel Like You* | 2 | 0 | 5 | loose |
| Drake | Feel Love (Drake Version) | 30 | 9 | 164 | loose |
| Drake | Feel No Ways | 22 | 18 | 54 | loose |
| Drake | Feël no wayz (Yeat mix) | 23 | 3 | 56 | loose |
| Drake | Fight That Feeling* | 9 | 3 | 18 | loose |
| Drake | Fighting Irish Freestyle | 55 | 175 | 428 | loose |
| Drake | Final Fantasy | 32 | 27 | 121 | loose |
| Drake | Finale | 103 | 74 | 546 | loose |
| Drake | Find Your Love | 19 | 18 | 40 | loose |
| Drake | Finesse | 24 | 41 | 53 | loose |
| Drake | Fire & Desire | 35 | 65 | 113 | loose |
| Drake | Fire in the Booth | 78 | 54 | 471 | loose |
| Drake | Fireworks | 58 | 55 | 311 | loose |
| Drake | Firm Friends | 85 | 103 | 735 | loose |
| Drake | First Person Shooter | 69 | 71 | 442 | loose |
| Drake | Flawless / Feeling Myself (Homecoming Live) | 46 | 20 | 79 | loose |
| Drake | Flight’s Booked | 29 | 12 | 78 | loose |
| Drake | For Free | 52 | 32 | 131 | loose |
| Drake | Forever | 79 | 93 | 709 | loose |
| Drake | Forgot I Was Famous | 43 | 46 | 195 | loose |
| Drake | Fortworth | 28 | 27 | 121 | loose |
| Drake | Fountains | 28 | 15 | 66 | loose |
| Drake | Fo’ Real | 37 | 24 | 180 | loose |
| Drake | Freak In You (Remix) | 44 | 30 | 233 | loose |
| Drake | Free Smoke | 77 | 95 | 184 | loose |
| Drake | Free Spirit | 54 | 36 | 337 | loose |
| Drake | Freeze The World | 4 | 0 | 9 | loose |
| Drake | Freshman | 21 | 9 | 133 | loose |
| Drake | Friend$ With Money | 32 | 36 | 167 | loose |
| Drake | Friends | 15 | 9 | 15 | loose |
| Drake | Friends With Money | 45 | 26 | 193 | loose |
| Drake | From Florida With Love | 33 | 48 | 119 | loose |
| Drake | From Time (Demo) | 8 | 1 | 12 | loose |
| Drake | Frozen | 25 | 41 | 72 | loose |
| Drake | Fuck da Bullshit | 51 | 59 | 304 | loose |
| Drake | Fuckin Problem | 60 | 66 | 324 | loose |
| Drake | Fucking Fans | 50 | 52 | 228 | loose |
| Drake | Fuckin’ Problems (Original) | 27 | 14 | 108 | loose |
| Drake | Fun Activity Montage | 4 | 0 | 1 | loose |
| Drake | Furthest Thing | 52 | 39 | 253 | loose |
| Drake | GIMME A HUG | 49 | 69 | 344 | loose |
| Drake | GLORIOUS | 48 | 59 | 405 | loose |
| Drake | GODSPLAN | 22 | 10 | 56 | loose |
| Drake | GREECE | 43 | 23 | 111 | loose |
| Drake | GREEDY | 41 | 70 | 244 | loose |
| Drake | Gen 5 | 34 | 63 | 127 | loose |
| Drake | Genesis | 4 | 0 | 8 | loose |
| Drake | Gently | 42 | 34 | 290 | loose |
| Drake | Get Along Better | 40 | 64 | 167 | loose |
| Drake | Get It Shawty (Remix) | 24 | 11 | 75 | loose |
| Drake | Get It Together | 19 | 1 | 30 | loose |
| Drake | Get Like Me | 45 | 35 | 342 | loose |
| Drake | Get Over It | 54 | 50 | 229 | loose |
| Drake | Gift | 27 | 12 | 69 | loose |
| Drake | Girl Let Me | 29 | 40 | 189 | loose |
| Drake | Girl You Know (BedRock) | 55 | 47 | 209 | loose |
| Drake | Girls Love Beyoncé | 44 | 52 | 189 | loose |
| Drake | Girls Love Rihanna | 42 | 22 | 107 | loose |
| Drake | Girls Need Love (Remix) | 48 | 45 | 128 | loose |
| Drake | Girls Want Girls | 55 | 38 | 226 | loose |
| Drake | Give Ya | 66 | 51 | 370 | loose |
| Drake | Glow | 43 | 34 | 120 | loose |
| Drake | Go Out Tonight | 23 | 6 | 44 | loose |
| Drake | Goddess Sword X ALAYLM X Language | 12 | 4 | 26 | loose |
| Drake | Gods Plan (remix) | 13 | 5 | 31 | loose |
| Drake | God’s Plan (Demo)* | 19 | 10 | 38 | loose |
| Drake | Going Bad | 40 | 41 | 156 | loose |
| Drake | Going in for Life | 49 | 60 | 272 | loose |
| Drake | Gold Roses | 87 | 137 | 559 | loose |
| Drake | Gonorrhea | 63 | 63 | 276 | loose |
| Drake | Good Girls Go Bad | 73 | 31 | 486 | loose |
| Drake | Good Kush And Alcohol (Remix) | 27 | 20 | 183 | loose |
| Drake | Good Life | 59 | 59 | 226 | loose |
| Drake | Good Night and Good Luck | 54 | 57 | 410 | loose |
| Drake | Good Ones Go (Interlude) | 23 | 8 | 92 | loose |
| Drake | Good Riddance (Aristo Diss) | 133 | 128 | 844 | loose |
| Drake | Goose and The Juice | 25 | 18 | 89 | loose |
| Drake | Gotta Throw A Party For My Day Ones 3:40 | 62 | 75 | 257 | loose |
| Drake | Grammys | 70 | 79 | 223 | loose |
| Drake | Greatness | 27 | 34 | 112 | loose |
| Drake | Grindin’ | 85 | 78 | 347 | loose |
| Drake | Growing Up | 30 | 26 | 147 | loose |
| Drake | Gyalchester | 32 | 35 | 128 | loose |
| Drake | HEATED | 66 | 56 | 306 | loose |
| Drake | HOT UPTOWN | 35 | 29 | 110 | loose |
| Drake | HOTLINE BLING X TEENAGE FEVER | 15 | 2 | 11 | loose |
| Drake | HOW ARE THEY NOT BANNED? | 36 | 29 | 159 | loose |
| Drake | HUNCHO DREAMS | 72 | 35 | 184 | loose |
| Drake | HYFR (Hell Ya Fucking Right) | 57 | 45 | 256 | loose |
| Drake | Hate Sleeping Alone | 44 | 41 | 209 | loose |
| Drake | Haunted | 38 | 18 | 155 | loose |
| Drake | Having Our Way | 84 | 160 | 408 | loose |
| Drake | Head I.C.E vs Serius Jones | 261 | 164 | 1805 | loose |
| Drake | Headlines | 40 | 31 | 179 | loose |
| Drake | Healing | 18 | 15 | 54 | loose |
| Drake | Heart On My Sleeve Drake & Selena Vazquez | 15 | 17 | 30 | loose |
| Drake | Heartdrake | 6 | 1 | 8 | loose |
| Drake | Heat of the Moment | 26 | 3 | 90 | loose |
| Drake | Heavens EP | 43 | 46 | 339 | loose |
| Drake | High Fives | 39 | 40 | 227 | loose |
| Drake | History of Rap 5 | 65 | 23 | 244 | loose |
| Drake | Hittas | 48 | 58 | 303 | loose |
| Drake | Hoe Phase | 42 | 29 | 91 | loose |
| Drake | Hold On | 6 | 3 | 14 | loose |
| Drake | Hold On We’re Going | 3 | 1 | 3 | loose |
| Drake | Hold On, We’re Going Home (BBC Radio 1 Live Lounge) | 9 | 4 | 40 | loose |
| Drake | Honestly, Nevermind (Intro) | 10 | 19 | 148 | loose |
| Drake | Honor and Respect | 26 | 51 | 202 | loose |
| Drake | Hot 97 Freestyle | 44 | 32 | 208 | loose |
| Drake | Hot Shit | 58 | 70 | 345 | loose |
| Drake | Hotline Bling (Live From Maida Vale) | 8 | 3 | 34 | loose |
| Drake | Hotline Bling (Remix) [Mixed] | 9 | 0 | 11 | loose |
| Drake | Hotline Bling / party favor | 31 | 15 | 95 | loose |
| Drake | Hours In Silence | 94 | 101 | 311 | loose |
| Drake | Housekeeping Knows | 32 | 31 | 127 | loose |
| Drake | Houstatlantavegas | 38 | 39 | 141 | loose |
| Drake | Houstatlantavegas Pains | 20 | 29 | 40 | loose |
| Drake | How Bout Now | 40 | 10 | 183 | loose |
| Drake | HumpDay HipHop 2: 0 to 100 (Real Fuckin Quick) | 51 | 66 | 909 | loose |
| Drake | Hungrybox Da Bess You Ever Had | 85 | 39 | 184 | loose |
| Drake | Hurrr Nor Thurrr | 41 | 61 | 189 | loose |
| Drake | Hush It Up | 35 | 26 | 145 | loose |
| Drake | Hype | 64 | 93 | 127 | loose |
| Drake | I Been That Girl | 25 | 20 | 83 | loose |
| Drake | I Could Never | 23 | 9 | 58 | loose |
| Drake | I Did (Grand Entrance) | 26 | 29 | 108 | loose |
| Drake | I Do (Remix) | 76 | 69 | 477 | loose |
| Drake | I Do It | 73 | 66 | 410 | loose |
| Drake | I Do This | 20 | 9 | 77 | loose |
| Drake | I Get Lonely | 25 | 13 | 57 | loose |
| Drake | I Get Paper | 35 | 38 | 138 | loose |
| Drake | I Guess It’s Fuck Me | 58 | 153 | 267 | loose |
| Drake | I Hate You I Love You & Too Good | 31 | 13 | 51 | loose |
| Drake | I Invented Sex | 52 | 38 | 206 | loose |
| Drake | I Stay Fly | 35 | 22 | 184 | loose |
| Drake | I Want This Forever | 50 | 32 | 266 | loose |
| Drake | ID1 (from All The Reason Live at Lost Lands 2025) / Pop That [Mixed] | 3 | 1 | 3 | loose |
| Drake | IDGAF | 63 | 73 | 295 | loose |
| Drake | IMY2 | 37 | 35 | 150 | loose |
| Drake | Ice Melts | 25 | 14 | 67 | loose |
| Drake | If you can meet | 2 | 0 | 7 | loose |
| Drake | Ignant Shit | 102 | 137 | 558 | loose |
| Drake | Imma Take Yo Girl | 52 | 41 | 360 | loose |
| Drake | In My Business | 12 | 15 | 66 | loose |
| Drake | In My Feelings (Drake Remix) | 50 | 31 | 165 | loose |
| Drake | In The Bible | 47 | 35 | 236 | loose |
| Drake | In the Cut | 36 | 29 | 164 | loose |
| Drake | In the Morning | 57 | 48 | 340 | loose |
| Drake | Insubordonné | 34 | 17 | 531 | loose |
| Drake | Intro (Room For Improvement) | 18 | 5 | 90 | loose |
| Drake | Is There More | 63 | 122 | 303 | loose |
| Drake | Issa | 88 | 88 | 548 | loose |
| Drake | It’s Been A Pleasure | 32 | 37 | 163 | loose |
| Drake | It’s Good | 59 | 39 | 334 | loose |
| Drake | It’s Up | 62 | 78 | 623 | loose |
| Drake | It’s gonna be me | 26 | 12 | 40 | loose |
| Drake | I’d Do Anything to Make You Smile | 29 | 26 | 150 | loose |
| Drake | I’m A Baby (Wah Wah Wah) | 5 | 1 | 5 | loose |
| Drake | I’m Goin In | 47 | 50 | 291 | loose |
| Drake | I’m On One | 62 | 55 | 328 | loose |
| Drake | I’m Ready For Ya | 5 | 3 | 18 | loose |
| Drake | I’m Ready For You | 47 | 32 | 171 | loose |
| Drake | I’m Single | 60 | 52 | 181 | loose |
| Drake | I’m Spent | 29 | 60 | 123 | loose |
| Drake | I’m Still | 74 | 59 | 277 | loose |
| Drake | I’m Still Fly (Freestyle) | 54 | 49 | 309 | loose |
| Drake | I’m Still Fly Freestyle | 20 | 12 | 117 | loose |
| Drake | I’m The Problem (Still A Good Man) | 31 | 37 | 102 | loose |
| Drake | I’m Upset | 34 | 59 | 205 | loose |
| Drake | I’m the Plug | 36 | 41 | 128 | loose |
| Drake | Jaded | 45 | 63 | 174 | loose |
| Drake | Janice STFU | 52 | 60 | 395 | loose |
| Drake | Jimmy Cooks | 36 | 60 | 201 | loose |
| Drake | Jimmy Cooks [Mixed] | 3 | 0 | 6 | loose |
| Drake | Jodeci Freestyle | 84 | 49 | 455 | loose |
| Drake | Jorja Interlude | 30 | 21 | 66 | loose |
| Drake | Juice | 32 | 48 | 154 | loose |
| Drake | July | 46 | 47 | 174 | loose |
| Drake | Jumbotron Shit Poppin | 28 | 43 | 194 | loose |
| Drake | Jump Man (Remix) | 22 | 18 | 116 | loose |
| Drake | Jumpan (Don Diablo Remix) | 6 | 6 | 8 | loose |
| Drake | Jumpman | 47 | 46 | 197 | loose |
| Drake | Jumpman freestyle | 1 | 0 | 1 | loose |
| Drake | Jungle | 43 | 31 | 94 | loose |
| Drake | Jungle (Drake Rework) Ft. CJ Trillo | 34 | 32 | 126 | loose |
| Drake | Jus Know (Demo) | 42 | 33 | 118 | loose |
| Drake | Just Another Interlude | 63 | 40 | 254 | loose |
| Drake | K-9 | 11 | 11 | 39 | loose |
| Drake | KMT | 36 | 66 | 122 | loose |
| Drake | KMT / Lovin’ You (Remix) [Mixed] | 6 | 0 | 5 | loose |
| Drake | Keep Calm | 40 | 29 | 104 | loose |
| Drake | Keep The Faith | 51 | 36 | 133 | loose |
| Drake | Keep the Family Close | 49 | 51 | 251 | loose |
| Drake | Kendrick a Meanie | 18 | 19 | 26 | loose |
| Drake | Kick, Push (Remix) | 88 | 76 | 412 | loose |
| Drake | Killer | 38 | 53 | 198 | loose |
| Drake | King Leon (Street Cred) | 19 | 14 | 94 | loose |
| Drake | Knife Talk | 48 | 55 | 306 | loose |
| Drake | Know Bout Me | 54 | 42 | 225 | loose |
| Drake | LASERS | 30 | 23 | 126 | loose |
| Drake | LOYAL | 24 | 32 | 67 | loose |
| Drake | Lake Como* | 32 | 74 | 112 | loose |
| Drake | Landed | 36 | 47 | 156 | loose |
| Drake | Laugh Now Cry Later | 35 | 53 | 233 | loose |
| Drake | Lazy | 92 | 33 | 195 | loose |
| Drake | Left you again | 5 | 2 | 8 | loose |
| Drake | Legend | 29 | 8 | 83 | loose |
| Drake | Lemon (Drake Remix) | 52 | 47 | 140 | loose |
| Drake | Lemon Pepper Freestyle | 116 | 167 | 689 | loose |
| Drake | Let Em Know I’m Real | 28 | 18 | 209 | loose |
| Drake | Let Me Love You & Come and See Me | 31 | 15 | 139 | loose |
| Drake | Let’s Call It Off | 26 | 14 | 87 | loose |
| Drake | Liability | 27 | 31 | 158 | loose |
| Drake | Lie To Me | 38 | 25 | 192 | loose |
| Drake | Life Is Good | 56 | 79 | 397 | loose |
| Drake | Light Up | 71 | 58 | 326 | loose |
| Drake | Like I’m Supposed To/Do Things | 16 | 7 | 19 | loose |
| Drake | Little Birdie | 36 | 49 | 211 | loose |
| Drake | Little Bit | 47 | 18 | 142 | loose |
| Drake | Live For | 32 | 28 | 219 | loose |
| Drake | Live Up to My Name | 37 | 60 | 201 | loose |
| Drake | Live from the Gutter | 50 | 47 | 273 | loose |
| Drake | Lollipop / Plain Jane / Praise The Lord / Jimmy Cooks [Mixed] | 17 | 12 | 115 | loose |
| Drake | London Tour Freestyle | 18 | 11 | 93 | loose |
| Drake | Lonely | 12 | 3 | 14 | loose |
| Drake | Look Alight | 3 | 3 | 13 | loose |
| Drake | Look Alive | 44 | 38 | 156 | loose |
| Drake | Look What You’ve Done | 74 | 49 | 298 | loose |
| Drake | Lord Knows | 78 | 72 | 468 | loose |
| Drake | Lose My Mind (Remix) | 53 | 32 | 228 | loose |
| Drake | Lose You | 83 | 112 | 421 | loose |
| Drake | Losses | 63 | 80 | 309 | loose |
| Drake | Lotta 42 | 19 | 50 | 66 | loose |
| Drake | Love All | 43 | 37 | 188 | loose |
| Drake | Love And Gunz | 21 | 17 | 37 | loose |
| Drake | Love Me | 50 | 23 | 164 | loose |
| Drake | Love My Team | 45 | 23 | 197 | loose |
| Drake | Love You Like I Do | 40 | 46 | 181 | loose |
| Drake | Love You More Than Always | 51 | 75 | 204 | loose |
| Drake | Love is Magic | 33 | 43 | 133 | loose |
| Drake | Loving You No More | 47 | 28 | 182 | loose |
| Drake | Loyalty (Remix) | 79 | 68 | 551 | loose |
| Drake | Lucky Lefty | 57 | 117 | 317 | loose |
| Drake | Lust 4 Love | 45 | 28 | 109 | loose |
| Drake | Lust for Life | 30 | 18 | 106 | loose |
| Drake | M1S3RY | 36 | 30 | 232 | loose |
| Drake | MADE YOU MINE | 36 | 48 | 194 | loose |
| Drake | MARLON’S ROOM | 27 | 7 | 74 | loose |
| Drake | MEET YOUR PADRE | 34 | 25 | 219 | loose |
| Drake | MELTDOWN | 70 | 89 | 352 | loose |
| Drake | MENTOS EN MI LENGUA | 15 | 12 | 197 | loose |
| Drake | MIA | 36 | 31 | 235 | loose |
| Drake | MORE LOVE | 44 | 27 | 238 | loose |
| Drake | MORE THAN BESTFRIENDS | 24 | 12 | 150 | loose |
| Drake | MOTH BALLS | 36 | 59 | 117 | loose |
| Drake | MR RECOUP | 37 | 57 | 170 | loose |
| Drake | MSG Freestyle (Hot 97) | 4 | 6 | 20 | ABBA |
| Drake | Made | 49 | 48 | 278 | loose |
| Drake | Made Men | 68 | 42 | 317 | loose |
| Drake | Madiba Riddim | 18 | 22 | 64 | loose |
| Drake | Madonna | 34 | 22 | 117 | loose |
| Drake | Mafia Music | 67 | 59 | 351 | loose |
| Drake | Major Distribution | 42 | 36 | 255 | loose |
| Drake | Major Distribution (Mixed) | 4 | 0 | 15 | loose |
| Drake | Make It Go | 40 | 41 | 115 | loose |
| Drake | Make Me Proud | 55 | 28 | 255 | loose |
| Drake | Make Them Cry | 78 | 179 | 700 | loose |
| Drake | Make Them Know | 80 | 138 | 213 | loose |
| Drake | Make Them Pay | 57 | 115 | 498 | loose |
| Drake | Make Them Remember | 102 | 232 | 793 | loose |
| Drake | Make Things Right | 42 | 41 | 229 | loose |
| Drake | Man of the Year | 75 | 88 | 428 | loose |
| Drake | March 14 | 57 | 56 | 257 | loose |
| Drake | Marvin’s Room | 55 | 37 | 252 | loose |
| Drake | Marvin’s Room JBMix | 20 | 4 | 68 | loose |
| Drake | Mashup Week | 8 | 3 | 21 | loose |
| Drake | Massive | 23 | 7 | 55 | loose |
| Drake | Massive (Remix) [Mixed] | 24 | 24 | 81 | loose |
| Drake | Massive / Faded (Mixed) | 4 | 0 | 1 | loose |
| Drake | Masterpiece | 92 | 109 | 451 | loose |
| Drake | Members Only | 54 | 45 | 244 | loose |
| Drake | Mention Me | 37 | 29 | 105 | loose |
| Drake | Messages From You | 19 | 19 | 80 | loose |
| Drake | Mi Gente (Homecoming Live) | 39 | 13 | 160 | loose |
| Drake | Middle of the Ocean | 108 | 149 | 546 | loose |
| Drake | Mine | 57 | 19 | 193 | loose |
| Drake | Miss Me | 78 | 63 | 415 | loose |
| Drake | Missin’ You (Freestyle) | 57 | 25 | 247 | loose |
| Drake | Mo Milly | 64 | 69 | 311 | loose |
| Drake | Mob Ties | 37 | 26 | 108 | loose |
| Drake | Modo Capone | 25 | 6 | 205 | loose |
| Drake | Moment 4 Life | 60 | 64 | 228 | loose |
| Drake | Money (Remix) | 48 | 44 | 344 | loose |
| Drake | Money in the Bank | 27 | 28 | 71 | loose |
| Drake | Money in the Grave | 56 | 79 | 305 | loose |
| Drake | Money to Blow | 63 | 41 | 261 | loose |
| Drake | More Life / Over the Top [CAIEL Remix] [Mixed] | 3 | 1 | 14 | loose |
| Drake | More Milli | 31 | 18 | 210 | loose |
| Drake | More M’s | 48 | 47 | 264 | loose |
| Drake | More Ready | 14 | 10 | 85 | loose |
| Drake | More Than A Meme | 70 | 48 | 209 | loose |
| Drake | More Than a Hustla | 32 | 17 | 115 | loose |
| Drake | Motto remix | 11 | 9 | 171 | loose |
| Drake | Mr. Right Now | 48 | 28 | 238 | loose |
| Drake | Mr. Wrong | 44 | 26 | 108 | loose |
| Drake | Must Hate Money | 65 | 75 | 372 | loose |
| Drake | Mustafa (time to move you) | 18 | 11 | 45 | loose |
| Drake | Mute | 52 | 32 | 218 | loose |
| Drake | My Chargie | 15 | 26 | 56 | loose |
| Drake | My Darlin Baby | 71 | 76 | 287 | loose |
| Drake | My Love | 22 | 8 | 79 | loose |
| Drake | My New Shit | 46 | 62 | 214 | loose |
| Drake | My Side | 40 | 15 | 108 | loose |
| Drake | My Way (Remix) | 44 | 49 | 167 | loose |
| Drake | My dick | 8 | 5 | 12 | AABB |
| Drake | MÍA (Dom Da Bomb Remix) | 31 | 30 | 187 | loose |
| Drake | N 2 Deep | 58 | 35 | 216 | loose |
| Drake | NEWEST | 34 | 19 | 103 | loose |
| Drake | NINE ONE FIVE | 23 | 24 | 142 | loose |
| Drake | NO SECRET | 13 | 10 | 32 | loose |
| Drake | NOKIA | 45 | 32 | 129 | loose |
| Drake | Nacho’s freestyle | 1 | 0 | 0 | loose |
| Drake | Nah Nah | 10 | 9 | 16 | loose |
| Drake | Naive | 26 | 14 | 57 | loose |
| Drake | National Treasures | 52 | 77 | 286 | loose |
| Drake | Neatly | 45 | 32 | 229 | loose |
| Drake | Needle | 47 | 28 | 279 | loose |
| Drake | Never Recover | 82 | 163 | 426 | loose |
| Drake | Never Satisfied | 29 | 33 | 118 | loose |
| Drake | Never Spin Without Me* | 23 | 2 | 73 | loose |
| Drake | New Bestie | 66 | 109 | 286 | loose |
| Drake | New Shit | 52 | 37 | 358 | loose |
| Drake | Nice For What | 51 | 28 | 133 | loose |
| Drake | Nice For What/Friends/No Scrubs | 45 | 28 | 120 | loose |
| Drake | Night | 28 | 12 | 117 | loose |
| Drake | Nikki Beach | 46 | 31 | 246 | loose |
| Drake | No Brakes | 36 | 25 | 165 | loose |
| Drake | No Complaints | 63 | 122 | 145 | loose |
| Drake | No Disguise | 12 | 13 | 32 | loose |
| Drake | No Face | 33 | 31 | 141 | loose |
| Drake | No Frauds | 63 | 53 | 331 | loose |
| Drake | No Friends In The Industry | 48 | 60 | 252 | loose |
| Drake | No Good* | 18 | 19 | 81 | loose |
| Drake | No Guidance | 47 | 60 | 251 | loose |
| Drake | No Guns Allowed | 32 | 28 | 127 | loose |
| Drake | No Lie | 62 | 41 | 239 | loose |
| Drake | No Long Talk | 50 | 52 | 344 | loose |
| Drake | No Manners | 17 | 12 | 131 | loose |
| Drake | No New Friends | 62 | 31 | 169 | loose |
| Drake | No Shopping | 53 | 40 | 257 | loose |
| Drake | No Stylist | 28 | 21 | 126 | loose |
| Drake | No Tellin’ | 62 | 44 | 304 | loose |
| Drake | No game | 39 | 36 | 163 | loose |
| Drake | Nonstop | 56 | 62 | 298 | loose |
| Drake | Not New To This | 77 | 37 | 546 | loose |
| Drake | Not Nice | 24 | 20 | 47 | loose |
| Drake | Not You Too | 40 | 31 | 112 | loose |
| Drake | Nothing At All | 17 | 3 | 10 | loose |
| Drake | Nothings Into Somethings | 14 | 11 | 46 | loose |
| Drake | Notification Bling | 8 | 2 | 9 | loose |
| Drake | November 18th | 36 | 11 | 210 | loose |
| Drake | Now & Forever | 36 | 40 | 172 | loose |
| Drake | Number 15 | 52 | 49 | 218 | loose |
| Drake | OMDB | 28 | 34 | 146 | loose |
| Drake | OMG (Remix) | 39 | 58 | 303 | loose |
| Drake | OMW | 31 | 39 | 100 | loose |
| Drake | OVO Sound Radio Episode 10 Tracklist | 51 | 12 | 139 | loose |
| Drake | OVO Sound Radio Episode 11 Tracklist | 31 | 7 | 88 | loose |
| Drake | OVO Sound Radio Episode 12 Tracklist | 40 | 11 | 82 | loose |
| Drake | OVO Sound Radio Episode 13 Tracklist | 51 | 8 | 180 | loose |
| Drake | OVO Sound Radio Episode 14 Tracklist | 27 | 3 | 93 | loose |
| Drake | OVO Sound Radio Episode 15 Tracklist | 42 | 9 | 156 | loose |
| Drake | OVO Sound Radio Episode 16 Tracklist | 31 | 9 | 49 | loose |
| Drake | OVO Sound Radio Episode 17 Tracklist | 32 | 4 | 62 | loose |
| Drake | OVO Sound Radio Episode 18 Tracklist | 41 | 11 | 56 | loose |
| Drake | OVO Sound Radio Episode 19 Tracklist | 22 | 2 | 44 | loose |
| Drake | OVO Sound Radio Episode 2 Tracklist | 37 | 6 | 80 | loose |
| Drake | OVO Sound Radio Episode 21 Tracklist | 47 | 17 | 88 | loose |
| Drake | OVO Sound Radio Episode 22 Tracklist | 34 | 6 | 106 | loose |
| Drake | OVO Sound Radio Episode 23 Tracklist | 35 | 5 | 110 | loose |
| Drake | OVO Sound Radio Episode 24 Tracklist | 39 | 13 | 82 | loose |
| Drake | OVO Sound Radio Episode 25 Tracklist | 44 | 8 | 103 | loose |
| Drake | OVO Sound Radio Episode 26 Tracklist | 33 | 2 | 53 | loose |
| Drake | OVO Sound Radio Episode 27 Tracklist | 23 | 4 | 24 | loose |
| Drake | OVO Sound Radio Episode 28 Tracklist | 35 | 8 | 76 | loose |
| Drake | OVO Sound Radio Episode 29 Tracklist | 48 | 15 | 162 | loose |
| Drake | OVO Sound Radio Episode 3 Tracklist | 27 | 10 | 83 | loose |
| Drake | OVO Sound Radio Episode 30 Tracklist | 54 | 12 | 138 | loose |
| Drake | OVO Sound Radio Episode 31 Tracklist | 48 | 13 | 146 | loose |
| Drake | OVO Sound Radio Episode 32 Tracklist | 28 | 9 | 75 | loose |
| Drake | OVO Sound Radio Episode 33 Tracklist | 33 | 10 | 80 | loose |
| Drake | OVO Sound Radio Episode 34 Tracklist | 57 | 15 | 191 | loose |
| Drake | OVO Sound Radio Episode 35 Tracklist | 69 | 20 | 164 | loose |
| Drake | OVO Sound Radio Episode 36 Tracklist | 34 | 5 | 74 | loose |
| Drake | OVO Sound Radio Episode 38 Tracklist | 24 | 1 | 61 | loose |
| Drake | OVO Sound Radio Episode 39 Tracklist | 19 | 6 | 53 | loose |
| Drake | OVO Sound Radio Episode 4 Tracklist | 26 | 8 | 49 | loose |
| Drake | OVO Sound Radio Episode 40 Tracklist | 39 | 11 | 150 | loose |
| Drake | OVO Sound Radio Episode 41 Tracklist | 23 | 4 | 58 | loose |
| Drake | OVO Sound Radio Episode 42 Tracklist | 33 | 13 | 93 | loose |
| Drake | OVO Sound Radio Episode 43 Tracklist | 51 | 21 | 169 | loose |
| Drake | OVO Sound Radio Episode 44 Tracklist | 27 | 4 | 61 | loose |
| Drake | OVO Sound Radio Episode 45 Tracklist | 31 | 6 | 79 | loose |
| Drake | OVO Sound Radio Episode 46 Tracklist | 34 | 3 | 92 | loose |
| Drake | OVO Sound Radio Episode 47 Tracklist | 29 | 12 | 73 | loose |
| Drake | OVO Sound Radio Episode 48 Tracklist | 26 | 3 | 110 | loose |
| Drake | OVO Sound Radio Episode 49 Tracklist | 45 | 3 | 88 | loose |
| Drake | OVO Sound Radio Episode 5 Tracklist | 58 | 18 | 98 | loose |
| Drake | OVO Sound Radio Episode 51 Tracklist | 49 | 12 | 110 | loose |
| Drake | OVO Sound Radio Episode 52 Tracklist | 28 | 8 | 74 | loose |
| Drake | OVO Sound Radio Episode 53 Tracklist | 45 | 12 | 128 | loose |
| Drake | OVO Sound Radio Episode 54 Tracklist | 38 | 13 | 77 | loose |
| Drake | OVO Sound Radio Episode 55 Tracklist | 21 | 4 | 57 | loose |
| Drake | OVO Sound Radio Episode 56 Tracklist | 42 | 12 | 141 | loose |
| Drake | OVO Sound Radio Episode 57 Tracklist | 60 | 17 | 124 | loose |
| Drake | OVO Sound Radio Episode 58 Tracklist | 43 | 6 | 131 | loose |
| Drake | OVO Sound Radio Episode 59 Tracklist | 38 | 7 | 126 | loose |
| Drake | OVO Sound Radio Episode 6 Tracklist | 17 | 4 | 32 | loose |
| Drake | OVO Sound Radio Episode 60 Tracklist | 35 | 7 | 65 | loose |
| Drake | OVO Sound Radio Episode 61 Tracklist | 51 | 11 | 153 | loose |
| Drake | OVO Sound Radio Episode 62 Tracklist | 40 | 3 | 87 | loose |
| Drake | OVO Sound Radio Episode 63 Tracklist | 44 | 8 | 135 | loose |
| Drake | OVO Sound Radio Episode 64 Tracklist | 33 | 6 | 78 | loose |
| Drake | OVO Sound Radio Episode 65 Tracklist | 12 | 3 | 55 | loose |
| Drake | OVO Sound Radio Episode 66 Tracklist | 35 | 10 | 141 | loose |
| Drake | OVO Sound Radio Episode 68 Tracklist | 48 | 12 | 208 | loose |
| Drake | OVO Sound Radio Episode 7 Tracklist | 56 | 21 | 195 | loose |
| Drake | OVO Sound Radio Episode 8 Tracklist | 40 | 16 | 107 | loose |
| Drake | OVO Sound Radio Episode 9 Tracklist | 47 | 9 | 225 | loose |
| Drake | OVO Sound Radio [Setlists] | 21 | 5 | 32 | loose |
| Drake | October’s Very Own* | 4 | 1 | 2 | loose |
| Drake | Odio | 38 | 25 | 180 | loose |
| Drake | Off That | 68 | 42 | 146 | loose |
| Drake | Oh U Went | 43 | 53 | 159 | loose |
| Drake | Ojuelegba (Remix) | 58 | 53 | 279 | loose |
| Drake | Omertà | 68 | 99 | 369 | loose |
| Drake | On BS | 59 | 74 | 287 | loose |
| Drake | On BS (Remix) [Mixed] | 6 | 4 | 16 | loose |
| Drake | On My Way | 21 | 10 | 63 | loose |
| Drake | On The Radar Freestyle | 74 | 154 | 915 | loose |
| Drake | On a Wave | 30 | 23 | 84 | loose |
| Drake | On the Level / Passionfruit (Mixed) | 5 | 1 | 11 | loose |
| Drake | One Dance (Dub) | 20 | 12 | 72 | loose |
| Drake | One Day (Remix) | 37 | 74 | 210 | loose |
| Drake | One Life | 35 | 19 | 120 | loose |
| Drake | One Man Show | 29 | 20 | 155 | loose |
| Drake | One More Time | 36 | 29 | 219 | loose |
| Drake | One Night Stand | 35 | 31 | 86 | loose |
| Drake | Only (Target Version) | 11 | 3 | 61 | loose |
| Drake | Only Me (Me & U Original) | 35 | 26 | 91 | loose |
| Drake | Only You Freestyle | 96 | 158 | 513 | loose |
| Drake | Ooovrrr | 10 | 7 | 25 | loose |
| Drake | Open | 30 | 7 | 70 | loose |
| Drake | Oprah’s Bank Account | 42 | 35 | 176 | loose |
| Drake | Organization | 49 | 108 | 168 | loose |
| Drake | Our Little Secret | 12 | 3 | 26 | loose |
| Drake | Out Loud* | 10 | 6 | 65 | loose |
| Drake | Outside Tweaking | 39 | 45 | 91 | loose |
| Drake | Outta Time | 32 | 17 | 95 | loose |
| Drake | Over | 44 | 36 | 246 | loose |
| Drake | Over / Silent Hill (Mixed) | 30 | 22 | 164 | loose |
| Drake | Over Here | 42 | 23 | 166 | loose |
| Drake | Over My Dead Body | 62 | 34 | 279 | loose |
| Drake | Over the Top | 59 | 81 | 264 | loose |
| Drake | Overdose | 89 | 60 | 518 | loose |
| Drake | Overdrive | 32 | 8 | 75 | loose |
| Drake | Own It | 44 | 13 | 142 | loose |
| Drake | P power | 34 | 47 | 178 | loose |
| Drake | P-Top* | 25 | 34 | 117 | loose |
| Drake | PIMMIE’S DILEMMA | 15 | 5 | 80 | loose |
| Drake | PLUGGLOVE | 56 | 59 | 230 | loose |
| Drake | POPKNG | 10 | 9 | 21 | loose |
| Drake | POPSTAR | 40 | 42 | 193 | loose |
| Drake | Pac-Man Battle Royale | 32 | 7 | 118 | loose |
| Drake | Pain 1993 | 40 | 55 | 180 | loose |
| Drake | Papi’s Home | 50 | 59 | 196 | loose |
| Drake | Parade on Cleveland | 44 | 41 | 167 | loose |
| Drake | Paris Morton Music | 22 | 14 | 114 | loose |
| Drake | Pass the Dutch | 73 | 107 | 494 | loose |
| Drake | Passionfruit | 22 | 5 | 61 | loose |
| Drake | Passionfruit & Loyalty | 30 | 14 | 57 | loose |
| Drake | Passionfruit - triple j Like A Version | 5 | 1 | 18 | loose |
| Drake | Payback | 8 | 1 | 26 | loose |
| Drake | Peak | 23 | 16 | 46 | loose |
| Drake | Peer Editing [Smoothie Blue Remix] | 101 | 87 | 479 | loose |
| Drake | Piece of Me* | 12 | 15 | 59 | loose |
| Drake | Pipe Down | 44 | 69 | 247 | loose |
| Drake | Pistol In My Bed | 17 | 5 | 137 | loose |
| Drake | Pistols | 16 | 6 | 74 | loose |
| Drake | Plastic Bag | 28 | 15 | 128 | loose |
| Drake | Playball | 26 | 21 | 93 | loose |
| Drake | Please Don’t Fall In Love With Me | 40 | 25 | 150 | loose |
| Drake | Plenty (Wet Up) | 24 | 32 | 88 | loose |
| Drake | Plot Twist | 37 | 17 | 382 | loose |
| Drake | Poetic Justice (Retrial) | 37 | 24 | 95 | loose |
| Drake | Poetic Justice [A Party Called Tribe Remix] [Mixed] | 8 | 2 | 70 | loose |
| Drake | Poetic Justice [Remix] [Mixed] [Tomorrowland 2024: Acraze] | 4 | 1 | 28 | loose |
| Drake | Polar Opposites | 38 | 48 | 140 | loose |
| Drake | Pop Rosé | 52 | 36 | 210 | loose |
| Drake | Pop Style | 41 | 33 | 133 | loose |
| Drake | Pop That | 94 | 82 | 334 | loose |
| Drake | Poppin Bottles | 63 | 50 | 389 | loose |
| Drake | Portland | 59 | 58 | 303 | loose |
| Drake | Practice | 39 | 31 | 164 | loose |
| Drake | Praise The Lord & Khalil (Interlude) | 24 | 6 | 119 | loose |
| Drake | Preach | 42 | 32 | 133 | loose |
| Drake | Preacher(Explicit) | 12 | 3 | 83 | loose |
| Drake | Princess | 25 | 9 | 110 | loose |
| Drake | Prioritizing | 30 | 38 | 152 | loose |
| Drake | Privileged Rappers | 31 | 48 | 225 | loose |
| Drake | Problemi | 35 | 37 | 309 | loose |
| Drake | Push Ups | 76 | 102 | 548 | loose |
| Drake | Pussy & Millions | 70 | 105 | 269 | loose |
| Drake | Put It Down | 63 | 62 | 434 | loose |
| Drake | Q&A | 24 | 23 | 174 | loose |
| Drake | R&B Princess from the Eastside of Toronto | 7 | 4 | 24 | loose |
| Drake | R.I.C.O. | 51 | 30 | 268 | loose |
| Drake | R.I.P. | 27 | 25 | 88 | loose |
| Drake | RAINING IN HOUSTON | 39 | 38 | 191 | loose |
| Drake | Race My Mind | 43 | 22 | 182 | loose |
| Drake | Ran To Atlanta | 57 | 55 | 385 | loose |
| Drake | Ransom | 99 | 86 | 694 | loose |
| Drake | Ratchet Happy Birthday | 27 | 17 | 59 | loose |
| Drake | Real Bad Karma | 40 | 55 | 144 | loose |
| Drake | Real/Dream Life Music (Remix) Drake (HOOK) | 32 | 25 | 121 | loose |
| Drake | Recognize | 54 | 36 | 216 | loose |
| Drake | Red Button | 43 | 146 | 290 | AAAA |
| Drake | Redemption | 70 | 62 | 313 | loose |
| Drake | Replacement Girl | 44 | 23 | 269 | loose |
| Drake | Resurgence and Resilience: Elijah Sommerz Steps Into a New Era With the Anticipated EP “No Days Off” | 5 | 1 | 13 | loose |
| Drake | Revenge (Summer Sixteen Original) | 36 | 26 | 122 | loose |
| Drake | Rewind | 30 | 7 | 353 | loose |
| Drake | Rich Baby Daddy | 57 | 54 | 215 | loose |
| Drake | Rich Baby Daddy [Remix] [Mixed] [Matroda b2b San Pacho] | 6 | 2 | 6 | loose |
| Drake | Rich Flex | 47 | 28 | 170 | loose |
| Drake | Rich Flex (Edit) / 24'S (Mixed) | 8 | 3 | 19 | loose |
| Drake | Rich Flex (Mixed) | 6 | 5 | 14 | loose |
| Drake | Rich Flex (Mixed) [Jan 2023] | 4 | 1 | 18 | loose |
| Drake | Ride / Circo Loco (Mixed) | 4 | 1 | 13 | loose |
| Drake | Ride With Me | 15 | 14 | 72 | loose |
| Drake | Right Above It | 60 | 78 | 326 | loose |
| Drake | Right Hand | 34 | 20 | 101 | loose |
| Drake | Right Here | 27 | 7 | 125 | loose |
| Drake | Right to Left | 36 | 20 | 167 | loose |
| Drake | Ring a Ding | 15 | 12 | 25 | loose |
| Drake | Road Trips | 39 | 51 | 239 | loose |
| Drake | Rock The Bed | 33 | 28 | 136 | loose |
| Drake | Rone vs Big T | 388 | 391 | 2726 | loose |
| Drake | Round of Applause | 52 | 44 | 302 | loose |
| Drake | Runaway (Free Larry Hoover Benefit Concert Version) | 48 | 34 | 170 | loose |
| Drake | Runaway Girl | 31 | 24 | 49 | loose |
| Drake | Rusty Intro | 15 | 12 | 62 | loose |
| Drake | S.O.Y. | 26 | 12 | 61 | loose |
| Drake | S.T.R.E.S.S. | 68 | 55 | 407 | loose |
| Drake | SERIOUS | 22 | 23 | 61 | loose |
| Drake | SERIOUS / MY HEART* | 13 | 5 | 31 | loose |
| Drake | SICKO MODE (Skrillex Remix) | 9 | 7 | 44 | loose |
| Drake | SIRENS | 49 | 69 | 125 | loose |
| Drake | SLIDE IN | 43 | 18 | 168 | loose |
| Drake | SMALL TOWN FAME | 38 | 45 | 168 | loose |
| Drake | SMOKED OUT | 50 | 38 | 287 | loose |
| Drake | SNL: Bag Jackin Bitches | 18 | 5 | 95 | loose |
| Drake | SNL: Bar Mitzvah in 1999 | 20 | 11 | 85 | loose |
| Drake | SOD | 33 | 36 | 136 | loose |
| Drake | SOMEBODY LOVES ME | 31 | 31 | 93 | loose |
| Drake | SOMEBODY LOVES ME PT. 2 | 33 | 52 | 131 | loose |
| Drake | SOMETHING ABOUT YOU | 43 | 48 | 152 | loose |
| Drake | SON PALE$ | 41 | 22 | 354 | loose |
| Drake | SPIDER-MAN SUPERMAN | 37 | 27 | 132 | loose |
| Drake | STAYING ALIVE | 32 | 34 | 188 | loose |
| Drake | Sacrifices | 101 | 141 | 448 | loose |
| Drake | Same 4 G’s | 29 | 22 | 295 | loose |
| Drake | Same Mistakes (Fall For Your Type) | 26 | 11 | 152 | loose |
| Drake | Samer Versace Remix | 28 | 26 | 226 | loose |
| Drake | Sandra’s Rose | 51 | 68 | 327 | loose |
| Drake | Say Hello | 42 | 31 | 251 | loose |
| Drake | Say My Name | 94 | 65 | 627 | loose |
| Drake | Say She Want A Hubby | 31 | 44 | 204 | loose |
| Drake | Say Something | 41 | 36 | 210 | loose |
| Drake | Say What’s Real | 74 | 66 | 324 | loose |
| Drake | Schemin’ Up | 80 | 73 | 373 | loose |
| Drake | Scholarships | 48 | 44 | 152 | loose |
| Drake | Scorpion Intro | 4 | 3 | 16 | loose |
| Drake | Screw The World (Interlude) | 24 | 10 | 110 | loose |
| Drake | Scriptures | 65 | 59 | 345 | loose |
| Drake | Search & Rescue | 37 | 21 | 142 | loose |
| Drake | Secrets | 15 | 6 | 40 | loose |
| Drake | See Bout It | 46 | 52 | 219 | loose |
| Drake | Seeing Green | 103 | 145 | 795 | loose |
| Drake | Self-Actualization [Smoothie Blue Remix] | 109 | 104 | 606 | loose |
| Drake | Selling The Century | 14 | 9 | 68 | loose |
| Drake | Separate LivesVer | 22 | 12 | 111 | loose |
| Drake | Sex Tonight | 12 | 4 | 18 | loose |
| Drake | Sh!t (Remix) | 55 | 37 | 276 | loose |
| Drake | Shabang | 47 | 60 | 131 | loose |
| Drake | Shake That Ass Bitch / Rich Baby Daddy [Mixed] | 10 | 3 | 35 | loose |
| Drake | Share | 13 | 1 | 35 | loose |
| Drake | She Got Me | 5 | 1 | 9 | loose |
| Drake | She Just Wanna Dance | 22 | 9 | 57 | loose |
| Drake | She Will | 40 | 21 | 243 | loose |
| Drake | She Will Freestyle | 48 | 80 | 173 | AAAA |
| Drake | Sho Me Love | 42 | 67 | 244 | loose |
| Drake | Shorty Grindin | 53 | 46 | 357 | loose |
| Drake | Shot Clock | 32 | 21 | 138 | loose |
| Drake | Shot for Me | 40 | 26 | 180 | loose |
| Drake | Shotty Horroh vs. Hitman Holla | 267 | 303 | 1980 | loose |
| Drake | Show Me a Good Time | 41 | 17 | 150 | loose |
| Drake | Shut It Down | 77 | 38 | 264 | loose |
| Drake | Shutdown | 60 | 76 | 207 | loose |
| Drake | Side Pieces | 26 | 9 | 117 | loose |
| Drake | SidelineDreams | 4 | 0 | 8 | loose |
| Drake | Sideways | 19 | 6 | 28 | loose |
| Drake | Signs | 27 | 13 | 147 | loose |
| Drake | Since Way Back | 51 | 33 | 117 | loose |
| Drake | Sing 2 Audition Medley | 25 | 10 | 61 | loose |
| Drake | Skepta Interlude | 49 | 90 | 199 | loose |
| Drake | Skies Parted | 71 | 90 | 476 | loose |
| Drake | Slap The City | 41 | 59 | 288 | loose |
| Drake | Slime You Out | 69 | 76 | 480 | loose |
| Drake | Slow It Down | 20 | 9 | 21 | loose |
| Drake | Slow Motion | 63 | 46 | 268 | loose |
| Drake | Small Town Fame 2 | 22 | 16 | 116 | loose |
| Drake | Smile | 35 | 15 | 188 | loose |
| Drake | Sneakin’ | 59 | 68 | 283 | loose |
| Drake | So Good | 49 | 22 | 172 | loose |
| Drake | Solid | 72 | 80 | 290 | loose |
| Drake | Someone Said | 3 | 2 | 13 | loose |
| Drake | Something | 19 | 5 | 36 | loose |
| Drake | Sooner Than Later | 29 | 17 | 129 | loose |
| Drake | Sorry i fed ur dog batteries | 4 | 1 | 10 | loose |
| Drake | Special | 85 | 49 | 297 | loose |
| Drake | Spin Bout U | 55 | 46 | 294 | loose |
| Drake | Splash Brothers | 54 | 50 | 331 | loose |
| Drake | Star67 | 58 | 53 | 346 | loose |
| Drake | Stars Align | 30 | 67 | 139 | AAAA |
| Drake | Started From The Bottom Remix | 28 | 8 | 217 | loose |
| Drake | Started From the Bottom Deluxe - Don’t Delete | 12 | 1 | 85 | loose |
| Drake | Started from the Bottom | 27 | 16 | 156 | loose |
| Drake | Startrax | 6 | 1 | 20 | loose |
| Drake | Stay | 4 | 0 | 2 | loose |
| Drake | Stay Down | 36 | 30 | 174 | loose |
| Drake | Stay Schemin’ | 53 | 27 | 272 | loose |
| Drake | Stay scheming | 34 | 19 | 217 | loose |
| Drake | Steph Curry With Da Shot #3Pointer #GoldenStateWarriors #WhenIGrowUpI’llPlayBasketballAndBeOnHisTeam | 10 | 4 | 17 | loose |
| Drake | Sticky | 56 | 71 | 182 | loose |
| Drake | Sticky / Boy’s a liar, Pt. 2 (DJ Neitjah Edit) [Mixed] | 17 | 6 | 51 | loose |
| Drake | Still Drake | 76 | 71 | 490 | loose |
| Drake | Still Fly | 37 | 19 | 384 | loose |
| Drake | Still Got It | 44 | 42 | 163 | loose |
| Drake | Still Here | 31 | 19 | 168 | loose |
| Drake | Stories About My Brother | 79 | 126 | 507 | loose |
| Drake | Street Cred | 49 | 29 | 311 | loose |
| Drake | Street Lights Never Fade | 57 | 53 | 236 | loose |
| Drake | Stuck | 28 | 18 | 55 | loose |
| Drake | Stunt Hard | 82 | 50 | 395 | loose |
| Drake | Stunt on You | 11 | 5 | 31 | loose |
| Drake | Stuntin | 83 | 73 | 542 | loose |
| Drake | Successful | 73 | 64 | 311 | loose |
| Drake | Summer 2016 (Medley Extended) | 62 | 21 | 362 | loose |
| Drake | Summer Games | 30 | 20 | 68 | loose |
| Drake | Summer Sixteen | 58 | 40 | 237 | loose |
| Drake | Summer jam | 41 | 33 | 130 | loose |
| Drake | Summers Over Interlude | 7 | 10 | 18 | AAAA |
| Drake | Sunflower | 23 | 9 | 142 | loose |
| Drake | Super Bowl LIII Halftime Show | 15 | 7 | 21 | loose |
| Drake | Supermax | 23 | 33 | 130 | loose |
| Drake | Survival | 36 | 67 | 255 | loose |
| Drake | Swagga Like Us | 32 | 16 | 163 | loose |
| Drake | Swagger Like Us | 34 | 18 | 202 | loose |
| Drake | Sweeterman (Remix) | 44 | 26 | 132 | loose |
| Drake | Sweeterman Freestyle | 26 | 20 | 96 | loose |
| Drake | Swishin’ | 51 | 46 | 166 | loose |
| Drake | T-Rex vs Hollohan | 214 | 204 | 1754 | loose |
| Drake | TABLE FOR ONE Episode 1 Tracklist | 26 | 6 | 46 | loose |
| Drake | TABLE FOR ONE Episode 2 Tracklist | 37 | 14 | 95 | loose |
| Drake | TABLE FOR ONE Episode 3 Tracklist | 57 | 13 | 125 | loose |
| Drake | THE HEART PART 6 | 94 | 193 | 659 | loose |
| Drake | TSU | 52 | 45 | 301 | loose |
| Drake | TWIST & TURN | 49 | 50 | 183 | loose |
| Drake | Take Care | 46 | 20 | 223 | loose |
| Drake | Take U Down (Remix) | 32 | 23 | 158 | loose |
| Drake | Take You Down | 25 | 10 | 86 | loose |
| Drake | Take Your Girl | 13 | 5 | 46 | loose |
| Drake | Take the Nine | 9 | 8 | 53 | loose |
| Drake | Talk Is Cheap | 39 | 21 | 113 | loose |
| Drake | Talk To Me | 38 | 34 | 209 | loose |
| Drake | Talk Up | 44 | 58 | 239 | loose |
| Drake | Taylor Made Freestyle | 70 | 81 | 415 | loose |
| Drake | Teach U a Lesson (Freestyle) | 35 | 11 | 323 | loose |
| Drake | Teach You A Lesson | 62 | 22 | 192 | loose |
| Drake | Teenage Fever | 30 | 18 | 76 | loose |
| Drake | Tell Me | 12 | 5 | 22 | loose |
| Drake | Tell Me Lies | 31 | 13 | 120 | loose |
| Drake | Tell Me Why | 31 | 13 | 151 | loose |
| Drake | Tell Your Friends (Remix) | 77 | 76 | 373 | loose |
| Drake | Terrible 2's | 42 | 59 | 450 | loose |
| Drake | Texts Go Green | 42 | 30 | 207 | loose |
| Drake | Thank Me Now | 79 | 75 | 387 | loose |
| Drake | Thank You Letter | 16 | 2 | 67 | loose |
| Drake | That’s How You Feel | 33 | 22 | 136 | loose |
| Drake | That’s Just How I Feel | 50 | 74 | 181 | loose |
| Drake | The Blanguage | 31 | 19 | 225 | loose |
| Drake | The Calm | 64 | 123 | 303 | loose |
| Drake | The Grind | 92 | 62 | 433 | loose |
| Drake | The Language | 54 | 38 | 214 | loose |
| Drake | The Last Hope | 35 | 24 | 216 | loose |
| Drake | The Motion | 28 | 14 | 123 | loose |
| Drake | The Motto (Remix) | 29 | 15 | 139 | loose |
| Drake | The Mottofication | 43 | 32 | 186 | loose |
| Drake | The Notice | 50 | 32 | 263 | loose |
| Drake | The One | 36 | 27 | 175 | loose |
| Drake | The Presentation | 63 | 60 | 311 | loose |
| Drake | The Real Her | 60 | 49 | 236 | loose |
| Drake | The Remorse | 79 | 132 | 614 | loose |
| Drake | The Resistance | 65 | 63 | 340 | loose |
| Drake | The Ride | 69 | 60 | 401 | loose |
| Drake | The Saurus vs. J-Pro | 206 | 178 | 1737 | loose |
| Drake | The Search | 57 | 53 | 269 | loose |
| Drake | The Shoe Fits | 89 | 92 | 566 | loose |
| Drake | The Usual | 32 | 9 | 118 | loose |
| Drake | The Winner | 68 | 66 | 432 | loose |
| Drake | The Zone | 46 | 21 | 164 | loose |
| Drake | The end.(The Beginning) | 13 | 12 | 65 | loose |
| Drake | These Days | 16 | 9 | 31 | loose |
| Drake | Things I Forgot To Do | 9 | 4 | 31 | loose |
| Drake | Think Good Thoughts | 55 | 37 | 430 | loose |
| Drake | Thrill Is Gone | 61 | 44 | 287 | loose |
| Drake | Throw It In The Bag (Remix) | 54 | 49 | 325 | loose |
| Drake | Tie That Binds | 18 | 12 | 56 | loose |
| Drake | Till The Club Close | 17 | 14 | 92 | loose |
| Drake | Till Things Get Right | 32 | 36 | 303 | loose |
| Drake | Tim Westwood Freestyle | 40 | 58 | 237 | loose |
| Drake | Tim Westwood Freestyle 2012 | 30 | 28 | 73 | loose |
| Drake | Time | 19 | 4 | 15 | loose |
| Drake | Time Flies | 33 | 27 | 108 | loose |
| Drake | To Feel Things | 13 | 13 | 41 | loose |
| Drake | To The Floor | 49 | 56 | 246 | loose |
| Drake | To the Max | 32 | 29 | 98 | loose |
| Drake | Tommorow’s Today | 11 | 4 | 16 | loose |
| Drake | Tony Montana (Remix) | 45 | 32 | 206 | loose |
| Drake | Too Good | 46 | 32 | 144 | loose |
| Drake | Too Many Times | 19 | 10 | 30 | loose |
| Drake | Too Much | 64 | 42 | 309 | loose |
| Drake | Toosie Slide | 41 | 33 | 173 | loose |
| Drake | Top Notch | 41 | 24 | 260 | loose |
| Drake | Touch the Sky | 23 | 11 | 207 | loose |
| Drake | Trance (Demo) | 67 | 133 | 204 | loose |
| Drake | Travis Scott and Fortnite Present: Astronomical (Full Event Video) | 95 | 86 | 246 | loose |
| Drake | Treacherous Twins | 38 | 31 | 242 | loose |
| Drake | Tried Our Best | 34 | 58 | 174 | loose |
| Drake | Trophies | 29 | 20 | 140 | loose |
| Drake | True Bestie | 24 | 22 | 152 | loose |
| Drake | True Story* | 21 | 13 | 115 | loose |
| Drake | Truffle Butter | 56 | 44 | 293 | loose |
| Drake | Trump Tower | 79 | 124 | 415 | loose |
| Drake | Trust Issues | 44 | 26 | 193 | loose |
| Drake | Trust Issues (Remix) [Demo] | 69 | 28 | 145 | loose |
| Drake | Try Harder | 37 | 16 | 264 | loose |
| Drake | Tryna Fuck | 35 | 35 | 183 | loose |
| Drake | Tuesday | 53 | 23 | 98 | loose |
| Drake | Tunechi’s Room | 50 | 32 | 192 | loose |
| Drake | Tuscan Leather | 76 | 56 | 531 | loose |
| Drake | Twist My Hair (Remix) | 56 | 34 | 137 | loose |
| Drake | Two Birds, One Stone | 77 | 106 | 482 | loose |
| Drake | U My Everything | 48 | 47 | 300 | loose |
| Drake | U With Me? | 63 | 53 | 249 | loose |
| Drake | Un-Thinkable - I’m Ready | 12 | 2 | 14 | loose |
| Drake | Un-thinkable (I’m Ready) (Live from VH1 Storytellers) | 24 | 7 | 87 | loose |
| Drake | Un-thinkable (I’m Ready) [Remix] | 44 | 23 | 175 | loose |
| Drake | Unbelievable | 25 | 23 | 63 | loose |
| Drake | Under Ground Kings | 49 | 19 | 278 | loose |
| Drake | Underdog | 47 | 49 | 298 | loose |
| Drake | Unforgettable | 46 | 37 | 235 | loose |
| Drake | Unholy / Sticky (Mixed) | 19 | 10 | 68 | loose |
| Drake | Unstoppable | 39 | 29 | 238 | loose |
| Drake | Unthinkable | 51 | 32 | 254 | loose |
| Drake | Unusual | 44 | 23 | 153 | loose |
| Drake | Up All Night | 45 | 39 | 238 | loose |
| Drake | Up Now | 58 | 53 | 246 | loose |
| Drake | Upset (Original) | 5 | 5 | 50 | loose |
| Drake | Uptown | 68 | 75 | 406 | loose |
| Drake | Us | 59 | 69 | 229 | loose |
| Drake | Used To | 77 | 52 | 356 | loose |
| Drake | Used to This | 35 | 26 | 179 | loose |
| Drake | Uuugly | 18 | 15 | 74 | loose |
| Drake | Vegas / Jimmy Cooks [Mixed] | 12 | 10 | 58 | loose |
| Drake | Versace (Remix) | 90 | 79 | 298 | loose |
| Drake | Vice Lord Poetry | 67 | 58 | 405 | loose |
| Drake | Video Girl | 81 | 68 | 443 | loose |
| Drake | Video Vixen* | 10 | 13 | 35 | loose |
| Drake | Views | 63 | 70 | 333 | loose |
| Drake | Views From The 6 | 19 | 3 | 58 | loose |
| Drake | Virginia Beach | 40 | 44 | 253 | loose |
| Drake | Vital | 50 | 55 | 225 | loose |
| Drake | WAIT FOR U | 42 | 39 | 243 | loose |
| Drake | WAIT FOR U (Mixed) [June 2022] | 10 | 2 | 31 | loose |
| Drake | WAITED | 47 | 49 | 221 | loose |
| Drake | WASTING TIME | 54 | 56 | 214 | loose |
| Drake | WESTON FREESTYLE | 10 | 1 | 61 | loose |
| Drake | WHEN HE’S GONE | 31 | 24 | 142 | loose |
| Drake | WIDDIT | 30 | 15 | 71 | loose |
| Drake | WNBA | 34 | 25 | 193 | loose |
| Drake | Wah Gwan Delilah | 46 | 31 | 183 | loose |
| Drake | Waiting To Exhale | 50 | 76 | 362 | loose |
| Drake | Waiting Up | 56 | 28 | 176 | loose |
| Drake | Walk It Talk It | 64 | 83 | 260 | loose |
| Drake | Wanna Know (Remix) | 41 | 96 | 245 | loose |
| Drake | Wants and Needs | 51 | 113 | 342 | loose |
| Drake | War | 40 | 46 | 562 | loose |
| Drake | Warriors | 60 | 36 | 290 | loose |
| Drake | Watch Me Ball (I’m On One) | 17 | 9 | 77 | loose |
| Drake | Wavin’ Flag | 44 | 27 | 208 | loose |
| Drake | Way 2 Sexy | 60 | 64 | 202 | loose |
| Drake | We Are (Film Version) | 23 | 4 | 39 | loose |
| Drake | We Caa Done | 41 | 39 | 221 | loose |
| Drake | We In This Bitch 1.5 | 44 | 21 | 269 | loose |
| Drake | We Made It (Remix) | 22 | 18 | 149 | loose |
| Drake | We Made It Freestyle | 51 | 92 | 334 | loose |
| Drake | Wednesday Night Interlude | 22 | 9 | 93 | loose |
| Drake | Weston Road Flows | 75 | 110 | 557 | loose |
| Drake | We’ll Be Fine | 54 | 27 | 254 | loose |
| Drake | We’re Going Home (Remix) | 35 | 20 | 88 | loose |
| Drake | What Did I Miss? | 33 | 20 | 236 | loose |
| Drake | What If I Kissed You | 26 | 10 | 59 | loose |
| Drake | What I’m Thinkin’ Right Now | 31 | 27 | 204 | loose |
| Drake | What Up | 57 | 43 | 307 | loose |
| Drake | What Would Pluto Do | 50 | 68 | 185 | loose |
| Drake | What a Time to be a Slime | 48 | 71 | 158 | loose |
| Drake | Whatcha Say | 43 | 31 | 287 | loose |
| Drake | What’s My Name? | 43 | 20 | 82 | loose |
| Drake | What’s Next | 42 | 40 | 160 | loose |
| Drake | What’s the 411/The Ride [MJB/OVO Cover] | 65 | 35 | 250 | loose |
| Drake | When I See It (Demo) | 16 | 5 | 35 | loose |
| Drake | When To Say When | 61 | 89 | 465 | loose |
| Drake | When u jus gotta do it, u gotta do it | 12 | 10 | 60 | loose |
| Drake | Where Were You | 40 | 23 | 95 | loose |
| Drake | Where Ya At | 50 | 36 | 346 | loose |
| Drake | Where to Now | 34 | 32 | 137 | loose |
| Drake | Where’s Your Stuff Interlude | 10 | 2 | 37 | loose |
| Drake | Which One | 63 | 98 | 240 | loose |
| Drake | Whisper My Name | 42 | 34 | 298 | loose |
| Drake | White Bone | 55 | 82 | 244 | loose |
| Drake | Whiter Then Blow | 42 | 20 | 213 | loose |
| Drake | Who Do You Love? | 52 | 34 | 199 | loose |
| Drake | Who Told You | 49 | 76 | 251 | loose |
| Drake | Who Told You / 4EVA [onnea Remix] [Mixed] | 38 | 44 | 139 | loose |
| Drake | Why You Always Hatin? | 51 | 30 | 199 | loose |
| Drake | Wick Man | 43 | 84 | 310 | loose |
| Drake | Wickman | 6 | 5 | 14 | loose |
| Drake | Wild Life... | 35 | 21 | 68 | loose |
| Drake | Wildfire (OVO Remix) | 37 | 34 | 164 | loose |
| Drake | Wish Me Well | 34 | 34 | 209 | loose |
| Drake | With You | 26 | 18 | 56 | loose |
| Drake | Won’t Be Late | 25 | 13 | 71 | loose |
| Drake | Work (R3HAB Remix) | 14 | 2 | 16 | loose |
| Drake | Work No Play | 27 | 17 | 186 | loose |
| Drake | World’s Greatest (Rafferty Disstrack) | 39 | 26 | 177 | loose |
| Drake | Worst Behavior | 55 | 45 | 290 | loose |
| Drake | Would You Love Me | 2 | 0 | 6 | loose |
| Drake | Wu-Tang Forever | 45 | 31 | 180 | loose |
| Drake | X-MEN 95’ | 100 | 53 | 173 | loose |
| Drake | YOU THE ONE | 70 | 32 | 123 | loose |
| Drake | Yamaha Mama | 41 | 27 | 110 | loose |
| Drake | Yeah Yeah | 8 | 3 | 12 | loose |
| Drake | Yebba’s Heartbreak | 14 | 5 | 18 | loose |
| Drake | Yes Indeed | 40 | 64 | 184 | loose |
| Drake | Yes Indeed Freestyle | 27 | 46 | 96 | loose |
| Drake | Yesterday | 42 | 29 | 124 | loose |
| Drake | Yikes | 48 | 38 | 155 | loose |
| Drake | Yikes [V3] | 4 | 0 | 8 | loose |
| Drake | You & The 6 | 75 | 40 | 425 | loose |
| Drake | You Broke My Heart | 46 | 51 | 226 | loose |
| Drake | You Give Me a Feeling | 5 | 0 | 1 | loose |
| Drake | You Got Me | 44 | 56 | 207 | loose |
| Drake | You Know, You Know | 55 | 65 | 347 | loose |
| Drake | You Only Live Twice | 65 | 91 | 414 | loose |
| Drake | You da Baddest | 49 | 88 | 222 | loose |
| Drake | Young Harleezy | 58 | 97 | 360 | loose |
| Drake | Your Pussy (Calling My Name Original) | 5 | 0 | 10 | loose |
| Drake | Your Room (Marvin’s Room Cover) | 47 | 25 | 79 | loose |
| Drake | You’re Mines Still (Remix) | 40 | 29 | 165 | loose |
| Drake | Yves Slatt Laurent | 16 | 14 | 74 | loose |
| Drake | Zodiac Sign | 46 | 96 | 239 | loose |
| Drake | Zone | 36 | 45 | 207 | loose |
| Drake | act ii: date @ 8 (remix) | 43 | 38 | 151 | loose |
| Drake | changelanes (alternate) | 31 | 22 | 189 | loose |
| Drake | chopped and sCREWed LOVE | 5 | 0 | 0 | loose |
| Drake | crew love freestyle | 16 | 3 | 17 | loose |
| Drake | enchanted | 65 | 58 | 224 | loose |
| Drake | hellfire | 27 | 22 | 33 | loose |
| Drake | i | 41 | 46 | 148 | loose |
| Drake | k | 15 | 13 | 11 | loose |
| Drake | knight | 10 | 4 | 41 | loose |
| Drake | królik w kapeluszu | 44 | 30 | 359 | loose |
| Drake | sakura chan | 23 | 22 | 108 | loose |
| Drake | stars | 7 | 2 | 12 | loose |
| Drake | u. | 8 | 2 | 10 | loose |
| Drake | we didn’t get the memo | 29 | 22 | 167 | loose |
