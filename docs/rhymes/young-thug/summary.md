# Young Thug rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Young Thug, Young Stoner Life & Young Thug, Young Stoner Life, Young Thug & Gunna, Young Stoner Life, Young Thug & Meek Mill
- Songs: 53
- Bars kept (Young Thug lyric lines): 2659
- Section headers dropped, not counted as bars: 4
- Genius page chrome dropped, not counted as bars: 85. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: Bad Bad Bad (5), Cartier Gucci Scarf (2), Circle of Bosses (4), Diamonds (6), Die Today (3), Hot (Remix) (3), I'm Scared (2), Jumped Out The Window (5), Mack Truck (5), My City (Remix) (3), No Surprise (3), Paid the Fine (6), Proud of You (4), Pussy (1), Ski (6), Slam the Door (4), Solid (6), Sup Mate (3), Superstar (4), Surf (4), That Go! (6)
- Lines skipped because a section header named another artist: 3
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 19
- Thugger: no vault credit contains Thugger. Nothing under that name was opened.
- YSL (USA) does not contain Young Thug or Thugger. That credit was not opened.
- Every matched artist string, the rejected titles, and the feature sections are in `coverage.md`.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 14013
- REPEAT pairs, recorded separately: 2282
- END rhymes: 2193
- INNER rhymes: 11820

By match:

- PERFECT: 1000 (END 234, INNER 766)
- SLANT: 5938 (END 870, INNER 5068)
- ASSONANCE: 6977 (END 1043, INNER 5934)
- MULTI: 98 (END 46, INNER 52)

By confidence:

- HIGH: 1021
- MED: 12054
- LOW: 938

## Core

- Core Y: 13761
- Core N among rhyme pairs: 252

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 6169 (44.0%)
- vowel: 6977 (49.8%)
- spelling: 769 (5.5%)
- multi: 98 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 53 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed. Millions is one bar, so its order is not called alphabetical.

- Young Thug | Boy Back | 44 lyric lines
- Young Stoner Life & Young Thug | Came and Saw | 49 lyric lines
- Young Thug | Ecstasy | 12 lyric lines
- Young Thug | Hop Off a Jet | 9 lyric lines
- Young Thug | Hot (Remix) | 80 lyric lines
- Young Stoner Life & Young Thug | Moon Man | 34 lyric lines
- Young Stoner Life & Young Thug | My City (Remix) | 49 lyric lines
- Young Stoner Life & Young Thug | No Surprise | 43 lyric lines
- Young Stoner Life, Young Thug & Gunna | Paid the Fine | 61 lyric lines
- Young Thug | Pussy | 42 lyric lines
- Young Stoner Life, Young Thug & Gunna | Ski | 33 lyric lines
- Young Stoner Life, Young Thug & Gunna | Slatty | 65 lyric lines
- Young Thug | Sup Mate | 81 lyric lines
- Young Thug | Surf | 61 lyric lines

## Top 20 families

