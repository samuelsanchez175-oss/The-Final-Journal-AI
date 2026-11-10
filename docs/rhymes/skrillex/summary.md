# Skrillex rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Skrillex
- Songs: 2
- Bars kept (Skrillex lyric lines): 52
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Skrillex.
- Credit strings: Skrillex.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 170
- REPEAT pairs, recorded separately: 31
- END rhymes: 48
- INNER rhymes: 122

By match:

- PERFECT: 7 (END 5, INNER 2)
- SLANT: 78 (END 18, INNER 60)
- ASSONANCE: 82 (END 25, INNER 57)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 10
- MED: 146
- LOW: 14

## Core

- Core Y: 162
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 79 (46.5%)
- vowel: 82 (48.2%)
- spelling: 6 (3.5%)
- multi: 3 (1.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 20 pairs (END 11, INNER 9). Words: health, intention, yourself, cigarettes, step, ghetto, spell, gepetto.
2. `vow:AY` — 15 pairs (END 7, INNER 8). Words: like, swiped, psilocybin, fightin, vice, time, life's, why.
3. `vow:OW` — 11 pairs (END 5, INNER 6). Words: don't, queso, tobacco, gepetto, arrow, low, show, go.
4. `slant:AE:stop` — 9 pairs (END 0, INNER 9). Words: bad, pat, back, cognac, baddie, 'cat.
5. `vow:IH` — 8 pairs (END 0, INNER 8). Words: ditched, chips, sing, pissed, ringtone, ding, anything, strings.
6. `slant:EH:fric-sib` — 7 pairs (END 5, INNER 2). Words: yourself, health, else, wealth.
7. `vow:AE` — 7 pairs (END 0, INNER 7). Words: actin, ass, back, pat, cognac.
8. `vow:AH` — 7 pairs (END 0, INNER 7). Words: hungry, jump, cup, funny, what, come, love, under.
9. `slant:AE:sib-stop` — 5 pairs (END 2, INNER 3). Words: ass, cognac, back, pat, 'cat.
10. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: baby, babe, maybe, make, take.
11. `slant:AE:nas-stop` — 4 pairs (END 0, INNER 4). Words: can, bad, back, 'cat.
12. `slant:EH:sib` — 4 pairs (END 4, INNER 0). Words: else, health, wealth.
13. `cmu:OW` — 3 pairs (END 3, INNER 0). Words: know, low, show.
14. `multi:EY-B-IY` — 3 pairs (END 0, INNER 3). Words: baby, maybe.
15. `slant:AA:liq-stop` — 3 pairs (END 0, INNER 3). Words: sorry, heart, not, lotta.
16. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: not, lotta, heart, lock.
17. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: funny, what, cup, come.
18. `slant:EH:liq-sib` — 3 pairs (END 1, INNER 2). Words: health, spell, where, queso, well.
19. `vow:AA` — 3 pairs (END 0, INNER 3). Words: wanna, heart, somebody, wasn't.
20. `vow:AO` — 3 pairs (END 0, INNER 3). Words: talk, songs, calling.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- queso — 6 pair sides, mostly vowel via spelling phonetic key, often with tobacco (1)
- gepetto — 4 pair sides, mostly vowel via spelling phonetic key, often with tobacco (1)
- baddie — 2 pair sides, mostly spelling via spelling phonetic key, often with bad (1)
- ringtone — 1 pair sides, mostly vowel via spelling phonetic key, often with ditched (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Skrillex | Bad For Me | 41 | 45 | 101 | loose |
| Skrillex | Creepin’ / Leave Me Like This (WESH Edit) [Mixed] | 11 | 3 | 21 | loose |
