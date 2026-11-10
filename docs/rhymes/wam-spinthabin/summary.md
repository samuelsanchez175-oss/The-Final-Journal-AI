# Wam SpinThaBin rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Wam SpinThaBin
- Songs: 2
- Bars kept (Wam SpinThaBin lyric lines): 82
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Wam SpinThaBin.
- Credit strings: Wam SpinThaBin.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 585
- REPEAT pairs, recorded separately: 53
- END rhymes: 94
- INNER rhymes: 491

By match:

- PERFECT: 54 (END 16, INNER 38)
- SLANT: 218 (END 29, INNER 189)
- ASSONANCE: 306 (END 48, INNER 258)
- MULTI: 7 (END 1, INNER 6)

By confidence:

- HIGH: 53
- MED: 483
- LOW: 49

## Core

- Core Y: 578
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 221 (37.8%)
- vowel: 306 (52.3%)
- spelling: 51 (8.7%)
- multi: 7 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 88 pairs (END 9, INNER 79). Words: send, better, steppin, end, ever, inevitable, heaven, sending.
2. `vow:IH` — 54 pairs (END 5, INNER 49). Words: shit, lil, dissin, figure, killed, until, years, him.
3. `vow:EY` — 50 pairs (END 12, INNER 38). Words: ain't, invasion, graves, way, make, jake, lay, made.
4. `vow:OW` — 33 pairs (END 7, INNER 26). Words: don't, know, no, stolen, won't, frozen, folk, smoke.
5. `vow:AH` — 22 pairs (END 6, INNER 16). Words: double, brother, fuckin, hundred, fumble, stuffing, trucks, dumpin.
6. `slant:IH:stop` — 18 pairs (END 0, INNER 18). Words: nigga, shit, hit, nick, city, big.
7. `vow:AE` — 18 pairs (END 9, INNER 9). Words: facts, plans, bands, pack, back, bam, kodak, can't.
8. `slant:EH:stop` — 17 pairs (END 0, INNER 17). Words: get, bread, already, send, ready, better, said, step.
9. `cmu:OW` — 14 pairs (END 8, INNER 6). Words: know, blow, show, bro, elbow, go, no.
10. `vow:AA` — 14 pairs (END 0, INNER 14). Words: na, block, bond, got, spot, starting, camaros, top.
11. `slant:IH:nas-sib` — 13 pairs (END 4, INNER 9). Words: bitch, spin, wiz, him, kin, fin, biz, miss.
12. `slant:AA:stop` — 12 pairs (END 0, INNER 12). Words: god, block, top, not, heart, want, caught, everybody.
13. `slant:IH:liq-stop` — 12 pairs (END 0, INNER 12). Words: lil, big, shit, bill, kill, city.
14. `vow:IY` — 12 pairs (END 0, INNER 12). Words: 't, clean, field, beat, free, seems, need, see.
15. `slant:IH:sib-stop` — 11 pairs (END 1, INNER 10). Words: bitch, shit, hit, miss, nigga, niggas, nick, wiz.
16. `vow:AY` — 11 pairs (END 0, INNER 11). Words: like, fly, private, stripes, slidin, eyes, iced, slime.
17. `cmu:IH-L` — 9 pairs (END 0, INNER 9). Words: kill, bill, lil.
18. `slant:IH:nas` — 9 pairs (END 0, INNER 9). Words: spin, i'ma, him, killin, prison, finna, spinnin, missin.
19. `slant:IH:nas-stop` — 8 pairs (END 0, INNER 8). Words: shit, gym, city, fin, him, kin, hit.
20. `cmu:EY` — 7 pairs (END 1, INNER 6). Words: day, lay, way, yesterday, dj.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 20 pair sides, mostly spelling via spelling phonetic key, often with shit (5)
- niggas — 8 pair sides, mostly spelling via spelling phonetic key, often with finna (3)
- ima — 6 pair sides, mostly spelling via spelling phonetic key, often with spin (2)
- wam — 5 pair sides, mostly spelling via spelling phonetic key, often with bam (2)
- finna — 5 pair sides, mostly vowel via spelling phonetic key, often with niggas (3)
- vegetabl — 4 pair sides, mostly spelling via spelling phonetic key, often with medical (1)
- blicks — 3 pair sides, mostly vowel via spelling phonetic key, often with kill (1)
- lambos — 2 pair sides, mostly spelling via spelling phonetic key, often with camaros (1)
- ain — 2 pair sides, mostly spelling via spelling phonetic key, often with snake (1)
- gangstas — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- ciggerelos — 2 pair sides, mostly spelling via spelling phonetic key, often with lambos (1)
- deral — 2 pair sides, mostly spelling via spelling phonetic key, often with medical (1)
- xannies — 2 pair sides, mostly spelling via spelling phonetic key, often with cannon (2)
- coorlink — 1 pair sides, mostly spelling via spelling phonetic key, often with think (1)
- marni — 1 pair sides, mostly spelling via spelling phonetic key, often with wanna (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- wylin — 1 pair sides, mostly spelling via spelling phonetic key, often with starin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Wam SpinThaBin | Ktb | 44 | 64 | 224 | loose |
| Wam SpinThaBin | Roger Dat | 38 | 30 | 267 | loose |
