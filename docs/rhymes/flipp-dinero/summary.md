# Flipp Dinero rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Flipp Dinero
- Songs: 2
- Bars kept (Flipp Dinero lyric lines): 82
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Flipp Dinero.
- Credit strings: Flipp Dinero.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 737
- REPEAT pairs, recorded separately: 128
- END rhymes: 91
- INNER rhymes: 646

By match:

- PERFECT: 46 (END 9, INNER 37)
- SLANT: 315 (END 34, INNER 281)
- ASSONANCE: 375 (END 47, INNER 328)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 47
- MED: 640
- LOW: 50

## Core

- Core Y: 730
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 318 (43.1%)
- vowel: 375 (50.9%)
- spelling: 43 (5.8%)
- multi: 1 (0.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 73 pairs (END 40, INNER 33). Words: happen, savage, average, bag, action, trappin, had, racks.
2. `vow:IY` — 50 pairs (END 2, INNER 48). Words: see, keep, streets, g, glizzy, green, these, vip.
3. `vow:IH` — 43 pairs (END 1, INNER 42). Words: livin, lives, 'til, shit, flippin, really, sitting, bitches.
4. `vow:AH` — 39 pairs (END 0, INNER 39). Words: money, lovely, brothers, duffel, hundred, what, struggle, cousin.
5. `vow:AY` — 36 pairs (END 0, INNER 36). Words: like, diamonds, by, why, lie, right, live, cry.
6. `vow:EY` — 36 pairs (END 0, INNER 36). Words: ain't, hatin, stay, make, always, played, sustain, occupation.
7. `vow:EH` — 32 pairs (END 1, INNER 31). Words: send, get, requested, ever, flex, necklace, gettin, tell.
8. `slant:AY:nas-stop` — 25 pairs (END 2, INNER 23). Words: like, time, line, find, fine, nine, mine, decline.
9. `slant:IH:stop` — 24 pairs (END 0, INNER 24). Words: shit, nigga, hip, mic, pimp, hitta, switched, city.
10. `vow:OW` — 24 pairs (END 3, INNER 21). Words: know, supposed, going, goes, focused, smokin, dope, hoes.
11. `slant:AE:nas` — 22 pairs (END 21, INNER 1). Words: trappin, happen, action, actin, captain, man, passin.
12. `vow:AA` — 20 pairs (END 0, INNER 20). Words: got, la, poppin, rollin, honestly, block, glock, bottles.
13. `vow:AO` — 14 pairs (END 0, INNER 14). Words: foreign, all, billboards, imported, important, shawn, walk.
14. `slant:IH:nas-stop` — 12 pairs (END 0, INNER 12). Words: him, limp, swim, i'ma, clip, dip, flippin, flip.
15. `slant:IH:sib-stop` — 11 pairs (END 0, INNER 11). Words: nigga, niggas, switch, shit, bitch, switched, clip, dip.
16. `cmu:AY-N` — 10 pairs (END 3, INNER 7). Words: line, fine, mine, nine, decline.
17. `slant:AY:nas` — 10 pairs (END 1, INNER 9). Words: time, line, fine, nine, mine, decline.
18. `slant:AH:nas` — 9 pairs (END 0, INNER 9). Words: money, come, fuckin.
19. `slant:AY:fric-stop` — 9 pairs (END 0, INNER 9). Words: life, live, like, inside, side, right, drive.
20. `slant:EH:nas-stop` — 9 pairs (END 0, INNER 9). Words: gettin, get, let, when, m, kemp, wet.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 15 pair sides, mostly spelling via spelling phonetic key, often with niggas (6)
- tryna — 15 pair sides, mostly spelling via spelling phonetic key, often with turn (3)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- glizzy — 5 pair sides, mostly vowel via spelling phonetic key, often with money (1)
- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with until (2)
- prolly — 3 pair sides, mostly vowel via spelling phonetic key, often with glizzy (1)
- hitta — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- guala — 2 pair sides, mostly spelling via spelling phonetic key, often with money (1)
- godll — 2 pair sides, mostly spelling via spelling phonetic key, often with prolly (1)
- tetris — 2 pair sides, mostly spelling via spelling phonetic key, often with flex (1)
- bimmer — 1 pair sides, mostly spelling via spelling phonetic key, often with thinkin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Flipp Dinero | Till I’m Gone | 54 | 78 | 358 | loose |
| Flipp Dinero | Time Goes Down (Remix) | 28 | 13 | 288 | loose |
