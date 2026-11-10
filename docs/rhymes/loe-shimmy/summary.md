# Loe Shimmy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Loe Shimmy
- Songs: 1
- Bars kept (Loe Shimmy lyric lines): 47
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Loe Shimmy.
- Credit strings: Loe Shimmy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 427
- REPEAT pairs, recorded separately: 33
- END rhymes: 56
- INNER rhymes: 371

By match:

- PERFECT: 55 (END 17, INNER 38)
- SLANT: 148 (END 17, INNER 131)
- ASSONANCE: 218 (END 21, INNER 197)
- MULTI: 6 (END 1, INNER 5)

By confidence:

- HIGH: 57
- MED: 343
- LOW: 27

## Core

- Core Y: 418
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 180 (42.2%)
- vowel: 218 (51.1%)
- spelling: 23 (5.4%)
- multi: 6 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 44 pairs (END 5, INNER 39). Words: intestines, sellin, check, when, get, collect, sentimental, head.
2. `vow:IH` — 42 pairs (END 2, INNER 40). Words: spinnin, think, tricks, six, fulfill, lil, pistol, grippin.
3. `vow:OW` — 42 pairs (END 0, INNER 42). Words: don't, know, no, broke, uploadin, told, cody, owe.
4. `cmu:IY-Z` — 33 pairs (END 16, INNER 17). Words: knees, p's, z's, keys, these, g's, rees, overseas.
5. `vow:AE` — 30 pairs (END 0, INNER 30). Words: rappin, band, crackers, trappin, cat, smackin, bag, man.
6. `vow:EY` — 16 pairs (END 5, INNER 11). Words: exchanges, ain't, impatient, made, take, location, playin, ave.
7. `slant:EH:stop` — 14 pairs (END 0, INNER 14). Words: let, get, head, leg, already, kept, dead, tec.
8. `vow:UW` — 11 pairs (END 9, INNER 2). Words: voodoo, usual, use, booted, fool, youtube, through, cuban.
9. `slant:AA:stop` — 10 pairs (END 1, INNER 9). Words: got, chopper, pocket, want, glock, shot, sock, job.
10. `slant:IY:fric-sib` — 10 pairs (END 6, INNER 4). Words: sleeve, knees, rees, trees, p's, these, z's, g's.
11. `slant:IY:sib` — 9 pairs (END 0, INNER 9). Words: needs, knees, these, rees, trees, p's, g's, z's.
12. `cmu:OW` — 8 pairs (END 0, INNER 8). Words: know, no, loe, owe, pompano.
13. `slant:IH:stop` — 8 pairs (END 0, INNER 8). Words: nigga, shit, hitter, big, link, winter, sit, quick.
14. `vow:AH` — 8 pairs (END 0, INNER 8). Words: fuck, what's, jumpin, stuck, what, duckin, somethin, hundred.
15. `vow:AW` — 8 pairs (END 0, INNER 8). Words: doubt, how, found, around, blackout, rounds, 'round.
16. `slant:EH:nas-stop` — 7 pairs (END 0, INNER 7). Words: when, get, send, gettin, denim, let, better, ten.
17. `slant:IY:liq-sib` — 7 pairs (END 0, INNER 7). Words: here, knees, p's, these, g's, z's, keys.
18. `slant:IY:sib-stop` — 7 pairs (END 0, INNER 7). Words: keep, knees, p's, these, g's, z's, keys.
19. `vow:AA` — 7 pairs (END 0, INNER 7). Words: wants, rockin, got, glock, pocket, bodies, cali, shot.
20. `vow:IY` — 7 pairs (END 0, INNER 7). Words: needs, yeezy, sleeve, here, keep, hear, b, shimmy.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- finessing — 5 pair sides, mostly vowel via spelling phonetic key, often with jumpin (1)
- cred — 4 pair sides, mostly spelling via spelling phonetic key, often with gentle (1)
- yeezy — 4 pair sides, mostly vowel via spelling phonetic key, often with shimmy (1)
- splats — 3 pair sides, mostly spelling via spelling phonetic key, often with cat (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with hear (1)
- skeeted — 1 pair sides, mostly spelling via spelling phonetic key, often with cred (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with six (1)
- zoolin — 1 pair sides, mostly spelling via spelling phonetic key, often with fool (1)
- cash4gold — 1 pair sides, mostly spelling via spelling phonetic key, often with hold (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with hold (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Loe Shimmy | Bounty | 47 | 56 | 371 | loose |
