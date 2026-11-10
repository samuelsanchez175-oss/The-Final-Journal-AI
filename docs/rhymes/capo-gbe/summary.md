# Capo (GBE) rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Capo (GBE)
- Songs: 8
- Bars kept (Capo (GBE) lyric lines): 229
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Capo (GBE).
- Credit strings: Capo (GBE).
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1793
- REPEAT pairs, recorded separately: 273
- END rhymes: 214
- INNER rhymes: 1579

By match:

- PERFECT: 151 (END 31, INNER 120)
- SLANT: 820 (END 94, INNER 726)
- ASSONANCE: 800 (END 86, INNER 714)
- MULTI: 22 (END 3, INNER 19)

By confidence:

- HIGH: 150
- MED: 1526
- LOW: 117

## Core

- Core Y: 1778
- Core N among rhyme pairs: 15

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 848 (47.3%)
- vowel: 800 (44.6%)
- spelling: 123 (6.9%)
- multi: 22 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 8 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 149 pairs (END 12, INNER 137). Words: gang, can't, macs, savage, hammers, happened, ass, ratchet.
2. `vow:EY` — 127 pairs (END 31, INNER 96). Words: ain't, stay, famous, hate, play, baby, ain’t, take.
3. `slant:AA:stop` — 106 pairs (END 0, INNER 106). Words: got, block, top, gotta, squad, cocked, lot, capo.
4. `vow:AA` — 106 pairs (END 20, INNER 86). Words: shots, got, block, watch, want, nothin, monsters, box.
5. `vow:OW` — 88 pairs (END 7, INNER 81). Words: don't, know, no, kobe, own, over, dozin, hoes.
6. `vow:IH` — 85 pairs (END 1, INNER 84). Words: shit, since, think, bitch, dissin, pistol, ringin, bitches.
7. `vow:AY` — 56 pairs (END 4, INNER 52). Words: why, life, right, stripes, by, like, pipes, try.
8. `slant:IH:stop` — 53 pairs (END 19, INNER 34). Words: sick, shit, clip, sit, nigga, flipped, whip, slick.
9. `vow:AH` — 50 pairs (END 0, INNER 50). Words: money, fuck, trust, what, drugs, fuckin, nothing, guns.
10. `vow:EH` — 47 pairs (END 0, INNER 47). Words: when, gettin, remember, flexin, never, protect, weapons, get.
11. `slant:IH:sib-stop` — 40 pairs (END 7, INNER 33). Words: niggas, nigga, bitch, shit, whips, hit, sick, flip.
12. `vow:IY` — 40 pairs (END 6, INNER 34). Words: streets, see, these, g, keep, here, weed, sleep.
13. `slant:AH:nas-stop` — 39 pairs (END 1, INNER 38). Words: money, fuck, one, what, guap, some, club, run.
14. `slant:AA:sib-stop` — 35 pairs (END 8, INNER 27). Words: watch, block, box, roc, shots, not, got, top.
15. `cmu:OW` — 28 pairs (END 4, INNER 24). Words: know, no, glo, o, pro, bro, blow, low.
16. `vow:UW` — 25 pairs (END 5, INNER 20). Words: shootin, ruthless, rulers, used, lugers, who, shooters, rooster.
17. `slant:EH:nas-stop` — 24 pairs (END 0, INNER 24). Words: get, when, gettin, let, men, send, step, better.
18. `slant:AE:stop` — 22 pairs (END 5, INNER 17). Words: act, cap, sack, bad, hand, matter, mad, rapper.
19. `slant:AE:nas-sib` — 20 pairs (END 0, INNER 20). Words: gang, ass, man, rather, thangs, whatchu, can, thang.
20. `slant:AE:sib-stop` — 20 pairs (END 0, INNER 20). Words: racks, catch, ass, sack, act, mac's, clack, had.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 27 pair sides, mostly spelling via spelling phonetic key, often with niggas (17)
- niggas — 24 pair sides, mostly spelling via spelling phonetic key, often with nigga (17)
- guap — 16 pair sides, mostly spelling via spelling phonetic key, often with one (3)
- ima — 8 pair sides, mostly spelling via spelling phonetic key, often with thing (1)
- tryna — 7 pair sides, mostly spelling via spelling phonetic key, often with these (2)
- gon — 7 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- rugers — 6 pair sides, mostly spelling via spelling phonetic key, often with rulers (2)
- trues — 6 pair sides, mostly spelling via spelling phonetic key, often with money (3)
- thangs — 5 pair sides, mostly spelling via spelling phonetic key, often with gang (2)
- snitches — 5 pair sides, mostly spelling via spelling phonetic key, often with bitches (2)
- whatchu — 4 pair sides, mostly spelling via spelling phonetic key, often with gang (2)
- opps — 4 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- bruh — 4 pair sides, mostly spelling via spelling phonetic key, often with another (1)
- blam — 3 pair sides, mostly vowel via vault phonetic_class, often with attitude (1)
- guaped — 3 pair sides, mostly spelling via vault phonetic_class, often with guap (2)
- oblock — 3 pair sides, mostly vowel via spelling phonetic key, often with block (1)
- imposters — 3 pair sides, mostly spelling via spelling phonetic key, often with roasters (1)
- gots — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- watin — 2 pair sides, mostly spelling via spelling phonetic key, often with man (1)
- imma — 2 pair sides, mostly vowel via spelling phonetic key, often with niggas (2)
- bronem — 2 pair sides, mostly spelling via spelling phonetic key, often with gon (1)
- finessin — 1 pair sides, mostly spelling via spelling phonetic key, often with nothin (1)
- ninas — 1 pair sides, mostly spelling via spelling phonetic key, often with diss (1)
- glocks — 1 pair sides, mostly spelling via spelling phonetic key, often with rocks (1)
- iont — 1 pair sides, mostly spelling via spelling phonetic key, often with hit (1)
- treet — 1 pair sides, mostly spelling via spelling phonetic key, often with these (1)
- hunnid — 1 pair sides, mostly spelling via spelling phonetic key, often with front (1)
- finna — 1 pair sides, mostly spelling via spelling phonetic key, often with bring (1)
- stuntin — 1 pair sides, mostly spelling via spelling phonetic key, often with nothin (1)
- shitll — 1 pair sides, mostly vowel via spelling phonetic key, often with shit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Capo (GBE) | Bein Famous | 33 | 38 | 285 | loose |
| Capo (GBE) | Forced To Shooting | 29 | 21 | 150 | loose |
| Capo (GBE) | G.L.O.N.L. Part 2 | 8 | 7 | 49 | loose |
| Capo (GBE) | Glo Gang Mafia | 25 | 18 | 137 | loose |
| Capo (GBE) | Hate Me | 30 | 13 | 133 | loose |
| Capo (GBE) | I’m Sick | 25 | 22 | 80 | loose |
| Capo (GBE) | Squad | 37 | 42 | 243 | loose |
| Capo (GBE) | Watchu Get | 42 | 53 | 502 | loose |
