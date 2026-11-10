# Icewear Vezzo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Icewear Vezzo
- Songs: 3
- Bars kept (Icewear Vezzo lyric lines): 204
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Icewear Vezzo.
- Credit strings: Icewear Vezzo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1476
- REPEAT pairs, recorded separately: 180
- END rhymes: 294
- INNER rhymes: 1182

By match:

- PERFECT: 127 (END 38, INNER 89)
- SLANT: 718 (END 158, INNER 560)
- ASSONANCE: 619 (END 93, INNER 526)
- MULTI: 12 (END 5, INNER 7)

By confidence:

- HIGH: 129
- MED: 1250
- LOW: 97

## Core

- Core Y: 1448
- Core N among rhyme pairs: 28

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 766 (51.9%)
- vowel: 619 (41.9%)
- spelling: 79 (5.4%)
- multi: 12 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 95 pairs (END 22, INNER 73). Words: ain't, came, way, laces, fakin, cases, take, range.
2. `vow:IH` — 78 pairs (END 17, INNER 61). Words: bitch, shit, fifty, bricks, mill, trippin, pics, think.
3. `vow:EH` — 71 pairs (END 14, INNER 57). Words: spent, heavy, twenty, went, tech, where, essex, trenches.
4. `vow:AH` — 67 pairs (END 1, INNER 66). Words: coming, hundred, couple, fuck, done, another, fucked, fuckin.
5. `vow:OW` — 67 pairs (END 1, INNER 66). Words: know, no, don't, dope, both, show, ho, throw.
6. `vow:AE` — 66 pairs (END 17, INNER 49). Words: faster, damaged, cash, havin, can't, mansions, taxes, ratchet.
7. `vow:AY` — 50 pairs (END 13, INNER 37). Words: like, times, i’ll, jivin, findin, mine, why, blindin.
8. `vow:IY` — 49 pairs (END 1, INNER 48). Words: demons, see, three, even, reason, real, cheese, ap.
9. `slant:AH:nas-stop` — 45 pairs (END 1, INNER 44). Words: fuck, done, come, truck, blood, what, none, fun.
10. `slant:IH:sib-stop` — 45 pairs (END 20, INNER 25). Words: bitch, shit, stick, rich, kid, switch, hitters, tris.
11. `slant:AH:nas` — 44 pairs (END 0, INNER 44). Words: come, done, coming, fuckin, one, money, running, run.
12. `slant:IH:stop` — 41 pairs (END 7, INNER 34). Words: shit, nigga, blick, sick, stick, city, kid, big.
13. `slant:AE:stop` — 40 pairs (END 0, INNER 40). Words: cat, 'cat, bladder, back, pack, cap, rapper, faster.
14. `slant:EH:stop` — 37 pairs (END 18, INNER 19). Words: check, yet, set, spent, tech, neck, ready, respect.
15. `vow:AA` — 33 pairs (END 0, INNER 33). Words: bought, nothin, got, dropped, rockin, want, pockets, pops.
16. `slant:AA:stop` — 31 pairs (END 1, INNER 30). Words: got, block, bought, gotta, drop, top, body, stop.
17. `slant:EY:sib-stop` — 24 pairs (END 12, INNER 12). Words: crazy, embrace, face, chase, faced, lady, made, baby.
18. `slant:EY:stop` — 21 pairs (END 6, INNER 15). Words: ain't, straight, haiti, state, take, baby, eighty, mcgrady.
19. `slant:EH:sib-stop` — 17 pairs (END 8, INNER 9). Words: prezi, sex, check, flex, tech, effect, neck, text.
20. `cmu:OW` — 15 pairs (END 0, INNER 15). Words: know, no, go, hoe, bro, show, ho, o.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 14 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- pics — 10 pair sides, mostly vowel via spelling phonetic key, often with six (1)
- tris — 8 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- jit — 7 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- essy — 7 pair sides, mostly spelling via spelling phonetic key, often with tesly (1)
- bezzy — 7 pair sides, mostly spelling via spelling phonetic key, often with presi (1)
- prezi — 6 pair sides, mostly spelling via spelling phonetic key, often with heavy (1)
- tesly — 6 pair sides, mostly spelling via spelling phonetic key, often with essy (1)
- presi — 6 pair sides, mostly spelling via spelling phonetic key, often with check (1)
- loc — 5 pair sides, mostly spelling via spelling phonetic key, often with dope (2)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with hits (1)
- slimin — 4 pair sides, mostly vowel via spelling phonetic key, often with bitch (1)
- wocky — 3 pair sides, mostly vowel via spelling phonetic key, often with quay (1)
- bossin — 3 pair sides, mostly spelling via spelling phonetic key, often with fuckin (1)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with cheese (1)
- fevzi — 3 pair sides, mostly spelling via spelling phonetic key, often with bezzy (1)
- merch — 3 pair sides, mostly vowel via spelling phonetic key, often with percs (1)
- herbo — 2 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with lil (1)
- opps — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- demonin — 2 pair sides, mostly spelling via spelling phonetic key, often with fuckin (1)
- youngin — 1 pair sides, mostly spelling via spelling phonetic key, often with fuckin (1)
- antt — 1 pair sides, mostly vowel via spelling phonetic key, often with track (1)
- maybach — 1 pair sides, mostly spelling via spelling phonetic key, often with baby (1)
- fetti — 1 pair sides, mostly spelling via spelling phonetic key, often with let (1)
- zaza — 1 pair sides, mostly spelling via spelling phonetic key, often with man (1)
- forgiato — 1 pair sides, mostly vowel via spelling phonetic key, often with throw (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Icewear Vezzo | How I’m Coming (Remix) | 101 | 122 | 549 | loose |
| Icewear Vezzo | It’s All on U | 61 | 139 | 296 | loose |
| Icewear Vezzo | Play For Keeps | 42 | 33 | 337 | loose |
