# Lil Poppa rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Poppa
- Songs: 2
- Bars kept (Lil Poppa lyric lines): 86
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lil Poppa.
- Credit strings: Lil Poppa.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 779
- REPEAT pairs, recorded separately: 88
- END rhymes: 144
- INNER rhymes: 635

By match:

- PERFECT: 58 (END 24, INNER 34)
- SLANT: 353 (END 74, INNER 279)
- ASSONANCE: 364 (END 44, INNER 320)
- MULTI: 4 (END 2, INNER 2)

By confidence:

- HIGH: 58
- MED: 681
- LOW: 40

## Core

- Core Y: 774
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 372 (47.8%)
- vowel: 364 (46.7%)
- spelling: 39 (5.0%)
- multi: 4 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs
- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 105 pairs (END 7, INNER 98). Words: ain't, dangerous, facin, way, same, game, changin, stage.
2. `vow:IH` — 72 pairs (END 5, INNER 67). Words: hitters, bitch, killed, pistol, lil, him, trippin, wicked.
3. `vow:AH` — 54 pairs (END 10, INNER 44). Words: double, customer, tucked, custom, fuck, what, money, brother.
4. `vow:AY` — 42 pairs (END 21, INNER 21). Words: slidin, ridin, die, drivin, hidin, line, mine, crime.
5. `vow:OW` — 30 pairs (END 1, INNER 29). Words: know, don't, smoke, no, knowin, woke, almost, phone.
6. `slant:IH:liq-stop` — 24 pairs (END 0, INNER 24). Words: lil, killed, kill, built, shit, stick, 'ville, rip.
7. `slant:AH:stop` — 22 pairs (END 12, INNER 10). Words: what, fuck, fucked, tucked, cup, mud, bust, trust.
8. `slant:EY:nas-sib` — 22 pairs (END 17, INNER 5). Words: phase, stage, game, always, same, range, lane, shame.
9. `slant:IH:stop` — 22 pairs (END 3, INNER 19). Words: nigga, wicked, swervin, clip, flipped, built, killed, minute.
10. `slant:AH:nas-stop` — 19 pairs (END 5, INNER 14). Words: run, money, fuck, what, cup, trust, custom, customer.
11. `slant:AY:fric-nas` — 19 pairs (END 0, INNER 19). Words: life, line, live, crime, mine, time, drivin.
12. `vow:AE` — 19 pairs (END 0, INNER 19). Words: traffic, gangster, catch, bangin, lackin, action, snapped, cap.
13. `cmu:EY-M` — 17 pairs (END 12, INNER 5). Words: game, same, shame, name, lame, came, fame, aim.
14. `slant:AY:nas` — 17 pairs (END 10, INNER 7). Words: line, drivin, time, crime, slidin, mine, dime, ridin.
15. `vow:EH` — 17 pairs (END 0, INNER 17). Words: negative, never, friend, next, gettin, rental, yellow, fell.
16. `slant:EY:nas-stop` — 16 pairs (END 0, INNER 16). Words: hater, late, pain, game, flamed, ain't, baby, shame.
17. `slant:AH:fric-stop` — 13 pairs (END 4, INNER 9). Words: love, fuck, enough, what, bluff, blood, cup, tough.
18. `slant:AY:nas-stop` — 12 pairs (END 7, INNER 5). Words: like, line, pipe, time, crime, mine.
19. `slant:EY:nas` — 11 pairs (END 7, INNER 4). Words: pain, main, aim, lane, came, game, name, fame.
20. `slant:IH:nas-stop` — 10 pairs (END 2, INNER 8). Words: swervin, clip, trippin, him, thing, flipped, finna, minute.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 16 pair sides, mostly spelling via spelling phonetic key, often with swervin (2)
- gon — 9 pair sides, mostly spelling via spelling phonetic key, often with knowin (4)
- swervin — 8 pair sides, mostly cmu via vault phonetic_class, often with nigga (2)
- finna — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- slangin — 3 pair sides, mostly spelling via spelling phonetic key, often with traffic (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- cuffin — 2 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- dawg — 2 pair sides, mostly spelling via spelling phonetic key, often with wrong (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- probaby — 1 pair sides, mostly vowel via spelling phonetic key, often with money (1)
- lyin — 1 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with real (1)
- ksoo — 1 pair sides, mostly vowel via spelling phonetic key, often with shoot (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Poppa | Murder Victim (Remix) | 34 | 88 | 365 | AAAA |
| Lil Poppa | Smoke | 52 | 56 | 270 | loose |
