# YG rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: YG
- Songs: 5
- Bars kept (YG lyric lines): 257
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: YG.
- Credit strings: YG.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1687
- REPEAT pairs, recorded separately: 185
- END rhymes: 267
- INNER rhymes: 1420

By match:

- PERFECT: 148 (END 43, INNER 105)
- SLANT: 844 (END 131, INNER 713)
- ASSONANCE: 674 (END 79, INNER 595)
- MULTI: 21 (END 14, INNER 7)

By confidence:

- HIGH: 154
- MED: 1416
- LOW: 117

## Core

- Core Y: 1670
- Core N among rhyme pairs: 17

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 878 (52.0%)
- vowel: 674 (40.0%)
- spelling: 114 (6.8%)
- multi: 21 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 5 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 137 pairs (END 17, INNER 120). Words: bitch, bitches, digits, big, shit, drink, different, fifties.
2. `vow:OW` — 123 pairs (END 18, INNER 105). Words: don't, hoe, no, know, told, hold, go, clothes.
3. `vow:AE` — 102 pairs (END 13, INNER 89). Words: bands, ass, can't, bank, stands, fallin, mascot, land.
4. `slant:IH:stop` — 88 pairs (END 20, INNER 68). Words: shit, nigga, big, bullshit, city, hit, clip, blicky.
5. `vow:AH` — 75 pairs (END 7, INNER 68). Words: fuck, some, double, hundreds, hundred, money, run, what's.
6. `vow:AA` — 63 pairs (END 6, INNER 57). Words: got, poppin, rockin, mama's, partner, argue, da, mocking.
7. `slant:AA:stop` — 61 pairs (END 6, INNER 55). Words: got, drop, not, gotta, top, lot, spot, lotta.
8. `slant:IH:sib-stop` — 57 pairs (END 6, INNER 51). Words: bitch, shit, rich, niggas, bullshit, hit, nigga, city.
9. `vow:EH` — 53 pairs (END 0, INNER 53). Words: get, sex, friend, gettin, never, benz, when, left.
10. `vow:EY` — 50 pairs (END 0, INNER 50). Words: ain't, day, dangerous, same, straight, playin, say, blame.
11. `slant:AE:nas-stop` — 40 pairs (END 8, INNER 32). Words: man, gang, batman, hand, 'gram, bag, splat, rap.
12. `vow:AY` — 32 pairs (END 12, INNER 20). Words: like, signs, wire, time, tired, prior, die, five.
13. `slant:AE:stop` — 29 pairs (END 2, INNER 27). Words: trap, can't, gat, bad, back, black, pac, clap.
14. `vow:IY` — 26 pairs (END 3, INNER 23). Words: shottas, these, keep, streets, speakin, feelin, v, p.
15. `slant:AH:nas-stop` — 25 pairs (END 1, INNER 24). Words: fuck, come, one, money, run, fuckin, what, front.
16. `slant:IH:sib` — 23 pairs (END 7, INNER 16). Words: bitches, bitch, switches, busy, killers, tipsy, britches, glizzies.
17. `slant:AE:sib-stop` — 22 pairs (END 6, INNER 16). Words: bands, ass, bad, stand, hand, back, packs, land.
18. `slant:EY:nas-stop` — 22 pairs (END 0, INNER 22). Words: lane, main, ain't, made, fake, claim, same, late.
19. `cmu:OW` — 21 pairs (END 1, INNER 20). Words: no, hoe, go, bro, know, dough, hello, o.
20. `slant:IH:nas-stop` — 20 pairs (END 5, INNER 15). Words: shit, i'ma, inn, hit, city, him, slim, ticket.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 39 pair sides, mostly spelling via spelling phonetic key, often with shit (12)
- niggas — 16 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- ima — 13 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- blicky — 10 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- gon — 7 pair sides, mostly spelling via spelling phonetic key, often with dont (6)
- shottas — 5 pair sides, mostly vowel via vault phonetic_class, often with squeeze (1)
- meds — 5 pair sides, mostly spelling via spelling phonetic key, often with red (1)
- apeshit — 4 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- bigg — 4 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- finna — 4 pair sides, mostly vowel via spelling phonetic key, often with niggas (2)
- popos — 4 pair sides, mostly vowel via spelling phonetic key, often with told (2)
- dap — 4 pair sides, mostly spelling via spelling phonetic key, often with rap (1)
- insta — 3 pair sides, mostly vowel via spelling phonetic key, often with niggas (2)
- glizzies — 3 pair sides, mostly spelling via spelling phonetic key, often with bitches (1)
- opps — 3 pair sides, mostly vowel via spelling phonetic key, often with glockenese (1)
- thot — 3 pair sides, mostly spelling via spelling phonetic key, often with spot (2)
- cath — 3 pair sides, mostly spelling via spelling phonetic key, often with hands (1)
- bap — 2 pair sides, mostly spelling via spelling phonetic key, often with gang (1)
- bros — 2 pair sides, mostly spelling via spelling phonetic key, often with clothes (1)
- nipsey — 2 pair sides, mostly spelling via spelling phonetic key, often with tipsy (1)
- lears — 2 pair sides, mostly spelling via spelling phonetic key, often with here (2)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with turn (1)
- thes — 1 pair sides, mostly spelling via spelling phonetic key, often with any (1)
- gle — 1 pair sides, mostly vowel via spelling phonetic key, often with nle (1)
- nle — 1 pair sides, mostly vowel via spelling phonetic key, often with gle (1)
- glockenese — 1 pair sides, mostly spelling via spelling phonetic key, often with opps (1)
- geeked — 1 pair sides, mostly spelling via spelling phonetic key, often with sneak (1)
- doin — 1 pair sides, mostly spelling via spelling phonetic key, often with paranoid (1)
- hoed — 1 pair sides, mostly cmu via vault phonetic_class, often with rollout (1)
- snapback — 1 pair sides, mostly spelling via spelling phonetic key, often with rapped (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| YG | Dangerous | 34 | 39 | 254 | loose |
| YG | I Be On | 52 | 29 | 237 | loose |
| YG | MALIBU | 56 | 49 | 375 | loose |
| YG | Run | 67 | 90 | 369 | loose |
| YG | YNS | 48 | 60 | 185 | loose |
