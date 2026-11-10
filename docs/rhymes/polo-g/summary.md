# Polo G rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Polo G
- Songs: 6
- Bars kept (Polo G lyric lines): 267
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Polo G.
- Credit strings: Polo G.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 2556
- REPEAT pairs, recorded separately: 191
- END rhymes: 437
- INNER rhymes: 2119

By match:

- PERFECT: 229 (END 63, INNER 166)
- SLANT: 1031 (END 177, INNER 854)
- ASSONANCE: 1277 (END 182, INNER 1095)
- MULTI: 19 (END 15, INNER 4)

By confidence:

- HIGH: 227
- MED: 2213
- LOW: 116

## Core

- Core Y: 2526
- Core N among rhyme pairs: 30

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1155 (45.2%)
- vowel: 1277 (50.0%)
- spelling: 105 (4.1%)
- multi: 19 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 6 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 372 pairs (END 49, INNER 323). Words: years, shit, risks, bitches, six, bitch, killers, really.
2. `vow:EY` — 145 pairs (END 38, INNER 107). Words: ain't, say, day, face, make, wakin, stay, take.
3. `vow:EH` — 140 pairs (END 7, INNER 133). Words: get, trenches, where, when, tears, getting, belt, weapon.
4. `vow:AH` — 110 pairs (END 24, INNER 86). Words: some, hundred, run, what, thugs, ugly, blood, one.
5. `vow:AE` — 109 pairs (END 29, INNER 80). Words: can't, fast, exactly, last, gangster, accuracy, raps, frank.
6. `vow:AY` — 109 pairs (END 20, INNER 89). Words: like, die, heights, ridin, revived, supply, high, mind.
7. `vow:OW` — 96 pairs (END 0, INNER 96). Words: don't, ago, know, no, totin, told, rolls, bro.
8. `vow:AA` — 60 pairs (END 1, INNER 59). Words: got, options, started, condo, la, robbin, hop, shots.
9. `vow:IY` — 57 pairs (END 0, INNER 57). Words: even, g, see, real, three, d, feel, streets.
10. `slant:AY:stop` — 51 pairs (END 11, INNER 40). Words: like, tired, type, highlight, fight, night, side, slide.
11. `slant:IH:sib-stop` — 50 pairs (END 17, INNER 33). Words: shit, bitch, chris, rich, lit, hit, whip, sick.
12. `slant:AA:stop` — 48 pairs (END 3, INNER 45). Words: got, glock, lot, heart, locked, stop, lotta, spot.
13. `slant:IH:sib` — 48 pairs (END 8, INNER 40). Words: bitches, switches, killers, years, six, niggas, blitz, miss.
14. `vow:UW` — 46 pairs (END 13, INNER 33). Words: who, shoot, two, new, movement, confusion, soon, boomin.
15. `slant:IH:liq-stop` — 40 pairs (END 0, INNER 40). Words: shit, really, lil, big, dick, until, kill, whip.
16. `slant:EY:sib-stop` — 35 pairs (END 15, INNER 20). Words: crazy, lazy, baby, made, straight, case, eight, ain't.
17. `slant:EH:nas-stop` — 32 pairs (END 0, INNER 32). Words: when, get, ten, many, better, went, forget, again.
18. `slant:AE:sib-stop` — 30 pairs (END 7, INNER 23). Words: strap, pass, naps, raps, match, ass, back, ath.
19. `slant:IH:stop` — 30 pairs (END 8, INNER 22). Words: shit, nigga, big, equipped, grip, lit, hit, trip.
20. `slant:IH:liq-sib` — 28 pairs (END 0, INNER 28). Words: killers, lil, really, years, bitch, still'll, chris, amiri.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 15 pair sides, mostly spelling via spelling phonetic key, often with dont (4)
- nigga — 14 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- bap — 9 pair sides, mostly spelling via spelling phonetic key, often with lap (2)
- ima — 8 pair sides, mostly spelling via spelling phonetic key, often with rich (2)
- fivi — 8 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- cuz — 6 pair sides, mostly spelling via spelling phonetic key, often with love (1)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with figures (1)
- spliff — 6 pair sides, mostly vowel via spelling phonetic key, often with bitch (2)
- libs — 6 pair sides, mostly vowel via spelling phonetic key, often with bitch (2)
- dolo — 6 pair sides, mostly spelling via spelling phonetic key, often with lo (2)
- fum — 5 pair sides, mostly spelling via spelling phonetic key, often with run (3)
- foenem — 5 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- boofin — 4 pair sides, mostly vowel via spelling phonetic key, often with boomin (1)
- blam — 4 pair sides, mostly spelling via spelling phonetic key, often with damn (1)
- capalot — 4 pair sides, mostly spelling via spelling phonetic key, often with lot (2)
- nem — 4 pair sides, mostly spelling via spelling phonetic key, often with get (2)
- ath — 3 pair sides, mostly spelling via spelling phonetic key, often with back (2)
- homie — 2 pair sides, mostly spelling via spelling phonetic key, often with gon (1)
- glizzy — 2 pair sides, mostly vowel via spelling phonetic key, often with see (1)
- shawty — 2 pair sides, mostly vowel via spelling phonetic key, often with many (1)
- killa — 2 pair sides, mostly spelling via spelling phonetic key, often with killer (1)
- savager — 2 pair sides, mostly vowel via spelling phonetic key, often with passenger (1)
- turnt — 2 pair sides, mostly spelling via spelling phonetic key, often with hunt (1)
- dissed — 2 pair sides, mostly vowel via spelling phonetic key, often with bitches (1)
- blicks — 2 pair sides, mostly vowel via spelling phonetic key, often with bitch (1)
- ganja — 2 pair sides, mostly vowel via vault phonetic_class, often with make (1)
- fridget — 1 pair sides, mostly vowel via vault phonetic_class, often with hopped (1)
- maybach — 1 pair sides, mostly spelling via spelling phonetic key, often with baby (1)
- saucin — 1 pair sides, mostly spelling via spelling phonetic key, often with walk (1)
- raq — 1 pair sides, mostly spelling via spelling phonetic key, often with gang (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Polo G | Can’t Fumble | 69 | 139 | 364 | loose |
| Polo G | Clueless | 36 | 79 | 158 | loose |
| Polo G | Gangsta Graduation | 39 | 61 | 535 | loose |
| Polo G | Go Part 1 | 46 | 61 | 352 | loose |
| Polo G | No Recruits | 44 | 66 | 373 | loose |
| Polo G | Survived The Trenches (Coincidental) | 33 | 31 | 337 | loose |
