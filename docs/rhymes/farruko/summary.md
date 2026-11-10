# Farruko rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Farruko
- Songs: 1
- Bars kept (Farruko lyric lines): 54
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Farruko.
- Credit strings: Farruko.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 437
- REPEAT pairs, recorded separately: 78
- END rhymes: 37
- INNER rhymes: 400

By match:

- PERFECT: 70 (END 12, INNER 58)
- SLANT: 147 (END 17, INNER 130)
- ASSONANCE: 215 (END 7, INNER 208)
- MULTI: 5 (END 1, INNER 4)

By confidence:

- HIGH: 43
- MED: 311
- LOW: 83

## Core

- Core Y: 392
- Core N among rhyme pairs: 45

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 148 (33.9%)
- vowel: 215 (49.2%)
- spelling: 69 (15.8%)
- multi: 5 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 54 pairs (END 0, INNER 54). Words: lo, como, no, know, whole, puerto, traqueo, to'a.
2. `vow:EH` — 38 pairs (END 4, INNER 34). Words: el, regular, fedex, next, ex, es, del, esas.
3. `vow:IH` — 34 pairs (END 0, INNER 34). Words: bitches, still, hinges, kicking, syringes, pink, think, nicki.
4. `vow:IY` — 26 pairs (END 0, INNER 26). Words: see, legal, even, these, de, krippy, lynches, krispy.
5. `vow:EY` — 20 pairs (END 0, INNER 20). Words: ain’t, away, make, paper, baby, pay, way, ain't.
6. `vow:AA` — 14 pairs (END 0, INNER 14). Words: la, got, rocking, las, par, pa, pr, baja.
7. `vow:AE` — 12 pairs (END 3, INNER 9). Words: had, can, thanks, gangs, bangs, tsa, gta, kha.
8. `slant:EH:liq-sib` — 11 pairs (END 0, INNER 11). Words: el, express, gps, del, es.
9. `slant:OW:sib-stop` — 9 pairs (END 3, INNER 6). Words: coca, boca, chocha, rosa, sosa, hermosa, bobo, los.
10. `cmu:EY` — 8 pairs (END 4, INNER 4). Words: se, away, way, ebay, ley, day.
11. `cmu:IY` — 7 pairs (END 0, INNER 7). Words: de, ac, 'e, v.
12. `slant:EH:sib` — 7 pairs (END 4, INNER 3). Words: ex, fedex, express, gps, es, esas.
13. `slant:IH:stop` — 7 pairs (END 3, INNER 4). Words: nicki, krippy, bizca, krispy, pink, friska, brisca, bichote.
14. `spell:as` — 7 pairs (END 0, INNER 7). Words: las, putas, libras, cajas, gatas.
15. `vow:UW` — 7 pairs (END 0, INNER 7). Words: que, movie, snoop, using, tools.
16. `slant:AE:sib-stop` — 6 pairs (END 0, INNER 6). Words: back, ass, racks, fat, pass.
17. `slant:EH:nas-sib` — 6 pairs (END 0, INNER 6). Words: es, en, n, venga.
18. `cmu:AA` — 5 pairs (END 0, INNER 5). Words: pa, baja, la.
19. `slant:EH:liq-nas` — 5 pairs (END 0, INNER 5). Words: el, en, n.
20. `slant:EH:nas-stop` — 5 pairs (END 0, INNER 5). Words: en, ped, n, prend, queda.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ped — 6 pair sides, mostly spelling via spelling phonetic key, often with en (3)
- queda — 6 pair sides, mostly spelling via spelling phonetic key, often with el (2)
- traqueo — 6 pair sides, mostly vowel via spelling phonetic key, often with lo (2)
- esas — 6 pair sides, mostly spelling via spelling phonetic key, often with ex (1)
- chocha — 5 pair sides, mostly spelling via spelling phonetic key, often with coca (1)
- sembrar — 5 pair sides, mostly spelling via spelling phonetic key, often with regular (1)
- krispy — 5 pair sides, mostly vowel via spelling phonetic key, often with frisbee (1)
- putas — 5 pair sides, mostly spelling via spelling phonetic key, often with las (3)
- krippy — 5 pair sides, mostly vowel via spelling phonetic key, often with nicki (1)
- venga — 5 pair sides, mostly vowel via spelling phonetic key, often with es (1)
- lynches — 4 pair sides, mostly vowel via spelling phonetic key, often with these (2)
- libras — 4 pair sides, mostly vowel via spelling phonetic key, often with las (2)
- cobramo — 4 pair sides, mostly vowel via spelling phonetic key, often with lo (2)
- somos — 4 pair sides, mostly spelling via spelling phonetic key, often with los (1)
- brisca — 3 pair sides, mostly multi via spelling phonetic key, often with friska (1)
- bizca — 3 pair sides, mostly spelling via spelling phonetic key, often with friska (1)
- quieren — 3 pair sides, mostly spelling via spelling phonetic key, often with when (1)
- cajas — 3 pair sides, mostly spelling via spelling phonetic key, often with pasamos (1)
- fumando — 3 pair sides, mostly vowel via spelling phonetic key, often with como (2)
- prend — 3 pair sides, mostly spelling via spelling phonetic key, often with n (1)
- llegan — 3 pair sides, mostly vowel via spelling phonetic key, often with n (1)
- sint — 3 pair sides, mostly spelling via spelling phonetic key, often with shipping (1)
- puestos — 3 pair sides, mostly spelling via spelling phonetic key, often with los (1)
- comprar — 3 pair sides, mostly spelling via spelling phonetic key, often with frontear (1)
- tsa — 2 pair sides, mostly vowel via spelling phonetic key, often with gta (1)
- gta — 2 pair sides, mostly vowel via spelling phonetic key, often with tsa (1)
- kha — 2 pair sides, mostly vowel via spelling phonetic key, often with tsa (1)
- friska — 2 pair sides, mostly multi via spelling phonetic key, often with brisca (1)
- pasamos — 2 pair sides, mostly spelling via spelling phonetic key, often with tenemos (1)
- dogg — 2 pair sides, mostly vowel via spelling phonetic key, often with como (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Farruko | Krippy Kush (Remix) | 54 | 37 | 400 | loose |
