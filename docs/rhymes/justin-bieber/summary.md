# Justin Bieber rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Justin Bieber
- Songs: 636
- Bars kept (Justin Bieber lyric lines): 16393
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 79
- Canonical name: Justin Bieber.
- Credit strings: Justin Bieber.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 72613
- REPEAT pairs, recorded separately: 13876
- END rhymes: 10259
- INNER rhymes: 62354

By match:

- PERFECT: 7489 (END 1662, INNER 5827)
- SLANT: 27598 (END 3670, INNER 23928)
- ASSONANCE: 36401 (END 4697, INNER 31704)
- MULTI: 1125 (END 230, INNER 895)

By confidence:

- HIGH: 7587
- MED: 60624
- LOW: 4402

## Core

- Core Y: 70781
- Core N among rhyme pairs: 1832

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 31548 (43.4%)
- vowel: 36401 (50.1%)
- spelling: 3539 (4.9%)
- multi: 1125 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- AABB: 1 songs
- ABAB: 1 songs
- ABCB: 1 songs
- ABAA: 1 songs
- loose: 631 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 6137 pairs (END 649, INNER 5488). Words: don't, know, no, go, won't, hold, only, over.
2. `vow:EH` — 5929 pairs (END 569, INNER 5360). Words: when, never, there's, get, let's, friends, tell, let.
3. `vow:EY` — 4961 pairs (END 733, INNER 4228). Words: ain't, say, way, baby, make, away, take, day.
4. `vow:AY` — 3508 pairs (END 603, INNER 2905). Words: like, mind, by, time, why, right, find, life.
5. `vow:IH` — 3492 pairs (END 469, INNER 3023). Words: think, things, still, little, give, didn't, christmas, really.
6. `vow:IY` — 3168 pairs (END 321, INNER 2847). Words: see, need, even, nobody, keep, here, people, feel.
7. `vow:AA` — 2667 pairs (END 313, INNER 2354). Words: want, got, wanna, la, heart, not, hard, problem.
8. `vow:AE` — 2325 pairs (END 319, INNER 2006). Words: can't, can, have, back, had, man, last, hands.
9. `vow:AH` — 1875 pairs (END 248, INNER 1627). Words: love, what, one, nothing, trust, something, some, come.
10. `cmu:OW` — 1160 pairs (END 211, INNER 949). Words: know, no, go, show, slow, though, o, blow.
11. `slant:AA:stop` — 1108 pairs (END 125, INNER 983). Words: got, want, not, gotta, heart, stop, god, body.
12. `cmu:IY` — 937 pairs (END 14, INNER 923). Words: nie, si, e, mi, de, je, z, d.
13. `slant:EH:nas-stop` — 907 pairs (END 41, INNER 866). Words: when, get, let, said, again, many, better, n.
14. `slant:EH:stop` — 817 pairs (END 88, INNER 729). Words: get, let, said, better, head, best, left, already.
15. `slant:EY:stop` — 752 pairs (END 109, INNER 643). Words: baby, make, take, babe, made, wait, ain't, hate.
16. `slant:AY:nas-stop` — 740 pairs (END 162, INNER 578). Words: time, like, right, mine, shine, line, night, fine.
17. `slant:AY:stop` — 738 pairs (END 128, INNER 610). Words: like, right, side, night, light, inside, might, tonight.
18. `slant:EH:liq-stop` — 715 pairs (END 41, INNER 674). Words: get, tell, let, where, there, well, better, said.
19. `vow:UW` — 660 pairs (END 120, INNER 540). Words: who, new, through, beautiful, used, two, move, room.
20. `vow:AO` — 659 pairs (END 114, INNER 545). Words: all, lost, wanted, more, call, morning, saw, thoughts.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 132 pair sides, mostly spelling via spelling phonetic key, often with keep (10)
- ima — 126 pair sides, mostly spelling via spelling phonetic key, often with give (21)
- pum — 126 pair sides, mostly spelling via spelling phonetic key, often with rum (81)
- gon — 88 pair sides, mostly spelling via spelling phonetic key, often with dont (30)
- tengo — 73 pair sides, mostly vowel via spelling phonetic key, often with el (7)
- eenie — 58 pair sides, mostly multi via spelling phonetic key, often with meenie (49)
- meenie — 58 pair sides, mostly multi via spelling phonetic key, often with eenie (49)
- nigga — 56 pair sides, mostly spelling via spelling phonetic key, often with shit (13)
- quiero — 54 pair sides, mostly vowel via spelling phonetic key, often with no (5)
- lyin — 48 pair sides, mostly spelling via spelling phonetic key, often with cryin (8)
- shawty — 47 pair sides, mostly vowel via spelling phonetic key, often with already (4)
- jak — 47 pair sides, mostly spelling via spelling phonetic key, often with tak (10)
- weh — 44 pair sides, mostly spelling via spelling phonetic key, often with dem (9)
- dem — 41 pair sides, mostly spelling via spelling phonetic key, often with weh (9)
- cheiro — 40 pair sides, mostly vowel via spelling phonetic key, often with o (8)
- dich — 39 pair sides, mostly spelling via spelling phonetic key, often with ich (15)
- mnie — 38 pair sides, mostly spelling via spelling phonetic key, often with nie (21)
- beijo — 38 pair sides, mostly vowel via spelling phonetic key, often with o (8)
- swag — 35 pair sides, mostly spelling via spelling phonetic key, often with tag (5)
- conmigo — 34 pair sides, mostly vowel via spelling phonetic key, often with no (3)
- esa — 32 pair sides, mostly spelling via spelling phonetic key, often with n (5)
- esto — 31 pair sides, mostly vowel via spelling phonetic key, often with est (3)
- nicht — 28 pair sides, mostly spelling via spelling phonetic key, often with ich (13)
- tudo — 28 pair sides, mostly vowel via spelling phonetic key, often with o (9)
- ese — 27 pair sides, mostly spelling via spelling phonetic key, often with n (4)
- despacito — 24 pair sides, mostly vowel via spelling phonetic key, often with apuro (2)
- ndolo — 24 pair sides, mostly vowel via spelling phonetic key, often with apellido (3)
- falando — 23 pair sides, mostly vowel via spelling phonetic key, often with o (6)
- quero — 23 pair sides, mostly spelling via spelling phonetic key, often with o (6)
- tego — 22 pair sides, mostly spelling via spelling phonetic key, often with em (4)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Justin Bieber | #thatPOWER | 26 | 14 | 151 | loose |
| Justin Bieber | 1, 2, 3, 4, 5 (Spend the Night)* | 7 | 3 | 28 | loose |
| Justin Bieber | 100 Years Now | 33 | 14 | 138 | loose |
| Justin Bieber | 16 | 60 | 37 | 202 | loose |
| Justin Bieber | 2 Much | 21 | 25 | 132 | loose |
| Justin Bieber | 2 Tone | 33 | 48 | 204 | loose |
| Justin Bieber | 2U | 18 | 9 | 79 | loose |
| Justin Bieber | 40 LOVE | 22 | 19 | 74 | loose |
| Justin Bieber | 405 | 8 | 7 | 31 | loose |
| Justin Bieber | 4K (Remix) | 4 | 0 | 2 | loose |
| Justin Bieber | <img src="https://images.genius.com/08d71b1c1d0ecb9c572f210a1054a091.300x300x1.png" alt="Baby" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>BabyJustin Bieber8.1M | 29 | 13 | 89 | loose |
| Justin Bieber | <img src="https://images.genius.com/08ea44a948780ecc67bc3a270a29556a.300x300x1.png" alt="I Don’t Care" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>I Don’t CareEd Sheeran & Justin Bieber1.7M | 40 | 21 | 122 | loose |
| Justin Bieber | <img src="https://images.genius.com/1b62379797987f85048fa9cc9cf37a9e.300x300x1.jpg" alt="Let Me Love You" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Let Me Love YouDJ Snake3.6M | 23 | 4 | 50 | loose |
| Justin Bieber | <img src="https://images.genius.com/40618136b6f4da3af79a024ef551d8c3.300x300x1.png" alt="DAISIES" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>DAISIESJustin Bieber1.8M | 20 | 19 | 98 | loose |
| Justin Bieber | <img src="https://images.genius.com/4164dff756ddd455675789bd67fe5f1a.300x300x1.png" alt="Despacito (Remix)" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Despacito (Remix)Luis Fonsi & Daddy Yankee24M | 45 | 50 | 571 | loose |
| Justin Bieber | <img src="https://images.genius.com/6127733e5dbc43f75fcbf1b92e48a068.300x300x1.png" alt="I’m the One" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>I’m the OneDJ Khaled5.8M | 52 | 40 | 270 | loose |
| Justin Bieber | <img src="https://images.genius.com/65bc382247ebc3340f818fd1aef87600.300x300x1.png" alt="Stuck with U" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Stuck with UAriana Grande & Justin Bieber2.1M | 37 | 19 | 98 | loose |
| Justin Bieber | <img src="https://images.genius.com/6c453e589e3901e2724e33edfaae707a.300x300x1.png" alt="YUKON" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>YUKONJustin Bieber1.7M | 33 | 8 | 76 | loose |
| Justin Bieber | <img src="https://images.genius.com/7dfd608a3137a6c038fdd4317e93e7cb.300x300x1.png" alt="Yummy" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>YummyJustin Bieber2.1M | 23 | 20 | 94 | loose |
| Justin Bieber | <img src="https://images.genius.com/7fe95e1b68bd9fe6b8c3f44f68d4e55b.300x300x1.png" alt="Peaches" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>PeachesJustin Bieber1.7M | 29 | 12 | 57 | loose |
| Justin Bieber | <img src="https://images.genius.com/c48eb30caab693c9a80f49610e2ddb24.300x300x1.png" alt="Love Yourself" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Love YourselfJustin Bieber8.7M | 26 | 19 | 98 | loose |
| Justin Bieber | <img src="https://images.genius.com/cd085ac3e3266b1d7af750c367855fda.300x300x1.png" alt="STAY" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>STAYThe Kid LAROI & Justin Bieber1.6M | 17 | 12 | 55 | loose |
| Justin Bieber | <img src="https://images.genius.com/d1a89b927c58661e57f29fc18c010ad0.300x300x1.png" alt="10,000 Hours" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>10,000 HoursDan + Shay & Justin Bieber1.7M | 16 | 2 | 63 | loose |
| Justin Bieber | <img src="https://images.genius.com/d2ffd9d11a2feaeabc74905deeb6bc90.300x300x1.png" alt="Earth" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>EarthLil Dicky2.2M | 74 | 35 | 180 | loose |
| Justin Bieber | <img src="https://images.genius.com/d4bf83c5821091e56e162b7df2fa194d.300x300x1.jpg" alt="That Should Be Me" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>That Should Be MeJustin Bieber1.8M | 33 | 12 | 56 | loose |
| Justin Bieber | <img src="https://images.genius.com/ddab64aa5e55030c98e4979aef0bea20.300x300x1.png" alt="Sorry" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>SorryJustin Bieber4.7M | 18 | 10 | 94 | loose |
| Justin Bieber | <img src="https://images.genius.com/e03688b4a1a566ce88283e682bdb95e4.300x300x1.jpg" alt="As Long as You Love Me" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>As Long as You Love MeJustin Bieber1.8M | 36 | 12 | 106 | loose |
| Justin Bieber | <img src="https://images.genius.com/e2b9ba626fcbb38d03fa850f5746f1ac.300x300x1.png" alt="What Do You Mean?" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>What Do You Mean?Justin Bieber2.3M | 24 | 13 | 65 | loose |
| Justin Bieber | <img src="https://images.genius.com/f08a81cc614a36b6cbbfad9ca3797273.300x300x1.png" alt="Eenie Meenie" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Eenie MeenieSean Kingston & Justin Bieber1.7M | 28 | 21 | 116 | loose |
| Justin Bieber | <img src="https://images.genius.com/ff9b9cd430fd463e40d250fa87ccd69b.300x300x1.png" alt="Cold Water" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Cold WaterMajor Lazer1.5M | 21 | 47 | 81 | loose |
| Justin Bieber | A Song For Mama | 14 | 8 | 18 | loose |
| Justin Bieber | ALL I CAN TAKE | 20 | 18 | 27 | loose |
| Justin Bieber | ALL THE WAY | 26 | 19 | 91 | loose |
| Justin Bieber | Actin Up | 69 | 68 | 271 | loose |
| Justin Bieber | Afraid To Say | 26 | 21 | 93 | loose |
| Justin Bieber | Ain’t Afraid | 4 | 2 | 6 | loose |
| Justin Bieber | All About That Bass (Maejor Remix) | 10 | 0 | 35 | loose |
| Justin Bieber | All About You | 4 | 1 | 3 | loose |
| Justin Bieber | All Angles* | 24 | 7 | 85 | loose |
| Justin Bieber | All Around Me | 22 | 11 | 56 | loose |
| Justin Bieber | All Around the World | 31 | 14 | 96 | loose |
| Justin Bieber | All Bad | 25 | 6 | 38 | loose |
| Justin Bieber | All For Me | 26 | 16 | 99 | loose |
| Justin Bieber | All I Want Is You | 26 | 14 | 68 | loose |
| Justin Bieber | All I Want for Christmas Is You (SuperFestive!) | 41 | 14 | 105 | loose |
| Justin Bieber | All In It | 37 | 27 | 96 | loose |
| Justin Bieber | All She Wrote | 60 | 81 | 260 | loose |
| Justin Bieber | All That Matters | 26 | 18 | 80 | loose |
| Justin Bieber | All Things | 31 | 14 | 55 | loose |
| Justin Bieber | Alone | 15 | 11 | 45 | loose |
| Justin Bieber | Always | 20 | 23 | 74 | loose |
| Justin Bieber | American Refugee Live From Sky Tower | 567 | 362 | 2267 | loose |
| Justin Bieber | Angels Speak | 19 | 16 | 91 | loose |
| Justin Bieber | Anxiety | 28 | 15 | 76 | loose |
| Justin Bieber | Anyone | 19 | 13 | 46 | loose |
| Justin Bieber | As I Am | 19 | 10 | 149 | loose |
| Justin Bieber | As Long As You Love Me (Acoustic) | 17 | 2 | 42 | loose |
| Justin Bieber | As Long As You Love Me Remix | 23 | 15 | 106 | loose |
| Justin Bieber | At Least For Now | 18 | 8 | 52 | loose |
| Justin Bieber | Atlanta | 29 | 15 | 75 | loose |
| Justin Bieber | Available | 32 | 17 | 104 | loose |
| Justin Bieber | BAD HONEY | 18 | 7 | 66 | loose |
| Justin Bieber | BETTER MAN | 16 | 5 | 112 | loose |
| Justin Bieber | BUTTERFLIES | 17 | 4 | 60 | loose |
| Justin Bieber | Baby (Acoustic Version) | 19 | 12 | 87 | loose |
| Justin Bieber | Baby by Justin bieber(Ft. Ludacris | 4 | 0 | 11 | loose |
| Justin Bieber | Baby/Where Did Our Love Go | 14 | 1 | 31 | loose |
| Justin Bieber | Baby’s In Love | 22 | 7 | 77 | loose |
| Justin Bieber | Backpack | 43 | 23 | 156 | loose |
| Justin Bieber | Bad Day | 18 | 6 | 41 | loose |
| Justin Bieber | Bad Night* | 2 | 0 | 0 | loose |
| Justin Bieber | Bankroll | 48 | 48 | 250 | loose |
| Justin Bieber | Be Alright | 23 | 16 | 50 | loose |
| Justin Bieber | Beautiful | 28 | 9 | 65 | loose |
| Justin Bieber | Beautiful Love (Free Fire) | 23 | 10 | 94 | loose |
| Justin Bieber | Beauty And A Beat x Naturally (SadBois Edit) | 11 | 2 | 18 | loose |
| Justin Bieber | Beauty and a Beat | 30 | 36 | 95 | loose |
| Justin Bieber | Been You | 22 | 15 | 23 | loose |
| Justin Bieber | Believe | 23 | 7 | 53 | loose |
| Justin Bieber | Believe In Me -Opening- | 8 | 4 | 37 | loose |
| Justin Bieber | Bella’s Sister (Ship to Shore) | 24 | 14 | 84 | loose |
| Justin Bieber | Benefits | 31 | 25 | 151 | loose |
| Justin Bieber | Better | 6 | 1 | 9 | loose |
| Justin Bieber | Better Without You | 31 | 11 | 77 | loose |
| Justin Bieber | Bieber | 27 | 26 | 551 | loose |
| Justin Bieber | Bieber’s Paparazzi Deposition | 83 | 31 | 467 | loose |
| Justin Bieber | Big Shots | 24 | 29 | 92 | loose |
| Justin Bieber | Bigger | 31 | 23 | 51 | loose |
| Justin Bieber | Billionaire | 22 | 9 | 75 | loose |
| Justin Bieber | Blend | 16 | 7 | 12 | loose |
| Justin Bieber | Blink | 23 | 5 | 88 | loose |
| Justin Bieber | Blowing In The Wind | 20 | 10 | 49 | loose |
| Justin Bieber | Born to Be Somebody | 25 | 15 | 67 | loose |
| Justin Bieber | Boy Without a Home | 26 | 32 | 77 | loose |
| Justin Bieber | Boyfriend | 31 | 20 | 126 | loose |
| Justin Bieber | Boyfriend - Jai Prakash | 10 | 2 | 47 | loose |
| Justin Bieber | Boys / Boyfriend | 34 | 16 | 66 | loose |
| Justin Bieber | Break From Love | 17 | 13 | 32 | loose |
| Justin Bieber | Break It Down | 56 | 38 | 103 | loose |
| Justin Bieber | Breathe | 22 | 19 | 90 | loose |
| Justin Bieber | Broken | 26 | 35 | 252 | loose |
| Justin Bieber | CHURCH | 41 | 17 | 156 | loose |
| Justin Bieber | California Cruisin’ | 13 | 3 | 54 | loose |
| Justin Bieber | Cannon (Remix) | 55 | 36 | 131 | loose |
| Justin Bieber | Cannonball | 29 | 20 | 75 | loose |
| Justin Bieber | Can’t Live Without You | 8 | 7 | 11 | loose |
| Justin Bieber | Can’t Stand It | 28 | 6 | 116 | loose |
| Justin Bieber | Can’t Steal Our Love | 16 | 5 | 41 | loose |
| Justin Bieber | Can’t Wait | 49 | 33 | 183 | loose |
| Justin Bieber | Catching Feelings | 32 | 16 | 78 | loose |
| Justin Bieber | Change Me | 15 | 15 | 52 | loose |
| Justin Bieber | Change the Weather | 26 | 17 | 90 | loose |
| Justin Bieber | Changes | 22 | 16 | 74 | loose |
| Justin Bieber | Children | 11 | 4 | 11 | loose |
| Justin Bieber | Choosin’ | 23 | 16 | 56 | loose |
| Justin Bieber | Christmas Eve | 25 | 12 | 95 | loose |
| Justin Bieber | Christmas Love | 23 | 11 | 134 | loose |
| Justin Bieber | Ciernie | 53 | 14 | 706 | loose |
| Justin Bieber | Coincidence | 23 | 13 | 98 | loose |
| Justin Bieber | Cold Water (Remix) | 18 | 20 | 92 | loose |
| Justin Bieber | Cold Water / Let Me Love You (Cover) | 12 | 4 | 46 | loose |
| Justin Bieber | Cold Water x Company | 18 | 11 | 93 | loose |
| Justin Bieber | Cold Waters | 7 | 5 | 19 | loose |
| Justin Bieber | Come Around Me | 21 | 8 | 63 | loose |
| Justin Bieber | Come Home To Me | 19 | 4 | 34 | loose |
| Justin Bieber | Come My Way | 21 | 9 | 52 | loose |
| Justin Bieber | Common Denominator | 27 | 22 | 72 | loose |
| Justin Bieber | Company | 28 | 22 | 53 | loose |
| Justin Bieber | Company (Acoustic) - Live | 4 | 2 | 1 | ABAB |
| Justin Bieber | Compromise (OG) | 27 | 15 | 57 | loose |
| Justin Bieber | Confident | 48 | 24 | 160 | loose |
| Justin Bieber | Confirmation | 19 | 11 | 54 | loose |
| Justin Bieber | Cry Me a River | 25 | 10 | 60 | loose |
| Justin Bieber | DADZ LOVE | 16 | 2 | 25 | loose |
| Justin Bieber | DEVOTION | 27 | 36 | 128 | loose |
| Justin Bieber | DON’T WANNA | 22 | 10 | 136 | loose |
| Justin Bieber | DOTTED LINE | 9 | 3 | 47 | loose |
| Justin Bieber | DOTTED LINE (Acoustic) [LIVE FROM COACHELLA - Weekend II] | 1 | 0 | 2 | loose |
| Justin Bieber | DOTTED LINE (Acoustic) [LIVE FROM COACHELLA - Weekend I] | 9 | 2 | 57 | loose |
| Justin Bieber | Daisies (How many days) | 13 | 6 | 41 | loose |
| Justin Bieber | Dance Like That | 12 | 4 | 36 | loose |
| Justin Bieber | Dark Side | 17 | 13 | 69 | loose |
| Justin Bieber | Darkside And Love Me - Mashup | 9 | 5 | 38 | loose |
| Justin Bieber | Dead Nor Alive | 23 | 23 | 94 | loose |
| Justin Bieber | Deja Vu | 33 | 37 | 122 | loose |
| Justin Bieber | Deserve You | 27 | 9 | 105 | loose |
| Justin Bieber | Designed To Love You | 6 | 1 | 10 | loose |
| Justin Bieber | Despacito (2018 Grammy Awards Performance) | 7 | 1 | 85 | loose |
| Justin Bieber | Die For You | 24 | 17 | 50 | loose |
| Justin Bieber | Die in Your Arms | 36 | 12 | 92 | loose |
| Justin Bieber | Distance* | 30 | 9 | 34 | loose |
| Justin Bieber | Dj Khaled - I’m The One Ft. Justin Bieber, Quavo, | 3 | 0 | 1 | loose |
| Justin Bieber | Do It Like That | 18 | 4 | 14 | loose |
| Justin Bieber | Do You Really Know Me?* | 4 | 5 | 43 | ABAA |
| Justin Bieber | DontFuckWithME | 32 | 16 | 124 | loose |
| Justin Bieber | Don’t Act Like You Care | 60 | 31 | 236 | loose |
| Justin Bieber | Don’t Check on Me | 39 | 20 | 144 | loose |
| Justin Bieber | Don’t Go | 36 | 34 | 195 | loose |
| Justin Bieber | Don’t You Tell Me | 25 | 9 | 102 | loose |
| Justin Bieber | Double Negative | 25 | 11 | 46 | loose |
| Justin Bieber | Down to Earth | 27 | 11 | 74 | loose |
| Justin Bieber | Dr. Bieber | 30 | 14 | 148 | loose |
| Justin Bieber | Drummer Boy | 52 | 63 | 383 | loose |
| Justin Bieber | E.T.A. | 28 | 13 | 96 | loose |
| Justin Bieber | EVERYTHING HALLELUJAH | 26 | 5 | 70 | loose |
| Justin Bieber | EVERYTHING HALLELUJAH (Acoustic) [LIVE FROM COACHELLA - Weekend II] | 21 | 1 | 31 | loose |
| Justin Bieber | EVERYTHING HALLELUJAH (Acoustic) [LIVE FROM COACHELLA - Weekend I] | 1 | 0 | 0 | loose |
| Justin Bieber | EYE CANDY | 22 | 4 | 66 | loose |
| Justin Bieber | Eastside / I Like Me Better / Cold Water [Mixed] | 15 | 3 | 45 | loose |
| Justin Bieber | Ecstasy (I Miss You) [Original] | 4 | 1 | 16 | loose |
| Justin Bieber | Ed Sheeran Medley | 34 | 21 | 102 | loose |
| Justin Bieber | Eenie Meenie (Re-Record) | 17 | 6 | 83 | loose |
| Justin Bieber | Emma Stoned (Demo) | 15 | 10 | 53 | loose |
| Justin Bieber | Essence (Remix) | 49 | 35 | 119 | loose |
| Justin Bieber | F YOU (FUCK YOU VERY MUCH) | 18 | 7 | 33 | loose |
| Justin Bieber | FIFA World Cup 2026™ | Topps Halftime Show (Full Version) | 90 | 53 | 274 | loose |
| Justin Bieber | FIRST PLACE | 21 | 24 | 78 | loose |
| Justin Bieber | FORGIVENESS | 12 | 11 | 24 | loose |
| Justin Bieber | Fa La La | 27 | 12 | 94 | loose |
| Justin Bieber | Fairytale | 28 | 30 | 225 | loose |
| Justin Bieber | Faithful | 24 | 11 | 46 | loose |
| Justin Bieber | Fall | 29 | 12 | 175 | loose |
| Justin Bieber | Fall (Acoustic) [Live] | 14 | 3 | 113 | loose |
| Justin Bieber | Fall Asleep | 24 | 27 | 80 | loose |
| Justin Bieber | Falling for You | 32 | 23 | 106 | loose |
| Justin Bieber | Favorite Girl | 29 | 15 | 72 | loose |
| Justin Bieber | Favorite Girl (Acoustic) [Live] | 17 | 4 | 54 | loose |
| Justin Bieber | Fearless | 22 | 15 | 83 | loose |
| Justin Bieber | Feel My Love | 18 | 16 | 56 | loose |
| Justin Bieber | First Dance | 35 | 18 | 178 | loose |
| Justin Bieber | Flatline | 19 | 13 | 89 | loose |
| Justin Bieber | Flawless | 16 | 4 | 14 | loose |
| Justin Bieber | Folded [Remix]* | 8 | 5 | 42 | loose |
| Justin Bieber | For Once | 23 | 13 | 46 | loose |
| Justin Bieber | For Sure | 41 | 25 | 202 | loose |
| Justin Bieber | Foreign (Remix) | 47 | 30 | 194 | loose |
| Justin Bieber | Forever | 34 | 28 | 246 | loose |
| Justin Bieber | Forgiving Me (You Keep)* | 28 | 7 | 118 | loose |
| Justin Bieber | Freedom | 24 | 14 | 101 | loose |
| Justin Bieber | Friends | 16 | 10 | 29 | loose |
| Justin Bieber | Friends & Unforgettable | 9 | 6 | 26 | loose |
| Justin Bieber | Friends / Wolves (Jelena Mashup) | 24 | 3 | 43 | loose |
| Justin Bieber | Friends [dvsn Remix] | 11 | 2 | 34 | loose |
| Justin Bieber | Fuck Yourself (Keyboard Version) | 6 | 3 | 22 | loose |
| Justin Bieber | Future | 17 | 5 | 93 | loose |
| Justin Bieber | Futureme | 20 | 16 | 98 | AABB |
| Justin Bieber | GLORY VOICE MEMO | 8 | 1 | 13 | loose |
| Justin Bieber | GLORY VOICE MEMO (Acoustic) [LIVE FROM COACHELLA - Weekend II] | 1 | 0 | 0 | loose |
| Justin Bieber | GLORY VOICE MEMO (Acoustic) [LIVE FROM COACHELLA - Weekend I] | 6 | 1 | 11 | loose |
| Justin Bieber | GO BABY | 30 | 25 | 84 | loose |
| Justin Bieber | Gas Pedal (Remix) | 53 | 44 | 275 | loose |
| Justin Bieber | Get It Right | 10 | 2 | 19 | loose |
| Justin Bieber | Get Me | 16 | 14 | 70 | loose |
| Justin Bieber | Get Used to It | 40 | 12 | 71 | loose |
| Justin Bieber | Ghost | 13 | 9 | 33 | loose |
| Justin Bieber | Give Me That Love | 3 | 0 | 0 | loose |
| Justin Bieber | Goddess Sword X ALAYLM X Language | 27 | 14 | 114 | loose |
| Justin Bieber | Going Down (2015 Version) | 24 | 25 | 115 | loose |
| Justin Bieber | Got Me Like | 19 | 9 | 105 | loose |
| Justin Bieber | Got Me One | 18 | 7 | 45 | loose |
| Justin Bieber | Guarded | 19 | 10 | 75 | loose |
| Justin Bieber | Habitual | 24 | 12 | 85 | loose |
| Justin Bieber | Hailey | 32 | 29 | 56 | loose |
| Justin Bieber | Hallelujah | 35 | 34 | 171 | loose |
| Justin Bieber | Happy New Year | 52 | 23 | 179 | loose |
| Justin Bieber | Hard 2 Face Reality | 39 | 30 | 128 | loose |
| Justin Bieber | Harder Than My Demons | 47 | 41 | 289 | loose |
| Justin Bieber | Hashtag Luv | 4 | 0 | 11 | loose |
| Justin Bieber | Head On Collision | 29 | 26 | 88 | loose |
| Justin Bieber | Heartache | 28 | 13 | 119 | loose |
| Justin Bieber | Heartbreaker | 38 | 27 | 88 | loose |
| Justin Bieber | Heaven | 17 | 9 | 30 | loose |
| Justin Bieber | Hello/Sorry | 8 | 5 | 18 | loose |
| Justin Bieber | Heroine (Let’s Stay Together) | 23 | 6 | 52 | loose |
| Justin Bieber | Hey Girl (Demo) | 19 | 8 | 84 | loose |
| Justin Bieber | Hit the Ground | 27 | 26 | 47 | loose |
| Justin Bieber | Hold My Hand | 36 | 31 | 80 | loose |
| Justin Bieber | Hold On | 17 | 11 | 40 | loose |
| Justin Bieber | Hold Tight | 34 | 11 | 119 | loose |
| Justin Bieber | Holding Back* | 10 | 1 | 28 | loose |
| Justin Bieber | Holy | 40 | 25 | 198 | loose |
| Justin Bieber | Home This Christmas | 22 | 13 | 79 | loose |
| Justin Bieber | Home to Mama | 24 | 13 | 58 | loose |
| Justin Bieber | Honest | 32 | 22 | 98 | loose |
| Justin Bieber | Hotline Bling (Remix) | 33 | 11 | 135 | loose |
| Justin Bieber | How To Love (Remix) | 41 | 26 | 103 | loose |
| Justin Bieber | Human Clock (House Remix) | 21 | 6 | 26 | loose |
| Justin Bieber | Humble (Remix) | 25 | 32 | 209 | loose |
| Justin Bieber | Hurry Up And Wait | 12 | 9 | 37 | loose |
| Justin Bieber | Hypercam 2 TwerkTage #Babyy (Twerkaholics Exclusive) | 4 | 0 | 11 | loose |
| Justin Bieber | I Been On 10 | 44 | 60 | 128 | loose |
| Justin Bieber | I Can’t Be Myself | 21 | 9 | 55 | loose |
| Justin Bieber | I DO | 21 | 19 | 84 | loose |
| Justin Bieber | I Don’t Care (Chronixx & Koffee Remix) | 41 | 38 | 159 | loose |
| Justin Bieber | I Feel Funny | 17 | 22 | 5 | loose |
| Justin Bieber | I Gave You Me | 21 | 14 | 44 | loose |
| Justin Bieber | I LOVE THE WAY YOU ARE | 4 | 0 | 3 | loose |
| Justin Bieber | I Love Closer Water (Kap Slap Mashup) | 32 | 35 | 49 | loose |
| Justin Bieber | I Love You | 27 | 20 | 71 | loose |
| Justin Bieber | I THINK YOU’RE SPECIAL | 23 | 32 | 118 | loose |
| Justin Bieber | I Wanna Be | 10 | 10 | 32 | loose |
| Justin Bieber | I Want It All | 4 | 1 | 3 | loose |
| Justin Bieber | I Want You | 11 | 0 | 18 | loose |
| Justin Bieber | I Would | 19 | 20 | 133 | loose |
| Justin Bieber | IPro | 4 | 0 | 4 | loose |
| Justin Bieber | Idea 03 | 7 | 2 | 5 | loose |
| Justin Bieber | Idea 1 | 7 | 1 | 7 | loose |
| Justin Bieber | If I was your insecure girlfriend | 17 | 2 | 56 | loose |
| Justin Bieber | If I was your tall idiot | 26 | 11 | 60 | loose |
| Justin Bieber | In God’s Country | 37 | 23 | 111 | loose |
| Justin Bieber | In the Merry Old Land of Oz | 20 | 8 | 30 | loose |
| Justin Bieber | Infectious | 22 | 9 | 38 | loose |
| Justin Bieber | Insecurities | 34 | 6 | 82 | loose |
| Justin Bieber | Instagram of Batman Vs. Superman Script | 2 | 0 | 1 | loose |
| Justin Bieber | Intentions | 32 | 33 | 152 | loose |
| Justin Bieber | Intertwine | 31 | 43 | 149 | loose |
| Justin Bieber | Is You Up | 39 | 23 | 143 | loose |
| Justin Bieber | It’s All Gonna Be Okay | 39 | 30 | 161 | loose |
| Justin Bieber | It’s Working | 27 | 21 | 69 | loose |
| Justin Bieber | I’d Say (Version 2) | 25 | 23 | 83 | loose |
| Justin Bieber | I’ll Show You | 17 | 4 | 44 | loose |
| Justin Bieber | I’ll Show You refix | 31 | 18 | 177 | loose |
| Justin Bieber | I’ll Show you (Acoustic) - Live | 5 | 2 | 24 | loose |
| Justin Bieber | I’m Believin’ | 74 | 115 | 594 | loose |
| Justin Bieber | I’m Sorry For My Racist Joke | 1 | 0 | 0 | loose |
| Justin Bieber | I’m Yours | 18 | 4 | 21 | loose |
| Justin Bieber | I’m the One Parody | 51 | 35 | 231 | loose |
| Justin Bieber | JARED [V7] | 26 | 22 | 101 | loose |
| Justin Bieber | Janet Jackson | 20 | 7 | 62 | loose |
| Justin Bieber | Jealousy | 28 | 15 | 47 | loose |
| Justin Bieber | Jesus | 18 | 7 | 89 | loose |
| Justin Bieber | Jitbands freestyel | 29 | 34 | 61 | loose |
| Justin Bieber | Jodeci | 35 | 16 | 102 | loose |
| Justin Bieber | Juke Jam | 27 | 10 | 125 | loose |
| Justin Bieber | Jump On It / Crazy In Love / Fester Skank / Where Are U Now / Ring The Alarm | 36 | 30 | 83 | loose |
| Justin Bieber | Just Chill | 61 | 55 | 393 | loose |
| Justin Bieber | Just Like Them | 19 | 6 | 73 | loose |
| Justin Bieber | Just a Baby | 28 | 13 | 30 | loose |
| Justin Bieber | Justin Bieber (Allday Remix) | 49 | 25 | 178 | loose |
| Justin Bieber | Justin Bieber Drummer Boy (Remix) | 20 | 13 | 117 | loose |
| Justin Bieber | Justin Bieber Gets Pregnant By Anal Penetration | 31 | 14 | 72 | loose |
| Justin Bieber | Ketchup Relish | 47 | 73 | 258 | loose |
| Justin Bieber | Kiss and Tell | 39 | 11 | 131 | loose |
| Justin Bieber | Know Me | 20 | 14 | 96 | loose |
| Justin Bieber | Know No Better | 28 | 18 | 163 | loose |
| Justin Bieber | LET IT GO | 32 | 36 | 237 | loose |
| Justin Bieber | LOVE SONG | 17 | 11 | 81 | loose |
| Justin Bieber | LYIN’ | 13 | 2 | 64 | loose |
| Justin Bieber | La Bomba | 31 | 17 | 154 | loose |
| Justin Bieber | La Bomba Cover | 5 | 1 | 11 | loose |
| Justin Bieber | Ladies Love Me | 55 | 36 | 199 | loose |
| Justin Bieber | Language For Now (Remix) | 5 | 2 | 2 | loose |
| Justin Bieber | Latin Girl | 13 | 2 | 35 | loose |
| Justin Bieber | Lean on Me - ArtistsCAN | 32 | 12 | 65 | loose |
| Justin Bieber | Leave | 15 | 4 | 60 | loose |
| Justin Bieber | Leave It In Paris | 32 | 18 | 100 | loose |
| Justin Bieber | Leave Me Lonely | 16 | 10 | 38 | loose |
| Justin Bieber | Let It Be | 7 | 1 | 24 | loose |
| Justin Bieber | Let Me Love You & Come and See Me | 27 | 21 | 148 | loose |
| Justin Bieber | Let Me Love You (Sean Paul Remix) | 24 | 21 | 77 | loose |
| Justin Bieber | Let Me Love You / Beautiful People [Mixed] | 18 | 20 | 27 | loose |
| Justin Bieber | Let Me Love You x Tum Hi Ho - Vidya Vox Mashup Cover | 3 | 0 | 5 | loose |
| Justin Bieber | Liebst Dich Selbst | 22 | 14 | 281 | loose |
| Justin Bieber | Life Is Worth Living | 44 | 24 | 104 | loose |
| Justin Bieber | Lifetime | 21 | 14 | 90 | loose |
| Justin Bieber | Lights On | 36 | 25 | 117 | loose |
| Justin Bieber | Lil Bit | 19 | 27 | 63 | loose |
| Justin Bieber | Little Drummer Boy | 65 | 59 | 167 | loose |
| Justin Bieber | Live My Life | 26 | 22 | 107 | loose |
| Justin Bieber | Lolly | 49 | 57 | 308 | loose |
| Justin Bieber | Lonely | 21 | 11 | 48 | loose |
| Justin Bieber | Long Way Home | 36 | 26 | 89 | loose |
| Justin Bieber | Look Up At The Stars | 12 | 5 | 18 | loose |
| Justin Bieber | Looking For You | 50 | 30 | 235 | loose |
| Justin Bieber | Love Me | 20 | 7 | 58 | loose |
| Justin Bieber | Love Me Like You Do | 31 | 28 | 103 | loose |
| Justin Bieber | Love Thru the Computer | 50 | 50 | 173 | loose |
| Justin Bieber | Love You Different | 32 | 16 | 127 | loose |
| Justin Bieber | Love Yourself (Drewsome Remix) | 22 | 14 | 134 | loose |
| Justin Bieber | Love Yourself - Acoustic | 14 | 9 | 42 | loose |
| Justin Bieber | Love Yourself - Acoustic (with Ed Sheeran) | 6 | 1 | 18 | loose |
| Justin Bieber | Love yourself - Justin Bieber | 5 | 1 | 18 | loose |
| Justin Bieber | Loved By You | 18 | 13 | 62 | loose |
| Justin Bieber | Lovey Dovey | 17 | 3 | 60 | loose |
| Justin Bieber | MASSIVE PARTY IN L.A | 66 | 25 | 184 | loose |
| Justin Bieber | MOTHER IN YOU | 12 | 4 | 37 | loose |
| Justin Bieber | MOTHER IN YOU (Acoustic) [LIVE FROM COACHELLA - Weekend II] | 9 | 3 | 31 | loose |
| Justin Bieber | MOVING FAST | 6 | 1 | 20 | loose |
| Justin Bieber | Madly In Love | 16 | 4 | 28 | loose |
| Justin Bieber | Make You Believe | 14 | 12 | 78 | loose |
| Justin Bieber | Mama’s Boy | 32 | 18 | 92 | loose |
| Justin Bieber | Many Men | 26 | 24 | 177 | loose |
| Justin Bieber | Maria | 40 | 13 | 119 | loose |
| Justin Bieber | Maria I’m Drunk | 58 | 43 | 229 | loose |
| Justin Bieber | Mark My Words | 13 | 3 | 17 | loose |
| Justin Bieber | Maserati | 99 | 62 | 185 | loose |
| Justin Bieber | Max Verstappen | 42 | 47 | 432 | loose |
| Justin Bieber | Meet Me | 23 | 21 | 81 | loose |
| Justin Bieber | Memphis | 41 | 34 | 147 | loose |
| Justin Bieber | Mirjana | 10 | 1 | 68 | loose |
| Justin Bieber | Mistletoe | 24 | 19 | 45 | loose |
| Justin Bieber | Moments | 21 | 12 | 60 | loose |
| Justin Bieber | Monster | 27 | 20 | 72 | loose |
| Justin Bieber | Mood (Remix) | 32 | 46 | 263 | loose |
| Justin Bieber | Mood (Remix) [CLEAN] | 7 | 10 | 28 | loose |
| Justin Bieber | NEED IT | 31 | 35 | 70 | loose |
| Justin Bieber | NUMBER 1 VICTORY ROYAL - Justin bieber | 33 | 36 | 143 | loose |
| Justin Bieber | Naked | 8 | 3 | 8 | loose |
| Justin Bieber | Name | 15 | 16 | 65 | loose |
| Justin Bieber | Need More | 3 | 0 | 6 | loose |
| Justin Bieber | Never Let You Go | 33 | 12 | 101 | loose |
| Justin Bieber | Never Say Never | 39 | 16 | 100 | loose |
| Justin Bieber | Never Too Far | 24 | 9 | 46 | loose |
| Justin Bieber | New One | 18 | 23 | 86 | loose |
| Justin Bieber | Next to Me | 19 | 15 | 64 | loose |
| Justin Bieber | Next to You | 26 | 8 | 108 | loose |
| Justin Bieber | No Brainer | 47 | 32 | 130 | loose |
| Justin Bieber | No Direction | 9 | 2 | 26 | loose |
| Justin Bieber | No Fear | 10 | 1 | 46 | loose |
| Justin Bieber | No Fue un Ratón | 20 | 13 | 216 | loose |
| Justin Bieber | No Hard Feelings | 23 | 16 | 45 | loose |
| Justin Bieber | No Matter What | 20 | 13 | 29 | loose |
| Justin Bieber | No More Offers | 25 | 11 | 63 | loose |
| Justin Bieber | No Option | 34 | 40 | 98 | loose |
| Justin Bieber | No Pressure | 55 | 43 | 168 | loose |
| Justin Bieber | No Reason (Version 1) | 37 | 31 | 164 | loose |
| Justin Bieber | No Sense | 38 | 15 | 164 | loose |
| Justin Bieber | None of Your Love | 31 | 33 | 120 | loose |
| Justin Bieber | Not Here Forever | 35 | 21 | 187 | loose |
| Justin Bieber | Nothing Like Us | 20 | 5 | 48 | loose |
| Justin Bieber | OH MAN | 11 | 4 | 118 | loose |
| Justin Bieber | OPEN UP YOUR HEART | 12 | 5 | 27 | loose |
| Justin Bieber | OUTRAGEOUS | 27 | 36 | 97 | loose |
| Justin Bieber | Obnoxious | 6 | 2 | 5 | loose |
| Justin Bieber | Off My Face | 17 | 7 | 23 | loose |
| Justin Bieber | Off My Mind | 6 | 1 | 9 | loose |
| Justin Bieber | Oh Girl | 14 | 7 | 59 | loose |
| Justin Bieber | Okay, Okay* | 10 | 6 | 30 | loose |
| Justin Bieber | Old School Flow | 24 | 22 | 212 | loose |
| Justin Bieber | Omaha Mall | 40 | 20 | 141 | loose |
| Justin Bieber | On Sight | 26 | 28 | 106 | loose |
| Justin Bieber | One Dance (Remix) | 23 | 10 | 47 | loose |
| Justin Bieber | One Girl | 33 | 30 | 85 | loose |
| Justin Bieber | One Less Lonely Girl | 23 | 18 | 230 | loose |
| Justin Bieber | One Life | 35 | 19 | 120 | loose |
| Justin Bieber | One Love | 19 | 4 | 67 | loose |
| Justin Bieber | One Time | 32 | 17 | 77 | loose |
| Justin Bieber | Only Thing I Ever Get for Christmas | 19 | 2 | 123 | loose |
| Justin Bieber | Only Yours | 19 | 9 | 36 | loose |
| Justin Bieber | Oops | 34 | 50 | 226 | loose |
| Justin Bieber | Otis (Freestyle) | 40 | 26 | 300 | loose |
| Justin Bieber | Out of Town Girl | 23 | 6 | 78 | loose |
| Justin Bieber | Over And Over | 25 | 8 | 42 | loose |
| Justin Bieber | Overboard | 24 | 12 | 50 | loose |
| Justin Bieber | Overrated | 14 | 5 | 31 | loose |
| Justin Bieber | Oxygen | 26 | 10 | 61 | loose |
| Justin Bieber | PETTING ZOO | 24 | 9 | 126 | loose |
| Justin Bieber | POPPIN’ MY S*** | 16 | 18 | 79 | loose |
| Justin Bieber | PYD | 47 | 11 | 88 | loose |
| Justin Bieber | Pain | 12 | 4 | 59 | loose |
| Justin Bieber | Pastel Stars | 8 | 1 | 10 | loose |
| Justin Bieber | Patient | 23 | 9 | 59 | loose |
| Justin Bieber | Peaches (Remix) | 53 | 35 | 203 | loose |
| Justin Bieber | Percolate | 39 | 23 | 110 | loose |
| Justin Bieber | Perfect Together | 14 | 3 | 56 | loose |
| Justin Bieber | Pick Me | 31 | 16 | 163 | loose |
| Justin Bieber | Pickled Ketchup & Broccoli Beans | 26 | 30 | 104 | loose |
| Justin Bieber | Pictures | 10 | 10 | 30 | loose |
| Justin Bieber | Pink Diamond | 58 | 31 | 106 | loose |
| Justin Bieber | Playtime | 17 | 9 | 118 | loose |
| Justin Bieber | Polka Face | 72 | 37 | 122 | loose |
| Justin Bieber | Pop Yo Shit | 3 | 0 | 4 | loose |
| Justin Bieber | Por Causa de Você / Baby / 1 Minuto (Ao Vivo) | 30 | 13 | 251 | loose |
| Justin Bieber | Powszechny i śmiertelny | 50 | 21 | 310 | loose |
| Justin Bieber | Praise The Lord & Khalil (Interlude) | 29 | 8 | 132 | loose |
| Justin Bieber | Pray | 24 | 25 | 96 | loose |
| Justin Bieber | Pretty Boy Swag | 29 | 18 | 70 | loose |
| Justin Bieber | Prise de conscience (Remix purpose de Justin Bieber) | 46 | 20 | 515 | loose |
| Justin Bieber | Private Landing | 60 | 55 | 200 | loose |
| Justin Bieber | Prom Day | 26 | 16 | 48 | loose |
| Justin Bieber | Proud of Me | 44 | 19 | 200 | loose |
| Justin Bieber | Proud of You | 19 | 25 | 29 | loose |
| Justin Bieber | Purpose | 23 | 16 | 62 | loose |
| Justin Bieber | Put Me On | 27 | 12 | 85 | loose |
| Justin Bieber | RAW | 41 | 29 | 154 | loose |
| Justin Bieber | Raindance | 21 | 10 | 27 | loose |
| Justin Bieber | Raise The Bar* | 16 | 12 | 37 | loose |
| Justin Bieber | Reckless Love (HXLY KXSS Edit) | 6 | 3 | 36 | loose |
| Justin Bieber | Recovery | 23 | 16 | 128 | loose |
| Justin Bieber | Red Eye | 24 | 11 | 49 | loose |
| Justin Bieber | Rich Girl | 88 | 60 | 363 | loose |
| Justin Bieber | Ride | 21 | 6 | 53 | loose |
| Justin Bieber | Righ There (Picture This) | 37 | 24 | 168 | loose |
| Justin Bieber | Right Here | 27 | 7 | 125 | loose |
| Justin Bieber | Rockin’ Around The Christmas Tree | 15 | 7 | 42 | loose |
| Justin Bieber | Roller Coaster | 14 | 3 | 54 | loose |
| Justin Bieber | Run For Me | 7 | 4 | 6 | loose |
| Justin Bieber | Run It Back | 32 | 24 | 114 | loose |
| Justin Bieber | Run With Me | 16 | 4 | 31 | loose |
| Justin Bieber | Runaway Love (Kanye West Remix) | 69 | 37 | 343 | loose |
| Justin Bieber | Running Over | 39 | 21 | 112 | loose |
| Justin Bieber | SAFE SPACE | 5 | 2 | 16 | ABCB |
| Justin Bieber | SO CUTE | 34 | 14 | 143 | loose |
| Justin Bieber | SOULFUL | 8 | 7 | 42 | loose |
| Justin Bieber | SPEED DEMON | 43 | 26 | 222 | loose |
| Justin Bieber | STANDING ON BUSINESS | 16 | 5 | 63 | loose |
| Justin Bieber | STAY (2021) | 7 | 0 | 28 | loose |
| Justin Bieber | STAY (Remix) / You Want Me / Ecstasy (Mixed) | 5 | 0 | 25 | loose |
| Justin Bieber | STAY [Spanish Version] | 16 | 7 | 76 | loose |
| Justin Bieber | STAY | [BEST VERSION] | 13 | 9 | 47 | loose |
| Justin Bieber | STORY OF GOD | 90 | 35 | 578 | loose |
| Justin Bieber | STRANGERS PT 2 (Interlude) | 2 | 0 | 3 | loose |
| Justin Bieber | SUNDOWN | 33 | 22 | 228 | loose |
| Justin Bieber | SWAG | 18 | 10 | 78 | loose |
| Justin Bieber | SWEET SPOT | 36 | 57 | 172 | loose |
| Justin Bieber | Santa Claus Is Coming to Town | 22 | 11 | 16 | loose |
| Justin Bieber | Say Yes | 15 | 13 | 101 | loose |
| Justin Bieber | Se Canso (Remix)* | 10 | 7 | 83 | loose |
| Justin Bieber | Second Emotion | 33 | 21 | 115 | loose |
| Justin Bieber | Set A Place At Your Table | 22 | 9 | 66 | loose |
| Justin Bieber | Shakin’ Off The Hate* | 7 | 3 | 31 | loose |
| Justin Bieber | Shape of You / Let Me Love You / Taki Taki / Psycho [Mixed] | 22 | 15 | 87 | loose |
| Justin Bieber | Shawty Let’s Go | 7 | 6 | 11 | loose |
| Justin Bieber | She Don’t Like the Lights | 29 | 10 | 87 | loose |
| Justin Bieber | She Know | 7 | 12 | 4 | AAAA |
| Justin Bieber | She Used To Be Close To Me | 29 | 26 | 64 | loose |
| Justin Bieber | Show You Off | 52 | 29 | 135 | loose |
| Justin Bieber | Silent Night | 9 | 10 | 21 | loose |
| Justin Bieber | Slave To The Rhythm (Remix) | 32 | 21 | 72 | loose |
| Justin Bieber | Slide City | 18 | 2 | 112 | loose |
| Justin Bieber | Slovenia Will Win | 25 | 9 | 62 | loose |
| Justin Bieber | Slow Up | 18 | 6 | 66 | loose |
| Justin Bieber | Snooze (Acoustic) | 31 | 21 | 125 | loose |
| Justin Bieber | So Good | 9 | 5 | 10 | loose |
| Justin Bieber | So Sick (Cover) | 28 | 12 | 44 | loose |
| Justin Bieber | Somebody | 22 | 13 | 82 | loose |
| Justin Bieber | Somebody to Love | 26 | 6 | 91 | loose |
| Justin Bieber | Someday At Christmas | 26 | 15 | 99 | loose |
| Justin Bieber | Sorry (Cover) | 13 | 3 | 28 | loose |
| Justin Bieber | Sou Pagodeiro (Love Yourself) [Ao Vivo] | 27 | 11 | 432 | loose |
| Justin Bieber | Speaking in Tongues (Freestyle) | 34 | 31 | 114 | loose |
| Justin Bieber | Spirit | 18 | 6 | 26 | loose |
| Justin Bieber | Start Again | 12 | 3 | 24 | loose |
| Justin Bieber | Stay | 4 | 1 | 6 | loose |
| Justin Bieber | Stay - Acoustic | 7 | 5 | 27 | loose |
| Justin Bieber | Stay With Me Forever | 23 | 17 | 41 | loose |
| Justin Bieber | Step Back | 13 | 5 | 38 | loose |
| Justin Bieber | Still Can’t Get Enough | 19 | 4 | 28 | loose |
| Justin Bieber | Stress | 24 | 9 | 89 | loose |
| Justin Bieber | Strobe / Beauty and a Beat [Mixed] | 6 | 0 | 13 | loose |
| Justin Bieber | Strong* | 17 | 20 | 35 | loose |
| Justin Bieber | Stuck In the Moment | 29 | 10 | 136 | loose |
| Justin Bieber | Stuck with You | 14 | 4 | 31 | loose |
| Justin Bieber | Summer | 9 | 1 | 29 | loose |
| Justin Bieber | Summer 2016 (Medley Extended) | 66 | 26 | 380 | loose |
| Justin Bieber | Summer’s Gone | 7 | 2 | 13 | loose |
| Justin Bieber | Superficial* | 15 | 7 | 17 | loose |
| Justin Bieber | Supermodel | 28 | 17 | 54 | loose |
| Justin Bieber | Swag So Mean | 6 | 1 | 12 | loose |
| Justin Bieber | Swap It Out | 37 | 17 | 68 | loose |
| Justin Bieber | THERAPY SESSION | 17 | 7 | 140 | loose |
| Justin Bieber | THINGS YOU DO | 8 | 1 | 47 | loose |
| Justin Bieber | THINGS YOU DO (Acoustic) [LIVE FROM COACHELLA - Weekend II] | 8 | 1 | 54 | loose |
| Justin Bieber | THINGS YOU DO (Acoustic) [LIVE FROM COACHELLA - Weekend I] | 1 | 0 | 2 | loose |
| Justin Bieber | TOO LONG | 14 | 6 | 24 | loose |
| Justin Bieber | TOO MUCH | 46 | 60 | 185 | loose |
| Justin Bieber | Take A Chance | 17 | 5 | 42 | loose |
| Justin Bieber | Take It Out On Me | 24 | 7 | 60 | loose |
| Justin Bieber | Take You | 24 | 26 | 61 | loose |
| Justin Bieber | Take Your Time | 20 | 7 | 77 | loose |
| Justin Bieber | Tebe Pizdec | 26 | 14 | 317 | loose |
| Justin Bieber | Tell Me | 17 | 7 | 83 | loose |
| Justin Bieber | Thank You* | 3 | 1 | 9 | loose |
| Justin Bieber | That Should Be Me (Remix) | 12 | 4 | 9 | loose |
| Justin Bieber | That’s What Love Is | 35 | 31 | 92 | loose |
| Justin Bieber | The 100th Digital Short | 56 | 34 | 119 | loose |
| Justin Bieber | The Christmas Song (Chestnuts Roasting on An Open Fire) | 19 | 16 | 62 | loose |
| Justin Bieber | The Feeling | 21 | 6 | 33 | loose |
| Justin Bieber | The Intro | 29 | 9 | 134 | loose |
| Justin Bieber | The Most | 15 | 13 | 61 | loose |
| Justin Bieber | There She Go | 36 | 42 | 200 | loose |
| Justin Bieber | They said | 12 | 4 | 26 | loose |
| Justin Bieber | Think Before | 48 | 61 | 144 | loose |
| Justin Bieber | Thinking About You | 40 | 21 | 214 | loose |
| Justin Bieber | This Is Me | 13 | 3 | 48 | loose |
| Justin Bieber | Thought of You | 22 | 4 | 25 | loose |
| Justin Bieber | Throw It Away (Demo) | 19 | 0 | 143 | loose |
| Justin Bieber | Thugz Mansion (Cover) | 37 | 26 | 258 | loose |
| Justin Bieber | Til It’s Over | 20 | 11 | 60 | loose |
| Justin Bieber | Tim Westwood (Freestyle) | 17 | 14 | 66 | loose |
| Justin Bieber | Time For Bed | 31 | 7 | 138 | loose |
| Justin Bieber | Time Tells | 15 | 8 | 62 | loose |
| Justin Bieber | Tonight I’m Getting Over You (Showtek Remix) | 12 | 5 | 34 | loose |
| Justin Bieber | Too Much - Justin Bieber Cover | 11 | 9 | 28 | loose |
| Justin Bieber | Towels In The Basket | 30 | 29 | 140 | loose |
| Justin Bieber | Trust | 39 | 12 | 70 | loose |
| Justin Bieber | Trust In Me | 17 | 18 | 26 | loose |
| Justin Bieber | Trust Issues (Remix) | 46 | 29 | 253 | loose |
| Justin Bieber | Trust Issues (Remix) [Demo] | 71 | 32 | 142 | loose |
| Justin Bieber | Trust Me | 25 | 17 | 187 | loose |
| Justin Bieber | Turn Up | 5 | 0 | 7 | loose |
| Justin Bieber | Turn to You (Mother’s Day Dedication) | 25 | 4 | 52 | loose |
| Justin Bieber | Twerk | 31 | 14 | 133 | loose |
| Justin Bieber | Two in the Morning Vibes | 36 | 21 | 121 | loose |
| Justin Bieber | U Got It Bad/Because of You | 34 | 14 | 125 | loose |
| Justin Bieber | U Smile | 26 | 4 | 61 | loose |
| Justin Bieber | Unconditional | 18 | 1 | 85 | loose |
| Justin Bieber | Unfamiliar (Demo) | 32 | 44 | 164 | loose |
| Justin Bieber | Unstable | 22 | 8 | 63 | loose |
| Justin Bieber | Up | 26 | 6 | 27 | loose |
| Justin Bieber | Used To (Reference Track) | 40 | 16 | 112 | loose |
| Justin Bieber | Vatican | 25 | 12 | 56 | loose |
| Justin Bieber | WALKING AWAY | 26 | 35 | 163 | loose |
| Justin Bieber | WAY IT IS | 24 | 7 | 180 | loose |
| Justin Bieber | WHAT’S POPPIN (Remix) | 24 | 23 | 119 | loose |
| Justin Bieber | WHEN IT’S OVER | 14 | 3 | 29 | loose |
| Justin Bieber | WIFE ME UP | 32 | 30 | 64 | loose |
| Justin Bieber | WITCHYA | 11 | 4 | 18 | loose |
| Justin Bieber | WTHELLY (Remix) | 3 | 0 | 13 | loose |
| Justin Bieber | Wait For a Minute | 43 | 26 | 161 | loose |
| Justin Bieber | Wake Up Next To You | 15 | 14 | 36 | loose |
| Justin Bieber | Wandered To LA | 31 | 29 | 83 | loose |
| Justin Bieber | Wash Away | 21 | 27 | 104 | loose |
| Justin Bieber | Wavin’ Flag | 44 | 27 | 208 | loose |
| Justin Bieber | We Are | 39 | 27 | 163 | loose |
| Justin Bieber | We Are the World 25 for Haiti | 60 | 36 | 168 | loose |
| Justin Bieber | We Got It (Evidence) | 21 | 35 | 73 | loose |
| Justin Bieber | We Were Born For This | 22 | 19 | 60 | loose |
| Justin Bieber | We’re Best Friends | 14 | 10 | 78 | loose |
| Justin Bieber | We’re In This Together | 38 | 23 | 200 | loose |
| Justin Bieber | What Do U Mean (Acoustic) | 13 | 5 | 47 | loose |
| Justin Bieber | What Do You Mean | 32 | 10 | 113 | loose |
| Justin Bieber | What Do You Mean? [Angelika Vee Cover] - Justin Caruso Remix | 5 | 0 | 12 | loose |
| Justin Bieber | What You See | 41 | 35 | 251 | loose |
| Justin Bieber | What You Wanna Do | 12 | 1 | 15 | loose |
| Justin Bieber | What’s Hatnin’ | 33 | 13 | 58 | loose |
| Justin Bieber | Where Are You Now | 22 | 11 | 24 | loose |
| Justin Bieber | Where Are Ü Now | 14 | 4 | 81 | loose |
| Justin Bieber | Where Are Ü Now - Piano Version | 8 | 1 | 28 | loose |
| Justin Bieber | Where Are Ü Now LIVE | 10 | 1 | 37 | loose |
| Justin Bieber | Where Do I Fit In | 34 | 11 | 147 | loose |
| Justin Bieber | Where You Go I Follow | 40 | 12 | 176 | loose |
| Justin Bieber | Who I Am | 17 | 7 | 43 | loose |
| Justin Bieber | Who Shot Ya? (Freestyle) | 34 | 37 | 134 | loose |
| Justin Bieber | Why You Mad? (Infinity Remix) | 48 | 36 | 185 | loose |
| Justin Bieber | Wind It (Remix) | 29 | 14 | 126 | loose |
| Justin Bieber | Wish You Would | 37 | 12 | 121 | loose |
| Justin Bieber | With You | 38 | 9 | 61 | loose |
| Justin Bieber | Won’t Stop | 42 | 35 | 299 | loose |
| Justin Bieber | YOU KNOW I CARE | 29 | 16 | 61 | loose |
| Justin Bieber | YUKON (Live at the 68th Grammy Awards) | 18 | 3 | 27 | loose |
| Justin Bieber | Yea Ya | 16 | 12 | 32 | loose |
| Justin Bieber | Yellow Raincoat | 18 | 10 | 43 | loose |
| Justin Bieber | You Can Lay It On Me | 10 | 5 | 31 | loose |
| Justin Bieber | You Know What I Want | 35 | 8 | 73 | loose |
| Justin Bieber | You To Go (2017 Version) | 17 | 6 | 45 | loose |
| Justin Bieber | You Want Me | 21 | 14 | 100 | loose |
| Justin Bieber | You and Me | 49 | 23 | 107 | loose |
| Justin Bieber | You’re The One | 5 | 1 | 17 | loose |
| Justin Bieber | Yummy (Summer Walker Remix) | 8 | 11 | 20 | loose |
| Justin Bieber | Yummy / positions (Mixed) | 15 | 8 | 33 | loose |
| Justin Bieber | Yummy Jalebi | 17 | 11 | 39 | loose |
| Justin Bieber | ZUMA HOUSE | 7 | 4 | 8 | loose |
| Justin Bieber | ZUMA HOUSE (Acoustic) [LIVE FROM COACHELLA - Weekend II] | 2 | 1 | 0 | loose |
| Justin Bieber | ZUMA HOUSE (Acoustic) [LIVE FROM COACHELLA - Weekend I] | 4 | 0 | 13 | loose |
| Justin Bieber | attention | 24 | 17 | 43 | loose |
| Justin Bieber | bad guy | 42 | 47 | 111 | loose |
| Justin Bieber | ecstasy (i miss you, pt. 2) | 24 | 12 | 113 | loose |
| Justin Bieber | iGETMONEY | 39 | 49 | 112 | loose |
| Justin Bieber | knight | 16 | 6 | 83 | loose |
| Justin Bieber | lonely christmas | 32 | 19 | 97 | loose |
| Justin Bieber | mistletoe cover :p | 24 | 14 | 52 | loose |
| Justin Bieber | mistletoe x nie łam mi serca w święta pt. 2 (hubi flip)* (fab fest 6) | 25 | 5 | 447 | loose |
| Justin Bieber | nfl | 33 | 21 | 135 | loose |
| Justin Bieber | up at night | 31 | 26 | 98 | loose |
| Justin Bieber | 내가 제일 잘 나가 (I Am the Best) [Remix] | 12 | 4 | 20 | loose |
