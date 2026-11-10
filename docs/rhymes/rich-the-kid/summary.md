# Rich The Kid rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rich The Kid
- Songs: 11
- Bars kept (Rich The Kid lyric lines): 545
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Rich The Kid.
- Credit strings: Rich The Kid.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 2970
- REPEAT pairs, recorded separately: 266
- END rhymes: 755
- INNER rhymes: 2215

By match:

- PERFECT: 300 (END 139, INNER 161)
- SLANT: 1315 (END 328, INNER 987)
- ASSONANCE: 1325 (END 277, INNER 1048)
- MULTI: 30 (END 11, INNER 19)

By confidence:

- HIGH: 301
- MED: 2464
- LOW: 205

## Core

- Core Y: 2926
- Core N among rhyme pairs: 44

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1427 (48.0%)
- vowel: 1325 (44.6%)
- spelling: 188 (6.3%)
- multi: 30 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 11 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 222 pairs (END 61, INNER 161). Words: can't, trap, bag, trapping, cash, have, magic, racks.
2. `vow:EY` — 212 pairs (END 70, INNER 142). Words: ain't, way, k, today, face, say, play, stay.
3. `vow:IH` — 196 pairs (END 22, INNER 174). Words: bitch, wrist, shit, sipping, windows, kitchen, whipping, givin.
4. `vow:OW` — 192 pairs (END 40, INNER 152). Words: no, don't, know, old, go, show, dope, told.
5. `vow:AA` — 114 pairs (END 20, INNER 94). Words: got, choppers, wasn’t, want, starve, raw, floss, pot.
6. `vow:EH` — 101 pairs (END 11, INNER 90). Words: get, let's, dividends, ready, when, tesla, flexing, head.
7. `slant:IH:sib-stop` — 98 pairs (END 33, INNER 65). Words: bitch, shit, rich, hit, nigga, niggas, big, clip.
8. `slant:AE:stop` — 88 pairs (END 35, INNER 53). Words: back, trap, act, matte, bag, mad, fat, black.
9. `vow:AH` — 85 pairs (END 5, INNER 80). Words: hundred, money, plug, some, fuck, done, run, fuckin.
10. `slant:IH:stop` — 83 pairs (END 11, INNER 72). Words: nigga, shit, hit, wit, migo, clip, lick, big.
11. `cmu:OW` — 56 pairs (END 21, INNER 35). Words: no, go, know, joe, show, ho, snow, glow.
12. `slant:AA:stop` — 54 pairs (END 6, INNER 48). Words: got, want, cop, pot, body, cock, glock, sloppy.
13. `slant:AH:nas-stop` — 51 pairs (END 2, INNER 49). Words: fuck, plug, money, young, run, what, juugin, done.
14. `vow:AY` — 50 pairs (END 0, INNER 50). Words: like, diamonds, die, by, why, behind, grindin, snipers.
15. `vow:IY` — 49 pairs (END 17, INNER 32). Words: see, sheets, keep, streets, beast, even, weak, freak.
16. `slant:EY:sib-stop` — 47 pairs (END 24, INNER 23). Words: race, face, straight, plate, late, breaks, wraith, fake.
17. `vow:AO` — 47 pairs (END 15, INNER 32). Words: orphanage, because, unfortunate, callin, ordered, recorded, supportin, all.
18. `slant:AE:sib-stop` — 40 pairs (END 10, INNER 30). Words: ass, bag, bags, back, racks, trap, cash, straps.
19. `slant:AH:nas` — 38 pairs (END 3, INNER 35). Words: money, some, run, young, done, one, none, fuckin.
20. `vow:AW` — 35 pairs (END 14, INNER 21). Words: now, chowder, thou, down, howard, around, house, firepower.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 48 pair sides, mostly spelling via spelling phonetic key, often with niggas (10)
- ima — 25 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- niggas — 15 pair sides, mostly spelling via spelling phonetic key, often with nigga (10)
- juugin — 12 pair sides, mostly spelling via spelling phonetic key, often with plug (6)
- wraith — 11 pair sides, mostly spelling via spelling phonetic key, often with face (2)
- migo — 11 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- finessin — 11 pair sides, mostly spelling via spelling phonetic key, often with juugin (3)
- gon — 9 pair sides, mostly spelling via spelling phonetic key, often with woke (2)
- pics — 8 pair sides, mostly spelling via spelling phonetic key, often with prince (2)
- finessing — 6 pair sides, mostly vowel via spelling phonetic key, often with trapping (1)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- crix — 4 pair sides, mostly spelling via spelling phonetic key, often with blick (1)
- quimp — 4 pair sides, mostly spelling via spelling phonetic key, often with sip (2)
- quavo — 4 pair sides, mostly spelling via spelling phonetic key, often with trap (1)
- finna — 4 pair sides, mostly vowel via spelling phonetic key, often with nigga (3)
- margielas — 4 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- birkin — 4 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- juug — 4 pair sides, mostly spelling via spelling phonetic key, often with plug (2)
- jero — 4 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- trappa — 4 pair sides, mostly spelling via spelling phonetic key, often with racks (1)
- piff — 3 pair sides, mostly vowel via spelling phonetic key, often with trip (1)
- trina — 3 pair sides, mostly multi via spelling phonetic key, often with aquafina (2)
- flippa — 3 pair sides, mostly spelling via spelling phonetic key, often with zippers (1)
- vacants — 3 pair sides, mostly vowel via spelling phonetic key, often with trap (1)
- donatello — 3 pair sides, mostly vowel via spelling phonetic key, often with elbow (1)
- titties — 2 pair sides, mostly spelling via spelling phonetic key, often with nobodies (1)
- shitted — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- megadome — 2 pair sides, mostly vowel via spelling phonetic key, often with ever (2)
- peepee — 2 pair sides, mostly spelling via spelling phonetic key, often with these (1)
- aquafina — 2 pair sides, mostly multi via spelling phonetic key, often with trina (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rich The Kid | Let’s Get It | 42 | 36 | 212 | loose |
| Rich The Kid | Louie Coat | 59 | 79 | 324 | loose |
| Rich The Kid | Migo Gang x Slaughter Gang Music | 122 | 201 | 385 | loose |
| Rich The Kid | Money Call | 32 | 51 | 228 | loose |
| Rich The Kid | Nobody Safe | 44 | 94 | 173 | loose |
| Rich The Kid | Plug | 44 | 57 | 236 | loose |
| Rich The Kid | Rain Snow | 36 | 67 | 166 | loose |
| Rich The Kid | Touchdown (Remix) | 40 | 44 | 149 | loose |
| Rich The Kid | Trap | 63 | 58 | 170 | loose |
| Rich The Kid | Trap House | 50 | 61 | 136 | loose |
| Rich The Kid | Why So Serious* | 13 | 7 | 36 | loose |
