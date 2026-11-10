# Earl Sweatshirt rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Earl Sweatshirt
- Songs: 351
- Bars kept (Earl Sweatshirt lyric lines): 12921
- Section headers dropped, not counted as bars: 4
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 108
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 11
- Canonical name: Earl Sweatshirt.
- Credit strings: Earl Sweatshirt.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 98786
- REPEAT pairs, recorded separately: 5127
- END rhymes: 13736
- INNER rhymes: 85050

By match:

- PERFECT: 6278 (END 1282, INNER 4996)
- SLANT: 36721 (END 5204, INNER 31517)
- ASSONANCE: 54902 (END 7064, INNER 47838)
- MULTI: 885 (END 186, INNER 699)

By confidence:

- HIGH: 6433
- MED: 88609
- LOW: 3744

## Core

- Core Y: 97586
- Core N among rhyme pairs: 1200

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 39760 (40.2%)
- vowel: 54902 (55.6%)
- spelling: 3239 (3.3%)
- multi: 885 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- ABCB: 1 songs
- loose: 350 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 8318 pairs (END 982, INNER 7336). Words: shit, bitch, bitches, think, still, little, him, give.
2. `vow:AE` — 6900 pairs (END 944, INNER 5956). Words: back, can't, had, have, last, hands, ass, hand.
3. `vow:EH` — 6242 pairs (END 530, INNER 5712). Words: when, get, never, where, left, end, head, best.
4. `vow:EY` — 6188 pairs (END 1001, INNER 5187). Words: ain't, way, say, day, face, play, stay, make.
5. `vow:OW` — 5787 pairs (END 541, INNER 5246). Words: don't, know, no, go, over, only, cold, home.
6. `vow:AA` — 4610 pairs (END 526, INNER 4084). Words: got, not, hard, problem, heart, want, god, gotta.
7. `vow:IY` — 4329 pairs (END 576, INNER 3753). Words: see, even, need, these, keep, three, people, leave.
8. `vow:AH` — 4211 pairs (END 593, INNER 3618). Words: fucking, fuck, what, some, fuckin, love, couple, nothing.
9. `vow:AY` — 3805 pairs (END 575, INNER 3230). Words: like, high, by, time, try, mind, why, find.
10. `slant:IH:stop` — 1699 pairs (END 260, INNER 1439). Words: shit, nigga, hit, big, dick, quick, spit, sick.
11. `vow:UW` — 1400 pairs (END 226, INNER 1174). Words: through, two, who, music, new, used, knew, blue.
12. `slant:AE:stop` — 1281 pairs (END 209, INNER 1072). Words: back, had, can't, black, rap, bad, fact, bag.
13. `vow:AO` — 1268 pairs (END 187, INNER 1081). Words: all, lost, thoughts, long, more, saw, call, talking.
14. `slant:AA:stop` — 1193 pairs (END 126, INNER 1067). Words: got, not, gotta, heart, god, stop, hard, start.
15. `slant:IH:sib-stop` — 1090 pairs (END 242, INNER 848). Words: bitch, shit, nigga, niggas, hit, miss, dick, switch.
16. `slant:EH:stop` — 996 pairs (END 132, INNER 864). Words: get, let, head, said, left, best, neck, bet.
17. `slant:AE:sib-stop` — 900 pairs (END 170, INNER 730). Words: ass, back, black, cash, catch, class, pass, glass.
18. `vow:AW` — 849 pairs (END 187, INNER 662). Words: now, how, down, around, clouds, about, house, 'bout.
19. `slant:EY:sib-stop` — 832 pairs (END 194, INNER 638). Words: face, make, place, take, made, always, baby, days.
20. `vow:ER` — 807 pairs (END 184, INNER 623). Words: first, work, purpose, person, words, heard, worry, world.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 607 pair sides, mostly spelling via spelling phonetic key, often with niggas (154)
- niggas — 335 pair sides, mostly spelling via spelling phonetic key, often with nigga (154)
- ima — 150 pair sides, mostly spelling via spelling phonetic key, often with shit (18)
- tryna — 149 pair sides, mostly spelling via spelling phonetic key, often with keep (17)
- gon — 120 pair sides, mostly spelling via spelling phonetic key, often with dont (22)
- spliff — 59 pair sides, mostly vowel via spelling phonetic key, often with shit (7)
- swag — 56 pair sides, mostly spelling via spelling phonetic key, often with had (5)
- finna — 34 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- cuz — 33 pair sides, mostly spelling via spelling phonetic key, often with what (7)
- spliffs — 31 pair sides, mostly vowel via spelling phonetic key, often with shit (6)
- fam — 28 pair sides, mostly spelling via spelling phonetic key, often with man (5)
- bruh — 21 pair sides, mostly spelling via spelling phonetic key, often with fuck (4)
- siento — 21 pair sides, mostly vowel via spelling phonetic key, often with lo (2)
- sess — 20 pair sides, mostly spelling via spelling phonetic key, often with best (4)
- creeper — 20 pair sides, mostly spelling via spelling phonetic key, often with beeper (2)
- bros — 19 pair sides, mostly spelling via spelling phonetic key, often with alone (3)
- piff — 19 pair sides, mostly vowel via spelling phonetic key, often with bitch (3)
- nak — 19 pair sides, mostly spelling via spelling phonetic key, often with black (2)
- steez — 17 pair sides, mostly spelling via spelling phonetic key, often with please (2)
- geeked — 17 pair sides, mostly spelling via spelling phonetic key, often with sleep (2)
- spitter — 16 pair sides, mostly spelling via spelling phonetic key, often with kick (2)
- uppercut — 15 pair sides, mostly vowel via spelling phonetic key, often with fuck (2)
- thebe — 15 pair sides, mostly spelling via spelling phonetic key, often with self (1)
- swervin — 14 pair sides, mostly spelling via spelling phonetic key, often with berman (2)
- hoopty — 14 pair sides, mostly vowel via spelling phonetic key, often with sticky (1)
- eso — 14 pair sides, mostly vowel via spelling phonetic key, often with lo (2)
- veces — 14 pair sides, mostly spelling via spelling phonetic key, often with es (5)
- bitchs — 14 pair sides, mostly vowel via spelling phonetic key, often with wrist (2)
- meds — 14 pair sides, mostly vowel via spelling phonetic key, often with said (3)
- floozy — 14 pair sides, mostly spelling via spelling phonetic key, often with loony (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Earl Sweatshirt | 100 High Street | 25 | 18 | 106 | loose |
| Earl Sweatshirt | 20 Wave Caps | 37 | 39 | 358 | loose |
| Earl Sweatshirt | 2010 | 45 | 46 | 319 | loose |
| Earl Sweatshirt | 2016 shit DWFH | 3 | 0 | 10 | loose |
| Earl Sweatshirt | 24 Gospel | 52 | 63 | 362 | loose |
| Earl Sweatshirt | 27 Braids | 28 | 42 | 236 | loose |
| Earl Sweatshirt | 45 | 17 | 8 | 122 | loose |
| Earl Sweatshirt | 4N | 24 | 27 | 165 | loose |
| Earl Sweatshirt | 74 | 33 | 29 | 232 | loose |
| Earl Sweatshirt | 8/22 | 20 | 25 | 150 | loose |
| Earl Sweatshirt | :( again :) | 38 | 91 | 136 | loose |
| Earl Sweatshirt | AM // Radio | 45 | 42 | 370 | loose |
| Earl Sweatshirt | AOK | 33 | 47 | 309 | loose |
| Earl Sweatshirt | Against The Wind* | 29 | 47 | 199 | loose |
| Earl Sweatshirt | All I Need | 55 | 103 | 327 | loose |
| Earl Sweatshirt | All In | 21 | 24 | 165 | loose |
| Earl Sweatshirt | All the Small Things | 25 | 27 | 203 | loose |
| Earl Sweatshirt | Alone* | 21 | 19 | 213 | loose |
| Earl Sweatshirt | Always Late & Heart Out (Snippets) | 10 | 11 | 68 | loose |
| Earl Sweatshirt | As Expected | 25 | 17 | 320 | loose |
| Earl Sweatshirt | AssMilk | 78 | 68 | 639 | loose |
| Earl Sweatshirt | Azucar | 32 | 37 | 205 | loose |
| Earl Sweatshirt | BAD FRUIT* | 25 | 30 | 133 | loose |
| Earl Sweatshirt | BOTH FEET | 50 | 28 | 173 | loose |
| Earl Sweatshirt | Balance | 16 | 14 | 88 | loose |
| Earl Sweatshirt | Baleen Pocketknife | 22 | 32 | 116 | loose |
| Earl Sweatshirt | Belladonna | 34 | 44 | 407 | loose |
| Earl Sweatshirt | Beltway | 2 | 0 | 0 | loose |
| Earl Sweatshirt | Bespoke | 29 | 7 | 168 | loose |
| Earl Sweatshirt | Between Friends | 53 | 33 | 405 | loose |
| Earl Sweatshirt | Between Villains | 59 | 48 | 601 | loose |
| Earl Sweatshirt | Bill | 79 | 78 | 738 | loose |
| Earl Sweatshirt | Bitcrusher | 8 | 4 | 43 | loose |
| Earl Sweatshirt | Bitter Cassava | 50 | 53 | 310 | loose |
| Earl Sweatshirt | Blade | 22 | 17 | 183 | loose |
| Earl Sweatshirt | Blondes | 46 | 36 | 197 | loose |
| Earl Sweatshirt | Blueblood Track #1 (Gazpacho, Zoo Pie) | 10 | 17 | 32 | loose |
| Earl Sweatshirt | Blueblood Track #2 | 17 | 8 | 57 | loose |
| Earl Sweatshirt | Book of Eli | 17 | 47 | 119 | loose |
| Earl Sweatshirt | Bowser’s Lament [V1] | 7 | 9 | 35 | loose |
| Earl Sweatshirt | Bowser’s Lament [V2] | 33 | 37 | 346 | loose |
| Earl Sweatshirt | Brand New | 14 | 17 | 127 | loose |
| Earl Sweatshirt | Burgundy | 30 | 20 | 216 | loose |
| Earl Sweatshirt | COOKIES (OG Live) | 8 | 9 | 19 | ABCB |
| Earl Sweatshirt | CRISCO | 49 | 34 | 347 | loose |
| Earl Sweatshirt | California Games | 67 | 75 | 363 | loose |
| Earl Sweatshirt | Carpe DM (Seize the Play) | 22 | 14 | 122 | loose |
| Earl Sweatshirt | Centurion | 49 | 33 | 373 | loose |
| Earl Sweatshirt | Chali 2na | 25 | 39 | 141 | loose |
| Earl Sweatshirt | Chapter 10; Sustainability | 5 | 0 | 19 | loose |
| Earl Sweatshirt | Chapter 1; The Empire is Collapsing | 10 | 7 | 35 | loose |
| Earl Sweatshirt | Chapter 7; W.O.K.E. Interlude | 15 | 2 | 36 | loose |
| Earl Sweatshirt | Chicago | 21 | 52 | 81 | loose |
| Earl Sweatshirt | Chordaroy | 62 | 51 | 418 | loose |
| Earl Sweatshirt | Chum | 41 | 33 | 307 | loose |
| Earl Sweatshirt | Cocaine On My Sweatshirt | 42 | 49 | 294 | loose |
| Earl Sweatshirt | Cold Summers | 24 | 18 | 137 | loose |
| Earl Sweatshirt | Cold World | 82 | 58 | 725 | loose |
| Earl Sweatshirt | Cool | 47 | 59 | 414 | loose |
| Earl Sweatshirt | CopKiller | 66 | 62 | 523 | loose |
| Earl Sweatshirt | Couch | 20 | 20 | 199 | loose |
| Earl Sweatshirt | Creatures of the Night | 32 | 15 | 153 | loose |
| Earl Sweatshirt | Cressidaway!/ TPGeeK | 88 | 119 | 407 | loose |
| Earl Sweatshirt | Crimson | 46 | 72 | 420 | loose |
| Earl Sweatshirt | Curse | 38 | 25 | 251 | loose |
| Earl Sweatshirt | DEAD MAN HUM400N | 17 | 31 | 120 | loose |
| Earl Sweatshirt | DNA | 63 | 47 | 298 | loose |
| Earl Sweatshirt | Da Bid | 47 | 94 | 309 | loose |
| Earl Sweatshirt | Dat Ass | 23 | 15 | 179 | loose |
| Earl Sweatshirt | Dead Man’s Tetris | 25 | 21 | 66 | loose |
| Earl Sweatshirt | Dead Zone | 42 | 40 | 297 | loose |
| Earl Sweatshirt | Death Whistles* | 30 | 25 | 226 | loose |
| Earl Sweatshirt | December 24 | 33 | 18 | 228 | loose |
| Earl Sweatshirt | Deerskin | 34 | 42 | 280 | loose |
| Earl Sweatshirt | Do You Remember the Monsters? | 41 | 61 | 292 | loose |
| Earl Sweatshirt | Don’t Go Summer | 21 | 22 | 92 | loose |
| Earl Sweatshirt | Don’t Worry! | 13 | 22 | 56 | loose |
| Earl Sweatshirt | Dreams | 12 | 6 | 62 | loose |
| Earl Sweatshirt | Drop | 38 | 38 | 334 | loose |
| Earl Sweatshirt | E. Coli | 34 | 35 | 155 | loose |
| Earl Sweatshirt | EAST | 41 | 37 | 208 | loose |
| Earl Sweatshirt | EL TORO COMBO MEAL | 64 | 75 | 432 | loose |
| Earl Sweatshirt | Earl | 51 | 67 | 503 | loose |
| Earl Sweatshirt | Earl Sweatshirt Sway In The Morning Freestyle | 22 | 33 | 236 | loose |
| Earl Sweatshirt | EarlyBird | 10 | 4 | 18 | loose |
| Earl Sweatshirt | Earth | 35 | 64 | 101 | loose |
| Earl Sweatshirt | Easter Sunday | 34 | 15 | 274 | loose |
| Earl Sweatshirt | Eclipse | 24 | 38 | 174 | loose |
| Earl Sweatshirt | Edge of a Mountain | 24 | 18 | 135 | loose |
| Earl Sweatshirt | Elimination Chamber | 3 | 0 | 8 | loose |
| Earl Sweatshirt | Eulogy | 45 | 51 | 144 | loose |
| Earl Sweatshirt | Ew! | 30 | 64 | 152 | loose |
| Earl Sweatshirt | FORGE | 21 | 13 | 179 | loose |
| Earl Sweatshirt | FUK IT | 17 | 8 | 240 | loose |
| Earl Sweatshirt | Fall 2013 Tour Dates | 16 | 2 | 36 | loose |
| Earl Sweatshirt | Falling out the Sky | 65 | 57 | 432 | loose |
| Earl Sweatshirt | Farm | 42 | 36 | 183 | loose |
| Earl Sweatshirt | Faucet | 39 | 31 | 264 | loose |
| Earl Sweatshirt | Fetch | 73 | 146 | 321 | loose |
| Earl Sweatshirt | Final | 18 | 11 | 198 | loose |
| Earl Sweatshirt | Fire in the Hole | 34 | 35 | 165 | loose |
| Earl Sweatshirt | Flowers on the Grave | 33 | 38 | 130 | loose |
| Earl Sweatshirt | Flummox | 28 | 18 | 167 | loose |
| Earl Sweatshirt | Foodies / The Lost Battles | 18 | 24 | 152 | loose |
| Earl Sweatshirt | For Casey | 58 | 55 | 353 | loose |
| Earl Sweatshirt | Free the Ruler | 32 | 36 | 162 | loose |
| Earl Sweatshirt | Freestyle at Terry’s Studio | 55 | 32 | 302 | loose |
| Earl Sweatshirt | Fuck This Christmas | 43 | 33 | 214 | loose |
| Earl Sweatshirt | Fuck Your Compression | 45 | 51 | 434 | loose |
| Earl Sweatshirt | GHOST | 26 | 35 | 105 | loose |
| Earl Sweatshirt | Gamebreaker | 47 | 45 | 542 | loose |
| Earl Sweatshirt | Gamma (need the ˂3) | 37 | 45 | 336 | loose |
| Earl Sweatshirt | Gamma (need the ˂3) [Live 2?] | 24 | 22 | 148 | loose |
| Earl Sweatshirt | Gas | 78 | 69 | 458 | loose |
| Earl Sweatshirt | Geb | 38 | 24 | 274 | loose |
| Earl Sweatshirt | Geedorah | 30 | 18 | 334 | loose |
| Earl Sweatshirt | Global Affairs* | 25 | 27 | 180 | loose |
| Earl Sweatshirt | God Laughs | 20 | 27 | 147 | loose |
| Earl Sweatshirt | God’s Feet | 17 | 9 | 89 | loose |
| Earl Sweatshirt | Gold | 30 | 36 | 333 | loose |
| Earl Sweatshirt | Great | 37 | 55 | 325 | loose |
| Earl Sweatshirt | Green Box Freestyle | 13 | 4 | 84 | loose |
| Earl Sweatshirt | Grief | 42 | 30 | 230 | loose |
| Earl Sweatshirt | Grown Ups | 41 | 31 | 317 | loose |
| Earl Sweatshirt | Guild | 67 | 60 | 481 | loose |
| Earl Sweatshirt | H.A.M (Sandwich) | 57 | 32 | 182 | loose |
| Earl Sweatshirt | HIGHSCHOOL (Intro) | 16 | 3 | 22 | loose |
| Earl Sweatshirt | Hand Grenade* | 24 | 62 | 102 | loose |
| Earl Sweatshirt | Hat Trick (CDQ) | 17 | 17 | 103 | loose |
| Earl Sweatshirt | Hat Trick / Human Error | 23 | 35 | 155 | loose |
| Earl Sweatshirt | Head Heavy | 26 | 23 | 223 | loose |
| Earl Sweatshirt | Head Heavy 2 | 11 | 6 | 49 | loose |
| Earl Sweatshirt | Heat Check | 38 | 67 | 325 | loose |
| Earl Sweatshirt | Heaven Knows* | 43 | 70 | 245 | loose |
| Earl Sweatshirt | Heavy Metal aka ejecto seato! | 42 | 53 | 300 | loose |
| Earl Sweatshirt | Hell | 23 | 8 | 198 | loose |
| Earl Sweatshirt | Hell Yeah* | 22 | 33 | 161 | loose |
| Earl Sweatshirt | He’s Still Alive | 45 | 51 | 367 | loose |
| Earl Sweatshirt | High 6AM Rambling at the 5th | 20 | 16 | 186 | loose |
| Earl Sweatshirt | Hive | 80 | 40 | 803 | loose |
| Earl Sweatshirt | Hoarse | 39 | 44 | 494 | loose |
| Earl Sweatshirt | Home | 29 | 51 | 399 | loose |
| Earl Sweatshirt | Home on the Range | 41 | 42 | 129 | loose |
| Earl Sweatshirt | Hot Water (Cahuilla) | 42 | 84 | 313 | loose |
| Earl Sweatshirt | Huey | 20 | 15 | 137 | loose |
| Earl Sweatshirt | I Know That Man | 25 | 21 | 292 | loose |
| Earl Sweatshirt | INFATUATION | 23 | 57 | 173 | loose |
| Earl Sweatshirt | In Route (MAVI Remix) | 31 | 48 | 111 | loose |
| Earl Sweatshirt | In The Closet | 36 | 31 | 297 | loose |
| Earl Sweatshirt | Inside | 31 | 38 | 211 | loose |
| Earl Sweatshirt | Intro [SOME TRASH SONGS] | 7 | 4 | 22 | loose |
| Earl Sweatshirt | Ion Rap Beef (Remix) | 52 | 69 | 314 | loose |
| Earl Sweatshirt | I’m Not Real | 51 | 40 | 442 | loose |
| Earl Sweatshirt | I’m still here, at rock bottom | 17 | 11 | 119 | loose |
| Earl Sweatshirt | Jameson | 39 | 41 | 298 | loose |
| Earl Sweatshirt | Jesus | 36 | 42 | 409 | loose |
| Earl Sweatshirt | Jumanji | 63 | 68 | 269 | loose |
| Earl Sweatshirt | Just | 22 | 21 | 164 | loose |
| Earl Sweatshirt | Kill | 39 | 58 | 357 | loose |
| Earl Sweatshirt | Kirkland | 29 | 39 | 211 | loose |
| Earl Sweatshirt | Knight | 39 | 49 | 343 | loose |
| Earl Sweatshirt | Knucklehead | 41 | 54 | 288 | loose |
| Earl Sweatshirt | Krouse 5216 | 23 | 36 | 75 | loose |
| Earl Sweatshirt | LOOK [Remix] | 26 | 21 | 160 | loose |
| Earl Sweatshirt | Landgrab | 33 | 73 | 209 | loose |
| Earl Sweatshirt | Leadbelly | 50 | 83 | 269 | loose |
| Earl Sweatshirt | Lemony Snicket* | 39 | 33 | 221 | loose |
| Earl Sweatshirt | Leppy Coqui | 61 | 45 | 293 | loose |
| Earl Sweatshirt | Live | 53 | 54 | 365 | loose |
| Earl Sweatshirt | Llama | 18 | 13 | 133 | loose |
| Earl Sweatshirt | Lobby (Int) | 23 | 32 | 92 | loose |
| Earl Sweatshirt | Location: State of Mind | 25 | 18 | 148 | loose |
| Earl Sweatshirt | Locusts | 55 | 95 | 223 | loose |
| Earl Sweatshirt | Look | 76 | 76 | 825 | loose |
| Earl Sweatshirt | Look at You | 95 | 70 | 712 | loose |
| Earl Sweatshirt | Loose Change | 26 | 20 | 124 | loose |
| Earl Sweatshirt | Loosie | 17 | 12 | 112 | loose |
| Earl Sweatshirt | Luper | 38 | 26 | 202 | loose |
| Earl Sweatshirt | Lye | 26 | 34 | 160 | loose |
| Earl Sweatshirt | MIKE & Earl Sweatshirt Deliver INSANE Freestyle on Mornings With Mero!) | 38 | 43 | 379 | loose |
| Earl Sweatshirt | MIRAGE | 109 | 78 | 534 | loose |
| Earl Sweatshirt | MTOMB | 23 | 40 | 122 | loose |
| Earl Sweatshirt | Mac Deuce | 32 | 40 | 187 | loose |
| Earl Sweatshirt | Making The Band (Danity Kane) | 29 | 95 | 67 | loose |
| Earl Sweatshirt | Mancala | 44 | 24 | 268 | loose |
| Earl Sweatshirt | Mantra | 50 | 30 | 336 | loose |
| Earl Sweatshirt | Marching In | 23 | 23 | 107 | loose |
| Earl Sweatshirt | Maybe | 42 | 41 | 84 | loose |
| Earl Sweatshirt | Mezmorized | 28 | 15 | 104 | loose |
| Earl Sweatshirt | Mirror | 30 | 13 | 225 | loose |
| Earl Sweatshirt | Mo(u)ring (OG Live) | 4 | 1 | 33 | loose |
| Earl Sweatshirt | Mo(u)rning | 25 | 27 | 170 | loose |
| Earl Sweatshirt | Molasses | 35 | 36 | 267 | loose |
| Earl Sweatshirt | Molliwopped | 28 | 38 | 219 | loose |
| Earl Sweatshirt | Moonlight | 31 | 31 | 223 | loose |
| Earl Sweatshirt | Mothership | 32 | 15 | 180 | loose |
| Earl Sweatshirt | My Brother, The Wind | 38 | 39 | 227 | loose |
| Earl Sweatshirt | NAI3M$ | 35 | 33 | 229 | loose |
| Earl Sweatshirt | NEW FACES V3. | 55 | 34 | 306 | loose |
| Earl Sweatshirt | NOT 4TW | 30 | 52 | 244 | loose |
| Earl Sweatshirt | Nebraska | 57 | 58 | 457 | loose |
| Earl Sweatshirt | New Faces v2 | 103 | 105 | 445 | loose |
| Earl Sweatshirt | New earlsweatshirt (Interlude) | 9 | 4 | 49 | loose |
| Earl Sweatshirt | Nobles | 32 | 20 | 174 | loose |
| Earl Sweatshirt | Nowhere2go | 40 | 48 | 157 | loose |
| Earl Sweatshirt | Nu Stogie | 54 | 35 | 405 | loose |
| Earl Sweatshirt | Nuclear War / King of Hearts* | 26 | 19 | 199 | loose |
| Earl Sweatshirt | OD | 28 | 34 | 114 | loose |
| Earl Sweatshirt | Off Top | 28 | 31 | 242 | loose |
| Earl Sweatshirt | Old Friend | 22 | 28 | 159 | loose |
| Earl Sweatshirt | Old Man/Meal Ticket* | 23 | 26 | 104 | loose |
| Earl Sweatshirt | Oldie | 201 | 176 | 1537 | loose |
| Earl Sweatshirt | On God | 48 | 73 | 209 | loose |
| Earl Sweatshirt | One Take | 68 | 61 | 286 | loose |
| Earl Sweatshirt | One Take [V1] | 4 | 3 | 15 | loose |
| Earl Sweatshirt | Ontheway! | 31 | 34 | 129 | loose |
| Earl Sweatshirt | Orange Juice | 65 | 41 | 517 | loose |
| Earl Sweatshirt | Out of Order | 27 | 34 | 115 | loose |
| Earl Sweatshirt | Outtheway!* | 32 | 31 | 189 | loose |
| Earl Sweatshirt | P2 | 64 | 57 | 435 | loose |
| Earl Sweatshirt | PNCINTLOFWGKTA | 63 | 55 | 641 | loose |
| Earl Sweatshirt | PROUD OF ME | 24 | 26 | 81 | loose |
| Earl Sweatshirt | Paradigm Shift | 96 | 96 | 425 | loose |
| Earl Sweatshirt | Paths | 30 | 41 | 123 | loose |
| Earl Sweatshirt | Peanut | 16 | 45 | 104 | loose |
| Earl Sweatshirt | Peculiar (Transcription 2?) | 22 | 34 | 219 | loose |
| Earl Sweatshirt | Peculiar/Seedy Motherfucker | 32 | 24 | 183 | loose |
| Earl Sweatshirt | Photographic Memories | 63 | 92 | 522 | loose |
| Earl Sweatshirt | Pico | 56 | 44 | 171 | loose |
| Earl Sweatshirt | Pigions | 61 | 51 | 689 | loose |
| Earl Sweatshirt | Play It Cool | 58 | 59 | 406 | loose |
| Earl Sweatshirt | Playing Possum | 18 | 4 | 62 | loose |
| Earl Sweatshirt | Plugged In | 48 | 51 | 379 | loose |
| Earl Sweatshirt | Pm | 24 | 48 | 132 | loose |
| Earl Sweatshirt | Polo Jeans | 63 | 65 | 463 | loose |
| Earl Sweatshirt | Post* | 52 | 51 | 255 | loose |
| Earl Sweatshirt | Pre | 59 | 37 | 299 | loose |
| Earl Sweatshirt | Pre [V1] | 15 | 13 | 51 | loose |
| Earl Sweatshirt | Psyche | 32 | 13 | 113 | loose |
| Earl Sweatshirt | Psyche [V2] | 11 | 8 | 18 | loose |
| Earl Sweatshirt | Put It On Me | 15 | 24 | 53 | loose |
| Earl Sweatshirt | RIP Tracy | 51 | 64 | 331 | loose |
| Earl Sweatshirt | Ramesses II | 73 | 63 | 368 | loose |
| Earl Sweatshirt | Ramona Park Legend Pt. 2 | 5 | 1 | 21 | loose |
| Earl Sweatshirt | Rats | 42 | 65 | 533 | loose |
| Earl Sweatshirt | React | 41 | 95 | 210 | loose |
| Earl Sweatshirt | Ready, Set, Start | 54 | 43 | 408 | loose |
| Earl Sweatshirt | Real Hiphop | 52 | 54 | 365 | loose |
| Earl Sweatshirt | Really Doe | 105 | 119 | 436 | loose |
| Earl Sweatshirt | Rebellious Shit | 23 | 21 | 278 | loose |
| Earl Sweatshirt | Red Water | 13 | 24 | 35 | loose |
| Earl Sweatshirt | Reform School | 55 | 47 | 464 | loose |
| Earl Sweatshirt | Return | 8 | 3 | 77 | loose |
| Earl Sweatshirt | Revenge of the Dreamers pt 4 | 33 | 45 | 156 | loose |
| Earl Sweatshirt | Ride Slow | 112 | 74 | 701 | loose |
| Earl Sweatshirt | Robes | 70 | 75 | 528 | loose |
| Earl Sweatshirt | Rusty | 85 | 112 | 839 | loose |
| Earl Sweatshirt | SHROOMS | 38 | 43 | 329 | loose |
| Earl Sweatshirt | SOLID SNAKE | 29 | 46 | 194 | loose |
| Earl Sweatshirt | SWAMP VERMIN // BOOGEYMAN | 32 | 48 | 79 | loose |
| Earl Sweatshirt | Sasquatch | 54 | 53 | 477 | loose |
| Earl Sweatshirt | Sense | 27 | 36 | 128 | loose |
| Earl Sweatshirt | Sentry | 59 | 95 | 212 | loose |
| Earl Sweatshirt | Serenade | 16 | 8 | 110 | loose |
| Earl Sweatshirt | Shattered Dreams | 31 | 52 | 215 | loose |
| Earl Sweatshirt | Sick! | 22 | 20 | 196 | loose |
| Earl Sweatshirt | Sirius Blac | 34 | 30 | 195 | loose |
| Earl Sweatshirt | Sisyphus | 31 | 52 | 144 | loose |
| Earl Sweatshirt | Slow Learners* | 10 | 2 | 140 | loose |
| Earl Sweatshirt | Snowing in LA | 34 | 22 | 157 | loose |
| Earl Sweatshirt | Soiree | 11 | 9 | 42 | loose |
| Earl Sweatshirt | Sores (Transcription 2) | 24 | 27 | 210 | loose |
| Earl Sweatshirt | Square | 57 | 122 | 232 | loose |
| Earl Sweatshirt | Staggered In* | 15 | 16 | 107 | loose |
| Earl Sweatshirt | Stapleton | 51 | 36 | 624 | loose |
| Earl Sweatshirt | Static | 24 | 29 | 162 | loose |
| Earl Sweatshirt | Stick-Up | 54 | 35 | 415 | loose |
| Earl Sweatshirt | Stones Throw (Transcription 2?) | 16 | 17 | 163 | loose |
| Earl Sweatshirt | Stone’s Throw | 11 | 8 | 173 | loose |
| Earl Sweatshirt | Summer | 25 | 15 | 138 | loose |
| Earl Sweatshirt | Sunday | 58 | 44 | 412 | loose |
| Earl Sweatshirt | Super Rich Kids | 45 | 36 | 240 | loose |
| Earl Sweatshirt | Swag Me Out | 86 | 71 | 412 | loose |
| Earl Sweatshirt | TISK TISK / COOKIES | 27 | 35 | 81 | loose |
| Earl Sweatshirt | TOURMALINE | 30 | 18 | 208 | loose |
| Earl Sweatshirt | Tabula Rasa | 77 | 128 | 505 | loose |
| Earl Sweatshirt | Tar Baby | 20 | 22 | 265 | loose |
| Earl Sweatshirt | Testimony | 42 | 29 | 77 | loose |
| Earl Sweatshirt | Tetanus Shots | 48 | 41 | 318 | loose |
| Earl Sweatshirt | The Bends | 25 | 18 | 169 | loose |
| Earl Sweatshirt | The Caliphate | 56 | 65 | 383 | loose |
| Earl Sweatshirt | The Daily News | 40 | 32 | 367 | loose |
| Earl Sweatshirt | The Mint | 49 | 64 | 325 | loose |
| Earl Sweatshirt | The Star Room | 64 | 85 | 423 | loose |
| Earl Sweatshirt | Thisniggaugly | 27 | 5 | 80 | loose |
| Earl Sweatshirt | Time | 2 | 0 | 17 | loose |
| Earl Sweatshirt | Titanic | 37 | 37 | 120 | loose |
| Earl Sweatshirt | Top (solo version) | 42 | 73 | 435 | loose |
| Earl Sweatshirt | Touch The Sky | 43 | 52 | 218 | loose |
| Earl Sweatshirt | Tour de France | 35 | 66 | 141 | loose |
| Earl Sweatshirt | Trappin | 49 | 44 | 96 | loose |
| Earl Sweatshirt | Truffle* | 40 | 71 | 155 | loose |
| Earl Sweatshirt | Twin Flame | 40 | 28 | 184 | loose |
| Earl Sweatshirt | Uncle Al | 16 | 16 | 157 | loose |
| Earl Sweatshirt | Underworld* | 30 | 23 | 287 | loose |
| Earl Sweatshirt | Unreleased 2 - 2025 - King of Hearts | 19 | 17 | 143 | loose |
| Earl Sweatshirt | Unreleased 2025 - Word to the Truest | 21 | 42 | 120 | loose |
| Earl Sweatshirt | V2 | 26 | 32 | 142 | loose |
| Earl Sweatshirt | VCR / Wheels | 44 | 23 | 218 | loose |
| Earl Sweatshirt | Veins | 33 | 35 | 213 | loose |
| Earl Sweatshirt | Vin Skully | 31 | 31 | 188 | loose |
| Earl Sweatshirt | Vision | 69 | 94 | 320 | loose |
| Earl Sweatshirt | Volcano | 5 | 1 | 28 | loose |
| Earl Sweatshirt | WELL DONE! | 18 | 11 | 192 | loose |
| Earl Sweatshirt | WEST | 26 | 14 | 108 | loose |
| Earl Sweatshirt | WHOLE WORLD | 46 | 46 | 263 | loose |
| Earl Sweatshirt | Wakeupfaggot | 12 | 0 | 31 | loose |
| Earl Sweatshirt | WalkOnBy | 37 | 84 | 241 | loose |
| Earl Sweatshirt | Warlord Leather | 51 | 64 | 309 | loose |
| Earl Sweatshirt | Warrior (Namaste) | 28 | 26 | 227 | loose |
| Earl Sweatshirt | Wattstax | 27 | 29 | 172 | loose |
| Earl Sweatshirt | Wearld Tour Dates | 34 | 5 | 152 | loose |
| Earl Sweatshirt | Whoa | 55 | 45 | 670 | loose |
| Earl Sweatshirt | Wind In My Sails | 37 | 22 | 229 | loose |
| Earl Sweatshirt | Wool | 52 | 40 | 324 | loose |
| Earl Sweatshirt | Word to the truest* | 35 | 59 | 111 | loose |
| Earl Sweatshirt | Words2LiveBy | 56 | 74 | 245 | loose |
| Earl Sweatshirt | Yacht Lash | 64 | 44 | 467 | loose |
| Earl Sweatshirt | You Know | 24 | 28 | 165 | loose |
| Earl Sweatshirt | ^^DODO!^^ 🦤 | 15 | 19 | 66 | loose |
| Earl Sweatshirt | agoura134 | 22 | 17 | 67 | loose |
| Earl Sweatshirt | allstar | 48 | 46 | 329 | loose |
| Earl Sweatshirt | azucar cover | 5 | 1 | 12 | loose |
| Earl Sweatshirt | boozeee | 9 | 1 | 59 | loose |
| Earl Sweatshirt | chilli | 51 | 61 | 271 | loose |
| Earl Sweatshirt | epaR | 62 | 65 | 455 | loose |
| Earl Sweatshirt | exhaust | 35 | 43 | 196 | loose |
| Earl Sweatshirt | gsw vs sac | 38 | 34 | 251 | loose |
| Earl Sweatshirt | nonchalant | 61 | 102 | 341 | loose |
| Earl Sweatshirt | paddleball | 31 | 34 | 176 | loose |
| Earl Sweatshirt | plz don’t cut my wings | 50 | 58 | 464 | loose |
| Earl Sweatshirt | quest/power | 52 | 69 | 272 | loose |
| Earl Sweatshirt | rectangle lens | 23 | 72 | 151 | loose |
| Earl Sweatshirt | silenceDArapgame | 60 | 36 | 287 | loose |
| Earl Sweatshirt | solace | 51 | 46 | 324 | loose |
| Earl Sweatshirt | the center of solace | 45 | 37 | 132 | loose |
| Earl Sweatshirt | this2shallpass | 15 | 23 | 167 | loose |
| Earl Sweatshirt | ~333~ | 26 | 50 | 101 | loose |
| Earl Sweatshirt | ¿Tu Tienes WiFi? | 40 | 62 | 275 | loose |
| Earl Sweatshirt | ‎okay maybe im sad lol #😁😋 #lsdradio | 16 | 22 | 99 | loose |
| Earl Sweatshirt | “EAST” Freestyle | 14 | 11 | 51 | loose |
