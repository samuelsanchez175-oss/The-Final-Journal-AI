# Sada Baby rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Sada Baby
- Songs: 2
- Bars kept (Sada Baby lyric lines): 130
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Sada Baby.
- Credit strings: Sada Baby.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1088
- REPEAT pairs, recorded separately: 104
- END rhymes: 187
- INNER rhymes: 901

By match:

- PERFECT: 96 (END 21, INNER 75)
- SLANT: 440 (END 86, INNER 354)
- ASSONANCE: 540 (END 76, INNER 464)
- MULTI: 12 (END 4, INNER 8)

By confidence:

- HIGH: 104
- MED: 880
- LOW: 104

## Core

- Core Y: 1056
- Core N among rhyme pairs: 32

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 460 (42.3%)
- vowel: 540 (49.6%)
- spelling: 76 (7.0%)
- multi: 12 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 154 pairs (END 23, INNER 131). Words: shit, ignorant, bitch, clips, give, bitches, drillin, intimate.
2. `vow:AE` — 89 pairs (END 24, INNER 65). Words: can't, ass, chances, casket, hands, dancing, mags, pass.
3. `vow:OW` — 83 pairs (END 0, INNER 83). Words: no, don't, know, go, close, hoes, throwin, show.
4. `vow:EY` — 65 pairs (END 6, INNER 59). Words: ain't, made, taking, play, range, aim, shakes, day.
5. `vow:IY` — 48 pairs (END 17, INNER 31). Words: feelings, streets, e, speak, beefing, lethal, see, squeeze.
6. `slant:IH:stop` — 45 pairs (END 3, INNER 42). Words: shit, nigga, wit, big, brick, flip, ripped, flipped.
7. `vow:EH` — 39 pairs (END 2, INNER 37). Words: get, itself, send, myself, enemies, twenty, second, negligence.
8. `slant:IH:sib-stop` — 33 pairs (END 7, INNER 26). Words: bitch, shit, nigga, niggas, blick, switch, quick, big.
9. `slant:AA:stop` — 28 pairs (END 1, INNER 27). Words: got, gotta, body, drop, robbed, squad, dropped, opp.
10. `cmu:OW` — 26 pairs (END 0, INNER 26). Words: no, go, hoe, blow, ho, bro, show, know.
11. `slant:EH:nas-stop` — 20 pairs (END 0, INNER 20). Words: get, 'nem, ten, when, em, better, many, dead.
12. `vow:UW` — 17 pairs (END 0, INNER 17). Words: shoot, new, newborn, juice, two, roof, used, poo.
13. `vow:AH` — 15 pairs (END 0, INNER 15). Words: hundred, blunts, another, what, smut, butt, once, wondering.
14. `slant:IH:liq-sib` — 14 pairs (END 0, INNER 14). Words: bitch, till, kill, year, near, lil, will, still.
15. `slant:IH:nas-stop` — 14 pairs (END 2, INNER 12). Words: shit, him, i'ma, wit, king, limit, flip, big.
16. `slant:IY:sib-stop` — 14 pairs (END 4, INNER 10). Words: cheese, pleased, speak, weed, freeze, squeeze, g's, skeet.
17. `slant:IH:liq-stop` — 12 pairs (END 0, INNER 12). Words: shit, year, kill, lil, quick, flip, big, brick.
18. `slant:AE:stop` — 11 pairs (END 2, INNER 9). Words: bag, back, trap, automatic, brag, can't, transit, bad.
19. `slant:EH:stop` — 11 pairs (END 0, INNER 11). Words: get, twenty, better, dead, red, end, went, head.
20. `slant:AE:sib-stop` — 10 pairs (END 4, INNER 6). Words: ass, trans, bag, mags, brag, drac, can't, transit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 31 pair sides, mostly spelling via spelling phonetic key, often with shit (12)
- nem — 11 pair sides, mostly spelling via spelling phonetic key, often with get (4)
- ima — 8 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- niggas — 7 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- tryna — 7 pair sides, mostly spelling via spelling phonetic key, often with weed (2)
- creatine — 6 pair sides, mostly spelling via spelling phonetic key, often with skeet (2)
- glicks — 5 pair sides, mostly vowel via spelling phonetic key, often with shit (2)
- inconsiderate — 5 pair sides, mostly vowel via spelling phonetic key, often with bitches (1)
- disipline — 4 pair sides, mostly vowel via spelling phonetic key, often with belligerent (1)
- teepee — 4 pair sides, mostly vowel via spelling phonetic key, often with tb (1)
- skilla — 3 pair sides, mostly vowel via spelling phonetic key, often with nigga (2)
- drac — 3 pair sides, mostly spelling via spelling phonetic key, often with ass (2)
- bloxk — 3 pair sides, mostly vowel via spelling phonetic key, often with dont (2)
- knifes — 2 pair sides, mostly vowel via spelling phonetic key, often with give (1)
- bando — 2 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- kawhi — 2 pair sides, mostly vowel via spelling phonetic key, often with scoring (1)
- topside — 1 pair sides, mostly vowel via spelling phonetic key, often with dope (1)
- runflats — 1 pair sides, mostly vowel via spelling phonetic key, often with what (1)
- skubaru — 1 pair sides, mostly vowel via spelling phonetic key, often with blunts (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Sada Baby | 150/55 | 75 | 112 | 660 | loose |
| Sada Baby | Baklava | 55 | 75 | 241 | loose |
