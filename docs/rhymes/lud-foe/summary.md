# Lud Foe rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lud Foe
- Songs: 1
- Bars kept (Lud Foe lyric lines): 48
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lud Foe.
- Credit strings: Lud Foe.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 431
- REPEAT pairs, recorded separately: 47
- END rhymes: 81
- INNER rhymes: 350

By match:

- PERFECT: 25 (END 4, INNER 21)
- SLANT: 190 (END 30, INNER 160)
- ASSONANCE: 209 (END 44, INNER 165)
- MULTI: 7 (END 3, INNER 4)

By confidence:

- HIGH: 22
- MED: 347
- LOW: 62

## Core

- Core Y: 416
- Core N among rhyme pairs: 15

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 158 (36.7%)
- vowel: 209 (48.5%)
- spelling: 57 (13.2%)
- multi: 7 (1.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 96 pairs (END 20, INNER 76). Words: mister, itchin, bitch, think, prison, literature, twister, hit.
2. `vow:AH` — 59 pairs (END 22, INNER 37). Words: muscle, guns, funds, fuck, runs, lucker, dust, plug.
3. `slant:IH:stop` — 45 pairs (END 7, INNER 38). Words: nigga, hit, bigger, wig, shit, whip, big, tricked.
4. `slant:IH:sib-stop` — 19 pairs (END 3, INNER 16). Words: bitch, stick, niggas, nigga, swisher, miss, dick, shit.
5. `slant:AH:stop` — 15 pairs (END 1, INNER 14). Words: fuck, drug, plug, lucker, club, sucker, dust, smothered.
6. `slant:IH:sib` — 13 pairs (END 4, INNER 9). Words: bitch, niggas, picture, pikachu, whips, miss, swisher, literature.
7. `vow:IY` — 13 pairs (END 2, INNER 11). Words: see, lethal, cheerleaders, police, eat, speed, dealers, need.
8. `vow:OW` — 13 pairs (END 0, INNER 13). Words: dope, no, smokin, potent, won't, know, smoke, roll.
9. `slant:AA:stop` — 10 pairs (END 0, INNER 10). Words: got, hop, bought, rob, chopper, popped, everybody, block.
10. `vow:AE` — 9 pairs (END 0, INNER 9). Words: catnaps, wrapped, saran, trap, sativa, trafficker, bad, ass.
11. `vow:EY` — 7 pairs (END 0, INNER 7). Words: ain't, make, say, wake, tastin.
12. `slant:IH:liq-stop` — 6 pairs (END 0, INNER 6). Words: kill, 'til, whip, shit, hit, lil, stick.
13. `slant:IH:nas-sib` — 6 pairs (END 1, INNER 5). Words: bitch, him, itchin, bitches, ring, everything.
14. `slant:AA:nas-stop` — 5 pairs (END 0, INNER 5). Words: wanna, plottin, hop, not, got, everybody.
15. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: drug, fuck, some, come, gun, plug, fuckin.
16. `slant:AH:sib` — 5 pairs (END 4, INNER 1). Words: funds, russia, ones, guns, runs, brother, mother.
17. `slant:AH:sib-stop` — 5 pairs (END 4, INNER 1). Words: russia, sucker, brother, smothered, lucker, mother.
18. `slant:IH:nas` — 5 pairs (END 3, INNER 2). Words: itchin, fishin, decision, prison.
19. `cmu:AH-N-Z` — 4 pairs (END 3, INNER 1). Words: guns, ones, runs.
20. `cmu:ER-Z` — 4 pairs (END 0, INNER 4). Words: splitters, dealers, killers.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 34 pair sides, mostly spelling via spelling phonetic key, often with hit (8)
- niggas — 11 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- splitters — 8 pair sides, mostly vowel via spelling phonetic key, often with bigger (4)
- gon — 8 pair sides, mostly spelling via spelling phonetic key, often with prison (3)
- pikachu — 4 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- tryna — 4 pair sides, mostly spelling via spelling phonetic key, often with mystikal (1)
- duffle — 3 pair sides, mostly vowel via spelling phonetic key, often with lucker (1)
- catnaps — 3 pair sides, mostly vowel via spelling phonetic key, often with saran (1)
- sativa — 3 pair sides, mostly vowel via spelling phonetic key, often with trap (1)
- finna — 3 pair sides, mostly vowel via spelling phonetic key, often with nigga (2)
- fonem — 2 pair sides, mostly spelling via spelling phonetic key, often with gon (2)
- mystikal — 1 pair sides, mostly vowel via spelling phonetic key, often with tryna (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lud Foe | Witcha | 48 | 81 | 350 | loose |
