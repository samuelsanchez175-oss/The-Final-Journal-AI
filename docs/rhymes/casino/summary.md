# Casino rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Casino
- Songs: 2
- Bars kept (Casino lyric lines): 68
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Casino.
- Credit strings: Casino.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 430
- REPEAT pairs, recorded separately: 67
- END rhymes: 32
- INNER rhymes: 398

By match:

- PERFECT: 22 (END 4, INNER 18)
- SLANT: 171 (END 15, INNER 156)
- ASSONANCE: 233 (END 13, INNER 220)
- MULTI: 4 (END 0, INNER 4)

By confidence:

- HIGH: 26
- MED: 383
- LOW: 21

## Core

- Core Y: 423
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 178 (41.4%)
- vowel: 233 (54.2%)
- spelling: 15 (3.5%)
- multi: 4 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 41 pairs (END 1, INNER 40). Words: fifty, richard, tinted, lit, thinkin, wrist, bitch, sticks.
2. `vow:OW` — 37 pairs (END 6, INNER 31). Words: don't, no, hold, hoes, know, whole, showin, lo.
3. `vow:EH` — 29 pairs (END 3, INNER 26). Words: steppin, yourself, freshest, neck, next, when, end, where.
4. `vow:AA` — 21 pairs (END 0, INNER 21). Words: problems, want, charm, got, rockin, dropped, hockey, dollar.
5. `vow:AH` — 21 pairs (END 0, INNER 21). Words: bust, muslim, fuck, puck, truck, fucked, once, summers.
6. `vow:AE` — 19 pairs (END 1, INNER 18). Words: pants, racks, ballin, ass, whacked, alexander, rrrah, slatt.
7. `slant:IH:stop` — 18 pairs (END 5, INNER 13). Words: city, hit, lit, lick, nigga, fifty, wrist, shit.
8. `vow:EY` — 17 pairs (END 0, INNER 17). Words: ain't, dae, made, chains, way, savings, baby, play.
9. `vow:AY` — 15 pairs (END 2, INNER 13). Words: like, diamonds, verizon, wifi, twice, diamond, buy, ice.
10. `slant:EH:stop` — 14 pairs (END 2, INNER 12). Words: get, neck, wet, check, sweater, red, head.
11. `vow:IY` — 14 pairs (END 0, INNER 14). Words: thirty, keep, three, mcqueen, beams, jeans, nobody, here.
12. `slant:AA:stop` — 11 pairs (END 0, INNER 11). Words: got, want, patek, lock, not, dropped, hockey, bought.
13. `vow:AO` — 10 pairs (END 0, INNER 10). Words: bossman, forty, all, call, walk, wanted, gone, y'all.
14. `vow:AW` — 9 pairs (END 0, INNER 9). Words: around, bow, now, without, loud, ground, thousand, 'round.
15. `slant:AW:stop` — 6 pairs (END 0, INNER 6). Words: cloudy, 'round, loud, around, ground, thousand, 'bout, account.
16. `slant:IH:sib-stop` — 6 pairs (END 2, INNER 4). Words: bitch, sit, richard, dick, stick, shit.
17. `cmu:AA-T` — 5 pairs (END 0, INNER 5). Words: got, not, bought, lot.
18. `slant:AA:nas-stop` — 5 pairs (END 0, INNER 5). Words: got, mama, drama, osama.
19. `slant:EH:nas-stop` — 5 pairs (END 0, INNER 5). Words: ten, neck, check, when.
20. `slant:EY:nas-stop` — 5 pairs (END 1, INNER 4). Words: draco, game, eight, made, main, bacon, chain.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- rrah — 5 pair sides, mostly spelling via spelling phonetic key, often with slatt (1)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with ticket (1)
- throwed — 3 pair sides, mostly vowel via vault phonetic_class, often with puck (1)
- slatt — 3 pair sides, mostly vowel via spelling phonetic key, often with rrah (1)
- wanye — 2 pair sides, mostly spelling via spelling phonetic key, often with can (1)
- swang — 2 pair sides, mostly spelling via spelling phonetic key, often with ganging (1)
- rari — 2 pair sides, mostly spelling via spelling phonetic key, often with swang (1)
- pacquiao — 1 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with all (1)
- cee — 1 pair sides, mostly vowel via spelling phonetic key, often with gucci (1)
- extendo — 1 pair sides, mostly vowel via spelling phonetic key, often with draco (1)
- balmain — 1 pair sides, mostly spelling via spelling phonetic key, often with chain (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Casino | Deal | 33 | 18 | 192 | loose |
| Casino | Problems | 35 | 14 | 206 | loose |
