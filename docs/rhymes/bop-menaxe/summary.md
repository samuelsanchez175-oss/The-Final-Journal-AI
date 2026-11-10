# Bop Menaxe rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bop Menaxe
- Songs: 2
- Bars kept (Bop Menaxe lyric lines): 77
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bop Menaxe.
- Credit strings: Bop Menaxe.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 374
- REPEAT pairs, recorded separately: 69
- END rhymes: 87
- INNER rhymes: 287

By match:

- PERFECT: 24 (END 8, INNER 16)
- SLANT: 173 (END 39, INNER 134)
- ASSONANCE: 169 (END 38, INNER 131)
- MULTI: 8 (END 2, INNER 6)

By confidence:

- HIGH: 28
- MED: 323
- LOW: 23

## Core

- Core Y: 373
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 173 (46.3%)
- vowel: 169 (45.2%)
- spelling: 24 (6.4%)
- multi: 8 (2.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 35 pairs (END 10, INNER 25). Words: else, against, left, neck, get, sheddin, breath, never.
2. `vow:OW` — 29 pairs (END 8, INNER 21). Words: know, don’t, soldiers, told, no, hoein, growin, code.
3. `vow:AY` — 28 pairs (END 15, INNER 13). Words: survive, traumatized, homicides, like, die, mine, diamond, cry.
4. `vow:EY` — 24 pairs (END 1, INNER 23). Words: ain’t, say, game, stay, fake, sprayin, patient, take.
5. `vow:AE` — 20 pairs (END 3, INNER 17). Words: back, man, facts, answerin, can’t, after, flats, last.
6. `slant:EH:stop` — 16 pairs (END 11, INNER 5). Words: set, respect, neck, left, kept, went, upset, net.
7. `vow:IH` — 15 pairs (END 1, INNER 14). Words: still, shit, mixed, clearly, pissed, bitches, vis, wishin.
8. `slant:EY:nas-stop` — 13 pairs (END 0, INNER 13). Words: ain’t, pain, take, game, chain, complainin, wake, stayed.
9. `vow:IY` — 12 pairs (END 0, INNER 12). Words: real, feelings, see, keepin, field, street, speakin, speak.
10. `slant:IH:stop` — 10 pairs (END 0, INNER 10). Words: nigga, shit, rid, mixed, pissed, tit.
11. `slant:IH:sib-stop` — 9 pairs (END 0, INNER 9). Words: niggas, nigga, shit, vis, wish.
12. `slant:EH:nas-stop` — 8 pairs (END 0, INNER 8). Words: many, when, neck, set, get, went, upset.
13. `slant:EY:nas` — 8 pairs (END 4, INNER 4). Words: game, pain, chain, complainin, sprayin, lane.
14. `slant:EH:fric-nas` — 7 pairs (END 0, INNER 7). Words: many, never, forever.
15. `slant:EY:nas-sib` — 7 pairs (END 2, INNER 5). Words: chain, veins, change, pain, lane.
16. `slant:EY:stop` — 6 pairs (END 0, INNER 6). Words: hate, ain’t, wait, make, fake.
17. `slant:IH:liq-sib` — 6 pairs (END 2, INNER 4). Words: still, vis, wish, bitch, kill, trill.
18. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: gotta, top, caught, got, lot.
19. `slant:AE:nas-stop` — 5 pairs (END 0, INNER 5). Words: man, gram, tat, slat, mad.
20. `slant:EH:fric-liq` — 5 pairs (END 0, INNER 5). Words: never, where, tell.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 15 pair sides, mostly spelling via spelling phonetic key, often with niggas (6)
- niggas — 7 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with alone (1)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with real (2)
- imma — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)
- sucka — 1 pair sides, mostly spelling via spelling phonetic key, often with some (1)
- youngin — 1 pair sides, mostly spelling via spelling phonetic key, often with win (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bop Menaxe | How to Cry Ft. YFN Lucci | 34 | 42 | 128 | loose |
| Bop Menaxe | Real Nigga Ft YFN Money | 43 | 45 | 159 | loose |
