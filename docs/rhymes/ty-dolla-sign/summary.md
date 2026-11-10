# Ty Dolla $ign rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ty Dolla $ign
- Songs: 1279
- Bars kept (Ty Dolla $ign lyric lines): 45467
- Section headers dropped, not counted as bars: 11
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 143
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 116
- Canonical name: Ty Dolla $ign.
- Credit strings: Ty Dolla $ign.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 215331
- REPEAT pairs, recorded separately: 34613
- END rhymes: 35797
- INNER rhymes: 179534

By match:

- PERFECT: 18762 (END 5139, INNER 13623)
- SLANT: 91757 (END 14610, INNER 77147)
- ASSONANCE: 102412 (END 15320, INNER 87092)
- MULTI: 2400 (END 728, INNER 1672)

By confidence:

- HIGH: 19499
- MED: 183645
- LOW: 12187

## Core

- Core Y: 211904
- Core N among rhyme pairs: 3427

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 100248 (46.6%)
- vowel: 102412 (47.6%)
- spelling: 10271 (4.8%)
- multi: 2400 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AABB: 1 songs
- ABCB: 2 songs
- loose: 1276 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 15394 pairs (END 1772, INNER 13622). Words: don't, know, no, go, told, only, hoes, over.
2. `vow:EY` — 13587 pairs (END 2224, INNER 11363). Words: ain't, say, way, baby, make, take, day, stay.
3. `vow:EH` — 13521 pairs (END 1621, INNER 11900). Words: get, when, never, tell, friends, next, let, gettin.
4. `vow:IH` — 12932 pairs (END 1737, INNER 11195). Words: bitch, shit, bitches, think, hit, still, different, give.
5. `vow:AY` — 8539 pairs (END 1606, INNER 6933). Words: like, why, time, mind, by, high, right, try.
6. `vow:AE` — 8319 pairs (END 1618, INNER 6701). Words: can't, back, can, had, ass, have, bad, fast.
7. `vow:AA` — 8303 pairs (END 1056, INNER 7247). Words: got, want, wanna, hard, not, gotta, nothin, talkin.
8. `vow:IY` — 7328 pairs (END 1141, INNER 6187). Words: see, even, need, keep, these, real, shawty, nobody.
9. `vow:AH` — 7313 pairs (END 983, INNER 6330). Words: love, fuck, some, what, one, hundred, fuckin, money.
10. `slant:AA:stop` — 4322 pairs (END 481, INNER 3841). Words: got, gotta, want, not, top, stop, body, drop.
11. `slant:IH:stop` — 3605 pairs (END 527, INNER 3078). Words: nigga, shit, hit, big, dick, city, whip, pick.
12. `cmu:OW` — 2974 pairs (END 454, INNER 2520). Words: know, no, go, show, though, ho, low, slow.
13. `slant:IH:sib-stop` — 2916 pairs (END 583, INNER 2333). Words: bitch, shit, nigga, niggas, hit, dick, rich, big.
14. `slant:AY:stop` — 2755 pairs (END 512, INNER 2243). Words: like, right, ride, night, might, side, type, inside.
15. `slant:EH:stop` — 2657 pairs (END 263, INNER 2394). Words: get, said, let, better, head, left, best, check.
16. `slant:EH:nas-stop` — 2465 pairs (END 106, INNER 2359). Words: when, get, let, again, said, better, many, ten.
17. `slant:AH:nas-stop` — 2367 pairs (END 167, INNER 2200). Words: fuck, what, some, one, money, come, club, done.
18. `slant:AE:stop` — 2303 pairs (END 464, INNER 1839). Words: back, had, bad, can't, bag, act, mad, fat.
19. `slant:AY:nas-stop` — 2151 pairs (END 414, INNER 1737). Words: time, like, mine, right, line, night, mind, fine.
20. `slant:EH:liq-stop` — 2042 pairs (END 149, INNER 1893). Words: get, tell, where, let, said, there, better, well.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 1926 pair sides, mostly spelling via spelling phonetic key, often with shit (420)
- ima — 859 pair sides, mostly spelling via spelling phonetic key, often with bitch (119)
- gon — 855 pair sides, mostly spelling via spelling phonetic key, often with dont (226)
- tryna — 712 pair sides, mostly spelling via spelling phonetic key, often with these (66)
- niggas — 564 pair sides, mostly spelling via spelling phonetic key, often with nigga (314)
- shawty — 350 pair sides, mostly vowel via spelling phonetic key, often with all (36)
- dolla — 111 pair sides, mostly spelling via spelling phonetic key, often with told (31)
- zaddy — 92 pair sides, mostly vowel via spelling phonetic key, often with baby (20)
- homie — 91 pair sides, mostly spelling via spelling phonetic key, often with hoes (9)
- brazy — 68 pair sides, mostly vowel via spelling phonetic key, often with baby (5)
- finna — 65 pair sides, mostly spelling via spelling phonetic key, often with nigga (23)
- thot — 64 pair sides, mostly spelling via spelling phonetic key, often with not (10)
- imma — 61 pair sides, mostly spelling via spelling phonetic key, often with nigga (18)
- henny — 61 pair sides, mostly vowel via spelling phonetic key, often with end (8)
- tengo — 58 pair sides, mostly vowel via spelling phonetic key, often with el (6)
- mojuba — 58 pair sides, mostly spelling via spelling phonetic key, often with gbogbo (18)
- fam — 57 pair sides, mostly spelling via spelling phonetic key, often with man (6)
- bros — 57 pair sides, mostly spelling via spelling phonetic key, often with know (7)
- ign — 52 pair sides, mostly spelling via spelling phonetic key, often with nigga (21)
- wraith — 48 pair sides, mostly spelling via spelling phonetic key, often with face (5)
- cuz — 45 pair sides, mostly spelling via spelling phonetic key, often with love (8)
- swag — 45 pair sides, mostly spelling via spelling phonetic key, often with back (5)
- quiero — 44 pair sides, mostly vowel via spelling phonetic key, often with no (13)
- pics — 41 pair sides, mostly vowel via spelling phonetic key, often with shit (4)
- homies — 40 pair sides, mostly spelling via spelling phonetic key, often with homie (5)
- baddest — 40 pair sides, mostly vowel via spelling phonetic key, often with have (6)
- lambo — 38 pair sides, mostly vowel via spelling phonetic key, often with know (7)
- bih — 36 pair sides, mostly spelling via spelling phonetic key, often with bitch (13)
- yeezy — 35 pair sides, mostly vowel via spelling phonetic key, often with leave (3)
- cuando — 35 pair sides, mostly vowel via spelling phonetic key, often with no (6)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ty Dolla $ign | #1 Freak | 29 | 21 | 216 | loose |
| Ty Dolla $ign | #WHERESTHELOVE | 53 | 60 | 254 | loose |
| Ty Dolla $ign | $ (Dollar Sign) | 29 | 20 | 43 | loose |
| Ty Dolla $ign | $Intro (Campaign) | 5 | 4 | 49 | AABB |
| Ty Dolla $ign | $nitches | 51 | 59 | 251 | loose |
| Ty Dolla $ign | 1 Time | 35 | 21 | 153 | loose |
| Ty Dolla $ign | 100 | 44 | 23 | 204 | loose |
| Ty Dolla $ign | 100 Grand | 43 | 39 | 145 | loose |
| Ty Dolla $ign | 100 Pounds | 26 | 13 | 136 | loose |
| Ty Dolla $ign | 18 Months | 23 | 12 | 114 | loose |
| Ty Dolla $ign | 1st Night | 22 | 6 | 117 | loose |
| Ty Dolla $ign | 1st Night / 4 A Young (Remix) | 35 | 13 | 151 | loose |
| Ty Dolla $ign | 2 Fine | 54 | 27 | 203 | loose |
| Ty Dolla $ign | 2 Myself | 17 | 8 | 57 | loose |
| Ty Dolla $ign | 200 | 42 | 26 | 97 | loose |
| Ty Dolla $ign | 2014 BET Hip Hop Awards - Cypher 1 | 103 | 78 | 372 | loose |
| Ty Dolla $ign | 2022 | 19 | 11 | 17 | loose |
| Ty Dolla $ign | 24 Hours (Remix) | 48 | 37 | 148 | loose |
| Ty Dolla $ign | 2morrow (We Ain’t Worried) | 43 | 28 | 177 | loose |
| Ty Dolla $ign | 3 Wayz | 29 | 19 | 86 | loose |
| Ty Dolla $ign | 3 billion | 23 | 18 | 157 | loose |
| Ty Dolla $ign | 3AM | 34 | 30 | 91 | loose |
| Ty Dolla $ign | 3Way | 28 | 12 | 116 | loose |
| Ty Dolla $ign | 4 Lit | 42 | 57 | 234 | loose |
| Ty Dolla $ign | 4 Real | 22 | 16 | 68 | loose |
| Ty Dolla $ign | 4 a Young | 24 | 15 | 79 | loose |
| Ty Dolla $ign | 40 | 40 | 25 | 83 | loose |
| Ty Dolla $ign | 4G’s | 56 | 41 | 158 | loose |
| Ty Dolla $ign | 4Play | 41 | 26 | 162 | loose |
| Ty Dolla $ign | 530 | 79 | 50 | 471 | loose |
| Ty Dolla $ign | 6 ‘N The Mornin’ (GMX) | 56 | 48 | 320 | loose |
| Ty Dolla $ign | 9 Lives | 43 | 33 | 163 | loose |
| Ty Dolla $ign | 9 Times Out Of 10 | 52 | 35 | 322 | loose |
| Ty Dolla $ign | 911 | 60 | 65 | 196 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/0c92648c2da17e4199bdc6d52e9165df.300x300x1.png" alt="Sucker for Pain" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Sucker for PainLil Wayne, Wiz Khalifa, Imagine Dragons, Logic & Ty Dolla $ign1.6M | 56 | 71 | 305 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/38df584102fc6044e8a6f70ae0bea6e2.300x300x1.png" alt="Cinderella" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>CinderellaMac Miller1.1M | 69 | 133 | 479 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/3d7bdca736daf5a069b4d5e86f5ff086.300x300x1.png" alt="FIELD TRIP" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>FIELD TRIP¥$, Kanye West & Ty Dolla $ign, Playboi Carti & Don Toliver943.2K | 53 | 45 | 153 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/3e907a630b59fcbf26c48a5a1b20066c.300x300x1.jpg" alt="Psycho" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>PsychoPost Malone3.8M | 36 | 41 | 243 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/417e5b985d42ee571934985d7904b63b.300x300x1.png" alt="CARNIVAL" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>CARNIVAL¥$, Kanye West & Ty Dolla $ign2.9M | 72 | 112 | 288 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/4c6a12df386ed1ab77c0efec44c1e49b.300x300x1.png" alt="Loyal" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>LoyalChris Brown1.2M | 58 | 28 | 183 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/521b925045ca5be201953c54501f3b6a.300x300x1.png" alt="All Mine" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>All MineKanye West2.6M | 40 | 32 | 116 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/521b925045ca5be201953c54501f3b6a.300x300x1.png" alt="Violent Crimes" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Violent CrimesKanye West2M | 12 | 10 | 38 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/6c5cf7aced7b6d5fd49c019f1a7558ac.300x300x1.png" alt="Fade" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>FadeKanye West1.3M | 21 | 2 | 39 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/6e4cd3685b2dc6cc406cd0ca7f71b842.300x300x1.png" alt="Young, Wild &amp; Free" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Young, Wild & FreeSnoop Dogg & Wiz Khalifa984.7K | 51 | 45 | 222 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/77e02a2992e56f82ef8ec8b39c870597.300x300x1.jpg" alt="Real Friends" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Real FriendsKanye West2.4M | 59 | 53 | 244 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/7efa3db6548214c9a1a30273f8194238.300x300x1.png" alt="Only One" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Only OneKanye West1.5M | 40 | 28 | 126 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/9b50709a30fbb0eee802ba391af0eb43.300x300x1.png" alt="WUSYANAME" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>WUSYANAMETyler, The Creator932.1K | 40 | 9 | 142 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/9c46af265dc73048ea8e7950f71afb60.300x300x1.jpg" alt="Post to Be" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Post to BeOmarion1.4M | 54 | 65 | 117 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/b3eb1d2503653d53486c87983f7b3e72.300x300x1.png" alt="FourFiveSeconds" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>FourFiveSecondsRihanna, Kanye West & Paul McCartney1.8M | 34 | 33 | 86 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/b69c8f63514bf88fe2259103ec6fde5b.300x300x1.png" alt="Or Nah (Remix)" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Or Nah (Remix)Ty Dolla $ign3.5M | 51 | 25 | 178 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/cfb437f6af0546f28a3a91b5f26f7821.300x300x1.png" alt="Swalla" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>SwallaJason Derulo2M | 37 | 28 | 152 | loose |
| Ty Dolla $ign | <img src="https://images.genius.com/d07c7aca495a624d5d4e0eb11cccd577.300x300x1.png" alt="Jaded" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>JadedDrake1.2M | 45 | 63 | 174 | loose |
| Ty Dolla $ign | ??? (Where) | 78 | 130 | 277 | loose |
| Ty Dolla $ign | A Norfside Story | 44 | 20 | 292 | loose |
| Ty Dolla $ign | A Song For Mom | 27 | 18 | 85 | loose |
| Ty Dolla $ign | A Thousand Miles (Haikou version) | 9 | 3 | 23 | loose |
| Ty Dolla $ign | A Wake, A Mass | 47 | 31 | 260 | loose |
| Ty Dolla $ign | ABOVE THE LAW | 23 | 48 | 109 | loose |
| Ty Dolla $ign | ADDICT (REMIX) | 31 | 15 | 104 | loose |
| Ty Dolla $ign | AFTER LYFE | 6 | 4 | 5 | loose |
| Ty Dolla $ign | ALL IN | 22 | 15 | 91 | loose |
| Ty Dolla $ign | APEROL SPRITZ (BACK OUTSIDE) | 18 | 15 | 79 | loose |
| Ty Dolla $ign | About Her | 37 | 20 | 95 | loose |
| Ty Dolla $ign | About Mine | 48 | 15 | 220 | loose |
| Ty Dolla $ign | Accelerate | 50 | 42 | 119 | loose |
| Ty Dolla $ign | Action | 61 | 53 | 312 | loose |
| Ty Dolla $ign | Actress | 39 | 18 | 102 | loose |
| Ty Dolla $ign | After Dark | 40 | 25 | 199 | loose |
| Ty Dolla $ign | Ain’t Fuckin With Her | 33 | 27 | 151 | loose |
| Ty Dolla $ign | Ain’t Got No | 38 | 47 | 34 | loose |
| Ty Dolla $ign | Ain’t My Girlfriend | 65 | 61 | 269 | loose |
| Ty Dolla $ign | Ain’t Nothing | 52 | 52 | 412 | loose |
| Ty Dolla $ign | Ain’t Said Shit | 81 | 20 | 334 | loose |
| Ty Dolla $ign | Ain’t You | 24 | 16 | 57 | loose |
| Ty Dolla $ign | Airplane Mode | 24 | 8 | 77 | loose |
| Ty Dolla $ign | All | 54 | 15 | 219 | loose |
| Ty Dolla $ign | All Around | 33 | 23 | 144 | loose |
| Ty Dolla $ign | All Eyez On Me | 49 | 21 | 191 | loose |
| Ty Dolla $ign | All Facts | 38 | 32 | 166 | loose |
| Ty Dolla $ign | All I Need | 27 | 13 | 46 | loose |
| Ty Dolla $ign | All My Friends (Demo) | 28 | 14 | 241 | loose |
| Ty Dolla $ign | All Night | 42 | 50 | 230 | loose |
| Ty Dolla $ign | All Star | 48 | 19 | 182 | loose |
| Ty Dolla $ign | All That | 72 | 53 | 397 | loose |
| Ty Dolla $ign | All U Needed | 38 | 17 | 55 | loose |
| Ty Dolla $ign | All the Time | 25 | 14 | 89 | loose |
| Ty Dolla $ign | Allatttt | 45 | 50 | 142 | loose |
| Ty Dolla $ign | Alone for Christmas | 22 | 24 | 94 | loose |
| Ty Dolla $ign | Always | 34 | 14 | 73 | loose |
| Ty Dolla $ign | Always Into Something | 39 | 35 | 187 | loose |
| Ty Dolla $ign | And If | 47 | 44 | 153 | loose |
| Ty Dolla $ign | And You Know That | 43 | 24 | 97 | loose |
| Ty Dolla $ign | Another B*tch | 47 | 66 | 202 | loose |
| Ty Dolla $ign | Another One | 44 | 41 | 230 | loose |
| Ty Dolla $ign | Anything Goes | 70 | 38 | 215 | loose |
| Ty Dolla $ign | Anything U Want | 36 | 34 | 108 | loose |
| Ty Dolla $ign | Anywhere | 25 | 18 | 97 | loose |
| Ty Dolla $ign | Appreciation | 34 | 40 | 121 | loose |
| Ty Dolla $ign | Are You Sure? | 20 | 4 | 39 | loose |
| Ty Dolla $ign | Area Codes | 44 | 41 | 160 | loose |
| Ty Dolla $ign | Ave Maria | 41 | 47 | 166 | loose |
| Ty Dolla $ign | Awesome | 36 | 24 | 66 | loose |
| Ty Dolla $ign | Ay Ya Ya Ya | 36 | 29 | 187 | loose |
| Ty Dolla $ign | B.E.D (Remix) | 56 | 34 | 211 | loose |
| Ty Dolla $ign | BACK TO ME | 58 | 50 | 298 | loose |
| Ty Dolla $ign | BBGIRLGOSLOW | 42 | 33 | 132 | loose |
| Ty Dolla $ign | BEG FORGIVENESS | 38 | 42 | 139 | loose |
| Ty Dolla $ign | BELIEVER | 16 | 4 | 44 | loose |
| Ty Dolla $ign | BLACKS N MEXICANS | 55 | 37 | 306 | loose |
| Ty Dolla $ign | BLIND DATE | 25 | 23 | 155 | loose |
| Ty Dolla $ign | BLITZ | 18 | 24 | 58 | loose |
| Ty Dolla $ign | BOMB | 22 | 9 | 54 | loose |
| Ty Dolla $ign | BOSS | 37 | 21 | 166 | loose |
| Ty Dolla $ign | BULLY | 21 | 11 | 48 | loose |
| Ty Dolla $ign | BULLY V1 | 140 | 102 | 542 | loose |
| Ty Dolla $ign | BURN | 22 | 22 | 98 | loose |
| Ty Dolla $ign | Baby Holla | 38 | 12 | 103 | loose |
| Ty Dolla $ign | Bacc Seat | 37 | 33 | 156 | loose |
| Ty Dolla $ign | Bacc to Winning | 44 | 74 | 152 | loose |
| Ty Dolla $ign | Back | 50 | 46 | 446 | loose |
| Ty Dolla $ign | Back Out | 37 | 24 | 136 | loose |
| Ty Dolla $ign | Back Up | 30 | 20 | 95 | loose |
| Ty Dolla $ign | Back in the City | 20 | 25 | 26 | loose |
| Ty Dolla $ign | Back of My Mind | 36 | 39 | 130 | loose |
| Ty Dolla $ign | Back to You (Demo) | 33 | 26 | 80 | loose |
| Ty Dolla $ign | Bacon | 27 | 7 | 92 | loose |
| Ty Dolla $ign | Bad & U Know It | 24 | 13 | 47 | loose |
| Ty Dolla $ign | Bad Bitch | 25 | 27 | 74 | loose |
| Ty Dolla $ign | Bae Af | 30 | 17 | 99 | loose |
| Ty Dolla $ign | Bag Of Trees | 27 | 23 | 69 | loose |
| Ty Dolla $ign | Ballerina (Remix) | 33 | 34 | 117 | loose |
| Ty Dolla $ign | Ballerina Tea | 29 | 14 | 98 | loose |
| Ty Dolla $ign | Bang My Line | 32 | 12 | 84 | loose |
| Ty Dolla $ign | Bang Your Line | 37 | 35 | 137 | loose |
| Ty Dolla $ign | Banger | 41 | 35 | 231 | loose |
| Ty Dolla $ign | Bankroll | 31 | 20 | 152 | loose |
| Ty Dolla $ign | Be My Lover | 43 | 21 | 101 | loose |
| Ty Dolla $ign | Beat It | 45 | 47 | 230 | loose |
| Ty Dolla $ign | Beat It Up | 27 | 11 | 66 | loose |
| Ty Dolla $ign | Bedroom Bully | 42 | 25 | 110 | loose |
| Ty Dolla $ign | Been a Long Time | 36 | 33 | 107 | loose |
| Ty Dolla $ign | Benz Boys | 43 | 39 | 270 | loose |
| Ty Dolla $ign | Besides Her | 30 | 31 | 130 | loose |
| Ty Dolla $ign | Best Friend | 37 | 30 | 114 | loose |
| Ty Dolla $ign | Better on Me | 38 | 15 | 136 | loose |
| Ty Dolla $ign | Bickin It | 30 | 25 | 96 | loose |
| Ty Dolla $ign | Big Body | 40 | 32 | 235 | loose |
| Ty Dolla $ign | Big Lie (Demo) | 37 | 30 | 92 | loose |
| Ty Dolla $ign | Big Mad | 50 | 44 | 231 | loose |
| Ty Dolla $ign | Big Tymin (Remix) | 51 | 42 | 144 | loose |
| Ty Dolla $ign | Bikini Bottom | 46 | 52 | 276 | loose |
| Ty Dolla $ign | Billionaires | 34 | 34 | 160 | loose |
| Ty Dolla $ign | Birthday | 39 | 34 | 93 | loose |
| Ty Dolla $ign | Bitches Ain’t Shit / Get It How I Live | 39 | 27 | 177 | loose |
| Ty Dolla $ign | Bitches Do Voodoo | 35 | 75 | 31 | loose |
| Ty Dolla $ign | Blah Blah Blah (Remix) | 75 | 44 | 213 | loose |
| Ty Dolla $ign | Blasé | 38 | 18 | 193 | loose |
| Ty Dolla $ign | Blessed | 38 | 35 | 305 | loose |
| Ty Dolla $ign | Blessings (Reprise) | 36 | 16 | 146 | loose |
| Ty Dolla $ign | Blow My Mind | 18 | 17 | 57 | loose |
| Ty Dolla $ign | Body Language | 36 | 22 | 180 | loose |
| Ty Dolla $ign | Boo Nop Woo Wop | 43 | 17 | 157 | loose |
| Ty Dolla $ign | Boom | 28 | 8 | 87 | loose |
| Ty Dolla $ign | Boothang | 53 | 35 | 238 | loose |
| Ty Dolla $ign | Booty Poppin | 20 | 14 | 45 | loose |
| Ty Dolla $ign | Bottled Up | 27 | 10 | 87 | loose |
| Ty Dolla $ign | Bouncin | 57 | 66 | 290 | loose |
| Ty Dolla $ign | Boyz in the Hood | 78 | 75 | 402 | loose |
| Ty Dolla $ign | Brand New | 48 | 48 | 97 | loose |
| Ty Dolla $ign | Breaking Point (Live From NPR’s Tiny Desk) | 31 | 26 | 51 | loose |
| Ty Dolla $ign | Breakin’ U Off | 47 | 51 | 184 | loose |
| Ty Dolla $ign | Breather | 60 | 79 | 143 | loose |
| Ty Dolla $ign | Bright Lights | 25 | 30 | 72 | loose |
| Ty Dolla $ign | Bring It Out of Me | 29 | 8 | 65 | loose |
| Ty Dolla $ign | Built A City Underground | 5 | 0 | 18 | loose |
| Ty Dolla $ign | Bumpy Ride (Dolla $ign Remix) | 31 | 21 | 158 | loose |
| Ty Dolla $ign | Burn Sumn | 39 | 25 | 96 | loose |
| Ty Dolla $ign | Burna Boy Interlude | 9 | 4 | 8 | loose |
| Ty Dolla $ign | Bussin’ Out | 42 | 58 | 211 | loose |
| Ty Dolla $ign | But I Did | 17 | 20 | 33 | loose |
| Ty Dolla $ign | By Your Side | 26 | 13 | 67 | loose |
| Ty Dolla $ign | By Yourself | 33 | 27 | 152 | loose |
| Ty Dolla $ign | Bye Bye | 31 | 20 | 352 | loose |
| Ty Dolla $ign | CAGE GIRL | 27 | 14 | 73 | loose |
| Ty Dolla $ign | CAN U BE | 63 | 44 | 181 | loose |
| Ty Dolla $ign | CAN’T BE FUCKED WITH | 40 | 64 | 110 | loose |
| Ty Dolla $ign | CAN’T HURRY LOVE | 18 | 3 | 36 | loose |
| Ty Dolla $ign | CARNIVAL (HONOR ROLL) [Demo] | 9 | 2 | 61 | loose |
| Ty Dolla $ign | CHANCES ALL | 1 | 0 | 0 | loose |
| Ty Dolla $ign | CITY UNDERGROUND | 9 | 2 | 16 | loose |
| Ty Dolla $ign | COLD FEET | 34 | 45 | 229 | loose |
| Ty Dolla $ign | COLE PIMP | 40 | 25 | 338 | loose |
| Ty Dolla $ign | CRAZY | 33 | 33 | 83 | loose |
| Ty Dolla $ign | CRY FOR ME | 30 | 29 | 214 | loose |
| Ty Dolla $ign | Callin’ | 51 | 80 | 149 | loose |
| Ty Dolla $ign | Campaign | 45 | 28 | 168 | loose |
| Ty Dolla $ign | Can You Feel It | 6 | 2 | 4 | loose |
| Ty Dolla $ign | Can You Take It (Interlude) | 16 | 8 | 36 | loose |
| Ty Dolla $ign | Can’t Believe | 45 | 46 | 177 | loose |
| Ty Dolla $ign | Can’t Fade Us | 53 | 57 | 292 | loose |
| Ty Dolla $ign | Can’t Go | 37 | 43 | 116 | loose |
| Ty Dolla $ign | Can’t Go for That | 35 | 35 | 155 | loose |
| Ty Dolla $ign | Can’t Shake Her | 26 | 19 | 89 | loose |
| Ty Dolla $ign | Can’t Stay | 44 | 18 | 161 | loose |
| Ty Dolla $ign | Can’t Tell | 40 | 26 | 147 | loose |
| Ty Dolla $ign | Carnival (Version 1) | 37 | 35 | 125 | loose |
| Ty Dolla $ign | Caught A Body | 11 | 4 | 32 | loose |
| Ty Dolla $ign | Change (Demo) | 6 | 2 | 35 | loose |
| Ty Dolla $ign | Change the Game | 42 | 38 | 293 | loose |
| Ty Dolla $ign | Chapo’s Daughter | 39 | 26 | 187 | loose |
| Ty Dolla $ign | Chasing A Feeling | 25 | 11 | 52 | loose |
| Ty Dolla $ign | Chew It Up | 28 | 17 | 86 | loose |
| Ty Dolla $ign | Childish | 35 | 32 | 99 | loose |
| Ty Dolla $ign | Children* | 14 | 11 | 80 | loose |
| Ty Dolla $ign | Chitty Bang | 36 | 33 | 227 | loose |
| Ty Dolla $ign | Chloe | 43 | 50 | 190 | loose |
| Ty Dolla $ign | Choose Up | 49 | 27 | 288 | loose |
| Ty Dolla $ign | Choosey | 39 | 28 | 88 | loose |
| Ty Dolla $ign | Chose | 41 | 29 | 124 | loose |
| Ty Dolla $ign | Chosen | 34 | 47 | 166 | loose |
| Ty Dolla $ign | Chucks | 22 | 7 | 51 | loose |
| Ty Dolla $ign | Church (West Coast Remix) | 45 | 39 | 229 | loose |
| Ty Dolla $ign | Circles | 51 | 38 | 83 | loose |
| Ty Dolla $ign | City In The Sky (Freestyle) | 53 | 37 | 172 | loose |
| Ty Dolla $ign | Clean | 33 | 27 | 30 | loose |
| Ty Dolla $ign | Clout | 27 | 17 | 91 | loose |
| Ty Dolla $ign | Codeine Kisses | 15 | 9 | 26 | loose |
| Ty Dolla $ign | Coi Leray Diamonds | 32 | 32 | 285 | loose |
| Ty Dolla $ign | Come Correct | 39 | 24 | 122 | loose |
| Ty Dolla $ign | Come Down (Remix 2) | 42 | 12 | 190 | loose |
| Ty Dolla $ign | Come Get Her | 51 | 35 | 180 | loose |
| Ty Dolla $ign | Come Up Off | 19 | 13 | 88 | loose |
| Ty Dolla $ign | Control | 40 | 29 | 60 | loose |
| Ty Dolla $ign | Cookies & OG | 41 | 36 | 246 | loose |
| Ty Dolla $ign | Cosmos | 6 | 0 | 5 | loose |
| Ty Dolla $ign | Could’ve Been Fucking Years Ago | 21 | 12 | 110 | loose |
| Ty Dolla $ign | Count Me Out | 40 | 26 | 103 | loose |
| Ty Dolla $ign | Coupe | 24 | 17 | 103 | loose |
| Ty Dolla $ign | Credit | 56 | 20 | 230 | loose |
| Ty Dolla $ign | Creez | 45 | 35 | 132 | loose |
| Ty Dolla $ign | Crush | 33 | 19 | 95 | loose |
| Ty Dolla $ign | Cut It Out (Remix) | 32 | 29 | 93 | loose |
| Ty Dolla $ign | D.F.W.T | 69 | 74 | 292 | loose |
| Ty Dolla $ign | DALLAX | 18 | 7 | 157 | loose |
| Ty Dolla $ign | DEAD | 13 | 5 | 63 | loose |
| Ty Dolla $ign | DECEMBER 31ST | 40 | 46 | 248 | loose |
| Ty Dolla $ign | DND | 31 | 28 | 198 | loose |
| Ty Dolla $ign | DO IT | 65 | 72 | 180 | loose |
| Ty Dolla $ign | DOIN IT FOR DOLLA* | 18 | 3 | 41 | loose |
| Ty Dolla $ign | DOIN’ A LOOK | 60 | 36 | 274 | loose |
| Ty Dolla $ign | DON’T KILL THE PARTY | 56 | 57 | 169 | loose |
| Ty Dolla $ign | DOORS UNLOCKED | 30 | 38 | 137 | loose |
| Ty Dolla $ign | DORIME | 30 | 14 | 80 | loose |
| Ty Dolla $ign | DRUNK | 12 | 7 | 308 | loose |
| Ty Dolla $ign | DTF | 33 | 23 | 156 | loose |
| Ty Dolla $ign | DUSTY | 44 | 20 | 260 | loose |
| Ty Dolla $ign | Damn Gloves | 14 | 15 | 65 | loose |
| Ty Dolla $ign | Dancin’ From Home | 20 | 13 | 58 | loose |
| Ty Dolla $ign | Dangerous | 44 | 33 | 174 | loose |
| Ty Dolla $ign | Dangerous City | 46 | 49 | 220 | loose |
| Ty Dolla $ign | Darkside | 46 | 33 | 155 | loose |
| Ty Dolla $ign | Dawsin’s Breek | 27 | 15 | 103 | loose |
| Ty Dolla $ign | Dead Presidents | 59 | 55 | 358 | loose |
| Ty Dolla $ign | Dead Wrong | 36 | 27 | 185 | loose |
| Ty Dolla $ign | Deliver | 56 | 88 | 387 | loose |
| Ty Dolla $ign | Demon Time | 39 | 39 | 114 | loose |
| Ty Dolla $ign | Designer Drugs | 12 | 8 | 87 | loose |
| Ty Dolla $ign | Diamond Mind | 60 | 102 | 288 | loose |
| Ty Dolla $ign | Dick Tonight | 16 | 7 | 54 | loose |
| Ty Dolla $ign | Didn’t I (Say I Didn’t) | 82 | 37 | 402 | loose |
| Ty Dolla $ign | Diggin’ | 39 | 24 | 206 | loose |
| Ty Dolla $ign | Dip | 44 | 41 | 169 | loose |
| Ty Dolla $ign | Dippin N Sippin | 44 | 32 | 230 | loose |
| Ty Dolla $ign | Dirty Mind | 30 | 10 | 62 | loose |
| Ty Dolla $ign | Dirty Wine | 27 | 15 | 59 | loose |
| Ty Dolla $ign | Dis Bitch Dat Hoe | 24 | 9 | 90 | loose |
| Ty Dolla $ign | Do Betta | 41 | 19 | 195 | loose |
| Ty Dolla $ign | Do Thangs | 15 | 8 | 77 | loose |
| Ty Dolla $ign | Do Ya | 37 | 28 | 71 | loose |
| Ty Dolla $ign | Do Yo Dance | 53 | 43 | 183 | loose |
| Ty Dolla $ign | Do You Believe | 25 | 16 | 88 | loose |
| Ty Dolla $ign | Do You Mean | 27 | 10 | 54 | loose |
| Ty Dolla $ign | Do You Really Mean | 19 | 15 | 21 | loose |
| Ty Dolla $ign | Do You Wanna (Snippet) | 5 | 1 | 5 | loose |
| Ty Dolla $ign | Dodgers Anthem | 34 | 15 | 213 | loose |
| Ty Dolla $ign | Dolla $ign | 44 | 28 | 119 | loose |
| Ty Dolla $ign | Dolla $ign / My Cabana Remix | 17 | 12 | 67 | loose |
| Ty Dolla $ign | Dolla Bills | 23 | 5 | 30 | loose |
| Ty Dolla $ign | Don’t Get Much Better | 40 | 55 | 152 | loose |
| Ty Dolla $ign | Don’t Go | 19 | 6 | 81 | loose |
| Ty Dolla $ign | Don’t Judge Me | 46 | 43 | 213 | loose |
| Ty Dolla $ign | Don’t Kill The Party x Drunk and Nasty (FS Green remix) | 21 | 8 | 63 | loose |
| Ty Dolla $ign | Don’t Play With Me | 45 | 34 | 92 | loose |
| Ty Dolla $ign | Don’t Say A Word | 29 | 14 | 85 | loose |
| Ty Dolla $ign | Don’t Sleep on Me | 60 | 43 | 173 | loose |
| Ty Dolla $ign | Don’t Stop | 29 | 30 | 137 | loose |
| Ty Dolla $ign | Don’t Tell ’Em (Remix) | 50 | 29 | 143 | loose |
| Ty Dolla $ign | Don’t Text Don’t Call | 33 | 29 | 130 | loose |
| Ty Dolla $ign | Dope (Snippet) | 5 | 1 | 3 | loose |
| Ty Dolla $ign | Double Dip | 54 | 39 | 235 | loose |
| Ty Dolla $ign | Double Dribble | 36 | 18 | 121 | loose |
| Ty Dolla $ign | Double R | 35 | 27 | 157 | loose |
| Ty Dolla $ign | Down On Me | 42 | 14 | 122 | loose |
| Ty Dolla $ign | Dr. Sebi | 24 | 27 | 99 | loose |
| Ty Dolla $ign | Drank N Cranberry | 41 | 28 | 137 | loose |
| Ty Dolla $ign | Dream Girl | 29 | 37 | 80 | loose |
| Ty Dolla $ign | Dreams | 46 | 26 | 154 | loose |
| Ty Dolla $ign | Drink You Away | 24 | 9 | 68 | loose |
| Ty Dolla $ign | Drive | 49 | 20 | 208 | loose |
| Ty Dolla $ign | Drones | 34 | 11 | 125 | loose |
| Ty Dolla $ign | Drop That Kitty | 37 | 16 | 72 | loose |
| Ty Dolla $ign | Droptop in the Rain | 25 | 11 | 40 | loose |
| Ty Dolla $ign | Drugs | 26 | 27 | 117 | loose |
| Ty Dolla $ign | Drunk AF | 36 | 14 | 134 | loose |
| Ty Dolla $ign | EVERYBODY | 4 | 1 | 9 | loose |
| Ty Dolla $ign | EVERYTHING / Once Again (Original) | 14 | 0 | 19 | loose |
| Ty Dolla $ign | Eat | 51 | 31 | 246 | loose |
| Ty Dolla $ign | Eat The Pussy | 45 | 30 | 189 | loose |
| Ty Dolla $ign | Ego | 35 | 17 | 168 | loose |
| Ty Dolla $ign | Ego Death | 49 | 27 | 192 | loose |
| Ty Dolla $ign | Embrace It | 45 | 53 | 125 | loose |
| Ty Dolla $ign | End Of Discussion | 54 | 25 | 234 | loose |
| Ty Dolla $ign | Enormous | 36 | 26 | 124 | loose |
| Ty Dolla $ign | Envy | 11 | 4 | 70 | loose |
| Ty Dolla $ign | Ever Again* | 17 | 7 | 52 | loose |
| Ty Dolla $ign | Ever Since U Left Me (West Coast Remix) | 38 | 30 | 149 | loose |
| Ty Dolla $ign | Everybody’s | 9 | 5 | 24 | loose |
| Ty Dolla $ign | Everyday (Evolved) | 31 | 21 | 185 | loose |
| Ty Dolla $ign | Everything | 51 | 61 | 255 | loose |
| Ty Dolla $ign | Everything 100 | 47 | 51 | 294 | loose |
| Ty Dolla $ign | Everything We Need | 16 | 9 | 30 | loose |
| Ty Dolla $ign | Everywhere | 22 | 21 | 50 | loose |
| Ty Dolla $ign | Evolution of Girl Groups | 92 | 52 | 209 | loose |
| Ty Dolla $ign | Ex | 27 | 24 | 111 | loose |
| Ty Dolla $ign | Excited | 27 | 24 | 155 | loose |
| Ty Dolla $ign | Expensive | 31 | 31 | 100 | loose |
| Ty Dolla $ign | Extra | 37 | 35 | 103 | loose |
| Ty Dolla $ign | F with U | 37 | 17 | 119 | loose |
| Ty Dolla $ign | FADED | 32 | 15 | 74 | loose |
| Ty Dolla $ign | FAR FETCHED | 32 | 25 | 67 | loose |
| Ty Dolla $ign | FAST CAR! | 33 | 37 | 121 | loose |
| Ty Dolla $ign | FIELD TRIP (Demo) | 55 | 49 | 252 | loose |
| Ty Dolla $ign | FOR THE STREETS (HELLO) | 41 | 35 | 140 | loose |
| Ty Dolla $ign | FOREVER | 28 | 32 | 175 | loose |
| Ty Dolla $ign | FOREVER ROLLING | 52 | 43 | 386 | loose |
| Ty Dolla $ign | FORTUNE AND FAME | 30 | 24 | 72 | loose |
| Ty Dolla $ign | FORTY YEARS OLD | 24 | 28 | 124 | loose |
| Ty Dolla $ign | FRIED | 32 | 71 | 99 | loose |
| Ty Dolla $ign | FUCK FLOWERS | 23 | 10 | 99 | loose |
| Ty Dolla $ign | FUK SUMN | 37 | 23 | 161 | loose |
| Ty Dolla $ign | FUK SUMN Pt. 2 | 14 | 7 | 116 | loose |
| Ty Dolla $ign | FYT | 49 | 21 | 142 | loose |
| Ty Dolla $ign | Fade (Demo) | 16 | 22 | 46 | loose |
| Ty Dolla $ign | Fair Chance | 30 | 17 | 60 | loose |
| Ty Dolla $ign | Faithful | 40 | 25 | 95 | loose |
| Ty Dolla $ign | Fakin | 53 | 28 | 148 | loose |
| Ty Dolla $ign | Fallen | 43 | 25 | 159 | loose |
| Ty Dolla $ign | Familiar | 51 | 29 | 201 | loose |
| Ty Dolla $ign | Family | 32 | 22 | 124 | loose |
| Ty Dolla $ign | Famous | 27 | 11 | 79 | loose |
| Ty Dolla $ign | Famous Excuses | 7 | 2 | 15 | loose |
| Ty Dolla $ign | Famous Friends | 5 | 0 | 6 | loose |
| Ty Dolla $ign | Famous Lies | 6 | 4 | 15 | loose |
| Ty Dolla $ign | Father’s Day | 32 | 41 | 149 | loose |
| Ty Dolla $ign | Favorite | 46 | 44 | 368 | loose |
| Ty Dolla $ign | Favorite Bitch | 93 | 64 | 610 | loose |
| Ty Dolla $ign | Favorite Girl | 27 | 34 | 81 | loose |
| Ty Dolla $ign | Feathers | 36 | 37 | 165 | loose |
| Ty Dolla $ign | Feel a Vibe | 9 | 1 | 17 | loose |
| Ty Dolla $ign | Feeling* | 3 | 1 | 2 | loose |
| Ty Dolla $ign | Feels Like Summer | 54 | 41 | 229 | loose |
| Ty Dolla $ign | Fill The Room Up | 26 | 21 | 113 | loose |
| Ty Dolla $ign | Finale | 22 | 18 | 41 | loose |
| Ty Dolla $ign | Find Out | 26 | 10 | 50 | loose |
| Ty Dolla $ign | Finnessin’ | 27 | 14 | 22 | loose |
| Ty Dolla $ign | Fire | 22 | 12 | 36 | loose |
| Ty Dolla $ign | Five Real | 13 | 14 | 38 | loose |
| Ty Dolla $ign | Five-0 | 34 | 34 | 119 | loose |
| Ty Dolla $ign | Float | 30 | 31 | 123 | loose |
| Ty Dolla $ign | Flood | 48 | 32 | 151 | loose |
| Ty Dolla $ign | Flowers | 33 | 21 | 102 | loose |
| Ty Dolla $ign | For A Real 1 | 45 | 50 | 180 | loose |
| Ty Dolla $ign | For Life | 43 | 31 | 179 | loose |
| Ty Dolla $ign | For More | 61 | 32 | 393 | loose |
| Ty Dolla $ign | Forbidden Fruit | 21 | 27 | 42 | loose |
| Ty Dolla $ign | Forever 21 | 11 | 5 | 39 | loose |
| Ty Dolla $ign | Forever Rollin’ (Demo) | 18 | 36 | 173 | loose |
| Ty Dolla $ign | Four Five Seconds | 13 | 7 | 34 | loose |
| Ty Dolla $ign | FourFiveSeconds (Live at Power Station) | 4 | 2 | 6 | loose |
| Ty Dolla $ign | Freak | 40 | 43 | 156 | loose |
| Ty Dolla $ign | Freak You | 15 | 3 | 25 | loose |
| Ty Dolla $ign | Free TC | 42 | 36 | 191 | loose |
| Ty Dolla $ign | Freeee (Ghost Town, Pt. 2) | 22 | 3 | 54 | loose |
| Ty Dolla $ign | Friday Night | 41 | 37 | 140 | loose |
| Ty Dolla $ign | Friend of Scotty | 42 | 39 | 169 | loose |
| Ty Dolla $ign | Friends | 42 | 13 | 65 | loose |
| Ty Dolla $ign | Fuck That Nigga | 48 | 30 | 163 | loose |
| Ty Dolla $ign | Fuck Y’all | 44 | 23 | 146 | loose |
| Ty Dolla $ign | Fuckin’ Tonight | 31 | 18 | 53 | loose |
| Ty Dolla $ign | Fuego | 42 | 32 | 120 | loose |
| Ty Dolla $ign | Full Circle | 29 | 19 | 38 | loose |
| Ty Dolla $ign | Full House | 40 | 27 | 188 | loose |
| Ty Dolla $ign | Fumble | 28 | 14 | 75 | loose |
| Ty Dolla $ign | Function Freestyle | 35 | 43 | 251 | loose |
| Ty Dolla $ign | G.O.A.T. | 59 | 28 | 318 | loose |
| Ty Dolla $ign | G.P.E. (Good Pussy Energy) | 38 | 32 | 123 | loose |
| Ty Dolla $ign | GET RICH | 29 | 42 | 121 | loose |
| Ty Dolla $ign | GO AHEAD | 29 | 17 | 103 | loose |
| Ty Dolla $ign | GO!* | 8 | 3 | 20 | loose |
| Ty Dolla $ign | GOOD (DON’T DIE) | 10 | 16 | 98 | loose |
| Ty Dolla $ign | GUN TO MY HEAD | 30 | 36 | 108 | loose |
| Ty Dolla $ign | GYU | 44 | 29 | 167 | loose |
| Ty Dolla $ign | Ga$ Leak | 40 | 22 | 243 | loose |
| Ty Dolla $ign | Gangsta | 61 | 26 | 155 | loose |
| Ty Dolla $ign | Garden | 24 | 9 | 58 | loose |
| Ty Dolla $ign | Gas Station | 31 | 57 | 117 | loose |
| Ty Dolla $ign | Geek’d Up | 38 | 38 | 149 | loose |
| Ty Dolla $ign | Geronimo | 40 | 22 | 151 | loose |
| Ty Dolla $ign | Get Along Better | 40 | 64 | 167 | loose |
| Ty Dolla $ign | Get It | 22 | 7 | 44 | loose |
| Ty Dolla $ign | Get It How I Live | 22 | 10 | 70 | loose |
| Ty Dolla $ign | Get Money | 22 | 5 | 39 | loose |
| Ty Dolla $ign | Get No Better | 6 | 2 | 10 | loose |
| Ty Dolla $ign | Get Right | 6 | 3 | 29 | loose |
| Ty Dolla $ign | Gettin 2 It | 47 | 19 | 166 | loose |
| Ty Dolla $ign | Giant | 28 | 13 | 55 | loose |
| Ty Dolla $ign | Gimme A Second 2 | 49 | 73 | 298 | loose |
| Ty Dolla $ign | Gimme Your Number | 25 | 24 | 95 | loose |
| Ty Dolla $ign | Girlfriend (Remix) | 63 | 29 | 160 | loose |
| Ty Dolla $ign | Girl’s Best Friend | 35 | 28 | 128 | loose |
| Ty Dolla $ign | Glock Glock! | 41 | 84 | 164 | loose |
| Ty Dolla $ign | Glowin | 46 | 40 | 245 | loose |
| Ty Dolla $ign | Go Deep | 42 | 42 | 198 | loose |
| Ty Dolla $ign | Go Get It | 44 | 31 | 151 | loose |
| Ty Dolla $ign | Go Get Sum Mo | 91 | 69 | 352 | loose |
| Ty Dolla $ign | Go Hard Or Go Home (Part 2) | 52 | 46 | 215 | loose |
| Ty Dolla $ign | Go Pro | 53 | 44 | 174 | loose |
| Ty Dolla $ign | Go So Deep | 47 | 25 | 192 | loose |
| Ty Dolla $ign | Go Without Her | 29 | 17 | 93 | loose |
| Ty Dolla $ign | Goin Thru Some Thangz | 26 | 24 | 83 | loose |
| Ty Dolla $ign | Goin Up | 41 | 34 | 244 | loose |
| Ty Dolla $ign | Gone | 26 | 7 | 82 | loose |
| Ty Dolla $ign | Good Enough | 43 | 17 | 161 | loose |
| Ty Dolla $ign | Good Pussy | 46 | 32 | 190 | loose |
| Ty Dolla $ign | Good Thing | 50 | 51 | 325 | loose |
| Ty Dolla $ign | Good To Ya | 48 | 23 | 171 | loose |
| Ty Dolla $ign | Gorgeous | 15 | 6 | 33 | loose |
| Ty Dolla $ign | Got Me | 58 | 41 | 306 | loose |
| Ty Dolla $ign | Got My Heart (Original Version) | 20 | 14 | 69 | loose |
| Ty Dolla $ign | Got My Heart / Outro | 59 | 28 | 330 | loose |
| Ty Dolla $ign | Got My Shit Together | 37 | 11 | 194 | loose |
| Ty Dolla $ign | Gotta Have It | 54 | 41 | 241 | loose |
| Ty Dolla $ign | Gotta Love It | 57 | 43 | 218 | loose |
| Ty Dolla $ign | Gracious | 28 | 21 | 89 | loose |
| Ty Dolla $ign | Greedy | 51 | 38 | 176 | loose |
| Ty Dolla $ign | Guard Down | 58 | 33 | 216 | loose |
| Ty Dolla $ign | H.O.E (Heaven On Earth) | 24 | 13 | 49 | loose |
| Ty Dolla $ign | HARDER | 34 | 30 | 94 | loose |
| Ty Dolla $ign | HAVING FUN | 29 | 56 | 122 | loose |
| Ty Dolla $ign | HBIC | 39 | 22 | 187 | loose |
| Ty Dolla $ign | HIGH & HOLY | 61 | 48 | 421 | loose |
| Ty Dolla $ign | HIGHS AND LOWS | 12 | 22 | 44 | loose |
| Ty Dolla $ign | HOLLYWOOD | 48 | 57 | 246 | loose |
| Ty Dolla $ign | HOODRAT | 37 | 29 | 136 | loose |
| Ty Dolla $ign | HOW FAST | 23 | 14 | 79 | loose |
| Ty Dolla $ign | Hands Off (Demo) | 38 | 42 | 83 | loose |
| Ty Dolla $ign | Hanging Up My Jersey | 53 | 25 | 103 | loose |
| Ty Dolla $ign | Have It All | 40 | 29 | 130 | loose |
| Ty Dolla $ign | He Ain’t Shit | 40 | 36 | 106 | loose |
| Ty Dolla $ign | Head Down | 42 | 50 | 275 | loose |
| Ty Dolla $ign | Headband | 57 | 61 | 274 | loose |
| Ty Dolla $ign | Heartbeat | 57 | 56 | 243 | loose |
| Ty Dolla $ign | Heels & Dresses | 42 | 21 | 195 | loose |
| Ty Dolla $ign | Hello | 29 | 12 | 44 | loose |
| Ty Dolla $ign | Henny And The Gin | 39 | 24 | 132 | loose |
| Ty Dolla $ign | Hey Hey | 17 | 10 | 34 | loose |
| Ty Dolla $ign | Hey Ty | 33 | 8 | 86 | loose |
| Ty Dolla $ign | Hey Up There | 42 | 33 | 113 | loose |
| Ty Dolla $ign | Highgrade | 38 | 49 | 94 | loose |
| Ty Dolla $ign | Hit Different | 28 | 10 | 137 | loose |
| Ty Dolla $ign | Hit Different [Remix] [Mixed] [Fluidity 4] | 7 | 3 | 88 | loose |
| Ty Dolla $ign | Hit The Pint | 24 | 29 | 86 | loose |
| Ty Dolla $ign | Hole in the Apple | 49 | 31 | 148 | loose |
| Ty Dolla $ign | Holy Moly | 24 | 14 | 90 | loose |
| Ty Dolla $ign | Home | 34 | 16 | 101 | loose |
| Ty Dolla $ign | Homiesexual | 35 | 23 | 141 | loose |
| Ty Dolla $ign | Hope | 49 | 29 | 325 | loose |
| Ty Dolla $ign | Horses In the Stable | 23 | 11 | 77 | loose |
| Ty Dolla $ign | Hot Girl Summer | 45 | 42 | 343 | loose |
| Ty Dolla $ign | Hot Sauce (Version 2) | 12 | 4 | 47 | loose |
| Ty Dolla $ign | Hotel | 53 | 42 | 233 | loose |
| Ty Dolla $ign | Hottest in the City | 42 | 47 | 210 | loose |
| Ty Dolla $ign | House Music | 23 | 20 | 95 | loose |
| Ty Dolla $ign | House On The Hill | 23 | 8 | 49 | loose |
| Ty Dolla $ign | Hurricane (Young Thug & Ty Dolla $ign Version) | 38 | 33 | 194 | loose |
| Ty Dolla $ign | I Apologize | 67 | 62 | 394 | loose |
| Ty Dolla $ign | I Believed It | 66 | 43 | 279 | loose |
| Ty Dolla $ign | I Bet | 43 | 26 | 164 | loose |
| Ty Dolla $ign | I Don’t Belong to You (Remix) | 37 | 17 | 132 | loose |
| Ty Dolla $ign | I Feel Free [Version 10] | 11 | 0 | 43 | loose |
| Ty Dolla $ign | I Feel Like That (Album Version) | 8 | 16 | 33 | loose |
| Ty Dolla $ign | I Got Bitches | 43 | 20 | 180 | loose |
| Ty Dolla $ign | I Just Wanna Know | 52 | 65 | 246 | loose |
| Ty Dolla $ign | I Know How It Feel | 48 | 43 | 186 | loose |
| Ty Dolla $ign | I Like (Demo) | 11 | 2 | 38 | loose |
| Ty Dolla $ign | I Love You | 44 | 32 | 216 | loose |
| Ty Dolla $ign | I Need Your Love | 37 | 21 | 130 | loose |
| Ty Dolla $ign | I Think About You | 12 | 14 | 89 | loose |
| Ty Dolla $ign | I Think She Like Me | 59 | 53 | 250 | loose |
| Ty Dolla $ign | I WISH | 27 | 23 | 61 | loose |
| Ty Dolla $ign | I Want Her | 19 | 7 | 34 | loose |
| Ty Dolla $ign | I Want You | 30 | 13 | 57 | loose |
| Ty Dolla $ign | I Won | 48 | 39 | 194 | loose |
| Ty Dolla $ign | IGNORANT | 31 | 25 | 196 | loose |
| Ty Dolla $ign | IN FELUL TĂU | 36 | 20 | 429 | loose |
| Ty Dolla $ign | ISABELLA [BONUS TRACK] | 13 | 4 | 146 | loose |
| Ty Dolla $ign | IT’S GIVIN | 49 | 83 | 288 | loose |
| Ty Dolla $ign | Ice Cream | 32 | 20 | 140 | loose |
| Ty Dolla $ign | Icee | 25 | 28 | 93 | loose |
| Ty Dolla $ign | If I Fall | 58 | 70 | 165 | loose |
| Ty Dolla $ign | If I Had You | 26 | 24 | 143 | loose |
| Ty Dolla $ign | Imitate | 18 | 8 | 43 | loose |
| Ty Dolla $ign | Impatient | 39 | 18 | 145 | loose |
| Ty Dolla $ign | In Her Lane | 38 | 20 | 198 | loose |
| Ty Dolla $ign | In My Foreign | 31 | 32 | 147 | loose |
| Ty Dolla $ign | In My Head | 33 | 33 | 181 | loose |
| Ty Dolla $ign | In My Room | 23 | 11 | 106 | loose |
| Ty Dolla $ign | In Some Trouble | 54 | 40 | 187 | loose |
| Ty Dolla $ign | In The Morning | 30 | 21 | 107 | loose |
| Ty Dolla $ign | In The Room | 52 | 58 | 319 | loose |
| Ty Dolla $ign | In Too Deep | 43 | 26 | 219 | loose |
| Ty Dolla $ign | In Your Feelings | 39 | 35 | 171 | loose |
| Ty Dolla $ign | In Your Phone | 23 | 10 | 35 | loose |
| Ty Dolla $ign | In tha Morning | 61 | 41 | 338 | loose |
| Ty Dolla $ign | Infinite Stripes | 30 | 10 | 125 | loose |
| Ty Dolla $ign | Inspiration | 22 | 19 | 55 | loose |
| Ty Dolla $ign | Integrity | 27 | 19 | 195 | loose |
| Ty Dolla $ign | Intro | 6 | 1 | 31 | loose |
| Ty Dolla $ign | Intro / These Hoes | 39 | 17 | 173 | loose |
| Ty Dolla $ign | Intro [Prod by DMile] | 24 | 13 | 115 | loose |
| Ty Dolla $ign | Irie | 46 | 20 | 246 | loose |
| Ty Dolla $ign | Irresistible Bitch | 36 | 20 | 106 | loose |
| Ty Dolla $ign | Is It Mine | 51 | 54 | 146 | loose |
| Ty Dolla $ign | Island | 61 | 50 | 191 | loose |
| Ty Dolla $ign | Issue | 27 | 23 | 154 | loose |
| Ty Dolla $ign | It’s Still Free TC | 9 | 0 | 27 | loose |
| Ty Dolla $ign | It’s a Vibe | 37 | 32 | 143 | loose |
| Ty Dolla $ign | I’ll Do Ya | 44 | 22 | 134 | loose |
| Ty Dolla $ign | I’m on 4.0 | 129 | 130 | 844 | loose |
| Ty Dolla $ign | I’m the $hit | 49 | 44 | 165 | loose |
| Ty Dolla $ign | JD BEAT | 31 | 51 | 158 | loose |
| Ty Dolla $ign | Jam | 60 | 28 | 267 | loose |
| Ty Dolla $ign | Jodeci | 39 | 25 | 149 | loose |
| Ty Dolla $ign | Jonah | 42 | 43 | 262 | loose |
| Ty Dolla $ign | Judge It | 36 | 24 | 133 | loose |
| Ty Dolla $ign | Juice (Remix) | 87 | 57 | 386 | loose |
| Ty Dolla $ign | Junya | 39 | 29 | 60 | loose |
| Ty Dolla $ign | Junya pt 2 | 33 | 27 | 44 | loose |
| Ty Dolla $ign | Just Fuckn | 30 | 26 | 77 | loose |
| Ty Dolla $ign | Just How You Are | 26 | 19 | 85 | loose |
| Ty Dolla $ign | Just the Bro | 48 | 44 | 214 | loose |
| Ty Dolla $ign | KEYS TO MY LIFE | 39 | 48 | 187 | loose |
| Ty Dolla $ign | KING | 25 | 16 | 83 | loose |
| Ty Dolla $ign | Keep Doin’ That (Rich Bitch) | 44 | 31 | 218 | loose |
| Ty Dolla $ign | Kill | 73 | 32 | 232 | loose |
| Ty Dolla $ign | Kill Me Tonight | 35 | 23 | 154 | loose |
| Ty Dolla $ign | King of The Fall (Remix) | 70 | 43 | 341 | loose |
| Ty Dolla $ign | Kissing New People | 30 | 21 | 91 | loose |
| Ty Dolla $ign | Kitchen Table (Remix) | 46 | 37 | 113 | loose |
| Ty Dolla $ign | Know U Ain’t Shit | 33 | 11 | 77 | loose |
| Ty Dolla $ign | Know Y I Came | 29 | 19 | 76 | loose |
| Ty Dolla $ign | Know Ya | 53 | 24 | 210 | loose |
| Ty Dolla $ign | L.A.LOVE (la la) (Unreleased Remix) | 63 | 34 | 166 | loose |
| Ty Dolla $ign | LA | 70 | 34 | 275 | loose |
| Ty Dolla $ign | LAST BREATH (First Pressing / Single Version) | 20 | 8 | 136 | loose |
| Ty Dolla $ign | LEMONADE | 45 | 33 | 188 | loose |
| Ty Dolla $ign | LET GO [V14] | 21 | 12 | 59 | loose |
| Ty Dolla $ign | LEXAPRO* | 10 | 1 | 27 | loose |
| Ty Dolla $ign | LIFESTYLE | 38 | 31 | 197 | loose |
| Ty Dolla $ign | LIKE THAT | 4 | 3 | 9 | loose |
| Ty Dolla $ign | LIKE THAT REMIX | 44 | 43 | 211 | loose |
| Ty Dolla $ign | LIKE YEAH! | 14 | 1 | 25 | loose |
| Ty Dolla $ign | LIT X3 | 27 | 10 | 68 | loose |
| Ty Dolla $ign | LOOP 20 (NICE TO MEET YOU Demo) | 7 | 0 | 39 | loose |
| Ty Dolla $ign | LOVE AGAIN | 18 | 8 | 53 | loose |
| Ty Dolla $ign | LOVE LOVE LOVE | 5 | 2 | 5 | ABCB |
| Ty Dolla $ign | LOVE ME THE MOST | 22 | 12 | 47 | loose |
| Ty Dolla $ign | LOVERS OR FRIENDS | 38 | 31 | 145 | loose |
| Ty Dolla $ign | Laid Up | 24 | 31 | 71 | loose |
| Ty Dolla $ign | Late Night King | 80 | 61 | 373 | loose |
| Ty Dolla $ign | Late to the Party | 62 | 82 | 265 | loose |
| Ty Dolla $ign | Lean On (Remix) | 26 | 18 | 79 | loose |
| Ty Dolla $ign | Leave LA | 33 | 16 | 104 | loose |
| Ty Dolla $ign | Leave Me Alone | 59 | 57 | 329 | loose |
| Ty Dolla $ign | Leg Over (Remix) | 37 | 16 | 147 | loose |
| Ty Dolla $ign | Let Down My Guard | 22 | 7 | 98 | loose |
| Ty Dolla $ign | Let Go (Ty Dolla $ign Reference) | 28 | 24 | 75 | loose |
| Ty Dolla $ign | Let You Go | 20 | 9 | 48 | loose |
| Ty Dolla $ign | Let’s Be Clear | 37 | 41 | 183 | loose |
| Ty Dolla $ign | Let’s Bick it | 27 | 23 | 96 | loose |
| Ty Dolla $ign | Let’s Get It | 30 | 11 | 123 | loose |
| Ty Dolla $ign | Let’s Ride (Trailer Anthem) | 35 | 31 | 75 | loose |
| Ty Dolla $ign | Lie 2 Kick It | 48 | 48 | 188 | loose |
| Ty Dolla $ign | Lie 2 Me | 30 | 28 | 194 | loose |
| Ty Dolla $ign | Lies | 32 | 30 | 114 | loose |
| Ty Dolla $ign | Lies & Dreams | 41 | 25 | 145 | loose |
| Ty Dolla $ign | Life Goes On (Ty Dolla $ign Remix) | 22 | 13 | 57 | loose |
| Ty Dolla $ign | Lifetime | 16 | 22 | 50 | loose |
| Ty Dolla $ign | Lift Me Up | 44 | 16 | 191 | loose |
| Ty Dolla $ign | Lights Out | 38 | 33 | 157 | loose |
| Ty Dolla $ign | Like I Do | 47 | 19 | 143 | loose |
| Ty Dolla $ign | Like That | 35 | 25 | 92 | loose |
| Ty Dolla $ign | Like This | 43 | 25 | 157 | loose |
| Ty Dolla $ign | Like You | 41 | 50 | 189 | loose |
| Ty Dolla $ign | Like a Drug | 43 | 19 | 87 | loose |
| Ty Dolla $ign | Like a Tornado | 24 | 13 | 93 | loose |
| Ty Dolla $ign | Lil Baby | 30 | 14 | 100 | loose |
| Ty Dolla $ign | Lil Favorite | 30 | 22 | 105 | loose |
| Ty Dolla $ign | Lil Freak | 36 | 26 | 52 | loose |
| Ty Dolla $ign | Lil Mama | 32 | 31 | 143 | loose |
| Ty Dolla $ign | Link Up | 34 | 20 | 126 | loose |
| Ty Dolla $ign | Liquor Locker | 49 | 22 | 166 | loose |
| Ty Dolla $ign | Lit (Remix) | 70 | 67 | 313 | loose |
| Ty Dolla $ign | Location | 33 | 29 | 82 | loose |
| Ty Dolla $ign | Locked In | 49 | 28 | 183 | loose |
| Ty Dolla $ign | Long Time | 38 | 48 | 107 | loose |
| Ty Dolla $ign | Look What I’ve Become | 33 | 25 | 153 | loose |
| Ty Dolla $ign | Loose Leaf | 26 | 21 | 95 | loose |
| Ty Dolla $ign | Lord Knows | 42 | 17 | 260 | loose |
| Ty Dolla $ign | Lord Of Chaos (Remix)* | 15 | 18 | 101 | loose |
| Ty Dolla $ign | Love Away | 26 | 10 | 71 | loose |
| Ty Dolla $ign | Love Crimes | 19 | 9 | 64 | loose |
| Ty Dolla $ign | Love Jones | 41 | 22 | 149 | loose |
| Ty Dolla $ign | Love Language | 32 | 9 | 162 | loose |
| Ty Dolla $ign | Love Me More | 26 | 12 | 74 | loose |
| Ty Dolla $ign | Love On You | 35 | 33 | 48 | loose |
| Ty Dolla $ign | Love U Better | 30 | 31 | 111 | loose |
| Ty Dolla $ign | Loving You | 40 | 25 | 123 | loose |
| Ty Dolla $ign | Low-Key (Remix) | 42 | 24 | 154 | loose |
| Ty Dolla $ign | Loyal (East Coast Version) | 30 | 11 | 109 | loose |
| Ty Dolla $ign | Lurkin’ | 40 | 14 | 86 | loose |
| Ty Dolla $ign | MATTHEW | 13 | 10 | 45 | loose |
| Ty Dolla $ign | MAYBE (Young Moose Version) | 22 | 21 | 69 | loose |
| Ty Dolla $ign | MELROSE | 37 | 40 | 155 | loose |
| Ty Dolla $ign | MIXED EMOTIONS | 45 | 46 | 274 | loose |
| Ty Dolla $ign | MUTT (Live From NPR’s Tiny Desk) | 18 | 15 | 73 | loose |
| Ty Dolla $ign | MY SOUL | 55 | 74 | 284 | loose |
| Ty Dolla $ign | Made In China | 24 | 17 | 58 | loose |
| Ty Dolla $ign | Make A Move | 43 | 5 | 106 | loose |
| Ty Dolla $ign | Make It Last | 29 | 17 | 94 | loose |
| Ty Dolla $ign | Make Me Rich | 36 | 44 | 262 | loose |
| Ty Dolla $ign | Make U Retire | 21 | 23 | 102 | loose |
| Ty Dolla $ign | Make Up | 32 | 21 | 67 | loose |
| Ty Dolla $ign | Make You Mine (Smile)* | 39 | 53 | 148 | loose |
| Ty Dolla $ign | Malokera | 42 | 25 | 170 | loose |
| Ty Dolla $ign | Mando | 42 | 31 | 181 | loose |
| Ty Dolla $ign | Master Teacher | 45 | 22 | 124 | loose |
| Ty Dolla $ign | Me | 33 | 25 | 94 | loose |
| Ty Dolla $ign | Me So Bad | 34 | 23 | 113 | loose |
| Ty Dolla $ign | Mean It | 41 | 49 | 297 | loose |
| Ty Dolla $ign | Medication (Remix) | 58 | 68 | 193 | loose |
| Ty Dolla $ign | Meet the Flockers | 35 | 33 | 146 | loose |
| Ty Dolla $ign | Memories | 34 | 24 | 44 | loose |
| Ty Dolla $ign | Message in a Bottle | 43 | 29 | 120 | loose |
| Ty Dolla $ign | Met Gala | 42 | 19 | 161 | loose |
| Ty Dolla $ign | Michael Jackson | 41 | 66 | 176 | loose |
| Ty Dolla $ign | Midnight Hour | 31 | 18 | 102 | loose |
| Ty Dolla $ign | Midnight Service | 55 | 32 | 254 | loose |
| Ty Dolla $ign | Might As Well | 44 | 20 | 88 | loose |
| Ty Dolla $ign | Minaj | 39 | 68 | 166 | loose |
| Ty Dolla $ign | Mind Games | 45 | 28 | 213 | loose |
| Ty Dolla $ign | Mind Your Business (Bosses in Love) | 43 | 29 | 143 | loose |
| Ty Dolla $ign | Mines | 35 | 21 | 132 | loose |
| Ty Dolla $ign | Mini Birki | 34 | 22 | 193 | loose |
| Ty Dolla $ign | Miracle / Wherever | 74 | 62 | 246 | loose |
| Ty Dolla $ign | Miss Me? | 21 | 17 | 85 | loose |
| Ty Dolla $ign | Missile | 34 | 31 | 112 | loose |
| Ty Dolla $ign | Mission | 36 | 65 | 189 | loose |
| Ty Dolla $ign | Missionary | 21 | 12 | 44 | loose |
| Ty Dolla $ign | Mix It Up | 27 | 15 | 89 | loose |
| Ty Dolla $ign | Mo Money | 36 | 40 | 135 | loose |
| Ty Dolla $ign | Model (You Ain’t No Model 2018 Ver.) | 67 | 48 | 179 | loose |
| Ty Dolla $ign | Money Ain’t Everything | 10 | 4 | 49 | loose |
| Ty Dolla $ign | Money Baby (Remix) | 45 | 34 | 271 | loose |
| Ty Dolla $ign | Money Ruin Friendships | 16 | 5 | 59 | loose |
| Ty Dolla $ign | Money Showers | 35 | 38 | 215 | loose |
| Ty Dolla $ign | Mood Swings | 16 | 11 | 82 | loose |
| Ty Dolla $ign | More / Diamond Ring | 24 | 6 | 91 | loose |
| Ty Dolla $ign | More Than A Friend | 26 | 34 | 102 | loose |
| Ty Dolla $ign | Mosh Pit | 51 | 77 | 258 | loose |
| Ty Dolla $ign | Motion | 11 | 6 | 28 | loose |
| Ty Dolla $ign | Motion [Mixed] | 10 | 5 | 28 | loose |
| Ty Dolla $ign | Motivation | 20 | 9 | 24 | loose |
| Ty Dolla $ign | Move to L.A. | 42 | 39 | 179 | loose |
| Ty Dolla $ign | Movin’ Up | 35 | 35 | 119 | loose |
| Ty Dolla $ign | Murder Charge | 31 | 12 | 78 | loose |
| Ty Dolla $ign | Muse (Writer’s Block Remix) | 22 | 4 | 49 | loose |
| Ty Dolla $ign | My Baby (Remix) | 54 | 32 | 166 | loose |
| Ty Dolla $ign | My Cabana | 32 | 18 | 103 | loose |
| Ty Dolla $ign | My Dear Love | 24 | 9 | 76 | loose |
| Ty Dolla $ign | My Flag/Da Homies | 102 | 69 | 514 | loose |
| Ty Dolla $ign | My Friends | 31 | 25 | 151 | loose |
| Ty Dolla $ign | My Last One | 13 | 0 | 54 | loose |
| Ty Dolla $ign | My Main | 50 | 28 | 164 | loose |
| Ty Dolla $ign | My Mind | 34 | 11 | 127 | loose |
| Ty Dolla $ign | My Own Thing | 17 | 15 | 54 | loose |
| Ty Dolla $ign | My Party | 25 | 15 | 73 | loose |
| Ty Dolla $ign | My Song | 37 | 30 | 75 | loose |
| Ty Dolla $ign | My Yea | 36 | 44 | 48 | loose |
| Ty Dolla $ign | NDK | 48 | 27 | 184 | loose |
| Ty Dolla $ign | NEXT TIME (MAKE IT FEEL RIGHT) | 22 | 10 | 58 | loose |
| Ty Dolla $ign | NGL | 83 | 40 | 185 | loose |
| Ty Dolla $ign | NO DISSAPOINTMENT | 8 | 10 | 23 | loose |
| Ty Dolla $ign | NO DRAMA | 31 | 24 | 286 | loose |
| Ty Dolla $ign | NOTHIN LIKE U | 35 | 21 | 90 | loose |
| Ty Dolla $ign | NRH | 23 | 13 | 75 | loose |
| Ty Dolla $ign | NSA | 15 | 5 | 57 | loose |
| Ty Dolla $ign | NYB (Need Your Best) | 32 | 22 | 119 | loose |
| Ty Dolla $ign | Naked | 37 | 14 | 121 | loose |
| Ty Dolla $ign | Nasty Freestyle [Remix] | 47 | 36 | 205 | loose |
| Ty Dolla $ign | Nate Howard Intro (BH3) | 16 | 9 | 27 | loose |
| Ty Dolla $ign | Need It Back | 63 | 61 | 281 | loose |
| Ty Dolla $ign | Neva Gon Leave | 26 | 16 | 139 | loose |
| Ty Dolla $ign | Never | 49 | 87 | 318 | loose |
| Ty Dolla $ign | Never 2 Much | 38 | 22 | 113 | loose |
| Ty Dolla $ign | Never Back Down | 23 | 6 | 45 | loose |
| Ty Dolla $ign | Never Be the Same | 47 | 40 | 228 | loose |
| Ty Dolla $ign | Never Fair | 34 | 76 | 258 | loose |
| Ty Dolla $ign | Never Would Have Made It | 16 | 7 | 44 | loose |
| Ty Dolla $ign | New Bitch | 32 | 30 | 179 | loose |
| Ty Dolla $ign | New Body | 53 | 52 | 249 | loose |
| Ty Dolla $ign | New Body [V8] | 23 | 24 | 88 | loose |
| Ty Dolla $ign | New Level | 15 | 14 | 25 | loose |
| Ty Dolla $ign | New One | 44 | 48 | 224 | loose |
| Ty Dolla $ign | New Sofas | 57 | 83 | 233 | loose |
| Ty Dolla $ign | Next To It | 67 | 56 | 498 | loose |
| Ty Dolla $ign | Nice Hotel | 9 | 8 | 58 | loose |
| Ty Dolla $ign | Night 2 Remember | 34 | 38 | 101 | loose |
| Ty Dolla $ign | Nights Like This | 31 | 20 | 144 | loose |
| Ty Dolla $ign | Nina (For My Bitches) | 24 | 8 | 36 | loose |
| Ty Dolla $ign | No Abus | 24 | 6 | 23 | loose |
| Ty Dolla $ign | No BFs | 36 | 25 | 108 | loose |
| Ty Dolla $ign | No Cuffin | 35 | 27 | 128 | loose |
| Ty Dolla $ign | No Fake $hit | 13 | 4 | 82 | loose |
| Ty Dolla $ign | No Favors | 27 | 12 | 67 | loose |
| Ty Dolla $ign | No Feelings | 48 | 24 | 254 | loose |
| Ty Dolla $ign | No Justice | 31 | 9 | 92 | loose |
| Ty Dolla $ign | No Love | 55 | 38 | 143 | loose |
| Ty Dolla $ign | No More | 30 | 25 | 197 | loose |
| Ty Dolla $ign | No No | 50 | 90 | 207 | loose |
| Ty Dolla $ign | No Panties | 40 | 17 | 119 | loose |
| Ty Dolla $ign | No Pressure | 28 | 11 | 114 | loose |
| Ty Dolla $ign | No Say So | 24 | 12 | 31 | loose |
| Ty Dolla $ign | No Sleep | 64 | 56 | 188 | loose |
| Ty Dolla $ign | No Smut On My Name | 39 | 18 | 198 | loose |
| Ty Dolla $ign | No Tomorrow | 6 | 1 | 11 | loose |
| Ty Dolla $ign | No Tomorrow, Pt. 2 | 24 | 15 | 92 | loose |
| Ty Dolla $ign | NoBody Else | 32 | 24 | 111 | loose |
| Ty Dolla $ign | Nobody Has To Know (Remix) | 40 | 16 | 160 | loose |
| Ty Dolla $ign | None Like U | 18 | 9 | 43 | loose |
| Ty Dolla $ign | None of Your Concern | 64 | 54 | 267 | loose |
| Ty Dolla $ign | None of Your Concern [Single Version] | 4 | 2 | 15 | loose |
| Ty Dolla $ign | Nonsense | 10 | 8 | 33 | loose |
| Ty Dolla $ign | Not It! | 34 | 25 | 174 | loose |
| Ty Dolla $ign | Not the Same | 27 | 30 | 110 | loose |
| Ty Dolla $ign | Nothing Like Your Exes | 30 | 19 | 98 | loose |
| Ty Dolla $ign | Nothin’ Like Me | 51 | 24 | 154 | loose |
| Ty Dolla $ign | Nothin’ Like Me [Mixed] | 33 | 8 | 46 | loose |
| Ty Dolla $ign | Numb* | 28 | 17 | 52 | loose |
| Ty Dolla $ign | Number | 27 | 16 | 64 | loose |
| Ty Dolla $ign | OCEAN 2077 | 39 | 11 | 303 | loose |
| Ty Dolla $ign | OMG | 34 | 5 | 47 | loose |
| Ty Dolla $ign | ON REPEAT | 31 | 50 | 163 | loose |
| Ty Dolla $ign | ON THE LOW | 42 | 47 | 176 | loose |
| Ty Dolla $ign | ON THESE HOES | 10 | 7 | 58 | loose |
| Ty Dolla $ign | ONE DAY AT A TIME | 20 | 29 | 149 | loose |
| Ty Dolla $ign | OT | 48 | 14 | 125 | loose |
| Ty Dolla $ign | OTW | 43 | 25 | 212 | loose |
| Ty Dolla $ign | OTW / Psycho | 9 | 6 | 62 | loose |
| Ty Dolla $ign | OUTTA LINE | 31 | 26 | 135 | loose |
| Ty Dolla $ign | Obvious | 29 | 27 | 97 | loose |
| Ty Dolla $ign | Off Guard | 26 | 14 | 62 | loose |
| Ty Dolla $ign | Off of It | 37 | 30 | 62 | loose |
| Ty Dolla $ign | Oh Yeah (Extended) | 10 | 3 | 20 | loose |
| Ty Dolla $ign | Ok | 29 | 13 | 177 | loose |
| Ty Dolla $ign | On Call | 33 | 12 | 91 | loose |
| Ty Dolla $ign | On God | 29 | 16 | 112 | loose |
| Ty Dolla $ign | On My Bumper | 45 | 25 | 178 | loose |
| Ty Dolla $ign | On My Tip | 35 | 24 | 192 | loose |
| Ty Dolla $ign | On One | 41 | 22 | 161 | loose |
| Ty Dolla $ign | On Sight | 41 | 74 | 182 | loose |
| Ty Dolla $ign | On The Run | 15 | 4 | 24 | loose |
| Ty Dolla $ign | On The Wall | 52 | 33 | 180 | loose |
| Ty Dolla $ign | On/Off Switch | 46 | 63 | 224 | loose |
| Ty Dolla $ign | One Call Away (Coast to Coast Mix) | 19 | 7 | 47 | loose |
| Ty Dolla $ign | One Nation | 37 | 29 | 131 | loose |
| Ty Dolla $ign | One Night | 36 | 25 | 156 | loose |
| Ty Dolla $ign | One Thing | 28 | 20 | 121 | loose |
| Ty Dolla $ign | One Time | 4 | 0 | 1 | loose |
| Ty Dolla $ign | One Woman | 39 | 27 | 62 | loose |
| Ty Dolla $ign | One for Me | 32 | 17 | 46 | loose |
| Ty Dolla $ign | One of One | 35 | 26 | 81 | loose |
| Ty Dolla $ign | Only 4 Me | 46 | 21 | 146 | loose |
| Ty Dolla $ign | Only Fanz | 37 | 44 | 162 | loose |
| Ty Dolla $ign | Only One (Demo) | 4 | 0 | 6 | loose |
| Ty Dolla $ign | Only Right | 46 | 25 | 183 | loose |
| Ty Dolla $ign | Only You | 58 | 34 | 164 | loose |
| Ty Dolla $ign | Onyx | 46 | 27 | 196 | loose |
| Ty Dolla $ign | Ooh Yea | 29 | 14 | 150 | loose |
| Ty Dolla $ign | Oops (I’m Sorry) | 26 | 9 | 35 | loose |
| Ty Dolla $ign | Or Nah | 22 | 8 | 64 | loose |
| Ty Dolla $ign | Other Side | 29 | 21 | 93 | loose |
| Ty Dolla $ign | Out Miami | 35 | 43 | 156 | loose |
| Ty Dolla $ign | Outkast | 48 | 48 | 330 | loose |
| Ty Dolla $ign | Outside | 34 | 23 | 90 | loose |
| Ty Dolla $ign | Over | 41 | 20 | 147 | loose |
| Ty Dolla $ign | Overtime | 41 | 29 | 123 | loose |
| Ty Dolla $ign | P&Q | 28 | 22 | 121 | loose |
| Ty Dolla $ign | P.I.M.P | 39 | 57 | 244 | loose |
| Ty Dolla $ign | PAID | 35 | 18 | 111 | loose |
| Ty Dolla $ign | PAPERWORK | 34 | 53 | 89 | loose |
| Ty Dolla $ign | PAY PER VIEW | 30 | 26 | 104 | loose |
| Ty Dolla $ign | PERFECT IS BORING | 15 | 13 | 56 | loose |
| Ty Dolla $ign | PETITE | 31 | 37 | 108 | loose |
| Ty Dolla $ign | POWER | 49 | 37 | 136 | loose |
| Ty Dolla $ign | PROBLEMATIC | 57 | 41 | 264 | loose |
| Ty Dolla $ign | PROMOTION | 41 | 38 | 149 | loose |
| Ty Dolla $ign | PURPLE MOON | 20 | 29 | 46 | loose |
| Ty Dolla $ign | PUSSY COST MONEY | 29 | 30 | 99 | loose |
| Ty Dolla $ign | PUT HER ON | 7 | 1 | 2 | loose |
| Ty Dolla $ign | Packs | 38 | 26 | 189 | loose |
| Ty Dolla $ign | Paranoid | 39 | 32 | 154 | loose |
| Ty Dolla $ign | Paranoid [VMix] | 37 | 23 | 114 | loose |
| Ty Dolla $ign | Paris (Who Taught You) | 32 | 20 | 143 | loose |
| Ty Dolla $ign | Party @ 4am | 18 | 4 | 90 | loose |
| Ty Dolla $ign | Party for Me | 42 | 22 | 202 | loose |
| Ty Dolla $ign | Pass Her To The Homie | 53 | 30 | 230 | loose |
| Ty Dolla $ign | Pass Off | 51 | 40 | 192 | loose |
| Ty Dolla $ign | Perfect Timing | 23 | 4 | 40 | loose |
| Ty Dolla $ign | Photoshop | 16 | 22 | 41 | loose |
| Ty Dolla $ign | Physical | 22 | 7 | 28 | loose |
| Ty Dolla $ign | Pick a Side (Remix) | 40 | 33 | 137 | loose |
| Ty Dolla $ign | Piece of My Love | 14 | 3 | 29 | loose |
| Ty Dolla $ign | Pineapple | 30 | 19 | 187 | loose |
| Ty Dolla $ign | Pistol Packin’ | 34 | 43 | 135 | loose |
| Ty Dolla $ign | Play No Games | 48 | 33 | 273 | loose |
| Ty Dolla $ign | Playas | 25 | 3 | 44 | loose |
| Ty Dolla $ign | Player | 33 | 27 | 129 | loose |
| Ty Dolla $ign | Playhouse | 33 | 44 | 134 | loose |
| Ty Dolla $ign | Playing for Keeps | 42 | 48 | 159 | loose |
| Ty Dolla $ign | Plays | 20 | 13 | 40 | loose |
| Ty Dolla $ign | Police | 43 | 32 | 237 | loose |
| Ty Dolla $ign | Pop Painkillaz | 34 | 18 | 139 | loose |
| Ty Dolla $ign | Pop Sumthn | 39 | 24 | 141 | loose |
| Ty Dolla $ign | Popstar Shawty | 50 | 55 | 134 | loose |
| Ty Dolla $ign | Post Up | 51 | 35 | 116 | loose |
| Ty Dolla $ign | Post to Be (Remix) | 74 | 56 | 281 | loose |
| Ty Dolla $ign | Post to Be [Wasserman Cover] | 69 | 85 | 355 | loose |
| Ty Dolla $ign | Posted Alone (Remix) | 44 | 21 | 216 | loose |
| Ty Dolla $ign | Powder Blue | 29 | 44 | 218 | loose |
| Ty Dolla $ign | Pray | 42 | 47 | 161 | loose |
| Ty Dolla $ign | Pray (Original Version) | 6 | 3 | 15 | loose |
| Ty Dolla $ign | Pray For Me | 14 | 26 | 35 | loose |
| Ty Dolla $ign | Pretend | 44 | 54 | 110 | loose |
| Ty Dolla $ign | Pretty Nights | 52 | 49 | 214 | loose |
| Ty Dolla $ign | Problem With You | 36 | 27 | 108 | loose |
| Ty Dolla $ign | Proud Side Nigga | 29 | 14 | 61 | loose |
| Ty Dolla $ign | Psychedelik Smoke | 37 | 30 | 199 | loose |
| Ty Dolla $ign | Pu$$y | 39 | 30 | 135 | loose |
| Ty Dolla $ign | Pu$$y on Me (Remix) | 52 | 49 | 297 | loose |
| Ty Dolla $ign | Pull Up | 28 | 9 | 104 | loose |
| Ty Dolla $ign | Purple Emoji | 39 | 37 | 241 | loose |
| Ty Dolla $ign | Purple In My Punch | 45 | 73 | 166 | loose |
| Ty Dolla $ign | Pushin | 36 | 43 | 188 | loose |
| Ty Dolla $ign | Put It on Dolla | 33 | 15 | 75 | loose |
| Ty Dolla $ign | Put This Thang On Ya | 51 | 32 | 69 | loose |
| Ty Dolla $ign | Quickie | 26 | 12 | 77 | loose |
| Ty Dolla $ign | R&B | 32 | 6 | 121 | loose |
| Ty Dolla $ign | READY TO LOVE | 38 | 59 | 170 | loose |
| Ty Dolla $ign | REAL HATERS | 15 | 18 | 48 | loose |
| Ty Dolla $ign | RESCUE ME | 36 | 60 | 160 | loose |
| Ty Dolla $ign | RIDE MY WAVE | 16 | 9 | 48 | loose |
| Ty Dolla $ign | RIVER | 62 | 74 | 205 | loose |
| Ty Dolla $ign | RNGM | 44 | 53 | 101 | loose |
| Ty Dolla $ign | RUBI ROSE | 35 | 29 | 143 | loose |
| Ty Dolla $ign | Rain Come Down | 44 | 59 | 174 | loose |
| Ty Dolla $ign | Rain on My Parade | 40 | 41 | 187 | loose |
| Ty Dolla $ign | Ratchet in My Benz | 41 | 28 | 161 | loose |
| Ty Dolla $ign | Re-Up | 28 | 13 | 62 | loose |
| Ty Dolla $ign | Reachin’ | 26 | 6 | 52 | loose |
| Ty Dolla $ign | Read It (The Ellen Remix) | 26 | 10 | 75 | loose |
| Ty Dolla $ign | Real Deal | 39 | 15 | 97 | loose |
| Ty Dolla $ign | Real Friends (Remix) | 20 | 21 | 94 | loose |
| Ty Dolla $ign | Real G | 60 | 41 | 317 | loose |
| Ty Dolla $ign | Real Lean | 40 | 47 | 275 | loose |
| Ty Dolla $ign | Real Life | 34 | 38 | 141 | loose |
| Ty Dolla $ign | Real Thing | 4 | 3 | 17 | loose |
| Ty Dolla $ign | Really Be (Smokin N Drinkin) | 66 | 63 | 526 | loose |
| Ty Dolla $ign | Really Good | 42 | 35 | 224 | loose |
| Ty Dolla $ign | Reap | 15 | 8 | 62 | loose |
| Ty Dolla $ign | Regular | 33 | 43 | 103 | loose |
| Ty Dolla $ign | Relax | 26 | 26 | 120 | loose |
| Ty Dolla $ign | Remember (Remix) | 23 | 10 | 40 | loose |
| Ty Dolla $ign | Reminisce | 45 | 21 | 190 | loose |
| Ty Dolla $ign | Replace My Ex | 32 | 17 | 157 | loose |
| Ty Dolla $ign | Return | 7 | 4 | 9 | loose |
| Ty Dolla $ign | Revenge of The Real | 57 | 37 | 95 | loose |
| Ty Dolla $ign | Rewind (Demo) | 14 | 13 | 46 | loose |
| Ty Dolla $ign | Rhythm of the Drum | 36 | 13 | 148 | loose |
| Ty Dolla $ign | Rich & Famous | 21 | 12 | 132 | loose |
| Ty Dolla $ign | Rich Ni$$a | 26 | 8 | 67 | loose |
| Ty Dolla $ign | Rich Shit | 30 | 23 | 238 | loose |
| Ty Dolla $ign | Ride (Remix) | 49 | 36 | 168 | loose |
| Ty Dolla $ign | Ride It | 29 | 19 | 110 | loose |
| Ty Dolla $ign | Ride La La | 38 | 27 | 235 | loose |
| Ty Dolla $ign | Ring Ring | 43 | 52 | 194 | loose |
| Ty Dolla $ign | Ring Ring [Extended Version] | 22 | 11 | 85 | loose |
| Ty Dolla $ign | Rockstar Nights | 43 | 58 | 90 | loose |
| Ty Dolla $ign | Roll Some Mo (Remix) | 45 | 27 | 222 | loose |
| Ty Dolla $ign | Rollin | 40 | 54 | 275 | loose |
| Ty Dolla $ign | Rookie | 48 | 43 | 181 | loose |
| Ty Dolla $ign | Rounds* | 4 | 0 | 1 | loose |
| Ty Dolla $ign | Routine Rouge | 37 | 34 | 107 | loose |
| Ty Dolla $ign | Rowdy (Hoes On Ice) | 33 | 60 | 119 | loose |
| Ty Dolla $ign | Rude (Remix) | 30 | 15 | 121 | loose |
| Ty Dolla $ign | Run From You | 22 | 12 | 39 | loose |
| Ty Dolla $ign | SAY IT | 46 | 40 | 129 | loose |
| Ty Dolla $ign | SCHEME | 19 | 23 | 120 | loose |
| Ty Dolla $ign | SEROTONIN [V11] | 11 | 12 | 52 | loose |
| Ty Dolla $ign | SEROTONIN [V19] | 10 | 4 | 37 | loose |
| Ty Dolla $ign | SHE GON POP IT | 31 | 25 | 225 | loose |
| Ty Dolla $ign | SHE SUCKING ME UP | 15 | 9 | 43 | loose |
| Ty Dolla $ign | SHOW ME LOVE | 23 | 17 | 102 | loose |
| Ty Dolla $ign | SINGING IN THE RAIN | 32 | 25 | 62 | loose |
| Ty Dolla $ign | SKY CITY | 61 | 66 | 282 | loose |
| Ty Dolla $ign | SLIDE | 30 | 60 | 243 | loose |
| Ty Dolla $ign | SMD (Sex Money Drugs) | 25 | 12 | 94 | loose |
| Ty Dolla $ign | SMILE BODY PRETTY FACE | 49 | 35 | 183 | loose |
| Ty Dolla $ign | SO CALLED FRIENDS | 53 | 35 | 365 | loose |
| Ty Dolla $ign | SO SOON | 20 | 32 | 69 | loose |
| Ty Dolla $ign | SOCIAL NORM | 23 | 19 | 97 | loose |
| Ty Dolla $ign | SSP | 36 | 32 | 211 | loose |
| Ty Dolla $ign | STAR TIME (Young Moose Reference) | 42 | 66 | 163 | loose |
| Ty Dolla $ign | STARS | 15 | 8 | 25 | loose |
| Ty Dolla $ign | STFU | 12 | 6 | 14 | loose |
| Ty Dolla $ign | STILL THE KING (KING Demo) | 19 | 12 | 57 | loose |
| Ty Dolla $ign | SWEET | 17 | 8 | 17 | loose |
| Ty Dolla $ign | Sad Spider | 37 | 20 | 135 | loose |
| Ty Dolla $ign | Same Hoes (Sam Californie) | 45 | 49 | 184 | loose |
| Ty Dolla $ign | Same Nigga | 20 | 17 | 58 | loose |
| Ty Dolla $ign | Saucin’ | 35 | 26 | 106 | loose |
| Ty Dolla $ign | Savage | 37 | 43 | 84 | loose |
| Ty Dolla $ign | Saved | 33 | 34 | 135 | loose |
| Ty Dolla $ign | Say Less | 32 | 12 | 106 | loose |
| Ty Dolla $ign | Say No More | 37 | 19 | 196 | loose |
| Ty Dolla $ign | Scared of the Dark (Remix) | 47 | 38 | 400 | loose |
| Ty Dolla $ign | Sections | 44 | 32 | 236 | loose |
| Ty Dolla $ign | Sex Faces | 5 | 1 | 9 | loose |
| Ty Dolla $ign | Sex Sounds | 34 | 23 | 117 | loose |
| Ty Dolla $ign | Sex on Drugs | 15 | 7 | 27 | loose |
| Ty Dolla $ign | Shake It | 39 | 28 | 223 | loose |
| Ty Dolla $ign | She Bad | 38 | 17 | 124 | loose |
| Ty Dolla $ign | She Better | 5 | 2 | 17 | loose |
| Ty Dolla $ign | She Don’t | 45 | 28 | 98 | loose |
| Ty Dolla $ign | She Don’t Know | 35 | 27 | 125 | loose |
| Ty Dolla $ign | She Don’t Love Me | 39 | 21 | 143 | loose |
| Ty Dolla $ign | She Just Wanna | 48 | 27 | 117 | loose |
| Ty Dolla $ign | She Know | 28 | 26 | 77 | loose |
| Ty Dolla $ign | She Knows | 40 | 28 | 114 | loose |
| Ty Dolla $ign | She Like It When I | 35 | 18 | 151 | loose |
| Ty Dolla $ign | She Ours | 34 | 24 | 78 | loose |
| Ty Dolla $ign | She Said | 33 | 34 | 181 | loose |
| Ty Dolla $ign | She Twerkin (Remix) | 52 | 33 | 307 | loose |
| Ty Dolla $ign | She a Freak | 46 | 33 | 156 | loose |
| Ty Dolla $ign | Shell Shocked | 44 | 30 | 160 | loose |
| Ty Dolla $ign | She’s Mad, She’s Angry | 35 | 22 | 56 | loose |
| Ty Dolla $ign | Shit’n | 27 | 22 | 122 | loose |
| Ty Dolla $ign | Shoot | 24 | 16 | 97 | loose |
| Ty Dolla $ign | Shootin Shots | 31 | 21 | 163 | loose |
| Ty Dolla $ign | Shoutout My Bitches | 28 | 15 | 75 | loose |
| Ty Dolla $ign | Show Me | 47 | 24 | 47 | loose |
| Ty Dolla $ign | Shut Up* | 4 | 0 | 5 | loose |
| Ty Dolla $ign | Side Effects | 13 | 2 | 34 | loose |
| Ty Dolla $ign | Side Tracked | 21 | 10 | 78 | loose |
| Ty Dolla $ign | Simple | 39 | 22 | 133 | loose |
| Ty Dolla $ign | Sin City (Remix) | 23 | 6 | 47 | loose |
| Ty Dolla $ign | Single Again | 45 | 28 | 139 | loose |
| Ty Dolla $ign | Sit Down | 65 | 39 | 270 | loose |
| Ty Dolla $ign | Sitting Pretty | 37 | 36 | 190 | loose |
| Ty Dolla $ign | Slide By | 59 | 60 | 242 | loose |
| Ty Dolla $ign | Slidin | 49 | 77 | 207 | loose |
| Ty Dolla $ign | Slipknot | 33 | 39 | 106 | loose |
| Ty Dolla $ign | Slow Down | 46 | 53 | 184 | loose |
| Ty Dolla $ign | Smoke Break* | 4 | 1 | 13 | loose |
| Ty Dolla $ign | Smoke, Drink, Break-Up (Remix) | 43 | 15 | 189 | loose |
| Ty Dolla $ign | Smoking & Drinking (Extended) | 32 | 15 | 79 | loose |
| Ty Dolla $ign | Smoking On Junt | 21 | 13 | 145 | loose |
| Ty Dolla $ign | So Am I | 20 | 7 | 38 | loose |
| Ty Dolla $ign | So Fast | 41 | 62 | 107 | loose |
| Ty Dolla $ign | So Fresh So Fly | 39 | 59 | 201 | loose |
| Ty Dolla $ign | So Good | 31 | 14 | 88 | loose |
| Ty Dolla $ign | Solid | 51 | 24 | 105 | loose |
| Ty Dolla $ign | Somebody That You Don’t Know | 33 | 19 | 136 | loose |
| Ty Dolla $ign | Something New | 33 | 20 | 89 | loose |
| Ty Dolla $ign | Something Serious | 30 | 11 | 97 | loose |
| Ty Dolla $ign | Somethin’ | 68 | 78 | 250 | loose |
| Ty Dolla $ign | Sophisticated | 36 | 60 | 129 | loose |
| Ty Dolla $ign | Sorry Momma | 42 | 27 | 126 | loose |
| Ty Dolla $ign | South Beach | 46 | 52 | 93 | loose |
| Ty Dolla $ign | Special Delivery | 36 | 26 | 155 | loose |
| Ty Dolla $ign | Speechless | 18 | 4 | 39 | loose |
| Ty Dolla $ign | Speed Me Up | 48 | 44 | 225 | loose |
| Ty Dolla $ign | Speed Me Up Ultimate Mix | 50 | 64 | 240 | loose |
| Ty Dolla $ign | Spicy | 32 | 18 | 110 | loose |
| Ty Dolla $ign | Splash | 35 | 42 | 167 | loose |
| Ty Dolla $ign | Split The Vibes | 29 | 15 | 65 | loose |
| Ty Dolla $ign | Sports Center | 40 | 48 | 104 | loose |
| Ty Dolla $ign | Stand For | 43 | 26 | 115 | loose |
| Ty Dolla $ign | Standout | 29 | 16 | 127 | loose |
| Ty Dolla $ign | Stare | 84 | 109 | 165 | loose |
| Ty Dolla $ign | Status | 19 | 30 | 59 | loose |
| Ty Dolla $ign | Stealing | 27 | 16 | 56 | loose |
| Ty Dolla $ign | Still (Family) | 50 | 31 | 238 | loose |
| Ty Dolla $ign | Still Brazy | 64 | 45 | 210 | loose |
| Ty Dolla $ign | Still Down | 45 | 20 | 219 | loose |
| Ty Dolla $ign | Still Free TC | 41 | 19 | 243 | loose |
| Ty Dolla $ign | Still Sippin | 35 | 40 | 101 | loose |
| Ty Dolla $ign | Still Work | 26 | 13 | 58 | loose |
| Ty Dolla $ign | Straight Up | 37 | 14 | 179 | loose |
| Ty Dolla $ign | Stressed Out | 18 | 9 | 54 | loose |
| Ty Dolla $ign | Stretch | 7 | 4 | 15 | loose |
| Ty Dolla $ign | Stretch / She Better | 56 | 21 | 177 | loose |
| Ty Dolla $ign | Stretch You Out | 18 | 14 | 80 | loose |
| Ty Dolla $ign | Stripper Pole | 26 | 11 | 44 | loose |
| Ty Dolla $ign | Striptease | 20 | 15 | 143 | loose |
| Ty Dolla $ign | Stuck | 22 | 16 | 41 | loose |
| Ty Dolla $ign | Stupid | 32 | 23 | 108 | loose |
| Ty Dolla $ign | Stupid Dumb | 37 | 33 | 94 | loose |
| Ty Dolla $ign | Subtle | 28 | 28 | 75 | loose |
| Ty Dolla $ign | Sullen Sunday | 7 | 3 | 40 | loose |
| Ty Dolla $ign | Summer Reign | 28 | 39 | 146 | loose |
| Ty Dolla $ign | Sunlight | 19 | 13 | 23 | loose |
| Ty Dolla $ign | Superstar | 44 | 38 | 279 | loose |
| Ty Dolla $ign | Surface | 27 | 13 | 136 | loose |
| Ty Dolla $ign | Surgery | 49 | 89 | 232 | loose |
| Ty Dolla $ign | Surprise You (The Life) | 50 | 43 | 177 | loose |
| Ty Dolla $ign | Surrounded | 53 | 92 | 131 | loose |
| Ty Dolla $ign | Survive | 54 | 48 | 253 | loose |
| Ty Dolla $ign | Survived (Reference) | 4 | 0 | 15 | loose |
| Ty Dolla $ign | Swalla (After Dark Remix) | 26 | 7 | 112 | loose |
| Ty Dolla $ign | Sweat | 48 | 36 | 106 | loose |
| Ty Dolla $ign | Switch | 37 | 23 | 105 | loose |
| Ty Dolla $ign | Switchblade | 37 | 22 | 48 | loose |
| Ty Dolla $ign | T-Shirt | 32 | 34 | 73 | loose |
| Ty Dolla $ign | T.O.P | 47 | 33 | 191 | loose |
| Ty Dolla $ign | TAKE OFF YOUR DRESS | 49 | 53 | 235 | loose |
| Ty Dolla $ign | TALKING | 23 | 26 | 81 | loose |
| Ty Dolla $ign | TEACH YOU HOW TO LUH ME | 48 | 68 | 245 | loose |
| Ty Dolla $ign | TELL ME | 68 | 61 | 210 | loose |
| Ty Dolla $ign | THOUSAND MILES | 23 | 8 | 58 | loose |
| Ty Dolla $ign | THROW AWAY | 37 | 16 | 120 | loose |
| Ty Dolla $ign | THUMBS DOWN | 4 | 3 | 6 | ABCB |
| Ty Dolla $ign | TIFFANY | 134 | 134 | 668 | loose |
| Ty Dolla $ign | TIME MOVING SLOW | 30 | 31 | 182 | loose |
| Ty Dolla $ign | TOO EASY! | 30 | 30 | 64 | loose |
| Ty Dolla $ign | TWITCH | 42 | 60 | 145 | loose |
| Ty Dolla $ign | TWO DAYS | 30 | 36 | 266 | loose |
| Ty Dolla $ign | TXT ME (Remix) | 30 | 22 | 100 | loose |
| Ty Dolla $ign | TYCOON$ | 50 | 36 | 199 | loose |
| Ty Dolla $ign | Tactics | 15 | 10 | 60 | loose |
| Ty Dolla $ign | Take | 31 | 16 | 98 | loose |
| Ty Dolla $ign | Take It Away | 26 | 40 | 112 | loose |
| Ty Dolla $ign | Take It There | 41 | 26 | 143 | loose |
| Ty Dolla $ign | Take Money, Make Money | 21 | 3 | 45 | loose |
| Ty Dolla $ign | Take Over The World | 38 | 37 | 199 | loose |
| Ty Dolla $ign | Take Your Time | 19 | 13 | 60 | loose |
| Ty Dolla $ign | Talented | 31 | 30 | 143 | loose |
| Ty Dolla $ign | Tap In | 36 | 27 | 159 | loose |
| Ty Dolla $ign | Tarzan | 32 | 48 | 256 | loose |
| Ty Dolla $ign | Tell Me What You Like | 25 | 6 | 69 | loose |
| Ty Dolla $ign | Temptations | 31 | 19 | 110 | loose |
| Ty Dolla $ign | Tequila | 56 | 74 | 182 | loose |
| Ty Dolla $ign | That Girl 2004 | 34 | 17 | 63 | loose |
| Ty Dolla $ign | That Good | 44 | 34 | 157 | loose |
| Ty Dolla $ign | That Shit Go | 20 | 12 | 64 | loose |
| Ty Dolla $ign | That’s Facts | 27 | 14 | 68 | loose |
| Ty Dolla $ign | That’s Just How It Is | 17 | 1 | 49 | loose |
| Ty Dolla $ign | That’s Love | 26 | 24 | 147 | loose |
| Ty Dolla $ign | That’s My Thing | 14 | 22 | 20 | loose |
| Ty Dolla $ign | That’s Right | 37 | 20 | 129 | loose |
| Ty Dolla $ign | That’s Wassup | 61 | 53 | 129 | loose |
| Ty Dolla $ign | The Business, Pt. II | 23 | 31 | 116 | loose |
| Ty Dolla $ign | The Distance | 44 | 23 | 139 | loose |
| Ty Dolla $ign | The Garden | 22 | 7 | 62 | loose |
| Ty Dolla $ign | The Light | 24 | 18 | 71 | loose |
| Ty Dolla $ign | The Man | 44 | 42 | 199 | loose |
| Ty Dolla $ign | The Motions (HeMotions Original) | 42 | 38 | 207 | loose |
| Ty Dolla $ign | The Other Side | 53 | 46 | 212 | loose |
| Ty Dolla $ign | The Perfect One | 23 | 26 | 83 | loose |
| Ty Dolla $ign | The Return | 49 | 46 | 315 | loose |
| Ty Dolla $ign | The Storm | 28 | 12 | 61 | loose |
| Ty Dolla $ign | The Story | 21 | 53 | 64 | loose |
| Ty Dolla $ign | The Summer League | 33 | 18 | 128 | loose |
| Ty Dolla $ign | The U.N. Plan | 16 | 6 | 19 | loose |
| Ty Dolla $ign | These Days | 27 | 42 | 93 | loose |
| Ty Dolla $ign | They Know | 53 | 40 | 311 | loose |
| Ty Dolla $ign | Thing Called Love | 44 | 33 | 179 | loose |
| Ty Dolla $ign | Think About Us (Remix) | 45 | 25 | 96 | loose |
| Ty Dolla $ign | This Big | 48 | 39 | 161 | loose |
| Ty Dolla $ign | This Time | 56 | 55 | 162 | loose |
| Ty Dolla $ign | This Weekend | 37 | 36 | 119 | loose |
| Ty Dolla $ign | Thought It | 38 | 28 | 288 | loose |
| Ty Dolla $ign | Throw It All Night | 35 | 27 | 36 | loose |
| Ty Dolla $ign | Throw That | 30 | 31 | 73 | loose |
| Ty Dolla $ign | Thug Holiday | 32 | 16 | 114 | loose |
| Ty Dolla $ign | Thug It Out | 26 | 37 | 89 | loose |
| Ty Dolla $ign | Thug Life | 105 | 115 | 528 | loose |
| Ty Dolla $ign | Thugz Mansion | 36 | 24 | 175 | loose |
| Ty Dolla $ign | Tie Me Down | 22 | 19 | 34 | loose |
| Ty Dolla $ign | Till We Meet Again | 36 | 15 | 94 | loose |
| Ty Dolla $ign | Time | 47 | 31 | 262 | loose |
| Ty Dolla $ign | Time Will Tell | 28 | 22 | 184 | loose |
| Ty Dolla $ign | To A Boss | 30 | 29 | 108 | loose |
| Ty Dolla $ign | Too Much to Ask | 21 | 6 | 70 | loose |
| Ty Dolla $ign | Toot It & Boot It (G-Mix) | 65 | 24 | 170 | loose |
| Ty Dolla $ign | Toot It N Boot It | 3 | 0 | 5 | loose |
| Ty Dolla $ign | Toot It and Boot It | 40 | 40 | 180 | loose |
| Ty Dolla $ign | Top Down (2025) | 46 | 49 | 241 | loose |
| Ty Dolla $ign | Touch Me (Remix) | 27 | 35 | 73 | loose |
| Ty Dolla $ign | Touch Of Heaven | 43 | 33 | 196 | loose |
| Ty Dolla $ign | Tour Bus | 35 | 6 | 166 | loose |
| Ty Dolla $ign | Toxic | 25 | 20 | 64 | loose |
| Ty Dolla $ign | Track 6 | 37 | 14 | 141 | loose |
| Ty Dolla $ign | Trap Paris | 48 | 50 | 116 | loose |
| Ty Dolla $ign | Treasure In The Hills (Live From NPR’s Tiny Desk) | 12 | 9 | 11 | loose |
| Ty Dolla $ign | Treehouse | 42 | 49 | 107 | loose |
| Ty Dolla $ign | Trick Pony (Boys Noize Remix) | 11 | 2 | 25 | loose |
| Ty Dolla $ign | Tricks | 39 | 24 | 160 | loose |
| Ty Dolla $ign | Trust Me | 31 | 23 | 177 | loose |
| Ty Dolla $ign | Try Me (Remix) | 59 | 43 | 201 | loose |
| Ty Dolla $ign | Tryna Fuck | 35 | 35 | 183 | loose |
| Ty Dolla $ign | Tu Vecina | 35 | 26 | 170 | loose |
| Ty Dolla $ign | Turn It Up | 17 | 10 | 30 | loose |
| Ty Dolla $ign | Turn Me Up* | 21 | 21 | 73 | loose |
| Ty Dolla $ign | Twerk It | 49 | 28 | 168 | loose |
| Ty Dolla $ign | Ty Dolla $ign Checks In (Interlude) | 19 | 8 | 68 | loose |
| Ty Dolla $ign | Ty and Kory Hustla’s Theme | 37 | 11 | 100 | loose |
| Ty Dolla $ign | Type Of Shit I Hate | 39 | 28 | 200 | loose |
| Ty Dolla $ign | Tyrone 2021 | 40 | 29 | 188 | loose |
| Ty Dolla $ign | U + Me (Rap Version) | 28 | 12 | 93 | loose |
| Ty Dolla $ign | U MISS ME? | 30 | 17 | 93 | loose |
| Ty Dolla $ign | Ugh | 41 | 31 | 123 | loose |
| Ty Dolla $ign | Uncle Luke | 33 | 28 | 109 | loose |
| Ty Dolla $ign | Underdogs (Interlude) | 10 | 3 | 8 | loose |
| Ty Dolla $ign | Universe | 37 | 21 | 67 | loose |
| Ty Dolla $ign | Up In The Stars | 26 | 34 | 107 | loose |
| Ty Dolla $ign | Up On the Wall | 83 | 62 | 475 | loose |
| Ty Dolla $ign | Use It | 22 | 29 | 61 | loose |
| Ty Dolla $ign | Use To | 23 | 17 | 54 | loose |
| Ty Dolla $ign | Used To Me | 42 | 34 | 122 | loose |
| Ty Dolla $ign | Uzi | 40 | 24 | 180 | loose |
| Ty Dolla $ign | VIBES DON’T LIE (Live From NPR’s Tiny Desk) | 26 | 11 | 82 | loose |
| Ty Dolla $ign | VULTURES | 84 | 84 | 461 | loose |
| Ty Dolla $ign | VULTURES - Havoc Version | 15 | 10 | 118 | loose |
| Ty Dolla $ign | Veggies | 54 | 73 | 171 | loose |
| Ty Dolla $ign | Vertigo | 25 | 21 | 17 | loose |
| Ty Dolla $ign | Vibe Like This | 32 | 24 | 126 | loose |
| Ty Dolla $ign | Vibe With You | 37 | 30 | 240 | loose |
| Ty Dolla $ign | Vices | 40 | 40 | 124 | loose |
| Ty Dolla $ign | Violent | 53 | 35 | 217 | loose |
| Ty Dolla $ign | Violent Crimes (Ty Dolla $ign Demo) | 29 | 28 | 144 | loose |
| Ty Dolla $ign | Viral | 24 | 22 | 145 | loose |
| Ty Dolla $ign | Vitamin D | 76 | 59 | 352 | loose |
| Ty Dolla $ign | Voices | 57 | 23 | 122 | loose |
| Ty Dolla $ign | WAY IT IS | 29 | 24 | 136 | loose |
| Ty Dolla $ign | WE GO WILD* | 12 | 4 | 40 | loose |
| Ty Dolla $ign | WE LIKE TO PARTY | 35 | 47 | 268 | loose |
| Ty Dolla $ign | WE NEED ALL DA VIBES | 35 | 31 | 188 | loose |
| Ty Dolla $ign | WFO-01 | 41 | 12 | 148 | loose |
| Ty Dolla $ign | WHAT I WANT | 38 | 42 | 253 | loose |
| Ty Dolla $ign | WHAT I’M MISSING | 24 | 29 | 93 | loose |
| Ty Dolla $ign | WHERE I GO | 24 | 41 | 77 | loose |
| Ty Dolla $ign | WHITE LINES (Reference) | 15 | 7 | 85 | loose |
| Ty Dolla $ign | WICKED GAMES | 25 | 12 | 66 | loose |
| Ty Dolla $ign | WIT IT | 32 | 13 | 43 | loose |
| Ty Dolla $ign | WUSYANAME [Remix] [Mixed] | 6 | 0 | 3 | loose |
| Ty Dolla $ign | Waist Down | 37 | 35 | 201 | loose |
| Ty Dolla $ign | Wake n Bake | 39 | 34 | 120 | loose |
| Ty Dolla $ign | Watch Out | 48 | 32 | 354 | loose |
| Ty Dolla $ign | Watch Yo Bitch | 37 | 29 | 180 | loose |
| Ty Dolla $ign | Watching | 47 | 50 | 74 | loose |
| Ty Dolla $ign | Water | 32 | 12 | 65 | loose |
| Ty Dolla $ign | Wavy | 39 | 29 | 170 | loose |
| Ty Dolla $ign | Way Back Home | 40 | 19 | 177 | loose |
| Ty Dolla $ign | We Could Be Free | 66 | 46 | 277 | loose |
| Ty Dolla $ign | We Don’t | 57 | 50 | 156 | loose |
| Ty Dolla $ign | We Know About You | 27 | 8 | 92 | loose |
| Ty Dolla $ign | Wedding Cake | 32 | 26 | 133 | loose |
| Ty Dolla $ign | Weekend | 37 | 20 | 99 | loose |
| Ty Dolla $ign | Welcome To My Life | 33 | 11 | 154 | loose |
| Ty Dolla $ign | Westside | 34 | 45 | 121 | loose |
| Ty Dolla $ign | Wet | 56 | 47 | 212 | loose |
| Ty Dolla $ign | What Are We Doing | 23 | 10 | 70 | loose |
| Ty Dolla $ign | What Do You Like | 35 | 41 | 149 | loose |
| Ty Dolla $ign | What These Bitches Want | 45 | 38 | 224 | loose |
| Ty Dolla $ign | What To Do With It | 23 | 11 | 47 | loose |
| Ty Dolla $ign | What We Not Fina Do | 31 | 22 | 94 | loose |
| Ty Dolla $ign | What You Like | 44 | 31 | 194 | loose |
| Ty Dolla $ign | What You Think | 40 | 45 | 161 | loose |
| Ty Dolla $ign | What You Want | 65 | 43 | 234 | loose |
| Ty Dolla $ign | Whatever You Need | 36 | 31 | 158 | loose |
| Ty Dolla $ign | Whatever You On | 62 | 36 | 286 | loose |
| Ty Dolla $ign | Wheels Fall Off | 26 | 11 | 62 | loose |
| Ty Dolla $ign | When I Lie (Remix) | 20 | 26 | 143 | loose |
| Ty Dolla $ign | When I See Ya | 35 | 7 | 110 | loose |
| Ty Dolla $ign | When We (Remix) | 50 | 37 | 145 | loose |
| Ty Dolla $ign | When We Wake Up | 54 | 24 | 206 | loose |
| Ty Dolla $ign | Where U Going (Assophat) | 38 | 26 | 128 | loose |
| Ty Dolla $ign | Whip | 45 | 26 | 132 | loose |
| Ty Dolla $ign | Whip It | 51 | 67 | 310 | loose |
| Ty Dolla $ign | White Sand | 64 | 72 | 211 | loose |
| Ty Dolla $ign | Wholeheartedly | 59 | 51 | 202 | loose |
| Ty Dolla $ign | Who’s That?* | 7 | 5 | 26 | loose |
| Ty Dolla $ign | Why Wait | 13 | 1 | 28 | loose |
| Ty Dolla $ign | Why’d You Call? | 17 | 4 | 52 | loose |
| Ty Dolla $ign | Willing To Trust | 18 | 8 | 74 | loose |
| Ty Dolla $ign | Woah | 34 | 36 | 82 | loose |
| Ty Dolla $ign | Woke Up | 44 | 48 | 69 | loose |
| Ty Dolla $ign | Wolves | 39 | 42 | 211 | loose |
| Ty Dolla $ign | Wonderful | 48 | 39 | 133 | loose |
| Ty Dolla $ign | Won’t Change | 54 | 27 | 248 | loose |
| Ty Dolla $ign | Woo (Demo) | 16 | 7 | 42 | loose |
| Ty Dolla $ign | Wood & Leather | 50 | 38 | 245 | loose |
| Ty Dolla $ign | Work | 69 | 57 | 365 | loose |
| Ty Dolla $ign | Work From Home | 33 | 11 | 118 | loose |
| Ty Dolla $ign | Work From Home [FH4 Version] | 14 | 6 | 43 | loose |
| Ty Dolla $ign | Work It | 20 | 21 | 93 | loose |
| Ty Dolla $ign | Work That Body (Snippet) | 4 | 1 | 9 | loose |
| Ty Dolla $ign | Worth It (Remix) | 33 | 19 | 111 | loose |
| Ty Dolla $ign | Wow Wow Wow | 50 | 50 | 226 | loose |
| Ty Dolla $ign | XTCY (Love Everyone Demo) | 32 | 34 | 133 | loose |
| Ty Dolla $ign | XXL Freshman Freestyle | 14 | 7 | 57 | loose |
| Ty Dolla $ign | XXL Freshmen 2014 Cypher - Part 2 | 62 | 34 | 281 | loose |
| Ty Dolla $ign | Y U Mad | 40 | 56 | 247 | loose |
| Ty Dolla $ign | YE ABOUT MINE | 46 | 95 | 169 | loose |
| Ty Dolla $ign | YES IT IS (Live From NPR’s Tiny Desk) | 36 | 26 | 106 | loose |
| Ty Dolla $ign | YKTV | 43 | 28 | 232 | loose |
| Ty Dolla $ign | Yacht Club | 42 | 17 | 137 | loose |
| Ty Dolla $ign | You | 36 | 46 | 115 | loose |
| Ty Dolla $ign | You Ain’t No Model | 35 | 25 | 151 | loose |
| Ty Dolla $ign | You And I | 39 | 25 | 216 | loose |
| Ty Dolla $ign | You Could Be My Lover | 47 | 20 | 107 | loose |
| Ty Dolla $ign | You Got It (Remix) [Amazon Original] | 48 | 38 | 101 | loose |
| Ty Dolla $ign | You See It | 13 | 4 | 20 | loose |
| Ty Dolla $ign | You and Your Friends | 32 | 22 | 137 | loose |
| Ty Dolla $ign | Young & Free | 20 | 21 | 72 | loose |
| Ty Dolla $ign | Young Black Male | 49 | 55 | 257 | loose |
| Ty Dolla $ign | Young Honey | 51 | 55 | 294 | loose |
| Ty Dolla $ign | Young, Wild, & Free (Demo) | 20 | 10 | 67 | loose |
| Ty Dolla $ign | Your Money | 29 | 14 | 183 | loose |
| Ty Dolla $ign | Your Turn | 41 | 12 | 110 | loose |
| Ty Dolla $ign | You’re the One | 58 | 31 | 208 | loose |
| Ty Dolla $ign | Zaddy | 38 | 37 | 172 | loose |
| Ty Dolla $ign | Zone’n | 29 | 27 | 122 | loose |
| Ty Dolla $ign | bad bitch alert | 24 | 29 | 105 | loose |
| Ty Dolla $ign | can you see? | 14 | 3 | 21 | loose |
| Ty Dolla $ign | good to me | 17 | 26 | 52 | loose |
| Ty Dolla $ign | intention | 27 | 17 | 53 | loose |
| Ty Dolla $ign | llf | 12 | 5 | 94 | loose |
| Ty Dolla $ign | miss u 2 | 32 | 24 | 75 | loose |
| Ty Dolla $ign | rtr | 38 | 24 | 404 | loose |
| Ty Dolla $ign | safety net | 28 | 28 | 82 | loose |
| Ty Dolla $ign | serpentwithfeet Interlude | 4 | 1 | 3 | loose |
| Ty Dolla $ign | slow it down | 8 | 6 | 65 | loose |
| Ty Dolla $ign | so then | 34 | 23 | 100 | loose |
| Ty Dolla $ign | sound like | 37 | 43 | 160 | loose |
| Ty Dolla $ign | speed | 33 | 41 | 191 | loose |
| Ty Dolla $ign | two nights part ii | 15 | 3 | 29 | loose |
| Ty Dolla $ign | ’til the room stinks | 30 | 20 | 132 | loose |
