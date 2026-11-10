# FBG Duck rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: FBG Duck
- Songs: 1
- Bars kept (FBG Duck lyric lines): 48
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: FBG Duck.
- Credit strings: FBG Duck.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 273
- REPEAT pairs, recorded separately: 26
- END rhymes: 53
- INNER rhymes: 220

By match:

- PERFECT: 13 (END 6, INNER 7)
- SLANT: 116 (END 22, INNER 94)
- ASSONANCE: 144 (END 25, INNER 119)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 13
- MED: 230
- LOW: 30

## Core

- Core Y: 266
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 105 (38.5%)
- vowel: 144 (52.7%)
- spelling: 24 (8.8%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 44 pairs (END 11, INNER 33). Words: damn, can't, accident, rappers, cannot, mans, actin, after.
2. `vow:IH` — 35 pairs (END 0, INNER 35). Words: bitch, trippin, itchin, shit, think, filled, kids, sixth.
3. `slant:IH:stop` — 17 pairs (END 0, INNER 17). Words: nigga, shit, big, hit, wit, trigger, finger, mid.
4. `vow:AH` — 13 pairs (END 1, INNER 12). Words: fuck, guns, coming, duckin, one, trust, slugs, bussin.
5. `slant:AY:stop` — 12 pairs (END 6, INNER 6). Words: slide, like, fired, quiet, right, tried, crucified, candlelight.
6. `vow:AY` — 12 pairs (END 6, INNER 6). Words: high, mines, like, hidin, ridin, right, quiet, tried.
7. `vow:UW` — 12 pairs (END 6, INNER 6). Words: school, due, shoot, coupes, knew, classroom, shootin, who.
8. `vow:AA` — 8 pairs (END 0, INNER 8). Words: wasn't, not, top, hah, shots, wanna, got, choppers.
9. `vow:OW` — 8 pairs (END 0, INNER 8). Words: don't, no, totin, foe, know.
10. `slant:AY:nas-stop` — 7 pairs (END 4, INNER 3). Words: slide, hidin, iron, fired, lied, fine, time, like.
11. `slant:AE:nas-stop` — 6 pairs (END 0, INNER 6). Words: fan, can't, gang, hand, cannot, had, dagger.
12. `slant:AE:stop` — 6 pairs (END 1, INNER 5). Words: cannot, can't, hand, had, dagger, bastard, pastor.
13. `slant:AE:sib-stop` — 5 pairs (END 0, INNER 5). Words: xans, cannot, can't, mans, hand.
14. `slant:IH:sib` — 5 pairs (END 0, INNER 5). Words: bitch, niggas, kids, sixth, wish, diss.
15. `vow:IY` — 5 pairs (END 0, INNER 5). Words: these, see, streets, hear, need, stealin.
16. `slant:IH:sib-stop` — 4 pairs (END 0, INNER 4). Words: bitch, stick, wit, wish, shit, diss.
17. `slant:AA:liq-stop` — 3 pairs (END 0, INNER 3). Words: car, lot, pop.
18. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: lot, pop, party, not.
19. `slant:AE:nas` — 3 pairs (END 0, INNER 3). Words: fan, damn, gang, hangin.
20. `slant:AH:fric-stop` — 3 pairs (END 2, INNER 1). Words: nut, stuff, tough, fuck.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with wit (2)
- xans — 6 pair sides, mostly spelling via spelling phonetic key, often with damn (2)
- plasmas — 2 pair sides, mostly vowel via spelling phonetic key, often with bastard (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with sixth (1)
- tatted — 2 pair sides, mostly vowel via spelling phonetic key, often with after (1)
- saiga — 2 pair sides, mostly spelling via spelling phonetic key, often with face (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- bombproof — 1 pair sides, mostly spelling via spelling phonetic key, often with sunroof (1)
- nem — 1 pair sides, mostly spelling via spelling phonetic key, often with get (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with here (1)
- facetime — 1 pair sides, mostly vowel via spelling phonetic key, often with tatted (1)
- fistfight — 1 pair sides, mostly vowel via spelling phonetic key, often with shit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| FBG Duck | Slide (Remix) | 48 | 53 | 220 | loose |
