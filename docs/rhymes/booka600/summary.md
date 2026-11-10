# Booka600 rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Booka600
- Songs: 1
- Bars kept (Booka600 lyric lines): 50
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Booka600.
- Credit strings: Booka600.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 157
- REPEAT pairs, recorded separately: 11
- END rhymes: 85
- INNER rhymes: 72

By match:

- PERFECT: 10 (END 6, INNER 4)
- SLANT: 76 (END 48, INNER 28)
- ASSONANCE: 70 (END 30, INNER 40)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 11
- MED: 127
- LOW: 19

## Core

- Core Y: 151
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 72 (45.9%)
- vowel: 70 (44.6%)
- spelling: 14 (8.9%)
- multi: 1 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:UW` — 22 pairs (END 20, INNER 2). Words: blue, jew, troops, proof, coupe, rule, truce, fruit.
2. `slant:AE:sib-stop` — 16 pairs (END 11, INNER 5). Words: patch, satch, catch, black, rat, trap, back, saks.
3. `vow:AE` — 15 pairs (END 7, INNER 8). Words: facts, hand, saks, racks, back, satch, patch, matte.
4. `vow:AY` — 11 pairs (END 3, INNER 8). Words: high, like, tiger, stripes, diamonds, timing, buy, findin.
5. `slant:UW:fric-stop` — 10 pairs (END 10, INNER 0). Words: proof, tooka, coupe, roof, fruit, spoof, flute.
6. `vow:AA` — 8 pairs (END 0, INNER 8). Words: condom, wasn't, pocket's, want, not, watch, glock, talkin.
7. `slant:AE:stop` — 7 pairs (END 7, INNER 0). Words: black, rat, trap, mat, strap.
8. `vow:EH` — 6 pairs (END 0, INNER 6). Words: sex, send, melly, get, head, s, let, check.
9. `vow:OW` — 5 pairs (END 0, INNER 5). Words: know, opps, post, don't, blow, smoke.
10. `slant:AA:stop` — 4 pairs (END 1, INNER 3). Words: hot, top, prada, want, not.
11. `slant:UW:fric-sib` — 4 pairs (END 4, INNER 0). Words: truce, proof, truth, roof, spoof.
12. `slant:UW:sib-stop` — 4 pairs (END 4, INNER 0). Words: truce, truth, fruit, tooka, coupe, flute.
13. `slant:UW:stop` — 3 pairs (END 3, INNER 0). Words: tooka, coupe, fruit, flute.
14. `cmu:AE-CH` — 2 pairs (END 1, INNER 1). Words: patch, satch, catch.
15. `cmu:EY` — 2 pairs (END 0, INNER 2). Words: play, say.
16. `cmu:UW` — 2 pairs (END 2, INNER 0). Words: new, blue, flu.
17. `slant:AA:sib-stop` — 2 pairs (END 0, INNER 2). Words: watch, got, glock.
18. `slant:AE:nas-stop` — 2 pairs (END 0, INNER 2). Words: gang, mat, strap.
19. `slant:AO:liq-sib` — 2 pairs (END 1, INNER 1). Words: all, because, flaws.
20. `slant:EH:sib-stop` — 2 pairs (END 1, INNER 1). Words: s, check, let.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- satch — 8 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- tooka — 6 pair sides, mostly spelling via spelling phonetic key, often with proof (2)
- opps — 2 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- grizzley — 2 pair sides, mostly vowel via spelling phonetic key, often with play (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with smoke (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with him (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Booka600 | Blue | 50 | 85 | 72 | loose |
