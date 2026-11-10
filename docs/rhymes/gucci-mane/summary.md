# Gucci Mane rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Gucci Mane
- Songs: 27
- Bars kept (Gucci Mane lyric lines): 1190
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Gucci Mane.
- Credit strings: Gucci Mane.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 7243
- REPEAT pairs, recorded separately: 1034
- END rhymes: 1237
- INNER rhymes: 6006

By match:

- PERFECT: 623 (END 161, INNER 462)
- SLANT: 3193 (END 595, INNER 2598)
- ASSONANCE: 3345 (END 457, INNER 2888)
- MULTI: 82 (END 24, INNER 58)

By confidence:

- HIGH: 638
- MED: 6157
- LOW: 448

## Core

- Core Y: 7146
- Core N among rhyme pairs: 97

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 3400 (46.9%)
- vowel: 3345 (46.2%)
- spelling: 416 (5.7%)
- multi: 82 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 27 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 480 pairs (END 47, INNER 433). Words: bitch, think, bitches, bricks, wrist, fifty, shit, didn't.
2. `vow:OW` — 456 pairs (END 56, INNER 400). Words: don't, know, no, dope, go, smoke, hoes, ho.
3. `vow:AA` — 424 pairs (END 55, INNER 369). Words: got, hard, constantly, want, top, cops, dark, darker.
4. `vow:EH` — 410 pairs (END 71, INNER 339). Words: get, getting, send, bentley, aggressive, where, never, already.
5. `vow:AE` — 334 pairs (END 28, INNER 306). Words: can't, grams, hands, have, man, damn, bad, bands.
6. `vow:AY` — 325 pairs (END 57, INNER 268). Words: like, diamonds, try, fly, time, license, by, why.
7. `slant:AA:stop` — 283 pairs (END 40, INNER 243). Words: got, top, drop, darker, block, bought, pop, shopped.
8. `vow:EY` — 262 pairs (END 43, INNER 219). Words: ain't, say, make, day, baby, made, take, pay.
9. `vow:AH` — 220 pairs (END 34, INNER 186). Words: hundred, fuck, fucking, one, money, some, come, ugly.
10. `vow:IY` — 209 pairs (END 34, INNER 175). Words: need, even, these, see, keep, feel, d, g.
11. `slant:IH:stop` — 161 pairs (END 24, INNER 137). Words: nigga, shit, hit, big, brick, think, dick, lick.
12. `slant:IH:sib-stop` — 141 pairs (END 46, INNER 95). Words: bitch, shit, nigga, niggas, hit, big, whips, bitchy.
13. `slant:AH:nas` — 95 pairs (END 12, INNER 83). Words: money, some, sumn, one, run, fuckin, young, done.
14. `slant:AA:sib-stop` — 89 pairs (END 17, INNER 72). Words: cause, got, watch, father, charger, darker, drop, dark.
15. `slant:AE:nas-stop` — 89 pairs (END 9, INNER 80). Words: man, can, grand, damn, chapo, can't, gang, had.
16. `slant:AE:stop` — 83 pairs (END 18, INNER 65). Words: back, trap, had, pack, cab, strap, clapped, intact.
17. `cmu:OW` — 77 pairs (END 10, INNER 67). Words: know, show, go, no, ho, throw, low, co.
18. `vow:AW` — 76 pairs (END 14, INNER 62). Words: now, how, mountain, down, around, house, bow, mouth.
19. `slant:IH:nas-stop` — 75 pairs (END 20, INNER 55). Words: him, shit, i'ma, hit, pimping, limp, crib, dick.
20. `slant:EH:nas-stop` — 70 pairs (END 9, INNER 61). Words: any, let, when, get, many, head, men, stepper.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 93 pair sides, mostly spelling via spelling phonetic key, often with niggas (26)
- niggas — 33 pair sides, mostly spelling via spelling phonetic key, often with nigga (26)
- ima — 32 pair sides, mostly spelling via spelling phonetic key, often with him (6)
- gon — 17 pair sides, mostly spelling via spelling phonetic key, often with hoes (4)
- chapo — 16 pair sides, mostly vowel via spelling phonetic key, often with gang (2)
- tryna — 14 pair sides, mostly spelling via spelling phonetic key, often with eat (1)
- guwop — 13 pair sides, mostly spelling via spelling phonetic key, often with dope (3)
- blama — 13 pair sides, mostly spelling via spelling phonetic key, often with hands (3)
- blicky — 12 pair sides, mostly spelling via spelling phonetic key, often with sticky (2)
- sumn — 12 pair sides, mostly spelling via spelling phonetic key, often with somethin (5)
- jit — 10 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- thots — 9 pair sides, mostly spelling via spelling phonetic key, often with pots (3)
- buh — 9 pair sides, mostly spelling via spelling phonetic key, often with buck (2)
- shawty — 8 pair sides, mostly spelling via spelling phonetic key, often with long (1)
- fam — 8 pair sides, mostly spelling via spelling phonetic key, often with half (2)
- dro — 7 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- setted — 7 pair sides, mostly vowel via spelling phonetic key, often with tell (1)
- choker — 7 pair sides, mostly spelling via spelling phonetic key, often with choke (1)
- cosigning — 6 pair sides, mostly spelling via spelling phonetic key, often with surprising (1)
- slanger — 6 pair sides, mostly vowel via spelling phonetic key, often with banger (2)
- jag — 6 pair sides, mostly spelling via spelling phonetic key, often with bags (2)
- tunk — 6 pair sides, mostly spelling via spelling phonetic key, often with trunk (1)
- strokers — 6 pair sides, mostly spelling via spelling phonetic key, often with poker (1)
- bling — 5 pair sides, mostly vowel via spelling phonetic key, often with think (1)
- lamest — 5 pair sides, mostly vowel via spelling phonetic key, often with language (2)
- celly — 5 pair sides, mostly vowel via spelling phonetic key, often with already (4)
- presi — 5 pair sides, mostly spelling via spelling phonetic key, often with jelly (1)
- icey — 5 pair sides, mostly spelling via spelling phonetic key, often with big (1)
- deebo — 5 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- bando — 5 pair sides, mostly spelling via spelling phonetic key, often with know (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Gucci Mane | 06 Gucci | 47 | 66 | 274 | loose |
| Gucci Mane | Aggressive (Remix) | 40 | 47 | 231 | loose |
| Gucci Mane | All These Bitches | 39 | 39 | 316 | loose |
| Gucci Mane | Baby Daddy Broke | 29 | 27 | 133 | loose |
| Gucci Mane | Backseat | 53 | 44 | 264 | loose |
| Gucci Mane | Banger | 34 | 32 | 131 | loose |
| Gucci Mane | Big Boy Diamonds | 51 | 64 | 213 | loose |
| Gucci Mane | Blama on Ya | 45 | 23 | 294 | loose |
| Gucci Mane | Bring Them Things | 71 | 84 | 214 | loose |
| Gucci Mane | Constantly | 40 | 33 | 163 | loose |
| Gucci Mane | Darker | 47 | 54 | 336 | loose |
| Gucci Mane | Dirt Cheap (Original Version) | 23 | 35 | 116 | loose |
| Gucci Mane | Don’t Lose No Load | 36 | 50 | 173 | loose |
| Gucci Mane | Down | 44 | 25 | 216 | loose |
| Gucci Mane | First Day of School | 30 | 6 | 81 | loose |
| Gucci Mane | Just Like It | 50 | 58 | 171 | loose |
| Gucci Mane | King Snipe | 57 | 62 | 310 | loose |
| Gucci Mane | Last Night (Remix) | 48 | 81 | 200 | loose |
| Gucci Mane | Nasty | 48 | 57 | 340 | loose |
| Gucci Mane | Peepin | 34 | 30 | 148 | loose |
| Gucci Mane | Semi on Em | 32 | 52 | 217 | loose |
| Gucci Mane | So Much Money (WW3) | 59 | 34 | 389 | loose |
| Gucci Mane | Start Pimpin’ | 31 | 44 | 168 | loose |
| Gucci Mane | Sumn Sumn | 35 | 38 | 268 | loose |
| Gucci Mane | Top in the Trash | 70 | 68 | 162 | loose |
| Gucci Mane | Turn Up | 58 | 51 | 285 | loose |
| Gucci Mane | Wake Up in the Sky | 39 | 33 | 193 | loose |
