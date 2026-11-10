# Alley Boy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Alley Boy
- Songs: 1
- Bars kept (Alley Boy lyric lines): 40
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Alley Boy.
- Credit strings: Alley Boy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 217
- REPEAT pairs, recorded separately: 23
- END rhymes: 28
- INNER rhymes: 189

By match:

- PERFECT: 10 (END 1, INNER 9)
- SLANT: 114 (END 11, INNER 103)
- ASSONANCE: 91 (END 14, INNER 77)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 10
- MED: 173
- LOW: 34

## Core

- Core Y: 217
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 88 (40.6%)
- vowel: 91 (41.9%)
- spelling: 36 (16.6%)
- multi: 2 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 24 pairs (END 5, INNER 19). Words: legs, lenox, when, get, scared, married, spend, buried.
2. `vow:IH` — 20 pairs (END 4, INNER 16). Words: spittin, listen, sticks, him, shit, killed, big, killers.
3. `slant:IH:sib-stop` — 14 pairs (END 1, INNER 13). Words: niggas, nigga, fish, rip, bitch, shit, spinned, big.
4. `vow:AA` — 11 pairs (END 1, INNER 10). Words: hard, bodies, got, glock, gotta, hop, start, cause.
5. `vow:AE` — 10 pairs (END 1, INNER 9). Words: whacked, crashin, rappers, carried, bad, bag, smash, granny.
6. `slant:AA:stop` — 9 pairs (END 0, INNER 9). Words: gotta, got, somebody, block, glock, god, cost, everybody.
7. `slant:IH:nas-stop` — 9 pairs (END 0, INNER 9). Words: him, i'ma, drip, hit, shit, stick.
8. `slant:IH:stop` — 9 pairs (END 0, INNER 9). Words: nigga, hit, big, shit, rip, drip, stick.
9. `slant:EH:nas-stop` — 6 pairs (END 0, INNER 6). Words: 'dem, head, when, get, let, wet, many, spend.
10. `slant:EH:stop` — 6 pairs (END 3, INNER 3). Words: married, scared, head, spend, buried, rest, get.
11. `vow:IY` — 6 pairs (END 0, INNER 6). Words: real, keep, t, three, free.
12. `vow:OW` — 6 pairs (END 0, INNER 6). Words: no, don't, ghosts, show, go, won't.
13. `slant:AA:sib-stop` — 5 pairs (END 0, INNER 5). Words: cause, got, glock, gotta, bodies, god.
14. `slant:EH:liq-stop` — 5 pairs (END 0, INNER 5). Words: air, where, get, let, wet, scared, head.
15. `slant:IH:nas` — 5 pairs (END 0, INNER 5). Words: him, i'ma.
16. `slant:AY:stop` — 4 pairs (END 0, INNER 4). Words: homicide, might, type, like, quiet, riot.
17. `slant:IH:nas-sib` — 4 pairs (END 2, INNER 2). Words: bitch, him, i'ma.
18. `slant:IH:sib` — 4 pairs (END 1, INNER 3). Words: spinned, sticks, fish, licks, diss, niggas, permits.
19. `vow:UW` — 4 pairs (END 1, INNER 3). Words: achoo, shootin, soon, shootouts, shoot.
20. `slant:EH:liq-nas` — 3 pairs (END 0, INNER 3). Words: where, 'dem, air, many, when.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 15 pair sides, mostly spelling via spelling phonetic key, often with niggas (7)
- ima — 10 pair sides, mostly spelling via spelling phonetic key, often with him (5)
- niggas — 8 pair sides, mostly spelling via spelling phonetic key, often with nigga (7)
- spinned — 4 pair sides, mostly cmu via vault phonetic_class, often with killed (1)
- dem — 4 pair sides, mostly spelling via spelling phonetic key, often with get (1)
- peekaboo — 1 pair sides, mostly spelling via spelling phonetic key, often with achoo (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with smoke (1)
- nefew — 1 pair sides, mostly spelling via spelling phonetic key, often with few (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with yall (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Alley Boy | Fish Fry | 40 | 28 | 189 | loose |
