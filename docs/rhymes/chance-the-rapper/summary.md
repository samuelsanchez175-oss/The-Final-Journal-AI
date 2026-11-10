# Chance the Rapper rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Chance the Rapper
- Songs: 465
- Bars kept (Chance the Rapper lyric lines): 19942
- Section headers dropped, not counted as bars: 4
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 28
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 27
- Canonical name: Chance the Rapper.
- Credit strings: Chance the Rapper.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 113932
- REPEAT pairs, recorded separately: 16450
- END rhymes: 17153
- INNER rhymes: 96779

By match:

- PERFECT: 10558 (END 2932, INNER 7626)
- SLANT: 45154 (END 6883, INNER 38271)
- ASSONANCE: 56632 (END 6983, INNER 49649)
- MULTI: 1588 (END 355, INNER 1233)

By confidence:

- HIGH: 11098
- MED: 97090
- LOW: 5744

## Core

- Core Y: 111855
- Core N among rhyme pairs: 2077

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 51056 (44.8%)
- vowel: 56632 (49.7%)
- spelling: 4656 (4.1%)
- multi: 1588 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- loose: 464 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 8270 pairs (END 978, INNER 7292). Words: don't, know, no, go, only, told, show, hold.
2. `vow:IH` — 7533 pairs (END 720, INNER 6813). Words: shit, think, still, little, bitch, big, kids, christmas.
3. `vow:EH` — 7516 pairs (END 639, INNER 6877). Words: when, get, never, friends, best, left, said, remember.
4. `vow:AE` — 6530 pairs (END 906, INNER 5624). Words: back, can't, chance, had, have, can, last, hands.
5. `vow:EY` — 5859 pairs (END 800, INNER 5059). Words: ain't, say, way, make, day, take, play, baby.
6. `vow:AY` — 4641 pairs (END 719, INNER 3922). Words: like, why, time, by, high, find, mind, try.
7. `vow:IY` — 4123 pairs (END 537, INNER 3586). Words: see, even, need, keep, these, free, feel, streets.
8. `vow:AA` — 4036 pairs (END 460, INNER 3576). Words: got, want, not, hard, wanna, god, cause, gotta.
9. `vow:AH` — 3559 pairs (END 414, INNER 3145). Words: love, what, what's, some, one, come, fuck, something.
10. `slant:AA:stop` — 1788 pairs (END 247, INNER 1541). Words: got, gotta, not, want, god, top, stop, rock.
11. `slant:AE:stop` — 1472 pairs (END 282, INNER 1190). Words: back, had, can't, rap, black, bad, rapper, bag.
12. `vow:AO` — 1441 pairs (END 209, INNER 1232). Words: all, more, lost, call, talking, fall, wanted, song.
13. `slant:IH:stop` — 1402 pairs (END 187, INNER 1215). Words: shit, nigga, big, hit, dick, city, crib, whip.
14. `cmu:OW` — 1351 pairs (END 225, INNER 1126). Words: know, no, go, show, though, o, low, slow.
15. `vow:UW` — 1336 pairs (END 200, INNER 1136). Words: used, new, who, through, two, school, music, use.
16. `slant:AY:stop` — 1302 pairs (END 180, INNER 1122). Words: like, right, ride, side, night, light, might, inside.
17. `slant:EH:stop` — 1182 pairs (END 122, INNER 1060). Words: get, better, said, let, left, best, head, went.
18. `slant:AE:nas-stop` — 1153 pairs (END 107, INNER 1046). Words: can, man, back, had, can't, damn, plan, bad.
19. `slant:EH:liq-stop` — 1014 pairs (END 78, INNER 936). Words: get, tell, where, there, said, let, better, well.
20. `slant:EH:nas-stop` — 991 pairs (END 49, INNER 942). Words: when, get, again, let, said, better, em, getting.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 495 pair sides, mostly spelling via spelling phonetic key, often with niggas (104)
- gon — 294 pair sides, mostly spelling via spelling phonetic key, often with dont (77)
- ima — 251 pair sides, mostly spelling via spelling phonetic key, often with shit (19)
- niggas — 248 pair sides, mostly spelling via spelling phonetic key, often with nigga (104)
- tryna — 240 pair sides, mostly spelling via spelling phonetic key, often with keep (17)
- chano — 136 pair sides, mostly spelling via spelling phonetic key, often with no (10)
- finna — 58 pair sides, mostly spelling via spelling phonetic key, often with niggas (8)
- quando — 53 pair sides, mostly vowel via spelling phonetic key, often with o (13)
- henny — 50 pair sides, mostly vowel via spelling phonetic key, often with shawty (3)
- shawty — 49 pair sides, mostly vowel via spelling phonetic key, often with baby (6)
- fam — 47 pair sides, mostly spelling via spelling phonetic key, often with man (5)
- icky — 41 pair sides, mostly vowel via spelling phonetic key, often with trippy (6)
- isso — 41 pair sides, mostly vowel via spelling phonetic key, often with o (9)
- kanye — 37 pair sides, mostly spelling via spelling phonetic key, often with man (4)
- gajo — 34 pair sides, mostly vowel via spelling phonetic key, often with o (8)
- imma — 30 pair sides, mostly vowel via spelling phonetic key, often with niggas (7)
- homies — 30 pair sides, mostly spelling via spelling phonetic key, often with hoodies (4)
- cuando — 25 pair sides, mostly vowel via spelling phonetic key, often with un (6)
- sem — 25 pair sides, mostly spelling via spelling phonetic key, often with n (6)
- veio — 23 pair sides, mostly vowel via spelling phonetic key, often with o (5)
- cuz — 22 pair sides, mostly spelling via spelling phonetic key, often with come (4)
- dolo — 21 pair sides, mostly vowel via spelling phonetic key, often with solo (7)
- prolly — 20 pair sides, mostly vowel via spelling phonetic key, often with body (2)
- dyin — 20 pair sides, mostly spelling via spelling phonetic key, often with these (3)
- eles — 20 pair sides, mostly spelling via spelling phonetic key, often with s (8)
- homie — 18 pair sides, mostly spelling via spelling phonetic key, often with gon (3)
- hella — 18 pair sides, mostly spelling via spelling phonetic key, often with yelling (1)
- bino — 18 pair sides, mostly vowel via spelling phonetic key, often with know (4)
- eso — 18 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- fosho — 18 pair sides, mostly vowel via spelling phonetic key, often with go (4)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Chance the Rapper | $WISH | 50 | 32 | 298 | loose |
| Chance the Rapper | 1.NO ISSUES | 58 | 65 | 364 | loose |
| Chance the Rapper | 10PM in THISTLE DRIVE (Freestyle) | 37 | 14 | 372 | loose |
| Chance the Rapper | 14,400 Minutes | 24 | 16 | 130 | loose |
| Chance the Rapper | 2014 Freestyle | 27 | 12 | 64 | loose |
| Chance the Rapper | 2017 Emmy Awards Opening Song | 44 | 42 | 282 | loose |
| Chance the Rapper | 22 Offs | 25 | 20 | 157 | loose |
| Chance the Rapper | 3333 | 40 | 41 | 152 | loose |
| Chance the Rapper | 4 Quarters in the Black (Skit) | 45 | 9 | 110 | loose |
| Chance the Rapper | 5 Year Plan | 68 | 79 | 300 | loose |
| Chance the Rapper | 65th & Ingleside | 57 | 81 | 313 | loose |
| Chance the Rapper | A Bar About a Bar | 19 | 22 | 110 | loose |
| Chance the Rapper | ACAB | 47 | 96 | 363 | loose |
| Chance the Rapper | Acid Rain | 57 | 41 | 293 | loose |
| Chance the Rapper | Acid Rain Remix | 26 | 27 | 169 | loose |
| Chance the Rapper | All Day Long | 50 | 57 | 199 | loose |
| Chance the Rapper | All My Friends | 37 | 15 | 134 | loose |
| Chance the Rapper | All Night | 36 | 9 | 180 | loose |
| Chance the Rapper | All That* | 16 | 6 | 30 | loose |
| Chance the Rapper | All We Got | 38 | 39 | 98 | loose |
| Chance the Rapper | All the Way | 48 | 58 | 91 | loose |
| Chance the Rapper | Ambitious | 41 | 32 | 277 | loose |
| Chance the Rapper | Amen BASED FREESTYLE | 123 | 72 | 290 | loose |
| Chance the Rapper | And They Say | 36 | 24 | 122 | loose |
| Chance the Rapper | Angels | 48 | 46 | 274 | loose |
| Chance the Rapper | Anxiety (Chance the Rapper Reference) | 4 | 0 | 9 | loose |
| Chance the Rapper | Are U Live | 60 | 83 | 166 | loose |
| Chance the Rapper | Atlanta House Freestyle | 93 | 131 | 535 | loose |
| Chance the Rapper | BET Uncut | 58 | 77 | 268 | loose |
| Chance the Rapper | Baby Blue | 55 | 34 | 284 | loose |
| Chance the Rapper | Baby Mama | 51 | 54 | 155 | loose |
| Chance the Rapper | Back Here Again* | 23 | 35 | 98 | loose |
| Chance the Rapper | Back To The Go | 60 | 50 | 501 | loose |
| Chance the Rapper | Bad 4 You | 50 | 39 | 216 | loose |
| Chance the Rapper | Bad Boys 2 | 46 | 62 | 378 | loose |
| Chance the Rapper | Bad Idea | 50 | 53 | 433 | loose |
| Chance the Rapper | Bad Kids (Dead Beats) | 24 | 39 | 217 | loose |
| Chance the Rapper | Ballin Flossin | 45 | 34 | 115 | loose |
| Chance the Rapper | Barbie Doll | 42 | 66 | 262 | loose |
| Chance the Rapper | Baskets | 26 | 21 | 67 | loose |
| Chance the Rapper | Beautiful Chicago (Based Freestyle) | 71 | 55 | 201 | loose |
| Chance the Rapper | Beddy Bye | 35 | 24 | 203 | loose |
| Chance the Rapper | Best Life | 67 | 73 | 455 | loose |
| Chance the Rapper | Better Move (Jozzy Reference) | 22 | 10 | 48 | loose |
| Chance the Rapper | Big B’s | 68 | 62 | 450 | loose |
| Chance the Rapper | Big Fish | 40 | 35 | 303 | loose |
| Chance the Rapper | Big Kid Again | 35 | 27 | 164 | loose |
| Chance the Rapper | Bikini Bottom | 35 | 44 | 206 | loose |
| Chance the Rapper | Bitch Like* | 13 | 6 | 16 | loose |
| Chance the Rapper | Black Men Don’t Cheat | 27 | 20 | 71 | loose |
| Chance the Rapper | Black Santa | 40 | 44 | 185 | loose |
| Chance the Rapper | Bless Them All | 38 | 25 | 169 | loose |
| Chance the Rapper | Blessing (freestyle) | 34 | 32 | 182 | loose |
| Chance the Rapper | Blessings | 29 | 24 | 229 | loose |
| Chance the Rapper | Bombay State of Mind | 103 | 80 | 406 | loose |
| Chance the Rapper | Bombs Away* | 85 | 73 | 216 | loose |
| Chance the Rapper | Bonnaroo Freestyle (2015) | 49 | 33 | 236 | loose |
| Chance the Rapper | Bout A Dolla | 74 | 52 | 485 | loose |
| Chance the Rapper | Brain Cells | 64 | 56 | 407 | loose |
| Chance the Rapper | Brain Cells Live | 24 | 12 | 132 | loose |
| Chance the Rapper | Breaking Up | 9 | 3 | 13 | loose |
| Chance the Rapper | Broad Shoulders | 53 | 67 | 373 | loose |
| Chance the Rapper | Buried Alive | 42 | 61 | 209 | loose |
| Chance the Rapper | Burn Ya Block | 30 | 43 | 150 | loose |
| Chance the Rapper | CNN | 6 | 3 | 28 | loose |
| Chance the Rapper | CRAZY FA LOVE | 26 | 14 | 126 | loose |
| Chance the Rapper | Chain Smoker | 42 | 31 | 183 | loose |
| Chance the Rapper | Chance The Rapper Vibin With Einer Bankz At Coachella | 30 | 18 | 83 | loose |
| Chance the Rapper | Chance The Rapper’s #SoGoneChallenge | 19 | 19 | 150 | loose |
| Chance the Rapper | Chance The Wrapper | 6 | 0 | 7 | loose |
| Chance the Rapper | Chance the Rapper Freestyle on Sway in the Morning | 61 | 43 | 251 | loose |
| Chance the Rapper | Chance the Rapper and Donnie Trumpet Interview on The Breakfast Club | 25 | 8 | 117 | loose |
| Chance the Rapper | Chano (Mr. #1 Dubplate) | 23 | 9 | 80 | loose |
| Chance the Rapper | Chi - Town Christmas | 34 | 17 | 113 | loose |
| Chance the Rapper | Chicago | 13 | 6 | 68 | loose |
| Chance the Rapper | Child of God | 44 | 65 | 336 | loose |
| Chance the Rapper | Childs Play | 39 | 16 | 118 | loose |
| Chance the Rapper | Church | 36 | 45 | 246 | loose |
| Chance the Rapper | Clean Up | 41 | 44 | 151 | loose |
| Chance the Rapper | Coast is Clear | 19 | 3 | 65 | loose |
| Chance the Rapper | Cocao Butter Kisses | 13 | 3 | 60 | loose |
| Chance the Rapper | Cocoa Butter Kisses | 66 | 50 | 423 | loose |
| Chance the Rapper | Cold Stares | 26 | 9 | 98 | loose |
| Chance the Rapper | Come Back, Barack | 45 | 22 | 143 | loose |
| Chance the Rapper | Coming For Your Spot | 30 | 13 | 215 | loose |
| Chance the Rapper | Confident | 48 | 24 | 160 | loose |
| Chance the Rapper | Conundrum | 83 | 95 | 229 | loose |
| Chance the Rapper | Count Me Out | 45 | 59 | 157 | loose |
| Chance the Rapper | Cross Me | 46 | 39 | 114 | loose |
| Chance the Rapper | Cross Roads | 72 | 93 | 388 | loose |
| Chance the Rapper | Cruisin’ | 21 | 8 | 64 | loose |
| Chance the Rapper | Cuba (Instagram Song 4) | 28 | 22 | 156 | loose |
| Chance the Rapper | D.R.A.M. Sings Special | 3 | 0 | 3 | loose |
| Chance the Rapper | DREAM. A poem by Reaux Marquez | 23 | 7 | 322 | loose |
| Chance the Rapper | Day 3 (SXSW Cypher) | 137 | 124 | 533 | loose |
| Chance the Rapper | Dear Chicago Summer | 38 | 16 | 207 | loose |
| Chance the Rapper | Dear Theodosia (Reprise) | 33 | 20 | 103 | loose |
| Chance the Rapper | Do My Dance BASED FREESTYLE | 97 | 65 | 391 | loose |
| Chance the Rapper | Do You Believe | 21 | 27 | 57 | loose |
| Chance the Rapper | Do You Remember | 33 | 35 | 165 | loose |
| Chance the Rapper | Doctor Oz | 50 | 68 | 283 | loose |
| Chance the Rapper | Don’t Wait (Remix) | 35 | 25 | 131 | loose |
| Chance the Rapper | Dope25 | 30 | 29 | 102 | loose |
| Chance the Rapper | Down Wit That | 33 | 22 | 158 | loose |
| Chance the Rapper | Drapetomania | 47 | 44 | 425 | loose |
| Chance the Rapper | Drinkin’ | 19 | 8 | 64 | loose |
| Chance the Rapper | Drowsiness | 61 | 39 | 173 | loose |
| Chance the Rapper | Ecstasy (Remix) | 48 | 26 | 168 | loose |
| Chance the Rapper | Eternal | 56 | 52 | 284 | loose |
| Chance the Rapper | Eucalyptus | 3 | 0 | 9 | loose |
| Chance the Rapper | Everybody’s Something | 55 | 72 | 255 | loose |
| Chance the Rapper | Everything (Remix) | 52 | 32 | 303 | loose |
| Chance the Rapper | Everything New | 41 | 64 | 235 | loose |
| Chance the Rapper | Everything’s Good (Good Ass Outro) | 49 | 34 | 252 | loose |
| Chance the Rapper | Extra Special Listener | 24 | 28 | 123 | loose |
| Chance the Rapper | Fam and Foolies | 42 | 29 | 305 | loose |
| Chance the Rapper | Familiar | 52 | 40 | 192 | loose |
| Chance the Rapper | Family | 51 | 61 | 336 | loose |
| Chance the Rapper | Family For | 42 | 31 | 216 | loose |
| Chance the Rapper | Family Matters | 22 | 14 | 71 | loose |
| Chance the Rapper | Famous | 36 | 27 | 96 | loose |
| Chance the Rapper | Fat Fingers | 42 | 25 | 206 | loose |
| Chance the Rapper | Father Stretch My Hands, Pt. 1 | 23 | 8 | 52 | loose |
| Chance the Rapper | Favorite Song | 49 | 47 | 364 | loose |
| Chance the Rapper | Fear | 123 | 106 | 271 | loose |
| Chance the Rapper | Feedback | 35 | 34 | 143 | loose |
| Chance the Rapper | Feel No Ways | 41 | 33 | 132 | loose |
| Chance the Rapper | Fernet con coca | 23 | 8 | 153 | loose |
| Chance the Rapper | Fight for You | 37 | 22 | 97 | loose |
| Chance the Rapper | Fight or Flight (Remix) | 76 | 81 | 531 | loose |
| Chance the Rapper | Finish Line / Drown | 69 | 37 | 283 | loose |
| Chance the Rapper | First Cypher Round | 35 | 39 | 164 | loose |
| Chance the Rapper | First Day Out | 37 | 42 | 198 | loose |
| Chance the Rapper | First Mixtape BASED FREESTYLE | 100 | 55 | 632 | loose |
| Chance the Rapper | First World Problems | 64 | 55 | 404 | loose |
| Chance the Rapper | Fix You | 13 | 5 | 25 | loose |
| Chance the Rapper | Fool Wit It Freestyle | 53 | 34 | 288 | loose |
| Chance the Rapper | For Marah, Juke Jam | 35 | 9 | 56 | loose |
| Chance the Rapper | Forever Always | 31 | 18 | 137 | loose |
| Chance the Rapper | Found You | 36 | 52 | 156 | loose |
| Chance the Rapper | Found a Good One (Single No More) | 38 | 21 | 129 | loose |
| Chance the Rapper | Freeee (Ghost Town, Pt. 2) (Chance Version) | 4 | 5 | 17 | loose |
| Chance the Rapper | Freestyle (Raincoat) | 32 | 37 | 160 | loose |
| Chance the Rapper | Friendship Heights | 32 | 19 | 181 | loose |
| Chance the Rapper | Frog (The Come Up Freestyle) | 24 | 20 | 148 | loose |
| Chance the Rapper | Fuck You | 18 | 17 | 135 | loose |
| Chance the Rapper | Fuck You All the Time (Extended) | 33 | 29 | 132 | loose |
| Chance the Rapper | Fuck You Tahm Bout | 63 | 51 | 228 | loose |
| Chance the Rapper | Fuck Y’all | 37 | 38 | 218 | loose |
| Chance the Rapper | GIRLS @ | 53 | 40 | 221 | loose |
| Chance the Rapper | GOODBYE (Remix) | 39 | 36 | 179 | loose |
| Chance the Rapper | GOSPEL | 59 | 66 | 322 | loose |
| Chance the Rapper | GRoCERIES | 37 | 35 | 158 | loose |
| Chance the Rapper | Gentleman | 36 | 24 | 160 | loose |
| Chance the Rapper | Get a Bag | 38 | 33 | 221 | loose |
| Chance the Rapper | Gimmie A Call | 35 | 31 | 162 | loose |
| Chance the Rapper | Girl in Town | 41 | 36 | 129 | loose |
| Chance the Rapper | Give and Take | 49 | 46 | 323 | loose |
| Chance the Rapper | Glam | 35 | 29 | 236 | loose |
| Chance the Rapper | Gloria | 29 | 14 | 92 | loose |
| Chance the Rapper | Going Back | 55 | 86 | 311 | loose |
| Chance the Rapper | Good Ass Intro | 47 | 23 | 317 | loose |
| Chance the Rapper | Good Ass Job* | 3 | 2 | 8 | loose |
| Chance the Rapper | Good Enough | 50 | 35 | 163 | loose |
| Chance the Rapper | Good Shit Roses | 41 | 27 | 158 | loose |
| Chance the Rapper | Greenlight | 45 | 59 | 187 | loose |
| Chance the Rapper | Grind Like Me | 49 | 39 | 312 | loose |
| Chance the Rapper | Grown Ass Kid | 91 | 47 | 654 | loose |
| Chance the Rapper | Grown Up Fairy Tales | 79 | 120 | 398 | loose |
| Chance the Rapper | Gucci Pajamas | 42 | 34 | 208 | loose |
| Chance the Rapper | Gun In Yo Purse | 61 | 63 | 214 | loose |
| Chance the Rapper | Handsome | 43 | 31 | 178 | loose |
| Chance the Rapper | Haterz Remix | 33 | 31 | 153 | loose |
| Chance the Rapper | Heaven Only Knows | 45 | 23 | 196 | loose |
| Chance the Rapper | Held It Down | 43 | 51 | 120 | loose |
| Chance the Rapper | Hello | 103 | 100 | 512 | loose |
| Chance the Rapper | Helmet | 8 | 5 | 24 | loose |
| Chance the Rapper | Hey Ma | 62 | 51 | 300 | loose |
| Chance the Rapper | Hiatus (Broadcast) | 21 | 24 | 149 | loose |
| Chance the Rapper | Higher | 62 | 74 | 231 | loose |
| Chance the Rapper | Holy | 40 | 25 | 198 | loose |
| Chance the Rapper | Home | 93 | 92 | 700 | loose |
| Chance the Rapper | Home Again | 48 | 44 | 269 | loose |
| Chance the Rapper | Home Studio (Back Up In This Bitch) | 25 | 15 | 81 | loose |
| Chance the Rapper | Hometown | 46 | 28 | 293 | loose |
| Chance the Rapper | Hot Shower | 70 | 58 | 286 | loose |
| Chance the Rapper | Hot Shower - Kaya’s Birthday Remix | 28 | 7 | 94 | loose |
| Chance the Rapper | House Of Kicks Theme Song | 11 | 6 | 67 | loose |
| Chance the Rapper | How Great | 66 | 50 | 444 | loose |
| Chance the Rapper | I Ain’t Word | 61 | 50 | 194 | loose |
| Chance the Rapper | I Am Very Very Lonely | 16 | 10 | 94 | loose |
| Chance the Rapper | I Got You (Always and Forever) | 55 | 70 | 268 | loose |
| Chance the Rapper | I Love You | 27 | 14 | 105 | loose |
| Chance the Rapper | I Love You So Much | 44 | 12 | 89 | loose |
| Chance the Rapper | I Might Need Security | 51 | 35 | 299 | loose |
| Chance the Rapper | I Told You So | 6 | 4 | 23 | loose |
| Chance the Rapper | I Want It That Way (Remix) | 17 | 15 | 75 | loose |
| Chance the Rapper | I Want What I Want | 37 | 30 | 195 | loose |
| Chance the Rapper | I Was a Rock (Muhammad Ali ESPYs Tribute) | 33 | 10 | 75 | loose |
| Chance the Rapper | I Will Be Your | 53 | 51 | 252 | loose |
| Chance the Rapper | I. The Worst Guys | 36 | 24 | 175 | loose |
| Chance the Rapper | Iconic | 41 | 23 | 177 | loose |
| Chance the Rapper | Idea | 35 | 23 | 73 | loose |
| Chance the Rapper | In My Place | 28 | 15 | 142 | loose |
| Chance the Rapper | In The Pen Dance | 34 | 23 | 138 | loose |
| Chance the Rapper | Instagram Song 1 (Mr. Perfect) | 30 | 62 | 139 | loose |
| Chance the Rapper | Instagram Song 2 | 13 | 13 | 73 | loose |
| Chance the Rapper | Instagram Song 3 | 18 | 16 | 166 | loose |
| Chance the Rapper | Instagram Song 4 (Cuba) | 34 | 27 | 197 | loose |
| Chance the Rapper | Instagram Song 5 | 16 | 16 | 103 | loose |
| Chance the Rapper | Instagram Song 6 | 30 | 22 | 45 | loose |
| Chance the Rapper | Instagram Song 7 (Gun or God) | 28 | 27 | 238 | loose |
| Chance the Rapper | Instagram Song 8 (CWYN) | 66 | 63 | 448 | loose |
| Chance the Rapper | Interlude (That’s Love) | 27 | 18 | 148 | loose |
| Chance the Rapper | Internet Explorer | 28 | 29 | 172 | loose |
| Chance the Rapper | Israel (Sparring) | 63 | 61 | 413 | loose |
| Chance the Rapper | I’m Not Crazy, Life Is | 49 | 42 | 272 | loose |
| Chance the Rapper | I’m Your Santa | 52 | 36 | 148 | loose |
| Chance the Rapper | I’m on 4.0 | 129 | 130 | 844 | loose |
| Chance the Rapper | I’m the One | 51 | 40 | 269 | loose |
| Chance the Rapper | I’m the One Parody | 51 | 35 | 231 | loose |
| Chance the Rapper | JLIG / Just Landed In Ghana | 13 | 16 | 20 | loose |
| Chance the Rapper | Jingle Barack | 37 | 27 | 219 | loose |
| Chance the Rapper | Johnny Dang* | 14 | 9 | 66 | loose |
| Chance the Rapper | Joy | 35 | 25 | 189 | loose |
| Chance the Rapper | Judas | 48 | 41 | 349 | loose |
| Chance the Rapper | Juice | 54 | 36 | 258 | loose |
| Chance the Rapper | Juke Jam | 27 | 10 | 125 | loose |
| Chance the Rapper | Juke Juke | 39 | 23 | 134 | loose |
| Chance the Rapper | Juke Or Treat | 9 | 2 | 7 | loose |
| Chance the Rapper | Just A Drop | 40 | 37 | 151 | loose |
| Chance the Rapper | Just Wait | 10 | 1 | 27 | loose |
| Chance the Rapper | K-Swiss | 14 | 8 | 38 | loose |
| Chance the Rapper | Kick Back | 45 | 35 | 237 | loose |
| Chance the Rapper | LOGOUT | 39 | 48 | 287 | loose |
| Chance the Rapper | LOW SODIUM | 71 | 45 | 281 | loose |
| Chance the Rapper | LSD | 48 | 30 | 193 | loose |
| Chance the Rapper | Lady Friend | 25 | 9 | 30 | loose |
| Chance the Rapper | Last Dance BASED FREESTYLE | 73 | 59 | 322 | loose |
| Chance the Rapper | Let It Snow | 46 | 52 | 161 | loose |
| Chance the Rapper | Let Me Bang | 21 | 10 | 76 | loose |
| Chance the Rapper | Letters | 88 | 82 | 391 | loose |
| Chance the Rapper | Let’s Go on the Run | 47 | 66 | 195 | loose |
| Chance the Rapper | Life Round Here (Remix) | 32 | 13 | 157 | loose |
| Chance the Rapper | Lift Up | 33 | 23 | 106 | loose |
| Chance the Rapper | Light It Up (Demo) | 10 | 2 | 24 | loose |
| Chance the Rapper | Lil Bit (Interlude) | 63 | 79 | 378 | loose |
| Chance the Rapper | Link Me In The Future | 38 | 49 | 317 | loose |
| Chance the Rapper | Living Single | 57 | 37 | 396 | loose |
| Chance the Rapper | Livin’ in Vain | 41 | 35 | 138 | loose |
| Chance the Rapper | Lonely Thoughts | 87 | 71 | 503 | loose |
| Chance the Rapper | Long Night | 57 | 50 | 307 | loose |
| Chance the Rapper | Long Time | 40 | 45 | 262 | loose |
| Chance the Rapper | Long Time Part 2 | 27 | 23 | 141 | loose |
| Chance the Rapper | Lord Release | 57 | 45 | 399 | loose |
| Chance the Rapper | Lost | 34 | 25 | 160 | loose |
| Chance the Rapper | Love Song | 52 | 62 | 214 | loose |
| Chance the Rapper | Make A Hit | 67 | 36 | 205 | loose |
| Chance the Rapper | Make a Pose Don xhoni Cover | 21 | 12 | 62 | loose |
| Chance the Rapper | May I Have This Dance (Remix) | 24 | 8 | 59 | loose |
| Chance the Rapper | Me And My Friends | 22 | 13 | 156 | loose |
| Chance the Rapper | Meet Me at the Door | 43 | 44 | 132 | loose |
| Chance the Rapper | Merry Christmas Lil’ Mama | 27 | 20 | 88 | loose |
| Chance the Rapper | Miracle | 34 | 13 | 194 | loose |
| Chance the Rapper | Missing You | 34 | 27 | 207 | loose |
| Chance the Rapper | Mixtape | 69 | 53 | 308 | loose |
| Chance the Rapper | Money Shower | 51 | 42 | 161 | loose |
| Chance the Rapper | Mo’ Purrp | 37 | 32 | 330 | loose |
| Chance the Rapper | Ms. Parker | 36 | 24 | 110 | loose |
| Chance the Rapper | My Own Thing | 32 | 19 | 146 | loose |
| Chance the Rapper | My Peak | 38 | 37 | 213 | loose |
| Chance the Rapper | NaNa | 51 | 56 | 274 | loose |
| Chance the Rapper | NaNa Live at Truth Studios (Third Verse) | 20 | 11 | 90 | loose |
| Chance the Rapper | NaNa Live in the Studio | 33 | 17 | 210 | loose |
| Chance the Rapper | National Geographical | 53 | 41 | 247 | loose |
| Chance the Rapper | Navigator Truck | 38 | 32 | 141 | loose |
| Chance the Rapper | Need to Know | 54 | 54 | 286 | loose |
| Chance the Rapper | Nina Chop (Chance The Rapper Version) | 17 | 21 | 88 | loose |
| Chance the Rapper | No Better Blues | 41 | 26 | 221 | loose |
| Chance the Rapper | No Brainer | 47 | 32 | 130 | loose |
| Chance the Rapper | No Idea | 37 | 25 | 171 | loose |
| Chance the Rapper | No More Old Men | 56 | 47 | 311 | loose |
| Chance the Rapper | No One Outside | 48 | 49 | 282 | loose |
| Chance the Rapper | No Problem | 70 | 44 | 282 | loose |
| Chance the Rapper | Nobody* | 31 | 22 | 201 | loose |
| Chance the Rapper | Nostalgia | 45 | 30 | 298 | loose |
| Chance the Rapper | Not Sober (Freestyle) | 27 | 16 | 69 | loose |
| Chance the Rapper | Nothing’s Impossible | 22 | 18 | 112 | loose |
| Chance the Rapper | NvrSayNvr | 25 | 27 | 71 | loose |
| Chance the Rapper | OOPS (Original) | 33 | 46 | 174 | loose |
| Chance the Rapper | OVERCOMER | 50 | 51 | 209 | loose |
| Chance the Rapper | On BET Tour Freestyle | 8 | 9 | 13 | loose |
| Chance the Rapper | One More Cry | 60 | 60 | 372 | loose |
| Chance the Rapper | Orange Soda | 38 | 21 | 197 | loose |
| Chance the Rapper | Origami | 80 | 68 | 389 | loose |
| Chance the Rapper | Our House (Skit) | 13 | 1 | 54 | loose |
| Chance the Rapper | Out of Sight | 26 | 15 | 82 | loose |
| Chance the Rapper | Out the Water | 52 | 43 | 272 | loose |
| Chance the Rapper | PTSD | 59 | 68 | 329 | loose |
| Chance the Rapper | PUNCH-A-THON | 4 | 1 | 10 | loose |
| Chance the Rapper | Pass Dat (Remix) | 63 | 31 | 169 | loose |
| Chance the Rapper | Penthouse Floor | 54 | 42 | 151 | loose |
| Chance the Rapper | Photo Ops (Skit) | 20 | 5 | 66 | loose |
| Chance the Rapper | Planez (Remix) | 53 | 19 | 256 | loose |
| Chance the Rapper | Poor | 27 | 13 | 22 | loose |
| Chance the Rapper | Pray for Real | 39 | 56 | 271 | loose |
| Chance the Rapper | Pretty | 40 | 29 | 171 | loose |
| Chance the Rapper | Prisoner | 43 | 33 | 149 | loose |
| Chance the Rapper | Prom Night | 78 | 96 | 399 | loose |
| Chance the Rapper | Pusha Man | 4 | 1 | 19 | loose |
| Chance the Rapper | Pusha Man / Paranoia | 72 | 56 | 335 | loose |
| Chance the Rapper | Put It On Me | 42 | 42 | 166 | loose |
| Chance the Rapper | Quiet Storm | 44 | 65 | 298 | loose |
| Chance the Rapper | R&B | 52 | 33 | 728 | loose |
| Chance the Rapper | Rainbow | 38 | 55 | 140 | loose |
| Chance the Rapper | Reboot | 30 | 20 | 108 | loose |
| Chance the Rapper | Red Lines | 25 | 16 | 61 | loose |
| Chance the Rapper | Remember Me? | 55 | 56 | 219 | loose |
| Chance the Rapper | Rememory | 31 | 11 | 125 | loose |
| Chance the Rapper | Revoltamos | 63 | 39 | 579 | loose |
| Chance the Rapper | Ride | 61 | 41 | 313 | loose |
| Chance the Rapper | Ridin’ Round | 73 | 42 | 307 | loose |
| Chance the Rapper | Roo | 57 | 74 | 361 | loose |
| Chance the Rapper | Rubber Tree | 11 | 5 | 55 | loose |
| Chance the Rapper | Run Up | 31 | 24 | 97 | loose |
| Chance the Rapper | Run to You | 61 | 34 | 339 | loose |
| Chance the Rapper | SHELTER | 69 | 73 | 373 | loose |
| Chance the Rapper | STFU | 64 | 72 | 237 | loose |
| Chance the Rapper | Safe With Me | 48 | 43 | 197 | loose |
| Chance the Rapper | Same Drugs | 40 | 10 | 110 | loose |
| Chance the Rapper | Save Yourself First | 11 | 5 | 40 | loose |
| Chance the Rapper | Savemoney Cypher | 87 | 90 | 495 | loose |
| Chance the Rapper | Saviour Money | 48 | 38 | 231 | loose |
| Chance the Rapper | Sco Wok | 10 | 4 | 20 | loose |
| Chance the Rapper | See Me Fly | 36 | 21 | 197 | loose |
| Chance the Rapper | Semi Detached | 27 | 13 | 70 | loose |
| Chance the Rapper | Senzu Bean | 59 | 28 | 318 | loose |
| Chance the Rapper | Seppuku | 80 | 95 | 371 | loose |
| Chance the Rapper | September 7th | 21 | 15 | 98 | loose |
| Chance the Rapper | Shake Dat a$$ | 56 | 52 | 360 | loose |
| Chance the Rapper | She’s The Type | 88 | 95 | 451 | loose |
| Chance the Rapper | Shoulda Left You | 70 | 55 | 297 | loose |
| Chance the Rapper | Show Me Love (Skrillex Remix) | 32 | 20 | 187 | loose |
| Chance the Rapper | Slide Around | 63 | 81 | 275 | loose |
| Chance the Rapper | Slip Slide | 41 | 58 | 165 | loose |
| Chance the Rapper | Smoke Again | 50 | 35 | 275 | loose |
| Chance the Rapper | Smoke Break | 86 | 68 | 186 | loose |
| Chance the Rapper | Snowed In | 54 | 66 | 124 | loose |
| Chance the Rapper | Social Experiment Tour Dates | 33 | 8 | 113 | loose |
| Chance the Rapper | Solid Beam of Light | 9 | 1 | 25 | loose |
| Chance the Rapper | Something About Us | 55 | 64 | 230 | loose |
| Chance the Rapper | Somewhere in Paradise | 52 | 40 | 391 | loose |
| Chance the Rapper | Somewhere, Nowhere USA | 48 | 58 | 309 | loose |
| Chance the Rapper | Space & Time | 47 | 40 | 110 | loose |
| Chance the Rapper | Spaceship | 61 | 38 | 219 | loose |
| Chance the Rapper | Spaceship iii | 36 | 22 | 151 | loose |
| Chance the Rapper | Special | 11 | 8 | 12 | loose |
| Chance the Rapper | Speed Of Light | 58 | 44 | 212 | loose |
| Chance the Rapper | Speed Of Love | 86 | 102 | 444 | loose |
| Chance the Rapper | Spooky Song | 58 | 34 | 228 | loose |
| Chance the Rapper | Ssssss | 35 | 34 | 57 | loose |
| Chance the Rapper | Star Side Intro | 73 | 58 | 386 | loose |
| Chance the Rapper | Stars Out | 28 | 30 | 216 | loose |
| Chance the Rapper | Steamer | 85 | 79 | 504 | loose |
| Chance the Rapper | Stevie Wonder | 44 | 17 | 95 | loose |
| Chance the Rapper | Still Get Chanel | 60 | 54 | 336 | loose |
| Chance the Rapper | Stranger at the Table | 43 | 27 | 138 | loose |
| Chance the Rapper | Stressed | 29 | 19 | 120 | loose |
| Chance the Rapper | Such A Thing | 35 | 17 | 228 | loose |
| Chance the Rapper | Suitcase | 38 | 23 | 264 | loose |
| Chance the Rapper | Suitcase Remix | 4 | 0 | 15 | loose |
| Chance the Rapper | Summer Friends | 52 | 35 | 251 | loose |
| Chance the Rapper | Summer Slumber | 26 | 26 | 138 | loose |
| Chance the Rapper | Sun Come Down | 46 | 54 | 203 | loose |
| Chance the Rapper | Sunday Candy | 34 | 15 | 154 | loose |
| Chance the Rapper | Swell Guy | 39 | 30 | 281 | loose |
| Chance the Rapper | T-Shirt | 33 | 33 | 77 | loose |
| Chance the Rapper | THANK YOU | 16 | 11 | 23 | loose |
| Chance the Rapper | Take Me To The Light [V6] | 11 | 3 | 51 | loose |
| Chance the Rapper | Take Me To The Light [v7] | 27 | 46 | 98 | loose |
| Chance the Rapper | Take Me to the Light | 36 | 44 | 46 | loose |
| Chance the Rapper | Tap Dance | 24 | 33 | 118 | loose |
| Chance the Rapper | Taxi Cab | 55 | 25 | 387 | loose |
| Chance the Rapper | The Big Day | 17 | 10 | 57 | loose |
| Chance the Rapper | The Breath (Falling Out) | 162 | 122 | 399 | loose |
| Chance the Rapper | The End | 45 | 28 | 146 | loose |
| Chance the Rapper | The First Time | 44 | 8 | 236 | loose |
| Chance the Rapper | The Fox & The Scorpion | 35 | 32 | 219 | loose |
| Chance the Rapper | The Heart & The Tongue | 37 | 88 | 431 | loose |
| Chance the Rapper | The Highs & The Lows | 58 | 91 | 349 | loose |
| Chance the Rapper | The Highs and The Lows (Remix) | 70 | 76 | 209 | loose |
| Chance the Rapper | The Lion - Writing Exercise #815 | 62 | 49 | 404 | loose |
| Chance the Rapper | The Man Who Has Everything | 46 | 46 | 356 | loose |
| Chance the Rapper | The Negro Problem | 55 | 35 | 267 | loose |
| Chance the Rapper | The Return | 38 | 50 | 318 | loose |
| Chance the Rapper | The Tragedy | 30 | 21 | 62 | loose |
| Chance the Rapper | The Way | 52 | 50 | 208 | loose |
| Chance the Rapper | The Wirter | 9 | 1 | 56 | loose |
| Chance the Rapper | The Wonder Years | 36 | 25 | 208 | loose |
| Chance the Rapper | The Worst Guys (Live at Governor’s Ball) | 11 | 0 | 42 | loose |
| Chance the Rapper | The Writer | 36 | 48 | 225 | loose |
| Chance the Rapper | They Don’t Like Me | 39 | 15 | 161 | loose |
| Chance the Rapper | Thotty | 36 | 27 | 141 | loose |
| Chance the Rapper | Three Course Meal | 58 | 37 | 436 | loose |
| Chance the Rapper | Thru the Fire | 36 | 33 | 117 | loose |
| Chance the Rapper | Thursday Night | 25 | 10 | 148 | loose |
| Chance the Rapper | Tired of These | 43 | 11 | 188 | loose |
| Chance the Rapper | Together | 46 | 40 | 263 | loose |
| Chance the Rapper | Too Late | 55 | 63 | 250 | loose |
| Chance the Rapper | Touch The Ground | 45 | 48 | 195 | loose |
| Chance the Rapper | Town on the Hill | 15 | 4 | 33 | loose |
| Chance the Rapper | Tree | 60 | 64 | 283 | loose |
| Chance the Rapper | True Kinda Love | 16 | 20 | 27 | loose |
| Chance the Rapper | Turn Down | 59 | 86 | 190 | loose |
| Chance the Rapper | Tweakin | 60 | 39 | 396 | loose |
| Chance the Rapper | U Got Me Fucked Up | 26 | 36 | 387 | loose |
| Chance the Rapper | Ultralight Beam | 68 | 60 | 309 | loose |
| Chance the Rapper | Ultralight Beams (Demo) | 28 | 11 | 40 | loose |
| Chance the Rapper | Untitled | 34 | 21 | 248 | loose |
| Chance the Rapper | Untitled ACL Song (10/10/2015) | 28 | 15 | 108 | loose |
| Chance the Rapper | Violent Nights (Violent Crimes Demo) | 37 | 51 | 183 | loose |
| Chance the Rapper | WE NEED ANGELS | 37 | 35 | 224 | loose |
| Chance the Rapper | Wake Up | 50 | 22 | 217 | loose |
| Chance the Rapper | Wala Cam | 63 | 76 | 227 | loose |
| Chance the Rapper | Wanna Be Cool | 57 | 21 | 225 | loose |
| Chance the Rapper | Want Me Dead | 51 | 72 | 112 | loose |
| Chance the Rapper | Warm Enough | 60 | 51 | 245 | loose |
| Chance the Rapper | Washington | 17 | 18 | 141 | loose |
| Chance the Rapper | Wasted | 17 | 10 | 73 | loose |
| Chance the Rapper | Wasting Time | 39 | 40 | 265 | loose |
| Chance the Rapper | Waves | 20 | 18 | 36 | loose |
| Chance the Rapper | We Are | 52 | 44 | 407 | loose |
| Chance the Rapper | We Go High | 73 | 82 | 512 | loose |
| Chance the Rapper | We Rare BASED FREESTYLE | 49 | 22 | 175 | loose |
| Chance the Rapper | We The People (Nike: Unlimited Together) | 26 | 10 | 86 | loose |
| Chance the Rapper | Weather Forecast | 38 | 33 | 190 | loose |
| Chance the Rapper | Wendy N Becky | 61 | 62 | 556 | loose |
| Chance the Rapper | Whats Next BASED FREESTYLE | 89 | 42 | 473 | loose |
| Chance the Rapper | What’s the Hook? | 45 | 72 | 189 | loose |
| Chance the Rapper | Who’s To Say | 58 | 55 | 218 | loose |
| Chance the Rapper | Wild ’N Out Rap Battle | 34 | 25 | 118 | loose |
| Chance the Rapper | Will | 7 | 11 | 33 | AAAA |
| Chance the Rapper | Windows | 52 | 43 | 252 | loose |
| Chance the Rapper | Winners | 53 | 44 | 285 | loose |
| Chance the Rapper | Wonderful Everyday: Arthur | 39 | 10 | 53 | loose |
| Chance the Rapper | Work Out | 51 | 60 | 221 | loose |
| Chance the Rapper | Wraith | 65 | 108 | 263 | loose |
| Chance the Rapper | Writing Exercise #2 | 12 | 7 | 86 | loose |
| Chance the Rapper | Writing Exercise #24 | 37 | 29 | 192 | loose |
| Chance the Rapper | XANZ & BITCHES !!! | 36 | 24 | 176 | loose |
| Chance the Rapper | XXL Freshman Freestyle | 23 | 12 | 85 | loose |
| Chance the Rapper | XXL Freshmen 2014 Cypher - Part 1 | 74 | 67 | 536 | loose |
| Chance the Rapper | YAH Know | 100 | 113 | 570 | loose |
| Chance the Rapper | YEAH YEAH | 55 | 56 | 171 | loose |
| Chance the Rapper | YOLO (DJ Allstyle Shout) | 44 | 55 | 219 | loose |
| Chance the Rapper | YOU CAN ALWAYS COME BACK HOME | 60 | 47 | 96 | loose |
| Chance the Rapper | You A Bitch | 41 | 31 | 119 | loose |
| Chance the Rapper | You Song | 63 | 34 | 371 | loose |
| Chance the Rapper | You Still Take Me To the Light | 29 | 48 | 68 | loose |
| Chance the Rapper | Yup (Bath Time Playlist) | 27 | 5 | 90 | loose |
| Chance the Rapper | Zanies and Fools | 105 | 157 | 662 | loose |
| Chance the Rapper | Zion | 23 | 16 | 157 | loose |
| Chance the Rapper | Zion - 170811 | 15 | 11 | 88 | loose |
| Chance the Rapper | ya | 8 | 8 | 6 | loose |
| Chance the Rapper | “Children and Monsters” Freestyle: Say Something | 38 | 24 | 147 | loose |
