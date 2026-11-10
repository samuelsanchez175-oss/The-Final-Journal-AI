# PARTYNEXTDOOR rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: PARTYNEXTDOOR
- Songs: 312
- Bars kept (PARTYNEXTDOOR lyric lines): 10357
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 44
- Canonical name: PARTYNEXTDOOR.
- Credit strings: PARTYNEXTDOOR.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 41946
- REPEAT pairs, recorded separately: 10017
- END rhymes: 6635
- INNER rhymes: 35311

By match:

- PERFECT: 3633 (END 919, INNER 2714)
- SLANT: 17591 (END 2686, INNER 14905)
- ASSONANCE: 20259 (END 2887, INNER 17372)
- MULTI: 463 (END 143, INNER 320)

By confidence:

- HIGH: 3843
- MED: 36081
- LOW: 2022

## Core

- Core Y: 41393
- Core N among rhyme pairs: 553

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 19524 (46.5%)
- vowel: 20259 (48.3%)
- spelling: 1700 (4.1%)
- multi: 463 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- ABAB: 1 songs
- loose: 310 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 3054 pairs (END 346, INNER 2708). Words: know, don't, no, go, only, over, won't, told.
2. `vow:EY` — 2894 pairs (END 436, INNER 2458). Words: ain't, baby, say, way, make, stay, day, play.
3. `vow:EH` — 2801 pairs (END 312, INNER 2489). Words: when, get, friends, best, tell, never, let's, every.
4. `vow:IH` — 2224 pairs (END 271, INNER 1953). Words: shit, bitch, bitches, things, still, think, give, different.
5. `vow:AY` — 1941 pairs (END 380, INNER 1561). Words: like, time, mind, why, by, right, high, night.
6. `vow:IY` — 1739 pairs (END 272, INNER 1467). Words: see, need, shawty, even, keep, nobody, here, feel.
7. `vow:AH` — 1473 pairs (END 179, INNER 1294). Words: love, fuck, what, come, one, trust, something, drugs.
8. `vow:AA` — 1383 pairs (END 144, INNER 1239). Words: got, want, hard, wanna, not, nothin, party, talkin.
9. `vow:AE` — 1281 pairs (END 200, INNER 1081). Words: can't, back, can, have, had, man, ask, last.
10. `slant:AA:stop` — 838 pairs (END 96, INNER 742). Words: got, want, gotta, not, god, heart, body, party.
11. `slant:AY:stop` — 665 pairs (END 123, INNER 542). Words: like, right, night, ride, side, might, tonight, inside.
12. `cmu:OW` — 589 pairs (END 136, INNER 453). Words: know, no, go, show, low, though, slow, ho.
13. `slant:EH:nas-stop` — 557 pairs (END 37, INNER 520). Words: when, get, again, let, ready, said, better, dem.
14. `slant:IH:stop` — 554 pairs (END 63, INNER 491). Words: nigga, shit, city, hit, trip, dick, big, crib.
15. `slant:AY:nas-stop` — 526 pairs (END 106, INNER 420). Words: time, like, mine, right, night, line, might, side.
16. `slant:EH:stop` — 524 pairs (END 51, INNER 473). Words: get, said, better, let, ready, best, already, bed.
17. `slant:EY:stop` — 521 pairs (END 112, INNER 409). Words: baby, make, babe, take, ain't, wait, hate, made.
18. `vow:AW` — 521 pairs (END 173, INNER 348). Words: now, down, how, 'bout, about, around, clouds, house.
19. `slant:AA:nas-stop` — 402 pairs (END 18, INNER 384). Words: wanna, got, want, not, mama, gonna, body, gotta.
20. `slant:AH:nas-stop` — 392 pairs (END 29, INNER 363). Words: what, fuck, one, come, money, some, done, someone.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 201 pair sides, mostly spelling via spelling phonetic key, often with keep (22)
- nigga — 192 pair sides, mostly spelling via spelling phonetic key, often with niggas (42)
- shawty — 177 pair sides, mostly vowel via spelling phonetic key, often with baby (26)
- gon — 155 pair sides, mostly spelling via spelling phonetic key, often with dont (54)
- ima — 135 pair sides, mostly spelling via spelling phonetic key, often with give (16)
- niggas — 86 pair sides, mostly spelling via spelling phonetic key, often with nigga (42)
- dem — 32 pair sides, mostly spelling via spelling phonetic key, often with ready (13)
- henny — 22 pair sides, mostly vowel via spelling phonetic key, often with lonely (7)
- omo — 19 pair sides, mostly vowel via spelling phonetic key, often with go (5)
- homie — 18 pair sides, mostly spelling via spelling phonetic key, often with knowin (3)
- cuando — 18 pair sides, mostly vowel via spelling phonetic key, often with lo (3)
- imma — 16 pair sides, mostly spelling via spelling phonetic key, often with timber (3)
- nuh — 16 pair sides, mostly spelling via spelling phonetic key, often with touch (4)
- ovo — 15 pair sides, mostly vowel via spelling phonetic key, often with know (3)
- prolly — 15 pair sides, mostly vowel via spelling phonetic key, often with whole (2)
- sauga — 12 pair sides, mostly spelling via spelling phonetic key, often with taught (3)
- tings — 12 pair sides, mostly spelling via spelling phonetic key, often with ting (2)
- gyal — 12 pair sides, mostly spelling via spelling phonetic key, often with feel (3)
- kizzy — 11 pair sides, mostly vowel via spelling phonetic key, often with crazy (1)
- precio — 10 pair sides, mostly vowel via spelling phonetic key, often with lo (2)
- finna — 9 pair sides, mostly spelling via spelling phonetic key, often with bring (4)
- keisha — 9 pair sides, mostly spelling via spelling phonetic key, often with let (3)
- cuz — 9 pair sides, mostly spelling via spelling phonetic key, often with fuck (5)
- eso — 9 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- gangy — 9 pair sides, mostly vowel via spelling phonetic key, often with see (3)
- kno — 9 pair sides, mostly vowel via spelling phonetic key, often with know (6)
- miny — 9 pair sides, mostly vowel via spelling phonetic key, often with still (2)
- eeny — 9 pair sides, mostly vowel via spelling phonetic key, often with money (2)
- meeny — 9 pair sides, mostly vowel via spelling phonetic key, often with money (2)
- dalle — 9 pair sides, mostly spelling via spelling phonetic key, often with valid (5)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| PARTYNEXTDOOR | 1942 | 37 | 7 | 97 | loose |
| PARTYNEXTDOOR | 1Night | 39 | 40 | 146 | loose |
| PARTYNEXTDOOR | 2AM | 51 | 29 | 158 | loose |
| PARTYNEXTDOOR | 647 | 38 | 29 | 84 | loose |
| PARTYNEXTDOOR | 9 Months Until Next September | 17 | 10 | 91 | loose |
| PARTYNEXTDOOR | A M o t h e r’ s P r a y e r | 4 | 1 | 22 | loose |
| PARTYNEXTDOOR | ANOTHER DAY | 16 | 15 | 22 | loose |
| PARTYNEXTDOOR | Admire Me | 29 | 13 | 58 | loose |
| PARTYNEXTDOOR | All Day Long | 9 | 1 | 6 | loose |
| PARTYNEXTDOOR | All I Wanna Know | 30 | 19 | 99 | loose |
| PARTYNEXTDOOR | All To You | 24 | 18 | 29 | loose |
| PARTYNEXTDOOR | Am I Wrong* | 18 | 6 | 35 | loose |
| PARTYNEXTDOOR | BELIEVE IT | 32 | 16 | 97 | loose |
| PARTYNEXTDOOR | BUZZIN’ | 26 | 26 | 133 | loose |
| PARTYNEXTDOOR | Baby Come Back | 18 | 8 | 87 | loose |
| PARTYNEXTDOOR | Back It Up | 45 | 33 | 123 | loose |
| PARTYNEXTDOOR | Bad Intentions | 29 | 16 | 69 | loose |
| PARTYNEXTDOOR | Baddest Girl Around | 19 | 10 | 46 | loose |
| PARTYNEXTDOOR | Ballin’ | 16 | 1 | 14 | loose |
| PARTYNEXTDOOR | Belong to the City | 22 | 9 | 20 | loose |
| PARTYNEXTDOOR | Best Friends | 36 | 26 | 164 | loose |
| PARTYNEXTDOOR | Better Man | 42 | 17 | 175 | loose |
| PARTYNEXTDOOR | Blasé (Remix) | 17 | 10 | 82 | loose |
| PARTYNEXTDOOR | Born 2 Be Great | 43 | 61 | 186 | loose |
| PARTYNEXTDOOR | Bout It | 29 | 9 | 106 | loose |
| PARTYNEXTDOOR | Break From Toronto | 25 | 11 | 66 | loose |
| PARTYNEXTDOOR | Break Me Down | 49 | 23 | 134 | loose |
| PARTYNEXTDOOR | Breather | 60 | 79 | 143 | loose |
| PARTYNEXTDOOR | Bricks | 72 | 53 | 192 | loose |
| PARTYNEXTDOOR | Bring That Ass Here | 26 | 6 | 144 | loose |
| PARTYNEXTDOOR | Broken Promises | 15 | 16 | 33 | loose |
| PARTYNEXTDOOR | Brown Skin | 26 | 4 | 35 | loose |
| PARTYNEXTDOOR | Bug A Boo Roll Call (Interlude - Homecoming Live) | 14 | 2 | 13 | loose |
| PARTYNEXTDOOR | C h e e r s | 53 | 21 | 141 | loose |
| PARTYNEXTDOOR | C o n t r o l | 29 | 8 | 80 | loose |
| PARTYNEXTDOOR | CANDY | 36 | 22 | 123 | loose |
| PARTYNEXTDOOR | CELIBACY | 34 | 44 | 107 | loose |
| PARTYNEXTDOOR | CN TOWER | 56 | 82 | 286 | loose |
| PARTYNEXTDOOR | CUFFED UP | 18 | 15 | 17 | loose |
| PARTYNEXTDOOR | Call You Bae | 16 | 24 | 16 | loose |
| PARTYNEXTDOOR | Can’t Hang | 31 | 20 | 179 | loose |
| PARTYNEXTDOOR | Can’t Let The Summer Pass | 20 | 9 | 32 | loose |
| PARTYNEXTDOOR | Cartier | 55 | 63 | 172 | loose |
| PARTYNEXTDOOR | Cash Out | 41 | 38 | 190 | loose |
| PARTYNEXTDOOR | Cleveland Ohio | 9 | 2 | 32 | loose |
| PARTYNEXTDOOR | Clique’d Up | 55 | 47 | 190 | loose |
| PARTYNEXTDOOR | Codeine Bumpin’ | 19 | 15 | 37 | loose |
| PARTYNEXTDOOR | Come Thru | 40 | 20 | 158 | loose |
| PARTYNEXTDOOR | Come and See Me | 37 | 19 | 240 | loose |
| PARTYNEXTDOOR | Company | 55 | 29 | 297 | loose |
| PARTYNEXTDOOR | Crazy | 16 | 33 | 37 | AAAA |
| PARTYNEXTDOOR | Cruise Control | 25 | 13 | 134 | loose |
| PARTYNEXTDOOR | DEEPER | 22 | 23 | 102 | loose |
| PARTYNEXTDOOR | DIE TRYING | 35 | 77 | 107 | loose |
| PARTYNEXTDOOR | DON’T DO IT FOR YOU NO MORE | 26 | 20 | 101 | loose |
| PARTYNEXTDOOR | Daddy | 38 | 20 | 113 | loose |
| PARTYNEXTDOOR | Damage | 33 | 22 | 70 | loose |
| PARTYNEXTDOOR | Damn | 41 | 35 | 139 | loose |
| PARTYNEXTDOOR | Daughter | 35 | 21 | 147 | loose |
| PARTYNEXTDOOR | Days in the East | 68 | 16 | 350 | loose |
| PARTYNEXTDOOR | Days in the West | 42 | 19 | 218 | loose |
| PARTYNEXTDOOR | Deserve It | 58 | 33 | 374 | loose |
| PARTYNEXTDOOR | Disappointed* | 21 | 11 | 58 | loose |
| PARTYNEXTDOOR | Don’t Choose | 34 | 8 | 146 | loose |
| PARTYNEXTDOOR | Don’t Know How | 34 | 11 | 74 | loose |
| PARTYNEXTDOOR | Don’t Let Me Fall Asleep | 24 | 19 | 72 | loose |
| PARTYNEXTDOOR | Don’t Run | 47 | 50 | 137 | loose |
| PARTYNEXTDOOR | Don’t Tell Me | 26 | 21 | 81 | loose |
| PARTYNEXTDOOR | Don’t Wait On My Love (Savage Anthem Demo) | 13 | 8 | 36 | loose |
| PARTYNEXTDOOR | Don’t Worry | 41 | 27 | 236 | loose |
| PARTYNEXTDOOR | Down for Life | 70 | 40 | 242 | loose |
| PARTYNEXTDOOR | Dreamin | 32 | 34 | 88 | loose |
| PARTYNEXTDOOR | EYE ON IT | 18 | 5 | 44 | loose |
| PARTYNEXTDOOR | East Liberty | 21 | 9 | 70 | loose |
| PARTYNEXTDOOR | Ego | 31 | 23 | 92 | loose |
| PARTYNEXTDOOR | Elevate | 30 | 53 | 163 | loose |
| PARTYNEXTDOOR | Excitement | 25 | 11 | 70 | loose |
| PARTYNEXTDOOR | F a m i l y | 22 | 6 | 66 | loose |
| PARTYNEXTDOOR | F o r C e r t a i n | 25 | 17 | 57 | loose |
| PARTYNEXTDOOR | FREAK IN YOU | 46 | 18 | 155 | loose |
| PARTYNEXTDOOR | FWU | 45 | 18 | 160 | loose |
| PARTYNEXTDOOR | Faithful | 52 | 30 | 177 | loose |
| PARTYNEXTDOOR | Famous | 11 | 2 | 15 | loose |
| PARTYNEXTDOOR | Feel It | 25 | 8 | 72 | loose |
| PARTYNEXTDOOR | Find Your Love | 22 | 19 | 28 | loose |
| PARTYNEXTDOOR | Fortworth | 28 | 27 | 121 | loose |
| PARTYNEXTDOOR | Friends | 15 | 9 | 15 | loose |
| PARTYNEXTDOOR | Fuck Wit Me / PG | 72 | 31 | 286 | loose |
| PARTYNEXTDOOR | Fucking Fans | 50 | 52 | 228 | loose |
| PARTYNEXTDOOR | GIRL FROM OAKLAND | 29 | 13 | 57 | loose |
| PARTYNEXTDOOR | GLORIOUS | 48 | 59 | 405 | loose |
| PARTYNEXTDOOR | GREEDY | 41 | 70 | 244 | loose |
| PARTYNEXTDOOR | Ghetto Cinderella | 22 | 16 | 120 | loose |
| PARTYNEXTDOOR | Ghost Town | 36 | 41 | 105 | loose |
| PARTYNEXTDOOR | Goals | 30 | 23 | 151 | loose |
| PARTYNEXTDOOR | Gold | 16 | 6 | 49 | loose |
| PARTYNEXTDOOR | Goodlove | 50 | 22 | 125 | loose |
| PARTYNEXTDOOR | Grown Man Cry | 34 | 25 | 68 | loose |
| PARTYNEXTDOOR | Grown Woman | 35 | 12 | 91 | loose |
| PARTYNEXTDOOR | H e r O l d F r i e n d s | 38 | 17 | 236 | loose |
| PARTYNEXTDOOR | Heat of the Moment | 26 | 3 | 90 | loose |
| PARTYNEXTDOOR | Her Way | 29 | 14 | 78 | loose |
| PARTYNEXTDOOR | High Hopes | 63 | 36 | 200 | loose |
| PARTYNEXTDOOR | His Name Cassius | 30 | 14 | 185 | loose |
| PARTYNEXTDOOR | Hit It In The Morning | 16 | 8 | 28 | loose |
| PARTYNEXTDOOR | Hold On Me | 47 | 32 | 174 | loose |
| PARTYNEXTDOOR | Home | 24 | 14 | 50 | loose |
| PARTYNEXTDOOR | Hot Boy | 50 | 52 | 304 | loose |
| PARTYNEXTDOOR | Hot Sauce (Version 1) | 20 | 3 | 56 | loose |
| PARTYNEXTDOOR | Hotel Lobby | 10 | 3 | 19 | loose |
| PARTYNEXTDOOR | How Many Strokes | 31 | 15 | 92 | loose |
| PARTYNEXTDOOR | I Can’t Wait | 20 | 16 | 192 | loose |
| PARTYNEXTDOOR | I Don’t | 44 | 24 | 104 | loose |
| PARTYNEXTDOOR | I Hope | 31 | 25 | 162 | loose |
| PARTYNEXTDOOR | I Need More | 14 | 2 | 51 | loose |
| PARTYNEXTDOOR | I Need a Break | 44 | 41 | 123 | loose |
| PARTYNEXTDOOR | Ice Cream | 20 | 1 | 53 | loose |
| PARTYNEXTDOOR | Intro (COLOURS 2) | 5 | 2 | 2 | ABAB |
| PARTYNEXTDOOR | I’m Good | 37 | 19 | 162 | loose |
| PARTYNEXTDOOR | JUS KNOW | 35 | 21 | 82 | loose |
| PARTYNEXTDOOR | Joy | 17 | 2 | 29 | loose |
| PARTYNEXTDOOR | Just A Rider | 63 | 18 | 171 | loose |
| PARTYNEXTDOOR | Just Might | 32 | 16 | 80 | loose |
| PARTYNEXTDOOR | K-TOWN | 20 | 18 | 68 | loose |
| PARTYNEXTDOOR | Keep Calm | 41 | 30 | 104 | loose |
| PARTYNEXTDOOR | Keisha | 24 | 11 | 75 | loose |
| PARTYNEXTDOOR | Kiss Me | 37 | 27 | 23 | loose |
| PARTYNEXTDOOR | L o s e M y M i n d | 35 | 19 | 76 | loose |
| PARTYNEXTDOOR | LA NIGHTS | 42 | 30 | 193 | loose |
| PARTYNEXTDOOR | LASERS | 30 | 23 | 126 | loose |
| PARTYNEXTDOOR | LETS GET MARRIED | 23 | 9 | 131 | loose |
| PARTYNEXTDOOR | LOW BATTERY | 36 | 9 | 117 | loose |
| PARTYNEXTDOOR | LOYAL | 24 | 32 | 67 | loose |
| PARTYNEXTDOOR | Leaning | 35 | 44 | 121 | loose |
| PARTYNEXTDOOR | Legend | 29 | 8 | 83 | loose |
| PARTYNEXTDOOR | Let It Rain | 23 | 14 | 56 | loose |
| PARTYNEXTDOOR | Let Me | 41 | 36 | 166 | loose |
| PARTYNEXTDOOR | Let Me Love You & Come and See Me | 31 | 15 | 139 | loose |
| PARTYNEXTDOOR | Let Me See You Bounce | 26 | 5 | 39 | loose |
| PARTYNEXTDOOR | Letters From The Attic | 34 | 7 | 93 | loose |
| PARTYNEXTDOOR | Life Amazing | 62 | 27 | 228 | loose |
| PARTYNEXTDOOR | Like Dat | 59 | 60 | 252 | loose |
| PARTYNEXTDOOR | Love | 17 | 5 | 63 | loose |
| PARTYNEXTDOOR | Love Me Again | 28 | 20 | 74 | loose |
| PARTYNEXTDOOR | M a k e I t T o T h e M o r n i n g | 24 | 13 | 114 | loose |
| PARTYNEXTDOOR | MEET YOUR PADRE | 34 | 25 | 219 | loose |
| PARTYNEXTDOOR | MOTH BALLS | 36 | 59 | 117 | loose |
| PARTYNEXTDOOR | Make It Rain | 8 | 0 | 23 | loose |
| PARTYNEXTDOOR | Make Up Sex | 24 | 9 | 99 | loose |
| PARTYNEXTDOOR | Make a Mall | 35 | 44 | 157 | loose |
| PARTYNEXTDOOR | Make a Mil | 23 | 13 | 55 | loose |
| PARTYNEXTDOOR | Maria | 46 | 19 | 109 | loose |
| PARTYNEXTDOOR | Members Only | 54 | 45 | 244 | loose |
| PARTYNEXTDOOR | Miss Tha Sauce | 22 | 9 | 90 | loose |
| PARTYNEXTDOOR | Mobbin’ | 37 | 18 | 64 | loose |
| PARTYNEXTDOOR | More | 19 | 6 | 44 | loose |
| PARTYNEXTDOOR | More Ready | 24 | 21 | 144 | loose |
| PARTYNEXTDOOR | More Than Friends | 34 | 25 | 91 | loose |
| PARTYNEXTDOOR | Muse | 39 | 21 | 96 | loose |
| PARTYNEXTDOOR | My Affection | 45 | 35 | 138 | loose |
| PARTYNEXTDOOR | My Side | 40 | 15 | 108 | loose |
| PARTYNEXTDOOR | My Terms | 28 | 10 | 57 | loose |
| PARTYNEXTDOOR | N o C h i l l | 36 | 15 | 112 | loose |
| PARTYNEXTDOOR | NEVER AGAIN | 15 | 10 | 46 | loose |
| PARTYNEXTDOOR | NOTHING LESS | 17 | 21 | 67 | loose |
| PARTYNEXTDOOR | Naked | 42 | 42 | 159 | loose |
| PARTYNEXTDOOR | Neatly | 45 | 32 | 229 | loose |
| PARTYNEXTDOOR | Never Played Me | 43 | 39 | 136 | loose |
| PARTYNEXTDOOR | Nineteen | 153 | 113 | 483 | loose |
| PARTYNEXTDOOR | No Feelings | 28 | 16 | 111 | loose |
| PARTYNEXTDOOR | No Fuss | 22 | 22 | 80 | loose |
| PARTYNEXTDOOR | No Shame | 30 | 29 | 112 | loose |
| PARTYNEXTDOOR | Nobody | 44 | 40 | 182 | loose |
| PARTYNEXTDOOR | Not Nice | 24 | 20 | 47 | loose |
| PARTYNEXTDOOR | Not To Young | 46 | 22 | 231 | loose |
| PARTYNEXTDOOR | Nothing But Net | 50 | 22 | 153 | loose |
| PARTYNEXTDOOR | Nothing Easy to Please | 19 | 8 | 97 | loose |
| PARTYNEXTDOOR | Nuh Ready Nuh Ready | 36 | 13 | 118 | loose |
| PARTYNEXTDOOR | OMO | 18 | 19 | 33 | loose |
| PARTYNEXTDOOR | OMW | 31 | 39 | 100 | loose |
| PARTYNEXTDOOR | ON UR MIND | 33 | 17 | 109 | loose |
| PARTYNEXTDOOR | ONLY ONE* | 19 | 11 | 50 | loose |
| PARTYNEXTDOOR | OVO Freestyle | 25 | 19 | 159 | loose |
| PARTYNEXTDOOR | OVO Sound Radio Episode 27 Tracklist | 31 | 7 | 26 | loose |
| PARTYNEXTDOOR | OVO Sound Radio Episode 53 Tracklist | 56 | 18 | 156 | loose |
| PARTYNEXTDOOR | OVO Sound Radio Episode 7 Tracklist | 56 | 21 | 195 | loose |
| PARTYNEXTDOOR | One I Want | 29 | 22 | 54 | loose |
| PARTYNEXTDOOR | One In A Million | 22 | 4 | 97 | loose |
| PARTYNEXTDOOR | Only For The Night | 30 | 16 | 154 | loose |
| PARTYNEXTDOOR | Only U | 38 | 22 | 99 | loose |
| PARTYNEXTDOOR | Oops x Wus Good | 24 | 11 | 56 | loose |
| PARTYNEXTDOOR | Options | 58 | 25 | 237 | loose |
| PARTYNEXTDOOR | Over Here | 42 | 23 | 166 | loose |
| PARTYNEXTDOOR | Own It | 44 | 13 | 142 | loose |
| PARTYNEXTDOOR | Own Up to Your Shit | 66 | 44 | 217 | loose |
| PARTYNEXTDOOR | PARTY AT 8 | 26 | 10 | 167 | loose |
| PARTYNEXTDOOR | PEACE OF MIND | 40 | 20 | 154 | loose |
| PARTYNEXTDOOR | PGT | 26 | 16 | 82 | loose |
| PARTYNEXTDOOR | PIMMIE’S DILEMMA | 15 | 5 | 80 | loose |
| PARTYNEXTDOOR | POINT ME TO THE DANCERS | 22 | 20 | 41 | loose |
| PARTYNEXTDOOR | Party At Game’s | 68 | 22 | 269 | loose |
| PARTYNEXTDOOR | Persian Rugs | 25 | 7 | 25 | loose |
| PARTYNEXTDOOR | Plenty | 16 | 10 | 97 | loose |
| PARTYNEXTDOOR | Poppa (All In 4 Daddy) | 35 | 15 | 108 | loose |
| PARTYNEXTDOOR | Preach | 42 | 32 | 133 | loose |
| PARTYNEXTDOOR | Problems & Selfless | 24 | 10 | 54 | loose |
| PARTYNEXTDOOR | Put It On Silent | 43 | 26 | 101 | loose |
| PARTYNEXTDOOR | R A I N (Remix) | 35 | 18 | 161 | loose |
| PARTYNEXTDOOR | R e a l W o m a n | 33 | 15 | 153 | loose |
| PARTYNEXTDOOR | R e s e n t m e n t | 26 | 17 | 64 | loose |
| PARTYNEXTDOOR | RAINING IN HOUSTON | 39 | 38 | 191 | loose |
| PARTYNEXTDOOR | RENDEZVOUS | 32 | 13 | 90 | loose |
| PARTYNEXTDOOR | Rain (2018) | 29 | 31 | 157 | loose |
| PARTYNEXTDOOR | Ratchet Happy Birthday | 27 | 17 | 59 | loose |
| PARTYNEXTDOOR | Reachin’ | 25 | 6 | 52 | loose |
| PARTYNEXTDOOR | Realest In The City | 49 | 38 | 274 | loose |
| PARTYNEXTDOOR | Recognize | 54 | 36 | 216 | loose |
| PARTYNEXTDOOR | Relax with Me | 37 | 14 | 96 | loose |
| PARTYNEXTDOOR | Right Now | 34 | 20 | 110 | loose |
| PARTYNEXTDOOR | Ron Cater | 25 | 15 | 39 | loose |
| PARTYNEXTDOOR | Routine Rouge | 37 | 34 | 107 | loose |
| PARTYNEXTDOOR | Run Up | 45 | 41 | 187 | loose |
| PARTYNEXTDOOR | S o r r y, B u t I’ m O u t s i d e | 55 | 21 | 201 | loose |
| PARTYNEXTDOOR | S t u c k I n M y W a y s | 16 | 12 | 44 | loose |
| PARTYNEXTDOOR | SAVAGE ANTHEM | 41 | 32 | 87 | loose |
| PARTYNEXTDOOR | SHOWING YOU | 20 | 9 | 42 | loose |
| PARTYNEXTDOOR | SLS | 32 | 16 | 95 | loose |
| PARTYNEXTDOOR | SOMEBODY LOVES ME | 31 | 31 | 93 | loose |
| PARTYNEXTDOOR | SOMEBODY LOVES ME PT. 2 | 33 | 52 | 131 | loose |
| PARTYNEXTDOOR | SOMETHING ABOUT YOU | 43 | 48 | 152 | loose |
| PARTYNEXTDOOR | SPIDER-MAN SUPERMAN | 37 | 27 | 132 | loose |
| PARTYNEXTDOOR | SPLIT DECISION | 15 | 2 | 70 | loose |
| PARTYNEXTDOOR | Say Things I Don’t Mean (Again) | 25 | 18 | 63 | loose |
| PARTYNEXTDOOR | Say What | 41 | 25 | 167 | loose |
| PARTYNEXTDOOR | Secret Lover | 37 | 19 | 38 | loose |
| PARTYNEXTDOOR | Sex In The Porsche | 31 | 13 | 108 | loose |
| PARTYNEXTDOOR | Sex With Me | 26 | 19 | 92 | loose |
| PARTYNEXTDOOR | Sex on the Beach | 26 | 17 | 39 | loose |
| PARTYNEXTDOOR | Sexually | 33 | 11 | 107 | loose |
| PARTYNEXTDOOR | Shining | 63 | 20 | 177 | loose |
| PARTYNEXTDOOR | Shining (Thank You) [Homecoming Live] | 13 | 6 | 38 | loose |
| PARTYNEXTDOOR | Shot Clock | 32 | 21 | 138 | loose |
| PARTYNEXTDOOR | Shy Ink | 15 | 5 | 106 | loose |
| PARTYNEXTDOOR | Silhouette | 8 | 2 | 7 | loose |
| PARTYNEXTDOOR | Since Way Back | 51 | 33 | 117 | loose |
| PARTYNEXTDOOR | Slow It Down | 56 | 19 | 114 | loose |
| PARTYNEXTDOOR | Some of Your Love | 22 | 5 | 78 | loose |
| PARTYNEXTDOOR | Something New | 17 | 2 | 42 | loose |
| PARTYNEXTDOOR | Speaking In French | 18 | 9 | 62 | loose |
| PARTYNEXTDOOR | Spiteful | 39 | 12 | 134 | loose |
| PARTYNEXTDOOR | Squad | 58 | 54 | 246 | loose |
| PARTYNEXTDOOR | Stamina (Remix) | 37 | 21 | 91 | loose |
| PARTYNEXTDOOR | Stay Sweet | 25 | 11 | 49 | loose |
| PARTYNEXTDOOR | Still Got Time | 34 | 28 | 63 | loose |
| PARTYNEXTDOOR | Strip Club | 12 | 4 | 35 | loose |
| PARTYNEXTDOOR | Stuck on Stacks | 65 | 34 | 168 | loose |
| PARTYNEXTDOOR | Summer 2016 (Medley Extended) | 67 | 29 | 382 | loose |
| PARTYNEXTDOOR | Swishin’ | 51 | 46 | 166 | loose |
| PARTYNEXTDOOR | TABLES TURN* | 34 | 27 | 84 | loose |
| PARTYNEXTDOOR | TALK TO ME NICE | 47 | 23 | 168 | loose |
| PARTYNEXTDOOR | TBH | 18 | 6 | 32 | loose |
| PARTYNEXTDOOR | THE NEWS | 29 | 12 | 55 | loose |
| PARTYNEXTDOOR | THINGS & SUCH | 59 | 51 | 170 | loose |
| PARTYNEXTDOOR | TOUCH ME | 20 | 13 | 47 | loose |
| PARTYNEXTDOOR | TRAUMA | 14 | 12 | 56 | loose |
| PARTYNEXTDOOR | TURN UP | 20 | 13 | 69 | loose |
| PARTYNEXTDOOR | TWIST & TURN | 49 | 50 | 183 | loose |
| PARTYNEXTDOOR | Table For Two | 27 | 21 | 84 | loose |
| PARTYNEXTDOOR | Take Care Pt. 2 | 43 | 25 | 125 | loose |
| PARTYNEXTDOOR | Takin’ Shots | 44 | 44 | 200 | loose |
| PARTYNEXTDOOR | Team | 45 | 29 | 141 | loose |
| PARTYNEXTDOOR | Tell Me | 12 | 5 | 22 | loose |
| PARTYNEXTDOOR | Temptations | 21 | 6 | 28 | loose |
| PARTYNEXTDOOR | Thank You Letter (P3) | 2 | 0 | 4 | loose |
| PARTYNEXTDOOR | That’s What I Like (PARTYNEXTDOOR Remix) | 33 | 24 | 86 | loose |
| PARTYNEXTDOOR | The Blinding | 39 | 40 | 211 | loose |
| PARTYNEXTDOOR | The Right Way | 36 | 31 | 107 | loose |
| PARTYNEXTDOOR | Thirsty | 32 | 12 | 88 | loose |
| PARTYNEXTDOOR | Transparency | 50 | 6 | 108 | loose |
| PARTYNEXTDOOR | Trap Star | 30 | 15 | 144 | loose |
| PARTYNEXTDOOR | Trouble | 43 | 28 | 181 | loose |
| PARTYNEXTDOOR | Truth For You | 43 | 32 | 137 | loose |
| PARTYNEXTDOOR | U With Me? | 63 | 53 | 249 | loose |
| PARTYNEXTDOOR | Unthinkable | 22 | 4 | 49 | loose |
| PARTYNEXTDOOR | Up From Here | 18 | 3 | 25 | loose |
| PARTYNEXTDOOR | WEST DISTRICT | 40 | 21 | 158 | loose |
| PARTYNEXTDOOR | WEST END GIRL | 4 | 0 | 16 | loose |
| PARTYNEXTDOOR | WHEN HE’S GONE | 31 | 24 | 142 | loose |
| PARTYNEXTDOOR | WNBA | 34 | 25 | 193 | loose |
| PARTYNEXTDOOR | Wait For You | 14 | 5 | 50 | loose |
| PARTYNEXTDOOR | Wanna Be | 37 | 25 | 122 | loose |
| PARTYNEXTDOOR | Want Me (Meghan’s Interlude) | 24 | 10 | 60 | loose |
| PARTYNEXTDOOR | Waves | 20 | 18 | 36 | loose |
| PARTYNEXTDOOR | Wednesday Night Interlude | 22 | 9 | 93 | loose |
| PARTYNEXTDOOR | Welcome To The Party | 21 | 2 | 40 | loose |
| PARTYNEXTDOOR | What Have U Done For Me Lately | 27 | 21 | 65 | loose |
| PARTYNEXTDOOR | Whatever You Say (You Got Me) | 21 | 8 | 47 | loose |
| PARTYNEXTDOOR | What’s Love Got To Do With It | 13 | 2 | 30 | loose |
| PARTYNEXTDOOR | Whole Lotta Liquor | 52 | 25 | 173 | loose |
| PARTYNEXTDOOR | Wild Bitches | 21 | 8 | 51 | loose |
| PARTYNEXTDOOR | Wild Thoughts | 41 | 26 | 116 | loose |
| PARTYNEXTDOOR | With You | 26 | 18 | 56 | loose |
| PARTYNEXTDOOR | Work | 56 | 45 | 114 | loose |
| PARTYNEXTDOOR | Work It Out | 39 | 16 | 97 | loose |
| PARTYNEXTDOOR | Wouldn’t Leave | 49 | 38 | 180 | loose |
| PARTYNEXTDOOR | Wus Good / Curious | 42 | 30 | 73 | loose |
| PARTYNEXTDOOR | You Girl* | 9 | 6 | 25 | loose |
| PARTYNEXTDOOR | You Got Me | 39 | 25 | 96 | loose |
| PARTYNEXTDOOR | You Made It | 39 | 16 | 77 | loose |
| PARTYNEXTDOOR | You’ve Been Missed | 23 | 3 | 31 | loose |
| PARTYNEXTDOOR | feel U luv Me | 17 | 8 | 14 | loose |
| PARTYNEXTDOOR | fue mejor | 45 | 20 | 261 | loose |
