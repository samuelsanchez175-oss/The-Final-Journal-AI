# BossMan Dlow rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: BossMan Dlow
- Songs: 142
- Bars kept (BossMan Dlow lyric lines): 4233
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 9
- Canonical name: BossMan Dlow.
- Credit strings: BossMan Dlow.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 32948
- REPEAT pairs, recorded separately: 3842
- END rhymes: 3558
- INNER rhymes: 29390

By match:

- PERFECT: 2028 (END 400, INNER 1628)
- SLANT: 14773 (END 1511, INNER 13262)
- ASSONANCE: 15991 (END 1596, INNER 14395)
- MULTI: 156 (END 51, INNER 105)

By confidence:

- HIGH: 1980
- MED: 28583
- LOW: 2385

## Core

- Core Y: 32596
- Core N among rhyme pairs: 352

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 14562 (44.2%)
- vowel: 15991 (48.5%)
- spelling: 2239 (6.8%)
- multi: 156 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 142 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 2781 pairs (END 295, INNER 2486). Words: bitch, shit, bitches, wrist, chicken, big, fifty, business.
2. `vow:EY` — 2214 pairs (END 253, INNER 1961). Words: ain't, baby, say, play, way, make, day, take.
3. `vow:OW` — 1790 pairs (END 120, INNER 1670). Words: don't, know, no, go, broke, motion, ho, hoes.
4. `vow:AH` — 1781 pairs (END 194, INNER 1587). Words: hundred, fuck, fuckin, somethin, some, come, money, love.
5. `vow:AE` — 1738 pairs (END 220, INNER 1518). Words: can't, ass, trap, can, bad, havin, racks, back.
6. `vow:EH` — 1703 pairs (END 141, INNER 1562). Words: get, gettin, when, left, went, let's, every, spent.
7. `slant:IH:stop` — 1375 pairs (END 144, INNER 1231). Words: nigga, shit, big, hit, wrist, dick, jit, city.
8. `vow:AA` — 1225 pairs (END 94, INNER 1131). Words: got, nothin, want, talkin, pockets, wanna, boss, hard.
9. `vow:AY` — 1015 pairs (END 69, INNER 946). Words: like, bae, diamonds, drivin, buy, time, ridin, why.
10. `vow:IY` — 986 pairs (END 91, INNER 895). Words: see, even, these, need, here, keep, real, streets.
11. `slant:IH:sib-stop` — 866 pairs (END 111, INNER 755). Words: bitch, shit, nigga, niggas, big, rich, hit, dick.
12. `slant:AA:stop` — 567 pairs (END 38, INNER 529). Words: got, want, gotta, pocket, pop, drop, top, not.
13. `slant:AH:nas-stop` — 522 pairs (END 17, INNER 505). Words: fuck, money, come, some, what, one, fuckin, run.
14. `slant:EH:stop` — 520 pairs (END 42, INNER 478). Words: get, better, left, check, twenty, neck, let, spent.
15. `slant:EY:stop` — 482 pairs (END 71, INNER 411). Words: baby, make, ain't, take, straight, made, wait, hate.
16. `slant:AE:stop` — 455 pairs (END 54, INNER 401). Words: back, bad, trap, bag, can't, had, fat, black.
17. `slant:AE:sib-stop` — 441 pairs (END 38, INNER 403). Words: ass, back, bad, bag, cash, catch, fat, black.
18. `slant:AH:nas` — 390 pairs (END 34, INNER 356). Words: money, some, come, runnin, run, fuckin, one, done.
19. `slant:IH:nas-stop` — 361 pairs (END 11, INNER 350). Words: shit, i'ma, him, big, hit, bring, everything, thing.
20. `cmu:OW` — 321 pairs (END 21, INNER 300). Words: know, no, go, ho, show, throw, low, though.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 1077 pair sides, mostly spelling via spelling phonetic key, often with shit (266)
- niggas — 255 pair sides, mostly spelling via spelling phonetic key, often with nigga (180)
- ima — 240 pair sides, mostly spelling via spelling phonetic key, often with bitch (40)
- tryna — 111 pair sides, mostly spelling via spelling phonetic key, often with these (12)
- gon — 109 pair sides, mostly spelling via spelling phonetic key, often with dont (19)
- jit — 92 pair sides, mostly spelling via spelling phonetic key, often with nigga (26)
- dlow — 29 pair sides, mostly spelling via spelling phonetic key, often with know (15)
- finna — 25 pair sides, mostly vowel via spelling phonetic key, often with nigga (6)
- shawty — 23 pair sides, mostly vowel via spelling phonetic key, often with nasty (3)
- thuggin — 22 pair sides, mostly spelling via spelling phonetic key, often with nothin (4)
- lik — 21 pair sides, mostly spelling via spelling phonetic key, often with nigga (11)
- meds — 19 pair sides, mostly spelling via spelling phonetic key, often with bread (2)
- runtz — 18 pair sides, mostly vowel via spelling phonetic key, often with fuck (2)
- wraith — 18 pair sides, mostly spelling via spelling phonetic key, often with aint (3)
- bling — 18 pair sides, mostly spelling via spelling phonetic key, often with wrist (4)
- maybach — 14 pair sides, mostly spelling via spelling phonetic key, often with baby (11)
- doin — 14 pair sides, mostly spelling via spelling phonetic key, often with goin (5)
- whipper — 13 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)
- birkin — 13 pair sides, mostly vowel via spelling phonetic key, often with shit (3)
- twerk — 13 pair sides, mostly spelling via vault phonetic_class, often with purpose (3)
- sexyy — 12 pair sides, mostly spelling via spelling phonetic key, often with sexy (4)
- rari — 11 pair sides, mostly spelling via spelling phonetic key, often with ran (1)
- dazy — 11 pair sides, mostly spelling via spelling phonetic key, often with bad (3)
- punters — 10 pair sides, mostly vowel via spelling phonetic key, often with numbers (2)
- blicky — 9 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- slayed — 9 pair sides, mostly spelling via spelling phonetic key, often with baby (5)
- carti — 8 pair sides, mostly spelling via spelling phonetic key, often with car (3)
- jeezy — 8 pair sides, mostly spelling via spelling phonetic key, often with need (2)
- weezy — 8 pair sides, mostly spelling via spelling phonetic key, often with need (2)
- kickstartin — 8 pair sides, mostly vowel via spelling phonetic key, often with shit (3)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| BossMan Dlow | 2 Slippery | 28 | 8 | 226 | loose |
| BossMan Dlow | 21 | 29 | 18 | 211 | loose |
| BossMan Dlow | 22 | 24 | 11 | 146 | loose |
| BossMan Dlow | 392 | 34 | 46 | 260 | loose |
| BossMan Dlow | 46th Street | 20 | 10 | 175 | loose |
| BossMan Dlow | 4AM at Coffee Zone (Florida Avengers) | 43 | 65 | 420 | loose |
| BossMan Dlow | 99 Problems | 20 | 10 | 143 | loose |
| BossMan Dlow | Act Like Money | 12 | 11 | 68 | loose |
| BossMan Dlow | Ain’t Easy | 42 | 24 | 379 | loose |
| BossMan Dlow | Ain’t Goin | 39 | 38 | 376 | loose |
| BossMan Dlow | Aye Yea | 43 | 50 | 183 | loose |
| BossMan Dlow | Bad Bitch Alarm | 39 | 27 | 197 | loose |
| BossMan Dlow | Big | 25 | 12 | 182 | loose |
| BossMan Dlow | Big Dawg Status | 38 | 32 | 277 | loose |
| BossMan Dlow | Big One | 21 | 21 | 133 | loose |
| BossMan Dlow | Big Za | 34 | 25 | 273 | loose |
| BossMan Dlow | Blue Hunnids | 27 | 18 | 280 | loose |
| BossMan Dlow | Booby Trap On The River | 33 | 11 | 221 | loose |
| BossMan Dlow | Boss Talk | 26 | 30 | 188 | loose |
| BossMan Dlow | Bout My Money | 38 | 20 | 296 | loose |
| BossMan Dlow | Boxing Night | 44 | 26 | 347 | loose |
| BossMan Dlow | Brick Man (Remix) | 25 | 29 | 156 | loose |
| BossMan Dlow | Bubble Up | 33 | 10 | 194 | loose |
| BossMan Dlow | Can’t Leave You Alone | 42 | 52 | 329 | loose |
| BossMan Dlow | Cash Shit | 20 | 25 | 151 | loose |
| BossMan Dlow | Cheat Codes | 40 | 35 | 331 | loose |
| BossMan Dlow | Check Callin | 21 | 13 | 153 | loose |
| BossMan Dlow | Chick-fil-A | 33 | 41 | 295 | loose |
| BossMan Dlow | Chicken Talkin Bastard | 32 | 25 | 220 | loose |
| BossMan Dlow | Chicken* | 14 | 7 | 46 | loose |
| BossMan Dlow | Come Here | 39 | 32 | 211 | loose |
| BossMan Dlow | Count Money | 37 | 74 | 311 | loose |
| BossMan Dlow | Creed | 26 | 41 | 152 | loose |
| BossMan Dlow | Cut Ties | 46 | 50 | 205 | loose |
| BossMan Dlow | Das Dat Nerve | 17 | 24 | 100 | loose |
| BossMan Dlow | Dats That Nerve | 6 | 6 | 26 | loose |
| BossMan Dlow | Dlow Curry | 28 | 17 | 182 | loose |
| BossMan Dlow | Dlow Flintstone | 20 | 9 | 155 | loose |
| BossMan Dlow | Dlow Gucci | 20 | 9 | 157 | loose |
| BossMan Dlow | Do Numbers | 34 | 42 | 227 | loose |
| BossMan Dlow | Dogshit Talker | 20 | 11 | 137 | loose |
| BossMan Dlow | Don’t Change For Us | 35 | 22 | 158 | loose |
| BossMan Dlow | Dopeman | 21 | 14 | 136 | loose |
| BossMan Dlow | Dove | 23 | 18 | 164 | loose |
| BossMan Dlow | Exotic | 32 | 29 | 269 | loose |
| BossMan Dlow | Finesse (Remix) | 28 | 27 | 189 | loose |
| BossMan Dlow | Flat | 25 | 30 | 80 | loose |
| BossMan Dlow | Flood | 31 | 17 | 142 | loose |
| BossMan Dlow | Fly Girl | 20 | 19 | 126 | loose |
| BossMan Dlow | For Days | 24 | 32 | 102 | loose |
| BossMan Dlow | FreeKat | 53 | 38 | 382 | loose |
| BossMan Dlow | Game Winner | 26 | 25 | 219 | loose |
| BossMan Dlow | Gas Money | 23 | 12 | 170 | loose |
| BossMan Dlow | Get In With Me | 20 | 15 | 126 | loose |
| BossMan Dlow | Get Stretched | 18 | 14 | 102 | loose |
| BossMan Dlow | Goddess | 27 | 28 | 180 | loose |
| BossMan Dlow | Got It | 36 | 32 | 162 | loose |
| BossMan Dlow | Heating Up | 18 | 15 | 127 | loose |
| BossMan Dlow | Hit | 33 | 19 | 179 | loose |
| BossMan Dlow | Homebody (Remix) | 58 | 40 | 377 | loose |
| BossMan Dlow | How I’m Livin | 20 | 11 | 199 | loose |
| BossMan Dlow | I Can’t Wait | 53 | 52 | 359 | loose |
| BossMan Dlow | I Fell Off | 44 | 30 | 440 | loose |
| BossMan Dlow | I Put On | 39 | 53 | 191 | loose |
| BossMan Dlow | I4 Music | 32 | 33 | 289 | loose |
| BossMan Dlow | ION WANNA HEAR IT | 27 | 32 | 136 | loose |
| BossMan Dlow | Iceberg | 25 | 17 | 239 | loose |
| BossMan Dlow | In My Pockets (Remix) | 39 | 31 | 285 | loose |
| BossMan Dlow | Intro | 48 | 29 | 406 | loose |
| BossMan Dlow | Is Money | 39 | 54 | 431 | loose |
| BossMan Dlow | I’m Him | 16 | 19 | 122 | loose |
| BossMan Dlow | Kick The Door Down | 30 | 22 | 275 | loose |
| BossMan Dlow | Kreepin Through The Streetz Freestyle | 3 | 0 | 10 | loose |
| BossMan Dlow | Let’s Go Get Em | 18 | 4 | 66 | loose |
| BossMan Dlow | Like Dat | 20 | 6 | 117 | loose |
| BossMan Dlow | Like This | 48 | 68 | 415 | loose |
| BossMan Dlow | Lil Bastard | 34 | 24 | 271 | loose |
| BossMan Dlow | Lil Nigga | 53 | 63 | 520 | loose |
| BossMan Dlow | Met The Plug | 34 | 37 | 225 | loose |
| BossMan Dlow | Mike Smiff | 29 | 21 | 212 | loose |
| BossMan Dlow | Mo Chicken | 31 | 54 | 137 | loose |
| BossMan Dlow | Money Over Bitches | 26 | 24 | 138 | loose |
| BossMan Dlow | Money Talks | 24 | 5 | 165 | loose |
| BossMan Dlow | Motion | 18 | 10 | 125 | loose |
| BossMan Dlow | Motion Party | 26 | 6 | 162 | loose |
| BossMan Dlow | Mr Pot Scraper | 23 | 9 | 126 | loose |
| BossMan Dlow | Muscle Up | 12 | 9 | 92 | loose |
| BossMan Dlow | Naked Hustle | 31 | 21 | 68 | loose |
| BossMan Dlow | Need You Beside Me | 31 | 45 | 249 | loose |
| BossMan Dlow | Nothin Like Me | 22 | 18 | 214 | loose |
| BossMan Dlow | OUTTA TOWN | 30 | 21 | 221 | loose |
| BossMan Dlow | Obama Runtz | 37 | 50 | 350 | loose |
| BossMan Dlow | Oh Shit | 32 | 14 | 152 | loose |
| BossMan Dlow | On The Radar Freestyle | 23 | 25 | 154 | loose |
| BossMan Dlow | Out The Mud | 24 | 17 | 178 | loose |
| BossMan Dlow | PJ | 38 | 21 | 233 | loose |
| BossMan Dlow | Parmesan | 29 | 28 | 199 | loose |
| BossMan Dlow | Phil Jackson | 30 | 17 | 213 | loose |
| BossMan Dlow | Pillsbury Dlow | 32 | 17 | 304 | loose |
| BossMan Dlow | Piss Me Off | 25 | 22 | 194 | loose |
| BossMan Dlow | Plays of the Week | 25 | 14 | 148 | loose |
| BossMan Dlow | Plenty Motion | 20 | 16 | 174 | loose |
| BossMan Dlow | Pop My Shit | 34 | 30 | 305 | loose |
| BossMan Dlow | Pressure | 19 | 6 | 53 | loose |
| BossMan Dlow | Pressure 2 (Shawty You Pressure) | 29 | 20 | 319 | loose |
| BossMan Dlow | Pull Up | 37 | 39 | 230 | loose |
| BossMan Dlow | Pushin Up | 35 | 13 | 154 | loose |
| BossMan Dlow | Real Trapper | 23 | 21 | 126 | loose |
| BossMan Dlow | Resurrect the Trap | 32 | 15 | 227 | loose |
| BossMan Dlow | Right Now | 36 | 28 | 270 | loose |
| BossMan Dlow | Rotation | 34 | 25 | 224 | loose |
| BossMan Dlow | Rules | 50 | 25 | 342 | loose |
| BossMan Dlow | Run It Up | 27 | 23 | 145 | loose |
| BossMan Dlow | STEP | 45 | 45 | 362 | loose |
| BossMan Dlow | STOP SNITCHIN (YouTube Visualizer Version) | 15 | 9 | 65 | loose |
| BossMan Dlow | STOP SNITCHING | 64 | 74 | 317 | loose |
| BossMan Dlow | SUSPECT | 31 | 41 | 284 | loose |
| BossMan Dlow | Same24 | 31 | 35 | 138 | loose |
| BossMan Dlow | See The World | 46 | 47 | 331 | loose |
| BossMan Dlow | Self Made | 20 | 8 | 163 | loose |
| BossMan Dlow | Shake Dat Ass (Twerk Song) | 35 | 29 | 153 | loose |
| BossMan Dlow | Shake Dat Ass (Twerk Song) [Remix] | 39 | 30 | 187 | loose |
| BossMan Dlow | Shake It | 31 | 21 | 252 | loose |
| BossMan Dlow | SportsCenter | 26 | 12 | 203 | loose |
| BossMan Dlow | Star Life | 22 | 15 | 158 | loose |
| BossMan Dlow | Starter Pack | 32 | 16 | 179 | loose |
| BossMan Dlow | Sum Out Of Nun | 30 | 13 | 177 | loose |
| BossMan Dlow | Talk My Shit | 18 | 3 | 159 | loose |
| BossMan Dlow | Tendernism | 32 | 23 | 196 | loose |
| BossMan Dlow | The Biggest | 22 | 9 | 92 | loose |
| BossMan Dlow | The Biggest Pt. 2 | 36 | 38 | 194 | loose |
| BossMan Dlow | Top Notch | 30 | 41 | 184 | loose |
| BossMan Dlow | Traplete (Remix) | 30 | 30 | 273 | loose |
| BossMan Dlow | Trippin | 22 | 18 | 141 | loose |
| BossMan Dlow | Tweakin | 6 | 1 | 20 | loose |
| BossMan Dlow | Up | 24 | 20 | 151 | loose |
| BossMan Dlow | What You Need | 46 | 35 | 366 | loose |
| BossMan Dlow | Worth a Ticket | 32 | 18 | 203 | loose |
| BossMan Dlow | XXL Freshman Freestyle: BossMan Dlow | 12 | 5 | 91 | loose |
| BossMan Dlow | XXL Freshmen 2024 Cypher - Part 1 | 46 | 57 | 382 | loose |
| BossMan Dlow | You So Pressure | 35 | 29 | 135 | loose |
| BossMan Dlow | Za Plates | 16 | 11 | 126 | loose |
