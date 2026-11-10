# Coi Leray rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Coi Leray
- Songs: 3
- Bars kept (Coi Leray lyric lines): 140
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Coi Leray.
- Credit strings: Coi Leray.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 919
- REPEAT pairs, recorded separately: 95
- END rhymes: 207
- INNER rhymes: 712

By match:

- PERFECT: 68 (END 22, INNER 46)
- SLANT: 403 (END 82, INNER 321)
- ASSONANCE: 446 (END 101, INNER 345)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 61
- MED: 818
- LOW: 40

## Core

- Core Y: 907
- Core N among rhyme pairs: 12

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 433 (47.1%)
- vowel: 446 (48.5%)
- spelling: 38 (4.1%)
- multi: 2 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 119 pairs (END 15, INNER 104). Words: bitch, bitches, shit, fits, sixty, whips, fifty, wrist.
2. `vow:AH` — 57 pairs (END 26, INNER 31). Words: fuck, trust, tussle, what's, somethin, muscle, puzzle, brother.
3. `vow:OW` — 56 pairs (END 15, INNER 41). Words: lonely, don't, no, show, know, chosen, posted, growin.
4. `vow:AY` — 52 pairs (END 5, INNER 47). Words: diamonds, bae, kind, time, slidin, why, like, line.
5. `vow:EY` — 52 pairs (END 21, INNER 31). Words: ain't, patience, greatness, outdated, favors, baby, racin, rotation.
6. `slant:IH:sib-stop` — 40 pairs (END 13, INNER 27). Words: shit, bitch, rich, richie, fits, dick, drip, lit.
7. `slant:IH:stop` — 40 pairs (END 5, INNER 35). Words: shit, nigga, dick, fifty, big, clip, drip, crib.
8. `vow:AE` — 30 pairs (END 6, INNER 24). Words: can't, racks, savage, magic, bag, tags, gas, damn.
9. `vow:AO` — 28 pairs (END 13, INNER 15). Words: all, law, storage, important, afford, gorgeous, water, talk.
10. `slant:AA:stop` — 27 pairs (END 0, INNER 27). Words: gotta, got, top, stop, lot, copped, hop, want.
11. `slant:IH:liq-stop` — 19 pairs (END 4, INNER 15). Words: really, shit, still, lil, dick, drip, lit, split.
12. `vow:IY` — 18 pairs (END 0, INNER 18). Words: even, free, screamin, streets, cheat, believe, feet, here.
13. `slant:AY:nas-stop` — 17 pairs (END 7, INNER 10). Words: time, like, ride, shine, line, night, feline, light.
14. `vow:AA` — 17 pairs (END 0, INNER 17). Words: rollin, glock, box, costin, got, cause, talkin, sock.
15. `slant:AH:nas-stop` — 14 pairs (END 1, INNER 13). Words: fuck, money, one, what, come, run, luck, slut.
16. `slant:IH:sib` — 14 pairs (END 3, INNER 11). Words: bitch, richie, whips, bitches, rich, piss, fish, fits.
17. `slant:AE:sib-stop` — 13 pairs (END 0, INNER 13). Words: ass, cash, bad, bag, swag, ask, sack, gas.
18. `slant:IH:liq-sib` — 12 pairs (END 2, INNER 10). Words: bitch, really, still, rich, richie.
19. `slant:AY:stop` — 11 pairs (END 2, INNER 9). Words: like, right, ride, night, kind, light.
20. `vow:EH` — 11 pairs (END 0, INNER 11). Words: check, every, get, m's, spend, gettin, lettuce, went.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- vibin — 6 pair sides, mostly spelling via spelling phonetic key, often with crib (2)
- cabbag — 5 pair sides, mostly spelling via spelling phonetic key, often with bag (3)
- swag — 5 pair sides, mostly spelling via spelling phonetic key, often with bag (2)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with broke (1)
- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- homie — 2 pair sides, mostly spelling via spelling phonetic key, often with moanin (1)
- hol — 2 pair sides, mostly spelling via spelling phonetic key, often with broke (1)
- branzino — 2 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- raq — 2 pair sides, mostly spelling via spelling phonetic key, often with sack (1)
- duffle — 2 pair sides, mostly vowel via spelling phonetic key, often with muscle (1)
- spazz — 2 pair sides, mostly cmu via vault phonetic_class, often with mouth (1)
- bomin — 1 pair sides, mostly spelling via spelling phonetic key, often with nothin (1)
- hunnid — 1 pair sides, mostly vowel via spelling phonetic key, often with somethin (1)
- dyin — 1 pair sides, mostly spelling via spelling phonetic key, often with tryin (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with fits (1)
- fishpole — 1 pair sides, mostly vowel via spelling phonetic key, often with tinted (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Coi Leray | At The Top | 34 | 39 | 150 | loose |
| Coi Leray | Pink Money | 54 | 78 | 216 | loose |
| Coi Leray | Thief In The Night | 52 | 90 | 346 | loose |
