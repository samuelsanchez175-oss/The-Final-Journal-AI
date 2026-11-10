# Ralfy the Plug rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ralfy the Plug
- Songs: 1
- Bars kept (Ralfy the Plug lyric lines): 29
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Ralfy the Plug.
- Credit strings: Ralfy the Plug.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 297
- REPEAT pairs, recorded separately: 18
- END rhymes: 27
- INNER rhymes: 270

By match:

- PERFECT: 10 (END 2, INNER 8)
- SLANT: 139 (END 10, INNER 129)
- ASSONANCE: 147 (END 14, INNER 133)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 10
- MED: 273
- LOW: 14

## Core

- Core Y: 292
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 139 (46.8%)
- vowel: 147 (49.5%)
- spelling: 10 (3.4%)
- multi: 1 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 28 pairs (END 2, INNER 26). Words: talkin, dogs, watch, got, la, start, harder, r's.
2. `vow:AH` — 28 pairs (END 0, INNER 28). Words: comfort, buttons, hundred, plus, what, one, fuckin, button.
3. `vow:EH` — 20 pairs (END 1, INNER 19). Words: shell's, neck, gettin, stretchin, wrestle, benz, legs, get.
4. `vow:UW` — 18 pairs (END 7, INNER 11). Words: who, bands'll, marmaduke, coupes, two, coupe, bandicoot, poop.
5. `slant:IH:stop` — 17 pairs (END 0, INNER 17). Words: shit, big, drip, whip, blick, nigga, spaceship, hit.
6. `vow:AE` — 15 pairs (END 0, INNER 15). Words: abandoned, crashed, hangin, gang, brand, ass, mad, half.
7. `vow:IH` — 14 pairs (END 0, INNER 14). Words: shit, biggest, dissin, whips, million, big, hit, blick.
8. `slant:IH:sib-stop` — 13 pairs (END 1, INNER 12). Words: bitch, shit, which, big, whip, chris, spaceship, blick.
9. `slant:AH:nas-stop` — 10 pairs (END 0, INNER 10). Words: what, one, some, button, plug, fuck.
10. `vow:EY` — 8 pairs (END 3, INNER 5). Words: ancient, slay, spacious, contagious, cane, crazy, courageous, case.
11. `slant:AE:nas-sib` — 7 pairs (END 0, INNER 7). Words: gang, man, ass, dash, smash, crash.
12. `slant:UW:stop` — 6 pairs (END 6, INNER 0). Words: marmaduke, coupe, bandicoot, poop.
13. `vow:IY` — 6 pairs (END 0, INNER 6). Words: probably, ralfy, nobody, keys, sneak, crazy.
14. `slant:AH:nas-sib` — 5 pairs (END 0, INNER 5). Words: plus, one, button, buttons.
15. `slant:AH:sib-stop` — 5 pairs (END 0, INNER 5). Words: what, plus, what's.
16. `slant:EH:nas-stop` — 5 pairs (END 0, INNER 5). Words: many, went, forget, 'nem, neck, gettin, better, gen5.
17. `slant:EH:stop` — 5 pairs (END 0, INNER 5). Words: better, neck, head, red, get.
18. `slant:IH:liq-stop` — 5 pairs (END 0, INNER 5). Words: severe, shit, blick, drip, big.
19. `slant:UW:sib-stop` — 5 pairs (END 2, INNER 3). Words: coupe, coupes, use, poop, ruth, root.
20. `slant:AE:sib-stop` — 4 pairs (END 0, INNER 4). Words: crashed, crash, dash, smash, mad.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- bandsll — 6 pair sides, mostly vowel via vault phonetic_class, often with coupes (1)
- ralfy — 3 pair sides, mostly vowel via spelling phonetic key, often with probably (1)
- gen5 — 3 pair sides, mostly spelling via spelling phonetic key, often with went (1)
- goro — 2 pair sides, mostly vowel via spelling phonetic key, often with corso (1)
- nem — 2 pair sides, mostly spelling via spelling phonetic key, often with many (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with whips (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ralfy the Plug | Marma Duke | 29 | 27 | 270 | loose |
