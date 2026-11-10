# J. Cole rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: J. Cole
- Songs: 637
- Bars kept (J. Cole lyric lines): 33703
- Section headers dropped, not counted as bars: 6
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 110
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 53
- Canonical name: J. Cole.
- Credit strings: J. Cole.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 227851
- REPEAT pairs, recorded separately: 21985
- END rhymes: 29138
- INNER rhymes: 198713

By match:

- PERFECT: 21334 (END 4947, INNER 16387)
- SLANT: 91761 (END 12049, INNER 79712)
- ASSONANCE: 111284 (END 11347, INNER 99937)
- MULTI: 3472 (END 795, INNER 2677)

By confidence:

- HIGH: 22538
- MED: 191963
- LOW: 13350

## Core

- Core Y: 223771
- Core N among rhyme pairs: 4080

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 101828 (44.7%)
- vowel: 111284 (48.8%)
- spelling: 11267 (4.9%)
- multi: 3472 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 2 songs
- loose: 635 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 15657 pairs (END 1607, INNER 14050). Words: shit, think, bitch, bitches, still, little, things, hit.
2. `vow:EH` — 15592 pairs (END 1399, INNER 14193). Words: when, get, never, tell, where, gettin, let, best.
3. `vow:OW` — 15202 pairs (END 1264, INNER 13938). Words: don't, know, no, go, only, won't, told, cole.
4. `vow:EY` — 13739 pairs (END 1617, INNER 12122). Words: ain't, say, way, make, day, take, play, stay.
5. `vow:AE` — 9050 pairs (END 953, INNER 8097). Words: can't, back, man, had, can, last, have, ass.
6. `vow:AA` — 8927 pairs (END 805, INNER 8122). Words: got, want, hard, not, wanna, cause, god, talkin.
7. `vow:IY` — 8876 pairs (END 848, INNER 8028). Words: see, even, these, need, here, people, feel, keep.
8. `vow:AY` — 8809 pairs (END 948, INNER 7861). Words: like, mind, why, by, time, high, find, life.
9. `vow:AH` — 6992 pairs (END 699, INNER 6293). Words: what, fuck, love, one, some, fuckin, what's, come.
10. `slant:IH:stop` — 4536 pairs (END 624, INNER 3912). Words: nigga, shit, hit, big, city, dick, sick, quick.
11. `slant:AA:stop` — 3715 pairs (END 453, INNER 3262). Words: got, not, gotta, want, god, top, stop, heart.
12. `slant:EH:stop` — 2846 pairs (END 300, INNER 2546). Words: get, better, let, said, head, best, went, left.
13. `vow:AO` — 2699 pairs (END 274, INNER 2425). Words: all, lost, more, wanted, saw, y'all, thoughts, call.
14. `slant:AE:stop` — 2534 pairs (END 387, INNER 2147). Words: back, had, rap, can't, bad, black, fact, trap.
15. `slant:IH:sib-stop` — 2529 pairs (END 395, INNER 2134). Words: bitch, nigga, niggas, shit, rich, hit, wish, miss.
16. `cmu:OW` — 2496 pairs (END 410, INNER 2086). Words: know, no, go, though, show, flow, blow, low.
17. `vow:UW` — 2434 pairs (END 394, INNER 2040). Words: through, who, used, new, two, knew, school, truth.
18. `slant:EH:liq-stop` — 2075 pairs (END 140, INNER 1935). Words: get, tell, where, let, there, well, better, hell.
19. `slant:AY:stop` — 2063 pairs (END 209, INNER 1854). Words: like, right, white, might, inside, type, night, ride.
20. `slant:IH:liq-stop` — 2055 pairs (END 99, INNER 1956). Words: shit, still, really, will, hit, lil, 'til, little.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 2878 pair sides, mostly spelling via spelling phonetic key, often with shit (733)
- niggas — 1217 pair sides, mostly spelling via spelling phonetic key, often with nigga (685)
- tryna — 624 pair sides, mostly spelling via spelling phonetic key, often with even (48)
- gon — 567 pair sides, mostly spelling via spelling phonetic key, often with dont (125)
- ima — 380 pair sides, mostly spelling via spelling phonetic key, often with shit (38)
- finna — 132 pair sides, mostly vowel via spelling phonetic key, often with nigga (43)
- dawg — 118 pair sides, mostly spelling via spelling phonetic key, often with long (26)
- shawty — 87 pair sides, mostly vowel via spelling phonetic key, often with see (6)
- quando — 83 pair sides, mostly vowel via spelling phonetic key, often with o (10)
- nao — 82 pair sides, mostly vowel via spelling phonetic key, often with o (13)
- nas — 68 pair sides, mostly spelling via spelling phonetic key, often with pac (9)
- lyin — 67 pair sides, mostly spelling via spelling phonetic key, often with these (7)
- homie — 61 pair sides, mostly spelling via spelling phonetic key, often with gon (7)
- prolly — 59 pair sides, mostly vowel via spelling phonetic key, often with old (6)
- imma — 57 pair sides, mostly vowel via spelling phonetic key, often with niggas (18)
- benim — 54 pair sides, mostly spelling via spelling phonetic key, often with m (13)
- cuz — 48 pair sides, mostly spelling via spelling phonetic key, often with what (5)
- dyin — 43 pair sides, mostly spelling via spelling phonetic key, often with these (5)
- siamo — 42 pair sides, mostly vowel via spelling phonetic key, often with quando (4)
- jigga — 41 pair sides, mostly spelling via spelling phonetic key, often with nigga (13)
- fam — 40 pair sides, mostly spelling via spelling phonetic key, often with man (9)
- het — 39 pair sides, mostly spelling via spelling phonetic key, often with en (5)
- abedo — 38 pair sides, mostly vowel via spelling phonetic key, often with atye (4)
- lado — 37 pair sides, mostly vowel via spelling phonetic key, often with o (6)
- henny — 36 pair sides, mostly vowel via spelling phonetic key, often with every (4)
- caminho — 35 pair sides, mostly vowel via spelling phonetic key, often with nao (6)
- astea — 35 pair sides, mostly vowel via spelling phonetic key, often with de (8)
- quem — 33 pair sides, mostly spelling via spelling phonetic key, often with n (8)
- bling — 32 pair sides, mostly spelling via spelling phonetic key, often with king (2)
- estao — 32 pair sides, mostly vowel via spelling phonetic key, often with o (5)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| J. Cole | #Ask Yourself | 44 | 16 | 388 | loose |
| J. Cole | 03' Adolescence | 61 | 47 | 415 | loose |
| J. Cole | 1 0 0 . m i l ’ | 32 | 24 | 239 | loose |
| J. Cole | 1-888-88-DREAM | 7 | 1 | 22 | loose |
| J. Cole | 100 Grand | 33 | 21 | 171 | loose |
| J. Cole | 102 Jamz Freestyle | 11 | 4 | 55 | loose |
| J. Cole | 102.1 Jamz Freestyle | 16 | 11 | 143 | loose |
| J. Cole | 1985 | 69 | 40 | 372 | loose |
| J. Cole | 1985 Remix | 30 | 17 | 172 | loose |
| J. Cole | 1993 | 71 | 37 | 282 | loose |
| J. Cole | 1994 (Interlude’s Justice) | 42 | 17 | 263 | loose |
| J. Cole | 2007 | 38 | 44 | 215 | loose |
| J. Cole | 2012 | 68 | 44 | 369 | loose |
| J. Cole | 2014 Forest Hills Drive Tour Dates | 66 | 5 | 282 | loose |
| J. Cole | 24k of Gold | 57 | 56 | 326 | loose |
| J. Cole | 29 Intro | 11 | 19 | 27 | loose |
| J. Cole | 2Face | 82 | 48 | 507 | loose |
| J. Cole | 3 Wishes | 33 | 15 | 224 | loose |
| J. Cole | 3001 | 46 | 55 | 421 | loose |
| J. Cole | 39 Intro | 80 | 89 | 518 | loose |
| J. Cole | 4 Your Eyez Only | 139 | 85 | 789 | loose |
| J. Cole | 7 Minute Drill | 58 | 53 | 468 | loose |
| J. Cole | 9 5 . s o u t h | 54 | 71 | 386 | loose |
| J. Cole | 90 Proof | 36 | 25 | 250 | loose |
| J. Cole | 99 Build Freestyle | 61 | 98 | 667 | loose |
| J. Cole | A PLATE OF COLLARD GREENS | 62 | 56 | 458 | loose |
| J. Cole | A Star Is Born | 68 | 29 | 326 | loose |
| J. Cole | A Tale of 2 Citiez | 59 | 67 | 237 | loose |
| J. Cole | ATM | 43 | 61 | 166 | loose |
| J. Cole | Acid Rain (Remix) | 42 | 43 | 253 | loose |
| J. Cole | Adonis Interlude (The Montage) | 30 | 35 | 202 | loose |
| J. Cole | AfricAryaN | 139 | 120 | 590 | loose |
| J. Cole | Ain’t That Some Shit (Interlude) | 49 | 49 | 240 | loose |
| J. Cole | Album of the Year (Freestyle) | 51 | 66 | 291 | loose |
| J. Cole | All I Want Is You | 48 | 21 | 227 | loose |
| J. Cole | All My Life | 70 | 50 | 267 | loose |
| J. Cole | American Dream | 55 | 77 | 449 | loose |
| J. Cole | Amnesia | 24 | 20 | 94 | loose |
| J. Cole | Animals (Remix) | 40 | 27 | 140 | loose |
| J. Cole | Anthem | 35 | 33 | 198 | loose |
| J. Cole | Apparently | 57 | 42 | 236 | loose |
| J. Cole | Atlantic City Freestyle | 7 | 1 | 23 | loose |
| J. Cole | Awaka | 71 | 31 | 496 | loose |
| J. Cole | BRACKETS | 61 | 34 | 387 | loose |
| J. Cole | Back 2 The Topic | 38 | 47 | 279 | loose |
| J. Cole | Back to the Topic | 64 | 73 | 422 | loose |
| J. Cole | Bad Girls Club | 60 | 33 | 270 | loose |
| J. Cole | Bath Salts (J Cole Version) | 15 | 9 | 77 | loose |
| J. Cole | Be (Freestyle) | 43 | 54 | 341 | loose |
| J. Cole | Be Free | 20 | 15 | 53 | loose |
| J. Cole | Beautiful Bliss | 68 | 79 | 487 | loose |
| J. Cole | Been Fucking The World | 52 | 27 | 34 | loose |
| J. Cole | Before I’m Gone | 66 | 64 | 363 | loose |
| J. Cole | Behind Bars Pt. 4 [J. Cole Edition] | 82 | 96 | 782 | loose |
| J. Cole | Best Friend | 41 | 22 | 173 | loose |
| J. Cole | Between Heaven And Earth - Intro | 75 | 79 | 441 | loose |
| J. Cole | Big Dreams | 51 | 46 | 237 | loose |
| J. Cole | Big Energy / I Like You (A Happier Song) / First Class / No Role Modelz (Mixed) | 22 | 9 | 71 | loose |
| J. Cole | Bitchez | 61 | 30 | 264 | loose |
| J. Cole | Bitter | 14 | 5 | 9 | loose |
| J. Cole | Black Friday | 64 | 69 | 509 | loose |
| J. Cole | Black Grammys | 116 | 162 | 603 | loose |
| J. Cole | Black Heaven | 56 | 46 | 350 | loose |
| J. Cole | Black Man in Hollywood | 33 | 43 | 204 | loose |
| J. Cole | Blood Moon | 33 | 33 | 130 | loose |
| J. Cole | Blow Up | 55 | 35 | 295 | loose |
| J. Cole | Blow for Blow | 61 | 65 | 492 | loose |
| J. Cole | Blowin’ Smoke | 35 | 33 | 220 | loose |
| J. Cole | Boblo Boat | 74 | 91 | 527 | loose |
| J. Cole | Boca Raton | 50 | 42 | 165 | loose |
| J. Cole | Bombs in the Ville/Hit the Gas | 63 | 57 | 247 | loose |
| J. Cole | Born Singer | 10 | 0 | 5 | loose |
| J. Cole | Born Sinner | 49 | 58 | 301 | loose |
| J. Cole | Break Out | 39 | 30 | 422 | loose |
| J. Cole | Breakdown | 60 | 32 | 316 | loose |
| J. Cole | Bref Control | 69 | 43 | 421 | loose |
| J. Cole | Breu | 50 | 53 | 454 | loose |
| J. Cole | Bring Em In | 59 | 65 | 319 | loose |
| J. Cole | Bronx Zoo Freestyle | 57 | 53 | 437 | loose |
| J. Cole | Bun B for President | 49 | 52 | 217 | loose |
| J. Cole | Bunce Road Blues | 58 | 31 | 423 | loose |
| J. Cole | Burn Bridges | 56 | 46 | 402 | loose |
| J. Cole | Buyou | 49 | 26 | 216 | loose |
| J. Cole | COLLARD GREENS | 30 | 16 | 207 | loose |
| J. Cole | COULD IT BE YOU | 41 | 61 | 244 | loose |
| J. Cole | Caesar’s Demise | 4 | 1 | 7 | loose |
| J. Cole | Caged Bird | 64 | 49 | 296 | loose |
| J. Cole | Can I Get Witcha | 56 | 55 | 358 | loose |
| J. Cole | Can I Holla At Ya | 61 | 31 | 289 | loose |
| J. Cole | Can I Kick It? (J. Cole Remix) | 34 | 66 | 183 | loose |
| J. Cole | Can I Live? | 58 | 57 | 323 | loose |
| J. Cole | Can’t Call It | 85 | 64 | 394 | loose |
| J. Cole | Can’t Cry | 72 | 41 | 408 | loose |
| J. Cole | Can’t Get Enough | 40 | 26 | 362 | loose |
| J. Cole | Carolina on My Mind | 61 | 45 | 420 | loose |
| J. Cole | Certified (I’m Good) | 49 | 25 | 393 | loose |
| J. Cole | Chaining Day | 54 | 44 | 318 | loose |
| J. Cole | Champion (Remix) | 51 | 28 | 184 | loose |
| J. Cole | Change | 81 | 72 | 440 | loose |
| J. Cole | Change The World | 56 | 33 | 517 | loose |
| J. Cole | Cheer Up | 48 | 34 | 240 | loose |
| J. Cole | Children Of Men | 76 | 73 | 440 | loose |
| J. Cole | Chris Tucker | 44 | 27 | 424 | loose |
| J. Cole | Climate Control | 171 | 122 | 725 | loose |
| J. Cole | Cold Blood | 70 | 33 | 431 | loose |
| J. Cole | Cole Summer | 83 | 51 | 562 | loose |
| J. Cole | Cole World | 47 | 33 | 238 | loose |
| J. Cole | College Boy | 86 | 52 | 426 | loose |
| J. Cole | Come For Me (Unlocked) | 35 | 26 | 60 | loose |
| J. Cole | Come Through and Chill | 57 | 34 | 248 | loose |
| J. Cole | Coming Down | 19 | 12 | 55 | loose |
| J. Cole | Coming Home | 58 | 32 | 183 | loose |
| J. Cole | Coming Home / Whatcha Say / Stay / Whatever You Like | 47 | 30 | 88 | loose |
| J. Cole | Coming Home, Pt. II | 10 | 13 | 48 | loose |
| J. Cole | Cosmic Kev Freestyle | 61 | 56 | 384 | loose |
| J. Cole | Cost Me a Lot | 45 | 30 | 259 | loose |
| J. Cole | Cousins | 56 | 54 | 321 | loose |
| J. Cole | Crazy Love Sickos | 61 | 31 | 381 | loose |
| J. Cole | Crocodile Tearz | 51 | 62 | 269 | loose |
| J. Cole | Crooked Smile | 57 | 40 | 353 | loose |
| J. Cole | Crunch Time | 49 | 47 | 301 | loose |
| J. Cole | Culture | 58 | 71 | 355 | loose |
| J. Cole | D/vision | 79 | 70 | 575 | loose |
| J. Cole | DISC 2 TRACK 2 | 36 | 34 | 157 | loose |
| J. Cole | DJ Enuff Freestyle | 126 | 92 | 913 | loose |
| J. Cole | DREAMERS | 69 | 67 | 258 | loose |
| J. Cole | Daddy’s Little Girl | 30 | 27 | 122 | loose |
| J. Cole | Dead Presidents | 59 | 52 | 446 | loose |
| J. Cole | Dead Presidents II | 55 | 46 | 515 | loose |
| J. Cole | Deja Vu | 55 | 23 | 307 | loose |
| J. Cole | Diamonds | 53 | 26 | 350 | loose |
| J. Cole | Die Together | 52 | 32 | 349 | loose |
| J. Cole | Disgusting | 42 | 35 | 181 | loose |
| J. Cole | Dollar and A Dream | 71 | 32 | 429 | loose |
| J. Cole | Dollar and a Dream II | 64 | 29 | 447 | loose |
| J. Cole | Dollar and a Dream III | 74 | 58 | 449 | loose |
| J. Cole | Down Bad | 66 | 45 | 379 | loose |
| J. Cole | Dr. O’blivion | 29 | 20 | 284 | loose |
| J. Cole | Drank In My Cup Freestyle | 62 | 62 | 217 | loose |
| J. Cole | Dreams | 69 | 58 | 330 | loose |
| J. Cole | Drug Test | 48 | 32 | 345 | loose |
| J. Cole | Drum n Bass | 65 | 76 | 581 | loose |
| J. Cole | Enchanted | 65 | 98 | 471 | loose |
| J. Cole | Evil Ways | 56 | 153 | 523 | loose |
| J. Cole | Expectations | 44 | 16 | 176 | loose |
| J. Cole | Eyez Freestyle | 28 | 13 | 95 | loose |
| J. Cole | FLA | 194 | 191 | 719 | loose |
| J. Cole | FRIENDS | 58 | 102 | 280 | loose |
| J. Cole | FaceTime | 14 | 2 | 9 | loose |
| J. Cole | False Prophets | 63 | 36 | 349 | loose |
| J. Cole | Family and Loyalty | 64 | 41 | 556 | loose |
| J. Cole | Farewell | 53 | 33 | 360 | loose |
| J. Cole | Feel Love | 66 | 47 | 283 | loose |
| J. Cole | Fever | 29 | 20 | 115 | loose |
| J. Cole | Fire Squad | 82 | 73 | 480 | loose |
| J. Cole | Fire Squad Freestyle | 88 | 70 | 504 | loose |
| J. Cole | First Person Shooter | 69 | 71 | 442 | loose |
| J. Cole | Fitted Cap | 63 | 50 | 473 | loose |
| J. Cole | Fly Together (Remix) | 60 | 36 | 290 | loose |
| J. Cole | Foldin Clothes | 49 | 18 | 118 | loose |
| J. Cole | Folgers Crystals | 41 | 18 | 255 | loose |
| J. Cole | For Whom the Bell Tolls | 15 | 11 | 73 | loose |
| J. Cole | Forbidden Fruit | 78 | 78 | 441 | loose |
| J. Cole | Foreigns | 21 | 42 | 224 | loose |
| J. Cole | Fortunate | 36 | 33 | 134 | loose |
| J. Cole | Fragrance | 37 | 24 | 115 | loose |
| J. Cole | Free Fall | 33 | 16 | 147 | loose |
| J. Cole | Freedom of Speech | 41 | 36 | 246 | loose |
| J. Cole | Freestyle (Hip Hop Nation) | 32 | 31 | 117 | loose |
| J. Cole | Freestyle At Kendrick Lamar Concert | 16 | 28 | 55 | loose |
| J. Cole | Friday Night Lights (Intro) | 8 | 3 | 24 | loose |
| J. Cole | Friendly Competition | 54 | 42 | 310 | loose |
| J. Cole | Front Desk | 29 | 34 | 162 | loose |
| J. Cole | Funkmaster Flex Freestyle (Part 2) | 68 | 48 | 471 | loose |
| J. Cole | G.O.M.D. | 86 | 50 | 393 | loose |
| J. Cole | Get Away | 43 | 29 | 294 | loose |
| J. Cole | Get Free ColeWorld | 61 | 38 | 318 | loose |
| J. Cole | Get It | 63 | 46 | 381 | loose |
| J. Cole | Give Nas Prop | 73 | 42 | 561 | loose |
| J. Cole | Gladiators | 38 | 46 | 267 | loose |
| J. Cole | Glistening (Freestyle) | 23 | 15 | 173 | loose |
| J. Cole | Godzilla (Nitin Randhawa Remix) | 156 | 168 | 1466 | loose |
| J. Cole | God’s Gift | 41 | 40 | 174 | loose |
| J. Cole | Goin Off | 54 | 49 | 350 | loose |
| J. Cole | Golden Goose Freestyle | 50 | 75 | 318 | loose |
| J. Cole | Good Game | 52 | 48 | 445 | loose |
| J. Cole | Gotta Throw A Party For My Day Ones 3:40 | 63 | 76 | 268 | loose |
| J. Cole | Greater | 14 | 20 | 23 | loose |
| J. Cole | Green Ranger | 73 | 47 | 350 | loose |
| J. Cole | Greetings | 46 | 119 | 312 | loose |
| J. Cole | Grew Up Fast | 59 | 50 | 444 | loose |
| J. Cole | Grippy | 87 | 85 | 445 | loose |
| J. Cole | Grown Simba | 65 | 47 | 417 | loose |
| J. Cole | Gummy | 23 | 23 | 81 | loose |
| J. Cole | H.Y.B. | 54 | 79 | 499 | loose |
| J. Cole | Hate Me Now | 29 | 27 | 116 | loose |
| J. Cole | Head Bussa | 47 | 46 | 304 | loose |
| J. Cole | Headhunters | 33 | 32 | 223 | loose |
| J. Cole | Heart Attack Remix | 40 | 18 | 258 | loose |
| J. Cole | Heartache | 43 | 34 | 237 | loose |
| J. Cole | Heartless | 76 | 45 | 345 | loose |
| J. Cole | Heavens EP | 43 | 46 | 338 | loose |
| J. Cole | Heavy | 52 | 53 | 270 | loose |
| J. Cole | Heavy Is The Head | 12 | 8 | 25 | loose |
| J. Cole | Hell Nah | 104 | 101 | 543 | loose |
| J. Cole | Hello | 31 | 12 | 93 | loose |
| J. Cole | Hell’s Kitchen | 50 | 47 | 333 | loose |
| J. Cole | Her Eyez Only | 36 | 26 | 176 | loose |
| J. Cole | High for Hours | 77 | 56 | 475 | loose |
| J. Cole | Higher | 52 | 59 | 257 | loose |
| J. Cole | HiiiPoWeR | 72 | 60 | 324 | loose |
| J. Cole | Hold It Down | 65 | 38 | 437 | loose |
| J. Cole | Home Alone | 57 | 79 | 365 | loose |
| J. Cole | Home Soon | 43 | 17 | 251 | loose |
| J. Cole | Home for the Holidays | 67 | 65 | 340 | loose |
| J. Cole | Homecoming | 35 | 18 | 136 | loose |
| J. Cole | Honestly Speaking | 44 | 21 | 256 | loose |
| J. Cole | Hot 97 Freestyle on Flex 05/03/10 | 88 | 63 | 497 | loose |
| J. Cole | House Of Blues Freestyle | 7 | 1 | 38 | loose |
| J. Cole | How Did I Get Here | 85 | 97 | 317 | loose |
| J. Cole | How High | 68 | 38 | 401 | loose |
| J. Cole | How We Live | 28 | 31 | 128 | loose |
| J. Cole | Huntin’ Wabbitz | 45 | 43 | 306 | loose |
| J. Cole | Hurt Feelings | 47 | 63 | 248 | loose |
| J. Cole | I Am a Worm | 14 | 18 | 50 | loose |
| J. Cole | I Can Bus | 47 | 38 | 411 | loose |
| J. Cole | I Do My Thing | 37 | 56 | 272 | loose |
| J. Cole | I Get Up | 61 | 53 | 517 | loose |
| J. Cole | I Got It | 70 | 39 | 384 | loose |
| J. Cole | I Love Her Again | 87 | 81 | 507 | loose |
| J. Cole | I Really Mean It (Freestyle) | 64 | 44 | 377 | loose |
| J. Cole | ICEY.. | 13 | 12 | 25 | loose |
| J. Cole | Icarus | 56 | 40 | 325 | loose |
| J. Cole | Ik Kom Weer Thuis | 45 | 17 | 343 | loose |
| J. Cole | Immortal | 50 | 60 | 283 | loose |
| J. Cole | In The Mornin’ | 59 | 32 | 348 | loose |
| J. Cole | In The Room | 52 | 58 | 319 | loose |
| J. Cole | In the Morning | 57 | 48 | 340 | loose |
| J. Cole | Incognito | 36 | 38 | 235 | loose |
| J. Cole | Infinity+2 | 27 | 17 | 97 | loose |
| J. Cole | Interlude (Sideline Story) | 2 | 0 | 9 | loose |
| J. Cole | Intro (2014 Forest Hills Drive) | 22 | 11 | 48 | loose |
| J. Cole | Intro Real Freestyle | 19 | 6 | 129 | loose |
| J. Cole | Ir Com O Vento | 59 | 56 | 724 | loose |
| J. Cole | Is She Gon Pop | 44 | 43 | 249 | loose |
| J. Cole | Is That You | 28 | 13 | 89 | loose |
| J. Cole | It Only Gets Better | 69 | 52 | 403 | loose |
| J. Cole | It Won’t Be Long | 49 | 33 | 287 | loose |
| J. Cole | It’s On* | 41 | 20 | 248 | loose |
| J. Cole | I’m Coming Home | 31 | 10 | 135 | loose |
| J. Cole | I’m Comin’ | 22 | 16 | 156 | loose |
| J. Cole | I’m On 2.0 | 110 | 111 | 627 | loose |
| J. Cole | I’m On It | 40 | 25 | 218 | loose |
| J. Cole | I’m a Fool | 37 | 63 | 207 | loose |
| J. Cole | I’m the Man | 70 | 36 | 415 | loose |
| J. Cole | J. Cole Freestyle | LA Leakers Freestyle #108 | 78 | 75 | 646 | loose |
| J. Cole | J. Cole’s Top 25 Verses | 17 | 0 | 11 | loose |
| J. Cole | Jack | 49 | 64 | 260 | loose |
| J. Cole | January 28th | 69 | 56 | 336 | loose |
| J. Cole | Javari (Want You to Fly) | 86 | 118 | 545 | loose |
| J. Cole | Jermaine’s Interlude | 34 | 33 | 192 | loose |
| J. Cole | Jodeci Freestyle | 84 | 49 | 455 | loose |
| J. Cole | Johnny P’s Caddy | 61 | 89 | 565 | loose |
| J. Cole | Jst | 12 | 9 | 86 | loose |
| J. Cole | Judgement Day | 50 | 33 | 432 | loose |
| J. Cole | Just Begun | 79 | 78 | 505 | loose |
| J. Cole | Just Face It | 28 | 24 | 143 | loose |
| J. Cole | Just to Get By | 31 | 35 | 261 | loose |
| J. Cole | KOD | 42 | 62 | 246 | loose |
| J. Cole | Keep Heaven Dancing | 64 | 44 | 349 | loose |
| J. Cole | Keith Sweat (Jodeci Freestyle) | 79 | 77 | 494 | loose |
| J. Cole | Kenny Lofton | 56 | 72 | 390 | loose |
| J. Cole | Kerney Sermon (Skit) | 13 | 0 | 23 | loose |
| J. Cole | Kevin’s Heart | 47 | 62 | 189 | loose |
| J. Cole | KiN | 26 | 20 | 66 | loose |
| J. Cole | Kill Ya Dreamz | 68 | 52 | 404 | loose |
| J. Cole | Killah Instinct | 95 | 74 | 495 | loose |
| J. Cole | Killers | 82 | 61 | 489 | loose |
| J. Cole | Kind Of...Sometimes...Maybe (J. Cole Remix) | 27 | 12 | 75 | loose |
| J. Cole | Knock Knock | 37 | 29 | 186 | loose |
| J. Cole | Knock on Wood (Freestyle) | 43 | 50 | 233 | loose |
| J. Cole | Knock tha Hustle (Remix) | 80 | 60 | 454 | loose |
| J. Cole | Knock tha Hustle (Remix) [Video Version] | 29 | 25 | 205 | loose |
| J. Cole | LAUDER | 74 | 72 | 563 | loose |
| J. Cole | LAnd of the Snakes | 74 | 73 | 360 | loose |
| J. Cole | LEGENDARY | 66 | 70 | 525 | loose |
| J. Cole | LONDON | 74 | 72 | 463 | loose |
| J. Cole | LaLa Challenge | 61 | 38 | 344 | loose |
| J. Cole | Ladies | 53 | 43 | 322 | loose |
| J. Cole | Ladies, Ladies, Ladies | 50 | 38 | 329 | loose |
| J. Cole | Land Of The Free | 17 | 8 | 75 | loose |
| J. Cole | Last Call | 121 | 57 | 775 | loose |
| J. Cole | Lauder|Impatient | 111 | 70 | 236 | loose |
| J. Cole | Lay Up | 29 | 29 | 138 | loose |
| J. Cole | Legacy | 60 | 50 | 301 | loose |
| J. Cole | Less Is More | 45 | 80 | 240 | loose |
| J. Cole | Let It Show | 56 | 81 | 336 | loose |
| J. Cole | Let Me Calm Down | 46 | 51 | 361 | loose |
| J. Cole | Let Nas Down | 74 | 47 | 422 | loose |
| J. Cole | Let You All Down | 28 | 12 | 218 | loose |
| J. Cole | Life On The Edge | 35 | 33 | 120 | loose |
| J. Cole | Life Sentence | 70 | 40 | 355 | loose |
| J. Cole | Lifestyle | 64 | 39 | 257 | loose |
| J. Cole | Life’s A Bitch | 19 | 10 | 125 | loose |
| J. Cole | Lights Please | 65 | 42 | 446 | loose |
| J. Cole | Like Dat (Firing Squad Remix) | 29 | 25 | 138 | loose |
| J. Cole | Like It Or Love It | 64 | 94 | 408 | loose |
| J. Cole | Like a Star | 54 | 53 | 270 | loose |
| J. Cole | Lil’ Ghetto Nigga | 58 | 42 | 296 | loose |
| J. Cole | Lil’ Niggaz (Snippet) | 14 | 12 | 56 | loose |
| J. Cole | Limiti | 48 | 28 | 457 | loose |
| J. Cole | Lion King on Ice | 70 | 85 | 468 | loose |
| J. Cole | Lit | 81 | 68 | 398 | loose |
| J. Cole | Live And Learn | 51 | 31 | 227 | loose |
| J. Cole | Lone Wolf (Intro) | 19 | 24 | 99 | loose |
| J. Cole | Lonely at the Top | 37 | 54 | 304 | loose |
| J. Cole | Long The Way | 38 | 43 | 108 | loose |
| J. Cole | Look Alive (Nitin Randhawa Remix) | 175 | 172 | 1410 | loose |
| J. Cole | Look In The Mirror (Remix) | 71 | 79 | 305 | loose |
| J. Cole | Looking for Trouble | 94 | 134 | 595 | loose |
| J. Cole | Losing My Balance | 66 | 35 | 316 | loose |
| J. Cole | Lost Ones | 68 | 39 | 351 | loose |
| J. Cole | Loui V | 16 | 6 | 58 | loose |
| J. Cole | Louis Vuitton | 68 | 59 | 280 | loose |
| J. Cole | Love Me Not | 43 | 31 | 197 | loose |
| J. Cole | Love Yourz | 43 | 29 | 220 | loose |
| J. Cole | Love and War | 18 | 7 | 45 | loose |
| J. Cole | Love me cray | 22 | 10 | 112 | loose |
| J. Cole | Loves Me Not | 20 | 14 | 139 | loose |
| J. Cole | Loyal | 36 | 31 | 167 | loose |
| J. Cole | M.P.A. | 62 | 38 | 243 | loose |
| J. Cole | MAFIA | 38 | 52 | 196 | loose |
| J. Cole | MIDDLE CHILD | 65 | 74 | 238 | loose |
| J. Cole | MTV Raps! | 89 | 52 | 410 | loose |
| J. Cole | Ma Boy | 45 | 44 | 158 | loose |
| J. Cole | Made Nas Proud (Let Nas Down Remix) | 50 | 42 | 307 | loose |
| J. Cole | Maine On Fire | 41 | 46 | 254 | loose |
| J. Cole | Make It Far | 56 | 49 | 205 | loose |
| J. Cole | Mama Told Me | 72 | 56 | 408 | loose |
| J. Cole | Mama’s Eyes | 22 | 5 | 126 | loose |
| J. Cole | Man Up Above | 64 | 66 | 536 | loose |
| J. Cole | Marcus, My Dear Friend (Feat. J. Cole) - Caesars Edition | 44 | 47 | 260 | loose |
| J. Cole | May the Bitter Man Win | 49 | 32 | 117 | loose |
| J. Cole | Meddafore Freestyle | 19 | 6 | 179 | loose |
| J. Cole | Mic Please | 72 | 56 | 642 | loose |
| J. Cole | Middle Child Freestyle | 27 | 46 | 335 | loose |
| J. Cole | Mighty Crazy | 25 | 13 | 188 | loose |
| J. Cole | Mighty Mouse | 51 | 46 | 309 | loose |
| J. Cole | Miles | 70 | 54 | 530 | loose |
| J. Cole | Miss America | 56 | 40 | 314 | loose |
| J. Cole | Miss America Reprise | 44 | 44 | 241 | loose |
| J. Cole | Mitus Touch | 35 | 29 | 249 | loose |
| J. Cole | Mo Money (Interlude) | 24 | 0 | 196 | loose |
| J. Cole | Moments (Original) | 33 | 16 | 119 | loose |
| J. Cole | Motiv8 | 31 | 17 | 147 | loose |
| J. Cole | Mr. Biggs | 39 | 28 | 161 | loose |
| J. Cole | Mr. Nice Watch | 56 | 48 | 337 | loose |
| J. Cole | Mufasa Jr. | 69 | 83 | 457 | loose |
| J. Cole | Murder | 78 | 70 | 528 | loose |
| J. Cole | My Boy (Freestyle) | 79 | 44 | 449 | loose |
| J. Cole | My Favorite Things | 15 | 17 | 43 | loose |
| J. Cole | My Life (J. Cole Remix) | 36 | 35 | 119 | loose |
| J. Cole | My Nigga Just Made Bail | 72 | 60 | 372 | loose |
| J. Cole | N.E.R.D. | 31 | 32 | 232 | loose |
| J. Cole | NBA Playoff Promo | 20 | 13 | 120 | loose |
| J. Cole | NY State Of Mind (Freestyle) | 26 | 17 | 125 | loose |
| J. Cole | Need U Bad (Remix) | 45 | 16 | 189 | loose |
| J. Cole | Neighbors | 63 | 39 | 179 | loose |
| J. Cole | Never Told | 34 | 18 | 337 | loose |
| J. Cole | Neverland | 45 | 68 | 198 | loose |
| J. Cole | New Year’s Resolution (Be Free Remix) | 27 | 19 | 102 | loose |
| J. Cole | New York Times | 65 | 55 | 365 | loose |
| J. Cole | Niggaz Know | 61 | 41 | 304 | loose |
| J. Cole | Night Job | 58 | 57 | 356 | loose |
| J. Cole | No Holding Me Back | 29 | 24 | 91 | loose |
| J. Cole | No Role Modelz | 55 | 35 | 276 | loose |
| J. Cole | No Settling | 21 | 14 | 130 | loose |
| J. Cole | No Sleeep | 48 | 21 | 219 | loose |
| J. Cole | Nobody’s Perfect | 40 | 27 | 202 | loose |
| J. Cole | Note to Self | 262 | 89 | 1125 | loose |
| J. Cole | Nothing Lasts Forever | 57 | 36 | 307 | loose |
| J. Cole | Nothing Like It | 63 | 64 | 507 | loose |
| J. Cole | Nothin’ For The Radio | 33 | 32 | 180 | loose |
| J. Cole | O N E . M O R E . T I M E ! | 74 | 68 | 313 | loose |
| J. Cole | OFG! | 68 | 65 | 387 | loose |
| J. Cole | OSOM | 85 | 73 | 370 | loose |
| J. Cole | Obviously | 31 | 6 | 133 | loose |
| J. Cole | Ocean Way | 18 | 27 | 61 | AAAA |
| J. Cole | Off Deez | 82 | 110 | 532 | loose |
| J. Cole | Ogogoro | 24 | 15 | 84 | loose |
| J. Cole | Oh Wow...Swerve | 64 | 49 | 377 | loose |
| J. Cole | Old Dog | 57 | 39 | 329 | loose |
| J. Cole | On Top of the World | 44 | 34 | 284 | loose |
| J. Cole | On and On | 75 | 65 | 553 | loose |
| J. Cole | On the Road Freestyle | 26 | 17 | 163 | loose |
| J. Cole | Once an Addict (Interlude) | 51 | 23 | 238 | loose |
| J. Cole | One Life | 43 | 37 | 183 | loose |
| J. Cole | Only Wanna Give It To You | 40 | 23 | 223 | loose |
| J. Cole | Only You | 64 | 53 | 304 | loose |
| J. Cole | PE LA NOI | 66 | 24 | 630 | loose |
| J. Cole | POF | 31 | 17 | 124 | loose |
| J. Cole | POWER 08.07.2023 v3 | 51 | 34 | 273 | loose |
| J. Cole | Palm Trees | 39 | 36 | 232 | loose |
| J. Cole | Paper Cuts | 26 | 22 | 181 | loose |
| J. Cole | PapiraRaw (J. Cole Remix) | 8 | 0 | 17 | loose |
| J. Cole | Party (Remix) | 33 | 14 | 145 | loose |
| J. Cole | Passport Bros | 33 | 19 | 147 | loose |
| J. Cole | Perspectives | 51 | 47 | 359 | loose |
| J. Cole | Photograph | 42 | 51 | 113 | loose |
| J. Cole | Pi | 110 | 124 | 881 | loose |
| J. Cole | Pinball II | 77 | 66 | 420 | loose |
| J. Cole | Pity | 62 | 40 | 423 | loose |
| J. Cole | Plain | 25 | 11 | 111 | loose |
| J. Cole | Planez | 57 | 30 | 241 | loose |
| J. Cole | Playground | 46 | 40 | 156 | loose |
| J. Cole | Poke It Out | 49 | 22 | 213 | loose |
| J. Cole | Poor Thang | 70 | 83 | 585 | loose |
| J. Cole | Popular | 6 | 0 | 38 | loose |
| J. Cole | Port Antonio | 80 | 96 | 655 | loose |
| J. Cole | Power 105.1 Freestyle | 46 | 17 | 229 | loose |
| J. Cole | Power 106 Freestyle with Joey Bada$$ | 96 | 66 | 457 | loose |
| J. Cole | Power Trip | 46 | 15 | 214 | loose |
| J. Cole | Pray | 80 | 72 | 339 | loose |
| J. Cole | Premeditated Murder | 53 | 46 | 242 | loose |
| J. Cole | Pretty Little Fears | 58 | 44 | 235 | loose |
| J. Cole | Pricey | 83 | 117 | 775 | loose |
| J. Cole | Prietene | 83 | 38 | 1201 | loose |
| J. Cole | Problems (Demo) | 55 | 28 | 202 | loose |
| J. Cole | Produced by J. Cole | 96 | 63 | 303 | loose |
| J. Cole | Proud 2 Be Hmong | 53 | 42 | 128 | loose |
| J. Cole | Prove It | 57 | 32 | 255 | loose |
| J. Cole | Pulparanthatre | 31 | 13 | 142 | loose |
| J. Cole | Purge | 53 | 45 | 341 | loose |
| J. Cole | Purple Emoji | 39 | 37 | 241 | loose |
| J. Cole | Purple Rain | 39 | 25 | 223 | loose |
| J. Cole | Queen Space | 25 | 23 | 98 | loose |
| J. Cole | Quik Stop | 60 | 98 | 553 | loose |
| J. Cole | Quote Me | 49 | 42 | 282 | loose |
| J. Cole | RAP GAME OVER | 42 | 23 | 664 | loose |
| J. Cole | RNP | 36 | 23 | 295 | loose |
| J. Cole | Ragamuffin (Remix) | 45 | 33 | 183 | loose |
| J. Cole | Raggamuffin (Remix) | 35 | 20 | 76 | loose |
| J. Cole | Rags to Riches (At the Beep) | 65 | 46 | 362 | loose |
| J. Cole | Rappa Magazine Freestyle | 25 | 22 | 178 | loose |
| J. Cole | Rather Be (Vagina Is For Lovers) | 78 | 87 | 460 | loose |
| J. Cole | Ready ’24 | 61 | 107 | 483 | loose |
| J. Cole | Red Leather | 116 | 130 | 582 | loose |
| J. Cole | Reddit AMA | 44 | 19 | 304 | loose |
| J. Cole | Relaxation | 68 | 75 | 413 | loose |
| J. Cole | Rembrandt...Run It Back | 55 | 64 | 373 | loose |
| J. Cole | Return Of Simba | 81 | 68 | 476 | loose |
| J. Cole | Revenge of the Dreamers | 59 | 34 | 459 | loose |
| J. Cole | Rich Niggaz | 77 | 78 | 392 | loose |
| J. Cole | Rise Above | 43 | 18 | 235 | loose |
| J. Cole | Rise and Shine | 81 | 72 | 525 | loose |
| J. Cole | Rivercity Was Us (Outro) | 172 | 148 | 1230 | loose |
| J. Cole | Roll Call | 26 | 10 | 124 | loose |
| J. Cole | Royal Flush | 34 | 32 | 189 | loose |
| J. Cole | Ruby Rosary | 82 | 87 | 635 | loose |
| J. Cole | Run a Train | 40 | 46 | 370 | loose |
| J. Cole | Runaway | 75 | 50 | 453 | loose |
| J. Cole | S&M (J. Cole Remix) | 33 | 15 | 107 | loose |
| J. Cole | SAFETY | 103 | 60 | 699 | loose |
| J. Cole | Sacrifices | 116 | 97 | 522 | loose |
| J. Cole | Sanufa | 12 | 12 | 25 | loose |
| J. Cole | Sapiosexual | 46 | 30 | 198 | loose |
| J. Cole | Say Na | 52 | 27 | 105 | loose |
| J. Cole | Scared Money | 50 | 47 | 362 | loose |
| J. Cole | School Daze | 69 | 41 | 457 | loose |
| J. Cole | See It To Believe It | 41 | 42 | 200 | loose |
| J. Cole | See World | 51 | 41 | 354 | loose |
| J. Cole | Serenade | 32 | 17 | 195 | loose |
| J. Cole | Shadows | 17 | 8 | 40 | loose |
| J. Cole | She Knows | 49 | 29 | 150 | loose |
| J. Cole | Shea Butter Baby | 27 | 14 | 149 | loose |
| J. Cole | She’s Mine, Pt. 1 | 30 | 24 | 157 | loose |
| J. Cole | She’s Mine, Pt. 2 | 44 | 16 | 192 | loose |
| J. Cole | Shock the World | 54 | 29 | 295 | loose |
| J. Cole | Shook Ones (Freestyle) | 35 | 22 | 180 | loose |
| J. Cole | Show Me Something | 60 | 34 | 345 | loose |
| J. Cole | Sick | 75 | 94 | 669 | loose |
| J. Cole | Sideline Story | 65 | 59 | 444 | loose |
| J. Cole | Sideline Story Remix | 38 | 62 | 334 | loose |
| J. Cole | Simba | 56 | 34 | 360 | loose |
| J. Cole | Skrawberries | 48 | 49 | 315 | loose |
| J. Cole | Sky Boy | 54 | 58 | 372 | loose |
| J. Cole | Smallville | 54 | 64 | 351 | loose |
| J. Cole | Smuty (skit) | 5 | 3 | 30 | loose |
| J. Cole | Snow On Tha Bluff | 48 | 37 | 406 | loose |
| J. Cole | Sojourner | 72 | 95 | 509 | loose |
| J. Cole | Song for the Ville | 62 | 36 | 362 | loose |
| J. Cole | Sound of Love | 28 | 21 | 240 | loose |
| J. Cole | Sparks Will Fly | 41 | 22 | 166 | loose |
| J. Cole | Split You Up | 39 | 34 | 248 | loose |
| J. Cole | St. Tropez | 22 | 4 | 75 | loose |
| J. Cole | Stain in the Game | 27 | 22 | 147 | loose |
| J. Cole | Stars | 73 | 84 | 449 | loose |
| J. Cole | Stay (2009) | 41 | 40 | 182 | loose |
| J. Cole | Stealth Mode | 28 | 17 | 204 | loose |
| J. Cole | Stick | 89 | 140 | 465 | loose |
| J. Cole | Stickz N Stonez | 49 | 50 | 645 | loose |
| J. Cole | Still Slummin’ | 41 | 25 | 243 | loose |
| J. Cole | Still the Hottest | 51 | 36 | 331 | loose |
| J. Cole | Stole Summer (Let ’Em Know) | 55 | 58 | 275 | loose |
| J. Cole | Stressed | 59 | 64 | 362 | loose |
| J. Cole | Summer Drop | 33 | 43 | 253 | loose |
| J. Cole | Sun | 94 | 181 | 774 | loose |
| J. Cole | Sunset | 45 | 67 | 250 | loose |
| J. Cole | Supply Luh | 20 | 18 | 49 | loose |
| J. Cole | Sweater weather | 25 | 13 | 72 | loose |
| J. Cole | Syrhenz | 74 | 50 | 406 | loose |
| J. Cole | TKO (Black Friday Remix) | 80 | 67 | 578 | loose |
| J. Cole | Talk To Me | 31 | 18 | 172 | loose |
| J. Cole | Tatted | 18 | 10 | 27 | loose |
| J. Cole | Tears for ODB | 43 | 37 | 338 | loose |
| J. Cole | Tell Everybody | 34 | 12 | 464 | loose |
| J. Cole | Temptation | 45 | 40 | 334 | loose |
| J. Cole | Thanks | 51 | 33 | 215 | loose |
| J. Cole | The Allure | 53 | 49 | 326 | loose |
| J. Cole | The Autograph | 66 | 73 | 411 | loose |
| J. Cole | The Badness | 37 | 30 | 239 | loose |
| J. Cole | The Come Up | 49 | 75 | 338 | loose |
| J. Cole | The Come Up Show Freestyle | 336 | 379 | 2429 | loose |
| J. Cole | The Cure | 79 | 69 | 558 | loose |
| J. Cole | The Cut Off | 36 | 19 | 126 | loose |
| J. Cole | The Elderly | 65 | 55 | 489 | loose |
| J. Cole | The Fall-Off Is Inevitable | 47 | 75 | 254 | loose |
| J. Cole | The Goat (Skit) [The Man, The Myth, The Legend Interlude Demo] | 29 | 5 | 77 | loose |
| J. Cole | The Good Son Pt. 1 | 27 | 20 | 136 | loose |
| J. Cole | The Jig Is Up (Dump’n) | 62 | 31 | 312 | loose |
| J. Cole | The Last Stretch | 69 | 52 | 274 | loose |
| J. Cole | The Let Out | 47 | 23 | 270 | loose |
| J. Cole | The London | 56 | 41 | 244 | loose |
| J. Cole | The Ojays | 72 | 39 | 426 | loose |
| J. Cole | The One | 61 | 63 | 396 | loose |
| J. Cole | The Pessimist | 67 | 37 | 413 | loose |
| J. Cole | The Plan | 43 | 29 | 235 | loose |
| J. Cole | The Reasons | 22 | 15 | 196 | loose |
| J. Cole | The Secret Recipe | 62 | 129 | 611 | loose |
| J. Cole | The Storm | 58 | 16 | 348 | loose |
| J. Cole | The Villest | 59 | 49 | 464 | loose |
| J. Cole | The Villest Freestyle | 15 | 20 | 61 | loose |
| J. Cole | There I Go | 43 | 38 | 292 | loose |
| J. Cole | They Ready | 53 | 57 | 311 | loose |
| J. Cole | Things Change | 53 | 43 | 390 | loose |
| J. Cole | This House is Haunted | 18 | 11 | 42 | loose |
| J. Cole | This Time | 41 | 21 | 169 | loose |
| J. Cole | Thotty | 36 | 27 | 141 | loose |
| J. Cole | Throne | 82 | 95 | 553 | loose |
| J. Cole | Throw It Up | 66 | 73 | 462 | loose |
| J. Cole | Tidal Wave (just a little reference) | 14 | 5 | 33 | loose |
| J. Cole | Til’ Infinity | 37 | 30 | 312 | loose |
| J. Cole | Tim Westwood Freestyle | 39 | 10 | 257 | loose |
| J. Cole | Time Well Spent* | 57 | 40 | 205 | loose |
| J. Cole | To Summer, From Cole (Audio Hug) | 36 | 20 | 147 | loose |
| J. Cole | Too Deep for the Intro | 59 | 40 | 359 | loose |
| J. Cole | Too Hard | 19 | 5 | 89 | loose |
| J. Cole | Trae Tha Truth in Ibiza (Remix) | 46 | 53 | 268 | loose |
| J. Cole | Trae The Truth in Ibiza | 80 | 81 | 382 | loose |
| J. Cole | Trapologist | 48 | 43 | 344 | loose |
| J. Cole | Tribe | 54 | 28 | 246 | loose |
| J. Cole | Trippy | 54 | 29 | 332 | loose |
| J. Cole | Trouble | 51 | 42 | 269 | loose |
| J. Cole | True Love | 57 | 35 | 435 | loose |
| J. Cole | Twins Forever - Remix | 43 | 37 | 179 | loose |
| J. Cole | Two Six | 54 | 59 | 365 | loose |
| J. Cole | Two Tens | 31 | 41 | 247 | loose |
| J. Cole | Unabomber | 54 | 58 | 311 | loose |
| J. Cole | Under the Sun | 66 | 68 | 408 | loose |
| J. Cole | Undercover | 44 | 28 | 198 | loose |
| J. Cole | Untitled. | 43 | 35 | 256 | loose |
| J. Cole | VIII | 39 | 21 | 34 | loose |
| J. Cole | VOLUME 1 - 1985 | 68 | 79 | 410 | loose |
| J. Cole | Vendetta | 44 | 44 | 207 | loose |
| J. Cole | Victory (Freestyle) | 37 | 42 | 93 | loose |
| J. Cole | Ville Mentality | 19 | 15 | 79 | loose |
| J. Cole | Villematic | 51 | 56 | 261 | loose |
| J. Cole | Villuminati | 91 | 53 | 498 | loose |
| J. Cole | Visionz of Home | 37 | 30 | 191 | loose |
| J. Cole | Voodoo | 47 | 81 | 195 | loose |
| J. Cole | WATERBOYZ | 105 | 117 | 529 | loose |
| J. Cole | WHO TF IZ U | 70 | 103 | 557 | loose |
| J. Cole | Wait For Tomorrow | 24 | 19 | 82 | loose |
| J. Cole | Warm Enough | 60 | 51 | 245 | loose |
| J. Cole | Watch Me Go | 48 | 60 | 321 | loose |
| J. Cole | Water Break (Interlude) | 47 | 35 | 392 | loose |
| J. Cole | We On | 33 | 41 | 289 | loose |
| J. Cole | Welcome | 37 | 24 | 273 | loose |
| J. Cole | Wet Dreamz | 60 | 32 | 336 | loose |
| J. Cole | What If | 84 | 72 | 409 | loose |
| J. Cole | Whats Poppin (Nitin Randhawa Remix) | 273 | 328 | 1422 | loose |
| J. Cole | Where’s Jermaine? (Skit) | 10 | 2 | 20 | loose |
| J. Cole | Who Am I? | 55 | 43 | 445 | loose |
| J. Cole | Who Dat | 61 | 48 | 407 | loose |
| J. Cole | Who Datt Pt. 2 | 73 | 45 | 458 | loose |
| J. Cole | Who Hot* | 13 | 12 | 54 | loose |
| J. Cole | Whole House | 46 | 41 | 325 | loose |
| J. Cole | Who’s World is This | 26 | 22 | 139 | loose |
| J. Cole | Will (Nitin Randhawa Remix) | 170 | 194 | 1100 | loose |
| J. Cole | Willow Tree | 29 | 27 | 219 | loose |
| J. Cole | Window Pain (Outro) | 56 | 50 | 379 | loose |
| J. Cole | Winter Schemes | 93 | 97 | 579 | loose |
| J. Cole | Winter Storm Freestyle | 44 | 36 | 247 | loose |
| J. Cole | Winter Wonderland | 46 | 47 | 263 | loose |
| J. Cole | Wireless 2012 Freestyle | 22 | 14 | 223 | loose |
| J. Cole | Work Out | 54 | 39 | 157 | loose |
| J. Cole | World Premiere | 47 | 41 | 321 | loose |
| J. Cole | World is Empty | 48 | 73 | 264 | loose |
| J. Cole | Writers Block | 59 | 59 | 528 | loose |
| J. Cole | XXL Freshman Freestyle: J. Cole | 7 | 3 | 43 | loose |
| J. Cole | XXVII | 18 | 9 | 15 | loose |
| J. Cole | Yesterday’s Paper (Un Intro) | 21 | 20 | 97 | loose |
| J. Cole | Yo No Habla | 50 | 53 | 216 | loose |
| J. Cole | You Got It | 66 | 52 | 412 | loose |
| J. Cole | Your Heart | 55 | 54 | 226 | loose |
| J. Cole | Zendaya | 63 | 83 | 403 | loose |
| J. Cole | [Admire Her] | 27 | 29 | 299 | loose |
| J. Cole | [The Jackie] | 35 | 13 | 160 | loose |
| J. Cole | [The Others] | 33 | 26 | 153 | loose |
| J. Cole | a lot | 77 | 75 | 319 | loose |
| J. Cole | a m a r i | 45 | 82 | 218 | loose |
| J. Cole | a p p l y i n g . p r e s s u r e | 45 | 25 | 364 | loose |
| J. Cole | and the whole world is the Ville | 55 | 40 | 345 | loose |
| J. Cole | c l o s e | 43 | 123 | 257 | AAAA |
| J. Cole | cLOUDs | 70 | 57 | 691 | loose |
| J. Cole | everybody dies | 42 | 37 | 235 | loose |
| J. Cole | h u n g e r . o n . h i l l s i d e | 51 | 44 | 247 | loose |
| J. Cole | hellfire | 27 | 22 | 33 | loose |
| J. Cole | i n t e r l u d e | 47 | 47 | 200 | loose |
| J. Cole | l e t . g o . m y . h a n d | 54 | 36 | 281 | loose |
| J. Cole | love letter | 29 | 22 | 333 | loose |
| J. Cole | m y . l i f e | 63 | 122 | 449 | loose |
| J. Cole | on the street | 45 | 20 | 178 | loose |
| J. Cole | p r i d e . i s . t h e . d e v i l | 55 | 71 | 344 | loose |
| J. Cole | p u n c h i n ’ . t h e . c l o c k | 40 | 47 | 219 | loose |
| J. Cole | procrastination (broke) | 52 | 35 | 190 | loose |
| J. Cole | t h e . c l i m b . b a c k | 76 | 75 | 759 | loose |
