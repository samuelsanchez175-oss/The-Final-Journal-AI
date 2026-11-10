# Jeremie rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Jeremie & Rucka Rucka Ali
- Songs: 1
- Bars kept (Jeremie lyric lines): 21
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Jeremie.
- Credit strings: Jeremie & Rucka Rucka Ali.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 93
- REPEAT pairs, recorded separately: 5
- END rhymes: 2
- INNER rhymes: 91

By match:

- PERFECT: 6 (END 0, INNER 6)
- SLANT: 48 (END 1, INNER 47)
- ASSONANCE: 36 (END 1, INNER 35)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 6
- MED: 76
- LOW: 11

## Core

- Core Y: 91
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 44 (47.3%)
- vowel: 36 (38.7%)
- spelling: 10 (10.8%)
- multi: 3 (3.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 8 pairs (END 0, INNER 8). Words: by, invited, guy, tryin, like, time, try.
2. `vow:AH` — 7 pairs (END 1, INNER 6). Words: government, what, hungry, does, motherfuckers, double, young, upppppp.
3. `meta:XNK` — 6 pairs (END 0, INNER 6). Words: chang, chong, ching.
4. `vow:EH` — 6 pairs (END 0, INNER 6). Words: legend, hell, hells, herro, tells.
5. `vow:IY` — 5 pairs (END 0, INNER 5). Words: sleep, seymour, people, even, cleaning, here, eatin.
6. `slant:AE:nas` — 4 pairs (END 0, INNER 4). Words: chang, damn, goddamn.
7. `slant:AE:nas-stop` — 4 pairs (END 0, INNER 4). Words: track, damn, chang, thank.
8. `slant:AH:stop` — 4 pairs (END 0, INNER 4). Words: fuck, upppppp, shut, rucka, what.
9. `vow:AE` — 4 pairs (END 0, INNER 4). Words: damn, dragon, thank, track.
10. `multi:AH-K-AH` — 3 pairs (END 0, INNER 3). Words: used america, america, rucka, by rucka, rucka rucka.
11. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: everyone, fuck, shut, upppppp.
12. `slant:AO:nas-stop` — 3 pairs (END 0, INNER 3). Words: talk, song, chong.
13. `vow:OW` — 3 pairs (END 0, INNER 3). Words: old, go, don't, know.
14. `cmu:AO-NG` — 2 pairs (END 0, INNER 2). Words: chong, song.
15. `slant:AA:stop` — 2 pairs (END 0, INNER 2). Words: not, want.
16. `slant:AH:sib-stop` — 2 pairs (END 0, INNER 2). Words: does, rucka, what.
17. `slant:IY:liq-stop` — 2 pairs (END 0, INNER 2). Words: sleep, here, people.
18. `slant:OW:nas-stop` — 2 pairs (END 0, INNER 2). Words: own, toby, don't.
19. `cmu:AE-M` — 1 pairs (END 0, INNER 1). Words: damn, goddamn.
20. `cmu:AY` — 1 pairs (END 0, INNER 1). Words: by, guy.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- rucka — 5 pair sides, mostly multi via spelling phonetic key, often with america (3)
- hells — 3 pair sides, mostly vowel via spelling phonetic key, often with hell (1)
- queef — 1 pair sides, mostly spelling via spelling phonetic key, often with here (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Jeremie & Rucka Rucka Ali | It’s Not Nice (feat. DJ Not Nice, Toby Queef, Seymour Schwartz & Fredrique Shampoo) | 21 | 2 | 91 | loose |
