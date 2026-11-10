# Rylo Rodriguez rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rylo Rodriguez
- Songs: 2
- Bars kept (Rylo Rodriguez lyric lines): 116
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Rylo Rodriguez.
- Credit strings: Rylo Rodriguez.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 851
- REPEAT pairs, recorded separately: 100
- END rhymes: 88
- INNER rhymes: 763

By match:

- PERFECT: 67 (END 10, INNER 57)
- SLANT: 393 (END 31, INNER 362)
- ASSONANCE: 386 (END 44, INNER 342)
- MULTI: 5 (END 3, INNER 2)

By confidence:

- HIGH: 67
- MED: 708
- LOW: 76

## Core

- Core Y: 831
- Core N among rhyme pairs: 20

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 397 (46.7%)
- vowel: 386 (45.4%)
- spelling: 63 (7.4%)
- multi: 5 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 77 pairs (END 17, INNER 60). Words: ain't, hate, waving, make, medication, stranger, patience, play.
2. `vow:AA` — 56 pairs (END 8, INNER 48). Words: not, got, wanna, starvin, problems, mama, wasn't, coppers.
3. `vow:AY` — 46 pairs (END 2, INNER 44). Words: buy, like, why, by, cry, diamonds, ion, mind.
4. `vow:IH` — 45 pairs (END 5, INNER 40). Words: shit, pistol, sticks, victim, thinkin, period, ritz, him.
5. `vow:OW` — 45 pairs (END 0, INNER 45). Words: know, told, don't, go, hoe, no, hoping, donor.
6. `slant:IH:stop` — 35 pairs (END 10, INNER 25). Words: hit, shit, lick, stick, acquitted, big, pig, rigged.
7. `vow:EH` — 27 pairs (END 2, INNER 25). Words: next, airin, get, lesser, pencils, denver, fell, tell.
8. `slant:EY:stop` — 23 pairs (END 0, INNER 23). Words: make, straight, hate, ain't, made, paid, changed, wake.
9. `vow:IY` — 18 pairs (END 0, INNER 18). Words: keep, see, probably, even, ainty, honey, earlobe, abc's.
10. `slant:AA:stop` — 16 pairs (END 0, INNER 16). Words: locked, want, got, not, gotta, start, og, chopper.
11. `slant:IH:liq-stop` — 16 pairs (END 0, INNER 16). Words: lil, 'til, hit, still, lick, stick, shit, dick.
12. `vow:AE` — 16 pairs (END 0, INNER 16). Words: crackers, can, hand, have, carrots, mans, bags, saltines.
13. `vow:AH` — 16 pairs (END 1, INNER 15). Words: honey, shrunk, fuck, nothing, money, hundred, what's, kukulkan.
14. `slant:IH:nas-stop` — 14 pairs (END 0, INNER 14). Words: shit, him, i'ma, ima, hit, lick, split, city.
15. `cmu:IH-T` — 12 pairs (END 2, INNER 10). Words: hit, shit, sit, split, hunnit, bit.
16. `slant:EH:nas-stop` — 12 pairs (END 0, INNER 12). Words: when, get, many, trend, said, red, em, n.
17. `vow:AO` — 12 pairs (END 3, INNER 9). Words: all, saw, porter, pork, endorsement, born, normal, more.
18. `slant:AE:nas-stop` — 11 pairs (END 1, INNER 10). Words: daddy, man, jaden, bad, nan, brand, hand, rap.
19. `slant:IY:sib-stop` — 11 pairs (END 0, INNER 11). Words: these, eat, keep, feed, deep, street, abc's.
20. `vow:UW` — 11 pairs (END 0, INNER 11). Words: shoot, used, through, juvenile, knew, losin, prove, flew.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 20 pair sides, mostly spelling via spelling phonetic key, often with lil (3)
- tryna — 7 pair sides, mostly spelling via spelling phonetic key, often with keep (2)
- delt — 6 pair sides, mostly spelling via spelling phonetic key, often with told (2)
- ainty — 4 pair sides, mostly vowel via spelling phonetic key, often with honey (3)
- glizzy — 3 pair sides, mostly vowel via spelling phonetic key, often with dizzy (1)
- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- ebt — 3 pair sides, mostly spelling via spelling phonetic key, often with bet (2)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with donor (1)
- rylo — 3 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- shurnk — 3 pair sides, mostly spelling via spelling phonetic key, often with shrunk (2)
- kukulkan — 2 pair sides, mostly spelling via spelling phonetic key, often with man (1)
- jamai — 2 pair sides, mostly spelling via spelling phonetic key, often with daddy (1)
- earlobe — 2 pair sides, mostly vowel via spelling phonetic key, often with leave (1)
- muthafuckin — 2 pair sides, mostly vowel via spelling phonetic key, often with nothing (1)
- jaden — 2 pair sides, mostly spelling via spelling phonetic key, often with daddy (1)
- hunnit — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- saltines — 2 pair sides, mostly vowel via spelling phonetic key, often with crackers (2)
- moschino — 2 pair sides, mostly vowel via spelling phonetic key, often with hoe (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- gunplay — 1 pair sides, mostly spelling via spelling phonetic key, often with play (1)
- yall — 1 pair sides, mostly spelling via spelling phonetic key, often with wall (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with long (1)
- cocoaine — 1 pair sides, mostly vowel via spelling phonetic key, often with dope (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rylo Rodriguez | Lie Bout It | 52 | 33 | 216 | loose |
| Rylo Rodriguez | Next To Me | 64 | 55 | 547 | loose |
