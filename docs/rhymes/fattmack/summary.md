# FattMack rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: FattMack
- Songs: 1
- Bars kept (FattMack lyric lines): 29
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: FattMack.
- Credit strings: FattMack.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 501
- REPEAT pairs, recorded separately: 18
- END rhymes: 47
- INNER rhymes: 454

By match:

- PERFECT: 60 (END 7, INNER 53)
- SLANT: 207 (END 27, INNER 180)
- ASSONANCE: 228 (END 13, INNER 215)
- MULTI: 6 (END 0, INNER 6)

By confidence:

- HIGH: 65
- MED: 427
- LOW: 9

## Core

- Core Y: 498
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 260 (51.9%)
- vowel: 228 (45.5%)
- spelling: 7 (1.4%)
- multi: 6 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 71 pairs (END 11, INNER 60). Words: attire, flyer, might, diamonds, finally, bae, white, find.
2. `vow:IH` — 52 pairs (END 0, INNER 52). Words: bitches, still, missin, since, listen, really, richest, whips.
3. `slant:AY:nas-stop` — 32 pairs (END 8, INNER 24). Words: nine, like, right, southside, alkaline, outlined, line, time.
4. `vow:EY` — 31 pairs (END 0, INNER 31). Words: ain't, day, way, major, changed, prayin, stay, gave.
5. `vow:EH` — 25 pairs (END 0, INNER 25). Words: every, trenches, myself, affection, next, sex, spend, yell.
6. `vow:AA` — 16 pairs (END 1, INNER 15). Words: hard, rockin, not, nothin, got, lot, copped, rock.
7. `cmu:EY` — 15 pairs (END 0, INNER 15). Words: way, day, today, play, say, stay.
8. `vow:OW` — 15 pairs (END 0, INNER 15). Words: don't, old, know, go, opps, no, told, bro.
9. `slant:IH:liq-stop` — 14 pairs (END 0, INNER 14). Words: still, lil, really, rid, fit, city, clip, shit.
10. `slant:IH:sib-stop` — 12 pairs (END 1, INNER 11). Words: bitch, hit, mic, bit, fit, city, rich, nigga.
11. `slant:AY:nas` — 10 pairs (END 8, INNER 2). Words: nine, tryin, time, prime, dime, alkaline, ridin.
12. `slant:IH:liq-sib` — 9 pairs (END 0, INNER 9). Words: bitch, still, killers, lil, rich, really, kill, killer.
13. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: glock, not, copped, got, lot.
14. `slant:AY:sib-stop` — 8 pairs (END 0, INNER 8). Words: guys, lies, white, might, right.
15. `slant:AY:liq-stop` — 7 pairs (END 0, INNER 7). Words: lifestyle, white, i'll, right, might.
16. `slant:AY:stop` — 7 pairs (END 2, INNER 5). Words: hide, might, southside, outlined, like, white, outside, find.
17. `cmu:AA-T` — 6 pairs (END 0, INNER 6). Words: not, got, lot.
18. `cmu:AY-T` — 6 pairs (END 0, INNER 6). Words: might, white, right.
19. `multi:EY-IH-NG` — 6 pairs (END 0, INNER 6). Words: die prayin, not payin, prayin, payin, think playin, playin.
20. `slant:AH:nas` — 6 pairs (END 0, INNER 6). Words: none, numb, one, money, come, done, gun.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- opps — 3 pair sides, mostly vowel via spelling phonetic key, often with know (3)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with rid (1)
- raq — 1 pair sides, mostly spelling via spelling phonetic key, often with bad (1)
- comittin — 1 pair sides, mostly spelling via spelling phonetic key, often with even (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| FattMack | White Lies | 29 | 47 | 454 | loose |
