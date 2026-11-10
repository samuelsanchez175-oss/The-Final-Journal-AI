# Rick Ross rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rick Ross
- Songs: 1266
- Bars kept (Rick Ross lyric lines): 62985
- Section headers dropped, not counted as bars: 3
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 16
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 75
- Canonical name: Rick Ross.
- Credit strings: Rick Ross.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 371408
- REPEAT pairs, recorded separately: 41642
- END rhymes: 50796
- INNER rhymes: 320612

By match:

- PERFECT: 30783 (END 7539, INNER 23244)
- SLANT: 152716 (END 21022, INNER 131694)
- ASSONANCE: 183497 (END 21195, INNER 162302)
- MULTI: 4412 (END 1040, INNER 3372)

By confidence:

- HIGH: 31534
- MED: 318586
- LOW: 21288

## Core

- Core Y: 364836
- Core N among rhyme pairs: 6572

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 165390 (44.5%)
- vowel: 183497 (49.4%)
- spelling: 18109 (4.9%)
- multi: 4412 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 6 songs
- AABB: 1 songs
- ABAA: 1 songs
- loose: 1258 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 28463 pairs (END 2744, INNER 25719). Words: bitches, bitch, shit, think, still, million, big, give.
2. `vow:EH` — 23562 pairs (END 2172, INNER 21390). Words: get, when, never, gettin, best, where, getting, tell.
3. `vow:OW` — 21221 pairs (END 2423, INNER 18798). Words: know, don't, no, go, only, hoes, told, dope.
4. `vow:AA` — 19996 pairs (END 2245, INNER 17751). Words: got, want, hard, talkin, wanna, bottles, nothin, cause.
5. `vow:EY` — 19353 pairs (END 2634, INNER 16719). Words: ain't, say, way, make, day, baby, play, take.
6. `vow:AE` — 15529 pairs (END 2065, INNER 13464). Words: back, can't, can, had, man, have, black, last.
7. `vow:IY` — 14621 pairs (END 1597, INNER 13024). Words: see, these, even, keep, streets, need, g, real.
8. `vow:AH` — 13620 pairs (END 1308, INNER 12312). Words: money, hundred, fuck, love, what, one, double, some.
9. `vow:AY` — 13094 pairs (END 1744, INNER 11350). Words: like, by, time, high, mind, die, why, life.
10. `slant:AA:stop` — 7093 pairs (END 810, INNER 6283). Words: got, gotta, want, top, not, block, stop, drop.
11. `slant:IH:stop` — 6723 pairs (END 799, INNER 5924). Words: nigga, shit, big, hit, city, dick, crib, whip.
12. `vow:AO` — 4947 pairs (END 609, INNER 4338). Words: all, talking, call, wanted, lord, more, lost, corner.
13. `slant:IH:sib-stop` — 4778 pairs (END 827, INNER 3951). Words: bitch, nigga, niggas, shit, rich, big, hit, dick.
14. `slant:EH:stop` — 4308 pairs (END 529, INNER 3779). Words: get, better, let, head, check, best, said, neck.
15. `vow:UW` — 4020 pairs (END 615, INNER 3405). Words: new, who, two, through, music, used, move, gucci.
16. `slant:AH:nas-stop` — 3909 pairs (END 161, INNER 3748). Words: fuck, money, what, one, come, some, young, run.
17. `slant:AE:stop` — 3750 pairs (END 645, INNER 3105). Words: back, had, black, bad, bag, can't, rap, fat.
18. `cmu:OW` — 3703 pairs (END 587, INNER 3116). Words: know, no, go, show, blow, ho, though, low.
19. `slant:EH:liq-stop` — 3282 pairs (END 137, INNER 3145). Words: get, tell, where, let, there, better, said, well.
20. `slant:EH:nas-stop` — 3219 pairs (END 121, INNER 3098). Words: when, get, let, ten, better, em, m, again.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 4693 pair sides, mostly spelling via spelling phonetic key, often with niggas (1200)
- niggas — 2114 pair sides, mostly spelling via spelling phonetic key, often with nigga (1200)
- ima — 833 pair sides, mostly spelling via spelling phonetic key, often with bitch (82)
- gon — 685 pair sides, mostly spelling via spelling phonetic key, often with dont (112)
- tryna — 516 pair sides, mostly spelling via spelling phonetic key, often with these (51)
- shawty — 448 pair sides, mostly vowel via spelling phonetic key, often with all (43)
- homie — 207 pair sides, mostly spelling via spelling phonetic key, often with gon (31)
- imma — 192 pair sides, mostly vowel via spelling phonetic key, often with nigga (62)
- cuz — 164 pair sides, mostly spelling via spelling phonetic key, often with fuck (20)
- swag — 132 pair sides, mostly spelling via spelling phonetic key, often with had (10)
- dem — 127 pair sides, mostly spelling via spelling phonetic key, often with get (11)
- rozay — 111 pair sides, mostly spelling via spelling phonetic key, often with say (7)
- weezy — 109 pair sides, mostly vowel via spelling phonetic key, often with baby (12)
- bling — 104 pair sides, mostly spelling via spelling phonetic key, often with selling (7)
- dawg — 98 pair sides, mostly spelling via spelling phonetic key, often with all (23)
- finna — 97 pair sides, mostly vowel via spelling phonetic key, often with nigga (29)
- tes — 87 pair sides, mostly spelling via spelling phonetic key, often with en (9)
- wraith — 82 pair sides, mostly spelling via spelling phonetic key, often with face (7)
- 2pac — 79 pair sides, mostly spelling via spelling phonetic key, often with back (15)
- eazy — 78 pair sides, mostly spelling via spelling phonetic key, often with easy (7)
- mes — 76 pair sides, mostly spelling via spelling phonetic key, often with les (9)
- lambo — 73 pair sides, mostly vowel via spelling phonetic key, often with no (9)
- snitches — 61 pair sides, mostly spelling via spelling phonetic key, often with bitches (14)
- yayo — 56 pair sides, mostly vowel via spelling phonetic key, often with know (11)
- bezel — 55 pair sides, mostly vowel via spelling phonetic key, often with when (4)
- maybach — 54 pair sides, mostly spelling via spelling phonetic key, often with baby (13)
- hella — 53 pair sides, mostly spelling via spelling phonetic key, often with tell (6)
- jeezy — 53 pair sides, mostly vowel via spelling phonetic key, often with weezy (3)
- realest — 51 pair sides, mostly vowel via spelling phonetic key, often with these (4)
- migo — 51 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rick Ross | #1 Stunna | 28 | 16 | 111 | loose |
| Rick Ross | #23 | 26 | 26 | 130 | loose |
| Rick Ross | #GRUBY OVM intro | 7 | 2 | 50 | loose |
| Rick Ross | $$$ Signs | 30 | 30 | 184 | loose |
| Rick Ross | .40 | 43 | 30 | 142 | loose |
| Rick Ross | 01. Cutback Season | 39 | 30 | 107 | loose |
| Rick Ross | 1 Question | 41 | 28 | 199 | loose |
| Rick Ross | 1.8.7 | 60 | 42 | 453 | loose |
| Rick Ross | 1.NO ISSUES | 38 | 37 | 231 | loose |
| Rick Ross | 10 2 10 (Remix) | 73 | 65 | 464 | loose |
| Rick Ross | 10 Bricks | 35 | 19 | 163 | loose |
| Rick Ross | 10 Summaz | 42 | 41 | 265 | loose |
| Rick Ross | 100 Black Coffins | 35 | 26 | 162 | loose |
| Rick Ross | 100 Keys | 52 | 55 | 289 | loose |
| Rick Ross | 100 Million | 59 | 46 | 261 | loose |
| Rick Ross | 100% | 52 | 27 | 238 | loose |
| Rick Ross | 2 Shots | 42 | 19 | 295 | loose |
| Rick Ross | 2011 BET Hip Hop Awards - Maybach Music Group Cypher | 88 | 85 | 558 | loose |
| Rick Ross | 3 Kings | 79 | 64 | 341 | loose |
| Rick Ross | 30 for 30 Freestyle | 32 | 34 | 201 | loose |
| Rick Ross | 300 Soldiers | 32 | 15 | 162 | loose |
| Rick Ross | 350 | 45 | 35 | 210 | loose |
| Rick Ross | 3Hunna (Album Version) | 38 | 32 | 110 | loose |
| Rick Ross | 4 U | 52 | 24 | 139 | loose |
| Rick Ross | 5 Star (Remix) | 42 | 20 | 157 | loose |
| Rick Ross | 50 In Da Safe | 47 | 21 | 174 | loose |
| Rick Ross | 50 Plates | 39 | 88 | 90 | loose |
| Rick Ross | 6 in the Morning (Remix) | 20 | 8 | 26 | loose |
| Rick Ross | 600 Benz | 63 | 41 | 310 | loose |
| Rick Ross | 7 Acoustic Covers (Medley) | 31 | 18 | 69 | loose |
| Rick Ross | 737 | 53 | 79 | 401 | loose |
| Rick Ross | 8 Figgaz | 25 | 10 | 89 | loose |
| Rick Ross | 800 Karats | 43 | 65 | 266 | loose |
| Rick Ross | 9 Piece | 39 | 26 | 153 | loose |
| Rick Ross | 9-24-7000 | 42 | 29 | 296 | loose |
| Rick Ross | 911 | 34 | 19 | 171 | loose |
| Rick Ross | A GEOMETRY’S DASH | 465 | 235 | 1484 | loose |
| Rick Ross | A Hunnit a Show | 45 | 38 | 192 | loose |
| Rick Ross | A Miracle | 54 | 53 | 465 | loose |
| Rick Ross | About That Life | 62 | 33 | 389 | loose |
| Rick Ross | Above The Law | 50 | 31 | 244 | loose |
| Rick Ross | Accident Murderers | 60 | 55 | 404 | loose |
| Rick Ross | Act a Fool | 68 | 67 | 296 | loose |
| Rick Ross | Addicted | 41 | 33 | 166 | loose |
| Rick Ross | Aight | 7 | 1 | 101 | loose |
| Rick Ross | Aiight | 46 | 28 | 188 | loose |
| Rick Ross | AintNuttin | 59 | 0 | 353 | loose |
| Rick Ross | Ain’t Shhh To Discuss | 38 | 65 | 212 | loose |
| Rick Ross | Ain’t Worried About Nothin (Remix 2) | 45 | 22 | 182 | loose |
| Rick Ross | Albert Pujols | 50 | 30 | 253 | loose |
| Rick Ross | Ali Bomaye | 96 | 73 | 515 | loose |
| Rick Ross | All About The Money | 56 | 65 | 238 | loose |
| Rick Ross | All Away | 46 | 24 | 262 | loose |
| Rick Ross | All Birds | 43 | 23 | 224 | loose |
| Rick Ross | All Day | 13 | 20 | 64 | loose |
| Rick Ross | All Good | 59 | 35 | 339 | loose |
| Rick Ross | All I Do Is Win | 44 | 24 | 266 | loose |
| Rick Ross | All I Have in This World | 48 | 32 | 306 | loose |
| Rick Ross | All I Need | 44 | 21 | 152 | loose |
| Rick Ross | All I Really Want | 58 | 51 | 227 | loose |
| Rick Ross | All I Want | 63 | 44 | 217 | loose |
| Rick Ross | All In One Swipe | 52 | 57 | 274 | loose |
| Rick Ross | All My Niggas | 13 | 9 | 89 | loose |
| Rick Ross | All On Me | 37 | 17 | 179 | loose |
| Rick Ross | All for Nothing | 57 | 60 | 252 | loose |
| Rick Ross | All the Money In the World | 59 | 52 | 345 | loose |
| Rick Ross | Almighty Black Dollar | 41 | 18 | 152 | loose |
| Rick Ross | Always Feel Like | 47 | 27 | 302 | loose |
| Rick Ross | Always Strapped (G-Mix) | 85 | 55 | 352 | loose |
| Rick Ross | Amazing Grace | 50 | 36 | 306 | loose |
| Rick Ross | Ambition | 62 | 51 | 373 | loose |
| Rick Ross | Amore | 33 | 25 | 138 | loose |
| Rick Ross | Amsterdam | 56 | 54 | 282 | loose |
| Rick Ross | Amsterdam #MillsMix | 50 | 79 | 209 | loose |
| Rick Ross | Angels (Bad Boy Remix) | 48 | 27 | 203 | loose |
| Rick Ross | Another Day | 41 | 23 | 240 | loose |
| Rick Ross | Another One | 52 | 30 | 189 | loose |
| Rick Ross | Another Round (Remix) | 64 | 60 | 373 | loose |
| Rick Ross | Another Summer | 29 | 22 | 183 | loose |
| Rick Ross | Anything (To Find You) | 33 | 21 | 149 | loose |
| Rick Ross | Apple of My Eye | 67 | 32 | 291 | loose |
| Rick Ross | Arab Bricks | 41 | 40 | 194 | loose |
| Rick Ross | Arab Money (Remix Part 2) | 50 | 22 | 278 | loose |
| Rick Ross | Ashamed | 50 | 46 | 345 | loose |
| Rick Ross | Ashes To Ashes | 40 | 18 | 117 | loose |
| Rick Ross | Aston Martin Music | 80 | 65 | 410 | loose |
| Rick Ross | Audio Meth | 37 | 15 | 137 | loose |
| Rick Ross | Automatic (Remix) | 32 | 29 | 74 | loose |
| Rick Ross | Ayo (MMGMix) | 69 | 37 | 270 | loose |
| Rick Ross | B R Right | 65 | 34 | 343 | loose |
| Rick Ross | B.L.O.W. (Block Life Is Our Way) | 53 | 75 | 329 | loose |
| Rick Ross | B.M.F. (Blowin’ Money Fast) | 40 | 31 | 175 | loose |
| Rick Ross | BCGMMG (Remix) | 58 | 50 | 289 | loose |
| Rick Ross | BGM | 37 | 15 | 82 | loose |
| Rick Ross | BIG TYME | 60 | 28 | 317 | loose |
| Rick Ross | BIRDZ | 40 | 32 | 200 | loose |
| Rick Ross | BLK & WHT (Remix) | 62 | 55 | 370 | loose |
| Rick Ross | BRRRR | 35 | 38 | 284 | loose |
| Rick Ross | Babies Cry | 36 | 42 | 194 | loose |
| Rick Ross | Back From Abu Dhabi | 75 | 56 | 415 | loose |
| Rick Ross | Back On My Bullshit (Remix) | 60 | 59 | 262 | loose |
| Rick Ross | Back Story | 30 | 14 | 167 | loose |
| Rick Ross | Bad Bitch (Remix) | 64 | 52 | 313 | loose |
| Rick Ross | Bag For It | 13 | 8 | 20 | loose |
| Rick Ross | Bag Up | 38 | 28 | 232 | loose |
| Rick Ross | Bag of Money | 43 | 26 | 218 | loose |
| Rick Ross | Bait (Remix) | 66 | 43 | 329 | loose |
| Rick Ross | Ball (Remix) | 38 | 24 | 177 | loose |
| Rick Ross | Ball Like a Dog (Remix) | 115 | 78 | 196 | loose |
| Rick Ross | Ball Player | 55 | 41 | 148 | loose |
| Rick Ross | Baller Alert | 50 | 51 | 244 | loose |
| Rick Ross | Ballin | 28 | 22 | 111 | loose |
| Rick Ross | Ballin and Blowing | 33 | 20 | 92 | loose |
| Rick Ross | Bananas (Remix) | 30 | 10 | 142 | loose |
| Rick Ross | Bananaz | 29 | 15 | 148 | loose |
| Rick Ross | Bands | 54 | 39 | 209 | loose |
| Rick Ross | Barking | 32 | 8 | 129 | loose |
| Rick Ross | Basquiat on the Draw | 55 | 55 | 264 | loose |
| Rick Ross | Be Like Me | 56 | 30 | 351 | loose |
| Rick Ross | Beam Me Up | 36 | 16 | 79 | loose |
| Rick Ross | Beast Mode Pt. 3 | 96 | 44 | 325 | loose |
| Rick Ross | Beat Build | 39 | 23 | 148 | loose |
| Rick Ross | Beautiful | 70 | 53 | 299 | loose |
| Rick Ross | Beautiful Lie | 77 | 56 | 331 | loose |
| Rick Ross | Beautiful Onyinye (Remix) | 59 | 28 | 99 | loose |
| Rick Ross | Been | 59 | 82 | 257 | loose |
| Rick Ross | Been About Money | 49 | 31 | 178 | loose |
| Rick Ross | Been That | 40 | 36 | 134 | loose |
| Rick Ross | Bel Air | 52 | 35 | 253 | loose |
| Rick Ross | Believe It | 66 | 46 | 203 | loose |
| Rick Ross | Belly | 29 | 25 | 341 | loose |
| Rick Ross | Benediction | 56 | 41 | 303 | loose |
| Rick Ross | Benyhana | 47 | 47 | 292 | loose |
| Rick Ross | Best Night Ever | 40 | 23 | 254 | loose |
| Rick Ross | Best Of Me | 45 | 57 | 243 | loose |
| Rick Ross | Better Man | 42 | 17 | 175 | loose |
| Rick Ross | Betty Stout | 39 | 39 | 256 | loose |
| Rick Ross | Big Bank | 59 | 33 | 390 | loose |
| Rick Ross | Big Banks (Remix) | 45 | 19 | 360 | loose |
| Rick Ross | Big Belly | 49 | 46 | 211 | loose |
| Rick Ross | Big Boy Talk | 44 | 32 | 256 | loose |
| Rick Ross | Big Business (Remix) | 42 | 27 | 216 | loose |
| Rick Ross | Big Dawg | 55 | 74 | 142 | loose |
| Rick Ross | Big Dreams | 36 | 26 | 253 | loose |
| Rick Ross | Big Fish | 43 | 50 | 323 | loose |
| Rick Ross | Big Homie | 38 | 43 | 194 | loose |
| Rick Ross | Big Talk | 29 | 19 | 276 | loose |
| Rick Ross | Biggest Bosses | 88 | 68 | 180 | loose |
| Rick Ross | Biggest Freak | 29 | 19 | 151 | loose |
| Rick Ross | Bill Gates | 47 | 23 | 324 | loose |
| Rick Ross | Bill Gates Remix | 33 | 20 | 256 | loose |
| Rick Ross | Billionaire | 68 | 40 | 287 | loose |
| Rick Ross | Bird Bath | 74 | 102 | 533 | loose |
| Rick Ross | Birthday | 93 | 69 | 480 | loose |
| Rick Ross | Birthday Cake (Remix) | 56 | 57 | 129 | loose |
| Rick Ross | Bitch I’m From Dade County | 95 | 49 | 584 | loose |
| Rick Ross | Bitch, Don’t Kill My Vibe (Remix) | 20 | 19 | 72 | loose |
| Rick Ross | Bitches & Bizness | 82 | 58 | 464 | loose |
| Rick Ross | Black Bonnie | 47 | 31 | 302 | loose |
| Rick Ross | Black Bottles | 67 | 53 | 314 | loose |
| Rick Ross | Black Grammys | 116 | 162 | 603 | loose |
| Rick Ross | Black Lambo | 43 | 32 | 270 | loose |
| Rick Ross | Black Magic | 37 | 43 | 230 | loose |
| Rick Ross | Black Man’s Dream | 39 | 65 | 243 | loose |
| Rick Ross | Black Opium | 49 | 76 | 271 | loose |
| Rick Ross | Black Superhero Car | 37 | 24 | 185 | loose |
| Rick Ross | Blessing in Disguise | 68 | 60 | 373 | loose |
| Rick Ross | Blockstars (Remix) | 74 | 56 | 397 | loose |
| Rick Ross | Blood Money | 66 | 38 | 438 | loose |
| Rick Ross | Blood Stain 2 | 43 | 37 | 185 | loose |
| Rick Ross | Blood Stain III | 63 | 56 | 396 | loose |
| Rick Ross | Blow | 53 | 45 | 427 | loose |
| Rick Ross | Bo$$ | 37 | 17 | 136 | loose |
| Rick Ross | Body Count | 37 | 36 | 163 | loose |
| Rick Ross | Body to Body (Remix) | 53 | 29 | 265 | loose |
| Rick Ross | Bogus Charms | 52 | 62 | 361 | loose |
| Rick Ross | Bop | 51 | 62 | 194 | loose |
| Rick Ross | Born Stunna (Remix) | 42 | 29 | 157 | loose |
| Rick Ross | Born to Kill | 58 | 49 | 274 | loose |
| Rick Ross | Born-N-Raised | 65 | 41 | 363 | loose |
| Rick Ross | Boss (2006) | 53 | 45 | 313 | loose |
| Rick Ross | Boss (feat. Rick Ross) [UNRELEASED] | 18 | 27 | 84 | AAAA |
| Rick Ross | Boss Smokers | 6 | 1 | 12 | loose |
| Rick Ross | Boss Talk | 47 | 58 | 121 | loose |
| Rick Ross | Bossy Lady | 49 | 47 | 243 | loose |
| Rick Ross | Both of Us | 31 | 45 | 211 | loose |
| Rick Ross | Bottles | 46 | 47 | 260 | loose |
| Rick Ross | Bottles And Rockin J’s (Remix) | 34 | 11 | 116 | loose |
| Rick Ross | Bottles and Rocking J’s | 86 | 51 | 469 | loose |
| Rick Ross | Bound 2 Freestyle | 60 | 74 | 289 | loose |
| Rick Ross | Bout Mine | 78 | 70 | 433 | loose |
| Rick Ross | Bout That | 43 | 35 | 231 | loose |
| Rick Ross | Bout That Life | 129 | 86 | 696 | loose |
| Rick Ross | Box Chevy | 42 | 29 | 169 | loose |
| Rick Ross | Boy Outta Here | 34 | 27 | 151 | loose |
| Rick Ross | Brand New | 73 | 42 | 297 | loose |
| Rick Ross | Brand New Ap | 39 | 48 | 191 | loose |
| Rick Ross | Break It Down | 51 | 28 | 219 | loose |
| Rick Ross | Break My Heart (My Fault) | 70 | 87 | 158 | loose |
| Rick Ross | Breathe | 33 | 55 | 109 | loose |
| Rick Ross | Breathe In, Breathe Out | 44 | 30 | 158 | loose |
| Rick Ross | Brick Man (Remix) | 30 | 67 | 215 | loose |
| Rick Ross | Brimstone | 61 | 27 | 326 | loose |
| Rick Ross | Broke Up | 51 | 64 | 195 | loose |
| Rick Ross | Brown Paper Bag | 89 | 74 | 454 | loose |
| Rick Ross | Bugatti | 58 | 65 | 212 | loose |
| Rick Ross | Built Different | 23 | 19 | 61 | loose |
| Rick Ross | Bullet | 16 | 4 | 26 | loose |
| Rick Ross | Buried in the Streets | 38 | 34 | 215 | loose |
| Rick Ross | Burn (Remix) | 74 | 56 | 378 | loose |
| Rick Ross | Bury Me a G | 27 | 16 | 208 | loose |
| Rick Ross | Buy Back the Block | 66 | 39 | 364 | loose |
| Rick Ross | By Any Means | 61 | 39 | 415 | loose |
| Rick Ross | By My Side | 27 | 13 | 138 | loose |
| Rick Ross | COLD GAME | 62 | 68 | 376 | loose |
| Rick Ross | COMUN BURRO | 18 | 9 | 89 | loose |
| Rick Ross | CUT EM IN | 57 | 58 | 235 | loose |
| Rick Ross | Cake | 19 | 4 | 61 | loose |
| Rick Ross | Camel Meat | 56 | 63 | 405 | loose |
| Rick Ross | Can A Drummer Get Some | 50 | 43 | 242 | loose |
| Rick Ross | Candy | 52 | 66 | 385 | loose |
| Rick Ross | Can’t Afford | 24 | 21 | 147 | loose |
| Rick Ross | Can’t Be Broke | 65 | 81 | 342 | loose |
| Rick Ross | Can’t Believe You | 63 | 110 | 307 | loose |
| Rick Ross | Can’t Feel My Face | 27 | 25 | 169 | loose |
| Rick Ross | Can’t Knock the Hustle | 54 | 34 | 218 | loose |
| Rick Ross | Can’t Say No | 34 | 12 | 172 | loose |
| Rick Ross | Capone Suite | 57 | 47 | 245 | loose |
| Rick Ross | Carol City | 45 | 25 | 307 | loose |
| Rick Ross | Cash Flow | 60 | 75 | 406 | loose |
| Rick Ross | Cassette Deck | 61 | 63 | 288 | loose |
| Rick Ross | Cause a Scene (Remix) | 46 | 36 | 147 | loose |
| Rick Ross | Caviar Bumps | 20 | 30 | 163 | loose |
| Rick Ross | Certified | 50 | 18 | 251 | loose |
| Rick Ross | Chain of Command | 68 | 61 | 369 | loose |
| Rick Ross | Champagne | 49 | 31 | 161 | loose |
| Rick Ross | Champagne Moments | 51 | 52 | 385 | loose |
| Rick Ross | Champion | 57 | 60 | 177 | loose |
| Rick Ross | Cheap Thrills | 41 | 28 | 196 | loose |
| Rick Ross | Check | 34 | 33 | 225 | loose |
| Rick Ross | Chemtrails & Muslim Wars (Remix) | 59 | 50 | 433 | loose |
| Rick Ross | Chevy Ridin’ High | 37 | 12 | 207 | loose |
| Rick Ross | Children’s Story (Uncle Ricky) | 45 | 50 | 244 | loose |
| Rick Ross | Choices | 49 | 67 | 241 | loose |
| Rick Ross | Choices (Yup) [Remix] | 78 | 85 | 313 | loose |
| Rick Ross | Choosin’ | 49 | 56 | 206 | loose |
| Rick Ross | Chop Em Down | 45 | 56 | 303 | loose |
| Rick Ross | Choppa Choppa Down (Rick Ross Remix) | 43 | 38 | 184 | loose |
| Rick Ross | Chuck D Speaks / Devil In A New Dress | 16 | 7 | 75 | loose |
| Rick Ross | Cigar Music | 58 | 41 | 300 | loose |
| Rick Ross | City Lights | 51 | 47 | 237 | loose |
| Rick Ross | Clappers (Remix) | 65 | 45 | 331 | loose |
| Rick Ross | Clear Da Scene | 48 | 29 | 396 | loose |
| Rick Ross | Cliché | 41 | 30 | 238 | loose |
| Rick Ross | Clickin | 37 | 55 | 231 | loose |
| Rick Ross | Clique | 54 | 31 | 323 | loose |
| Rick Ross | Clouds | 52 | 29 | 237 | loose |
| Rick Ross | Cocaine | 52 | 36 | 291 | loose |
| Rick Ross | Cocaine Muzik | 51 | 47 | 193 | loose |
| Rick Ross | Cocaine Spoon | 32 | 45 | 274 | loose |
| Rick Ross | Cognac & Conversation | 40 | 25 | 106 | loose |
| Rick Ross | Coke Like the 80's | 47 | 21 | 222 | loose |
| Rick Ross | Colombia (Remix) | 56 | 38 | 246 | loose |
| Rick Ross | Color Money | 48 | 32 | 347 | loose |
| Rick Ross | Colors | 55 | 47 | 352 | loose |
| Rick Ross | Come Back to Me | 51 | 29 | 127 | loose |
| Rick Ross | Comfortable Freestyle | 52 | 37 | 296 | loose |
| Rick Ross | Connect the Dots | 64 | 91 | 331 | loose |
| Rick Ross | Couldn’t Wait for It | 40 | 65 | 326 | loose |
| Rick Ross | Crack A Bottle (G-Unit Diss) | 23 | 7 | 70 | loose |
| Rick Ross | Cranes in the Sky (Remix) | 47 | 40 | 171 | loose |
| Rick Ross | Crash Dummies* | 15 | 10 | 93 | loose |
| Rick Ross | Crib | 32 | 18 | 162 | loose |
| Rick Ross | Crib in My Closet | 52 | 40 | 315 | loose |
| Rick Ross | Criminal | 50 | 39 | 189 | loose |
| Rick Ross | Crocodile Birkins* | 7 | 2 | 46 | loose |
| Rick Ross | Crocodile Python | 50 | 33 | 252 | loose |
| Rick Ross | Cross That Line | 48 | 56 | 220 | loose |
| Rick Ross | Currency | 29 | 31 | 186 | loose |
| Rick Ross | Curtain Call | 74 | 36 | 117 | loose |
| Rick Ross | Custom Cars & Clips | 63 | 34 | 159 | loose |
| Rick Ross | Customized | 44 | 14 | 128 | loose |
| Rick Ross | Cut Her Off (Remix) | 63 | 42 | 366 | loose |
| Rick Ross | Cypher | 114 | 103 | 659 | loose |
| Rick Ross | D.O.P.E. | 3 | 0 | 6 | loose |
| Rick Ross | DJ Khaled Interlude | 20 | 10 | 89 | loose |
| Rick Ross | Dancin’ (Remix) | 50 | 34 | 64 | loose |
| Rick Ross | Dangerous II | 37 | 50 | 249 | loose |
| Rick Ross | Dead Last | 65 | 74 | 512 | loose |
| Rick Ross | Dead Presidents | 59 | 69 | 253 | loose |
| Rick Ross | Dead Rappers | 49 | 27 | 284 | loose |
| Rick Ross | Dear Lord | 58 | 33 | 381 | loose |
| Rick Ross | Debbie | 23 | 8 | 109 | loose |
| Rick Ross | Deep | 32 | 16 | 156 | loose |
| Rick Ross | Deep End | 32 | 30 | 209 | loose |
| Rick Ross | Deep in the Game | 28 | 61 | 233 | AAAA |
| Rick Ross | Deeper Than Rap (Lost Intro) | 32 | 24 | 180 | loose |
| Rick Ross | Def R | 15 | 9 | 109 | loose |
| Rick Ross | Deuces (Remix) | 115 | 65 | 660 | loose |
| Rick Ross | Devil In a New Dress | 69 | 60 | 335 | loose |
| Rick Ross | Diamonds | 53 | 26 | 350 | loose |
| Rick Ross | Diamonds Never Die | 53 | 60 | 361 | loose |
| Rick Ross | Diced Pineapples | 73 | 66 | 447 | loose |
| Rick Ross | Diddy Intro | 40 | 10 | 163 | loose |
| Rick Ross | Died In Your Arms (Remix) | 39 | 24 | 84 | loose |
| Rick Ross | Dirty White Speaks / Make Em Say Huh | 26 | 18 | 143 | loose |
| Rick Ross | Dis Ain’t What You Want (Remix) | 64 | 28 | 279 | loose |
| Rick Ross | Do It One Time | 78 | 64 | 314 | loose |
| Rick Ross | Do Sumthing Strange | 49 | 36 | 199 | loose |
| Rick Ross | Do This Shit Again | 7 | 7 | 28 | AAAA |
| Rick Ross | Do What I Do | 73 | 41 | 394 | loose |
| Rick Ross | Do What U Want (DJWS Remix) | 57 | 39 | 217 | loose |
| Rick Ross | Do You Mind | 65 | 33 | 264 | loose |
| Rick Ross | Dog Food | 54 | 55 | 263 | loose |
| Rick Ross | Dog It’s Not You | 84 | 82 | 475 | loose |
| Rick Ross | Dollar Signs (Remix) | 13 | 7 | 78 | loose |
| Rick Ross | Don’t (Rick Ross Remix) | 66 | 46 | 423 | loose |
| Rick Ross | Don’t Be Scared | 39 | 22 | 146 | loose |
| Rick Ross | Don’t Change | 37 | 14 | 206 | loose |
| Rick Ross | Don’t Get Fucked Up | 53 | 42 | 255 | loose |
| Rick Ross | Don’t Hustle Again | 34 | 17 | 135 | loose |
| Rick Ross | Don’t Like | 69 | 145 | 340 | AAAA |
| Rick Ross | Don’t Panic | 37 | 25 | 183 | loose |
| Rick Ross | Don’t Shoot | 108 | 63 | 545 | loose |
| Rick Ross | Don’t Tell Em (Rick Ross Remix) | 55 | 45 | 182 | loose |
| Rick Ross | Dope | 52 | 48 | 343 | loose |
| Rick Ross | Dope Bitch (Skit) | 31 | 5 | 47 | loose |
| Rick Ross | Dope Boys | 55 | 44 | 397 | loose |
| Rick Ross | Dope Boyz & Trap Godz | 45 | 34 | 285 | loose |
| Rick Ross | Dope Dealer | 75 | 61 | 300 | loose |
| Rick Ross | Dope Dick | 70 | 42 | 429 | loose |
| Rick Ross | Dopechella | 69 | 61 | 269 | loose |
| Rick Ross | Down Here | 55 | 42 | 279 | loose |
| Rick Ross | Down In The DM (Remix) | 23 | 14 | 88 | loose |
| Rick Ross | Down Like That | 40 | 44 | 211 | loose |
| Rick Ross | Down Like That [TMPKFK Remix] | 4 | 3 | 5 | loose |
| Rick Ross | Down South | 49 | 28 | 233 | loose |
| Rick Ross | Down for Life | 70 | 40 | 242 | loose |
| Rick Ross | Down in tha Dirty | 63 | 44 | 330 | loose |
| Rick Ross | Down with me | 25 | 7 | 49 | loose |
| Rick Ross | Drake | 36 | 34 | 204 | loose |
| Rick Ross | Dreaming (Interlude) | 71 | 19 | 187 | loose |
| Rick Ross | Dreams and Nightmares (Intro) | 76 | 65 | 503 | loose |
| Rick Ross | Drive a Nigga Crazy | 48 | 49 | 233 | loose |
| Rick Ross | Drop Top Music | 68 | 51 | 205 | loose |
| Rick Ross | Drug Dealer’s Dream | 53 | 42 | 250 | loose |
| Rick Ross | Drug Money (Remix) | 33 | 8 | 289 | loose |
| Rick Ross | Dueces | 13 | 8 | 72 | loose |
| Rick Ross | DunnHill | 49 | 55 | 227 | loose |
| Rick Ross | East Coast REMIX | 133 | 91 | 677 | loose |
| Rick Ross | Eastern Conference Final | 47 | 41 | 266 | loose |
| Rick Ross | Ecstasy | 57 | 36 | 185 | loose |
| Rick Ross | Elvis Presley Blvd. | 47 | 36 | 252 | loose |
| Rick Ross | Empire | 46 | 53 | 211 | loose |
| Rick Ross | Entanglements | 48 | 23 | 264 | loose |
| Rick Ross | Equal | 30 | 14 | 127 | loose |
| Rick Ross | Errday | 54 | 43 | 248 | loose |
| Rick Ross | Euro Bricks | 43 | 16 | 504 | loose |
| Rick Ross | Euro Vision Freestyle | 8 | 3 | 20 | loose |
| Rick Ross | Even Deeper | 46 | 44 | 207 | loose |
| Rick Ross | Every Hour | 50 | 35 | 137 | loose |
| Rick Ross | Everyday Hustle | 74 | 69 | 368 | loose |
| Rick Ross | Everything A Dope Boy Ever Wanted | 51 | 29 | 234 | loose |
| Rick Ross | Expectations | 48 | 24 | 263 | loose |
| Rick Ross | Extreme Extravagance* | 9 | 10 | 21 | loose |
| Rick Ross | Face | 26 | 17 | 158 | loose |
| Rick Ross | Face Down | 32 | 42 | 223 | loose |
| Rick Ross | FaceTime | 44 | 38 | 236 | loose |
| Rick Ross | Faded | 45 | 29 | 187 | loose |
| Rick Ross | Family Ties | 50 | 36 | 279 | loose |
| Rick Ross | Famous (Remix) | 62 | 56 | 187 | loose |
| Rick Ross | Far 4rom Over | 29 | 27 | 186 | loose |
| Rick Ross | Fascinated | 57 | 34 | 164 | loose |
| Rick Ross | Fast Life / Break My Heart / Mark My Words (DJ Green Lantern Edit) [Mixed] | 15 | 9 | 84 | loose |
| Rick Ross | Fat Boy | 49 | 24 | 263 | loose |
| Rick Ross | Fed Up | 66 | 56 | 312 | loose |
| Rick Ross | Feds Takin’ Pictures | 55 | 33 | 323 | loose |
| Rick Ross | Feds Takin’ Pictures 2 | 24 | 12 | 146 | loose |
| Rick Ross | Feel My Pain | 45 | 68 | 276 | loose |
| Rick Ross | Feel Rick Ross | 18 | 13 | 130 | loose |
| Rick Ross | Feelings | 47 | 25 | 320 | loose |
| Rick Ross | Finals | 64 | 39 | 344 | loose |
| Rick Ross | Finals 2 | 125 | 88 | 769 | loose |
| Rick Ross | Fine Lines | 61 | 49 | 415 | loose |
| Rick Ross | Finest Hour | 50 | 36 | 246 | loose |
| Rick Ross | Fire | 43 | 24 | 212 | loose |
| Rick Ross | Fire Hazard | 40 | 23 | 244 | loose |
| Rick Ross | Fitted Cap | 63 | 50 | 473 | loose |
| Rick Ross | Flashing Lights | 48 | 28 | 192 | loose |
| Rick Ross | Flashy Cars Movie Stars | 89 | 60 | 350 | loose |
| Rick Ross | Flawless / Feeling Myself (Homecoming Live) | 46 | 20 | 79 | loose |
| Rick Ross | Flip That Bitch a Few Times | 27 | 34 | 122 | loose |
| Rick Ross | Flippin’ That | 56 | 49 | 205 | loose |
| Rick Ross | Florida Boy | 89 | 81 | 547 | loose |
| Rick Ross | Fluorescent Ink | 46 | 33 | 255 | loose |
| Rick Ross | Fly Together | 58 | 26 | 257 | loose |
| Rick Ross | Fontaine Bleu | 76 | 44 | 243 | loose |
| Rick Ross | Foolish (Remix) | 61 | 55 | 193 | loose |
| Rick Ross | For Da Low | 44 | 21 | 277 | loose |
| Rick Ross | For The Money | 56 | 109 | 279 | loose |
| Rick Ross | Foreclosures | 65 | 45 | 351 | loose |
| Rick Ross | Forever (Remix) | 41 | 24 | 123 | loose |
| Rick Ross | Fountain of Youth | 53 | 59 | 269 | loose |
| Rick Ross | Freaks (Remix) | 50 | 31 | 244 | loose |
| Rick Ross | Freaky Hoe | 45 | 26 | 249 | loose |
| Rick Ross | Free Enterprise | 61 | 57 | 342 | loose |
| Rick Ross | Free Mason | 59 | 38 | 226 | loose |
| Rick Ross | Free Spirit | 54 | 36 | 337 | loose |
| Rick Ross | Freestyle | 8 | 1 | 27 | loose |
| Rick Ross | Freeze Me (Remix) | 85 | 83 | 470 | loose |
| Rick Ross | Freeze Me Remix | 5 | 0 | 6 | loose |
| Rick Ross | Fresh Prince of Belaire | 33 | 43 | 246 | loose |
| Rick Ross | Fuck Em | 55 | 53 | 400 | loose |
| Rick Ross | Fuck Up Some Commas (Remix) | 63 | 30 | 332 | loose |
| Rick Ross | Fuck Up the Club | 46 | 16 | 264 | loose |
| Rick Ross | FuckWitMeYouKnowIGotIt | 80 | 76 | 440 | loose |
| Rick Ross | FuckWithMeYouKnowIGotIt | 36 | 23 | 72 | loose |
| Rick Ross | Fuckin’ Problems (Remix) | 36 | 38 | 210 | loose |
| Rick Ross | Fun Fact | 32 | 26 | 153 | loose |
| Rick Ross | Future Bright | 43 | 15 | 205 | loose |
| Rick Ross | GOD DID | 124 | 92 | 723 | loose |
| Rick Ross | GOD IS REAL | 61 | 36 | 310 | loose |
| Rick Ross | GUESS WHAT | 45 | 70 | 316 | loose |
| Rick Ross | GUMMO (Remix) | 67 | 59 | 578 | loose |
| Rick Ross | Gallardo | 48 | 29 | 263 | loose |
| Rick Ross | Game Ain’t Based On Sympathy | 53 | 44 | 304 | loose |
| Rick Ross | Game Over | 68 | 90 | 352 | loose |
| Rick Ross | Gang Related | 57 | 43 | 241 | loose |
| Rick Ross | Gangsta Shit | 80 | 59 | 390 | loose |
| Rick Ross | Gangster Of Love | 42 | 37 | 413 | loose |
| Rick Ross | Geechi Liberace | 57 | 45 | 286 | loose |
| Rick Ross | Geetchi Liberachi | 27 | 32 | 187 | loose |
| Rick Ross | Gele Fiets | 41 | 22 | 278 | loose |
| Rick Ross | Get Away | 64 | 35 | 275 | loose |
| Rick Ross | Get Down | 71 | 61 | 290 | loose |
| Rick Ross | Get Home | 17 | 10 | 114 | loose |
| Rick Ross | Get It Girl | 43 | 21 | 130 | loose |
| Rick Ross | Get It Together | 45 | 21 | 102 | loose |
| Rick Ross | Get Money | 51 | 42 | 335 | loose |
| Rick Ross | Get Out | 32 | 25 | 127 | loose |
| Rick Ross | Get That Bread | 45 | 41 | 325 | loose |
| Rick Ross | Getting mine | 29 | 15 | 48 | loose |
| Rick Ross | Ghostwriter | 51 | 30 | 334 | loose |
| Rick Ross | Gimme Brain | 35 | 29 | 271 | loose |
| Rick Ross | Girl Friday | 28 | 16 | 116 | loose |
| Rick Ross | Girls All Around the World (Remix) | 119 | 66 | 651 | loose |
| Rick Ross | Give It to ’Em | 34 | 24 | 169 | loose |
| Rick Ross | Glory of War | 52 | 51 | 286 | loose |
| Rick Ross | Go | 59 | 46 | 272 | loose |
| Rick Ross | Go Ahead | 66 | 64 | 287 | loose |
| Rick Ross | Go Get the Money | 63 | 30 | 441 | loose |
| Rick Ross | Go Mode | 46 | 26 | 228 | loose |
| Rick Ross | Go To Hell | 58 | 76 | 318 | loose |
| Rick Ross | God Complex/Gravity | 53 | 87 | 480 | loose |
| Rick Ross | God’s Favorite | 27 | 38 | 181 | loose |
| Rick Ross | God’s Will | 32 | 27 | 152 | loose |
| Rick Ross | Gold Alpinas | 57 | 76 | 217 | loose |
| Rick Ross | Gold Medals | 47 | 46 | 261 | loose |
| Rick Ross | Gold Roses | 87 | 137 | 559 | loose |
| Rick Ross | Gold Wrappers | 39 | 35 | 203 | loose |
| Rick Ross | Gone to the Moon | 27 | 17 | 135 | loose |
| Rick Ross | Good Life | 25 | 34 | 123 | loose |
| Rick Ross | Gordo | 21 | 13 | 50 | loose |
| Rick Ross | Got Me Crazy | 52 | 59 | 212 | loose |
| Rick Ross | Got Me Going (Remix) | 65 | 42 | 191 | loose |
| Rick Ross | Got a Bitch | 63 | 47 | 367 | loose |
| Rick Ross | Gotti Family | 24 | 9 | 81 | loose |
| Rick Ross | Grab Yo Beltloop (Shank you in the shower) | 16 | 5 | 98 | loose |
| Rick Ross | Grandiose | 35 | 37 | 237 | loose |
| Rick Ross | Green Gucci Suit | 69 | 44 | 308 | loose |
| Rick Ross | Grind 24 | 65 | 28 | 177 | loose |
| Rick Ross | Grind Don’t Stop | 16 | 25 | 155 | loose |
| Rick Ross | Grippin grain | 30 | 15 | 71 | loose |
| Rick Ross | Gucci Time Remix | 16 | 15 | 60 | loose |
| Rick Ross | Gunplay | 64 | 33 | 340 | loose |
| Rick Ross | HNIC | 57 | 42 | 112 | loose |
| Rick Ross | Half A Brick | 37 | 39 | 199 | loose |
| Rick Ross | Hands Down | 32 | 49 | 158 | loose |
| Rick Ross | Hands Up | 67 | 42 | 296 | loose |
| Rick Ross | Hard Horn Nightmare / Live Fast Die Young | 75 | 70 | 403 | loose |
| Rick Ross | Hard Piano | 54 | 44 | 299 | loose |
| Rick Ross | Hard in the Paint (Freestyle) | 29 | 17 | 151 | loose |
| Rick Ross | Harder | 52 | 63 | 327 | loose |
| Rick Ross | Harsh | 62 | 60 | 430 | loose |
| Rick Ross | Haterz | 77 | 61 | 251 | loose |
| Rick Ross | Head Shots | 43 | 61 | 237 | loose |
| Rick Ross | Headache | 51 | 37 | 240 | loose |
| Rick Ross | Heads Up Eyes Open | 66 | 73 | 335 | loose |
| Rick Ross | Hear Me Clearly | 34 | 38 | 227 | loose |
| Rick Ross | Heartless | 40 | 29 | 273 | loose |
| Rick Ross | Heavenly Body | 37 | 23 | 129 | loose |
| Rick Ross | Heavy Artillery | 61 | 40 | 340 | loose |
| Rick Ross | Heavyweight | 44 | 41 | 230 | loose |
| Rick Ross | Hell Yeah | 31 | 17 | 145 | loose |
| Rick Ross | Hella Smoke | 61 | 67 | 352 | loose |
| Rick Ross | Hello (Remix) | 38 | 33 | 178 | loose |
| Rick Ross | Hello, Good Morning (Remix) | 61 | 39 | 241 | loose |
| Rick Ross | Hell’s Angels (American Heathens) | 59 | 59 | 447 | loose |
| Rick Ross | Here I Am | 53 | 49 | 228 | loose |
| Rick Ross | Hide The Rest | 42 | 73 | 330 | loose |
| Rick Ross | High Definition | 47 | 35 | 274 | loose |
| Rick Ross | High is Coming Down | 43 | 16 | 320 | loose |
| Rick Ross | Highest To Lowest | 50 | 9 | 41 | loose |
| Rick Ross | Highly Prestigious | 49 | 32 | 275 | loose |
| Rick Ross | Hills to the Hood | 49 | 32 | 205 | loose |
| Rick Ross | History of Rap 2 | 70 | 29 | 174 | loose |
| Rick Ross | History of Rap 6 | 86 | 41 | 308 | loose |
| Rick Ross | Hit U from the Back | 64 | 28 | 228 | loose |
| Rick Ross | Hold Me Back | 46 | 32 | 281 | loose |
| Rick Ross | Hold Me Down | 61 | 53 | 384 | loose |
| Rick Ross | Hold On | 52 | 41 | 288 | loose |
| Rick Ross | Hold You Down (Remix) | 59 | 38 | 267 | loose |
| Rick Ross | Hold on I’ll eat it all | 13 | 3 | 28 | loose |
| Rick Ross | Holla at Me | 81 | 48 | 441 | loose |
| Rick Ross | Holy Ghost | 36 | 32 | 153 | loose |
| Rick Ross | Homage | 37 | 34 | 108 | loose |
| Rick Ross | Homegurl (G-Mix) | 15 | 7 | 146 | loose |
| Rick Ross | Homegurl 2.0 | 62 | 37 | 332 | loose |
| Rick Ross | Homey N Hoes | 60 | 25 | 201 | loose |
| Rick Ross | Hood Billionaire | 51 | 25 | 252 | loose |
| Rick Ross | Hoodtails | 73 | 61 | 371 | loose |
| Rick Ross | Hot Commodity | 65 | 57 | 174 | loose |
| Rick Ross | Hottest in the Hood (Remix 1) | 68 | 55 | 300 | loose |
| Rick Ross | How Low (Remix) | 49 | 45 | 314 | loose |
| Rick Ross | How Many (Remix) | 42 | 65 | 247 | loose |
| Rick Ross | How Many Drinks (Remix) | 62 | 47 | 270 | loose |
| Rick Ross | How We Do It | 40 | 27 | 203 | loose |
| Rick Ross | How to Minimize Politics in Your Company | 10 | 3 | 31 | loose |
| Rick Ross | Hungry | 23 | 9 | 108 | loose |
| Rick Ross | Hurt Nobody | 63 | 39 | 331 | loose |
| Rick Ross | Hustle | 51 | 33 | 285 | loose |
| Rick Ross | Hustle Hard (Remix) | 63 | 49 | 350 | loose |
| Rick Ross | Hustle hard french remix | 23 | 5 | 116 | loose |
| Rick Ross | Hustlin’ | 48 | 38 | 237 | loose |
| Rick Ross | Hustlin’ Remix | 45 | 15 | 510 | loose |
| Rick Ross | I Ain’t Got No Time | 41 | 46 | 349 | loose |
| Rick Ross | I Ain’t Worried | 41 | 25 | 171 | loose |
| Rick Ross | I Am The Streets | 59 | 41 | 349 | loose |
| Rick Ross | I Am Your Leader | 66 | 88 | 430 | loose |
| Rick Ross | I Been Workin’ | 44 | 51 | 250 | loose |
| Rick Ross | I Came I Saw | 34 | 18 | 58 | loose |
| Rick Ross | I Changed Her Life | 13 | 21 | 57 | loose |
| Rick Ross | I Did It for My Dawgz | 79 | 62 | 338 | loose |
| Rick Ross | I Don’t Give A Fuck | 42 | 23 | 230 | loose |
| Rick Ross | I Don’t Play About My Paper | 41 | 22 | 175 | loose |
| Rick Ross | I Feel Like Pac / I Feel Like Biggie | 71 | 50 | 362 | loose |
| Rick Ross | I Get It In | 44 | 17 | 169 | loose |
| Rick Ross | I Get Money | 68 | 23 | 206 | loose |
| Rick Ross | I Get Money [Clean] | 43 | 19 | 266 | loose |
| Rick Ross | I Got A Chick (Remix) | 40 | 25 | 112 | loose |
| Rick Ross | I Got It | 50 | 22 | 190 | loose |
| Rick Ross | I Got Love | 36 | 51 | 165 | loose |
| Rick Ross | I Gotta | 50 | 37 | 342 | loose |
| Rick Ross | I Gotta Chick | 34 | 25 | 133 | loose |
| Rick Ross | I Know | 50 | 38 | 238 | loose |
| Rick Ross | I Know Remix | 40 | 30 | 157 | loose |
| Rick Ross | I Like Him | 38 | 20 | 70 | loose |
| Rick Ross | I Love My Bitches | 48 | 47 | 212 | loose |
| Rick Ross | I Made It | 41 | 22 | 143 | loose |
| Rick Ross | I Mean It (Remix) | 38 | 28 | 144 | loose |
| Rick Ross | I Must Admit (Remix) | 45 | 60 | 178 | loose |
| Rick Ross | I Need a 100 | 57 | 22 | 106 | loose |
| Rick Ross | I Really Want | 10 | 6 | 45 | loose |
| Rick Ross | I Ride | 46 | 21 | 230 | loose |
| Rick Ross | I Solemnly Swear | 53 | 62 | 213 | loose |
| Rick Ross | I Still Pray | 63 | 44 | 308 | loose |
| Rick Ross | I Still Wanna | 56 | 40 | 309 | loose |
| Rick Ross | I Still Wanna Rock | 27 | 7 | 149 | loose |
| Rick Ross | I Swear to God | 42 | 46 | 248 | loose |
| Rick Ross | I Think I Love Her (Rick Ross Remix) | 49 | 62 | 450 | loose |
| Rick Ross | I Think She Like Me | 59 | 53 | 250 | loose |
| Rick Ross | I Wanna Be With You | 50 | 39 | 238 | loose |
| Rick Ross | I Wanna Rock (DJ Green Lantern Interstate Trafficking Remix) 12" | 61 | 29 | 397 | loose |
| Rick Ross | I Wish You Would | 51 | 49 | 273 | loose |
| Rick Ross | I Wonder Why | 38 | 32 | 169 | loose |
| Rick Ross | I.D.F.W.U. (MMG Mix) | 90 | 63 | 533 | loose |
| Rick Ross | ID1 (from All The Reason Live at Lost Lands 2025) / Pop That [Mixed] | 3 | 1 | 3 | loose |
| Rick Ross | Ice Cold | 55 | 43 | 173 | loose |
| Rick Ross | Ice Cream | 31 | 24 | 200 | loose |
| Rick Ross | Ice Cream Dream | 44 | 48 | 204 | loose |
| Rick Ross | Icon | 51 | 26 | 168 | loose |
| Rick Ross | Iconic | 65 | 62 | 353 | loose |
| Rick Ross | Idols Become Rivals | 91 | 43 | 593 | loose |
| Rick Ross | If They Knew | 56 | 60 | 271 | loose |
| Rick Ross | Ima Boss (Remix) | 82 | 65 | 578 | loose |
| Rick Ross | Imma Boss Remix | 104 | 78 | 177 | loose |
| Rick Ross | Imma General(Explicit) | 9 | 3 | 65 | loose |
| Rick Ross | Imma Get Me Sum | 42 | 30 | 398 | loose |
| Rick Ross | Imma Zoe (Remix) | 73 | 71 | 238 | loose |
| Rick Ross | Imperial High | 55 | 68 | 241 | loose |
| Rick Ross | In Cold Blood | 48 | 29 | 258 | loose |
| Rick Ross | In Da Box | 47 | 31 | 284 | loose |
| Rick Ross | In Da Club (Remix) | 40 | 18 | 231 | loose |
| Rick Ross | In God We Trust | 64 | 53 | 359 | loose |
| Rick Ross | In Luv With The Money | 27 | 32 | 200 | loose |
| Rick Ross | In The Box Remix | 36 | 9 | 161 | loose |
| Rick Ross | In Vein | 52 | 26 | 231 | loose |
| Rick Ross | In Vein (remix) [Fake] | 29 | 20 | 91 | loose |
| Rick Ross | In the Ayer (Remix) | 64 | 51 | 149 | loose |
| Rick Ross | In the Name of Love (Do It All) | 62 | 39 | 296 | loose |
| Rick Ross | Infinity | 131 | 143 | 550 | loose |
| Rick Ross | Inkredible | 51 | 47 | 316 | loose |
| Rick Ross | Inkredible 3 (Yall 4 Got) | 52 | 50 | 283 | loose |
| Rick Ross | Insomniak | 64 | 41 | 343 | loose |
| Rick Ross | Instagram That H** | 31 | 15 | 100 | loose |
| Rick Ross | Intro (Mastermind) | 8 | 2 | 18 | loose |
| Rick Ross | It Ain’t a Problem | 59 | 39 | 367 | loose |
| Rick Ross | Itchin’ | 30 | 21 | 91 | loose |
| Rick Ross | It’s Goin’ Down (Remix) | 57 | 36 | 347 | loose |
| Rick Ross | It’s My Time | 58 | 36 | 336 | loose |
| Rick Ross | It’s Okay (One Blood) (Remix) | 229 | 164 | 1331 | loose |
| Rick Ross | It’s On | 59 | 67 | 286 | loose |
| Rick Ross | It’s Possible | 5 | 1 | 24 | loose |
| Rick Ross | It’s a Tower Heist | 31 | 27 | 251 | loose |
| Rick Ross | I’m A Coke Boy (Remix) | 49 | 39 | 181 | loose |
| Rick Ross | I’m A Dog (Remix) | 58 | 58 | 414 | loose |
| Rick Ross | I’m Bad | 52 | 45 | 267 | loose |
| Rick Ross | I’m Ballin | 44 | 18 | 256 | loose |
| Rick Ross | I’m Da Man (Remix) | 32 | 23 | 164 | loose |
| Rick Ross | I’m Fresh | 56 | 20 | 312 | loose |
| Rick Ross | I’m Good Remix | 55 | 49 | 256 | loose |
| Rick Ross | I’m Just Doing My Thing | 59 | 42 | 283 | loose |
| Rick Ross | I’m Not a Star | 37 | 23 | 205 | loose |
| Rick Ross | I’m On 3.0 | 168 | 184 | 903 | loose |
| Rick Ross | I’m On One | 62 | 55 | 328 | loose |
| Rick Ross | I’m Only Human | 50 | 43 | 275 | loose |
| Rick Ross | I’m So High | 17 | 2 | 46 | loose |
| Rick Ross | I’m So Hood (Remix) | 129 | 66 | 633 | loose |
| Rick Ross | I’m Ya Dogg | 53 | 33 | 200 | loose |
| Rick Ross | I’m a Boss | 56 | 54 | 250 | loose |
| Rick Ross | I’m a G | 64 | 61 | 234 | loose |
| Rick Ross | I’m a Pig | 54 | 43 | 236 | loose |
| Rick Ross | I’m a Stunna | 56 | 45 | 251 | loose |
| Rick Ross | Jack Mode | 62 | 38 | 285 | loose |
| Rick Ross | Jam On It | 55 | 36 | 147 | loose |
| Rick Ross | John | 64 | 86 | 413 | loose |
| Rick Ross | John Doe | 36 | 20 | 121 | loose |
| Rick Ross | Jugg King (Remix) | 57 | 38 | 383 | loose |
| Rick Ross | Julio (Remix) | 71 | 142 | 212 | loose |
| Rick Ross | Jumping Out the Gym | 16 | 14 | 65 | loose |
| Rick Ross | Jumping Ship | 41 | 27 | 129 | loose |
| Rick Ross | Jumpman (Remix) | 56 | 46 | 248 | loose |
| Rick Ross | Just Business | 41 | 55 | 247 | loose |
| Rick Ross | Just In Case | 42 | 36 | 175 | loose |
| Rick Ross | Just Us (Remix) | 50 | 53 | 241 | loose |
| Rick Ross | Justice | 71 | 39 | 274 | loose |
| Rick Ross | Karate Chop (RichMix) | 50 | 34 | 233 | loose |
| Rick Ross | Keep Doin’ That (Rich Bitch) | 44 | 31 | 218 | loose |
| Rick Ross | Keep It Real | 54 | 23 | 317 | loose |
| Rick Ross | Keys to the Crib | 67 | 65 | 333 | loose |
| Rick Ross | Killswitch | 52 | 27 | 292 | loose |
| Rick Ross | Kind of Girl | 43 | 38 | 197 | loose |
| Rick Ross | King Boss | 52 | 26 | 224 | loose |
| Rick Ross | King of Diamonds | 28 | 15 | 159 | loose |
| Rick Ross | Kira | 43 | 49 | 707 | loose |
| Rick Ross | Kiss My Pinky Ring, Curly (50 Cent Diss) | 51 | 20 | 192 | loose |
| Rick Ross | Kiss Of Judas | 41 | 26 | 211 | loose |
| Rick Ross | Kisses to the Sky | 67 | 63 | 369 | loose |
| Rick Ross | Knife Fight | 38 | 37 | 205 | loose |
| Rick Ross | Knight of the Templar | 38 | 24 | 116 | loose |
| Rick Ross | Knotty Head | 57 | 43 | 381 | loose |
| Rick Ross | Know About | 29 | 12 | 183 | loose |
| Rick Ross | Know What I’m Doin’ | 56 | 49 | 318 | loose |
| Rick Ross | Kobe or Ginobili (Remix) | 77 | 81 | 439 | loose |
| Rick Ross | Kush | 60 | 48 | 214 | loose |
| Rick Ross | Kyrie | 45 | 41 | 225 | loose |
| Rick Ross | Lakers In The 80's | 58 | 53 | 375 | loose |
| Rick Ross | Lamborghini Doors | 72 | 51 | 387 | loose |
| Rick Ross | Lame | 54 | 133 | 307 | AAAA |
| Rick Ross | Last Breath | 57 | 49 | 323 | loose |
| Rick Ross | Last Forever | 47 | 24 | 303 | loose |
| Rick Ross | Lay Back | 46 | 38 | 256 | loose |
| Rick Ross | Lay Back Pt. 2 | 39 | 17 | 210 | loose |
| Rick Ross | Lay It Down | 37 | 18 | 228 | loose |
| Rick Ross | Lay Up | 52 | 47 | 369 | loose |
| Rick Ross | Layers | 60 | 53 | 388 | loose |
| Rick Ross | Legend | 62 | 91 | 357 | loose |
| Rick Ross | Lemme See | 40 | 31 | 121 | loose |
| Rick Ross | Lemon Pepper Freestyle | 116 | 167 | 689 | loose |
| Rick Ross | Let Em Know I’m Real | 28 | 18 | 209 | loose |
| Rick Ross | Let Me Do Me | 28 | 11 | 78 | loose |
| Rick Ross | Let Me Ride | 53 | 33 | 306 | loose |
| Rick Ross | Let Me Tell Ya | 64 | 42 | 356 | loose |
| Rick Ross | Let’s Get It | 31 | 11 | 130 | loose |
| Rick Ross | Let’s Talk | 53 | 37 | 189 | loose |
| Rick Ross | LiGhT rAiLs *ੈ✩‧₊˚ | 46 | 43 | 173 | loose |
| Rick Ross | Lick Season | 32 | 15 | 129 | loose |
| Rick Ross | Life Long | 55 | 55 | 306 | loose |
| Rick Ross | Lifestyles of the Rich & Hated | 51 | 61 | 235 | loose |
| Rick Ross | Light Years | 43 | 29 | 267 | loose |
| Rick Ross | Lights Get Low | 62 | 32 | 221 | loose |
| Rick Ross | Like I See It (Remix) | 64 | 64 | 181 | loose |
| Rick Ross | Like Them | 52 | 37 | 347 | loose |
| Rick Ross | Lincoln Way Nights - Shop Remix | 38 | 22 | 275 | loose |
| Rick Ross | Lincoln Way Nights Remix | 62 | 46 | 339 | loose |
| Rick Ross | Lipstick | 35 | 18 | 110 | loose |
| Rick Ross | Little Havana | 72 | 65 | 400 | loose |
| Rick Ross | Litty | 7 | 2 | 15 | loose |
| Rick Ross | Live Fast, Die Young | 79 | 54 | 434 | loose |
| Rick Ross | Living Better Now | 34 | 19 | 127 | loose |
| Rick Ross | Living Large | 42 | 75 | 412 | loose |
| Rick Ross | Lobster Omelette | 40 | 47 | 307 | loose |
| Rick Ross | LockJaw (Clue Radio Remix) | 46 | 63 | 310 | loose |
| Rick Ross | London Skit | 11 | 2 | 26 | loose |
| Rick Ross | Look Me In My Eyes | 47 | 34 | 263 | loose |
| Rick Ross | Looking for Love | 49 | 36 | 146 | loose |
| Rick Ross | Lord Knows | 78 | 72 | 468 | loose |
| Rick Ross | Lord Vader Kush II | 50 | 53 | 345 | loose |
| Rick Ross | Lose It | 38 | 26 | 167 | loose |
| Rick Ross | Loss 4 Wrdz | 50 | 48 | 141 | loose |
| Rick Ross | Love & Loyalty | 48 | 30 | 219 | loose |
| Rick Ross | Love Come Down (Bad Boy Remix) | 54 | 80 | 239 | loose |
| Rick Ross | Love Lies (Rick Ross Remix) | 37 | 43 | 111 | loose |
| Rick Ross | Love Me Nina / Semiautomatic | 64 | 50 | 332 | loose |
| Rick Ross | Love Sosa (Remix) | 55 | 59 | 270 | loose |
| Rick Ross | Love... (Her Fault) | 59 | 30 | 401 | loose |
| Rick Ross | Luxury Tax | 75 | 69 | 457 | loose |
| Rick Ross | Lyrical Eazy | 35 | 31 | 195 | loose |
| Rick Ross | M.I.A. (Remix) | 58 | 44 | 293 | loose |
| Rick Ross | MC Hammer | 58 | 48 | 261 | loose |
| Rick Ross | MMG The World Is Ours | 92 | 84 | 515 | loose |
| Rick Ross | MMG Untouchable | 39 | 35 | 182 | loose |
| Rick Ross | MONEYFLY | 30 | 53 | 171 | loose |
| Rick Ross | MYLIFE 2.0 | 41 | 30 | 72 | loose |
| Rick Ross | Made It | 60 | 113 | 172 | loose |
| Rick Ross | Made It from Nothing | 66 | 71 | 316 | loose |
| Rick Ross | Made Men | 68 | 42 | 317 | loose |
| Rick Ross | Made N*GGAZ | 44 | 43 | 169 | loose |
| Rick Ross | Made it Out Alive | 42 | 29 | 289 | loose |
| Rick Ross | Mafia Music | 76 | 67 | 385 | loose |
| Rick Ross | Mafia Music II | 62 | 42 | 374 | loose |
| Rick Ross | Mafia Music III | 68 | 68 | 369 | loose |
| Rick Ross | Magic (Rick Ross, Yo Gotti & T.I. Remix) | 31 | 12 | 100 | loose |
| Rick Ross | Magnificent | 55 | 44 | 299 | loose |
| Rick Ross | Mahogany Caskets | 70 | 71 | 494 | loose |
| Rick Ross | Make It Rain (Remix) | 108 | 69 | 572 | loose |
| Rick Ross | Make It Rain Remix | 126 | 120 | 413 | loose |
| Rick Ross | Make It Up As We Go (Remix) | 44 | 17 | 83 | loose |
| Rick Ross | Make It Work | 58 | 42 | 321 | loose |
| Rick Ross | Make Me Feel (Remix) | 34 | 27 | 85 | loose |
| Rick Ross | Make a move | 13 | 3 | 76 | loose |
| Rick Ross | Make tha Trap Say Aye (Remix) | 10 | 3 | 22 | loose |
| Rick Ross | Making Me Proud | 40 | 27 | 97 | loose |
| Rick Ross | Manslaughter | 39 | 32 | 138 | loose |
| Rick Ross | Marathon | 37 | 39 | 246 | loose |
| Rick Ross | Marble Floors | 52 | 32 | 192 | loose |
| Rick Ross | Mark My Words | 44 | 55 | 223 | loose |
| Rick Ross | Mars | 26 | 12 | 93 | loose |
| Rick Ross | Master Fard Muhammad | 74 | 90 | 448 | loose |
| Rick Ross | Mastermind Unfolds Like A True Crime: The Album’s Top Lyrics | 17 | 3 | 114 | loose |
| Rick Ross | Maybach Curtains | 53 | 42 | 351 | loose |
| Rick Ross | Maybach Dons | 40 | 40 | 232 | loose |
| Rick Ross | Maybach Drip | 47 | 60 | 227 | loose |
| Rick Ross | Maybach Music | 72 | 41 | 376 | loose |
| Rick Ross | Maybach Music 2 | 55 | 49 | 323 | loose |
| Rick Ross | Maybach Music 2.5 | 43 | 20 | 205 | loose |
| Rick Ross | Maybach Music II (Remix) | 57 | 45 | 273 | loose |
| Rick Ross | Maybach Music III | 55 | 80 | 315 | loose |
| Rick Ross | Maybach Music IV | 73 | 41 | 318 | loose |
| Rick Ross | Maybach Music V | 64 | 47 | 275 | loose |
| Rick Ross | Maybach Music VI | 46 | 53 | 378 | loose |
| Rick Ross | Maybach Music VII | 70 | 44 | 385 | loose |
| Rick Ross | Maybe (Remix) | 53 | 29 | 329 | loose |
| Rick Ross | Mercy | 83 | 71 | 334 | loose |
| Rick Ross | Miami | 49 | 27 | 250 | loose |
| Rick Ross | Miami Mount Rushmore | 60 | 41 | 319 | loose |
| Rick Ross | Miami Vice | 21 | 35 | 147 | loose |
| Rick Ross | Midnight Hoes | 52 | 36 | 269 | loose |
| Rick Ross | Million Dollar Trap | 36 | 32 | 283 | loose |
| Rick Ross | Million in a Month (feat. Rick Ross) | 39 | 37 | 161 | loose |
| Rick Ross | Millionaire Row | 37 | 20 | 201 | loose |
| Rick Ross | Millions | 55 | 22 | 211 | loose |
| Rick Ross | Milly Rock (Remix) | 49 | 46 | 190 | loose |
| Rick Ross | Mine Games | 44 | 39 | 146 | loose |
| Rick Ross | Mini Kelly | 64 | 80 | 628 | loose |
| Rick Ross | Minks In Miami | 44 | 50 | 266 | loose |
| Rick Ross | Mirror Remix | 56 | 34 | 184 | loose |
| Rick Ross | Molasses | 78 | 39 | 425 | loose |
| Rick Ross | Moment | 52 | 20 | 243 | loose |
| Rick Ross | Money | 55 | 27 | 300 | loose |
| Rick Ross | Money Bag | 53 | 58 | 127 | loose |
| Rick Ross | Money Dance | 91 | 66 | 343 | loose |
| Rick Ross | Money Dance II | 25 | 10 | 189 | loose |
| Rick Ross | Money Machine | 43 | 44 | 222 | loose |
| Rick Ross | Money Make Me Come | 35 | 19 | 170 | loose |
| Rick Ross | Money Maker | 54 | 55 | 259 | loose |
| Rick Ross | Money On My Mind (Remix) [Blow] | 35 | 43 | 71 | loose |
| Rick Ross | Money Right | 41 | 39 | 291 | loose |
| Rick Ross | Money To Make | 53 | 28 | 230 | loose |
| Rick Ross | Money and Powder | 44 | 39 | 183 | loose |
| Rick Ross | Money in the Grave | 56 | 79 | 305 | loose |
| Rick Ross | Monkey Suit | 50 | 89 | 351 | loose |
| Rick Ross | Monster | 95 | 83 | 543 | loose |
| Rick Ross | Monster [Demo] | 4 | 2 | 18 | loose |
| Rick Ross | Movin’ Bass | 68 | 55 | 358 | loose |
| Rick Ross | Mrs. Officer Freestyle | 29 | 25 | 168 | loose |
| Rick Ross | Mugello Red | 41 | 30 | 287 | loose |
| Rick Ross | Murda Mami | 57 | 39 | 283 | loose |
| Rick Ross | Murder Mami | 46 | 25 | 193 | loose |
| Rick Ross | My Bitch | 50 | 43 | 240 | loose |
| Rick Ross | My Man | 51 | 87 | 264 | loose |
| Rick Ross | My Pimpin | 46 | 62 | 314 | loose |
| Rick Ross | My nigga | 45 | 39 | 239 | loose |
| Rick Ross | Naomi Campbell | 44 | 51 | 212 | loose |
| Rick Ross | Nastolgia | 32 | 44 | 277 | loose |
| Rick Ross | Nasty | 19 | 16 | 54 | loose |
| Rick Ross | National Champs | 48 | 22 | 225 | loose |
| Rick Ross | Negrin Zika | 29 | 4 | 336 | loose |
| Rick Ross | Neighborhood Drug Dealer | 36 | 20 | 181 | loose |
| Rick Ross | Never Been, Pt. II | 44 | 34 | 247 | loose |
| Rick Ross | Never Enough | 45 | 46 | 333 | loose |
| Rick Ross | Never personal | 39 | 22 | 315 | loose |
| Rick Ross | Nevermind That | 53 | 25 | 236 | loose |
| Rick Ross | New Agenda | 45 | 46 | 207 | loose |
| Rick Ross | New Bugatti | 39 | 41 | 218 | loose |
| Rick Ross | New Flame | 40 | 21 | 135 | loose |
| Rick Ross | New Greats | 34 | 35 | 259 | loose |
| Rick Ross | Nickel Rock | 48 | 55 | 364 | loose |
| Rick Ross | Nino | 34 | 22 | 212 | loose |
| Rick Ross | No | 17 | 10 | 73 | loose |
| Rick Ross | No Bark When I Bite | 23 | 16 | 132 | loose |
| Rick Ross | No Church in the Wild (Freestyle) | 57 | 69 | 253 | loose |
| Rick Ross | No Diddy (Gotham City) Ft. Rick Ross | 61 | 57 | 343 | loose |
| Rick Ross | No Games | 39 | 23 | 299 | loose |
| Rick Ross | No New Friends | 62 | 31 | 169 | loose |
| Rick Ross | No Problems | 19 | 5 | 77 | loose |
| Rick Ross | No Sucka Shit | 47 | 49 | 312 | loose |
| Rick Ross | No U-Turns | 32 | 19 | 151 | loose |
| Rick Ross | No Worries | 33 | 18 | 221 | loose |
| Rick Ross | No. 1 | 55 | 28 | 252 | loose |
| Rick Ross | Noble | 45 | 63 | 344 | loose |
| Rick Ross | Nobody | 47 | 34 | 205 | loose |
| Rick Ross | Nobody’s Favorite | 51 | 53 | 429 | loose |
| Rick Ross | Not For Nothing | 46 | 31 | 259 | loose |
| Rick Ross | Now That I’m Paid | 41 | 34 | 286 | loose |
| Rick Ross | Numb | 43 | 54 | 181 | loose |
| Rick Ross | NumbNumb Juice Freestyle | 76 | 75 | 408 | loose |
| Rick Ross | O Let’s Do It (Remix) | 67 | 28 | 327 | loose |
| Rick Ross | OG | 50 | 66 | 273 | loose |
| Rick Ross | Off The Corner | 47 | 33 | 231 | loose |
| Rick Ross | Off the Boat | 35 | 23 | 120 | loose |
| Rick Ross | Often (Remix) | 45 | 19 | 196 | loose |
| Rick Ross | Oh My Gosh (Remix) | 29 | 17 | 89 | loose |
| Rick Ross | Oil Money Gang | 68 | 52 | 370 | loose |
| Rick Ross | On Everything | 48 | 33 | 282 | loose |
| Rick Ross | On Some Real Shit | 59 | 49 | 314 | loose |
| Rick Ross | On Top of the World | 33 | 14 | 128 | loose |
| Rick Ross | On the Hotline (Remix) | 57 | 34 | 212 | loose |
| Rick Ross | One Blood (Dirty South Remix) | 25 | 8 | 111 | loose |
| Rick Ross | One Last Time (Blue Laces 3) | 62 | 71 | 405 | loose |
| Rick Ross | One Love | 41 | 14 | 305 | loose |
| Rick Ross | One Man Can Change the World | 49 | 50 | 339 | loose |
| Rick Ross | One More Shot | 41 | 36 | 409 | loose |
| Rick Ross | One Take Freestyle | 46 | 28 | 266 | loose |
| Rick Ross | One Take Freestyle Remix | 21 | 34 | 213 | loose |
| Rick Ross | One of Us | 49 | 24 | 292 | loose |
| Rick Ross | Only Fans | 26 | 20 | 128 | loose |
| Rick Ross | Open Hand | 41 | 55 | 204 | loose |
| Rick Ross | Options | 52 | 33 | 236 | loose |
| Rick Ross | Out Here Grindin’ | 57 | 39 | 259 | loose |
| Rick Ross | Outlawz | 57 | 57 | 261 | loose |
| Rick Ross | Own It (MMG Remix) | 48 | 22 | 122 | loose |
| Rick Ross | Oyster Perpetual Freestyle | 26 | 21 | 135 | loose |
| Rick Ross | Pablo’s Revere | 38 | 24 | 161 | loose |
| Rick Ross | Pacman | 46 | 66 | 313 | loose |
| Rick Ross | Pandemonium | 101 | 94 | 547 | loose |
| Rick Ross | Panera Bread | 46 | 28 | 320 | loose |
| Rick Ross | Panties In My Penthouse | 46 | 37 | 243 | loose |
| Rick Ross | Paper | 35 | 29 | 205 | loose |
| Rick Ross | Paper Plates | 60 | 61 | 204 | loose |
| Rick Ross | Paradise Lost | 42 | 33 | 153 | loose |
| Rick Ross | Paranoid (Remix) | 91 | 41 | 353 | loose |
| Rick Ross | Paris Morton Music | 22 | 14 | 114 | loose |
| Rick Ross | Party | 32 | 17 | 202 | loose |
| Rick Ross | Party Heart | 54 | 76 | 283 | loose |
| Rick Ross | Pass Rich (Remix) | 33 | 27 | 175 | loose |
| Rick Ross | Patrona | 57 | 71 | 218 | loose |
| Rick Ross | Patty Cake | 36 | 23 | 253 | loose |
| Rick Ross | Peace Sign | 42 | 36 | 186 | loose |
| Rick Ross | Penthouse Prayers | 57 | 60 | 431 | loose |
| Rick Ross | Perfect | 60 | 36 | 168 | loose |
| Rick Ross | Perfectionist | 50 | 58 | 303 | loose |
| Rick Ross | Phantom Swag | 52 | 72 | 181 | loose |
| Rick Ross | Phone Tap | 55 | 50 | 290 | loose |
| Rick Ross | Pillow Talk | 53 | 25 | 276 | loose |
| Rick Ross | Pimpin | 12 | 4 | 89 | loose |
| Rick Ross | Pinky Ring | 38 | 24 | 272 | loose |
| Rick Ross | Pinned to the Cross | 61 | 51 | 372 | loose |
| Rick Ross | Pirates | 44 | 44 | 283 | loose |
| Rick Ross | Play Your Part | 58 | 43 | 344 | loose |
| Rick Ross | Playa’s Ball | 47 | 20 | 150 | loose |
| Rick Ross | Pledge Allegiance | 92 | 67 | 654 | loose |
| Rick Ross | Plenty Cake | 35 | 24 | 92 | loose |
| Rick Ross | Plugged | 18 | 10 | 89 | loose |
| Rick Ross | Poledancer | 48 | 14 | 157 | loose |
| Rick Ross | Poor Decisions | 83 | 102 | 442 | loose |
| Rick Ross | Pop That | 94 | 82 | 334 | loose |
| Rick Ross | Pop That Pussy | 51 | 48 | 245 | loose |
| Rick Ross | Poppin’ | 57 | 31 | 285 | loose |
| Rick Ross | Porsche GT3 - RS | 26 | 31 | 116 | loose |
| Rick Ross | Port of Miami 2 Freestyle | 29 | 25 | 139 | loose |
| Rick Ross | Post to Be (Remix) | 93 | 95 | 336 | loose |
| Rick Ross | Potente (feat. Rick Ross) | 38 | 30 | 396 | loose |
| Rick Ross | Pots and Pans | 56 | 22 | 328 | loose |
| Rick Ross | Pour It Up (Remix) | 72 | 47 | 441 | loose |
| Rick Ross | Power | 55 | 42 | 208 | loose |
| Rick Ross | Power Circle | 150 | 148 | 869 | loose |
| Rick Ross | Powers That Be | 70 | 58 | 546 | loose |
| Rick Ross | Pray For Me | 76 | 72 | 298 | loose |
| Rick Ross | Pray for Us | 8 | 1 | 37 | loose |
| Rick Ross | Prayer | 55 | 41 | 196 | loose |
| Rick Ross | Preach (Remix) | 63 | 37 | 366 | loose |
| Rick Ross | Presidential | 59 | 48 | 256 | loose |
| Rick Ross | Presidential Pass | 34 | 20 | 87 | loose |
| Rick Ross | Price | 44 | 42 | 291 | loose |
| Rick Ross | Private Entertainer | 36 | 23 | 120 | loose |
| Rick Ross | Problem | 51 | 78 | 396 | loose |
| Rick Ross | Proud of That | 63 | 63 | 236 | loose |
| Rick Ross | Prove Me Wrong | 45 | 62 | 264 | loose |
| Rick Ross | Proven | 48 | 25 | 189 | loose |
| Rick Ross | Pull Up | 30 | 30 | 88 | loose |
| Rick Ross | Pull a Caper | 39 | 25 | 174 | loose |
| Rick Ross | Pullin on Her Hair | 35 | 26 | 148 | loose |
| Rick Ross | Purple Fentanyl | 29 | 21 | 200 | loose |
| Rick Ross | Purple Lamborghini | 39 | 20 | 220 | loose |
| Rick Ross | Push Em Over (50 Cent & Lloyd Banks Diss) | 23 | 9 | 85 | loose |
| Rick Ross | Push It | 49 | 44 | 269 | loose |
| Rick Ross | Put On Freestyle | 34 | 21 | 179 | loose |
| Rick Ross | Put One In the Air | 45 | 38 | 181 | loose |
| Rick Ross | Put Your Hands Up | 49 | 46 | 186 | loose |
| Rick Ross | Pyrex Poppin | 38 | 39 | 277 | loose |
| Rick Ross | Quarter Brick | 39 | 28 | 282 | loose |
| Rick Ross | Quarter To Eight (Money) | 40 | 32 | 207 | loose |
| Rick Ross | Quiet Storm | 17 | 10 | 89 | loose |
| Rick Ross | Quintessential | 40 | 22 | 363 | loose |
| Rick Ross | Rap Song | 42 | 12 | 230 | loose |
| Rick Ross | Rapper Estates | 59 | 112 | 304 | loose |
| Rick Ross | Real Love | 38 | 23 | 82 | loose |
| Rick Ross | Real Niggas | 68 | 37 | 274 | loose |
| Rick Ross | Realest Livin | 55 | 50 | 293 | loose |
| Rick Ross | Realest Niggas | 52 | 46 | 331 | loose |
| Rick Ross | Receipts | 32 | 41 | 144 | loose |
| Rick Ross | Red Bottom Boss | 50 | 26 | 380 | loose |
| Rick Ross | Red Cross (Brick Cover) | 17 | 19 | 56 | loose |
| Rick Ross | Red Horns | 36 | 60 | 124 | loose |
| Rick Ross | Red Horns 1 | 30 | 40 | 110 | loose |
| Rick Ross | Remarkable Hussle | 61 | 39 | 308 | loose |
| Rick Ross | Reppin’ My City | 93 | 43 | 256 | loose |
| Rick Ross | Respect Me | 39 | 35 | 165 | loose |
| Rick Ross | Respect the Code | 54 | 39 | 401 | loose |
| Rick Ross | Restored | 20 | 43 | 118 | AAAA |
| Rick Ross | RetroSuperFuture | 41 | 73 | 219 | loose |
| Rick Ross | RetroSuperFuture II | 13 | 9 | 79 | loose |
| Rick Ross | Revelations | 46 | 74 | 314 | loose |
| Rick Ross | Revory (Wraith) | 54 | 58 | 303 | loose |
| Rick Ross | Rich Forever | 68 | 65 | 309 | loose |
| Rick Ross | Rich Is Gangsta | 56 | 29 | 246 | loose |
| Rick Ross | Rich Nigga Lifestyle | 62 | 72 | 331 | loose |
| Rick Ross | Rich Nigga Walk Thru’ | 50 | 35 | 201 | loose |
| Rick Ross | Rich Off Cocaine | 60 | 45 | 303 | loose |
| Rick Ross | Rich Porter | 34 | 28 | 215 | loose |
| Rick Ross | Richer Than I Ever Been | 40 | 45 | 203 | loose |
| Rick Ross | Rick Ross Shout Out | 3 | 2 | 17 | loose |
| Rick Ross | Rick Ross Speaks / DJ Khaled Speaks | 9 | 5 | 19 | loose |
| Rick Ross | Rictus | 64 | 24 | 878 | loose |
| Rick Ross | Ride (Remix) | 50 | 47 | 278 | loose |
| Rick Ross | Ridin’ Thru the Ghetto | 69 | 46 | 348 | loose |
| Rick Ross | Right On Time | 45 | 31 | 133 | loose |
| Rick Ross | Ring Around The Rolls | 57 | 68 | 378 | loose |
| Rick Ross | Ring Ring | 30 | 20 | 149 | loose |
| Rick Ross | Rise Up | 30 | 27 | 175 | loose |
| Rick Ross | Risky | 29 | 29 | 259 | loose |
| Rick Ross | Rockin’ That Shit (Remix) | 72 | 59 | 307 | loose |
| Rick Ross | Rolex | 35 | 16 | 140 | loose |
| Rick Ross | Roll On ’Em | 62 | 65 | 353 | loose |
| Rick Ross | Rollin’ (Remix) | 42 | 27 | 293 | loose |
| Rick Ross | Room For the Yacht* | 4 | 3 | 44 | ABAA |
| Rick Ross | Rorschach | 33 | 12 | 443 | loose |
| Rick Ross | Rose Red (Remix) | 57 | 54 | 405 | loose |
| Rick Ross | Rosenberg Skit | 10 | 7 | 73 | loose |
| Rick Ross | Rounds | 33 | 21 | 118 | loose |
| Rick Ross | Routine | 77 | 65 | 328 | loose |
| Rick Ross | Royals (Rick Ross Remix) | 40 | 19 | 138 | loose |
| Rick Ross | Rozay Interlude | 20 | 8 | 59 | loose |
| Rick Ross | Rubber Bands | 19 | 13 | 124 | loose |
| Rick Ross | Rubberband Check | 52 | 47 | 177 | loose |
| Rick Ross | Rude Boy (Remix) | 44 | 34 | 156 | loose |
| Rick Ross | Run It | 31 | 32 | 141 | loose |
| Rick Ross | Run the World (Rap Version) | 35 | 25 | 156 | loose |
| Rick Ross | Runaway (Film) | 223 | 195 | 857 | loose |
| Rick Ross | Running Back | 54 | 50 | 203 | loose |
| Rick Ross | Running the Streets | 55 | 35 | 229 | loose |
| Rick Ross | SAINTS | 40 | 18 | 94 | loose |
| Rick Ross | SHAQ & KOBE | 56 | 54 | 315 | loose |
| Rick Ross | SOVEREIGN | 39 | 17 | 144 | loose |
| Rick Ross | STEPPIN (ft. Rick Ross) | 28 | 9 | 64 | loose |
| Rick Ross | Same Damn Time | 69 | 51 | 377 | loose |
| Rick Ross | Same Hoes | 35 | 26 | 164 | loose |
| Rick Ross | Sanctified | 45 | 42 | 218 | loose |
| Rick Ross | Santorini Greece | 78 | 57 | 332 | loose |
| Rick Ross | Saturday Night Special | 56 | 56 | 363 | loose |
| Rick Ross | Save The Best For Last | 70 | 95 | 396 | loose |
| Rick Ross | Scarface | 37 | 27 | 234 | loose |
| Rick Ross | Scientology | 39 | 37 | 257 | loose |
| Rick Ross | Scottie Beam | 56 | 48 | 426 | loose |
| Rick Ross | Season Ticket Holder | 67 | 58 | 406 | loose |
| Rick Ross | Seen or Saw (Remix) | 33 | 23 | 224 | loose |
| Rick Ross | Self Made | 89 | 75 | 563 | loose |
| Rick Ross | Self Paid | 24 | 16 | 38 | loose |
| Rick Ross | Set You Free | 42 | 25 | 140 | loose |
| Rick Ross | She Crazy | 38 | 34 | 253 | loose |
| Rick Ross | She Fell in Love (Remix) | 62 | 65 | 274 | loose |
| Rick Ross | She Wanna Fuck | 36 | 21 | 201 | loose |
| Rick Ross | She Will (Original) | 54 | 38 | 327 | loose |
| Rick Ross | She on My Dick | 55 | 46 | 354 | loose |
| Rick Ross | She’s My Star | 34 | 26 | 140 | loose |
| Rick Ross | Shhh (Freestyle) | 104 | 106 | 587 | loose |
| Rick Ross | Shine Bright International Remix | 28 | 18 | 292 | loose |
| Rick Ross | ShokkaSG | 49 | 69 | 202 | loose |
| Rick Ross | Shoot (Remix) | 31 | 14 | 208 | loose |
| Rick Ross | Shooter | 27 | 16 | 62 | loose |
| Rick Ross | Shop Open | 30 | 36 | 197 | loose |
| Rick Ross | Shot Caller (Remix) | 46 | 31 | 226 | loose |
| Rick Ross | Shot to the Heart | 43 | 41 | 254 | loose |
| Rick Ross | Shots Fired (Skit) | 3 | 1 | 5 | loose |
| Rick Ross | Sights | 27 | 21 | 115 | loose |
| Rick Ross | Silk Road | 49 | 35 | 282 | loose |
| Rick Ross | Simple And Plain | 56 | 80 | 508 | loose |
| Rick Ross | Sing For Me | 42 | 19 | 172 | loose |
| Rick Ross | Single Again (Remix) | 62 | 45 | 196 | loose |
| Rick Ross | Sixteen | 120 | 69 | 778 | loose |
| Rick Ross | Skip the Awards* | 6 | 1 | 22 | loose |
| Rick Ross | Skit #1 | 8 | 1 | 57 | loose |
| Rick Ross | Sky Might Fall (Freestyle) | 10 | 2 | 67 | loose |
| Rick Ross | Skyline | 44 | 45 | 196 | loose |
| Rick Ross | Smile Mama, Smile | 41 | 27 | 239 | loose |
| Rick Ross | Smoking pt. 2 | 49 | 39 | 258 | loose |
| Rick Ross | So Drunk (Original Version) | 30 | 12 | 134 | loose |
| Rick Ross | So Sharp | 46 | 35 | 298 | loose |
| Rick Ross | So Sophisticated | 60 | 136 | 360 | loose |
| Rick Ross | So in Love | 44 | 53 | 230 | loose |
| Rick Ross | Soft | 57 | 60 | 515 | loose |
| Rick Ross | Sola | 44 | 29 | 208 | loose |
| Rick Ross | Somethings Going On | 52 | 31 | 326 | loose |
| Rick Ross | Something’s Goin’ On | 29 | 14 | 175 | loose |
| Rick Ross | Sorry | 51 | 42 | 262 | loose |
| Rick Ross | Southern Gangsta | 72 | 36 | 398 | loose |
| Rick Ross | Southside (Remix) | 40 | 30 | 249 | loose |
| Rick Ross | Speakers | 4 | 3 | 38 | loose |
| Rick Ross | Speedin’ | 46 | 29 | 278 | loose |
| Rick Ross | Spend It Remix | 61 | 53 | 197 | loose |
| Rick Ross | Splash Brothers | 54 | 50 | 331 | loose |
| Rick Ross | Spotlight (Rick Ross Remix) | 54 | 55 | 189 | loose |
| Rick Ross | Stack On My Belt | 72 | 55 | 462 | loose |
| Rick Ross | Star Island | 53 | 27 | 249 | loose |
| Rick Ross | Staring Through My Rearview | 67 | 43 | 412 | loose |
| Rick Ross | State of the Union | 54 | 53 | 243 | loose |
| Rick Ross | Stay (Remix) | 46 | 22 | 129 | loose |
| Rick Ross | Stay Schemin Remix | 7 | 3 | 25 | loose |
| Rick Ross | Stay Schemin’ | 53 | 27 | 272 | loose |
| Rick Ross | Stay scheming | 34 | 19 | 217 | loose |
| Rick Ross | Steppin’ Out | 47 | 27 | 72 | loose |
| Rick Ross | Stick Talk (Remix) | 39 | 18 | 198 | loose |
| Rick Ross | Still Fuck Your Bitch* | 11 | 3 | 35 | loose |
| Rick Ross | Stop | 46 | 35 | 225 | loose |
| Rick Ross | Strapped | 51 | 48 | 389 | loose |
| Rick Ross | Street Life | 43 | 58 | 186 | loose |
| Rick Ross | Street Love | 59 | 63 | 250 | loose |
| Rick Ross | Street Money | 43 | 31 | 315 | loose |
| Rick Ross | Streets On Lock (Remix) | 45 | 30 | 252 | loose |
| Rick Ross | Sue Me | 50 | 40 | 277 | loose |
| Rick Ross | Summer Reign | 38 | 27 | 205 | loose |
| Rick Ross | Summer Seventeen | 44 | 32 | 185 | loose |
| Rick Ross | Sun Come Up | 36 | 21 | 173 | loose |
| Rick Ross | Sunshine (Remix) | 69 | 67 | 397 | loose |
| Rick Ross | Supa Cindy | 30 | 12 | 159 | loose |
| Rick Ross | Super Bowl LIII Halftime Show | 16 | 5 | 21 | loose |
| Rick Ross | Super Cindy | 13 | 0 | 20 | loose |
| Rick Ross | Super Freak | 41 | 52 | 180 | loose |
| Rick Ross | Super High (Sativa Remix) | 61 | 71 | 309 | loose |
| Rick Ross | Supreme | 58 | 45 | 311 | loose |
| Rick Ross | Swagger Right | 59 | 48 | 250 | loose |
| Rick Ross | Sweet Life | 27 | 24 | 118 | loose |
| Rick Ross | Swipe Life | 56 | 47 | 238 | loose |
| Rick Ross | THIS IS MY YEAR | 71 | 56 | 312 | loose |
| Rick Ross | Take Advantage | 36 | 32 | 166 | loose |
| Rick Ross | Take It to the Head | 45 | 37 | 244 | loose |
| Rick Ross | Talk That Talk (Remix) | 45 | 32 | 168 | loose |
| Rick Ross | Tangerine (Gentlemen’s Club Remix) | 75 | 67 | 384 | loose |
| Rick Ross | Tats on My Arm | 53 | 63 | 169 | loose |
| Rick Ross | Tear Gas | 67 | 86 | 551 | loose |
| Rick Ross | Tears of Joy | 70 | 71 | 272 | loose |
| Rick Ross | Tears of War | 90 | 79 | 611 | loose |
| Rick Ross | Teenage Numbers | 47 | 54 | 264 | loose |
| Rick Ross | Ten Jesus Pieces | 84 | 54 | 393 | loose |
| Rick Ross | Thank You | 60 | 57 | 328 | loose |
| Rick Ross | That Way | 44 | 41 | 303 | loose |
| Rick Ross | That’s On My Momma | 50 | 49 | 224 | loose |
| Rick Ross | That’s a Check | 57 | 53 | 228 | loose |
| Rick Ross | The Algorithm | 63 | 78 | 274 | loose |
| Rick Ross | The Boss | 44 | 40 | 228 | loose |
| Rick Ross | The Devil Is a Lie | 77 | 68 | 279 | loose |
| Rick Ross | The Game | 57 | 47 | 286 | loose |
| Rick Ross | The Gospel | 38 | 33 | 175 | loose |
| Rick Ross | The Great Americans | 77 | 74 | 452 | loose |
| Rick Ross | The Lion Roars | 48 | 51 | 150 | loose |
| Rick Ross | The More I Get | 18 | 22 | 63 | loose |
| Rick Ross | The Pulitzer | 34 | 23 | 177 | loose |
| Rick Ross | The Realist Livin’ | 20 | 9 | 108 | loose |
| Rick Ross | The Scenic Route | 33 | 60 | 235 | loose |
| Rick Ross | The Show | 57 | 46 | 295 | loose |
| Rick Ross | The Summer’s Mine | 26 | 22 | 85 | loose |
| Rick Ross | The Times And Life of Shawn Carter | 70 | 42 | 298 | loose |
| Rick Ross | The Transporter | 50 | 36 | 215 | loose |
| Rick Ross | The Trillest | 36 | 28 | 174 | loose |
| Rick Ross | The Way You Love Me | 42 | 32 | 179 | loose |
| Rick Ross | The Weather | 76 | 99 | 367 | loose |
| Rick Ross | The Zenith | 68 | 77 | 366 | loose |
| Rick Ross | The risk of love | 22 | 5 | 74 | loose |
| Rick Ross | Then I Leave | 33 | 14 | 107 | loose |
| Rick Ross | They Don’t Love You No More | 68 | 56 | 338 | loose |
| Rick Ross | They Don’t Really Love You | 47 | 47 | 304 | loose |
| Rick Ross | They Know (Remix) | 19 | 14 | 65 | loose |
| Rick Ross | Think About It (Rich As In Spirit) | 32 | 25 | 181 | loose |
| Rick Ross | Think Like a Man | 50 | 34 | 154 | loose |
| Rick Ross | This Is The Life | 47 | 32 | 262 | loose |
| Rick Ross | This Me | 49 | 37 | 329 | loose |
| Rick Ross | This Thing of Ours | 62 | 54 | 411 | loose |
| Rick Ross | Throw It In The Sky Remix | 66 | 74 | 305 | loose |
| Rick Ross | Throw It in the Sky | 38 | 48 | 189 | loose |
| Rick Ross | Thug Cry | 56 | 34 | 264 | loose |
| Rick Ross | Thug Tears (Remix) | 62 | 51 | 467 | loose |
| Rick Ross | Thumbin’ | 50 | 33 | 317 | loose |
| Rick Ross | Til Da Sun Come Up | 38 | 32 | 156 | loose |
| Rick Ross | Til We Die | 59 | 64 | 319 | loose |
| Rick Ross | Timeless | 44 | 50 | 260 | loose |
| Rick Ross | TipToe’N | 42 | 20 | 219 | loose |
| Rick Ross | Tired of Dreaming | 34 | 21 | 168 | loose |
| Rick Ross | Told Y’all | 51 | 30 | 238 | loose |
| Rick Ross | Too Late | 31 | 5 | 149 | loose |
| Rick Ross | Too Many Goats | 68 | 53 | 421 | loose |
| Rick Ross | Torn (Remix) | 57 | 30 | 163 | loose |
| Rick Ross | Touch My Body (Love / Hate Remix) | 52 | 24 | 87 | loose |
| Rick Ross | Touch The Sky | 52 | 48 | 154 | loose |
| Rick Ross | Touch’N You | 52 | 16 | 277 | loose |
| Rick Ross | Tranquillo | 62 | 37 | 394 | loose |
| Rick Ross | Trap Boomin | 29 | 30 | 172 | loose |
| Rick Ross | Trap House | 58 | 19 | 254 | loose |
| Rick Ross | Trap House 3 | 39 | 31 | 81 | loose |
| Rick Ross | Trap Luv | 64 | 44 | 313 | loose |
| Rick Ross | Trap Trap Trap | 53 | 31 | 306 | loose |
| Rick Ross | Trick’n Off | 41 | 41 | 245 | loose |
| Rick Ross | Trilla Intro | 49 | 25 | 200 | loose |
| Rick Ross | Triple Beam Dreams | 77 | 71 | 481 | loose |
| Rick Ross | Triple Platinum | 73 | 80 | 428 | loose |
| Rick Ross | Triumphant (Get ’Em) | 49 | 24 | 197 | loose |
| Rick Ross | Trust Issues | 44 | 26 | 193 | loose |
| Rick Ross | Trust Me* | 13 | 4 | 49 | loose |
| Rick Ross | Tunechi’s Back | 36 | 27 | 170 | loose |
| Rick Ross | Tupac Back | 50 | 46 | 304 | loose |
| Rick Ross | Turn Ya Back | 60 | 43 | 254 | loose |
| Rick Ross | Turnpike Ike | 76 | 35 | 416 | loose |
| Rick Ross | Two Three | 31 | 20 | 135 | loose |
| Rick Ross | Type A Nigga (Remix) | 63 | 46 | 470 | loose |
| Rick Ross | U Ain’t Him | 50 | 44 | 197 | loose |
| Rick Ross | U.O.E.N.O | 46 | 23 | 401 | loose |
| Rick Ross | UH OH | 44 | 67 | 337 | loose |
| Rick Ross | Ugh | 37 | 13 | 197 | loose |
| Rick Ross | Uh Huh (Remix) | 55 | 39 | 283 | loose |
| Rick Ross | Umma Do Me (Remix) | 64 | 40 | 375 | loose |
| Rick Ross | Us | 59 | 69 | 229 | loose |
| Rick Ross | Usual Suspects | 63 | 33 | 384 | loose |
| Rick Ross | VSOP (Remix) | 43 | 18 | 183 | loose |
| Rick Ross | VSVSVS (Remix) | 57 | 50 | 227 | loose |
| Rick Ross | Vacheron | 53 | 91 | 404 | loose |
| Rick Ross | Valentina (Bonus) | 28 | 21 | 141 | loose |
| Rick Ross | Valley of Death | 60 | 65 | 332 | loose |
| Rick Ross | Vamonos | 65 | 86 | 352 | loose |
| Rick Ross | Vanilla Sprite Remix | 66 | 73 | 324 | loose |
| Rick Ross | Vegas Residency | 83 | 48 | 545 | loose |
| Rick Ross | Venus | 23 | 10 | 42 | loose |
| Rick Ross | Very Best | 52 | 56 | 349 | loose |
| Rick Ross | Veteran’s Day | 60 | 49 | 289 | loose |
| Rick Ross | Vial | 71 | 73 | 294 | loose |
| Rick Ross | Virgo Tendencies (Remix) | 39 | 45 | 139 | loose |
| Rick Ross | WE OFF THAT | 224 | 162 | 880 | loose |
| Rick Ross | WINDOWS | 10 | 1 | 34 | loose |
| Rick Ross | Waist So Skinny | 38 | 25 | 115 | loose |
| Rick Ross | Waka | 43 | 13 | 120 | loose |
| Rick Ross | Walking On Water | 49 | 25 | 229 | loose |
| Rick Ross | Walkin’ on Air | 55 | 36 | 224 | loose |
| Rick Ross | War Ready | 109 | 23 | 623 | loose |
| Rick Ross | Warm Words in a Cold World | 53 | 72 | 271 | loose |
| Rick Ross | Watch Money Fall | 39 | 24 | 289 | loose |
| Rick Ross | Watch Out | 55 | 35 | 190 | loose |
| Rick Ross | Watcha Gon’ Do? | 79 | 56 | 639 | loose |
| Rick Ross | Water Whip’N | 39 | 37 | 173 | loose |
| Rick Ross | Way I Get It | 62 | 28 | 333 | loose |
| Rick Ross | We Dem Boyz (Remix) | 56 | 54 | 394 | loose |
| Rick Ross | We Don’t | 58 | 51 | 159 | loose |
| Rick Ross | We Gangsta | 60 | 33 | 257 | loose |
| Rick Ross | We Gettin’ It | 49 | 16 | 201 | loose |
| Rick Ross | We Gon Make It | 37 | 18 | 207 | loose |
| Rick Ross | We Shinin’ | 61 | 48 | 328 | loose |
| Rick Ross | We Takin’ Over | 78 | 66 | 316 | loose |
| Rick Ross | Welcome 2 My Hood (Remix) | 13 | 5 | 74 | AABB |
| Rick Ross | Welcome to My Hood | 50 | 40 | 261 | loose |
| Rick Ross | Welcome to the World | 33 | 24 | 114 | loose |
| Rick Ross | We’re Going Home (Remix) | 49 | 27 | 136 | loose |
| Rick Ross | What It Is | 34 | 34 | 268 | loose |
| Rick Ross | What a Shame | 29 | 16 | 114 | loose |
| Rick Ross | Whatever | 53 | 37 | 280 | loose |
| Rick Ross | What’s Free | 106 | 135 | 627 | loose |
| Rick Ross | When You Feel This | 29 | 19 | 115 | loose |
| Rick Ross | Where My Money (I Need That) | 60 | 49 | 334 | loose |
| Rick Ross | Where Would I Go | 58 | 50 | 381 | loose |
| Rick Ross | Where Ya At (Remix) | 74 | 56 | 507 | loose |
| Rick Ross | Where You From? | 74 | 44 | 336 | loose |
| Rick Ross | Whispers in the Woods | 10 | 4 | 33 | loose |
| Rick Ross | White Girl (Remix) | 55 | 35 | 234 | loose |
| Rick Ross | White House | 45 | 41 | 246 | loose |
| Rick Ross | White Iverson (Remix) | 38 | 18 | 189 | loose |
| Rick Ross | White Lines | 40 | 60 | 152 | loose |
| Rick Ross | White Sand | 55 | 39 | 179 | loose |
| Rick Ross | White Sand Part II | 67 | 55 | 493 | loose |
| Rick Ross | Who Do We Think We Are | 38 | 14 | 165 | loose |
| Rick Ross | Whole Lotta Money (Remix) | 29 | 26 | 188 | loose |
| Rick Ross | Why | 56 | 40 | 214 | loose |
| Rick Ross | Why R U? (Remix) | 54 | 35 | 285 | loose |
| Rick Ross | Why do not we fall in love | 50 | 19 | 240 | loose |
| Rick Ross | Wiggle | 40 | 48 | 223 | loose |
| Rick Ross | Wild One | 54 | 63 | 362 | loose |
| Rick Ross | Window Seat (Remix) | 50 | 22 | 141 | loose |
| Rick Ross | Wing Stop (Remix) | 57 | 49 | 380 | loose |
| Rick Ross | Wit It | 49 | 25 | 94 | loose |
| Rick Ross | Work | 47 | 16 | 165 | loose |
| Rick Ross | Work Remix | 57 | 47 | 233 | loose |
| Rick Ross | World’s Finest | 56 | 42 | 273 | loose |
| Rick Ross | Worry No More | 31 | 31 | 120 | loose |
| Rick Ross | Wrong Lover | 31 | 10 | 51 | loose |
| Rick Ross | Wuzzup | 33 | 19 | 221 | loose |
| Rick Ross | YM Inkredible | 84 | 76 | 417 | loose |
| Rick Ross | YRB | 57 | 63 | 430 | loose |
| Rick Ross | Ya Don’t Stop | 43 | 49 | 319 | loose |
| Rick Ross | Yacht Club | 71 | 34 | 389 | loose |
| Rick Ross | Yams | 48 | 27 | 180 | loose |
| Rick Ross | Yams Pt. 2 | 54 | 46 | 195 | loose |
| Rick Ross | Yayo | 32 | 24 | 115 | loose |
| Rick Ross | Yeah OK | 40 | 38 | 163 | loose |
| Rick Ross | Yeah, Dat’s Money | 32 | 15 | 73 | loose |
| Rick Ross | Yella Diamonds | 46 | 26 | 214 | loose |
| Rick Ross | Yellow Stone | 31 | 47 | 203 | loose |
| Rick Ross | You (Remix) | 39 | 20 | 131 | loose |
| Rick Ross | You A Lie Remix | 54 | 58 | 289 | loose |
| Rick Ross | You Can Tell How I Walk | 42 | 48 | 249 | loose |
| Rick Ross | You Don’t Want These Problems | 72 | 48 | 306 | loose |
| Rick Ross | You Know I Got It (Reprise) | 27 | 21 | 83 | loose |
| Rick Ross | You Only Live Twice | 65 | 91 | 414 | loose |
| Rick Ross | You Should’ve Killed Me | 39 | 22 | 247 | loose |
| Rick Ross | You The Boss | 51 | 23 | 160 | loose |
| Rick Ross | Young & Gettin It | 36 | 16 | 238 | loose |
| Rick Ross | Your Life | 66 | 39 | 173 | loose |
| Rick Ross | Your Love (Remix) | 58 | 30 | 247 | loose |
| Rick Ross | You’re Everything | 67 | 21 | 537 | loose |
| Rick Ross | glo_up | 26 | 29 | 210 | loose |
| Rick Ross | ’06 | 27 | 18 | 156 | loose |
