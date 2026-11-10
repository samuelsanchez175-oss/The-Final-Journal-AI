# Rob49 rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rob49
- Songs: 6
- Bars kept (Rob49 lyric lines): 389
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Rob49.
- Credit strings: Rob49.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 3023
- REPEAT pairs, recorded separately: 270
- END rhymes: 364
- INNER rhymes: 2659

By match:

- PERFECT: 214 (END 41, INNER 173)
- SLANT: 1420 (END 199, INNER 1221)
- ASSONANCE: 1346 (END 111, INNER 1235)
- MULTI: 43 (END 13, INNER 30)

By confidence:

- HIGH: 237
- MED: 2520
- LOW: 266

## Core

- Core Y: 2959
- Core N among rhyme pairs: 64

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1417 (46.9%)
- vowel: 1346 (44.5%)
- spelling: 217 (7.2%)
- multi: 43 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 6 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 231 pairs (END 13, INNER 218). Words: bitch, shit, since, big, rich, trippin, lil, giving.
2. `vow:OW` — 207 pairs (END 12, INNER 195). Words: don't, hoes, no, know, ho, go, smoke, post.
3. `vow:EH` — 176 pairs (END 21, INNER 155). Words: get, never, left, gettin, pregnant, spend, pendant, tell.
4. `vow:AH` — 156 pairs (END 22, INNER 134). Words: fuckin, hundred, somethin, fuck, what, come, done, fucked.
5. `vow:AE` — 132 pairs (END 9, INNER 123). Words: can't, platinum, back, trap, actin, active, savage, i'ma.
6. `vow:IY` — 120 pairs (END 10, INNER 110). Words: even, see, b, flee, need, free, ease, streets.
7. `vow:AA` — 112 pairs (END 13, INNER 99). Words: got, want, nothin, watch, talkin, dark, botherin, profit.
8. `slant:IH:sib-stop` — 95 pairs (END 12, INNER 83). Words: bitch, shit, rich, niggas, nigga, dick, big, switch.
9. `vow:EY` — 89 pairs (END 7, INNER 82). Words: ain't, make, playin, made, day, famous, basic, k.
10. `slant:IH:stop` — 81 pairs (END 5, INNER 76). Words: shit, nigga, big, lick, dick, city, bity, quick.
11. `vow:AY` — 61 pairs (END 0, INNER 61). Words: like, ridin, diamonds, why, outside, by, fly, right.
12. `slant:IH:liq-stop` — 56 pairs (END 3, INNER 53). Words: shit, lil, big, really, kill, still, mill, filled.
13. `slant:AA:stop` — 55 pairs (END 3, INNER 52). Words: got, not, pop, gotta, top, want, glock, popped.
14. `slant:AH:nas-stop` — 55 pairs (END 4, INNER 51). Words: fuck, one, what, come, done, some, young, fuckin.
15. `cmu:OW` — 45 pairs (END 1, INNER 44). Words: no, know, go, ho, bro, blow, throw, slow.
16. `slant:AE:stop` — 45 pairs (END 10, INNER 35). Words: back, bad, black, packed, smacked, clap, trap, mask.
17. `slant:EH:liq-stop` — 43 pairs (END 10, INNER 33). Words: tell, hell, get, check, already, shithead, skelly, zelle.
18. `slant:IY:nas-stop` — 43 pairs (END 5, INNER 38). Words: need, tryna, keep, green, lean, scene, seein, bleed.
19. `slant:EH:stop` — 39 pairs (END 4, INNER 35). Words: get, check, already, wet, neck, spaghetti, becky, went.
20. `slant:EH:liq` — 38 pairs (END 26, INNER 12). Words: helly, berry, hell, tell, zelle, melly, belly, celly.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 44 pair sides, mostly spelling via spelling phonetic key, often with shit (15)
- helly — 38 pair sides, mostly spelling via spelling phonetic key, often with zelle (4)
- tryna — 22 pair sides, mostly spelling via spelling phonetic key, often with need (5)
- niggas — 18 pair sides, mostly spelling via spelling phonetic key, often with nigga (12)
- ima — 17 pair sides, mostly spelling via spelling phonetic key, often with bitch (3)
- gon — 13 pair sides, mostly spelling via spelling phonetic key, often with dont (5)
- leav — 11 pair sides, mostly spelling via spelling phonetic key, often with need (2)
- 4ski — 9 pair sides, mostly vowel via spelling phonetic key, often with pills (3)
- presi — 9 pair sides, mostly spelling via spelling phonetic key, often with spaghetti (3)
- lyin — 7 pair sides, mostly spelling via spelling phonetic key, often with scene (2)
- tatted — 6 pair sides, mostly cmu via vault phonetic_class, often with truck (1)
- herbo — 6 pair sides, mostly vowel via spelling phonetic key, often with low (1)
- birkin — 6 pair sides, mostly vowel via spelling phonetic key, often with rich (2)
- celly — 6 pair sides, mostly spelling via spelling phonetic key, often with helly (2)
- bity — 5 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- jeezy — 5 pair sides, mostly spelling via spelling phonetic key, often with easy (1)
- cujo — 5 pair sides, mostly spelling via spelling phonetic key, often with another (1)
- glizzy — 4 pair sides, mostly vowel via spelling phonetic key, often with key (1)
- jag — 4 pair sides, mostly spelling via spelling phonetic key, often with ass (1)
- bap — 4 pair sides, mostly spelling via spelling phonetic key, often with cash (1)
- jit — 4 pair sides, mostly spelling via spelling phonetic key, often with lil (1)
- bty — 3 pair sides, mostly vowel via spelling phonetic key, often with brodie (1)
- rari — 3 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- gyal — 3 pair sides, mostly spelling via spelling phonetic key, often with beat (1)
- trapstar — 3 pair sides, mostly vowel via spelling phonetic key, often with black (1)
- franky — 3 pair sides, mostly vowel via spelling phonetic key, often with becky (1)
- bih — 3 pair sides, mostly spelling via spelling phonetic key, often with give (1)
- vski — 3 pair sides, mostly vowel via spelling phonetic key, often with drills (1)
- foenem — 2 pair sides, mostly spelling via spelling phonetic key, often with em (1)
- trackhawk — 2 pair sides, mostly vowel via spelling phonetic key, often with scat (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rob49 | Add It Up | 55 | 50 | 355 | loose |
| Rob49 | BLOODCLOT 2 | 4 | 1 | 23 | loose |
| Rob49 | Da Fuxk (Remix) | 157 | 152 | 1053 | loose |
| Rob49 | Skeme | 49 | 41 | 532 | loose |
| Rob49 | Trench Baby | 67 | 48 | 377 | loose |
| Rob49 | WTHELLY (Remix) | 57 | 72 | 319 | loose |
