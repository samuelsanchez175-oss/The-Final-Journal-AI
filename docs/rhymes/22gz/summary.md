# 22Gz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 22Gz
- Songs: 4
- Bars kept (22Gz lyric lines): 123
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: 22Gz.
- Credit strings: 22Gz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 948
- REPEAT pairs, recorded separately: 66
- END rhymes: 133
- INNER rhymes: 815

By match:

- PERFECT: 71 (END 7, INNER 64)
- SLANT: 497 (END 63, INNER 434)
- ASSONANCE: 377 (END 62, INNER 315)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 67
- MED: 781
- LOW: 100

## Core

- Core Y: 940
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 471 (49.7%)
- vowel: 377 (39.8%)
- spelling: 97 (10.2%)
- multi: 3 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 4 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 117 pairs (END 30, INNER 87). Words: him, slippin, switches, drift, civic, lift, killed, spinnin.
2. `slant:AA:stop` — 102 pairs (END 26, INNER 76). Words: got, block, shot, dropped, lot, drop, stop, glock.
3. `vow:AA` — 57 pairs (END 8, INNER 49). Words: got, dogs, rockin, nothin, card, poppin, shots, want.
4. `vow:AE` — 52 pairs (END 10, INNER 42). Words: pants, bands, can't, gang, hang, fashion, caskets, captions.
5. `vow:AH` — 41 pairs (END 8, INNER 33). Words: discussion, punish, duckin, buckin, come, public, once, frontin.
6. `slant:IH:nas-stop` — 34 pairs (END 3, INNER 31). Words: i'ma, hit, spin, him, blick, blicky, litty, everything.
7. `slant:IH:nas` — 31 pairs (END 3, INNER 28). Words: i'ma, spin, him, everything, slippin, spinnin, dissin, glitchin.
8. `vow:OW` — 31 pairs (END 4, INNER 27). Words: don't, no, know, hold, totin, focus, motion, postin.
9. `cmu:AA-T` — 29 pairs (END 5, INNER 24). Words: got, shot, lot, hot, spot, bought, not, headshot.
10. `slant:AA:liq-stop` — 28 pairs (END 0, INNER 28). Words: car, hollow, got, shot, body, drop, bought, card.
11. `slant:IH:nas-sib` — 23 pairs (END 2, INNER 21). Words: miss, i'ma, spin, him, switches, catfish, ms, switch.
12. `vow:IY` — 23 pairs (END 1, INNER 22). Words: see, even, beat, leave, skeet, visa, scene, beef.
13. `slant:AH:nas` — 22 pairs (END 3, INNER 19). Words: some, run, running, none, drum, money, runnin, comin.
14. `vow:EY` — 22 pairs (END 0, INNER 22). Words: ain't, day, make, k's, take, way, say, safe.
15. `slant:AE:nas` — 20 pairs (END 4, INNER 16). Words: gang, miami, lamb, hang, ran, van, instagram, caravan.
16. `slant:EH:stop` — 19 pairs (END 3, INNER 16). Words: get, head, cheddar, dead, yet, stepper, checked, sped.
17. `slant:IH:liq-nas` — 16 pairs (END 0, INNER 16). Words: him, kill, still, spin, 'til, lil, really, i'ma.
18. `slant:IH:sib-stop` — 16 pairs (END 3, INNER 13). Words: miss, niggas, nigga, dick, spit, blicky, hit, blick.
19. `vow:EH` — 14 pairs (END 0, INNER 14). Words: attention, when, gettin, credit, get, where, checked, myself.
20. `vow:UW` — 12 pairs (END 0, INNER 12). Words: through, cool, shooters, introduced, use, shoot, loosing, soon.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 43 pair sides, mostly spelling via spelling phonetic key, often with spin (14)
- tryna — 12 pair sides, mostly spelling via spelling phonetic key, often with beat (3)
- blicky — 8 pair sides, mostly spelling via spelling phonetic key, often with ima (2)
- glitchin — 8 pair sides, mostly vowel via spelling phonetic key, often with dissin (1)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- nigga — 5 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- blicks — 3 pair sides, mostly spelling via spelling phonetic key, often with blick (1)
- dracos — 3 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- jag — 3 pair sides, mostly spelling via spelling phonetic key, often with damn (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with whole (2)
- toolies — 2 pair sides, mostly multi via spelling phonetic key, often with woadies (2)
- woadies — 2 pair sides, mostly multi via spelling phonetic key, often with toolies (2)
- guap — 2 pair sides, mostly spelling via spelling phonetic key, often with run (1)
- pix11 — 2 pair sides, mostly spelling via spelling phonetic key, often with blicks (1)
- blickys — 2 pair sides, mostly spelling via spelling phonetic key, often with pix11 (1)
- blam — 1 pair sides, mostly spelling via spelling phonetic key, often with instagram (1)
- hella — 1 pair sides, mostly spelling via spelling phonetic key, often with yellow (1)
- henny — 1 pair sides, mostly vowel via spelling phonetic key, often with litty (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 22Gz | Caravan | 16 | 10 | 94 | loose |
| 22Gz | Spin the Block | 47 | 54 | 379 | loose |
| 22Gz | Up N Stuck (Remix) | 43 | 49 | 224 | loose |
| 22Gz | Up n Stuck (Demo)* | 17 | 20 | 118 | loose |
