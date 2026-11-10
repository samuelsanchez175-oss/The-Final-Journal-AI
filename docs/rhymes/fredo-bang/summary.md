# Fredo Bang rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Fredo Bang
- Songs: 3
- Bars kept (Fredo Bang lyric lines): 114
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Fredo Bang.
- Credit strings: Fredo Bang.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 729
- REPEAT pairs, recorded separately: 69
- END rhymes: 123
- INNER rhymes: 606

By match:

- PERFECT: 59 (END 12, INNER 47)
- SLANT: 307 (END 63, INNER 244)
- ASSONANCE: 351 (END 48, INNER 303)
- MULTI: 12 (END 0, INNER 12)

By confidence:

- HIGH: 69
- MED: 623
- LOW: 37

## Core

- Core Y: 725
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 331 (45.4%)
- vowel: 351 (48.1%)
- spelling: 35 (4.8%)
- multi: 12 (1.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 61 pairs (END 9, INNER 52). Words: don't, go, coaches, open, notice, told, no, broke.
2. `vow:IH` — 60 pairs (END 10, INNER 50). Words: business, bitch, kids, give, shit, linens, pittsburgh, finished.
3. `vow:IY` — 45 pairs (END 13, INNER 32). Words: bp, fleets, keepin, streets, these, free, keep, demon.
4. `vow:AH` — 42 pairs (END 6, INNER 36). Words: fuck, fuckin, puttin, fucking, vulture, hundred, toughest, come.
5. `vow:AA` — 34 pairs (END 4, INNER 30). Words: got, collins, spot, lockin, knockin, watchin, drop, not.
6. `vow:AE` — 32 pairs (END 3, INNER 29). Words: master, lambs, ass, asked, hands, bandit, can't, mad.
7. `vow:EY` — 28 pairs (END 1, INNER 27). Words: ain't, j, range, failed, game, chains, make, play.
8. `vow:AW` — 21 pairs (END 0, INNER 21). Words: how, proud, doubted, now, count, 'bout, 'round, town.
9. `slant:IY:sib-stop` — 19 pairs (END 12, INNER 7). Words: these, speak, sleep, beat, week, lease, streets, repeat.
10. `vow:EH` — 17 pairs (END 2, INNER 15). Words: remember, set, let, tennis, get, tender, tell, l's.
11. `slant:AA:stop` — 15 pairs (END 0, INNER 15). Words: not, got, stop, copy, rod, facade, heart, hopped.
12. `slant:IH:stop` — 14 pairs (END 3, INNER 11). Words: nigga, big, wit, jiggy, shit.
13. `slant:IH:sib-stop` — 11 pairs (END 1, INNER 10). Words: bitch, shit, clip, big, wit, nigga, niggas.
14. `cmu:OW` — 10 pairs (END 0, INNER 10). Words: go, no, show, ho, throw.
15. `slant:AH:nas-sib` — 9 pairs (END 1, INNER 8). Words: one, done, much, brother, run, other, once, 'nother.
16. `slant:IY:fric-stop` — 9 pairs (END 7, INNER 2). Words: leave, beat, repeat, week, speak, feet, heat, leak.
17. `slant:AA:nas` — 8 pairs (END 1, INNER 7). Words: poppin, watchin, rockin, lockin, knockin, bottom.
18. `slant:AE:nas-stop` — 8 pairs (END 2, INNER 6). Words: back, smackin, lackin, ran, pack, black, mad, anna.
19. `slant:EH:stop` — 8 pairs (END 0, INNER 8). Words: get, said, beretta, spent, ssed.
20. `slant:IY:stop` — 8 pairs (END 6, INNER 2). Words: sleep, feet, leak, freak, heat, keep, week, speak.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 11 pair sides, mostly spelling via spelling phonetic key, often with wit (3)
- jiggy — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- swag — 4 pair sides, mostly spelling via spelling phonetic key, often with act (1)
- ssed — 4 pair sides, mostly spelling via spelling phonetic key, often with get (2)
- thuggin — 2 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with keep (1)
- chanaynay — 2 pair sides, mostly spelling via spelling phonetic key, often with plan (1)
- citco — 2 pair sides, mostly vowel via vault phonetic_class, often with catch (1)
- rari — 2 pair sides, mostly spelling via spelling phonetic key, often with rather (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with lil (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with hitters (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with wont (1)
- nev — 2 pair sides, mostly spelling via spelling phonetic key, often with ssed (1)
- dolo — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- scammin — 1 pair sides, mostly vowel via spelling phonetic key, often with rari (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Fredo Bang | Back 2 Back | 33 | 52 | 238 | loose |
| Fredo Bang | Proud Of Me | 47 | 44 | 190 | loose |
| Fredo Bang | Throw Away | 34 | 27 | 178 | loose |
