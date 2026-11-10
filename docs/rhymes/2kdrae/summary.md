# 2KDrae rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 2KDrae
- Songs: 1
- Bars kept (2KDrae lyric lines): 48
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: 2KDrae.
- Credit strings: 2KDrae.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 324
- REPEAT pairs, recorded separately: 95
- END rhymes: 39
- INNER rhymes: 285

By match:

- PERFECT: 35 (END 16, INNER 19)
- SLANT: 137 (END 14, INNER 123)
- ASSONANCE: 150 (END 9, INNER 141)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 26
- MED: 274
- LOW: 24

## Core

- Core Y: 317
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 144 (44.4%)
- vowel: 150 (46.3%)
- spelling: 28 (8.6%)
- multi: 2 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 48 pairs (END 7, INNER 41). Words: don't, no, thots, know, shows, most, go, smoking.
2. `vow:IH` — 32 pairs (END 0, INNER 32). Words: bitches, bitch, clips, think, minutes, lil, pictures, listen.
3. `vow:AH` — 24 pairs (END 1, INNER 23). Words: fuck, bust, brothers, puffing, couple, love, other, fucked.
4. `slant:AY:fric-stop` — 10 pairs (END 0, INNER 10). Words: wife, night, like, life, live.
5. `vow:EY` — 10 pairs (END 0, INNER 10). Words: ain't, take, taking, pay.
6. `slant:IH:liq-sib` — 9 pairs (END 0, INNER 9). Words: bitch, kiss, lil, landfill, still, will, mill.
7. `vow:AY` — 9 pairs (END 1, INNER 8). Words: fighting, wife, time, high, riding, while, driving.
8. `slant:IH:liq-stop` — 8 pairs (END 0, INNER 8). Words: dick, still, shit, landfill, mill, will, kid.
9. `slant:IH:sib` — 8 pairs (END 2, INNER 6). Words: bitches, bitch, swishers, niggas, clips, pictures.
10. `slant:IH:sib-stop` — 8 pairs (END 2, INNER 6). Words: bitch, shit, nigga, niggas, dick, kiss.
11. `vow:AE` — 8 pairs (END 0, INNER 8). Words: man, acting, stacks, ass, hanging, stank, that'll, catching.
12. `cmu:IY-L` — 7 pairs (END 5, INNER 2). Words: feel, real, deal, she'll, o'neal.
13. `slant:EH:liq-stop` — 7 pairs (END 0, INNER 7). Words: swear, said, tell, head, dead, bread.
14. `vow:AA` — 7 pairs (END 0, INNER 7). Words: ops, got, cause, hopped, wanna, choppers.
15. `cmu:IH-L` — 6 pairs (END 6, INNER 0). Words: landfill, still, will, mill.
16. `slant:AH:sib-stop` — 6 pairs (END 0, INNER 6). Words: fuck, other.
17. `vow:EH` — 6 pairs (END 0, INNER 6). Words: remember, attention, swear, getting, said, send, get, when.
18. `slant:AY:nas-stop` — 5 pairs (END 0, INNER 5). Words: night, fighting, time.
19. `cmu:EH-D` — 4 pairs (END 0, INNER 4). Words: head, dead, bread.
20. `cmu:IH-NG` — 4 pairs (END 1, INNER 3). Words: cuffing, fighting, dyking, puffing, nothing, taking.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- thots — 9 pair sides, mostly vowel via spelling phonetic key, often with dont (6)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- thot — 5 pair sides, mostly spelling via spelling phonetic key, often with got (2)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- swishers — 4 pair sides, mostly spelling via spelling phonetic key, often with brothers (1)
- cuffing — 3 pair sides, mostly spelling via spelling phonetic key, often with puffing (1)
- wifey — 2 pair sides, mostly spelling via spelling phonetic key, often with dick (1)
- thotianas — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- dyking — 1 pair sides, mostly spelling via spelling phonetic key, often with fighting (1)
- thotiana — 1 pair sides, mostly spelling via spelling phonetic key, often with thots (1)
- pasto — 1 pair sides, mostly spelling via spelling phonetic key, often with ass (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with here (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 2KDrae | Thotiana | 48 | 39 | 285 | loose |
