# Offset rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Offset
- Songs: 182
- Bars kept (Offset lyric lines): 7078
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 9
- Canonical name: Offset.
- Credit strings: Offset.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 41646
- REPEAT pairs, recorded separately: 3522
- END rhymes: 9803
- INNER rhymes: 31843

By match:

- PERFECT: 3535 (END 1273, INNER 2262)
- SLANT: 18069 (END 4111, INNER 13958)
- ASSONANCE: 19652 (END 4279, INNER 15373)
- MULTI: 390 (END 140, INNER 250)

By confidence:

- HIGH: 3611
- MED: 35421
- LOW: 2614

## Core

- Core Y: 40997
- Core N among rhyme pairs: 649

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 19328 (46.4%)
- vowel: 19652 (47.2%)
- spelling: 2276 (5.5%)
- multi: 390 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 4 songs
- ABAB: 1 songs
- loose: 177 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 3141 pairs (END 448, INNER 2693). Words: bitch, bitches, shit, wrist, million, think, hit, rich.
2. `vow:OW` — 2620 pairs (END 462, INNER 2158). Words: don't, know, no, go, told, hoes, ho, dope.
3. `vow:AA` — 2212 pairs (END 428, INNER 1784). Words: got, want, top, not, cost, nothin, pockets, poppin.
4. `vow:AE` — 2192 pairs (END 544, INNER 1648). Words: can't, had, back, racks, bands, can, bad, man.
5. `vow:EY` — 1862 pairs (END 511, INNER 1351). Words: ain't, way, say, play, take, make, k, face.
6. `vow:EH` — 1861 pairs (END 318, INNER 1543). Words: get, when, never, bentley, left, gettin, spend, m's.
7. `vow:IY` — 1538 pairs (END 507, INNER 1031). Words: see, three, these, keep, even, streets, people, eat.
8. `vow:AY` — 1423 pairs (END 289, INNER 1134). Words: like, diamonds, fire, by, why, buy, time, high.
9. `vow:AH` — 1387 pairs (END 269, INNER 1118). Words: hundred, money, fuck, one, bust, what, double, somethin.
10. `slant:AA:stop` — 1168 pairs (END 142, INNER 1026). Words: got, gotta, not, want, top, bought, body, pop.
11. `slant:IH:stop` — 935 pairs (END 108, INNER 827). Words: nigga, shit, hit, big, dick, stick, wrist, lick.
12. `slant:IH:sib-stop` — 722 pairs (END 144, INNER 578). Words: bitch, shit, nigga, niggas, hit, rich, dick, big.
13. `slant:AE:stop` — 567 pairs (END 141, INNER 426). Words: back, had, bad, bag, trap, can't, fact, rat.
14. `slant:EH:stop` — 480 pairs (END 78, INNER 402). Words: get, head, check, better, let, neck, left, respect.
15. `slant:AH:nas-stop` — 455 pairs (END 30, INNER 425). Words: fuck, money, what, come, one, some, done, run.
16. `slant:IY:stop` — 436 pairs (END 189, INNER 247). Words: keep, sleep, eat, geeked, feet, beat, need, speak.
17. `slant:IY:sib-stop` — 431 pairs (END 210, INNER 221). Words: these, keep, eat, beat, feet, teeth, sleep, beach.
18. `vow:AO` — 413 pairs (END 120, INNER 293). Words: all, lost, north, walkin, talk, vault, border, walk.
19. `cmu:OW` — 409 pairs (END 74, INNER 335). Words: know, go, no, ho, show, hoe, low, blow.
20. `slant:AH:nas` — 408 pairs (END 44, INNER 364). Words: money, some, young, come, run, one, runnin, done.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 488 pair sides, mostly spelling via spelling phonetic key, often with niggas (100)
- ima — 214 pair sides, mostly spelling via spelling phonetic key, often with shit (30)
- niggas — 183 pair sides, mostly spelling via spelling phonetic key, often with nigga (100)
- tryna — 145 pair sides, mostly spelling via spelling phonetic key, often with keep (21)
- gon — 117 pair sides, mostly spelling via spelling phonetic key, often with dont (41)
- migo — 55 pair sides, mostly spelling via spelling phonetic key, often with bitch (5)
- shawty — 54 pair sides, mostly spelling via spelling phonetic key, often with all (4)
- bando — 50 pair sides, mostly vowel via spelling phonetic key, often with no (6)
- geeked — 45 pair sides, mostly spelling via spelling phonetic key, often with sleep (5)
- lambo — 39 pair sides, mostly vowel via spelling phonetic key, often with no (9)
- dawg — 38 pair sides, mostly spelling via spelling phonetic key, often with gone (6)
- thot — 38 pair sides, mostly spelling via spelling phonetic key, often with dont (6)
- wraith — 37 pair sides, mostly spelling via spelling phonetic key, often with take (5)
- bros — 35 pair sides, mostly spelling via spelling phonetic key, often with hoes (5)
- birkin — 27 pair sides, mostly vowel via spelling phonetic key, often with bitch (7)
- hol — 21 pair sides, mostly vowel via vault phonetic_class, often with column (4)
- pics — 20 pair sides, mostly vowel via spelling phonetic key, often with bitch (2)
- nawf — 19 pair sides, mostly spelling via spelling phonetic key, often with all (4)
- rari — 18 pair sides, mostly spelling via spelling phonetic key, often with back (3)
- fam — 18 pair sides, mostly spelling via spelling phonetic key, often with can (3)
- lyin — 17 pair sides, mostly vowel via vault phonetic_class, often with see (2)
- chapo — 15 pair sides, mostly vowel via spelling phonetic key, often with go (2)
- chos — 15 pair sides, mostly spelling via spelling phonetic key, often with hoes (3)
- blicky — 15 pair sides, mostly spelling via spelling phonetic key, often with sticky (3)
- meeny — 15 pair sides, mostly vowel via spelling phonetic key, often with eeny (4)
- eeny — 14 pair sides, mostly vowel via spelling phonetic key, often with meeny (4)
- opps — 13 pair sides, mostly vowel via spelling phonetic key, often with told (4)
- imma — 11 pair sides, mostly spelling via spelling phonetic key, often with bring (3)
- thots — 11 pair sides, mostly vowel via spelling phonetic key, often with dont (3)
- adderall — 11 pair sides, mostly vowel via spelling phonetic key, often with all (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Offset | 10 X Outta 10* | 33 | 65 | 364 | loose |
| Offset | 100 Bricks | 70 | 84 | 251 | loose |
| Offset | 1st Day Out | 33 | 39 | 171 | loose |
| Offset | 54321 | 51 | 67 | 262 | loose |
| Offset | ANOTHER PROBLEM | 48 | 61 | 285 | loose |
| Offset | ANTISOCIAL | 33 | 44 | 137 | loose |
| Offset | ATL* | 5 | 4 | 13 | ABAB |
| Offset | After Dark | 37 | 40 | 205 | loose |
| Offset | All Of My Hoes | 30 | 23 | 142 | loose |
| Offset | Ask Somebody | 67 | 118 | 111 | loose |
| Offset | Athlete | 37 | 41 | 141 | loose |
| Offset | Auto | 60 | 94 | 243 | loose |
| Offset | Aww Man | 5 | 1 | 21 | loose |
| Offset | BIG DAWG | 37 | 42 | 160 | loose |
| Offset | BLAME IT ON SET | 48 | 43 | 238 | loose |
| Offset | BROAD DAY | 40 | 33 | 274 | loose |
| Offset | BUSS MY WATCH | 38 | 38 | 117 | loose |
| Offset | Back In That Mode | 60 | 107 | 347 | loose |
| Offset | Backends Fasho | 40 | 53 | 219 | loose |
| Offset | Bad Like Mike | 49 | 80 | 130 | loose |
| Offset | Ball Player | 17 | 29 | 106 | loose |
| Offset | Bay* | 8 | 10 | 40 | loose |
| Offset | Beat It | 22 | 47 | 159 | loose |
| Offset | Big Bank Take Lil Bank* | 70 | 79 | 170 | loose |
| Offset | Bodies | 62 | 72 | 412 | loose |
| Offset | CODE | 54 | 60 | 309 | loose |
| Offset | Calories | 39 | 46 | 146 | loose |
| Offset | Came a Long Way | 42 | 89 | 295 | loose |
| Offset | Cash Now* | 32 | 65 | 251 | loose |
| Offset | Chanel | 33 | 38 | 116 | loose |
| Offset | Checkmate (Smooth) | 48 | 83 | 216 | loose |
| Offset | Cinco de Mayo | 90 | 103 | 450 | loose |
| Offset | Clout | 68 | 85 | 207 | loose |
| Offset | DISSOLVE | 43 | 42 | 149 | loose |
| Offset | DON’T YOU LIE | 41 | 81 | 211 | loose |
| Offset | DOPE BOY | 45 | 71 | 153 | loose |
| Offset | DOUBLED UP | 16 | 23 | 58 | loose |
| Offset | Damage (Up My Status) | 57 | 82 | 190 | loose |
| Offset | Danger* (Alsiyadun) | 25 | 59 | 112 | AAAA |
| Offset | Diamonds | 24 | 21 | 74 | loose |
| Offset | Different Breed* | 15 | 15 | 76 | loose |
| Offset | Different Shit | 33 | 29 | 108 | loose |
| Offset | Different Species | 43 | 59 | 122 | loose |
| Offset | Diplomat | 35 | 60 | 202 | loose |
| Offset | Dirty Diana* | 13 | 11 | 82 | loose |
| Offset | Don’t Lose Me | 59 | 113 | 129 | loose |
| Offset | Double (Original) | 38 | 54 | 127 | loose |
| Offset | Double R* | 48 | 59 | 242 | loose |
| Offset | Double Up | 20 | 33 | 75 | loose |
| Offset | Dragons | 68 | 155 | 351 | loose |
| Offset | Drip (Demo) | 58 | 133 | 240 | loose |
| Offset | Duffle Bag | 26 | 16 | 86 | loose |
| Offset | Dumb or Slow | 6 | 8 | 25 | loose |
| Offset | Eenie Meenie | 31 | 45 | 415 | loose |
| Offset | Enemies | 42 | 56 | 227 | loose |
| Offset | Extra | 36 | 62 | 102 | loose |
| Offset | FAN | 40 | 56 | 226 | loose |
| Offset | FASHION ICON | 41 | 46 | 244 | loose |
| Offset | FINE AS CAN BE | 68 | 119 | 256 | loose |
| Offset | FREAKY | 45 | 31 | 213 | loose |
| Offset | FREE PICK | 16 | 16 | 273 | loose |
| Offset | Father of 4 | 52 | 52 | 265 | loose |
| Offset | Favorite Girl | 27 | 34 | 81 | loose |
| Offset | First 48 | 40 | 91 | 154 | AAAA |
| Offset | First Day Out | 8 | 2 | 27 | loose |
| Offset | Folgers | 40 | 49 | 195 | loose |
| Offset | Formula | 27 | 38 | 123 | loose |
| Offset | Frozen | 18 | 29 | 42 | loose |
| Offset | Glitch | 20 | 25 | 186 | loose |
| Offset | Gold Bottles | 38 | 37 | 111 | loose |
| Offset | HAUNTED BY FAME | 42 | 45 | 212 | loose |
| Offset | HEADHUNTER | 27 | 31 | 168 | loose |
| Offset | HEALTHY | 12 | 16 | 134 | loose |
| Offset | HOP OUT THE VAN | 19 | 17 | 46 | loose |
| Offset | History | 32 | 60 | 136 | loose |
| Offset | Hit Em Hard | 68 | 69 | 294 | loose |
| Offset | Hit The Gas | 41 | 44 | 207 | loose |
| Offset | Hot Spot* | 41 | 33 | 94 | loose |
| Offset | How Did I Get Here | 85 | 97 | 317 | loose |
| Offset | How Did We Get Here? | 41 | 39 | 105 | loose |
| Offset | I HEARD | 49 | 51 | 267 | loose |
| Offset | Impossible | 38 | 28 | 203 | loose |
| Offset | In Her Throat | 31 | 65 | 67 | loose |
| Offset | I’M ON | 38 | 48 | 212 | loose |
| Offset | JEALOUSY | 79 | 94 | 351 | loose |
| Offset | Juug Season | 22 | 22 | 79 | loose |
| Offset | Legacy | 81 | 83 | 354 | loose |
| Offset | Lick | 45 | 71 | 289 | loose |
| Offset | Line It Up* | 35 | 37 | 147 | loose |
| Offset | Love You Down | 31 | 31 | 153 | loose |
| Offset | Made Men | 75 | 150 | 243 | loose |
| Offset | Make It Right | 26 | 22 | 104 | loose |
| Offset | Man Down | 70 | 40 | 278 | loose |
| Offset | Marvin The Martian | 32 | 54 | 114 | loose |
| Offset | Millionaire* | 53 | 51 | 201 | loose |
| Offset | Mix | 41 | 48 | 141 | loose |
| Offset | Monday | 37 | 55 | 141 | loose |
| Offset | Mourning* | 39 | 41 | 128 | loose |
| Offset | Move On | 27 | 32 | 78 | loose |
| Offset | My Choices | 50 | 48 | 217 | loose |
| Offset | My Ice Is Wet (Fast and the Furious) | 61 | 68 | 166 | loose |
| Offset | N.A.M.E | 34 | 32 | 242 | loose |
| Offset | NIGHT VISION | 36 | 76 | 281 | loose |
| Offset | NO REGRETS | 23 | 20 | 132 | loose |
| Offset | NO SWEAT | 27 | 31 | 51 | loose |
| Offset | Need Some More | 17 | 14 | 156 | loose |
| Offset | Never Let Go | 21 | 21 | 126 | loose |
| Offset | New Year | 76 | 113 | 367 | loose |
| Offset | New Years Eve | 8 | 11 | 29 | loose |
| Offset | Nightmare | 28 | 39 | 143 | loose |
| Offset | No Option | 33 | 54 | 135 | loose |
| Offset | No Pressure (Bomboclaat) | 51 | 98 | 102 | loose |
| Offset | No Trust | 29 | 45 | 203 | loose |
| Offset | North Star | 62 | 71 | 282 | loose |
| Offset | OKAY, OKAY | 28 | 49 | 86 | loose |
| Offset | ON THE RIVER | 31 | 61 | 121 | loose |
| Offset | Offset | Funk Flex | #Freestyle203 | 49 | 59 | 233 | loose |
| Offset | Offset4* | 4 | 0 | 16 | loose |
| Offset | Okay* | 8 | 3 | 38 | loose |
| Offset | On Fleek | 70 | 142 | 211 | loose |
| Offset | One Shot, Two Shot | 29 | 44 | 141 | loose |
| Offset | Oprah Winfrey | 70 | 91 | 306 | loose |
| Offset | P.I.M.P. (Smooth Criminal) | 55 | 89 | 338 | loose |
| Offset | PRINCESS CUT | 65 | 90 | 248 | loose |
| Offset | Pain* | 15 | 24 | 55 | AAAA |
| Offset | Patience | 9 | 10 | 27 | loose |
| Offset | Patty Cake* | 39 | 53 | 151 | loose |
| Offset | Percs | 32 | 53 | 149 | loose |
| Offset | Pills | 70 | 88 | 289 | loose |
| Offset | Pink Toes (Demo) | 52 | 98 | 269 | loose |
| Offset | Playing For Keeps* | 30 | 29 | 62 | loose |
| Offset | Plot | 31 | 54 | 225 | loose |
| Offset | Pop (Hell of a Night) | 54 | 93 | 212 | loose |
| Offset | Power Moves | 26 | 36 | 68 | loose |
| Offset | Prada Myself | 29 | 55 | 87 | loose |
| Offset | Professional | 48 | 85 | 209 | loose |
| Offset | Pull Up In A Foreign* | 24 | 32 | 144 | loose |
| Offset | Quarter Milli | 50 | 61 | 219 | loose |
| Offset | ROCK OUT | 27 | 28 | 130 | loose |
| Offset | Rags To Riches* | 15 | 37 | 33 | loose |
| Offset | Red Room | 79 | 197 | 295 | loose |
| Offset | Ric Flair Drip | 34 | 20 | 167 | loose |
| Offset | Ric Flair Drip Remix | 40 | 32 | 152 | loose |
| Offset | Rooster | 41 | 90 | 108 | loose |
| Offset | Run To The Money | 28 | 54 | 138 | loose |
| Offset | Run Up My Money | 41 | 33 | 151 | loose |
| Offset | Runnin Up Da Money | 4 | 1 | 25 | loose |
| Offset | SAY MY GRACE | 48 | 99 | 385 | loose |
| Offset | SKYAMI | 65 | 119 | 319 | loose |
| Offset | SOS (Sticks) | 18 | 33 | 62 | loose |
| Offset | Safaree | 40 | 36 | 175 | loose |
| Offset | Save The World (Thoughts) | 17 | 28 | 39 | loose |
| Offset | See What I’m Saying* | 33 | 30 | 322 | loose |
| Offset | Set It Off | 20 | 16 | 100 | loose |
| Offset | Snake | 40 | 61 | 118 | loose |
| Offset | Snakes In The Grass | 31 | 25 | 69 | loose |
| Offset | Snowflakes* | 15 | 19 | 46 | loose |
| Offset | Solitaire | 8 | 1 | 18 | loose |
| Offset | Str8 Drop | 66 | 74 | 326 | loose |
| Offset | Stuck | 50 | 62 | 180 | loose |
| Offset | Style Rare | 48 | 48 | 241 | loose |
| Offset | Swing My Way | 36 | 47 | 133 | loose |
| Offset | TEN | 22 | 14 | 100 | loose |
| Offset | Tats on My Face | 66 | 144 | 141 | loose |
| Offset | Tequila | 42 | 92 | 118 | loose |
| Offset | Threat | 27 | 61 | 147 | loose |
| Offset | Too Deep | 29 | 48 | 123 | loose |
| Offset | Too Easy (Original) | 55 | 114 | 193 | loose |
| Offset | Truck Loads | 50 | 49 | 185 | loose |
| Offset | Truth Be Told* | 18 | 37 | 130 | AAAA |
| Offset | UPSIDE DOWN | 21 | 31 | 64 | loose |
| Offset | Underrated | 44 | 65 | 261 | loose |
| Offset | Uon Want Problems | 40 | 58 | 308 | loose |
| Offset | WORTH IT | 38 | 38 | 234 | loose |
| Offset | Walk Outside | 47 | 55 | 100 | loose |
| Offset | Wet Wet | 29 | 27 | 204 | loose |
| Offset | When U Grow Up | 32 | 36 | 149 | loose |
| Offset | Whole Lotta* | 5 | 3 | 55 | loose |
| Offset | Wild Wild West | 64 | 111 | 335 | loose |
| Offset | Work | 53 | 73 | 164 | loose |
| Offset | World Guinness (Wrist on Froze)* | 79 | 105 | 433 | loose |
| Offset | YA DIGG | 34 | 43 | 208 | loose |
