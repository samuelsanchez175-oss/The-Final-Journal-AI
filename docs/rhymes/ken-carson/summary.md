# Ken Carson rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ken Carson
- Songs: 433
- Bars kept (Ken Carson lyric lines): 13488
- Section headers dropped, not counted as bars: 1
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 34
- Canonical name: Ken Carson.
- Credit strings: Ken Carson.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 88445
- REPEAT pairs, recorded separately: 13193
- END rhymes: 16571
- INNER rhymes: 71874

By match:

- PERFECT: 8548 (END 2865, INNER 5683)
- SLANT: 39365 (END 7355, INNER 32010)
- ASSONANCE: 39789 (END 6040, INNER 33749)
- MULTI: 743 (END 311, INNER 432)

By confidence:

- HIGH: 8745
- MED: 73989
- LOW: 5711

## Core

- Core Y: 87013
- Core N among rhyme pairs: 1432

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 43070 (48.7%)
- vowel: 39789 (45.0%)
- spelling: 4843 (5.5%)
- multi: 743 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 11 songs
- AABB: 3 songs
- ABAB: 1 songs
- ABCB: 2 songs
- ABAA: 1 songs
- loose: 415 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 7320 pairs (END 825, INNER 6495). Words: don't, no, know, go, hoes, ho, told, smoke.
2. `vow:IH` — 5250 pairs (END 766, INNER 4484). Words: bitch, shit, think, bitches, wrist, lil, hit, sticks.
3. `vow:EH` — 4319 pairs (END 614, INNER 3705). Words: get, x, when, gettin, tell, never, went, every.
4. `vow:AE` — 4041 pairs (END 584, INNER 3457). Words: can't, racks, back, havin, pants, can, bad, bands.
5. `vow:AA` — 4017 pairs (END 393, INNER 3624). Words: got, want, nothin, talkin, not, wanna, rockin, poppin.
6. `vow:EY` — 3912 pairs (END 616, INNER 3296). Words: ain't, way, day, say, make, baby, stay, take.
7. `vow:IY` — 3070 pairs (END 629, INNER 2441). Words: these, see, even, shawty, need, nobody, p, three.
8. `vow:AY` — 2771 pairs (END 451, INNER 2320). Words: like, high, diamonds, why, time, try, fly, right.
9. `vow:AH` — 2765 pairs (END 491, INNER 2274). Words: fuck, drugs, fuckin, some, double, money, what, love.
10. `slant:IH:sib-stop` — 2525 pairs (END 455, INNER 2070). Words: bitch, shit, hit, dick, nigga, niggas, stick, rich.
11. `slant:AA:stop` — 2403 pairs (END 234, INNER 2169). Words: got, want, not, gotta, pop, rock, top, glock.
12. `cmu:OW` — 1797 pairs (END 247, INNER 1550). Words: know, no, go, ho, blow, show, bro, throw.
13. `slant:IH:stop` — 1679 pairs (END 358, INNER 1321). Words: shit, nigga, hit, stick, dick, big, wrist, rick.
14. `slant:EH:stop` — 1086 pairs (END 193, INNER 893). Words: get, said, ready, let, better, head, already, neck.
15. `slant:IH:liq-sib` — 1077 pairs (END 56, INNER 1021). Words: bitch, lil, still, really, 'til, rich, pill, kill.
16. `slant:IH:liq-stop` — 1068 pairs (END 77, INNER 991). Words: lil, shit, still, hit, really, dick, 'til, big.
17. `slant:AH:nas-stop` — 1044 pairs (END 41, INNER 1003). Words: fuck, some, money, what, one, come, young, fuckin.
18. `slant:AE:stop` — 1022 pairs (END 232, INNER 790). Words: can't, back, bad, swag, had, bag, black, mad.
19. `slant:IH:nas-stop` — 876 pairs (END 72, INNER 804). Words: shit, i'ma, him, hit, everything, bring, stick, dick.
20. `slant:AY:stop` — 831 pairs (END 164, INNER 667). Words: like, right, ride, night, white, sight, outside, type.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 700 pair sides, mostly spelling via spelling phonetic key, often with bitch (199)
- nigga — 666 pair sides, mostly spelling via spelling phonetic key, often with shit (173)
- gon — 402 pair sides, mostly spelling via spelling phonetic key, often with dont (121)
- shawty — 376 pair sides, mostly vowel via spelling phonetic key, often with all (55)
- swag — 343 pair sides, mostly spelling via spelling phonetic key, often with cant (34)
- tryna — 321 pair sides, mostly spelling via spelling phonetic key, often with these (56)
- niggas — 302 pair sides, mostly spelling via spelling phonetic key, often with nigga (138)
- geeked — 109 pair sides, mostly spelling via spelling phonetic key, often with these (9)
- thot — 78 pair sides, mostly spelling via spelling phonetic key, often with dont (12)
- opps — 61 pair sides, mostly vowel via spelling phonetic key, often with know (22)
- balenciaga — 61 pair sides, mostly vowel via spelling phonetic key, often with cant (12)
- wock — 51 pair sides, mostly spelling via spelling phonetic key, often with know (8)
- lik — 50 pair sides, mostly spelling via spelling phonetic key, often with bitch (9)
- tris — 49 pair sides, mostly spelling via spelling phonetic key, often with shit (10)
- meds — 47 pair sides, mostly spelling via spelling phonetic key, often with legs (5)
- lyin — 44 pair sides, mostly spelling via spelling phonetic key, often with these (12)
- codeine — 39 pair sides, mostly vowel via spelling phonetic key, often with promethazine (11)
- vetements — 34 pair sides, mostly vowel via spelling phonetic key, often with when (4)
- xans — 33 pair sides, mostly spelling via spelling phonetic key, often with pants (6)
- bros — 32 pair sides, mostly spelling via spelling phonetic key, often with hoes (6)
- fam — 31 pair sides, mostly spelling via spelling phonetic key, often with atlanta (2)
- swole — 29 pair sides, mostly spelling via spelling phonetic key, often with old (5)
- hella — 26 pair sides, mostly spelling via spelling phonetic key, often with tell (8)
- swaggin — 26 pair sides, mostly spelling via spelling phonetic key, often with braggin (7)
- wraith — 25 pair sides, mostly vowel via vault phonetic_class, often with bag (4)
- brazy — 25 pair sides, mostly vowel via spelling phonetic key, often with crazy (4)
- blicky — 25 pair sides, mostly spelling via spelling phonetic key, often with bitch (3)
- moshpit — 23 pair sides, mostly spelling via spelling phonetic key, often with shit (11)
- finna — 22 pair sides, mostly vowel via spelling phonetic key, often with niggas (7)
- ine — 21 pair sides, mostly spelling via spelling phonetic key, often with shit (3)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ken Carson | 005 | 38 | 52 | 247 | loose |
| Ken Carson | 100 | 55 | 64 | 320 | loose |
| Ken Carson | 100 Shots | 61 | 83 | 353 | loose |
| Ken Carson | 200 Kash | 31 | 23 | 234 | loose |
| Ken Carson | 2000 | 42 | 54 | 270 | loose |
| Ken Carson | 30Klip* | 4 | 1 | 19 | loose |
| Ken Carson | 40 Rounds* | 9 | 0 | 10 | loose |
| Ken Carson | 50k | 30 | 24 | 134 | loose |
| Ken Carson | 5AM | 22 | 20 | 126 | loose |
| Ken Carson | 720s (Redman) | 41 | 52 | 305 | loose |
| Ken Carson | 808 punch | 54 | 54 | 276 | loose |
| Ken Carson | 9 bitches | 38 | 41 | 231 | loose |
| Ken Carson | ALL YEAR FREESTYLE (Delinquent Original) | 17 | 9 | 122 | loose |
| Ken Carson | Actin’ Tough* | 12 | 19 | 79 | loose |
| Ken Carson | Adderall* | 6 | 1 | 10 | loose |
| Ken Carson | Ain’t No Way | 49 | 44 | 282 | loose |
| Ken Carson | All I Need Is Drugs* | 13 | 7 | 133 | loose |
| Ken Carson | Aquafina (X TWO THREE) | 35 | 56 | 140 | loose |
| Ken Carson | BAD TERMS | 11 | 5 | 68 | loose |
| Ken Carson | BLOWER | 54 | 63 | 361 | loose |
| Ken Carson | BODY BAG | 39 | 56 | 231 | loose |
| Ken Carson | BPM | 10 | 9 | 40 | loose |
| Ken Carson | Back And Forth (Privacy) | 36 | 37 | 268 | loose |
| Ken Carson | BackPack | 20 | 58 | 240 | AAAA |
| Ken Carson | Bad Boys 3 | 60 | 56 | 229 | loose |
| Ken Carson | Bags on Bags | 37 | 26 | 101 | loose |
| Ken Carson | Bags* | 6 | 0 | 9 | loose |
| Ken Carson | Balenciaga* | 4 | 1 | 13 | loose |
| Ken Carson | Bank | 18 | 14 | 55 | loose |
| Ken Carson | Batgang / Black Gun | 26 | 24 | 100 | loose |
| Ken Carson | Been Braggin | 36 | 41 | 157 | loose |
| Ken Carson | Beno! | 38 | 35 | 108 | loose |
| Ken Carson | Birds | 9 | 1 | 26 | loose |
| Ken Carson | Blakk Rokkstar | 55 | 64 | 273 | loose |
| Ken Carson | Blue Benjamins | 69 | 87 | 632 | loose |
| Ken Carson | Blue Check | 29 | 22 | 224 | loose |
| Ken Carson | Blue Cheese* | 8 | 6 | 47 | loose |
| Ken Carson | Blush* | 8 | 5 | 30 | loose |
| Ken Carson | Bora Bora* | 10 | 21 | 62 | AAAA |
| Ken Carson | BoredMusic | 4 | 2 | 20 | loose |
| Ken Carson | Burnin Up | 37 | 75 | 158 | loose |
| Ken Carson | Bust | 32 | 25 | 144 | loose |
| Ken Carson | Butterfly | 16 | 36 | 83 | loose |
| Ken Carson | CALL N | 17 | 13 | 58 | loose |
| Ken Carson | CAPO | 25 | 21 | 119 | loose |
| Ken Carson | CHL | 21 | 2 | 68 | loose |
| Ken Carson | CRACK! | 38 | 41 | 83 | loose |
| Ken Carson | Call Nobody | 21 | 25 | 85 | loose |
| Ken Carson | Came A Long Way | 11 | 23 | 39 | loose |
| Ken Carson | Can’t Save A Ho* | 5 | 4 | 27 | AABB |
| Ken Carson | Can’t You See* | 11 | 5 | 54 | loose |
| Ken Carson | Casket | 20 | 61 | 233 | AAAA |
| Ken Carson | Celebrate | 26 | 24 | 78 | loose |
| Ken Carson | Champagne Drake | 36 | 33 | 131 | loose |
| Ken Carson | Change | 49 | 78 | 182 | loose |
| Ken Carson | Change Her Life | 24 | 27 | 171 | loose |
| Ken Carson | Chrome Hearts | 24 | 24 | 170 | loose |
| Ken Carson | Chrome Hearts Jeans | 57 | 91 | 243 | loose |
| Ken Carson | Clutch | 39 | 85 | 164 | loose |
| Ken Carson | Come Outside | 41 | 55 | 282 | loose |
| Ken Carson | Confetti | 43 | 46 | 269 | loose |
| Ken Carson | DRUGS TLKN | 15 | 12 | 87 | loose |
| Ken Carson | Danny Phantom | 38 | 42 | 158 | loose |
| Ken Carson | Daredevil* | 6 | 3 | 25 | loose |
| Ken Carson | Delinquent | 52 | 56 | 332 | loose |
| Ken Carson | Diamonds | 67 | 51 | 328 | loose |
| Ken Carson | Die Lit* | 29 | 22 | 133 | loose |
| Ken Carson | Dime | 18 | 24 | 31 | loose |
| Ken Carson | Disguise* | 19 | 21 | 111 | loose |
| Ken Carson | Dismantled | 31 | 28 | 259 | loose |
| Ken Carson | Down2Earth | 43 | 38 | 162 | loose |
| Ken Carson | Drenched Out | 41 | 41 | 187 | loose |
| Ken Carson | Drill Shit | 41 | 36 | 424 | loose |
| Ken Carson | Drugs | 12 | 9 | 34 | loose |
| Ken Carson | Ever Since* | 10 | 5 | 54 | loose |
| Ken Carson | Everyday* | 5 | 3 | 17 | loose |
| Ken Carson | Evolution | 82 | 74 | 310 | loose |
| Ken Carson | Exodus | 62 | 71 | 546 | loose |
| Ken Carson | FUCK IT (5) | 53 | 35 | 324 | loose |
| Ken Carson | FWM | 14 | 6 | 56 | loose |
| Ken Carson | Fan Behavior | 54 | 71 | 251 | loose |
| Ken Carson | Fashion Habits | 32 | 29 | 183 | loose |
| Ken Carson | Fell In Love | 43 | 91 | 206 | loose |
| Ken Carson | Fighting My Demons | 28 | 34 | 101 | loose |
| Ken Carson | Fire* | 3 | 0 | 3 | loose |
| Ken Carson | Flexing (Exotic) | 31 | 49 | 222 | loose |
| Ken Carson | Fold | 22 | 35 | 242 | loose |
| Ken Carson | For Her | 22 | 32 | 162 | loose |
| Ken Carson | For Sum | 24 | 35 | 94 | loose |
| Ken Carson | Foreign Car* | 5 | 0 | 16 | loose |
| Ken Carson | Forsaken (Put It On)* | 9 | 21 | 102 | loose |
| Ken Carson | Freestyle 1 | 55 | 129 | 318 | loose |
| Ken Carson | Freestyle 2 | 39 | 62 | 236 | loose |
| Ken Carson | Freestyle 3 | 41 | 40 | 242 | loose |
| Ken Carson | Fuck for the Money* | 5 | 0 | 29 | loose |
| Ken Carson | Fuk 12 | 21 | 35 | 100 | loose |
| Ken Carson | Game Over* | 18 | 31 | 39 | loose |
| Ken Carson | Geeked | 27 | 30 | 163 | loose |
| Ken Carson | Geeked Up | 18 | 11 | 108 | loose |
| Ken Carson | Gems | 39 | 53 | 212 | loose |
| Ken Carson | Get Off | 34 | 72 | 189 | loose |
| Ken Carson | Get Rich Or Die | 40 | 101 | 199 | loose |
| Ken Carson | Ghoul | 62 | 78 | 223 | loose |
| Ken Carson | Give Up* | 4 | 0 | 33 | loose |
| Ken Carson | Glock 19 | 18 | 29 | 110 | loose |
| Ken Carson | Glow | 17 | 35 | 35 | loose |
| Ken Carson | Go | 29 | 51 | 120 | loose |
| Ken Carson | Going Krazy | 34 | 17 | 118 | loose |
| Ken Carson | Going Schitz | 33 | 58 | 228 | loose |
| Ken Carson | Gold Medal | 33 | 51 | 143 | loose |
| Ken Carson | Gon’ Blow (KENC&BOAT) | 19 | 28 | 167 | loose |
| Ken Carson | Green Bean | 26 | 30 | 79 | loose |
| Ken Carson | Green Room | 41 | 43 | 313 | loose |
| Ken Carson | Gucci Socks* | 13 | 13 | 88 | loose |
| Ken Carson | Gëek high | 42 | 38 | 169 | loose |
| Ken Carson | Hardcore | 23 | 28 | 151 | loose |
| Ken Carson | Hell Yeah | 36 | 64 | 123 | loose |
| Ken Carson | Hella | 35 | 70 | 148 | AAAA |
| Ken Carson | Hellcat | 43 | 48 | 243 | loose |
| Ken Carson | Hello Kitty* | 12 | 15 | 66 | loose |
| Ken Carson | High | 23 | 16 | 32 | loose |
| Ken Carson | High as Sh!T | 20 | 16 | 57 | loose |
| Ken Carson | How 2 Flex | 26 | 34 | 127 | loose |
| Ken Carson | How It Feel | 26 | 36 | 86 | loose |
| Ken Carson | How You Keep It | 28 | 63 | 107 | loose |
| Ken Carson | Hunnid Rounds | 5 | 2 | 16 | AABB |
| Ken Carson | I Serve X | 36 | 57 | 91 | loose |
| Ken Carson | Ice | 35 | 80 | 144 | AAAA |
| Ken Carson | Iced Out Wrist* | 7 | 6 | 11 | loose |
| Ken Carson | Inferno | 40 | 38 | 256 | loose |
| Ken Carson | Intro | 50 | 40 | 181 | loose |
| Ken Carson | It’s Over | 22 | 14 | 70 | loose |
| Ken Carson | I’m Different (Emotionless) | 43 | 32 | 232 | loose |
| Ken Carson | JPG* | 17 | 13 | 89 | loose |
| Ken Carson | Jennifer’s Body | 29 | 43 | 167 | loose |
| Ken Carson | Jumanji | 32 | 38 | 209 | loose |
| Ken Carson | Jus Sayin | 39 | 61 | 298 | loose |
| Ken Carson | Jus bëtter (Original) | 42 | 38 | 168 | loose |
| Ken Carson | Just Might | 50 | 63 | 240 | loose |
| Ken Carson | K-Hole | 48 | 48 | 302 | loose |
| Ken Carson | KOBK (Kill Or Be Killed)* | 10 | 15 | 63 | AAAA |
| Ken Carson | Killstreak | 32 | 58 | 135 | loose |
| Ken Carson | Know The Price | 26 | 45 | 96 | loose |
| Ken Carson | Kryptonite | 30 | 32 | 268 | loose |
| Ken Carson | Kurt Cobain* | 47 | 45 | 221 | loose |
| Ken Carson | LET ME TOUCH* | 5 | 3 | 19 | loose |
| Ken Carson | Like This | 47 | 50 | 297 | loose |
| Ken Carson | Lil Vamp | 28 | 35 | 352 | loose |
| Ken Carson | Line Them Up | 44 | 65 | 252 | loose |
| Ken Carson | LiveLeak | 46 | 57 | 302 | loose |
| Ken Carson | Load | 36 | 50 | 48 | loose |
| Ken Carson | Loaded* | 5 | 4 | 27 | AABB |
| Ken Carson | Lookbook | 33 | 34 | 210 | loose |
| Ken Carson | Loot | 14 | 11 | 56 | loose |
| Ken Carson | Lord Of Chaos | 32 | 37 | 215 | loose |
| Ken Carson | Lose It | 30 | 58 | 115 | loose |
| Ken Carson | Lotto* | 8 | 8 | 44 | loose |
| Ken Carson | Love Me* | 12 | 6 | 56 | loose |
| Ken Carson | Luv the Violence | 25 | 43 | 47 | loose |
| Ken Carson | M&M | 29 | 38 | 138 | loose |
| Ken Carson | MDMA | 60 | 110 | 443 | loose |
| Ken Carson | Maaly Freestyle (Do It All) | 57 | 64 | 215 | loose |
| Ken Carson | Maaly Raw* | 6 | 2 | 17 | loose |
| Ken Carson | Mad* | 6 | 1 | 29 | loose |
| Ken Carson | Magic* | 6 | 14 | 14 | AAAA |
| Ken Carson | Magician | 30 | 43 | 191 | loose |
| Ken Carson | Me N My Kup | 45 | 45 | 258 | loose |
| Ken Carson | Me vs. Me* | 9 | 2 | 15 | loose |
| Ken Carson | Meds | 16 | 21 | 84 | loose |
| Ken Carson | Meet Me At The Top* | 18 | 17 | 58 | loose |
| Ken Carson | Misfit | 35 | 40 | 190 | loose |
| Ken Carson | Miss U* | 7 | 2 | 17 | loose |
| Ken Carson | Missing | 26 | 43 | 112 | loose |
| Ken Carson | Money Hungry | 21 | 25 | 47 | loose |
| Ken Carson | Money Hunt | 24 | 14 | 63 | loose |
| Ken Carson | Money Run | 31 | 56 | 213 | loose |
| Ken Carson | Money Spread | 15 | 8 | 47 | loose |
| Ken Carson | Moshpit | 18 | 31 | 77 | AAAA |
| Ken Carson | Murda Musik | 31 | 57 | 208 | loose |
| Ken Carson | Murder She Wrote | 35 | 53 | 162 | loose |
| Ken Carson | NOISOME* | 27 | 38 | 119 | loose |
| Ken Carson | Naked | 46 | 48 | 310 | loose |
| Ken Carson | Natural Habitat | 42 | 33 | 114 | loose |
| Ken Carson | Netflix & Chill | 38 | 44 | 141 | loose |
| Ken Carson | Never Switch* | 10 | 8 | 11 | loose |
| Ken Carson | New | 35 | 53 | 145 | loose |
| Ken Carson | New Age Rockstar* | 3 | 1 | 15 | loose |
| Ken Carson | New Body* | 20 | 44 | 144 | loose |
| Ken Carson | Night (LiveLeak Original) | 16 | 11 | 62 | loose |
| Ken Carson | No Numbers* | 8 | 3 | 20 | loose |
| Ken Carson | No One | 8 | 2 | 27 | loose |
| Ken Carson | No Other Way* | 36 | 29 | 112 | loose |
| Ken Carson | No Photos | 37 | 62 | 209 | loose |
| Ken Carson | No Reason | 7 | 3 | 24 | loose |
| Ken Carson | No Smoke* | 16 | 9 | 82 | loose |
| Ken Carson | No Time Freestyle* | 8 | 7 | 73 | loose |
| Ken Carson | No Way* | 21 | 32 | 178 | loose |
| Ken Carson | No Wings* | 8 | 7 | 48 | loose |
| Ken Carson | Nobody | 25 | 26 | 218 | loose |
| Ken Carson | Norbit* | 3 | 3 | 13 | loose |
| Ken Carson | Novacane | 29 | 38 | 217 | loose |
| Ken Carson | Nun’ Less | 45 | 55 | 295 | loose |
| Ken Carson | OFF DA FACE | 29 | 26 | 150 | loose |
| Ken Carson | Odell* | 10 | 7 | 80 | loose |
| Ken Carson | Off The Meter | 47 | 63 | 232 | loose |
| Ken Carson | Old Nat | 38 | 41 | 309 | loose |
| Ken Carson | Olympics | 25 | 40 | 125 | loose |
| Ken Carson | On Deck | 15 | 16 | 56 | loose |
| Ken Carson | On Sight | 41 | 61 | 175 | loose |
| Ken Carson | On the Low | 16 | 37 | 141 | loose |
| Ken Carson | One of None* | 4 | 0 | 10 | loose |
| Ken Carson | Otto Rocket | 28 | 35 | 92 | loose |
| Ken Carson | Out the Bank | 38 | 31 | 205 | loose |
| Ken Carson | Over There* | 8 | 9 | 27 | loose |
| Ken Carson | Overtime | 14 | 17 | 60 | loose |
| Ken Carson | PB&J | 49 | 31 | 180 | loose |
| Ken Carson | PDBMH | 30 | 43 | 181 | loose |
| Ken Carson | PSYCH!N | 11 | 1 | 9 | loose |
| Ken Carson | PURPLE (PB&J Original) | 24 | 32 | 105 | loose |
| Ken Carson | Paranoid | 20 | 19 | 87 | loose |
| Ken Carson | Party All Day | 47 | 72 | 146 | loose |
| Ken Carson | Patrick Ewing | 44 | 53 | 142 | loose |
| Ken Carson | Peel | 40 | 32 | 306 | loose |
| Ken Carson | Perc* | 4 | 3 | 4 | ABAA |
| Ken Carson | Pink Panther | 42 | 74 | 123 | loose |
| Ken Carson | Pissed Off | 18 | 15 | 142 | loose |
| Ken Carson | Play Wit Her Nose | 53 | 61 | 240 | loose |
| Ken Carson | Playing For Keeps | 57 | 56 | 227 | loose |
| Ken Carson | Please Don’t Leave | 25 | 20 | 91 | loose |
| Ken Carson | Poker | 15 | 16 | 35 | loose |
| Ken Carson | Pop (X TWO THREE) | 24 | 36 | 159 | loose |
| Ken Carson | Pots | 26 | 55 | 178 | loose |
| Ken Carson | Pourin’ Up | 33 | 42 | 168 | loose |
| Ken Carson | President | 46 | 107 | 360 | loose |
| Ken Carson | Pretty Girls | 30 | 46 | 209 | loose |
| Ken Carson | Private | 29 | 31 | 203 | loose |
| Ken Carson | Problems | 33 | 36 | 245 | loose |
| Ken Carson | Proud Family (Diamonds Original) | 19 | 9 | 100 | loose |
| Ken Carson | Psycho | 37 | 37 | 230 | loose |
| Ken Carson | Pull Up | 107 | 118 | 397 | loose |
| Ken Carson | Pussy Pink | 52 | 64 | 195 | loose |
| Ken Carson | RICK OWENS | 28 | 22 | 248 | loose |
| Ken Carson | RICKBODY | 3 | 3 | 10 | loose |
| Ken Carson | Rage | 28 | 48 | 176 | loose |
| Ken Carson | Raver | 73 | 87 | 449 | loose |
| Ken Carson | Ready | 46 | 114 | 300 | AAAA |
| Ken Carson | Ready to Die | 39 | 44 | 272 | loose |
| Ken Carson | Real Deal Vampire | 58 | 71 | 414 | loose |
| Ken Carson | Rich As Hell* | 9 | 7 | 67 | loose |
| Ken Carson | Rick | 40 | 53 | 271 | loose |
| Ken Carson | Ricky | 18 | 13 | 128 | loose |
| Ken Carson | Right Now* | 23 | 12 | 149 | loose |
| Ken Carson | Rock N Roll | 33 | 42 | 154 | loose |
| Ken Carson | Rocked Out | 55 | 32 | 391 | loose |
| Ken Carson | Rockstar Lifestyle | 44 | 39 | 325 | loose |
| Ken Carson | Root Of All Evil | 34 | 23 | 280 | loose |
| Ken Carson | Rubberbandz Poppin | 47 | 85 | 163 | loose |
| Ken Carson | Run + Ran | 51 | 55 | 246 | loose |
| Ken Carson | SRT | 34 | 72 | 237 | AAAA |
| Ken Carson | SRTBBL | 47 | 83 | 345 | loose |
| Ken Carson | STAY HERE 4 LIFE | 58 | 40 | 454 | loose |
| Ken Carson | Same Thing | 33 | 35 | 170 | loose |
| Ken Carson | Scene | 59 | 59 | 336 | loose |
| Ken Carson | See You Tomorrow | 29 | 31 | 110 | loose |
| Ken Carson | She Want Some More | 56 | 107 | 203 | loose |
| Ken Carson | Shoot | 33 | 43 | 202 | loose |
| Ken Carson | Shoot It Up | 45 | 31 | 160 | loose |
| Ken Carson | Shoot Up* | 5 | 1 | 10 | loose |
| Ken Carson | Should’ve Listened (X TWO THREE) | 54 | 110 | 416 | loose |
| Ken Carson | Since Birth* | 4 | 3 | 26 | loose |
| Ken Carson | Singapore | 32 | 28 | 242 | loose |
| Ken Carson | So What | 35 | 42 | 171 | loose |
| Ken Carson | Someone | 38 | 46 | 178 | loose |
| Ken Carson | South Beach | 24 | 30 | 171 | loose |
| Ken Carson | Start Something | 38 | 51 | 251 | loose |
| Ken Carson | Stick | 38 | 43 | 225 | loose |
| Ken Carson | Sticks | 28 | 29 | 249 | loose |
| Ken Carson | Straight To Heaven* | 7 | 6 | 29 | loose |
| Ken Carson | Stunt | 56 | 84 | 296 | loose |
| Ken Carson | Succubus | 28 | 43 | 174 | loose |
| Ken Carson | Superstar* | 10 | 12 | 45 | loose |
| Ken Carson | Swag Overload | 39 | 52 | 201 | loose |
| Ken Carson | Switch* | 25 | 33 | 110 | loose |
| Ken Carson | Switchblade* | 2 | 1 | 4 | loose |
| Ken Carson | THRILL | 65 | 118 | 300 | loose |
| Ken Carson | TIGHTEN UP | 46 | 63 | 176 | loose |
| Ken Carson | TUMS | 19 | 20 | 84 | loose |
| Ken Carson | Take Your Life* | 20 | 27 | 85 | loose |
| Ken Carson | Taste* | 9 | 3 | 28 | loose |
| Ken Carson | Teen Bean | 44 | 73 | 150 | loose |
| Ken Carson | Teen X | 29 | 29 | 106 | loose |
| Ken Carson | Teen X Babe | 24 | 68 | 108 | loose |
| Ken Carson | Teenager Rager | 28 | 37 | 94 | loose |
| Ken Carson | Tesla (Blakk Rokkstar Original) | 18 | 19 | 96 | loose |
| Ken Carson | The End | 31 | 36 | 123 | loose |
| Ken Carson | Thief in the Night* | 6 | 3 | 36 | loose |
| Ken Carson | Throw It | 28 | 65 | 75 | AAAA |
| Ken Carson | Thx | 38 | 27 | 236 | loose |
| Ken Carson | Tic Tac Toe | 41 | 61 | 171 | loose |
| Ken Carson | Till I Die | 54 | 95 | 169 | loose |
| Ken Carson | Too Many Drugs* | 16 | 8 | 40 | loose |
| Ken Carson | Too Much | 5 | 1 | 49 | ABCB |
| Ken Carson | Trap Jump | 41 | 36 | 260 | loose |
| Ken Carson | Trip Wit Me | 28 | 23 | 103 | loose |
| Ken Carson | Tripped Out | 5 | 9 | 6 | ABCB |
| Ken Carson | Try It | 31 | 43 | 154 | loose |
| Ken Carson | Turn Up | 30 | 43 | 73 | loose |
| Ken Carson | VETERAN | 62 | 82 | 403 | loose |
| Ken Carson | VMP (LiveLeak Original) | 2 | 0 | 6 | loose |
| Ken Carson | Vampire Hour | 32 | 48 | 183 | loose |
| Ken Carson | Vampires* | 5 | 8 | 45 | ABAB |
| Ken Carson | WOKEUPxd (2025) | 14 | 2 | 31 | loose |
| Ken Carson | Werewolf (Dracula) | 19 | 13 | 79 | loose |
| Ken Carson | What I Need | 31 | 47 | 164 | loose |
| Ken Carson | What You Know | 39 | 57 | 106 | loose |
| Ken Carson | When I’m Gone | 55 | 49 | 221 | loose |
| Ken Carson | Where TF (Fighting My Demons Original) | 9 | 7 | 30 | loose |
| Ken Carson | Who’s Next | 24 | 38 | 126 | loose |
| Ken Carson | Why | 20 | 18 | 73 | loose |
| Ken Carson | Woah* | 2 | 0 | 0 | loose |
| Ken Carson | Wockstar | 48 | 112 | 167 | loose |
| Ken Carson | Workin On Me | 32 | 54 | 167 | loose |
| Ken Carson | X | 34 | 47 | 165 | loose |
| Ken Carson | X Games (X TWO THREE) | 27 | 45 | 209 | loose |
| Ken Carson | X for Breakfast (X TWO THREE) | 43 | 83 | 354 | loose |
| Ken Carson | Xposed | 58 | 53 | 314 | loose |
| Ken Carson | Yale | 14 | 18 | 149 | loose |
| Ken Carson | Yoda | 14 | 27 | 96 | loose |
| Ken Carson | Yuck | 69 | 71 | 388 | loose |
| Ken Carson | addiction | 78 | 105 | 345 | loose |
| Ken Carson | amandabynes | 32 | 34 | 223 | loose |
| Ken Carson | amnesia | 29 | 29 | 165 | loose |
| Ken Carson | back from the dead | 29 | 39 | 242 | loose |
| Ken Carson | bad day* | 7 | 1 | 6 | loose |
| Ken Carson | blk | 27 | 29 | 160 | loose |
| Ken Carson | blood on the leaves (remix) | 93 | 95 | 512 | loose |
| Ken Carson | bloody mary | 57 | 83 | 231 | loose |
| Ken Carson | bosses | 30 | 42 | 161 | loose |
| Ken Carson | by my lonely | 42 | 64 | 163 | loose |
| Ken Carson | call up yo shooters | 14 | 9 | 99 | loose |
| Ken Carson | can’t feel my legs | 43 | 29 | 239 | loose |
| Ken Carson | catastrophe | 48 | 54 | 198 | loose |
| Ken Carson | clutch remix | 26 | 22 | 87 | loose |
| Ken Carson | copy cats | 34 | 70 | 192 | loose |
| Ken Carson | country grammar | 34 | 23 | 260 | loose |
| Ken Carson | cut it down | 46 | 53 | 301 | loose |
| Ken Carson | deaf note | 57 | 42 | 328 | loose |
| Ken Carson | delusional | 34 | 21 | 148 | loose |
| Ken Carson | disturbing the peace | 26 | 28 | 182 | loose |
| Ken Carson | dream | 37 | 37 | 118 | loose |
| Ken Carson | drug kit | 49 | 34 | 361 | loose |
| Ken Carson | drugs_over_love :{ | 31 | 63 | 266 | loose |
| Ken Carson | eaters | 34 | 42 | 115 | loose |
| Ken Carson | edm | 50 | 44 | 322 | loose |
| Ken Carson | fake news | 55 | 52 | 276 | loose |
| Ken Carson | flamethrower | 24 | 18 | 92 | loose |
| Ken Carson | flexin | 23 | 12 | 167 | loose |
| Ken Carson | free dro | 55 | 96 | 216 | loose |
| Ken Carson | free young thug | 29 | 23 | 200 | loose |
| Ken Carson | fuk shit | 22 | 22 | 49 | loose |
| Ken Carson | full moon. (fall in tokyo) | 10 | 3 | 13 | loose |
| Ken Carson | fw00 | 28 | 30 | 192 | loose |
| Ken Carson | gang | 66 | 105 | 324 | loose |
| Ken Carson | ghost | 106 | 157 | 401 | loose |
| Ken Carson | glock with a switch | 41 | 66 | 273 | loose |
| Ken Carson | gynecologist | 46 | 52 | 161 | loose |
| Ken Carson | hang_fire :/ | 41 | 22 | 165 | loose |
| Ken Carson | higher & flyer | 43 | 55 | 138 | loose |
| Ken Carson | i need u | 32 | 37 | 136 | loose |
| Ken Carson | i_influence | 36 | 22 | 165 | loose |
| Ken Carson | im in this bitch | 3 | 1 | 0 | loose |
| Ken Carson | interlude | 21 | 43 | 166 | loose |
| Ken Carson | iwin* | 3 | 1 | 11 | loose |
| Ken Carson | keep goin | 20 | 10 | 95 | loose |
| Ken Carson | kicked out the bnb | 63 | 59 | 400 | loose |
| Ken Carson | knocking | 39 | 47 | 290 | loose |
| Ken Carson | leather jacket | 26 | 59 | 124 | loose |
| Ken Carson | lets go shoppin | 31 | 57 | 175 | loose |
| Ken Carson | loading | 47 | 40 | 160 | loose |
| Ken Carson | margiela | 33 | 33 | 279 | loose |
| Ken Carson | mewtwo | 24 | 35 | 118 | loose |
| Ken Carson | midnight massacre | 50 | 59 | 346 | loose |
| Ken Carson | molly | 49 | 63 | 341 | loose |
| Ken Carson | money & sex | 64 | 116 | 463 | loose |
| Ken Carson | money stretch | 24 | 39 | 148 | loose |
| Ken Carson | more chaos | 37 | 48 | 145 | loose |
| Ken Carson | no love | 10 | 22 | 59 | loose |
| Ken Carson | off a bean | 32 | 34 | 203 | loose |
| Ken Carson | open it up | 41 | 20 | 220 | loose |
| Ken Carson | outofmybody | 33 | 43 | 202 | loose |
| Ken Carson | overseas | 24 | 51 | 155 | loose |
| Ken Carson | peppermint | 40 | 41 | 296 | loose |
| Ken Carson | phenomenon | 21 | 22 | 184 | loose |
| Ken Carson | player | 35 | 51 | 156 | loose |
| Ken Carson | pose 2 do | 28 | 36 | 54 | loose |
| Ken Carson | possession | 31 | 38 | 126 | loose |
| Ken Carson | prayer* (2026) | 34 | 67 | 175 | loose |
| Ken Carson | r_u_srs_? | 42 | 48 | 255 | loose |
| Ken Carson | rare creature | 31 | 23 | 246 | loose |
| Ken Carson | rollin | 15 | 11 | 51 | loose |
| Ken Carson | roxy reynolds | 48 | 74 | 218 | loose |
| Ken Carson | scrape | 56 | 55 | 174 | loose |
| Ken Carson | shadeson | 28 | 39 | 220 | loose |
| Ken Carson | shopping | 61 | 51 | 275 | loose |
| Ken Carson | shut yo mouth when you talkin 2 me | 80 | 119 | 277 | loose |
| Ken Carson | somanybags | 19 | 20 | 94 | loose |
| Ken Carson | spaced out | 52 | 52 | 101 | loose |
| Ken Carson | ss | 30 | 27 | 186 | loose |
| Ken Carson | stolie | 41 | 25 | 275 | loose |
| Ken Carson | stoner | 6 | 2 | 12 | loose |
| Ken Carson | stuck | 23 | 37 | 74 | loose |
| Ken Carson | suicidal | 41 | 73 | 237 | loose |
| Ken Carson | swag jack | 34 | 41 | 195 | loose |
| Ken Carson | the acronym | 42 | 43 | 294 | loose |
| Ken Carson | the ritual | 45 | 45 | 237 | loose |
| Ken Carson | these hoes smdh | 47 | 58 | 281 | loose |
| Ken Carson | too many poles | 29 | 24 | 133 | loose |
| Ken Carson | touchdown | 43 | 61 | 253 | loose |
| Ken Carson | toxic | 37 | 46 | 221 | loose |
| Ken Carson | truth | 28 | 34 | 234 | loose |
| Ken Carson | upside_down | 36 | 47 | 114 | loose |
| Ken Carson | vamp city | 23 | 30 | 128 | loose |
| Ken Carson | wedidit | 54 | 75 | 319 | loose |
| Ken Carson | wheredoistart | 36 | 51 | 235 | loose |
| Ken Carson | wrinkles | 50 | 56 | 459 | loose |
| Ken Carson | wrist | 36 | 38 | 265 | loose |
| Ken Carson | yes | 45 | 46 | 283 | loose |
| Ken Carson | yves saint laurent | 24 | 24 | 58 | loose |
| Ken Carson | yvngvmp | 40 | 38 | 327 | loose |
| Ken Carson | баленсиага боты (balenciaga boots) | 15 | 14 | 93 | loose |
| Ken Carson | ‎over_dosed | 23 | 28 | 69 | loose |
| Ken Carson | ‎sh00t | 19 | 16 | 95 | loose |
| Ken Carson | ‎x2 | 33 | 57 | 164 | loose |
