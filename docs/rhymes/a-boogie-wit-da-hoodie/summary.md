# A Boogie wit da Hoodie rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: A Boogie wit da Hoodie
- Songs: 8
- Bars kept (A Boogie wit da Hoodie lyric lines): 300
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: A Boogie wit da Hoodie.
- Credit strings: A Boogie wit da Hoodie.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 2031
- REPEAT pairs, recorded separately: 275
- END rhymes: 326
- INNER rhymes: 1705

By match:

- PERFECT: 150 (END 42, INNER 108)
- SLANT: 836 (END 123, INNER 713)
- ASSONANCE: 1034 (END 157, INNER 877)
- MULTI: 11 (END 4, INNER 7)

By confidence:

- HIGH: 152
- MED: 1804
- LOW: 75

## Core

- Core Y: 2008
- Core N among rhyme pairs: 23

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 921 (45.3%)
- vowel: 1034 (50.9%)
- spelling: 65 (3.2%)
- multi: 11 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 8 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 173 pairs (END 57, INNER 116). Words: got, artist, harley, bodies, nothin, father, problems, charge.
2. `vow:IH` — 141 pairs (END 27, INNER 114). Words: bitches, bitch, richard, wrist, think, dipped, brickley, biggie.
3. `vow:EY` — 128 pairs (END 2, INNER 126). Words: ain't, way, say, make, baby, same, davidson, play.
4. `vow:OW` — 111 pairs (END 2, INNER 109). Words: don't, know, no, only, home, told, hoes, go.
5. `vow:AY` — 86 pairs (END 17, INNER 69). Words: like, time, high, reply, why, write, comply, life's.
6. `vow:EH` — 83 pairs (END 2, INNER 81). Words: get, flex, friends, never, flexing, went, friend, when.
7. `vow:AH` — 78 pairs (END 2, INNER 76). Words: one, fuck, bustin, hundred, funds, cuffed, done, fucked.
8. `vow:AE` — 72 pairs (END 1, INNER 71). Words: can't, last, mad, had, actin, bad, damn, panties.
9. `vow:IY` — 71 pairs (END 18, INNER 53). Words: undefeated, three, even, need, company, shotty, key, see.
10. `slant:AA:stop` — 54 pairs (END 8, INNER 46). Words: got, god, want, body, chopper, rob, deposit, drop.
11. `slant:IH:stop` — 47 pairs (END 3, INNER 44). Words: nigga, dick, clip, whipped, think, brick, wit, biggie.
12. `vow:AW` — 47 pairs (END 25, INNER 22). Words: about, down, fountain, now, around, surrounded, bouncer, without.
13. `slant:AH:nas-stop` — 39 pairs (END 0, INNER 39). Words: fuck, one, done, what, money, makeup, fun, bum.
14. `slant:AY:stop` — 35 pairs (END 9, INNER 26). Words: like, nighter, might, ride, tried, excited, right, sniper.
15. `slant:AH:nas` — 34 pairs (END 20, INNER 14). Words: cum, one, done, tongue, son, dumb, run, young.
16. `slant:IH:sib-stop` — 33 pairs (END 8, INNER 25). Words: bitch, dick, miss, richer, kiss, richard, chris, wit.
17. `cmu:AH-N` — 32 pairs (END 24, INNER 8). Words: done, one, run, fun, son, gun.
18. `vow:AO` — 32 pairs (END 4, INNER 28). Words: water, florida, all, gone, quarter, false, york, songs.
19. `cmu:OW` — 26 pairs (END 1, INNER 25). Words: no, know, go, slow, ho, show, throw, balmain.
20. `slant:AH:fric-nas` — 26 pairs (END 0, INNER 26). Words: love, done, cum, one, fun, gun, son, run.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 9 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- gon — 8 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- tryna — 7 pair sides, mostly spelling via spelling phonetic key, often with keep (2)
- killy — 7 pair sides, mostly vowel via spelling phonetic key, often with brickley (1)
- shotty — 7 pair sides, mostly vowel via spelling phonetic key, often with tricky (1)
- archy — 5 pair sides, mostly spelling via spelling phonetic key, often with harness (1)
- titties — 4 pair sides, mostly spelling via spelling phonetic key, often with baguettes (1)
- blicky — 4 pair sides, mostly spelling via spelling phonetic key, often with richer (1)
- bih — 4 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- balmain — 4 pair sides, mostly vowel via vault phonetic_class, often with clothes (1)
- babygirl — 3 pair sides, mostly spelling via spelling phonetic key, often with girl (3)
- wagen — 3 pair sides, mostly vowel via spelling phonetic key, often with tatted (1)
- fam — 3 pair sides, mostly spelling via spelling phonetic key, often with half (1)
- huncho — 2 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- polod — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- margielas — 2 pair sides, mostly spelling via spelling phonetic key, often with umbrellas (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with titties (1)
- baguettes — 1 pair sides, mostly spelling via spelling phonetic key, often with titties (1)
- xannys — 1 pair sides, mostly spelling via spelling phonetic key, often with addys (1)
- addys — 1 pair sides, mostly spelling via spelling phonetic key, often with xannys (1)
- singalong — 1 pair sides, mostly spelling via spelling phonetic key, often with song (1)
- shotta — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- rari — 1 pair sides, mostly spelling via spelling phonetic key, often with gang (1)
- highbridg — 1 pair sides, mostly vowel via spelling phonetic key, often with might (1)
- grippyd — 1 pair sides, mostly cmu via vault phonetic_class, often with what (1)
- hoodie — 1 pair sides, mostly spelling via spelling phonetic key, often with boogie (1)
- tatted — 1 pair sides, mostly vowel via spelling phonetic key, often with wagen (1)
- straggl — 1 pair sides, mostly vowel via spelling phonetic key, often with gang (1)
- rs — 1 pair sides, mostly cmu via vault phonetic_class, often with what (1)
- birkins — 1 pair sides, mostly vowel via spelling phonetic key, often with thinkin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| A Boogie wit da Hoodie | Addictions (Girls) | 39 | 62 | 98 | loose |
| A Boogie wit da Hoodie | Babygirl (Reply Demo) | 50 | 56 | 256 | loose |
| A Boogie wit da Hoodie | Drowning | 30 | 46 | 163 | loose |
| A Boogie wit da Hoodie | Drowning (Sped Up Version) | 13 | 16 | 44 | loose |
| A Boogie wit da Hoodie | Last Time | 52 | 53 | 350 | loose |
| A Boogie wit da Hoodie | One Nighter | 43 | 43 | 274 | loose |
| A Boogie wit da Hoodie | Undefeated | 34 | 27 | 172 | loose |
| A Boogie wit da Hoodie | Water (Drowning Pt. 2) [Acappella] | 39 | 23 | 348 | loose |
