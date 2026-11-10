# Don Ace rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Don Ace
- Songs: 1
- Bars kept (Don Ace lyric lines): 38
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Don Ace.
- Credit strings: Don Ace.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 205
- REPEAT pairs, recorded separately: 37
- END rhymes: 30
- INNER rhymes: 175

By match:

- PERFECT: 15 (END 1, INNER 14)
- SLANT: 112 (END 10, INNER 102)
- ASSONANCE: 76 (END 19, INNER 57)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 15
- MED: 157
- LOW: 33

## Core

- Core Y: 201
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 96 (46.8%)
- vowel: 76 (37.1%)
- spelling: 31 (15.1%)
- multi: 2 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 25 pairs (END 12, INNER 13). Words: pistol, years, kissed, issue, pictures, stick, shit, pickle.
2. `slant:IH:liq-stop` — 20 pairs (END 1, INNER 19). Words: lil, shit, drip, slip, stick, still, pistol, kissed.
3. `slant:IH:stop` — 14 pairs (END 0, INNER 14). Words: nigga, shit, stick, drip, slip, hit, lick, kissed.
4. `vow:AE` — 14 pairs (END 2, INNER 12). Words: savage, scatpack, can, hang, rats, ask, plat, niggas.
5. `vow:AY` — 14 pairs (END 1, INNER 13). Words: ridin, five, like, try, by, nine, brian, light.
6. `slant:IH:sib-stop` — 11 pairs (END 0, INNER 11). Words: nigga, niggas, issue, stick.
7. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: rob, everybody, block, got, shot.
8. `slant:EH:fric-stop` — 7 pairs (END 0, INNER 7). Words: whoever, get, check, head, set.
9. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: ho, know, go.
10. `vow:IY` — 6 pairs (END 1, INNER 5). Words: need, east, keep, see, nobody, freak.
11. `slant:AE:sib-stop` — 5 pairs (END 2, INNER 3). Words: rats, nat, ask, ass, plat, rat.
12. `slant:AY:fric-stop` — 5 pairs (END 0, INNER 5). Words: five, like, light.
13. `slant:IH:sib` — 5 pairs (END 4, INNER 1). Words: niggas, pictures, nichols, killers.
14. `vow:AH` — 5 pairs (END 0, INNER 5). Words: drum, hundred, fuckin, humble.
15. `vow:EH` — 5 pairs (END 0, INNER 5). Words: myself, check, head, whoever.
16. `slant:AY:nas-stop` — 4 pairs (END 0, INNER 4). Words: like, brian, nine.
17. `slant:EH:stop` — 4 pairs (END 0, INNER 4). Words: check, head.
18. `slant:IY:nas-stop` — 4 pairs (END 0, INNER 4). Words: tryna, keep, need.
19. `vow:EY` — 4 pairs (END 3, INNER 1). Words: play, ain't, takin, crazy, daily, take.
20. `cmu:AE-T` — 3 pairs (END 1, INNER 2). Words: nat, plat, rat.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 16 pair sides, mostly spelling via spelling phonetic key, often with niggas (9)
- niggas — 13 pair sides, mostly spelling via spelling phonetic key, often with nigga (9)
- plat — 5 pair sides, mostly spelling via spelling phonetic key, often with nat (2)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with keep (3)
- scatpack — 4 pair sides, mostly vowel via spelling phonetic key, often with plat (2)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with tote (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Don Ace | 4 5 (Remix) | 38 | 30 | 175 | loose |
