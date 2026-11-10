# Vic Mensa rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Vic Mensa, VIC MENSA
- Songs: 365
- Bars kept (Vic Mensa lyric lines): 17211
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 18
- Canonical name: Vic Mensa.
- Credit strings: Vic Mensa; VIC MENSA.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 106169
- REPEAT pairs, recorded separately: 9879
- END rhymes: 14014
- INNER rhymes: 92155

By match:

- PERFECT: 8760 (END 2166, INNER 6594)
- SLANT: 41409 (END 5489, INNER 35920)
- ASSONANCE: 54584 (END 5971, INNER 48613)
- MULTI: 1416 (END 388, INNER 1028)

By confidence:

- HIGH: 9161
- MED: 92270
- LOW: 4738

## Core

- Core Y: 104704
- Core N among rhyme pairs: 1465

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 45902 (43.2%)
- vowel: 54584 (51.4%)
- spelling: 4267 (4.0%)
- multi: 1416 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 365 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 7671 pairs (END 683, INNER 6988). Words: shit, think, bitch, still, bitches, little, different, hit.
2. `vow:EH` — 7628 pairs (END 687, INNER 6941). Words: when, get, never, where, let, left, every, tell.
3. `vow:OW` — 6731 pairs (END 738, INNER 5993). Words: don't, know, no, go, only, told, home, over.
4. `vow:EY` — 6150 pairs (END 813, INNER 5337). Words: ain't, say, way, make, day, play, take, away.
5. `vow:AY` — 5179 pairs (END 548, INNER 4631). Words: like, by, die, high, why, time, mind, life.
6. `vow:AE` — 5092 pairs (END 562, INNER 4530). Words: back, can't, had, have, man, black, can, ask.
7. `vow:AA` — 4584 pairs (END 488, INNER 4096). Words: got, want, not, hard, wanna, cause, problems, shots.
8. `vow:IY` — 4421 pairs (END 488, INNER 3933). Words: see, even, need, these, keep, people, free, streets.
9. `vow:AH` — 3111 pairs (END 308, INNER 2803). Words: love, what, fuck, some, one, come, something, fucking.
10. `slant:AA:stop` — 1714 pairs (END 194, INNER 1520). Words: got, not, gotta, want, stop, god, block, top.
11. `slant:IH:stop` — 1592 pairs (END 180, INNER 1412). Words: shit, nigga, hit, vic, big, city, dick, whip.
12. `vow:UW` — 1374 pairs (END 237, INNER 1137). Words: new, who, through, two, used, knew, move, music.
13. `slant:AY:stop` — 1299 pairs (END 96, INNER 1203). Words: like, right, might, night, ride, white, side, inside.
14. `slant:AE:stop` — 1242 pairs (END 185, INNER 1057). Words: back, had, black, bad, can't, rap, act, fact.
15. `vow:AO` — 1210 pairs (END 135, INNER 1075). Words: all, lost, call, more, talking, wanted, morning, gone.
16. `slant:EH:stop` — 1203 pairs (END 148, INNER 1055). Words: get, let, said, better, head, neck, left, best.
17. `cmu:OW` — 1177 pairs (END 191, INNER 986). Words: know, no, go, show, though, flow, blow, low.
18. `slant:EH:nas-stop` — 1045 pairs (END 43, INNER 1002). Words: when, get, let, said, em, again, many, better.
19. `slant:AY:nas-stop` — 1037 pairs (END 87, INNER 950). Words: like, time, trying, line, sign, right, shine, mine.
20. `slant:EH:liq-stop` — 961 pairs (END 55, INNER 906). Words: get, tell, where, let, said, there, head, well.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 755 pair sides, mostly spelling via spelling phonetic key, often with niggas (166)
- niggas — 358 pair sides, mostly spelling via spelling phonetic key, often with nigga (166)
- tryna — 207 pair sides, mostly spelling via spelling phonetic key, often with even (14)
- gon — 142 pair sides, mostly spelling via spelling phonetic key, often with dont (34)
- ima — 113 pair sides, mostly spelling via spelling phonetic key, often with shit (12)
- imma — 42 pair sides, mostly spelling via spelling phonetic key, often with niggas (11)
- shawty — 36 pair sides, mostly vowel via spelling phonetic key, often with body (5)
- cuz — 31 pair sides, mostly spelling via spelling phonetic key, often with money (4)
- homie — 30 pair sides, mostly spelling via spelling phonetic key, often with holy (4)
- savemoney — 30 pair sides, mostly vowel via spelling phonetic key, often with money (6)
- henny — 29 pair sides, mostly vowel via spelling phonetic key, often with any (2)
- finna — 28 pair sides, mostly spelling via spelling phonetic key, often with nigga (8)
- hov — 28 pair sides, mostly spelling via spelling phonetic key, often with whole (3)
- mensa — 26 pair sides, mostly spelling via spelling phonetic key, often with when (4)
- weezy — 24 pair sides, mostly multi via spelling phonetic key, often with easy (8)
- fam — 23 pair sides, mostly spelling via spelling phonetic key, often with have (3)
- bruh — 21 pair sides, mostly spelling via spelling phonetic key, often with money (2)
- chano — 20 pair sides, mostly spelling via spelling phonetic key, often with black (2)
- swervin — 20 pair sides, mostly spelling via spelling phonetic key, often with suburban (3)
- prolly — 19 pair sides, mostly vowel via spelling phonetic key, often with diddy (1)
- blam — 19 pair sides, mostly spelling via spelling phonetic key, often with bands (2)
- slacking — 19 pair sides, mostly spelling via spelling phonetic key, often with macking (4)
- vino — 18 pair sides, mostly vowel via spelling phonetic key, often with no (3)
- glocks — 18 pair sides, mostly vowel via spelling phonetic key, often with dont (3)
- meds — 17 pair sides, mostly vowel via spelling phonetic key, often with head (2)
- homies — 17 pair sides, mostly spelling via spelling phonetic key, often with hoodies (2)
- coldplay — 16 pair sides, mostly spelling via spelling phonetic key, often with day (6)
- nappy — 16 pair sides, mostly vowel via spelling phonetic key, often with grandpappy (4)
- opps — 15 pair sides, mostly vowel via spelling phonetic key, often with know (5)
- weezer — 15 pair sides, mostly spelling via spelling phonetic key, often with dreams (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Vic Mensa | $WISH | 50 | 32 | 298 | loose |
| Vic Mensa | $outhside Story | 60 | 82 | 410 | loose |
| Vic Mensa | 10K Problems | 27 | 16 | 198 | loose |
| Vic Mensa | 14 Days | 24 | 14 | 64 | loose |
| Vic Mensa | 16 Shots | 49 | 36 | 282 | loose |
| Vic Mensa | 2 Bad Bitches | 16 | 20 | 113 | loose |
| Vic Mensa | 2014 BET Hip Hop Awards - Cypher 2 | 96 | 74 | 781 | loose |
| Vic Mensa | 2018 BET Hip Hop Awards - Cypher 2 | 89 | 78 | 559 | loose |
| Vic Mensa | 2HONEST | 58 | 34 | 416 | loose |
| Vic Mensa | 3 AM | 47 | 20 | 151 | loose |
| Vic Mensa | 3 Years Sober | 22 | 31 | 63 | loose |
| Vic Mensa | 4 Rock Genius | 15 | 7 | 41 | loose |
| Vic Mensa | 5 Fingers of Death | 76 | 50 | 469 | loose |
| Vic Mensa | 773 Freestyle | 88 | 83 | 529 | loose |
| Vic Mensa | A.C. Green (Remix) | 53 | 30 | 274 | loose |
| Vic Mensa | ARE YOU REALLY THERE? | 50 | 32 | 231 | loose |
| Vic Mensa | Acid Trips to Vegas | 38 | 21 | 239 | loose |
| Vic Mensa | Alexander Wang | 41 | 23 | 275 | loose |
| Vic Mensa | Algorithm | 60 | 61 | 245 | loose |
| Vic Mensa | All Day | 67 | 23 | 333 | loose |
| Vic Mensa | All Good | 38 | 16 | 95 | loose |
| Vic Mensa | All That Shines | 67 | 66 | 198 | loose |
| Vic Mensa | Almost There | 54 | 34 | 281 | loose |
| Vic Mensa | Alone Wit U | 37 | 21 | 205 | loose |
| Vic Mensa | April 13th | 22 | 11 | 132 | loose |
| Vic Mensa | Around My Way | 28 | 29 | 214 | loose |
| Vic Mensa | B4 I Rule | 20 | 5 | 177 | loose |
| Vic Mensa | BET Backroom Freestyle | 69 | 71 | 400 | loose |
| Vic Mensa | BETHLEHEM / SC FREESTYLE | 67 | 47 | 499 | loose |
| Vic Mensa | BREATHE (FREESTYLE) | 47 | 33 | 327 | loose |
| Vic Mensa | Back To The Go | 60 | 50 | 501 | loose |
| Vic Mensa | Bad Man Lighter 2.0 | 45 | 42 | 282 | loose |
| Vic Mensa | Black Intro | 66 | 92 | 318 | loose |
| Vic Mensa | Black Sour | 60 | 49 | 257 | loose |
| Vic Mensa | Blazin’ | 48 | 44 | 551 | loose |
| Vic Mensa | Ble$$ings | 47 | 57 | 242 | loose |
| Vic Mensa | Blessing | 40 | 28 | 131 | loose |
| Vic Mensa | Blue Eyes | 27 | 43 | 117 | loose |
| Vic Mensa | Breaking All My Rules | 37 | 21 | 180 | loose |
| Vic Mensa | Bud Billiken | 57 | 57 | 247 | loose |
| Vic Mensa | CANDYMAN | 48 | 30 | 299 | loose |
| Vic Mensa | CHICAGO | 30 | 15 | 128 | loose |
| Vic Mensa | CLIPSE FREESTYLE | 22 | 8 | 285 | loose |
| Vic Mensa | Callie | 54 | 33 | 146 | loose |
| Vic Mensa | Camp America | 26 | 21 | 101 | loose |
| Vic Mensa | Can I Call U Baby | 35 | 33 | 178 | loose |
| Vic Mensa | Cancer (Interlude) | 24 | 17 | 150 | loose |
| Vic Mensa | Card Cracker (Skit) | 7 | 4 | 48 | loose |
| Vic Mensa | Children Of The Sun | 41 | 42 | 308 | loose |
| Vic Mensa | Clear Eyes | 21 | 10 | 129 | loose |
| Vic Mensa | Cocaine | 51 | 22 | 265 | loose |
| Vic Mensa | Cocoa Butter Kisses | 66 | 50 | 423 | loose |
| Vic Mensa | Codeine Crazy (Icarus Story) | 49 | 21 | 173 | loose |
| Vic Mensa | Coffee & Cigarettes | 47 | 28 | 195 | loose |
| Vic Mensa | Coldplay | 40 | 29 | 221 | loose |
| Vic Mensa | Come Closer | 76 | 56 | 229 | loose |
| Vic Mensa | Common Sense | 47 | 38 | 208 | loose |
| Vic Mensa | Crash | 22 | 25 | 347 | loose |
| Vic Mensa | Crazy | 38 | 28 | 264 | loose |
| Vic Mensa | Cross Roads | 72 | 93 | 388 | loose |
| Vic Mensa | DIRT ON MY NAME | 48 | 49 | 241 | loose |
| Vic Mensa | DRIPPING SUMMERS | 27 | 22 | 208 | loose |
| Vic Mensa | DRIVE ME CRAZY | 47 | 40 | 261 | loose |
| Vic Mensa | Dancing In The Streetz | 32 | 26 | 151 | loose |
| Vic Mensa | Danger | 66 | 51 | 279 | loose |
| Vic Mensa | Dark Things | 32 | 18 | 138 | loose |
| Vic Mensa | Darling | 47 | 41 | 232 | loose |
| Vic Mensa | Dawn | 27 | 12 | 62 | loose |
| Vic Mensa | Day 3 (SXSW Cypher) | 137 | 124 | 533 | loose |
| Vic Mensa | Deserve It | 56 | 84 | 219 | loose |
| Vic Mensa | Did It B4 | 67 | 58 | 385 | loose |
| Vic Mensa | Didn’t I (Say I Didn’t) | 82 | 37 | 402 | loose |
| Vic Mensa | Dim Sum | 53 | 65 | 199 | loose |
| Vic Mensa | Diplomatic Immunity (Freestyle) | 57 | 51 | 428 | loose |
| Vic Mensa | Do It All | 72 | 60 | 503 | loose |
| Vic Mensa | Don Juan | 44 | 31 | 224 | loose |
| Vic Mensa | Donuts Freestyle | 42 | 39 | 251 | loose |
| Vic Mensa | Don’t Blame Me (For You) | 31 | 40 | 108 | loose |
| Vic Mensa | Don’t Give Up | 46 | 49 | 219 | loose |
| Vic Mensa | Don’t Leave | 29 | 21 | 234 | loose |
| Vic Mensa | Doo-Wah | 53 | 46 | 128 | loose |
| Vic Mensa | Down On My Luck | 27 | 10 | 97 | loose |
| VIC MENSA | Down for Some Ignorance (Ghetto Lullaby) | 81 | 68 | 274 | loose |
| Vic Mensa | Drug Dealers Anonymous (Freestyle) | 55 | 40 | 377 | loose |
| Vic Mensa | Dusk Till Dawn | 56 | 46 | 132 | loose |
| Vic Mensa | Dynasty | 63 | 41 | 443 | loose |
| Vic Mensa | D’ussé Tears | 37 | 21 | 95 | loose |
| Vic Mensa | Eastside Girl | 33 | 19 | 66 | loose |
| Vic Mensa | Egyptian Cotton | 31 | 16 | 142 | loose |
| Vic Mensa | Empathy | 28 | 21 | 191 | loose |
| Vic Mensa | Every Step That I Take (Mensa Mix) | 26 | 19 | 33 | loose |
| Vic Mensa | F.I.N.E. [sketch] | 17 | 18 | 41 | loose |
| Vic Mensa | FR33DOM | 65 | 43 | 201 | loose |
| Vic Mensa | FTW! | 61 | 48 | 334 | loose |
| Vic Mensa | Fake Decent | 39 | 49 | 247 | loose |
| Vic Mensa | Falling Asleep at the Wheel | 33 | 46 | 168 | loose |
| Vic Mensa | Family | 51 | 61 | 336 | loose |
| Vic Mensa | Farm to Table | 44 | 41 | 263 | loose |
| Vic Mensa | Fast Life | 36 | 38 | 257 | loose |
| Vic Mensa | Fear & Doubt | 62 | 31 | 336 | loose |
| Vic Mensa | Feel That | 33 | 15 | 190 | loose |
| Vic Mensa | Fire In The Booth (Freestyle) | 166 | 126 | 880 | loose |
| Vic Mensa | Fistfight! | 35 | 17 | 128 | loose |
| Vic Mensa | Flashing Lights | 31 | 24 | 288 | loose |
| Vic Mensa | For The Win | 42 | 19 | 254 | loose |
| Vic Mensa | Forever | 32 | 40 | 209 | loose |
| Vic Mensa | Free Love | 78 | 51 | 444 | loose |
| Vic Mensa | Freedom Is A Word | 36 | 52 | 254 | loose |
| Vic Mensa | Freestyle on The Hot Box w/ DJ Enuff | 28 | 18 | 193 | loose |
| Vic Mensa | Friends Don’t Hurt Friends (Original) | 41 | 29 | 233 | loose |
| Vic Mensa | G W M | 62 | 38 | 87 | loose |
| Vic Mensa | GHETTO. | 45 | 38 | 267 | loose |
| Vic Mensa | GOIN’ SCOTTY | 28 | 13 | 98 | loose |
| Vic Mensa | Gangsta | 61 | 26 | 155 | loose |
| Vic Mensa | Ganja | 21 | 9 | 42 | loose |
| Vic Mensa | Gentlemen’s Club | 64 | 31 | 158 | loose |
| Vic Mensa | Get Away | 35 | 59 | 137 | loose |
| Vic Mensa | Get That | 29 | 5 | 150 | loose |
| Vic Mensa | Go Tell ’Em | 39 | 50 | 194 | loose |
| Vic Mensa | Go with It | 37 | 20 | 158 | loose |
| Vic Mensa | Gold (Peter CottonTale Remix) | 50 | 30 | 244 | loose |
| Vic Mensa | Goodbye 2 Heartbreak | 16 | 4 | 21 | loose |
| Vic Mensa | Gorgeous | 65 | 46 | 287 | loose |
| Vic Mensa | HEALTH IS WEALTH (RANDY MOSS) | 46 | 45 | 205 | loose |
| Vic Mensa | HIT BOY FREESTYLE | 47 | 61 | 332 | loose |
| Vic Mensa | Half | 44 | 38 | 274 | loose |
| Vic Mensa | Hangerz | 61 | 64 | 295 | loose |
| Vic Mensa | Happy Little Thoughts (Remix) | 52 | 32 | 111 | loose |
| Vic Mensa | Hard Times | 50 | 66 | 386 | loose |
| Vic Mensa | Have U Eva | 56 | 44 | 286 | loose |
| Vic Mensa | Heat It Up (Freestyle) | 50 | 25 | 316 | loose |
| Vic Mensa | Heathens Freestyle | 60 | 64 | 439 | loose |
| Vic Mensa | Heaven on Earth | 112 | 72 | 557 | loose |
| Vic Mensa | Heir to the Throne (Freestyle) | 69 | 52 | 421 | loose |
| Vic Mensa | Hey Jane | 35 | 26 | 132 | loose |
| Vic Mensa | High In The Woods (Remix) | 33 | 32 | 125 | loose |
| Vic Mensa | Hollywood LA | 72 | 45 | 259 | loose |
| Vic Mensa | Holy F4k | 45 | 50 | 232 | loose |
| Vic Mensa | Holy Holy | 51 | 33 | 335 | loose |
| Vic Mensa | Home | 93 | 92 | 700 | loose |
| Vic Mensa | Homesick | 34 | 14 | 105 | loose |
| Vic Mensa | Homewrecker | 54 | 48 | 279 | loose |
| Vic Mensa | Hot 97 Freestyle | 57 | 43 | 194 | loose |
| Vic Mensa | Hunger Flow, Vol. 2 Intro | 71 | 81 | 399 | loose |
| Vic Mensa | I Ain’t Trippin | 49 | 46 | 279 | loose |
| Vic Mensa | I Been | 34 | 15 | 205 | loose |
| Vic Mensa | I CRY 2 | 10 | 9 | 43 | loose |
| Vic Mensa | I Got This | 54 | 43 | 385 | loose |
| Vic Mensa | INTRODUCTION | 9 | 10 | 15 | loose |
| Vic Mensa | Imperial | 64 | 44 | 185 | loose |
| Vic Mensa | In Some Trouble | 54 | 40 | 187 | loose |
| Vic Mensa | Internet Explorer | 28 | 29 | 172 | loose |
| Vic Mensa | Involved | 51 | 26 | 199 | loose |
| Vic Mensa | I’m Yours | 29 | 12 | 86 | loose |
| Vic Mensa | JLIG / Just Landed In Ghana | 13 | 16 | 20 | loose |
| Vic Mensa | James Harden | 52 | 42 | 291 | loose |
| Vic Mensa | Jerseys & Loafers | 45 | 40 | 400 | loose |
| Vic Mensa | Joyride [Remix] | 29 | 21 | 126 | loose |
| Vic Mensa | Juice (Remix) | 42 | 23 | 231 | loose |
| Vic Mensa | Just Like the Movies | 77 | 70 | 373 | loose |
| Vic Mensa | Just the Same | 41 | 23 | 163 | loose |
| Vic Mensa | K-Swiss | 14 | 8 | 38 | loose |
| Vic Mensa | KING | 25 | 16 | 83 | loose |
| Vic Mensa | KNOW ME 2 WELL | 17 | 8 | 52 | loose |
| Vic Mensa | Karma Police | 13 | 7 | 19 | loose |
| Vic Mensa | Keep on Slippin’ | 50 | 29 | 220 | loose |
| Vic Mensa | Kill Us All | 31 | 17 | 185 | loose |
| Vic Mensa | Kingdom Come | 38 | 44 | 173 | loose |
| Vic Mensa | Klonopin | 37 | 23 | 161 | loose |
| Vic Mensa | Knew Bae | 45 | 38 | 154 | loose |
| Vic Mensa | LOVE | 39 | 17 | 125 | loose |
| Vic Mensa | LVLN UP | 34 | 35 | 117 | loose |
| Vic Mensa | Law of Karma | 65 | 61 | 431 | loose |
| Vic Mensa | Lay It All On Me (Rudimental VIP Mix) | 45 | 37 | 123 | loose |
| Vic Mensa | Let U Know | 31 | 58 | 176 | loose |
| Vic Mensa | Levis 5:01 Live Freestyle | 11 | 3 | 100 | loose |
| Vic Mensa | Lights Out | 42 | 26 | 263 | loose |
| Vic Mensa | Like the Way | 44 | 47 | 248 | loose |
| Vic Mensa | Link up | 27 | 30 | 97 | loose |
| Vic Mensa | Liquor Locker | 50 | 22 | 166 | loose |
| Vic Mensa | Lord Release | 57 | 45 | 399 | loose |
| Vic Mensa | Lose It | 27 | 12 | 108 | loose |
| Vic Mensa | Lovely Day | 52 | 29 | 203 | loose |
| Vic Mensa | MACHIAVELLI | 53 | 33 | 310 | loose |
| Vic Mensa | MILLIONAIRES | 53 | 35 | 258 | loose |
| Vic Mensa | MOOSA | 94 | 64 | 495 | loose |
| Vic Mensa | Made An America - Remix | 26 | 12 | 105 | loose |
| Vic Mensa | Magic | 56 | 32 | 268 | loose |
| Vic Mensa | Major Payne | 36 | 23 | 215 | loose |
| Vic Mensa | Make That Money Girl | 28 | 18 | 46 | loose |
| Vic Mensa | Married To The King Freestyle | 57 | 46 | 291 | loose |
| Vic Mensa | Married to the King | 32 | 29 | 203 | loose |
| Vic Mensa | Memories on 47th St. | 51 | 35 | 318 | loose |
| Vic Mensa | Mercy | 29 | 21 | 99 | loose |
| Vic Mensa | Metaphysical | 33 | 20 | 78 | loose |
| Vic Mensa | Money Clip | 97 | 86 | 747 | loose |
| Vic Mensa | Mood | 41 | 21 | 213 | loose |
| Vic Mensa | MurderFACE | 42 | 22 | 253 | loose |
| Vic Mensa | My Level* | 22 | 9 | 108 | loose |
| Vic Mensa | NIGHT RIDERS | 22 | 7 | 77 | loose |
| Vic Mensa | Naked Pictures | 48 | 20 | 264 | loose |
| Vic Mensa | Neon Guts (Remix) | 74 | 83 | 299 | loose |
| Vic Mensa | New Bae | 51 | 43 | 253 | loose |
| Vic Mensa | Nino’s Lips | 66 | 56 | 453 | loose |
| Vic Mensa | No Bow Wow Challenge | 46 | 26 | 321 | loose |
| Vic Mensa | No Chill | 37 | 29 | 206 | loose |
| Vic Mensa | No Fear | 37 | 35 | 243 | loose |
| Vic Mensa | No Love | 18 | 12 | 66 | loose |
| Vic Mensa | No More Teardrops | 69 | 58 | 322 | loose |
| Vic Mensa | Northstar | 55 | 60 | 238 | loose |
| Vic Mensa | Numbers on the Board (DJ Semtex Freestyle) | 61 | 54 | 309 | loose |
| Vic Mensa | OMG | 61 | 74 | 331 | loose |
| Vic Mensa | Oh No!!! (Remix) | 40 | 25 | 238 | loose |
| Vic Mensa | Orange Soda | 38 | 21 | 197 | loose |
| Vic Mensa | Outta This World | 42 | 24 | 235 | loose |
| Vic Mensa | Over And Over* | 3 | 0 | 0 | loose |
| Vic Mensa | Paradise | 36 | 29 | 133 | loose |
| Vic Mensa | Pasadena | 13 | 9 | 48 | loose |
| Vic Mensa | Pay Back Is A Dog | 57 | 23 | 316 | loose |
| Vic Mensa | Persephone | 29 | 17 | 60 | loose |
| Vic Mensa | Pharoah | 22 | 21 | 69 | loose |
| Vic Mensa | Pick Me Up | 14 | 15 | 29 | loose |
| Vic Mensa | Pouring Rain | 29 | 17 | 228 | loose |
| Vic Mensa | Practice | 44 | 73 | 238 | loose |
| Vic Mensa | REBIRTH | 56 | 44 | 269 | loose |
| Vic Mensa | RUMORS | 14 | 14 | 106 | loose |
| Vic Mensa | RUN! | 40 | 25 | 188 | loose |
| Vic Mensa | Racer | 57 | 86 | 306 | loose |
| Vic Mensa | Radio Silent | 17 | 15 | 140 | loose |
| Vic Mensa | Rage | 62 | 59 | 378 | loose |
| Vic Mensa | RapFix Freestyle | 134 | 115 | 689 | loose |
| Vic Mensa | Red Light Freestyle | 32 | 26 | 210 | loose |
| Vic Mensa | Reverse | 44 | 61 | 367 | loose |
| Vic Mensa | Rich Ghetto Bitch | 53 | 34 | 654 | loose |
| Vic Mensa | Ride or Die | 45 | 30 | 272 | loose |
| Vic Mensa | Right Now | 66 | 47 | 368 | loose |
| Vic Mensa | Ring The Bell | 23 | 13 | 84 | loose |
| Vic Mensa | Rock This Smoove | 31 | 25 | 97 | loose |
| Vic Mensa | Roll My Weed | 50 | 43 | 258 | loose |
| Vic Mensa | Rollin’ Like a Stoner | 29 | 31 | 177 | loose |
| VIC MENSA | Rowdy | 49 | 33 | 171 | loose |
| Vic Mensa | Run to You | 61 | 34 | 339 | loose |
| Vic Mensa | SAVEMONEY Christmas | 117 | 92 | 584 | loose |
| Vic Mensa | SHELTER | 69 | 73 | 373 | loose |
| Vic Mensa | SHIBUYA (GHOST II) | 62 | 66 | 245 | loose |
| Vic Mensa | STRAWBERRY LOUIS VUITTON | 22 | 11 | 111 | loose |
| Vic Mensa | Save Money No Writtens (SXSW Cypher) | 91 | 56 | 255 | loose |
| Vic Mensa | Savemoney Cypher | 87 | 90 | 495 | loose |
| Vic Mensa | Saviour Money | 48 | 38 | 231 | loose |
| Vic Mensa | Scattered | 31 | 28 | 190 | loose |
| Vic Mensa | Sco Wok | 10 | 4 | 20 | loose |
| Vic Mensa | Seppuku | 80 | 95 | 371 | loose |
| Vic Mensa | Shade 45 Freestyle | 49 | 51 | 245 | loose |
| Vic Mensa | Shades of Blue | 62 | 53 | 300 | loose |
| Vic Mensa | Shakedown ’99 | 24 | 5 | 85 | loose |
| Vic Mensa | She Loves The Mirror | 10 | 5 | 48 | loose |
| Vic Mensa | Shotty | 34 | 29 | 163 | loose |
| Vic Mensa | Show You How | 46 | 28 | 167 | loose |
| Vic Mensa | Showoff Radio Freestyle | 130 | 90 | 799 | loose |
| Vic Mensa | Shut Up | 18 | 11 | 57 | loose |
| Vic Mensa | Sing Me a Lullabye | 17 | 10 | 46 | loose |
| Vic Mensa | Sleep Number | 44 | 25 | 189 | loose |
| Vic Mensa | Snippet of There Will Be Tears (Live Remix) | 10 | 4 | 40 | loose |
| Vic Mensa | So Cold | 13 | 0 | 14 | loose |
| Vic Mensa | So Stupid | 37 | 42 | 203 | loose |
| Vic Mensa | Solar Return II | 45 | 28 | 169 | loose |
| Vic Mensa | Staples | 62 | 46 | 395 | loose |
| Vic Mensa | Steamer | 85 | 79 | 504 | loose |
| Vic Mensa | Still Got It | 64 | 22 | 260 | loose |
| Vic Mensa | Stop Looking For This | 20 | 16 | 33 | loose |
| Vic Mensa | Suitcase | 38 | 23 | 264 | loose |
| Vic Mensa | Suitcase Remix | 4 | 0 | 15 | loose |
| Vic Mensa | Summer’s Over | 36 | 35 | 125 | loose |
| Vic Mensa | Sunday Evening Reprise | 25 | 30 | 164 | loose |
| Vic Mensa | Sunday Morning Intro | 31 | 9 | 132 | loose |
| Vic Mensa | Sway In The Morining “A Lot” Freestyle (08/17/2019) | 33 | 16 | 417 | loose |
| Vic Mensa | Sway In The Morning (Grammy Family) 2019 | 61 | 73 | 523 | loose |
| Vic Mensa | Sway In The Morning Freestyle | 155 | 147 | 832 | loose |
| Vic Mensa | Swear | 28 | 18 | 186 | loose |
| Vic Mensa | THE TASTE | 40 | 16 | 173 | loose |
| Vic Mensa | TO THE NIGHT | 32 | 31 | 148 | loose |
| Vic Mensa | TOOK HER TO THE O (FREESTYLE) | 21 | 17 | 185 | loose |
| Vic Mensa | Talk About It (Remix) | 40 | 27 | 199 | loose |
| Vic Mensa | Taxi Cab | 55 | 25 | 387 | loose |
| Vic Mensa | Tell Me | 34 | 35 | 186 | loose |
| Vic Mensa | That Nigga | 56 | 24 | 341 | loose |
| Vic Mensa | That’s My Baby Interlude | 16 | 11 | 17 | loose |
| Vic Mensa | The 1 That Got Away / No Shoes | 43 | 28 | 195 | loose |
| Vic Mensa | The Fire Next Time | 63 | 51 | 292 | loose |
| Vic Mensa | There’s Alot Going On | 87 | 48 | 481 | loose |
| Vic Mensa | Till the World Falls | 28 | 13 | 80 | loose |
| Vic Mensa | Time Is Money | 77 | 80 | 491 | loose |
| Vic Mensa | Too Hard | 53 | 27 | 192 | loose |
| Vic Mensa | Tree | 60 | 64 | 283 | loose |
| Vic Mensa | Tweakin | 61 | 39 | 396 | loose |
| Vic Mensa | U Mad | 59 | 36 | 331 | loose |
| Vic Mensa | Unified | 51 | 85 | 258 | loose |
| Vic Mensa | United States of Evil | 20 | 22 | 36 | loose |
| Vic Mensa | Untitled Live Snippet from University of Cincinnati | 5 | 2 | 26 | loose |
| Vic Mensa | Untitled Snippet | 19 | 11 | 122 | loose |
| Vic Mensa | Untitled Snippets 3 | 23 | 23 | 146 | loose |
| Vic Mensa | VENDETTA | 68 | 58 | 494 | loose |
| Vic Mensa | VIC MENSA | Funk Flex | #Freestyle071 | 84 | 90 | 587 | loose |
| Vic Mensa | VICTORY | 55 | 66 | 320 | loose |
| Vic Mensa | Vertical | 55 | 49 | 283 | loose |
| Vic Mensa | Vibration | 61 | 61 | 279 | loose |
| Vic Mensa | Vic Chops Soul | 49 | 40 | 366 | loose |
| Vic Mensa | Vic Mensa Freestyle (2017) | LA Leakers Freestyle #016 | 53 | 46 | 297 | loose |
| Vic Mensa | Vic Mensa Freestyle (2018) | LA Leakers Freestyle #047 | 49 | 42 | 369 | loose |
| Vic Mensa | Vic Mensa Freestyle | LA Leakers Freestyle #067 | 66 | 78 | 623 | loose |
| Vic Mensa | Vic Mensa Freestyle | LA Leakers Freestyle #113 | 219 | 202 | 1363 | loose |
| Vic Mensa | Vic Mensa Freestyle | LA Leakers Freestyle #164 | 152 | 150 | 781 | loose |
| Vic Mensa | Vic Mensa Spazzes in 15 Minute Freestyle on Sway In the Morning Beat 1 | 196 | 212 | 1939 | loose |
| Vic Mensa | Vic Mensa Sway in the Morning Freestyle 2017 | 61 | 62 | 492 | loose |
| Vic Mensa | Vic Mensa on The Come Up Show | 37 | 30 | 228 | loose |
| Vic Mensa | Victor | 38 | 45 | 291 | loose |
| Vic Mensa | WINNERS CIRCLE | 76 | 58 | 425 | loose |
| Vic Mensa | WORK | 37 | 49 | 185 | loose |
| Vic Mensa | WWYD | 36 | 21 | 108 | loose |
| Vic Mensa | Wake Up | 15 | 8 | 53 | loose |
| Vic Mensa | Warm Up Sessions Freestyle | 48 | 37 | 410 | loose |
| Vic Mensa | Washington | 17 | 18 | 141 | loose |
| Vic Mensa | Wasting Time | 39 | 40 | 265 | loose |
| Vic Mensa | Waves | 19 | 9 | 104 | loose |
| Vic Mensa | We Could Be Free | 66 | 46 | 277 | loose |
| Vic Mensa | We Don’t Need You | 23 | 26 | 102 | loose |
| Vic Mensa | Weeping Poets | 47 | 25 | 317 | loose |
| Vic Mensa | Welcome To INNANET | 55 | 41 | 411 | loose |
| Vic Mensa | What It Takes | 54 | 103 | 152 | loose |
| Vic Mensa | When A Fire Starts To Burn (Freestyle) | 67 | 47 | 246 | loose |
| Vic Mensa | Whispers | 103 | 119 | 442 | loose |
| Vic Mensa | Wild ’N Out Wildstyle | 46 | 27 | 312 | loose |
| Vic Mensa | Wildstyle #502 | 29 | 18 | 239 | loose |
| Vic Mensa | Will to Survive | 48 | 40 | 382 | loose |
| Vic Mensa | Wimme Nah | 53 | 43 | 249 | loose |
| Vic Mensa | Wings | 50 | 48 | 335 | loose |
| Vic Mensa | Winning | 63 | 61 | 271 | loose |
| Vic Mensa | Wolves | 59 | 30 | 180 | loose |
| Vic Mensa | Wraith | 65 | 108 | 263 | loose |
| Vic Mensa | XGAMES | 59 | 65 | 332 | loose |
| Vic Mensa | XXL Freshman Freestyle | 10 | 6 | 40 | loose |
| Vic Mensa | XXL Freshmen 2014 Cypher - Part 1 | 74 | 67 | 536 | loose |
| Vic Mensa | YNSP | 63 | 34 | 266 | loose |
| Vic Mensa | Yacht | 47 | 28 | 192 | loose |
| Vic Mensa | Yap Yap | 27 | 25 | 137 | loose |
| Vic Mensa | You Don’t Know Me | 8 | 4 | 12 | loose |
| Vic Mensa | You Keep Me Waiting | 35 | 41 | 162 | loose |
| Vic Mensa | Zion | 23 | 16 | 157 | loose |
| Vic Mensa | Zion - 170811 | 15 | 11 | 88 | loose |
| Vic Mensa | Zombie | 21 | 8 | 22 | loose |
| Vic Mensa | [commercial break] | 11 | 3 | 87 | loose |
| Vic Mensa | all i kno | 41 | 22 | 173 | loose |
| Vic Mensa | definition of a fuck-boi | 26 | 10 | 131 | loose |
| Vic Mensa | falling | 57 | 44 | 264 | loose |
| Vic Mensa | it’s a bad dream | 44 | 53 | 260 | loose |
| Vic Mensa | melting clocks | 91 | 35 | 326 | loose |
| Vic Mensa | numb | 26 | 25 | 47 | loose |
| Vic Mensa | still with the smoke | 43 | 33 | 152 | loose |
| Vic Mensa | sunset on the low end | 45 | 30 | 308 | loose |
| Vic Mensa | the word | 47 | 61 | 394 | loose |
| Vic Mensa | unfuckingfortunately! | 23 | 8 | 139 | loose |
| Vic Mensa | ‘Commas’ L.A. Leakers Freestyle | 48 | 31 | 347 | loose |
| Vic Mensa | ‘Save Money Summer’ LA Leakers Freestyle | 53 | 42 | 186 | loose |
| Vic Mensa | ‘Seminal Bars’ Freestyle | 69 | 77 | 473 | loose |
| Vic Mensa | “What You Taught Us” | 22 | 13 | 173 | loose |
