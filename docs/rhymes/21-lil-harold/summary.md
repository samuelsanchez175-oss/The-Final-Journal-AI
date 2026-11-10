# 21 Lil Harold rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 21 Lil Harold
- Songs: 5
- Bars kept (21 Lil Harold lyric lines): 218
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 2
- Canonical name: 21 Lil Harold.
- Credit strings: 21 Lil Harold.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1634
- REPEAT pairs, recorded separately: 176
- END rhymes: 248
- INNER rhymes: 1386

By match:

- PERFECT: 168 (END 55, INNER 113)
- SLANT: 710 (END 77, INNER 633)
- ASSONANCE: 746 (END 113, INNER 633)
- MULTI: 10 (END 3, INNER 7)

By confidence:

- HIGH: 167
- MED: 1336
- LOW: 131

## Core

- Core Y: 1599
- Core N among rhyme pairs: 35

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 769 (47.1%)
- vowel: 746 (45.7%)
- spelling: 109 (6.7%)
- multi: 10 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 5 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 141 pairs (END 26, INNER 115). Words: hundred, somethin, come, truck, love, bust, guns, what's.
2. `vow:OW` — 139 pairs (END 21, INNER 118). Words: don't, ho, no, smoke, rolls, know, go, broke.
3. `vow:IH` — 101 pairs (END 9, INNER 92). Words: bitches, shit, think, kids, dissin, bitch, since, fill.
4. `vow:AW` — 60 pairs (END 28, INNER 32). Words: thou, now, down, rounds, town, bounds, around, sundown.
5. `vow:AY` — 57 pairs (END 16, INNER 41). Words: like, die, y, by, cry, homicide, shinin, kind.
6. `vow:IY` — 52 pairs (END 2, INNER 50). Words: these, thirty, keep, see, speakin, evenin, shawty, free.
7. `vow:EH` — 51 pairs (END 1, INNER 50). Words: memphis, seven, get, sense, feds, married, extension, said.
8. `vow:AA` — 50 pairs (END 6, INNER 44). Words: talkin, dark, partner, gotta, got, dropped, mamas, drop.
9. `slant:AA:stop` — 48 pairs (END 8, INNER 40). Words: got, glock, lot, gotta, hop, not, dropped, top.
10. `vow:AE` — 44 pairs (END 3, INNER 41). Words: can't, goddamn, cap, rap, daddy, had, wax, fast.
11. `cmu:OW` — 41 pairs (END 16, INNER 25). Words: ho, no, know, though, go, low, show, bro.
12. `slant:IH:stop` — 37 pairs (END 6, INNER 31). Words: nigga, shit, flip, broomstick, tip, hit, stick, titty.
13. `vow:EY` — 34 pairs (END 1, INNER 33). Words: ain't, make, way, baby, oj, braids, shake, pay.
14. `slant:IH:sib-stop` — 33 pairs (END 1, INNER 32). Words: bitch, nigga, shit, niggas, triggers, rich, blitz, hip.
15. `slant:AE:stop` — 27 pairs (END 3, INNER 24). Words: had, back, whacked, daddy, splat, strap, rap, adapt.
16. `slant:AH:stop` — 27 pairs (END 12, INNER 15). Words: fuck, nut, trunk, bust, what, jumped, gut, truck.
17. `slant:AH:nas-stop` — 25 pairs (END 2, INNER 23). Words: come, fuck, what, done, run, sunup, money, dub.
18. `slant:AH:nas` — 21 pairs (END 3, INNER 18). Words: bummy, tongue, money, done, fun, some, come, runnin.
19. `slant:EH:liq-stop` — 19 pairs (END 1, INNER 18). Words: where, get, said, everywhere, yellow, military, better, check.
20. `slant:AY:stop` — 17 pairs (END 1, INNER 16). Words: like, sided, rider, outside, type, died, right, side.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 32 pair sides, mostly spelling via spelling phonetic key, often with shit (5)
- ima — 23 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- niggas — 10 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)
- bummy — 9 pair sides, mostly spelling via spelling phonetic key, often with money (2)
- gon — 8 pair sides, mostly spelling via spelling phonetic key, often with dont (4)
- thot — 6 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- titty — 5 pair sides, mostly spelling via spelling phonetic key, often with stingy (1)
- repasado — 5 pair sides, mostly vowel via spelling phonetic key, often with ho (2)
- opps — 4 pair sides, mostly vowel via spelling phonetic key, often with dont (2)
- bap — 4 pair sides, mostly spelling via spelling phonetic key, often with had (1)
- shawty — 4 pair sides, mostly vowel via spelling phonetic key, often with baby (1)
- glocky — 4 pair sides, mostly vowel via spelling phonetic key, often with pussy (2)
- eazy — 3 pair sides, mostly vowel via spelling phonetic key, often with e (1)
- stuntin — 3 pair sides, mostly spelling via spelling phonetic key, often with blunt (1)
- diamondback — 3 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- bronem — 3 pair sides, mostly vowel via spelling phonetic key, often with closer (1)
- hunds — 2 pair sides, mostly spelling via spelling phonetic key, often with ones (1)
- glocks — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- dawg — 2 pair sides, mostly spelling via spelling phonetic key, often with all (1)
- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with real (1)
- raq — 2 pair sides, mostly spelling via spelling phonetic key, often with rap (1)
- sparxx — 2 pair sides, mostly vowel via spelling phonetic key, often with dark (1)
- pendent — 2 pair sides, mostly vowel via spelling phonetic key, often with when (1)
- hobos — 1 pair sides, mostly vowel via spelling phonetic key, often with promo (1)
- ibaka — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- drac — 1 pair sides, mostly spelling via spelling phonetic key, often with rari (1)
- rari — 1 pair sides, mostly spelling via spelling phonetic key, often with drac (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with turn (1)
- migo — 1 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 21 Lil Harold | Ain’t On None | 31 | 17 | 158 | loose |
| 21 Lil Harold | Damn | 57 | 87 | 444 | loose |
| 21 Lil Harold | Johnny | 44 | 41 | 250 | loose |
| 21 Lil Harold | Nookie (Pu$$y) | 40 | 37 | 251 | loose |
| 21 Lil Harold | One in the Head | 46 | 66 | 283 | loose |
