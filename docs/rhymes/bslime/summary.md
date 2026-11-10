# BSlime rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: BSlime
- Songs: 69
- Bars kept (BSlime lyric lines): 2847
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: BSlime.
- Credit strings: BSlime.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 17065
- REPEAT pairs, recorded separately: 1914
- END rhymes: 3007
- INNER rhymes: 14058

By match:

- PERFECT: 1336 (END 361, INNER 975)
- SLANT: 7316 (END 1238, INNER 6078)
- ASSONANCE: 8222 (END 1364, INNER 6858)
- MULTI: 191 (END 44, INNER 147)

By confidence:

- HIGH: 1411
- MED: 14471
- LOW: 1183

## Core

- Core Y: 16816
- Core N among rhyme pairs: 249

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 7603 (44.6%)
- vowel: 8222 (48.2%)
- spelling: 1049 (6.1%)
- multi: 191 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- loose: 68 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 1290 pairs (END 178, INNER 1112). Words: bitch, shit, bitches, think, lil, business, wrist, him.
2. `vow:EY` — 1052 pairs (END 156, INNER 896). Words: ain't, say, way, play, stay, ain’t, take, make.
3. `vow:OW` — 959 pairs (END 118, INNER 841). Words: know, don't, no, told, go, ho, hoes, don’t.
4. `vow:AE` — 843 pairs (END 162, INNER 681). Words: can't, back, racks, had, can, have, ass, cash.
5. `vow:AA` — 842 pairs (END 90, INNER 752). Words: got, nothin, poppin, want, wanna, talkin, dogs, not.
6. `vow:EH` — 806 pairs (END 141, INNER 665). Words: get, when, tell, remember, went, gettin, said, where.
7. `vow:AH` — 712 pairs (END 97, INNER 615). Words: some, fuck, fucked, jumped, fuckin, money, love, nothing.
8. `vow:AY` — 704 pairs (END 141, INNER 563). Words: like, diamonds, why, slime, time, ridin, die, by.
9. `vow:IY` — 569 pairs (END 136, INNER 433). Words: these, see, streets, need, p, here, people, g.
10. `slant:IH:stop` — 390 pairs (END 43, INNER 347). Words: nigga, shit, big, hit, stick, dick, drip, trick.
11. `slant:AA:stop` — 375 pairs (END 36, INNER 339). Words: got, not, want, gotta, block, pop, top, drop.
12. `slant:IH:sib-stop` — 297 pairs (END 63, INNER 234). Words: bitch, nigga, niggas, shit, rich, dick, hit, drip.
13. `slant:AH:nas-stop` — 226 pairs (END 20, INNER 206). Words: fuck, some, what, money, one, come, done, run.
14. `cmu:OW` — 224 pairs (END 17, INNER 207). Words: no, know, go, ho, show, bro, slow, blow.
15. `slant:AH:nas` — 213 pairs (END 18, INNER 195). Words: some, money, come, one, young, run, done, runnin.
16. `slant:AE:stop` — 202 pairs (END 46, INNER 156). Words: back, had, can't, slatt, trap, hand, bad, whacked.
17. `slant:IH:nas-stop` — 193 pairs (END 6, INNER 187). Words: him, shit, i'ma, hit, big, everything, stick, whip.
18. `slant:AA:nas-stop` — 176 pairs (END 8, INNER 168). Words: wanna, got, mama, not, pop, poppin, want, block.
19. `slant:EY:stop` — 172 pairs (END 30, INNER 142). Words: ain't, make, made, baby, paper, straight, take, wait.
20. `slant:EH:stop` — 167 pairs (END 27, INNER 140). Words: get, went, head, neck, red, check, said, better.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 285 pair sides, mostly spelling via spelling phonetic key, often with niggas (76)
- niggas — 120 pair sides, mostly spelling via spelling phonetic key, often with nigga (76)
- ima — 88 pair sides, mostly spelling via spelling phonetic key, often with bitch (20)
- gon — 63 pair sides, mostly spelling via spelling phonetic key, often with dont (17)
- bslime — 36 pair sides, mostly spelling via spelling phonetic key, often with bdime (5)
- tryna — 33 pair sides, mostly spelling via spelling phonetic key, often with keep (4)
- shawty — 26 pair sides, mostly vowel via spelling phonetic key, often with all (6)
- blicky — 25 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- bdime — 21 pair sides, mostly spelling via spelling phonetic key, often with bslime (5)
- slatt — 20 pair sides, mostly spelling via spelling phonetic key, often with back (3)
- slimes — 16 pair sides, mostly spelling via spelling phonetic key, often with business (3)
- thot — 14 pair sides, mostly spelling via spelling phonetic key, often with know (4)
- bros — 14 pair sides, mostly spelling via spelling phonetic key, often with clothes (2)
- imma — 12 pair sides, mostly vowel via spelling phonetic key, often with nigga (4)
- finna — 12 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- tris — 11 pair sides, mostly spelling via spelling phonetic key, often with spit (1)
- jacker — 11 pair sides, mostly spelling via spelling phonetic key, often with trappers (1)
- swag — 10 pair sides, mostly spelling via spelling phonetic key, often with gang (2)
- opps — 10 pair sides, mostly vowel via spelling phonetic key, often with know (6)
- keed — 9 pair sides, mostly spelling via spelling phonetic key, often with keep (3)
- slatty — 9 pair sides, mostly spelling via spelling phonetic key, often with slatt (2)
- brung — 9 pair sides, mostly spelling via spelling phonetic key, often with fuck (3)
- slushy — 9 pair sides, mostly spelling via spelling phonetic key, often with blurry (1)
- scuti — 9 pair sides, mostly spelling via spelling phonetic key, often with one (4)
- dyin — 9 pair sides, mostly spelling via spelling phonetic key, often with tryin (4)
- youngin — 9 pair sides, mostly spelling via spelling phonetic key, often with fuckin (2)
- thugga — 8 pair sides, mostly spelling via spelling phonetic key, often with struggle (8)
- gotit — 8 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- britch — 8 pair sides, mostly spelling via spelling phonetic key, often with killin (2)
- stickbaby — 8 pair sides, mostly vowel via spelling phonetic key, often with baby (7)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| BSlime | 1 Diamond Missing | 42 | 47 | 184 | loose |
| BSlime | Ain’t No Fallin Off | 37 | 55 | 204 | loose |
| BSlime | Alphabet Boys | 24 | 27 | 114 | loose |
| BSlime | Baguette | 52 | 89 | 220 | loose |
| BSlime | Believe That | 41 | 37 | 228 | loose |
| BSlime | Bvlgari | 94 | 89 | 559 | loose |
| BSlime | Came From Nothing | 40 | 15 | 261 | loose |
| BSlime | Can’t Fail | 19 | 16 | 60 | loose |
| BSlime | Can’t Play Both Sides | 40 | 80 | 221 | loose |
| BSlime | Changed Me | 51 | 65 | 235 | loose |
| BSlime | Chew | 38 | 53 | 160 | loose |
| BSlime | Come Wit It | 44 | 30 | 117 | loose |
| BSlime | Crocodile Skin | 29 | 15 | 146 | loose |
| BSlime | Doors Off | 29 | 21 | 169 | loose |
| BSlime | G6 | 40 | 24 | 123 | loose |
| BSlime | God See It | 37 | 40 | 172 | loose |
| BSlime | Gotta Love Us | 81 | 70 | 412 | loose |
| BSlime | Grab It | 39 | 43 | 134 | loose |
| BSlime | Grandma’s Baby | 42 | 53 | 250 | loose |
| BSlime | Harriet Tubman | 42 | 69 | 189 | loose |
| BSlime | Hazard Lights ATL ⚠️ | 35 | 23 | 185 | loose |
| BSlime | Hell Yeah | 45 | 39 | 143 | loose |
| BSlime | Hoodie | 47 | 58 | 237 | loose |
| BSlime | I Don’t Deserve That Cap | 44 | 51 | 238 | loose |
| BSlime | I Want It | 67 | 99 | 262 | loose |
| BSlime | Keep Tryin’ | 47 | 59 | 192 | loose |
| BSlime | Know What to Do With It | 50 | 44 | 186 | loose |
| BSlime | Little Haiti | 50 | 67 | 230 | loose |
| BSlime | Love Me or Don’t | 44 | 34 | 321 | loose |
| BSlime | Meet My Grave | 30 | 27 | 167 | loose |
| BSlime | Mislead | 31 | 40 | 100 | loose |
| BSlime | Monster (Remix) | 52 | 31 | 172 | loose |
| BSlime | Murder Man | 40 | 63 | 169 | loose |
| BSlime | No Surprise | 43 | 45 | 205 | loose |
| BSlime | Off the Lot | 21 | 24 | 85 | loose |
| BSlime | Okay Then | 20 | 14 | 122 | loose |
| BSlime | Opp Top | 21 | 18 | 319 | loose |
| BSlime | Peepin Out The Window | 36 | 24 | 315 | loose |
| BSlime | Pill | 42 | 39 | 194 | loose |
| BSlime | Poolside | 36 | 37 | 164 | loose |
| BSlime | Poppin’ | 29 | 46 | 99 | loose |
| BSlime | Rage | 35 | 44 | 121 | loose |
| BSlime | Rain Don’t Come | 33 | 13 | 194 | loose |
| BSlime | Real Spill | 37 | 42 | 172 | loose |
| BSlime | Real Talk | 60 | 32 | 209 | loose |
| BSlime | Really Be Slime | 50 | 47 | 174 | loose |
| BSlime | Ridin’ Round | 25 | 25 | 119 | loose |
| BSlime | Seal | 32 | 38 | 168 | loose |
| BSlime | Separation | 34 | 30 | 224 | loose |
| BSlime | Shut Up & Walk | 58 | 41 | 214 | loose |
| BSlime | Slide at Night | 48 | 58 | 347 | loose |
| BSlime | SlimeOSnakin | 55 | 47 | 318 | loose |
| BSlime | So Slime | 106 | 110 | 534 | loose |
| BSlime | Stephen Curry | 37 | 47 | 312 | loose |
| BSlime | Take from Me | 36 | 35 | 130 | loose |
| BSlime | That’s Okay | 26 | 46 | 143 | loose |
| BSlime | Truth or Dare | 34 | 29 | 214 | loose |
| BSlime | Tryna Get Me | 44 | 33 | 157 | loose |
| BSlime | Tuck Yo Heart | 23 | 50 | 70 | loose |
| BSlime | Turnt Up | 53 | 86 | 257 | loose |
| BSlime | Two Face | 30 | 23 | 168 | loose |
| BSlime | Wait For It | 20 | 8 | 82 | loose |
| BSlime | Walk Thru | 40 | 43 | 162 | loose |
| BSlime | Walkin’ | 43 | 53 | 267 | loose |
| BSlime | War Ready | 18 | 46 | 120 | AAAA |
| BSlime | Water | 33 | 28 | 173 | loose |
| BSlime | We da Gang | 52 | 57 | 177 | loose |
| BSlime | Whippin It | 32 | 30 | 213 | loose |
| BSlime | ØWAYSL | 62 | 46 | 356 | loose |
