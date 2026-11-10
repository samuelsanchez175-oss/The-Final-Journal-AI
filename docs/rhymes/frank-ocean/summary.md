# Frank Ocean rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Frank Ocean
- Songs: 324
- Bars kept (Frank Ocean lyric lines): 10043
- Section headers dropped, not counted as bars: 3
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 7
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 34
- Canonical name: Frank Ocean.
- Credit strings: Frank Ocean.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 44377
- REPEAT pairs, recorded separately: 7528
- END rhymes: 6230
- INNER rhymes: 38147

By match:

- PERFECT: 3682 (END 927, INNER 2755)
- SLANT: 17048 (END 2404, INNER 14644)
- ASSONANCE: 23168 (END 2812, INNER 20356)
- MULTI: 479 (END 87, INNER 392)

By confidence:

- HIGH: 3834
- MED: 38297
- LOW: 2246

## Core

- Core Y: 43422
- Core N among rhyme pairs: 955

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 19130 (43.1%)
- vowel: 23168 (52.2%)
- spelling: 1600 (3.6%)
- multi: 479 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- loose: 323 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 3791 pairs (END 321, INNER 3470). Words: don't, no, know, go, won't, don’t, over, only.
2. `vow:IH` — 3062 pairs (END 265, INNER 2797). Words: think, shit, still, bitch, little, since, didn't, bitches.
3. `vow:EH` — 2716 pairs (END 218, INNER 2498). Words: when, get, never, remember, there's, left, best, tell.
4. `vow:EY` — 2542 pairs (END 378, INNER 2164). Words: ain't, say, way, baby, make, day, stay, take.
5. `vow:AY` — 2327 pairs (END 448, INNER 1879). Words: like, mind, by, time, why, life, sky, high.
6. `vow:IY` — 1985 pairs (END 239, INNER 1746). Words: see, even, feeling, need, people, feel, here, keep.
7. `vow:AE` — 1981 pairs (END 265, INNER 1716). Words: can't, back, had, have, can, after, last, hand.
8. `vow:AH` — 1568 pairs (END 235, INNER 1333). Words: what, love, fuck, some, fucking, something, nothing, fuckin.
9. `vow:AA` — 1483 pairs (END 121, INNER 1362). Words: got, not, wanna, hard, want, la, heart, cause.
10. `vow:AO` — 641 pairs (END 100, INNER 541). Words: all, saw, lost, more, wanted, songs, call, gone.
11. `slant:AA:stop` — 578 pairs (END 66, INNER 512). Words: got, not, want, gotta, heart, god, stop, start.
12. `cmu:OW` — 556 pairs (END 96, INNER 460). Words: no, know, go, though, show, solo, slow, blow.
13. `slant:IH:stop` — 478 pairs (END 61, INNER 417). Words: shit, nigga, hit, dick, big, kid, shift, quick.
14. `slant:AY:stop` — 470 pairs (END 76, INNER 394). Words: like, right, light, inside, white, night, slide, ride.
15. `slant:EH:liq-stop` — 460 pairs (END 35, INNER 425). Words: get, tell, let, there, said, where, well, better.
16. `vow:UW` — 445 pairs (END 94, INNER 351). Words: through, new, two, who, used, que, cool, pool.
17. `slant:EH:stop` — 434 pairs (END 40, INNER 394). Words: get, said, let, better, left, best, head, ready.
18. `slant:AE:stop` — 398 pairs (END 62, INNER 336). Words: back, had, can't, black, matter, last, bag, bad.
19. `slant:EH:nas-stop` — 370 pairs (END 18, INNER 352). Words: when, get, let, again, said, getting, better, met.
20. `slant:AY:nas-stop` — 351 pairs (END 70, INNER 281). Words: time, like, right, shine, mine, night, line, white.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 158 pair sides, mostly spelling via spelling phonetic key, often with shit (40)
- esto — 131 pair sides, mostly vowel via spelling phonetic key, often with no (21)
- odio — 74 pair sides, mostly vowel via spelling phonetic key, often with los (15)
- ima — 71 pair sides, mostly spelling via spelling phonetic key, often with bitch (15)
- tryna — 70 pair sides, mostly spelling via spelling phonetic key, often with keep (15)
- quiero — 44 pair sides, mostly vowel via spelling phonetic key, often with no (11)
- gon — 43 pair sides, mostly spelling via spelling phonetic key, often with dont (17)
- niggas — 41 pair sides, mostly spelling via spelling phonetic key, often with nigga (20)
- sirvo — 41 pair sides, mostly vowel via spelling phonetic key, often with lo (8)
- eso — 41 pair sides, mostly vowel via spelling phonetic key, often with lo (5)
- saben — 35 pair sides, mostly vowel via spelling phonetic key, often with bastante (5)
- monetizado — 34 pair sides, mostly vowel via spelling phonetic key, often with publicado (7)
- publicado — 33 pair sides, mostly vowel via spelling phonetic key, often with monetizado (7)
- despu — 32 pair sides, mostly spelling via spelling phonetic key, often with s (12)
- ninguno — 32 pair sides, mostly vowel via spelling phonetic key, often with ning (5)
- puedo — 31 pair sides, mostly vowel via spelling phonetic key, often with no (9)
- hecho — 29 pair sides, mostly vowel via spelling phonetic key, often with no (5)
- swag — 27 pair sides, mostly spelling via spelling phonetic key, often with cant (4)
- dejo — 23 pair sides, mostly vowel via spelling phonetic key, often with lo (4)
- hago — 21 pair sides, mostly vowel via spelling phonetic key, often with mundo (3)
- acaso — 20 pair sides, mostly vowel via spelling phonetic key, often with video (3)
- tiempo — 17 pair sides, mostly vowel via spelling phonetic key, often with haciendo (2)
- hace — 17 pair sides, mostly vowel via spelling phonetic key, often with bastante (9)
- cobrado — 17 pair sides, mostly vowel via spelling phonetic key, often with monetizado (4)
- dinero — 17 pair sides, mostly vowel via spelling phonetic key, often with monetizado (2)
- conmigo — 16 pair sides, mostly vowel via spelling phonetic key, often with tiempo (2)
- mismo — 16 pair sides, mostly vowel via spelling phonetic key, often with odio (3)
- femyo — 16 pair sides, mostly spelling via spelling phonetic key, often with ere (4)
- bastante — 16 pair sides, mostly vowel via spelling phonetic key, often with hace (9)
- dibujo — 16 pair sides, mostly vowel via spelling phonetic key, often with sirvo (4)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Frank Ocean | (lotus flower bomb+thinkin bout you)cover | 28 | 14 | 131 | loose |
| Frank Ocean | 1st & Love | 39 | 14 | 87 | loose |
| Frank Ocean | 34+35 (Remix) / Slide (Mixed) | 54 | 31 | 226 | loose |
| Frank Ocean | 4 Tears | 19 | 8 | 61 | loose |
| Frank Ocean | 48 | 70 | 25 | 257 | loose |
| Frank Ocean | 911 / Mr. Lonely | 77 | 50 | 262 | loose |
| Frank Ocean | Abracadabra | 28 | 23 | 81 | loose |
| Frank Ocean | Acura Integurl | 34 | 14 | 148 | loose |
| Frank Ocean | Alabama | 25 | 16 | 75 | loose |
| Frank Ocean | Always | 18 | 7 | 26 | loose |
| Frank Ocean | Analog 2 | 39 | 16 | 105 | loose |
| Frank Ocean | Ankward | 21 | 8 | 49 | loose |
| Frank Ocean | Anthem | 23 | 8 | 67 | loose |
| Frank Ocean | Anywhere | 13 | 9 | 50 | loose |
| Frank Ocean | Astro | 52 | 34 | 300 | loose |
| Frank Ocean | At Your Best (You Are Love) | 27 | 7 | 68 | loose |
| Frank Ocean | Awkward | 48 | 19 | 180 | loose |
| Frank Ocean | Back | 35 | 18 | 130 | loose |
| Frank Ocean | Bad Religion | 26 | 13 | 39 | loose |
| Frank Ocean | Be Yourself | 18 | 4 | 74 | loose |
| Frank Ocean | Bedtime Story | 24 | 8 | 67 | loose |
| Frank Ocean | Bend Ya (Remix) | 63 | 22 | 341 | loose |
| Frank Ocean | Best Seller | 32 | 10 | 103 | loose |
| Frank Ocean | Big Enough | 9 | 0 | 11 | loose |
| Frank Ocean | Bigger | 31 | 23 | 51 | loose |
| Frank Ocean | Biking | 80 | 68 | 249 | loose |
| Frank Ocean | Biking [Mixed] | 10 | 2 | 24 | loose |
| Frank Ocean | Blasted | 28 | 12 | 76 | loose |
| Frank Ocean | Blondes | 46 | 36 | 197 | loose |
| Frank Ocean | Blood Rain | 24 | 17 | 35 | loose |
| Frank Ocean | Blue Whale | 47 | 33 | 306 | loose |
| Frank Ocean | Booty Club | 12 | 7 | 22 | loose |
| Frank Ocean | Brave | 17 | 5 | 40 | loose |
| Frank Ocean | Breakdown | 8 | 4 | 12 | loose |
| Frank Ocean | Bricks and Steel | 38 | 15 | 91 | loose |
| Frank Ocean | Broken Pieces | 17 | 7 | 68 | loose |
| Frank Ocean | Brotha Man | 50 | 36 | 324 | loose |
| Frank Ocean | Brown Eyed Man | 41 | 18 | 54 | loose |
| Frank Ocean | By Your Side (Frank Ocean Cover) [Live from Los Angeles] | 21 | 9 | 86 | loose |
| Frank Ocean | CAROUSEL | 41 | 79 | 167 | loose |
| Frank Ocean | CRUST IN THEIR EYES | 32 | 22 | 162 | loose |
| Frank Ocean | Cameras (Snippet) | 5 | 0 | 7 | loose |
| Frank Ocean | Can’t Be the Last Time | 33 | 11 | 187 | loose |
| Frank Ocean | Caught Their Eyes | 55 | 49 | 218 | loose |
| Frank Ocean | Cayendo | 12 | 2 | 81 | loose |
| Frank Ocean | Cayendo Remix | 3 | 0 | 4 | loose |
| Frank Ocean | Chanel | 49 | 28 | 198 | loose |
| Frank Ocean | Chanel (Remix) ft. Sose Paez | 24 | 11 | 80 | loose |
| Frank Ocean | Chanel (TWINSICK Remix) [Mixed] | 6 | 4 | 16 | loose |
| Frank Ocean | Choices | 35 | 17 | 156 | loose |
| Frank Ocean | Close to You | 10 | 5 | 34 | loose |
| Frank Ocean | Close to You / Never Can Say Goodbye (Live at FYF 2017) | 17 | 5 | 41 | loose |
| Frank Ocean | Come On World, You Can’t Go! | 134 | 129 | 690 | loose |
| Frank Ocean | Comme Des Garçons | 13 | 7 | 49 | loose |
| Frank Ocean | Coral | 28 | 12 | 181 | loose |
| Frank Ocean | Cost of Master Recordings (Blonde Vinyl Lyrics Foldout) | 9 | 1 | 36 | loose |
| Frank Ocean | Crack Rock | 28 | 13 | 148 | loose |
| Frank Ocean | DHL | 78 | 41 | 277 | loose |
| Frank Ocean | Day Away | 35 | 29 | 212 | loose |
| Frank Ocean | Dear April | 32 | 17 | 56 | loose |
| Frank Ocean | Denim | 19 | 12 | 80 | loose |
| Frank Ocean | Device Control (Reprise) | 37 | 15 | 115 | loose |
| Frank Ocean | Diary* | 6 | 4 | 29 | loose |
| Frank Ocean | Disillusioned | 27 | 9 | 76 | loose |
| Frank Ocean | Done | 19 | 4 | 60 | loose |
| Frank Ocean | Don’t Don’t Do It! | 52 | 23 | 178 | loose |
| Frank Ocean | Don’t Leave Me Now | 23 | 7 | 51 | loose |
| Frank Ocean | Dopamine | 36 | 24 | 148 | loose |
| Frank Ocean | Draper (feat. Jay-Z, Kanye West) | 26 | 11 | 68 | loose |
| Frank Ocean | Dream Killa | 23 | 8 | 93 | loose |
| Frank Ocean | Dying for Your Love | 21 | 9 | 96 | loose |
| Frank Ocean | Easy (Magazine Print Version) | 27 | 16 | 65 | loose |
| Frank Ocean | End / Golden Girl | 59 | 38 | 201 | loose |
| Frank Ocean | Eyes (V1) | 27 | 27 | 84 | loose |
| Frank Ocean | Eyes Like Sky | 28 | 8 | 98 | loose |
| Frank Ocean | Facebook Story | 16 | 2 | 36 | loose |
| Frank Ocean | Feel California | 16 | 4 | 55 | loose |
| Frank Ocean | Feelings Gone (Side-B Acoustic) | 28 | 17 | 141 | loose |
| Frank Ocean | Fish / Boppin’ Bitch | 94 | 93 | 559 | loose |
| Frank Ocean | Flight | 28 | 9 | 93 | loose |
| Frank Ocean | Focus | 13 | 3 | 42 | loose |
| Frank Ocean | Follow | 44 | 13 | 146 | loose |
| Frank Ocean | Forrest Gump | 20 | 9 | 18 | loose |
| Frank Ocean | Frank’s Track | 7 | 0 | 3 | loose |
| Frank Ocean | Freedom | 24 | 11 | 94 | loose |
| Frank Ocean | Freestyle | 9 | 9 | 63 | loose |
| Frank Ocean | Fringe | 19 | 6 | 77 | loose |
| Frank Ocean | Futura Free | 115 | 49 | 484 | loose |
| Frank Ocean | Get My Gun | 59 | 48 | 302 | loose |
| Frank Ocean | Girlfriend’s Best Friend | 31 | 15 | 62 | loose |
| Frank Ocean | Godspeed | 17 | 11 | 42 | loose |
| Frank Ocean | Golden Girl (Frank Ocean Cover) | 11 | 4 | 16 | loose |
| Frank Ocean | Good Decoration | 18 | 11 | 48 | loose |
| Frank Ocean | Good Guy | 14 | 10 | 45 | loose |
| Frank Ocean | Got the Keys | 27 | 14 | 69 | loose |
| Frank Ocean | Gotta Be | 42 | 34 | 147 | loose |
| Frank Ocean | Greedy Love | 24 | 7 | 91 | loose |
| Frank Ocean | HBK | 23 | 25 | 77 | loose |
| Frank Ocean | Hardest Thing | 32 | 16 | 108 | loose |
| Frank Ocean | Heartbreak + Jet Lag | 17 | 15 | 26 | loose |
| Frank Ocean | Hell | 42 | 42 | 228 | loose |
| Frank Ocean | Hero | 16 | 8 | 49 | loose |
| Frank Ocean | Hey you! | 16 | 9 | 44 | loose |
| Frank Ocean | Higgs | 28 | 22 | 78 | loose |
| Frank Ocean | Hoarse | 39 | 44 | 494 | loose |
| Frank Ocean | Holly Baby | 21 | 4 | 21 | loose |
| Frank Ocean | Hublots | 19 | 10 | 48 | loose |
| Frank Ocean | I Feel Like That (Frank Ocean Demo) | 22 | 12 | 100 | loose |
| Frank Ocean | I Fell | 35 | 20 | 64 | loose |
| Frank Ocean | I Got My License | 33 | 19 | 147 | loose |
| Frank Ocean | I Miss That Life | 27 | 19 | 40 | loose |
| Frank Ocean | I Miss You | 16 | 13 | 42 | loose |
| Frank Ocean | I Need It | 32 | 22 | 113 | loose |
| Frank Ocean | I Need Love | 29 | 12 | 71 | loose |
| Frank Ocean | If I’m in Love | 22 | 4 | 34 | loose |
| Frank Ocean | Igualitos | 18 | 3 | 114 | loose |
| Frank Ocean | Impietas + Deathwish (ASR) | 9 | 1 | 10 | loose |
| Frank Ocean | In My Room | 36 | 21 | 191 | loose |
| Frank Ocean | It’s All Good | 27 | 9 | 49 | loose |
| Frank Ocean | Ivy | 36 | 19 | 124 | loose |
| Frank Ocean | J.O.B | 25 | 6 | 74 | loose |
| Frank Ocean | John Ehret High School Alma Mater | 10 | 2 | 18 | loose |
| Frank Ocean | Journey | 24 | 11 | 50 | loose |
| Frank Ocean | June | 11 | 4 | 47 | loose |
| Frank Ocean | Kamikaze | 31 | 7 | 40 | loose |
| Frank Ocean | Kinikin’ ’Bout You | 20 | 6 | 67 | loose |
| Frank Ocean | Know Better | 28 | 16 | 68 | loose |
| Frank Ocean | LEMONHEAD | 50 | 34 | 187 | loose |
| Frank Ocean | LOVSOME [V2] | 10 | 5 | 26 | loose |
| Frank Ocean | Lava (Version 2) | 19 | 4 | 62 | loose |
| Frank Ocean | Lavender + White | 47 | 29 | 194 | loose |
| Frank Ocean | Lay It Down | 58 | 72 | 283 | loose |
| Frank Ocean | Lemonade | 43 | 59 | 282 | loose |
| Frank Ocean | Lens | 34 | 29 | 137 | loose |
| Frank Ocean | Let Me | 19 | 9 | 95 | loose |
| Frank Ocean | Lights | 38 | 9 | 98 | loose |
| Frank Ocean | Little Demon | 35 | 36 | 212 | loose |
| Frank Ocean | Live For Tonight (RG43 Version) | 18 | 28 | 68 | loose |
| Frank Ocean | Locket (Locked In Love) | 33 | 23 | 71 | loose |
| Frank Ocean | Lonny (New Mix) | 14 | 9 | 26 | loose |
| Frank Ocean | Look at us, We’re in love | 15 | 6 | 53 | loose |
| Frank Ocean | Lost | 20 | 8 | 96 | loose |
| Frank Ocean | Lost - Recorded at Metropolis Studios, London | 19 | 6 | 58 | loose |
| Frank Ocean | Lost Angel | 26 | 11 | 60 | loose |
| Frank Ocean | Love on My Piano | 24 | 8 | 53 | loose |
| Frank Ocean | Lovely Day | 56 | 53 | 241 | loose |
| Frank Ocean | Made in America | 39 | 47 | 170 | loose |
| Frank Ocean | Mama’s Boy | 32 | 18 | 92 | loose |
| Frank Ocean | Math | 29 | 15 | 129 | loose |
| Frank Ocean | Me retiro (PARTE 2) | 60 | 32 | 1034 | loose |
| Frank Ocean | Memrise | 16 | 7 | 32 | loose |
| Frank Ocean | Miss You So | 41 | 22 | 144 | loose |
| Frank Ocean | Mitsubishi Sony | 17 | 19 | 87 | loose |
| Frank Ocean | Monks | 50 | 18 | 103 | loose |
| Frank Ocean | Moon River | 16 | 11 | 20 | loose |
| Frank Ocean | Morango (Feat. Frank Ocean) | 9 | 10 | 69 | loose |
| Frank Ocean | My Willing Heart | 19 | 7 | 45 | loose |
| Frank Ocean | New Slaves | 62 | 33 | 212 | loose |
| Frank Ocean | Night Life (Live at Coachella 2023) | 28 | 19 | 24 | loose |
| Frank Ocean | Night.s (Demo) | 54 | 29 | 197 | loose |
| Frank Ocean | Nights | 79 | 46 | 244 | loose |
| Frank Ocean | Nikes | 53 | 33 | 137 | loose |
| Frank Ocean | Nikes [Live at Way Out West] | 5 | 1 | 8 | loose |
| Frank Ocean | No Bonnie | 19 | 8 | 51 | loose |
| Frank Ocean | No Church (V2) | 6 | 6 | 22 | loose |
| Frank Ocean | No Church in the Wild | 43 | 52 | 177 | loose |
| Frank Ocean | No Love | 31 | 9 | 67 | loose |
| Frank Ocean | No Rules | 20 | 9 | 71 | loose |
| Frank Ocean | No Such Thing As White Jesus | 5 | 0 | 12 | loose |
| Frank Ocean | Non-Stop | 23 | 14 | 83 | loose |
| Frank Ocean | Not Just Money | 14 | 4 | 50 | loose |
| Frank Ocean | Novacane | 57 | 34 | 141 | loose |
| Frank Ocean | Oceans | 40 | 33 | 181 | loose |
| Frank Ocean | Ohh in Love | 28 | 15 | 45 | loose |
| Frank Ocean | Old Terror | 28 | 10 | 98 | loose |
| Frank Ocean | Oldie | 201 | 176 | 1537 | loose |
| Frank Ocean | On and On | 4 | 6 | 2 | AAAA |
| Frank Ocean | One Look | 45 | 15 | 101 | loose |
| Frank Ocean | One Thing | 36 | 25 | 85 | loose |
| Frank Ocean | Only You (Live at FYF 2017) | 15 | 5 | 9 | loose |
| Frank Ocean | Open Air | 25 | 9 | 115 | loose |
| Frank Ocean | Orion (Oh, Ryan) | 31 | 20 | 89 | loose |
| Frank Ocean | Overload | 34 | 11 | 61 | loose |
| Frank Ocean | PDA (Backstreet Boys Reference) | 29 | 26 | 55 | loose |
| Frank Ocean | PETIT NOIR/E-BONUS TRACK | 33 | 9 | 49 | loose |
| Frank Ocean | Pacifica | 5 | 0 | 0 | loose |
| Frank Ocean | Parachute [Today] | 27 | 14 | 58 | loose |
| Frank Ocean | PartyIsntOver/Campfire/Bimmer | 58 | 29 | 272 | loose |
| Frank Ocean | Pictures | 15 | 3 | 48 | loose |
| Frank Ocean | Pilot Jones | 31 | 15 | 92 | loose |
| Frank Ocean | Pink + White | 40 | 21 | 87 | loose |
| Frank Ocean | Pink Matter | 46 | 36 | 157 | loose |
| Frank Ocean | Pleasure over Matter | 23 | 10 | 196 | loose |
| Frank Ocean | Poolside Convo (Self Control Intro) | 20 | 28 | 178 | loose |
| Frank Ocean | Pre | 59 | 37 | 299 | loose |
| Frank Ocean | Pre [V1] | 15 | 13 | 51 | loose |
| Frank Ocean | Pretty Sweet | 24 | 30 | 27 | loose |
| Frank Ocean | Private Show | 28 | 9 | 41 | loose |
| Frank Ocean | Provider | 38 | 27 | 146 | loose |
| Frank Ocean | Purity | 65 | 40 | 399 | loose |
| Frank Ocean | Pyramids | 64 | 21 | 214 | loose |
| Frank Ocean | Pyrite (Fool’s Gold) | 34 | 22 | 95 | loose |
| Frank Ocean | Quickly | 29 | 21 | 58 | loose |
| Frank Ocean | Qué quieres? | 16 | 13 | 103 | loose |
| Frank Ocean | RAF | 113 | 155 | 313 | loose |
| Frank Ocean | RIck Rick | 26 | 11 | 158 | loose |
| Frank Ocean | Reach For The Stars | 23 | 10 | 71 | loose |
| Frank Ocean | Read the Stars | 24 | 9 | 54 | loose |
| Frank Ocean | Ready | 35 | 25 | 86 | loose |
| Frank Ocean | Real | 28 | 17 | 113 | loose |
| Frank Ocean | Real Ones, a Nikes Cover | 8 | 4 | 14 | loose |
| Frank Ocean | Rewind That | 32 | 22 | 110 | loose |
| Frank Ocean | Richest Man in the Room | 33 | 5 | 75 | loose |
| Frank Ocean | Rico | 39 | 22 | 274 | loose |
| Frank Ocean | Rocket Love | 32 | 6 | 75 | loose |
| Frank Ocean | Rolls Royce Bitch (Freestyle) | 33 | 14 | 71 | loose |
| Frank Ocean | Royalty | 59 | 50 | 363 | loose |
| Frank Ocean | Rushes | 34 | 16 | 74 | loose |
| Frank Ocean | ST4RCR4SH | 50 | 79 | 204 | loose |
| Frank Ocean | Scared of Beautiful | 27 | 4 | 62 | loose |
| Frank Ocean | Seigfried | 46 | 16 | 154 | loose |
| Frank Ocean | Seigfried / Self Control / White Ferarri | 19 | 8 | 26 | loose |
| Frank Ocean | Self Control | 29 | 31 | 90 | loose |
| Frank Ocean | She | 54 | 31 | 217 | loose |
| Frank Ocean | She Dgaf | 22 | 11 | 78 | loose |
| Frank Ocean | She Won’t Say Hello | 29 | 16 | 130 | loose |
| Frank Ocean | Shibuya | 14 | 8 | 47 | loose |
| Frank Ocean | Shot | 1 | 0 | 0 | loose |
| Frank Ocean | Sideways | 27 | 28 | 80 | loose |
| Frank Ocean | Sierra Leone | 18 | 7 | 115 | loose |
| Frank Ocean | Simply | 24 | 5 | 96 | loose |
| Frank Ocean | Skyline To | 25 | 20 | 71 | loose |
| Frank Ocean | Slater | 55 | 76 | 324 | loose |
| Frank Ocean | Slide | 38 | 39 | 197 | loose |
| Frank Ocean | Slide On Me | 44 | 14 | 155 | loose |
| Frank Ocean | Snow White | 31 | 29 | 201 | loose |
| Frank Ocean | So Comfortable | 19 | 5 | 99 | loose |
| Frank Ocean | So Fresh | 16 | 9 | 51 | loose |
| Frank Ocean | Solo | 38 | 25 | 158 | loose |
| Frank Ocean | Solo (JD. Reid Remix) [Mixed] | 12 | 3 | 43 | loose |
| Frank Ocean | Somebody Else | 25 | 19 | 91 | loose |
| Frank Ocean | Spaceman | 58 | 51 | 201 | loose |
| Frank Ocean | Standing Still | 24 | 14 | 76 | loose |
| Frank Ocean | Static | 48 | 14 | 114 | loose |
| Frank Ocean | Stay If You Go | 37 | 14 | 79 | loose |
| Frank Ocean | Steamroller | 51 | 32 | 236 | loose |
| Frank Ocean | Steer It (AI) | 18 | 8 | 55 | loose |
| Frank Ocean | Still Mine | 39 | 24 | 137 | loose |
| Frank Ocean | Still Mine, Pt. 2* | 3 | 0 | 2 | loose |
| Frank Ocean | Sucka for Love (Alternate Version) | 35 | 41 | 137 | loose |
| Frank Ocean | Sucker for Love | 28 | 27 | 110 | loose |
| Frank Ocean | Summer Remains | 31 | 24 | 66 | loose |
| Frank Ocean | Sunday | 58 | 44 | 412 | loose |
| Frank Ocean | Super Rich Kids | 45 | 36 | 240 | loose |
| Frank Ocean | Superpower | 39 | 25 | 62 | loose |
| Frank Ocean | Surprise Ending | 32 | 16 | 71 | loose |
| Frank Ocean | Swag Me Out | 86 | 71 | 412 | loose |
| Frank Ocean | Sweet Life | 28 | 19 | 144 | loose |
| Frank Ocean | Swim Good | 28 | 8 | 87 | loose |
| Frank Ocean | TBY Remix Bouyon | 12 | 1 | 54 | loose |
| Frank Ocean | Taste | 35 | 29 | 153 | loose |
| Frank Ocean | Tfue freestyle | 59 | 88 | 170 | loose |
| Frank Ocean | Thank Me Later | 33 | 10 | 111 | loose |
| Frank Ocean | The City | 39 | 16 | 80 | loose |
| Frank Ocean | The Pajama Game/I’ll Never Be Jealous Again | 21 | 5 | 44 | loose |
| Frank Ocean | The Weekend | 29 | 12 | 93 | loose |
| Frank Ocean | Theme Song | 14 | 3 | 31 | loose |
| Frank Ocean | These Days | 34 | 33 | 196 | loose |
| Frank Ocean | Thinkin Bout You | 22 | 13 | 97 | loose |
| Frank Ocean | Thinkin bout you - spring sampler / 2012 | 14 | 7 | 49 | loose |
| Frank Ocean | Thinking About Forever | 10 | 4 | 53 | loose |
| Frank Ocean | Thinking About You | 16 | 1 | 66 | loose |
| Frank Ocean | Thinking Bout You Pt. 2 | 29 | 9 | 55 | loose |
| Frank Ocean | Thinking bout you, Rendition | 19 | 10 | 46 | loose |
| Frank Ocean | Thinkin’ Ahead | 17 | 6 | 59 | loose |
| Frank Ocean | Time Machine | 29 | 12 | 62 | loose |
| Frank Ocean | Together | 31 | 10 | 56 | loose |
| Frank Ocean | Tonight | 19 | 4 | 72 | loose |
| Frank Ocean | Trouble | 26 | 19 | 81 | loose |
| Frank Ocean | Truce | 30 | 18 | 75 | loose |
| Frank Ocean | Try | 21 | 9 | 54 | loose |
| Frank Ocean | Tryin’ So Hard (Demo) | 14 | 8 | 68 | loose |
| Frank Ocean | U Got it | 28 | 13 | 58 | loose |
| Frank Ocean | Unity | 53 | 46 | 263 | loose |
| Frank Ocean | Versace | 22 | 13 | 120 | loose |
| Frank Ocean | Visions, Visions. ‘Interlude’ | 16 | 4 | 32 | loose |
| Frank Ocean | Wake Up | 36 | 24 | 64 | loose |
| Frank Ocean | War Vet | 53 | 65 | 197 | loose |
| Frank Ocean | Wayfarers (Light Show) | 25 | 4 | 34 | loose |
| Frank Ocean | We Gud... J- Jake | 18 | 6 | 47 | loose |
| Frank Ocean | Where This Flower Blooms | 42 | 27 | 118 | loose |
| Frank Ocean | Whip Appeal | 35 | 14 | 121 | loose |
| Frank Ocean | White | 14 | 4 | 45 | loose |
| Frank Ocean | White Ferrari | 36 | 17 | 114 | loose |
| Frank Ocean | White Ferrari / Twin Fantasy (Those Boys) / Do What You Gotta Do | 37 | 16 | 106 | loose |
| Frank Ocean | White Ferrari X I Know The End | 18 | 12 | 70 | loose |
| Frank Ocean | Wildfire | 24 | 19 | 58 | loose |
| Frank Ocean | Wildfire Interlude | 10 | 26 | 35 | loose |
| Frank Ocean | Window | 124 | 93 | 754 | loose |
| Frank Ocean | Wine Words | 4 | 2 | 43 | loose |
| Frank Ocean | Wise Man | 39 | 26 | 132 | loose |
| Frank Ocean | Wither | 20 | 13 | 48 | loose |
| Frank Ocean | Wither Remix | 25 | 20 | 188 | loose |
| Frank Ocean | Without You | 41 | 13 | 101 | loose |
| Frank Ocean | Wolves | 27 | 5 | 33 | loose |
| Frank Ocean | Xenons | 4 | 1 | 2 | loose |
| Frank Ocean | Younger Self / Boundaries* | 15 | 3 | 62 | loose |
| Frank Ocean | You’re My Baby | 12 | 4 | 51 | loose |
| Frank Ocean | american wedding | 58 | 38 | 126 | loose |
| Frank Ocean | anaphylaxis | 41 | 48 | 261 | loose |
| Frank Ocean | bitches talkin’ | 5 | 2 | 11 | loose |
| Frank Ocean | cªliupsycė’s ~Interlude~ (Ends of the Debuts ¿) | 5 | 1 | 10 | loose |
| Frank Ocean | dust | 24 | 9 | 53 | loose |
| Frank Ocean | fireflys og | 3 | 1 | 9 | loose |
| Frank Ocean | lovecrimes | 22 | 7 | 16 | loose |
| Frank Ocean | misshape | 27 | 17 | 176 | loose |
| Frank Ocean | nature feels | 24 | 11 | 54 | loose |
| Frank Ocean | proud of u | 7 | 1 | 24 | loose |
| Frank Ocean | songs for women | 58 | 28 | 142 | loose |
| Frank Ocean | strawberry swing | 31 | 18 | 62 | loose |
| Frank Ocean | there will be tears | 27 | 7 | 68 | loose |
| Frank Ocean | we all try | 27 | 6 | 40 | loose |
| Frank Ocean | yes, cold lady | 44 | 40 | 230 | loose |
| Frank Ocean | ‎i ❤️ blond | 7 | 5 | 8 | loose |
