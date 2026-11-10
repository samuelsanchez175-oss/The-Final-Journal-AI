# Central Cee rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Central Cee
- Songs: 1
- Bars kept (Central Cee lyric lines): 32
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Central Cee.
- Credit strings: Central Cee.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 348
- REPEAT pairs, recorded separately: 23
- END rhymes: 35
- INNER rhymes: 313

By match:

- PERFECT: 28 (END 5, INNER 23)
- SLANT: 150 (END 16, INNER 134)
- ASSONANCE: 170 (END 14, INNER 156)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 28
- MED: 297
- LOW: 23

## Core

- Core Y: 343
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 160 (46.0%)
- vowel: 170 (48.9%)
- spelling: 18 (5.2%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 29 pairs (END 7, INNER 22). Words: things, pimp, mink, lived, sticks, switch, mitch, brits.
2. `vow:AH` — 26 pairs (END 0, INNER 26). Words: hundred, london, front, couple, bun, gloves, fuck, once.
3. `vow:AY` — 23 pairs (END 0, INNER 23). Words: samurai, divers, why, buy, nike, i'll, guys, outside.
4. `vow:IY` — 17 pairs (END 3, INNER 14). Words: ski, see, demons, league, field, shiesty, sightsee, deal.
5. `slant:IH:liq-sib` — 16 pairs (END 4, INNER 12). Words: bitch, pills, still, switch, jill, will, drill, nil.
6. `slant:AY:sib-stop` — 14 pairs (END 5, INNER 9). Words: guys, spicy, nike, like, icy, outside, type, right.
7. `vow:OW` — 14 pairs (END 0, INNER 14). Words: go, don't, home, broke, told, phone, oakland, bro.
8. `vow:AO` — 13 pairs (END 3, INNER 10). Words: law, wrong, distraught, force, snowboard, record, sword.
9. `vow:AE` — 11 pairs (END 0, INNER 11). Words: had, max, can't, man, mask, catch, traffic, can.
10. `vow:AA` — 10 pairs (END 0, INNER 10). Words: swallowin, carpet, want, got, common, opp, gotta, watch.
11. `vow:EY` — 10 pairs (END 0, INNER 10). Words: uk, pay, ain't, generational, nominated, came, wake, make.
12. `cmu:IH-L` — 9 pairs (END 1, INNER 8). Words: will, nil, drill, jill, still.
13. `slant:EH:liq-stop` — 9 pairs (END 0, INNER 9). Words: tell, air, get, tech, red, hell, well, internet.
14. `slant:AY:stop` — 8 pairs (END 2, INNER 6). Words: nike, like, type, glide, inside, outside, alright.
15. `slant:EH:stop` — 8 pairs (END 0, INNER 8). Words: get, better, already, red, went, internet, head.
16. `slant:AA:stop` — 7 pairs (END 0, INNER 7). Words: got, want, gotta, opp, caught, god, closet.
17. `vow:EH` — 7 pairs (END 0, INNER 7). Words: wealth, get, latex, seven, air, red, never.
18. `slant:AE:nas-stop` — 5 pairs (END 0, INNER 5). Words: trackie, can, man, jack, had, gang.
19. `slant:AW:stop` — 5 pairs (END 0, INNER 5). Words: pound, crowd, thousand, 'bout.
20. `slant:AY:liq-stop` — 5 pairs (END 1, INNER 4). Words: i'll, style, right, child, like, alright.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- shiesty — 4 pair sides, mostly vowel via spelling phonetic key, often with nike (1)
- trackie — 4 pair sides, mostly spelling via spelling phonetic key, often with had (1)
- snitched — 3 pair sides, mostly spelling via spelling phonetic key, often with switch (1)
- wifey — 3 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with beef (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- birkins — 1 pair sides, mostly vowel via spelling phonetic key, often with fill (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Central Cee | GBP | 32 | 35 | 313 | loose |
