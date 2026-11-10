# ZayBang rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: ZayBang
- Songs: 2
- Bars kept (ZayBang lyric lines): 70
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: ZayBang.
- Credit strings: ZayBang.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 584
- REPEAT pairs, recorded separately: 58
- END rhymes: 63
- INNER rhymes: 521

By match:

- PERFECT: 51 (END 21, INNER 30)
- SLANT: 289 (END 18, INNER 271)
- ASSONANCE: 243 (END 23, INNER 220)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 48
- MED: 483
- LOW: 53

## Core

- Core Y: 575
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 291 (49.8%)
- vowel: 243 (41.6%)
- spelling: 49 (8.4%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 51 pairs (END 7, INNER 44). Words: somethin, guns, hundred, brother, some, suckers, huntin, couple.
2. `vow:IH` — 47 pairs (END 6, INNER 41). Words: still, risk, trippin, shit, bippin, tickets, sippin, issues.
3. `vow:AE` — 32 pairs (END 2, INNER 30). Words: can, plastic, travel, can't, rappin, ask, dancin, racks.
4. `slant:EH:liq-stop` — 31 pairs (END 3, INNER 28). Words: get, tell, swear, hell, neck, smell, check, gel.
5. `vow:IY` — 29 pairs (END 5, INNER 24). Words: even, real, frisco, seasons, probably, see, skis, cc.
6. `vow:OW` — 21 pairs (END 0, INNER 21). Words: don't, no, told, won't, go, hope, going, moment.
7. `vow:AA` — 17 pairs (END 0, INNER 17). Words: nothin, shots, problem, got, hard, chops, glock, som.
8. `cmu:EH-L` — 16 pairs (END 13, INNER 3). Words: tell, hell, gel, spell, smell.
9. `slant:AH:nas-stop` — 16 pairs (END 0, INNER 16). Words: come, fuck, gun, stuck, some, buck, tuck.
10. `slant:AY:stop` — 16 pairs (END 1, INNER 15). Words: like, snipe, inside, hyped, bike, might, vibe, light.
11. `vow:AY` — 16 pairs (END 0, INNER 16). Words: high, rifle, diamonds, like, why, inside, by, white.
12. `vow:EY` — 15 pairs (END 0, INNER 15). Words: way, ain't, say, takin, take, name, macon, safe.
13. `slant:AH:nas` — 14 pairs (END 3, INNER 11). Words: some, money, done, one, gun, come, rum, dumb.
14. `slant:IH:stop` — 12 pairs (END 1, INNER 11). Words: nigga, shit, stick, think, limit, sixty, fifty, bit.
15. `slant:EH:fric-stop` — 11 pairs (END 0, INNER 11). Words: never, get, jet, let, pet, neck.
16. `slant:IH:liq-stop` — 11 pairs (END 0, INNER 11). Words: still, killed, sipp, shit, amiri, bit, fit.
17. `slant:IH:sib-stop` — 11 pairs (END 0, INNER 11). Words: nigga, niggas, shit, bitch, miss.
18. `slant:AH:nas-sib` — 10 pairs (END 1, INNER 9). Words: brother, some, one, rum, guns, dumb, come, money.
19. `vow:EH` — 9 pairs (END 3, INNER 6). Words: pandemic, get, exquisite, never, tell, send, ever, swear.
20. `slant:IH:nas-stop` — 8 pairs (END 0, INNER 8). Words: him, shit, sipp, stick, limit, sippin, trippin, bring.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 14 pair sides, mostly spelling via spelling phonetic key, often with niggas (7)
- tryna — 13 pair sides, mostly spelling via spelling phonetic key, often with peeve (2)
- gon — 12 pair sides, mostly spelling via spelling phonetic key, often with dont (4)
- niggas — 8 pair sides, mostly spelling via spelling phonetic key, often with nigga (7)
- bippin — 8 pair sides, mostly vowel via spelling phonetic key, often with still (4)
- micd — 4 pair sides, mostly vowel via vault phonetic_class, often with somethin (1)
- scammin — 2 pair sides, mostly spelling via spelling phonetic key, often with dancin (1)
- glocks — 2 pair sides, mostly vowel via spelling phonetic key, often with wont (1)
- faceshots — 1 pair sides, mostly spelling via spelling phonetic key, often with shots (1)
- leav — 1 pair sides, mostly spelling via spelling phonetic key, often with feel (1)
- pics — 1 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- hella — 1 pair sides, mostly spelling via spelling phonetic key, often with swear (1)
- youngin — 1 pair sides, mostly spelling via spelling phonetic key, often with demon (1)
- glicks — 1 pair sides, mostly vowel via spelling phonetic key, often with shit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| ZayBang | Get Up With Me | 44 | 42 | 306 | loose |
| ZayBang | Light Money | 26 | 21 | 215 | loose |
