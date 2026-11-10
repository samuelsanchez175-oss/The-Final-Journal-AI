# Young Dolph rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Young Dolph
- Songs: 632
- Bars kept (Young Dolph lyric lines): 25431
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 25
- Canonical name: Young Dolph.
- Credit strings: Young Dolph.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 154359
- REPEAT pairs, recorded separately: 19991
- END rhymes: 26238
- INNER rhymes: 128121

By match:

- PERFECT: 11804 (END 3712, INNER 8092)
- SLANT: 66096 (END 10909, INNER 55187)
- ASSONANCE: 75095 (END 11145, INNER 63950)
- MULTI: 1364 (END 472, INNER 892)

By confidence:

- HIGH: 11731
- MED: 133031
- LOW: 9597

## Core

- Core Y: 152111
- Core N among rhyme pairs: 2248

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 69133 (44.8%)
- vowel: 75095 (48.6%)
- spelling: 8767 (5.7%)
- multi: 1364 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 2 songs
- ABCB: 1 songs
- loose: 629 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 12021 pairs (END 1609, INNER 10412). Words: bitch, bitches, shit, million, think, lil, wrist, still.
2. `vow:OW` — 9491 pairs (END 970, INNER 8521). Words: don't, no, know, go, told, dolph, whole, dope.
3. `vow:EH` — 8896 pairs (END 1004, INNER 7892). Words: get, memphis, when, never, left, getting, said, went.
4. `vow:AH` — 8239 pairs (END 1137, INNER 7102). Words: hundred, fuck, money, some, love, nothing, what, one.
5. `vow:AE` — 7839 pairs (END 1333, INNER 6506). Words: can't, back, trap, ass, had, racks, bad, man.
6. `vow:EY` — 7493 pairs (END 1245, INNER 6248). Words: ain't, say, way, day, make, paper, stay, play.
7. `vow:AA` — 6715 pairs (END 1064, INNER 5651). Words: got, want, hard, nothin, mama, talkin, wanna, hah.
8. `slant:IH:stop` — 4532 pairs (END 597, INNER 3935). Words: nigga, shit, big, hit, city, dick, lit, wrist.
9. `vow:IY` — 4489 pairs (END 741, INNER 3748). Words: see, these, streets, even, keep, real, three, need.
10. `vow:AY` — 4117 pairs (END 739, INNER 3378). Words: like, why, diamonds, high, time, by, buy, fire.
11. `slant:IH:sib-stop` — 3412 pairs (END 771, INNER 2641). Words: bitch, shit, nigga, niggas, rich, big, hit, dick.
12. `slant:AA:stop` — 3084 pairs (END 360, INNER 2724). Words: got, want, gotta, drop, stop, not, glock, block.
13. `slant:AH:nas-stop` — 2669 pairs (END 125, INNER 2544). Words: fuck, money, what, some, one, young, come, plug.
14. `slant:AE:stop` — 1916 pairs (END 308, INNER 1608). Words: back, trap, had, bad, can't, bag, pack, mad.
15. `slant:EH:stop` — 1832 pairs (END 205, INNER 1627). Words: get, said, went, head, left, let, check, better.
16. `vow:UW` — 1745 pairs (END 465, INNER 1280). Words: two, new, through, who, used, stupid, school, gucci.
17. `vow:AO` — 1600 pairs (END 259, INNER 1341). Words: all, call, wanted, foreign, talking, lost, morning, more.
18. `slant:IH:liq-stop` — 1584 pairs (END 116, INNER 1468). Words: shit, lil, still, really, big, hit, kill, mil.
19. `slant:AH:nas` — 1564 pairs (END 237, INNER 1327). Words: money, some, young, one, come, runnin, fuckin, run.
20. `slant:AE:sib-stop` — 1510 pairs (END 431, INNER 1079). Words: ass, back, cash, trap, bad, racks, bag, had.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 3447 pair sides, mostly spelling via spelling phonetic key, often with shit (931)
- niggas — 1123 pair sides, mostly spelling via spelling phonetic key, often with nigga (715)
- ima — 345 pair sides, mostly spelling via spelling phonetic key, often with bitch (56)
- gon — 323 pair sides, mostly spelling via spelling phonetic key, often with dont (79)
- tryna — 262 pair sides, mostly spelling via spelling phonetic key, often with these (37)
- swag — 178 pair sides, mostly spelling via spelling phonetic key, often with bag (25)
- shawty — 160 pair sides, mostly vowel via spelling phonetic key, often with call (18)
- bruh — 130 pair sides, mostly spelling via spelling phonetic key, often with fuck (22)
- cuz — 75 pair sides, mostly spelling via spelling phonetic key, often with fuck (14)
- guap — 73 pair sides, mostly spelling via spelling phonetic key, often with money (10)
- wraith — 68 pair sides, mostly spelling via spelling phonetic key, often with face (9)
- homie — 60 pair sides, mostly spelling via spelling phonetic key, often with gon (7)
- rari — 60 pair sides, mostly spelling via spelling phonetic key, often with bag (6)
- codeine — 58 pair sides, mostly vowel via spelling phonetic key, often with whole (12)
- skrilla — 57 pair sides, mostly vowel via spelling phonetic key, often with nigga (28)
- imma — 51 pair sides, mostly vowel via spelling phonetic key, often with nigga (19)
- dawg — 51 pair sides, mostly spelling via spelling phonetic key, often with all (8)
- lambo — 45 pair sides, mostly vowel via spelling phonetic key, often with cant (6)
- squeeky — 43 pair sides, mostly vowel via spelling phonetic key, often with see (3)
- flippa — 42 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- ignit — 38 pair sides, mostly vowel via spelling phonetic key, often with nigga (6)
- juiced — 38 pair sides, mostly cmu via vault phonetic_class, often with fuck (5)
- finna — 37 pair sides, mostly vowel via spelling phonetic key, often with nigga (15)
- scrilla — 35 pair sides, mostly vowel via spelling phonetic key, often with nigga (19)
- jeezy — 34 pair sides, mostly vowel via spelling phonetic key, often with these (3)
- gelato — 34 pair sides, mostly vowel via spelling phonetic key, often with get (4)
- gabbana — 33 pair sides, mostly vowel via spelling phonetic key, often with cant (4)
- jit — 33 pair sides, mostly spelling via spelling phonetic key, often with bitch (6)
- glocks — 32 pair sides, mostly vowel via spelling phonetic key, often with know (7)
- homeboy — 31 pair sides, mostly spelling via spelling phonetic key, often with boy (12)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Young Dolph | 1 Hell of a Life | 30 | 68 | 146 | loose |
| Young Dolph | 1 Scale | 69 | 78 | 427 | loose |
| Young Dolph | 1 of 1 | 39 | 27 | 128 | loose |
| Young Dolph | 100 Bands | 51 | 28 | 188 | loose |
| Young Dolph | 12 | 30 | 42 | 177 | loose |
| Young Dolph | 150 | 25 | 24 | 122 | loose |
| Young Dolph | 1st Lady | 39 | 39 | 141 | loose |
| Young Dolph | 1st Of Da Month | 57 | 65 | 209 | loose |
| Young Dolph | 20 Bitches | 38 | 39 | 219 | loose |
| Young Dolph | 24 | 35 | 24 | 101 | loose |
| Young Dolph | 3 Way | 44 | 40 | 303 | loose |
| Young Dolph | 360 | 29 | 31 | 161 | loose |
| Young Dolph | 911 | 35 | 34 | 217 | loose |
| Young Dolph | <img src="https://images.genius.com/015f65965fd4b016e1b116a4c539aeee.300x300x1.jpg" alt="By Mistake" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>By MistakeYoung Dolph78K | 35 | 51 | 226 | loose |
| Young Dolph | <img src="https://images.genius.com/176144ac2270009b2293aab282bad5e8.300x300x1.png" alt="Both Eyes Closed" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Both Eyes ClosedGucci Mane145.8K | 56 | 83 | 343 | loose |
| Young Dolph | <img src="https://images.genius.com/1bbb139b4f31bdfbae688fe3ff486e48.300x300x1.jpg" alt="16 Zips" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>16 ZipsYoung Dolph68.1K | 20 | 22 | 53 | loose |
| Young Dolph | <img src="https://images.genius.com/1bbb139b4f31bdfbae688fe3ff486e48.300x300x1.jpg" alt="Trap Nigga" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Trap NiggaYoung Dolph100.8K | 41 | 41 | 194 | loose |
| Young Dolph | <img src="https://images.genius.com/271db73c3867ea37008e1a0a309aa195.300x300x1.png" alt="Never Had It" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Never Had ItYoung Thug162.3K | 59 | 82 | 303 | loose |
| Young Dolph | <img src="https://images.genius.com/32f0d4f72fc3201e2ad2ef3f524bb303.300x300x1.png" alt="Major" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>MajorYoung Dolph212.5K | 38 | 61 | 214 | loose |
| Young Dolph | <img src="https://images.genius.com/483984d6aeea6e6e37cccb7efa35fcaf.300x300x1.jpg" alt="Get Paid" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Get PaidYoung Dolph126.2K | 32 | 25 | 196 | loose |
| Young Dolph | <img src="https://images.genius.com/4da68d9619cde669496e970d7f868c65.300x300x1.jpg" alt="Foreva" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>ForevaYoung Dolph231.8K | 68 | 48 | 266 | loose |
| Young Dolph | <img src="https://images.genius.com/6a90010253f6b608fb7a5944b4d3a91f.300x300x1.png" alt="100 Shots" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>100 ShotsYoung Dolph348.9K | 66 | 90 | 278 | loose |
| Young Dolph | <img src="https://images.genius.com/7776bea295400d0cd8e661eb3c37f524.300x300x1.png" alt="Get This Money" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Get This MoneyYoung Dolph177.4K | 39 | 25 | 118 | loose |
| Young Dolph | <img src="https://images.genius.com/924afcc8a7b9ff1ff8d10157190ad4ca.300x300x1.jpg" alt="Preach" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>PreachYoung Dolph985.5K | 44 | 42 | 235 | loose |
| Young Dolph | <img src="https://images.genius.com/a90c68f30fd2a9cb79d7e0289086a0fa.300x300x1.png" alt="Stunting Ain’t Nuthin" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Stunting Ain’t NuthinGucci Mane101.3K | 101 | 95 | 322 | loose |
| Young Dolph | <img src="https://images.genius.com/b638ee1862301b1a2d3999bfd5e22392.300x300x1.png" alt="Penguins" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>PenguinsYoung Dolph & Key Glock70.8K | 64 | 112 | 246 | loose |
| Young Dolph | <img src="https://images.genius.com/b72a73c87d4de4fb180ef97fafbd7a6c.300x300x1.png" alt="Play Wit Yo Bitch" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Play Wit Yo BitchYoung Dolph374.3K | 82 | 36 | 409 | loose |
| Young Dolph | <img src="https://images.genius.com/bb8e59771060c47c94eec1c47c002568.300x300x1.png" alt="Facts" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>FactsYoung Dolph75.5K | 33 | 30 | 244 | loose |
| Young Dolph | <img src="https://images.genius.com/cb9ff460640ac73b803521303f7d50d3.300x300x1.jpg" alt="On the River" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>On the RiverYoung Dolph95.9K | 42 | 60 | 171 | loose |
| Young Dolph | <img src="https://images.genius.com/db50282503550d96f016eafc742dce9a.300x300x1.png" alt="Cut It" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Cut ItO.T. Genasis546.7K | 44 | 64 | 186 | loose |
| Young Dolph | <img src="https://images.genius.com/efb1e26b3e78e2d2d111eef7996bc2fb.300x300x1.png" alt="Downfall" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>DownfallLil Durk140.9K | 64 | 39 | 342 | loose |
| Young Dolph | <img src="https://images.rapgenius.com/85e8257a7dad604c24ccd679e3847078.300x300x1.jpg" alt="Pulled Up" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>Pulled UpYoung Dolph156.3K | 42 | 58 | 238 | loose |
| Young Dolph | <img src="https://images.rapgenius.com/b2e890638a4bb38c69288da009d108f5.300x300x1.jpg" alt="California (Remix)" class="SizedImage__NoScript-sc-d4d34081-2 kJPgLt"/>California (Remix)Colonel Loud126.8K | 71 | 36 | 288 | loose |
| Young Dolph | A Goat & A Dolphin | 44 | 81 | 272 | loose |
| Young Dolph | A to Z | 53 | 68 | 232 | loose |
| Young Dolph | A-Plus | 39 | 10 | 137 | loose |
| Young Dolph | AF | 48 | 64 | 282 | loose |
| Young Dolph | Actin Up | 36 | 14 | 173 | loose |
| Young Dolph | Addicted | 37 | 36 | 220 | loose |
| Young Dolph | Aight | 48 | 31 | 90 | loose |
| Young Dolph | Ain’t Like That | 31 | 26 | 123 | loose |
| Young Dolph | All About | 51 | 41 | 208 | loose |
| Young Dolph | All I Wanted | 42 | 46 | 218 | loose |
| Young Dolph | All Mine | 33 | 11 | 196 | loose |
| Young Dolph | All She Wanna Do | 36 | 22 | 225 | loose |
| Young Dolph | All Work | 30 | 29 | 202 | loose |
| Young Dolph | All of Mine | 40 | 35 | 122 | loose |
| Young Dolph | All of Them | 30 | 41 | 167 | loose |
| Young Dolph | Always | 31 | 43 | 197 | loose |
| Young Dolph | Any Many Miny Moe | 39 | 42 | 158 | loose |
| Young Dolph | Ashtray | 26 | 21 | 266 | loose |
| Young Dolph | Ask Your Bitch | 36 | 27 | 268 | loose |
| Young Dolph | Aspen | 33 | 70 | 215 | loose |
| Young Dolph | At Da Jugg House | 31 | 16 | 123 | loose |
| Young Dolph | At the House | 48 | 37 | 286 | loose |
| Young Dolph | Attic | 45 | 57 | 262 | loose |
| Young Dolph | Austin Powers | 40 | 40 | 212 | loose |
| Young Dolph | BO$$ | 66 | 113 | 307 | loose |
| Young Dolph | Baby Joker | 50 | 96 | 203 | loose |
| Young Dolph | Back Against the Wall | 35 | 28 | 148 | loose |
| Young Dolph | Back Door | 31 | 18 | 255 | loose |
| Young Dolph | Back Stroke | 54 | 100 | 327 | loose |
| Young Dolph | Back to Back | 34 | 57 | 156 | loose |
| Young Dolph | Backyard | 54 | 77 | 242 | loose |
| Young Dolph | Bad Ass Jit (Remix) | 46 | 69 | 256 | loose |
| Young Dolph | Bad Girl | 38 | 21 | 188 | loose |
| Young Dolph | Badboy wit Dirtymoney | 27 | 24 | 144 | loose |
| Young Dolph | Bagg | 81 | 97 | 209 | loose |
| Young Dolph | Ball | 31 | 33 | 180 | loose |
| Young Dolph | Baller Alert | 49 | 52 | 310 | loose |
| Young Dolph | Bandz In The Bank (Remix) | 63 | 52 | 240 | loose |
| Young Dolph | Bang Ya | 50 | 27 | 177 | loose |
| Young Dolph | Bars | 48 | 57 | 228 | loose |
| Young Dolph | Beat It | 42 | 62 | 194 | loose |
| Young Dolph | Been Thru It All | 30 | 16 | 153 | loose |
| Young Dolph | Beep Beep | 39 | 43 | 208 | loose |
| Young Dolph | Believe Me | 33 | 29 | 154 | loose |
| Young Dolph | Benz | 26 | 51 | 112 | loose |
| Young Dolph | Better Not | 38 | 27 | 136 | loose |
| Young Dolph | Big Bag | 39 | 50 | 237 | loose |
| Young Dolph | Big Dawg Status | 56 | 40 | 321 | loose |
| Young Dolph | Big Deal | 37 | 25 | 200 | loose |
| Young Dolph | Big Faces | 32 | 39 | 130 | loose |
| Young Dolph | Blac Loccs | 27 | 53 | 154 | loose |
| Young Dolph | Black Queen | 48 | 58 | 247 | loose |
| Young Dolph | Blam! Gang Shit | 36 | 39 | 154 | loose |
| Young Dolph | Blama on Ya | 45 | 23 | 294 | loose |
| Young Dolph | Blind Fold | 42 | 74 | 229 | loose |
| Young Dolph | Bling Blaww Burr | 41 | 66 | 145 | loose |
| Young Dolph | Blonde & A Onion | 34 | 53 | 181 | loose |
| Young Dolph | Blood All On it | 61 | 46 | 248 | loose |
| Young Dolph | Blow Sniffer | 31 | 40 | 174 | loose |
| Young Dolph | Blu Boyz | 74 | 80 | 345 | loose |
| Young Dolph | Blue Diamonds | 41 | 50 | 269 | loose |
| Young Dolph | Booked Up | 38 | 33 | 153 | loose |
| Young Dolph | Boss Nigga | 42 | 42 | 227 | loose |
| Young Dolph | Bosses & Shooters | 65 | 56 | 245 | loose |
| Young Dolph | Both Ways | 30 | 28 | 185 | loose |
| Young Dolph | Bounce | 42 | 62 | 189 | loose |
| Young Dolph | Boyz in da Hood | 39 | 31 | 176 | loose |
| Young Dolph | Break the Bank | 40 | 61 | 180 | loose |
| Young Dolph | Breezy | 38 | 43 | 217 | loose |
| Young Dolph | Broke Boy | 29 | 12 | 76 | loose |
| Young Dolph | Buddy Love | 25 | 57 | 222 | loose |
| Young Dolph | Bundle | 54 | 46 | 352 | loose |
| Young Dolph | But I’m Bulletproof | 36 | 39 | 215 | loose |
| Young Dolph | Buy My Way In Heaven | 36 | 53 | 212 | loose |
| Young Dolph | By Mistake (Remix) | 35 | 31 | 185 | loose |
| Young Dolph | Ca$hed Out | 44 | 32 | 259 | loose |
| Young Dolph | California | 20 | 7 | 55 | loose |
| Young Dolph | Call Me Back | 35 | 28 | 151 | loose |
| Young Dolph | Can You Hear Me Now | 39 | 30 | 157 | loose |
| Young Dolph | Can’t Handle Me | 44 | 24 | 218 | loose |
| Young Dolph | Can’t Stop Now | 35 | 47 | 156 | loose |
| Young Dolph | Case Closed | 52 | 69 | 236 | loose |
| Young Dolph | Cashville To Memphis To Houston | 32 | 53 | 342 | loose |
| Young Dolph | Castalia | 42 | 38 | 195 | loose |
| Young Dolph | Castalia Hot Boy | 27 | 33 | 128 | loose |
| Young Dolph | Celebration | 17 | 24 | 92 | loose |
| Young Dolph | Chances | 33 | 21 | 148 | loose |
| Young Dolph | Cheat Code | 86 | 84 | 551 | loose |
| Young Dolph | Check | 48 | 54 | 218 | loose |
| Young Dolph | CheezNDope | 49 | 34 | 269 | loose |
| Young Dolph | Chill | 48 | 60 | 145 | loose |
| Young Dolph | Choppa on the Couch | 36 | 23 | 130 | loose |
| Young Dolph | Choppers | 51 | 59 | 328 | loose |
| Young Dolph | Clear | 43 | 28 | 205 | loose |
| Young Dolph | Clientele | 25 | 23 | 123 | loose |
| Young Dolph | Cold World | 38 | 15 | 169 | loose |
| Young Dolph | Contaminated | 36 | 29 | 151 | loose |
| Young Dolph | Coolin’ | 42 | 62 | 276 | loose |
| Young Dolph | Coordinate | 33 | 46 | 188 | loose |
| Young Dolph | Count This Money | 61 | 50 | 247 | loose |
| Young Dolph | Count Up | 27 | 31 | 229 | loose |
| Young Dolph | Crashin’ Out | 42 | 34 | 259 | loose |
| Young Dolph | CrayCray | 31 | 56 | 203 | loose |
| Young Dolph | Cross Country | 41 | 27 | 202 | loose |
| Young Dolph | Cutthroat Committee | 32 | 35 | 270 | loose |
| Young Dolph | D.A.R.E. | 44 | 52 | 205 | loose |
| Young Dolph | Da Block Talkin’ | 29 | 27 | 172 | loose |
| Young Dolph | Damn Right | 32 | 22 | 198 | loose |
| Young Dolph | Damn Thang | 34 | 26 | 96 | loose |
| Young Dolph | Dance | 63 | 78 | 423 | loose |
| Young Dolph | Dat Recipe | 49 | 46 | 337 | loose |
| Young Dolph | Dead Ass Serious | 30 | 47 | 147 | loose |
| Young Dolph | Dead Body | 66 | 111 | 308 | loose |
| Young Dolph | Death Row | 34 | 46 | 224 | loose |
| Young Dolph | Detox | 59 | 64 | 248 | loose |
| Young Dolph | Diamond Tester | 75 | 74 | 275 | loose |
| Young Dolph | Die Real | 46 | 17 | 311 | loose |
| Young Dolph | Die Young | 68 | 57 | 364 | loose |
| Young Dolph | Dirk Nowitzki | 29 | 28 | 72 | loose |
| Young Dolph | Disrespectful (Remix) | 37 | 13 | 128 | loose |
| Young Dolph | Distribution Center | 32 | 23 | 166 | loose |
| Young Dolph | Dollar Signs | 37 | 44 | 110 | loose |
| Young Dolph | Dolph Speaks | 25 | 5 | 83 | loose |
| Young Dolph | Dolph!!!!! | 44 | 51 | 255 | loose |
| Young Dolph | Don’t Make Sence | 28 | 35 | 173 | loose |
| Young Dolph | Don’t Spill It | 24 | 20 | 166 | loose |
| Young Dolph | Don’t Stop | 44 | 44 | 170 | loose |
| Young Dolph | Dope Boi Shit | 49 | 27 | 170 | loose |
| Young Dolph | Dope Spot | 38 | 27 | 314 | loose |
| Young Dolph | Dopeboys | 36 | 32 | 183 | loose |
| Young Dolph | Double Up | 50 | 119 | 177 | loose |
| Young Dolph | Down South Hustlaz | 53 | 53 | 287 | loose |
| Young Dolph | Dream | 45 | 33 | 189 | loose |
| Young Dolph | Drinking Lean Smoking Loud | 38 | 41 | 227 | loose |
| Young Dolph | Drip Like Dis | 77 | 99 | 472 | loose |
| Young Dolph | Drippy | 49 | 73 | 126 | loose |
| Young Dolph | Drop It Off | 37 | 28 | 165 | loose |
| Young Dolph | Drop It on the Scale | 33 | 12 | 160 | loose |
| Young Dolph | Dum & Dummer | 26 | 37 | 167 | loose |
| Young Dolph | Dumb High | 24 | 12 | 383 | loose |
| Young Dolph | Dummest & the Dummest | 37 | 52 | 239 | loose |
| Young Dolph | Easter Egg Hunt (OG) | 20 | 31 | 98 | loose |
| Young Dolph | Eddie Cane | 26 | 27 | 125 | loose |
| Young Dolph | Elvis Presley BLVD (Remix) | 104 | 80 | 649 | loose |
| Young Dolph | Everybody Know | 71 | 113 | 252 | loose |
| Young Dolph | Everyday 420 | 33 | 24 | 235 | loose |
| Young Dolph | Everything 4 Sale | 47 | 100 | 199 | loose |
| Young Dolph | Everything Back | 42 | 21 | 273 | loose |
| Young Dolph | Everything Happens for a Reason | 33 | 32 | 158 | loose |
| Young Dolph | Face It | 37 | 56 | 335 | loose |
| Young Dolph | Fast | 51 | 94 | 215 | loose |
| Young Dolph | Feet Up | 34 | 48 | 187 | loose |
| Young Dolph | Ferris Wheel* | 10 | 6 | 39 | loose |
| Young Dolph | Flavor | 41 | 46 | 207 | loose |
| Young Dolph | Flawless | 40 | 34 | 202 | loose |
| Young Dolph | Flippa | 44 | 103 | 272 | loose |
| Young Dolph | Floatin’ | 44 | 30 | 298 | loose |
| Young Dolph | Flodgin | 35 | 35 | 188 | loose |
| Young Dolph | Forever | 30 | 24 | 216 | loose |
| Young Dolph | Freestyle on Sway in the Morning | 14 | 5 | 56 | loose |
| Young Dolph | Fresh As A Bitch | 54 | 65 | 234 | loose |
| Young Dolph | Front & Back Pockets | 27 | 19 | 155 | loose |
| Young Dolph | Fuck A Nigga | 28 | 27 | 133 | loose |
| Young Dolph | Fuck Dat | 54 | 34 | 212 | loose |
| Young Dolph | Fuck It | 36 | 42 | 274 | loose |
| Young Dolph | Fucked It Up | 31 | 43 | 168 | loose |
| Young Dolph | Fugitive | 73 | 66 | 267 | loose |
| Young Dolph | Fuk U Pay Me | 41 | 37 | 184 | loose |
| Young Dolph | Fun | 43 | 58 | 305 | loose |
| Young Dolph | Gangsta | 27 | 17 | 162 | loose |
| Young Dolph | Gangsta Bitch | 32 | 25 | 109 | loose |
| Young Dolph | Gangsta Muzik | 61 | 62 | 288 | loose |
| Young Dolph | Gary Payton | 37 | 28 | 201 | loose |
| Young Dolph | Gelato | 38 | 55 | 197 | loose |
| Young Dolph | George | 33 | 39 | 151 | loose |
| Young Dolph | Get Away | 42 | 61 | 84 | loose |
| Young Dolph | Get Em Off | 44 | 65 | 219 | loose |
| Young Dolph | Get High/Get Money | 45 | 42 | 178 | loose |
| Young Dolph | Get It Back | 27 | 19 | 141 | loose |
| Young Dolph | Get It In | 40 | 42 | 130 | loose |
| Young Dolph | Get Money Alwayz | 62 | 75 | 135 | loose |
| Young Dolph | Get Paid (Remix) | 59 | 72 | 291 | loose |
| Young Dolph | Get That Money | 56 | 38 | 140 | loose |
| Young Dolph | Get to the Racks | 56 | 65 | 147 | loose |
| Young Dolph | Gettin’ Money | 35 | 34 | 159 | loose |
| Young Dolph | Gimme My Bag | 47 | 76 | 128 | loose |
| Young Dolph | Go Get It | 54 | 48 | 166 | loose |
| Young Dolph | Go Get Sum Mo | 91 | 69 | 352 | loose |
| Young Dolph | Go Get the Money | 36 | 30 | 150 | loose |
| Young Dolph | Going Crazy with the Work | 34 | 19 | 161 | loose |
| Young Dolph | Goin’ In | 34 | 44 | 174 | loose |
| Young Dolph | Gone | 51 | 43 | 321 | loose |
| Young Dolph | Good Drugs | 35 | 52 | 165 | loose |
| Young Dolph | Goodbye | 53 | 33 | 239 | loose |
| Young Dolph | Got Blow’d | 29 | 34 | 176 | loose |
| Young Dolph | Green Light | 29 | 33 | 160 | loose |
| Young Dolph | Grew Up | 40 | 23 | 236 | loose |
| Young Dolph | Guap | 46 | 62 | 119 | loose |
| Young Dolph | Guapo | 47 | 47 | 191 | loose |
| Young Dolph | Guess What | 41 | 53 | 212 | loose |
| Young Dolph | Gwopanese | 22 | 11 | 120 | loose |
| Young Dolph | Hall of Fame | 45 | 34 | 352 | loose |
| Young Dolph | Hashtag | 36 | 62 | 211 | loose |
| Young Dolph | Having Thangs | 29 | 28 | 135 | loose |
| Young Dolph | Heavy n’ da Streets | 58 | 33 | 268 | loose |
| Young Dolph | Hella Stoned | 28 | 15 | 103 | loose |
| Young Dolph | Here We Go | 63 | 82 | 339 | loose |
| Young Dolph | Heron | 63 | 64 | 320 | loose |
| Young Dolph | Highclass Streetmusic | 28 | 29 | 110 | loose |
| Young Dolph | Hold Up Hold Up Hold Up | 39 | 39 | 312 | loose |
| Young Dolph | Holla At Me | 30 | 25 | 211 | loose |
| Young Dolph | Homeboys | 42 | 20 | 232 | loose |
| Young Dolph | Homeboyz | 80 | 29 | 200 | loose |
| Young Dolph | Hood Love Forever | 32 | 19 | 146 | loose |
| Young Dolph | Hood On Smash | 51 | 29 | 159 | loose |
| Young Dolph | Hot Head | 42 | 71 | 242 | loose |
| Young Dolph | Hotter Than A Crack Pot | 44 | 39 | 326 | loose |
| Young Dolph | How Bout That Money | 65 | 39 | 258 | loose |
| Young Dolph | How Could | 44 | 42 | 236 | loose |
| Young Dolph | How U Feel | 37 | 32 | 230 | loose |
| Young Dolph | How U Luv Dat | 27 | 25 | 157 | loose |
| Young Dolph | Hustler | 31 | 56 | 195 | loose |
| Young Dolph | Hustler Mentality | 8 | 2 | 28 | loose |
| Young Dolph | Hustlers Paradise | 29 | 37 | 133 | loose |
| Young Dolph | I Ain’t Even Gonna Lie | 34 | 30 | 174 | loose |
| Young Dolph | I Ain’t Lyin | 27 | 29 | 166 | loose |
| Young Dolph | I Apologize | 34 | 32 | 155 | loose |
| Young Dolph | I Do This | 31 | 50 | 121 | loose |
| Young Dolph | I Don’t See Them | 36 | 24 | 190 | loose |
| Young Dolph | I Got Strong | 32 | 21 | 94 | loose |
| Young Dolph | I Got This | 33 | 24 | 168 | loose |
| Young Dolph | I Just Landed | 34 | 38 | 225 | loose |
| Young Dolph | I Luv All My Hoes | 27 | 20 | 154 | loose |
| Young Dolph | I Need A Plugg | 63 | 45 | 277 | loose |
| Young Dolph | I Need My Medicine | 45 | 47 | 229 | loose |
| Young Dolph | I Pray for My Enemies | 38 | 36 | 145 | loose |
| Young Dolph | I Quit | 49 | 28 | 314 | loose |
| Young Dolph | I See $’s | 27 | 43 | 207 | loose |
| Young Dolph | I Survived | 38 | 20 | 124 | loose |
| Young Dolph | I Swear | 43 | 34 | 173 | loose |
| Young Dolph | I Think I Can Fly | 54 | 106 | 161 | loose |
| Young Dolph | I Think I’m Sprung | 45 | 22 | 242 | loose |
| Young Dolph | I Will Never | 35 | 19 | 193 | loose |
| Young Dolph | I.D.G.A.F. | 78 | 59 | 452 | loose |
| Young Dolph | Ice* | 9 | 4 | 60 | loose |
| Young Dolph | If | 41 | 69 | 192 | loose |
| Young Dolph | If I Ever | 39 | 56 | 196 | loose |
| Young Dolph | If It Ain’t 1 Thang It’s Anotha | 25 | 30 | 160 | loose |
| Young Dolph | Ignit | 44 | 40 | 272 | loose |
| Young Dolph | Ill | 54 | 51 | 383 | loose |
| Young Dolph | Illuminati | 16 | 21 | 69 | loose |
| Young Dolph | Im Blowin | 33 | 26 | 76 | loose |
| Young Dolph | In Charlotte | 52 | 44 | 311 | loose |
| Young Dolph | In My CIty | 51 | 43 | 298 | loose |
| Young Dolph | In My Feelings | 50 | 49 | 207 | loose |
| Young Dolph | In My System | 49 | 20 | 244 | loose |
| Young Dolph | In My Trunk | 64 | 61 | 243 | loose |
| Young Dolph | Infatuated With Drugs | 61 | 118 | 377 | loose |
| Young Dolph | Insane | 39 | 78 | 222 | loose |
| Young Dolph | Instagram Famous | 42 | 32 | 197 | loose |
| Young Dolph | Intro | 9 | 4 | 16 | loose |
| Young Dolph | Investigation | 56 | 48 | 239 | loose |
| Young Dolph | It Feel Different | 25 | 15 | 135 | loose |
| Young Dolph | It Only Happens In Miami | 67 | 42 | 208 | loose |
| Young Dolph | It’s Goin Down | 32 | 53 | 120 | loose |
| Young Dolph | It’s My Time | 44 | 45 | 154 | loose |
| Young Dolph | I’m Blessed | 45 | 54 | 264 | loose |
| Young Dolph | I’m Everything You Wanna Be | 32 | 29 | 144 | loose |
| Young Dolph | I’m Gone | 48 | 57 | 197 | loose |
| Young Dolph | I’m Juggin | 30 | 30 | 188 | loose |
| Young Dolph | I’m Offended | 28 | 17 | 183 | loose |
| Young Dolph | I’m Siccc | 30 | 48 | 242 | AAAA |
| Young Dolph | I’m So Real | 34 | 31 | 133 | loose |
| Young Dolph | I’m wit It | 49 | 26 | 228 | loose |
| Young Dolph | Jug In Da M-Town | 29 | 29 | 135 | loose |
| Young Dolph | Juiced Up | 51 | 44 | 182 | loose |
| Young Dolph | Juicy | 29 | 29 | 83 | loose |
| Young Dolph | Kansas City / Drug Runner | 57 | 42 | 432 | loose |
| Young Dolph | Keep It Comin’ | 28 | 31 | 203 | loose |
| Young Dolph | Keepin it Real | 38 | 43 | 202 | loose |
| Young Dolph | Kill It | 38 | 23 | 225 | loose |
| Young Dolph | King of the Trap | 8 | 4 | 31 | loose |
| Young Dolph | KingPin | 58 | 41 | 248 | loose |
| Young Dolph | Know U Know | 41 | 34 | 254 | loose |
| Young Dolph | Knuckles | 53 | 71 | 317 | loose |
| Young Dolph | Kush on the Yacht | 75 | 94 | 239 | loose |
| Young Dolph | L.E.a.n. | 62 | 26 | 265 | loose |
| Young Dolph | Large Amounts | 48 | 79 | 140 | loose |
| Young Dolph | LeBron | 34 | 21 | 186 | loose |
| Young Dolph | Left Da Bank | 30 | 23 | 132 | loose |
| Young Dolph | Let Me See It | 28 | 31 | 163 | loose |
| Young Dolph | Let The Plug In | 31 | 43 | 165 | loose |
| Young Dolph | Lets Get It On | 44 | 25 | 214 | loose |
| Young Dolph | Letter to Flippa | 60 | 53 | 336 | loose |
| Young Dolph | Let’s Go (Remix) | 37 | 76 | 118 | loose |
| Young Dolph | Like Me | 30 | 61 | 280 | loose |
| Young Dolph | Lipstick | 34 | 54 | 207 | loose |
| Young Dolph | Listen to the Street | 41 | 26 | 208 | loose |
| Young Dolph | Lit | 50 | 97 | 228 | loose |
| Young Dolph | Lit AF | 36 | 20 | 122 | loose |
| Young Dolph | Living In A Kingdom | 36 | 27 | 143 | loose |
| Young Dolph | Livin’ My Life | 30 | 51 | 135 | loose |
| Young Dolph | Loner | 49 | 42 | 154 | loose |
| Young Dolph | Long Money | 36 | 34 | 239 | loose |
| Young Dolph | Looong Waay | 44 | 54 | 290 | loose |
| Young Dolph | Love For Me | 30 | 39 | 133 | loose |
| Young Dolph | Love For The Streets | 34 | 60 | 226 | loose |
| Young Dolph | Love the Hate | 47 | 43 | 115 | loose |
| Young Dolph | Loves Me Not | 62 | 42 | 375 | loose |
| Young Dolph | Lyte 300 (Fat Fat OG) | 18 | 33 | 73 | AAAA |
| Young Dolph | Maintain | 28 | 13 | 129 | loose |
| Young Dolph | Make It Happen | 32 | 40 | 188 | loose |
| Young Dolph | Make It Work | 41 | 49 | 235 | loose |
| Young Dolph | Make The World Go Round | 26 | 18 | 155 | loose |
| Young Dolph | Man Of The Year | 26 | 36 | 127 | loose |
| Young Dolph | Mane Wattt | 38 | 37 | 211 | loose |
| Young Dolph | Meanwhile | 64 | 65 | 220 | loose |
| Young Dolph | Meech | 46 | 32 | 110 | loose |
| Young Dolph | Meet The Connect | 5 | 1 | 6 | loose |
| Young Dolph | Menace To Society | 33 | 45 | 234 | loose |
| Young Dolph | Millionaire Shit | 42 | 32 | 306 | loose |
| Young Dolph | Mine Forever | 19 | 9 | 135 | loose |
| Young Dolph | Mirror Mirror Mirror | 45 | 23 | 279 | loose |
| Young Dolph | Missed Count | 63 | 40 | 110 | loose |
| Young Dolph | Mo Money | 42 | 34 | 216 | loose |
| Young Dolph | Mob Ties | 30 | 29 | 187 | loose |
| Young Dolph | Money | 60 | 77 | 252 | loose |
| Young Dolph | Money Callin’ | 36 | 30 | 176 | loose |
| Young Dolph | Money Hungry | 33 | 23 | 211 | loose |
| Young Dolph | Money In The Way | 35 | 18 | 196 | loose |
| Young Dolph | Money Money Money | 39 | 37 | 165 | loose |
| Young Dolph | Money Power Respect | 30 | 21 | 169 | loose |
| Young Dolph | Money Right | 43 | 32 | 89 | loose |
| Young Dolph | Money Talk | 37 | 37 | 133 | loose |
| Young Dolph | Much Deeper | 40 | 51 | 268 | loose |
| Young Dolph | Muddy | 42 | 23 | 206 | loose |
| Young Dolph | Muhammad | 55 | 92 | 178 | loose |
| Young Dolph | My Bitch Badder | 46 | 42 | 210 | loose |
| Young Dolph | My Blower (Remix) | 34 | 40 | 80 | loose |
| Young Dolph | My Real Life | 43 | 58 | 256 | loose |
| Young Dolph | My Trap House | 26 | 18 | 130 | loose |
| Young Dolph | Neat (Remix) | 126 | 175 | 614 | loose |
| Young Dolph | Nervous | 40 | 65 | 145 | loose |
| Young Dolph | Never | 47 | 64 | 264 | loose |
| Young Dolph | Never Ever | 31 | 20 | 216 | loose |
| Young Dolph | Never Going Broke | 51 | 39 | 303 | loose |
| Young Dolph | New Blinds | 54 | 37 | 182 | loose |
| Young Dolph | New Gun | 31 | 38 | 226 | loose |
| Young Dolph | Newschool, Ol’school | 41 | 57 | 223 | loose |
| Young Dolph | No Good | 44 | 39 | 170 | loose |
| Young Dolph | No Matter What | 43 | 19 | 307 | loose |
| Young Dolph | No More Stressin | 37 | 49 | 105 | loose |
| Young Dolph | No Panties | 33 | 18 | 285 | loose |
| Young Dolph | No Regrets | 43 | 86 | 294 | loose |
| Young Dolph | No Sense | 51 | 72 | 213 | loose |
| Young Dolph | No Sleep | 28 | 13 | 155 | loose |
| Young Dolph | Not No More | 32 | 28 | 139 | loose |
| Young Dolph | Nothin | 31 | 32 | 135 | loose |
| Young Dolph | Nothing | 42 | 58 | 179 | loose |
| Young Dolph | Nothing To Me | 69 | 76 | 312 | loose |
| Young Dolph | Now They Mad | 45 | 83 | 204 | loose |
| Young Dolph | Nun 2 Fuck Wit | 43 | 38 | 294 | loose |
| Young Dolph | Obey Your Thirst | 44 | 31 | 330 | loose |
| Young Dolph | Old Ways | 34 | 24 | 243 | loose |
| Young Dolph | On God | 44 | 39 | 172 | loose |
| Young Dolph | On Me | 33 | 35 | 110 | loose |
| Young Dolph | On My Line | 31 | 28 | 144 | loose |
| Young Dolph | On My Own | 42 | 31 | 235 | loose |
| Young Dolph | On My Way | 32 | 28 | 152 | loose |
| Young Dolph | On The Run | 30 | 29 | 193 | loose |
| Young Dolph | Out da Park | 46 | 47 | 145 | loose |
| Young Dolph | Outro (AT2K) | 23 | 1 | 48 | loose |
| Young Dolph | Outta Space Flavor, Overseas Swag | 39 | 24 | 188 | loose |
| Young Dolph | O’s | 21 | 17 | 113 | loose |
| Young Dolph | Pacific Ocean | 43 | 67 | 178 | loose |
| Young Dolph | Paper Route | 37 | 28 | 253 | loose |
| Young Dolph | Paper Route Campaign | 69 | 54 | 338 | loose |
| Young Dolph | Paranoid | 39 | 54 | 176 | loose |
| Young Dolph | Photoshoots & Interviews | 47 | 64 | 308 | loose |
| Young Dolph | Piss Codeine (Remix) | 69 | 56 | 249 | loose |
| Young Dolph | Playa | 47 | 77 | 257 | loose |
| Young Dolph | Playas Night Out | 25 | 22 | 96 | loose |
| Young Dolph | Playin Wit a Chek | 35 | 58 | 148 | loose |
| Young Dolph | Plenty Cake | 35 | 24 | 92 | loose |
| Young Dolph | Pocket Full Of Money | 56 | 51 | 287 | loose |
| Young Dolph | Point Across | 28 | 23 | 174 | loose |
| Young Dolph | Pot Of Gold | 33 | 67 | 210 | loose |
| Young Dolph | Potential | 60 | 77 | 184 | loose |
| Young Dolph | Preach (Remix) | 40 | 16 | 215 | loose |
| Young Dolph | Pressure | 36 | 17 | 230 | loose |
| Young Dolph | Pretty Girls | 29 | 22 | 177 | loose |
| Young Dolph | Private Party | 73 | 39 | 198 | loose |
| Young Dolph | Pulled Up (OG) | 4 | 0 | 24 | loose |
| Young Dolph | Put Ur Hands Up | 61 | 48 | 241 | loose |
| Young Dolph | RAIN RAIN | 46 | 89 | 292 | loose |
| Young Dolph | RNB | 35 | 55 | 250 | loose |
| Young Dolph | Racks | 44 | 33 | 184 | loose |
| Young Dolph | Racks Up To My Ear | 45 | 33 | 236 | loose |
| Young Dolph | Rainbow Colors | 24 | 11 | 145 | loose |
| Young Dolph | Re Up | 44 | 63 | 218 | loose |
| Young Dolph | Ready (Remix) | 124 | 82 | 433 | loose |
| Young Dolph | Real | 28 | 18 | 205 | loose |
| Young Dolph | Real Language | 4 | 1 | 21 | loose |
| Young Dolph | Real Life | 33 | 44 | 293 | loose |
| Young Dolph | Real Me | 43 | 53 | 238 | loose |
| Young Dolph | Real Nigga (Remix) | 57 | 28 | 380 | loose |
| Young Dolph | Real Talk | 7 | 1 | 13 | loose |
| Young Dolph | Reality Talk | 21 | 6 | 58 | loose |
| Young Dolph | Really | 38 | 35 | 270 | loose |
| Young Dolph | Really Ready | 56 | 45 | 316 | loose |
| Young Dolph | Reflection | 36 | 26 | 127 | loose |
| Young Dolph | Reload | 31 | 33 | 207 | loose |
| Young Dolph | Replay | 26 | 28 | 102 | loose |
| Young Dolph | Rich Crack Baby | 44 | 40 | 156 | loose |
| Young Dolph | Rich Nigga | 38 | 42 | 210 | loose |
| Young Dolph | Rich Nigga High | 40 | 34 | 89 | loose |
| Young Dolph | Rich Off Grass (Remix) | 28 | 52 | 167 | loose |
| Young Dolph | Rich Slave | 26 | 59 | 197 | loose |
| Young Dolph | Ricky | 46 | 79 | 398 | loose |
| Young Dolph | Ride or Die | 20 | 17 | 112 | loose |
| Young Dolph | Right On Time | 25 | 25 | 243 | loose |
| Young Dolph | Rock n’ Rollin’ | 32 | 44 | 181 | loose |
| Young Dolph | Rokkin’ | 37 | 23 | 158 | loose |
| Young Dolph | Role Model | 49 | 42 | 302 | loose |
| Young Dolph | Roll Up, Poe Up | 66 | 50 | 156 | loose |
| Young Dolph | Roster | 29 | 29 | 162 | loose |
| Young Dolph | Royalty | 34 | 37 | 176 | loose |
| Young Dolph | Rubber Band | 31 | 24 | 250 | loose |
| Young Dolph | Rubberband Money | 42 | 45 | 179 | loose |
| Young Dolph | Run Dem Bandz (Remix) | 42 | 41 | 197 | loose |
| Young Dolph | Run It Up | 26 | 26 | 104 | loose |
| Young Dolph | Running Man | 41 | 32 | 156 | loose |
| Young Dolph | Runs Thru My Blood | 40 | 33 | 245 | loose |
| Young Dolph | SHOPPING SPREE | 47 | 55 | 239 | loose |
| Young Dolph | SMH | 30 | 34 | 90 | loose |
| Young Dolph | Sack | 10 | 10 | 34 | loose |
| Young Dolph | Sacrifices | 35 | 22 | 193 | loose |
| Young Dolph | Same Crew (Remix) | 61 | 57 | 363 | loose |
| Young Dolph | Scared of Me | 27 | 10 | 152 | loose |
| Young Dolph | Scotch | 55 | 91 | 107 | loose |
| Young Dolph | Send Me Pack | 34 | 33 | 182 | loose |
| Young Dolph | Send the Work | 32 | 24 | 134 | loose |
| Young Dolph | Shake Back | 29 | 21 | 162 | loose |
| Young Dolph | She Not Mines | 49 | 51 | 222 | loose |
| Young Dolph | She Will | 42 | 26 | 101 | loose |
| Young Dolph | She on My Dick (Remix) | 72 | 92 | 470 | loose |
| Young Dolph | Shittin’ On The Industry | 29 | 18 | 193 | loose |
| Young Dolph | Shouldn’t Be Underated | 61 | 79 | 212 | loose |
| Young Dolph | Shoutouts | 5 | 1 | 3 | loose |
| Young Dolph | Show My Ass | 43 | 49 | 365 | loose |
| Young Dolph | Show Out | 51 | 83 | 219 | loose |
| Young Dolph | Show Us Some | 23 | 41 | 74 | loose |
| Young Dolph | Showtime | 37 | 33 | 211 | loose |
| Young Dolph | Simple Pimpin | 42 | 24 | 80 | loose |
| Young Dolph | Sit Still | 46 | 34 | 242 | loose |
| Young Dolph | Skerr | 27 | 18 | 170 | loose |
| Young Dolph | Skit (SOTI) | 6 | 0 | 27 | loose |
| Young Dolph | Skit 1 | 4 | 0 | 10 | loose |
| Young Dolph | Sky High | 31 | 12 | 161 | loose |
| Young Dolph | Slave Owner | 36 | 43 | 170 | loose |
| Young Dolph | Sleep With the Roaches | 47 | 79 | 242 | loose |
| Young Dolph | Slow Down | 30 | 40 | 61 | loose |
| Young Dolph | Smack Down | 28 | 33 | 116 | loose |
| Young Dolph | Smoke My Weed | 36 | 62 | 172 | loose |
| Young Dolph | Smoke Session | 12 | 5 | 49 | loose |
| Young Dolph | Smoke Talk | 15 | 0 | 51 | loose |
| Young Dolph | Smokin Kush On A Yacht | 5 | 1 | 14 | loose |
| Young Dolph | Smokin’ Habit | 50 | 73 | 367 | loose |
| Young Dolph | Snakes | 37 | 33 | 271 | loose |
| Young Dolph | So Fuk’em | 40 | 45 | 247 | loose |
| Young Dolph | So Gone | 54 | 73 | 329 | loose |
| Young Dolph | Somethin’ Else | 39 | 40 | 273 | loose |
| Young Dolph | South Memphis | 29 | 19 | 229 | loose |
| Young Dolph | South Memphis Rugrats (Remix) | 50 | 63 | 344 | loose |
| Young Dolph | South Memphis to Zone 6 | 17 | 10 | 110 | loose |
| Young Dolph | Space Jam | 31 | 35 | 159 | loose |
| Young Dolph | Sparkle | 27 | 26 | 79 | loose |
| Young Dolph | Special | 36 | 36 | 150 | loose |
| Young Dolph | Star Power | 53 | 47 | 245 | loose |
| Young Dolph | Starter Kit | 33 | 31 | 240 | loose |
| Young Dolph | Stay Down | 32 | 35 | 172 | loose |
| Young Dolph | Steve Austin | 44 | 60 | 181 | loose |
| Young Dolph | Still Pumpin’ | 43 | 50 | 245 | loose |
| Young Dolph | Still Puttin’ It Down | 41 | 34 | 229 | loose |
| Young Dolph | Still Smell Like It | 38 | 23 | 233 | loose |
| Young Dolph | Stop Me | 47 | 78 | 306 | loose |
| Young Dolph | Story | 70 | 102 | 371 | loose |
| Young Dolph | Str8 Up (Interlude) | 10 | 5 | 15 | loose |
| Young Dolph | Street Nigga | 49 | 35 | 164 | loose |
| Young Dolph | Street Talk | 9 | 5 | 48 | loose |
| Young Dolph | Streets Sour | 48 | 47 | 325 | loose |
| Young Dolph | Stressin’ | 37 | 23 | 201 | loose |
| Young Dolph | Strippa | 33 | 52 | 299 | loose |
| Young Dolph | Suicide Doors | 22 | 32 | 84 | loose |
| Young Dolph | Summo’ | 30 | 54 | 231 | loose |
| Young Dolph | Sunshine | 35 | 40 | 212 | loose |
| Young Dolph | Survival of the Fittest | 35 | 21 | 130 | loose |
| Young Dolph | TOOT TOOT | 37 | 66 | 250 | loose |
| Young Dolph | Take It All | 5 | 0 | 11 | loose |
| Young Dolph | Taking Care of Business | 30 | 13 | 262 | loose |
| Young Dolph | Talk is Cheap | 45 | 54 | 242 | loose |
| Young Dolph | Talking to My Scale | 75 | 87 | 487 | loose |
| Young Dolph | Tatted | 30 | 23 | 122 | loose |
| Young Dolph | Tell Me Nothin | 32 | 51 | 166 | loose |
| Young Dolph | Texas Kool-Aid | 31 | 14 | 200 | loose |
| Young Dolph | Texas Margarita | 77 | 72 | 221 | loose |
| Young Dolph | Tha Plug | 33 | 38 | 117 | loose |
| Young Dolph | Thank Me | 37 | 29 | 242 | loose |
| Young Dolph | Thank tha Plug | 44 | 20 | 260 | loose |
| Young Dolph | Thats How | 58 | 75 | 236 | loose |
| Young Dolph | That’s How I Feel | 32 | 38 | 208 | loose |
| Young Dolph | The Call | 50 | 21 | 96 | loose |
| Young Dolph | The Field | 57 | 64 | 221 | loose |
| Young Dolph | The Game Is To Be Sold | 28 | 21 | 135 | loose |
| Young Dolph | The Land | 27 | 29 | 133 | loose |
| Young Dolph | The Life | 63 | 67 | 204 | loose |
| Young Dolph | The Plug Best Friend | 32 | 42 | 155 | loose |
| Young Dolph | The Realest | 23 | 10 | 137 | loose |
| Young Dolph | Them O’s | 51 | 52 | 230 | loose |
| Young Dolph | These Streets | 30 | 36 | 222 | loose |
| Young Dolph | They Watchin’ | 33 | 62 | 165 | loose |
| Young Dolph | Thinking Out Loud | 30 | 20 | 156 | loose |
| Young Dolph | Thinkin’ Like Pac, Feelin’ Like Biggie | 28 | 9 | 183 | loose |
| Young Dolph | Time | 49 | 44 | 281 | loose |
| Young Dolph | Time 2 Kill | 40 | 32 | 253 | loose |
| Young Dolph | To Be Honest | 31 | 29 | 185 | loose |
| Young Dolph | Toast | 40 | 41 | 139 | loose |
| Young Dolph | Tomorrow | 42 | 57 | 269 | loose |
| Young Dolph | Tony | 26 | 11 | 108 | loose |
| Young Dolph | Top Of Shit | 30 | 24 | 201 | loose |
| Young Dolph | Tracking Numbers | 64 | 74 | 270 | loose |
| Young Dolph | Trampoline Trap | 37 | 34 | 150 | loose |
| Young Dolph | Trap | 34 | 26 | 115 | loose |
| Young Dolph | Trap Baby | 34 | 45 | 160 | loose |
| Young Dolph | Trap House (Remix) | 58 | 44 | 186 | loose |
| Young Dolph | Trap House Stalkin | 46 | 39 | 237 | loose |
| Young Dolph | Trap On Fire | 27 | 40 | 38 | loose |
| Young Dolph | Trappa | 36 | 54 | 177 | loose |
| Young Dolph | Trappin’ Out a Mansion | 33 | 29 | 245 | loose |
| Young Dolph | Trenches | 67 | 66 | 269 | loose |
| Young Dolph | Tric Or Treat | 52 | 41 | 424 | loose |
| Young Dolph | Trigger Man | 30 | 29 | 214 | loose |
| Young Dolph | Trust Nobody | 45 | 56 | 280 | loose |
| Young Dolph | Tune Up | 54 | 62 | 328 | loose |
| Young Dolph | Turned Cold | 5 | 6 | 4 | loose |
| Young Dolph | Two | 29 | 38 | 165 | loose |
| Young Dolph | U Already Know | 49 | 65 | 572 | loose |
| Young Dolph | USA | 25 | 23 | 121 | loose |
| Young Dolph | Uh Uh | 35 | 44 | 132 | loose |
| Young Dolph | Um so real fr | 12 | 4 | 65 | loose |
| Young Dolph | Until It Rot | 32 | 43 | 231 | loose |
| Young Dolph | Virgin | 42 | 48 | 346 | loose |
| Young Dolph | WORKIN | 12 | 19 | 113 | loose |
| Young Dolph | Waffle House | 30 | 31 | 88 | loose |
| Young Dolph | Walk Back | 58 | 105 | 179 | loose |
| Young Dolph | Wall Street | 29 | 20 | 101 | loose |
| Young Dolph | Want It All | 39 | 62 | 133 | loose |
| Young Dolph | Wanted | 41 | 46 | 192 | loose |
| Young Dolph | Water | 44 | 31 | 231 | loose |
| Young Dolph | Water on Water on Water | 52 | 88 | 300 | loose |
| Young Dolph | We Fuckin It Up | 53 | 74 | 152 | loose |
| Young Dolph | We Gone | 51 | 43 | 183 | loose |
| Young Dolph | Weak | 27 | 13 | 157 | loose |
| Young Dolph | Weekend | 50 | 49 | 236 | loose |
| Young Dolph | Welcome | 51 | 48 | 304 | loose |
| Young Dolph | Welcome to Dolph World | 41 | 36 | 217 | loose |
| Young Dolph | What Else Is New | 32 | 14 | 145 | loose |
| Young Dolph | What Happened (Remix) | 72 | 66 | 329 | loose |
| Young Dolph | What I Came For | 27 | 33 | 172 | loose |
| Young Dolph | What I Gotta Do | 30 | 29 | 151 | loose |
| Young Dolph | What They Want | 28 | 33 | 220 | loose |
| Young Dolph | What Yo Life Like | 35 | 53 | 179 | loose |
| Young Dolph | What You Been Doin’ | 40 | 28 | 276 | loose |
| Young Dolph | What u see is what u get | 37 | 76 | 237 | loose |
| Young Dolph | Whatever | 24 | 16 | 138 | loose |
| Young Dolph | What’s Poppin (Intro) | 48 | 29 | 257 | loose |
| Young Dolph | What’s Wrong With The Streets | 28 | 25 | 154 | loose |
| Young Dolph | What’s da Bizness | 28 | 32 | 124 | loose |
| Young Dolph | What’s the Deal | 32 | 63 | 163 | loose |
| Young Dolph | Where the Money | 79 | 71 | 365 | loose |
| Young Dolph | While I’m Rollin’ Up | 52 | 27 | 274 | loose |
| Young Dolph | While U Here | 35 | 38 | 178 | loose |
| Young Dolph | Whoa (Remix) | 37 | 24 | 67 | loose |
| Young Dolph | Whole Lot | 32 | 20 | 141 | loose |
| Young Dolph | Whole Lotta | 44 | 84 | 278 | loose |
| Young Dolph | Whole World | 47 | 51 | 297 | loose |
| Young Dolph | Why Not | 38 | 47 | 287 | loose |
| Young Dolph | Win Big | 53 | 67 | 385 | loose |
| Young Dolph | With Me | 56 | 52 | 270 | loose |
| Young Dolph | Woah | 24 | 38 | 180 | loose |
| Young Dolph | Worth da Wait | 9 | 9 | 31 | loose |
| Young Dolph | Xtra Bad | 36 | 37 | 236 | loose |
| Young Dolph | Y.N.T Young Nigga Trap | 8 | 3 | 15 | ABCB |
| Young Dolph | Yeeh Yeeh | 23 | 41 | 163 | loose |
| Young Dolph | Yeezy | 33 | 32 | 191 | loose |
| Young Dolph | You Ain’t Straight | 69 | 69 | 419 | loose |
| Young Dolph | You Are What You Eat | 39 | 50 | 253 | loose |
| Young Dolph | You Got It (Remix) | 66 | 37 | 199 | loose |
| Young Dolph | Young Nigga | 39 | 9 | 184 | loose |
