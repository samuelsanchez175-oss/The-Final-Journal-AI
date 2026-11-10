# Homixide Gang rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Homixide Gang
- Songs: 235
- Bars kept (Homixide Gang lyric lines): 6431
- Section headers dropped, not counted as bars: 2
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 54
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 21
- Canonical name: Homixide Gang.
- Credit strings: Homixide Gang.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 30651
- REPEAT pairs, recorded separately: 4552
- END rhymes: 5698
- INNER rhymes: 24953

By match:

- PERFECT: 2613 (END 741, INNER 1872)
- SLANT: 13626 (END 2373, INNER 11253)
- ASSONANCE: 14280 (END 2553, INNER 11727)
- MULTI: 132 (END 31, INNER 101)

By confidence:

- HIGH: 2438
- MED: 26091
- LOW: 2122

## Core

- Core Y: 30107
- Core N among rhyme pairs: 544

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 14355 (46.8%)
- vowel: 14280 (46.6%)
- spelling: 1884 (6.1%)
- multi: 132 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 4 songs
- ABCB: 1 songs
- loose: 230 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 2362 pairs (END 485, INNER 1877). Words: shit, bitch, bitches, lil, business, sticks, him, wrist.
2. `vow:OW` — 1930 pairs (END 243, INNER 1687). Words: don't, know, no, go, told, hoes, ho, hold.
3. `vow:EY` — 1633 pairs (END 330, INNER 1303). Words: ain't, play, way, say, face, day, make, takin.
4. `vow:AE` — 1626 pairs (END 354, INNER 1272). Words: can't, racks, gang, havin, pants, nasty, back, ass.
5. `vow:AA` — 1365 pairs (END 142, INNER 1223). Words: got, poppin, rockin, want, nothin, rollin, shots, talkin.
6. `vow:AH` — 1300 pairs (END 202, INNER 1098). Words: drugs, fuck, money, hundred, double, come, what, fuckin.
7. `vow:AY` — 1168 pairs (END 255, INNER 913). Words: diamonds, like, fire, die, high, ride, by, sky.
8. `vow:EH` — 1163 pairs (END 202, INNER 961). Words: get, gettin, when, step, let's, send, x, friends.
9. `vow:IY` — 1120 pairs (END 208, INNER 912). Words: these, snotty, see, even, free, real, demon, keep.
10. `slant:AA:stop` — 998 pairs (END 105, INNER 893). Words: got, block, gotta, glock, body, rock, hop, want.
11. `slant:IH:stop` — 950 pairs (END 130, INNER 820). Words: shit, nigga, stick, big, hit, blick, wrist, dick.
12. `slant:IH:sib-stop` — 943 pairs (END 262, INNER 681). Words: bitch, shit, stick, hit, switch, nigga, niggas, big.
13. `cmu:OW` — 462 pairs (END 68, INNER 394). Words: know, no, go, ho, low, show, bro, dough.
14. `slant:EH:stop` — 446 pairs (END 45, INNER 401). Words: get, ready, step, neck, head, better, check, red.
15. `slant:AH:nas-stop` — 431 pairs (END 36, INNER 395). Words: fuck, come, what, money, some, run, young, blood.
16. `slant:IH:liq-stop` — 425 pairs (END 15, INNER 410). Words: lil, shit, still, hit, stick, big, really, 'til.
17. `slant:IH:nas-stop` — 421 pairs (END 30, INNER 391). Words: shit, him, i'ma, hit, spin, stick, bring, big.
18. `slant:AA:liq-stop` — 336 pairs (END 18, INNER 318). Words: rockstar, got, car, star, block, gotta, guitar, molly.
19. `slant:EH:nas-stop` — 286 pairs (END 20, INNER 266). Words: get, when, em, ten, again, gettin, n, many.
20. `slant:AE:nas-stop` — 285 pairs (END 51, INNER 234). Words: gang, back, trap, man, can, bad, damn, black.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 450 pair sides, mostly spelling via spelling phonetic key, often with shit (170)
- ima — 177 pair sides, mostly spelling via spelling phonetic key, often with bitch (54)
- gon — 119 pair sides, mostly spelling via spelling phonetic key, often with dont (36)
- niggas — 99 pair sides, mostly spelling via spelling phonetic key, often with nigga (64)
- tryna — 90 pair sides, mostly spelling via spelling phonetic key, often with these (16)
- shawty — 80 pair sides, mostly vowel via spelling phonetic key, often with money (7)
- swag — 58 pair sides, mostly spelling via spelling phonetic key, often with back (7)
- bih — 57 pair sides, mostly spelling via spelling phonetic key, often with lil (6)
- homixide — 51 pair sides, mostly vowel via spelling phonetic key, often with whole (5)
- drac — 49 pair sides, mostly spelling via spelling phonetic key, often with cant (8)
- tris — 45 pair sides, mostly spelling via spelling phonetic key, often with shit (9)
- blicks — 43 pair sides, mostly vowel via spelling phonetic key, often with shit (10)
- bros — 31 pair sides, mostly spelling via spelling phonetic key, often with know (5)
- moshpit — 27 pair sides, mostly spelling via spelling phonetic key, often with shit (18)
- codeine — 25 pair sides, mostly vowel via spelling phonetic key, often with smokin (5)
- geekin — 22 pair sides, mostly spelling via spelling phonetic key, often with another (3)
- hol — 20 pair sides, mostly spelling via spelling phonetic key, often with home (3)
- geeked — 19 pair sides, mostly vowel via spelling phonetic key, often with these (4)
- twerk — 18 pair sides, mostly spelling via spelling phonetic key, often with work (14)
- glizzy — 18 pair sides, mostly vowel via spelling phonetic key, often with bitch (6)
- finna — 17 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- spazz — 17 pair sides, mostly spelling via spelling phonetic key, often with flash (6)
- blicky — 16 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- thot — 16 pair sides, mostly spelling via spelling phonetic key, often with show (3)
- dyin — 15 pair sides, mostly spelling via spelling phonetic key, often with these (6)
- opps — 14 pair sides, mostly vowel via spelling phonetic key, often with know (5)
- wock — 14 pair sides, mostly vowel via spelling phonetic key, often with know (3)
- glocks — 13 pair sides, mostly vowel via spelling phonetic key, often with know (4)
- bap — 12 pair sides, mostly spelling via spelling phonetic key, often with cap (6)
- remix — 12 pair sides, mostly vowel via vault phonetic_class, often with bitch (3)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Homixide Gang | #’s (Numbers) | 29 | 25 | 250 | loose |
| Homixide Gang | $$$ PROBLEMS | 38 | 19 | 126 | loose |
| Homixide Gang | 00-MEGA | 54 | 47 | 173 | loose |
| Homixide Gang | 05.09.23 SONG #2 | 31 | 17 | 73 | loose |
| Homixide Gang | 1-800-555-OPIUM | 30 | 27 | 74 | loose |
| Homixide Gang | 100 Racks | 8 | 5 | 14 | loose |
| Homixide Gang | 100% | 20 | 11 | 71 | loose |
| Homixide Gang | 2 Da Face | 40 | 16 | 94 | loose |
| Homixide Gang | 21 | 25 | 41 | 100 | loose |
| Homixide Gang | 25/8 | 31 | 35 | 81 | loose |
| Homixide Gang | 2xTREME | 33 | 22 | 118 | loose |
| Homixide Gang | 40 FLOORS UP | 51 | 53 | 227 | loose |
| Homixide Gang | 5 Hunnit Bags | 18 | 23 | 188 | loose |
| Homixide Gang | 5 O’clock | 53 | 38 | 272 | loose |
| Homixide Gang | 5 Ways | 51 | 56 | 155 | loose |
| Homixide Gang | 5!RE | 29 | 27 | 118 | loose |
| Homixide Gang | 500 Degrees* | 25 | 7 | 91 | loose |
| Homixide Gang | 55 Lifestyle | 30 | 39 | 129 | loose |
| Homixide Gang | 5G | 38 | 42 | 116 | loose |
| Homixide Gang | 5HIP | 31 | 52 | 131 | loose |
| Homixide Gang | 5ONJOUR | 28 | 56 | 72 | loose |
| Homixide Gang | 5REW | 36 | 37 | 98 | loose |
| Homixide Gang | 5ins | 33 | 28 | 225 | loose |
| Homixide Gang | 5unna | 22 | 17 | 165 | loose |
| Homixide Gang | ADHD | 29 | 32 | 54 | loose |
| Homixide Gang | AYYE | 36 | 23 | 134 | loose |
| Homixide Gang | AddXcts | 36 | 28 | 82 | loose |
| Homixide Gang | Ain’t No Way | 49 | 44 | 282 | loose |
| Homixide Gang | Al Capone* | 14 | 11 | 63 | loose |
| Homixide Gang | Anarky* | 3 | 0 | 0 | loose |
| Homixide Gang | Around | 20 | 16 | 198 | loose |
| Homixide Gang | B!NK | 20 | 16 | 72 | loose |
| Homixide Gang | B0DYBAG | 41 | 39 | 94 | loose |
| Homixide Gang | B5 | 17 | 9 | 91 | loose |
| Homixide Gang | BACK5LIP | 41 | 15 | 178 | loose |
| Homixide Gang | BARNACL3PLATT5R | 8 | 8 | 23 | AAAA |
| Homixide Gang | BB | 11 | 6 | 67 | loose |
| Homixide Gang | BBY GRL | 35 | 16 | 97 | loose |
| Homixide Gang | BEAN! | 5 | 0 | 4 | loose |
| Homixide Gang | BLACK5!VE* | 55 | 35 | 170 | loose |
| Homixide Gang | BLAK ROKSTAR* | 10 | 4 | 15 | loose |
| Homixide Gang | BLOOD | 5 | 1 | 11 | ABCB |
| Homixide Gang | BREEZE | 59 | 45 | 269 | loose |
| Homixide Gang | BUDDHA MAN | 3 | 0 | 4 | loose |
| Homixide Gang | Bandz | 33 | 22 | 70 | loose |
| Homixide Gang | Benci Boots | 31 | 21 | 83 | loose |
| Homixide Gang | Big O Shit | 22 | 37 | 143 | loose |
| Homixide Gang | Block Work | 41 | 20 | 111 | loose |
| Homixide Gang | Block Wrk | 5 | 4 | 8 | loose |
| Homixide Gang | Bloody Mary | 4 | 1 | 1 | loose |
| Homixide Gang | Bora Bora* | 10 | 21 | 62 | AAAA |
| Homixide Gang | C4N | 18 | 12 | 113 | loose |
| Homixide Gang | CALL ON ME | 39 | 28 | 144 | loose |
| Homixide Gang | CHOPPAS | 4 | 1 | 4 | loose |
| Homixide Gang | CHOPSHOP | 70 | 63 | 291 | loose |
| Homixide Gang | CLONES | 21 | 24 | 35 | loose |
| Homixide Gang | COCAINE | 13 | 15 | 75 | loose |
| Homixide Gang | COCAINE WHITE | 35 | 31 | 276 | loose |
| Homixide Gang | CROCS | 4 | 0 | 6 | loose |
| Homixide Gang | CV | 22 | 27 | 58 | loose |
| Homixide Gang | Can’t Go | 30 | 23 | 46 | loose |
| Homixide Gang | Can’t You Tell | 20 | 9 | 82 | loose |
| Homixide Gang | Chrome Heart Timbs* | 40 | 42 | 233 | loose |
| Homixide Gang | DEN!M | 40 | 30 | 167 | loose |
| Homixide Gang | DXE DXE DXE | 29 | 38 | 76 | loose |
| Homixide Gang | DeathLOK | 28 | 35 | 96 | loose |
| Homixide Gang | Delinquent | 52 | 56 | 332 | loose |
| Homixide Gang | Demon (Blood)* | 10 | 11 | 26 | loose |
| Homixide Gang | DesignerDRÜGZ | 35 | 32 | 94 | loose |
| Homixide Gang | Did That | 18 | 19 | 65 | loose |
| Homixide Gang | Different | 21 | 14 | 133 | loose |
| Homixide Gang | Dive In | 30 | 13 | 65 | loose |
| Homixide Gang | Don’t Give A Fuck* | 5 | 2 | 5 | loose |
| Homixide Gang | Drakon ! | 28 | 27 | 111 | loose |
| Homixide Gang | E.U. | 39 | 33 | 107 | loose |
| Homixide Gang | Every Day* | 10 | 13 | 18 | loose |
| Homixide Gang | FA5EBUSTER | 37 | 38 | 113 | loose |
| Homixide Gang | FACET!ME | 31 | 12 | 160 | loose |
| Homixide Gang | FLAMETHR0WER | 20 | 15 | 99 | loose |
| Homixide Gang | FRANK MATTHEWS | 32 | 22 | 119 | loose |
| Homixide Gang | FREE AGENTS | 56 | 56 | 204 | loose |
| Homixide Gang | FREESTYLE | 4 | 1 | 5 | loose |
| Homixide Gang | FUCK IT (1) | 32 | 21 | 200 | loose |
| Homixide Gang | FiGure5 [INTERLUDE] | 40 | 35 | 225 | loose |
| Homixide Gang | Five Dents | 30 | 24 | 107 | loose |
| Homixide Gang | Flight’s Booked | 35 | 25 | 99 | loose |
| Homixide Gang | Fox 5* | 4 | 0 | 5 | loose |
| Homixide Gang | FroZone | 44 | 34 | 111 | loose |
| Homixide Gang | Fully Loaded* | 12 | 14 | 48 | loose |
| Homixide Gang | G6* | 43 | 57 | 304 | loose |
| Homixide Gang | GOING ON | 1 | 0 | 1 | loose |
| Homixide Gang | GVNGANATI | 24 | 15 | 119 | loose |
| Homixide Gang | Get Down* | 6 | 5 | 20 | loose |
| Homixide Gang | Get It* | 9 | 5 | 55 | loose |
| Homixide Gang | Get Lucky* | 15 | 41 | 32 | loose |
| Homixide Gang | Go* | 6 | 1 | 8 | loose |
| Homixide Gang | God’s Way* | 16 | 13 | 39 | loose |
| Homixide Gang | Goin’ Global* | 14 | 2 | 36 | loose |
| Homixide Gang | Gr!nch | 27 | 33 | 103 | loose |
| Homixide Gang | Grab Da Door! | 22 | 26 | 128 | loose |
| Homixide Gang | Guitars | 38 | 25 | 126 | loose |
| Homixide Gang | Gun | 28 | 29 | 110 | loose |
| Homixide Gang | Gunz in SOHO | 34 | 42 | 114 | loose |
| Homixide Gang | HEADTAP | 42 | 31 | 189 | loose |
| Homixide Gang | HELLRAI5ER | 6 | 1 | 18 | loose |
| Homixide Gang | HI-VOLTAGE | 36 | 21 | 142 | loose |
| Homixide Gang | HXG Bizness | 24 | 12 | 125 | loose |
| Homixide Gang | Hallucinating* | 16 | 7 | 41 | loose |
| Homixide Gang | Hardy Boyz | 4 | 1 | 11 | loose |
| Homixide Gang | High as Fuck* | 14 | 13 | 55 | loose |
| Homixide Gang | Hold It Down* | 16 | 10 | 62 | loose |
| Homixide Gang | Holler! | 22 | 9 | 158 | loose |
| Homixide Gang | Hom3 Invasion | 24 | 12 | 135 | loose |
| Homixide Gang | Homixide Language | 26 | 5 | 73 | loose |
| Homixide Gang | Hurt ’Em* | 52 | 44 | 185 | loose |
| Homixide Gang | I00 | 38 | 34 | 344 | loose |
| Homixide Gang | INFAMOUS | 49 | 44 | 75 | loose |
| Homixide Gang | JOHNNY CAGE | 45 | 50 | 178 | loose |
| Homixide Gang | K9INE | 11 | 3 | 23 | loose |
| Homixide Gang | KPBEATZ* | 14 | 9 | 33 | loose |
| Homixide Gang | L1ghtShow | 13 | 8 | 31 | loose |
| Homixide Gang | LIES | 4 | 3 | 8 | loose |
| Homixide Gang | Laced Up | 43 | 46 | 149 | loose |
| Homixide Gang | Left Hand | 29 | 23 | 130 | loose |
| Homixide Gang | Let It Ring* | 17 | 8 | 41 | loose |
| Homixide Gang | LexLuger | 23 | 39 | 53 | loose |
| Homixide Gang | Lif3 | 28 | 16 | 88 | loose |
| Homixide Gang | Lifestyle | 27 | 19 | 68 | loose |
| Homixide Gang | Lose It* | 29 | 19 | 66 | loose |
| Homixide Gang | M.I.A | 4 | 3 | 9 | loose |
| Homixide Gang | MADNESS | 30 | 39 | 134 | loose |
| Homixide Gang | MW5 | 50 | 57 | 257 | loose |
| Homixide Gang | Money Mission* | 19 | 7 | 60 | loose |
| Homixide Gang | My Way* | 23 | 12 | 43 | loose |
| Homixide Gang | NINTEND0 | 52 | 39 | 123 | loose |
| Homixide Gang | NUN 2 IT | 48 | 54 | 236 | loose |
| Homixide Gang | NiNO 5ROWN | 34 | 41 | 65 | loose |
| Homixide Gang | NoEvi | 22 | 27 | 114 | loose |
| Homixide Gang | None 2 Some | 16 | 13 | 94 | loose |
| Homixide Gang | Norbit* | 3 | 3 | 13 | loose |
| Homixide Gang | Notice It | 25 | 32 | 98 | loose |
| Homixide Gang | OUTSIDE | 4 | 1 | 2 | loose |
| Homixide Gang | Other Way | 1 | 0 | 0 | loose |
| Homixide Gang | Overseas | 22 | 15 | 75 | loose |
| Homixide Gang | PARIS | 5 | 1 | 10 | loose |
| Homixide Gang | PAVEMENT | 14 | 4 | 56 | loose |
| Homixide Gang | PAYBACK (Homixide Lifestyle 2) | 19 | 5 | 249 | loose |
| Homixide Gang | PB&J | 49 | 31 | 180 | loose |
| Homixide Gang | PC5 | 32 | 31 | 90 | loose |
| Homixide Gang | PLATOON | 13 | 8 | 35 | loose |
| Homixide Gang | PRADA | 29 | 14 | 83 | loose |
| Homixide Gang | PUT EM UP | 29 | 15 | 62 | loose |
| Homixide Gang | Packs* | 6 | 4 | 10 | loose |
| Homixide Gang | Patience* | 28 | 19 | 163 | loose |
| Homixide Gang | Pour Up* | 19 | 2 | 20 | loose |
| Homixide Gang | Pray for Me* | 19 | 16 | 66 | loose |
| Homixide Gang | Project X | 29 | 16 | 87 | loose |
| Homixide Gang | Puttem On | 45 | 31 | 163 | loose |
| Homixide Gang | QUAKE* | 28 | 14 | 60 | loose |
| Homixide Gang | R.I.P. (Remix) | 5 | 8 | 34 | AAAA |
| Homixide Gang | R50 | 36 | 36 | 85 | loose |
| Homixide Gang | RCKstarB!tch | 43 | 44 | 139 | loose |
| Homixide Gang | RED TAILS | 50 | 46 | 180 | loose |
| Homixide Gang | REDRAG | 51 | 37 | 186 | loose |
| Homixide Gang | RESTLESS | 12 | 13 | 32 | loose |
| Homixide Gang | ROAD RAGE! | 25 | 11 | 44 | loose |
| Homixide Gang | RX | 27 | 14 | 72 | loose |
| Homixide Gang | Ready To Crash | 41 | 37 | 183 | loose |
| Homixide Gang | RedRum | 37 | 21 | 163 | loose |
| Homixide Gang | Roadkill* | 25 | 14 | 103 | loose |
| Homixide Gang | Rockstar | 24 | 26 | 99 | loose |
| Homixide Gang | Rockstar Stepper* | 6 | 6 | 7 | loose |
| Homixide Gang | Rockstar Trapper Shit | 32 | 26 | 127 | loose |
| Homixide Gang | Rockstar Trappin’! | 25 | 32 | 70 | loose |
| Homixide Gang | Rockstar/Molly* | 8 | 1 | 7 | loose |
| Homixide Gang | Roundz | 22 | 10 | 57 | loose |
| Homixide Gang | Run Up My Paper* | 20 | 10 | 52 | loose |
| Homixide Gang | SCALES | 34 | 21 | 103 | loose |
| Homixide Gang | SHOPPING BAGS | 44 | 42 | 180 | loose |
| Homixide Gang | SIDE EFFExT | 72 | 94 | 260 | loose |
| Homixide Gang | SMAKDWN | 23 | 14 | 68 | loose |
| Homixide Gang | SMELL LIKE SHIT | 45 | 57 | 260 | loose |
| Homixide Gang | SOBER | 53 | 42 | 195 | loose |
| Homixide Gang | SOUL-FLY | 31 | 29 | 140 | loose |
| Homixide Gang | SPRAYTOVEN | 8 | 0 | 18 | loose |
| Homixide Gang | SRT | 34 | 49 | 113 | loose |
| Homixide Gang | SSN | 24 | 18 | 141 | loose |
| Homixide Gang | STATE PROPERTY | 41 | 39 | 121 | loose |
| Homixide Gang | SUPER-V | 58 | 62 | 282 | loose |
| Homixide Gang | Scale Stretcher | 22 | 24 | 114 | loose |
| Homixide Gang | Section 8 | 29 | 36 | 190 | loose |
| Homixide Gang | Sharp Sh00ter | 28 | 20 | 68 | loose |
| Homixide Gang | Shots Off | 28 | 45 | 177 | AAAA |
| Homixide Gang | Shoulda Signed to the O* | 17 | 8 | 28 | loose |
| Homixide Gang | Snot Sh!t | 26 | 33 | 45 | loose |
| Homixide Gang | Snotty Rock! | 40 | 81 | 202 | loose |
| Homixide Gang | Snotty Run! | 29 | 15 | 105 | loose |
| Homixide Gang | Snotty Wax! | 24 | 33 | 194 | loose |
| Homixide Gang | Snotty* | 7 | 0 | 14 | loose |
| Homixide Gang | Spinnin’ | 40 | 41 | 156 | loose |
| Homixide Gang | Step Daddy | 38 | 54 | 198 | loose |
| Homixide Gang | Stick* | 32 | 17 | 109 | loose |
| Homixide Gang | Stuck In My Ways | 17 | 20 | 95 | loose |
| Homixide Gang | Stunt | 56 | 84 | 296 | loose |
| Homixide Gang | SwanTon BOMB | 52 | 49 | 206 | loose |
| Homixide Gang | Switch Up | 26 | 34 | 78 | loose |
| Homixide Gang | T0TEBAG | 31 | 28 | 140 | loose |
| Homixide Gang | TABLESandLATTER5 | 45 | 32 | 111 | loose |
| Homixide Gang | TF! | 32 | 53 | 218 | loose |
| Homixide Gang | THESNOTTIEST | 27 | 18 | 86 | loose |
| Homixide Gang | TNT | 29 | 15 | 41 | loose |
| Homixide Gang | TRAUMA | 32 | 30 | 61 | loose |
| Homixide Gang | TREFLIP! | 17 | 16 | 103 | loose |
| Homixide Gang | Tatted | 25 | 19 | 80 | loose |
| Homixide Gang | The LifeStyle! (The LifeStyle!) | 19 | 14 | 134 | loose |
| Homixide Gang | Tight pants | 47 | 33 | 142 | loose |
| Homixide Gang | Today* | 9 | 8 | 26 | loose |
| Homixide Gang | Tripping | 21 | 26 | 91 | loose |
| Homixide Gang | Us vs Them | 40 | 40 | 103 | loose |
| Homixide Gang | Uzi Work | 30 | 24 | 130 | loose |
| Homixide Gang | V-Friends | 23 | 25 | 109 | loose |
| Homixide Gang | VICE CITY | 59 | 75 | 200 | loose |
| Homixide Gang | VILLAIN | 24 | 9 | 168 | loose |
| Homixide Gang | VersionF!VE | 36 | 60 | 119 | loose |
| Homixide Gang | Versus | 35 | 20 | 136 | loose |
| Homixide Gang | Vibes! | 21 | 25 | 122 | loose |
| Homixide Gang | WATCH OUT! | 37 | 21 | 62 | loose |
| Homixide Gang | Wants & Needs | 35 | 40 | 49 | loose |
| Homixide Gang | What It Is?! | 43 | 28 | 129 | loose |
| Homixide Gang | What?* | 1 | 0 | 0 | loose |
| Homixide Gang | Wings | 25 | 25 | 87 | loose |
| Homixide Gang | YVL | 43 | 67 | 194 | loose |
| Homixide Gang | fridaythe13th | 8 | 3 | 13 | loose |
| Homixide Gang | ss (Original) | 17 | 14 | 101 | loose |
| Homixide Gang | ‘DAMN’ | 36 | 33 | 169 | loose |
