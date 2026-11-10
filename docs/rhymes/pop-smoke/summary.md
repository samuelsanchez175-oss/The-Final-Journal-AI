# Pop Smoke rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Pop Smoke
- Songs: 152
- Bars kept (Pop Smoke lyric lines): 4685
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 24
- Canonical name: Pop Smoke.
- Credit strings: Pop Smoke.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 21423
- REPEAT pairs, recorded separately: 2799
- END rhymes: 4218
- INNER rhymes: 17205

By match:

- PERFECT: 1814 (END 500, INNER 1314)
- SLANT: 9475 (END 1887, INNER 7588)
- ASSONANCE: 9849 (END 1720, INNER 8129)
- MULTI: 285 (END 111, INNER 174)

By confidence:

- HIGH: 1923
- MED: 17695
- LOW: 1805

## Core

- Core Y: 20862
- Core N among rhyme pairs: 561

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 9898 (46.2%)
- vowel: 9849 (46.0%)
- spelling: 1391 (6.5%)
- multi: 285 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- AABB: 1 songs
- loose: 150 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 1276 pairs (END 178, INNER 1098). Words: get, send, when, never, gettin, tell, said, steppin.
2. `vow:OW` — 1275 pairs (END 128, INNER 1147). Words: know, don't, no, go, smoke, show, hold, told.
3. `vow:AA` — 1140 pairs (END 154, INNER 986). Words: got, talkin, pop, nothin, want, shots, not, body.
4. `vow:EY` — 1116 pairs (END 234, INNER 882). Words: ain't, say, way, play, day, baby, make, stay.
5. `vow:IH` — 1073 pairs (END 159, INNER 914). Words: bitches, bitch, him, shit, big, fifty, clip, think.
6. `vow:IY` — 984 pairs (END 214, INNER 770). Words: see, free, streets, these, g, tee, keep, need.
7. `vow:AE` — 963 pairs (END 257, INNER 706). Words: can't, back, have, can, bag, ask, catch, mad.
8. `vow:AH` — 766 pairs (END 110, INNER 656). Words: hundred, what, fuck, what's, double, some, guns, fuckin.
9. `slant:AA:stop` — 731 pairs (END 64, INNER 667). Words: got, pop, body, want, block, not, gotta, chop.
10. `vow:AY` — 558 pairs (END 96, INNER 462). Words: like, why, try, diamonds, fire, fly, bae, wildin.
11. `slant:IH:stop` — 504 pairs (END 116, INNER 388). Words: nigga, shit, big, hit, clip, city, dick, fifty.
12. `slant:EH:stop` — 394 pairs (END 72, INNER 322). Words: get, better, said, let, left, neck, ready, head.
13. `slant:IH:sib-stop` — 358 pairs (END 79, INNER 279). Words: nigga, niggas, bitch, shit, big, dick, clip, hit.
14. `vow:UW` — 300 pairs (END 103, INNER 197). Words: who, shoot, through, two, new, coupe, shootin, jewelry.
15. `slant:AE:stop` — 295 pairs (END 85, INNER 210). Words: back, bag, can't, mad, had, hat, papi, fat.
16. `slant:EH:nas-stop` — 264 pairs (END 10, INNER 254). Words: when, get, let, better, head, ten, again, step.
17. `cmu:OW` — 249 pairs (END 23, INNER 226). Words: know, no, go, show, bro, throw, mo, low.
18. `slant:EH:liq-stop` — 244 pairs (END 21, INNER 223). Words: tell, get, where, said, head, there, let, dread.
19. `slant:IH:nas-stop` — 234 pairs (END 24, INNER 210). Words: him, i'ma, big, shit, hit, clip, spin, thing.
20. `slant:AH:nas-stop` — 202 pairs (END 16, INNER 186). Words: fuck, what, one, some, come, gun, run, money.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 365 pair sides, mostly spelling via spelling phonetic key, often with niggas (135)
- niggas — 215 pair sides, mostly spelling via spelling phonetic key, often with nigga (135)
- gon — 103 pair sides, mostly spelling via spelling phonetic key, often with dont (39)
- ima — 82 pair sides, mostly spelling via spelling phonetic key, often with shit (10)
- shawty — 46 pair sides, mostly vowel via spelling phonetic key, often with every (4)
- henny — 44 pair sides, mostly vowel via spelling phonetic key, often with fendi (4)
- tryna — 41 pair sides, mostly spelling via spelling phonetic key, often with keep (5)
- wraith — 41 pair sides, mostly spelling via spelling phonetic key, often with face (8)
- opps — 38 pair sides, mostly vowel via spelling phonetic key, often with dont (12)
- flossy — 33 pair sides, mostly vowel via spelling phonetic key, often with g (4)
- eso — 27 pair sides, mostly vowel via spelling phonetic key, often with en (3)
- papi — 25 pair sides, mostly spelling via spelling phonetic key, often with back (5)
- renty — 24 pair sides, mostly spelling via spelling phonetic key, often with money (3)
- suvy — 22 pair sides, mostly vowel via spelling phonetic key, often with movie (6)
- glizzy — 18 pair sides, mostly vowel via spelling phonetic key, often with whitney (2)
- tengo — 17 pair sides, mostly spelling via spelling phonetic key, often with en (3)
- titty — 16 pair sides, mostly spelling via spelling phonetic key, often with city (2)
- breesh — 14 pair sides, mostly spelling via spelling phonetic key, often with these (3)
- jiggy — 13 pair sides, mostly spelling via spelling phonetic key, often with hit (2)
- fetti — 13 pair sides, mostly spelling via spelling phonetic key, often with let (2)
- loko — 13 pair sides, mostly vowel via spelling phonetic key, often with pro (3)
- brrt — 12 pair sides, mostly cmu via vault phonetic_class, often with back (3)
- crippin — 12 pair sides, mostly spelling via spelling phonetic key, often with sippin (1)
- prolly — 12 pair sides, mostly vowel via spelling phonetic key, often with lobby (3)
- ooter — 12 pair sides, mostly spelling via spelling phonetic key, often with ruler (2)
- tekken — 12 pair sides, mostly vowel via spelling phonetic key, often with check (1)
- junto — 11 pair sides, mostly vowel via spelling phonetic key, often with flow (2)
- hunnid — 10 pair sides, mostly vowel via spelling phonetic key, often with budgin (2)
- nappy — 10 pair sides, mostly spelling via spelling phonetic key, often with tag (1)
- slatt — 10 pair sides, mostly spelling via spelling phonetic key, often with back (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Pop Smoke | 100k On a Coupe | 18 | 11 | 72 | loose |
| Pop Smoke | 2 Sticks | 7 | 2 | 12 | loose |
| Pop Smoke | 2020* | 20 | 10 | 39 | loose |
| Pop Smoke | 30 | 60 | 47 | 312 | loose |
| Pop Smoke | 44 BullDog | 39 | 34 | 130 | loose |
| Pop Smoke | 50k (Demo) | 7 | 9 | 13 | loose |
| Pop Smoke | 60s* | 54 | 42 | 233 | loose |
| Pop Smoke | 8-Ball | 20 | 15 | 124 | loose |
| Pop Smoke | AP | 36 | 31 | 120 | loose |
| Pop Smoke | Aim for the Moon | 41 | 32 | 169 | loose |
| Pop Smoke | Armed And Dangerous (That’s on Everything) | 53 | 38 | 121 | loose |
| Pop Smoke | Armed N Dangerous (Charlie Sloth Freestyle) | 33 | 30 | 213 | loose |
| Pop Smoke | Babba Treesh (Demeanor Original) | 5 | 4 | 3 | AAAA |
| Pop Smoke | Baby Cry* (Wishing On A Star) | 33 | 18 | 145 | loose |
| Pop Smoke | Back Door | 42 | 43 | 364 | loose |
| Pop Smoke | Backseat | 30 | 19 | 97 | loose |
| Pop Smoke | Bad Bitch from Tokyo (Demo 1) | 9 | 6 | 46 | loose |
| Pop Smoke | Bad Boys | 35 | 12 | 135 | loose |
| Pop Smoke | Be Clearr | 25 | 28 | 84 | loose |
| Pop Smoke | Beat the Speaker | 19 | 15 | 66 | loose |
| Pop Smoke | Better Have Your Gun | 56 | 55 | 134 | loose |
| Pop Smoke | Blue Passion* (Rowdy Rebel Demo) | 25 | 34 | 63 | loose |
| Pop Smoke | Bout a Million | 49 | 61 | 219 | loose |
| Pop Smoke | Brother Man | 44 | 37 | 108 | loose |
| Pop Smoke | Brush Em | 68 | 54 | 230 | loose |
| Pop Smoke | Bugatti Baby (feat. Tyga) | 40 | 25 | 111 | loose |
| Pop Smoke | Cappin* | 36 | 22 | 109 | loose |
| Pop Smoke | Cash Shit* | 9 | 0 | 29 | loose |
| Pop Smoke | Catch (Merci Beaucoup Original) | 39 | 33 | 228 | loose |
| Pop Smoke | Chanel | 15 | 25 | 34 | loose |
| Pop Smoke | Christopher Walking | 31 | 34 | 107 | loose |
| Pop Smoke | Coupe | 30 | 14 | 66 | loose |
| Pop Smoke | Creature | 55 | 56 | 175 | loose |
| Pop Smoke | Defiant | 81 | 90 | 251 | loose |
| Pop Smoke | Demeanor | 28 | 36 | 129 | loose |
| Pop Smoke | Diana | 38 | 30 | 144 | loose |
| Pop Smoke | Dior | 40 | 21 | 106 | loose |
| Pop Smoke | Dja Dja* (Cha Cha*) | 10 | 3 | 8 | loose |
| Pop Smoke | Don’t Know Em | 36 | 22 | 83 | loose |
| Pop Smoke | Don’t Talk Twice (Can’t Get Right)* | 11 | 6 | 27 | loose |
| Pop Smoke | Double G (Demo) | 12 | 5 | 53 | loose |
| Pop Smoke | Double It | 49 | 49 | 144 | loose |
| Pop Smoke | Dreaming | 45 | 59 | 81 | loose |
| Pop Smoke | Drive the Boat | 31 | 21 | 52 | loose |
| Pop Smoke | Element | 32 | 56 | 109 | loose |
| Pop Smoke | Enjoy Yourself | 45 | 19 | 281 | loose |
| Pop Smoke | Exposing Me | 37 | 21 | 96 | loose |
| Pop Smoke | Face 2 Face* | 35 | 44 | 129 | loose |
| Pop Smoke | Face to Face (Version 1) | 10 | 3 | 28 | loose |
| Pop Smoke | Fashion (Chief Keef Demo) | 36 | 21 | 99 | loose |
| Pop Smoke | Fashion (Chief Keef Remix) | 24 | 16 | 129 | loose |
| Pop Smoke | Fashion [OG] | 4 | 6 | 2 | AABB |
| Pop Smoke | Feeling | 37 | 19 | 81 | loose |
| Pop Smoke | Fire in the Booth, Pt. 1 | 54 | 22 | 249 | loose |
| Pop Smoke | Flexin’ | 52 | 64 | 257 | loose |
| Pop Smoke | For the Night | 41 | 54 | 220 | loose |
| Pop Smoke | Foreigner | 49 | 61 | 133 | loose |
| Pop Smoke | Fuck You* | 27 | 32 | 90 | loose |
| Pop Smoke | Fully Focused Freestyle (My Life Session Edit) | 10 | 3 | 28 | loose |
| Pop Smoke | G3* (Summertime Freestyle) | 45 | 34 | 146 | loose |
| Pop Smoke | GATTI (Chuwe + Tellah Remix) [Mixed] | 4 | 1 | 6 | loose |
| Pop Smoke | GATTI (Tyga Demo) | 17 | 6 | 23 | loose |
| Pop Smoke | Gang Gang* (Lean) | 9 | 3 | 14 | loose |
| Pop Smoke | Gangstas | 36 | 31 | 128 | loose |
| Pop Smoke | Genius | 75 | 75 | 261 | loose |
| Pop Smoke | Genius (Original) V1 | 5 | 0 | 14 | loose |
| Pop Smoke | Get Back | 41 | 61 | 172 | loose |
| Pop Smoke | Get Back / ID5 (from HVDES at EDC Las Vegas 2023: Bass Pod Stage) [Mixed] | 4 | 0 | 7 | loose |
| Pop Smoke | Get Right* | 16 | 7 | 44 | loose |
| Pop Smoke | Girl I Want U (Tsunami Demo) | 4 | 5 | 10 | loose |
| Pop Smoke | Girl I Want U (Tsunami Original) | 36 | 25 | 85 | loose |
| Pop Smoke | Good News | 9 | 1 | 40 | loose |
| Pop Smoke | Got It on Me | 33 | 24 | 90 | loose |
| Pop Smoke | Hawk Em | 34 | 17 | 52 | loose |
| Pop Smoke | Hello | 40 | 24 | 169 | loose |
| Pop Smoke | Hook (Envy Me*) | 7 | 3 | 20 | loose |
| Pop Smoke | Hotel Lobby | 21 | 15 | 55 | loose |
| Pop Smoke | How We Move* | 50 | 46 | 222 | loose |
| Pop Smoke | I See You Baby* | 12 | 4 | 7 | loose |
| Pop Smoke | Iced Out Audemars | 62 | 56 | 130 | loose |
| Pop Smoke | Imperfections (Interlude) | 12 | 2 | 34 | loose |
| Pop Smoke | Invincible | 39 | 39 | 104 | loose |
| Pop Smoke | Jewels (Bout A Million Demo) | 4 | 1 | 4 | loose |
| Pop Smoke | Lefty (Demo) | 11 | 12 | 5 | loose |
| Pop Smoke | Like Me | 47 | 48 | 281 | loose |
| Pop Smoke | MPR | 48 | 32 | 220 | loose |
| Pop Smoke | Make It Rain | 69 | 67 | 303 | loose |
| Pop Smoke | Man On A Mission | 11 | 0 | 15 | loose |
| Pop Smoke | Mannequin | 50 | 83 | 145 | loose |
| Pop Smoke | Manslaughter | 39 | 32 | 138 | loose |
| Pop Smoke | Meet the Woo | 28 | 35 | 88 | loose |
| Pop Smoke | Merci Beaucoup | 24 | 12 | 173 | loose |
| Pop Smoke | Mercy (Got It On Me Original*) | 6 | 8 | 25 | loose |
| Pop Smoke | Mike Amiri (Dior Demo) | 3 | 1 | 1 | loose |
| Pop Smoke | Money Call (Demo) | 23 | 41 | 150 | loose |
| Pop Smoke | Money Man | 13 | 3 | 70 | loose |
| Pop Smoke | Mood Swings | 57 | 74 | 231 | loose |
| Pop Smoke | More Time | 54 | 60 | 208 | loose |
| Pop Smoke | Mr. Jones | 39 | 23 | 195 | loose |
| Pop Smoke | My Dawgs (Wolves Demo)* | 9 | 2 | 9 | loose |
| Pop Smoke | My Life* | 20 | 15 | 66 | loose |
| Pop Smoke | No Cap (Remix) | 49 | 66 | 153 | loose |
| Pop Smoke | Ok Ok (GATTI French Montana Demo) | 29 | 24 | 84 | loose |
| Pop Smoke | One Shot | 22 | 21 | 88 | loose |
| Pop Smoke | Outro | 12 | 2 | 35 | loose |
| Pop Smoke | PTSD | 37 | 24 | 167 | loose |
| Pop Smoke | Paranoia | 35 | 20 | 164 | loose |
| Pop Smoke | Pop Smoke Freestyle | LA Leakers Freestyle #93 | 18 | 10 | 82 | loose |
| Pop Smoke | Questions | 22 | 27 | 100 | loose |
| Pop Smoke | Ready For This* | 17 | 15 | 37 | loose |
| Pop Smoke | Rich Niggas* | 4 | 0 | 8 | loose |
| Pop Smoke | Rumble | 71 | 78 | 453 | loose |
| Pop Smoke | Run Down | 40 | 36 | 190 | loose |
| Pop Smoke | Same Day* | 9 | 3 | 47 | loose |
| Pop Smoke | Scenario | 49 | 19 | 174 | loose |
| Pop Smoke | Shake the Room | 37 | 47 | 90 | loose |
| Pop Smoke | She Feelin Nice | 29 | 26 | 60 | loose |
| Pop Smoke | She Got a Thing | 18 | 30 | 43 | loose |
| Pop Smoke | Show Out (Original) | 12 | 10 | 69 | loose |
| Pop Smoke | Showin Off Pt.1 | 36 | 48 | 79 | loose |
| Pop Smoke | Showin Off Pt.2 | 52 | 51 | 125 | loose |
| Pop Smoke | Snitching | 87 | 68 | 280 | loose |
| Pop Smoke | So 4 Real* | 33 | 18 | 137 | loose |
| Pop Smoke | So Into You (Something Special Original [V1]) | 5 | 2 | 8 | loose |
| Pop Smoke | So Into You (Something Special Original [V3]) | 29 | 18 | 100 | loose |
| Pop Smoke | Something Special | 16 | 27 | 52 | loose |
| Pop Smoke | Spoiled | 13 | 7 | 41 | loose |
| Pop Smoke | Start Shooting | 42 | 26 | 97 | loose |
| Pop Smoke | Sweetheart | 41 | 50 | 108 | loose |
| Pop Smoke | Swirv* | 23 | 8 | 79 | loose |
| Pop Smoke | Tell Em Stop It | 28 | 39 | 120 | loose |
| Pop Smoke | Ten Toes (She a Freak) | 10 | 8 | 11 | loose |
| Pop Smoke | The Woo | 44 | 40 | 198 | loose |
| Pop Smoke | They Know | 36 | 43 | 92 | loose |
| Pop Smoke | Throw The Woo’s Up | 9 | 2 | 1 | loose |
| Pop Smoke | Tiger (Mike Dee Demo) | 35 | 58 | 223 | loose |
| Pop Smoke | Top Shotta | 62 | 56 | 333 | loose |
| Pop Smoke | Tsunami | 5 | 0 | 16 | loose |
| Pop Smoke | Tunnel Vision (Outro) | 30 | 23 | 134 | loose |
| Pop Smoke | U Not Like Me (L.A. Leakers Freestyle) | 10 | 1 | 66 | loose |
| Pop Smoke | War | 64 | 61 | 212 | loose |
| Pop Smoke | We Made It (Calboy Demo) | 29 | 40 | 170 | loose |
| Pop Smoke | Welcome to the Party | 31 | 30 | 137 | loose |
| Pop Smoke | West Coast Shit | 45 | 74 | 260 | loose |
| Pop Smoke | What You Know Bout Love | 33 | 28 | 134 | loose |
| Pop Smoke | What’s Crackin | 31 | 27 | 136 | loose |
| Pop Smoke | Wolves | 41 | 61 | 166 | loose |
| Pop Smoke | Woo (Remix)* | 6 | 0 | 18 | loose |
| Pop Smoke | Woo Baby | 36 | 45 | 96 | loose |
| Pop Smoke | Woo Baby Interlude | 10 | 20 | 27 | loose |
| Pop Smoke | Woo Year | 32 | 33 | 109 | loose |
| Pop Smoke | Yea Yea | 48 | 41 | 116 | loose |
