# Loso Loaded rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Loso Loaded
- Songs: 2
- Bars kept (Loso Loaded lyric lines): 88
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Loso Loaded.
- Credit strings: Loso Loaded.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 467
- REPEAT pairs, recorded separately: 57
- END rhymes: 86
- INNER rhymes: 381

By match:

- PERFECT: 40 (END 19, INNER 21)
- SLANT: 177 (END 20, INNER 157)
- ASSONANCE: 243 (END 44, INNER 199)
- MULTI: 7 (END 3, INNER 4)

By confidence:

- HIGH: 42
- MED: 396
- LOW: 29

## Core

- Core Y: 465
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 185 (39.6%)
- vowel: 243 (52.0%)
- spelling: 32 (6.9%)
- multi: 7 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 75 pairs (END 20, INNER 55). Words: ain't, day, make, face, sensei, display, way, weekday.
2. `vow:AE` — 38 pairs (END 4, INNER 34). Words: bad, barrel, can, bands, had, racks, brand, tags.
3. `vow:OW` — 34 pairs (END 9, INNER 25). Words: throw, loso, loaded, don't, hold, no, hole, motor.
4. `vow:EH` — 21 pairs (END 2, INNER 19). Words: never, get, flexin, extensions, ends, spendin, rented, independent.
5. `vow:IH` — 21 pairs (END 1, INNER 20). Words: window, bitch, nicks, hit, whippin, rear, lil, indo.
6. `vow:AY` — 16 pairs (END 5, INNER 11). Words: like, iced, y, breitling, silent, shining, five, white.
7. `cmu:EY` — 15 pairs (END 12, INNER 3). Words: day, spray, way, k, stay, hay, bay, say.
8. `slant:IH:stop` — 14 pairs (END 0, INNER 14). Words: nigga, stick, whip, big, brick, hit, shit, city.
9. `slant:EY:sib-stop` — 13 pairs (END 3, INNER 10). Words: fade, paper, wait, race, always, days, spades, ace.
10. `vow:AA` — 11 pairs (END 0, INNER 11). Words: got, dark, pockets, poppin, want, rockin, commas, gonna.
11. `vow:IY` — 11 pairs (END 1, INNER 10). Words: seen, tee, even, tea, fully, fuckery, real, thirty.
12. `slant:AY:stop` — 10 pairs (END 0, INNER 10). Words: like, right, inside, white, spike, iced.
13. `slant:EY:nas-stop` — 10 pairs (END 0, INNER 10). Words: came, lane, draco, ain't, sprayin, fade, make, straight.
14. `slant:IH:sib-stop` — 10 pairs (END 0, INNER 10). Words: niggas, nigga, bitch, big, hit, city.
15. `slant:EY:nas-sib` — 8 pairs (END 2, INNER 6). Words: lane, came, race, peso, face, days, always, chains.
16. `slant:AH:nas-stop` — 7 pairs (END 0, INNER 7). Words: motherfucker, motherfuckin, run, gun, fuck, kung, nut.
17. `slant:AY:fric-stop` — 6 pairs (END 0, INNER 6). Words: like, five, life, white.
18. `slant:AE:sib-stop` — 5 pairs (END 2, INNER 3). Words: bad, ass, cash, dash, mask, had.
19. `slant:AE:stop` — 5 pairs (END 0, INNER 5). Words: trap, rat, bad, pack, had, master, brand.
20. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: ain't, wait, draco, make, paper, eight.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 19 pair sides, mostly spelling via spelling phonetic key, often with niggas (7)
- niggas — 9 pair sides, mostly spelling via spelling phonetic key, often with nigga (7)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with loso (1)
- fuckery — 1 pair sides, mostly vowel via spelling phonetic key, often with fully (1)
- batcave — 1 pair sides, mostly vowel via spelling phonetic key, often with backpage (1)
- backpage — 1 pair sides, mostly vowel via spelling phonetic key, often with batcave (1)
- gualla — 1 pair sides, mostly spelling via spelling phonetic key, often with gulla (1)
- vacayin — 1 pair sides, mostly spelling via spelling phonetic key, often with youngin (1)
- youngin — 1 pair sides, mostly spelling via spelling phonetic key, often with vacayin (1)
- bling — 1 pair sides, mostly spelling via spelling phonetic key, often with kickin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Loso Loaded | Extortion | 35 | 33 | 130 | loose |
| Loso Loaded | Never Seen | 53 | 53 | 251 | loose |