1. `vow:IH` — 1391 pairs (END 226, INNER 1165). Words: bitch, shit, bitches, big, wrist, lil, think, business.
2. `vow:OW` — 905 pairs (END 74, INNER 831). Words: don't, no, know, told, go, ho, won't, gold.
3. `vow:EH` — 764 pairs (END 101, INNER 663). Words: get, gettin, tell, when, never, every, let's, left.
4. `vow:AE` — 708 pairs (END 161, INNER 547). Words: can't, man, had, back, racks, can, bad, ass.
5. `vow:AA` — 654 pairs (END 73, INNER 581). Words: got, want, nothin, not, top, gotta, card, cops.
6. `vow:EY` — 612 pairs (END 91, INNER 521). Words: ain't, play, say, baby, way, stay, came, day.
7. `vow:AY` — 586 pairs (END 97, INNER 489). Words: like, diamonds, by, ridin, fly, die, why, life.
8. `vow:IY` — 532 pairs (END 112, INNER 420). Words: see, three, shawty, need, streets, these, seats, feel.
9. `vow:AH` — 452 pairs (END 46, INNER 406). Words: hundred, fuck, come, one, some, done, somethin, fuckin.
10. `slant:AA:stop` — 367 pairs (END 27, INNER 340). Words: got, not, gotta, want, block, opp, top, bought.
11. `slant:IH:sib-stop` — 303 pairs (END 38, INNER 265). Words: bitch, shit, hit, rich, big, stick, dick, niggas.
12. `slant:IH:stop` — 292 pairs (END 38, INNER 254). Words: nigga, shit, big, hit, stick, dick, wrist, kick.
13. `slant:AE:stop` — 221 pairs (END 56, INNER 165). Words: slatt, slatty, back, bad, had, can't, bag, brand.
14. `slant:EH:stop` — 188 pairs (END 20, INNER 168). Words: get, let, neck, went, head, check, red, twenty.
15. `slant:IH:liq-stop` — 168 pairs (END 4, INNER 164). Words: shit, lil, still, big, really, crib, 'til, kill.
16. `slant:AH:nas-stop` — 165 pairs (END 5, INNER 160). Words: fuck, some, what, come, young, one, money, thug.
17. `slant:AY:stop` — 150 pairs (END 10, INNER 140). Words: like, right, side, might, ride, light, night, white.
18. `slant:EH:nas-stop` — 148 pairs (END 28, INNER 120). Words: when, get, gettin, again, head, ten, let, send.
19. `cmu:OW` — 139 pairs (END 12, INNER 127). Words: no, know, go, ho, show, throw, blow, bro.
20. `slant:AE:sib-stop` — 136 pairs (END 39, INNER 97). Words: ass, back, racks, bad, cash, had, sack, relax.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 130 pair sides, mostly spelling via spelling phonetic key, often with shit (18)
- gon — 62 pair sides, mostly spelling via spelling phonetic key, often with dont (24)
- ima — 56 pair sides, mostly spelling via spelling phonetic key, often with shit (8)
- slatt — 54 pair sides, mostly spelling via spelling phonetic key, often with slatty (40)
- tryna — 47 pair sides, mostly spelling via spelling phonetic key, often with these (8)
- slatty — 47 pair sides, mostly spelling via spelling phonetic key, often with slatt (40)
- shawty — 44 pair sides, mostly vowel via spelling phonetic key, often with money (3)
- niggas — 29 pair sides, mostly spelling via spelling phonetic key, often with nigga (14)
- birkin — 18 pair sides, mostly vowel via spelling phonetic key, often with bitch (4)
- gunna — 14 pair sides, mostly spelling via spelling phonetic key, often with one (2)
- dawg — 14 pair sides, mostly spelling via spelling phonetic key, often with all (5)
- wussy — 14 pair sides, mostly vowel via spelling phonetic key, often with pussy (12)
- piranhas — 14 pair sides, mostly vowel via vault phonetic_class, often with slatts (4)
- bidness — 13 pair sides, mostly spelling via spelling phonetic key, often with witness (3)
- molto — 12 pair sides, mostly vowel via spelling phonetic key, often with no (3)
- opps — 12 pair sides, mostly vowel via spelling phonetic key, often with dont (5)
- thot — 12 pair sides, mostly spelling via spelling phonetic key, often with not (5)
- bling — 12 pair sides, mostly spelling via spelling phonetic key, often with wrist (2)
- tris — 12 pair sides, mostly spelling via spelling phonetic key, often with bitch (3)
- lyin — 11 pair sides, mostly spelling via spelling phonetic key, often with eat (2)
- popo — 11 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- thugger — 11 pair sides, mostly vowel via vault phonetic_class, often with hundred (1)
- rari — 10 pair sides, mostly spelling via spelling phonetic key, often with bad (4)
- kizzy — 10 pair sides, mostly cmu via vault phonetic_class, often with get (1)
- sike — 9 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- coolie — 9 pair sides, mostly spelling via spelling phonetic key, often with woolie (1)
- roofy — 9 pair sides, mostly spelling via spelling phonetic key, often with woolie (1)
- rackity — 8 pair sides, mostly vowel via spelling phonetic key, often with knapity (2)
- neets — 8 pair sides, mostly spelling via spelling phonetic key, often with street (2)
- slatts — 8 pair sides, mostly spelling via spelling phonetic key, often with rats (4)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Young Thug | Audemar (Demo) | 64 | 113 | 224 | loose |
| Young Thug | Bad Bad Bad | 49 | 64 | 267 | loose |
| Big Sean | Big Bidness | 73 | 61 | 484 | loose |
| Young Thug | Big Racks | 58 | 72 | 210 | loose |
| Young Thug | Big Tipper | 61 | 26 | 423 | loose |
| Young Thug | Boy Back | 44 | 41 | 226 | loose |
| Young Stoner Life & Young Thug | Came and Saw | 49 | 40 | 174 | loose |
| Young Thug | Cartier Gucci Scarf | 64 | 15 | 200 | loose |
| Young Thug | Chanel (Go Get It) [Demo 2] | 63 | 105 | 210 | loose |
| Young Thug | Chanel (Go Get It) [Remix] | 26 | 27 | 146 | loose |
| Young Thug | Circle of Bosses | 59 | 40 | 165 | loose |
| Young Thug | Diamonds | 84 | 38 | 296 | loose |
| Young Thug | Die Today | 36 | 22 | 200 | loose |
| Young Thug | Ecstasy | 12 | 5 | 23 | loose |
| Young Thug | Finish The Task | 39 | 71 | 272 | loose |
| Young Thug | Goin Overseas | 51 | 40 | 133 | loose |
| Young Thug | High School | 26 | 19 | 87 | loose |
| Young Thug | Hop Off a Jet | 9 | 1 | 22 | loose |
| Young Thug | Hot (Remix) | 80 | 53 | 366 | loose |
| Young Thug | I'm Scared | 49 | 24 | 375 | loose |
| Young Thug | Imma Go* | 5 | 2 | 3 | loose |
| Young Thug | Jumped Out The Window | 43 | 44 | 241 | loose |
| Young Thug | Just How It Is | 46 | 59 | 283 | loose |
| Young Thug | Light It Up | 48 | 18 | 130 | loose |
| Young Thug | Lil Baby | 19 | 22 | 69 | loose |
| Young Stoner Life & Young Thug | Mack Truck | 40 | 14 | 213 | loose |
| Young Thug | Mannequin Challenge | 52 | 29 | 106 | loose |
| Young Thug | Marilyn Manson | 46 | 58 | 273 | loose |
| Young Stoner Life & Young Thug | Mil in Vegas | 47 | 28 | 237 | loose |
| Young Thug | Millions | 1 | 0 | 0 | loose |
| Young Stoner Life & Young Thug | Mob Ties Remix | 93 | 50 | 164 | loose |
| Young Thug | Money Hit (Remix)* | 78 | 88 | 231 | loose |
| Young Stoner Life & Young Thug | Moon Man | 34 | 13 | 179 | loose |
| Young Stoner Life & Young Thug | My City (Remix) | 49 | 32 | 399 | loose |
| Young Stoner Life & Young Thug | No Surprise | 43 | 30 | 218 | loose |
| Young Thug | Now | 50 | 76 | 230 | loose |
| Young Stoner Life, Young Thug & Gunna | Paid the Fine | 61 | 26 | 347 | loose |
| Young Stoner Life & Young Thug | Proud of You | 55 | 33 | 132 | loose |
| Young Thug | Pussy | 42 | 23 | 181 | loose |
| Young Stoner Life, Young Thug & Gunna | Ski | 33 | 27 | 251 | loose |
| Young Stoner Life, Young Thug & Gunna | Slam the Door | 58 | 19 | 221 | loose |
| Young Stoner Life, Young Thug & Gunna | Slatty | 65 | 42 | 262 | loose |
| Young Stoner Life, Young Thug & Gunna | Solid | 72 | 39 | 256 | loose |
| Young Thug | Sup Mate | 81 | 39 | 327 | loose |
| Young Stoner Life & Young Thug | Superstar | 23 | 15 | 126 | loose |
| Young Thug | Surf | 61 | 56 | 297 | loose |
| Young Stoner Life, Young Thug & Gunna | Take It to Trial | 50 | 43 | 284 | loose |
| Young Stoner Life, Young Thug & Meek Mill | That Go! | 76 | 63 | 398 | loose |
| Young Thug | Walk Down | 44 | 49 | 214 | loose |
| Young Thug | Want Me Dead | 55 | 90 | 302 | loose |
| Young Thug | Whaddup Jesus | 40 | 28 | 234 | loose |
| Young Thug | What's the Move | 75 | 38 | 162 | loose |
| Young Thug | Wit Da Racks | 78 | 123 | 347 | loose |
