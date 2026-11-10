# Bankroll Freddie rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bankroll Freddie
- Songs: 1
- Bars kept (Bankroll Freddie lyric lines): 38
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bankroll Freddie.
- Credit strings: Bankroll Freddie.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 209
- REPEAT pairs, recorded separately: 29
- END rhymes: 61
- INNER rhymes: 148

By match:

- PERFECT: 19 (END 8, INNER 11)
- SLANT: 93 (END 20, INNER 73)
- ASSONANCE: 97 (END 33, INNER 64)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 13
- MED: 171
- LOW: 25

## Core

- Core Y: 203
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 87 (41.6%)
- vowel: 97 (46.4%)
- spelling: 25 (12.0%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 42 pairs (END 15, INNER 27). Words: bitch, livin, forgiveness, ballistic, switches, commission, insisting, middle.
2. `vow:AE` — 17 pairs (END 3, INNER 14). Words: handling, rapper, last, cappers, trappin, straps, trap, strapped.
3. `slant:AE:stop` — 15 pairs (END 2, INNER 13). Words: rapper, trap, clapped, black, rap, lap, tap, last.
4. `cmu:AE-P` — 11 pairs (END 6, INNER 5). Words: rap, lap, cap, tap, trap.
5. `slant:AE:nas-stop` — 11 pairs (END 0, INNER 11). Words: trappin, man, rapper, trap, rap, camera, strapped, cap.
6. `vow:ER` — 11 pairs (END 11, INNER 0). Words: purpose, lurkin, worth, serve, served, nervous.
7. `slant:AE:sib-stop` — 9 pairs (END 5, INNER 4). Words: straps, trappers, rap, lap, cap, tap, rapper, trap.
8. `slant:EH:stop` — 9 pairs (END 0, INNER 9). Words: head, get, 'vette, better, bet, step, stepper, 'head.
9. `slant:IH:stop` — 9 pairs (END 0, INNER 9). Words: nigga, kid, hit, ticket, trist.
10. `vow:OW` — 7 pairs (END 0, INNER 7). Words: no, don't, don’t, ho, lovin, bezzo, go.
11. `slant:IH:sib-stop` — 5 pairs (END 0, INNER 5). Words: nigga, niggas, bitch, kid, stick.
12. `vow:AH` — 5 pairs (END 0, INNER 5). Words: fuck, comin, consult, what.
13. `cmu:IH-NG` — 4 pairs (END 1, INNER 3). Words: swerving, scamming, comin, lurkin, insisting, rocking.
14. `vow:EY` — 4 pairs (END 0, INNER 4). Words: play, complaining, game, ain't, hate, make.
15. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: not, drop, want, opp, block.
16. `slant:EH:nas-stop` — 3 pairs (END 0, INNER 3). Words: when, 'vette, head, better.
17. `slant:EY:nas-stop` — 3 pairs (END 0, INNER 3). Words: chain, ain't, make, came.
18. `vow:AO` — 3 pairs (END 3, INNER 0). Words: forces, torched, quarter, horse.
19. `slant:AH:nas` — 2 pairs (END 0, INNER 2). Words: run, dumb, some.
20. `slant:ER:fric-sib` — 2 pairs (END 2, INNER 0). Words: serve, worth, nervous.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 11 pair sides, mostly spelling via spelling phonetic key, often with kid (4)
- swerving — 4 pair sides, mostly spelling via spelling phonetic key, often with served (1)
- cappers — 4 pair sides, mostly vowel via spelling phonetic key, often with rapper (2)
- thot — 3 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with kid (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- baguettes — 2 pair sides, mostly vowel via spelling phonetic key, often with strapped (1)
- scamming — 2 pair sides, mostly spelling via spelling phonetic key, often with insisting (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with thot (1)
- coked — 1 pair sides, mostly cmu via vault phonetic_class, often with bows (1)
- trist — 1 pair sides, mostly spelling via spelling phonetic key, often with hit (1)
- bezzo — 1 pair sides, mostly vowel via spelling phonetic key, often with go (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bankroll Freddie | Bows | 38 | 61 | 148 | loose |
