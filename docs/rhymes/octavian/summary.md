# Octavian rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Octavian
- Songs: 1
- Bars kept (Octavian lyric lines): 42
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Octavian.
- Credit strings: Octavian.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 210
- REPEAT pairs, recorded separately: 33
- END rhymes: 42
- INNER rhymes: 168

By match:

- PERFECT: 15 (END 1, INNER 14)
- SLANT: 77 (END 11, INNER 66)
- ASSONANCE: 115 (END 29, INNER 86)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 15
- MED: 148
- LOW: 47

## Core

- Core Y: 183
- Core N among rhyme pairs: 27

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 72 (34.3%)
- vowel: 115 (54.8%)
- spelling: 20 (9.5%)
- multi: 3 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 37 pairs (END 18, INNER 19). Words: like, lineman, hidin, pirate, violent, rival, private, diary.
2. `vow:IY` — 26 pairs (END 6, INNER 20). Words: glizzy, tekky, bucky, twinny, blicky, blocky, penty, probably.
3. `vow:EH` — 19 pairs (END 0, INNER 19). Words: step, left, temperaments, test, ten, seven, never, henry.
4. `vow:OW` — 10 pairs (END 1, INNER 9). Words: don't, go, shows, gold, told, ho, know, opps.
5. `vow:AA` — 8 pairs (END 0, INNER 8). Words: cars, models, block, got, mama, cops.
6. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: go, blow, ho, no.
7. `slant:AE:nas-sib` — 6 pairs (END 0, INNER 6). Words: pass, gang, man.
8. `slant:EH:nas-stop` — 6 pairs (END 0, INNER 6). Words: lenny, step, ten, speci, plenty, end, penty.
9. `slant:EH:stop` — 6 pairs (END 0, INNER 6). Words: check, get, end, net, tekky, step, speci, plenty.
10. `slant:AY:stop` — 4 pairs (END 2, INNER 2). Words: pirate, slide, violent, private, might, right.
11. `vow:AO` — 4 pairs (END 4, INNER 0). Words: boredom, tutorial, balls, more.
12. `vow:EY` — 4 pairs (END 0, INNER 4). Words: change, name, face, baby, ain't.
13. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: grab, man.
14. `slant:AE:stop` — 3 pairs (END 0, INNER 3). Words: black, bad, trackie, grab.
15. `slant:EH:liq-stop` — 3 pairs (END 1, INNER 2). Words: henry, plenty, end, penty.
16. `slant:EH:sib-stop` — 3 pairs (END 0, INNER 3). Words: messy, check, net, get.
17. `slant:EY:nas-sib` — 3 pairs (END 0, INNER 3). Words: face, chain, change, name.
18. `slant:IH:sib` — 3 pairs (END 0, INNER 3). Words: glizzy, lizzy, switch, bitch, nizz.
19. `slant:OW:stop` — 3 pairs (END 1, INNER 2). Words: scoped, blocky, shotty, told, smoke.
20. `vow:UW` — 3 pairs (END 0, INNER 3). Words: uzi, tattoo, gucci, new.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- glizzy — 9 pair sides, mostly vowel via spelling phonetic key, often with tekky (1)
- penty — 8 pair sides, mostly spelling via spelling phonetic key, often with plenty (2)
- tekky — 7 pair sides, mostly vowel via spelling phonetic key, often with glizzy (1)
- blicky — 7 pair sides, mostly vowel via spelling phonetic key, often with probably (1)
- blocky — 6 pair sides, mostly vowel via spelling phonetic key, often with glizzy (1)
- twinny — 5 pair sides, mostly vowel via spelling phonetic key, often with maybe (1)
- glocky — 4 pair sides, mostly vowel via spelling phonetic key, often with blicky (1)
- shotty — 2 pair sides, mostly vowel via spelling phonetic key, often with tekky (1)
- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with well (1)
- fenty — 2 pair sides, mostly cmu via vault phonetic_class, often with probably (1)
- scoped — 2 pair sides, mostly spelling via spelling phonetic key, often with told (1)
- speci — 2 pair sides, mostly spelling via spelling phonetic key, often with step (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with blicky (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with told (1)
- trackie — 1 pair sides, mostly spelling via spelling phonetic key, often with black (1)
- nizz — 1 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Octavian | Blicky (Original) | 42 | 42 | 168 | loose |
