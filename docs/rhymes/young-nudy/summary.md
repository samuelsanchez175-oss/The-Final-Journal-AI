# Young Nudy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Young Nudy
- Songs: 320
- Bars kept (Young Nudy lyric lines): 14323
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 33
- Canonical name: Young Nudy.
- Credit strings: Young Nudy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 86109
- REPEAT pairs, recorded separately: 16520
- END rhymes: 14773
- INNER rhymes: 71336

By match:

- PERFECT: 8060 (END 2282, INNER 5778)
- SLANT: 41731 (END 6422, INNER 35309)
- ASSONANCE: 35627 (END 5858, INNER 29769)
- MULTI: 691 (END 211, INNER 480)

By confidence:

- HIGH: 8081
- MED: 70095
- LOW: 7933

## Core

- Core Y: 84771
- Core N among rhyme pairs: 1338

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 42487 (49.3%)
- vowel: 35627 (41.4%)
- spelling: 7304 (8.5%)
- multi: 691 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- loose: 319 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 6001 pairs (END 819, INNER 5182). Words: shit, bitch, bitches, think, big, him, didn't, nigga.
2. `vow:OW` — 5785 pairs (END 628, INNER 5157). Words: don't, know, no, go, hoes, ho, smoke, broke.
3. `slant:IH:stop` — 4327 pairs (END 538, INNER 3789). Words: nigga, shit, big, hit, stick, dick, lick, brick.
4. `vow:AE` — 3849 pairs (END 786, INNER 3063). Words: can't, back, ass, havin, man, damn, fast, have.
5. `slant:IH:sib-stop` — 3669 pairs (END 752, INNER 2917). Words: bitch, nigga, niggas, shit, big, hit, dick, rich.
6. `vow:EY` — 3661 pairs (END 646, INNER 3015). Words: ain't, say, play, way, make, day, face, take.
7. `vow:AH` — 3513 pairs (END 512, INNER 3001). Words: money, fuck, fuckin, somethin, some, hundred, love, what.
8. `vow:AA` — 3116 pairs (END 412, INNER 2704). Words: got, nothin, talkin, want, problem, not, wanna, gotta.
9. `vow:EH` — 2918 pairs (END 403, INNER 2515). Words: get, when, gettin, send, never, scared, remember, tell.
10. `vow:IY` — 2643 pairs (END 564, INNER 2079). Words: see, these, streets, real, keep, east, need, even.
11. `slant:AA:stop` — 2346 pairs (END 252, INNER 2094). Words: got, gotta, block, not, want, glock, drop, pop.
12. `vow:AY` — 1870 pairs (END 429, INNER 1441). Words: like, die, try, slime, why, time, mind, fire.
13. `slant:AH:nas-stop` — 1815 pairs (END 72, INNER 1743). Words: fuck, money, what, some, young, come, one, motherfucker.
14. `cmu:OW` — 1784 pairs (END 199, INNER 1585). Words: know, no, go, ho, show, blow, though, hoe.
15. `slant:AH:nas` — 1249 pairs (END 95, INNER 1154). Words: money, some, young, come, one, fuckin, done, run.
16. `slant:IH:liq-stop` — 1125 pairs (END 46, INNER 1079). Words: shit, really, kill, lil, still, big, hit, will.
17. `slant:IH:nas-stop` — 1043 pairs (END 77, INNER 966). Words: him, shit, i'ma, hit, thing, big, spin, everything.
18. `slant:AE:stop` — 895 pairs (END 168, INNER 727). Words: back, had, trap, can't, act, pack, black, bag.
19. `slant:AE:nas-stop` — 887 pairs (END 103, INNER 784). Words: man, can, back, damn, gang, had, can't, trap.
20. `slant:AA:nas-stop` — 858 pairs (END 20, INNER 838). Words: wanna, got, gonna, mama, not, want, block, gotta.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 4103 pair sides, mostly spelling via spelling phonetic key, often with niggas (1151)
- niggas — 1508 pair sides, mostly spelling via spelling phonetic key, often with nigga (1151)
- ima — 403 pair sides, mostly spelling via spelling phonetic key, often with bitch (63)
- gon — 393 pair sides, mostly spelling via spelling phonetic key, often with dont (125)
- tryna — 287 pair sides, mostly spelling via spelling phonetic key, often with these (42)
- slimeball — 196 pair sides, mostly vowel via spelling phonetic key, often with nigga (79)
- nudy — 130 pair sides, mostly spelling via spelling phonetic key, often with fuck (16)
- shawty — 117 pair sides, mostly vowel via spelling phonetic key, often with money (23)
- finna — 110 pair sides, mostly vowel via spelling phonetic key, often with nigga (38)
- dawg — 108 pair sides, mostly spelling via spelling phonetic key, often with all (31)
- opps — 69 pair sides, mostly vowel via spelling phonetic key, often with know (20)
- brazy — 63 pair sides, mostly vowel via spelling phonetic key, often with crazy (6)
- bros — 61 pair sides, mostly spelling via spelling phonetic key, often with hoes (14)
- homie — 49 pair sides, mostly spelling via spelling phonetic key, often with gon (6)
- geeked — 45 pair sides, mostly spelling via spelling phonetic key, often with sleep (4)
- glizzy — 42 pair sides, mostly spelling via spelling phonetic key, often with bitch (10)
- doin — 41 pair sides, mostly cmu via vault phonetic_class, often with rich (3)
- glocks — 41 pair sides, mostly vowel via spelling phonetic key, often with know (14)
- bruh — 40 pair sides, mostly spelling via spelling phonetic key, often with money (7)
- slimin — 35 pair sides, mostly vowel via spelling phonetic key, often with shit (10)
- swag — 33 pair sides, mostly spelling via spelling phonetic key, often with gas (5)
- thot — 29 pair sides, mostly spelling via spelling phonetic key, often with know (6)
- turnt — 27 pair sides, mostly vowel via spelling phonetic key, often with fuck (6)
- wifey — 27 pair sides, mostly spelling via spelling phonetic key, often with money (4)
- glist — 25 pair sides, mostly vowel via spelling phonetic key, often with rich (4)
- cuffin — 23 pair sides, mostly spelling via spelling phonetic key, often with fuckin (9)
- blicky — 23 pair sides, mostly spelling via spelling phonetic key, often with pussy (3)
- extendo — 23 pair sides, mostly cmu via vault phonetic_class, often with pretendo (7)
- xans — 22 pair sides, mostly spelling via spelling phonetic key, often with man (4)
- jugg — 22 pair sides, mostly spelling via vault phonetic_class, often with fuck (6)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Young Nudy | 10pc Teriyaki | 42 | 35 | 237 | loose |
| Young Nudy | 17 | 27 | 39 | 232 | loose |
| Young Nudy | 2 Um | 20 | 4 | 84 | loose |
| Young Nudy | 2Face | 80 | 84 | 354 | loose |
| Young Nudy | 4 GOD | 37 | 31 | 169 | loose |
| Young Nudy | 4L | 73 | 78 | 556 | loose |
| Young Nudy | 4L Gang Shit | 40 | 30 | 144 | loose |
| Young Nudy | 4L Lifestyle | 37 | 57 | 154 | loose |
| Young Nudy | 4Slime | 56 | 68 | 211 | loose |
| Young Nudy | A Nudy Story | 47 | 37 | 372 | loose |
| Young Nudy | ABM | 67 | 69 | 205 | loose |
| Young Nudy | ACT UP | 66 | 63 | 246 | loose |
| Young Nudy | Addicted | 50 | 29 | 235 | loose |
| Young Nudy | Against Me | 48 | 59 | 339 | loose |
| Young Nudy | Aint Got time | 54 | 46 | 308 | loose |
| Young Nudy | Ain’t Playing | 33 | 32 | 105 | loose |
| Young Nudy | Air It Out | 44 | 49 | 98 | loose |
| Young Nudy | All My Niggas | 31 | 31 | 261 | loose |
| Young Nudy | All White | 74 | 76 | 353 | loose |
| Young Nudy | Andy G | 56 | 50 | 141 | loose |
| Young Nudy | Angels Vs Demons | 37 | 45 | 222 | loose |
| Young Nudy | Anyways | 55 | 52 | 220 | loose |
| Young Nudy | Ask Bout Me | 47 | 47 | 293 | loose |
| Young Nudy | At the Traphouse | 71 | 54 | 259 | loose |
| Young Nudy | Attitude | 53 | 40 | 219 | loose |
| Young Nudy | BIG BAD WOLF | 59 | 38 | 293 | loose |
| Young Nudy | BTA | 47 | 42 | 299 | loose |
| Young Nudy | Baby* | 27 | 28 | 98 | loose |
| Young Nudy | Bad News | 28 | 25 | 160 | loose |
| Young Nudy | Bang Pistols | 32 | 21 | 158 | loose |
| Young Nudy | Barbecue | 51 | 79 | 184 | loose |
| Young Nudy | Barry From Simpson | 85 | 102 | 479 | loose |
| Young Nudy | Battlefield | 62 | 49 | 262 | loose |
| Young Nudy | Been Thuggin’ | 59 | 48 | 199 | loose |
| Young Nudy | Bermuda | 38 | 33 | 114 | loose |
| Young Nudy | Big Flame | 29 | 30 | 168 | loose |
| Young Nudy | Big Strap | 29 | 28 | 124 | loose |
| Young Nudy | Black Hippie, White Hipster | 70 | 104 | 334 | loose |
| Young Nudy | Blessings | 39 | 40 | 130 | loose |
| Young Nudy | Block Lovin | 44 | 44 | 274 | loose |
| Young Nudy | Bloody | 36 | 56 | 290 | loose |
| Young Nudy | Blue Cheese Salad | 51 | 49 | 232 | loose |
| Young Nudy | Bodies on Bodies | 46 | 81 | 306 | loose |
| Young Nudy | Boujee Bitches | 35 | 25 | 167 | loose |
| Young Nudy | Bouldercrest Legend | 26 | 24 | 90 | loose |
| Young Nudy | Breakdown | 29 | 22 | 121 | loose |
| Young Nudy | Brussel Sprout | 43 | 22 | 221 | loose |
| Young Nudy | Burn Ya | 34 | 24 | 167 | loose |
| Young Nudy | Butt Naked Bitches | 34 | 38 | 244 | loose |
| Young Nudy | Bypass | 38 | 40 | 229 | loose |
| Young Nudy | CHAINS ON | 41 | 23 | 176 | loose |
| Young Nudy | Call Dat Bitch Homicide | 58 | 37 | 158 | loose |
| Young Nudy | Cancer Stick No Pressure | 135 | 166 | 608 | loose |
| Young Nudy | Can’t Clone Me | 74 | 71 | 259 | loose |
| Young Nudy | Can’t Contain | 51 | 45 | 284 | loose |
| Young Nudy | Cap Dem | 56 | 46 | 331 | loose |
| Young Nudy | Child’s Play | 53 | 47 | 185 | loose |
| Young Nudy | Cinco de Mayo | 6 | 1 | 25 | loose |
| Young Nudy | Colombian Necktie | 79 | 50 | 563 | loose |
| Young Nudy | Come To My World | 36 | 57 | 109 | loose |
| Young Nudy | Coming For It | 42 | 22 | 200 | loose |
| Young Nudy | Crack | 54 | 61 | 217 | loose |
| Young Nudy | DOPE BOY | 45 | 71 | 153 | loose |
| Young Nudy | DR. EV4L | 55 | 54 | 239 | loose |
| Young Nudy | Deep Blue | 32 | 25 | 171 | loose |
| Young Nudy | Deeper Than Rap | 69 | 147 | 344 | loose |
| Young Nudy | Dispatch | 46 | 31 | 266 | loose |
| Young Nudy | Do It | 30 | 9 | 173 | loose |
| Young Nudy | Do It with The... | 47 | 41 | 244 | loose |
| Young Nudy | Do That | 42 | 25 | 190 | loose |
| Young Nudy | Don’t Beef | 4 | 1 | 3 | loose |
| Young Nudy | Don’t Trust Y’all | 40 | 14 | 149 | loose |
| Young Nudy | Down Bad | 66 | 45 | 379 | loose |
| Young Nudy | Duck Meat | 44 | 41 | 314 | loose |
| Young Nudy | Duntsane | 35 | 37 | 263 | loose |
| Young Nudy | EA | 60 | 81 | 250 | loose |
| Young Nudy | EA Nightmare | 43 | 38 | 263 | loose |
| Young Nudy | Ends | 39 | 16 | 146 | loose |
| Young Nudy | Enough Ammo (Remix) | 50 | 68 | 275 | loose |
| Young Nudy | Envy | 25 | 26 | 154 | loose |
| Young Nudy | Extendo | 64 | 68 | 183 | loose |
| Young Nudy | Fatsane | 39 | 60 | 259 | loose |
| Young Nudy | Ferris Wheel | 35 | 65 | 319 | loose |
| Young Nudy | First Day Out | 70 | 47 | 276 | loose |
| Young Nudy | Fish & Chips | 50 | 100 | 422 | loose |
| Young Nudy | Fish Scale | 57 | 35 | 380 | loose |
| Young Nudy | Fox 5 | 31 | 17 | 81 | loose |
| Young Nudy | Freaky Girl | 39 | 36 | 189 | loose |
| Young Nudy | Freaky Music | 30 | 29 | 102 | loose |
| Young Nudy | Fresh As Fuck | 51 | 26 | 387 | loose |
| Young Nudy | Friday | 60 | 34 | 160 | loose |
| Young Nudy | From Da Gutta | 39 | 29 | 149 | loose |
| Young Nudy | Fuck Me Mean | 56 | 82 | 510 | loose |
| Young Nudy | Fugazi | 43 | 18 | 83 | loose |
| Young Nudy | GOAT | 54 | 49 | 457 | loose |
| Young Nudy | GOAT Freestyle | 42 | 44 | 139 | loose |
| Young Nudy | GTA Lyfestyle | 81 | 139 | 434 | loose |
| Young Nudy | Gangbang | 25 | 35 | 99 | loose |
| Young Nudy | Gas | 48 | 55 | 205 | loose |
| Young Nudy | Gas Station | 37 | 30 | 131 | loose |
| Young Nudy | Get Fu*ked Up | 24 | 26 | 134 | loose |
| Young Nudy | Get It | 36 | 37 | 66 | loose |
| Young Nudy | Ghana | 36 | 22 | 184 | loose |
| Young Nudy | Glocks & Choppas | 30 | 36 | 212 | loose |
| Young Nudy | Gnarly | 28 | 38 | 107 | loose |
| Young Nudy | Go (30 Hang Out) | 37 | 38 | 101 | loose |
| Young Nudy | Gone On On | 33 | 30 | 115 | loose |
| Young Nudy | Good Somethin | 52 | 35 | 233 | loose |
| Young Nudy | Gotta Salute | 28 | 19 | 166 | loose |
| Young Nudy | Green Bean | 76 | 118 | 460 | loose |
| Young Nudy | Hakuna Matata | 30 | 37 | 142 | loose |
| Young Nudy | Hang | 19 | 22 | 71 | loose |
| Young Nudy | Havin My Way | 56 | 44 | 153 | loose |
| Young Nudy | Hell Shell | 32 | 34 | 130 | loose |
| Young Nudy | Homies | 58 | 59 | 277 | loose |
| Young Nudy | Hot Grease | 49 | 35 | 359 | loose |
| Young Nudy | Hot Wings | 49 | 32 | 248 | loose |
| Young Nudy | How I Eat | 48 | 82 | 309 | loose |
| Young Nudy | How It Be | 47 | 75 | 235 | loose |
| Young Nudy | How They Label Me | 29 | 38 | 215 | loose |
| Young Nudy | I Ain’t Havin’ It | 60 | 84 | 209 | loose |
| Young Nudy | I Can’t Change | 35 | 25 | 182 | loose |
| Young Nudy | I Got | 44 | 43 | 139 | loose |
| Young Nudy | I Won’t Flex | 32 | 13 | 97 | loose |
| Young Nudy | ICED TEA | 49 | 89 | 287 | loose |
| Young Nudy | Ice Chain (Bonus) | 41 | 25 | 244 | loose |
| Young Nudy | Impala | 27 | 37 | 218 | loose |
| Young Nudy | In Real Life | 46 | 54 | 161 | loose |
| Young Nudy | InDaStreet | 41 | 22 | 213 | loose |
| Young Nudy | Influencer | 70 | 64 | 262 | loose |
| Young Nudy | Intro (Back on that BS) | 14 | 14 | 37 | loose |
| Young Nudy | It’s Official | 52 | 44 | 217 | loose |
| Young Nudy | It’s Time* | 40 | 19 | 290 | loose |
| Young Nudy | I’m Big Dawg | 22 | 20 | 121 | loose |
| Young Nudy | I’m a Savage | 42 | 49 | 171 | loose |
| Young Nudy | JBH | 49 | 84 | 187 | loose |
| Young Nudy | John Wayne | 33 | 27 | 323 | loose |
| Young Nudy | Joker | 64 | 50 | 257 | loose |
| Young Nudy | Judge Scott Convicted | 35 | 35 | 195 | loose |
| Young Nudy | Jugg | 46 | 22 | 94 | loose |
| Young Nudy | Jungle | 60 | 80 | 208 | loose |
| Young Nudy | KKK | 53 | 56 | 214 | loose |
| Young Nudy | Keep It 100 | 50 | 45 | 283 | loose |
| Young Nudy | Keep It in the Street | 57 | 41 | 340 | loose |
| Young Nudy | Kill Bill | 47 | 62 | 337 | loose |
| Young Nudy | KitKat | 35 | 17 | 293 | loose |
| Young Nudy | Know How I Rock | 67 | 115 | 364 | loose |
| Young Nudy | Know What’s Happenin | 51 | 44 | 255 | loose |
| Young Nudy | Like You Want To | 47 | 65 | 400 | loose |
| Young Nudy | Little Foot Big Foot | 57 | 82 | 265 | loose |
| Young Nudy | Loaded | 25 | 35 | 127 | loose |
| Young Nudy | Loaded Baked Potato | 72 | 70 | 279 | loose |
| Young Nudy | Location | 67 | 62 | 275 | loose |
| Young Nudy | Long Ride | 45 | 17 | 280 | loose |
| Young Nudy | Lovers | 24 | 12 | 78 | loose |
| Young Nudy | Lullaby | 38 | 58 | 227 | loose |
| Young Nudy | Lunch Meat | 36 | 62 | 275 | loose |
| Young Nudy | M.R.E. | 38 | 35 | 191 | loose |
| Young Nudy | MOP STICK | 40 | 58 | 307 | loose |
| Young Nudy | Marathon | 50 | 64 | 335 | loose |
| Young Nudy | MarcB | 47 | 37 | 193 | loose |
| Young Nudy | Max Payne | 31 | 48 | 259 | loose |
| Young Nudy | McChicken | 47 | 50 | 260 | loose |
| Young Nudy | Mercy with Doubt | 47 | 24 | 168 | loose |
| Young Nudy | Middle Fingers | 54 | 29 | 237 | loose |
| Young Nudy | Middle Of The Hood | 25 | 21 | 169 | loose |
| Young Nudy | Mini Me | 63 | 115 | 291 | loose |
| Young Nudy | Miracle | 42 | 58 | 213 | loose |
| Young Nudy | Mister | 45 | 39 | 204 | loose |
| Young Nudy | Money | 34 | 31 | 227 | loose |
| Young Nudy | Money Makin Mitch | 29 | 76 | 203 | loose |
| Young Nudy | Money Spread | 66 | 66 | 293 | loose |
| Young Nudy | Money to Spend | 34 | 20 | 225 | loose |
| Young Nudy | Mood Gone | 30 | 25 | 164 | loose |
| Young Nudy | Moving Too Fast | 42 | 47 | 202 | loose |
| Young Nudy | Mud | 36 | 17 | 103 | loose |
| Young Nudy | My Gang | 27 | 27 | 256 | loose |
| Young Nudy | My Real Dawgs | 47 | 23 | 273 | loose |
| Young Nudy | My Year | 86 | 68 | 274 | loose |
| Young Nudy | NICE | 48 | 62 | 123 | loose |
| Young Nudy | Nasty | 48 | 52 | 359 | loose |
| Young Nudy | Never | 59 | 64 | 393 | loose |
| Young Nudy | No Chaser | 33 | 40 | 305 | loose |
| Young Nudy | No Clue | 57 | 49 | 119 | loose |
| Young Nudy | No Comprende | 67 | 120 | 299 | loose |
| Young Nudy | No Deal | 49 | 41 | 292 | loose |
| Young Nudy | No Disrespect | 46 | 60 | 302 | loose |
| Young Nudy | No Freestyle | 60 | 35 | 467 | loose |
| Young Nudy | No Go | 76 | 133 | 279 | loose |
| Young Nudy | No Hospitals | 32 | 69 | 280 | loose |
| Young Nudy | No Pretending | 51 | 72 | 303 | loose |
| Young Nudy | No Problem | 51 | 54 | 304 | loose |
| Young Nudy | No Stains | 42 | 48 | 154 | loose |
| Young Nudy | No Worries | 33 | 26 | 176 | loose |
| Young Nudy | Nonchalant | 30 | 33 | 123 | loose |
| Young Nudy | Noon | 51 | 39 | 147 | loose |
| Young Nudy | Notice (R.I.P. Fredo Demo) | 4 | 1 | 5 | loose |
| Young Nudy | Nun Like This | 53 | 55 | 149 | loose |
| Young Nudy | Nun To Do | 56 | 105 | 245 | loose |
| Young Nudy | Nutsack | 54 | 27 | 338 | loose |
| Young Nudy | Ok Again | 31 | 24 | 117 | loose |
| Young Nudy | Okra | 39 | 38 | 197 | loose |
| Young Nudy | Old School | 44 | 26 | 263 | loose |
| Young Nudy | On Deck* | 8 | 3 | 9 | loose |
| Young Nudy | On the Curb | 45 | 57 | 251 | loose |
| Young Nudy | One Dolla | 61 | 36 | 155 | loose |
| Young Nudy | One in the Head | 69 | 79 | 267 | loose |
| Young Nudy | Outro | 34 | 28 | 101 | loose |
| Young Nudy | PARADISE | 36 | 71 | 230 | loose |
| Young Nudy | PB&J | 41 | 65 | 346 | loose |
| Young Nudy | PULL UP | 48 | 59 | 171 | loose |
| Young Nudy | Pancake | 48 | 88 | 219 | loose |
| Young Nudy | Paranoia | 39 | 34 | 90 | loose |
| Young Nudy | Passion Fruit | 41 | 41 | 161 | loose |
| Young Nudy | Patience | 56 | 73 | 201 | loose |
| Young Nudy | Peaches & Eggplants | 59 | 77 | 169 | loose |
| Young Nudy | Pelican | 52 | 46 | 217 | loose |
| Young Nudy | Pennywise | 37 | 23 | 187 | loose |
| Young Nudy | Peons | 44 | 36 | 355 | loose |
| Young Nudy | Perc 30 | 55 | 75 | 291 | loose |
| Young Nudy | Photoshoot* | 17 | 10 | 90 | loose |
| Young Nudy | Pissy Pamper | 79 | 57 | 155 | loose |
| Young Nudy | Pissy Pamper Remix (Kid Cudi on Kid Cudi)* | 4 | 1 | 17 | loose |
| Young Nudy | Polker | 9 | 8 | 74 | loose |
| Young Nudy | Portabella | 49 | 89 | 241 | loose |
| Young Nudy | Pot Roast | 48 | 28 | 242 | loose |
| Young Nudy | Project X | 35 | 22 | 309 | loose |
| Young Nudy | Pussy | 33 | 32 | 202 | loose |
| Young Nudy | R.I.P. Fredo (Notice Me) | 43 | 41 | 75 | loose |
| Young Nudy | ROCK OUT (Remix) | 58 | 66 | 349 | loose |
| Young Nudy | Rainbow | 32 | 9 | 109 | loose |
| Young Nudy | Ready | 46 | 40 | 202 | loose |
| Young Nudy | Real Nigga | 29 | 13 | 128 | loose |
| Young Nudy | Real Right | 44 | 25 | 171 | loose |
| Young Nudy | Really Redd | 32 | 48 | 218 | loose |
| Young Nudy | Reckless | 46 | 53 | 183 | loose |
| Young Nudy | Revenge | 60 | 53 | 519 | loose |
| Young Nudy | Rich Flex | 69 | 53 | 265 | loose |
| Young Nudy | Richer Dreams | 38 | 40 | 299 | loose |
| Young Nudy | Right 1 | 34 | 40 | 183 | loose |
| Young Nudy | Right Now | 52 | 49 | 372 | loose |
| Young Nudy | Robbin and Gettin | 36 | 21 | 213 | loose |
| Young Nudy | Rough Life | 32 | 44 | 248 | loose |
| Young Nudy | Roughneck | 48 | 63 | 161 | loose |
| Young Nudy | SNAKE | 60 | 79 | 166 | loose |
| Young Nudy | SPENDIN AINT NOTHIN | 47 | 47 | 217 | loose |
| Young Nudy | SPIN N FLIP | 31 | 37 | 358 | loose |
| Young Nudy | STEPBROTHERS | 73 | 80 | 480 | loose |
| Young Nudy | SUGAR | 41 | 44 | 309 | loose |
| Young Nudy | SUPER SLIME | 35 | 47 | 155 | loose |
| Young Nudy | Safety | 4 | 1 | 13 | loose |
| Young Nudy | Save Myself | 55 | 67 | 255 | loose |
| Young Nudy | Say Too Much | 37 | 40 | 210 | loose |
| Young Nudy | Scott Evil | 90 | 107 | 375 | loose |
| Young Nudy | Sherbert | 70 | 55 | 155 | loose |
| Young Nudy | Shootem Up Bang | 57 | 67 | 300 | loose |
| Young Nudy | Shootin Star | 63 | 55 | 291 | loose |
| Young Nudy | Shots Fired | 31 | 28 | 153 | loose |
| Young Nudy | Shotta | 44 | 33 | 166 | loose |
| Young Nudy | Shrimp | 47 | 75 | 347 | loose |
| Young Nudy | Shrimp & Grits | 44 | 87 | 238 | loose |
| Young Nudy | Sick Of Slime | 39 | 51 | 257 | loose |
| Young Nudy | Since When | 55 | 45 | 191 | loose |
| Young Nudy | Single Asf | 68 | 88 | 282 | loose |
| Young Nudy | Slight Dub | 37 | 47 | 226 | loose |
| Young Nudy | Slime | 54 | 43 | 166 | loose |
| Young Nudy | Slime Shit | 59 | 58 | 241 | loose |
| Young Nudy | SlimeBall | 23 | 13 | 242 | loose |
| Young Nudy | Smoke | 24 | 48 | 169 | loose |
| Young Nudy | Snakes in My Grass | 29 | 19 | 195 | loose |
| Young Nudy | Sneak Dissa | 37 | 41 | 240 | loose |
| Young Nudy | Snitches & Rats | 46 | 46 | 258 | loose |
| Young Nudy | Something Else | 40 | 23 | 133 | loose |
| Young Nudy | Soul Keeper | 57 | 109 | 447 | loose |
| Young Nudy | Spaced Out | 48 | 46 | 246 | loose |
| Young Nudy | Splash | 45 | 38 | 148 | loose |
| Young Nudy | Studio | 25 | 39 | 224 | loose |
| Young Nudy | Sunflower Seeds | 38 | 21 | 94 | loose |
| Young Nudy | Sunset | 45 | 67 | 250 | loose |
| Young Nudy | Sweep | 36 | 37 | 195 | loose |
| Young Nudy | Swisher Backwood | 62 | 51 | 171 | loose |
| Young Nudy | That’s Not Gangsta | 38 | 42 | 175 | loose |
| Young Nudy | That’s Why | 63 | 59 | 249 | loose |
| Young Nudy | The Race (Remix) | 57 | 93 | 248 | loose |
| Young Nudy | The Rustlers | 46 | 46 | 301 | loose |
| Young Nudy | Threat | 18 | 7 | 277 | loose |
| Young Nudy | Tighten Up | 46 | 50 | 226 | loose |
| Young Nudy | Timber | 69 | 80 | 153 | loose |
| Young Nudy | Too Real | 4 | 5 | 4 | AAAA |
| Young Nudy | Trafficking (KKK) | 29 | 34 | 125 | loose |
| Young Nudy | Trap House | 33 | 12 | 367 | loose |
| Young Nudy | Trap Shit | 53 | 43 | 236 | loose |
| Young Nudy | Trapaholic | 27 | 12 | 106 | loose |
| Young Nudy | Trust Freestyle | 17 | 10 | 97 | loose |
| Young Nudy | Turn Up | 38 | 41 | 116 | loose |
| Young Nudy | Turnt | 35 | 41 | 158 | loose |
| Young Nudy | Umbrella | 68 | 87 | 221 | loose |
| Young Nudy | Understanding | 62 | 85 | 549 | loose |
| Young Nudy | Unemotional | 32 | 22 | 223 | loose |
| Young Nudy | Vice City | 53 | 10 | 269 | loose |
| Young Nudy | WHAT’S HAPPENIN’ | 43 | 55 | 207 | loose |
| Young Nudy | WIT TWIN* | 9 | 6 | 26 | loose |
| Young Nudy | Walk Down (Remix) | 66 | 104 | 405 | loose |
| Young Nudy | Walking Dead | 47 | 53 | 277 | loose |
| Young Nudy | We Do Not Give Up | 37 | 21 | 289 | loose |
| Young Nudy | We Outta Here! | 69 | 78 | 199 | loose |
| Young Nudy | We Up | 20 | 17 | 112 | loose |
| Young Nudy | Weed | 42 | 29 | 137 | loose |
| Young Nudy | WhoopDuWhoop | 40 | 42 | 119 | loose |
| Young Nudy | Wicked for the Money | 44 | 37 | 351 | loose |
| Young Nudy | YN* | 9 | 8 | 28 | loose |
| Young Nudy | Ya Dig | 34 | 40 | 229 | loose |
| Young Nudy | Yall Dont Want It | 50 | 31 | 64 | loose |
| Young Nudy | Yeah Yeah | 47 | 21 | 125 | loose |
| Young Nudy | Yellow Tape | 45 | 46 | 243 | loose |
| Young Nudy | Yep Yep | 24 | 20 | 82 | loose |
| Young Nudy | You Ain’t Hard | 51 | 23 | 269 | loose |
| Young Nudy | You Better Learn | 48 | 24 | 146 | loose |
| Young Nudy | You See It | 41 | 56 | 146 | loose |
| Young Nudy | Zone 6 (Remix) | 59 | 66 | 251 | loose |
