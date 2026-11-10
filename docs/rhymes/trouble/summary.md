# Trouble rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Trouble
- Songs: 2
- Bars kept (Trouble lyric lines): 56
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Trouble.
- Credit strings: Trouble.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 466
- REPEAT pairs, recorded separately: 83
- END rhymes: 30
- INNER rhymes: 436

By match:

- PERFECT: 28 (END 0, INNER 28)
- SLANT: 177 (END 14, INNER 163)
- ASSONANCE: 247 (END 15, INNER 232)
- MULTI: 14 (END 1, INNER 13)

By confidence:

- HIGH: 36
- MED: 387
- LOW: 43

## Core

- Core Y: 462
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 164 (35.2%)
- vowel: 247 (53.0%)
- spelling: 41 (8.8%)
- multi: 14 (3.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 88 pairs (END 5, INNER 83). Words: ain't, situation, same, hatin, basic, imagination, came, station.
2. `vow:EH` — 44 pairs (END 4, INNER 40). Words: gettin, penitentiaries, bread, friends, l, penitentiary, plenty, regret.
3. `vow:AE` — 34 pairs (END 2, INNER 32). Words: back, gangsta, rappin, snatched, fast, crab, spazz, laughin.
4. `vow:OW` — 20 pairs (END 0, INNER 20). Words: no, don’t, don't, know, folk, fold, whole, hope.
5. `slant:IH:stop` — 18 pairs (END 2, INNER 16). Words: nigga, wit, shit, big.
6. `vow:IH` — 15 pairs (END 3, INNER 12). Words: wit, pistol, issues, distance, since, bring, still, lil.
7. `slant:IH:sib-stop` — 14 pairs (END 2, INNER 12). Words: niggas, nigga, bitch, shit, wit.
8. `multi:EY-SH-AH-N` — 11 pairs (END 1, INNER 10). Words: situation, imagination, nann situation, airing station, station, hoes imagination, why hesitation, hesitation.
9. `slant:EH:liq-stop` — 11 pairs (END 0, INNER 11). Words: get, tell, bread, l, where, red, nowhere, hell.
10. `vow:AA` — 11 pairs (END 0, INNER 11). Words: parking, gotta, parker, lamas, lot, wanna, stop, dark.
11. `vow:AH` — 11 pairs (END 0, INNER 11). Words: runnin, fuck, some, bust, country, cut, thug, love.
12. `vow:IY` — 10 pairs (END 0, INNER 10). Words: even, see, keep, real, these, free, petty, team.
13. `slant:EY:nas` — 9 pairs (END 0, INNER 9). Words: payin, chain, claim, aim, stain.
14. `slant:EY:nas-stop` — 9 pairs (END 0, INNER 9). Words: chain, make, came, ain't, fade, paper, claim, aim.
15. `vow:AY` — 9 pairs (END 0, INNER 9). Words: testify, ion, die, why, like, homicide, identified, mine.
16. `slant:AA:nas-stop` — 8 pairs (END 0, INNER 8). Words: lot, wanna, stop, marijuana, mama, got, gotta.
17. `cmu:AH-M` — 5 pairs (END 0, INNER 5). Words: 'em, some.
18. `slant:AE:nas-stop` — 5 pairs (END 0, INNER 5). Words: gang, back, cracker, banged, can.
19. `slant:AH:stop` — 5 pairs (END 0, INNER 5). Words: cut, fuck, thug, gutta.
20. `slant:EH:sib` — 5 pairs (END 5, INNER 0). Words: penitentiaries, friends, penitentiary.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 29 pair sides, mostly spelling via spelling phonetic key, often with niggas (12)
- niggas — 13 pair sides, mostly spelling via spelling phonetic key, often with nigga (12)
- spazz — 5 pair sides, mostly vowel via spelling phonetic key, often with cant (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with whole (1)
- troub — 1 pair sides, mostly spelling via spelling phonetic key, often with about (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with lil (1)
- gutta — 1 pair sides, mostly spelling via spelling phonetic key, often with cut (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with own (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Trouble | Ion Like | 23 | 17 | 233 | loose |
| Trouble | Shit Crazy | 33 | 13 | 203 | loose |
