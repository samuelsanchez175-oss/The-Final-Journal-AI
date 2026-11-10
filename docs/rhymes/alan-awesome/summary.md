# Alan Awesome rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Alan Awesome
- Songs: 1
- Bars kept (Alan Awesome lyric lines): 48
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Alan Awesome.
- Credit strings: Alan Awesome.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 263
- REPEAT pairs, recorded separately: 75
- END rhymes: 26
- INNER rhymes: 237

By match:

- PERFECT: 17 (END 8, INNER 9)
- SLANT: 122 (END 11, INNER 111)
- ASSONANCE: 121 (END 7, INNER 114)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 10
- MED: 216
- LOW: 37

## Core

- Core Y: 256
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 99 (37.6%)
- vowel: 121 (46.0%)
- spelling: 40 (15.2%)
- multi: 3 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 32 pairs (END 0, INNER 32). Words: see, leave, louie, streets, sweepin, freaky, weepin, sneakers.
2. `vow:EH` — 23 pairs (END 0, INNER 23). Words: extras, next, collect, every, rest, whatever, ready, dresser.
3. `vow:AH` — 12 pairs (END 3, INNER 9). Words: fuck, nuts, juss, thugs, love, plug, must, judge.
4. `vow:OW` — 10 pairs (END 0, INNER 10). Words: know, don't, load, no, dont, rollie, tombstone, go.
5. `vow:AY` — 9 pairs (END 0, INNER 9). Words: fire, try, why, fried, die, like, ice, ridin.
6. `vow:IH` — 9 pairs (END 3, INNER 6). Words: children, lyrics, bitch, different, spirit, period, sister, hit.
7. `slant:OW:liq-nas` — 8 pairs (END 6, INNER 2). Words: holey, homie, gon, rollie.
8. `vow:AW` — 8 pairs (END 0, INNER 8). Words: now, shout, around, 'round, down.
9. `slant:AA:nas-stop` — 6 pairs (END 0, INNER 6). Words: got, wanna, john, gotti.
10. `slant:IY:sib-stop` — 6 pairs (END 0, INNER 6). Words: keep, easy, deep, these, freak, freaky, sneakers, police.
11. `vow:EY` — 6 pairs (END 0, INNER 6). Words: aim, lay, play, 'caine, chains, make, name.
12. `slant:EH:sib-stop` — 5 pairs (END 0, INNER 5). Words: ready, dresser, presser, rest, yes, get.
13. `slant:EH:stop` — 5 pairs (END 0, INNER 5). Words: collect, ready, rest, next, weekend.
14. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: nigga, big, stick, hit, spirit, period.
15. `spell:ie` — 5 pairs (END 5, INNER 0). Words: homie, rollie.
16. `vow:AA` — 5 pairs (END 0, INNER 5). Words: shots, block, car, star, wanna.
17. `slant:AA:sib-stop` — 4 pairs (END 0, INNER 4). Words: got, shots, lots, shot.
18. `slant:AH:sib-stop` — 4 pairs (END 0, INNER 4). Words: thugs, plug, wuuut, nuts, must, juss, fuck, judge.
19. `slant:EY:nas` — 4 pairs (END 2, INNER 2). Words: name, 'caine, aim, stain, insane.
20. `vow:AO` — 4 pairs (END 0, INNER 4). Words: foreign, cross, short, lost, bosses.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- homie — 14 pair sides, mostly spelling via spelling phonetic key, often with holey (6)
- holey — 10 pair sides, mostly spelling via spelling phonetic key, often with homie (6)
- juss — 7 pair sides, mostly vowel via spelling phonetic key, often with fuck (2)
- gon — 7 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with big (2)
- wuut — 3 pair sides, mostly spelling via spelling phonetic key, often with must (1)
- cuz — 2 pair sides, mostly spelling via spelling phonetic key, often with thugs (1)
- dont — 2 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with extras (1)
- shawty — 1 pair sides, mostly spelling via spelling phonetic key, often with all (1)
- eastside — 1 pair sides, mostly vowel via spelling phonetic key, often with police (1)
- hunnit — 1 pair sides, mostly spelling via spelling phonetic key, often with spirit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Alan Awesome | That Thang On Me | 48 | 26 | 237 | loose |
