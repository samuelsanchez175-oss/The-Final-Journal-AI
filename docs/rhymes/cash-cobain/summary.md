# Cash Cobain rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Cash Cobain
- Songs: 364
- Bars kept (Cash Cobain lyric lines): 12821
- Section headers dropped, not counted as bars: 2
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 8
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 41
- Canonical name: Cash Cobain.
- Credit strings: Cash Cobain.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 73941
- REPEAT pairs, recorded separately: 11718
- END rhymes: 14488
- INNER rhymes: 59453

By match:

- PERFECT: 6788 (END 2277, INNER 4511)
- SLANT: 33442 (END 5947, INNER 27495)
- ASSONANCE: 32782 (END 5896, INNER 26886)
- MULTI: 929 (END 368, INNER 561)

By confidence:

- HIGH: 6959
- MED: 61363
- LOW: 5619

## Core

- Core Y: 72041
- Core N among rhyme pairs: 1900

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 35845 (48.5%)
- vowel: 32782 (44.3%)
- spelling: 4385 (5.9%)
- multi: 929 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 3 songs
- AABB: 1 songs
- loose: 360 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 5142 pairs (END 784, INNER 4358). Words: don't, know, no, go, told, hoes, don’t, though.
2. `vow:IH` — 4532 pairs (END 803, INNER 3729). Words: bitch, bitches, think, shit, really, different, give, hit.
3. `vow:EH` — 4063 pairs (END 594, INNER 3469). Words: get, when, never, sex, friends, tell, let, friend.
4. `vow:EY` — 3532 pairs (END 581, INNER 2951). Words: ain't, baby, say, way, play, make, day, stay.
5. `vow:IY` — 3112 pairs (END 646, INNER 2466). Words: see, slizzy, need, even, keep, these, feel, shawty.
6. `vow:AE` — 3011 pairs (END 704, INNER 2307). Words: can't, back, had, can, bad, damn, have, ass.
7. `vow:AH` — 2669 pairs (END 545, INNER 2124). Words: fuck, love, fuckin, what, come, one, hundred, fucked.
8. `vow:AY` — 2360 pairs (END 419, INNER 1941). Words: like, why, mind, by, high, time, die, bae.
9. `vow:AA` — 2349 pairs (END 233, INNER 2116). Words: got, want, not, wanna, talkin, top, nothin, body.
10. `slant:AA:stop` — 1990 pairs (END 266, INNER 1724). Words: got, not, want, gotta, top, stop, body, block.
11. `slant:IH:stop` — 1262 pairs (END 269, INNER 993). Words: nigga, shit, hit, dick, city, lick, big, stick.
12. `slant:IH:sib-stop` — 1206 pairs (END 207, INNER 999). Words: bitch, shit, hit, dick, niggas, nigga, miss, rich.
13. `cmu:OW` — 1128 pairs (END 262, INNER 866). Words: know, no, go, though, bro, hoe, ho, show.
14. `slant:AE:stop` — 1127 pairs (END 279, INNER 848). Words: back, bad, had, can't, act, bag, fat, mad.
15. `slant:AH:nas-stop` — 1082 pairs (END 111, INNER 971). Words: fuck, what, come, one, some, money, done, run.
16. `slant:AY:stop` — 985 pairs (END 109, INNER 876). Words: like, right, ride, night, might, outside, inside, type.
17. `slant:EH:stop` — 983 pairs (END 190, INNER 793). Words: get, said, let, better, head, wet, neck, bed.
18. `slant:AA:nas-stop` — 920 pairs (END 29, INNER 891). Words: wanna, got, want, not, mama, gonna, gotta, body.
19. `slant:EH:nas-stop` — 847 pairs (END 53, INNER 794). Words: when, get, again, let, said, m, ten, friend.
20. `vow:UW` — 719 pairs (END 249, INNER 470). Words: new, who, two, through, used, move, boo, stupid.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 527 pair sides, mostly spelling via spelling phonetic key, often with bitch (117)
- nigga — 461 pair sides, mostly spelling via spelling phonetic key, often with shit (102)
- slizzy — 455 pair sides, mostly vowel via spelling phonetic key, often with bitch (56)
- tryna — 350 pair sides, mostly spelling via spelling phonetic key, often with eat (38)
- gon — 265 pair sides, mostly spelling via spelling phonetic key, often with dont (83)
- niggas — 142 pair sides, mostly spelling via spelling phonetic key, often with nigga (83)
- shawty — 127 pair sides, mostly vowel via spelling phonetic key, often with pussy (12)
- henny — 102 pair sides, mostly vowel via spelling phonetic key, often with pussy (9)
- thot — 93 pair sides, mostly spelling via spelling phonetic key, often with not (16)
- opps — 59 pair sides, mostly vowel via spelling phonetic key, often with know (18)
- bros — 48 pair sides, mostly spelling via spelling phonetic key, often with dont (8)
- cuz — 41 pair sides, mostly spelling via spelling phonetic key, often with fuck (9)
- slatt — 39 pair sides, mostly spelling via spelling phonetic key, often with harassed (3)
- wifey — 39 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- wetty — 38 pair sides, mostly vowel via spelling phonetic key, often with pussy (5)
- baddie — 38 pair sides, mostly spelling via spelling phonetic key, often with fat (5)
- lik — 37 pair sides, mostly spelling via spelling phonetic key, often with bitch (9)
- jatty — 35 pair sides, mostly spelling via spelling phonetic key, often with fat (3)
- cuando — 32 pair sides, mostly vowel via spelling phonetic key, often with un (5)
- swag — 30 pair sides, mostly spelling via spelling phonetic key, often with bad (3)
- wock — 30 pair sides, mostly spelling via spelling phonetic key, often with dont (4)
- hol — 29 pair sides, mostly spelling via spelling phonetic key, often with old (5)
- thotty — 29 pair sides, mostly vowel via spelling phonetic key, often with dont (4)
- glizzy — 29 pair sides, mostly vowel via spelling phonetic key, often with slizzy (9)
- meds — 28 pair sides, mostly spelling via spelling phonetic key, often with dead (3)
- finna — 27 pair sides, mostly vowel via spelling phonetic key, often with nigga (10)
- blicky — 27 pair sides, mostly spelling via spelling phonetic key, often with blick (11)
- jles — 27 pair sides, mostly spelling via spelling phonetic key, often with s (6)
- neaky — 26 pair sides, mostly spelling via spelling phonetic key, often with freak (2)
- grippy — 26 pair sides, mostly spelling via spelling phonetic key, often with already (3)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Cash Cobain | 100 Hoes | 31 | 67 | 180 | loose |
| Cash Cobain | 2 PEOPLE | 25 | 14 | 95 | loose |
| Cash Cobain | 2021 Vibes | 21 | 24 | 161 | loose |
| Cash Cobain | 23 Freestyle | 45 | 111 | 126 | loose |
| Cash Cobain | 2C | 32 | 24 | 258 | loose |
| Cash Cobain | 3 Sides* | 17 | 4 | 37 | loose |
| Cash Cobain | 4Tex RMX | 65 | 71 | 517 | loose |
| Cash Cobain | 5 | 52 | 94 | 444 | loose |
| Cash Cobain | 5 Star | 22 | 28 | 83 | loose |
| Cash Cobain | 6AM Thoughts | 49 | 71 | 225 | loose |
| Cash Cobain | 7 DAYS | 36 | 59 | 177 | loose |
| Cash Cobain | 7B | 56 | 75 | 227 | loose |
| Cash Cobain | 90's Baby | 67 | 81 | 260 | loose |
| Cash Cobain | 911 | 43 | 33 | 276 | loose |
| Cash Cobain | 98 Wock | 102 | 111 | 232 | loose |
| Cash Cobain | A P* | 19 | 19 | 78 | loose |
| Cash Cobain | ALL MY LIFE IM GEEKED UP | 35 | 45 | 171 | loose |
| Cash Cobain | ALL NIGHT LONG | 43 | 47 | 164 | loose |
| Cash Cobain | ALREADY | 45 | 27 | 271 | loose |
| Cash Cobain | ASSON3000 | 54 | 94 | 321 | loose |
| Cash Cobain | ATL | 55 | 66 | 196 | loose |
| Cash Cobain | ATTITUDE | 34 | 41 | 110 | loose |
| Cash Cobain | ATTITUDE PROBLEMS | 54 | 58 | 245 | loose |
| Cash Cobain | Actually | 40 | 31 | 228 | loose |
| Cash Cobain | Air4 | 39 | 32 | 152 | loose |
| Cash Cobain | Aliens | 84 | 112 | 219 | loose |
| Cash Cobain | Alive | 46 | 103 | 109 | loose |
| Cash Cobain | All Alone | 28 | 35 | 145 | loose |
| Cash Cobain | All My Life | 31 | 42 | 108 | loose |
| Cash Cobain | All Night | 27 | 41 | 100 | loose |
| Cash Cobain | Alone | 30 | 38 | 150 | loose |
| Cash Cobain | And 3 | 44 | 47 | 188 | loose |
| Cash Cobain | BACK IT UP | 42 | 35 | 133 | loose |
| Cash Cobain | BAD | 30 | 45 | 190 | loose |
| Cash Cobain | BANG OUT | 33 | 56 | 103 | loose |
| Cash Cobain | BEAUTIFUL LADY | 38 | 92 | 65 | loose |
| Cash Cobain | BETTER* | 15 | 5 | 84 | loose |
| Cash Cobain | BLANKBOY | 18 | 8 | 65 | loose |
| Cash Cobain | BODY LANGUAGE | 29 | 21 | 132 | loose |
| Cash Cobain | BUMBAA (Remix) | 48 | 45 | 263 | loose |
| Cash Cobain | Baddies | 24 | 14 | 122 | loose |
| Cash Cobain | Badness | 39 | 32 | 213 | loose |
| Cash Cobain | Bali | 33 | 42 | 189 | loose |
| Cash Cobain | Beamers & Bentlys | 44 | 90 | 268 | loose |
| Cash Cobain | Bed Or the Floor | 44 | 79 | 206 | loose |
| Cash Cobain | Better Than You | 76 | 58 | 359 | loose |
| Cash Cobain | Big Worm | 45 | 52 | 200 | loose |
| Cash Cobain | Bigga Wick | 24 | 17 | 73 | loose |
| Cash Cobain | Birthday | 45 | 30 | 198 | loose |
| Cash Cobain | Bitcoin | 34 | 39 | 143 | loose |
| Cash Cobain | Bitter | 22 | 29 | 207 | loose |
| Cash Cobain | Body | 40 | 19 | 104 | loose |
| Cash Cobain | Body Party | 34 | 39 | 78 | loose |
| Cash Cobain | Burglary | 15 | 40 | 38 | loose |
| Cash Cobain | By My Side | 34 | 47 | 330 | loose |
| Cash Cobain | By The Way | 48 | 52 | 226 | loose |
| Cash Cobain | CASH COBELLA CHOW COBIZZY | 53 | 44 | 181 | loose |
| Cash Cobain | CHEETAH GIRL | 31 | 65 | 91 | loose |
| Cash Cobain | CORTEX | 47 | 50 | 263 | loose |
| Cash Cobain | CORTEX RMX | 37 | 49 | 157 | loose |
| Cash Cobain | CVS | 44 | 98 | 181 | loose |
| Cash Cobain | Caicos | 16 | 12 | 117 | loose |
| Cash Cobain | Calling For You | 82 | 71 | 335 | loose |
| Cash Cobain | Can U Be? | 26 | 18 | 33 | loose |
| Cash Cobain | Can We | 18 | 18 | 66 | loose |
| Cash Cobain | Cantsleep (Original Version) | 12 | 9 | 76 | loose |
| Cash Cobain | Cartel Talk | 54 | 141 | 456 | AAAA |
| Cash Cobain | Cash Cobain | 21 | 18 | 252 | loose |
| Cash Cobain | Chill baby I love you* | 57 | 55 | 223 | loose |
| Cash Cobain | Christian Dior | 41 | 70 | 176 | loose |
| Cash Cobain | Chrome Hearts | 47 | 60 | 243 | loose |
| Cash Cobain | Clocking U | 17 | 27 | 73 | loose |
| Cash Cobain | Closure | 46 | 71 | 209 | loose |
| Cash Cobain | Computer Love | 18 | 15 | 80 | loose |
| Cash Cobain | Concrete Jungle Freestyle | 24 | 20 | 231 | AABB |
| Cash Cobain | Confession | 38 | 69 | 253 | loose |
| Cash Cobain | Cortex 2 | 39 | 69 | 220 | loose |
| Cash Cobain | Cortex Freestyle | 50 | 95 | 407 | loose |
| Cash Cobain | Cortex RMX Freestyle | 55 | 58 | 288 | loose |
| Cash Cobain | D&D | 37 | 20 | 108 | loose |
| Cash Cobain | DAMN WTF | 46 | 64 | 317 | loose |
| Cash Cobain | DAMN! | 31 | 27 | 162 | loose |
| Cash Cobain | DC Girls | 16 | 14 | 79 | loose |
| Cash Cobain | DIAMONDS DANCING | 29 | 15 | 154 | loose |
| Cash Cobain | DOME PIECE | 31 | 44 | 122 | loose |
| Cash Cobain | DONT WAIT | 48 | 37 | 292 | loose |
| Cash Cobain | DRAFTBOAT_1 | 49 | 48 | 201 | loose |
| Cash Cobain | DRANK | 36 | 29 | 129 | loose |
| Cash Cobain | Daily Duppy | 96 | 140 | 816 | loose |
| Cash Cobain | Daylight | 34 | 47 | 155 | loose |
| Cash Cobain | Defense | 37 | 28 | 232 | loose |
| Cash Cobain | Don’t Care No More | 32 | 23 | 192 | loose |
| Cash Cobain | Draft-Day | 39 | 22 | 97 | loose |
| Cash Cobain | Drippy | 46 | 38 | 91 | loose |
| Cash Cobain | Dying Over Me | 23 | 26 | 101 | loose |
| Cash Cobain | ELMO | 30 | 24 | 116 | loose |
| Cash Cobain | Elon Musk | 54 | 91 | 188 | loose |
| Cash Cobain | Enough Is Enough | 8 | 5 | 63 | loose |
| Cash Cobain | Etsy (41Slizzy) | 51 | 67 | 191 | loose |
| Cash Cobain | FAVORITE LADY (Remix) | 28 | 22 | 126 | loose |
| Cash Cobain | FED UP & HAD IT | 19 | 16 | 88 | loose |
| Cash Cobain | FREAK OF DI WEEK | 44 | 36 | 160 | loose |
| Cash Cobain | FRIDAY | 46 | 22 | 212 | loose |
| Cash Cobain | Face2Face | 27 | 59 | 168 | loose |
| Cash Cobain | Fairy* | 22 | 29 | 124 | loose |
| Cash Cobain | Faith | 40 | 114 | 168 | loose |
| Cash Cobain | Fast Route | 34 | 30 | 174 | loose |
| Cash Cobain | Feeeeeeeeel | 25 | 0 | 74 | loose |
| Cash Cobain | Feeeeeeeeel - A COLORS SHOW | 5 | 0 | 12 | loose |
| Cash Cobain | Feeling You Now | 52 | 29 | 211 | loose |
| Cash Cobain | Fires | 36 | 52 | 201 | loose |
| Cash Cobain | Fisherrr (Remix) | 36 | 46 | 254 | loose |
| Cash Cobain | Flashing Lights* | 16 | 11 | 29 | loose |
| Cash Cobain | Flex/Bad Bitch | 44 | 43 | 130 | loose |
| Cash Cobain | For Us | 22 | 16 | 139 | loose |
| Cash Cobain | For What | 38 | 26 | 92 | loose |
| Cash Cobain | Freak | 4 | 1 | 19 | loose |
| Cash Cobain | Full service | 4 | 0 | 10 | loose |
| Cash Cobain | GMT | 45 | 42 | 117 | loose |
| Cash Cobain | GOOD NANI | 36 | 27 | 213 | loose |
| Cash Cobain | GOODFELLAS | 26 | 19 | 179 | loose |
| Cash Cobain | GRIMEY | 36 | 43 | 112 | loose |
| Cash Cobain | Georgia | 16 | 16 | 41 | loose |
| Cash Cobain | Get Home | 34 | 29 | 160 | loose |
| Cash Cobain | Get You Back | 69 | 78 | 296 | loose |
| Cash Cobain | Go Get It | 23 | 26 | 218 | loose |
| Cash Cobain | Gold | 7 | 3 | 30 | loose |
| Cash Cobain | Gotta Get U | 33 | 36 | 107 | loose |
| Cash Cobain | Grippy | 88 | 85 | 445 | loose |
| Cash Cobain | HATE U DELILAH | 63 | 107 | 226 | loose |
| Cash Cobain | Higher | 29 | 20 | 48 | loose |
| Cash Cobain | Hoeisha | 14 | 11 | 49 | loose |
| Cash Cobain | Hoes Be Mad | 24 | 25 | 65 | loose |
| Cash Cobain | Hold Me Tight (Demo) | 10 | 10 | 35 | loose |
| Cash Cobain | Hostile | 31 | 33 | 103 | loose |
| Cash Cobain | I Cant Help It | 4 | 0 | 16 | loose |
| Cash Cobain | I Can’t Help It | 59 | 78 | 308 | loose |
| Cash Cobain | I DID IT | 22 | 10 | 24 | loose |
| Cash Cobain | I DONT KNOW/THROWIN 100S | 26 | 4 | 132 | loose |
| Cash Cobain | I Just Wanna | 33 | 20 | 176 | loose |
| Cash Cobain | I Love You A Lot | 15 | 8 | 83 | loose |
| Cash Cobain | I Need A Girl | 40 | 56 | 219 | loose |
| Cash Cobain | I Remember | 46 | 47 | 108 | loose |
| Cash Cobain | I Wanna Rock | 39 | 30 | 271 | loose |
| Cash Cobain | ICE AGE | 42 | 39 | 215 | loose |
| Cash Cobain | IDC | 46 | 40 | 236 | loose |
| Cash Cobain | IMMA MAKE U CUM | 35 | 18 | 149 | loose |
| Cash Cobain | IMU | 54 | 67 | 232 | loose |
| Cash Cobain | Idk her | 64 | 38 | 120 | loose |
| Cash Cobain | In the Morning | 24 | 26 | 126 | loose |
| Cash Cobain | Intro | 7 | 0 | 16 | loose |
| Cash Cobain | Irreplaceable | 47 | 44 | 158 | loose |
| Cash Cobain | It’s Never Real* | 26 | 7 | 109 | loose |
| Cash Cobain | I’m in love with you girl | 7 | 1 | 10 | loose |
| Cash Cobain | JENNI | 56 | 64 | 123 | loose |
| Cash Cobain | JHOLIDAY | 51 | 64 | 228 | loose |
| Cash Cobain | JHOLIDAY 2 | 48 | 96 | 267 | loose |
| Cash Cobain | JUST BLICK IT | 27 | 42 | 50 | loose |
| Cash Cobain | Jodeci (Remix) | 53 | 68 | 142 | loose |
| Cash Cobain | Keep Going | 34 | 38 | 88 | loose |
| Cash Cobain | Kick It | 54 | 89 | 252 | loose |
| Cash Cobain | Krush On You | 55 | 56 | 85 | loose |
| Cash Cobain | LET IT SNOW | 23 | 20 | 290 | loose |
| Cash Cobain | LICK HER NO CHASER (BONUS) | 30 | 38 | 142 | loose |
| Cash Cobain | LINE YOU | 36 | 44 | 128 | loose |
| Cash Cobain | LOTUS FLOWER BOMB | 28 | 23 | 184 | loose |
| Cash Cobain | Last Night | 41 | 52 | 166 | loose |
| Cash Cobain | Let Me Hold You | 40 | 41 | 167 | loose |
| Cash Cobain | Lexy Sove | 36 | 47 | 172 | loose |
| Cash Cobain | Lifted | 47 | 38 | 116 | loose |
| Cash Cobain | Love & Tequila | 27 | 20 | 56 | loose |
| Cash Cobain | Love Me* | 11 | 6 | 33 | loose |
| Cash Cobain | Lovers & Friends (Intro) | 54 | 73 | 256 | loose |
| Cash Cobain | MAD GOOD | 33 | 62 | 144 | loose |
| Cash Cobain | MADeMYWEEK | 28 | 28 | 162 | loose |
| Cash Cobain | MARNI | 20 | 42 | 207 | loose |
| Cash Cobain | MONEY GON DANCE* | 24 | 6 | 93 | loose |
| Cash Cobain | MOROCCO | 41 | 38 | 156 | loose |
| Cash Cobain | Mad Bitches | 24 | 44 | 85 | loose |
| Cash Cobain | Melrose (Bail Me Out) | 36 | 52 | 93 | loose |
| Cash Cobain | Messy | 31 | 26 | 128 | loose |
| Cash Cobain | More than a kill* | 9 | 5 | 39 | loose |
| Cash Cobain | Murder on my Mind | 33 | 67 | 137 | loose |
| Cash Cobain | My Everything | 27 | 26 | 116 | loose |
| Cash Cobain | MyBaeMyLove | 19 | 30 | 111 | loose |
| Cash Cobain | NDA | 43 | 53 | 280 | loose |
| Cash Cobain | NEW PENTHOUSE | 47 | 73 | 274 | loose |
| Cash Cobain | NIGHTS | 31 | 29 | 163 | loose |
| Cash Cobain | NINA | 22 | 27 | 97 | loose |
| Cash Cobain | NOBODY | 48 | 49 | 211 | loose |
| Cash Cobain | NOW THIS | 53 | 54 | 131 | loose |
| Cash Cobain | NSG | 41 | 73 | 116 | loose |
| Cash Cobain | NYC to Chi-Raq | 45 | 45 | 263 | loose |
| Cash Cobain | Never Knew Luv | 35 | 22 | 81 | loose |
| Cash Cobain | Nice N Slow | 29 | 55 | 163 | loose |
| Cash Cobain | Nice to meet you | 34 | 25 | 208 | loose |
| Cash Cobain | No More | 46 | 54 | 259 | loose |
| Cash Cobain | No Regular Artist | 33 | 42 | 129 | loose |
| Cash Cobain | No Tears | 19 | 7 | 104 | loose |
| Cash Cobain | Not My Problem* | 16 | 5 | 57 | loose |
| Cash Cobain | Not No Xanax 2 | 40 | 38 | 153 | loose |
| Cash Cobain | Nothing Last Forever | 33 | 31 | 147 | loose |
| Cash Cobain | Nothing to Something | 49 | 78 | 162 | loose |
| Cash Cobain | ORGASM | 34 | 52 | 97 | loose |
| Cash Cobain | Off the Radar | 29 | 15 | 79 | loose |
| Cash Cobain | Old U | 25 | 21 | 98 | loose |
| Cash Cobain | On It | 22 | 10 | 49 | loose |
| Cash Cobain | On The Radar Freestyle | 49 | 49 | 237 | loose |
| Cash Cobain | One By One | 41 | 56 | 391 | loose |
| Cash Cobain | One By One - A COLORS SHOW | 11 | 8 | 95 | loose |
| Cash Cobain | Onthatbullshit | 20 | 8 | 44 | loose |
| Cash Cobain | P4M2 | 49 | 93 | 296 | loose |
| Cash Cobain | PATTY CAKE | 39 | 62 | 402 | loose |
| Cash Cobain | PIMPIN AINT EASY | 30 | 39 | 70 | loose |
| Cash Cobain | PLAYA / IGHTY | 24 | 28 | 179 | loose |
| Cash Cobain | PUT IT UP | 24 | 26 | 128 | loose |
| Cash Cobain | Pack U Up | 26 | 39 | 102 | loose |
| Cash Cobain | Parlay | 15 | 8 | 73 | loose |
| Cash Cobain | Past Tense* | 15 | 15 | 81 | loose |
| Cash Cobain | Peach Dream | 30 | 6 | 95 | loose |
| Cash Cobain | Peach dreams | 5 | 1 | 17 | loose |
| Cash Cobain | Plug In The Kitchen | 85 | 125 | 312 | loose |
| Cash Cobain | Pon De River | 22 | 24 | 123 | loose |
| Cash Cobain | Poppin | 36 | 25 | 160 | loose |
| Cash Cobain | Pradabae | 14 | 20 | 79 | loose |
| Cash Cobain | Pray 4 Us | 61 | 82 | 182 | loose |
| Cash Cobain | Pressure | 46 | 52 | 171 | loose |
| Cash Cobain | Pretty & Sexy | 37 | 49 | 175 | loose |
| Cash Cobain | Problem Freestyle | 27 | 25 | 174 | loose |
| Cash Cobain | Pull It | 5 | 0 | 15 | loose |
| Cash Cobain | Pussy Is A Drug | 15 | 27 | 24 | loose |
| Cash Cobain | ROLLIN | 36 | 52 | 115 | loose |
| Cash Cobain | RYDA | 56 | 26 | 161 | loose |
| Cash Cobain | Road Kill | 37 | 65 | 162 | loose |
| Cash Cobain | Rock It* | 51 | 43 | 298 | loose |
| Cash Cobain | Rump | 34 | 31 | 148 | loose |
| Cash Cobain | Rump [Mixed] | 4 | 0 | 12 | loose |
| Cash Cobain | SHAKIN IT | 38 | 47 | 316 | loose |
| Cash Cobain | SHE F BOBBY | 41 | 74 | 145 | loose |
| Cash Cobain | SHE KNOW | 16 | 24 | 37 | loose |
| Cash Cobain | SHOT O’CLOCK | 45 | 36 | 183 | loose |
| Cash Cobain | SLIZZY LIKE | 28 | 25 | 125 | loose |
| Cash Cobain | SOMEBODY LOVES ME PT. 2 | 39 | 56 | 138 | loose |
| Cash Cobain | SOMETIMES / CLOSE THE DOOR | 15 | 6 | 28 | loose |
| Cash Cobain | STARTED* | 35 | 29 | 320 | loose |
| Cash Cobain | STOP THE ACT | 23 | 38 | 152 | loose |
| Cash Cobain | SWAG | 18 | 10 | 78 | loose |
| Cash Cobain | SWISH / USE 2 | 49 | 56 | 229 | loose |
| Cash Cobain | Sarah’s Interlude | 42 | 37 | 164 | loose |
| Cash Cobain | Saythatyouloveme | 48 | 54 | 118 | loose |
| Cash Cobain | Send the Addy | 49 | 64 | 187 | loose |
| Cash Cobain | Sexiest Soul | 48 | 40 | 190 | loose |
| Cash Cobain | Sexy Drill | 48 | 72 | 142 | loose |
| Cash Cobain | Sexy This Is Not a Drill | 43 | 40 | 158 | loose |
| Cash Cobain | Shoot Up Your Block | 22 | 33 | 117 | loose |
| Cash Cobain | Sick n Tired | 19 | 13 | 135 | loose |
| Cash Cobain | Slizzy Dialogue | 56 | 64 | 202 | loose |
| Cash Cobain | Slizzy Flow | 61 | 86 | 229 | loose |
| Cash Cobain | Slizzy Gods | 24 | 17 | 62 | loose |
| Cash Cobain | Slizzy Like Remix | 22 | 9 | 202 | loose |
| Cash Cobain | Slizzy Physical | 27 | 35 | 147 | loose |
| Cash Cobain | Slizzy Talk | 39 | 39 | 173 | loose |
| Cash Cobain | Slutie | 33 | 32 | 130 | loose |
| Cash Cobain | So Fire | 20 | 28 | 86 | loose |
| Cash Cobain | Sorry (Stop, Go) | 17 | 34 | 172 | loose |
| Cash Cobain | Special needs | 19 | 13 | 74 | loose |
| Cash Cobain | Stay Cool | 41 | 43 | 120 | loose |
| Cash Cobain | Stop The Violence* | 11 | 7 | 95 | loose |
| Cash Cobain | Sunday | 29 | 19 | 348 | loose |
| Cash Cobain | Super Bizzy | 39 | 41 | 121 | loose |
| Cash Cobain | TALK DAT WALK DAT | 33 | 22 | 123 | loose |
| Cash Cobain | THANKSGIVING / MY BITCHES SHOOT TOO | 30 | 77 | 275 | loose |
| Cash Cobain | THAT’S HARD | 26 | 26 | 62 | loose |
| Cash Cobain | THE POET | 48 | 95 | 244 | loose |
| Cash Cobain | THIS AINT HIGHSCHOOL* | 24 | 26 | 128 | loose |
| Cash Cobain | TOP OF THE MORNING | 54 | 34 | 190 | loose |
| Cash Cobain | TRICK | 5 | 1 | 20 | loose |
| Cash Cobain | TRY ME | 3 | 2 | 6 | loose |
| Cash Cobain | Talk About It | 49 | 64 | 271 | loose |
| Cash Cobain | Tezzus & diamond* | 70 | 72 | 242 | loose |
| Cash Cobain | The Coolest (3 Sides) | 38 | 44 | 189 | loose |
| Cash Cobain | The Moment | 29 | 47 | 150 | loose |
| Cash Cobain | The Sound or Drown “On The Radar” Freestyle | 8 | 0 | 23 | loose |
| Cash Cobain | Time Line | 32 | 15 | 94 | loose |
| Cash Cobain | To The Beat | 61 | 96 | 164 | loose |
| Cash Cobain | Too Geeked* | 29 | 41 | 182 | loose |
| Cash Cobain | Too good to be true | 18 | 11 | 84 | loose |
| Cash Cobain | Took a While | 27 | 19 | 87 | loose |
| Cash Cobain | Top Ten | 13 | 10 | 56 | loose |
| Cash Cobain | Trench Baby | 27 | 56 | 303 | loose |
| Cash Cobain | Trench Warfare | 48 | 46 | 180 | loose |
| Cash Cobain | Trippin on a Yacht | 55 | 96 | 198 | loose |
| Cash Cobain | Trump Tower | 79 | 124 | 415 | loose |
| Cash Cobain | Tuci | 34 | 30 | 174 | loose |
| Cash Cobain | Turks and Caicos | 38 | 42 | 142 | loose |
| Cash Cobain | Twi$ted | 58 | 51 | 309 | loose |
| Cash Cobain | Twi$ted, Pt. 2 | 64 | 86 | 301 | loose |
| Cash Cobain | Ugly | 20 | 3 | 125 | loose |
| Cash Cobain | Uh Oh | 7 | 13 | 46 | AAAA |
| Cash Cobain | Unbelievable | 31 | 23 | 78 | loose |
| Cash Cobain | Up Right Now | 56 | 36 | 274 | loose |
| Cash Cobain | VACANT | 36 | 49 | 191 | loose |
| Cash Cobain | Video Soul | 28 | 39 | 197 | loose |
| Cash Cobain | W33zy | 33 | 33 | 163 | loose |
| Cash Cobain | WATERGUN | 54 | 32 | 217 | loose |
| Cash Cobain | WAVY LADY | 29 | 37 | 118 | loose |
| Cash Cobain | WAVY LADY 2 | 27 | 30 | 164 | loose |
| Cash Cobain | WH0LE R00M | 36 | 18 | 151 | loose |
| Cash Cobain | WHAT’S THE WORD | 30 | 76 | 274 | loose |
| Cash Cobain | WHITE LINES | 23 | 9 | 59 | loose |
| Cash Cobain | WHITE LINES [V13] | 16 | 6 | 53 | loose |
| Cash Cobain | WHO U THINK? | 47 | 54 | 111 | loose |
| Cash Cobain | WITH YOU | 23 | 12 | 75 | loose |
| Cash Cobain | WIZZAS IN PARIS | 53 | 82 | 180 | loose |
| Cash Cobain | WYLIN | 23 | 43 | 98 | loose |
| Cash Cobain | Wait Until | 14 | 12 | 94 | loose |
| Cash Cobain | Walking on Water | 39 | 19 | 155 | loose |
| Cash Cobain | Ways | 28 | 28 | 148 | loose |
| Cash Cobain | What I’m On | 31 | 20 | 128 | loose |
| Cash Cobain | What NYC Sounds Like | 70 | 51 | 286 | loose |
| Cash Cobain | Whole Room | 8 | 6 | 13 | loose |
| Cash Cobain | Wish | 47 | 29 | 292 | loose |
| Cash Cobain | Woah* | 19 | 23 | 54 | loose |
| Cash Cobain | Wocky My Lover | 67 | 82 | 468 | loose |
| Cash Cobain | Worldwide Sniper | 42 | 31 | 120 | loose |
| Cash Cobain | X FCKED IT UP FOR THE BIRKINS | 46 | 57 | 235 | loose |
| Cash Cobain | XXL Freshman Freestyle: Cash Cobain | 5 | 1 | 29 | loose |
| Cash Cobain | XXL Freshmen 2024 Cypher - Part 2 | 105 | 114 | 850 | loose |
| Cash Cobain | Yellow Service | 13 | 4 | 56 | loose |
| Cash Cobain | Yellow Tears | 24 | 47 | 116 | loose |
| Cash Cobain | Yessir | 23 | 46 | 189 | AAAA |
| Cash Cobain | You Belong* | 10 | 7 | 56 | loose |
| Cash Cobain | act bad twin! | 71 | 37 | 259 | loose |
| Cash Cobain | act like | 24 | 27 | 131 | loose |
| Cash Cobain | advance w her! | 45 | 47 | 222 | loose |
| Cash Cobain | cant do it again* | 25 | 48 | 148 | loose |
| Cash Cobain | copy my drip | 25 | 40 | 214 | loose |
| Cash Cobain | hopeful romantic... | 36 | 34 | 143 | loose |
| Cash Cobain | jane baby | 21 | 26 | 95 | loose |
| Cash Cobain | jeffkillergothmoney | 10 | 3 | 34 | loose |
| Cash Cobain | ms.beautiful V | 17 | 10 | 109 | loose |
| Cash Cobain | porno story! | 29 | 19 | 110 | loose |
| Cash Cobain | practice! | 20 | 9 | 198 | loose |
| Cash Cobain | problem | 149 | 72 | 513 | loose |
| Cash Cobain | rump punch | 23 | 18 | 123 | loose |
| Cash Cobain | sleepy & sheff | 49 | 80 | 218 | loose |
| Cash Cobain | slizzy’s interlude | 36 | 30 | 62 | loose |
| Cash Cobain | swag it! | 48 | 41 | 137 | loose |
| Cash Cobain | toxic | 21 | 23 | 176 | loose |
| Cash Cobain | weekend | 45 | 74 | 289 | loose |
| Cash Cobain | 󠁪all i wanna hear | 32 | 20 | 102 | loose |
| Cash Cobain | 󠁪baddest in the room | 24 | 23 | 174 | loose |
| Cash Cobain | 󠁪candle | 30 | 52 | 121 | loose |
| Cash Cobain | 󠁪cantsleep/drunkinluv | 41 | 50 | 173 | loose |
| Cash Cobain | 󠁪dunk | 34 | 24 | 139 | loose |
| Cash Cobain | 󠁪luv it | 19 | 4 | 54 | loose |
| Cash Cobain | 󠁪me n payroll | 33 | 27 | 256 | loose |
| Cash Cobain | 󠁪message to u | 22 | 37 | 57 | loose |
| Cash Cobain | 󠁪slizzy poetry (interlude) | 40 | 72 | 156 | loose |
| Cash Cobain | 󠁪slizzy poetry pt. 2 (interlude) | 32 | 43 | 175 | loose |
| Cash Cobain | 󠁪slizzyhunchodon | 54 | 88 | 318 | loose |
| Cash Cobain | 󠁪some shit | 31 | 19 | 209 | loose |
| Cash Cobain | 󠁪turks (i apologize) | 16 | 16 | 153 | loose |
| Cash Cobain | 󠁪wassup wya | 25 | 25 | 127 | loose |
