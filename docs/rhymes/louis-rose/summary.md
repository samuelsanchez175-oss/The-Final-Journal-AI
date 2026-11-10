# Louis Rose rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Louis Rose
- Songs: 1
- Bars kept (Louis Rose lyric lines): 67
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Louis Rose.
- Credit strings: Louis Rose.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 422
- REPEAT pairs, recorded separately: 88
- END rhymes: 75
- INNER rhymes: 347

By match:

- PERFECT: 33 (END 13, INNER 20)
- SLANT: 221 (END 46, INNER 175)
- ASSONANCE: 166 (END 16, INNER 150)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 31
- MED: 345
- LOW: 46

## Core

- Core Y: 422
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 206 (48.8%)
- vowel: 166 (39.3%)
- spelling: 48 (11.4%)
- multi: 2 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 36 pairs (END 6, INNER 30). Words: bitch, shit, bitches, whippin, dick, limp, wrist, kitchen.
2. `slant:IH:stop` — 32 pairs (END 8, INNER 24). Words: shit, nigga, dick, chick, city, drink, whip, twitter.
3. `slant:AY:nas-stop` — 27 pairs (END 0, INNER 27). Words: time, right, like, shine, fine, klondike, white, tight.
4. `slant:IH:sib-stop` — 26 pairs (END 12, INNER 14). Words: bitch, niggas, nigga, dick, shit, chick, sit, whip.
5. `vow:AY` — 25 pairs (END 4, INNER 21). Words: diamonds, dykes, highlights, time, right, like, grind, shine.
6. `vow:EH` — 25 pairs (END 2, INNER 23). Words: scared, never, lettin, friends, get, respect, where, text.
7. `vow:EY` — 20 pairs (END 0, INNER 20). Words: ain't, make, way, naming, fake, hatin, phrase, played.
8. `vow:OW` — 19 pairs (END 0, INNER 19). Words: broke, don't, no, own, know, rose, ho, old.
9. `slant:AY:stop` — 17 pairs (END 8, INNER 9). Words: like, right, white, klondike, tight.
10. `vow:AH` — 17 pairs (END 0, INNER 17). Words: fuck, under, trust, covers, hustle, brothers, bust, crush.
11. `slant:IH:sib` — 11 pairs (END 2, INNER 9). Words: niggas, picks, bricks, chicks, bitches, pills, lips.
12. `vow:UW` — 10 pairs (END 0, INNER 10). Words: future, movement, used, two, uzi, ratatouille, lose.
13. `slant:IH:nas-stop` — 9 pairs (END 0, INNER 9). Words: thing, king, whip, bring, dick, shit, city, i'ma.
14. `vow:AE` — 8 pairs (END 4, INNER 4). Words: tags, mad, back, passed, last, bad, had, fags.
15. `slant:AE:nas-stop` — 7 pairs (END 1, INNER 6). Words: back, mackin, mad, kanye, crack, damn.
16. `slant:AY:sib-stop` — 7 pairs (END 6, INNER 1). Words: highlights, right, dykes, klondike, like, tight, white.
17. `cmu:AY-T` — 6 pairs (END 4, INNER 2). Words: right, white, tight.
18. `slant:IH:nas-sib` — 6 pairs (END 0, INNER 6). Words: bitch, king, bring, i'ma, kitchen, him, snitchin.
19. `slant:IY:liq-nas` — 5 pairs (END 0, INNER 5). Words: real, tryna, mean.
20. `slant:IY:liq-sib` — 5 pairs (END 0, INNER 5). Words: these, real.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 22 pair sides, mostly spelling via spelling phonetic key, often with niggas (9)
- niggas — 18 pair sides, mostly spelling via spelling phonetic key, often with nigga (9)
- tryna — 7 pair sides, mostly spelling via spelling phonetic key, often with real (4)
- toolie — 5 pair sides, mostly spelling via spelling phonetic key, often with ratatouille (2)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- kanye — 2 pair sides, mostly spelling via spelling phonetic key, often with mad (2)
- woulda — 2 pair sides, mostly multi via spelling phonetic key, often with shoulda (2)
- shoulda — 2 pair sides, mostly multi via spelling phonetic key, often with woulda (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Louis Rose | Barry White | 67 | 75 | 347 | loose |
