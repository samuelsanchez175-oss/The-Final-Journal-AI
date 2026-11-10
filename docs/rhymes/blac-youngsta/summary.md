# Blac Youngsta rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Blac Youngsta
- Songs: 275
- Bars kept (Blac Youngsta lyric lines): 12095
- Section headers dropped, not counted as bars: 1
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 12
- Canonical name: Blac Youngsta.
- Credit strings: Blac Youngsta.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 77354
- REPEAT pairs, recorded separately: 13187
- END rhymes: 12583
- INNER rhymes: 64771

By match:

- PERFECT: 7604 (END 2367, INNER 5237)
- SLANT: 36202 (END 5482, INNER 30720)
- ASSONANCE: 32884 (END 4516, INNER 28368)
- MULTI: 664 (END 218, INNER 446)

By confidence:

- HIGH: 7762
- MED: 64070
- LOW: 5522

## Core

- Core Y: 76447
- Core N among rhyme pairs: 907

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 38682 (50.0%)
- vowel: 32884 (42.5%)
- spelling: 5124 (6.6%)
- multi: 664 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 5 songs
- loose: 270 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 4641 pairs (END 400, INNER 4241). Words: don't, know, no, go, told, ho, hoes, don’t.
2. `vow:IH` — 4637 pairs (END 503, INNER 4134). Words: bitch, shit, bitches, lil, think, hit, didn't, give.
3. `vow:EY` — 4340 pairs (END 660, INNER 3680). Words: ain't, say, day, play, way, make, take, pay.
4. `vow:EH` — 4274 pairs (END 512, INNER 3762). Words: when, get, never, went, let, every, send, left.
5. `vow:AH` — 3065 pairs (END 443, INNER 2622). Words: fuck, somethin, some, hundred, money, what, bust, come.
6. `vow:AE` — 2806 pairs (END 471, INNER 2335). Words: can't, back, can, had, have, ass, last, ask.
7. `vow:AA` — 2540 pairs (END 382, INNER 2158). Words: got, want, talkin, hard, shots, wanna, gotta, nothin.
8. `slant:IH:stop` — 2497 pairs (END 352, INNER 2145). Words: nigga, shit, hit, big, dick, city, quick, stick.
9. `vow:AY` — 2342 pairs (END 447, INNER 1895). Words: like, die, by, why, fire, time, life, try.
10. `vow:IY` — 2178 pairs (END 311, INNER 1867). Words: see, need, these, streets, real, even, keep, free.
11. `slant:AA:stop` — 2083 pairs (END 277, INNER 1806). Words: got, gotta, god, block, want, not, body, everybody.
12. `slant:IH:sib-stop` — 2077 pairs (END 413, INNER 1664). Words: bitch, nigga, niggas, shit, rich, hit, dick, big.
13. `cmu:OW` — 1397 pairs (END 213, INNER 1184). Words: know, no, go, ho, blow, low, show, though.
14. `slant:AH:nas-stop` — 1319 pairs (END 47, INNER 1272). Words: fuck, what, some, come, money, one, young, run.
15. `slant:IH:liq-stop` — 1300 pairs (END 37, INNER 1263). Words: shit, lil, still, really, kill, hit, 'til, big.
16. `slant:AH:nas` — 1077 pairs (END 137, INNER 940). Words: money, some, young, come, one, run, done, runnin.
17. `slant:EH:stop` — 1051 pairs (END 177, INNER 874). Words: get, let, head, better, said, went, dead, red.
18. `slant:AE:stop` — 944 pairs (END 279, INNER 665). Words: back, can't, had, bag, whacked, bad, mac, trap.
19. `slant:EH:nas-stop` — 937 pairs (END 54, INNER 883). Words: when, get, let, many, again, friend, head, dead.
20. `slant:IH:nas-stop` — 807 pairs (END 38, INNER 769). Words: shit, him, i'ma, hit, big, spin, thing, dick.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 2075 pair sides, mostly spelling via spelling phonetic key, often with niggas (568)
- niggas — 795 pair sides, mostly spelling via spelling phonetic key, often with nigga (568)
- ima — 586 pair sides, mostly spelling via spelling phonetic key, often with shit (74)
- gon — 494 pair sides, mostly spelling via spelling phonetic key, often with dont (161)
- tryna — 366 pair sides, mostly spelling via spelling phonetic key, often with need (32)
- opps — 95 pair sides, mostly vowel via spelling phonetic key, often with know (32)
- imma — 78 pair sides, mostly vowel via spelling phonetic key, often with nigga (49)
- shawty — 55 pair sides, mostly vowel via spelling phonetic key, often with all (17)
- homie — 46 pair sides, mostly spelling via spelling phonetic key, often with gon (11)
- cuz — 43 pair sides, mostly spelling via spelling phonetic key, often with fuck (7)
- bih — 39 pair sides, mostly spelling via spelling phonetic key, often with quick (4)
- dawg — 38 pair sides, mostly spelling via spelling phonetic key, often with all (12)
- cudi — 38 pair sides, mostly spelling via spelling phonetic key, often with nutty (8)
- migo — 35 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- wraith — 34 pair sides, mostly spelling via spelling phonetic key, often with aint (6)
- finna — 33 pair sides, mostly vowel via spelling phonetic key, often with niggas (15)
- dyin — 33 pair sides, mostly spelling via spelling phonetic key, often with reason (6)
- lyin — 25 pair sides, mostly spelling via spelling phonetic key, often with need (2)
- thot — 24 pair sides, mostly spelling via spelling phonetic key, often with dont (5)
- blac — 24 pair sides, mostly spelling via spelling phonetic key, often with gang (4)
- dolo — 21 pair sides, mostly vowel via spelling phonetic key, often with hoes (3)
- lik — 20 pair sides, mostly spelling via spelling phonetic key, often with bitch (6)
- lambo — 20 pair sides, mostly vowel via spelling phonetic key, often with rambo (4)
- mammy — 19 pair sides, mostly vowel via spelling phonetic key, often with money (2)
- killa — 18 pair sides, mostly vowel via spelling phonetic key, often with nigga (10)
- twerk — 17 pair sides, mostly spelling via spelling phonetic key, often with work (8)
- mami — 17 pair sides, mostly spelling via spelling phonetic key, often with gran (9)
- thuggin — 16 pair sides, mostly spelling via spelling phonetic key, often with bustin (2)
- bruh — 16 pair sides, mostly spelling via spelling phonetic key, often with what (5)
- swag — 16 pair sides, mostly spelling via spelling phonetic key, often with cash (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Blac Youngsta | 1 2 3 | 48 | 40 | 233 | loose |
| Blac Youngsta | 1 on 1 | 42 | 59 | 115 | loose |
| Blac Youngsta | 2 Way Street | 33 | 31 | 215 | loose |
| Blac Youngsta | 901 | 36 | 27 | 181 | loose |
| Blac Youngsta | Ain’t In Need | 34 | 15 | 169 | loose |
| Blac Youngsta | All Day | 66 | 66 | 353 | loose |
| Blac Youngsta | All I Want | 45 | 39 | 219 | loose |
| Blac Youngsta | All Of My Niggas | 38 | 37 | 99 | loose |
| Blac Youngsta | Alleged | 34 | 46 | 338 | loose |
| Blac Youngsta | Anybody | 41 | 62 | 254 | loose |
| Blac Youngsta | Anythang | 31 | 35 | 204 | loose |
| Blac Youngsta | Ask For It | 52 | 51 | 126 | loose |
| Blac Youngsta | B.R.A.T. | 39 | 51 | 282 | loose |
| Blac Youngsta | Back Breaker (Demo) | 15 | 16 | 36 | loose |
| Blac Youngsta | Background | 32 | 54 | 274 | loose |
| Blac Youngsta | Bad Bitch (Remix) | 38 | 35 | 174 | loose |
| Blac Youngsta | Bands On Me | 43 | 36 | 176 | loose |
| Blac Youngsta | Bandz | 37 | 43 | 237 | loose |
| Blac Youngsta | Bang & On The Run | 39 | 65 | 325 | loose |
| Blac Youngsta | Battle | 40 | 16 | 128 | loose |
| Blac Youngsta | Beat It | 36 | 42 | 153 | loose |
| Blac Youngsta | Behind the Wheel | 37 | 57 | 361 | loose |
| Blac Youngsta | Belly | 44 | 59 | 316 | loose |
| Blac Youngsta | Birthday | 67 | 54 | 268 | loose |
| Blac Youngsta | Birthplace | 48 | 54 | 179 | loose |
| Blac Youngsta | Blac Ball | 46 | 100 | 401 | AAAA |
| Blac Youngsta | Blac Money | 53 | 107 | 310 | loose |
| Blac Youngsta | Blac Sheep | 41 | 66 | 326 | loose |
| Blac Youngsta | Blind | 52 | 64 | 235 | loose |
| Blac Youngsta | Bloody N | 32 | 41 | 223 | loose |
| Blac Youngsta | Blunt | 45 | 65 | 174 | loose |
| Blac Youngsta | Booty | 34 | 27 | 94 | loose |
| Blac Youngsta | Breathe | 39 | 39 | 109 | loose |
| Blac Youngsta | BulletProof | 35 | 39 | 151 | loose |
| Blac Youngsta | Bullshit | 23 | 19 | 107 | loose |
| Blac Youngsta | Bus Stop / Booty (Mixed) | 16 | 12 | 66 | loose |
| Blac Youngsta | CHANGE MY LIFE | 59 | 109 | 280 | loose |
| Blac Youngsta | CMG | 44 | 29 | 339 | loose |
| Blac Youngsta | CMG / Heavy Camp | 64 | 99 | 495 | loose |
| Blac Youngsta | Can’t Spell | 46 | 51 | 376 | loose |
| Blac Youngsta | Catch a Body | 26 | 10 | 241 | loose |
| Blac Youngsta | Certified | 37 | 17 | 141 | loose |
| Blac Youngsta | Cheat On Me | 43 | 26 | 190 | loose |
| Blac Youngsta | Church on Sunday | 50 | 64 | 239 | loose |
| Blac Youngsta | Colors (Remix) | 69 | 74 | 293 | loose |
| Blac Youngsta | Come Thru | 44 | 35 | 177 | loose |
| Blac Youngsta | Confuse Me | 37 | 37 | 111 | loose |
| Blac Youngsta | Cool Lil Thottie | 48 | 25 | 234 | loose |
| Blac Youngsta | Count Up | 32 | 78 | 306 | AAAA |
| Blac Youngsta | Court Tomorrow | 37 | 33 | 263 | loose |
| Blac Youngsta | Crash Out | 49 | 56 | 379 | loose |
| Blac Youngsta | Cut Up | 24 | 44 | 97 | loose |
| Blac Youngsta | Damm | 55 | 70 | 153 | loose |
| Blac Youngsta | Dangerous | 24 | 29 | 253 | loose |
| Blac Youngsta | Daylight | 43 | 35 | 403 | loose |
| Blac Youngsta | Deserve That Shit | 39 | 43 | 170 | loose |
| Blac Youngsta | Designer (Remix) | 67 | 67 | 394 | loose |
| Blac Youngsta | Diss Me | 45 | 53 | 316 | loose |
| Blac Youngsta | Do It | 32 | 29 | 87 | loose |
| Blac Youngsta | Do That | 50 | 39 | 179 | loose |
| Blac Youngsta | Dodge | 35 | 17 | 114 | loose |
| Blac Youngsta | Don’t Bother Me | 59 | 94 | 260 | loose |
| Blac Youngsta | Don’t Make A Sound | 44 | 77 | 360 | loose |
| Blac Youngsta | Drive Thru | 29 | 13 | 111 | loose |
| Blac Youngsta | Drop | 40 | 44 | 161 | loose |
| Blac Youngsta | Drop Yo Flag | 38 | 28 | 207 | loose |
| Blac Youngsta | Drug Lord | 39 | 13 | 93 | loose |
| Blac Youngsta | Eaze My Mind | 49 | 117 | 173 | AAAA |
| Blac Youngsta | Ever Since | 31 | 45 | 330 | loose |
| Blac Youngsta | EveryThang | 38 | 19 | 235 | loose |
| Blac Youngsta | Exactly | 35 | 70 | 381 | loose |
| Blac Youngsta | F Da Rap Game | 21 | 15 | 186 | loose |
| Blac Youngsta | FIRE | 36 | 50 | 279 | loose |
| Blac Youngsta | Feelings | 28 | 19 | 122 | loose |
| Blac Youngsta | Field Goal | 32 | 27 | 306 | loose |
| Blac Youngsta | Fire Us | 30 | 24 | 296 | loose |
| Blac Youngsta | Flashy | 39 | 51 | 109 | loose |
| Blac Youngsta | Foreva Eva | 39 | 25 | 72 | loose |
| Blac Youngsta | Forever | 32 | 39 | 98 | loose |
| Blac Youngsta | Freaky | 34 | 39 | 194 | loose |
| Blac Youngsta | Free Lunch | 34 | 23 | 143 | loose |
| Blac Youngsta | Free Thugger | 50 | 59 | 366 | loose |
| Blac Youngsta | Front Row Seat | 47 | 32 | 220 | loose |
| Blac Youngsta | Fuck Em | 48 | 14 | 192 | loose |
| Blac Youngsta | Fuck Everybody Else | 41 | 64 | 324 | loose |
| Blac Youngsta | Fuck Everybody Intro | 99 | 89 | 301 | loose |
| Blac Youngsta | Gang Gang | 67 | 21 | 203 | loose |
| Blac Youngsta | Gang Gang Gang | 4 | 0 | 4 | loose |
| Blac Youngsta | Gangsta Art | 104 | 142 | 700 | loose |
| Blac Youngsta | Get Here | 33 | 14 | 274 | loose |
| Blac Youngsta | Get Out My Face | 31 | 15 | 55 | loose |
| Blac Youngsta | Get Whacked | 41 | 36 | 94 | loose |
| Blac Youngsta | Go To Sleep | 52 | 94 | 467 | loose |
| Blac Youngsta | GoT MoE DoE | 38 | 69 | 351 | loose |
| Blac Youngsta | Goal Line | 61 | 45 | 269 | loose |
| Blac Youngsta | Gone Till | 30 | 24 | 112 | loose |
| Blac Youngsta | Good Die Young | 37 | 30 | 220 | loose |
| Blac Youngsta | Goodbye | 60 | 44 | 165 | loose |
| Blac Youngsta | Gravy | 57 | 79 | 418 | loose |
| Blac Youngsta | Gun On Me | 29 | 21 | 131 | loose |
| Blac Youngsta | Gun Smoke | 63 | 94 | 485 | loose |
| Blac Youngsta | Hail Mary | 36 | 20 | 127 | loose |
| Blac Youngsta | Havv Sum Fun | 45 | 39 | 296 | loose |
| Blac Youngsta | Heavy | 61 | 43 | 203 | loose |
| Blac Youngsta | Heavy 2 | 39 | 43 | 228 | loose |
| Blac Youngsta | Heavy Camp | 28 | 35 | 110 | loose |
| Blac Youngsta | High Beams | 56 | 55 | 423 | loose |
| Blac Youngsta | Hip Hopper | 44 | 32 | 232 | loose |
| Blac Youngsta | Hip hopper clean | 30 | 15 | 149 | loose |
| Blac Youngsta | Hit And Go | 20 | 25 | 196 | loose |
| Blac Youngsta | Hit It | 58 | 42 | 173 | loose |
| Blac Youngsta | Hold It Down | 38 | 42 | 102 | loose |
| Blac Youngsta | Hunt You | 42 | 45 | 244 | loose |
| Blac Youngsta | Hush | 31 | 32 | 136 | loose |
| Blac Youngsta | Hustle For Mine | 53 | 53 | 135 | loose |
| Blac Youngsta | I Don’t | 58 | 78 | 415 | loose |
| Blac Youngsta | I Got You | 47 | 35 | 138 | loose |
| Blac Youngsta | I Met Tay Keith First | 63 | 65 | 274 | loose |
| Blac Youngsta | I WANA | 51 | 32 | 296 | loose |
| Blac Youngsta | I Want It All | 38 | 24 | 144 | loose |
| Blac Youngsta | I Would | 33 | 22 | 166 | loose |
| Blac Youngsta | IDK What To Say | 37 | 60 | 297 | loose |
| Blac Youngsta | Ight | 55 | 53 | 269 | loose |
| Blac Youngsta | Illuminati Intro | 61 | 33 | 406 | loose |
| Blac Youngsta | Intro | 79 | 57 | 403 | loose |
| Blac Youngsta | Invisible | 43 | 47 | 178 | loose |
| Blac Youngsta | I’m Assuming | 61 | 70 | 437 | loose |
| Blac Youngsta | I’m Innocent | 43 | 24 | 204 | loose |
| Blac Youngsta | Keep That | 63 | 80 | 251 | loose |
| Blac Youngsta | Kid Cudi | 55 | 37 | 214 | loose |
| Blac Youngsta | LIVE LIFE | 37 | 63 | 269 | loose |
| Blac Youngsta | Late | 39 | 81 | 241 | loose |
| Blac Youngsta | Lay Down | 46 | 57 | 267 | loose |
| Blac Youngsta | Layin Low | 64 | 51 | 229 | loose |
| Blac Youngsta | Left | 41 | 14 | 181 | loose |
| Blac Youngsta | Lie to Me | 35 | 24 | 283 | loose |
| Blac Youngsta | Like A Russian | 53 | 43 | 197 | loose |
| Blac Youngsta | Like a Pro | 43 | 40 | 191 | loose |
| Blac Youngsta | Lil Bitch | 33 | 37 | 75 | loose |
| Blac Youngsta | Lil Nigga | 61 | 13 | 185 | loose |
| Blac Youngsta | Lit As A MF | 39 | 65 | 249 | loose |
| Blac Youngsta | Locked In | 63 | 52 | 472 | loose |
| Blac Youngsta | Lonely Road | 47 | 46 | 321 | loose |
| Blac Youngsta | Long Live | 55 | 44 | 300 | loose |
| Blac Youngsta | Long Time | 58 | 71 | 245 | loose |
| Blac Youngsta | M&Ms | 56 | 55 | 196 | loose |
| Blac Youngsta | Mad People | 32 | 36 | 344 | loose |
| Blac Youngsta | Make The News | 42 | 37 | 256 | loose |
| Blac Youngsta | Mark, Said, Ready, Go | 60 | 89 | 260 | loose |
| Blac Youngsta | Megan | 33 | 25 | 214 | loose |
| Blac Youngsta | Miss You | 44 | 21 | 117 | loose |
| Blac Youngsta | Money | 54 | 97 | 429 | loose |
| Blac Youngsta | Money Bag | 53 | 58 | 127 | loose |
| Blac Youngsta | More Than a Man | 43 | 78 | 256 | loose |
| Blac Youngsta | Mosh Pit | 29 | 34 | 369 | loose |
| Blac Youngsta | Motor | 26 | 35 | 159 | loose |
| Blac Youngsta | My Fault | 24 | 5 | 262 | loose |
| Blac Youngsta | N Traffic | 58 | 49 | 421 | loose |
| Blac Youngsta | Need Love | 52 | 50 | 308 | loose |
| Blac Youngsta | Need You | 30 | 18 | 118 | loose |
| Blac Youngsta | Neighborhood Hero | 36 | 29 | 266 | loose |
| Blac Youngsta | New Chain | 89 | 89 | 440 | loose |
| Blac Youngsta | New Guwop | 74 | 43 | 470 | loose |
| Blac Youngsta | No Competition | 48 | 50 | 273 | loose |
| Blac Youngsta | No Reason | 48 | 135 | 307 | AAAA |
| Blac Youngsta | No Tellin’ | 41 | 26 | 156 | loose |
| Blac Youngsta | Nobody | 44 | 52 | 351 | loose |
| Blac Youngsta | Old Friends | 49 | 46 | 121 | loose |
| Blac Youngsta | On Me | 48 | 29 | 135 | loose |
| Blac Youngsta | On Sight | 54 | 69 | 153 | loose |
| Blac Youngsta | One Time | 32 | 15 | 158 | loose |
| Blac Youngsta | Ooouuu | 37 | 32 | 136 | loose |
| Blac Youngsta | PEGS | 32 | 29 | 257 | loose |
| Blac Youngsta | POP | 13 | 5 | 53 | loose |
| Blac Youngsta | Paparazzi | 45 | 34 | 407 | loose |
| Blac Youngsta | Plastic | 46 | 69 | 132 | loose |
| Blac Youngsta | Poking Out | 32 | 30 | 285 | loose |
| Blac Youngsta | Problems | 41 | 36 | 250 | loose |
| Blac Youngsta | Protect | 38 | 39 | 279 | loose |
| Blac Youngsta | Pull Up | 29 | 15 | 75 | loose |
| Blac Youngsta | Pure | 34 | 24 | 252 | loose |
| Blac Youngsta | RAID | 39 | 32 | 165 | loose |
| Blac Youngsta | RNS | 54 | 57 | 317 | loose |
| Blac Youngsta | RUN IT UP | 63 | 91 | 465 | loose |
| Blac Youngsta | Ratchet | 59 | 44 | 142 | loose |
| Blac Youngsta | Raw | 38 | 59 | 157 | loose |
| Blac Youngsta | Razzle Dazzle | 32 | 35 | 362 | loose |
| Blac Youngsta | Ready | 53 | 61 | 434 | loose |
| Blac Youngsta | Reckless | 77 | 83 | 255 | loose |
| Blac Youngsta | Red Light District | 42 | 43 | 165 | loose |
| Blac Youngsta | Redchuck Red Flag | 42 | 37 | 171 | loose |
| Blac Youngsta | Rent | 26 | 14 | 173 | loose |
| Blac Youngsta | Respect It & All I Had | 44 | 62 | 301 | loose |
| Blac Youngsta | Rich Pleasure | 48 | 47 | 145 | loose |
| Blac Youngsta | Right Now | 38 | 42 | 202 | loose |
| Blac Youngsta | Right There | 33 | 24 | 134 | loose |
| Blac Youngsta | Romantic | 37 | 64 | 350 | loose |
| Blac Youngsta | Run Down | 38 | 46 | 177 | loose |
| Blac Youngsta | Running Schemes | 63 | 64 | 253 | loose |
| Blac Youngsta | STWDK | 57 | 75 | 246 | loose |
| Blac Youngsta | Same Nigga | 25 | 26 | 179 | loose |
| Blac Youngsta | Sauce | 38 | 28 | 82 | loose |
| Blac Youngsta | Saving Money | 40 | 48 | 245 | loose |
| Blac Youngsta | School | 36 | 29 | 134 | loose |
| Blac Youngsta | Set Trip | 16 | 9 | 78 | loose |
| Blac Youngsta | Sex | 37 | 67 | 164 | loose |
| Blac Youngsta | Shake It | 39 | 28 | 223 | loose |
| Blac Youngsta | Shake Sum | 51 | 28 | 229 | loose |
| Blac Youngsta | Shoot Sumn | 15 | 7 | 34 | loose |
| Blac Youngsta | Shoot at Some | 50 | 25 | 293 | loose |
| Blac Youngsta | Shoulders | 49 | 68 | 296 | loose |
| Blac Youngsta | Sidewalk | 55 | 57 | 228 | loose |
| Blac Youngsta | Silent | 33 | 30 | 196 | loose |
| Blac Youngsta | Simon Says | 47 | 47 | 262 | loose |
| Blac Youngsta | Sky’s The Limit | 38 | 34 | 162 | loose |
| Blac Youngsta | Sleep | 57 | 119 | 356 | loose |
| Blac Youngsta | Slide On Em | 44 | 39 | 227 | loose |
| Blac Youngsta | Smash On Em | 29 | 34 | 165 | loose |
| Blac Youngsta | Smell The Hate | 48 | 55 | 181 | loose |
| Blac Youngsta | So What | 38 | 23 | 155 | loose |
| Blac Youngsta | Soldier | 30 | 11 | 112 | loose |
| Blac Youngsta | Solo | 30 | 33 | 221 | loose |
| Blac Youngsta | Start A Fire | 69 | 50 | 284 | loose |
| Blac Youngsta | Steppers | 65 | 68 | 467 | loose |
| Blac Youngsta | Steppin | 71 | 72 | 300 | loose |
| Blac Youngsta | Still | 32 | 54 | 173 | loose |
| Blac Youngsta | Stop Sign | 65 | 60 | 278 | loose |
| Blac Youngsta | Strapped | 50 | 47 | 206 | loose |
| Blac Youngsta | Streets | 60 | 81 | 256 | loose |
| Blac Youngsta | Suicide | 42 | 36 | 253 | loose |
| Blac Youngsta | Sumn | 58 | 30 | 243 | loose |
| Blac Youngsta | Sunset | 41 | 28 | 200 | loose |
| Blac Youngsta | Super Hot | 29 | 44 | 217 | loose |
| Blac Youngsta | Supposed to Be | 37 | 24 | 176 | loose |
| Blac Youngsta | Survive | 33 | 48 | 128 | loose |
| Blac Youngsta | Swear to God | 8 | 10 | 52 | loose |
| Blac Youngsta | Thank God | 53 | 46 | 234 | loose |
| Blac Youngsta | Thin Line | 37 | 46 | 201 | loose |
| Blac Youngsta | Throw It (Cash Up) | 73 | 61 | 238 | loose |
| Blac Youngsta | Thug Holiday | 32 | 16 | 114 | loose |
| Blac Youngsta | Tissue | 45 | 42 | 97 | loose |
| Blac Youngsta | Too Much Power | 51 | 78 | 377 | loose |
| Blac Youngsta | Too Unique | 43 | 104 | 381 | loose |
| Blac Youngsta | Trench Bitch | 35 | 40 | 303 | loose |
| Blac Youngsta | Trickin Ass Nigga | 37 | 41 | 206 | loose |
| Blac Youngsta | Tru Colors | 42 | 38 | 279 | loose |
| Blac Youngsta | True Story | 51 | 63 | 212 | loose |
| Blac Youngsta | Truth Be Told | 55 | 47 | 388 | loose |
| Blac Youngsta | Tryna Relax | 32 | 42 | 301 | loose |
| Blac Youngsta | Uh Uh | 35 | 21 | 129 | loose |
| Blac Youngsta | Uncut | 75 | 62 | 444 | loose |
| Blac Youngsta | Understand | 35 | 8 | 91 | loose |
| Blac Youngsta | Venting | 61 | 78 | 270 | loose |
| Blac Youngsta | Vote | 32 | 72 | 184 | AAAA |
| Blac Youngsta | Wait For It | 28 | 23 | 233 | loose |
| Blac Youngsta | Wait In Line | 35 | 29 | 261 | loose |
| Blac Youngsta | War Ready | 31 | 35 | 173 | loose |
| Blac Youngsta | Way Before | 47 | 60 | 314 | loose |
| Blac Youngsta | We Don’t Play That | 58 | 53 | 187 | loose |
| Blac Youngsta | We Kept the Receipts | 34 | 38 | 202 | loose |
| Blac Youngsta | What’s Next | 34 | 60 | 160 | loose |
| Blac Youngsta | When I Want | 35 | 14 | 308 | loose |
| Blac Youngsta | Where They Do That | 36 | 41 | 300 | loose |
| Blac Youngsta | Where You Going | 63 | 33 | 312 | loose |
| Blac Youngsta | Whippin’ | 40 | 30 | 203 | loose |
| Blac Youngsta | Whisper | 54 | 72 | 298 | loose |
| Blac Youngsta | Who Am I | 48 | 66 | 403 | loose |
| Blac Youngsta | Who Run It (Remix) | 107 | 106 | 376 | loose |
| Blac Youngsta | Who’s Real & Shit A Trip | 42 | 79 | 427 | loose |
| Blac Youngsta | Wishy Washy | 41 | 74 | 426 | loose |
| Blac Youngsta | With It | 58 | 34 | 158 | loose |
| Blac Youngsta | Woozy | 47 | 23 | 115 | loose |
| Blac Youngsta | You Can See | 64 | 75 | 328 | loose |
| Blac Youngsta | Youngsta | 64 | 62 | 264 | loose |
| Blac Youngsta | coordinate | 40 | 16 | 154 | loose |
