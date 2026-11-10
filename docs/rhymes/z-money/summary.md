# Z Money rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Z Money
- Songs: 2
- Bars kept (Z Money lyric lines): 61
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Z Money.
- Credit strings: Z Money.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 657
- REPEAT pairs, recorded separately: 54
- END rhymes: 72
- INNER rhymes: 585

By match:

- PERFECT: 57 (END 6, INNER 51)
- SLANT: 260 (END 30, INNER 230)
- ASSONANCE: 314 (END 27, INNER 287)
- MULTI: 26 (END 9, INNER 17)

By confidence:

- HIGH: 79
- MED: 554
- LOW: 24

## Core

- Core Y: 650
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 296 (45.1%)
- vowel: 314 (47.8%)
- spelling: 21 (3.2%)
- multi: 26 (4.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 75 pairs (END 17, INNER 58). Words: diamonds, time, eye, kind, blind, fly, shine, hypnotized.
2. `vow:AA` — 57 pairs (END 2, INNER 55). Words: got, closet, rockin, robbin, dropped, partner, droppin, pop.
3. `vow:IH` — 54 pairs (END 4, INNER 50). Words: consistent, simple, bitches, bitch, whippin, missin, hitter, really.
4. `vow:EH` — 27 pairs (END 4, INNER 23). Words: sensors, when, pendant, friendly, semi, mental, gentle, rental.
5. `slant:AA:stop` — 21 pairs (END 2, INNER 19). Words: got, lock, shot, glock, stop, hockey, nada, chalk.
6. `slant:AY:nas-stop` — 20 pairs (END 13, INNER 7). Words: shine, hide, time, grind, beside, kind, blind, spine.
7. `vow:IY` — 18 pairs (END 0, INNER 18). Words: freaks, keeps, real, halloween, dealer, treat, sweet, even.
8. `vow:OW` — 18 pairs (END 0, INNER 18). Words: don't, dope, go, posted, know, froze, knows, no.
9. `vow:UW` — 18 pairs (END 0, INNER 18). Words: coupe, new, used, cuckoo, ku, blue, move, through.
10. `vow:AH` — 17 pairs (END 0, INNER 17). Words: money, hungry, appetit, young, what, fuck, duh, bust.
11. `multi:EH-N-T-AH-L` — 15 pairs (END 1, INNER 14). Words: no rental, rental, dental, mental, gentle, money mental, dick dental, cook gentle.
12. `slant:AY:nas` — 15 pairs (END 5, INNER 10). Words: time, shine, cryin, dime, spine, fine, sign.
13. `slant:AA:liq-stop` — 13 pairs (END 2, INNER 11). Words: car, got, shot, holler, lock, dollar, collar, nada.
14. `slant:EH:stop` — 13 pairs (END 0, INNER 13). Words: spent, went, best, get, left, chest, invest, vest.
15. `slant:IH:sib-stop` — 13 pairs (END 0, INNER 13). Words: bitch, shit, thick, clip, crib, trick, dick, hitter.
16. `vow:EY` — 13 pairs (END 0, INNER 13). Words: ain't, mercedes, say, playin, play, re, stay, bales.
17. `slant:IH:stop` — 12 pairs (END 0, INNER 12). Words: nigga, shit, trick, thick, drifter, dick, hitter, clip.
18. `vow:AE` — 11 pairs (END 0, INNER 11). Words: brand, mansion, hand, cat, flashy, balenciaga, can't, trap.
19. `cmu:UW` — 10 pairs (END 0, INNER 10). Words: new, ku, cuckoo, blue, who.
20. `slant:AY:stop` — 9 pairs (END 0, INNER 9). Words: like, right, hypnotized, might, slide, night, inside, beside.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with trick (2)
- appetit — 4 pair sides, mostly vowel via vault phonetic_class, often with duh (1)
- sweeped — 4 pair sides, mostly spelling via spelling phonetic key, often with treat (1)
- foenem — 4 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- iguodala — 3 pair sides, mostly multi via spelling phonetic key, often with guala (1)
- balenciaga — 2 pair sides, mostly vowel via spelling phonetic key, often with brand (2)
- flodgin — 2 pair sides, mostly spelling via spelling phonetic key, often with robbin (1)
- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with cryin (2)
- blickys — 1 pair sides, mostly spelling via spelling phonetic key, often with pickin (1)
- skydweller — 1 pair sides, mostly vowel via spelling phonetic key, often with here (1)
- guala — 1 pair sides, mostly multi via spelling phonetic key, often with iguodala (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with foenem (1)
- 6am — 1 pair sides, mostly spelling via spelling phonetic key, often with had (1)
- shitll — 1 pair sides, mostly spelling via spelling phonetic key, often with iguodala (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Z Money | Bon Appétit | 32 | 16 | 328 | loose |
| Z Money | No Floggin | 29 | 56 | 257 | loose |
