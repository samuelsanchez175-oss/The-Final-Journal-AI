# Riko rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Riko With Da K
- Songs: 1
- Bars kept (Riko lyric lines): 33
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Riko.
- Credit strings: Riko With Da K.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 306
- REPEAT pairs, recorded separately: 27
- END rhymes: 25
- INNER rhymes: 281

By match:

- PERFECT: 16 (END 0, INNER 16)
- SLANT: 167 (END 10, INNER 157)
- ASSONANCE: 121 (END 15, INNER 106)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 13
- MED: 255
- LOW: 38

## Core

- Core Y: 296
- Core N among rhyme pairs: 10

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 150 (49.0%)
- vowel: 121 (39.5%)
- spelling: 33 (10.8%)
- multi: 2 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 46 pairs (END 11, INNER 35). Words: fuckin, cutters, touch, bluffin, bussin, buzzin, cousin, hundred.
2. `vow:IH` — 25 pairs (END 3, INNER 22). Words: victim, flipped, bitch, tips, switches, pistols, kill, swisher.
3. `slant:AH:nas` — 16 pairs (END 7, INNER 9). Words: bussin, cousin, comin, bluffin, bunny, dummy, buzzin, fuckin.
4. `slant:IH:sib-stop` — 16 pairs (END 0, INNER 16). Words: bitch, hit, stick, whip, nigga, niggas, scissor, swisher.
5. `vow:OW` — 16 pairs (END 0, INNER 16). Words: don't, whole, snow, know, no, smoke, sho, soul.
6. `slant:IH:stop` — 13 pairs (END 0, INNER 13). Words: nigga, hit, stick, flipped, whip, riko.
7. `vow:AA` — 12 pairs (END 1, INNER 11). Words: want, nothin, bodies, talkin, body, skyrocket, pop, stoppin.
8. `vow:EH` — 9 pairs (END 0, INNER 9). Words: self, remember, tearin, when, get, scared, lettin, tell.
9. `slant:IH:liq-sib` — 7 pairs (END 0, INNER 7). Words: bitch, kill, lil, millie, scissor, swisher.
10. `slant:AH:sib-stop` — 6 pairs (END 0, INNER 6). Words: fuck, brother, judge, cutter, cutters, what.
11. `slant:IH:sib` — 6 pairs (END 1, INNER 5). Words: bitch, scissor, swisher, switches.
12. `vow:EY` — 6 pairs (END 0, INNER 6). Words: ain't, sunday, game, claim, stay, way.
13. `slant:AE:nas-stop` — 5 pairs (END 0, INNER 5). Words: man, kodak, gang, bad, back.
14. `slant:AH:fric-stop` — 5 pairs (END 0, INNER 5). Words: love, fuck, cutter, what.
15. `slant:IH:nas-sib` — 5 pairs (END 0, INNER 5). Words: bitch, i'ma, him, tiane, scissor.
16. `cmu:IH-N` — 4 pairs (END 0, INNER 4). Words: fuckin, thuggin, nothin, dyin, twin, spin, oppin.
17. `slant:AA:nas-stop` — 4 pairs (END 0, INNER 4). Words: pop, droppin, stoppin, top.
18. `slant:AE:sib-stop` — 4 pairs (END 0, INNER 4). Words: catch, bad, crash, back.
19. `slant:AH:nas-stop` — 4 pairs (END 0, INNER 4). Words: come, fuck, runnin, monday, dummy, what.
20. `slant:AW:nas-stop` — 4 pairs (END 0, INNER 4). Words: down, round, shout, 'bout.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with riko (3)
- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- riko — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- thuggin — 5 pair sides, mostly vowel via spelling phonetic key, often with cousin (1)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with phone (2)
- tiane — 4 pair sides, mostly spelling via spelling phonetic key, often with him (1)
- reekee — 4 pair sides, mostly vowel via spelling phonetic key, often with haiti (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with sweet (1)
- sho — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- dyin — 1 pair sides, mostly spelling via spelling phonetic key, often with nothin (1)
- oppin — 1 pair sides, mostly spelling via spelling phonetic key, often with fuckin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Riko With Da K | Anthem | 33 | 25 | 281 | loose |
