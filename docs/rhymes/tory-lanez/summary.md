# Tory Lanez rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Tory Lanez
- Songs: 1118
- Bars kept (Tory Lanez lyric lines): 44124
- Section headers dropped, not counted as bars: 1
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 73
- Canonical name: Tory Lanez.
- Credit strings: Tory Lanez.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 260713
- REPEAT pairs, recorded separately: 37791
- END rhymes: 36227
- INNER rhymes: 224486

By match:

- PERFECT: 24182 (END 5528, INNER 18654)
- SLANT: 110140 (END 15017, INNER 95123)
- ASSONANCE: 122456 (END 14643, INNER 107813)
- MULTI: 3935 (END 1039, INNER 2896)

By confidence:

- HIGH: 25417
- MED: 215693
- LOW: 19603

## Core

- Core Y: 254903
- Core N among rhyme pairs: 5810

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 118172 (45.3%)
- vowel: 122456 (47.0%)
- spelling: 16150 (6.2%)
- multi: 3935 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 3 songs
- loose: 1115 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 17113 pairs (END 1517, INNER 15596). Words: bitches, shit, bitch, think, still, give, hit, different.
2. `vow:OW` — 16918 pairs (END 1638, INNER 15280). Words: know, don't, no, go, hoes, told, only, over.
3. `vow:EY` — 15555 pairs (END 2311, INNER 13244). Words: ain't, say, baby, way, make, day, play, take.
4. `vow:EH` — 15549 pairs (END 1683, INNER 13866). Words: when, get, never, gettin, tell, friends, left, let.
5. `vow:IY` — 10597 pairs (END 1347, INNER 9250). Words: see, even, shawty, need, these, keep, here, real.
6. `vow:AY` — 9680 pairs (END 1452, INNER 8228). Words: like, time, why, by, mind, fly, high, try.
7. `vow:AH` — 9621 pairs (END 1124, INNER 8497). Words: fuck, love, fuckin, what, one, some, come, money.
8. `vow:AE` — 9569 pairs (END 1324, INNER 8245). Words: can't, back, had, have, can, man, bad, ass.
9. `vow:AA` — 9130 pairs (END 869, INNER 8261). Words: got, want, talkin, hard, wanna, not, poppin, nothin.
10. `slant:IH:stop` — 5640 pairs (END 774, INNER 4866). Words: nigga, shit, hit, dick, big, whip, city, chick.
11. `slant:AA:stop` — 4825 pairs (END 427, INNER 4398). Words: got, gotta, want, not, top, body, stop, drop.
12. `slant:IH:sib-stop` — 4242 pairs (END 682, INNER 3560). Words: bitch, nigga, niggas, shit, hit, rich, dick, big.
13. `cmu:OW` — 3637 pairs (END 498, INNER 3139). Words: know, no, go, though, low, show, slow, throw.
14. `slant:AH:nas-stop` — 3121 pairs (END 176, INNER 2945). Words: fuck, what, one, money, come, some, done, fuckin.
15. `slant:AY:stop` — 3047 pairs (END 380, INNER 2667). Words: like, right, might, ride, night, side, inside, white.
16. `slant:EH:nas-stop` — 2976 pairs (END 146, INNER 2830). Words: when, get, let, again, said, gettin, ten, better.
17. `slant:AE:stop` — 2809 pairs (END 466, INNER 2343). Words: back, had, bad, can't, bag, trap, black, act.
18. `vow:AO` — 2745 pairs (END 354, INNER 2391). Words: all, call, wanted, more, talking, y'all, talk, lost.
19. `slant:EH:stop` — 2645 pairs (END 336, INNER 2309). Words: get, let, said, better, head, left, best, check.
20. `vow:UW` — 2588 pairs (END 409, INNER 2179). Words: new, through, two, used, who, move, cool, movin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 3837 pair sides, mostly spelling via spelling phonetic key, often with niggas (1121)
- niggas — 1774 pair sides, mostly spelling via spelling phonetic key, often with nigga (1121)
- shawty — 1110 pair sides, mostly vowel via spelling phonetic key, often with all (140)
- ima — 1005 pair sides, mostly spelling via spelling phonetic key, often with shit (139)
- tryna — 918 pair sides, mostly spelling via spelling phonetic key, often with these (91)
- gon — 861 pair sides, mostly spelling via spelling phonetic key, often with dont (235)
- dem — 215 pair sides, mostly spelling via spelling phonetic key, often with when (30)
- nuh — 151 pair sides, mostly spelling via spelling phonetic key, often with come (26)
- gyal — 145 pair sides, mostly spelling via spelling phonetic key, often with need (16)
- wraith — 145 pair sides, mostly spelling via spelling phonetic key, often with safe (12)
- swavey — 124 pair sides, mostly spelling via spelling phonetic key, often with swave (11)
- quiero — 124 pair sides, mostly vowel via spelling phonetic key, often with no (21)
- dawg — 117 pair sides, mostly spelling via spelling phonetic key, often with all (27)
- finna — 106 pair sides, mostly vowel via spelling phonetic key, often with nigga (31)
- cuando — 104 pair sides, mostly vowel via spelling phonetic key, often with no (17)
- lambo — 94 pair sides, mostly vowel via spelling phonetic key, often with know (17)
- stuntin — 91 pair sides, mostly spelling via spelling phonetic key, often with fuckin (12)
- lyin — 85 pair sides, mostly spelling via spelling phonetic key, often with these (7)
- bando — 84 pair sides, mostly vowel via spelling phonetic key, often with no (10)
- swag — 84 pair sides, mostly spelling via spelling phonetic key, often with back (9)
- cuz — 80 pair sides, mostly spelling via spelling phonetic key, often with love (10)
- wid — 79 pair sides, mostly spelling via spelling phonetic key, often with dick (21)
- digg — 77 pair sides, mostly spelling via spelling phonetic key, often with bitch (8)
- contigo — 76 pair sides, mostly vowel via spelling phonetic key, often with no (11)
- bih — 75 pair sides, mostly spelling via spelling phonetic key, often with bitch (13)
- seh — 74 pair sides, mostly spelling via spelling phonetic key, often with dem (10)
- twerk — 71 pair sides, mostly spelling via spelling phonetic key, often with work (30)
- henny — 68 pair sides, mostly vowel via spelling phonetic key, often with baby (10)
- tings — 67 pair sides, mostly spelling via spelling phonetic key, often with ting (8)
- bros — 66 pair sides, mostly spelling via spelling phonetic key, often with hoes (12)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Tory Lanez | #PRAY4FARGO (Healing) | 31 | 37 | 299 | loose |
| Tory Lanez | $ailor Moon | 44 | 23 | 183 | loose |
| Tory Lanez | ...The Make Up | 29 | 12 | 177 | loose |
| Tory Lanez | 1 Call | 33 | 10 | 78 | loose |
| Tory Lanez | 1 Hitter | 57 | 78 | 267 | loose |
| Tory Lanez | 1 Hunnit | 27 | 31 | 168 | loose |
| Tory Lanez | 1 Night | 41 | 33 | 180 | loose |
| Tory Lanez | 10 F*CKS | 40 | 19 | 272 | loose |
| Tory Lanez | 10 Shots | 70 | 35 | 330 | loose |
| Tory Lanez | 10 Shots Of Deleon | 30 | 22 | 95 | loose |
| Tory Lanez | 10 Times | 58 | 40 | 290 | loose |
| Tory Lanez | 100 | 36 | 22 | 153 | loose |
| Tory Lanez | 100 Bandz | 49 | 21 | 172 | loose |
| Tory Lanez | 100 Percent | 38 | 17 | 168 | loose |
| Tory Lanez | 100 Reasons (Lost Tapes 2022) | 48 | 27 | 217 | loose |
| Tory Lanez | 2 Bad Bitches | 45 | 65 | 216 | loose |
| Tory Lanez | 2 Cups | 45 | 44 | 215 | loose |
| Tory Lanez | 2 Ea$y | 34 | 26 | 163 | loose |
| Tory Lanez | 2 Late (Mixtape Version) | 43 | 55 | 296 | loose |
| Tory Lanez | 2 Shot Gyal | 23 | 19 | 106 | loose |
| Tory Lanez | 2AM | 47 | 36 | 116 | loose |
| Tory Lanez | 3 Choices* | 48 | 44 | 319 | loose |
| Tory Lanez | 392 | 76 | 71 | 319 | loose |
| Tory Lanez | 4 Me | 20 | 6 | 58 | loose |
| Tory Lanez | 40 Days n 40 Nights | 47 | 34 | 331 | loose |
| Tory Lanez | 48 Floors | 36 | 30 | 224 | loose |
| Tory Lanez | 4PM in Calabasas | 43 | 28 | 324 | loose |
| Tory Lanez | 4am Flex | 62 | 33 | 233 | loose |
| Tory Lanez | 4u | 7 | 4 | 80 | loose |
| Tory Lanez | 580 Benz (Prison Tapes) | 52 | 52 | 353 | loose |
| Tory Lanez | 6 minutes, 5 reasons | 19 | 3 | 83 | loose |
| Tory Lanez | 62 | 31 | 17 | 182 | loose |
| Tory Lanez | 9$IDE x Amethyst | 62 | 74 | 382 | loose |
| Tory Lanez | 9Side Bodmon | 57 | 59 | 479 | loose |
| Tory Lanez | 9x Outta 10 | 35 | 50 | 112 | loose |
| Tory Lanez | A Fools Tale (Running Back) | 86 | 50 | 339 | loose |
| Tory Lanez | A Poem From Me 2 You | 16 | 27 | 101 | loose |
| Tory Lanez | A Week Straight | 50 | 38 | 322 | loose |
| Tory Lanez | A Woman | 39 | 15 | 90 | loose |
| Tory Lanez | AFTERPARTY FREESTYLE | 28 | 16 | 45 | loose |
| Tory Lanez | Aaliyah | 34 | 17 | 133 | loose |
| Tory Lanez | Aaron Hall Sample (Scottie Pippen / 5-Minute Freestyle) | 13 | 14 | 147 | loose |
| Tory Lanez | Accidents Happen | 70 | 81 | 441 | loose |
| Tory Lanez | Accordian | 27 | 9 | 50 | loose |
| Tory Lanez | Act a Fool (Remix) | 33 | 32 | 79 | loose |
| Tory Lanez | Acting Like | 31 | 19 | 69 | loose |
| Tory Lanez | Actin’ Up | 66 | 37 | 242 | loose |
| Tory Lanez | Adidas | 72 | 99 | 626 | loose |
| Tory Lanez | Adore (feat. Tory Lanez) | 47 | 46 | 84 | loose |
| Tory Lanez | Adrenalina | 40 | 36 | 328 | loose |
| Tory Lanez | Again | 19 | 6 | 51 | loose |
| Tory Lanez | Again & Again | 6 | 1 | 7 | loose |
| Tory Lanez | Against My Religion | 20 | 15 | 162 | loose |
| Tory Lanez | Aggression From Saturn | 35 | 27 | 183 | loose |
| Tory Lanez | Ahhhahhhhh (Lost Tapes 2021) | 26 | 20 | 112 | loose |
| Tory Lanez | Ain’t Mine* | 36 | 35 | 110 | loose |
| Tory Lanez | Albany Bahamas | 45 | 27 | 393 | loose |
| Tory Lanez | Alexa Loves It | 10 | 2 | 20 | loose |
| Tory Lanez | Alexandria (Lost Tapes 2019) | 28 | 31 | 133 | loose |
| Tory Lanez | All Away | 46 | 24 | 262 | loose |
| Tory Lanez | All I Want Is You | 44 | 23 | 173 | loose |
| Tory Lanez | All That | 28 | 15 | 85 | loose |
| Tory Lanez | All The Time | 56 | 54 | 323 | loose |
| Tory Lanez | All These Bandz | 45 | 32 | 152 | loose |
| Tory Lanez | All in My Head (Flex) | 31 | 12 | 64 | loose |
| Tory Lanez | All or Nothing | 38 | 15 | 97 | loose |
| Tory Lanez | All the Girls | 38 | 25 | 142 | loose |
| Tory Lanez | Alright With Me | 12 | 7 | 44 | loose |
| Tory Lanez | Ambitionz Az a Ridah Freestyle | 29 | 35 | 177 | loose |
| Tory Lanez | And This Is Just the Intro | 85 | 74 | 437 | loose |
| Tory Lanez | Anymore // Fuck Boy Intentions | 105 | 105 | 658 | loose |
| Tory Lanez | Anything | 17 | 21 | 139 | loose |
| Tory Lanez | Anyway | 30 | 26 | 128 | loose |
| Tory Lanez | Apartment 310 | 55 | 45 | 230 | loose |
| Tory Lanez | Appellate Court Freestyle (Prison Tapes) | 68 | 89 | 628 | loose |
| Tory Lanez | Are You Down? | 20 | 12 | 92 | loose |
| Tory Lanez | Around Here Remix | 24 | 0 | 211 | loose |
| Tory Lanez | Aston Martin Music | 39 | 24 | 167 | loose |
| Tory Lanez | August 19th | 75 | 93 | 478 | loose |
| Tory Lanez | Automatic | 32 | 39 | 125 | loose |
| Tory Lanez | Ayo | 22 | 3 | 96 | loose |
| Tory Lanez | B.A.B.Y | 46 | 68 | 200 | loose |
| Tory Lanez | B.B.O (Bad Bitches Only) (Lost Tapes 2022) | 30 | 12 | 187 | loose |
| Tory Lanez | B.B.W.W x Fake Show | 69 | 66 | 557 | loose |
| Tory Lanez | B.I.D | 28 | 22 | 82 | loose |
| Tory Lanez | B.L.O.W. | 78 | 65 | 318 | loose |
| Tory Lanez | BACK FOR YOU | 11 | 4 | 41 | loose |
| Tory Lanez | BDay | 48 | 46 | 309 | loose |
| Tory Lanez | BESOOZOON | 7 | 3 | 27 | loose |
| Tory Lanez | BUGIA | 45 | 29 | 321 | loose |
| Tory Lanez | BUSS AT YOU [G-Mix] | 37 | 21 | 126 | loose |
| Tory Lanez | Babyface Savage | 40 | 40 | 295 | loose |
| Tory Lanez | Back Out$ide | 49 | 36 | 337 | loose |
| Tory Lanez | Back Outside | 32 | 18 | 76 | loose |
| Tory Lanez | Back in Business | 35 | 11 | 141 | loose |
| Tory Lanez | Back to Back (Twitch Tapes) | 16 | 12 | 63 | loose |
| Tory Lanez | Bad Bitches Wrk @ Taboo | 29 | 35 | 182 | loose |
| Tory Lanez | Bad Blood | 20 | 10 | 63 | loose |
| Tory Lanez | Bad Boy | 37 | 20 | 155 | loose |
| Tory Lanez | Bad Then A Beach | 11 | 7 | 57 | loose |
| Tory Lanez | Bad Tings Richmix | 67 | 42 | 210 | loose |
| Tory Lanez | Baddest Boy (US Remix) | 28 | 23 | 118 | loose |
| Tory Lanez | Bal Harbour | 50 | 60 | 171 | loose |
| Tory Lanez | Balenciagas | 59 | 44 | 462 | loose |
| Tory Lanez | Ballad of a Badman | 24 | 22 | 63 | loose |
| Tory Lanez | Band a Man | 55 | 33 | 336 | loose |
| Tory Lanez | Bands In the Trap | 38 | 38 | 175 | loose |
| Tory Lanez | Bands On Her | 49 | 69 | 243 | loose |
| Tory Lanez | Baneful (Lost Tapes 2022) | 30 | 21 | 380 | loose |
| Tory Lanez | Bangout Maria | 42 | 34 | 266 | loose |
| Tory Lanez | Bartenders & Spenders | 46 | 30 | 167 | loose |
| Tory Lanez | Basement (Prison Tapes) | 28 | 61 | 196 | loose |
| Tory Lanez | Be Polite | 21 | 33 | 62 | loose |
| Tory Lanez | Be With You | 50 | 33 | 151 | loose |
| Tory Lanez | Beamer, Benz, or Bentley Freestyle | 44 | 42 | 330 | loose |
| Tory Lanez | Beautiful Place | 40 | 59 | 177 | loose |
| Tory Lanez | Beautiful Refugee | 28 | 6 | 112 | loose |
| Tory Lanez | Beauty in the Benz | 55 | 53 | 270 | loose |
| Tory Lanez | Bed Sheet (Lost Tapes 2019) | 23 | 14 | 83 | loose |
| Tory Lanez | Been Getting Money | 54 | 31 | 270 | loose |
| Tory Lanez | Been On (Remix) | 66 | 52 | 370 | loose |
| Tory Lanez | Beetlejuice | 45 | 30 | 143 | loose |
| Tory Lanez | Benevolent | 61 | 44 | 482 | loose |
| Tory Lanez | Benihana | 8 | 8 | 79 | loose |
| Tory Lanez | Benjamin Heads | 15 | 15 | 60 | loose |
| Tory Lanez | Best Birthday Ever | 35 | 16 | 123 | loose |
| Tory Lanez | Best Friend | 66 | 106 | 340 | loose |
| Tory Lanez | Best of You // Busted (SKIT) | 73 | 45 | 238 | loose |
| Tory Lanez | Better | 43 | 37 | 173 | loose |
| Tory Lanez | Bhad | 35 | 21 | 99 | loose |
| Tory Lanez | Bicycle ride | 42 | 34 | 170 | loose |
| Tory Lanez | Big | 35 | 18 | 180 | loose |
| Tory Lanez | Big Big (Lost Tapes 2022) | 13 | 11 | 68 | loose |
| Tory Lanez | Big Dog | 25 | 23 | 161 | loose |
| Tory Lanez | Big Drip (Tory Lanez Remix) | 66 | 58 | 145 | loose |
| Tory Lanez | Big Timing* | 26 | 29 | 155 | loose |
| Tory Lanez | Big Tipper | 70 | 62 | 456 | loose |
| Tory Lanez | Birthday | 56 | 28 | 611 | loose |
| Tory Lanez | Bittersweet | 113 | 116 | 784 | loose |
| Tory Lanez | Bizzerk (Lost Tapes 2019) | 29 | 17 | 279 | loose |
| Tory Lanez | Black and Yellow | 32 | 22 | 154 | loose |
| Tory Lanez | Blackout | 16 | 5 | 85 | loose |
| Tory Lanez | Blame My Ex | 17 | 8 | 99 | loose |
| Tory Lanez | Blessed (Lost Tapes 2019) | 30 | 29 | 168 | loose |
| Tory Lanez | Blowin’ Mine’s // Leah’s Introduction (SKIT) | 55 | 20 | 165 | loose |
| Tory Lanez | Blue Jay Season | 13 | 4 | 73 | loose |
| Tory Lanez | Blue Tinted | 62 | 34 | 171 | loose |
| Tory Lanez | Blue Violets (Twitch Tapes) | 25 | 23 | 117 | loose |
| Tory Lanez | Blurred (Twitch Tapes) | 19 | 35 | 135 | loose |
| Tory Lanez | Bodmon Remix | 28 | 10 | 129 | loose |
| Tory Lanez | Bodmon Song | 30 | 22 | 100 | loose |
| Tory Lanez | Bogus | 84 | 36 | 171 | loose |
| Tory Lanez | Boink Boink | 72 | 98 | 346 | loose |
| Tory Lanez | Bonnie & Clyde (Lost Tapes 2022) | 23 | 12 | 122 | loose |
| Tory Lanez | Booker T | 6 | 4 | 21 | loose |
| Tory Lanez | Boss | 39 | 48 | 235 | loose |
| Tory Lanez | Brand New | 34 | 18 | 202 | loose |
| Tory Lanez | Brand New Choppa | 63 | 40 | 228 | loose |
| Tory Lanez | Brazy Ness | 35 | 51 | 201 | loose |
| Tory Lanez | Broke In A Minute | 45 | 47 | 164 | loose |
| Tory Lanez | Broke Leg | 46 | 50 | 283 | loose |
| Tory Lanez | Broken Promises | 27 | 8 | 69 | loose |
| Tory Lanez | Brucesteen (Lost Tapes 2019) | 13 | 7 | 206 | loose |
| Tory Lanez | Bulma’s Patience | 31 | 32 | 97 | loose |
| Tory Lanez | Bus Stop Dreams | 29 | 14 | 122 | loose |
| Tory Lanez | Bus Ticket (Lost Tapes 2022) | 13 | 19 | 110 | loose |
| Tory Lanez | C.O.D. | 41 | 38 | 202 | loose |
| Tory Lanez | CAP | 39 | 38 | 225 | loose |
| Tory Lanez | COOCHEE | 40 | 24 | 210 | loose |
| Tory Lanez | Call Me If (Remix) | 48 | 37 | 353 | loose |
| Tory Lanez | Call Me Up (feat. Tory Lanez) | 22 | 6 | 72 | loose |
| Tory Lanez | Call My Phone* | 10 | 3 | 34 | loose |
| Tory Lanez | Calling (Twitch Tapes) | 19 | 16 | 132 | loose |
| Tory Lanez | Came 4 Me | 21 | 9 | 60 | loose |
| Tory Lanez | Came Thru | 35 | 19 | 75 | loose |
| Tory Lanez | Camera Phone (Lost Tapes 2018) | 15 | 16 | 69 | loose |
| Tory Lanez | Can I | 52 | 60 | 165 | loose |
| Tory Lanez | Canada Goose | 56 | 54 | 236 | loose |
| Tory Lanez | Can’t Forget | 36 | 45 | 118 | loose |
| Tory Lanez | Can’t Get Enough | 47 | 30 | 223 | loose |
| Tory Lanez | Can’t Stand It | 38 | 24 | 226 | loose |
| Tory Lanez | Can’t Stop Me Freestyle | 61 | 54 | 305 | loose |
| Tory Lanez | Captain Week | 30 | 7 | 65 | loose |
| Tory Lanez | Care for You | 90 | 97 | 686 | loose |
| Tory Lanez | Carolina High | 52 | 35 | 411 | loose |
| Tory Lanez | Cartier | 34 | 50 | 226 | loose |
| Tory Lanez | Casa-Freak-Hoes | 16 | 7 | 156 | loose |
| Tory Lanez | Caucasian Girls | 66 | 49 | 451 | loose |
| Tory Lanez | Cell 245 (Prison Tapes) | 56 | 58 | 379 | loose |
| Tory Lanez | Champagne Wishes & Caviar Dreams | 53 | 33 | 397 | loose |
| Tory Lanez | Chances | 28 | 14 | 178 | loose |
| Tory Lanez | Charlie Row x Wishing Well | 65 | 69 | 390 | loose |
| Tory Lanez | Chauffeur | 21 | 16 | 64 | loose |
| Tory Lanez | Chauffeur Ricky Rich Remix | 16 | 4 | 80 | loose |
| Tory Lanez | Chixtape Trilogy Freestyle | 35 | 21 | 190 | loose |
| Tory Lanez | Choppa* | 4 | 2 | 6 | loose |
| Tory Lanez | Chops Out | 48 | 65 | 293 | loose |
| Tory Lanez | Chopstix II | 40 | 68 | 173 | loose |
| Tory Lanez | Circumstances (Lost Tapes 2016) | 28 | 14 | 120 | loose |
| Tory Lanez | City (Lost Tapes 2021) | 24 | 23 | 151 | loose |
| Tory Lanez | City Boy Summer | 76 | 47 | 462 | loose |
| Tory Lanez | City Lock | 53 | 48 | 345 | loose |
| Tory Lanez | Clean | 56 | 42 | 231 | loose |
| Tory Lanez | Closer | 37 | 28 | 189 | loose |
| Tory Lanez | Clouded // TJ’s Interlude | 30 | 22 | 168 | loose |
| Tory Lanez | Cold | 41 | 41 | 188 | loose |
| Tory Lanez | Cold Hard Love | 41 | 23 | 147 | loose |
| Tory Lanez | Cold Love | 55 | 19 | 193 | loose |
| Tory Lanez | Collection | 33 | 27 | 183 | loose |
| Tory Lanez | College Kid | 4 | 0 | 13 | loose |
| Tory Lanez | Color Violet | 17 | 9 | 31 | loose |
| Tory Lanez | Colt 95 | 53 | 24 | 304 | loose |
| Tory Lanez | Come Around | 30 | 33 | 119 | loose |
| Tory Lanez | Come Back to Me | 24 | 11 | 112 | loose |
| Tory Lanez | Comeback (Remix) | 37 | 27 | 154 | loose |
| Tory Lanez | Comfort You | 25 | 14 | 81 | loose |
| Tory Lanez | Conclusions* | 17 | 9 | 42 | loose |
| Tory Lanez | Conexión | 70 | 58 | 902 | loose |
| Tory Lanez | Conmigo (With Me) | 9 | 0 | 40 | loose |
| Tory Lanez | Connection | 32 | 20 | 225 | loose |
| Tory Lanez | Controlla (Remix) | 50 | 28 | 201 | loose |
| Tory Lanez | Convertible Burt | 84 | 74 | 295 | loose |
| Tory Lanez | Could’ve Been (Twitch Tapes) | 9 | 0 | 46 | loose |
| Tory Lanez | Count Up The Bands (Lost Tapes 2019) | 38 | 35 | 103 | loose |
| Tory Lanez | Courtside | 44 | 35 | 353 | loose |
| Tory Lanez | Crazy (Wrong Way) (Solo Version)* | 29 | 12 | 54 | loose |
| Tory Lanez | Crazy Freestyle (Twitch Outro, Umbrella Freestyle, Lymph Nodes, Chris Rock) | 55 | 33 | 325 | loose |
| Tory Lanez | Crew | 24 | 16 | 60 | loose |
| Tory Lanez | Crocodile Teeth Freestyle | 46 | 50 | 303 | loose |
| Tory Lanez | Crodie From The 9 // Guy In My City | 65 | 90 | 453 | loose |
| Tory Lanez | Crystal Strawberry | 17 | 16 | 18 | loose |
| Tory Lanez | CuT me oFF | 29 | 23 | 151 | loose |
| Tory Lanez | Cuba (Lost Tapes 2021) | 16 | 12 | 57 | loose |
| Tory Lanez | Curry | 24 | 23 | 184 | loose |
| Tory Lanez | Cut Up (Remix) | 40 | 36 | 182 | loose |
| Tory Lanez | Cypher | 121 | 122 | 708 | loose |
| Tory Lanez | D.N.D. | 29 | 57 | 123 | loose |
| Tory Lanez | D.O.E / The Lights | 40 | 18 | 281 | loose |
| Tory Lanez | D.O.S.E | 52 | 86 | 192 | loose |
| Tory Lanez | DANNY PHANTOM (Free Tory) | 51 | 65 | 221 | loose |
| Tory Lanez | DJ Drama’s Presentation | 5 | 1 | 22 | loose |
| Tory Lanez | DJADJA | 28 | 13 | 102 | loose |
| Tory Lanez | DON’T DIE | 50 | 66 | 368 | loose |
| Tory Lanez | Dada Di (Lost Tapes 2022) | 10 | 22 | 23 | AAAA |
| Tory Lanez | Damn | 35 | 16 | 150 | loose |
| Tory Lanez | Dance for Me | 60 | 33 | 315 | loose |
| Tory Lanez | Dancers Remorse (Sin City) | 27 | 12 | 97 | loose |
| Tory Lanez | Dancin’ | 38 | 56 | 101 | loose |
| Tory Lanez | Dangerous* | 8 | 12 | 14 | loose |
| Tory Lanez | Danny Glover (Freestyle) | 74 | 72 | 485 | loose |
| Tory Lanez | Dark Chocolate (Prison Tapes) | 28 | 11 | 138 | loose |
| Tory Lanez | Dark Fantasy | 48 | 47 | 280 | loose |
| Tory Lanez | Dash (Lost Tapes 2020) | 34 | 27 | 234 | loose |
| Tory Lanez | Day Shift (Lost Tapes 2022) | 15 | 6 | 58 | loose |
| Tory Lanez | Daylight (Demo) | 13 | 10 | 54 | loose |
| Tory Lanez | Dear Kai (Prison Tapes) | 50 | 34 | 398 | loose |
| Tory Lanez | Deceiving Eve | 51 | 50 | 186 | loose |
| Tory Lanez | Decisions | 38 | 33 | 113 | loose |
| Tory Lanez | Deen & AB // SGA | 74 | 72 | 371 | loose |
| Tory Lanez | Dem Ones | 71 | 54 | 347 | loose |
| Tory Lanez | Dependency | 91 | 83 | 575 | loose |
| Tory Lanez | Designer, Dasani | 52 | 44 | 158 | loose |
| Tory Lanez | Diamond Minds | 40 | 39 | 188 | loose |
| Tory Lanez | Diamonds (Lost Tapes 2016) | 34 | 50 | 177 | loose |
| Tory Lanez | Diego | 55 | 28 | 215 | loose |
| Tory Lanez | Diego - Live From Spotify House | 13 | 1 | 21 | loose |
| Tory Lanez | Differences | 31 | 14 | 60 | loose |
| Tory Lanez | Dirty Money | 50 | 28 | 222 | loose |
| Tory Lanez | Disclosure | 37 | 24 | 165 | loose |
| Tory Lanez | Distance | 40 | 23 | 128 | loose |
| Tory Lanez | Do Better | 13 | 11 | 58 | loose |
| Tory Lanez | Do It for Me | 44 | 30 | 164 | loose |
| Tory Lanez | Do You Remember (Lost Tapes 2016) | 39 | 56 | 231 | loose |
| Tory Lanez | Do You Understand? | 80 | 154 | 308 | loose |
| Tory Lanez | Do the Most | 45 | 44 | 202 | loose |
| Tory Lanez | Don Queen (Don Q Diss) | 112 | 94 | 728 | loose |
| Tory Lanez | Don’t I Know Ya | 35 | 22 | 217 | loose |
| Tory Lanez | Don’t Look Down | 43 | 29 | 110 | loose |
| Tory Lanez | Don’t Say Nothin’ | 50 | 35 | 224 | loose |
| Tory Lanez | Don’t Walk Away... Just Trust Me | 102 | 60 | 457 | loose |
| Tory Lanez | Dope Boy’s Diary | 72 | 54 | 426 | loose |
| Tory Lanez | DopeMan Go | 45 | 23 | 159 | loose |
| Tory Lanez | DrIP DrIp Drip | 50 | 30 | 159 | loose |
| Tory Lanez | Drama | 46 | 71 | 349 | loose |
| Tory Lanez | Dreaming | 37 | 32 | 299 | loose |
| Tory Lanez | Dreaming2 | 55 | 76 | 475 | loose |
| Tory Lanez | Drifting | 61 | 51 | 225 | loose |
| Tory Lanez | Dripping | 38 | 34 | 260 | loose |
| Tory Lanez | Dripping in Sauce | 28 | 16 | 140 | loose |
| Tory Lanez | Drive You Home | 48 | 28 | 126 | loose |
| Tory Lanez | Driver | 57 | 35 | 239 | loose |
| Tory Lanez | Droptop in the Rain | 25 | 11 | 40 | loose |
| Tory Lanez | Dry Your I’s | 14 | 5 | 95 | loose |
| Tory Lanez | DucK my Ex | 41 | 34 | 98 | loose |
| Tory Lanez | Dusty* | 21 | 41 | 146 | loose |
| Tory Lanez | Dímelo | 38 | 18 | 193 | loose |
| Tory Lanez | Earned | 41 | 37 | 194 | loose |
| Tory Lanez | Earth | 74 | 35 | 180 | loose |
| Tory Lanez | Eediot Bwoy (Lost Tapes 2020) | 21 | 11 | 134 | loose |
| Tory Lanez | Elephants | 60 | 86 | 296 | loose |
| Tory Lanez | Elevator Music (Remix) | 48 | 32 | 204 | loose |
| Tory Lanez | Emotional | 33 | 47 | 142 | loose |
| Tory Lanez | EmpireMatic II | 45 | 33 | 185 | loose |
| Tory Lanez | Enchanted Waterfall | 24 | 20 | 59 | loose |
| Tory Lanez | Es rollt | 39 | 26 | 354 | loose |
| Tory Lanez | Everything I Ever Wanted | 41 | 20 | 245 | loose |
| Tory Lanez | Everywhere | 33 | 62 | 256 | loose |
| Tory Lanez | Ex-Men | 42 | 42 | 177 | loose |
| Tory Lanez | Extravagant Bullshit//Nunchucks | 48 | 49 | 399 | loose |
| Tory Lanez | F&V (Prison Tapes) | 13 | 10 | 73 | loose |
| Tory Lanez | F.E.E.L.S. | 29 | 8 | 70 | loose |
| Tory Lanez | F.L.Y. | 40 | 41 | 315 | loose |
| Tory Lanez | FALL | 26 | 7 | 80 | loose |
| Tory Lanez | FIFTY | 57 | 68 | 340 | loose |
| Tory Lanez | FYB | 31 | 8 | 86 | loose |
| Tory Lanez | Face Time Fake Time* | 8 | 0 | 51 | loose |
| Tory Lanez | Faded (Freestyle) | 69 | 69 | 311 | loose |
| Tory Lanez | Faithful | 38 | 42 | 319 | loose |
| Tory Lanez | Fake Addresses (Twitch Tapes) | 14 | 6 | 50 | loose |
| Tory Lanez | Fake Love (Original) | 23 | 14 | 71 | loose |
| Tory Lanez | Fallback | 40 | 17 | 169 | loose |
| Tory Lanez | Falling (Lil Thing) | 12 | 11 | 34 | loose |
| Tory Lanez | Familiar | 4 | 1 | 5 | loose |
| Tory Lanez | Favorite Eater | 42 | 18 | 197 | loose |
| Tory Lanez | FeRRis WhEEL | 34 | 31 | 258 | loose |
| Tory Lanez | Featherweight (Prison Tapes) | 21 | 15 | 160 | loose |
| Tory Lanez | Feel Alive | 29 | 19 | 140 | loose |
| Tory Lanez | Feel It Too | 41 | 36 | 103 | loose |
| Tory Lanez | Feet on the Ground | 43 | 37 | 348 | loose |
| Tory Lanez | Fine Line (Remix) | 35 | 19 | 76 | loose |
| Tory Lanez | First Day Out (R&B version) | 28 | 13 | 169 | loose |
| Tory Lanez | First Time | 53 | 45 | 263 | loose |
| Tory Lanez | Fish Scale | 24 | 9 | 84 | loose |
| Tory Lanez | FlEXiBle | 37 | 46 | 156 | loose |
| Tory Lanez | Flaunt That | 22 | 16 | 65 | loose |
| Tory Lanez | Flewed Out | 26 | 25 | 148 | loose |
| Tory Lanez | Flex | 41 | 30 | 149 | loose |
| Tory Lanez | Florida Shit | 78 | 56 | 563 | loose |
| Tory Lanez | Fly Shit | 21 | 12 | 40 | loose |
| Tory Lanez | Fly to the Beach | 2 | 0 | 0 | loose |
| Tory Lanez | Follow Me | 18 | 9 | 24 | loose |
| Tory Lanez | For Me | 4 | 0 | 8 | loose |
| Tory Lanez | For Real | 83 | 52 | 286 | loose |
| Tory Lanez | For You | 45 | 44 | 201 | loose |
| Tory Lanez | Forever | 58 | 58 | 268 | loose |
| Tory Lanez | Fortnite | 20 | 29 | 74 | loose |
| Tory Lanez | Fourteen & 40's | 28 | 12 | 217 | loose |
| Tory Lanez | Freaky | 45 | 39 | 349 | loose |
| Tory Lanez | Free 21 Freestyle | 95 | 101 | 568 | loose |
| Tory Lanez | Free Me | 77 | 84 | 585 | loose |
| Tory Lanez | Free Pedro Interlude | 54 | 38 | 211 | loose |
| Tory Lanez | Free Tory | 112 | 72 | 782 | loose |
| Tory Lanez | Fresh Out | 36 | 32 | 186 | loose |
| Tory Lanez | Friday the 13th | 55 | 28 | 311 | loose |
| Tory Lanez | Friends | 31 | 13 | 178 | loose |
| Tory Lanez | Friends Become Strangers | 79 | 96 | 521 | loose |
| Tory Lanez | Friends with Benefits | 39 | 20 | 78 | loose |
| Tory Lanez | Front Row (Lost Tapes 2019) | 18 | 17 | 124 | loose |
| Tory Lanez | Fuck Breast Cancer (Lost Tapes 2022) | 36 | 21 | 194 | loose |
| Tory Lanez | Fuck Love | 45 | 18 | 165 | loose |
| Tory Lanez | Fuck That Nigga | 50 | 31 | 175 | loose |
| Tory Lanez | Fuck the Pain Away (Lost Tapes 2022) | 23 | 25 | 102 | loose |
| Tory Lanez | Fuck with You | 31 | 14 | 263 | loose |
| Tory Lanez | Fucking Awesome | 36 | 11 | 290 | loose |
| Tory Lanez | Fuckin’ Wit Me | 54 | 45 | 253 | loose |
| Tory Lanez | Fyne Shit Paradise | 37 | 13 | 163 | loose |
| Tory Lanez | G.A.N.G. !@#$% | 51 | 35 | 407 | loose |
| Tory Lanez | GIDI GIDI | 62 | 57 | 235 | loose |
| Tory Lanez | GIRLS IN LOVE | 52 | 58 | 314 | loose |
| Tory Lanez | GYATT | 11 | 15 | 37 | loose |
| Tory Lanez | GYMR | 56 | 74 | 290 | loose |
| Tory Lanez | Gangland x Fargentina 4EVR | 133 | 152 | 680 | loose |
| Tory Lanez | Gelato | 25 | 32 | 71 | loose |
| Tory Lanez | Get Me Some More* | 2 | 0 | 0 | loose |
| Tory Lanez | Getaway | 40 | 19 | 165 | loose |
| Tory Lanez | Getcha Roll On | 46 | 48 | 211 | loose |
| Tory Lanez | Gimme That Work | 19 | 14 | 96 | loose |
| Tory Lanez | Girl Is Mine | 28 | 13 | 83 | loose |
| Tory Lanez | Girlfriend | 58 | 43 | 216 | loose |
| Tory Lanez | Girls Around the World (Lost Tapes 2016) | 30 | 8 | 72 | loose |
| Tory Lanez | Girls in the Room (Lost Tapes 2020) | 36 | 35 | 108 | loose |
| Tory Lanez | Give It Up | 37 | 17 | 301 | loose |
| Tory Lanez | Gliss Gliss | 19 | 41 | 171 | loose |
| Tory Lanez | Glock 44 (Lost Tapes 2022) | 58 | 56 | 453 | loose |
| Tory Lanez | Go (Lost Tapes 2022) | 28 | 28 | 113 | loose |
| Tory Lanez | Go Hard | 74 | 80 | 378 | loose |
| Tory Lanez | God Sent You | 34 | 26 | 107 | loose |
| Tory Lanez | Goin’ Up | 22 | 13 | 108 | loose |
| Tory Lanez | Gold | 20 | 10 | 151 | loose |
| Tory Lanez | Good Dope | 5 | 0 | 2 | loose |
| Tory Lanez | Good Girls Gone Bad | 42 | 17 | 197 | loose |
| Tory Lanez | Good Love | 37 | 30 | 144 | loose |
| Tory Lanez | Good Luck* | 7 | 3 | 10 | loose |
| Tory Lanez | Good Night | 35 | 53 | 63 | loose |
| Tory Lanez | Gotta Move On (Kings Remix) | 48 | 39 | 286 | loose |
| Tory Lanez | Grah Tah Tah | 49 | 44 | 416 | loose |
| Tory Lanez | Grandma House | 31 | 22 | 126 | loose |
| Tory Lanez | Grandma’s Crib | 43 | 45 | 197 | loose |
| Tory Lanez | Grave (Lost Tapes 2018) | 28 | 96 | 292 | AAAA |
| Tory Lanez | Guess What (Intentions)* | 57 | 48 | 162 | loose |
| Tory Lanez | Guide Me Through The Storm | 85 | 63 | 414 | loose |
| Tory Lanez | Guilty As Charged | 43 | 35 | 239 | loose |
| Tory Lanez | Guilty Of It | 40 | 43 | 354 | loose |
| Tory Lanez | Guns and Roses | 23 | 17 | 62 | loose |
| Tory Lanez | Gyal Dem Ryte | 56 | 34 | 214 | loose |
| Tory Lanez | Gyal Gimmie | 32 | 18 | 178 | loose |
| Tory Lanez | Gyalis (Remix) | 32 | 13 | 218 | loose |
| Tory Lanez | H.E.R.//Are You Dumb | 47 | 50 | 229 | loose |
| Tory Lanez | HANDLING BUSINESS | 61 | 80 | 557 | loose |
| Tory Lanez | HELMET ft Tory Lanez (SD3) | 25 | 7 | 42 | loose |
| Tory Lanez | HML (Tory Lanez Remix) | 47 | 69 | 157 | loose |
| Tory Lanez | Hair, Nails, Makeup | 48 | 23 | 155 | loose |
| Tory Lanez | Hallelujah | 53 | 27 | 215 | loose |
| Tory Lanez | Halo | 33 | 17 | 146 | loose |
| Tory Lanez | Handsome (Lost Tapes 2016) | 23 | 27 | 137 | loose |
| Tory Lanez | Happiness x Tell Me | 59 | 64 | 270 | loose |
| Tory Lanez | Happy Hour | 46 | 39 | 276 | loose |
| Tory Lanez | Hasty Market // Toronto | 95 | 89 | 621 | loose |
| Tory Lanez | Hate Freestyle | 49 | 48 | 167 | loose |
| Tory Lanez | Hate Me on the Low / The Suggestion | 48 | 36 | 329 | loose |
| Tory Lanez | Hate To Say | 74 | 39 | 618 | loose |
| Tory Lanez | Heartbreak From Cell 210 | 36 | 24 | 287 | loose |
| Tory Lanez | Heartless | 30 | 14 | 131 | loose |
| Tory Lanez | Help | 24 | 17 | 129 | loose |
| Tory Lanez | Helping Hand* | 19 | 15 | 103 | loose |
| Tory Lanez | Hennessy Memories | 48 | 48 | 441 | loose |
| Tory Lanez | Henny in Hand | 17 | 9 | 179 | loose |
| Tory Lanez | Her | 35 | 11 | 79 | loose |
| Tory Lanez | Here It Goes | 62 | 95 | 252 | loose |
| Tory Lanez | High | 15 | 16 | 61 | loose |
| Tory Lanez | High Notes | 19 | 7 | 45 | loose |
| Tory Lanez | Highschool Memories | 34 | 17 | 241 | loose |
| Tory Lanez | Hillside | 36 | 48 | 146 | loose |
| Tory Lanez | Hit And Run | 51 | 34 | 127 | loose |
| Tory Lanez | Hold It Down | 37 | 27 | 111 | loose |
| Tory Lanez | Hold Onto Me | 9 | 3 | 22 | loose |
| Tory Lanez | Hold the Jet* | 16 | 37 | 127 | loose |
| Tory Lanez | Hollywood Life | 45 | 26 | 129 | loose |
| Tory Lanez | Honda Civic | 50 | 18 | 158 | loose |
| Tory Lanez | Honest | 28 | 16 | 206 | loose |
| Tory Lanez | Horror Plays (The Process) | 11 | 8 | 36 | loose |
| Tory Lanez | Hot Gyal | 41 | 44 | 218 | loose |
| Tory Lanez | Hot Pursuit | 40 | 44 | 233 | loose |
| Tory Lanez | Hot Toddy | 27 | 30 | 168 | loose |
| Tory Lanez | Hou’s World | 75 | 66 | 467 | loose |
| Tory Lanez | How Long Can You Go Freestyle | 20 | 21 | 117 | loose |
| Tory Lanez | How Much (Original) | 18 | 12 | 141 | loose |
| Tory Lanez | How Much X | 56 | 52 | 314 | loose |
| Tory Lanez | Huh | 25 | 17 | 56 | loose |
| Tory Lanez | Hurt Nobody | 41 | 20 | 135 | loose |
| Tory Lanez | Hurt from Mercury | 18 | 6 | 85 | loose |
| Tory Lanez | Hurting Me | 32 | 27 | 211 | loose |
| Tory Lanez | Hurts Me | 27 | 12 | 42 | loose |
| Tory Lanez | Hypnotized | 25 | 6 | 53 | loose |
| Tory Lanez | I Bet | 38 | 21 | 191 | loose |
| Tory Lanez | I Fxcked A Lady Cop | 55 | 58 | 280 | loose |
| Tory Lanez | I Go | 51 | 34 | 299 | loose |
| Tory Lanez | I Got | 8 | 9 | 14 | loose |
| Tory Lanez | I Got the Keys | 85 | 74 | 486 | loose |
| Tory Lanez | I Hope So | 8 | 5 | 7 | loose |
| Tory Lanez | I Know Everything | 22 | 14 | 104 | loose |
| Tory Lanez | I LIKE | 28 | 15 | 179 | loose |
| Tory Lanez | I Might (Twitch Tapes) | 22 | 20 | 203 | loose |
| Tory Lanez | I Need More | 42 | 13 | 205 | loose |
| Tory Lanez | I See | 33 | 19 | 131 | loose |
| Tory Lanez | I Shoulda* | 24 | 12 | 61 | loose |
| Tory Lanez | I Sip | 30 | 18 | 97 | loose |
| Tory Lanez | I Told You/ Another One | 87 | 88 | 498 | loose |
| Tory Lanez | I Want You | 38 | 19 | 176 | loose |
| Tory Lanez | I-95 | 29 | 11 | 217 | loose |
| Tory Lanez | IF iT Ain’T rIGHt | 31 | 43 | 107 | loose |
| Tory Lanez | Ice Cream | 6 | 4 | 25 | loose |
| Tory Lanez | Icey Dicey | 109 | 98 | 539 | loose |
| Tory Lanez | If You Gotta... | 54 | 40 | 295 | loose |
| Tory Lanez | Ignition | 49 | 32 | 152 | loose |
| Tory Lanez | In For It | 56 | 18 | 164 | loose |
| Tory Lanez | In My Nightmares | 16 | 12 | 38 | loose |
| Tory Lanez | In da Morning | 27 | 15 | 124 | loose |
| Tory Lanez | In the Air | 91 | 79 | 624 | loose |
| Tory Lanez | Initiation | 46 | 30 | 136 | loose |
| Tory Lanez | Intermission | 18 | 6 | 91 | loose |
| Tory Lanez | Internet Girl | 55 | 20 | 228 | loose |
| Tory Lanez | Intro (Chixtape 4) | 10 | 1 | 36 | loose |
| Tory Lanez | Intro - Live From Spotify House | 4 | 1 | 13 | loose |
| Tory Lanez | Island Gyal | 39 | 5 | 95 | loose |
| Tory Lanez | It Doesn’t Matter | 34 | 27 | 107 | loose |
| Tory Lanez | It’s Crazy | 35 | 15 | 123 | loose |
| Tory Lanez | It’s Up* | 29 | 23 | 84 | loose |
| Tory Lanez | I’M THE MAN — 52ndz Version | 29 | 26 | 89 | loose |
| Tory Lanez | I’ll Be There | 42 | 13 | 182 | loose |
| Tory Lanez | I’m Gone Have It (Interlude) | 6 | 0 | 39 | loose |
| Tory Lanez | I’m Good (Freestyle) | 83 | 76 | 422 | loose |
| Tory Lanez | I’m On My Way | 58 | 38 | 180 | loose |
| Tory Lanez | I’ve Been (Lost Tapes 2016) | 25 | 7 | 53 | loose |
| Tory Lanez | JLO (Bad Then A Beach/Woo Baby Original) | 34 | 30 | 133 | loose |
| Tory Lanez | Jalen Brunson | 43 | 55 | 256 | loose |
| Tory Lanez | Jalissa’s Back! (SKIT) | 19 | 1 | 52 | loose |
| Tory Lanez | Jalissa’s Friends (Interlude) | 14 | 3 | 74 | loose |
| Tory Lanez | Jalissa’s Friends Pt.2 (Skit) | 19 | 1 | 59 | loose |
| Tory Lanez | Jalissa’s Intro | 16 | 3 | 65 | loose |
| Tory Lanez | Janne’s Cotton Candy | 30 | 20 | 160 | loose |
| Tory Lanez | Jerry Sprunger | 56 | 36 | 152 | loose |
| Tory Lanez | Jokes on Me | 50 | 69 | 280 | loose |
| Tory Lanez | Junior High | 20 | 13 | 65 | loose |
| Tory Lanez | Jus Know (Demo) | 43 | 33 | 118 | loose |
| Tory Lanez | Just Got It Done | 37 | 23 | 246 | loose |
| Tory Lanez | Just Landed | 27 | 20 | 126 | loose |
| Tory Lanez | Just Like You (Remix) | 37 | 22 | 149 | loose |
| Tory Lanez | Just a Friend | 41 | 21 | 65 | loose |
| Tory Lanez | Just the Way (Lost Tapes 2022) | 16 | 11 | 87 | loose |
| Tory Lanez | Juvenile Freestyle | 48 | 17 | 155 | loose |
| Tory Lanez | Juvenile Freestyle - Live From Spotify House | 12 | 4 | 15 | loose |
| Tory Lanez | K Lo K | 46 | 65 | 93 | loose |
| Tory Lanez | KAME HOUSE | 12 | 6 | 34 | loose |
| Tory Lanez | KIKA | 27 | 21 | 192 | loose |
| Tory Lanez | KJm | 48 | 41 | 248 | loose |
| Tory Lanez | Kaioken | 56 | 54 | 245 | loose |
| Tory Lanez | Karrueche | 33 | 13 | 134 | loose |
| Tory Lanez | Katrina (Lost Tapes 2017) | 25 | 24 | 82 | loose |
| Tory Lanez | KeeP IN tOUcH | 48 | 30 | 183 | loose |
| Tory Lanez | Keep Callin (Lost Tapes 2021) | 26 | 29 | 182 | loose |
| Tory Lanez | Keep It 100 | 41 | 32 | 84 | loose |
| Tory Lanez | Keep It A Hunned | 66 | 36 | 335 | loose |
| Tory Lanez | Keeping Me Out (with Tory Lanez) | 34 | 16 | 118 | loose |
| Tory Lanez | Keisha | 22 | 10 | 122 | loose |
| Tory Lanez | Keisha’s Intro (Skit) | 13 | 4 | 35 | loose |
| Tory Lanez | Keyz to Vampa | 31 | 23 | 68 | loose |
| Tory Lanez | Kick Back (Lost Tapes 2020) | 15 | 3 | 32 | loose |
| Tory Lanez | Kids From the West | 49 | 25 | 190 | loose |
| Tory Lanez | Know Bout Us | 10 | 3 | 37 | loose |
| Tory Lanez | Know What You Need (Prison Tapes) | 33 | 14 | 76 | loose |
| Tory Lanez | Know What’s Up / The Take | 51 | 19 | 192 | loose |
| Tory Lanez | Kody | 33 | 24 | 105 | loose |
| Tory Lanez | Konichiwa | 65 | 72 | 450 | loose |
| Tory Lanez | Krillin’s Fumble | 44 | 30 | 121 | loose |
| Tory Lanez | L.M.B.B (Lost Tapes 2018) | 24 | 8 | 124 | loose |
| Tory Lanez | LA Confidential | 22 | 7 | 78 | loose |
| Tory Lanez | LICK x Drive You Crazy | 58 | 52 | 469 | loose |
| Tory Lanez | LUV | 35 | 11 | 93 | loose |
| Tory Lanez | Lady of Namek | 35 | 40 | 119 | loose |
| Tory Lanez | Lady of Neptune | 53 | 20 | 136 | loose |
| Tory Lanez | Laid Back Fun | 24 | 8 | 209 | loose |
| Tory Lanez | Language | 31 | 40 | 245 | loose |
| Tory Lanez | Last Chance | 22 | 18 | 125 | loose |
| Tory Lanez | Last Kiss of Nebulon | 26 | 7 | 100 | loose |
| Tory Lanez | Last Love Letter (SKIT) | 26 | 1 | 60 | loose |
| Tory Lanez | Late at Night | 9 | 11 | 36 | loose |
| Tory Lanez | Lavender Sunflower | 21 | 6 | 42 | loose |
| Tory Lanez | Lawyer Fees | 35 | 19 | 144 | loose |
| Tory Lanez | LeBron in Miami (Twitch Tapes) | 14 | 9 | 110 | loose |
| Tory Lanez | Leaning | 35 | 44 | 121 | loose |
| Tory Lanez | Leave In The Morning | 29 | 9 | 134 | loose |
| Tory Lanez | Let Her Go | 22 | 15 | 44 | loose |
| Tory Lanez | Let Me | 23 | 9 | 43 | loose |
| Tory Lanez | Let Me Know | 41 | 28 | 241 | loose |
| Tory Lanez | Lets Dance* (One More Time) | 7 | 3 | 24 | loose |
| Tory Lanez | Letter to the City | 23 | 18 | 136 | loose |
| Tory Lanez | Letter to the City 2 | 64 | 75 | 418 | loose |
| Tory Lanez | Let’s Get Married | 18 | 10 | 47 | loose |
| Tory Lanez | Let’s Get to It (Lost Tapes 2019) | 17 | 4 | 56 | loose |
| Tory Lanez | Life | 69 | 65 | 481 | loose |
| Tory Lanez | Light Up | 24 | 14 | 163 | loose |
| Tory Lanez | Lights On | 41 | 29 | 159 | loose |
| Tory Lanez | Like Dope | 67 | 51 | 277 | loose |
| Tory Lanez | Like Them | 52 | 37 | 347 | loose |
| Tory Lanez | Line Up the Flex | 31 | 30 | 150 | loose |
| Tory Lanez | Line of Scrimmage (Lost Tapes 2019) | 26 | 20 | 243 | loose |
| Tory Lanez | Lip Lock (Lost Tapes 2018) | 19 | 27 | 151 | loose |
| Tory Lanez | Liquor | 36 | 35 | 268 | loose |
| Tory Lanez | Little Birdie (Lost Tapes 2019) | 19 | 9 | 110 | loose |
| Tory Lanez | Litty | 70 | 40 | 418 | loose |
| Tory Lanez | Litty Again (Freestyle) | 132 | 88 | 759 | loose |
| Tory Lanez | Livin’ Right | 41 | 33 | 113 | loose |
| Tory Lanez | London (Freestyle) | 52 | 40 | 776 | loose |
| Tory Lanez | Lonely | 37 | 35 | 237 | loose |
| Tory Lanez | Loner at Sunset | 10 | 2 | 28 | loose |
| Tory Lanez | Loners Blvd | 60 | 23 | 295 | loose |
| Tory Lanez | Long Time (Nightstand)* | 18 | 9 | 53 | loose |
| Tory Lanez | Look How GOD Works | 54 | 78 | 333 | loose |
| Tory Lanez | Look No Further (Lost Tapes 2016) | 75 | 67 | 363 | loose |
| Tory Lanez | Looks | 67 | 58 | 280 | loose |
| Tory Lanez | Loose Leaf | 26 | 21 | 95 | loose |
| Tory Lanez | Lord Knows | 85 | 93 | 449 | loose |
| Tory Lanez | Lord Knows Pt. 2 | 37 | 12 | 141 | loose |
| Tory Lanez | Losing Friends (Lost Tapes 2018) | 43 | 18 | 242 | loose |
| Tory Lanez | Lotta Money Ave (Lost Tapes 2017) | 14 | 5 | 41 | loose |
| Tory Lanez | Loud | 42 | 11 | 76 | loose |
| Tory Lanez | Loud Pack | 40 | 25 | 192 | loose |
| Tory Lanez | Louis V Belt | 23 | 28 | 99 | loose |
| Tory Lanez | Love Come Down Freestyle | 33 | 30 | 164 | loose |
| Tory Lanez | Love Me After | 63 | 83 | 513 | loose |
| Tory Lanez | Love Sounds* | 15 | 1 | 36 | loose |
| Tory Lanez | Love Too Hard (Remix) | 35 | 26 | 162 | loose |
| Tory Lanez | Lucky | 38 | 44 | 104 | loose |
| Tory Lanez | Lucky You (Freestyle) | 78 | 79 | 511 | loose |
| Tory Lanez | Lurkin’ | 36 | 24 | 91 | loose |
| Tory Lanez | Luv Ya Gyal // Love Sounds | 93 | 43 | 298 | loose |
| Tory Lanez | MAWA Interlude x Lunch Tray | 59 | 67 | 419 | loose |
| Tory Lanez | MEMORIES | 7 | 7 | 29 | loose |
| Tory Lanez | MSG 4 GOD’S CHILDREN | 37 | 31 | 340 | loose |
| Tory Lanez | MYLIFE 2.0 | 41 | 30 | 72 | loose |
| Tory Lanez | MadMan (Lost Tapes 2020) | 25 | 19 | 171 | loose |
| Tory Lanez | Magic | 32 | 13 | 121 | loose |
| Tory Lanez | Magnolia Freestyle | 60 | 60 | 328 | loose |
| Tory Lanez | Main One | 39 | 37 | 115 | loose |
| Tory Lanez | Makaveli | 56 | 41 | 381 | loose |
| Tory Lanez | Mama Told Me | 102 | 111 | 587 | loose |
| Tory Lanez | Man Eater* | 27 | 15 | 149 | loose |
| Tory Lanez | Many Men Pt. 2 | 41 | 47 | 348 | loose |
| Tory Lanez | March 2nd | 34 | 25 | 227 | loose |
| Tory Lanez | MariWanna | 75 | 63 | 169 | loose |
| Tory Lanez | Marriott Hotel | 45 | 19 | 746 | loose |
| Tory Lanez | Maybe | 25 | 14 | 57 | loose |
| Tory Lanez | Me & My Bitch | 48 | 16 | 153 | loose |
| Tory Lanez | Melee | 49 | 38 | 129 | loose |
| Tory Lanez | Memories Don’t Die (Freestyle) | 18 | 9 | 138 | loose |
| Tory Lanez | Memory Lane | 20 | 20 | 112 | loose |
| Tory Lanez | Menace* | 49 | 41 | 607 | loose |
| Tory Lanez | Mexico | 35 | 21 | 277 | loose |
| Tory Lanez | MiAMi | 73 | 49 | 368 | loose |
| Tory Lanez | Midnight’s Interlude | 8 | 2 | 13 | loose |
| Tory Lanez | Millions | 73 | 63 | 228 | loose |
| Tory Lanez | Mine Still (Freestyle) | 43 | 33 | 268 | loose |
| Tory Lanez | Mirage (feat. Tory Lanez) | 57 | 64 | 293 | loose |
| Tory Lanez | Miss Me | 40 | 31 | 239 | loose |
| Tory Lanez | Miss You | 28 | 22 | 40 | loose |
| Tory Lanez | Money Over Fallouts | 99 | 134 | 792 | loose |
| Tory Lanez | Monies | 27 | 16 | 68 | loose |
| Tory Lanez | More Than Friends | 34 | 25 | 91 | loose |
| Tory Lanez | Motorboat | 59 | 61 | 381 | loose |
| Tory Lanez | Mr. Peterson (Intro) | 37 | 27 | 184 | loose |
| Tory Lanez | Ms. Backseat Love / The Gut Feeling | 60 | 20 | 275 | loose |
| Tory Lanez | Mucky James | 54 | 39 | 460 | loose |
| Tory Lanez | Mugz’s Advi$e | 9 | 2 | 76 | loose |
| Tory Lanez | Murcielago | 28 | 31 | 146 | loose |
| Tory Lanez | Music to My Ears | 14 | 10 | 63 | loose |
| Tory Lanez | My Feelings | 4 | 1 | 25 | loose |
| Tory Lanez | My Heart Feels (Lost Tapes 2021) | 27 | 17 | 100 | loose |
| Tory Lanez | My Nigga | 71 | 58 | 204 | loose |
| Tory Lanez | My One | 44 | 26 | 141 | loose |
| Tory Lanez | My Salsa | 34 | 21 | 217 | loose |
| Tory Lanez | My Shayla * SPICE-RILLA | 111 | 140 | 661 | loose |
| Tory Lanez | My Time to Shine | 66 | 49 | 477 | loose |
| Tory Lanez | My Town Freestyle | 37 | 33 | 182 | loose |
| Tory Lanez | My Type | 37 | 26 | 252 | loose |
| Tory Lanez | N.A.M.E. | 47 | 29 | 182 | loose |
| Tory Lanez | N.I.N.A. | 30 | 45 | 130 | loose |
| Tory Lanez | NO MORE EXCUSES | 12 | 10 | 54 | loose |
| Tory Lanez | Naked | 39 | 31 | 115 | loose |
| Tory Lanez | Name - Live From Spotify House | 6 | 3 | 17 | loose |
| Tory Lanez | Naughty Naughty (O.G Version) | 30 | 16 | 118 | loose |
| Tory Lanez | Need Somebody | 21 | 12 | 24 | loose |
| Tory Lanez | Need a Girl | 31 | 9 | 45 | loose |
| Tory Lanez | Neighborhood Hero | 28 | 35 | 181 | loose |
| Tory Lanez | Never Was | 26 | 17 | 169 | loose |
| Tory Lanez | New Edition | 36 | 40 | 252 | loose |
| Tory Lanez | New Toronto | 41 | 42 | 245 | loose |
| Tory Lanez | New Year / $auce Baby | 41 | 32 | 181 | loose |
| Tory Lanez | Newz | 33 | 44 | 189 | loose |
| Tory Lanez | Nice & Slow | 37 | 40 | 311 | loose |
| Tory Lanez | Nigga Skit Pt. 2 | 15 | 1 | 61 | loose |
| Tory Lanez | Niggas In Paris (Freestyle) | 86 | 74 | 342 | loose |
| Tory Lanez | Niggas Talk (Skit) | 21 | 7 | 66 | loose |
| Tory Lanez | Nights Like This (Lost Tapes 2022) | 33 | 25 | 219 | loose |
| Tory Lanez | Nikki Beach | 46 | 31 | 246 | loose |
| Tory Lanez | No Confidence (Intro) | 11 | 6 | 37 | loose |
| Tory Lanez | No Games | 33 | 20 | 140 | loose |
| Tory Lanez | No More Parties in LA | 51 | 57 | 248 | loose |
| Tory Lanez | No Service | 50 | 77 | 208 | loose |
| Tory Lanez | No Sleep | 33 | 38 | 183 | loose |
| Tory Lanez | No Strings Attached | 40 | 38 | 247 | loose |
| Tory Lanez | No Switches | 49 | 38 | 253 | loose |
| Tory Lanez | Nobody (Lost Tapes 2018) | 46 | 28 | 264 | loose |
| Tory Lanez | Not Going Back | 56 | 66 | 327 | loose |
| Tory Lanez | Not Today | 47 | 30 | 169 | loose |
| Tory Lanez | Not Tricking // Black Keys | 61 | 54 | 373 | loose |
| Tory Lanez | Note to Self | 8 | 2 | 16 | loose |
| Tory Lanez | Note to You | 14 | 6 | 34 | loose |
| Tory Lanez | Novacane | 26 | 32 | 68 | loose |
| Tory Lanez | Numb | 31 | 21 | 126 | loose |
| Tory Lanez | Number One | 34 | 30 | 76 | loose |
| Tory Lanez | Numbers Out The Gym | 21 | 19 | 97 | loose |
| Tory Lanez | Obvious* | 7 | 3 | 23 | loose |
| Tory Lanez | Odesza (Liquor & Vodka) | 9 | 7 | 18 | loose |
| Tory Lanez | Oh My | 31 | 30 | 53 | loose |
| Tory Lanez | Old Friends x New Foes | 59 | 62 | 409 | loose |
| Tory Lanez | On & On | 35 | 24 | 104 | loose |
| Tory Lanez | On Da Low | 32 | 25 | 106 | loose |
| Tory Lanez | On It | 35 | 24 | 58 | loose |
| Tory Lanez | On Me | 35 | 34 | 139 | loose |
| Tory Lanez | On My Way | 39 | 68 | 235 | loose |
| Tory Lanez | On You | 44 | 38 | 161 | loose |
| Tory Lanez | On a Fucking Lean | 23 | 10 | 53 | loose |
| Tory Lanez | On the Set | 43 | 25 | 166 | loose |
| Tory Lanez | One Day | 35 | 18 | 182 | loose |
| Tory Lanez | One Night Lover | 40 | 26 | 240 | loose |
| Tory Lanez | Only Fans | 28 | 17 | 107 | loose |
| Tory Lanez | Or Somethin’ | 6 | 0 | 35 | loose |
| Tory Lanez | Other Side | 74 | 55 | 214 | loose |
| Tory Lanez | Out Of Center | 72 | 67 | 361 | loose |
| Tory Lanez | Out the Park | 13 | 5 | 39 | loose |
| Tory Lanez | Outro (Swavey) | 43 | 22 | 282 | loose |
| Tory Lanez | P. Family | 7 | 0 | 30 | loose |
| Tory Lanez | P.A.I.N | 53 | 15 | 329 | loose |
| Tory Lanez | PILLOWTALK (Tory Lanez Remix) | 38 | 38 | 170 | loose |
| Tory Lanez | PUNANI (Demo) | 26 | 36 | 113 | loose |
| Tory Lanez | Pa Mi | 35 | 17 | 304 | loose |
| Tory Lanez | Pandora Swave | 35 | 19 | 246 | loose |
| Tory Lanez | Party 4 Martians | 24 | 10 | 71 | loose |
| Tory Lanez | Passport (Twitch Tapes) | 14 | 4 | 87 | loose |
| Tory Lanez | Patek Philippe (Remix) | 50 | 28 | 165 | loose |
| Tory Lanez | Pay Up | 44 | 46 | 212 | loose |
| Tory Lanez | Peace of Mind | 49 | 35 | 150 | loose |
| Tory Lanez | Penny | 45 | 46 | 407 | loose |
| Tory Lanez | Penthouse Blue | 56 | 120 | 358 | AAAA |
| Tory Lanez | Penthouse Red | 44 | 51 | 315 | loose |
| Tory Lanez | Perfect Timing | 18 | 23 | 82 | loose |
| Tory Lanez | Phases (Lost Tapes 2017) | 29 | 53 | 192 | loose |
| Tory Lanez | Phone Secs x FaceTime | 30 | 15 | 103 | loose |
| Tory Lanez | Pieces | 94 | 74 | 679 | loose |
| Tory Lanez | Pierre Balmain | 54 | 25 | 334 | loose |
| Tory Lanez | Pink Dolphin Sunset | 31 | 17 | 74 | loose |
| Tory Lanez | Pink Material | 35 | 35 | 115 | loose |
| Tory Lanez | Planet Bass/NBLYB | 26 | 7 | 48 | loose |
| Tory Lanez | Pluto’s Last Comet | 18 | 18 | 64 | loose |
| Tory Lanez | Poison Ivy | 23 | 5 | 123 | loose |
| Tory Lanez | Pop Out Freestyle (Playboy Mix) | 26 | 28 | 195 | loose |
| Tory Lanez | Popular Chance (Lost Tapes 2022) | 43 | 60 | 303 | loose |
| Tory Lanez | Pour Up for Me | 26 | 19 | 74 | loose |
| Tory Lanez | Practice (Lost Tapes 2022) | 25 | 29 | 106 | loose |
| Tory Lanez | Pretty Face | 27 | 38 | 207 | loose |
| Tory Lanez | Priceless | 51 | 34 | 224 | loose |
| Tory Lanez | Priceless - Live From Spotify House | 15 | 8 | 47 | loose |
| Tory Lanez | Pricey & Spicy | 51 | 42 | 125 | loose |
| Tory Lanez | Prima Donna (Lost Tapes 2022) | 25 | 29 | 181 | loose |
| Tory Lanez | Prison Letters | 14 | 1 | 24 | loose |
| Tory Lanez | Prom King / Love On Acid | 30 | 25 | 40 | loose |
| Tory Lanez | Pronto Freestyle | 23 | 21 | 102 | loose |
| Tory Lanez | Prostitute Flange (Lost Tapes 2021) | 46 | 47 | 178 | loose |
| Tory Lanez | Proud Family | 45 | 13 | 164 | loose |
| Tory Lanez | Proud Penny | 52 | 75 | 154 | loose |
| Tory Lanez | Pull Up | 46 | 31 | 127 | loose |
| Tory Lanez | Purple (Lost Tapes 2022) | 40 | 39 | 294 | loose |
| Tory Lanez | Purple Swave (Freestyle) | 66 | 57 | 421 | loose |
| Tory Lanez | Pussy Like Oouuu | 53 | 23 | 186 | loose |
| Tory Lanez | Put It In (Lost Tapes 2019) | 35 | 17 | 169 | loose |
| Tory Lanez | Putting It Down* | 4 | 1 | 0 | loose |
| Tory Lanez | Quarantine (Lost Tapes 2020) | 17 | 22 | 97 | loose |
| Tory Lanez | Queen and Slim | 88 | 78 | 385 | loose |
| Tory Lanez | Question Is | 58 | 40 | 315 | loose |
| Tory Lanez | R.I.D.E. | 17 | 15 | 46 | loose |
| Tory Lanez | RIGHT NOW RADIO | 24 | 17 | 85 | loose |
| Tory Lanez | RONDO | 36 | 53 | 176 | loose |
| Tory Lanez | Rack City (Freestyle) | 51 | 50 | 293 | loose |
| Tory Lanez | Racks to the Ceiling | 37 | 43 | 237 | loose |
| Tory Lanez | Radar | 29 | 15 | 49 | loose |
| Tory Lanez | Rain | 20 | 14 | 92 | loose |
| Tory Lanez | Rapture | 62 | 104 | 351 | loose |
| Tory Lanez | Rare L | 45 | 52 | 311 | loose |
| Tory Lanez | Rather You Than Me (Twitch Tapes) | 18 | 22 | 72 | loose |
| Tory Lanez | Real Addresses | 36 | 15 | 192 | loose |
| Tory Lanez | Real Thing | 57 | 74 | 313 | loose |
| Tory Lanez | Really Large Amount | 11 | 2 | 9 | loose |
| Tory Lanez | Red Casamigos | 51 | 58 | 309 | loose |
| Tory Lanez | Reggie Miller | 28 | 14 | 92 | loose |
| Tory Lanez | Remembrance Day | 55 | 20 | 297 | loose |
| Tory Lanez | Reminders | 15 | 11 | 77 | loose |
| Tory Lanez | Reminds Me Of (Twitch Tapes) | 30 | 30 | 290 | loose |
| Tory Lanez | Restricted Raven | 39 | 30 | 173 | loose |
| Tory Lanez | Return of the G | 20 | 11 | 170 | loose |
| Tory Lanez | Revenge of Fargo | 60 | 123 | 443 | loose |
| Tory Lanez | Ric Flair | 100 | 69 | 535 | loose |
| Tory Lanez | Rich Forever | 41 | 42 | 172 | loose |
| Tory Lanez | Rick n Morty (Remix) | 31 | 33 | 171 | loose |
| Tory Lanez | Ride | 42 | 47 | 175 | loose |
| Tory Lanez | Ride - Live From Spotify House | 17 | 4 | 36 | loose |
| Tory Lanez | Ridin’ Round | 25 | 25 | 135 | loose |
| Tory Lanez | Right Now (Remix) | 24 | 20 | 79 | loose |
| Tory Lanez | Right There (Remix) | 34 | 42 | 164 | loose |
| Tory Lanez | Rihanna | 34 | 25 | 177 | loose |
| Tory Lanez | Risk It All | 49 | 33 | 118 | loose |
| Tory Lanez | Rivals | 19 | 11 | 148 | loose |
| Tory Lanez | Rodeo Drive (Twitch Tapes) | 23 | 12 | 109 | loose |
| Tory Lanez | Role Call | 29 | 26 | 144 | loose |
| Tory Lanez | Roll (4AM Demo) | 23 | 23 | 117 | loose |
| Tory Lanez | Rolled Up | 35 | 26 | 127 | loose |
| Tory Lanez | Rollin’ | 54 | 46 | 150 | loose |
| Tory Lanez | Room 112 | 49 | 28 | 183 | loose |
| Tory Lanez | Roses (Lost Tapes 2022) | 23 | 14 | 224 | loose |
| Tory Lanez | Rotation | 40 | 49 | 163 | loose |
| Tory Lanez | Round Here | 50 | 11 | 182 | loose |
| Tory Lanez | Rubberband (Balling) | 37 | 42 | 150 | loose |
| Tory Lanez | Ruffles Bag (Lost Tapes 2019) | 28 | 32 | 170 | loose |
| Tory Lanez | S*M*N | 49 | 38 | 135 | loose |
| Tory Lanez | S.L.I.D.E | 34 | 12 | 54 | loose |
| Tory Lanez | S.M.O | 25 | 7 | 84 | loose |
| Tory Lanez | S.W.A.V.E. Radio (Interlude) | 6 | 1 | 30 | loose |
| Tory Lanez | S.W.A.V.E. Radio Pt II (Interlude) | 7 | 1 | 13 | loose |
| Tory Lanez | S.W.A.V.E. Radio Pt III (Interlude) | 8 | 1 | 49 | loose |
| Tory Lanez | S.w.I.n.G | 57 | 42 | 242 | loose |
| Tory Lanez | SHE tOLd Me | 39 | 25 | 196 | loose |
| Tory Lanez | SKAT | 83 | 87 | 495 | loose |
| Tory Lanez | SOCO | 43 | 27 | 103 | loose |
| Tory Lanez | SWAVE MAN | 50 | 21 | 310 | loose |
| Tory Lanez | Same Shit | 46 | 49 | 131 | loose |
| Tory Lanez | Same Way (Twitch Tapes) | 13 | 4 | 70 | loose |
| Tory Lanez | Sandy Lil Beach* | 6 | 3 | 11 | loose |
| Tory Lanez | Sauce | 39 | 28 | 82 | loose |
| Tory Lanez | Save As Mudanisse | 43 | 31 | 744 | loose |
| Tory Lanez | Save It | 54 | 25 | 231 | loose |
| Tory Lanez | Say Ahh Freestyle | 37 | 19 | 197 | loose |
| Tory Lanez | Say Goodbye | 5 | 1 | 4 | loose |
| Tory Lanez | Say Hello | 44 | 43 | 262 | loose |
| Tory Lanez | Say It | 40 | 28 | 98 | loose |
| Tory Lanez | Say It - Live From Spotify House | 13 | 6 | 33 | loose |
| Tory Lanez | Say That Shit | 50 | 29 | 207 | loose |
| Tory Lanez | Say What’s Ill | 72 | 125 | 594 | loose |
| Tory Lanez | Scarborough to Dubai | 16 | 17 | 79 | loose |
| Tory Lanez | School Fight (Lost Tapes 2020) | 19 | 17 | 136 | loose |
| Tory Lanez | Seasons Change | 42 | 42 | 176 | loose |
| Tory Lanez | Selfish / York University | 90 | 56 | 329 | loose |
| Tory Lanez | Senseless (Remix) | 44 | 31 | 181 | loose |
| Tory Lanez | Set It Off x Better | 40 | 42 | 140 | loose |
| Tory Lanez | Sex Anonymous | 28 | 13 | 110 | loose |
| Tory Lanez | Sex Lies (OG)* | 38 | 34 | 163 | loose |
| Tory Lanez | Sex So Good | 22 | 11 | 119 | loose |
| Tory Lanez | Sex Songs | 38 | 40 | 89 | loose |
| Tory Lanez | Sextasy | 15 | 4 | 66 | loose |
| Tory Lanez | Sexy | 38 | 36 | 240 | loose |
| Tory Lanez | Shabba Ranks (Freestyle) | 68 | 77 | 430 | loose |
| Tory Lanez | Shadow Soul | 28 | 11 | 83 | loose |
| Tory Lanez | Shameless | 37 | 48 | 167 | loose |
| Tory Lanez | Shawty Girl | 42 | 20 | 158 | loose |
| Tory Lanez | She Don’t Love U | 47 | 26 | 240 | loose |
| Tory Lanez | She Like It Ruff | 22 | 9 | 39 | loose |
| Tory Lanez | She Love Me | 54 | 49 | 151 | loose |
| Tory Lanez | She Make It Clap (Freestyle) | 2 | 0 | 1 | loose |
| Tory Lanez | She Make It Clap Freestyle | 34 | 37 | 135 | loose |
| Tory Lanez | She Used to Be Mine | 33 | 21 | 146 | loose |
| Tory Lanez | She’s Mine | 44 | 17 | 143 | loose |
| Tory Lanez | Shining Remix | 61 | 60 | 282 | loose |
| Tory Lanez | Shit Freestyle (Swave Session 2) | 46 | 54 | 329 | loose |
| Tory Lanez | Shooby Doowoop//One Last Heartbreak | 52 | 22 | 181 | loose |
| Tory Lanez | Shooters | 31 | 26 | 122 | loose |
| Tory Lanez | Shootin Shots | 31 | 21 | 163 | loose |
| Tory Lanez | Shot 4 Later | 40 | 27 | 118 | loose |
| Tory Lanez | Shot Caller (Freestyle) | 60 | 48 | 424 | loose |
| Tory Lanez | Shot Clock Violations | 69 | 115 | 475 | loose |
| Tory Lanez | Shotgun | 29 | 5 | 81 | loose |
| Tory Lanez | Shots Come for Free (Prison Tapes) | 58 | 53 | 565 | loose |
| Tory Lanez | Show Me Love | 27 | 39 | 162 | loose |
| Tory Lanez | Show Me Love x KNUCK, ROCK, SCRUB & CONNECT | 23 | 17 | 101 | loose |
| Tory Lanez | Shrug It Off (Lost Tapes 2022) | 14 | 13 | 60 | loose |
| Tory Lanez | Shut Up | 67 | 46 | 244 | loose |
| Tory Lanez | Shut Up & Love | 12 | 5 | 25 | loose |
| Tory Lanez | Sickening | 44 | 41 | 177 | loose |
| Tory Lanez | Signs (2021) | 25 | 17 | 97 | loose |
| Tory Lanez | Simba (Lost Tapes 2022) | 69 | 61 | 423 | loose |
| Tory Lanez | Simple Things | 36 | 28 | 130 | loose |
| Tory Lanez | Sincerely Tory | 41 | 19 | 158 | loose |
| Tory Lanez | Situation | 32 | 26 | 132 | loose |
| Tory Lanez | Skate on Jake (Lost Tapes 2020) | 70 | 114 | 299 | loose |
| Tory Lanez | Skrt Skrt | 22 | 11 | 31 | loose |
| Tory Lanez | Sleep On U | 31 | 31 | 113 | loose |
| Tory Lanez | Sleep On You | 37 | 36 | 184 | loose |
| Tory Lanez | Slept on You | 33 | 15 | 227 | loose |
| Tory Lanez | Slide | 27 | 12 | 63 | loose |
| Tory Lanez | Slipping x Falling | 54 | 66 | 423 | loose |
| Tory Lanez | Slow (Lost Tapes 2021) | 16 | 12 | 117 | loose |
| Tory Lanez | Slow Down | 46 | 49 | 207 | loose |
| Tory Lanez | Slow Fade (Lost Tapes 2019) | 20 | 31 | 58 | loose |
| Tory Lanez | Slow Grind | 41 | 21 | 114 | loose |
| Tory Lanez | Slow for Me | 36 | 26 | 126 | loose |
| Tory Lanez | Sneeze Wrong | 68 | 41 | 427 | loose |
| Tory Lanez | So Drunk | 37 | 16 | 190 | loose |
| Tory Lanez | So Drunk I Forgot You (Twitch Tapes) | 7 | 0 | 43 | loose |
| Tory Lanez | So Many Times (Lost Tapes 2022) | 40 | 60 | 216 | loose |
| Tory Lanez | Solar Drive @ Night | 19 | 7 | 37 | loose |
| Tory Lanez | Some More | 40 | 21 | 156 | loose |
| Tory Lanez | Someone Else (Lost Tapes 2015) | 25 | 20 | 78 | loose |
| Tory Lanez | Sorry 4 What? // LV BELT | 39 | 53 | 163 | loose |
| Tory Lanez | Sorry But I Had To... | 114 | 93 | 899 | loose |
| Tory Lanez | Spaceship | 27 | 8 | 95 | loose |
| Tory Lanez | Spain | 56 | 61 | 340 | loose |
| Tory Lanez | Speaking Tongues | 66 | 61 | 587 | loose |
| Tory Lanez | Special 4 U | 36 | 23 | 52 | loose |
| Tory Lanez | Spend It (Freestyle) | 88 | 54 | 388 | loose |
| Tory Lanez | Spin Around | 29 | 27 | 131 | loose |
| Tory Lanez | Splash.Wave.Repeat (Interlude) | 17 | 4 | 125 | loose |
| Tory Lanez | Staccato | 44 | 68 | 265 | loose |
| Tory Lanez | Stay Down | 54 | 41 | 143 | loose |
| Tory Lanez | Stay Schemin (Freestyle) | 74 | 66 | 427 | loose |
| Tory Lanez | Steady | 29 | 26 | 181 | loose |
| Tory Lanez | Step Yo Game Up | 92 | 80 | 503 | loose |
| Tory Lanez | Still Be Friends | 55 | 47 | 255 | loose |
| Tory Lanez | Still Cute | 37 | 11 | 151 | loose |
| Tory Lanez | Still Waiting | 82 | 83 | 321 | loose |
| Tory Lanez | Stitch Me Up | 28 | 12 | 55 | loose |
| Tory Lanez | Stolen Hearts | 22 | 11 | 187 | loose |
| Tory Lanez | Streets Want You Back | 16 | 1 | 37 | loose |
| Tory Lanez | Stripclub Las Vegas | 27 | 8 | 101 | loose |
| Tory Lanez | Stuck Behind the Wall (Lost Tapes 2022) | 23 | 19 | 144 | loose |
| Tory Lanez | Stuck On You | 31 | 8 | 82 | loose |
| Tory Lanez | Stuck With It | 33 | 18 | 152 | loose |
| Tory Lanez | Stuck on U | 9 | 2 | 41 | loose |
| Tory Lanez | Stupid Again | 69 | 75 | 289 | loose |
| Tory Lanez | Stupido | 51 | 34 | 265 | loose |
| Tory Lanez | Styll | 53 | 32 | 327 | loose |
| Tory Lanez | Suge (Remix) | 185 | 231 | 1857 | loose |
| Tory Lanez | Summer Love | 61 | 33 | 375 | loose |
| Tory Lanez | Summer Rain (Lost Tapes 2017) | 14 | 7 | 32 | loose |
| Tory Lanez | Summertime* | 14 | 2 | 27 | loose |
| Tory Lanez | Summin | 31 | 13 | 227 | loose |
| Tory Lanez | Summin Part II | 18 | 7 | 77 | loose |
| Tory Lanez | Sună | 34 | 19 | 209 | loose |
| Tory Lanez | Super Freak | 41 | 52 | 180 | loose |
| Tory Lanez | Super High | 42 | 54 | 219 | loose |
| Tory Lanez | Swag Get At You | 52 | 31 | 300 | loose |
| Tory Lanez | Swangin’ | 15 | 5 | 64 | loose |
| Tory Lanez | Swavey | 39 | 31 | 228 | loose |
| Tory Lanez | Sweat It Out (Lost Tapes 2019) | 28 | 27 | 90 | loose |
| Tory Lanez | T Dot Girls | 8 | 6 | 26 | loose |
| Tory Lanez | T.D.F x LA County Jail | 51 | 40 | 461 | loose |
| Tory Lanez | T.L.C. | 41 | 13 | 177 | loose |
| Tory Lanez | TABBY CAT | 40 | 37 | 395 | loose |
| Tory Lanez | TAlk tO Me | 33 | 19 | 103 | loose |
| Tory Lanez | TAlk tO Me (Remix) Extended Version | 34 | 32 | 232 | loose |
| Tory Lanez | TB’s Interlude *LIVE PHONE RECORDING* | 21 | 17 | 77 | loose |
| Tory Lanez | TELL ME | 68 | 61 | 210 | loose |
| Tory Lanez | TGIF (Lost Tapes 2022) | 23 | 6 | 60 | loose |
| Tory Lanez | TOAST | 48 | 17 | 266 | loose |
| Tory Lanez | TOCA (Lost Tapes 2017) | 13 | 4 | 38 | loose |
| Tory Lanez | TOUCHDOWN | 53 | 53 | 275 | loose |
| Tory Lanez | Take It Off (Lost Tapes 2022) | 31 | 17 | 130 | loose |
| Tory Lanez | Take Me With You | 19 | 13 | 49 | loose |
| Tory Lanez | Take Shots | 54 | 29 | 344 | loose |
| Tory Lanez | Take a Minute (Lost Tapes 2022) | 14 | 17 | 98 | loose |
| Tory Lanez | Taken Care | 21 | 5 | 80 | loose |
| Tory Lanez | Taken x G Party | 28 | 17 | 189 | loose |
| Tory Lanez | Talk To Me Remix (Tory Lanez) | 23 | 28 | 47 | loose |
| Tory Lanez | Talk on Road | 26 | 7 | 89 | loose |
| Tory Lanez | Talk to Me Nice / Fargo Season | 98 | 74 | 467 | loose |
| Tory Lanez | Talk to Me Nice / Real Money | 17 | 19 | 73 | loose |
| Tory Lanez | Tax | 49 | 30 | 176 | loose |
| Tory Lanez | Tek Weh Yuh Heart | 31 | 28 | 130 | loose |
| Tory Lanez | Telephone | 28 | 16 | 122 | loose |
| Tory Lanez | Tell Me How You Feel | 39 | 21 | 112 | loose |
| Tory Lanez | Temperature Rising | 21 | 2 | 42 | loose |
| Tory Lanez | Teyana (Lost Tapes 2013) | 43 | 22 | 104 | loose |
| Tory Lanez | ThE RUn oFF | 34 | 34 | 173 | loose |
| Tory Lanez | Tha Six | 33 | 30 | 94 | loose |
| Tory Lanez | Thank You Mama | 37 | 12 | 156 | loose |
| Tory Lanez | That Often (Too Often) | 37 | 31 | 146 | loose |
| Tory Lanez | The Bubble (Lost Tapes 2022) | 25 | 30 | 88 | loose |
| Tory Lanez | The Chase (Lost Tapes 2022) | 39 | 28 | 404 | loose |
| Tory Lanez | The Coldest Playboy | 32 | 25 | 178 | loose |
| Tory Lanez | The Color Violet | 26 | 17 | 138 | loose |
| Tory Lanez | The Cry | 75 | 33 | 292 | loose |
| Tory Lanez | The Doowop Kid (Interlude) | 16 | 3 | 27 | loose |
| Tory Lanez | The Fargo Splash | 96 | 68 | 390 | loose |
| Tory Lanez | The Godfather | 66 | 49 | 327 | loose |
| Tory Lanez | The Hate of Friends | 17 | 10 | 124 | loose |
| Tory Lanez | The Making | 58 | 61 | 363 | loose |
| Tory Lanez | The Mission | 46 | 28 | 287 | loose |
| Tory Lanez | The Mission - Live From Spotify House | 16 | 8 | 71 | loose |
| Tory Lanez | The Morning After | 19 | 1 | 46 | loose |
| Tory Lanez | The Most High | 62 | 56 | 271 | loose |
| Tory Lanez | The Motto (Freestyle) | 51 | 31 | 327 | loose |
| Tory Lanez | The One | 16 | 11 | 68 | loose |
| Tory Lanez | The Over Song | 54 | 40 | 192 | loose |
| Tory Lanez | The Plan (Lost Tapes 2016) | 32 | 12 | 144 | loose |
| Tory Lanez | The Prequel | 49 | 38 | 399 | loose |
| Tory Lanez | The Same | 8 | 4 | 37 | loose |
| Tory Lanez | The Serve (It) Anthem | 42 | 30 | 267 | loose |
| Tory Lanez | The Take | 52 | 53 | 227 | loose |
| Tory Lanez | The Trade | 43 | 29 | 180 | loose |
| Tory Lanez | The Valley (Lost Tapes 2022) | 20 | 11 | 133 | loose |
| Tory Lanez | The Vent | 57 | 54 | 429 | loose |
| Tory Lanez | The Weekend | 42 | 21 | 107 | loose |
| Tory Lanez | Them Days | 30 | 27 | 101 | loose |
| Tory Lanez | They Don’t Know | 35 | 21 | 96 | loose |
| Tory Lanez | Thing For You | 9 | 5 | 37 | loose |
| Tory Lanez | Things I Should of Said | 25 | 17 | 86 | loose |
| Tory Lanez | This Ain’t Working | 75 | 67 | 390 | loose |
| Tory Lanez | Thoughts | 50 | 31 | 158 | loose |
| Tory Lanez | Thrill (The Sun)* | 35 | 21 | 33 | loose |
| Tory Lanez | Throw Myself A Party | 45 | 32 | 163 | loose |
| Tory Lanez | Throw Myself a Party [Explicit] | 23 | 13 | 119 | loose |
| Tory Lanez | Tic Toc | 29 | 41 | 240 | loose |
| Tory Lanez | Till It’s All Gone | 51 | 31 | 140 | loose |
| Tory Lanez | Tim Duncan (Lost Tapes 2015) | 86 | 48 | 362 | loose |
| Tory Lanez | Time (Lost Tapes 2016) | 22 | 13 | 113 | loose |
| Tory Lanez | Time Away (Lost Tapes 2019) | 18 | 27 | 118 | loose |
| Tory Lanez | Time Flies (Original) | 32 | 18 | 129 | loose |
| Tory Lanez | To D.R.E.A.M. | 62 | 47 | 372 | loose |
| Tory Lanez | Toca Tuesday Freestyle | 30 | 11 | 119 | loose |
| Tory Lanez | Tommie’s Interlude (Lost Tapes 2019) | 48 | 35 | 262 | loose |
| Tory Lanez | Tonight | 23 | 11 | 86 | loose |
| Tory Lanez | Too Hot | 25 | 18 | 114 | loose |
| Tory Lanez | Too Turnt* | 9 | 5 | 27 | loose |
| Tory Lanez | Top Down Rolling* | 29 | 29 | 112 | loose |
| Tory Lanez | Top of the World | 55 | 38 | 227 | loose |
| Tory Lanez | Topless in Miami (Lost Tapes 2016) | 17 | 6 | 36 | loose |
| Tory Lanez | Tory Lanez & Adin Ross Freestyle | 153 | 113 | 703 | loose |
| Tory Lanez | Tory Lanez (2017) | Funk Flex | #Freestyle086 | 193 | 228 | 1346 | loose |
| Tory Lanez | Tory Lanez (2021) | Funk Flex | #Freestyle162 | 119 | 151 | 1091 | loose |
| Tory Lanez | Tory Lanez Freestyle on Sway in the Morning, Pt. 1 (2015) | 84 | 89 | 592 | loose |
| Tory Lanez | Tory Lanez Freestyle on Sway in the Morning, Pt. 2 (2016) | 123 | 125 | 819 | loose |
| Tory Lanez | Tory Lanez | Five Fingers Of Death (2018) | 170 | 165 | 1455 | loose |
| Tory Lanez | Toxicodendron (Poison Ivy) | 14 | 5 | 29 | loose |
| Tory Lanez | Transaction (Lost Tapes 2022) | 27 | 9 | 199 | loose |
| Tory Lanez | Traphouse | 35 | 32 | 193 | loose |
| Tory Lanez | Trust (Remix) | 46 | 62 | 309 | loose |
| Tory Lanez | Trust Nobody | 34 | 34 | 139 | loose |
| Tory Lanez | Tuh | 104 | 109 | 630 | loose |
| Tory Lanez | Turn Back Time (Twitch Tapes) | 20 | 22 | 123 | loose |
| Tory Lanez | Turn It Back | 30 | 18 | 144 | loose |
| Tory Lanez | Twitch Intro (Low Rider/Shawty Got My Soul) | 7 | 2 | 2 | loose |
| Tory Lanez | U.N.I.T.Y. | 23 | 10 | 107 | loose |
| Tory Lanez | UN DÍA (ONE DAY) | 48 | 17 | 298 | loose |
| Tory Lanez | UN DÍA (ONE DAY) [Demo] | 24 | 7 | 99 | loose |
| Tory Lanez | Uber Everywhere | 46 | 47 | 251 | loose |
| Tory Lanez | Un Dia (One Day) | 12 | 6 | 67 | loose |
| Tory Lanez | Undecided (Lost Tapes 2022) | 44 | 45 | 291 | loose |
| Tory Lanez | Understand | 38 | 45 | 198 | loose |
| Tory Lanez | Undo | 20 | 16 | 96 | loose |
| Tory Lanez | Unforgetful | 50 | 51 | 154 | loose |
| Tory Lanez | Unstoppable Freestyle | 31 | 19 | 159 | loose |
| Tory Lanez | Up (Fell In Love) | 58 | 27 | 250 | loose |
| Tory Lanez | Upgraded Rolex | 30 | 13 | 109 | loose |
| Tory Lanez | Vamos a Bailar | 39 | 69 | 263 | loose |
| Tory Lanez | Variables (Lost Tapes 2022) | 36 | 62 | 374 | loose |
| Tory Lanez | Verdict Day x Lawyer Fees Interlude | 79 | 70 | 471 | loose |
| Tory Lanez | Victoria | 37 | 45 | 224 | loose |
| Tory Lanez | Visa | 36 | 35 | 70 | loose |
| Tory Lanez | Voices (Lost Tapes 2021) | 72 | 82 | 689 | loose |
| Tory Lanez | Vybez | 38 | 55 | 97 | loose |
| Tory Lanez | W | 24 | 41 | 150 | loose |
| Tory Lanez | WHATS POPPIN (Remix) | 114 | 148 | 502 | loose |
| Tory Lanez | Wait | 34 | 24 | 121 | loose |
| Tory Lanez | Wait For Me | 24 | 12 | 43 | loose |
| Tory Lanez | Wait For You (Freestyle) | 46 | 77 | 317 | loose |
| Tory Lanez | Walked Out | 27 | 9 | 89 | loose |
| Tory Lanez | Wanna Fxck (Lost Tapes 2022) | 18 | 22 | 141 | loose |
| Tory Lanez | Wanted More (Lost Tapes 2016) | 19 | 15 | 75 | loose |
| Tory Lanez | Warchild | 25 | 12 | 83 | loose |
| Tory Lanez | Watch for Your Soul | 41 | 57 | 394 | loose |
| Tory Lanez | Watching You | 30 | 17 | 234 | loose |
| Tory Lanez | Way Too Drunk* | 11 | 8 | 37 | loose |
| Tory Lanez | We Can | 46 | 31 | 256 | loose |
| Tory Lanez | We Just Ride | 35 | 16 | 270 | loose |
| Tory Lanez | We Made It | 58 | 63 | 388 | loose |
| Tory Lanez | We On Our Way | 34 | 49 | 220 | loose |
| Tory Lanez | We Outside | 40 | 44 | 235 | loose |
| Tory Lanez | Weekend | 28 | 15 | 55 | loose |
| Tory Lanez | Westwood Crib Session Freestyle | 109 | 70 | 686 | loose |
| Tory Lanez | What Happened To The Kids | 51 | 70 | 373 | loose |
| Tory Lanez | What Sucks About Love | 40 | 29 | 68 | loose |
| Tory Lanez | What You Want | 65 | 43 | 234 | loose |
| Tory Lanez | Whats Poppin Remix | 2 | 0 | 1 | loose |
| Tory Lanez | What’s Kulture ?? | 67 | 117 | 588 | loose |
| Tory Lanez | What’s Luv | 42 | 28 | 198 | loose |
| Tory Lanez | When Its Dark | 63 | 64 | 490 | loose |
| Tory Lanez | When You’re Comfortable | 32 | 19 | 101 | loose |
| Tory Lanez | Where 2 Start | 60 | 77 | 306 | loose |
| Tory Lanez | Where I’m From | 45 | 39 | 375 | loose |
| Tory Lanez | Where My Problems Go | 40 | 26 | 218 | loose |
| Tory Lanez | Wherever You Are | 36 | 25 | 121 | loose |
| Tory Lanez | White Lightning | 30 | 4 | 92 | loose |
| Tory Lanez | Who ? | 50 | 34 | 259 | loose |
| Tory Lanez | Who Needs Love | 42 | 33 | 243 | loose |
| Tory Lanez | Whole Team | 37 | 15 | 127 | loose |
| Tory Lanez | Why DON’T You LOVE me? | 55 | 71 | 178 | loose |
| Tory Lanez | Why Did I | 27 | 35 | 172 | loose |
| Tory Lanez | Wifey* | 31 | 16 | 117 | loose |
| Tory Lanez | Wild Thoughts (Remix) | 62 | 89 | 289 | loose |
| Tory Lanez | Wilona’s Workshop | 20 | 10 | 66 | loose |
| Tory Lanez | Wind Blowing (Lost Tapes 2022) | 47 | 57 | 516 | loose |
| Tory Lanez | Wind It (Remix) | 29 | 14 | 126 | loose |
| Tory Lanez | Wings | 48 | 29 | 331 | loose |
| Tory Lanez | Winnerlude | 14 | 8 | 60 | loose |
| Tory Lanez | Winning | 44 | 37 | 168 | loose |
| Tory Lanez | Wipe Me Down | 48 | 30 | 118 | loose |
| Tory Lanez | Wish I | 35 | 19 | 160 | loose |
| Tory Lanez | Wish I Never Met You (Prison Tapes) | 39 | 31 | 211 | loose |
| Tory Lanez | Wishing (Remix) | 102 | 69 | 364 | loose |
| Tory Lanez | With It / We Did It | 33 | 22 | 75 | loose |
| Tory Lanez | Woke Up | 52 | 43 | 209 | loose |
| Tory Lanez | WongTong Soup | 14 | 10 | 41 | loose |
| Tory Lanez | Woo Baby (Original) | 11 | 2 | 45 | loose |
| Tory Lanez | Wooden Beads | 48 | 52 | 310 | loose |
| Tory Lanez | Woods | 45 | 43 | 158 | loose |
| Tory Lanez | Work Sumn (Remix) | 34 | 15 | 165 | loose |
| Tory Lanez | Worth It (Remix) | 33 | 19 | 111 | loose |
| Tory Lanez | Wraith Talk | 78 | 52 | 366 | loose |
| Tory Lanez | Wrist | 39 | 37 | 237 | loose |
| Tory Lanez | Wrist Watch | 40 | 53 | 171 | loose |
| Tory Lanez | Wrong Moves | 23 | 34 | 124 | loose |
| Tory Lanez | X2 (Lost Tapes 2019) | 35 | 42 | 271 | loose |
| Tory Lanez | Y.D.L.R. | 22 | 8 | 94 | loose |
| Tory Lanez | Y.D.S // Iggy DelDia | 41 | 41 | 249 | loose |
| Tory Lanez | Ya Digg (Lost Tapes 2017) | 45 | 43 | 294 | loose |
| Tory Lanez | Yas | 24 | 22 | 228 | loose |
| Tory Lanez | Yeah Ho | 5 | 2 | 41 | loose |
| Tory Lanez | Yessirr | 53 | 34 | 196 | loose |
| Tory Lanez | YoU ThouGHt WrONg | 38 | 13 | 151 | loose |
| Tory Lanez | You | 30 | 17 | 224 | loose |
| Tory Lanez | You Ain’t Gotta Say Nothin’ | 51 | 38 | 69 | loose |
| Tory Lanez | You Choose | 36 | 30 | 130 | loose |
| Tory Lanez | You Got It Worse... | 34 | 18 | 110 | loose |
| Tory Lanez | You Shouldn’t Have | 48 | 29 | 308 | loose |
| Tory Lanez | Young Niggas | 67 | 58 | 232 | loose |
| Tory Lanez | Your Go To (Lost Tapes 2022) | 28 | 30 | 268 | loose |
| Tory Lanez | Your Love | 71 | 123 | 282 | loose |
| Tory Lanez | jes | 18 | 1 | 75 | loose |
| Tory Lanez | paint THE sky | 17 | 10 | 44 | loose |
| Tory Lanez | ’87 Stingray | 17 | 3 | 41 | loose |
| Tory Lanez | “Nobody” Land | 32 | 24 | 85 | loose |
