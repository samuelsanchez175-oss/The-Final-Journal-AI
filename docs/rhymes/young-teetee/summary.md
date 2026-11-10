# Young TeeTee rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Young TeeTee
- Songs: 1
- Bars kept (Young TeeTee lyric lines): 38
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Young TeeTee.
- Credit strings: Young TeeTee.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 207
- REPEAT pairs, recorded separately: 34
- END rhymes: 47
- INNER rhymes: 160

By match:

- PERFECT: 8 (END 0, INNER 8)
- SLANT: 112 (END 20, INNER 92)
- ASSONANCE: 78 (END 23, INNER 55)
- MULTI: 9 (END 4, INNER 5)

By confidence:

- HIGH: 11
- MED: 178
- LOW: 18

## Core

- Core Y: 207
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 100 (48.3%)
- vowel: 78 (37.7%)
- spelling: 20 (9.7%)
- multi: 9 (4.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 28 pairs (END 12, INNER 16). Words: nothing, stomach, guns, dumpin, blunts, fronting, coming, fuckin.
2. `slant:IH:stop` — 20 pairs (END 3, INNER 17). Words: nigga, kid, shit, whip, sick, big, clip, sip.
3. `slant:AH:nas` — 19 pairs (END 5, INNER 14). Words: coming, runnin, money, honey, nothing, dumpin, done, summer.
4. `vow:OW` — 19 pairs (END 3, INNER 16). Words: hold, don't, o, know, blow, chokin, smokin, smoke.
5. `slant:IH:sib-stop` — 17 pairs (END 8, INNER 9). Words: bitch, shit, whip, sick, kid, twitter, hit, big.
6. `vow:IH` — 13 pairs (END 5, INNER 8). Words: bitch, wrist, killed, building, shit, whip, sick, sip.
7. `slant:AH:nas-stop` — 8 pairs (END 1, INNER 7). Words: money, what, club, fuck, done, summer, coming, stomach.
8. `vow:IY` — 6 pairs (END 2, INNER 4). Words: mean, see, probably, even.
9. `vow:AE` — 5 pairs (END 0, INNER 5). Words: cracking, ballin, bag, had, stacked, savage, cashed.
10. `multi:AW-L-D-AH` — 4 pairs (END 0, INNER 4). Words: coulda, shoulda, woulda, nigga coulda, cracking woulda.
11. `slant:EH:liq-stop` — 4 pairs (END 0, INNER 4). Words: tell, get, step, neck.
12. `cmu:OW` — 3 pairs (END 0, INNER 3). Words: know, blow, o, go, foe.
13. `multi:OW-K-IH-NG` — 3 pairs (END 3, INNER 0). Words: smoking, chokin, smokin.
14. `slant:AE:stop` — 3 pairs (END 0, INNER 3). Words: bag, had, stacked.
15. `slant:AH:nas-sib` — 3 pairs (END 2, INNER 1). Words: guns, money, honey, runnin.
16. `slant:EH:nas-stop` — 3 pairs (END 0, INNER 3). Words: when, step, get, neck.
17. `slant:EH:stop` — 3 pairs (END 0, INNER 3). Words: step, get, neck.
18. `slant:IH:liq-sib` — 3 pairs (END 0, INNER 3). Words: bitch, still, will.
19. `slant:IH:liq-stop` — 3 pairs (END 0, INNER 3). Words: still, shit, kid, twitter, will.
20. `slant:AO:liq-nas` — 2 pairs (END 0, INNER 2). Words: long, four, pour.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 12 pair sides, mostly spelling via spelling phonetic key, often with kid (4)
- coulda — 3 pair sides, mostly multi via spelling phonetic key, often with woulda (2)
- woulda — 3 pair sides, mostly multi via spelling phonetic key, often with coulda (2)
- stuntin — 2 pair sides, mostly spelling via spelling phonetic key, often with fronting (1)
- shoulda — 2 pair sides, mostly multi via spelling phonetic key, often with coulda (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- choppa — 1 pair sides, mostly spelling via spelling phonetic key, often with smoke (1)
- nem — 1 pair sides, mostly spelling via spelling phonetic key, often with pen (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Young TeeTee | You Ain’t 100 | 38 | 47 | 160 | loose |
