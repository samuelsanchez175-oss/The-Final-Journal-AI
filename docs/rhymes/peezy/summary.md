# Peezy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Peezy
- Songs: 3
- Bars kept (Peezy lyric lines): 126
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Peezy.
- Credit strings: Peezy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1115
- REPEAT pairs, recorded separately: 64
- END rhymes: 151
- INNER rhymes: 964

By match:

- PERFECT: 53 (END 15, INNER 38)
- SLANT: 503 (END 59, INNER 444)
- ASSONANCE: 549 (END 71, INNER 478)
- MULTI: 10 (END 6, INNER 4)

By confidence:

- HIGH: 58
- MED: 980
- LOW: 77

## Core

- Core Y: 1093
- Core N among rhyme pairs: 22

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 499 (44.8%)
- vowel: 549 (49.2%)
- spelling: 57 (5.1%)
- multi: 10 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 132 pairs (END 6, INNER 126). Words: shit, sippin, pimp, bitches, think, figures, bitch, six.
2. `vow:EH` — 91 pairs (END 10, INNER 81). Words: fresh, spent, stretchin, pepsi, hesitant, letterman, expensive, let.
3. `vow:AE` — 74 pairs (END 7, INNER 67). Words: fashion, ass, jacket, can't, back, drank, casually, catch.
4. `vow:AA` — 68 pairs (END 16, INNER 52). Words: got, impossible, popsicle, block, watch, stoppin, lot, popular.
5. `slant:IH:stop` — 61 pairs (END 9, INNER 52). Words: shit, big, nigga, sit, crib, spit, tint, brick.
6. `slant:IH:sib-stop` — 58 pairs (END 12, INNER 46). Words: bitch, shit, big, rich, brick, tris, sit, itch.
7. `vow:IY` — 36 pairs (END 13, INNER 23). Words: p, week, three, peezy, c, eat, jeezy, see.
8. `slant:IH:liq-stop` — 34 pairs (END 0, INNER 34). Words: shit, lil, still, brick, year, big, crib, really.
9. `vow:EY` — 34 pairs (END 1, INNER 33). Words: ain't, today, make, play, say, fake, birthday, appreciation.
10. `vow:UW` — 33 pairs (END 16, INNER 17). Words: louis, boo, prostitutes, chew, move, movin, shoe, choose.
11. `slant:IH:nas-stop` — 29 pairs (END 3, INNER 26). Words: spin, shit, bring, i'ma, big, everything, askin, tint.
12. `vow:OW` — 29 pairs (END 1, INNER 28). Words: no, don't, sold, go, only, know, poles, ho.
13. `vow:AY` — 24 pairs (END 1, INNER 23). Words: like, buy, miles, private, dimes, tryin, find, dr.
14. `slant:AA:stop` — 22 pairs (END 0, INNER 22). Words: block, not, got, gotta, lot, rob, stop, stock.
15. `vow:AH` — 21 pairs (END 0, INNER 21). Words: hundred, buses, junkies, cup, what, run, double, fuckin.
16. `slant:EH:stop` — 19 pairs (END 2, INNER 17). Words: get, ghetto, better, spent, fent, check, cent, let.
17. `slant:AE:stop` — 17 pairs (END 0, INNER 17). Words: can't, jacket, after, last, back, master, drank, brand.
18. `slant:IH:liq-sib` — 14 pairs (END 0, INNER 14). Words: bitch, lil, still, rich, year, itch, switch, biz.
19. `slant:IH:nas-sib` — 14 pairs (END 0, INNER 14). Words: bitch, spin, bring, i'ma, tris, biz, trippin, whips.
20. `slant:EH:fric-stop` — 13 pairs (END 3, INNER 10). Words: forever, get, ghetto, whatever, check, better, every.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 11 pair sides, mostly spelling via spelling phonetic key, often with relationship (1)
- peezy — 10 pair sides, mostly vowel via spelling phonetic key, often with eat (1)
- ima — 10 pair sides, mostly spelling via spelling phonetic key, often with dick (1)
- tris — 9 pair sides, mostly spelling via spelling phonetic key, often with sit (1)
- gon — 8 pair sides, mostly spelling via spelling phonetic key, often with mode (2)
- jeezy — 7 pair sides, mostly vowel via spelling phonetic key, often with p (1)
- shitll — 7 pair sides, mostly vowel via spelling phonetic key, often with shit (2)
- lik — 3 pair sides, mostly spelling via spelling phonetic key, often with quit (1)
- wock — 3 pair sides, mostly vowel via spelling phonetic key, often with show (1)
- dracs — 3 pair sides, mostly vowel via spelling phonetic key, often with cant (2)
- goyard — 2 pair sides, mostly spelling via spelling phonetic key, often with hard (2)
- moncler — 2 pair sides, mostly spelling via spelling phonetic key, often with only (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with kids (1)
- amg — 1 pair sides, mostly spelling via spelling phonetic key, often with brand (1)
- hunnid — 1 pair sides, mostly spelling via spelling phonetic key, often with slid (1)
- plat — 1 pair sides, mostly spelling via spelling phonetic key, often with match (1)
- collabed — 1 pair sides, mostly vowel via spelling phonetic key, often with moncler (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with over (1)
- nem — 1 pair sides, mostly spelling via spelling phonetic key, often with fresh (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Peezy | Fashion Week | 48 | 65 | 294 | loose |
| Peezy | I Told Her | 32 | 42 | 204 | loose |
| Peezy | Texas Shit | 46 | 44 | 466 | loose |
