# VonOff1700 rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: VonOff1700
- Songs: 2
- Bars kept (VonOff1700 lyric lines): 108
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: VonOff1700.
- Credit strings: VonOff1700.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1323
- REPEAT pairs, recorded separately: 85
- END rhymes: 189
- INNER rhymes: 1134

By match:

- PERFECT: 141 (END 29, INNER 112)
- SLANT: 561 (END 95, INNER 466)
- ASSONANCE: 611 (END 62, INNER 549)
- MULTI: 10 (END 3, INNER 7)

By confidence:

- HIGH: 142
- MED: 1087
- LOW: 94

## Core

- Core Y: 1284
- Core N among rhyme pairs: 39

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 638 (48.2%)
- vowel: 611 (46.2%)
- spelling: 64 (4.8%)
- multi: 10 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 127 pairs (END 1, INNER 126). Words: don't, know, opps, no, broke, go, blow, ho.
2. `vow:IH` — 93 pairs (END 9, INNER 84). Words: killin, him, dissin, think, shit, bitch, kidneys, lil.
3. `vow:AE` — 75 pairs (END 9, INNER 66). Words: ass, back, can't, pants, hand, apps, straps, land.
4. `vow:EH` — 63 pairs (END 1, INNER 62). Words: went, help, when, against, get, pendant, trenches, left.
5. `vow:EY` — 49 pairs (END 5, INNER 44). Words: ain't, play, way, crazy, always, raised, faded, playin.
6. `vow:AH` — 48 pairs (END 12, INNER 36). Words: fuck, cuddlin, hundred, ugly, public, stutterin, slumped, dumb.
7. `vow:AY` — 48 pairs (END 2, INNER 46). Words: die, survived, find, ridin, times, viral, guys, time.
8. `vow:AA` — 40 pairs (END 0, INNER 40). Words: wasn't, got, costs, hot, rollin, bodies, swappin, toppin.
9. `cmu:OW` — 39 pairs (END 0, INNER 39). Words: know, no, go, blow, micro, ho, bro.
10. `slant:IH:sib-stop` — 30 pairs (END 1, INNER 29). Words: bitch, hit, rich, dick, big, whip, switch, niggas.
11. `slant:AA:stop` — 29 pairs (END 0, INNER 29). Words: got, glock, opp, heart, chop, copped, want, chopper.
12. `slant:AE:stop` — 29 pairs (END 2, INNER 27). Words: had, back, hat, rap, stacked, whacked, can't, clapped.
13. `slant:IH:stop` — 27 pairs (END 1, INNER 26). Words: nigga, hit, dick, shit, big, city, whip, clipper.
14. `vow:ER` — 26 pairs (END 23, INNER 3). Words: permanent, mergin, nervous, words, deserve, purgin, curb, burnt.
15. `vow:IY` — 25 pairs (END 0, INNER 25). Words: even, probably, see, g, keepin, peace, keep, please.
16. `slant:IH:liq-stop` — 23 pairs (END 0, INNER 23). Words: still, lil, hit, shit, really, dick, milli, big.
17. `slant:AY:nas-stop` — 21 pairs (END 7, INNER 14). Words: time, ridin, slide, hide, decide, online, spine, find.
18. `slant:AY:stop` — 19 pairs (END 10, INNER 9). Words: survived, right, slide, like, type, died, hide, lied.
19. `slant:EH:liq-stop` — 19 pairs (END 8, INNER 11). Words: get, head, tell, bare, there, bed, scared, wheelchair.
20. `slant:AE:nas-stop` — 18 pairs (END 6, INNER 12). Words: man, hang, bang, had, hat, rappin, trap, back.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- opps — 23 pair sides, mostly vowel via spelling phonetic key, often with dont (8)
- nigga — 19 pair sides, mostly spelling via spelling phonetic key, often with hit (5)
- drac — 15 pair sides, mostly spelling via spelling phonetic key, often with ass (4)
- niggas — 8 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- finna — 7 pair sides, mostly vowel via spelling phonetic key, often with nigga (2)
- gon — 6 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- turnt — 4 pair sides, mostly vowel via spelling phonetic key, often with burnt (1)
- herbo — 4 pair sides, mostly spelling via spelling phonetic key, often with swerve (1)
- raq — 3 pair sides, mostly spelling via spelling phonetic key, often with hat (1)
- foenem — 3 pair sides, mostly spelling via spelling phonetic key, often with blowin (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with eat (1)
- tris — 2 pair sides, mostly spelling via spelling phonetic key, often with really (1)
- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with playin (1)
- dracs — 2 pair sides, mostly vowel via spelling phonetic key, often with cant (2)
- youngins — 2 pair sides, mostly vowel via spelling phonetic key, often with feelings (1)
- merch — 1 pair sides, mostly vowel via spelling phonetic key, often with werent (1)
- cosignin — 1 pair sides, mostly spelling via spelling phonetic key, often with even (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| VonOff1700 | Dead Niggas | 60 | 109 | 532 | loose |
| VonOff1700 | U Know Dat (Remix) | 48 | 80 | 602 | loose |
