# Trae tha Truth rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Trae tha Truth
- Songs: 2
- Bars kept (Trae tha Truth lyric lines): 188
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 4
- Canonical name: Trae tha Truth.
- Credit strings: Trae tha Truth.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1124
- REPEAT pairs, recorded separately: 155
- END rhymes: 173
- INNER rhymes: 951

By match:

- PERFECT: 91 (END 26, INNER 65)
- SLANT: 518 (END 79, INNER 439)
- ASSONANCE: 506 (END 68, INNER 438)
- MULTI: 9 (END 0, INNER 9)

By confidence:

- HIGH: 98
- MED: 985
- LOW: 41

## Core

- Core Y: 1117
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 572 (50.9%)
- vowel: 506 (45.0%)
- spelling: 37 (3.3%)
- multi: 9 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 116 pairs (END 24, INNER 92). Words: ain't, say, game, way, same, play, mason, name.
2. `vow:EH` — 109 pairs (END 9, INNER 100). Words: never, treble, devil, when, trends, temperature, somewhere, section.
3. `vow:AY` — 76 pairs (END 18, INNER 58). Words: like, by, diamonds, time, kind, lines, lie, right.
4. `vow:IH` — 65 pairs (END 2, INNER 63). Words: think, kitchen, checklist, still, hit, list, shit, bitches.
5. `slant:EH:stop` — 33 pairs (END 2, INNER 31). Words: get, better, check, set, slept, stepped, best, crept.
6. `vow:OW` — 31 pairs (END 0, INNER 31). Words: don't, know, soldier, dope, supposed, load, no, broker.
7. `slant:IH:stop` — 30 pairs (END 3, INNER 27). Words: nigga, wit, hit, shit, sip, split, bigger, big.
8. `vow:AH` — 28 pairs (END 2, INNER 26). Words: what's, what, something, double, fucked, other, trust, strugglin.
9. `vow:AA` — 25 pairs (END 5, INNER 20). Words: box, solid, not, hard, bought, got, soft, wanna.
10. `slant:EH:fric-stop` — 22 pairs (END 0, INNER 22). Words: never, get, every, said, let, def, f, whenever.
11. `slant:EY:nas-stop` — 22 pairs (END 3, INNER 19). Words: same, make, layin, eight, chain, name, hater, late.
12. `slant:IH:sib-stop` — 19 pairs (END 5, INNER 14). Words: bitch, nigga, niggas, hit, switch, kiss, sip, split.
13. `slant:EH:nas-stop` — 18 pairs (END 0, INNER 18). Words: when, let, get, bet, better, said, em, represent.
14. `slant:AA:stop` — 17 pairs (END 4, INNER 13). Words: got, block, not, stop, top, soft, bought, party.
15. `slant:UW:sib-stop` — 17 pairs (END 16, INNER 1). Words: shooters, shooter, shoot, loose, coupe.
16. `vow:IY` — 17 pairs (END 3, INNER 14). Words: see, peeves, breathe, real, needed, ski, eastside, these.
17. `slant:EH:fric-liq` — 15 pairs (END 0, INNER 15). Words: never, tell, where, ever, every, somewhere, devil, level.
18. `slant:EH:liq-stop` — 15 pairs (END 0, INNER 15). Words: get, where, tell, said, bet, spell, somewhere, better.
19. `slant:EY:sib-stop` — 13 pairs (END 2, INNER 11). Words: face, great, steak, grace, race, make, fake.
20. `slant:ER:liq-stop` — 11 pairs (END 0, INNER 11). Words: early, bird, squirrel, world, word, worried.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 19 pair sides, mostly spelling via spelling phonetic key, often with wit (5)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- def — 4 pair sides, mostly spelling via spelling phonetic key, often with better (1)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with either (2)
- trigga — 2 pair sides, mostly spelling via spelling phonetic key, often with sip (1)
- realest — 2 pair sides, mostly spelling via spelling phonetic key, often with trillest (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with road (1)
- eastside — 2 pair sides, mostly vowel via spelling phonetic key, often with peeves (1)
- sto — 2 pair sides, mostly vowel via spelling phonetic key, often with go (1)
- coronavirus — 1 pair sides, mostly spelling via spelling phonetic key, often with cyrus (1)
- trillest — 1 pair sides, mostly spelling via spelling phonetic key, often with realest (1)
- spazz — 1 pair sides, mostly spelling via spelling phonetic key, often with bass (1)
- imma — 1 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- prash — 1 pair sides, mostly spelling via spelling phonetic key, often with had (1)
- extendo — 1 pair sides, mostly vowel via spelling phonetic key, often with no (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Trae tha Truth | I’m on 4.0 | 129 | 130 | 844 | loose |
| Trae tha Truth | Shooter | 59 | 43 | 107 | loose |
