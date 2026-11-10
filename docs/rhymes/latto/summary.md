# Latto rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Latto
- Songs: 254
- Bars kept (Latto lyric lines): 9691
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 31
- Canonical name: Latto.
- Credit strings: Latto.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 59220
- REPEAT pairs, recorded separately: 6438
- END rhymes: 9765
- INNER rhymes: 49455

By match:

- PERFECT: 5067 (END 1440, INNER 3627)
- SLANT: 26903 (END 4397, INNER 22506)
- ASSONANCE: 26728 (END 3766, INNER 22962)
- MULTI: 522 (END 162, INNER 360)

By confidence:

- HIGH: 5160
- MED: 49883
- LOW: 4177

## Core

- Core Y: 57977
- Core N among rhyme pairs: 1243

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 28639 (48.4%)
- vowel: 26728 (45.1%)
- spelling: 3331 (5.6%)
- multi: 522 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 254 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 5017 pairs (END 548, INNER 4469). Words: bitches, bitch, shit, think, big, him, still, hit.
2. `vow:OW` — 3866 pairs (END 416, INNER 3450). Words: don't, know, no, go, hoes, ho, told, latto.
3. `vow:EH` — 3241 pairs (END 457, INNER 2784). Words: get, when, never, let, tell, next, gettin, best.
4. `vow:EY` — 3152 pairs (END 346, INNER 2806). Words: ain't, say, make, way, play, baby, face, day.
5. `vow:AE` — 2500 pairs (END 487, INNER 2013). Words: can't, back, ass, had, can, ask, bad, have.
6. `vow:IY` — 2031 pairs (END 271, INNER 1760). Words: see, even, these, need, keep, real, g, here.
7. `vow:AH` — 1997 pairs (END 311, INNER 1686). Words: fuck, love, hundred, what, money, one, some, what's.
8. `vow:AA` — 1835 pairs (END 262, INNER 1573). Words: got, want, nothin, not, talkin, poppin, top, hard.
9. `slant:IH:sib-stop` — 1527 pairs (END 266, INNER 1261). Words: bitch, shit, big, hit, dick, rich, nigga, niggas.
10. `slant:IH:stop` — 1521 pairs (END 134, INNER 1387). Words: nigga, shit, big, hit, dick, pretty, city, thick.
11. `vow:AY` — 1482 pairs (END 234, INNER 1248). Words: like, why, time, try, bae, right, diamonds, mind.
12. `slant:AA:stop` — 1313 pairs (END 176, INNER 1137). Words: got, gotta, want, not, top, stop, body, pop.
13. `slant:AE:stop` — 1012 pairs (END 274, INNER 738). Words: back, bag, can't, latto, bad, had, mad, rap.
14. `slant:EH:stop` — 863 pairs (END 122, INNER 741). Words: get, better, let, check, said, head, wet, neck.
15. `cmu:OW` — 861 pairs (END 113, INNER 748). Words: know, no, go, ho, show, throw, hoe, flow.
16. `slant:AY:stop` — 729 pairs (END 80, INNER 649). Words: like, ride, right, might, type, night, white, side.
17. `slant:IH:nas-stop` — 684 pairs (END 40, INNER 644). Words: him, shit, i'ma, big, hit, dick, pretty, bring.
18. `slant:EH:nas-stop` — 683 pairs (END 32, INNER 651). Words: when, get, let, better, again, ten, em, gettin.
19. `slant:AH:nas-stop` — 681 pairs (END 57, INNER 624). Words: fuck, what, come, one, money, some, done, fuckin.
20. `slant:AE:sib-stop` — 649 pairs (END 191, INNER 458). Words: ass, back, bag, mad, bad, cash, catch, match.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 755 pair sides, mostly spelling via spelling phonetic key, often with shit (146)
- ima — 359 pair sides, mostly spelling via spelling phonetic key, often with bitch (60)
- latto — 300 pair sides, mostly vowel via spelling phonetic key, often with know (42)
- gon — 235 pair sides, mostly spelling via spelling phonetic key, often with dont (60)
- tryna — 225 pair sides, mostly spelling via spelling phonetic key, often with keep (19)
- niggas — 149 pair sides, mostly spelling via spelling phonetic key, often with nigga (81)
- birkin — 88 pair sides, mostly vowel via spelling phonetic key, often with bitch (24)
- clayco — 51 pair sides, mostly vowel via spelling phonetic key, often with know (5)
- thot — 50 pair sides, mostly spelling via spelling phonetic key, often with hot (6)
- shawty — 47 pair sides, mostly vowel via spelling phonetic key, often with all (5)
- kdy — 41 pair sides, mostly vowel via spelling phonetic key, often with v (6)
- swag — 35 pair sides, mostly spelling via spelling phonetic key, often with back (5)
- lyin — 32 pair sides, mostly spelling via spelling phonetic key, often with keep (5)
- pics — 30 pair sides, mostly vowel via spelling phonetic key, often with bitch (8)
- lik — 30 pair sides, mostly spelling via spelling phonetic key, often with bitch (6)
- gostoso — 27 pair sides, mostly vowel via spelling phonetic key, often with o (5)
- blicky — 26 pair sides, mostly spelling via spelling phonetic key, often with sticky (7)
- bajo — 25 pair sides, mostly vowel via spelling phonetic key, often with no (4)
- henny — 24 pair sides, mostly vowel via spelling phonetic key, often with when (2)
- finna — 22 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- baddest — 22 pair sides, mostly vowel via spelling phonetic key, often with average (6)
- bih — 19 pair sides, mostly spelling via spelling phonetic key, often with lil (5)
- tuh — 18 pair sides, mostly spelling via spelling phonetic key, often with what (4)
- eso — 18 pair sides, mostly vowel via spelling phonetic key, often with el (2)
- shiesty — 17 pair sides, mostly vowel via spelling phonetic key, often with shit (4)
- opps — 17 pair sides, mostly vowel via spelling phonetic key, often with know (6)
- soso — 17 pair sides, mostly vowel via spelling phonetic key, often with dont (3)
- turnt — 16 pair sides, mostly spelling via spelling phonetic key, often with burnt (6)
- prometo — 16 pair sides, mostly vowel via spelling phonetic key, often with o (4)
- iludido — 16 pair sides, mostly vowel via spelling phonetic key, often with o (3)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Latto | 1K | 37 | 32 | 175 | loose |
| Latto | 4L | 26 | 6 | 84 | loose |
| Latto | 5'5 | 40 | 41 | 198 | loose |
| Latto | 678* | 24 | 23 | 115 | loose |
| Latto | 777 Pt. 1 | 23 | 32 | 107 | loose |
| Latto | 777 Pt. 2 | 40 | 27 | 292 | loose |
| Latto | A-Town Girl | 61 | 28 | 138 | loose |
| Latto | ART | 25 | 36 | 119 | loose |
| Latto | ATL Hoe | 29 | 39 | 114 | loose |
| Latto | All Gone | 42 | 47 | 177 | loose |
| Latto | All-Women Cypher | 108 | 103 | 943 | loose |
| Latto | Another Nasty Song | 24 | 13 | 205 | loose |
| Latto | Anxious | 37 | 36 | 223 | loose |
| Latto | BACK OUTSIDE | 48 | 47 | 128 | loose |
| Latto | BILLS PAID | 50 | 39 | 267 | loose |
| Latto | BOMB (Remix) | 48 | 41 | 259 | loose |
| Latto | BOTA | 27 | 15 | 359 | loose |
| Latto | Baby Wyd (Remix) | 52 | 39 | 287 | loose |
| Latto | Back In Blood (Remix)* | 17 | 18 | 135 | loose |
| Latto | Bad Azz | 46 | 51 | 371 | loose |
| Latto | Baddest | 27 | 21 | 181 | loose |
| Latto | Baddies | 41 | 30 | 110 | loose |
| Latto | Beat Box (Big Latto Mix) | 35 | 24 | 242 | loose |
| Latto | BeatBox Freestyle | 20 | 14 | 230 | loose |
| Latto | Bet* | 17 | 18 | 80 | loose |
| Latto | Big Energy | 38 | 25 | 129 | loose |
| Latto | Big Energy (Remix) [Explicit Version] | 24 | 11 | 53 | loose |
| Latto | Big Latto Freestyle | 49 | 77 | 385 | loose |
| Latto | Big Mama | 47 | 57 | 360 | loose |
| Latto | Big Ole Booty (Remix) | 46 | 40 | 129 | loose |
| Latto | Bitch From Da Souf (Remix) | 41 | 40 | 324 | loose |
| Latto | Bitch How* | 21 | 19 | 82 | loose |
| Latto | Bitter | 50 | 53 | 246 | loose |
| Latto | Blame Me | 26 | 19 | 104 | loose |
| Latto | Blick Blick* | 20 | 22 | 100 | loose |
| Latto | Blick Sum (Remix) | 36 | 36 | 181 | loose |
| Latto | Boom Pt. 2 | 42 | 42 | 277 | loose |
| Latto | Booty | 33 | 23 | 154 | loose |
| Latto | Bounce | 29 | 43 | 156 | loose |
| Latto | Brat | 36 | 37 | 229 | loose |
| Latto | Bring It Over Here | 33 | 31 | 160 | loose |
| Latto | Broke* | 25 | 19 | 70 | loose |
| Latto | Broken Record Player | 44 | 61 | 108 | loose |
| Latto | Brokey | 42 | 33 | 264 | loose |
| Latto | Budget | 40 | 59 | 230 | loose |
| Latto | Business & Personal (Intro) | 66 | 105 | 550 | loose |
| Latto | Bussdown | 28 | 10 | 212 | loose |
| Latto | Can’t Be Mine | 28 | 27 | 74 | loose |
| Latto | Can’t Stop | 30 | 27 | 91 | loose |
| Latto | Champagne Shit (Remix) | 49 | 56 | 152 | loose |
| Latto | ChaseDaMoney Freestyle | 35 | 42 | 201 | loose |
| Latto | Check Me Out | 33 | 16 | 142 | loose |
| Latto | Cheerleader | 44 | 70 | 269 | loose |
| Latto | Chicken Grease | 30 | 27 | 225 | loose |
| Latto | Chosen One (Demo) | 54 | 33 | 173 | loose |
| Latto | Chrome Heart Diaper Bag | 39 | 62 | 195 | loose |
| Latto | Cool with Me | 67 | 89 | 354 | loose |
| Latto | Copper Cove | 33 | 26 | 238 | loose |
| Latto | Crush (Remix) | 27 | 14 | 104 | loose |
| Latto | Daddy’s Girl Interlude | 40 | 51 | 268 | loose |
| Latto | Death Row | 22 | 13 | 100 | loose |
| Latto | Deserve | 33 | 26 | 134 | loose |
| Latto | Did It Again* | 34 | 43 | 164 | loose |
| Latto | Did Somebody Say HipOpera | 18 | 10 | 101 | loose |
| Latto | Didn’t Say | 46 | 37 | 191 | loose |
| Latto | Different 2 | 21 | 14 | 429 | loose |
| Latto | Different Breed | 38 | 35 | 153 | loose |
| Latto | Do I | 45 | 60 | 206 | loose |
| Latto | Do It (Remix) | 95 | 90 | 320 | loose |
| Latto | Don’t Play With Her* | 32 | 24 | 214 | loose |
| Latto | Don’t Play With It (Remix) | 45 | 58 | 246 | loose |
| Latto | Don’t Play With Me* | 27 | 47 | 139 | loose |
| Latto | Don’t Wanna Leave | 28 | 17 | 116 | loose |
| Latto | Down | 48 | 68 | 296 | loose |
| Latto | Drip | 28 | 29 | 124 | loose |
| Latto | Ear Candy | 41 | 46 | 225 | loose |
| Latto | Energy (Latto Remix) | 46 | 54 | 269 | loose |
| Latto | ErrTime (Remix) | 34 | 39 | 263 | loose |
| Latto | F.N.F (Let’s Go) [Remix] | 46 | 38 | 313 | loose |
| Latto | FINE AS CAN BE | 68 | 119 | 256 | loose |
| Latto | FTCU | 31 | 29 | 254 | loose |
| Latto | Facts | 41 | 44 | 258 | loose |
| Latto | Fallin’ | 44 | 59 | 219 | loose |
| Latto | Fast Lane | 32 | 28 | 205 | loose |
| Latto | Feelings | 31 | 15 | 83 | loose |
| Latto | First Off* | 47 | 48 | 273 | loose |
| Latto | For the Night | 32 | 32 | 153 | loose |
| Latto | Forever | 38 | 29 | 121 | loose |
| Latto | Freak | 25 | 40 | 277 | loose |
| Latto | Freak Show | 29 | 36 | 266 | loose |
| Latto | Freaky as Me | 25 | 10 | 80 | loose |
| Latto | FreakyT (Remix) | 31 | 58 | 309 | loose |
| Latto | Fuck Rice Street | 51 | 38 | 293 | loose |
| Latto | GOMF | 44 | 38 | 354 | loose |
| Latto | Georgia Peach | 36 | 52 | 115 | loose |
| Latto | Get Money Girl | 34 | 22 | 140 | loose |
| Latto | Getting That Money | 59 | 93 | 250 | loose |
| Latto | Gimme Dat | 66 | 65 | 169 | loose |
| Latto | Go Girl | 48 | 48 | 257 | loose |
| Latto | Going On | 38 | 31 | 130 | loose |
| Latto | Goin’ On | 24 | 15 | 89 | loose |
| Latto | Gold | 23 | 20 | 70 | loose |
| Latto | Good 2 You | 36 | 10 | 206 | loose |
| Latto | Gotta Go Get It | 47 | 64 | 196 | loose |
| Latto | Gyatt | 31 | 32 | 214 | loose |
| Latto | H&M | 29 | 24 | 140 | loose |
| Latto | HYS | 39 | 51 | 147 | loose |
| Latto | Hate You | 36 | 26 | 75 | loose |
| Latto | He Say She Say | 48 | 62 | 191 | loose |
| Latto | Hobby | 45 | 41 | 248 | loose |
| Latto | Hold It Down | 50 | 52 | 206 | loose |
| Latto | Hostage | 49 | 77 | 249 | loose |
| Latto | Housekeeping Knows | 32 | 31 | 127 | loose |
| Latto | Hurt | 32 | 14 | 112 | loose |
| Latto | Hydrate* | 16 | 16 | 74 | loose |
| Latto | I Got Moves (#UsherRaymond) | 23 | 19 | 22 | loose |
| Latto | I Just Called | 34 | 17 | 116 | loose |
| Latto | I Need a Real Bitch | 55 | 75 | 253 | loose |
| Latto | I Set Trends | 68 | 73 | 306 | loose |
| Latto | ISSA PARTY | 34 | 38 | 374 | loose |
| Latto | Ice Cream* | 24 | 31 | 114 | loose |
| Latto | In It | 29 | 46 | 160 | loose |
| Latto | In N Out | 38 | 47 | 218 | loose |
| Latto | Infidelity | 46 | 39 | 108 | loose |
| Latto | It’s Givin | 30 | 29 | 180 | loose |
| Latto | KIRK | 31 | 39 | 207 | loose |
| Latto | Kash App | 32 | 23 | 189 | loose |
| Latto | Kill A Hoe | 33 | 20 | 108 | loose |
| Latto | Latto | 45 | 42 | 127 | loose |
| Latto | Latto Freestyle | LA Leakers Freestyle #123 | 28 | 28 | 209 | loose |
| Latto | Like Me* | 23 | 14 | 62 | loose |
| Latto | Like a Thug | 35 | 35 | 161 | loose |
| Latto | Liquor | 34 | 39 | 178 | loose |
| Latto | Live My Best Life | 31 | 25 | 179 | loose |
| Latto | Longway | 26 | 22 | 111 | loose |
| Latto | Look Back at It | 43 | 67 | 232 | loose |
| Latto | Look What You Did | 49 | 44 | 88 | loose |
| Latto | Lottery | 36 | 31 | 136 | loose |
| Latto | Lovin Me* | 31 | 22 | 88 | loose |
| Latto | MMM MMM (The Remix) | 53 | 51 | 333 | loose |
| Latto | Make Em Say | 34 | 18 | 211 | loose |
| Latto | Make Me | 31 | 31 | 171 | loose |
| Latto | Mama | 34 | 19 | 220 | loose |
| Latto | Maybe | 63 | 69 | 245 | loose |
| Latto | Meeting | 61 | 66 | 285 | loose |
| Latto | Mimi Interlude | 6 | 2 | 30 | loose |
| Latto | Mind Yo Business | 29 | 34 | 135 | loose |
| Latto | Minute | 32 | 35 | 36 | loose |
| Latto | Money (OG)* | 4 | 1 | 44 | loose |
| Latto | Moved On | 47 | 30 | 146 | loose |
| Latto | Muffin (Freak Hoe) | 36 | 16 | 198 | loose |
| Latto | Mush Mouf | 52 | 40 | 140 | loose |
| Latto | Muwop | 44 | 62 | 275 | loose |
| Latto | My Body | 37 | 40 | 161 | loose |
| Latto | Naked | 40 | 42 | 168 | loose |
| Latto | Nasty | 46 | 81 | 309 | loose |
| Latto | Nasty Nasty | 44 | 49 | 133 | loose |
| Latto | Need Luv 2 | 34 | 30 | 122 | loose |
| Latto | No Hook | 34 | 39 | 211 | loose |
| Latto | No More Talking | 41 | 36 | 187 | loose |
| Latto | No Panties | 23 | 31 | 177 | loose |
| Latto | Nobody | 36 | 32 | 203 | loose |
| Latto | Off Rip* | 25 | 30 | 152 | loose |
| Latto | Off Top | 40 | 27 | 211 | loose |
| Latto | Okay Okay* | 28 | 44 | 87 | loose |
| Latto | Okayyy | 53 | 42 | 231 | loose |
| Latto | On God | 25 | 26 | 123 | loose |
| Latto | On Me | 38 | 53 | 150 | loose |
| Latto | On My Way | 45 | 46 | 93 | loose |
| Latto | One Light (Remix) | 41 | 40 | 186 | loose |
| Latto | Onnat | 44 | 44 | 151 | loose |
| Latto | POP IT | 46 | 72 | 194 | loose |
| Latto | PROCEDURE | 40 | 42 | 344 | loose |
| Latto | PUSSY | 29 | 21 | 129 | loose |
| Latto | Peaches & Eggplants (Remix) | 58 | 41 | 169 | loose |
| Latto | Pretty Girl (Remix) | 54 | 36 | 338 | loose |
| Latto | Pretty Ricky | 31 | 48 | 149 | loose |
| Latto | Prized Possession | 47 | 79 | 327 | loose |
| Latto | Pull Up | 36 | 29 | 253 | loose |
| Latto | Put It On Da Floor | 18 | 14 | 91 | loose |
| Latto | Put It On Da Floor Again | 49 | 43 | 318 | loose |
| Latto | Put It On Da Floor Again [Mixed] | 4 | 1 | 20 | loose |
| Latto | Put It On You | 29 | 22 | 53 | loose |
| Latto | Quarantine Thick | 45 | 41 | 272 | loose |
| Latto | Queen | 21 | 25 | 129 | loose |
| Latto | Rain Down | 59 | 41 | 210 | loose |
| Latto | Real One | 24 | 10 | 69 | loose |
| Latto | Real Princess | 72 | 56 | 308 | loose |
| Latto | Red Opps (Remix) | 36 | 30 | 167 | loose |
| Latto | Remember | 41 | 36 | 142 | loose |
| Latto | Response Diss | 67 | 50 | 242 | loose |
| Latto | Rich Sex | 28 | 27 | 178 | loose |
| Latto | Rough* | 12 | 13 | 106 | loose |
| Latto | Running | 49 | 51 | 439 | loose |
| Latto | S/O to Me | 63 | 99 | 513 | loose |
| Latto | Safe | 7 | 15 | 69 | loose |
| Latto | Say That Shit* | 22 | 28 | 236 | loose |
| Latto | See Sum | 21 | 6 | 150 | loose |
| Latto | Settle Down | 41 | 42 | 125 | loose |
| Latto | Seven (Clean Ver.) | 37 | 53 | 119 | loose |
| Latto | Sex Lies | 34 | 44 | 235 | loose |
| Latto | Show Me | 36 | 23 | 120 | loose |
| Latto | Shrimp & Grits | 44 | 87 | 238 | loose |
| Latto | Sleep Sleep | 40 | 27 | 185 | loose |
| Latto | Smoking on My Ex Pack (Freestyle) | 49 | 32 | 118 | loose |
| Latto | Snippet (BET Awards 2024) | 20 | 20 | 119 | loose |
| Latto | Solid | 48 | 47 | 120 | loose |
| Latto | Somebody | 47 | 65 | 127 | loose |
| Latto | Sorry Not Sorry (Remix) | 78 | 55 | 419 | loose |
| Latto | Soufside | 38 | 32 | 122 | loose |
| Latto | South Beach Freestyle | 42 | 50 | 244 | loose |
| Latto | Special | 38 | 23 | 263 | loose |
| Latto | Spend It | 42 | 66 | 256 | loose |
| Latto | Squeeze | 37 | 33 | 94 | loose |
| Latto | Step It Up | 42 | 80 | 215 | loose |
| Latto | Steppers (OG) | 38 | 45 | 218 | loose |
| Latto | Still Can’t Do | 57 | 86 | 308 | loose |
| Latto | Striptease | 20 | 15 | 143 | loose |
| Latto | Sunday Service | 30 | 29 | 213 | loose |
| Latto | Sunshine | 56 | 47 | 377 | loose |
| Latto | Super Gremlin Freestyle | 45 | 51 | 237 | loose |
| Latto | Talk* | 28 | 9 | 152 | loose |
| Latto | Technique (Sprite Limelight) | 30 | 54 | 167 | loose |
| Latto | The Biggest | 44 | 35 | 277 | loose |
| Latto | The Grinch Freestyle | 41 | 68 | 466 | loose |
| Latto | There She Go | 26 | 29 | 179 | loose |
| Latto | Thirsty | 39 | 43 | 85 | loose |
| Latto | This Right Here | 48 | 26 | 200 | loose |
| Latto | Thot Box (Remix) | 61 | 72 | 345 | loose |
| Latto | Thotiana (REMIX) | 19 | 9 | 85 | loose |
| Latto | Too Fast (Pull Over) | 61 | 45 | 352 | loose |
| Latto | Touch Your Toes | 34 | 47 | 189 | loose |
| Latto | Tough on the Internet | 48 | 50 | 207 | loose |
| Latto | Toya Turnup Talks (skit) | 12 | 3 | 40 | loose |
| Latto | Trust No Bitch | 34 | 52 | 262 | loose |
| Latto | UNAVAILABLE (Latto Remix) | 36 | 14 | 145 | loose |
| Latto | Up & Down | 44 | 54 | 185 | loose |
| Latto | WHAT’S HAPPENIN’ | 43 | 55 | 207 | loose |
| Latto | WHIM WHAMIEE (Latto Remix) | 32 | 22 | 147 | loose |
| Latto | WHOLE LOTTA MONEY | 26 | 32 | 202 | loose |
| Latto | WTHELLY (Latto Remix) | 18 | 12 | 103 | loose |
| Latto | WWYD | 37 | 30 | 123 | loose |
| Latto | Wake Up | 73 | 64 | 265 | loose |
| Latto | Wet (Remix) | 60 | 74 | 215 | loose |
| Latto | What’s Up* | 26 | 23 | 167 | loose |
| Latto | Wheelie | 44 | 54 | 192 | loose |
| Latto | Who is You | 55 | 50 | 135 | loose |
| Latto | With Me* | 14 | 9 | 44 | loose |
| Latto | XXL Freshman Freestyle: Latto | 17 | 18 | 130 | loose |
| Latto | XXL Freshmen 2020 Cypher - Part 3 | 122 | 79 | 455 | loose |
| Latto | YBG* | 40 | 51 | 240 | loose |
| Latto | Yikes / It’s Givin (Mixed) | 7 | 1 | 31 | loose |
| Latto | You Thought | 31 | 17 | 196 | loose |
| Latto | Youngest N Richest | 33 | 26 | 250 | loose |
