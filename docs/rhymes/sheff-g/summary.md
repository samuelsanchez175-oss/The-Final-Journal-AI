# Sheff G rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Sheff G
- Songs: 2
- Bars kept (Sheff G lyric lines): 99
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Sheff G.
- Credit strings: Sheff G.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 526
- REPEAT pairs, recorded separately: 65
- END rhymes: 92
- INNER rhymes: 434

By match:

- PERFECT: 58 (END 14, INNER 44)
- SLANT: 205 (END 33, INNER 172)
- ASSONANCE: 257 (END 43, INNER 214)
- MULTI: 6 (END 2, INNER 4)

By confidence:

- HIGH: 59
- MED: 428
- LOW: 39

## Core

- Core Y: 511
- Core N among rhyme pairs: 15

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 233 (44.3%)
- vowel: 257 (48.9%)
- spelling: 30 (5.7%)
- multi: 6 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 75 pairs (END 22, INNER 53). Words: hit, drillin, cities, different, really, twistin, forgiveness, figures.
2. `vow:OW` — 53 pairs (END 2, INNER 51). Words: know, don't, go, no, both, only, rolls, homo.
3. `vow:AE` — 29 pairs (END 8, INNER 21). Words: laughin, gang, dance, back, sandwich, collapse, clappin, scammin.
4. `vow:AH` — 22 pairs (END 0, INNER 22). Words: month, buckin, jump, money, another, beastin, what, muggin.
5. `slant:AA:stop` — 17 pairs (END 0, INNER 17). Words: not, gotta, got, chalk, want, drop, opp, bop.
6. `vow:AW` — 15 pairs (END 8, INNER 7). Words: about, now, around, 'round, blicky, without, down, clown.
7. `cmu:OW` — 13 pairs (END 0, INNER 13). Words: know, go, no, blow, toe, show.
8. `vow:EH` — 13 pairs (END 0, INNER 13). Words: get, gettin, federal, message, tell, send, s, care.
9. `vow:AA` — 12 pairs (END 0, INNER 12). Words: not, bah, want, talkin, got, gotta, poppin, drop.
10. `slant:AH:nas` — 11 pairs (END 5, INNER 6). Words: runnin, some, money, dummy, funny, comin, bunny, buckin.
11. `slant:IH:nas-stop` — 11 pairs (END 0, INNER 11). Words: him, hit, i'ma, trigger, skin, sip, stick, pick.
12. `vow:IY` — 11 pairs (END 0, INNER 11). Words: demons, screamin, see, hear, squeeze, eat, cheese, real.
13. `cmu:AO-L` — 10 pairs (END 0, INNER 10). Words: fall, all, ball, mall, waterfall.
14. `slant:IY:liq-stop` — 10 pairs (END 2, INNER 8). Words: sleepy, deal, real, peeled, field, squeal, hear, eat.
15. `slant:AW:nas-stop` — 9 pairs (END 8, INNER 1). Words: clown, down, about, blicky, without, around, 'round.
16. `slant:IH:liq-nas` — 9 pairs (END 0, INNER 9). Words: still, him, i'ma, 'til, chill.
17. `slant:IH:nas` — 9 pairs (END 3, INNER 6). Words: drillin, him, skin, sinnin, sittin, building, children, million.
18. `vow:EY` — 8 pairs (END 0, INNER 8). Words: ain't, stayin, same, great, way, probation, name, paid.
19. `vow:UW` — 8 pairs (END 3, INNER 5). Words: who, twos, used, coupe, new, news, shooters, soon.
20. `slant:AE:nas` — 7 pairs (END 4, INNER 3). Words: gang, laughin, man, blastin, ashin, passin, clappin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- blicky — 7 pair sides, mostly cmu via vault phonetic_class, often with now (1)
- ima — 6 pair sides, mostly spelling via spelling phonetic key, often with hit (2)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with squeeze (1)
- crills — 4 pair sides, mostly vowel via spelling phonetic key, often with will (1)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- ashin — 3 pair sides, mostly spelling via spelling phonetic key, often with blastin (1)
- scammin — 3 pair sides, mostly vowel via spelling phonetic key, often with clappin (1)
- opps — 3 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- papoose — 3 pair sides, mostly vowel via spelling phonetic key, often with have (2)
- niggas — 3 pair sides, mostly vowel via vault phonetic_class, often with mix (1)
- beastin — 2 pair sides, mostly vowel via vault phonetic_class, often with runnin (1)
- cuzzo — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- glocks — 1 pair sides, mostly vowel via spelling phonetic key, often with show (1)
- coolax — 1 pair sides, mostly spelling via spelling phonetic key, often with relax (1)
- homies — 1 pair sides, mostly spelling via spelling phonetic key, often with home (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with hit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Sheff G | Panic, Pt. 4 (Original) | 62 | 63 | 272 | loose |
| Sheff G | Ventilator | 37 | 29 | 162 | loose |
