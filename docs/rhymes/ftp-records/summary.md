# FTP Records rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: FTP Records
- Songs: 2
- Bars kept (FTP Records lyric lines): 118
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: FTP Records.
- Credit strings: FTP Records.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 795
- REPEAT pairs, recorded separately: 136
- END rhymes: 156
- INNER rhymes: 639

By match:

- PERFECT: 54 (END 9, INNER 45)
- SLANT: 341 (END 50, INNER 291)
- ASSONANCE: 388 (END 93, INNER 295)
- MULTI: 12 (END 4, INNER 8)

By confidence:

- HIGH: 63
- MED: 676
- LOW: 56

## Core

- Core Y: 779
- Core N among rhyme pairs: 16

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 351 (44.2%)
- vowel: 388 (48.8%)
- spelling: 44 (5.5%)
- multi: 12 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 107 pairs (END 40, INNER 67). Words: bitch, fishes, listen, kitchen, fitted, wishes, shit, think.
2. `vow:IY` — 68 pairs (END 24, INNER 44). Words: ftp, even, sleep, see, dreams, shawty, jeep, c.
3. `vow:OW` — 53 pairs (END 0, INNER 53). Words: don't, know, going, home, no, chokin, ho, ghosts.
4. `vow:AA` — 36 pairs (END 16, INNER 20). Words: charlie, swatted, vomit, comet, charmin, block, charlotte, got.
5. `slant:IH:sib-stop` — 32 pairs (END 3, INNER 29). Words: bitch, shit, crib, ti'd, sick, dick, hit, stick.
6. `vow:AE` — 29 pairs (END 10, INNER 19). Words: habits, can't, salad, addy, trap, advantage, trappin, savage.
7. `vow:AH` — 23 pairs (END 0, INNER 23). Words: fuck, mushroom, bust, khaled, running, hundred, motherfuckers, nothing.
8. `slant:IH:stop` — 22 pairs (END 1, INNER 21). Words: shit, crib, nigga, sick, big, ti'd, whip, crypt.
9. `slant:AH:nas-stop` — 19 pairs (END 0, INNER 19). Words: fuck, some, dumb, fuckin, run, young, upper, money.
10. `vow:EY` — 19 pairs (END 0, INNER 19). Words: make, population, away, dj, say, pay, ain't, crazy.
11. `slant:IH:liq-stop` — 18 pairs (END 0, INNER 18). Words: lil, crib, still, shit, bill, ti'd, big, it'll.
12. `vow:EH` — 17 pairs (END 3, INNER 14). Words: backends, where, friend, senate, let's, tell, buried, when.
13. `slant:IH:sib` — 16 pairs (END 5, INNER 11). Words: bitch, fishes, dishes, pigs, britches, ears, wishes, sixes.
14. `slant:AY:liq-stop` — 15 pairs (END 0, INNER 15). Words: i'll, like, side, outside, tired, might, ride, light.
15. `slant:AH:stop` — 14 pairs (END 3, INNER 11). Words: fuck, what, club, blinged, cup, blood, hunnid, hundred.
16. `vow:AY` — 14 pairs (END 0, INNER 14). Words: spiked, i'll, breitling, ridin, iced, high, flies, biting.
17. `slant:AY:stop` — 12 pairs (END 2, INNER 10). Words: like, ride, outside, tired, might, westside, light, side.
18. `cmu:AW-N-D` — 10 pairs (END 0, INNER 10). Words: around, 'round, mound.
19. `cmu:IY` — 10 pairs (END 4, INNER 6). Words: see, c, ftp, z, lyin, g, t, v.
20. `slant:AA:stop` — 10 pairs (END 0, INNER 10). Words: gotta, swatted, god, got, stop, popped, rock, not.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- shawty — 8 pair sides, mostly vowel via spelling phonetic key, often with see (1)
- tid — 8 pair sides, mostly spelling via spelling phonetic key, often with bitch (3)
- lyin — 7 pair sides, mostly vowel via vault phonetic_class, often with jeep (1)
- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- hunnid — 3 pair sides, mostly spelling via spelling phonetic key, often with running (1)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with here (2)
- forgiato — 3 pair sides, mostly vowel via spelling phonetic key, often with afford (1)
- dyin — 3 pair sides, mostly spelling via spelling phonetic key, often with jeep (1)
- geeked — 3 pair sides, mostly vowel via spelling phonetic key, often with here (1)
- sammich — 2 pair sides, mostly spelling via spelling phonetic key, often with advantage (1)
- blinged — 2 pair sides, mostly cmu via vault phonetic_class, often with fuck (2)
- zacs — 2 pair sides, mostly spelling via spelling phonetic key, often with ass (2)
- cvstillo — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- caus — 1 pair sides, mostly spelling via spelling phonetic key, often with all (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with chicago (1)
- forgiatos — 1 pair sides, mostly vowel via spelling phonetic key, often with song (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- mothafuckin — 1 pair sides, mostly spelling via spelling phonetic key, often with mothafucka (1)
- mothafucka — 1 pair sides, mostly spelling via spelling phonetic key, often with mothafuckin (1)
- zacftp — 1 pair sides, mostly vowel via spelling phonetic key, often with cant (1)
- tosey — 1 pair sides, mostly spelling via spelling phonetic key, often with going (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| FTP Records | Charlie | 57 | 73 | 277 | loose |
| FTP Records | Fuck the World | 61 | 83 | 362 | loose |
