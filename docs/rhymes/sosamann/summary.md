# Sosamann rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Sosamann
- Songs: 2
- Bars kept (Sosamann lyric lines): 143
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Sosamann.
- Credit strings: Sosamann.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 782
- REPEAT pairs, recorded separately: 94
- END rhymes: 201
- INNER rhymes: 581

By match:

- PERFECT: 51 (END 32, INNER 19)
- SLANT: 351 (END 85, INNER 266)
- ASSONANCE: 378 (END 82, INNER 296)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 51
- MED: 664
- LOW: 67

## Core

- Core Y: 758
- Core N among rhyme pairs: 24

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 356 (45.5%)
- vowel: 378 (48.3%)
- spelling: 46 (5.9%)
- multi: 2 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 81 pairs (END 21, INNER 60). Words: bitch, wrist, bitches, spill, dripping, really, pimping, living.
2. `vow:AE` — 53 pairs (END 9, INNER 44). Words: savage, bag, bands, hands, wrap, mad, can, damn.
3. `vow:EH` — 40 pairs (END 15, INNER 25). Words: em, medals, pressure, metal, myself, shelf, credit, protection.
4. `vow:OW` — 40 pairs (END 22, INNER 18). Words: know, go, bowl, ocean, don't, heroic, opps, home.
5. `vow:IY` — 39 pairs (END 6, INNER 33). Words: see, serena, cleaner, bleachers, shawty, green, thirty, real.
6. `slant:AE:stop` — 32 pairs (END 20, INNER 12). Words: whacked, strap, back, jack, hat, bag, stack, lap.
7. `vow:EY` — 31 pairs (END 5, INNER 26). Words: ain't, way, play, take, day, game, base, sba.
8. `slant:IH:stop` — 29 pairs (END 1, INNER 28). Words: hit, nigga, lick, whip, wrist, diddy, flip, city.
9. `vow:AY` — 27 pairs (END 0, INNER 27). Words: like, isis, dye, why, rhymes, diamonds, right, pirate.
10. `vow:AH` — 26 pairs (END 2, INNER 24). Words: motherfuckin, some, hundred, hundreds, double, months, bust, drum.
11. `slant:IH:liq-stop` — 23 pairs (END 10, INNER 13). Words: spill, shit, grip, drill, drip, whip, jill, still.
12. `slant:IH:sib-stop` — 23 pairs (END 4, INNER 19). Words: bitch, hit, whip, clips, drip, shit, grip, trip.
13. `vow:AA` — 22 pairs (END 0, INNER 22). Words: caused, knocking, cause, got, chops, sharp, knocked, want.
14. `slant:IH:nas-stop` — 16 pairs (END 2, INNER 14). Words: sing, synonym, i'ma, hit, lick, him, grip, split.
15. `slant:AH:nas-stop` — 13 pairs (END 3, INNER 10). Words: fuck, young, thug, one, money, some, none, nut.
16. `slant:AA:stop` — 12 pairs (END 1, INNER 11). Words: got, gotta, hopped, locked, bought, god, knocked, want.
17. `slant:AE:nas-stop` — 11 pairs (END 2, INNER 9). Words: bag, scam, can, mad, sack, damn, had, man.
18. `slant:EY:sib-stop` — 10 pairs (END 10, INNER 0). Words: mase, faith, gate, base, cape, weight, nate.
19. `slant:EY:stop` — 9 pairs (END 3, INNER 6). Words: ain't, cape, nate, weight, gate, take, wait, eight.
20. `cmu:IH-P` — 8 pairs (END 8, INNER 0). Words: drip, trip, hip, clip, whip, grip.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with lick (2)
- tryna — 10 pair sides, mostly spelling via spelling phonetic key, often with superhero (3)
- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with give (3)
- icepick — 7 pair sides, mostly vowel via spelling phonetic key, often with wrist (1)
- twinz — 5 pair sides, mostly vowel via spelling phonetic key, often with drippin (2)
- shawty — 5 pair sides, mostly vowel via spelling phonetic key, often with currency (1)
- sisq — 4 pair sides, mostly spelling via spelling phonetic key, often with criscos (1)
- opps — 4 pair sides, mostly vowel via spelling phonetic key, often with dont (2)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with bowl (3)
- criscos — 3 pair sides, mostly spelling via spelling phonetic key, often with rizzoo (1)
- leeno — 2 pair sides, mostly vowel via spelling phonetic key, often with sancho (1)
- rizzoo — 2 pair sides, mostly spelling via spelling phonetic key, often with criscos (1)
- kaoir — 2 pair sides, mostly spelling via spelling phonetic key, often with bag (1)
- vins — 2 pair sides, mostly vowel via spelling phonetic key, often with still (1)
- changs — 2 pair sides, mostly vowel via spelling phonetic key, often with wrap (1)
- kaepernick — 1 pair sides, mostly spelling via spelling phonetic key, often with icepick (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with talk (1)
- yorkie — 1 pair sides, mostly spelling via spelling phonetic key, often with sneak (1)
- finna — 1 pair sides, mostly spelling via spelling phonetic key, often with gym (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Sosamann | Sauce Savage | 68 | 110 | 205 | loose |
| Sosamann | You Know It | 75 | 91 | 376 | loose |
