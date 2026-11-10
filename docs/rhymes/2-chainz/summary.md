# 2 Chainz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 2 Chainz
- Songs: 5
- Bars kept (2 Chainz lyric lines): 287
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: 2 Chainz.
- Credit strings: 2 Chainz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1488
- REPEAT pairs, recorded separately: 224
- END rhymes: 302
- INNER rhymes: 1186

By match:

- PERFECT: 144 (END 25, INNER 119)
- SLANT: 638 (END 141, INNER 497)
- ASSONANCE: 676 (END 122, INNER 554)
- MULTI: 30 (END 14, INNER 16)

By confidence:

- HIGH: 160
- MED: 1219
- LOW: 109

## Core

- Core Y: 1456
- Core N among rhyme pairs: 32

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 691 (46.4%)
- vowel: 676 (45.4%)
- spelling: 91 (6.1%)
- multi: 30 (2.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 5 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 130 pairs (END 22, INNER 108). Words: know, no, don't, phone, lotto, go, kyro, home.
2. `vow:EH` — 86 pairs (END 10, INNER 76). Words: when, attention, developed, left, check, best, tesla, text.
3. `vow:AY` — 85 pairs (END 27, INNER 58). Words: like, lighter, sirens, y, find, try, blind, fightin.
4. `vow:AA` — 79 pairs (END 12, INNER 67). Words: wasn't, artist, moms, pockets, charger, solid, charges, supermarkets.
5. `vow:EY` — 75 pairs (END 6, INNER 69). Words: say, ain't, crazy, play, baby, haters, shades, waist.
6. `vow:IH` — 52 pairs (END 9, INNER 43). Words: wrist, bitch, ikey, lil, million, figures, still, hitters.
7. `vow:AH` — 45 pairs (END 14, INNER 31). Words: fuckin, love, mothers, young, some, guns, fucked, pumps.
8. `vow:IY` — 38 pairs (END 5, INNER 33). Words: nobody, need, p, feelings, streets, feel, see, hear.
9. `slant:AA:stop` — 37 pairs (END 0, INNER 37). Words: got, hot, art, top, block, market, everybody, rob.
10. `slant:IH:sib-stop` — 37 pairs (END 9, INNER 28). Words: bitch, sick, nigga, niggas, split, nigga's, big, pitch.
11. `slant:AY:stop` — 33 pairs (END 9, INNER 24). Words: like, lighter, almighty, ride, right, nike, beside, side.
12. `slant:IH:stop` — 33 pairs (END 5, INNER 28). Words: nigga, split, hit, flip, sick, big, shit, lit.
13. `vow:AE` — 32 pairs (END 4, INNER 28). Words: back, rats, compassion, brand, bags, fashion, pastor, savin.
14. `vow:UW` — 30 pairs (END 11, INNER 19). Words: bamboo, used, shampoo, foods, avenue, move, room, knew.
15. `cmu:OW` — 24 pairs (END 4, INNER 20). Words: no, know, though, bro, ho, lotto, go, o.
16. `slant:EH:stop` — 24 pairs (END 0, INNER 24). Words: better, get, check, neck, checked, respect, head, dead.
17. `slant:AH:nas-stop` — 23 pairs (END 4, INNER 19). Words: butter, young, come, lump, fuck, gutter, stutter, gum.
18. `slant:EY:nas-stop` — 21 pairs (END 1, INNER 20). Words: rained, shake, eight, came, great, dane, lame, jermaine.
19. `slant:IH:nas` — 18 pairs (END 14, INNER 4). Words: women, grinnin, swimmin, pimpin, pitchin, thing, missin, him.
20. `slant:AE:stop` — 17 pairs (END 4, INNER 13). Words: back, crack, bad, had, bag, can't, lambo, rap.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 29 pair sides, mostly spelling via spelling phonetic key, often with niggas (10)
- niggas — 17 pair sides, mostly spelling via spelling phonetic key, often with nigga (10)
- kyro — 10 pair sides, mostly vowel via spelling phonetic key, often with though (2)
- ima — 8 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- lambo — 5 pair sides, mostly vowel via spelling phonetic key, often with grabba (1)
- thot — 5 pair sides, mostly spelling via spelling phonetic key, often with phone (2)
- titty — 5 pair sides, mostly vowel via spelling phonetic key, often with silly (1)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with whole (2)
- cuffin — 5 pair sides, mostly spelling via spelling phonetic key, often with fuckin (5)
- butterfingers — 3 pair sides, mostly vowel via spelling phonetic key, often with some (1)
- swoll — 3 pair sides, mostly vowel via spelling phonetic key, often with lotto (2)
- homie — 3 pair sides, mostly spelling via spelling phonetic key, often with whole (1)
- glizzy — 3 pair sides, mostly vowel via spelling phonetic key, often with silly (1)
- wraith — 3 pair sides, mostly vowel via spelling phonetic key, often with waist (1)
- swag — 3 pair sides, mostly spelling via spelling phonetic key, often with stand (1)
- tymer — 2 pair sides, mostly spelling via spelling phonetic key, often with tymers (1)
- hov — 2 pair sides, mostly spelling via spelling phonetic key, often with toes (2)
- grabba — 2 pair sides, mostly spelling via spelling phonetic key, often with diablo (1)
- mulsanne — 2 pair sides, mostly vowel via spelling phonetic key, often with hundred (1)
- rices — 2 pair sides, mostly spelling via spelling phonetic key, often with wifeys (1)
- cuticles — 2 pair sides, mostly vowel via spelling phonetic key, often with come (1)
- payphone — 2 pair sides, mostly spelling via spelling phonetic key, often with maintain (1)
- tymers — 1 pair sides, mostly spelling via spelling phonetic key, often with tymer (1)
- throwed — 1 pair sides, mostly spelling via spelling phonetic key, often with round (1)
- flocka — 1 pair sides, mostly spelling via spelling phonetic key, often with pole (1)
- def — 1 pair sides, mostly spelling via spelling phonetic key, often with left (1)
- micin — 1 pair sides, mostly vowel via spelling phonetic key, often with bitch (1)
- dej — 1 pair sides, mostly spelling via spelling phonetic key, often with tell (1)
- maneski — 1 pair sides, mostly spelling via spelling phonetic key, often with lambo (1)
- dungarees — 1 pair sides, mostly spelling via spelling phonetic key, often with guns (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 2 Chainz | Big Diamonds | 69 | 80 | 211 | loose |
| 2 Chainz | Free Lighter | 59 | 87 | 220 | loose |
| 2 Chainz | I’m Not Crazy, Life Is | 49 | 42 | 272 | loose |
| 2 Chainz | Save Me | 38 | 39 | 243 | loose |
| 2 Chainz | You in Luv wit Her | 72 | 54 | 240 | loose |
