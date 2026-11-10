# Reem (Rap) rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Reem (Rap)
- Songs: 1
- Bars kept (Reem (Rap) lyric lines): 102
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Reem (Rap).
- Credit strings: Reem (Rap).
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 801
- REPEAT pairs, recorded separately: 48
- END rhymes: 145
- INNER rhymes: 656

By match:

- PERFECT: 66 (END 21, INNER 45)
- SLANT: 361 (END 62, INNER 299)
- ASSONANCE: 368 (END 58, INNER 310)
- MULTI: 6 (END 4, INNER 2)

By confidence:

- HIGH: 70
- MED: 675
- LOW: 56

## Core

- Core Y: 790
- Core N among rhyme pairs: 11

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 379 (47.3%)
- vowel: 368 (45.9%)
- spelling: 48 (6.0%)
- multi: 6 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 59 pairs (END 17, INNER 42). Words: ain't, day, face, fake, shapes, haters, snakes, embrace.
2. `vow:IY` — 58 pairs (END 17, INNER 41). Words: see, need, demons, people’s, sleeping, team, keep, keepin.
3. `vow:OW` — 46 pairs (END 0, INNER 46). Words: know, only, don’t, no, broke, go, roll, smoking.
4. `vow:AE` — 37 pairs (END 1, INNER 36). Words: capital, cash, bands, master, action, man, traffic, plan.
5. `vow:EH` — 35 pairs (END 3, INNER 32). Words: metal, checking, get, flex, blessed, tell, twelve, selling.
6. `vow:AA` — 34 pairs (END 3, INNER 31). Words: got, problem, goblins, causing, drama, da, hottest, wanna.
7. `slant:EY:stop` — 32 pairs (END 17, INNER 15). Words: hate, fake, paid, ain't, grade, made, trade, later.
8. `vow:IH` — 32 pairs (END 0, INNER 32). Words: bitch, killed, winnin, imma, trips, wrist, niggas, convinced.
9. `vow:AY` — 30 pairs (END 8, INNER 22). Words: homicides, ride, live, die, identify, guy, like, five.
10. `vow:UW` — 22 pairs (END 9, INNER 13). Words: shootin, abusive, movement, two, abuse, news, through, music.
11. `cmu:EY-T` — 16 pairs (END 7, INNER 9). Words: hate, relate, great, trait, straight.
12. `slant:IH:sib-stop` — 15 pairs (END 0, INNER 15). Words: niggas, nigga, bitch, shit, rich, dick, wit, city.
13. `slant:IH:stop` — 15 pairs (END 2, INNER 13). Words: city, nigga, bibby, dick, shit, picky, pretty, wit.
14. `slant:AH:sib` — 14 pairs (END 2, INNER 12). Words: brothers, cuz, other, mother, another, guns, drugs, dubs.
15. `slant:IH:liq-stop` — 14 pairs (END 0, INNER 14). Words: shit, city, still, lil, mirror, year, bibby, dick.
16. `cmu:AY` — 13 pairs (END 9, INNER 4). Words: identify, guy, sky, high, try, die.
17. `slant:AA:stop` — 13 pairs (END 0, INNER 13). Words: gotta, got, block, top, locked, part, dropped, want.
18. `slant:EH:liq-stop` — 13 pairs (END 0, INNER 13). Words: get, tell, everywhere, where, already, share, let, care.
19. `slant:EY:sib-stop` — 13 pairs (END 7, INNER 6). Words: face, fake, embrace, straight, take, chase, grade, trade.
20. `slant:AE:nas-sib` — 11 pairs (END 2, INNER 9). Words: man, can, ass, advance, cash, gang, catch, plan.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 15 pair sides, mostly spelling via spelling phonetic key, often with niggas (7)
- cuz — 12 pair sides, mostly spelling via spelling phonetic key, often with some (3)
- niggas — 12 pair sides, mostly spelling via spelling phonetic key, often with nigga (7)
- tryna — 8 pair sides, mostly spelling via spelling phonetic key, often with these (2)
- imma — 6 pair sides, mostly vowel via spelling phonetic key, often with niggas (3)
- hoopin — 2 pair sides, mostly vowel via spelling phonetic key, often with music (1)
- realest — 2 pair sides, mostly spelling via spelling phonetic key, often with greatest (1)
- ninas — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- dont — 2 pair sides, mostly vowel via spelling phonetic key, often with roll (1)
- remix — 1 pair sides, mostly vowel via spelling phonetic key, often with semi (1)
- dolo — 1 pair sides, mostly spelling via spelling phonetic key, often with hoes (1)
- fefe — 1 pair sides, mostly vowel via spelling phonetic key, often with west (1)
- lyin — 1 pair sides, mostly spelling via spelling phonetic key, often with tryna (1)
- cigarillo — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Reem (Rap) | Chicago Conscious (Remix) | 102 | 145 | 656 | loose |
