# Ca$h Out rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ca$h Out
- Songs: 1
- Bars kept (Ca$h Out lyric lines): 21
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Ca$h Out.
- Credit strings: Ca$h Out.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 50
- REPEAT pairs, recorded separately: 7
- END rhymes: 6
- INNER rhymes: 44

By match:

- PERFECT: 5 (END 1, INNER 4)
- SLANT: 29 (END 4, INNER 25)
- ASSONANCE: 16 (END 1, INNER 15)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 5
- MED: 40
- LOW: 5

## Core

- Core Y: 49
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 30 (60.0%)
- vowel: 16 (32.0%)
- spelling: 4 (8.0%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AH:nas` — 8 pairs (END 1, INNER 7). Words: money, one, come, sunny, done, dumb.
2. `vow:OW` — 8 pairs (END 0, INNER 8). Words: know, go, whole, don't, no, broke, kelo.
3. `vow:AH` — 5 pairs (END 1, INNER 4). Words: fucking, hundred, run, sunny, dumb, money, another.
4. `cmu:OW` — 4 pairs (END 1, INNER 3). Words: know, go, no.
5. `slant:AE:sib-stop` — 3 pairs (END 0, INNER 3). Words: racks, back, mac, pack.
6. `slant:AE:stop` — 2 pairs (END 0, INNER 2). Words: act, mac, pack.
7. `slant:AH:nas-sib` — 2 pairs (END 0, INNER 2). Words: another, dumb, money.
8. `slant:EH:liq-stop` — 2 pairs (END 0, INNER 2). Words: kelo, neck, jet.
9. `slant:EH:nas-stop` — 2 pairs (END 0, INNER 2). Words: when, get.
10. `slant:EY:nas-stop` — 2 pairs (END 0, INNER 2). Words: name, made, straight.
11. `slant:IH:sib-stop` — 2 pairs (END 2, INNER 0). Words: niggas, nigga.
12. `cmu:AE-K` — 1 pairs (END 0, INNER 1). Words: mac, pack.
13. `slant:AA:sib-stop` — 1 pairs (END 0, INNER 1). Words: gotta, watch.
14. `slant:AO:nas-sib` — 1 pairs (END 0, INNER 1). Words: sauce, gone.
15. `slant:EH:stop` — 1 pairs (END 1, INNER 0). Words: neck, jet.
16. `slant:EY:stop` — 1 pairs (END 0, INNER 1). Words: made, straight.
17. `slant:IH:stop` — 1 pairs (END 0, INNER 1). Words: winter, shit.
18. `slant:UW:liq` — 1 pairs (END 0, INNER 1). Words: jewelry, cool.
19. `vow:EH` — 1 pairs (END 0, INNER 1). Words: there's, when.
20. `vow:IY` — 1 pairs (END 0, INNER 1). Words: these, even.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- kelo — 3 pair sides, mostly spelling via spelling phonetic key, often with know (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ca$h Out | Get Money (Run It Up) | 21 | 6 | 44 | loose |
