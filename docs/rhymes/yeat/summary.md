# Yeat rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Yeat
- Songs: 1219
- Bars kept (Yeat lyric lines): 35028
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 73
- Canonical name: Yeat.
- Credit strings: Yeat.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 215296
- REPEAT pairs, recorded separately: 36460
- END rhymes: 36424
- INNER rhymes: 178872

By match:

- PERFECT: 19741 (END 6413, INNER 13328)
- SLANT: 94371 (END 15302, INNER 79069)
- ASSONANCE: 99010 (END 13835, INNER 85175)
- MULTI: 2174 (END 874, INNER 1300)

By confidence:

- HIGH: 20306
- MED: 183256
- LOW: 11734

## Core

- Core Y: 211761
- Core N among rhyme pairs: 3535

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 104309 (48.4%)
- vowel: 99010 (46.0%)
- spelling: 9803 (4.6%)
- multi: 2174 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 13 songs
- AABB: 1 songs
- ABCB: 1 songs
- AABA: 1 songs
- ABAA: 2 songs
- loose: 1201 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 15674 pairs (END 1605, INNER 14069). Words: bitch, shit, think, bitches, kids, lil, really, wrist.
2. `vow:OW` — 13889 pairs (END 1178, INNER 12711). Words: don't, no, know, go, told, broke, whole, won't.
3. `vow:EH` — 11769 pairs (END 1356, INNER 10413). Words: x, get, when, went, said, every, tell, myself.
4. `vow:AY` — 10788 pairs (END 1750, INNER 9038). Words: like, high, diamonds, why, time, die, try, life.
5. `vow:EY` — 8460 pairs (END 1407, INNER 7053). Words: ain't, say, way, day, make, take, stay, made.
6. `vow:AE` — 8314 pairs (END 1380, INNER 6934). Words: can't, racks, bands, back, bag, had, can, ass.
7. `vow:AH` — 8296 pairs (END 1212, INNER 7084). Words: money, drugs, fuck, what, some, fuckin, love, trust.
8. `vow:IY` — 7879 pairs (END 1464, INNER 6415). Words: even, see, these, need, feel, nobody, twizzy, keep.
9. `vow:AA` — 7692 pairs (END 708, INNER 6984). Words: got, want, not, talkin, tonka, nothin, oxy, pockets.
10. `slant:AA:stop` — 5128 pairs (END 450, INNER 4678). Words: got, not, want, gotta, top, body, rock, lot.
11. `slant:IH:sib-stop` — 5116 pairs (END 700, INNER 4416). Words: bitch, shit, hit, rich, big, dick, kid, miss.
12. `slant:AH:nas-stop` — 3581 pairs (END 260, INNER 3321). Words: fuck, what, money, some, one, come, done, fuckin.
13. `slant:IH:stop` — 3067 pairs (END 426, INNER 2641). Words: shit, big, dick, hit, kid, nigga, crib, wrist.
14. `slant:EH:stop` — 2820 pairs (END 397, INNER 2423). Words: get, said, head, went, let, better, bread, jet.
15. `slant:IH:liq-stop` — 2637 pairs (END 74, INNER 2563). Words: shit, lil, really, still, big, hit, kid, dick.
16. `cmu:OW` — 2620 pairs (END 463, INNER 2157). Words: know, no, go, show, ho, low, bro, blow.
17. `slant:AE:stop` — 2523 pairs (END 612, INNER 1911). Words: back, bag, can't, had, bad, fact, act, sad.
18. `slant:IH:liq-sib` — 2395 pairs (END 78, INNER 2317). Words: bitch, lil, really, still, rich, year, kill, pill.
19. `slant:EH:nas-stop` — 2318 pairs (END 174, INNER 2144). Words: when, get, again, said, many, ten, went, head.
20. `slant:EH:liq-stop` — 2217 pairs (END 179, INNER 2038). Words: get, tell, said, hell, where, care, swear, head.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 1120 pair sides, mostly spelling via spelling phonetic key, often with dont (399)
- ima — 1041 pair sides, mostly spelling via spelling phonetic key, often with bitch (315)
- twizzy — 803 pair sides, mostly vowel via spelling phonetic key, often with bitch (175)
- tryna — 364 pair sides, mostly spelling via spelling phonetic key, often with these (42)
- yeat — 345 pair sides, mostly spelling via spelling phonetic key, often with feel (28)
- swag — 319 pair sides, mostly spelling via spelling phonetic key, often with cant (32)
- nigga — 317 pair sides, mostly spelling via spelling phonetic key, often with shit (65)
- shawty — 250 pair sides, mostly vowel via spelling phonetic key, often with all (44)
- wock — 207 pair sides, mostly vowel via spelling phonetic key, often with dont (49)
- geeked — 201 pair sides, mostly spelling via spelling phonetic key, often with need (19)
- tris — 196 pair sides, mostly spelling via spelling phonetic key, often with bitch (40)
- lyin — 182 pair sides, mostly spelling via spelling phonetic key, often with these (24)
- twizz — 157 pair sides, mostly spelling via spelling phonetic key, often with bitch (44)
- thot — 146 pair sides, mostly spelling via spelling phonetic key, often with got (33)
- bih — 121 pair sides, mostly spelling via spelling phonetic key, often with bitch (30)
- twerk — 99 pair sides, mostly spelling via spelling phonetic key, often with earth (11)
- niggas — 93 pair sides, mostly spelling via spelling phonetic key, often with nigga (49)
- finna — 89 pair sides, mostly spelling via spelling phonetic key, often with ima (13)
- blicky — 89 pair sides, mostly spelling via spelling phonetic key, often with shit (7)
- chanelly — 81 pair sides, mostly vowel via spelling phonetic key, often with really (8)
- muhfuckin — 81 pair sides, mostly spelling via spelling phonetic key, often with fuckin (14)
- trackhawk — 80 pair sides, mostly vowel via spelling phonetic key, often with cant (12)
- guap — 78 pair sides, mostly spelling via spelling phonetic key, often with money (11)
- hunnid — 73 pair sides, mostly vowel via spelling phonetic key, often with fuckin (7)
- blicks — 72 pair sides, mostly vowel via spelling phonetic key, often with bitch (15)
- dyin — 68 pair sides, mostly spelling via spelling phonetic key, often with these (11)
- geekin — 67 pair sides, mostly spelling via spelling phonetic key, often with week (8)
- ine — 58 pair sides, mostly spelling via spelling phonetic key, often with bitch (10)
- wifey — 58 pair sides, mostly spelling via spelling phonetic key, often with bitch (15)
- swervin — 57 pair sides, mostly spelling via spelling phonetic key, often with fuckin (12)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Yeat | #Wassup | 44 | 39 | 154 | loose |
| Yeat | $OLD | 44 | 48 | 145 | loose |
| Yeat | (Duplicate 3) | 26 | 18 | 144 | loose |
| Yeat | (N)INE | 17 | 10 | 32 | loose |
| Yeat | 1.5 / GLEski* | 7 | 4 | 46 | loose |
| Yeat | 10 Bones | 28 | 24 | 224 | loose |
| Yeat | 100 Rackocets | 46 | 22 | 354 | loose |
| Yeat | 105 | 42 | 38 | 328 | loose |
| Yeat | 1093 | 41 | 68 | 105 | loose |
| Yeat | 1st Hunnid | 40 | 36 | 206 | loose |
| Yeat | 1st Off .... | 63 | 108 | 349 | loose |
| Yeat | 1st of my kind | 40 | 42 | 189 | loose |
| Yeat | 1st thing 1st | 30 | 55 | 98 | loose |
| Yeat | 2 Kut Off | 36 | 40 | 240 | loose |
| Yeat | 2 Me Freestyle | 34 | 60 | 161 | loose |
| Yeat | 2 Much (2020) | 9 | 6 | 25 | loose |
| Yeat | 2 Up | 44 | 93 | 160 | loose |
| Yeat | 2 be honest | 42 | 36 | 273 | loose |
| Yeat | 2 in | 32 | 36 | 189 | loose |
| Yeat | 2093 | 17 | 5 | 31 | loose |
| Yeat | 24/7 | 34 | 39 | 152 | loose |
| Yeat | 293842341 | 5 | 3 | 14 | loose |
| Yeat | 293842341 (Time Again V3 Outro) | 3 | 0 | 9 | loose |
| Yeat | 2HIGH | 17 | 5 | 74 | loose |
| Yeat | 2Nite | 26 | 11 | 105 | loose |
| Yeat | 2Planës | 36 | 24 | 184 | loose |
| Yeat | 2TONE | 39 | 39 | 136 | loose |
| Yeat | 2Up / Bad Boy Remix | 43 | 45 | 214 | loose |
| Yeat | 2day | 33 | 13 | 139 | loose |
| Yeat | 2day / Today | 48 | 76 | 324 | loose |
| Yeat | 2lite | 17 | 13 | 81 | loose |
| Yeat | 2turnty (Extortion) | 29 | 53 | 136 | loose |
| Yeat | 2x2 | 45 | 76 | 143 | loose |
| Yeat | 2x2 Pt 2 | 20 | 27 | 139 | loose |
| Yeat | 3093* / Big body* | 6 | 7 | 13 | loose |
| Yeat | 3AM | 26 | 35 | 121 | loose |
| Yeat | 3G | 52 | 35 | 118 | loose |
| Yeat | 4 AND A 5 | 24 | 13 | 66 | loose |
| Yeat | 4 Nun (Freezing) | 38 | 44 | 236 | loose |
| Yeat | 4LY | 30 | 19 | 113 | loose |
| Yeat | 5 2 Üh 60 | 36 | 43 | 197 | loose |
| Yeat | 5 Planës | 38 | 63 | 263 | loose |
| Yeat | 5BRAZY | 26 | 22 | 124 | loose |
| Yeat | 5BRAZY REMIX | 25 | 20 | 186 | loose |
| Yeat | 5am on x freestyle | 26 | 22 | 89 | loose |
| Yeat | 66 nitës | 14 | 7 | 120 | loose |
| Yeat | 7 nightz | 39 | 37 | 174 | loose |
| Yeat | ADDICTED | 30 | 39 | 151 | loose |
| Yeat | AMG C63 | 47 | 64 | 119 | loose |
| Yeat | AR / Lamb* | 4 | 1 | 1 | loose |
| Yeat | AWAY FROM IT | 37 | 18 | 130 | loose |
| Yeat | Actin Üp | 21 | 19 | 181 | loose |
| Yeat | Addict In General* | 11 | 10 | 24 | loose |
| Yeat | Admit It | 56 | 63 | 240 | loose |
| Yeat | Again | 40 | 60 | 171 | loose |
| Yeat | Aint Enough | 21 | 21 | 153 | loose |
| Yeat | Aint Shit Change | 51 | 46 | 395 | loose |
| Yeat | Aint Try (Tried Once) | 25 | 17 | 165 | loose |
| Yeat | Aint Us | 34 | 41 | 163 | loose |
| Yeat | Aint worried | 28 | 27 | 139 | loose |
| Yeat | Aint worried v2 | 10 | 0 | 74 | loose |
| Yeat | Ain’t Tried Once | 12 | 11 | 124 | loose |
| Yeat | Ain’t nothing | 41 | 43 | 336 | loose |
| Yeat | Alien Hi | 6 | 2 | 24 | loose |
| Yeat | Alien Language | 47 | 45 | 132 | loose |
| Yeat | All 4 Nothin | 42 | 35 | 240 | loose |
| Yeat | All Day | 24 | 44 | 123 | loose |
| Yeat | All Daë | 30 | 39 | 123 | loose |
| Yeat | All Different | 35 | 45 | 216 | loose |
| Yeat | All I See | 42 | 57 | 213 | loose |
| Yeat | All I Think About | 13 | 6 | 56 | loose |
| Yeat | All I Think Bout | 17 | 12 | 67 | loose |
| Yeat | All Lies | 34 | 36 | 210 | loose |
| Yeat | All Season | 36 | 50 | 288 | loose |
| Yeat | All Typëz Changëd | 17 | 15 | 70 | loose |
| Yeat | All UP | 35 | 34 | 173 | loose |
| Yeat | All fax | 52 | 60 | 270 | loose |
| Yeat | All i got | 45 | 55 | 207 | loose |
| Yeat | All of it | 57 | 68 | 244 | loose |
| Yeat | All tha way | 43 | 42 | 300 | loose |
| Yeat | All typëz | 28 | 47 | 207 | loose |
| Yeat | All wëek | 31 | 33 | 299 | loose |
| Yeat | Allah high (Big tonka) | 56 | 70 | 161 | loose |
| Yeat | Alot on my mind | 36 | 58 | 343 | loose |
| Yeat | Already Rich | 27 | 11 | 156 | loose |
| Yeat | Already Said It | 29 | 34 | 191 | loose |
| Yeat | Alright | 37 | 50 | 171 | loose |
| Yeat | Always Alivë | 36 | 39 | 189 | loose |
| Yeat | Always Try* | 8 | 2 | 27 | loose |
| Yeat | Appear | 32 | 22 | 230 | loose |
| Yeat | Ard Up (Already Rich Original) | 3 | 0 | 14 | loose |
| Yeat | Are You? | 29 | 35 | 130 | loose |
| Yeat | Are you serious (Siri*) | 4 | 3 | 19 | loose |
| Yeat | As We Speak | 57 | 65 | 276 | loose |
| Yeat | Atm | 47 | 39 | 210 | loose |
| Yeat | Attack | 41 | 25 | 136 | loose |
| Yeat | Autopilot | 43 | 22 | 161 | loose |
| Yeat | B light | 32 | 51 | 218 | loose |
| Yeat | B!RTHDAY | 28 | 28 | 154 | loose |
| Yeat | BABYDRAKE | 37 | 46 | 387 | loose |
| Yeat | BACK THËN | 28 | 25 | 122 | loose |
| Yeat | BACKWARD | 42 | 37 | 184 | loose |
| Yeat | BAND$ | 31 | 32 | 213 | loose |
| Yeat | BARBARIAN | 43 | 49 | 149 | loose |
| Yeat | BARBARIAN REMIX | 4 | 1 | 14 | loose |
| Yeat | BATMAN VS SUPERMAN | 37 | 49 | 214 | loose |
| Yeat | BEEN AROUND | 16 | 17 | 17 | loose |
| Yeat | BIG DOGGY | 8 | 2 | 22 | loose |
| Yeat | BLOOD ON THE FIELD | 24 | 11 | 55 | loose |
| Yeat | BO$$ (Snippet) | 4 | 1 | 14 | loose |
| Yeat | BRIGHTS ON | 6 | 2 | 42 | loose |
| Yeat | Baby Bria* | 11 | 5 | 85 | loose |
| Yeat | Back 2 basics* (2023) | 6 | 2 | 19 | loose |
| Yeat | Back Den | 37 | 68 | 227 | loose |
| Yeat | Back Home | 35 | 43 | 192 | loose |
| Yeat | Back homë | 19 | 30 | 134 | loose |
| Yeat | Back up | 29 | 36 | 105 | loose |
| Yeat | Backends | 29 | 37 | 96 | loose |
| Yeat | Backroads | 34 | 26 | 159 | loose |
| Yeat | Bad | 32 | 45 | 93 | loose |
| Yeat | Bad Bend | 32 | 23 | 209 | loose |
| Yeat | Bad Dream | 33 | 24 | 150 | loose |
| Yeat | Bad Night* | 2 | 0 | 0 | loose |
| Yeat | Bad bënd / DëMON | 35 | 35 | 162 | loose |
| Yeat | Bag Getters | 16 | 8 | 109 | loose |
| Yeat | Bak Outside | 31 | 38 | 148 | loose |
| Yeat | Bak in town | 31 | 48 | 120 | loose |
| Yeat | Bak on ëm | 33 | 27 | 136 | loose |
| Yeat | Bak onna X | 24 | 19 | 139 | loose |
| Yeat | Ball On Em 2 | 16 | 2 | 56 | loose |
| Yeat | Ball Wit Us | 23 | 17 | 137 | loose |
| Yeat | Balënci Feet | 44 | 77 | 332 | loose |
| Yeat | Band or 2 | 39 | 50 | 414 | loose |
| Yeat | Bankroll / How U Feel? | 31 | 35 | 113 | loose |
| Yeat | Bankrollëy | 5 | 4 | 29 | loose |
| Yeat | Barbados | 44 | 62 | 389 | loose |
| Yeat | Barnëy | 36 | 43 | 241 | loose |
| Yeat | Been Off | 59 | 78 | 279 | loose |
| Yeat | Best for me | 25 | 44 | 115 | loose |
| Yeat | Big Boy Racks | 24 | 14 | 121 | loose |
| Yeat | Big Geek Week | 32 | 17 | 156 | loose |
| Yeat | Big Hey | 39 | 39 | 229 | loose |
| Yeat | Big Kiid | 45 | 65 | 226 | loose |
| Yeat | Big Stonëz | 40 | 33 | 131 | loose |
| Yeat | Big Trunk | 29 | 24 | 136 | loose |
| Yeat | Big bëntly | 19 | 39 | 87 | loose |
| Yeat | Big money in my backpack | 3 | 0 | 38 | loose |
| Yeat | Bird | 52 | 69 | 271 | loose |
| Yeat | Birds in da skye* | 5 | 0 | 6 | loose |
| Yeat | Bizzy | 37 | 57 | 329 | loose |
| Yeat | Boot Up Sum | 28 | 60 | 116 | loose |
| Yeat | Booted | 27 | 35 | 178 | loose |
| Yeat | Bootup | 32 | 43 | 176 | loose |
| Yeat | Bootup Bible* | 8 | 7 | 71 | loose |
| Yeat | Bopster | 38 | 60 | 194 | loose |
| Yeat | Bought The Earth | 43 | 41 | 153 | loose |
| Yeat | Box | 9 | 25 | 26 | AAAA |
| Yeat | Brand New | 25 | 24 | 154 | loose |
| Yeat | Brand New #YUP | 17 | 28 | 59 | AAAA |
| Yeat | Brang it in | 26 | 24 | 132 | loose |
| Yeat | Brazie | 13 | 7 | 69 | loose |
| Yeat | Breakfast | 14 | 13 | 78 | loose |
| Yeat | Breaking News | 37 | 110 | 96 | AAAA |
| Yeat | Breathe | 38 | 40 | 147 | loose |
| Yeat | Bring It In | 29 | 40 | 173 | loose |
| Yeat | Brink! | 26 | 48 | 170 | loose |
| Yeat | Brëëzy 3 | 40 | 64 | 152 | loose |
| Yeat | Built Different | 24 | 16 | 121 | loose |
| Yeat | Busted Balmain | 48 | 41 | 143 | loose |
| Yeat | Buyin Shit | 47 | 38 | 208 | loose |
| Yeat | BË QUIET | 46 | 19 | 231 | loose |
| Yeat | Bäk 2 BED | 42 | 74 | 325 | loose |
| Yeat | Bëd Side | 45 | 50 | 343 | loose |
| Yeat | Bëtter Lyfe | 38 | 50 | 312 | loose |
| Yeat | Bëttr 0ff | 40 | 41 | 377 | loose |
| Yeat | C3NTURY | 3 | 0 | 4 | loose |
| Yeat | CANT GET THAT | 46 | 27 | 220 | loose |
| Yeat | CANT GO BACK | 4 | 1 | 3 | loose |
| Yeat | CANT SEE | 31 | 22 | 103 | loose |
| Yeat | CANT WASTE NO TIME | 39 | 39 | 105 | loose |
| Yeat | CAN’T B ME | 36 | 30 | 173 | loose |
| Yeat | CC | 17 | 12 | 129 | loose |
| Yeat | COKE | 44 | 65 | 196 | loose |
| Yeat | COME INSIDE* | 4 | 3 | 4 | loose |
| Yeat | COMË N GO | 44 | 26 | 148 | loose |
| Yeat | CRASH OUT | 22 | 4 | 57 | loose |
| Yeat | Cali | 43 | 27 | 155 | loose |
| Yeat | Call Up : Opiates | 50 | 61 | 139 | loose |
| Yeat | Call më | 41 | 43 | 251 | loose |
| Yeat | Callin me (4L) | 26 | 34 | 190 | loose |
| Yeat | Callin më | 42 | 32 | 130 | loose |
| Yeat | Cant Complain | 36 | 32 | 219 | loose |
| Yeat | Cant Get Up | 23 | 18 | 217 | loose |
| Yeat | Cant Keep Pushing it | 28 | 26 | 140 | loose |
| Yeat | Cant go | 22 | 31 | 113 | loose |
| Yeat | Cant go 4 it | 13 | 12 | 79 | loose |
| Yeat | Cant see in | 30 | 32 | 179 | loose |
| Yeat | Cant trust me | 33 | 22 | 104 | loose |
| Yeat | Can’t Love | 4 | 0 | 7 | loose |
| Yeat | Can’t Remember | 40 | 46 | 324 | loose |
| Yeat | Can’t See HOOK [Trippie Redd Remix] | 4 | 1 | 25 | loose |
| Yeat | Can’t Think | 24 | 35 | 126 | loose |
| Yeat | Can’t stop it | 26 | 31 | 126 | loose |
| Yeat | Cap To Me | 28 | 32 | 247 | loose |
| Yeat | Cayenne outside | 34 | 31 | 163 | loose |
| Yeat | Cayenne outsidë (Remix) | 23 | 36 | 78 | loose |
| Yeat | Celine | 38 | 41 | 115 | loose |
| Yeat | Chains | 26 | 25 | 136 | loose |
| Yeat | Change | 41 | 80 | 147 | loose |
| Yeat | Chanëlly | 35 | 35 | 185 | loose |
| Yeat | Christmas | 27 | 50 | 243 | loose |
| Yeat | Circle Back | 27 | 30 | 96 | loose |
| Yeat | Cmon | 14 | 9 | 76 | loose |
| Yeat | Codeine Vybing | 26 | 25 | 143 | loose |
| Yeat | Come Again | 16 | 18 | 42 | loose |
| Yeat | Comin In | 4 | 0 | 8 | loose |
| Yeat | Comin! | 28 | 18 | 133 | loose |
| Yeat | Complicated | 39 | 36 | 207 | loose |
| Yeat | Comë Again | 15 | 0 | 39 | loose |
| Yeat | Comë on | 42 | 48 | 300 | loose |
| Yeat | Condo | 43 | 55 | 195 | loose |
| Yeat | Condo On The Moon | 24 | 30 | 92 | loose |
| Yeat | Convertible | 73 | 95 | 344 | loose |
| Yeat | Cooperate* | 6 | 10 | 54 | loose |
| Yeat | Cop My Style (feat. Yeat) | 61 | 29 | 282 | loose |
| Yeat | Corona virus | 17 | 17 | 111 | loose |
| Yeat | Count it up | 32 | 19 | 151 | loose |
| Yeat | Crashëd dat bitch | 30 | 31 | 201 | loose |
| Yeat | Crashëd tha jet | 23 | 15 | 169 | loose |
| Yeat | Crime | 22 | 22 | 88 | loose |
| Yeat | Cruisin’ | 52 | 18 | 86 | loose |
| Yeat | Cullinan* | 15 | 23 | 39 | loose |
| Yeat | Curtains | 9 | 18 | 17 | AAAA |
| Yeat | Cöld World | 33 | 39 | 213 | loose |
| Yeat | Cöme Down | 30 | 28 | 160 | loose |
| Yeat | Cöming Down | 25 | 29 | 149 | loose |
| Yeat | D I E | 20 | 17 | 117 | loose |
| Yeat | DAILY | 16 | 29 | 78 | AAAA |
| Yeat | DAMAGE | 31 | 26 | 144 | loose |
| Yeat | DANGEROUSLY | 34 | 19 | 127 | loose |
| Yeat | DAYS GO BY | 36 | 26 | 199 | loose |
| Yeat | DEAD SPIRITS | 51 | 80 | 208 | loose |
| Yeat | DISEASE | 37 | 41 | 140 | loose |
| Yeat | DOG HOUSE | 43 | 37 | 219 | loose |
| Yeat | DOWN | 42 | 52 | 181 | loose |
| Yeat | DROPTOP | 13 | 9 | 112 | loose |
| Yeat | Dangerous House | 38 | 33 | 77 | loose |
| Yeat | Dangerous stuff* | 3 | 1 | 8 | loose |
| Yeat | Dead Man | 56 | 47 | 263 | loose |
| Yeat | Dead Rising | 41 | 36 | 307 | loose |
| Yeat | Dead2Me Interlude | 32 | 21 | 66 | loose |
| Yeat | Deep Blue / Trendsetter (Original) | 57 | 66 | 172 | loose |
| Yeat | Demenos Theios | 24 | 8 | 183 | loose |
| Yeat | Demon | 51 | 56 | 183 | loose |
| Yeat | Detour | 30 | 22 | 123 | loose |
| Yeat | Diamond Teeth | 4 | 2 | 4 | loose |
| Yeat | Diamonds on me | 8 | 4 | 26 | loose |
| Yeat | Did wrong | 37 | 21 | 192 | loose |
| Yeat | Die Today Remix | 25 | 16 | 230 | loose |
| Yeat | Died Once | 29 | 37 | 88 | loose |
| Yeat | Different Up | 31 | 22 | 175 | loose |
| Yeat | Different bootup (X With The Boot Up) | 35 | 20 | 126 | loose |
| Yeat | Dirty x | 25 | 39 | 117 | loose |
| Yeat | Dis A AP | 22 | 19 | 71 | loose |
| Yeat | Distance | 34 | 58 | 110 | loose |
| Yeat | Diëd B4 | 42 | 64 | 187 | loose |
| Yeat | Dnt lië | 50 | 63 | 198 | loose |
| Yeat | Do It | 25 | 21 | 72 | loose |
| Yeat | Done wit | 22 | 27 | 117 | loose |
| Yeat | Dont Bë Cleaning Booty | 25 | 35 | 170 | loose |
| Yeat | Dont get 2 close | 21 | 20 | 154 | loose |
| Yeat | Dont hav this | 35 | 38 | 137 | loose |
| Yeat | Dont remember | 36 | 44 | 182 | loose |
| Yeat | Don’t do that | 34 | 40 | 208 | loose |
| Yeat | Don’t tëll | 12 | 11 | 39 | loose |
| Yeat | Double Tesla | 35 | 60 | 158 | loose |
| Yeat | Double Tonka* | 4 | 0 | 14 | loose |
| Yeat | Doublë | 54 | 69 | 166 | loose |
| Yeat | Doublėd ÜP | 30 | 45 | 206 | loose |
| Yeat | Down badd | 61 | 57 | 362 | loose |
| Yeat | Drug Damage | 38 | 37 | 248 | loose |
| Yeat | Drug Party | 11 | 8 | 58 | loose |
| Yeat | Dub | 32 | 27 | 212 | loose |
| Yeat | Duce | 22 | 12 | 90 | loose |
| Yeat | Duckcontëst | 8 | 7 | 27 | loose |
| Yeat | Duffles Up | 21 | 30 | 120 | loose |
| Yeat | Duh | 28 | 10 | 137 | loose |
| Yeat | Dëmon 2 | 35 | 64 | 228 | loose |
| Yeat | Dëmon Time (Signing OFF) | 15 | 12 | 51 | loose |
| Yeat | Dëmon tied | 32 | 31 | 207 | loose |
| Yeat | Dëserve it | 23 | 33 | 172 | loose |
| Yeat | EARNEDIT | 11 | 10 | 59 | loose |
| Yeat | EDD Hit 50 | 38 | 98 | 253 | loose |
| Yeat | ELIMINATË | 47 | 35 | 195 | loose |
| Yeat | EVER KNOW FREESTYLE | 31 | 28 | 180 | loose |
| Yeat | EVERY TYPA BAD / DAMAGE | 43 | 75 | 400 | loose |
| Yeat | EVERYTIME | 37 | 29 | 173 | loose |
| Yeat | EVERYWHERE | 36 | 16 | 126 | loose |
| Yeat | EYES* | 17 | 18 | 85 | loose |
| Yeat | Eagle Vision | 31 | 37 | 161 | loose |
| Yeat | Earnëd it | 32 | 57 | 236 | loose |
| Yeat | Eaters | 68 | 48 | 221 | loose |
| Yeat | Edd fuckit [OPEN] | 18 | 37 | 172 | loose |
| Yeat | End Of The Day | 33 | 17 | 172 | loose |
| Yeat | Every Night | 4 | 6 | 14 | loose |
| Yeat | Every Sunday | 30 | 52 | 269 | loose |
| Yeat | Everyday | 28 | 13 | 125 | loose |
| Yeat | Everything Up | 35 | 39 | 207 | loose |
| Yeat | Evolve | 25 | 17 | 155 | loose |
| Yeat | Evolvëd | 47 | 43 | 281 | loose |
| Yeat | Evëry time | 26 | 36 | 200 | loose |
| Yeat | Ex Still | 43 | 41 | 218 | loose |
| Yeat | Exotic | 31 | 44 | 141 | loose |
| Yeat | Expensive Taste | 44 | 41 | 175 | loose |
| Yeat | Extraaa | 32 | 46 | 175 | loose |
| Yeat | FATË | 35 | 25 | 127 | loose |
| Yeat | FAX | 8 | 1 | 31 | loose |
| Yeat | FLY NITË | 41 | 47 | 210 | loose |
| Yeat | FLYTROOP | 25 | 19 | 157 | loose |
| Yeat | FN [V3] | 26 | 8 | 46 | loose |
| Yeat | FOR LYFE | 21 | 29 | 63 | loose |
| Yeat | FOREVER AGAIN | 22 | 14 | 74 | loose |
| Yeat | FORREAL | 5 | 0 | 7 | loose |
| Yeat | FUCK WIT US | 30 | 17 | 151 | loose |
| Yeat | FUCK WITCHA | 20 | 42 | 32 | loose |
| Yeat | FaLyfë | 7 | 1 | 26 | loose |
| Yeat | Face (Remix) | 48 | 28 | 269 | loose |
| Yeat | Face The Flamë | 38 | 23 | 283 | loose |
| Yeat | Factz | 29 | 28 | 237 | loose |
| Yeat | Fake Friends* | 11 | 8 | 29 | loose |
| Yeat | Fake Luv Freestyle | 41 | 40 | 167 | loose |
| Yeat | Fake Luv Freestyle [Duplicate Page] | 15 | 7 | 78 | loose |
| Yeat | Fall Out The Sky | 8 | 6 | 21 | loose |
| Yeat | Familia | 27 | 37 | 175 | loose |
| Yeat | Fanclub | 19 | 10 | 35 | loose |
| Yeat | Farr | 14 | 4 | 46 | loose |
| Yeat | Fashün Week | 33 | 39 | 196 | loose |
| Yeat | Fast | 38 | 21 | 252 | loose |
| Yeat | Fck Em All | 4 | 1 | 6 | loose |
| Yeat | Fed Up Freestyle | 40 | 58 | 216 | loose |
| Yeat | Feel it | 25 | 27 | 238 | loose |
| Yeat | Feel it V1 | 4 | 2 | 45 | loose |
| Yeat | Feel like E.T | 5 | 8 | 29 | AABA |
| Yeat | Feel more | 32 | 30 | 293 | loose |
| Yeat | Feel none no more | 20 | 9 | 114 | loose |
| Yeat | Feel sum | 32 | 34 | 156 | loose |
| Yeat | Feelinz | 27 | 32 | 297 | loose |
| Yeat | Fell in luv | 38 | 38 | 225 | loose |
| Yeat | Fences | 24 | 19 | 163 | loose |
| Yeat | Feël no wayz (Yeat mix) | 31 | 16 | 81 | loose |
| Yeat | Fifty | 4 | 3 | 23 | ABAA |
| Yeat | Fill My Cup | 44 | 38 | 175 | loose |
| Yeat | Finally #FRËË | 23 | 28 | 127 | loose |
| Yeat | Firemane | 27 | 41 | 156 | loose |
| Yeat | Firemane 2 | 5 | 2 | 38 | loose |
| Yeat | Flashëy | 31 | 28 | 295 | loose |
| Yeat | Flawless (2020) | 38 | 47 | 272 | loose |
| Yeat | Flawlëss | 51 | 59 | 215 | loose |
| Yeat | Flip | 30 | 61 | 118 | loose |
| Yeat | Flippëd | 23 | 25 | 146 | loose |
| Yeat | Fluently (OG) | 25 | 20 | 59 | loose |
| Yeat | Flëxing* | 19 | 14 | 122 | loose |
| Yeat | Foreign | 3 | 1 | 3 | loose |
| Yeat | Forëally / 4Ly | 30 | 24 | 123 | loose |
| Yeat | Free em | 37 | 21 | 262 | loose |
| Yeat | Free sum | 26 | 19 | 163 | loose |
| Yeat | Freestyle* | 27 | 29 | 82 | loose |
| Yeat | Fresh | 48 | 50 | 166 | loose |
| Yeat | Front Row | 21 | 23 | 84 | loose |
| Yeat | Fuck Shyt | 33 | 20 | 204 | loose |
| Yeat | Fuck em all unreleased | 7 | 2 | 23 | loose |
| Yeat | Fuck em all* | 13 | 6 | 44 | loose |
| Yeat | Fuck the cops | 12 | 3 | 62 | loose |
| Yeat | Fuckit | 30 | 38 | 225 | loose |
| Yeat | Fuk Tha Clout | 42 | 52 | 222 | loose |
| Yeat | Fuk ’Em All | 8 | 3 | 26 | loose |
| Yeat | Fukit | 30 | 22 | 154 | loose |
| Yeat | Fun | 26 | 17 | 127 | loose |
| Yeat | Function* | 10 | 7 | 15 | loose |
| Yeat | Fyed Up | 38 | 58 | 176 | loose |
| Yeat | Föotjob AddÏction | 17 | 19 | 71 | loose |
| Yeat | GEEK TIMË | 31 | 14 | 102 | loose |
| Yeat | GEEK TIMË - 2093 intro | 23 | 15 | 93 | loose |
| Yeat | GEEKED UP | 25 | 15 | 95 | loose |
| Yeat | GO AGAIN | 22 | 18 | 114 | loose |
| Yeat | GO2WORK | 41 | 23 | 179 | loose |
| Yeat | GOD TALKIN SHHH | 50 | 43 | 334 | loose |
| Yeat | GODAMNIT | 49 | 44 | 164 | loose |
| Yeat | GOMOVE* | 3 | 1 | 0 | loose |
| Yeat | GONE 4 A MIN | 33 | 33 | 148 | loose |
| Yeat | GONË | 17 | 3 | 77 | loose |
| Yeat | GRAVEYARD | 22 | 18 | 102 | loose |
| Yeat | GRAVËLROAD | 27 | 18 | 108 | loose |
| Yeat | GROWING PAINS | 49 | 36 | 189 | loose |
| Yeat | Geek Luv | 27 | 10 | 76 | loose |
| Yeat | Geek up | 4 | 3 | 9 | loose |
| Yeat | Geeker Day | 22 | 42 | 94 | loose |
| Yeat | Get like dis | 34 | 32 | 202 | loose |
| Yeat | Get up | 30 | 25 | 203 | loose |
| Yeat | Gettin Hi | 19 | 30 | 81 | loose |
| Yeat | Ghost | 10 | 16 | 44 | loose |
| Yeat | Give My Last | 26 | 42 | 145 | loose |
| Yeat | Glö Gö UP | 42 | 60 | 304 | loose |
| Yeat | Go UP 3 | 21 | 16 | 145 | loose |
| Yeat | Go away | 6 | 9 | 18 | loose |
| Yeat | Go b4 | 20 | 16 | 117 | loose |
| Yeat | Go yea | 22 | 16 | 73 | loose |
| Yeat | Go! (Whole Lotta) | 30 | 16 | 142 | loose |
| Yeat | GoGo | 47 | 60 | 202 | loose |
| Yeat | Goat Emoji | 52 | 70 | 219 | loose |
| Yeat | Goin Back 2 Ella | 46 | 17 | 201 | loose |
| Yeat | Goin Up* | 4 | 1 | 11 | loose |
| Yeat | Going Out Sad | 39 | 34 | 109 | loose |
| Yeat | Going There | 30 | 31 | 186 | loose |
| Yeat | Goin’ Crazy | 33 | 42 | 214 | loose |
| Yeat | Good Day | 40 | 26 | 219 | loose |
| Yeat | Got 2 Slow Down | 12 | 12 | 71 | loose |
| Yeat | Got it all | 41 | 41 | 268 | loose |
| Yeat | Got rich | 25 | 24 | 147 | loose |
| Yeat | GotRich (Unreleased) | 39 | 34 | 186 | loose |
| Yeat | Gotta Bounce | 34 | 50 | 85 | loose |
| Yeat | Gotta move on | 32 | 39 | 160 | loose |
| Yeat | Green | 21 | 12 | 192 | loose |
| Yeat | Griddlë | 37 | 28 | 166 | loose |
| Yeat | Grind / Balmains | 31 | 20 | 81 | loose |
| Yeat | Guap | 13 | 20 | 50 | loose |
| Yeat | GËEKED | 22 | 16 | 106 | loose |
| Yeat | Gëek high | 41 | 36 | 171 | loose |
| Yeat | Gët Busy | 29 | 44 | 133 | loose |
| Yeat | Gö | 40 | 61 | 157 | loose |
| Yeat | H.A.B | 25 | 38 | 166 | loose |
| Yeat | HARD 2 MISS | 40 | 23 | 258 | loose |
| Yeat | HEAD FIRST | 16 | 10 | 53 | loose |
| Yeat | HEARD OF MË | 25 | 20 | 100 | loose |
| Yeat | HEARTLOCK | 43 | 34 | 120 | loose |
| Yeat | HIT THA GROUND | 17 | 8 | 78 | loose |
| Yeat | HOT 2 THA TOUCH | 36 | 40 | 104 | loose |
| Yeat | HOW U DOING? | 26 | 20 | 92 | loose |
| Yeat | HOW YOU DOING (v1) | 20 | 24 | 110 | loose |
| Yeat | HYD | 23 | 33 | 163 | loose |
| Yeat | HYD v1 | 16 | 14 | 137 | loose |
| Yeat | Haha | 10 | 16 | 29 | loose |
| Yeat | Hatër | 33 | 22 | 184 | loose |
| Yeat | Have You Ever | 17 | 18 | 25 | loose |
| Yeat | Havin motion | 28 | 29 | 178 | loose |
| Yeat | He-he | 7 | 17 | 14 | AAAA |
| Yeat | Hear That / Geeked Up | 13 | 10 | 12 | loose |
| Yeat | Heaven Knows I’m Miserable Now / Jus Better | 14 | 9 | 57 | loose |
| Yeat | Heavenly | 38 | 37 | 190 | loose |
| Yeat | Heavy stunts | 41 | 15 | 107 | loose |
| Yeat | HeliMAn | 36 | 28 | 235 | loose |
| Yeat | Hello | 33 | 34 | 155 | loose |
| Yeat | Hey Hey (How Much)* | 13 | 7 | 79 | loose |
| Yeat | Hi af (Open Demo) | 10 | 7 | 52 | loose |
| Yeat | High As Shit (Unreleased) | 27 | 47 | 139 | loose |
| Yeat | High Music | 16 | 9 | 51 | loose |
| Yeat | High Noon | 24 | 10 | 67 | loose |
| Yeat | High Style | 27 | 35 | 177 | loose |
| Yeat | Hit Sum | 28 | 40 | 115 | loose |
| Yeat | Holy 1 | 40 | 29 | 263 | loose |
| Yeat | Honestly | 6 | 1 | 25 | loose |
| Yeat | Honeydew | 34 | 41 | 125 | loose |
| Yeat | Hot Sauce | 42 | 47 | 384 | loose |
| Yeat | How Do He Does It (SonFreddit) | 15 | 8 | 26 | loose |
| Yeat | How I Eat | 50 | 57 | 226 | loose |
| Yeat | How U Gët Like | 35 | 42 | 205 | loose |
| Yeat | How U Gët Like [Duplicate Page] | 29 | 38 | 128 | loose |
| Yeat | How it feel | 8 | 11 | 38 | loose |
| Yeat | How it go | 32 | 30 | 136 | loose |
| Yeat | How it gö (2021) | 31 | 28 | 124 | loose |
| Yeat | Huh??? | 19 | 24 | 55 | loose |
| Yeat | Hundun | 19 | 27 | 66 | loose |
| Yeat | Hunnid Now | 38 | 58 | 197 | loose |
| Yeat | Hurricaine | 29 | 26 | 112 | loose |
| Yeat | Hëavyweight | 23 | 9 | 98 | loose |
| Yeat | Hëllo | 21 | 12 | 65 | loose |
| Yeat | Hëlly (Hëllcat) | 33 | 31 | 192 | loose |
| Yeat | Hëy | 37 | 40 | 143 | loose |
| Yeat | Höw culd i changë | 37 | 36 | 208 | loose |
| Yeat | I Can Tell | 34 | 28 | 151 | loose |
| Yeat | I DONT | 23 | 16 | 124 | loose |
| Yeat | I Don’t Text Back | 33 | 23 | 181 | loose |
| Yeat | I Feel Alive 4 A Min* | 8 | 3 | 23 | loose |
| Yeat | I Hëard | 40 | 53 | 252 | loose |
| Yeat | I Lyke | 25 | 30 | 157 | loose |
| Yeat | I Remembër | 6 | 6 | 30 | loose |
| Yeat | I Say Go (Snippet) | 5 | 4 | 13 | loose |
| Yeat | I got / evëry spot* | 10 | 12 | 101 | loose |
| Yeat | IDGAF | 63 | 73 | 295 | loose |
| Yeat | ILUV | 26 | 17 | 98 | loose |
| Yeat | IM YEAT | 42 | 16 | 201 | loose |
| Yeat | IMMA BASTARD | 45 | 30 | 181 | loose |
| Yeat | IN2THAT* | 8 | 7 | 25 | loose |
| Yeat | ISSUES | 10 | 9 | 25 | loose |
| Yeat | If God Exists Its Fcking Me! | 10 | 4 | 46 | loose |
| Yeat | If I Did | 8 | 3 | 30 | loose |
| Yeat | If I Died | 46 | 27 | 216 | loose |
| Yeat | If I Had One | 35 | 34 | 139 | loose |
| Yeat | If We Being Rëal | 49 | 54 | 190 | loose |
| Yeat | Ight | 14 | 15 | 80 | loose |
| Yeat | Im Sorry | 35 | 48 | 178 | loose |
| Yeat | Im tha kind dëvil | 31 | 13 | 132 | loose |
| Yeat | Impatient | 58 | 69 | 209 | loose |
| Yeat | Insane | 35 | 41 | 111 | loose |
| Yeat | Insidë out | 34 | 23 | 147 | loose |
| Yeat | Intro 2022 | 37 | 46 | 234 | loose |
| Yeat | Ion Even Know | 22 | 21 | 27 | loose |
| Yeat | Ion Know | 27 | 20 | 170 | loose |
| Yeat | Ion Need Shit | 9 | 9 | 11 | loose |
| Yeat | Ion care | 23 | 39 | 187 | loose |
| Yeat | Is it bad (Unreleased Snippet) 2??24 | 19 | 12 | 48 | loose |
| Yeat | Isnt that crazy | 30 | 33 | 125 | loose |
| Yeat | It UP [V1] | 30 | 39 | 214 | loose |
| Yeat | Itz 2 sides to this wrld* | 4 | 3 | 13 | ABAA |
| Yeat | Iwas | 20 | 30 | 120 | loose |
| Yeat | I’m on a roll | 18 | 6 | 124 | loose |
| Yeat | Jetlag | 10 | 9 | 15 | loose |
| Yeat | Jetski* | 16 | 7 | 66 | loose |
| Yeat | Jokester | 10 | 4 | 35 | loose |
| Yeat | Jump | 32 | 47 | 170 | loose |
| Yeat | Jus Came In | 22 | 23 | 203 | loose |
| Yeat | Jus Wokeup At 7 n Boot up Freestyle | 41 | 36 | 117 | loose |
| Yeat | Jus Wokëup | 25 | 26 | 113 | loose |
| Yeat | Jus bëtter | 34 | 27 | 122 | loose |
| Yeat | Kant Luvv | 32 | 34 | 226 | loose |
| Yeat | Kant Switch | 36 | 33 | 148 | loose |
| Yeat | Kant changë | 24 | 16 | 111 | loose |
| Yeat | Kant dië | 40 | 67 | 132 | loose |
| Yeat | Kant rëlax | 34 | 55 | 216 | loose |
| Yeat | Keep Goin | 16 | 19 | 74 | loose |
| Yeat | Keep Goin INTERLUDE | 26 | 18 | 102 | loose |
| Yeat | Keep Pushin | 24 | 8 | 130 | loose |
| Yeat | KickStand | 36 | 39 | 108 | loose |
| Yeat | Killin ëm | 35 | 19 | 296 | loose |
| Yeat | King tonka | 23 | 9 | 92 | loose |
| Yeat | Know That* | 10 | 3 | 24 | loose |
| Yeat | Krank | 41 | 72 | 241 | loose |
| Yeat | Kranky (Arriba) | 21 | 15 | 49 | loose |
| Yeat | Krazy 2 Më | 27 | 31 | 188 | loose |
| Yeat | Krazy up | 29 | 32 | 142 | loose |
| Yeat | Kry bout it | 47 | 67 | 304 | loose |
| Yeat | Kurt Angle | 33 | 31 | 122 | loose |
| Yeat | Këep Up | 15 | 9 | 46 | loose |
| Yeat | LAST DAY (2023) | 7 | 6 | 26 | loose |
| Yeat | LOCK IT UP | 81 | 117 | 345 | loose |
| Yeat | LOCO | 35 | 14 | 179 | loose |
| Yeat | LOOSE LEAF | 37 | 25 | 266 | loose |
| Yeat | LOSE THE FEELING | 9 | 4 | 33 | loose |
| Yeat | LOSE UR MIND W ME | 32 | 50 | 81 | loose |
| Yeat | LOVELOVË IT | 34 | 23 | 133 | loose |
| Yeat | LYFE PARTY | 27 | 12 | 126 | loose |
| Yeat | LYFE STEALER | 23 | 15 | 96 | loose |
| Yeat | LYFESTYLE | 35 | 23 | 152 | loose |
| Yeat | LYING 5 FUN | 41 | 46 | 194 | loose |
| Yeat | Lalala | 43 | 52 | 203 | loose |
| Yeat | Lamb talk | 31 | 45 | 95 | loose |
| Yeat | Last Day | 53 | 40 | 279 | loose |
| Yeat | Latë Night | 46 | 47 | 399 | loose |
| Yeat | Laughin To The Bank | 25 | 33 | 68 | loose |
| Yeat | Learn 2 Leave | 35 | 56 | 184 | loose |
| Yeat | Let King Tonka Talk | 49 | 83 | 331 | loose |
| Yeat | Let’s Race | 28 | 28 | 184 | loose |
| Yeat | Let’s be honëst* | 16 | 10 | 111 | loose |
| Yeat | Ley Go | 11 | 1 | 53 | loose |
| Yeat | Li work | 39 | 84 | 370 | loose |
| Yeat | Life Goes ON | 22 | 21 | 79 | loose |
| Yeat | Life Is Great | 12 | 12 | 65 | loose |
| Yeat | Life a joke* | 12 | 12 | 62 | loose |
| Yeat | Liftëd | 52 | 40 | 433 | loose |
| Yeat | Lightshow | 38 | 57 | 215 | loose |
| Yeat | Lil Dub | 25 | 17 | 204 | loose |
| Yeat | Lil Krazy | 36 | 49 | 241 | loose |
| Yeat | Lil Skatty | 14 | 26 | 157 | loose |
| Yeat | LiteWork | 44 | 50 | 241 | loose |
| Yeat | Liv Likë Dis | 42 | 22 | 162 | loose |
| Yeat | Liv dis lyfë | 21 | 10 | 123 | loose |
| Yeat | Live | 26 | 13 | 106 | loose |
| Yeat | Live or Die (Ū Choose) | 25 | 22 | 200 | loose |
| Yeat | Live too fast* | 17 | 30 | 78 | loose |
| Yeat | Livin lyke us | 36 | 54 | 257 | loose |
| Yeat | Livë Hi | 49 | 68 | 360 | loose |
| Yeat | London OPEN | 16 | 17 | 20 | loose |
| Yeat | Long Money | 32 | 45 | 126 | loose |
| Yeat | Look Up | 49 | 72 | 345 | loose |
| Yeat | Look Wat U Did | 31 | 35 | 250 | loose |
| Yeat | Loot | 33 | 43 | 187 | loose |
| Yeat | Lose Control | 24 | 19 | 79 | loose |
| Yeat | Lost | 12 | 10 | 26 | loose |
| Yeat | Lot goin on | 26 | 16 | 186 | loose |
| Yeat | Love Drug | 46 | 47 | 171 | loose |
| Yeat | Love Yourself | 29 | 17 | 158 | loose |
| Yeat | Low | 21 | 35 | 104 | loose |
| Yeat | Luh break | 13 | 12 | 24 | loose |
| Yeat | Luh geëky | 47 | 63 | 205 | loose |
| Yeat | Luh gëek | 38 | 76 | 267 | loose |
| Yeat | Luh m | 46 | 56 | 267 | loose |
| Yeat | Luh skelë | 22 | 19 | 63 | loose |
| Yeat | Luv monëy | 42 | 41 | 150 | loose |
| Yeat | Lyfestylë | 53 | 108 | 368 | loose |
| Yeat | LyfëBorg | 4 | 0 | 2 | loose |
| Yeat | Lying 4 fun | 58 | 89 | 394 | loose |
| Yeat | Lët ya know | 28 | 52 | 113 | loose |
| Yeat | Lëvitate* | 17 | 6 | 98 | loose |
| Yeat | Löok Bakk | 38 | 33 | 187 | loose |
| Yeat | M.F.U. | 53 | 53 | 325 | loose |
| Yeat | MARGIELA ROOF | 33 | 22 | 31 | loose |
| Yeat | MELT EM | 24 | 34 | 169 | loose |
| Yeat | MEh (Remix) | 46 | 63 | 362 | loose |
| Yeat | MOGUL* | 16 | 5 | 102 | loose |
| Yeat | MOLLYKUP | 20 | 25 | 121 | loose |
| Yeat | MORNING RACKS | 82 | 77 | 381 | loose |
| Yeat | Mad bout that | 23 | 23 | 119 | loose |
| Yeat | Made It On Our Own | 46 | 71 | 148 | loose |
| Yeat | Make It Out | 25 | 16 | 103 | loose |
| Yeat | Makë no sense | 29 | 29 | 158 | loose |
| Yeat | Mata | 15 | 19 | 80 | loose |
| Yeat | Matching Pateks | 25 | 18 | 112 | loose |
| Yeat | Maxxed Out! | 4 | 0 | 17 | loose |
| Yeat | Maybach* | 4 | 1 | 15 | loose |
| Yeat | Me vs tha world | 44 | 51 | 282 | loose |
| Yeat | Meh 2 | 11 | 17 | 61 | loose |
| Yeat | Meh, Yeat | 26 | 11 | 126 | loose |
| Yeat | Met Tha Devil | 37 | 36 | 196 | loose |
| Yeat | Met tha mob* | 3 | 2 | 12 | loose |
| Yeat | Million Dollar Minion | 22 | 16 | 120 | loose |
| Yeat | Mindin’ my Bizness | 10 | 14 | 31 | loose |
| Yeat | Misguided | 8 | 13 | 56 | loose |
| Yeat | Miss The Rage 2 | 4 | 3 | 15 | loose |
| Yeat | Miss the Rage | 18 | 12 | 54 | loose |
| Yeat | Mixed Emotions | 56 | 96 | 198 | loose |
| Yeat | Mob outsidë | 22 | 17 | 133 | loose |
| Yeat | Mode | 43 | 59 | 282 | loose |
| Yeat | Money Dance* | 12 | 12 | 65 | loose |
| Yeat | Money Fetish | 53 | 72 | 400 | loose |
| Yeat | Money Long | 12 | 18 | 93 | AAAA |
| Yeat | Money Move | 36 | 56 | 135 | loose |
| Yeat | Money N Drugs | 31 | 32 | 160 | loose |
| Yeat | Money Twërk | 50 | 56 | 223 | loose |
| Yeat | Money Twërk 2 | 33 | 21 | 133 | loose |
| Yeat | Monster | 50 | 67 | 149 | loose |
| Yeat | Monsters Inc. (Original) | 51 | 50 | 347 | loose |
| Yeat | Monëy so big | 34 | 51 | 268 | loose |
| Yeat | Moon | 5 | 1 | 16 | loose |
| Yeat | More | 37 | 26 | 137 | loose |
| Yeat | Morning Routine | 60 | 72 | 340 | loose |
| Yeat | Morning mudd | 28 | 19 | 132 | loose |
| Yeat | Morë | 30 | 37 | 107 | loose |
| Yeat | Moshpit fukit | 9 | 2 | 5 | loose |
| Yeat | Mountain Climbërs | 37 | 34 | 204 | loose |
| Yeat | Move (Open Demo) | 15 | 16 | 83 | loose |
| Yeat | Move Enough Dope [V2] | 24 | 19 | 131 | loose |
| Yeat | Movië Rōom | 17 | 8 | 85 | loose |
| Yeat | Mr. Clean | 3 | 0 | 4 | loose |
| Yeat | Mr. Inbetweenit | 30 | 26 | 135 | loose |
| Yeat | Mud | 60 | 62 | 119 | loose |
| Yeat | My Doctor | 38 | 30 | 192 | loose |
| Yeat | My House | 8 | 2 | 52 | loose |
| Yeat | My Sh!t | 34 | 32 | 170 | loose |
| Yeat | My Time | 42 | 28 | 206 | loose |
| Yeat | My Way | 37 | 16 | 135 | loose |
| Yeat | My turn | 27 | 25 | 121 | loose |
| Yeat | My wrist | 46 | 40 | 317 | loose |
| Yeat | Myself (2021) | 24 | 23 | 203 | loose |
| Yeat | Mysëlf | 34 | 23 | 74 | loose |
| Yeat | Myë WRLD | 31 | 26 | 197 | loose |
| Yeat | MÄRCHING | 36 | 42 | 189 | loose |
| Yeat | Mëan feen | 29 | 30 | 207 | loose |
| Yeat | Mëssy | 16 | 23 | 74 | loose |
| Yeat | NEON BËAN | 29 | 50 | 169 | loose |
| Yeat | NEVER CATCH ON | 27 | 13 | 78 | loose |
| Yeat | NEW HIGH | 39 | 27 | 151 | loose |
| Yeat | NEW KRANKy | 15 | 23 | 48 | loose |
| Yeat | NEW VIEW | 24 | 13 | 92 | loose |
| Yeat | NIGHT COME | 19 | 12 | 171 | loose |
| Yeat | NO MORE GHOSTS | 35 | 21 | 90 | loose |
| Yeat | NO SEE | 44 | 31 | 149 | loose |
| Yeat | NO Y | 13 | 5 | 28 | loose |
| Yeat | NOT OVER HERE | 5 | 0 | 1 | loose |
| Yeat | NUWÖRLD | 24 | 49 | 286 | loose |
| Yeat | NY (feat. Lunchbox) | 27 | 25 | 172 | loose |
| Yeat | Naked | 9 | 15 | 20 | loose |
| Yeat | Narcoticz | 62 | 82 | 183 | loose |
| Yeat | Nat Nat | 42 | 56 | 129 | loose |
| Yeat | Nerdz | 36 | 49 | 148 | loose |
| Yeat | Never Changëd | 27 | 43 | 125 | loose |
| Yeat | Never The Same Way | 5 | 0 | 9 | loose |
| Yeat | Never quit | 31 | 23 | 147 | loose |
| Yeat | New Chain | 13 | 9 | 85 | loose |
| Yeat | New Face | 42 | 26 | 206 | loose |
| Yeat | New OPP | 36 | 51 | 191 | loose |
| Yeat | New Trip | 47 | 52 | 184 | loose |
| Yeat | New X | 25 | 26 | 118 | loose |
| Yeat | Nickolodean | 38 | 46 | 424 | loose |
| Yeat | Night Time | 43 | 51 | 222 | loose |
| Yeat | Nite | 41 | 68 | 227 | loose |
| Yeat | Nitë 2 | 38 | 41 | 158 | loose |
| Yeat | No Clout | 38 | 27 | 181 | loose |
| Yeat | No Deal | 28 | 22 | 97 | loose |
| Yeat | No Earth (Remix) | 44 | 24 | 192 | loose |
| Yeat | No Handoutz | 40 | 52 | 172 | loose |
| Yeat | No Jokë | 18 | 6 | 90 | loose |
| Yeat | No Kidding* / No Spinning* | 4 | 3 | 5 | AAAA |
| Yeat | No Lz | 10 | 13 | 76 | loose |
| Yeat | No Option | 12 | 15 | 92 | loose |
| Yeat | No Question | 30 | 26 | 119 | loose |
| Yeat | No Sense | 21 | 11 | 132 | loose |
| Yeat | No breaks / i tried | 10 | 4 | 43 | loose |
| Yeat | No commënt | 30 | 20 | 143 | loose |
| Yeat | No cosign | 22 | 13 | 82 | loose |
| Yeat | No fëelingz | 30 | 37 | 163 | loose |
| Yeat | No morë talk | 34 | 17 | 293 | loose |
| Yeat | Nobu | 34 | 27 | 195 | loose |
| Yeat | Not Da Same | 44 | 69 | 284 | loose |
| Yeat | Not Enough | 37 | 39 | 309 | loose |
| Yeat | Not Me | 44 | 28 | 110 | loose |
| Yeat | Not On Shit | 28 | 32 | 137 | loose |
| Yeat | Not Tha Samë | 29 | 23 | 146 | loose |
| Yeat | Not Worriëd | 31 | 24 | 197 | loose |
| Yeat | Not involved | 34 | 29 | 140 | loose |
| Yeat | Nother League [v2] | 30 | 38 | 85 | loose |
| Yeat | Nother league | 26 | 46 | 175 | loose |
| Yeat | NothinGonImpressMe | 19 | 14 | 70 | loose |
| Yeat | Nothing Changë | 44 | 84 | 244 | loose |
| Yeat | Now | 34 | 9 | 146 | loose |
| Yeat | Number 1 | 49 | 92 | 174 | loose |
| Yeat | Nun id change | 27 | 15 | 128 | loose |
| Yeat | Nutrition in switzerland | 32 | 33 | 119 | loose |
| Yeat | Nvr again | 34 | 29 | 177 | loose |
| Yeat | Nëw turban | 33 | 28 | 131 | loose |
| Yeat | Nö Reason | 34 | 32 | 186 | loose |
| Yeat | ODe | 25 | 26 | 112 | loose |
| Yeat | OFF THA RIP | 26 | 22 | 161 | loose |
| Yeat | OH I DID | 37 | 15 | 170 | loose |
| Yeat | ON 1 | 34 | 40 | 175 | loose |
| Yeat | ON THE WAY! | 20 | 14 | 51 | loose |
| Yeat | ONE TAKE | 37 | 63 | 162 | loose |
| Yeat | ORCHESTRATË | 28 | 21 | 80 | loose |
| Yeat | OTW! | 38 | 40 | 90 | loose |
| Yeat | OUT MY HANDS | 29 | 44 | 99 | loose |
| Yeat | OXY STORY | 25 | 23 | 139 | loose |
| Yeat | Of course | 31 | 35 | 248 | loose |
| Yeat | Off Tha Lot | 30 | 18 | 189 | loose |
| Yeat | Off wit they head | 50 | 47 | 381 | loose |
| Yeat | Oh My Pockëts | 35 | 41 | 138 | loose |
| Yeat | Oh eX whY | 34 | 61 | 284 | loose |
| Yeat | Ok Kool | 33 | 47 | 91 | loose |
| Yeat | On Go! | 28 | 27 | 135 | loose |
| Yeat | On Livë | 35 | 31 | 178 | loose |
| Yeat | On Top | 37 | 34 | 209 | loose |
| Yeat | On me | 5 | 6 | 5 | ABCB |
| Yeat | On tha linë | 22 | 37 | 140 | loose |
| Yeat | One Thing I Fear (Interlude) | 35 | 41 | 175 | loose |
| Yeat | One Wish | 7 | 2 | 10 | loose |
| Yeat | Orion’s Belt | 39 | 30 | 251 | loose |
| Yeat | Osama | 17 | 19 | 84 | loose |
| Yeat | Out +++ | 9 | 2 | 20 | loose |
| Yeat | Out My Planet* | 26 | 18 | 91 | loose |
| Yeat | Out thë way | 34 | 34 | 220 | loose |
| Yeat | Outside Time | 19 | 16 | 59 | loose |
| Yeat | Outside Trippin (Remix) | 29 | 32 | 162 | loose |
| Yeat | Outsidë | 42 | 27 | 204 | loose |
| Yeat | Ouu Yeah | 34 | 51 | 172 | loose |
| Yeat | Over timë | 6 | 1 | 31 | loose |
| Yeat | Overloaded | 38 | 24 | 141 | loose |
| Yeat | Oxy Party | 24 | 11 | 162 | loose |
| Yeat | PERCAHOLIC | 31 | 38 | 187 | loose |
| Yeat | PIXELATED KISSES (Remix) | 18 | 14 | 36 | loose |
| Yeat | PROJECT LYFESTYLE | 33 | 43 | 100 | loose |
| Yeat | PULL OFF* | 8 | 3 | 12 | loose |
| Yeat | PULLED IN FIRST | 25 | 8 | 92 | loose |
| Yeat | PULLUP TIME | 21 | 10 | 73 | loose |
| Yeat | PUT IT ONG | 25 | 27 | 182 | loose |
| Yeat | Painting Picturës | 28 | 32 | 212 | loose |
| Yeat | Pandemic | 31 | 62 | 216 | AAAA |
| Yeat | Panic | 44 | 77 | 206 | loose |
| Yeat | Paradise | 50 | 30 | 281 | loose |
| Yeat | Paris | 23 | 12 | 133 | loose |
| Yeat | Percasseur | 42 | 52 | 117 | loose |
| Yeat | Percodëmon | 8 | 5 | 25 | loose |
| Yeat | Percs | 7 | 6 | 32 | loose |
| Yeat | Perfect Timing | 26 | 61 | 131 | loose |
| Yeat | Personalities | 28 | 16 | 164 | loose |
| Yeat | Pilot | 33 | 32 | 89 | loose |
| Yeat | Pit Stop (Interlude) | 24 | 23 | 135 | loose |
| Yeat | Pizza Time | 20 | 5 | 18 | loose |
| Yeat | Playd da coupe | 29 | 58 | 174 | loose |
| Yeat | Playin Gamës | 10 | 6 | 38 | loose |
| Yeat | Plenty options | 30 | 16 | 192 | loose |
| Yeat | Pop Out | 43 | 30 | 241 | loose |
| Yeat | Pop Yo Shit | 39 | 48 | 199 | loose |
| Yeat | Popout V1 | 4 | 1 | 13 | loose |
| Yeat | Poppin | 33 | 34 | 190 | loose |
| Yeat | Power Trip | 64 | 109 | 260 | loose |
| Yeat | Prada U | 12 | 3 | 70 | loose |
| Yeat | Probably! | 33 | 47 | 430 | loose |
| Yeat | Provë sum | 32 | 45 | 259 | loose |
| Yeat | Psycho CEO | 33 | 23 | 134 | loose |
| Yeat | Psychocainë | 22 | 27 | 51 | loose |
| Yeat | Pull Up | 106 | 118 | 399 | loose |
| Yeat | Punk | 16 | 6 | 58 | loose |
| Yeat | Punk Monk (Remix) | 38 | 33 | 223 | loose |
| Yeat | Purpose General | 37 | 48 | 180 | loose |
| Yeat | Put It On | 11 | 5 | 70 | loose |
| Yeat | Put somë in | 37 | 47 | 209 | loose |
| Yeat | RACKS | 24 | 25 | 103 | loose |
| Yeat | REGULAR PPL 1ST | 7 | 3 | 23 | loose |
| Yeat | REUP | 35 | 35 | 291 | loose |
| Yeat | RIDE* | 8 | 13 | 33 | loose |
| Yeat | RIP Virgil | 36 | 41 | 191 | loose |
| Yeat | ROCKETS | 4 | 2 | 11 | loose |
| Yeat | ROLL | 21 | 11 | 125 | loose |
| Yeat | RP | 40 | 43 | 138 | loose |
| Yeat | Rackie Fitness | 34 | 41 | 187 | loose |
| Yeat | Racks On Mëh | 21 | 7 | 96 | loose |
| Yeat | Racky up | 27 | 9 | 102 | loose |
| Yeat | Rackz | 28 | 22 | 250 | loose |
| Yeat | Rackz IN | 31 | 43 | 145 | loose |
| Yeat | Rackz got më | 38 | 39 | 157 | loose |
| Yeat | Raglord | 13 | 5 | 33 | loose |
| Yeat | Ragz | 31 | 27 | 156 | loose |
| Yeat | Raised Me | 29 | 14 | 103 | loose |
| Yeat | Rav3 p4rty | 31 | 23 | 202 | loose |
| Yeat | Rav3 part | 35 | 25 | 96 | loose |
| Yeat | Real Gëëkërz | 31 | 33 | 180 | loose |
| Yeat | Real Is rarë | 27 | 39 | 157 | loose |
| Yeat | Real Life Shit | 32 | 33 | 277 | loose |
| Yeat | Real Lyfe | 41 | 25 | 206 | loose |
| Yeat | Real Trendsettër | 28 | 43 | 130 | loose |
| Yeat | Really Rlly | 40 | 43 | 409 | loose |
| Yeat | Release | 31 | 41 | 122 | loose |
| Yeat | Remember | 5 | 2 | 9 | loose |
| Yeat | Remiss | 11 | 4 | 20 | loose |
| Yeat | Rendezvous | 24 | 42 | 72 | loose |
| Yeat | Repent | 27 | 16 | 58 | loose |
| Yeat | Reverend* | 7 | 3 | 15 | loose |
| Yeat | Rëal SPill | 41 | 44 | 210 | loose |
| Yeat | Rich Minion | 39 | 40 | 90 | loose |
| Yeat | Riding in a Rental (Unreleased) | 14 | 2 | 34 | loose |
| Yeat | Rino Hercules (Remix)* | 9 | 6 | 33 | loose |
| Yeat | Riot & Set it off | 20 | 7 | 97 | loose |
| Yeat | Rise up (BEEN) | 28 | 31 | 83 | loose |
| Yeat | Risk | 71 | 59 | 457 | loose |
| Yeat | Risky (Unreleased) | 22 | 37 | 223 | loose |
| Yeat | Robbed tha bank | 20 | 26 | 77 | loose |
| Yeat | Rockin It | 37 | 26 | 126 | loose |
| Yeat | Rockstar living | 37 | 44 | 250 | loose |
| Yeat | Rokstar | 28 | 31 | 217 | loose |
| Yeat | Rolled IN | 28 | 28 | 109 | loose |
| Yeat | Rollin | 49 | 81 | 335 | loose |
| Yeat | RolËy DÆ 2 | 46 | 76 | 380 | loose |
| Yeat | Rolëy DÆ | 34 | 34 | 213 | loose |
| Yeat | Rose Colored | 21 | 20 | 77 | loose |
| Yeat | Roxy | 37 | 54 | 147 | loose |
| Yeat | Run Thëy Mouth | 31 | 16 | 195 | loose |
| Yeat | Rëady* | 18 | 17 | 32 | loose |
| Yeat | Rëal Lyfë | 15 | 8 | 77 | loose |
| Yeat | Rëal lifë | 27 | 45 | 139 | loose |
| Yeat | Rëal six | 32 | 37 | 249 | loose |
| Yeat | Rëmind ya (Lyfestylë Demo) | 6 | 13 | 30 | loose |
| Yeat | Rïch off rap | 58 | 98 | 303 | loose |
| Yeat | SCREWS LOOSE | 4 | 1 | 12 | loose |
| Yeat | SECRET CHAT (Snippet 03.06.25) | 5 | 1 | 7 | loose |
| Yeat | SEDATIVES* | 6 | 1 | 11 | loose |
| Yeat | SIZEITUP | 28 | 27 | 78 | loose |
| Yeat | SKLUB | 31 | 34 | 212 | loose |
| Yeat | SMD / Hater | 34 | 56 | 353 | loose |
| Yeat | SMDP | 53 | 75 | 163 | loose |
| Yeat | SO WHAT | 25 | 24 | 204 | loose |
| Yeat | SOSAYEAT | 28 | 27 | 193 | loose |
| Yeat | SPEEDBALL | 18 | 10 | 101 | loose |
| Yeat | SRT | 37 | 15 | 172 | loose |
| Yeat | STAND STILL* | 17 | 5 | 93 | loose |
| Yeat | STEP BACK | 19 | 14 | 95 | loose |
| Yeat | STEPP BACK | 22 | 13 | 57 | loose |
| Yeat | STFU | 26 | 18 | 106 | loose |
| Yeat | STYLE LYFE | 28 | 16 | 164 | loose |
| Yeat | SUCKING DICK | 9 | 3 | 25 | loose |
| Yeat | SUPER CHICKEN (2024) | 22 | 11 | 44 | loose |
| Yeat | SWITCH IT | 35 | 25 | 190 | loose |
| Yeat | SYMPATHY4ME | 21 | 8 | 79 | loose |
| Yeat | Sacrafice | 60 | 106 | 582 | loose |
| Yeat | Safe | 35 | 27 | 254 | loose |
| Yeat | Same Shit | 29 | 10 | 297 | loose |
| Yeat | Same Shyt (Leave Me Alone)* | 4 | 1 | 17 | loose |
| Yeat | Say Sum | 26 | 36 | 209 | loose |
| Yeat | Sayin words | 26 | 20 | 98 | loose |
| Yeat | Screwed Up | 25 | 25 | 144 | loose |
| Yeat | Scrätch That | 28 | 51 | 127 | loose |
| Yeat | Seen Alot Of Shit | 27 | 21 | 105 | loose |
| Yeat | Seent it all | 24 | 37 | 131 | loose |
| Yeat | Sextape | 3 | 0 | 4 | loose |
| Yeat | Shade | 69 | 69 | 214 | loose |
| Yeat | Shhhh | 40 | 35 | 308 | loose |
| Yeat | Shmunk | 49 | 81 | 296 | loose |
| Yeat | Showin Out | 30 | 23 | 125 | loose |
| Yeat | Shyt Changëd | 33 | 47 | 210 | loose |
| Yeat | Shë luv god | 33 | 25 | 203 | loose |
| Yeat | Sidëwayz | 45 | 42 | 242 | loose |
| Yeat | Silk Facë | 34 | 63 | 90 | loose |
| Yeat | Simon Says | 4 | 0 | 26 | loose |
| Yeat | Simple (All I Do) | 22 | 30 | 47 | loose |
| Yeat | Simplë | 33 | 24 | 184 | loose |
| Yeat | Sit bakk | 36 | 47 | 140 | loose |
| Yeat | Skam | 8 | 5 | 14 | loose |
| Yeat | Skervem | 10 | 5 | 81 | loose |
| Yeat | Skufflr | 19 | 25 | 89 | loose |
| Yeat | Slamm | 30 | 25 | 175 | loose |
| Yeat | Sleep monëy | 37 | 57 | 286 | loose |
| Yeat | Sleeptalking | 23 | 14 | 193 | loose |
| Yeat | Slimd Em Out | 25 | 25 | 122 | loose |
| Yeat | Slurpee | 22 | 17 | 78 | loose |
| Yeat | Smoke Up! | 3 | 0 | 2 | loose |
| Yeat | Smooktobër | 30 | 57 | 173 | loose |
| Yeat | Snap tha chain | 16 | 7 | 58 | loose |
| Yeat | So Extra | 10 | 21 | 75 | loose |
| Yeat | So Wat | 44 | 68 | 214 | loose |
| Yeat | So Wrong | 23 | 28 | 131 | loose |
| Yeat | Sorry Bout That | 46 | 54 | 186 | loose |
| Yeat | Soup | 36 | 39 | 167 | loose |
| Yeat | Space* | 7 | 8 | 50 | loose |
| Yeat | Speak Alien Friistyle (UFO) | 23 | 36 | 64 | loose |
| Yeat | Speak on It / I’m So Me | 45 | 56 | 129 | loose |
| Yeat | Spend It All | 29 | 29 | 148 | loose |
| Yeat | Spend it | 6 | 2 | 22 | loose |
| Yeat | Spike Lee (Core / High As Shit) | 19 | 21 | 130 | loose |
| Yeat | Split | 25 | 23 | 151 | loose |
| Yeat | Spoil Me | 26 | 34 | 205 | loose |
| Yeat | Stand On It | 44 | 35 | 252 | loose |
| Yeat | Started Off | 35 | 46 | 148 | loose |
| Yeat | Starz (Duplicate) | 10 | 6 | 25 | loose |
| Yeat | Stay Up | 38 | 36 | 199 | loose |
| Yeat | Stayed Down Long Enough | 42 | 78 | 187 | loose |
| Yeat | Stayëd tha same | 29 | 34 | 105 | loose |
| Yeat | Steppin Out! | 21 | 20 | 165 | loose |
| Yeat | Still | 32 | 75 | 175 | loose |
| Yeat | Still Pull Up If I Die (On a Flight with Yeat & Yachty) | 16 | 4 | 27 | loose |
| Yeat | Still countin | 33 | 32 | 133 | loose |
| Yeat | Still did it | 25 | 17 | 189 | loose |
| Yeat | Stood Taller | 34 | 27 | 210 | loose |
| Yeat | Strogänoff | 36 | 23 | 135 | loose |
| Yeat | Studio Mode | 6 | 2 | 26 | loose |
| Yeat | Stupid Rich Shyt | 48 | 43 | 319 | loose |
| Yeat | Suicidal | 33 | 22 | 154 | loose |
| Yeat | Sum 2 do | 31 | 33 | 207 | loose |
| Yeat | Sum Problems (Solo) | 11 | 17 | 24 | loose |
| Yeat | Sum lean | 20 | 10 | 68 | loose |
| Yeat | Sum new plz | 26 | 41 | 118 | loose |
| Yeat | Sunday Service | 28 | 34 | 192 | loose |
| Yeat | Super Surfer | 33 | 32 | 153 | loose |
| Yeat | Supër Test | 36 | 32 | 260 | loose |
| Yeat | Swear | 39 | 40 | 224 | loose |
| Yeat | Swerve 2 a swerve | 30 | 14 | 194 | loose |
| Yeat | Swërve | 38 | 32 | 179 | loose |
| Yeat | Swërved It | 28 | 46 | 117 | loose |
| Yeat | Systëm | 40 | 31 | 316 | loose |
| Yeat | Sïck | 26 | 16 | 245 | loose |
| Yeat | TALKIN SHIT PT 2 | 18 | 38 | 58 | AAAA |
| Yeat | TALKING SHIT | 18 | 32 | 55 | loose |
| Yeat | TELL U AGAIN | 19 | 11 | 78 | loose |
| Yeat | TERRIFIED | 21 | 27 | 111 | loose |
| Yeat | THA 1 | 25 | 9 | 58 | loose |
| Yeat | THE COSTËS | 31 | 16 | 106 | loose |
| Yeat | THE MARTIAN | 20 | 10 | 35 | loose |
| Yeat | THEY TELL MË | 21 | 9 | 100 | loose |
| Yeat | THEY TELL MË [V3] | 26 | 24 | 136 | loose |
| Yeat | TOOLY | 29 | 35 | 113 | loose |
| Yeat | TRIP OUT | 45 | 33 | 122 | loose |
| Yeat | TRY2DAMAGE | 29 | 17 | 162 | loose |
| Yeat | TURNMEUP | 29 | 53 | 135 | loose |
| Yeat | TWATSKI | 25 | 30 | 90 | loose |
| Yeat | Take Back | 58 | 42 | 118 | loose |
| Yeat | Take Off | 13 | 9 | 67 | loose |
| Yeat | Take it for granted | 38 | 40 | 139 | loose |
| Yeat | Taliban | 44 | 61 | 284 | loose |
| Yeat | Talk | 38 | 40 | 309 | loose |
| Yeat | Talk 2 God | 44 | 48 | 223 | loose |
| Yeat | Talk Money | 16 | 8 | 98 | loose |
| Yeat | Tallër | 24 | 15 | 65 | loose |
| Yeat | Tank 2 | 23 | 19 | 164 | loose |
| Yeat | Tank high* | 6 | 2 | 14 | loose |
| Yeat | Tanky | 3 | 1 | 15 | loose |
| Yeat | Team ceo | 36 | 44 | 149 | loose |
| Yeat | Tell më | 57 | 46 | 230 | loose |
| Yeat | Temptation (2020) | 13 | 0 | 8 | loose |
| Yeat | Temptation [Version 1] | 29 | 23 | 149 | loose |
| Yeat | Tesla | 29 | 29 | 200 | loose |
| Yeat | Tessy | 41 | 42 | 154 | loose |
| Yeat | Test* | 8 | 13 | 45 | loose |
| Yeat | Text | 4 | 1 | 24 | loose |
| Yeat | Tha Gëtup (2021) | 33 | 18 | 171 | loose |
| Yeat | Tha Gëtup | 38 | 31 | 158 | loose |
| Yeat | Tha WRLD | 16 | 16 | 54 | loose |
| Yeat | Tha Worstie | 49 | 42 | 386 | loose |
| Yeat | Tha bëntly | 26 | 27 | 223 | loose |
| Yeat | That a rack (yeat version) | 33 | 33 | 210 | loose |
| Yeat | That’s fasho | 28 | 21 | 143 | loose |
| Yeat | The Baconator | 73 | 97 | 371 | loose |
| Yeat | The Bell | 35 | 22 | 184 | loose |
| Yeat | The Last Supper | 28 | 25 | 206 | loose |
| Yeat | The Wolf | 49 | 23 | 202 | loose |
| Yeat | Theyon Kno | 50 | 50 | 219 | loose |
| Yeat | This Is It | 38 | 54 | 139 | loose |
| Yeat | This is me destroying my vocal cords | 21 | 22 | 174 | loose |
| Yeat | Thots | 31 | 28 | 152 | loose |
| Yeat | Throw Sum | 35 | 44 | 206 | loose |
| Yeat | Thëy not us | 18 | 5 | 97 | loose |
| Yeat | Tie Die | 59 | 83 | 139 | loose |
| Yeat | Time Again | 32 | 17 | 83 | loose |
| Yeat | Timë Out | 7 | 2 | 27 | loose |
| Yeat | Timë Passed | 26 | 16 | 178 | loose |
| Yeat | Told Ya / Arceteryx | 26 | 24 | 147 | loose |
| Yeat | Told em | 32 | 54 | 189 | loose |
| Yeat | Told ya | 44 | 49 | 296 | loose |
| Yeat | Tonka | 37 | 37 | 203 | loose |
| Yeat | Tonka 2 | 39 | 35 | 134 | loose |
| Yeat | Too Extra | 30 | 30 | 107 | loose |
| Yeat | Took a break | 30 | 67 | 205 | loose |
| Yeat | Took a long time | 10 | 6 | 93 | loose |
| Yeat | Top Floor | 31 | 37 | 145 | loose |
| Yeat | Torë it apart | 38 | 43 | 162 | loose |
| Yeat | Traumatizëd! | 46 | 41 | 241 | loose |
| Yeat | Trendy 2 | 44 | 34 | 330 | loose |
| Yeat | Tried Once | 14 | 15 | 54 | loose |
| Yeat | Trië 2 Tell U outro | 35 | 13 | 178 | loose |
| Yeat | Tru to U | 48 | 54 | 413 | loose |
| Yeat | Truely | 48 | 45 | 253 | loose |
| Yeat | Trust it | 58 | 77 | 276 | loose |
| Yeat | Try It | 3 | 2 | 0 | loose |
| Yeat | Trënds & Topics* | 5 | 1 | 35 | loose |
| Yeat | Trëndy | 27 | 21 | 78 | loose |
| Yeat | Trëndy way | 40 | 80 | 256 | loose |
| Yeat | Turban | 32 | 20 | 130 | loose |
| Yeat | Turbothots | 16 | 9 | 86 | loose |
| Yeat | Turn Mе Up* | 11 | 14 | 52 | loose |
| Yeat | Twerk | 35 | 23 | 221 | loose |
| Yeat | Twins | 15 | 14 | 90 | loose |
| Yeat | Twizardry | 60 | 58 | 359 | loose |
| Yeat | Twizz | 20 | 19 | 58 | loose |
| Yeat | Twizzy | 35 | 46 | 158 | loose |
| Yeat | Twizzy Rich | 33 | 25 | 218 | loose |
| Yeat | Type monëy | 51 | 31 | 236 | loose |
| Yeat | TÖNKA HORSE | 27 | 17 | 179 | loose |
| Yeat | Tëslas & Rovers | 33 | 43 | 197 | loose |
| Yeat | U COULD | 32 | 26 | 146 | loose |
| Yeat | U DONT KNOW LYFE | 40 | 36 | 203 | loose |
| Yeat | U MAD | 24 | 41 | 62 | loose |
| Yeat | U Should Know | 25 | 28 | 178 | loose |
| Yeat | U could tëll | 34 | 35 | 213 | loose |
| Yeat | U got it | 24 | 16 | 70 | loose |
| Yeat | US | 38 | 62 | 340 | loose |
| Yeat | Ugh Ugh Ugh | 26 | 40 | 228 | loose |
| Yeat | Ughh (Brand new coupe / Hold me tight) | 7 | 9 | 27 | loose |
| Yeat | Untitled (dir. Lil Nextel) | 9 | 10 | 14 | loose |
| Yeat | Up 2 Me Now | 31 | 20 | 210 | loose |
| Yeat | Up From Here | 34 | 56 | 188 | loose |
| Yeat | Up off X | 40 | 55 | 213 | loose |
| Yeat | Ups n Downs :(: | 28 | 29 | 138 | loose |
| Yeat | Urus | 38 | 34 | 162 | loose |
| Yeat | Usëd To | 28 | 20 | 147 | loose |
| Yeat | VIBEWME | 22 | 6 | 87 | loose |
| Yeat | W.A.H.W.G.C | 19 | 39 | 104 | loose |
| Yeat | W0RLDCHANGRS | 24 | 15 | 113 | loose |
| Yeat | WAR 1 | 37 | 22 | 217 | loose |
| Yeat | WAR 2 | 47 | 39 | 263 | loose |
| Yeat | WOAH | 36 | 60 | 93 | loose |
| Yeat | WTF | 24 | 17 | 110 | loose |
| Yeat | WTF 2 | 19 | 27 | 103 | loose |
| Yeat | WYE? | 31 | 38 | 133 | loose |
| Yeat | Walk Up | 12 | 9 | 39 | loose |
| Yeat | Walkd Inn | 22 | 16 | 93 | loose |
| Yeat | Wanna be më* | 8 | 8 | 36 | loose |
| Yeat | Wat It is | 20 | 12 | 81 | loose |
| Yeat | Wat Tha Deal | 32 | 27 | 239 | loose |
| Yeat | Wat happen | 34 | 26 | 92 | loose |
| Yeat | Wat it feel lykë | 23 | 24 | 123 | loose |
| Yeat | Wat ü want | 44 | 58 | 171 | loose |
| Yeat | Watch | 34 | 34 | 171 | loose |
| Yeat | Watch Dis | 26 | 11 | 179 | loose |
| Yeat | Watch It | 5 | 2 | 2 | loose |
| Yeat | Watchu Said? | 21 | 11 | 92 | loose |
| Yeat | Wavëy Krazy | 30 | 14 | 122 | loose |
| Yeat | Way back | 38 | 51 | 202 | loose |
| Yeat | We Don’t Trust You* | 4 | 0 | 14 | loose |
| Yeat | We Up | 26 | 29 | 158 | loose |
| Yeat | We at the show* | 6 | 0 | 11 | loose |
| Yeat | Weather (Twitter Snippet) | 6 | 9 | 41 | AAAA |
| Yeat | Went Wrong | 38 | 23 | 106 | loose |
| Yeat | What I Want | 31 | 47 | 116 | loose |
| Yeat | What U Said? | 41 | 56 | 224 | loose |
| Yeat | Wild West | 38 | 26 | 256 | loose |
| Yeat | Wish I Could | 40 | 45 | 261 | loose |
| Yeat | Wit my alien | 33 | 26 | 178 | loose |
| Yeat | Woa OPEN | 4 | 1 | 4 | loose |
| Yeat | Woa...! | 41 | 26 | 177 | loose |
| Yeat | Wokeup | 49 | 47 | 315 | loose |
| Yeat | Wonky | 44 | 55 | 401 | loose |
| Yeat | Woof* | 12 | 6 | 27 | loose |
| Yeat | Work | 32 | 23 | 78 | loose |
| Yeat | Worth More | 41 | 59 | 233 | loose |
| Yeat | Worth None | 35 | 30 | 222 | loose |
| Yeat | Would ya v2 | 21 | 24 | 103 | loose |
| Yeat | Woulda ya (Stylerz) | 17 | 20 | 84 | loose |
| Yeat | Wtf thëy on | 39 | 34 | 308 | loose |
| Yeat | Wtw | 18 | 18 | 107 | loose |
| Yeat | Wya | 56 | 29 | 208 | loose |
| Yeat | WΤw?? | 43 | 55 | 194 | loose |
| Yeat | WΤw?? [Duplicate] | 37 | 41 | 156 | loose |
| Yeat | X | 30 | 30 | 116 | loose |
| Yeat | X Krazy | 31 | 12 | 141 | loose |
| Yeat | X Luv | 31 | 17 | 102 | loose |
| Yeat | X everyday | 26 | 51 | 118 | loose |
| Yeat | X n Oxy | 44 | 47 | 334 | loose |
| Yeat | X ta C | 31 | 28 | 214 | loose |
| Yeat | XD EM OUT | 27 | 17 | 76 | loose |
| Yeat | XMAS | 29 | 24 | 183 | loose |
| Yeat | Xtra Krazy | 39 | 47 | 149 | loose |
| Yeat | YEET | 38 | 47 | 244 | loose |
| Yeat | YOU KNOW I CARE | 29 | 16 | 61 | loose |
| Yeat | Ya Ya | 26 | 37 | 124 | loose |
| Yeat | Yam | 27 | 39 | 144 | loose |
| Yeat | Yea Language | 31 | 33 | 73 | loose |
| Yeat | Yea Yea | 34 | 40 | 210 | loose |
| Yeat | Yea! | 6 | 4 | 39 | loose |
| Yeat | Yeat | 41 | 37 | 278 | loose |
| Yeat | Yeat - LUH Cÿphër | 9 | 4 | 55 | AABB |
| Yeat | Yeat Endlëss | 25 | 13 | 201 | loose |
| Yeat | Yeee | 11 | 5 | 44 | loose |
| Yeat | Young Slime | 10 | 4 | 78 | loose |
| Yeat | [ADL IS COMING] | 43 | 34 | 166 | loose |
| Yeat | all in | 35 | 35 | 124 | loose |
| Yeat | banKroLL | 30 | 46 | 166 | loose |
| Yeat | been 2 long | 25 | 21 | 194 | loose |
| Yeat | bigger thën everything | 37 | 49 | 200 | loose |
| Yeat | booted up | 5 | 6 | 8 | AAAA |
| Yeat | chanel n#9 | 39 | 66 | 128 | loose |
| Yeat | chem high | 5 | 5 | 11 | loose |
| Yeat | chemistry | 52 | 57 | 189 | loose |
| Yeat | chief justice | 32 | 36 | 152 | loose |
| Yeat | death note | 45 | 108 | 351 | loose |
| Yeat | deep blue 30 | 34 | 65 | 148 | loose |
| Yeat | demon speed | 12 | 13 | 69 | loose |
| Yeat | designer drugz | 33 | 38 | 124 | loose |
| Yeat | died before | 55 | 55 | 89 | loose |
| Yeat | dont go | 22 | 16 | 98 | loose |
| Yeat | dope sickk | 22 | 21 | 120 | loose |
| Yeat | drama | 48 | 61 | 230 | loose |
| Yeat | every month | 14 | 11 | 86 | loose |
| Yeat | evrywhere i go | 30 | 30 | 211 | loose |
| Yeat | f*ckn bags | 8 | 6 | 24 | loose |
| Yeat | feel none | 7 | 1 | 15 | loose |
| Yeat | fuck | 32 | 29 | 253 | loose |
| Yeat | fuëgo | 37 | 24 | 289 | loose |
| Yeat | geekin [OPEN] | 21 | 33 | 143 | loose |
| Yeat | got it back | 55 | 62 | 186 | loose |
| Yeat | high asf | 44 | 64 | 265 | loose |
| Yeat | hit making | 26 | 25 | 41 | loose |
| Yeat | hollon | 37 | 42 | 106 | loose |
| Yeat | i Told u 2 | 14 | 8 | 48 | loose |
| Yeat | i see evl | 32 | 27 | 145 | loose |
| Yeat | ikonic | 37 | 76 | 243 | loose |
| Yeat | job (Jog / Feelin Junkie) | 32 | 36 | 95 | loose |
| Yeat | jt 2 uzi [Remix] | 26 | 6 | 168 | loose |
| Yeat | jus talkin fr lol | 26 | 9 | 76 | loose |
| Yeat | kant gët likë dis | 22 | 14 | 121 | loose |
| Yeat | kinda krazy | 39 | 45 | 316 | loose |
| Yeat | king is back | 1 | 0 | 0 | loose |
| Yeat | knew waye | 39 | 42 | 249 | loose |
| Yeat | layup | 29 | 26 | 121 | loose |
| Yeat | leave me lone | 13 | 10 | 84 | loose |
| Yeat | lil vibe (Pull Up On Meh) | 19 | 32 | 112 | loose |
| Yeat | long time | 43 | 43 | 166 | loose |
| Yeat | luh crank | 17 | 11 | 62 | loose |
| Yeat | money twerk 3 | 38 | 60 | 91 | loose |
| Yeat | mt hood | 21 | 7 | 110 | loose |
| Yeat | my birds | 26 | 13 | 169 | loose |
| Yeat | neon green | 19 | 30 | 142 | loose |
| Yeat | new lang | 19 | 6 | 85 | loose |
| Yeat | no issues | 23 | 29 | 96 | loose |
| Yeat | not song | 21 | 13 | 85 | loose |
| Yeat | open (OPEN) | 10 | 4 | 49 | loose |
| Yeat | out of my hands | 28 | 43 | 114 | loose |
| Yeat | perc ten | 34 | 42 | 130 | loose |
| Yeat | popped out | 19 | 18 | 206 | loose |
| Yeat | push 2 start | 9 | 24 | 57 | AAAA |
| Yeat | përctivated | 29 | 31 | 107 | loose |
| Yeat | real or fake | 37 | 55 | 354 | loose |
| Yeat | recap | 4 | 2 | 7 | loose |
| Yeat | recap [Duplicate Page] | 38 | 57 | 179 | loose |
| Yeat | see you later | 7 | 3 | 44 | loose |
| Yeat | sherbinskii | 22 | 32 | 226 | loose |
| Yeat | sick remix | 19 | 21 | 83 | loose |
| Yeat | silent | 23 | 29 | 156 | loose |
| Yeat | sinked in (Wii / Let It Sink In) | 32 | 46 | 165 | loose |
| Yeat | skam shyt | 19 | 28 | 120 | loose |
| Yeat | slidin | 47 | 86 | 260 | loose |
| Yeat | snappz (Full Sail / Alien Summer) | 39 | 55 | 247 | loose |
| Yeat | tha end | 45 | 46 | 144 | loose |
| Yeat | tonka freestyle | 26 | 25 | 142 | loose |
| Yeat | too much | 37 | 32 | 288 | loose |
| Yeat | try me | 26 | 15 | 103 | loose |
| Yeat | turnedd into some | 51 | 69 | 204 | loose |
| Yeat | up | 20 | 10 | 115 | loose |
| Yeat | wat happën (2022) | 32 | 24 | 151 | loose |
| Yeat | wat u did today | 41 | 48 | 247 | loose |
| Yeat | way i did | 11 | 2 | 75 | loose |
| Yeat | went there* | 6 | 2 | 16 | loose |
| Yeat | what ya want.. | 24 | 24 | 160 | loose |
| Yeat | whenever i want | 13 | 7 | 61 | loose |
| Yeat | whole lot different | 31 | 16 | 211 | loose |
| Yeat | wit da gods | 34 | 39 | 171 | loose |
| Yeat | wokiki | 30 | 22 | 114 | loose |
| Yeat | z06 | 36 | 26 | 234 | loose |
| Yeat | zaza | 35 | 55 | 92 | loose |
| Yeat | Ëlla | 6 | 5 | 36 | loose |
| Yeat | Ëxotic Drugs / OMG | 21 | 13 | 88 | loose |
| Yeat | ‎Countup | 39 | 67 | 224 | loose |
| Yeat | ‎Televised | 39 | 59 | 198 | loose |
| Yeat | ‎nëw phone | 36 | 57 | 201 | loose |
| Yeat | ‘N KNEE DEEP | 19 | 18 | 131 | loose |
