# Tray Tray rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Tray Tray
- Songs: 1
- Bars kept (Tray Tray lyric lines): 41
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 2
- Canonical name: Tray Tray.
- Credit strings: Tray Tray.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 270
- REPEAT pairs, recorded separately: 29
- END rhymes: 44
- INNER rhymes: 226

By match:

- PERFECT: 29 (END 10, INNER 19)
- SLANT: 127 (END 21, INNER 106)
- ASSONANCE: 114 (END 13, INNER 101)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 26
- MED: 209
- LOW: 35

## Core

- Core Y: 265
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 123 (45.6%)
- vowel: 114 (42.2%)
- spelling: 33 (12.2%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 33 pairs (END 4, INNER 29). Words: ain't, made, bracin, make, say, pay, chase, face.
2. `vow:IY` — 17 pairs (END 3, INNER 14). Words: even, deceased, reach, field, speakin, real, g, feel.
3. `vow:OW` — 15 pairs (END 0, INNER 15). Words: don't, know, gold, rose, hoes, soul, bro, glocks.
4. `vow:AE` — 13 pairs (END 3, INNER 10). Words: handle, ask, damages, mannequin, can, panic, pants, racks.
5. `vow:IH` — 13 pairs (END 3, INNER 10). Words: victim, different, him, bitches, shit, fingers, amiri, 'til.
6. `slant:IH:liq-nas` — 12 pairs (END 0, INNER 12). Words: him, still, bling, kill, chill, i'ma, 'til, really.
7. `slant:AY:stop` — 11 pairs (END 5, INNER 6). Words: type, right, pipe, mike, sight, like.
8. `cmu:IH-L` — 10 pairs (END 0, INNER 10). Words: still, kill, drill, will, 'til, lil.
9. `cmu:IY-L` — 9 pairs (END 9, INNER 0). Words: feel, real, wheel, steel.
10. `spell:ill` — 8 pairs (END 0, INNER 8). Words: i'll, still, will, kill, drill, chill.
11. `vow:AY` — 8 pairs (END 0, INNER 8). Words: behind, like, die, sight, right, pipe, mike, type.
12. `slant:EY:stop` — 7 pairs (END 5, INNER 2). Words: made, make, faked, take, basic, ain't.
13. `vow:EH` — 6 pairs (END 0, INNER 6). Words: barely, care, when, rep, gen3s, gen5s.
14. `slant:AY:fric-stop` — 5 pairs (END 4, INNER 1). Words: life, type, sight, right, pipe, mike.
15. `slant:AY:liq-stop` — 5 pairs (END 0, INNER 5). Words: i'll, like, mike, type.
16. `slant:IH:liq-sib` — 5 pairs (END 0, INNER 5). Words: miss, lil, bitch, 'til, kill, still.
17. `slant:IH:liq-stop` — 5 pairs (END 0, INNER 5). Words: shit, lil, really, still.
18. `slant:IY:liq-nas` — 5 pairs (END 4, INNER 1). Words: scene, real, feelin, feel, wheel, steel.
19. `slant:AE:fric-nas` — 4 pairs (END 0, INNER 4). Words: can, half, have.
20. `slant:IH:liq` — 4 pairs (END 0, INNER 4). Words: really, still, lil, kill.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- bling — 6 pair sides, mostly spelling via spelling phonetic key, often with still (2)
- gen5s — 5 pair sides, mostly spelling via spelling phonetic key, often with gen3s (2)
- gen3s — 5 pair sides, mostly spelling via spelling phonetic key, often with gen5s (2)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with stiff (2)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- glocks — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- herbo — 1 pair sides, mostly vowel via spelling phonetic key, often with bro (1)
- drawed — 1 pair sides, mostly spelling via spelling phonetic key, often with all (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Tray Tray | Eastsiders | 41 | 44 | 226 | loose |
