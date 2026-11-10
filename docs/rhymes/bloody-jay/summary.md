# Bloody Jay rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bloody Jay
- Songs: 3
- Bars kept (Bloody Jay lyric lines): 136
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bloody Jay.
- Credit strings: Bloody Jay.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 665
- REPEAT pairs, recorded separately: 139
- END rhymes: 88
- INNER rhymes: 577

By match:

- PERFECT: 58 (END 9, INNER 49)
- SLANT: 300 (END 28, INNER 272)
- ASSONANCE: 293 (END 49, INNER 244)
- MULTI: 14 (END 2, INNER 12)

By confidence:

- HIGH: 57
- MED: 537
- LOW: 71

## Core

- Core Y: 646
- Core N among rhyme pairs: 19

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 291 (43.8%)
- vowel: 293 (44.1%)
- spelling: 67 (10.1%)
- multi: 14 (2.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 66 pairs (END 3, INNER 63). Words: no, going, hoe, know, hoes, don't, told, boat.
2. `vow:IH` — 52 pairs (END 18, INNER 34). Words: shit, bitch, things, really, bitches, bridges, bringing, fishing.
3. `vow:EH` — 47 pairs (END 11, INNER 36). Words: left, pretend, self, help, shelf, ever, guess, else.
4. `slant:AH:stop` — 46 pairs (END 13, INNER 33). Words: fuck, what, fucked, club, cut, bloody.
5. `vow:EY` — 43 pairs (END 10, INNER 33). Words: ain't, play, greatness, make, games, playin, jay, lately.
6. `vow:AH` — 25 pairs (END 5, INNER 20). Words: fuck, love, muts, some, fuckin, nuts, drugging, fucking.
7. `cmu:OW` — 19 pairs (END 5, INNER 14). Words: no, go, hoe, know, o, blow, throw, tomorrow.
8. `slant:AH:nas-stop` — 18 pairs (END 0, INNER 18). Words: fuck, drum, some, what, fuckin, club, cut, motherfucker.
9. `vow:AA` — 17 pairs (END 0, INNER 17). Words: got, want, dogs, backyard, cause, promise, hard, otha.
10. `slant:AH:fric-stop` — 13 pairs (END 0, INNER 13). Words: love, fuck, club, above, bloody.
11. `cmu:AE-S` — 12 pairs (END 0, INNER 12). Words: niggas, brothas, ass.
12. `slant:IH:sib-stop` — 12 pairs (END 3, INNER 9). Words: niggas, nigga, shit, bitch, richer, bigger.
13. `slant:IH:stop` — 12 pairs (END 2, INNER 10). Words: nigga, shit, liquor, flipped, bigger.
14. `vow:AY` — 12 pairs (END 0, INNER 12). Words: like, die, times, wining, why, white, buy, line.
15. `vow:IY` — 11 pairs (END 0, INNER 11). Words: g, keep, these, see, probably, reason, here, feel.
16. `slant:AH:sib-stop` — 10 pairs (END 3, INNER 7). Words: another, what, motherfucker, blood, muts, nuts, motherfuckers, other.
17. `multi:OW-IH-NG` — 8 pairs (END 0, INNER 8). Words: going, showing, keep going, dawg showing, rasta blowing, blowing, growing, blowin.
18. `slant:IY:liq-stop` — 8 pairs (END 0, INNER 8). Words: keep, here, feel, real.
19. `slant:OW:nas-stop` — 8 pairs (END 0, INNER 8). Words: going, owner, don't, road, boat, gon.
20. `vow:AE` — 8 pairs (END 1, INNER 7). Words: cash, last, dances, can't, sack, bank, makin, panamera.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- niggas — 24 pair sides, mostly spelling via spelling phonetic key, often with brothas (11)
- brothas — 17 pair sides, mostly spelling via spelling phonetic key, often with niggas (11)
- nigga — 16 pair sides, mostly spelling via spelling phonetic key, often with shit (6)
- muts — 6 pair sides, mostly vowel via spelling phonetic key, often with fuck (4)
- eep — 5 pair sides, mostly spelling via spelling phonetic key, often with keep (2)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with going (2)
- imma — 4 pair sides, mostly vowel via spelling phonetic key, often with niggas (3)
- grinded — 4 pair sides, mostly cmu via vault phonetic_class, often with before (2)
- dinero — 4 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- foreva — 4 pair sides, mostly vowel via spelling phonetic key, often with brothas (4)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with these (2)
- parter — 3 pair sides, mostly spelling via spelling phonetic key, often with harder (1)
- bros — 3 pair sides, mostly spelling via spelling phonetic key, often with throwing (1)
- cuz — 3 pair sides, mostly spelling via spelling phonetic key, often with love (2)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with richer (1)
- dawg — 2 pair sides, mostly spelling via spelling phonetic key, often with gone (2)
- rasta — 2 pair sides, mostly spelling via spelling phonetic key, often with ass (2)
- dont — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- panamera — 1 pair sides, mostly vowel via spelling phonetic key, often with cash (1)
- maybach — 1 pair sides, mostly spelling via spelling phonetic key, often with greatness (1)
- tilpia — 1 pair sides, mostly spelling via spelling phonetic key, often with still (1)
- motherfucka — 1 pair sides, mostly vowel via spelling phonetic key, often with brothas (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bloody Jay | Fuck It Up | 49 | 25 | 184 | loose |
| Bloody Jay | Keep Going | 44 | 45 | 259 | loose |
| Bloody Jay | We Bros Remix | 43 | 18 | 134 | loose |
