# Jimbo World rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Jimbo World
- Songs: 1
- Bars kept (Jimbo World lyric lines): 43
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Jimbo World.
- Credit strings: Jimbo World.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 275
- REPEAT pairs, recorded separately: 41
- END rhymes: 51
- INNER rhymes: 224

By match:

- PERFECT: 14 (END 3, INNER 11)
- SLANT: 136 (END 24, INNER 112)
- ASSONANCE: 124 (END 24, INNER 100)
- MULTI: 1 (END 0, INNER 1)

By confidence:

- HIGH: 14
- MED: 243
- LOW: 18

## Core

- Core Y: 273
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 133 (48.4%)
- vowel: 124 (45.1%)
- spelling: 17 (6.2%)
- multi: 1 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 32 pairs (END 2, INNER 30). Words: fuckin, much, motherfuckin, coming, guns, fuck, once, what.
2. `vow:IH` — 27 pairs (END 12, INNER 15). Words: dribble, crisps, dishes, bitch, kiss, pistols, kidneys, shit.
3. `vow:OW` — 23 pairs (END 7, INNER 16). Words: no, ho, dope, soap, throats, whole, boat, throat.
4. `slant:AH:nas` — 21 pairs (END 1, INNER 20). Words: fuckin, money, motherfuckin, runnin, coming, drum.
5. `slant:AH:nas-stop` — 12 pairs (END 0, INNER 12). Words: fuck, fuckin, motherfuckin, some, money, cut.
6. `vow:EH` — 11 pairs (END 0, INNER 11). Words: twenty, gettin, check, steppin, never, when, there's, plenty.
7. `slant:IH:stop` — 10 pairs (END 1, INNER 9). Words: shit, nigga, crib, ticket, tick, hit.
8. `vow:IY` — 9 pairs (END 3, INNER 6). Words: t, free, real, g, seen, feel, squeeze, thieves.
9. `slant:IH:nas-sib` — 7 pairs (END 0, INNER 7). Words: bitch, i'ma, kitchen, kiss, bitches, spin, jimmy.
10. `vow:EY` — 7 pairs (END 0, INNER 7). Words: say, ain't, th, tatum, hate, daily, make.
11. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: no, ho, throw, o, know, show.
12. `slant:IH:sib-stop` — 6 pairs (END 1, INNER 5). Words: bitch, tick, kiss, nigga, niggas, shit, crib, hit.
13. `slant:AY:sib-stop` — 5 pairs (END 4, INNER 1). Words: ice, sprite, night, price.
14. `slant:EH:nas` — 5 pairs (END 0, INNER 5). Words: gettin, steppin, revving, when, atm.
15. `slant:IH:sib` — 5 pairs (END 2, INNER 3). Words: dishes, crisps, pistols, glizzies, bitches, bitch.
16. `vow:AA` — 5 pairs (END 0, INNER 5). Words: robbin, cars, exotic, gotta, wash, got.
17. `vow:AE` — 5 pairs (END 0, INNER 5). Words: dripper, can't, track, cap, gang, ran, stash.
18. `slant:AA:sib-stop` — 4 pairs (END 0, INNER 4). Words: gotta, wash, got, watch.
19. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: cap, kodak, can, gang, ran.
20. `slant:AY:fric-stop` — 3 pairs (END 1, INNER 2). Words: like, drive, life, night.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with kiss (2)
- nigga — 5 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- dripper — 4 pair sides, mostly vowel via vault phonetic_class, often with cap (1)
- glizzies — 2 pair sides, mostly spelling via spelling phonetic key, often with crisps (1)
- henny — 1 pair sides, mostly spelling via spelling phonetic key, often with plenty (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- conversate — 1 pair sides, mostly vowel via spelling phonetic key, often with whole (1)
- scammin — 1 pair sides, mostly spelling via spelling phonetic key, often with fuckin (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with leave (1)
- shawty — 1 pair sides, mostly vowel via spelling phonetic key, often with daily (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Jimbo World | Fuckin’ Up | 43 | 51 | 224 | loose |
