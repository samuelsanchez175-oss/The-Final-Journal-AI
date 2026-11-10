# Travis Scott rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Travis Scott
- Songs: 588
- Bars kept (Travis Scott lyric lines): 23407
- Section headers dropped, not counted as bars: 9
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 61
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 60
- Canonical name: Travis Scott.
- Credit strings: Travis Scott.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 123803
- REPEAT pairs, recorded separately: 18381
- END rhymes: 22437
- INNER rhymes: 101366

By match:

- PERFECT: 11252 (END 3022, INNER 8230)
- SLANT: 51414 (END 9370, INNER 42044)
- ASSONANCE: 59749 (END 9568, INNER 50181)
- MULTI: 1388 (END 477, INNER 911)

By confidence:

- HIGH: 11774
- MED: 105436
- LOW: 6593

## Core

- Core Y: 121764
- Core N among rhyme pairs: 2039

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 57250 (46.2%)
- vowel: 59749 (48.3%)
- spelling: 5416 (4.4%)
- multi: 1388 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 3 songs
- ABAB: 1 songs
- AABA: 1 songs
- loose: 583 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 8602 pairs (END 1249, INNER 7353). Words: don't, know, no, go, told, hoes, over, ho.
2. `vow:IH` — 7753 pairs (END 940, INNER 6813). Words: shit, bitch, bitches, think, hit, still, wrist, little.
3. `vow:EY` — 7141 pairs (END 1348, INNER 5793). Words: ain't, way, say, day, take, make, play, baby.
4. `vow:EH` — 6923 pairs (END 1018, INNER 5905). Words: get, when, never, gettin, left, tell, let, friends.
5. `vow:AY` — 5680 pairs (END 968, INNER 4712). Words: like, by, time, high, why, diamonds, try, mind.
6. `vow:AE` — 5600 pairs (END 1015, INNER 4585). Words: can't, back, last, had, have, can, man, ass.
7. `vow:AA` — 4882 pairs (END 560, INNER 4322). Words: got, want, la, wanna, not, hard, talkin, party.
8. `vow:IY` — 4816 pairs (END 851, INNER 3965). Words: see, need, these, even, keep, three, feel, here.
9. `vow:AH` — 3822 pairs (END 560, INNER 3262). Words: fuck, love, some, what, come, one, somethin, hundred.
10. `slant:AA:stop` — 2499 pairs (END 291, INNER 2208). Words: got, gotta, not, want, top, pop, god, body.
11. `slant:IH:stop` — 1995 pairs (END 310, INNER 1685). Words: nigga, shit, hit, big, dick, city, crib, whip.
12. `slant:AY:stop` — 1900 pairs (END 351, INNER 1549). Words: like, right, night, side, ride, might, outside, type.
13. `cmu:OW` — 1676 pairs (END 297, INNER 1379). Words: know, no, go, ho, show, though, blow, throw.
14. `slant:EH:stop` — 1472 pairs (END 248, INNER 1224). Words: get, let, better, said, check, left, head, neck.
15. `vow:UW` — 1450 pairs (END 418, INNER 1032). Words: new, through, two, who, blue, move, used, shoot.
16. `slant:IH:sib-stop` — 1426 pairs (END 308, INNER 1118). Words: bitch, shit, nigga, niggas, hit, dick, rich, big.
17. `slant:AY:nas-stop` — 1254 pairs (END 238, INNER 1016). Words: time, like, line, mine, right, night, ride, might.
18. `slant:AH:nas-stop` — 1241 pairs (END 78, INNER 1163). Words: fuck, what, one, some, young, money, come, thug.
19. `vow:AO` — 1205 pairs (END 159, INNER 1046). Words: all, call, more, lost, mornin, long, order, walk.
20. `slant:AE:stop` — 1186 pairs (END 231, INNER 955). Words: back, had, can't, bad, bag, last, trap, black.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 873 pair sides, mostly spelling via spelling phonetic key, often with niggas (227)
- niggas — 400 pair sides, mostly spelling via spelling phonetic key, often with nigga (227)
- ima — 388 pair sides, mostly spelling via spelling phonetic key, often with hit (52)
- gon — 356 pair sides, mostly spelling via spelling phonetic key, often with dont (69)
- tryna — 308 pair sides, mostly spelling via spelling phonetic key, often with these (52)
- shawty — 179 pair sides, mostly vowel via spelling phonetic key, often with all (22)
- homie — 65 pair sides, mostly spelling via spelling phonetic key, often with gon (5)
- quavo — 64 pair sides, mostly spelling via spelling phonetic key, often with travis (6)
- toppy — 52 pair sides, mostly vowel via spelling phonetic key, often with sloppy (26)
- xans — 52 pair sides, mostly spelling via spelling phonetic key, often with plans (13)
- lambo — 52 pair sides, mostly vowel via spelling phonetic key, often with go (15)
- geeked — 51 pair sides, mostly spelling via spelling phonetic key, often with sleep (5)
- dawg — 50 pair sides, mostly spelling via spelling phonetic key, often with all (14)
- swag — 45 pair sides, mostly spelling via spelling phonetic key, often with man (4)
- thot — 40 pair sides, mostly spelling via spelling phonetic key, often with got (5)
- codeine — 39 pair sides, mostly vowel via spelling phonetic key, often with moses (6)
- meto — 38 pair sides, mostly vowel via spelling phonetic key, often with lo (7)
- bros — 37 pair sides, mostly spelling via spelling phonetic key, often with gon (2)
- kanye — 36 pair sides, mostly spelling via spelling phonetic key, often with man (7)
- rari — 33 pair sides, mostly spelling via spelling phonetic key, often with back (5)
- finna — 31 pair sides, mostly vowel via spelling phonetic key, often with niggas (6)
- lyin — 30 pair sides, mostly spelling via spelling phonetic key, often with need (3)
- vamo — 29 pair sides, mostly vowel via spelling phonetic key, often with lo (3)
- prolly — 26 pair sides, mostly vowel via spelling phonetic key, often with see (2)
- fam — 26 pair sides, mostly spelling via spelling phonetic key, often with pass (4)
- opps — 25 pair sides, mostly vowel via spelling phonetic key, often with dont (8)
- blocka — 25 pair sides, mostly spelling via spelling phonetic key, often with choppas (9)
- tiempo — 25 pair sides, mostly vowel via spelling phonetic key, often with no (5)
- homies — 24 pair sides, mostly spelling via spelling phonetic key, often with homie (4)
- chiefing — 24 pair sides, mostly spelling via spelling phonetic key, often with getting (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Travis Scott | #727 | 53 | 61 | 233 | loose |
| Travis Scott | $hut Up!!! | 33 | 20 | 148 | loose |
| Travis Scott | $tay | 30 | 22 | 175 | loose |
| Travis Scott | .WAV RADIO EP 1 Tracklist | 51 | 14 | 269 | loose |
| Travis Scott | .WAV RADIO EP 2 Tracklist | 69 | 21 | 243 | loose |
| Travis Scott | .WAV RADIO EP 3 Tracklist | 20 | 4 | 11 | loose |
| Travis Scott | .WAV RADIO EP 5 Tracklist | 35 | 9 | 115 | loose |
| Travis Scott | .WAV RADIO EP 7 Tracklist | 35 | 8 | 94 | loose |
| Travis Scott | .WAV RADIO EP 8 Tracklist | 34 | 6 | 89 | loose |
| Travis Scott | .Wav Radio Freestyle | 123 | 158 | 490 | loose |
| Travis Scott | 1 Thing About Me | 32 | 23 | 216 | loose |
| Travis Scott | 10 2 10 | 34 | 31 | 196 | loose |
| Travis Scott | 100 Bottles | 5 | 0 | 19 | loose |
| Travis Scott | 100 Bottles (Remix) | 45 | 23 | 105 | loose |
| Travis Scott | 10s and Up | 27 | 20 | 111 | loose |
| Travis Scott | 12 Disciples | 23 | 33 | 157 | loose |
| Travis Scott | 16 Chapels | 40 | 28 | 121 | loose |
| Travis Scott | 1st Quarter Freestyle | 89 | 93 | 382 | loose |
| Travis Scott | 2 Fucks | 88 | 99 | 539 | loose |
| Travis Scott | 2 Many Chances | 6 | 1 | 11 | loose |
| Travis Scott | 2000 EXCURSION | 52 | 78 | 215 | loose |
| Travis Scott | 2013 BET Hip Hop Awards - Cypher 3 | 71 | 48 | 528 | loose |
| Travis Scott | 2018 Grammys Performance | 106 | 55 | 394 | loose |
| Travis Scott | 2019 Grammys Performance | 26 | 20 | 127 | loose |
| Travis Scott | 3 Wayz | 29 | 19 | 86 | loose |
| Travis Scott | 3500 | 95 | 76 | 347 | loose |
| Travis Scott | 4 AM | 60 | 57 | 204 | loose |
| Travis Scott | 4X4 | 33 | 42 | 185 | loose |
| Travis Scott | 5 Mo | 25 | 20 | 101 | loose |
| Travis Scott | 5% TINT | 28 | 27 | 185 | loose |
| Travis Scott | 712PM | 40 | 40 | 449 | loose |
| Travis Scott | 90210 | 49 | 37 | 265 | loose |
| Travis Scott | A man | 40 | 35 | 149 | loose |
| Travis Scott | A-Team | 27 | 26 | 44 | loose |
| Travis Scott | AEIO | 6 | 4 | 32 | loose |
| Travis Scott | ASTROTHUNDER | 18 | 25 | 124 | loose |
| Travis Scott | AT THE PARTY | 70 | 83 | 247 | loose |
| Travis Scott | Abracadabra | 43 | 51 | 222 | loose |
| Travis Scott | Active | 40 | 28 | 177 | loose |
| Travis Scott | After Party | 21 | 13 | 66 | loose |
| Travis Scott | Ahoy | 61 | 29 | 150 | loose |
| Travis Scott | All Day | 67 | 23 | 333 | loose |
| Travis Scott | All I Know (Demo) | 38 | 25 | 131 | loose |
| Travis Scott | All Year* | 19 | 6 | 65 | loose |
| Travis Scott | All Your Fault | 63 | 77 | 340 | loose |
| Travis Scott | Amazing | 29 | 27 | 103 | loose |
| Travis Scott | Analogue | 37 | 37 | 161 | loose |
| Travis Scott | Animal | 50 | 47 | 278 | loose |
| Travis Scott | Another Check | 23 | 13 | 120 | loose |
| Travis Scott | Antidote | 51 | 73 | 191 | loose |
| Travis Scott | Antisocial | 32 | 29 | 133 | loose |
| Travis Scott | Anytime | 41 | 28 | 162 | loose |
| Travis Scott | Apple Pie | 44 | 19 | 305 | loose |
| Travis Scott | Around Me | 24 | 16 | 121 | loose |
| Travis Scott | Astronomical | 29 | 26 | 71 | loose |
| Travis Scott | Astroworld | 4 | 0 | 15 | loose |
| Travis Scott | Aye | 34 | 26 | 113 | loose |
| Travis Scott | BABY ROYAL | 1 | 0 | 0 | loose |
| Travis Scott | BACC (Bonus) | 26 | 21 | 129 | loose |
| Travis Scott | BACKR00MS | 38 | 36 | 266 | loose |
| Travis Scott | BEEP BEEP | 61 | 87 | 259 | loose |
| Travis Scott | BET Cypher 2013 | 19 | 12 | 71 | loose |
| Travis Scott | BGYCFMB | 33 | 14 | 159 | loose |
| Travis Scott | BROTHER STONE | 42 | 42 | 329 | loose |
| Travis Scott | BUTTERFLY EFFECT | 29 | 32 | 130 | loose |
| Travis Scott | Back On It (Demo) | 56 | 43 | 218 | loose |
| Travis Scott | Back Up (Remix) | 46 | 50 | 238 | loose |
| Travis Scott | Back of My Benz | 8 | 5 | 2 | loose |
| Travis Scott | Backyard | 46 | 59 | 244 | loose |
| Travis Scott | Bad Mood (Demo) | 15 | 7 | 19 | loose |
| Travis Scott | Bad Mood / Shit on You | 50 | 31 | 197 | loose |
| Travis Scott | Bake Sale | 56 | 40 | 184 | loose |
| Travis Scott | Bandz | 36 | 18 | 240 | loose |
| Travis Scott | Bape | 25 | 14 | 109 | loose |
| Travis Scott | Baptized in Fire | 51 | 22 | 256 | loose |
| Travis Scott | Basement Freestyle | 59 | 26 | 142 | loose |
| Travis Scott | Batman | 34 | 34 | 98 | loose |
| Travis Scott | Be In Love (The Freshest) | 33 | 32 | 227 | loose |
| Travis Scott | Best Man | 46 | 43 | 190 | loose |
| Travis Scott | Big Champ | 41 | 44 | 220 | loose |
| Travis Scott | Big Shot | 34 | 23 | 162 | loose |
| Travis Scott | Birds in the Trap [Short Film] | 71 | 27 | 298 | loose |
| Travis Scott | Bitch Betta Have My Money | 27 | 21 | 106 | loose |
| Travis Scott | Bitch Better Have My Money | 21 | 25 | 78 | loose |
| Travis Scott | Black & Chinese | 39 | 33 | 166 | loose |
| Travis Scott | Black Folk | 26 | 21 | 141 | loose |
| Travis Scott | Black Mass | 24 | 54 | 126 | loose |
| Travis Scott | Black Skinhead (Remix) | 59 | 58 | 107 | loose |
| Travis Scott | Blame | 40 | 60 | 132 | loose |
| Travis Scott | Bless Em | 37 | 61 | 274 | loose |
| Travis Scott | Blocka | 32 | 26 | 154 | loose |
| Travis Scott | Blocka La Flame | 38 | 27 | 196 | loose |
| Travis Scott | Blue Pill | 31 | 20 | 96 | loose |
| Travis Scott | Blunt Talk | 36 | 31 | 210 | loose |
| Travis Scott | Body | 24 | 11 | 118 | loose |
| Travis Scott | Bow Down (Homecoming Live) | 19 | 10 | 70 | loose |
| Travis Scott | Brand New Choppa | 63 | 40 | 228 | loose |
| Travis Scott | Bruh (Ooh Na Na) | 7 | 3 | 29 | loose |
| Travis Scott | Bubbly | 62 | 111 | 283 | loose |
| Travis Scott | Buss It (Remix) | 54 | 44 | 256 | loose |
| Travis Scott | By My Side (Forever Be) | 20 | 27 | 101 | loose |
| Travis Scott | CAN U BE | 63 | 44 | 181 | loose |
| Travis Scott | CAN’T SAY | 39 | 35 | 246 | loose |
| Travis Scott | CAROUSEL | 41 | 79 | 167 | loose |
| Travis Scott | CHAMPAIN & VACAY | 47 | 41 | 161 | loose |
| Travis Scott | CHARGE DEM HOES A FEE | 50 | 42 | 234 | loose |
| Travis Scott | CHopstix | 34 | 16 | 88 | loose |
| Travis Scott | CIRCUS MAXIMUS | 62 | 57 | 98 | loose |
| Travis Scott | CLOSE | 35 | 57 | 194 | loose |
| Travis Scott | COFFEE BEAN | 45 | 63 | 159 | loose |
| Travis Scott | CONTEST | 46 | 62 | 359 | loose |
| Travis Scott | CR@SH | 39 | 59 | 257 | loose |
| Travis Scott | CRUSH | 35 | 54 | 51 | loose |
| Travis Scott | California Girls | 24 | 10 | 80 | loose |
| Travis Scott | Candy | 24 | 7 | 20 | loose |
| Travis Scott | Can’t Get Over Me | 49 | 27 | 95 | loose |
| Travis Scott | Carnage (Man of My City Demo) | 21 | 18 | 70 | loose |
| Travis Scott | Catrin (the city) | 13 | 4 | 41 | loose |
| Travis Scott | Celebrate | 27 | 15 | 89 | loose |
| Travis Scott | Champion | 33 | 32 | 123 | loose |
| Travis Scott | Champions | 103 | 127 | 306 | loose |
| Travis Scott | Chandeliers | 48 | 49 | 131 | loose |
| Travis Scott | Chaz Interlude | 4 | 1 | 7 | loose |
| Travis Scott | Chimes (Remix) | 40 | 32 | 158 | loose |
| Travis Scott | Cinderella | 42 | 80 | 126 | loose |
| Travis Scott | Clap (Demo) | 21 | 17 | 44 | loose |
| Travis Scott | Collision* | 20 | 13 | 161 | loose |
| Travis Scott | Company | 55 | 29 | 297 | loose |
| Travis Scott | Compton | 48 | 34 | 126 | loose |
| Travis Scott | Creepin’ | 35 | 21 | 99 | loose |
| Travis Scott | Crown | 45 | 46 | 149 | loose |
| Travis Scott | DA WIZARD | 28 | 23 | 200 | loose |
| Travis Scott | DELRESTO (ECHOES) | 48 | 30 | 122 | loose |
| Travis Scott | DOUGIE F - ANTI (DELETE) | 4 | 1 | 8 | loose |
| Travis Scott | DUMBO | 37 | 78 | 305 | loose |
| Travis Scott | Dance on the Moon | 60 | 51 | 272 | loose |
| Travis Scott | Dangerous World | 38 | 31 | 122 | loose |
| Travis Scott | Dark Knight Dummo | 41 | 62 | 164 | loose |
| Travis Scott | Day ‘n’ Nite | 32 | 10 | 57 | loose |
| Travis Scott | Days Before Rodeo: The Prayer | 20 | 24 | 117 | loose |
| Travis Scott | Demon (Ecstasy) | 22 | 21 | 81 | loose |
| Travis Scott | Deserve | 26 | 19 | 130 | loose |
| Travis Scott | Diamonds Dancing | 69 | 83 | 254 | loose |
| Travis Scott | Dinosaurus | 36 | 23 | 204 | loose |
| Travis Scott | Dis Ain’t What You Want (Remix) | 64 | 28 | 279 | loose |
| Travis Scott | Dis Side (Demo) | 37 | 62 | 107 | AAAA |
| Travis Scott | Don’t Play | 48 | 42 | 226 | loose |
| Travis Scott | Don’t Quit | 42 | 45 | 108 | loose |
| Travis Scott | Down In Atlanta | 28 | 18 | 145 | loose |
| Travis Scott | Down for Life | 70 | 40 | 242 | loose |
| Travis Scott | Dream | 40 | 19 | 151 | loose |
| Travis Scott | Dreamcatcher | 49 | 45 | 158 | loose |
| Travis Scott | Drive | 33 | 12 | 139 | loose |
| Travis Scott | Drugs You Should Try It | 33 | 15 | 97 | loose |
| Travis Scott | Drunk (Demo) | 29 | 19 | 89 | loose |
| Travis Scott | Dubai Shit | 41 | 35 | 115 | loose |
| Travis Scott | Dust | 47 | 53 | 283 | loose |
| Travis Scott | E85 | 18 | 13 | 96 | loose |
| Travis Scott | ESCAPE PLAN | 25 | 15 | 200 | loose |
| Travis Scott | Easy | 32 | 19 | 127 | loose |
| Travis Scott | Eaters | 68 | 48 | 221 | loose |
| Travis Scott | Ecstasy | 15 | 11 | 24 | loose |
| Travis Scott | Embarrassed | 49 | 46 | 152 | loose |
| Travis Scott | Enormous | 49 | 34 | 342 | loose |
| Travis Scott | Euphoria | 34 | 30 | 148 | loose |
| Travis Scott | Europa Pools (Demo) | 11 | 17 | 25 | loose |
| Travis Scott | Eye 2 Eye | 46 | 77 | 169 | loose |
| Travis Scott | FATHER | 40 | 17 | 59 | loose |
| Travis Scott | FE!N | 37 | 41 | 211 | loose |
| Travis Scott | FE!N - Remix | 18 | 14 | 161 | loose |
| Travis Scott | FE!N / Until I Bleed Out (The Weeknd: Live at São Paulo) | 13 | 2 | 41 | loose |
| Travis Scott | FLORIDA FLOW | 62 | 48 | 567 | loose |
| Travis Scott | FLORIDA FLOW (Physical Edition) | 5 | 1 | 7 | loose |
| Travis Scott | FML | 44 | 43 | 125 | loose |
| Travis Scott | FRANCHISE | 51 | 42 | 283 | loose |
| Travis Scott | FTCU (SLEEZEMIX) | 63 | 71 | 337 | loose |
| Travis Scott | FUK SUMN | 37 | 23 | 161 | loose |
| Travis Scott | FUK SUMN Pt. 2 | 14 | 7 | 116 | loose |
| Travis Scott | FUNKY WIZARD SMOKE | 39 | 25 | 170 | loose |
| Travis Scott | Facts | 44 | 90 | 329 | loose |
| Travis Scott | Fair Trade | 79 | 53 | 344 | loose |
| Travis Scott | Familiar | 52 | 35 | 213 | loose |
| Travis Scott | Family* | 6 | 1 | 22 | loose |
| Travis Scott | Feel It | 25 | 8 | 72 | loose |
| Travis Scott | Feels Like Summer | 25 | 19 | 53 | loose |
| Travis Scott | Finesse (Quintana Pt. 2 Demo) | 16 | 3 | 42 | loose |
| Travis Scott | Fingers Blue | 36 | 39 | 160 | loose |
| Travis Scott | Fire | 22 | 12 | 36 | loose |
| Travis Scott | First Off | 47 | 38 | 277 | loose |
| Travis Scott | Fish n Grits | 53 | 43 | 250 | loose |
| Travis Scott | Flawless / Feeling Myself (Homecoming Live) | 46 | 20 | 79 | loose |
| Travis Scott | Flocky Flocky | 28 | 24 | 150 | loose |
| Travis Scott | Floyd Mayweather | 94 | 170 | 450 | loose |
| Travis Scott | Flying High | 19 | 14 | 163 | loose |
| Travis Scott | Forgiato | 8 | 8 | 28 | loose |
| Travis Scott | Forgive Me | 38 | 19 | 103 | loose |
| Travis Scott | Freestyle | 54 | 76 | 227 | loose |
| Travis Scott | Fuck & Smoke | 35 | 19 | 174 | loose |
| Travis Scott | Future Bounce (Demo) | 5 | 5 | 21 | AABA |
| Travis Scott | Future Sounds | 24 | 45 | 63 | loose |
| Travis Scott | GANG GANG | 65 | 106 | 225 | loose |
| Travis Scott | GATTI | 45 | 53 | 139 | loose |
| Travis Scott | GET OFF ME | 50 | 42 | 207 | loose |
| Travis Scott | GF | 8 | 2 | 42 | loose |
| Travis Scott | GOD’S COUNTRY | 22 | 17 | 66 | loose |
| Travis Scott | GOLD BLACKBERRY | 35 | 51 | 295 | loose |
| Travis Scott | GOOD Morning | 34 | 36 | 176 | loose |
| Travis Scott | Ghostface Killers | 58 | 51 | 362 | loose |
| Travis Scott | Ghosttown | 41 | 49 | 209 | loose |
| Travis Scott | Gigi (what you went through) | 19 | 23 | 29 | loose |
| Travis Scott | Girlfriend | 17 | 11 | 60 | loose |
| Travis Scott | Give No Fxk | 38 | 28 | 252 | loose |
| Travis Scott | Go | 21 | 39 | 118 | loose |
| Travis Scott | Go All Night | 32 | 17 | 44 | loose |
| Travis Scott | Go Legend | 52 | 54 | 269 | loose |
| Travis Scott | Go Off | 45 | 25 | 155 | loose |
| Travis Scott | God Level | 27 | 24 | 200 | loose |
| Travis Scott | Gold 88 | 32 | 12 | 91 | loose |
| Travis Scott | Goodnight | 31 | 39 | 193 | loose |
| Travis Scott | Green & Purple | 84 | 124 | 163 | loose |
| Travis Scott | Grey | 35 | 46 | 178 | loose |
| Travis Scott | Guilt Trip | 29 | 19 | 109 | loose |
| Travis Scott | HEARTBEAT* | 27 | 34 | 150 | loose |
| Travis Scott | HIGHEST IN THE ROOM | 33 | 34 | 56 | loose |
| Travis Scott | HOTEL LOBBY (Unc & Phew) | 37 | 46 | 193 | loose |
| Travis Scott | HOUSTONFORNICATION | 43 | 93 | 224 | loose |
| Travis Scott | HYAENA | 45 | 31 | 213 | loose |
| Travis Scott | Hands On (Remix) | 63 | 70 | 241 | loose |
| Travis Scott | Hats Off | 96 | 101 | 393 | loose |
| Travis Scott | Heaven and Hell | 33 | 25 | 128 | loose |
| Travis Scott | Heavy Camp | 28 | 35 | 110 | loose |
| Travis Scott | Hell You Saying | 75 | 55 | 398 | loose |
| Travis Scott | Hell of a Night | 26 | 21 | 120 | loose |
| Travis Scott | Hi | 33 | 9 | 102 | loose |
| Travis Scott | High Fashion | 39 | 38 | 167 | loose |
| Travis Scott | Hold On | 49 | 53 | 146 | loose |
| Travis Scott | Hold That Heat | 55 | 95 | 218 | loose |
| Travis Scott | Home | 46 | 21 | 192 | loose |
| Travis Scott | Hop Off a Jet | 43 | 37 | 224 | loose |
| Travis Scott | Hot (Remix) | 79 | 119 | 379 | loose |
| Travis Scott | Hot Sauce (Version 1) | 20 | 3 | 56 | loose |
| Travis Scott | Houdini | 38 | 42 | 79 | loose |
| Travis Scott | Houstatlantaville | 50 | 68 | 485 | loose |
| Travis Scott | How U Feel | 44 | 38 | 140 | loose |
| Travis Scott | Huncho Jack | 57 | 90 | 98 | loose |
| Travis Scott | I Am A God | 39 | 42 | 136 | loose |
| Travis Scott | I Am Not Home | 6 | 3 | 21 | loose |
| Travis Scott | I Can Tell | 41 | 34 | 242 | loose |
| Travis Scott | I Don’t Know* | 24 | 6 | 153 | loose |
| Travis Scott | I Don’t Trust These Bitches | 41 | 25 | 246 | loose |
| Travis Scott | I Get It | 39 | 45 | 412 | loose |
| Travis Scott | I KNOW ? | 41 | 26 | 125 | loose |
| Travis Scott | ICE AGE | 42 | 39 | 215 | loose |
| Travis Scott | ILLemeriCA | 33 | 25 | 202 | loose |
| Travis Scott | ILMB | 48 | 40 | 278 | loose |
| Travis Scott | INSIDE | 27 | 17 | 131 | loose |
| Travis Scott | Illuminati | 32 | 24 | 121 | loose |
| Travis Scott | Impossible | 41 | 24 | 125 | loose |
| Travis Scott | In Common (Remix) | 46 | 37 | 105 | loose |
| Travis Scott | In My Head (Demo) | 44 | 68 | 154 | loose |
| Travis Scott | Intro | 10 | 3 | 78 | loose |
| Travis Scott | It’s Secured | 47 | 39 | 186 | loose |
| Travis Scott | I’m Fine | 55 | 50 | 231 | loose |
| Travis Scott | I’m Good | 31 | 35 | 171 | loose |
| Travis Scott | I’m Leanin’ | 83 | 62 | 321 | loose |
| Travis Scott | JB2 RADIO | 8 | 0 | 21 | loose |
| Travis Scott | JUS KNOW | 34 | 21 | 83 | loose |
| Travis Scott | Joyride | 31 | 14 | 76 | loose |
| Travis Scott | Jump | 42 | 44 | 143 | loose |
| Travis Scott | Jungle Gym* | 23 | 21 | 109 | loose |
| Travis Scott | K-POP | 52 | 49 | 281 | loose |
| Travis Scott | KICK OUT (Physical Version) | 38 | 66 | 172 | loose |
| Travis Scott | KRZY TRAIN | 35 | 49 | 192 | loose |
| Travis Scott | Keep Goin’ Freestyle | 13 | 22 | 32 | AAAA |
| Travis Scott | Kelly Price | 67 | 125 | 253 | loose |
| Travis Scott | Knife | 14 | 9 | 84 | loose |
| Travis Scott | Know No Better | 46 | 50 | 112 | loose |
| Travis Scott | Know You Miss Me | 14 | 4 | 54 | loose |
| Travis Scott | Krippy Kush (Travis Scott Remix) | 55 | 47 | 440 | loose |
| Travis Scott | L.O.V.E. Interlude | 4 | 0 | 3 | loose |
| Travis Scott | LEGEND IN MY HOOD* | 7 | 5 | 25 | loose |
| Travis Scott | LET’S PRAY | 32 | 38 | 162 | loose |
| Travis Scott | LOOOVE | 53 | 34 | 247 | loose |
| Travis Scott | LOST | 48 | 49 | 167 | loose |
| Travis Scott | LOST FOREVER | 48 | 40 | 207 | loose |
| Travis Scott | Laptop (Remix)* | 4 | 1 | 14 | loose |
| Travis Scott | Last Time | 43 | 36 | 248 | loose |
| Travis Scott | Lastly* | 16 | 4 | 123 | loose |
| Travis Scott | Left Cheek, Right Cheek | 16 | 13 | 56 | loose |
| Travis Scott | Legacy | 82 | 82 | 349 | loose |
| Travis Scott | Lens (V2) | 52 | 41 | 203 | loose |
| Travis Scott | Let Her Go | 17 | 10 | 57 | loose |
| Travis Scott | Let It Fly | 50 | 79 | 403 | loose |
| Travis Scott | License | 12 | 10 | 43 | loose |
| Travis Scott | Lights (Love Sick) | 33 | 20 | 170 | loose |
| Travis Scott | Likka Sto 2 | 78 | 83 | 446 | loose |
| Travis Scott | Lithuania | 46 | 47 | 270 | loose |
| Travis Scott | LoFi | 34 | 46 | 139 | loose |
| Travis Scott | Lock On Me | 47 | 35 | 230 | loose |
| Travis Scott | Locked Away* | 13 | 4 | 56 | loose |
| Travis Scott | Lords Never Worry | 66 | 54 | 321 | loose |
| Travis Scott | Loudah | 11 | 9 | 35 | loose |
| Travis Scott | Love Galore | 59 | 26 | 206 | loose |
| Travis Scott | Love Hurts | 41 | 45 | 73 | loose |
| Travis Scott | Love It Mane | 19 | 3 | 46 | loose |
| Travis Scott | Low | 34 | 17 | 154 | loose |
| Travis Scott | MAFIA | 38 | 52 | 196 | loose |
| Travis Scott | MELTDOWN | 70 | 89 | 352 | loose |
| Travis Scott | MIA | 44 | 25 | 198 | loose |
| Travis Scott | MIXED EMOTIONS | 45 | 46 | 274 | loose |
| Travis Scott | MODERN JAM | 45 | 61 | 152 | loose |
| Travis Scott | MY EYES | 66 | 61 | 350 | loose |
| Travis Scott | Mamacita | 14 | 13 | 49 | loose |
| Travis Scott | Man of My City | 44 | 36 | 224 | loose |
| Travis Scott | Maria I’m Drunk | 58 | 43 | 229 | loose |
| Travis Scott | Me or Us (Remix) | 52 | 36 | 222 | loose |
| Travis Scott | Meadow Creek | 27 | 15 | 123 | loose |
| Travis Scott | Mediterranean | 44 | 50 | 284 | loose |
| Travis Scott | Might Go* | 11 | 6 | 25 | loose |
| Travis Scott | Mile High | 39 | 44 | 72 | loose |
| Travis Scott | Miss My Dawgs | 52 | 45 | 271 | loose |
| Travis Scott | Mo City Flexologist | 39 | 64 | 187 | loose |
| Travis Scott | Modern Slavery | 38 | 24 | 120 | loose |
| Travis Scott | Momma Be Trippin | 39 | 19 | 233 | loose |
| Travis Scott | Money Counter | 54 | 69 | 351 | loose |
| Travis Scott | Money Go | 44 | 51 | 188 | loose |
| Travis Scott | Money, Power, Respect | 20 | 27 | 161 | loose |
| Travis Scott | Moon Rock | 39 | 44 | 211 | loose |
| Travis Scott | Moses | 58 | 49 | 204 | loose |
| Travis Scott | Motorcycle Patches | 47 | 67 | 180 | loose |
| Travis Scott | Murda | 37 | 36 | 184 | loose |
| Travis Scott | My Ex Best Friend | 32 | 20 | 92 | loose |
| Travis Scott | Myles | 68 | 54 | 154 | loose |
| Travis Scott | NC-17 | 29 | 16 | 135 | loose |
| Travis Scott | NO BYSTANDERS | 54 | 65 | 193 | loose |
| Travis Scott | Naked | 22 | 18 | 100 | loose |
| Travis Scott | Naughty | 40 | 30 | 111 | loose |
| Travis Scott | Neighbor | 39 | 45 | 157 | loose |
| Travis Scott | Neptune Estate (Travi$ Scott RMX) | 31 | 31 | 201 | loose |
| Travis Scott | Never Catch Me | 20 | 12 | 129 | loose |
| Travis Scott | Never Sleep | 52 | 95 | 260 | loose |
| Travis Scott | New Idea 1 (Marietta)* | 98 | 70 | 343 | loose |
| Travis Scott | New Slaves | 48 | 33 | 159 | loose |
| Travis Scott | Niagara Falls (Foot or 2) | 45 | 51 | 98 | loose |
| Travis Scott | Night | 24 | 3 | 139 | loose |
| Travis Scott | Night Call | 71 | 71 | 246 | loose |
| Travis Scott | Night Riders | 32 | 20 | 241 | loose |
| Travis Scott | Nightcrawler | 65 | 62 | 193 | loose |
| Travis Scott | Nightcrawler (Demo 1) | 34 | 14 | 77 | loose |
| Travis Scott | Nightcrawler (Demo 2) | 12 | 6 | 34 | loose |
| Travis Scott | No Cap | 46 | 56 | 236 | loose |
| Travis Scott | No English | 45 | 55 | 295 | loose |
| Travis Scott | No Feelings | 28 | 16 | 111 | loose |
| Travis Scott | No Introductions (Flashing Lights) | 33 | 18 | 72 | loose |
| Travis Scott | No Limit (G-Mix) | 114 | 99 | 506 | loose |
| Travis Scott | No More | 58 | 48 | 344 | loose |
| Travis Scott | No Sense | 38 | 15 | 164 | loose |
| Travis Scott | No Vacancy | 56 | 77 | 295 | loose |
| Travis Scott | Not Afraid of Love | 33 | 12 | 76 | loose |
| Travis Scott | Nothing But Net | 49 | 22 | 154 | loose |
| Travis Scott | ON THE MOON | 22 | 30 | 47 | loose |
| Travis Scott | OUT OF MY MIND* | 28 | 15 | 87 | loose |
| Travis Scott | OUT WEST | 32 | 41 | 168 | loose |
| Travis Scott | Oh Chet | 37 | 36 | 280 | loose |
| Travis Scott | Oh Me Oh My | 50 | 87 | 122 | loose |
| Travis Scott | Oh My (Demo) | 12 | 1 | 35 | loose |
| Travis Scott | Oh My Dis Side | 75 | 81 | 160 | loose |
| Travis Scott | Oh Shhh... | 37 | 23 | 78 | loose |
| Travis Scott | Ok Alright | 51 | 28 | 309 | loose |
| Travis Scott | Old English | 37 | 16 | 122 | loose |
| Travis Scott | On Everything | 48 | 33 | 282 | loose |
| Travis Scott | On Fleek | 70 | 142 | 211 | loose |
| Travis Scott | On My Vibe | 28 | 21 | 198 | loose |
| Travis Scott | Only 1 (Interlude) | 14 | 7 | 39 | loose |
| Travis Scott | Open Arms | 47 | 37 | 159 | loose |
| Travis Scott | Overdue | 34 | 40 | 81 | loose |
| Travis Scott | Owe Me | 62 | 39 | 317 | loose |
| Travis Scott | P.T.W.I.L.U. (Preme Remix) | 7 | 4 | 9 | loose |
| Travis Scott | PABLO | 33 | 30 | 69 | loose |
| Travis Scott | PABLO [V38] | 54 | 32 | 198 | loose |
| Travis Scott | PARASAIL | 25 | 9 | 59 | loose |
| Travis Scott | PART TIME | 16 | 18 | 71 | loose |
| Travis Scott | PBT | 49 | 25 | 167 | loose |
| Travis Scott | PHILLY | 39 | 31 | 222 | loose |
| Travis Scott | Pack Loud | 45 | 31 | 208 | loose |
| Travis Scott | Palm Trees | 46 | 60 | 118 | loose |
| Travis Scott | Paradise V3 | 20 | 15 | 17 | loose |
| Travis Scott | Parking Lot | 38 | 65 | 221 | loose |
| Travis Scott | Party 101 | 56 | 47 | 284 | loose |
| Travis Scott | Party Till | 27 | 18 | 84 | loose |
| Travis Scott | Perfect | 12 | 9 | 28 | loose |
| Travis Scott | Phoenix | 34 | 23 | 261 | loose |
| Travis Scott | Picture Me | 56 | 89 | 202 | loose |
| Travis Scott | Pink Birthday | 19 | 10 | 106 | loose |
| Travis Scott | Pipe Down | 42 | 30 | 213 | loose |
| Travis Scott | Piss On Your Grave | 37 | 51 | 95 | loose |
| Travis Scott | Playing For Keeps* | 30 | 29 | 62 | loose |
| Travis Scott | Poet | 33 | 21 | 115 | loose |
| Travis Scott | Poet and Parade | 43 | 35 | 256 | loose |
| Travis Scott | Pornography | 59 | 30 | 249 | loose |
| Travis Scott | Portland | 59 | 58 | 303 | loose |
| Travis Scott | Pose | 18 | 29 | 43 | loose |
| Travis Scott | Power Is Power | 38 | 28 | 150 | loose |
| Travis Scott | Praise God | 65 | 62 | 234 | loose |
| Travis Scott | Pray 4 Love | 59 | 84 | 326 | loose |
| Travis Scott | Prayers Up | 27 | 21 | 71 | loose |
| Travis Scott | Pressure (Original) | 15 | 11 | 50 | loose |
| Travis Scott | Prices | 58 | 129 | 204 | AAAA |
| Travis Scott | Problem Child | 33 | 37 | 136 | loose |
| Travis Scott | Pull Up | 30 | 30 | 88 | loose |
| Travis Scott | Pussy | 70 | 76 | 342 | loose |
| Travis Scott | Pussy & Millions | 70 | 105 | 269 | loose |
| Travis Scott | Quintana | 51 | 46 | 205 | loose |
| Travis Scott | Quintana Pt. 2 | 39 | 24 | 180 | loose |
| Travis Scott | R.I.P. SCREW | 29 | 7 | 122 | loose |
| Travis Scott | RERUN | 39 | 39 | 237 | loose |
| Travis Scott | RaRa | 27 | 30 | 53 | loose |
| Travis Scott | Raid (Demo) | 23 | 21 | 103 | loose |
| Travis Scott | Raindrops (Insane) | 44 | 63 | 125 | loose |
| Travis Scott | Reflections Laughing | 51 | 82 | 129 | loose |
| Travis Scott | Reflex | 35 | 31 | 108 | loose |
| Travis Scott | Regular | 33 | 43 | 103 | loose |
| Travis Scott | Respected | 33 | 40 | 143 | loose |
| Travis Scott | Ride Good | 27 | 28 | 94 | loose |
| Travis Scott | Ring Ring | 43 | 52 | 194 | loose |
| Travis Scott | Ring Ring [Extended Version] | 22 | 11 | 85 | loose |
| Travis Scott | Rockstar Made (Original) | 7 | 1 | 9 | loose |
| Travis Scott | Rodeo (Travis Scott Remix)* | 15 | 14 | 79 | loose |
| Travis Scott | Rodeo Tour Dates | 24 | 0 | 241 | loose |
| Travis Scott | Roll in Peace (Original) | 39 | 49 | 136 | loose |
| Travis Scott | Rollercoaster | 12 | 4 | 16 | loose |
| Travis Scott | Rosary | 43 | 30 | 207 | loose |
| Travis Scott | Rotation | 62 | 35 | 246 | loose |
| Travis Scott | Rule The World | 38 | 26 | 60 | loose |
| Travis Scott | SAY MY GRACE | 49 | 106 | 383 | loose |
| Travis Scott | SHYNE | 37 | 27 | 232 | loose |
| Travis Scott | SICKO MODE | 77 | 107 | 268 | loose |
| Travis Scott | SIRENS | 49 | 69 | 125 | loose |
| Travis Scott | SKELETONS | 17 | 14 | 63 | loose |
| Travis Scott | SKITZO | 91 | 90 | 551 | loose |
| Travis Scott | SOMETIMES I FEEL ALONE* (CIRCUS MAXIMUS Freestyle) | 16 | 10 | 18 | loose |
| Travis Scott | SOUTH OF FRANCE | 22 | 16 | 159 | loose |
| Travis Scott | STARGAZING | 41 | 38 | 215 | loose |
| Travis Scott | STARGAZING/STOP TRYING TO BE GOD/SICKO MODE (Live from the 2018 VMAs) | 13 | 10 | 53 | loose |
| Travis Scott | STOP TRYING TO BE GOD | 42 | 68 | 134 | loose |
| Travis Scott | Safe (Millions) | 43 | 79 | 121 | loose |
| Travis Scott | Saint | 27 | 22 | 52 | loose |
| Travis Scott | Saint Laurent Mask | 39 | 32 | 96 | loose |
| Travis Scott | Savage Time | 95 | 96 | 662 | loose |
| Travis Scott | Second Emotion | 33 | 21 | 115 | loose |
| Travis Scott | Secret | 31 | 29 | 326 | loose |
| Travis Scott | Serenade | 28 | 50 | 98 | loose |
| Travis Scott | She Love Me | 54 | 49 | 151 | loose |
| Travis Scott | Sin City | 70 | 102 | 322 | loose |
| Travis Scott | Skibidi Toilet 2 | 9 | 8 | 14 | loose |
| Travis Scott | Sky Walker | 45 | 36 | 140 | loose |
| Travis Scott | Skyfall | 55 | 77 | 208 | loose |
| Travis Scott | Sloppy Toppy | 92 | 85 | 395 | loose |
| Travis Scott | Smell of Money | 15 | 16 | 52 | loose |
| Travis Scott | Solitaires | 52 | 82 | 270 | loose |
| Travis Scott | Somewhereinamerica | 33 | 20 | 77 | loose |
| Travis Scott | Sounds | 19 | 18 | 83 | loose |
| Travis Scott | Southside Serenade | 8 | 6 | 55 | loose |
| Travis Scott | Space Cadet | 42 | 67 | 307 | loose |
| Travis Scott | Speaking of the Devil | 32 | 60 | 188 | loose |
| Travis Scott | Stuff | 50 | 65 | 274 | loose |
| Travis Scott | Swang (Remix) | 50 | 55 | 217 | loose |
| Travis Scott | Sway in the Morning Freestyle | 41 | 28 | 161 | loose |
| Travis Scott | TELEKINESIS | 70 | 100 | 323 | loose |
| Travis Scott | THANK GOD | 37 | 44 | 203 | loose |
| Travis Scott | THE PLAN | 29 | 25 | 125 | loose |
| Travis Scott | THE SCOTTS | 41 | 21 | 104 | loose |
| Travis Scott | TIL FURTHER NOTICE | 53 | 62 | 233 | loose |
| Travis Scott | TKN | 27 | 13 | 160 | loose |
| Travis Scott | TOP FLOOR | 45 | 54 | 184 | loose |
| Travis Scott | TOPIA TWINS | 53 | 63 | 388 | loose |
| Travis Scott | TRIM (Original) | 50 | 48 | 250 | loose |
| Travis Scott | TaTaTa | 32 | 28 | 107 | loose |
| Travis Scott | Take What You Want | 35 | 25 | 159 | loose |
| Travis Scott | Takeoff | 8 | 7 | 19 | loose |
| Travis Scott | Talk To Me Nice* | 32 | 51 | 130 | loose |
| Travis Scott | Talk to Me (I’m In It Demo) | 53 | 44 | 234 | loose |
| Travis Scott | Tarzan | 78 | 72 | 350 | loose |
| Travis Scott | Texas Cyclone | 32 | 40 | 128 | loose |
| Travis Scott | That B!tch Crazy | 34 | 24 | 236 | loose |
| Travis Scott | The Blinding | 39 | 40 | 211 | loose |
| Travis Scott | The Curse | 37 | 60 | 157 | loose |
| Travis Scott | The Hooch | 33 | 25 | 147 | loose |
| Travis Scott | The London | 56 | 41 | 244 | loose |
| Travis Scott | The Mack | 38 | 24 | 138 | loose |
| Travis Scott | The Morning | 71 | 64 | 397 | loose |
| Travis Scott | The One | 4 | 1 | 13 | loose |
| Travis Scott | The Relays | 45 | 52 | 219 | loose |
| Travis Scott | The Travis Scott Burger Meal | McDonald’s | 11 | 3 | 14 | loose |
| Travis Scott | This song is fake lol | 7 | 3 | 18 | loose |
| Travis Scott | Time Machine | 17 | 7 | 158 | loose |
| Travis Scott | To the World | 42 | 28 | 151 | loose |
| Travis Scott | Too Geeked* | 29 | 41 | 182 | loose |
| Travis Scott | Too Many Chances | 21 | 7 | 118 | loose |
| Travis Scott | Too Many Options | 40 | 42 | 76 | loose |
| Travis Scott | Tourist | 47 | 25 | 188 | loose |
| Travis Scott | Trance | 63 | 98 | 200 | loose |
| Travis Scott | Trap in Mexico | 35 | 27 | 156 | loose |
| Travis Scott | Trippin | 17 | 17 | 62 | loose |
| Travis Scott | Trippin’ On Me | 30 | 31 | 158 | loose |
| Travis Scott | Try Me (Left Cheek) | 34 | 13 | 113 | loose |
| Travis Scott | Tsunami | 28 | 31 | 133 | loose |
| Travis Scott | Turks | 56 | 87 | 348 | loose |
| Travis Scott | Type Shit | 59 | 41 | 459 | loose |
| Travis Scott | Uber Everywhere (SoundCloud Remix) | 39 | 77 | 170 | loose |
| Travis Scott | Ultrasounds | 8 | 3 | 47 | loose |
| Travis Scott | Uncle M | 21 | 22 | 151 | loose |
| Travis Scott | Universal Soldier | 42 | 24 | 234 | loose |
| Travis Scott | Untitled (Trill Mode)* | 20 | 22 | 118 | loose |
| Travis Scott | Up | 51 | 37 | 173 | loose |
| Travis Scott | Up Top | 28 | 19 | 129 | loose |
| Travis Scott | Up to Something | 45 | 60 | 130 | loose |
| Travis Scott | Upper Echelon | 55 | 35 | 252 | loose |
| Travis Scott | Uptown | 49 | 41 | 220 | loose |
| Travis Scott | VISION* | 9 | 11 | 27 | ABAB |
| Travis Scott | Vodka | 42 | 38 | 260 | loose |
| Travis Scott | Vulnerable | 28 | 27 | 103 | loose |
| Travis Scott | WAKE UP | 35 | 33 | 135 | loose |
| Travis Scott | WAKE UP F1LTHY | 38 | 45 | 149 | loose |
| Travis Scott | WHAT TO DO? | 41 | 66 | 127 | loose |
| Travis Scott | WHERE WAS YOU | 50 | 66 | 376 | loose |
| Travis Scott | WHITE TEE (FRANCHISE Demo) | 13 | 15 | 74 | loose |
| Travis Scott | WHO? WHAT! | 57 | 89 | 201 | loose |
| Travis Scott | WTFYM | 93 | 125 | 298 | loose |
| Travis Scott | Wash Us in the Blood | 63 | 51 | 117 | loose |
| Travis Scott | Wasted | 41 | 31 | 369 | loose |
| Travis Scott | Watch | 56 | 79 | 251 | loose |
| Travis Scott | Water (Remix) | 41 | 44 | 97 | loose |
| Travis Scott | Waves (Remix) | 41 | 30 | 186 | loose |
| Travis Scott | Wavy (Remix) | 46 | 66 | 284 | loose |
| Travis Scott | We $tar$ | 20 | 5 | 70 | loose |
| Travis Scott | We Loved It | 21 | 8 | 61 | loose |
| Travis Scott | West Side Highway | 33 | 31 | 193 | loose |
| Travis Scott | What’s Next | 56 | 52 | 224 | loose |
| Travis Scott | When I’m Home | 39 | 13 | 79 | loose |
| Travis Scott | Where U From | 54 | 53 | 126 | loose |
| Travis Scott | Whip | 46 | 45 | 120 | loose |
| Travis Scott | White Dress | 33 | 18 | 176 | loose |
| Travis Scott | White Girls | 39 | 48 | 187 | loose |
| Travis Scott | White Sand | 64 | 72 | 211 | loose |
| Travis Scott | Who Am I | 39 | 31 | 131 | loose |
| Travis Scott | Whole Lots Changed | 29 | 4 | 133 | loose |
| Travis Scott | Whole Lotta Lovin’ | 33 | 25 | 82 | loose |
| Travis Scott | Whole Time | 34 | 22 | 163 | loose |
| Travis Scott | Why You So Nasty? | 31 | 8 | 89 | loose |
| Travis Scott | Williamsburg | 35 | 25 | 128 | loose |
| Travis Scott | Wine and Hennessy | 131 | 106 | 249 | loose |
| Travis Scott | Wit Da Racks | 79 | 124 | 343 | loose |
| Travis Scott | Woo | 24 | 13 | 84 | loose |
| Travis Scott | Workin’ (Remix) | 84 | 66 | 314 | loose |
| Travis Scott | X2C | 35 | 35 | 65 | loose |
| Travis Scott | XX | 31 | 28 | 83 | loose |
| Travis Scott | XXL Freshman Freestyle: Travis Scott | 10 | 9 | 158 | loose |
| Travis Scott | XXL Freshmen 2013 Cypher - Part 1 | 94 | 94 | 774 | loose |
| Travis Scott | YOSEMITE | 33 | 51 | 213 | loose |
| Travis Scott | Ya Digg | 53 | 59 | 347 | loose |
| Travis Scott | Yeah Yeah (Original) | 80 | 61 | 185 | loose |
| Travis Scott | Yes Lord | 80 | 35 | 322 | loose |
| Travis Scott | You | 28 | 30 | 201 | loose |
| Travis Scott | Young Wheezy | 50 | 49 | 245 | loose |
| Travis Scott | ZEZE | 58 | 62 | 212 | loose |
| Travis Scott | ZOOM | 25 | 49 | 127 | loose |
| Travis Scott | ZTFO | 36 | 42 | 169 | loose |
| Travis Scott | Zombies | 38 | 49 | 218 | loose |
| Travis Scott | beibs in the trap | 44 | 47 | 192 | loose |
| Travis Scott | coordinate | 40 | 16 | 154 | loose |
| Travis Scott | durag activity | 51 | 57 | 277 | loose |
| Travis Scott | first take | 64 | 88 | 162 | loose |
| Travis Scott | flooded | 36 | 66 | 242 | loose |
| Travis Scott | goosebumps | 49 | 48 | 194 | loose |
| Travis Scott | guidance | 36 | 28 | 93 | loose |
| Travis Scott | lose | 23 | 18 | 72 | loose |
| Travis Scott | née-nah | 59 | 78 | 379 | loose |
| Travis Scott | out for the night | 13 | 9 | 10 | loose |
| Travis Scott | out for the night, pt. 2 | 59 | 73 | 301 | loose |
| Travis Scott | outside | 41 | 28 | 145 | loose |
| Travis Scott | pick up the phone | 64 | 92 | 177 | loose |
| Travis Scott | sdp interlude (Original) | 21 | 18 | 89 | loose |
| Travis Scott | sweet sweet | 38 | 52 | 85 | loose |
| Travis Scott | the ends | 51 | 43 | 141 | loose |
| Travis Scott | through the late night | 31 | 19 | 139 | loose |
| Travis Scott | way back | 43 | 29 | 158 | loose |
| Travis Scott | wonderful | 36 | 51 | 100 | loose |
