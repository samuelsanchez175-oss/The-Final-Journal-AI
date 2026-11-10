# Veeze rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Veeze
- Songs: 220
- Bars kept (Veeze lyric lines): 9373
- Section headers dropped, not counted as bars: 1
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 12
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 10
- Canonical name: Veeze.
- Credit strings: Veeze.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 82322
- REPEAT pairs, recorded separately: 6610
- END rhymes: 11320
- INNER rhymes: 71002

By match:

- PERFECT: 5167 (END 980, INNER 4187)
- SLANT: 35816 (END 4524, INNER 31292)
- ASSONANCE: 40929 (END 5673, INNER 35256)
- MULTI: 410 (END 143, INNER 267)

By confidence:

- HIGH: 5177
- MED: 71733
- LOW: 5412

## Core

- Core Y: 81192
- Core N among rhyme pairs: 1130

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 36307 (44.1%)
- vowel: 40929 (49.7%)
- spelling: 4676 (5.7%)
- multi: 410 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 2 songs
- loose: 218 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 7054 pairs (END 881, INNER 6173). Words: bitch, think, shit, bitches, lil, sippin, still, him.
2. `vow:OW` — 5250 pairs (END 527, INNER 4723). Words: don't, no, know, go, ho, broke, told, hoes.
3. `vow:EY` — 4697 pairs (END 760, INNER 3937). Words: ain't, say, day, play, make, take, way, pay.
4. `vow:AE` — 4584 pairs (END 716, INNER 3868). Words: can't, back, ass, man, had, havin, bag, have.
5. `vow:EH` — 4265 pairs (END 511, INNER 3754). Words: get, gettin, when, never, every, head, tell, best.
6. `vow:AA` — 3470 pairs (END 457, INNER 3013). Words: got, want, talkin, nothin, wanna, hard, not, gotta.
7. `vow:AH` — 3414 pairs (END 535, INNER 2879). Words: fuck, hundred, money, fuckin, somethin, fucked, some, love.
8. `vow:IY` — 3173 pairs (END 337, INNER 2836). Words: even, see, these, need, free, three, feel, keep.
9. `vow:AY` — 2547 pairs (END 279, INNER 2268). Words: like, why, buy, high, by, pint, time, try.
10. `slant:IH:stop` — 2003 pairs (END 193, INNER 1810). Words: nigga, shit, hit, big, city, brick, kid, whip.
11. `slant:AA:stop` — 1802 pairs (END 122, INNER 1680). Words: got, gotta, want, pop, not, block, drop, body.
12. `slant:IH:sib-stop` — 1540 pairs (END 144, INNER 1396). Words: bitch, shit, nigga, niggas, hit, rich, big, switch.
13. `slant:IH:liq-stop` — 1119 pairs (END 53, INNER 1066). Words: shit, lil, still, really, hit, big, near, kill.
14. `slant:AH:nas-stop` — 1078 pairs (END 86, INNER 992). Words: fuck, money, one, some, what, come, done, young.
15. `slant:AE:stop` — 1018 pairs (END 202, INNER 816). Words: back, can't, bag, had, bad, mad, act, hat.
16. `slant:EH:stop` — 967 pairs (END 143, INNER 824). Words: get, better, head, said, let, check, neck, red.
17. `cmu:OW` — 944 pairs (END 56, INNER 888). Words: no, know, go, ho, bro, show, though, throw.
18. `slant:AE:nas-stop` — 937 pairs (END 86, INNER 851). Words: man, can, back, can't, bag, damn, gang, had.
19. `slant:IH:liq-sib` — 846 pairs (END 22, INNER 824). Words: bitch, lil, still, really, rich, near, kill, pill.
20. `slant:AY:stop` — 833 pairs (END 31, INNER 802). Words: like, might, white, right, inside, type, night, tried.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 1371 pair sides, mostly spelling via spelling phonetic key, often with shit (354)
- niggas — 482 pair sides, mostly spelling via spelling phonetic key, often with nigga (306)
- ima — 427 pair sides, mostly spelling via spelling phonetic key, often with bitch (73)
- gon — 338 pair sides, mostly spelling via spelling phonetic key, often with dont (84)
- tryna — 278 pair sides, mostly spelling via spelling phonetic key, often with these (28)
- veeze — 108 pair sides, mostly spelling via spelling phonetic key, often with these (9)
- wock — 90 pair sides, mostly spelling via spelling phonetic key, often with dont (15)
- swag — 80 pair sides, mostly spelling via spelling phonetic key, often with cant (5)
- tris — 71 pair sides, mostly spelling via spelling phonetic key, often with bitch (8)
- cuz — 61 pair sides, mostly spelling via spelling phonetic key, often with some (7)
- shawty — 41 pair sides, mostly vowel via spelling phonetic key, often with all (4)
- blicky — 40 pair sides, mostly spelling via spelling phonetic key, often with nigga (8)
- opps — 37 pair sides, mostly vowel via spelling phonetic key, often with know (12)
- shiesty — 32 pair sides, mostly vowel via spelling phonetic key, often with free (3)
- meds — 32 pair sides, mostly spelling via spelling phonetic key, often with head (4)
- thot — 31 pair sides, mostly spelling via spelling phonetic key, often with dont (4)
- geeked — 31 pair sides, mostly spelling via spelling phonetic key, often with even (4)
- lik — 30 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)
- prolly — 28 pair sides, mostly vowel via spelling phonetic key, often with nobody (8)
- lyin — 28 pair sides, mostly spelling via spelling phonetic key, often with who (2)
- switchy — 25 pair sides, mostly spelling via spelling phonetic key, often with bitch (7)
- wocky — 24 pair sides, mostly vowel via spelling phonetic key, often with body (2)
- rari — 23 pair sides, mostly spelling via spelling phonetic key, often with grass (2)
- pissy — 23 pair sides, mostly vowel via spelling phonetic key, often with bitches (3)
- pics — 22 pair sides, mostly vowel via spelling phonetic key, often with bitch (5)
- slatt — 22 pair sides, mostly vowel via spelling phonetic key, often with half (3)
- finna — 19 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- bruh — 18 pair sides, mostly spelling via spelling phonetic key, often with club (1)
- spital — 18 pair sides, mostly spelling via spelling phonetic key, often with lil (3)
- titty — 18 pair sides, mostly vowel via spelling phonetic key, often with baby (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Veeze | 12 Before 12 | 47 | 65 | 370 | loose |
| Veeze | 2 (Brent Swish) | 7 | 2 | 21 | loose |
| Veeze | 2am In 4sho | 48 | 58 | 372 | loose |
| Veeze | 36 Bows | 51 | 58 | 299 | loose |
| Veeze | 4 Kobe | 41 | 54 | 310 | loose |
| Veeze | 4 MY | 41 | 39 | 351 | loose |
| Veeze | 441 Navy Lane | 21 | 20 | 121 | loose |
| Veeze | 5.Am | 32 | 50 | 153 | loose |
| Veeze | 5Star | 33 | 17 | 312 | loose |
| Veeze | 6am Freestyle (Remix) | 74 | 89 | 516 | loose |
| Veeze | 700 Degrees | 40 | 45 | 333 | loose |
| Veeze | 777 | 54 | 63 | 364 | loose |
| Veeze | 7sixers | 47 | 29 | 412 | loose |
| Veeze | A Town Love | 25 | 28 | 174 | loose |
| Veeze | A and W | 33 | 40 | 277 | loose |
| Veeze | ALL THE SAME | 53 | 30 | 228 | loose |
| Veeze | ATL Freestyle 1 | 45 | 67 | 462 | loose |
| Veeze | ATL Freestyle 2 | 49 | 42 | 365 | loose |
| Veeze | All Blues | 13 | 24 | 128 | loose |
| Veeze | All Brown | 35 | 41 | 213 | loose |
| Veeze | Amusing | 55 | 54 | 409 | loose |
| Veeze | Ball Brothers | 46 | 92 | 393 | loose |
| Veeze | Big Body | 42 | 66 | 314 | loose |
| Veeze | Big Dawg | 33 | 18 | 225 | loose |
| Veeze | Big Draco | 31 | 30 | 111 | loose |
| Veeze | Billion | 48 | 45 | 397 | loose |
| Veeze | BirdMan | 52 | 49 | 184 | loose |
| Veeze | Block | 64 | 42 | 281 | loose |
| Veeze | Boat Interlude | 40 | 69 | 313 | loose |
| Veeze | Bodily Harm | 57 | 39 | 397 | loose |
| Veeze | Bosses Linking With Bosses | 43 | 63 | 265 | loose |
| Veeze | Bottega | 40 | 33 | 84 | loose |
| Veeze | Broke phone | 64 | 39 | 407 | loose |
| Veeze | Brothers Only | 53 | 41 | 476 | loose |
| Veeze | Bruce Wayne Coupe | 52 | 24 | 361 | loose |
| Veeze | Burberry | 49 | 86 | 495 | loose |
| Veeze | Business N Percents | 31 | 58 | 235 | loose |
| Veeze | CDL | 32 | 44 | 231 | loose |
| Veeze | Can U Hear Me | 37 | 37 | 170 | loose |
| Veeze | Can’t Be Crete Boy | 67 | 97 | 561 | loose |
| Veeze | Can’t Be Veeze | 14 | 9 | 131 | loose |
| Veeze | Choppas In Hawaii | 30 | 69 | 267 | loose |
| Veeze | Chosen | 26 | 54 | 197 | loose |
| Veeze | Close Friends | 49 | 67 | 500 | loose |
| Veeze | Cop Vs. Cat | 49 | 81 | 197 | loose |
| Veeze | DOTTED LINE | 50 | 35 | 367 | loose |
| Veeze | Daisy Navy | 30 | 28 | 165 | loose |
| Veeze | Designer Bagz | 41 | 29 | 289 | loose |
| Veeze | Dirty Soda Junkie | 32 | 47 | 421 | loose |
| Veeze | Domestic | 38 | 60 | 387 | loose |
| Veeze | Done Witchu | 45 | 56 | 392 | loose |
| Veeze | Don’t Even Bother | 35 | 57 | 303 | loose |
| Veeze | Drankhead | 43 | 42 | 252 | loose |
| Veeze | Drug Habits | 30 | 28 | 211 | loose |
| Veeze | Drug Ring | 37 | 49 | 308 | loose |
| Veeze | Eminem | 30 | 42 | 307 | loose |
| Veeze | Everlasting Bass / Blue Hundreds* | 44 | 84 | 461 | loose |
| Veeze | Exotics | 32 | 34 | 122 | loose |
| Veeze | FAKE LOVE | 47 | 38 | 341 | loose |
| Veeze | Fat Albert | 56 | 71 | 415 | loose |
| Veeze | Fight Night Round 3 | 60 | 78 | 432 | loose |
| Veeze | Fingers Crossed | 45 | 53 | 261 | loose |
| Veeze | Flamie Foxx | 34 | 38 | 237 | loose |
| Veeze | For The Record | 47 | 67 | 404 | loose |
| Veeze | Free Peezy (Last Forever) | 19 | 12 | 151 | loose |
| Veeze | Free Ralo | 32 | 55 | 237 | loose |
| Veeze | Free Shiest | 33 | 43 | 293 | loose |
| Veeze | Fuck the Bank | 40 | 43 | 228 | loose |
| Veeze | Fucked A Fan | 64 | 101 | 589 | loose |
| Veeze | GAIG | 35 | 39 | 259 | loose |
| Veeze | GOMD | 43 | 62 | 393 | loose |
| Veeze | GTA | 47 | 73 | 338 | loose |
| Veeze | Gallery Dept | 44 | 42 | 304 | loose |
| Veeze | Gangermatic | 52 | 52 | 378 | loose |
| Veeze | Gerskiway | 44 | 39 | 494 | loose |
| Veeze | Get Along | 68 | 90 | 294 | loose |
| Veeze | Get Lucki | 48 | 45 | 474 | loose |
| Veeze | God Hands II | 49 | 92 | 258 | loose |
| Veeze | Good Eats | 66 | 84 | 220 | loose |
| Veeze | Goodluck | 17 | 14 | 167 | loose |
| Veeze | Grandma’s Baby | 42 | 53 | 250 | loose |
| Veeze | HUSTLER$ CLUB | 37 | 50 | 221 | loose |
| Veeze | Half & Half | 63 | 98 | 379 | loose |
| Veeze | Half Sleep | 48 | 69 | 406 | loose |
| Veeze | Hall of Fame | 43 | 85 | 302 | loose |
| Veeze | Heart Cold | 36 | 48 | 139 | loose |
| Veeze | Heart Insurance | 36 | 30 | 334 | loose |
| Veeze | Hitler | 40 | 81 | 327 | loose |
| Veeze | How Tf I’m Rookie | 30 | 34 | 162 | loose |
| Veeze | IDK | 40 | 24 | 340 | loose |
| Veeze | Ians The Devil | 51 | 41 | 505 | loose |
| Veeze | Idols | 48 | 87 | 460 | loose |
| Veeze | Intro (Back To The Bando) | 50 | 60 | 428 | loose |
| Veeze | Itself | 48 | 121 | 381 | AAAA |
| Veeze | I’m Snake | 30 | 38 | 177 | loose |
| Veeze | JAPANESE DENIM | 31 | 21 | 269 | loose |
| Veeze | Jason Brother | 37 | 26 | 252 | loose |
| Veeze | Kinda $ | 37 | 41 | 381 | loose |
| Veeze | Kount Ya Hat | 45 | 38 | 427 | loose |
| Veeze | Kurt Angle | 26 | 26 | 183 | loose |
| Veeze | L.O.A.T | 43 | 40 | 512 | loose |
| Veeze | LICK | 36 | 49 | 275 | loose |
| Veeze | Law N Order | 35 | 41 | 386 | loose |
| Veeze | Listen to me | 57 | 70 | 464 | loose |
| Veeze | Little | 33 | 30 | 309 | loose |
| Veeze | Living For Today | 35 | 67 | 212 | loose |
| Veeze | Loc Dawg | 33 | 25 | 209 | loose |
| Veeze | Long Live | 26 | 27 | 169 | loose |
| Veeze | Lose it all today | 56 | 70 | 436 | loose |
| Veeze | Luv the Tour | 41 | 50 | 318 | loose |
| Veeze | ME N MY DRANK | 42 | 50 | 378 | loose |
| Veeze | Making a Mess | 57 | 110 | 403 | loose |
| Veeze | Malice in the Palace | 48 | 47 | 449 | loose |
| Veeze | Marilyn Manson | 30 | 29 | 285 | loose |
| Veeze | Meg The Stallion | 51 | 41 | 449 | loose |
| Veeze | Miami (Pop It) | 46 | 67 | 344 | loose |
| Veeze | Millions | 52 | 65 | 490 | loose |
| Veeze | Mojo Jojo | 36 | 79 | 358 | loose |
| Veeze | Move Heavy | 42 | 57 | 226 | loose |
| Veeze | My Love | 64 | 58 | 520 | loose |
| Veeze | NCAA | 36 | 76 | 327 | loose |
| Veeze | New Clothes | 40 | 28 | 290 | loose |
| Veeze | No Membership | 47 | 61 | 411 | loose |
| Veeze | No Sir Ski | 45 | 63 | 386 | loose |
| Veeze | No Stars in Maybachs | 46 | 38 | 413 | loose |
| Veeze | Not Da 2 | 12 | 11 | 87 | loose |
| Veeze | Not a Drill | 69 | 55 | 546 | loose |
| Veeze | Nothin’ | 40 | 38 | 248 | loose |
| Veeze | Numb | 40 | 27 | 378 | loose |
| Veeze | ONE TIME | 97 | 113 | 664 | loose |
| Veeze | OUT RAP US (Crete x CBFW) | 45 | 57 | 437 | loose |
| Veeze | OUTRO | 88 | 76 | 511 | loose |
| Veeze | Oink Up | 52 | 63 | 323 | loose |
| Veeze | Old Heads | 35 | 22 | 378 | loose |
| Veeze | Old Shit | 43 | 35 | 458 | loose |
| Veeze | One Of Them Ones | 62 | 74 | 373 | loose |
| Veeze | Open The Door | 25 | 56 | 287 | AAAA |
| Veeze | OverseasBaller | 36 | 48 | 274 | loose |
| Veeze | PELLE PELLE | 27 | 34 | 164 | loose |
| Veeze | PETTY AND SELFISH | 46 | 77 | 605 | loose |
| Veeze | PPP | 40 | 59 | 239 | loose |
| Veeze | Painting Pictures | 51 | 65 | 266 | loose |
| Veeze | Pop Shit | 58 | 90 | 341 | loose |
| Veeze | Pop Yo Shit | 36 | 30 | 422 | loose |
| Veeze | Postman | 21 | 34 | 299 | loose |
| Veeze | Purest Form | 37 | 48 | 387 | loose |
| Veeze | RIP Blade | 43 | 41 | 367 | loose |
| Veeze | Rapper | 37 | 59 | 275 | loose |
| Veeze | Red Key | 46 | 51 | 222 | loose |
| Veeze | Rich No Duh | 41 | 102 | 296 | loose |
| Veeze | Rich Rockstar | 27 | 22 | 225 | loose |
| Veeze | Right Key | 48 | 68 | 445 | loose |
| Veeze | Robert De Niro | 39 | 80 | 285 | loose |
| Veeze | Rocafella | 32 | 25 | 195 | loose |
| Veeze | Run Down | 95 | 125 | 708 | loose |
| Veeze | Runnin’ Out | 42 | 69 | 259 | loose |
| Veeze | Rusty | 37 | 55 | 292 | loose |
| Veeze | S680 | 36 | 42 | 315 | loose |
| Veeze | SEXY Liar | 29 | 33 | 238 | loose |
| Veeze | Safe 2 | 27 | 39 | 451 | loose |
| Veeze | Sell Me A Dream / I Don’t Know | 48 | 52 | 484 | loose |
| Veeze | Shit Show | 36 | 56 | 317 | loose |
| Veeze | Signed A Napkin | 57 | 34 | 395 | loose |
| Veeze | Silly Rabbit | 22 | 45 | 239 | loose |
| Veeze | Sker Friend | 32 | 32 | 97 | loose |
| Veeze | Skittle Head | 54 | 57 | 385 | loose |
| Veeze | Slatt School | 63 | 89 | 363 | loose |
| Veeze | Sleep Walking | 31 | 79 | 261 | loose |
| Veeze | Sleep Walking Pt.3 | 29 | 26 | 172 | loose |
| Veeze | Slide Alone | 24 | 26 | 281 | loose |
| Veeze | Slime | 20 | 32 | 132 | loose |
| Veeze | Slow Down | 48 | 54 | 394 | loose |
| Veeze | Small Fry | 46 | 79 | 304 | loose |
| Veeze | Sorry Not Sorry | 61 | 68 | 448 | loose |
| Veeze | Spending Spree | 53 | 57 | 590 | loose |
| Veeze | Starter Kit | 32 | 35 | 305 | loose |
| Veeze | Steppin On My Crack Heads | 32 | 57 | 206 | loose |
| Veeze | Still Grinding | 33 | 37 | 366 | loose |
| Veeze | Still Tippin | 49 | 35 | 231 | loose |
| Veeze | Stop Tagging Us | 45 | 75 | 392 | loose |
| Veeze | Store Runner | 37 | 53 | 279 | loose |
| Veeze | Switching Gears | 32 | 65 | 373 | loose |
| Veeze | TWIN FLOW | 43 | 38 | 333 | loose |
| Veeze | Talk To Em | 44 | 36 | 268 | loose |
| Veeze | Teach You | 33 | 23 | 180 | loose |
| Veeze | Tesla Pill | 39 | 22 | 341 | loose |
| Veeze | This That One | 79 | 93 | 499 | loose |
| Veeze | Time Tell All | 54 | 103 | 298 | loose |
| Veeze | Tony Hawk | 20 | 14 | 252 | loose |
| Veeze | Tremendous | 31 | 32 | 332 | loose |
| Veeze | Twin Flow/Godfather II | 45 | 24 | 308 | loose |
| Veeze | U Need? | 35 | 10 | 186 | loose |
| Veeze | U-Digg | 59 | 64 | 764 | loose |
| Veeze | Unreleased leak | 66 | 117 | 537 | loose |
| Veeze | Untitled (Ouu Ouu) | 74 | 89 | 397 | loose |
| Veeze | V Cut | 34 | 41 | 135 | loose |
| Veeze | Veeze May 7 V2 (Unfinished) | 18 | 11 | 188 | loose |
| Veeze | Vibe | 55 | 52 | 184 | loose |
| Veeze | WHOda1 | 43 | 47 | 359 | loose |
| Veeze | WURDALAK* | 3 | 0 | 2 | loose |
| Veeze | Wavy Navy University | 60 | 69 | 360 | loose |
| Veeze | We Did It (Remix) | 34 | 50 | 259 | loose |
| Veeze | We Rich | 42 | 85 | 297 | loose |
| Veeze | Wedding Cake | 42 | 39 | 474 | loose |
| Veeze | Weekend | 59 | 74 | 332 | loose |
| Veeze | What You Telling Me | 35 | 60 | 201 | loose |
| Veeze | WhiteHouse, Vol. 2 | 45 | 59 | 194 | loose |
| Veeze | Who Is That? | 44 | 39 | 231 | loose |
| Veeze | Wholeworldslatt | 77 | 64 | 444 | loose |
| Veeze | Will Bill | 23 | 19 | 207 | loose |
| Veeze | Wilt | 38 | 60 | 277 | loose |
| Veeze | Wocky Sinner | 47 | 48 | 443 | loose |
| Veeze | Worst | 42 | 48 | 269 | loose |
| Veeze | Wrong Place, Wrong time | 58 | 61 | 590 | loose |
| Veeze | Yea Yea | 46 | 48 | 354 | loose |
| Veeze | Yoa Twin | 40 | 47 | 277 | loose |
| Veeze | You know i | 51 | 22 | 353 | loose |
| Veeze | duh duh duh | 41 | 44 | 132 | loose |
| Veeze | let it fly | 42 | 35 | 226 | loose |
| Veeze | tramp Stamp | 44 | 69 | 369 | loose |
