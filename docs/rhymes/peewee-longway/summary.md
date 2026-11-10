# Peewee Longway rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Peewee Longway
- Songs: 12
- Bars kept (Peewee Longway lyric lines): 583
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Peewee Longway.
- Credit strings: Peewee Longway.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 3762
- REPEAT pairs, recorded separately: 406
- END rhymes: 989
- INNER rhymes: 2773

By match:

- PERFECT: 347 (END 128, INNER 219)
- SLANT: 1575 (END 430, INNER 1145)
- ASSONANCE: 1824 (END 425, INNER 1399)
- MULTI: 16 (END 6, INNER 10)

By confidence:

- HIGH: 343
- MED: 3171
- LOW: 248

## Core

- Core Y: 3690
- Core N among rhyme pairs: 72

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1729 (46.0%)
- vowel: 1824 (48.5%)
- spelling: 193 (5.1%)
- multi: 16 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 2 songs
- loose: 10 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 258 pairs (END 68, INNER 190). Words: got, boxes, bought, hard, want, commas, choppers, harlem.
2. `vow:OW` — 252 pairs (END 66, INNER 186). Words: don't, no, know, go, low, approachable, dope, ghost.
3. `vow:IH` — 241 pairs (END 32, INNER 209). Words: bitch, bitches, pimpin, big, lil, bricks, drippin, dick.
4. `vow:AE` — 236 pairs (END 63, INNER 173). Words: racks, bags, bands, fast, pack, trap, can't, cash.
5. `vow:EY` — 188 pairs (END 38, INNER 150). Words: ain't, way, today, made, face, jakes, say, wake.
6. `vow:AH` — 171 pairs (END 42, INNER 129). Words: double, something, fuck, money, done, bust, some, hustlin.
7. `vow:EH` — 142 pairs (END 29, INNER 113). Words: when, went, get, freshest, connected, west, press, steppin.
8. `vow:IY` — 135 pairs (END 36, INNER 99). Words: wee, these, beat, see, feelin, real, week, b.
9. `slant:AA:stop` — 113 pairs (END 15, INNER 98). Words: got, want, pop, top, body, exotic, rocket, glock.
10. `vow:AY` — 107 pairs (END 22, INNER 85). Words: like, buy, by, wifi, hybrids, privates, michael, diamonds.
11. `slant:EY:sib-stop` — 74 pairs (END 50, INNER 24). Words: face, place, break, brakes, wake, made, lace, gate.
12. `slant:EY:stop` — 65 pairs (END 28, INNER 37). Words: made, make, take, late, escape, steak, draco, estate.
13. `slant:IH:stop` — 64 pairs (END 0, INNER 64). Words: nigga, shit, big, dick, stick, quick, hit, brick.
14. `slant:AE:sib-stop` — 59 pairs (END 39, INNER 20). Words: bag, ass, had, cash, lab, mad, math, gas.
15. `cmu:OW` — 58 pairs (END 12, INNER 46). Words: go, no, know, low, mo, show, ho, grow.
16. `slant:IH:sib-stop` — 52 pairs (END 3, INNER 49). Words: bitch, big, shit, dick, miss, hit, quick, tip.
17. `slant:AH:nas-stop` — 47 pairs (END 1, INNER 46). Words: fuck, some, money, plug, come, one, what, suck.
18. `slant:AE:stop` — 43 pairs (END 19, INNER 24). Words: had, mad, bag, trap, lab, can't, papi, bad.
19. `vow:UW` — 42 pairs (END 14, INNER 28). Words: two, who, room, used, dudes, new, cuban, coupe.
20. `slant:AA:nas-stop` — 39 pairs (END 0, INNER 39). Words: wanna, got, mama, john, want, pop, top, not.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 40 pair sides, mostly spelling via spelling phonetic key, often with bitch (11)
- nigga — 37 pair sides, mostly spelling via spelling phonetic key, often with shit (11)
- tryna — 16 pair sides, mostly spelling via spelling phonetic key, often with need (5)
- gon — 12 pair sides, mostly spelling via spelling phonetic key, often with dont (6)
- bondo — 9 pair sides, mostly vowel via spelling phonetic key, often with cleo (1)
- rondo — 9 pair sides, mostly vowel via spelling phonetic key, often with condo (1)
- cholo — 9 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- jag — 8 pair sides, mostly spelling via spelling phonetic key, often with cash (1)
- taz — 7 pair sides, mostly spelling via spelling phonetic key, often with ass (1)
- papi — 6 pair sides, mostly spelling via spelling phonetic key, often with capper (2)
- wraith — 6 pair sides, mostly spelling via spelling phonetic key, often with gate (1)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- dabs — 5 pair sides, mostly spelling via spelling phonetic key, often with bands (1)
- tuss — 5 pair sides, mostly spelling via spelling phonetic key, often with bucks (1)
- skully — 4 pair sides, mostly vowel via spelling phonetic key, often with buddy (1)
- runtz — 4 pair sides, mostly vowel via spelling phonetic key, often with bunch (1)
- chainz — 4 pair sides, mostly spelling via spelling phonetic key, often with lanes (1)
- shawty — 4 pair sides, mostly spelling via spelling phonetic key, often with walk (1)
- zaddy — 4 pair sides, mostly spelling via spelling phonetic key, often with automatic (1)
- dripper — 3 pair sides, mostly vowel via vault phonetic_class, often with lactose (1)
- baguettes — 3 pair sides, mostly vowel via spelling phonetic key, often with dripper (1)
- baguetty — 3 pair sides, mostly vowel via spelling phonetic key, often with amiri (1)
- geechee — 3 pair sides, mostly spelling via spelling phonetic key, often with meechie (1)
- ovo — 3 pair sides, mostly vowel via spelling phonetic key, often with gon (1)
- giuseppes — 3 pair sides, mostly vowel via spelling phonetic key, often with ridges (1)
- baddest — 3 pair sides, mostly vowel via spelling phonetic key, often with pallet (2)
- addies — 3 pair sides, mostly spelling via spelling phonetic key, often with baddest (1)
- cuz — 3 pair sides, mostly spelling via spelling phonetic key, often with fuck (2)
- kinfolk — 2 pair sides, mostly vowel via spelling phonetic key, often with timbos (1)
- timbos — 2 pair sides, mostly vowel via spelling phonetic key, often with kinfolk (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Peewee Longway | Back Stroke | 54 | 100 | 327 | loose |
| Peewee Longway | Bout a Check | 66 | 109 | 251 | loose |
| Peewee Longway | Digital | 48 | 48 | 175 | loose |
| Peewee Longway | Fragile | 26 | 71 | 174 | AAAA |
| Peewee Longway | Impressive | 45 | 89 | 199 | loose |
| Peewee Longway | Long Money | 37 | 33 | 223 | loose |
| Peewee Longway | Moon | 56 | 79 | 247 | loose |
| Peewee Longway | My Way | 69 | 185 | 323 | AAAA |
| Peewee Longway | Next One | 29 | 36 | 171 | loose |
| Peewee Longway | OOOWWWEEE | 59 | 92 | 192 | loose |
| Peewee Longway | Shake Something | 31 | 57 | 125 | loose |
| Peewee Longway | Still Hustlin’ | 63 | 90 | 366 | loose |
