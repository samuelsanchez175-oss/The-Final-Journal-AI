# 1504 MuteBaby rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 1504 MuteBaby
- Songs: 2
- Bars kept (1504 MuteBaby lyric lines): 94
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: 1504 MuteBaby.
- Credit strings: 1504 MuteBaby.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 779
- REPEAT pairs, recorded separately: 122
- END rhymes: 112
- INNER rhymes: 667

By match:

- PERFECT: 61 (END 27, INNER 34)
- SLANT: 428 (END 45, INNER 383)
- ASSONANCE: 289 (END 39, INNER 250)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 51
- MED: 659
- LOW: 69

## Core

- Core Y: 772
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 416 (53.4%)
- vowel: 289 (37.1%)
- spelling: 73 (9.4%)
- multi: 1 (0.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 82 pairs (END 26, INNER 56). Words: him, shit, system, sisters, victim, victims, bitches, disney.
2. `slant:IH:stop` — 53 pairs (END 4, INNER 49). Words: nigga, shit, big, bid, hit, stick, blick, lift.
3. `slant:IH:nas-stop` — 45 pairs (END 4, INNER 41). Words: him, shit, kin, sic, twin, big, tip, clip.
4. `vow:OW` — 40 pairs (END 1, INNER 39). Words: don't, no, know, smoke, ho, told, smoked, close.
5. `vow:EY` — 34 pairs (END 0, INNER 34). Words: ain't, play, make, spray, matrix, placement, say, face.
6. `vow:IY` — 27 pairs (END 3, INNER 24). Words: even, see, thirty, reeboks, teeth, feel, need, bleed.
7. `vow:AE` — 26 pairs (END 1, INNER 25). Words: ass, can't, smashed, savage, bags, catch, lacking, trap.
8. `slant:IH:liq-stop` — 25 pairs (END 4, INNER 21). Words: shit, clear, hit, lil, kill, still, killer, gill.
9. `slant:IH:sib-stop` — 23 pairs (END 0, INNER 23). Words: bitch, nigga, niggas, shit, diss, big, tip, clip.
10. `slant:AA:liq-stop` — 22 pairs (END 2, INNER 20). Words: car, got, park, heart, jar, far, knock, gunshot.
11. `vow:EH` — 19 pairs (END 4, INNER 15). Words: steppers, get, m's, pretend, feds, never, red, tears.
12. `vow:AH` — 18 pairs (END 0, INNER 18). Words: young, jump, fuck, fuckin, double, gloves, some, club.
13. `slant:IH:nas-sib` — 16 pairs (END 1, INNER 15). Words: bitch, him, twin, kin, sisters, system, win, skin.
14. `slant:IH:liq-nas` — 15 pairs (END 1, INNER 14). Words: lil, killer, kin, twin, win, him, really, skin.
15. `vow:AA` — 14 pairs (END 0, INNER 14). Words: dogs, bottom, hop, knock, dodge, want, cars, got.
16. `cmu:IH-N` — 13 pairs (END 13, INNER 0). Words: twin, win, kin, skin.
17. `slant:AA:stop` — 13 pairs (END 0, INNER 13). Words: got, block, chop, body, knock, heart, park, lotta.
18. `vow:AY` — 12 pairs (END 0, INNER 12). Words: behind, live, wire, ridin, like, silent, fried, driver.
19. `slant:AH:nas-stop` — 11 pairs (END 0, INNER 11). Words: fuck, young, some, blood, done, jump, come.
20. `slant:AY:stop` — 11 pairs (END 0, INNER 11). Words: like, type, right, inside, side, cried, died, fried.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 43 pair sides, mostly spelling via spelling phonetic key, often with shit (14)
- niggas — 23 pair sides, mostly spelling via spelling phonetic key, often with nigga (10)
- tryna — 7 pair sides, mostly spelling via spelling phonetic key, often with police (2)
- swishers — 3 pair sides, mostly spelling via spelling phonetic key, often with figures (1)
- layed — 3 pair sides, mostly spelling via spelling phonetic key, often with red (1)
- finna — 3 pair sides, mostly vowel via spelling phonetic key, often with nigga (2)
- sticked — 2 pair sides, mostly spelling via spelling phonetic key, often with blick (1)
- cliquing — 2 pair sides, mostly spelling via spelling phonetic key, often with beefing (1)
- vallet — 2 pair sides, mostly spelling via spelling phonetic key, often with get (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- nem — 1 pair sides, mostly spelling via spelling phonetic key, often with hell (1)
- trues — 1 pair sides, mostly spelling via spelling phonetic key, often with young (1)
- recrute — 1 pair sides, mostly vowel via spelling phonetic key, often with went (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with hoes (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 1504 MuteBaby | MIA Freestyle | 70 | 94 | 580 | loose |
| 1504 MuteBaby | Moment of Silence | 24 | 18 | 87 | loose |
