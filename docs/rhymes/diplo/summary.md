# Diplo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Diplo
- Songs: 2
- Bars kept (Diplo lyric lines): 40
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Diplo.
- Credit strings: Diplo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 272
- REPEAT pairs, recorded separately: 27
- END rhymes: 21
- INNER rhymes: 251

By match:

- PERFECT: 21 (END 5, INNER 16)
- SLANT: 123 (END 5, INNER 118)
- ASSONANCE: 127 (END 11, INNER 116)
- MULTI: 1 (END 0, INNER 1)

By confidence:

- HIGH: 20
- MED: 224
- LOW: 28

## Core

- Core Y: 271
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 114 (41.9%)
- vowel: 127 (46.7%)
- spelling: 30 (11.0%)
- multi: 1 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 43 pairs (END 6, INNER 37). Words: problem, holler, rocket, harden, bothered, wanna, projects, solid.
2. `vow:IY` — 22 pairs (END 1, INNER 21). Words: even, see, please, streets, philippe, keep, beef, feet.
3. `slant:IY:stop` — 16 pairs (END 0, INNER 16). Words: feet, freak, keep, sweep, greet, meet, geeked, weak.
4. `vow:AE` — 14 pairs (END 0, INNER 14). Words: maskin, starin, man, actin, langston, back, damn, happy.
5. `vow:OW` — 14 pairs (END 3, INNER 11). Words: don't, zoe, poetry, pole, hoes, throwin, home, no.
6. `slant:IY:nas-stop` — 13 pairs (END 0, INNER 13). Words: tryna, skeetin, feet, greet, meet, philippe, week, freak.
7. `vow:AY` — 12 pairs (END 0, INNER 12). Words: like, stylist, tried, ridin, minded, pi, life, sight.
8. `vow:EY` — 8 pairs (END 0, INNER 8). Words: away, gave, way, taste, wasted, baby, break, ain't.
9. `cmu:IH-T` — 7 pairs (END 0, INNER 7). Words: shit, hit, spit.
10. `slant:AA:liq-stop` — 7 pairs (END 2, INNER 5). Words: holler, solid, bought, got, knock.
11. `slant:IY:fric-stop` — 7 pairs (END 0, INNER 7). Words: beef, feet, freak, greet, meet, keep, sweep.
12. `cmu:IY-T` — 5 pairs (END 2, INNER 3). Words: feet, greet, meet.
13. `slant:AA:nas-stop` — 5 pairs (END 0, INNER 5). Words: wanna, got, bought, knock, rock.
14. `slant:AA:sib-stop` — 5 pairs (END 0, INNER 5). Words: bother, bought, bothered, got, knock, rocks, rock.
15. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: nigga, broomstick, stick.
16. `slant:IY:nas` — 5 pairs (END 0, INNER 5). Words: tryna, dreamin, eatin, even, skeetin.
17. `vow:IH` — 5 pairs (END 0, INNER 5). Words: listen, pistol, broomstick, stick, lil, think, wink.
18. `vow:UW` — 5 pairs (END 1, INNER 4). Words: glue, acoustic, cupid, booth, goons, overdo, lucid.
19. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: solid, heart, bothered, bought, rocket, got, knock.
20. `slant:EY:stop` — 4 pairs (END 1, INNER 3). Words: late, break, baby, taste, wasted, ain't, faded.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 14 pair sides, mostly spelling via spelling phonetic key, often with feet (2)
- skeetin — 6 pair sides, mostly spelling via spelling phonetic key, often with even (2)
- nigga — 5 pair sides, mostly spelling via spelling phonetic key, often with broomstick (3)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with broomstick (1)
- geeked — 1 pair sides, mostly spelling via spelling phonetic key, often with weak (1)
- backwood — 1 pair sides, mostly spelling via spelling phonetic key, often with good (1)
- sherm — 1 pair sides, mostly spelling via spelling phonetic key, often with burn (1)
- ketamine — 1 pair sides, mostly vowel via spelling phonetic key, often with best (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Diplo | Loitering | 20 | 15 | 197 | loose |
| Diplo | Wasted | 20 | 6 | 54 | loose |
