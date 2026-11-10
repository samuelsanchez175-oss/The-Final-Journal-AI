# DCG BROTHERS rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DCG BROTHERS
- Songs: 1
- Bars kept (DCG BROTHERS lyric lines): 76
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DCG BROTHERS.
- Credit strings: DCG BROTHERS.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 514
- REPEAT pairs, recorded separately: 34
- END rhymes: 128
- INNER rhymes: 386

By match:

- PERFECT: 58 (END 17, INNER 41)
- SLANT: 182 (END 39, INNER 143)
- ASSONANCE: 268 (END 69, INNER 199)
- MULTI: 6 (END 3, INNER 3)

By confidence:

- HIGH: 54
- MED: 424
- LOW: 36

## Core

- Core Y: 493
- Core N among rhyme pairs: 21

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 216 (42.0%)
- vowel: 268 (52.1%)
- spelling: 24 (4.7%)
- multi: 6 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 97 pairs (END 41, INNER 56). Words: jump, button, comin, uppin, fumble, runnin, assumptions, stutterin.
2. `vow:OW` — 41 pairs (END 7, INNER 34). Words: don't, no, ho, logos, go, roho, opps, strokes.
3. `vow:AA` — 36 pairs (END 8, INNER 28). Words: stomp, comments, start, hop, flops, screenshot, glock, wanna.
4. `vow:EH` — 30 pairs (END 3, INNER 27). Words: next, stretchin, left, gettin, when, step, fresh, neck.
5. `vow:AY` — 27 pairs (END 7, INNER 20). Words: like, die, died, mine, buy, eye, swipin, guy.
6. `slant:AH:nas` — 26 pairs (END 10, INNER 16). Words: come, gun, one, gunnin, comin, drummer, gunna, button.
7. `slant:AA:stop` — 23 pairs (END 2, INNER 21). Words: got, start, top, glock, want, hop, stomp, gotta.
8. `vow:IH` — 21 pairs (END 0, INNER 21). Words: bitch, still, brickin, givin, fifty, testicles, niggas, finna.
9. `slant:AH:stop` — 17 pairs (END 11, INNER 6). Words: jump, crunk, front, blunt, punt, slumped, trump, hut.
10. `slant:AH:nas-stop` — 15 pairs (END 2, INNER 13). Words: punt, one, fuck, trump, come, button, hut, comin.
11. `cmu:OW` — 12 pairs (END 1, INNER 11). Words: go, no, ho, know, bro.
12. `cmu:AY` — 9 pairs (END 9, INNER 0). Words: eye, guy, try, buy, die.
13. `cmu:IH-P` — 9 pairs (END 0, INNER 9). Words: flip, hip, lip, zip.
14. `slant:IH:sib-stop` — 9 pairs (END 0, INNER 9). Words: nigga, niggas, bitch, flip, hip, lip, zip, lips.
15. `slant:IH:liq-sib` — 8 pairs (END 0, INNER 8). Words: bitch, lil, still, really, si's.
16. `slant:AA:nas-stop` — 7 pairs (END 0, INNER 7). Words: wanna, hop, want, rockin, screenshot, locked, lock.
17. `slant:EH:fric-stop` — 7 pairs (END 0, INNER 7). Words: wherever, step, get, whenever, better, ever, steph.
18. `slant:EH:stop` — 7 pairs (END 1, INNER 6). Words: better, get, step, lefteye, left, test, next, rest.
19. `slant:AA:liq-stop` — 6 pairs (END 0, INNER 6). Words: r, guitar, screenshot, hop, lock, top, roc, glock.
20. `slant:AO:nas` — 6 pairs (END 5, INNER 1). Words: borin, snorin, scorin, torn, pourin, corn.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- roho — 10 pair sides, mostly vowel via spelling phonetic key, often with ho (3)
- niggas — 10 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- tustlin — 5 pair sides, mostly vowel via spelling phonetic key, often with stutterin (1)
- opps — 5 pair sides, mostly vowel via spelling phonetic key, often with dont (2)
- pogos — 3 pair sides, mostly vowel via spelling phonetic key, often with logos (1)
- brickin — 3 pair sides, mostly vowel via spelling phonetic key, often with bitch (1)
- gunna — 3 pair sides, mostly spelling via spelling phonetic key, often with gun (1)
- finna — 2 pair sides, mostly vowel via spelling phonetic key, often with niggas (2)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with button (2)
- lefteye — 2 pair sides, mostly spelling via spelling phonetic key, often with test (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with rookie (1)
- doin — 1 pair sides, mostly spelling via spelling phonetic key, often with goin (1)
- nem — 1 pair sides, mostly spelling via spelling phonetic key, often with get (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DCG BROTHERS | Stomp | 76 | 128 | 386 | loose |
