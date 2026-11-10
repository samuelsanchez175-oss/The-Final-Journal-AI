# Twista rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Twista
- Songs: 1
- Bars kept (Twista lyric lines): 37
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Twista.
- Credit strings: Twista.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 277
- REPEAT pairs, recorded separately: 27
- END rhymes: 32
- INNER rhymes: 245

By match:

- PERFECT: 40 (END 16, INNER 24)
- SLANT: 111 (END 10, INNER 101)
- ASSONANCE: 126 (END 6, INNER 120)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 27
- MED: 238
- LOW: 12

## Core

- Core Y: 274
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 128 (46.2%)
- vowel: 126 (45.5%)
- spelling: 23 (8.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 37 pairs (END 3, INNER 34). Words: friend, enemies, stretching, prayers, extended, friends, ends, wearing.
2. `vow:EY` — 34 pairs (END 0, INNER 34). Words: ain't, pay, dj, playing, may, break, fake, shame.
3. `slant:IH:stop` — 19 pairs (END 0, INNER 19). Words: shit, click, hitter, clip, rip, slip, nigga, sit.
4. `vow:OW` — 19 pairs (END 1, INNER 18). Words: go, no, broke, only, tote, toting, smoke, show.
5. `vow:AE` — 13 pairs (END 0, INNER 13). Words: after, that'll, can't, clack, back, mac, crack, catch.
6. `cmu:AE-T` — 11 pairs (END 8, INNER 3). Words: hat, grat, ratat, gat.
7. `slant:AH:nas` — 11 pairs (END 1, INNER 10). Words: come, money, none, coming, some, fuckin, dumb.
8. `cmu:AE-K` — 6 pairs (END 3, INNER 3). Words: clack, back, mac, crack.
9. `cmu:AH-M` — 6 pairs (END 2, INNER 4). Words: come, dumb, some.
10. `slant:AH:nas-stop` — 6 pairs (END 2, INNER 4). Words: money, club, what, fuckin, fuck, some, none.
11. `slant:EH:nas-stop` — 6 pairs (END 3, INNER 3). Words: enemy, friend, when, meant, bet, get.
12. `vow:IH` — 6 pairs (END 0, INNER 6). Words: clips, killers, critical, condition, still, kill, killing, him.
13. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: got, chopper, job, prop.
14. `slant:EH:nas-sib` — 5 pairs (END 2, INNER 3). Words: enemy, when, guess, wearing, prayers, enemies, energy.
15. `vow:AY` — 5 pairs (END 2, INNER 3). Words: try, high, price, like, life, knife.
16. `slant:AE:stop` — 4 pairs (END 0, INNER 4). Words: mac, ratat, hat, grat, gat, pack.
17. `slant:EH:sib-stop` — 4 pairs (END 1, INNER 3). Words: energy, friend, meant, guess, bet, benz, send.
18. `slant:IH:sib-stop` — 4 pairs (END 0, INNER 4). Words: nigga, niggas, rich, shit, sit, bitch.
19. `vow:AA` — 4 pairs (END 0, INNER 4). Words: parking, got, job, prop.
20. `vow:IY` — 4 pairs (END 0, INNER 4). Words: seen, keep, see, vip, key, g.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- grat — 8 pair sides, mostly spelling via spelling phonetic key, often with hat (4)
- ratat — 7 pair sides, mostly spelling via spelling phonetic key, often with hat (2)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- thot — 3 pair sides, mostly spelling via spelling phonetic key, often with got (2)
- bulletsll — 2 pair sides, mostly vowel via spelling phonetic key, often with some (2)
- frienemies — 1 pair sides, mostly spelling via spelling phonetic key, often with enemies (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Twista | No Friend of Me | 37 | 32 | 245 | loose |
