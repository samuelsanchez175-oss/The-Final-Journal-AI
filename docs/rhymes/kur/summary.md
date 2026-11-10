# Kur rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Kur
- Songs: 1
- Bars kept (Kur lyric lines): 59
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Kur.
- Credit strings: Kur.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 796
- REPEAT pairs, recorded separately: 42
- END rhymes: 105
- INNER rhymes: 691

By match:

- PERFECT: 60 (END 18, INNER 42)
- SLANT: 335 (END 50, INNER 285)
- ASSONANCE: 395 (END 36, INNER 359)
- MULTI: 6 (END 1, INNER 5)

By confidence:

- HIGH: 55
- MED: 722
- LOW: 19

## Core

- Core Y: 793
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 368 (46.2%)
- vowel: 395 (49.6%)
- spelling: 27 (3.4%)
- multi: 6 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 88 pairs (END 5, INNER 83). Words: giving, bitches, listen, big, wrist, difference, bitch, shit.
2. `vow:AH` — 78 pairs (END 31, INNER 47). Words: trust, something, lungs, come, funds, fronting, nothing, run.
3. `vow:OW` — 61 pairs (END 0, INNER 61). Words: told, don't, go, know, roll, home, smoke, slow.
4. `vow:EH` — 58 pairs (END 0, INNER 58). Words: getting, remember, heaven, stressing, text, never, end, get.
5. `vow:AA` — 37 pairs (END 0, INNER 37). Words: started, watching, wanna, charging, want, bar, target, shocked.
6. `slant:EH:nas-stop` — 31 pairs (END 0, INNER 31). Words: when, get, let, getting, end, better, head, went.
7. `slant:IH:stop` — 23 pairs (END 8, INNER 15). Words: shit, quick, hit, big, dick, built, whip, fit.
8. `slant:IH:liq-stop` — 19 pairs (END 0, INNER 19). Words: lil, shit, kill, still, big, built, killed, quit.
9. `cmu:UH-D` — 18 pairs (END 14, INNER 4). Words: could, would, hood, wood, good, misunderstood.
10. `vow:IY` — 17 pairs (END 0, INNER 17). Words: these, eating, nobody, peeking, keep, deep, sleeping, teaching.
11. `slant:AH:nas` — 14 pairs (END 2, INNER 12). Words: one, money, come, run, some, funny, ducking, nothing.
12. `slant:EH:stop` — 14 pairs (END 0, INNER 14). Words: get, head, better, let, went, west, already, end.
13. `slant:AA:stop` — 13 pairs (END 0, INNER 13). Words: shocked, spot, got, stop, start, drop, want, party.
14. `slant:EH:fric-stop` — 12 pairs (END 0, INNER 12). Words: never, get, let, whenever, every, better, head, said.
15. `slant:IH:sib-stop` — 12 pairs (END 9, INNER 3). Words: bitch, rich, big, whip, quick, hit, fit, shit.
16. `vow:AY` — 12 pairs (END 0, INNER 12). Words: swiping, like, times, minding, buying, might, grinding, finally.
17. `slant:AH:nas-sib` — 11 pairs (END 2, INNER 9). Words: plus, judge, some, one, much, touching, come, money.
18. `slant:UH:stop` — 11 pairs (END 0, INNER 11). Words: good, hooked, would, look, took, put, hook.
19. `slant:EH:nas-sib` — 10 pairs (END 0, INNER 10). Words: when, hese, s, m, death, yes.
20. `slant:AH:sib` — 9 pairs (END 8, INNER 1). Words: dubs, buzz, hugs, drugs, bus, brothers, judge, much.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 7 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- hese — 6 pair sides, mostly spelling via spelling phonetic key, often with when (3)
- luxe — 3 pair sides, mostly vowel via spelling phonetic key, often with bus (1)
- trizzy — 2 pair sides, mostly spelling via spelling phonetic key, often with business (1)
- slackin — 1 pair sides, mostly spelling via spelling phonetic key, often with shadreno (1)
- shadreno — 1 pair sides, mostly spelling via spelling phonetic key, often with slackin (1)
- tryn — 1 pair sides, mostly spelling via spelling phonetic key, often with feel (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with between (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Kur | HUMBUG | 59 | 105 | 691 | loose |
