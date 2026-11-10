# BIA rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: BIA
- Songs: 158
- Bars kept (BIA lyric lines): 5439
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 19
- Canonical name: BIA.
- Credit strings: BIA.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 31799
- REPEAT pairs, recorded separately: 3630
- END rhymes: 5421
- INNER rhymes: 26378

By match:

- PERFECT: 3167 (END 855, INNER 2312)
- SLANT: 12919 (END 2093, INNER 10826)
- ASSONANCE: 15225 (END 2279, INNER 12946)
- MULTI: 488 (END 194, INNER 294)

By confidence:

- HIGH: 3171
- MED: 25500
- LOW: 3128

## Core

- Core Y: 30192
- Core N among rhyme pairs: 1607

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 14169 (44.6%)
- vowel: 15225 (47.9%)
- spelling: 1917 (6.0%)
- multi: 488 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 158 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 2783 pairs (END 307, INNER 2476). Words: no, don't, know, go, o, ho, broke, told.
2. `vow:IH` — 2380 pairs (END 287, INNER 2093). Words: bitches, bitch, think, shit, big, him, give, really.
3. `vow:EH` — 1748 pairs (END 210, INNER 1538). Words: get, when, never, gettin, left, friends, tell, said.
4. `vow:AE` — 1498 pairs (END 315, INNER 1183). Words: can't, had, back, have, can, ass, bad, man.
5. `vow:EY` — 1459 pairs (END 259, INNER 1200). Words: ain't, say, way, make, take, play, baby, day.
6. `vow:AA` — 1361 pairs (END 203, INNER 1158). Words: got, want, wanna, la, not, talkin, god, hard.
7. `vow:IY` — 1276 pairs (END 183, INNER 1093). Words: see, need, these, even, here, keep, people, d.
8. `vow:AY` — 1110 pairs (END 222, INNER 888). Words: like, why, time, fly, die, by, high, mind.
9. `vow:AH` — 774 pairs (END 100, INNER 674). Words: fuck, what, fuckin, love, trust, hundred, what's, money.
10. `slant:AA:stop` — 568 pairs (END 46, INNER 522). Words: got, not, want, gotta, top, body, god, hot.
11. `slant:IH:stop` — 466 pairs (END 80, INNER 386). Words: shit, nigga, big, dick, hit, liquor, think, whip.
12. `cmu:IY` — 435 pairs (END 17, INNER 418). Words: d, de, g, t, e, b, z, mi.
13. `cmu:OW` — 426 pairs (END 55, INNER 371). Words: no, know, go, though, ho, lo, o, show.
14. `slant:IH:sib-stop` — 385 pairs (END 51, INNER 334). Words: bitch, shit, big, dick, pick, rich, nigga, niggas.
15. `slant:AE:stop` — 382 pairs (END 95, INNER 287). Words: back, can't, had, bad, bag, mad, fat, daddy.
16. `slant:AY:stop` — 381 pairs (END 69, INNER 312). Words: like, right, might, night, type, inside, ride, light.
17. `slant:EH:nas-stop` — 314 pairs (END 7, INNER 307). Words: when, get, n, ten, let, better, said, gettin.
18. `slant:EH:stop` — 310 pairs (END 40, INNER 270). Words: get, better, said, head, let, respect, check, jet.
19. `slant:AH:nas-stop` — 308 pairs (END 26, INNER 282). Words: fuck, money, what, one, come, some, run, done.
20. `slant:AE:sib-stop` — 290 pairs (END 87, INNER 203). Words: back, ass, had, cash, racks, bad, gas, bag.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 155 pair sides, mostly spelling via spelling phonetic key, often with shit (45)
- quero — 109 pair sides, mostly vowel via spelling phonetic key, often with o (15)
- ima — 100 pair sides, mostly spelling via spelling phonetic key, often with him (20)
- contigo — 64 pair sides, mostly vowel via spelling phonetic key, often with o (10)
- gon — 63 pair sides, mostly spelling via spelling phonetic key, often with dont (10)
- tryna — 53 pair sides, mostly spelling via spelling phonetic key, often with these (7)
- niggas — 49 pair sides, mostly spelling via spelling phonetic key, often with nigga (17)
- tengo — 49 pair sides, mostly vowel via spelling phonetic key, often with though (5)
- quem — 44 pair sides, mostly spelling via spelling phonetic key, often with n (12)
- quando — 39 pair sides, mostly vowel via spelling phonetic key, often with o (8)
- tudo — 37 pair sides, mostly vowel via spelling phonetic key, often with o (6)
- pelo — 32 pair sides, mostly vowel via spelling phonetic key, often with o (3)
- nisso — 31 pair sides, mostly vowel via spelling phonetic key, often with cio (3)
- gente — 24 pair sides, mostly spelling via spelling phonetic key, often with n (7)
- quiero — 24 pair sides, mostly vowel via spelling phonetic key, often with no (5)
- cuando — 24 pair sides, mostly vowel via spelling phonetic key, often with tengo (3)
- penso — 24 pair sides, mostly vowel via spelling phonetic key, often with o (6)
- sono — 24 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- mami — 23 pair sides, mostly spelling via spelling phonetic key, often with back (2)
- lado — 23 pair sides, mostly vowel via spelling phonetic key, often with no (3)
- fungshway — 23 pair sides, mostly spelling via spelling phonetic key, often with shway (7)
- wraith — 21 pair sides, mostly spelling via spelling phonetic key, often with made (3)
- tenho — 21 pair sides, mostly vowel via spelling phonetic key, often with o (3)
- consigo — 21 pair sides, mostly vowel via spelling phonetic key, often with contigo (5)
- esa — 19 pair sides, mostly spelling via spelling phonetic key, often with s (4)
- uelo — 19 pair sides, mostly vowel via spelling phonetic key, often with pelo (2)
- suelo — 19 pair sides, mostly vowel via spelling phonetic key, often with pelo (2)
- nello — 19 pair sides, mostly vowel via spelling phonetic key, often with duecento (1)
- eso — 18 pair sides, mostly spelling via spelling phonetic key, often with est (2)
- prendo — 18 pair sides, mostly vowel via spelling phonetic key, often with no (6)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| BIA | #CHOLASEASON | 7 | 7 | 32 | loose |
| BIA | +44 | 27 | 29 | 141 | loose |
| BIA | ..FEISTY | 25 | 13 | 73 | loose |
| BIA | 808 | 27 | 24 | 61 | loose |
| BIA | AUTOMATIC | 54 | 51 | 326 | loose |
| BIA | AWAKE | 26 | 25 | 173 | loose |
| BIA | BAD GUY | 36 | 19 | 212 | loose |
| BIA | BEACH BALL | 33 | 31 | 164 | loose |
| BIA | BESITO | 38 | 37 | 189 | loose |
| BIA | BEST ON EARTH | 34 | 30 | 198 | loose |
| BIA | BIA BIA | 22 | 19 | 118 | loose |
| BIA | BIG BUSINESS | 30 | 53 | 122 | loose |
| BIA | BIG DEAL | 35 | 39 | 157 | loose |
| BIA | BIRTHDAY BEHAVIOR | 36 | 36 | 189 | loose |
| BIA | BLUE BANK | 26 | 18 | 118 | loose |
| BIA | BOTH | 35 | 29 | 138 | loose |
| BIA | BRING IT ON | 33 | 42 | 80 | loose |
| BIA | Badside | 32 | 23 | 215 | loose |
| BIA | Bamba | 52 | 60 | 334 | loose |
| BIA | Bitch Duh (Remix) | 50 | 63 | 367 | loose |
| BIA | Bo$$day | 12 | 16 | 96 | loose |
| BIA | Bobby Brown | 33 | 30 | 109 | loose |
| BIA | Buy What U Want | 45 | 35 | 345 | loose |
| BIA | CAN’T TOUCH THIS | 24 | 20 | 109 | loose |
| BIA | CAN’T TOUCH THIS (R3HAB Remix) [Mixed] | 4 | 0 | 3 | loose |
| BIA | CARBONE FREESTYLE | 32 | 31 | 219 | loose |
| BIA | CARPET | 43 | 45 | 254 | loose |
| BIA | CHATTY | 46 | 39 | 237 | loose |
| BIA | CHICKY TA | 39 | 25 | 330 | loose |
| BIA | CLASSY | 23 | 25 | 97 | loose |
| BIA | COOKIE | 3 | 0 | 14 | loose |
| BIA | COVER GIRL | 32 | 42 | 126 | loose |
| BIA | CRAZY | 33 | 33 | 83 | loose |
| BIA | Can’t Get Enough | 46 | 48 | 254 | loose |
| BIA | Chain Swang | 50 | 45 | 281 | loose |
| BIA | Clouds | 38 | 21 | 143 | loose |
| BIA | Come When I Call | 24 | 11 | 44 | loose |
| BIA | DADE | 26 | 27 | 274 | loose |
| BIA | DIRTY BITCH | 22 | 13 | 63 | loose |
| BIA | DON’T TELL | 39 | 39 | 228 | loose |
| BIA | DROWN IN MY CUP | 12 | 9 | 49 | loose |
| BIA | DUBAI | 56 | 78 | 306 | loose |
| BIA | Disturbia (Feat. BIA) | 49 | 76 | 136 | loose |
| BIA | Eat It Up | 32 | 19 | 153 | loose |
| BIA | Energy | 30 | 13 | 75 | loose |
| BIA | Entendido! | 23 | 10 | 269 | loose |
| BIA | Esta Noche | 30 | 57 | 150 | loose |
| BIA | Expressing Myself | 60 | 45 | 193 | loose |
| BIA | FALLBACK | 31 | 35 | 190 | loose |
| BIA | FOUR SEASONS | 21 | 14 | 130 | loose |
| BIA | FREAK IN THE NIGHT | 34 | 47 | 149 | loose |
| BIA | FREE BIA (1ST DAY OUT) | 38 | 45 | 87 | loose |
| BIA | FREE MASON | 21 | 15 | 94 | loose |
| BIA | Facts | 55 | 97 | 306 | loose |
| BIA | Forever | 23 | 21 | 69 | loose |
| BIA | Freak (Remix) | 29 | 33 | 70 | loose |
| BIA | Fungshway | 33 | 40 | 159 | loose |
| BIA | Furious | 8 | 5 | 50 | loose |
| BIA | GBAD (Remix) | 48 | 29 | 100 | loose |
| BIA | GEEKALEEK (Remix) | 41 | 52 | 231 | loose |
| BIA | GUAVA | 35 | 29 | 94 | loose |
| BIA | Girls Cypher | 76 | 27 | 855 | loose |
| BIA | Glossed Up | 43 | 53 | 187 | loose |
| BIA | Good Idea | 45 | 37 | 217 | loose |
| BIA | Gucci Comin Home | 23 | 27 | 197 | loose |
| BIA | HARD WAY | 27 | 15 | 121 | loose |
| BIA | HOLLYWOOD | 27 | 27 | 115 | loose |
| BIA | Handful | 23 | 29 | 44 | loose |
| BIA | Harlem | 49 | 35 | 126 | loose |
| BIA | High | 22 | 9 | 124 | loose |
| BIA | I Like Dat | 71 | 55 | 260 | loose |
| BIA | ICEY.. | 12 | 9 | 20 | loose |
| BIA | Is That Right | 42 | 40 | 252 | loose |
| BIA | It’s You | 18 | 8 | 49 | loose |
| BIA | I’M THAT BITCH | 38 | 39 | 117 | loose |
| BIA | I’m Geekin (Remix) | 57 | 96 | 237 | loose |
| BIA | LIFELINE | 46 | 91 | 180 | loose |
| BIA | LIGHTS OUT | 39 | 28 | 270 | loose |
| BIA | LONDON | 74 | 72 | 463 | loose |
| BIA | La Tirana | 25 | 14 | 60 | loose |
| BIA | Labels. | 27 | 19 | 181 | loose |
| BIA | Labels. / Juicy (Mixed) | 25 | 6 | 148 | loose |
| BIA | Like That | 16 | 8 | 29 | loose |
| BIA | Like Yoga | 56 | 93 | 195 | loose |
| BIA | Likka Sto 2 | 78 | 83 | 446 | loose |
| BIA | MILANO | 45 | 54 | 268 | loose |
| BIA | MILLIONS | 30 | 29 | 124 | loose |
| BIA | MOTIONLESS | 28 | 20 | 225 | loose |
| BIA | Mami | 40 | 14 | 190 | loose |
| BIA | Mi Naturaleza | 30 | 16 | 150 | loose |
| BIA | Miami | 31 | 26 | 209 | loose |
| BIA | NWFA | 23 | 15 | 155 | loose |
| BIA | Nasty Girl | 29 | 32 | 114 | loose |
| BIA | Navegando | 40 | 38 | 643 | loose |
| BIA | No Type (Freestyle) | 22 | 42 | 95 | loose |
| BIA | OCTOBER | 12 | 3 | 63 | loose |
| BIA | OH NO | 19 | 18 | 74 | loose |
| BIA | OMG | 42 | 37 | 147 | loose |
| BIA | ONE MINUTE WARNING | 20 | 16 | 55 | loose |
| BIA | ONE THING | 39 | 29 | 275 | loose |
| BIA | PISSED OFF | 42 | 42 | 180 | loose |
| BIA | PLATE | 31 | 21 | 207 | loose |
| BIA | PRAY FOR YOU | 32 | 39 | 74 | loose |
| BIA | PRIVATE | 25 | 23 | 103 | loose |
| BIA | PRO BONO | 4 | 5 | 31 | loose |
| BIA | Perfect (Remix) | 48 | 58 | 166 | loose |
| BIA | Piñata | 42 | 30 | 164 | loose |
| BIA | RAISE THE STAKES | 43 | 79 | 126 | loose |
| BIA | READY SET | 23 | 27 | 104 | loose |
| BIA | ROLLIN | 35 | 52 | 115 | loose |
| BIA | Raised Me | 39 | 62 | 160 | loose |
| BIA | Remember Me | 38 | 24 | 114 | loose |
| BIA | Rumors | 11 | 8 | 25 | loose |
| BIA | Run | 67 | 90 | 369 | loose |
| BIA | SAD PARTY | 35 | 24 | 96 | loose |
| BIA | SAME HANDS | 37 | 106 | 118 | loose |
| BIA | SIXTEEN | 28 | 40 | 207 | loose |
| BIA | SKATE | 33 | 53 | 254 | loose |
| BIA | SKATE (Sara Landry Remix) [Mixed] | 9 | 2 | 51 | loose |
| BIA | SUE MEEE¿ | 42 | 34 | 194 | loose |
| BIA | SUPABIEN | 35 | 25 | 89 | loose |
| BIA | Safari | 25 | 10 | 147 | loose |
| BIA | Sangria Wine | 23 | 15 | 78 | loose |
| BIA | Savage (Remix) | 27 | 17 | 73 | loose |
| BIA | Schizo | 37 | 9 | 61 | loose |
| BIA | Seashell | 56 | 50 | 192 | loose |
| BIA | Solitude | 23 | 22 | 39 | loose |
| BIA | Street Opera | 80 | 109 | 318 | loose |
| BIA | Sturdy* | 15 | 16 | 93 | loose |
| BIA | Super Freaky Girl (Queen Mix) | 90 | 99 | 422 | loose |
| BIA | Suéltate | 33 | 15 | 100 | loose |
| BIA | TRIFLING | 43 | 39 | 213 | loose |
| BIA | TWIN | 30 | 45 | 66 | loose |
| BIA | Trampoline | 36 | 41 | 177 | loose |
| BIA | U N I T Y | 78 | 85 | 427 | loose |
| BIA | Unknown2023 | 13 | 5 | 45 | loose |
| BIA | Untitled | 5 | 1 | 4 | loose |
| BIA | VIBES ON ME | 34 | 27 | 94 | loose |
| BIA | Vamos | 19 | 13 | 85 | loose |
| BIA | Vício- Feat BIA | 20 | 25 | 311 | loose |
| BIA | WE ON GO | 31 | 26 | 98 | loose |
| BIA | WE ON GO II | 30 | 37 | 279 | loose |
| BIA | WE ON GO III | 14 | 10 | 86 | loose |
| BIA | WHOLE LOTTA MONEY (Remix) | 41 | 39 | 232 | loose |
| BIA | Waiting On Me | 51 | 51 | 224 | loose |
| BIA | Way 2 High (Cut It) | 59 | 42 | 216 | loose |
| BIA | When You Are Down | 20 | 12 | 74 | loose |
| BIA | Whip it | 63 | 92 | 254 | loose |
| BIA | X6 | 37 | 23 | 268 | loose |
| BIA | YAKWTFGO | 29 | 37 | 126 | loose |
| BIA | Yeah | 31 | 38 | 144 | loose |
| BIA | Young | 29 | 26 | 129 | loose |
| BIA | a woman is a god (BIA Remix) | 34 | 46 | 103 | loose |
| BIA | back it up (Remix) | 45 | 43 | 192 | loose |
| BIA | fine shyt | 34 | 38 | 218 | loose |
| BIA | jaded | 33 | 36 | 148 | loose |
| BIA | more | 38 | 25 | 139 | loose |
| BIA | ‌boy | 44 | 42 | 100 | loose |
