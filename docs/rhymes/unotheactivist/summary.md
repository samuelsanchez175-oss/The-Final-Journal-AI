# UnoTheActivist rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: UnoTheActivist
- Songs: 1
- Bars kept (UnoTheActivist lyric lines): 55
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: UnoTheActivist.
- Credit strings: UnoTheActivist.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 268
- REPEAT pairs, recorded separately: 17
- END rhymes: 51
- INNER rhymes: 217

By match:

- PERFECT: 24 (END 6, INNER 18)
- SLANT: 128 (END 26, INNER 102)
- ASSONANCE: 110 (END 17, INNER 93)
- MULTI: 6 (END 2, INNER 4)

By confidence:

- HIGH: 22
- MED: 230
- LOW: 16

## Core

- Core Y: 267
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 133 (49.6%)
- vowel: 110 (41.0%)
- spelling: 19 (7.1%)
- multi: 6 (2.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 32 pairs (END 12, INNER 20). Words: phoenix, seen, bleed, here, seals, breathing, beatin, tv.
2. `vow:EY` — 19 pairs (END 0, INNER 19). Words: ain't, name, play, playin, failed, make, pay, sayin.
3. `vow:IH` — 13 pairs (END 1, INNER 12). Words: givin, didn't, little, kitchen, dick, bitch, thinking, chin.
4. `vow:EH` — 12 pairs (END 2, INNER 10). Words: friends, hell, sexy, test, again, spent, well, swear.
5. `slant:AA:stop` — 10 pairs (END 0, INNER 10). Words: body, lobby, opp, start, drop, gotta, got, dot.
6. `slant:IY:nas` — 10 pairs (END 9, INNER 1). Words: mean, scene, demeanor, subpoena, selena, genie, hyena, semen.
7. `vow:AE` — 10 pairs (END 2, INNER 8). Words: havin, back, hand, chan, had, ballin, man, that'll.
8. `slant:AA:nas-stop` — 6 pairs (END 0, INNER 6). Words: wanna, body, mom, opp, stop, gotta.
9. `slant:IH:nas-stop` — 6 pairs (END 2, INNER 4). Words: shit, kick, spin, him, chin.
10. `vow:AA` — 6 pairs (END 0, INNER 6). Words: opp, spartan, arm, beyond, got, bar, pot.
11. `vow:OW` — 6 pairs (END 0, INNER 6). Words: won't, hope, owe, shows, whole, mexico, hoe, know.
12. `multi:IY-N-AH` — 5 pairs (END 1, INNER 4). Words: bro tryna, tryna, subpoena, selena, get subpoena, name selena.
13. `slant:EH:nas-stop` — 5 pairs (END 2, INNER 3). Words: friend, red, when, again, sleighing.
14. `slant:EH:stop` — 5 pairs (END 0, INNER 5). Words: head, get, set, headed, test.
15. `slant:IH:liq-nas` — 5 pairs (END 0, INNER 5). Words: till, chin, 'til, him, swim, i'ma, kim.
16. `slant:IH:nas` — 5 pairs (END 0, INNER 5). Words: him, chin, i'ma, spin, kitchen, swim, kim.
17. `slant:IY:nas-sib` — 5 pairs (END 3, INNER 2). Words: arenas, police, selena, scene, demeanor, genie, hyena.
18. `vow:AY` — 5 pairs (END 0, INNER 5). Words: like, why, try, type, pints.
19. `slant:AA:sib-stop` — 4 pairs (END 0, INNER 4). Words: cause, body, gotta.
20. `slant:AE:nas-stop` — 4 pairs (END 3, INNER 1). Words: hand, chan, man, back, tan, jackie.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- sleighing — 7 pair sides, mostly spelling via spelling phonetic key, often with givin (2)
- tryna — 5 pair sides, mostly multi via spelling phonetic key, often with subpoena (2)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with ninas (1)
- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with till (1)
- hamms — 1 pair sides, mostly spelling via spelling phonetic key, often with hands (1)
- ninas — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with throat (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with arenas (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| UnoTheActivist | Chieff Keef Sossa | 55 | 51 | 217 | loose |
