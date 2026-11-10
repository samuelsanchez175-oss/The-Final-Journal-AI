# Aarne rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Aarne
- Songs: 2
- Bars kept (Aarne lyric lines): 53
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Aarne.
- Credit strings: Aarne.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 487
- REPEAT pairs, recorded separately: 31
- END rhymes: 70
- INNER rhymes: 417

By match:

- PERFECT: 55 (END 16, INNER 39)
- SLANT: 254 (END 28, INNER 226)
- ASSONANCE: 170 (END 22, INNER 148)
- MULTI: 8 (END 4, INNER 4)

By confidence:

- HIGH: 61
- MED: 398
- LOW: 28

## Core

- Core Y: 481
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 285 (58.5%)
- vowel: 170 (34.9%)
- spelling: 24 (4.9%)
- multi: 8 (1.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 56 pairs (END 17, INNER 39). Words: don't, though, foe, go, those, hoes, no, smoke.
2. `vow:AA` — 23 pairs (END 0, INNER 23). Words: party, bossed, rockin, pop, got, involved, everybody, rotten.
3. `slant:AA:stop` — 21 pairs (END 0, INNER 21). Words: got, pop, body, yacht, glock, cocky, top, bossed.
4. `slant:AH:stop` — 21 pairs (END 0, INNER 21). Words: fuck, what, club, fucked, motherfucker, chuck, buddy.
5. `vow:EY` — 20 pairs (END 2, INNER 18). Words: rates, baby, stay, play, say, faith, tapin, ain't.
6. `vow:AE` — 19 pairs (END 3, INNER 16). Words: hand, last, ask, racks, makin, pan, can't, badman.
7. `vow:EH` — 19 pairs (END 0, INNER 19). Words: hell, left, gets, head, friend, emptyin, let's, spend.
8. `slant:AH:nas-stop` — 15 pairs (END 0, INNER 15). Words: come, fuck, what, bloody, money, buddy, some, one.
9. `slant:OW:sib` — 15 pairs (END 5, INNER 10). Words: hoes, bankrolls, bros, loads, poles, knows, those, grows.
10. `slant:IH:stop` — 14 pairs (END 1, INNER 13). Words: nick, nigga, wit, city, hit, lit, dick, kid.
11. `slant:OW:sib-stop` — 14 pairs (END 10, INNER 4). Words: code, boat, exposed, shows, knows, grows, nose, those.
12. `cmu:OW-Z` — 13 pairs (END 9, INNER 4). Words: hoes, those, grows, shows, nose, rose, knows.
13. `slant:EH:stop` — 12 pairs (END 0, INNER 12). Words: let, swept, get, spent, went, said, head, spend.
14. `slant:IH:liq-stop` — 11 pairs (END 0, INNER 11). Words: lil, lit, still, hit, 'til, shit, city, nick.
15. `slant:OW:stop` — 10 pairs (END 3, INNER 7). Words: don't, smoke, tote, goat, throat, boat, exposed, code.
16. `vow:AH` — 9 pairs (END 0, INNER 9). Words: comin, everyone's, nuttin, somethin, bunch, fucked, come, hundred.
17. `vow:AY` — 9 pairs (END 0, INNER 9). Words: fly, like, bae, why, while, five, night, died.
18. `vow:IY` — 8 pairs (END 0, INNER 8). Words: keep, please, thirty, least, nobody, machines, beat, g.
19. `cmu:OW` — 7 pairs (END 5, INNER 2). Words: bro, go, know, toe, o, radio, blow, foe.
20. `slant:IH:nas-stop` — 7 pairs (END 0, INNER 7). Words: him, everything, nick, hit, city, lit, i'ma, big.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- bros — 6 pair sides, mostly spelling via spelling phonetic key, often with hoes (2)
- herbo — 5 pair sides, mostly vowel via spelling phonetic key, often with though (1)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with city (1)
- buni — 4 pair sides, mostly spelling via spelling phonetic key, often with sully (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with hoes (1)
- ganja — 2 pair sides, mostly vowel via spelling phonetic key, often with badman (1)
- glocks — 2 pair sides, mostly spelling via spelling phonetic key, often with bros (1)
- sebz — 1 pair sides, mostly spelling via spelling phonetic key, often with gets (1)
- dracos — 1 pair sides, mostly spelling via spelling phonetic key, often with bros (1)
- raq — 1 pair sides, mostly spelling via spelling phonetic key, often with stank (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with big (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Aarne | 4 ur girl | 17 | 15 | 154 | loose |
| Aarne | Saint | 36 | 55 | 263 | loose |
