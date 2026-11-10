# Choo Choo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Choo Choo
- Songs: 1
- Bars kept (Choo Choo lyric lines): 11
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Choo Choo.
- Credit strings: Choo Choo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 113
- REPEAT pairs, recorded separately: 6
- END rhymes: 15
- INNER rhymes: 98

By match:

- PERFECT: 4 (END 1, INNER 3)
- SLANT: 38 (END 0, INNER 38)
- ASSONANCE: 64 (END 14, INNER 50)
- MULTI: 7 (END 0, INNER 7)

By confidence:

- HIGH: 10
- MED: 99
- LOW: 4

## Core

- Core Y: 113
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 38 (33.6%)
- vowel: 64 (56.6%)
- spelling: 4 (3.5%)
- multi: 7 (6.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 31 pairs (END 9, INNER 22). Words: accurate, traffickin, rappin, ass, imagine, capture, happenin, snappin.
2. `vow:IH` — 15 pairs (END 0, INNER 15). Words: since, single, bringing, hit, lil, quit, really, shit.
3. `vow:AH` — 12 pairs (END 5, INNER 7). Words: what's, lust, dust, truck, fuck, love.
4. `slant:AE:nas` — 10 pairs (END 0, INNER 10). Words: jackin, happenin, rappin, snappin, trappin, traffickin, can, imagine.
5. `slant:IH:liq-stop` — 8 pairs (END 0, INNER 8). Words: really, lil, quit, hit, spit, shit.
6. `multi:AE-P-IH-NG` — 7 pairs (END 0, INNER 7). Words: rappin, snappin, trappin, snappin trappin, niggas rappin, deeper rappin.
7. `slant:IH:stop` — 3 pairs (END 0, INNER 3). Words: nigga, hit, quit, spit.
8. `cmu:IH-T` — 2 pairs (END 0, INNER 2). Words: hit, quit, spit, shit.
9. `slant:AA:liq-nas` — 2 pairs (END 0, INNER 2). Words: r, mama, wanna.
10. `slant:AA:nas-stop` — 2 pairs (END 0, INNER 2). Words: stop, mama, wanna.
11. `slant:AH:fric-stop` — 2 pairs (END 0, INNER 2). Words: love, fuck, truck.
12. `vow:EH` — 2 pairs (END 0, INNER 2). Words: went, every, pressure.
13. `cmu:AH-K` — 1 pairs (END 0, INNER 1). Words: fuck, truck.
14. `cmu:AH-S-T` — 1 pairs (END 1, INNER 0). Words: dust, lust.
15. `slant:AA:liq-stop` — 1 pairs (END 0, INNER 1). Words: stop, r.
16. `slant:AA:nas` — 1 pairs (END 0, INNER 1). Words: mama, wanna.
17. `slant:AA:stop` — 1 pairs (END 0, INNER 1). Words: copped, stop.
18. `slant:AE:nas-sib` — 1 pairs (END 0, INNER 1). Words: rappin, capture.
19. `slant:AE:nas-stop` — 1 pairs (END 0, INNER 1). Words: can, kodak.
20. `slant:AO:liq-stop` — 1 pairs (END 0, INNER 1). Words: door, audi.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with hit (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Choo Choo | In da Noya | 11 | 15 | 98 | loose |
