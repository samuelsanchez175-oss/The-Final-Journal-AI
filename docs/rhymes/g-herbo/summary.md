# G Herbo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: G Herbo
- Songs: 440
- Bars kept (G Herbo lyric lines): 21896
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 20
- Canonical name: G Herbo.
- Credit strings: G Herbo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 176500
- REPEAT pairs, recorded separately: 20135
- END rhymes: 27771
- INNER rhymes: 148729

By match:

- PERFECT: 16925 (END 4932, INNER 11993)
- SLANT: 74735 (END 11823, INNER 62912)
- ASSONANCE: 82907 (END 10450, INNER 72457)
- MULTI: 1933 (END 566, INNER 1367)

By confidence:

- HIGH: 17357
- MED: 148833
- LOW: 10310

## Core

- Core Y: 173951
- Core N among rhyme pairs: 2549

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 82545 (46.8%)
- vowel: 82907 (47.0%)
- spelling: 9115 (5.2%)
- multi: 1933 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 10 songs
- loose: 430 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 12779 pairs (END 1435, INNER 11344). Words: shit, bitch, bitches, still, think, lil, him, since.
2. `vow:OW` — 11009 pairs (END 1036, INNER 9973). Words: don't, know, no, go, told, only, hoes, over.
3. `vow:EY` — 10481 pairs (END 1221, INNER 9260). Words: ain't, way, say, day, make, stay, made, play.
4. `vow:EH` — 9707 pairs (END 883, INNER 8824). Words: get, when, never, gettin, went, remember, left, let.
5. `vow:AE` — 8105 pairs (END 1333, INNER 6772). Words: can't, back, had, man, last, have, after, havin.
6. `vow:AA` — 6916 pairs (END 700, INNER 6216). Words: got, nothin, want, wasn't, gotta, hard, block, not.
7. `vow:AH` — 6570 pairs (END 1054, INNER 5516). Words: fuck, hundred, some, what, nothing, love, money, somethin.
8. `vow:IY` — 6536 pairs (END 852, INNER 5684). Words: see, even, streets, g, these, need, keep, real.
9. `vow:AY` — 5772 pairs (END 897, INNER 4875). Words: like, why, by, high, time, die, right, try.
10. `slant:AA:stop` — 4514 pairs (END 537, INNER 3977). Words: got, gotta, block, not, want, glock, top, stop.
11. `slant:IH:stop` — 3745 pairs (END 567, INNER 3178). Words: shit, nigga, hit, big, whip, clip, quick, city.
12. `slant:IH:sib-stop` — 3151 pairs (END 653, INNER 2498). Words: bitch, shit, niggas, nigga, rich, hit, big, switch.
13. `slant:IH:liq-stop` — 2545 pairs (END 93, INNER 2452). Words: shit, still, lil, really, hit, big, kill, 'til.
14. `slant:AE:stop` — 2483 pairs (END 536, INNER 1947). Words: back, had, can't, rap, act, black, bag, bad.
15. `cmu:OW` — 2377 pairs (END 347, INNER 2030). Words: know, no, go, show, though, blow, bro, ho.
16. `slant:EH:stop` — 2271 pairs (END 246, INNER 2025). Words: get, let, better, head, went, said, check, ready.
17. `slant:AH:nas-stop` — 1848 pairs (END 114, INNER 1734). Words: fuck, what, money, some, one, come, run, done.
18. `slant:EH:nas-stop` — 1795 pairs (END 121, INNER 1674). Words: when, get, let, again, gettin, better, any, many.
19. `slant:AY:stop` — 1765 pairs (END 290, INNER 1475). Words: like, right, might, ride, night, side, outside, died.
20. `vow:AO` — 1596 pairs (END 194, INNER 1402). Words: all, lost, saw, more, before, talking, call, ball.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 2249 pair sides, mostly spelling via spelling phonetic key, often with niggas (639)
- niggas — 1134 pair sides, mostly spelling via spelling phonetic key, often with nigga (639)
- gon — 702 pair sides, mostly spelling via spelling phonetic key, often with dont (195)
- ima — 667 pair sides, mostly spelling via spelling phonetic key, often with shit (119)
- tryna — 621 pair sides, mostly spelling via spelling phonetic key, often with these (50)
- herbo — 375 pair sides, mostly vowel via spelling phonetic key, often with know (104)
- raq — 221 pair sides, mostly spelling via spelling phonetic key, often with back (39)
- cuz — 194 pair sides, mostly spelling via spelling phonetic key, often with fuck (20)
- opps — 170 pair sides, mostly vowel via spelling phonetic key, often with dont (52)
- fazo — 122 pair sides, mostly vowel via spelling phonetic key, often with no (11)
- bros — 108 pair sides, mostly spelling via spelling phonetic key, often with know (19)
- glocks — 103 pair sides, mostly vowel via spelling phonetic key, often with know (26)
- foenem — 91 pair sides, mostly spelling via spelling phonetic key, often with dont (20)
- bap — 88 pair sides, mostly spelling via spelling phonetic key, often with man (17)
- finna — 88 pair sides, mostly vowel via spelling phonetic key, often with nigga (24)
- swervo — 87 pair sides, mostly vowel via spelling phonetic key, often with know (18)
- imma — 71 pair sides, mostly vowel via spelling phonetic key, often with nigga (27)
- nem — 71 pair sides, mostly spelling via spelling phonetic key, often with foenem (16)
- glizzy — 68 pair sides, mostly vowel via spelling phonetic key, often with bitch (4)
- coulda — 66 pair sides, mostly multi via spelling phonetic key, often with shoulda (31)
- swag — 65 pair sides, mostly spelling via spelling phonetic key, often with bag (8)
- hunnid — 64 pair sides, mostly vowel via spelling phonetic key, often with nothing (9)
- shoulda — 63 pair sides, mostly multi via spelling phonetic key, often with coulda (31)
- dawg — 63 pair sides, mostly spelling via spelling phonetic key, often with all (18)
- woulda — 60 pair sides, mostly multi via spelling phonetic key, often with shoulda (30)
- fam — 53 pair sides, mostly spelling via spelling phonetic key, often with damn (7)
- dolo — 51 pair sides, mostly vowel via spelling phonetic key, often with dont (6)
- chiraq — 51 pair sides, mostly vowel via spelling phonetic key, often with niggas (16)
- weezy — 49 pair sides, mostly spelling via spelling phonetic key, often with breezy (6)
- stuntin — 47 pair sides, mostly spelling via spelling phonetic key, often with nothin (9)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| G Herbo | 05/17/22 | 31 | 26 | 215 | loose |
| G Herbo | 1 Chance | 65 | 86 | 405 | loose |
| G Herbo | 10 More Seasons | 56 | 99 | 388 | loose |
| G Herbo | 100 Days 100 Nights | 42 | 44 | 387 | loose |
| G Herbo | 100 Sticks | 51 | 67 | 231 | loose |
| G Herbo | 2 Chains | 82 | 99 | 671 | loose |
| G Herbo | 23 | 44 | 57 | 98 | loose |
| G Herbo | 2AM | 37 | 73 | 170 | loose |
| G Herbo | 4 Minutes Of Hell, Part 4 | 65 | 79 | 524 | loose |
| G Herbo | 4 Minutes of Hell | 71 | 101 | 576 | loose |
| G Herbo | 4 Minutes of Hell Part 2 | 97 | 78 | 759 | loose |
| G Herbo | 4 Minutes of Hell, Part 3 | 119 | 141 | 504 | loose |
| G Herbo | 4 Minutes of Hell, Pt. 5 | 123 | 164 | 622 | loose |
| G Herbo | 4 Minutes of Hell, Pt. 6 | 72 | 98 | 762 | loose |
| G Herbo | 4 Nem | 41 | 32 | 240 | loose |
| G Herbo | 4am to 8am | 64 | 88 | 473 | loose |
| G Herbo | 7 Rings | 23 | 14 | 145 | loose |
| G Herbo | 91111111 | 28 | 31 | 216 | loose |
| G Herbo | A Year Ago | 64 | 100 | 538 | loose |
| G Herbo | Actions | 59 | 58 | 297 | loose |
| G Herbo | After That | 34 | 81 | 450 | loose |
| G Herbo | Ain’t Nothing To Me | 39 | 32 | 248 | loose |
| G Herbo | Ain’t Right | 53 | 39 | 266 | loose |
| G Herbo | Ain’t for None | 50 | 43 | 303 | loose |
| G Herbo | All Black | 58 | 109 | 293 | loose |
| G Herbo | All Day | 66 | 66 | 353 | loose |
| G Herbo | All I Got | 57 | 33 | 377 | loose |
| G Herbo | All My Niggaz | 74 | 34 | 341 | loose |
| G Herbo | All That | 29 | 43 | 307 | loose |
| G Herbo | Already Know | 21 | 16 | 154 | loose |
| G Herbo | Another Day | 66 | 67 | 334 | loose |
| G Herbo | Any Other Way | 41 | 62 | 404 | loose |
| G Herbo | At Night | 65 | 41 | 200 | loose |
| G Herbo | At The Light | 48 | 75 | 268 | loose |
| G Herbo | Aye | 48 | 60 | 188 | loose |
| G Herbo | Back On Tour | 64 | 52 | 411 | loose |
| G Herbo | Back at It Pt. 3 | 62 | 63 | 394 | loose |
| G Herbo | Bad Asl | 50 | 54 | 274 | loose |
| G Herbo | Bag | 34 | 78 | 177 | AAAA |
| G Herbo | Ball | 65 | 111 | 430 | loose |
| G Herbo | Because Of You | 40 | 65 | 429 | loose |
| G Herbo | Bi Polar | 72 | 81 | 341 | loose |
| G Herbo | Big Nolimit | 17 | 3 | 83 | loose |
| G Herbo | Bill Gluckman | 56 | 71 | 377 | loose |
| G Herbo | Black | 64 | 62 | 282 | loose |
| G Herbo | Blackin Out | 43 | 61 | 266 | loose |
| G Herbo | Bless The Booth (Freestyle) | 37 | 93 | 249 | AAAA |
| G Herbo | Blitz | 41 | 66 | 284 | loose |
| G Herbo | Blueprint | 38 | 97 | 316 | loose |
| G Herbo | Blues | 37 | 31 | 517 | loose |
| G Herbo | Bonjour | 71 | 116 | 576 | loose |
| G Herbo | Bottom of the Bottom | 57 | 61 | 369 | loose |
| G Herbo | Bought a Tool | 87 | 105 | 482 | loose |
| G Herbo | Boww | 58 | 60 | 261 | loose |
| G Herbo | Boyz In The Hood | 60 | 95 | 393 | loose |
| G Herbo | Break Yoself | 58 | 123 | 487 | loose |
| G Herbo | Breathe Slow | 37 | 47 | 266 | loose |
| G Herbo | Breathing Heavy | 44 | 88 | 330 | loose |
| G Herbo | Bricks and Mansions | 47 | 77 | 415 | loose |
| G Herbo | Brown Skin | 43 | 57 | 118 | loose |
| G Herbo | Bryce Maximus | 42 | 71 | 314 | loose |
| G Herbo | Bug | 59 | 68 | 356 | loose |
| G Herbo | By Any Means | 74 | 80 | 420 | loose |
| G Herbo | Candyman | 50 | 78 | 494 | loose |
| G Herbo | Can’t Sleep | 51 | 52 | 396 | loose |
| G Herbo | Cap Guns | 68 | 139 | 486 | loose |
| G Herbo | Cash Shit | 46 | 26 | 187 | loose |
| G Herbo | Cashin’ | 49 | 29 | 400 | loose |
| G Herbo | Catch Up | 72 | 67 | 311 | loose |
| G Herbo | Change (Gun Shots) | 41 | 72 | 288 | loose |
| G Herbo | Church | 25 | 13 | 142 | loose |
| G Herbo | Clap | 28 | 15 | 194 | loose |
| G Herbo | Cold World | 64 | 109 | 566 | loose |
| G Herbo | Cole Bennett | 46 | 67 | 310 | loose |
| G Herbo | Colossal | 41 | 49 | 421 | loose |
| G Herbo | Computers Freestyle | 80 | 114 | 351 | loose |
| G Herbo | Control | 48 | 55 | 276 | loose |
| G Herbo | Control Me | 32 | 42 | 261 | loose |
| G Herbo | Countin’ 100's | 42 | 31 | 319 | loose |
| G Herbo | Crazy | 53 | 64 | 294 | loose |
| G Herbo | Crazy Soda | 29 | 25 | 63 | loose |
| G Herbo | Crown | 86 | 56 | 754 | loose |
| G Herbo | Cry No More | 52 | 120 | 319 | loose |
| G Herbo | Dark Knight | 37 | 61 | 316 | loose |
| G Herbo | Dat Nigga | 66 | 104 | 604 | loose |
| G Herbo | Death Row | 44 | 36 | 303 | loose |
| G Herbo | Demands | 58 | 80 | 633 | loose |
| G Herbo | Designer | 48 | 54 | 302 | loose |
| G Herbo | Desperate | 36 | 57 | 242 | loose |
| G Herbo | Dinner Time | 75 | 137 | 353 | loose |
| G Herbo | Do U | 66 | 96 | 669 | loose |
| G Herbo | Do What I Wanna | 32 | 34 | 246 | loose |
| G Herbo | Do Yo Sh!t | 75 | 105 | 342 | loose |
| G Herbo | Done for Me | 40 | 59 | 218 | loose |
| G Herbo | Don’t Forget It | 37 | 39 | 237 | loose |
| G Herbo | Don’t Worry | 74 | 94 | 272 | loose |
| G Herbo | Doughboy | 36 | 46 | 405 | loose |
| G Herbo | Down By The River | 65 | 95 | 476 | loose |
| G Herbo | Dreaming | 6 | 4 | 9 | loose |
| G Herbo | Drill | 52 | 65 | 282 | loose |
| G Herbo | Dropout | 56 | 47 | 324 | loose |
| G Herbo | Drunk AF | 38 | 35 | 209 | loose |
| G Herbo | Duffel | 44 | 58 | 482 | loose |
| G Herbo | Dust | 50 | 65 | 273 | loose |
| G Herbo | E.B.K. ( EveryBody Killers) | 14 | 5 | 73 | loose |
| G Herbo | EBK | 37 | 25 | 221 | loose |
| G Herbo | Eastside | 62 | 67 | 375 | loose |
| G Herbo | Eastside Story | 54 | 60 | 291 | loose |
| G Herbo | Ego* | 29 | 17 | 150 | loose |
| G Herbo | Elevator Freestyle | 32 | 28 | 197 | loose |
| G Herbo | Emergency | 49 | 56 | 387 | loose |
| G Herbo | End Of The Tunnel | 57 | 73 | 547 | loose |
| G Herbo | Enemies | 5 | 1 | 25 | loose |
| G Herbo | Essence | 29 | 32 | 254 | loose |
| G Herbo | Every Night | 27 | 79 | 221 | AAAA |
| G Herbo | Everyday | 31 | 38 | 258 | loose |
| G Herbo | Everyday in Chicago | 46 | 36 | 257 | loose |
| G Herbo | Everything | 39 | 23 | 225 | loose |
| G Herbo | FWM | 49 | 51 | 350 | loose |
| G Herbo | Fallen Soldiers | 61 | 85 | 544 | loose |
| G Herbo | Father’s Day | 44 | 65 | 273 | loose |
| G Herbo | Feel High | 42 | 62 | 150 | loose |
| G Herbo | Feel This | 45 | 73 | 461 | loose |
| G Herbo | Feelings | 79 | 108 | 443 | loose |
| G Herbo | Fight or Flight | 45 | 40 | 210 | loose |
| G Herbo | Flashbacks | 50 | 56 | 364 | loose |
| G Herbo | FoReal | 57 | 53 | 262 | loose |
| G Herbo | Focused | 61 | 44 | 277 | loose |
| G Herbo | Foenem | 6 | 8 | 29 | AAAA |
| G Herbo | For My Niggas* | 7 | 4 | 22 | loose |
| G Herbo | Frankie Lymon | 41 | 73 | 358 | loose |
| G Herbo | Frfr | 38 | 24 | 301 | loose |
| G Herbo | Friends & Foes | 92 | 175 | 479 | loose |
| G Herbo | Fuck It Tho | 42 | 79 | 233 | loose |
| G Herbo | Fuck Opps | 46 | 80 | 448 | loose |
| G Herbo | G Herbo (2017) | Funk Flex | #Freestyle045 | 68 | 94 | 401 | loose |
| G Herbo | G Herbo (2018) | Funk Flex | #Freestyle104 | 54 | 77 | 340 | loose |
| G Herbo | G Herbo (2020) | Funk Flex | #Freestyle146 | 77 | 130 | 631 | loose |
| G Herbo | G Herbo (2021) | Funk Flex | #Freestyle160 | 49 | 60 | 612 | loose |
| G Herbo | GFazos | 40 | 34 | 272 | loose |
| G Herbo | Gang | 81 | 112 | 255 | loose |
| G Herbo | Gangbangin | 38 | 41 | 274 | loose |
| G Herbo | Gangsta’s Cry | 45 | 96 | 356 | loose |
| G Herbo | Gangway | 53 | 65 | 399 | loose |
| G Herbo | Get 2 Bussin | 39 | 74 | 230 | loose |
| G Herbo | Get In Wit Me (Freestyle) | 27 | 25 | 126 | loose |
| G Herbo | Get Real | 26 | 41 | 195 | loose |
| G Herbo | Give It All | 41 | 48 | 267 | loose |
| G Herbo | Glass in the Face | 34 | 43 | 417 | loose |
| G Herbo | Global Spinning | 54 | 75 | 486 | loose |
| G Herbo | Go | 36 | 65 | 354 | loose |
| G Herbo | Go Hard | 13 | 19 | 99 | loose |
| G Herbo | Go Krazy | 43 | 54 | 361 | loose |
| G Herbo | Got Em Sick | 38 | 74 | 289 | loose |
| G Herbo | Gutta | 78 | 153 | 572 | loose |
| G Herbo | Had Nothin’ | 56 | 56 | 292 | loose |
| G Herbo | Hail Mary Remix | 75 | 92 | 331 | loose |
| G Herbo | Hard Top | 36 | 60 | 187 | loose |
| G Herbo | Havin’ Shit | 37 | 20 | 118 | loose |
| G Herbo | Head Right | 35 | 46 | 223 | loose |
| G Herbo | Heaven or Hell | 49 | 54 | 227 | loose |
| G Herbo | Hell N Back | 36 | 38 | 382 | loose |
| G Herbo | Herbo (Intro) | 29 | 22 | 119 | loose |
| G Herbo | Herbovelli | 65 | 50 | 339 | loose |
| G Herbo | High School | 70 | 80 | 474 | loose |
| G Herbo | High Speed | 55 | 40 | 473 | loose |
| G Herbo | Him | 38 | 51 | 244 | loose |
| G Herbo | History | 36 | 38 | 341 | loose |
| G Herbo | Hold Me Down | 58 | 95 | 473 | loose |
| G Herbo | Hold My Hand | 46 | 76 | 406 | loose |
| G Herbo | Honestly | 40 | 39 | 267 | loose |
| G Herbo | Hood Cycle | 95 | 102 | 297 | loose |
| G Herbo | Hood Legends | 94 | 102 | 293 | loose |
| G Herbo | Hoody Hoo | 20 | 29 | 112 | loose |
| G Herbo | Hot Nigga (Remix) | 75 | 82 | 446 | loose |
| G Herbo | How Can I Lose | 87 | 81 | 768 | loose |
| G Herbo | How Could U Hate Me | 61 | 115 | 294 | loose |
| G Herbo | How I Grew Up | 46 | 32 | 214 | loose |
| G Herbo | Huh | 70 | 102 | 452 | loose |
| G Herbo | Humble Beast Intro | 37 | 27 | 357 | loose |
| G Herbo | Hunnit Bands | 56 | 139 | 430 | loose |
| G Herbo | I Belong | 51 | 90 | 207 | loose |
| G Herbo | I Did | 34 | 31 | 342 | loose |
| G Herbo | I Don’t Wanna Die | 39 | 70 | 328 | loose |
| G Herbo | I Got That | 21 | 25 | 42 | loose |
| G Herbo | I Like | 35 | 42 | 299 | loose |
| G Herbo | I Tried | 30 | 76 | 233 | loose |
| G Herbo | I Want It | 69 | 50 | 300 | loose |
| G Herbo | Ima Boss | 49 | 49 | 313 | loose |
| G Herbo | In The A | 67 | 92 | 368 | loose |
| G Herbo | In The Air | 41 | 55 | 227 | loose |
| G Herbo | In This Bitch | 55 | 29 | 428 | loose |
| G Herbo | In a Minute | 63 | 96 | 539 | loose |
| G Herbo | Influence | 81 | 171 | 370 | loose |
| G Herbo | Intro | 64 | 94 | 673 | loose |
| G Herbo | Intuition | 74 | 89 | 463 | loose |
| G Herbo | It’s Something In Me | 42 | 48 | 276 | loose |
| G Herbo | Izzo Freestyle | 46 | 70 | 364 | loose |
| G Herbo | I’m A Boss (Freestyle) | 61 | 39 | 388 | loose |
| G Herbo | I’m Back | 24 | 24 | 144 | loose |
| G Herbo | Jay-Z (Outro) | 41 | 39 | 255 | loose |
| G Herbo | Jugghouse | 32 | 6 | 162 | loose |
| G Herbo | Just Bars | 99 | 135 | 539 | loose |
| G Herbo | Just Bars 2 | 65 | 49 | 543 | loose |
| G Herbo | Just a Nigga | 48 | 49 | 405 | loose |
| G Herbo | K104 Freestyle | 16 | 10 | 67 | loose |
| G Herbo | Kill Shit | 86 | 92 | 554 | loose |
| G Herbo | Know Me | 45 | 55 | 266 | loose |
| G Herbo | Knucklehead | 38 | 48 | 307 | loose |
| G Herbo | Koolin | 55 | 58 | 315 | loose |
| G Herbo | Krack Flow | 40 | 27 | 389 | loose |
| G Herbo | Lawyer Fees | 67 | 106 | 346 | loose |
| G Herbo | Legend | 50 | 58 | 299 | loose |
| G Herbo | Letter | 94 | 182 | 585 | loose |
| G Herbo | Letter To Juice | 75 | 36 | 438 | loose |
| G Herbo | Letter to My Love | 36 | 46 | 331 | loose |
| G Herbo | Let’s Get It | 56 | 47 | 223 | loose |
| G Herbo | Like This | 73 | 75 | 368 | loose |
| G Herbo | Lil Gangbangin Ass | 46 | 60 | 182 | loose |
| G Herbo | Lil Herb Freestyle (Ether Flow) | 22 | 10 | 244 | loose |
| G Herbo | Lil Herb x Hollow x Lil Smoke “Money” | 46 | 66 | 330 | loose |
| G Herbo | Lil Ride | 75 | 84 | 710 | loose |
| G Herbo | Lionhearted | 29 | 46 | 185 | loose |
| G Herbo | Locked In | 58 | 97 | 376 | loose |
| G Herbo | Longevity | 52 | 104 | 633 | loose |
| G Herbo | Lord Knows | 57 | 51 | 251 | loose |
| G Herbo | Love 2 Stunt | 104 | 117 | 437 | loose |
| G Herbo | Loyalty | 27 | 57 | 183 | loose |
| G Herbo | L’s | 47 | 54 | 188 | loose |
| G Herbo | Machines | 58 | 46 | 444 | loose |
| G Herbo | Mad People | 36 | 43 | 188 | loose |
| G Herbo | Malcolm | 79 | 86 | 573 | loose |
| G Herbo | Mamma I’m Sorry | 44 | 48 | 253 | loose |
| G Herbo | Man Down | 67 | 47 | 409 | loose |
| G Herbo | Man Now | 43 | 56 | 316 | loose |
| G Herbo | Mansion Flow | 4 | 0 | 11 | loose |
| G Herbo | Many Men (Freestyle) | 49 | 43 | 332 | loose |
| G Herbo | Me, Myself & I | 48 | 86 | 271 | loose |
| G Herbo | Mirror | 89 | 88 | 479 | loose |
| G Herbo | Missin Em All | 27 | 49 | 272 | loose |
| G Herbo | Money | 46 | 43 | 249 | loose |
| G Herbo | Mufucka | 30 | 50 | 153 | loose |
| G Herbo | My Baby | 59 | 97 | 271 | loose |
| G Herbo | My Bro’s a Legend | 32 | 71 | 199 | loose |
| G Herbo | My City | 27 | 21 | 145 | loose |
| G Herbo | My Soul | 38 | 46 | 430 | loose |
| G Herbo | My Time | 41 | 64 | 289 | loose |
| G Herbo | My Way | 41 | 74 | 237 | loose |
| G Herbo | Neva Going Back | 28 | 65 | 372 | loose |
| G Herbo | Never Cared | 57 | 109 | 456 | loose |
| G Herbo | Never Going Back (Pandemic Money) | 77 | 116 | 509 | loose |
| G Herbo | Never Scared | 36 | 49 | 509 | loose |
| G Herbo | Next Up | 66 | 91 | 332 | loose |
| G Herbo | Nightmares On Essex | 26 | 21 | 258 | loose |
| G Herbo | No Bap | 49 | 64 | 381 | loose |
| G Herbo | No Depression | 49 | 45 | 428 | loose |
| G Herbo | No Guts, No Glory | 51 | 115 | 412 | loose |
| G Herbo | No Jail Time | 49 | 46 | 491 | loose |
| G Herbo | No Limit | 66 | 34 | 332 | loose |
| G Herbo | No Limit Niggas | 69 | 64 | 428 | loose |
| G Herbo | No Mercy | 36 | 31 | 261 | loose |
| G Herbo | No Passes | 49 | 42 | 328 | loose |
| G Herbo | No Pics | 44 | 41 | 383 | loose |
| G Herbo | No Way Out | 46 | 41 | 320 | loose |
| G Herbo | Nonchalant | 38 | 37 | 210 | loose |
| G Herbo | Norfolk | 44 | 51 | 239 | loose |
| G Herbo | Nothin | 37 | 59 | 233 | loose |
| G Herbo | Nothing At All | 26 | 28 | 160 | loose |
| G Herbo | O.W.D. | 35 | 56 | 275 | loose |
| G Herbo | OFNG | 78 | 107 | 323 | loose |
| G Herbo | October Thoughts | 41 | 82 | 469 | loose |
| G Herbo | Off Days | 37 | 72 | 407 | loose |
| G Herbo | Ok | 51 | 45 | 256 | loose |
| G Herbo | On My Soul | 51 | 61 | 480 | loose |
| G Herbo | On the Corner | 80 | 51 | 397 | loose |
| G Herbo | One Blood | 35 | 94 | 426 | AAAA |
| G Herbo | Opp Down | 22 | 34 | 55 | loose |
| G Herbo | Outside | 44 | 48 | 355 | loose |
| G Herbo | Outside Looking In | 53 | 53 | 530 | loose |
| G Herbo | Outta Bounds | 57 | 79 | 641 | loose |
| G Herbo | P Interlude | 8 | 2 | 30 | loose |
| G Herbo | PTSD | 59 | 68 | 329 | loose |
| G Herbo | Pac n Dre | 61 | 83 | 255 | loose |
| G Herbo | Paid | 40 | 70 | 377 | loose |
| G Herbo | Pain | 74 | 88 | 486 | loose |
| G Herbo | Party in Heaven | 43 | 53 | 437 | loose |
| G Herbo | Past Tense | 59 | 63 | 494 | loose |
| G Herbo | Peace of Mind | 40 | 63 | 389 | loose |
| G Herbo | Pistol P Intro | 28 | 21 | 259 | loose |
| G Herbo | Play It Smart | 35 | 21 | 309 | loose |
| G Herbo | Play They Role | 98 | 117 | 482 | loose |
| G Herbo | Play Your Part | 60 | 101 | 170 | loose |
| G Herbo | Poled Up | 53 | 56 | 173 | loose |
| G Herbo | Posted | 56 | 69 | 233 | loose |
| G Herbo | Pray 4 My Enemies | 40 | 64 | 552 | loose |
| G Herbo | Prayers | 46 | 70 | 262 | loose |
| G Herbo | Pull Up | 58 | 30 | 279 | loose |
| G Herbo | Quarantine | 77 | 83 | 285 | loose |
| G Herbo | Quick And Easy | 49 | 30 | 339 | loose |
| G Herbo | R.N. | 44 | 46 | 373 | loose |
| G Herbo | Racks In Class (Lunch Break Freestyle) | 58 | 91 | 726 | loose |
| G Herbo | Radar | 68 | 160 | 301 | AAAA |
| G Herbo | Rain | 77 | 90 | 442 | loose |
| G Herbo | Rain 2 | 62 | 74 | 367 | loose |
| G Herbo | Rain Bounce | 60 | 63 | 469 | loose |
| G Herbo | Raining | 47 | 47 | 271 | loose |
| G Herbo | Ran Thru | 33 | 37 | 262 | loose |
| G Herbo | Rap God | 36 | 66 | 293 | loose |
| G Herbo | Real | 38 | 44 | 278 | loose |
| G Herbo | Real One | 54 | 43 | 471 | loose |
| G Herbo | Real Rap | 51 | 60 | 416 | loose |
| G Herbo | Really Like That | 58 | 67 | 460 | loose |
| G Herbo | Reason | 51 | 68 | 440 | loose |
| G Herbo | Red Light Freestyle | 34 | 33 | 409 | loose |
| G Herbo | Red Snow | 65 | 67 | 470 | loose |
| G Herbo | Reject | 42 | 63 | 349 | loose |
| G Herbo | Relax | 38 | 40 | 295 | loose |
| G Herbo | Remember | 58 | 36 | 268 | loose |
| G Herbo | Remember (2019) [OG Mix] | 64 | 78 | 441 | loose |
| G Herbo | Remorse Outro | 26 | 41 | 239 | loose |
| G Herbo | Retro Flow | 31 | 34 | 374 | loose |
| G Herbo | Revolutionary | 54 | 66 | 443 | loose |
| G Herbo | Ride | 80 | 93 | 241 | loose |
| G Herbo | Ridin wit It | 65 | 86 | 466 | loose |
| G Herbo | Rob | 22 | 24 | 82 | loose |
| G Herbo | Roc Block | 44 | 47 | 344 | loose |
| G Herbo | Rollin’ | 81 | 52 | 352 | loose |
| G Herbo | Rose Gold | 44 | 80 | 287 | loose |
| G Herbo | Rubberbands (December 8th) | 13 | 10 | 54 | loose |
| G Herbo | Rumors | 58 | 73 | 468 | loose |
| G Herbo | Rumors | From The Block [SCHOOL] Performance | 23 | 12 | 161 | loose |
| G Herbo | Run It Up | 37 | 43 | 414 | loose |
| G Herbo | Running Through A Check | 54 | 71 | 363 | loose |
| G Herbo | Sacrifice | 83 | 121 | 563 | loose |
| G Herbo | Same Me | 76 | 115 | 515 | loose |
| G Herbo | Same Shit | 37 | 41 | 332 | loose |
| G Herbo | Scratchy & Itchy | 67 | 89 | 420 | loose |
| G Herbo | Sessions | 57 | 84 | 529 | loose |
| G Herbo | Shaderoom | 43 | 45 | 340 | loose |
| G Herbo | Shine | 18 | 31 | 117 | loose |
| G Herbo | Shine Bright* | 61 | 56 | 306 | loose |
| G Herbo | Shook | 58 | 72 | 584 | loose |
| G Herbo | Shoot | 32 | 41 | 150 | loose |
| G Herbo | Shooter | 40 | 72 | 157 | loose |
| G Herbo | Shordie | 39 | 42 | 226 | loose |
| G Herbo | Sin & Games | 47 | 54 | 353 | loose |
| G Herbo | Sins | 32 | 40 | 170 | loose |
| G Herbo | Sleepless Nights | 41 | 86 | 329 | loose |
| G Herbo | Slide (Remix) | 65 | 73 | 429 | loose |
| G Herbo | Smoke | 42 | 72 | 384 | loose |
| G Herbo | Sneaky Link NYC | 51 | 89 | 327 | loose |
| G Herbo | So Chicago (So Brooklyn Freestyle) | 37 | 39 | 273 | loose |
| G Herbo | Some Nights | 70 | 113 | 389 | loose |
| G Herbo | Some Otha Shit | 43 | 70 | 344 | AAAA |
| G Herbo | Something | 76 | 96 | 385 | loose |
| G Herbo | Song Cry 95' | 95 | 74 | 202 | loose |
| G Herbo | Spam 2 Lamb | 40 | 47 | 399 | loose |
| G Herbo | Spend That Bag | 47 | 72 | 262 | loose |
| G Herbo | Splat | 48 | 94 | 392 | loose |
| G Herbo | Stand the Rain (Mad Max) | 69 | 88 | 452 | loose |
| G Herbo | Statement | 50 | 65 | 324 | loose |
| G Herbo | Stay Solid | 46 | 75 | 595 | loose |
| G Herbo | Steel | 38 | 87 | 272 | AAAA |
| G Herbo | Still Dangerous | 40 | 95 | 348 | loose |
| G Herbo | Still Fucked Up | 42 | 43 | 254 | loose |
| G Herbo | Story Of A Thug | 62 | 82 | 493 | loose |
| G Herbo | Street | 76 | 89 | 616 | loose |
| G Herbo | Street Shit | 52 | 23 | 216 | loose |
| G Herbo | Strictly 4 My Fans (Intro) | 27 | 29 | 169 | loose |
| G Herbo | Strike You | 58 | 114 | 478 | loose |
| G Herbo | Strong | 37 | 26 | 277 | loose |
| G Herbo | Struggle | 46 | 50 | 269 | loose |
| G Herbo | Subject | 38 | 56 | 419 | loose |
| G Herbo | Summer is Cancelled | 62 | 75 | 539 | loose |
| G Herbo | Survivor’s Outro | 49 | 52 | 375 | loose |
| G Herbo | Swerv n Em | 35 | 30 | 294 | loose |
| G Herbo | Swervo | 45 | 32 | 200 | loose |
| G Herbo | T.O.P. | 43 | 39 | 230 | loose |
| G Herbo | Take Me Away | 34 | 50 | 395 | loose |
| G Herbo | Take Me Away x | 27 | 39 | 245 | loose |
| G Herbo | Teflon | 53 | 106 | 323 | loose |
| G Herbo | Ten | 43 | 50 | 239 | loose |
| G Herbo | Thank Me | 43 | 49 | 161 | loose |
| G Herbo | Thanksgiving Cypher | 38 | 34 | 165 | loose |
| G Herbo | That Boy | 41 | 69 | 268 | loose |
| G Herbo | That Sack | 76 | 43 | 234 | loose |
| G Herbo | That Shit Crazy | 56 | 126 | 530 | loose |
| G Herbo | That’s How I Grew Up | 28 | 20 | 92 | loose |
| G Herbo | The Drop | 54 | 62 | 352 | loose |
| G Herbo | This n That | 68 | 46 | 256 | loose |
| G Herbo | Through The Fire | 45 | 77 | 243 | loose |
| G Herbo | Through With You | 52 | 83 | 388 | loose |
| G Herbo | Thug | 45 | 51 | 294 | loose |
| G Herbo | TimWestwoodTV Freestyle | 65 | 118 | 411 | loose |
| G Herbo | Tired | 31 | 67 | 473 | loose |
| G Herbo | Together (Remix) | 34 | 44 | 263 | loose |
| G Herbo | Torn | 52 | 101 | 325 | loose |
| G Herbo | Traffic | 55 | 98 | 741 | loose |
| G Herbo | Trained to Kill (Big Body Whip) | 52 | 93 | 301 | loose |
| G Herbo | Trenches | 42 | 56 | 258 | loose |
| G Herbo | Trenches Know My Name | 44 | 84 | 559 | loose |
| G Herbo | Trials | 67 | 102 | 464 | loose |
| G Herbo | Trim | 58 | 65 | 288 | loose |
| G Herbo | Turning 25 | 57 | 99 | 377 | loose |
| G Herbo | Tweakin (Head) | 32 | 53 | 131 | loose |
| G Herbo | Unn | 49 | 74 | 386 | loose |
| G Herbo | Up It | 38 | 47 | 325 | loose |
| G Herbo | Versace (Remix) | 42 | 72 | 674 | loose |
| G Herbo | Vibin | 41 | 45 | 420 | loose |
| G Herbo | Visionary | 50 | 69 | 208 | loose |
| G Herbo | Wait 4 Me (Remix) | 57 | 88 | 440 | loose |
| G Herbo | Waitin’ For Nothin’ | 42 | 39 | 321 | loose |
| G Herbo | Watch Me Ball | 32 | 29 | 295 | loose |
| G Herbo | Watch Me Ball, Pt. 2 | 31 | 22 | 278 | loose |
| G Herbo | Wayback | 40 | 52 | 285 | loose |
| G Herbo | We Ball Remix | 27 | 24 | 237 | loose |
| G Herbo | We Don’t Care | 41 | 87 | 393 | AAAA |
| G Herbo | We don’t love these hoes | 8 | 10 | 56 | AAAA |
| G Herbo | Went Legit | 38 | 74 | 490 | loose |
| G Herbo | What I Did | 46 | 28 | 274 | loose |
| G Herbo | What You Need | 60 | 80 | 309 | loose |
| G Herbo | Whatchu Get | 44 | 66 | 532 | loose |
| G Herbo | Whatever U Want | 28 | 45 | 268 | loose |
| G Herbo | Where I Reside | 34 | 48 | 328 | loose |
| G Herbo | Where Would I Be? | 70 | 118 | 422 | loose |
| G Herbo | Who Run It | 91 | 100 | 352 | loose |
| G Herbo | Whole Hearts | 46 | 52 | 258 | loose |
| G Herbo | Wilt Chamberlin | 85 | 59 | 241 | loose |
| G Herbo | Win Again | 32 | 60 | 442 | loose |
| G Herbo | Windy City Shit | 39 | 35 | 108 | loose |
| G Herbo | Write Your Name | 61 | 39 | 416 | loose |
| G Herbo | XXL | 49 | 43 | 418 | loose |
| G Herbo | XXL Freshman Freestyle: G Herbo | 32 | 30 | 221 | loose |
| G Herbo | YN | 57 | 101 | 484 | loose |
| G Herbo | Yea I Know | 53 | 39 | 442 | loose |
| G Herbo | Yerk 30 | 84 | 141 | 544 | loose |
| G Herbo | Yerkys | 37 | 30 | 249 | loose |
| G Herbo | You Can’t | 37 | 42 | 202 | loose |
| G Herbo | Yup | 38 | 30 | 210 | loose |
| G Herbo | Y’all Don’t Really Hear Me | 91 | 106 | 374 | loose |
