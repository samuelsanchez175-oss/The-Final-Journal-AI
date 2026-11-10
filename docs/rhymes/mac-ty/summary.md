# Mac Ty rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Mac Ty
- Songs: 1
- Bars kept (Mac Ty lyric lines): 46
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Mac Ty.
- Credit strings: Mac Ty.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 265
- REPEAT pairs, recorded separately: 25
- END rhymes: 81
- INNER rhymes: 184

By match:

- PERFECT: 5 (END 1, INNER 4)
- SLANT: 125 (END 22, INNER 103)
- ASSONANCE: 133 (END 56, INNER 77)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 6
- MED: 241
- LOW: 18

## Core

- Core Y: 261
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 115 (43.4%)
- vowel: 133 (50.2%)
- spelling: 15 (5.7%)
- multi: 2 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 57 pairs (END 38, INNER 19). Words: fabric, taxes, snatch, attic, ratchet, trap, fasting, passion.
2. `vow:IY` — 28 pairs (END 12, INNER 16). Words: feeling, season, demon, speakin, proceed, sneaky, keyless, freaky.
3. `vow:AA` — 18 pairs (END 4, INNER 14). Words: rocking, gonna, rockin, start, copy, solid, mama, versace.
4. `slant:AA:nas-stop` — 14 pairs (END 0, INNER 14). Words: gonna, gotta, got, copy, mama, body, rockin, jock.
5. `vow:EY` — 11 pairs (END 2, INNER 9). Words: ain't, paying, waste, weigh, lay, payin, made, change.
6. `slant:AA:stop` — 10 pairs (END 2, INNER 8). Words: got, copy, gotta, body, start, jock.
7. `slant:AA:sib-stop` — 9 pairs (END 3, INNER 6). Words: cause, versace, gotta, got, copy, body.
8. `slant:AA:nas-sib` — 7 pairs (END 0, INNER 7). Words: cause, gonna, mama, versace.
9. `slant:AE:stop` — 7 pairs (END 2, INNER 5). Words: attic, trap, fabric, bad.
10. `slant:IH:stop` — 7 pairs (END 0, INNER 7). Words: nigga, drip, dealership, dick.
11. `slant:IY:nas` — 7 pairs (END 5, INNER 2). Words: freezing, season, cheesin, feeling, demon.
12. `vow:OW` — 7 pairs (END 0, INNER 7). Words: know, float, broke, over.
13. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: ain't, waste.
14. `vow:AY` — 5 pairs (END 0, INNER 5). Words: biting, designer, like, while, find.
15. `slant:AE:sib-stop` — 4 pairs (END 1, INNER 3). Words: snatch, trap, ratchet, bad.
16. `slant:AE:nas` — 3 pairs (END 2, INNER 1). Words: fasting, passion, fashion, happen.
17. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: what, some, come, fuck, money, plug.
18. `slant:IH:nas` — 3 pairs (END 0, INNER 3). Words: swimmin, him, inner, missin, diggin.
19. `slant:IY:nas-stop` — 3 pairs (END 0, INNER 3). Words: tryna, speed, freaky, sneaky.
20. `slant:IY:stop` — 3 pairs (END 1, INNER 2). Words: speed, sleep, week, freaky, sneaky.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with drip (3)
- cheesin — 6 pair sides, mostly spelling via spelling phonetic key, often with feeling (2)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with speed (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with lil (1)
- diamondback — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Mac Ty | Fashion | 46 | 81 | 184 | loose |
