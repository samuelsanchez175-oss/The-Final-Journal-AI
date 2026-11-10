# Young Thug rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Young Stoner Life & Young Thug, Young Stoner Life, Young Thug & Gunna, Young Stoner Life, Young Thug & Meek Mill, Young Thug
- Songs: 52
- Bars kept (Young Thug lyric lines): 2586
- Section headers dropped, not counted as bars: 3
- Genius page chrome dropped, not counted as bars: 85. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: Bad Bad Bad (5), Cartier Gucci Scarf (2), Circle of Bosses (4), Diamonds (6), Die Today (3), Hot (Remix) (3), I'm Scared (2), Jumped Out The Window (5), Mack Truck (5), My City (Remix) (3), No Surprise (3), Paid the Fine (6), Proud of You (4), Pussy (1), Ski (6), Slam the Door (4), Solid (6), Sup Mate (3), Superstar (4), Surf (4), That Go! (6)
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 19
- Thugger: no vault credit contains Thugger. Nothing under that name was opened.
- YSL (USA) does not contain Young Thug or Thugger. That credit was not opened.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the end, inner, multi, or low sheets, and they are not in the layer share.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 13468
- REPEAT pairs, recorded separately: 2239
- END rhymes: 2132
- INNER rhymes: 11336

By match:

- PERFECT: 947 (END 224, INNER 723)
- SLANT: 5724 (END 841, INNER 4883)
- ASSONANCE: 6712 (END 1023, INNER 5689)
- MULTI: 85 (END 44, INNER 41)

By confidence:

- HIGH: 956
- MED: 11611
- LOW: 901

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 5938 (44.1%)
- vowel: 6712 (49.8%)
- spelling: 733 (5.4%)
- multi: 85 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 52 songs

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

1. `vow:IH` — 1267 pairs (END 221, INNER 1046). Words: bitch, shit, bitches, wrist, big, lil, kids, think.
2. `vow:OW` — 865 pairs (END 68, INNER 797). Words: don't, no, know, told, go, won't, ho, gold.
3. `vow:EH` — 761 pairs (END 101, INNER 660). Words: get, gettin, tell, when, never, every, let's, left.
4. `vow:AE` — 695 pairs (END 161, INNER 534). Words: can't, had, back, man, racks, can, bad, ass.
5. `vow:AA` — 640 pairs (END 73, INNER 567). Words: got, want, nothin, top, not, gotta, card, cops.
6. `vow:EY` — 602 pairs (END 91, INNER 511). Words: ain't, play, say, baby, way, stay, came, pay.
7. `vow:AY` — 576 pairs (END 95, INNER 481). Words: like, diamonds, by, ridin, fly, die, why, life.
8. `vow:IY` — 515 pairs (END 112, INNER 403). Words: see, three, shawty, need, streets, these, feel, seats.
9. `vow:AH` — 437 pairs (END 45, INNER 392). Words: hundred, fuck, come, one, some, done, somethin, fuckin.
10. `slant:AA:stop` — 363 pairs (END 27, INNER 336). Words: got, not, want, gotta, block, opp, top, bought.
11. `slant:IH:sib-stop` — 288 pairs (END 38, INNER 250). Words: bitch, shit, hit, rich, stick, niggas, big, nigga.
12. `slant:IH:stop` — 279 pairs (END 38, INNER 241). Words: nigga, shit, big, hit, stick, dick, wrist, kick.
13. `slant:AE:stop` — 221 pairs (END 56, INNER 165). Words: slatt, slatty, back, bad, had, can't, bag, brand.
14. `slant:EH:stop` — 172 pairs (END 16, INNER 156). Words: get, let, neck, head, went, check, red, twenty.
15. `slant:IH:liq-stop` — 160 pairs (END 4, INNER 156). Words: shit, lil, still, big, really, crib, 'til, kill.
16. `slant:AH:nas-stop` — 159 pairs (END 5, INNER 154). Words: fuck, some, what, come, young, money, thug, one.
17. `slant:AY:stop` — 146 pairs (END 10, INNER 136). Words: like, right, side, might, ride, light, night, wipe.
18. `slant:EH:nas-stop` — 146 pairs (END 28, INNER 118). Words: when, get, gettin, again, head, ten, let, send.
19. `cmu:OW` — 136 pairs (END 12, INNER 124). Words: no, know, go, ho, show, throw, bro, blow.
20. `slant:AE:sib-stop` — 136 pairs (END 39, INNER 97). Words: ass, back, racks, bad, cash, had, sack, relax.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 130 pair sides, mostly spelling via spelling phonetic key, often with shit (18)
- gon — 60 pair sides, mostly spelling via spelling phonetic key, often with dont (24)
- ima — 56 pair sides, mostly spelling via spelling phonetic key, often with shit (8)
- slatt — 54 pair sides, mostly spelling via spelling phonetic key, often with slatty (40)
- slatty — 47 pair sides, mostly spelling via spelling phonetic key, often with slatt (40)
- tryna — 46 pair sides, mostly spelling via spelling phonetic key, often with these (8)
- shawty — 44 pair sides, mostly vowel via spelling phonetic key, often with money (3)
- niggas — 26 pair sides, mostly spelling via spelling phonetic key, often with nigga (14)
- birkin — 18 pair sides, mostly vowel via spelling phonetic key, often with bitch (4)
- gunna — 14 pair sides, mostly spelling via spelling phonetic key, often with one (2)
- dawg — 14 pair sides, mostly spelling via spelling phonetic key, often with all (5)
- wussy — 14 pair sides, mostly vowel via spelling phonetic key, often with pussy (12)
- piranhas — 14 pair sides, mostly vowel via vault phonetic_class, often with slatts (4)
- molto — 12 pair sides, mostly vowel via spelling phonetic key, often with no (3)
- opps — 12 pair sides, mostly vowel via spelling phonetic key, often with dont (5)
- thot — 12 pair sides, mostly spelling via spelling phonetic key, often with not (5)
- bling — 12 pair sides, mostly spelling via spelling phonetic key, often with wrist (2)
- tris — 12 pair sides, mostly spelling via spelling phonetic key, often with bitch (3)
- popo — 11 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- thugger — 11 pair sides, mostly vowel via vault phonetic_class, often with hundred (1)
- rari — 10 pair sides, mostly spelling via spelling phonetic key, often with bad (4)
- kizzy — 10 pair sides, mostly cmu via vault phonetic_class, often with get (1)
- coolie — 9 pair sides, mostly spelling via spelling phonetic key, often with woolie (1)
- roofy — 9 pair sides, mostly spelling via spelling phonetic key, often with woolie (1)
- rackity — 8 pair sides, mostly vowel via spelling phonetic key, often with knapity (2)
- neets — 8 pair sides, mostly spelling via spelling phonetic key, often with street (2)
- slatts — 8 pair sides, mostly spelling via spelling phonetic key, often with rats (4)
- hellcat — 7 pair sides, mostly spelling via spelling phonetic key, often with bat (3)
- zaddy — 7 pair sides, mostly spelling via spelling phonetic key, often with bad (5)
- bando — 7 pair sides, mostly vowel via spelling phonetic key, often with molto (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Young Thug | Audemar (Demo) | 64 | 113 | 224 | loose |
| Young Thug | Bad Bad Bad | 49 | 64 | 267 | loose |
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
