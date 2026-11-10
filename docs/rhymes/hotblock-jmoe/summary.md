# HotBlock Jmoe rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: HotBlock Jmoe
- Songs: 4
- Bars kept (HotBlock Jmoe lyric lines): 192
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 2
- Canonical name: HotBlock Jmoe.
- Credit strings: HotBlock Jmoe.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1649
- REPEAT pairs, recorded separately: 124
- END rhymes: 262
- INNER rhymes: 1387

By match:

- PERFECT: 164 (END 21, INNER 143)
- SLANT: 693 (END 109, INNER 584)
- ASSONANCE: 780 (END 128, INNER 652)
- MULTI: 12 (END 4, INNER 8)

By confidence:

- HIGH: 167
- MED: 1333
- LOW: 149

## Core

- Core Y: 1605
- Core N among rhyme pairs: 44

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 744 (45.1%)
- vowel: 780 (47.3%)
- spelling: 113 (6.9%)
- multi: 12 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 4 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 198 pairs (END 24, INNER 174). Words: no, don't, know, go, only, post, whole, broke.
2. `vow:IH` — 173 pairs (END 58, INNER 115). Words: fifty, shit, livin, him, think, trippin, bitch, killed.
3. `vow:AA` — 78 pairs (END 17, INNER 61). Words: karma, watchin, got, everybody, toxic, rotten, forgotten, rocket.
4. `cmu:OW` — 71 pairs (END 5, INNER 66). Words: go, know, no, throw, bro, solo, photo, promo.
5. `vow:AE` — 70 pairs (END 5, INNER 65). Words: stand, catch, can't, savage, ask, dallas, back, bad.
6. `vow:AY` — 56 pairs (END 1, INNER 55). Words: right, ridin, by, like, grind, try, high, times.
7. `vow:EH` — 55 pairs (END 1, INNER 54). Words: get, let's, remember, sendin, trenches, every, deaths, when.
8. `slant:AA:stop` — 49 pairs (END 8, INNER 41). Words: got, stop, everybody, not, gotta, rock, glock, rocket.
9. `slant:IH:stop` — 49 pairs (END 8, INNER 41). Words: shit, nigga, quick, whip, litty, bibby, sit, tick.
10. `slant:IH:liq-stop` — 46 pairs (END 0, INNER 46). Words: shit, still, really, quick, lil, fill, 'til, molehill.
11. `vow:IY` — 44 pairs (END 0, INNER 44). Words: even, see, feelin, key, weeks, g, three, peep.
12. `vow:EY` — 41 pairs (END 4, INNER 37). Words: ain't, away, way, stay, face, grave, day, takin.
13. `slant:IH:sib-stop` — 37 pairs (END 2, INNER 35). Words: bitch, shit, nigga, niggas, rich, switch, quick, hit.
14. `slant:AA:nas-stop` — 35 pairs (END 8, INNER 27). Words: wanna, got, plottin, forgotten, not, rotten, hot, stop.
15. `slant:IH:nas-stop` — 32 pairs (END 5, INNER 27). Words: shit, him, i'ma, thing, whip, pick, quick, spin.
16. `vow:AW` — 25 pairs (END 13, INNER 12). Words: now, down, 'round, 'bout, how, around, thousand.
17. `slant:IH:liq-sib` — 23 pairs (END 1, INNER 22). Words: bitch, still, lil, really, rich, millis, diss, switch.
18. `vow:UW` — 19 pairs (END 5, INNER 14). Words: shootouts, move, confused, rules, few, noon, ku, rudy.
19. `vow:AH` — 17 pairs (END 0, INNER 17). Words: fuck, fuckin, what, justice, blunted, touched, one, jump.
20. `slant:IH:nas` — 16 pairs (END 5, INNER 11). Words: trippin, him, livin, drillin, bringin, missin, killin, finna.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 23 pair sides, mostly spelling via spelling phonetic key, often with dont (7)
- nigga — 22 pair sides, mostly spelling via spelling phonetic key, often with shit (8)
- ima — 16 pair sides, mostly spelling via spelling phonetic key, often with shit (6)
- soso — 14 pair sides, mostly vowel via spelling phonetic key, often with solo (1)
- niggas — 9 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)
- noho — 9 pair sides, mostly vowel via spelling phonetic key, often with bro (1)
- tryna — 8 pair sides, mostly spelling via spelling phonetic key, often with beef (2)
- opps — 8 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- herbo — 7 pair sides, mostly vowel via spelling phonetic key, often with go (3)
- motherload — 4 pair sides, mostly spelling via spelling phonetic key, often with chokehold (1)
- shiesty — 3 pair sides, mostly vowel via spelling phonetic key, often with mally (1)
- 4gen — 3 pair sides, mostly spelling via spelling phonetic key, often with every (1)
- swishers — 3 pair sides, mostly vowel via spelling phonetic key, often with picture (1)
- bap — 3 pair sides, mostly spelling via spelling phonetic key, often with cap (1)
- homie — 3 pair sides, mostly spelling via spelling phonetic key, often with flowin (1)
- finna — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- rnet — 3 pair sides, mostly spelling via spelling phonetic key, often with get (2)
- wifey — 3 pair sides, mostly spelling via spelling phonetic key, often with still (1)
- birkin — 3 pair sides, mostly vowel via spelling phonetic key, often with still (1)
- meds — 2 pair sides, mostly spelling via spelling phonetic key, often with head (1)
- hotblock — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- getin — 2 pair sides, mostly vowel via spelling phonetic key, often with sendin (1)
- raq — 1 pair sides, mostly spelling via spelling phonetic key, often with blacks (1)
- glizzys — 1 pair sides, mostly spelling via spelling phonetic key, often with distance (1)
- tatted — 1 pair sides, mostly spelling via spelling phonetic key, often with taxed (1)
- colfax — 1 pair sides, mostly spelling via spelling phonetic key, often with rolex (1)
- homies — 1 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- tiktok — 1 pair sides, mostly spelling via spelling phonetic key, often with ziplocked (1)
- ziplocked — 1 pair sides, mostly spelling via spelling phonetic key, often with tiktok (1)
- int — 1 pair sides, mostly spelling via spelling phonetic key, often with finish (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| HotBlock Jmoe | FASHO | 34 | 54 | 436 | loose |
| HotBlock Jmoe | Long Road | 65 | 95 | 346 | loose |
| HotBlock Jmoe | ROTTEN | 34 | 51 | 195 | loose |
| HotBlock Jmoe | TO THE GRAVE | 59 | 62 | 410 | loose |
