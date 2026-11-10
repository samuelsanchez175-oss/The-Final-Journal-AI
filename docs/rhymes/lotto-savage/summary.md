# Lotto Savage rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lotto Savage
- Songs: 3
- Bars kept (Lotto Savage lyric lines): 105
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lotto Savage.
- Credit strings: Lotto Savage.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 625
- REPEAT pairs, recorded separately: 123
- END rhymes: 121
- INNER rhymes: 504

By match:

- PERFECT: 52 (END 9, INNER 43)
- SLANT: 300 (END 66, INNER 234)
- ASSONANCE: 267 (END 46, INNER 221)
- MULTI: 6 (END 0, INNER 6)

By confidence:

- HIGH: 51
- MED: 527
- LOW: 47

## Core

- Core Y: 617
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 307 (49.1%)
- vowel: 267 (42.7%)
- spelling: 45 (7.2%)
- multi: 6 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 66 pairs (END 12, INNER 54). Words: ass, man, catch, smashing, bad, rapping, savages, trappin.
2. `vow:EH` — 48 pairs (END 21, INNER 27). Words: next, check, trenches, gettin, devil, sellin, jet, pebbles.
3. `slant:IH:sib-stop` — 44 pairs (END 22, INNER 22). Words: bitch, shit, nigga, niggas, sis, stick, miss, clip.
4. `vow:EY` — 37 pairs (END 4, INNER 33). Words: ain't, takin, statement, fakin, lately, bales, ape, paper.
5. `slant:IH:stop` — 29 pairs (END 10, INNER 19). Words: shit, nigga, clip, mid, brick, trick, cyst, stick.
6. `vow:IY` — 27 pairs (END 5, INNER 22). Words: these, see, keep, eat, dreamin, streets, lethal, tweakin.
7. `vow:IH` — 24 pairs (END 3, INNER 21). Words: bitch, shit, pimp, cyst, window, sticks, glistening, wifing.
8. `vow:OW` — 24 pairs (END 0, INNER 24). Words: no, don't, smoke, loaded, won't, know, go, whole.
9. `slant:EH:stop` — 22 pairs (END 10, INNER 12). Words: check, jet, respect, better, set, tec, neck, rep.
10. `slant:AO:liq` — 19 pairs (END 0, INNER 19). Words: y'all, before, war, all.
11. `vow:AH` — 13 pairs (END 0, INNER 13). Words: run, couple, what, motherfuckin, fucked, huggin, jungle, money.
12. `slant:EH:liq-stop` — 12 pairs (END 4, INNER 8). Words: check, tell, jet, swear, ready, well, smell, l.
13. `slant:EH:sib-stop` — 12 pairs (END 3, INNER 9). Words: flex, check, tec, finesse, next, sex, respect, jet.
14. `vow:AO` — 11 pairs (END 1, INNER 10). Words: foreign, call, losses, all, slaughter, y'all, talking.
15. `slant:AH:nas-stop` — 10 pairs (END 0, INNER 10). Words: fuck, what, run, young, motherfuckin, some, plug, money.
16. `slant:IY:sib-stop` — 10 pairs (END 0, INNER 10). Words: these, eat, sleep, teeth, creep, beat, streets, keep.
17. `cmu:OW` — 9 pairs (END 0, INNER 9). Words: know, no, hoe, lotto, show.
18. `slant:EH:liq` — 9 pairs (END 1, INNER 8). Words: swear, very, l, well, tell, rebel, devil, level.
19. `cmu:AO-L` — 8 pairs (END 0, INNER 8). Words: all, y'all, call.
20. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: got, block, knotted, pocket, start.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 30 pair sides, mostly spelling via spelling phonetic key, often with shit (14)
- niggas — 19 pair sides, mostly spelling via spelling phonetic key, often with nigga (12)
- gon — 6 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- dracos — 5 pair sides, mostly cmu via vault phonetic_class, often with man (3)
- wifing — 4 pair sides, mostly vowel via spelling phonetic key, often with bitch (2)
- lambo — 3 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- choppas — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- porshe — 2 pair sides, mostly spelling via spelling phonetic key, often with afford (1)
- yeen — 2 pair sides, mostly spelling via spelling phonetic key, often with these (1)
- mistaked — 1 pair sides, mostly vowel via spelling phonetic key, often with give (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with keep (1)
- bno — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- traphouses — 1 pair sides, mostly vowel via spelling phonetic key, often with trapped (1)
- spazzing — 1 pair sides, mostly spelling via spelling phonetic key, often with smashing (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lotto Savage | All Or Nothing | 35 | 31 | 168 | loose |
| Lotto Savage | Stack Up | 43 | 71 | 182 | loose |
| Lotto Savage | Whoa | 27 | 19 | 154 | loose |
