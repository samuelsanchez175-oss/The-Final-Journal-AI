# Rhyme detector — hand-labeled ground truth comparison

**Overall across all 3 sections.** Precision **0.740**, recall **0.794**, F1 **0.766**. TP=54  FP=19  FN=14  pairs_total=145.

**Vault order caveat.** Most Gunna songs are stored alphabetically — see the top of this file for how that was discovered. The three sections below are among the ~15% that preserve song order (alphabetical-pair-rate ≤ 0.47). All order-dependent stats in gunna_rulebook.md v1-v3 are therefore measuring rhyme between alphabetically-adjacent lines for most songs, not song-adjacent. Per-line stats (commas, triplets, POV, mood, subtopics, inner-rhyme-per-line) are unaffected.

## `pushin P` — bars 3..13 (11 bars)

| bar | line (ad-libs stripped) | hand label | anchor |
| ---:| --- | :-:| --- |
| 3 | "Pointers in the Patek and my piece, I'm pushin' P" | **A** | `IY1` |
| 4 | "Copped new hammers for my P, we don't want no peace" | **A** | `IY1-S` |
| 5 | "Got a spot across the spot, just for P's" | **A** | `IY1-Z` |
| 6 | "Dropped the dot and then we plot, exotic P's" | **A** | `IY1-Z` |
| 7 | 'She not a lesbian, for P, she turn Pesbian' | **B** | `ER1-N` |
| 8 | 'Off capital P, I rock these presidents, count presidents' | **B** | `EH1-Z-AH0-D-EH2-N-T-S` |
| 9 | "Portuguese on her knees, moppin' down the P" | **A** | `IY1` |
| 10 | "She let me squeeze, then she lеave 'cause she keep it P" | **A** | `IY1` |
| 11 | "Privatе suite, private seat, bitch, I'm pushin' P" | **A** | `IY1` |
| 12 | "Purple pint, pussy pink, bitch, I'm pushin' P" | **A** | `IY1` |
| 13 | "Pushin' P, I'm pushin' P, pushin' P, I'm pushin' P" | **A** | `IY1` |

**Hand-labeled rhyme pairs:** 37  **Detector-flagged pairs:** 36  **True positives:** 36  **False positives:** 0  **False negatives:** 1
**Precision:** 1.000  **Recall:** 0.973  **F1:** 0.986

### False positives (detector says rhyme, hand says no)

### False negatives (hand says rhyme, detector says no)
- bars 7 + 8: 'She not a lesbian, for P, she turn Pesbian' / 'Off capital P, I rock these presidents, count presidents'

## `Understood` — bars 5..14 (10 bars)

| bar | line (ad-libs stripped) | hand label | anchor |
| ---:| --- | :-:| --- |
| 5 | 'I have to say , cuz this understood' | **A** | `UH1-D` |
| 6 | 'I do this shit here for the hood' | **A** | `UH1-D` |
| 7 | 'Went to the top at this shit from the foot' | **A** | `UH1-T` |
| 8 | 'Tell momma that we gonna be good' | **A** | `UH1-D` |
| 9 | 'I do this shit here for the bros' | **B** | `AO1-R-DH-AH0` |
| 10 | 'We do not do it for hoes' | **B** | `OW1-Z` |
| 11 | 'Straight out the hood and my niggas they rollin' | **C** | `AA1-L-IH0-N` |
| 12 | "Keep a strap and my niggas stay totin'" | **C** | `EY1` |
| 13 | 'These little niggas they rougeish' | **D** | `EY1` |
| 14 | 'Pull up in Phantoms no Lotus' | **D** | `OW1-T-AH0-S` |

**Hand-labeled rhyme pairs:** 9  **Detector-flagged pairs:** 8  **True positives:** 6  **False positives:** 2  **False negatives:** 3
**Precision:** 0.750  **Recall:** 0.667  **F1:** 0.706

### False positives (detector says rhyme, hand says no)
- bars 10 + 14 (assonance): 'We do not do it for hoes' / 'Pull up in Phantoms no Lotus'
- bars 12 + 13 (exact): "Keep a strap and my niggas stay totin'" / 'These little niggas they rougeish'

### False negatives (hand says rhyme, detector says no)
- bars 9 + 10: 'I do this shit here for the bros' / 'We do not do it for hoes'
- bars 11 + 12: 'Straight out the hood and my niggas they rollin' / "Keep a strap and my niggas stay totin'"
- bars 13 + 14: 'These little niggas they rougeish' / 'Pull up in Phantoms no Lotus'

## `Floyd Mayweather` — bars 5..14 (10 bars)

| bar | line (ad-libs stripped) | hand label | anchor |
| ---:| --- | :-:| --- |
| 5 | 'I got six brand new foreigns on my wrist, ah' | **A** | `AA1` |
| 6 | 'I got six Forgiatos on my fist' | **A** | `IH1-S-T` |
| 7 | 'I got fifty foreign hoes on my dick' | **B** | `IH1-K` |
| 8 | "I'ma nut in all them hoes, let's have some chicks" | **B** | `IH1-K-S` |
| 9 | 'Nigga tried to hit a lick and missed' | **A** | `IH1-S-T` |
| 10 | 'Tried to run then I caught him like a fish' | **A** | `IH1-SH` |
| 11 | "I'ma catch his ass with the whole clip" | **C** | `IH1-P` |
| 12 | "I'ma beat they ass up like Ron Artest" | **A** | `AA1-N` |
| 13 | 'Pussy nigga ran like a Miss' | **A** | `IH1-S` |
| 14 | 'I got your bitch up underwater tryna kiss' | **A** | `IH1-S` |

**Hand-labeled rhyme pairs:** 22  **Detector-flagged pairs:** 29  **True positives:** 12  **False positives:** 17  **False negatives:** 10
**Precision:** 0.414  **Recall:** 0.545  **F1:** 0.471

### False positives (detector says rhyme, hand says no)
- bars 6 + 7 (assonance): 'I got six Forgiatos on my fist' / 'I got fifty foreign hoes on my dick'
- bars 6 + 8 (assonance): 'I got six Forgiatos on my fist' / "I'ma nut in all them hoes, let's have some chicks"
- bars 6 + 11 (assonance): 'I got six Forgiatos on my fist' / "I'ma catch his ass with the whole clip"
- bars 7 + 9 (assonance): 'I got fifty foreign hoes on my dick' / 'Nigga tried to hit a lick and missed'
- bars 7 + 10 (assonance): 'I got fifty foreign hoes on my dick' / 'Tried to run then I caught him like a fish'
- bars 7 + 11 (slant): 'I got fifty foreign hoes on my dick' / "I'ma catch his ass with the whole clip"
- bars 7 + 13 (assonance): 'I got fifty foreign hoes on my dick' / 'Pussy nigga ran like a Miss'
- bars 7 + 14 (assonance): 'I got fifty foreign hoes on my dick' / 'I got your bitch up underwater tryna kiss'
- bars 8 + 9 (assonance): "I'ma nut in all them hoes, let's have some chicks" / 'Nigga tried to hit a lick and missed'
- bars 8 + 10 (assonance): "I'ma nut in all them hoes, let's have some chicks" / 'Tried to run then I caught him like a fish'
- bars 8 + 11 (assonance): "I'ma nut in all them hoes, let's have some chicks" / "I'ma catch his ass with the whole clip"
- bars 8 + 13 (assonance): "I'ma nut in all them hoes, let's have some chicks" / 'Pussy nigga ran like a Miss'
- bars 8 + 14 (assonance): "I'ma nut in all them hoes, let's have some chicks" / 'I got your bitch up underwater tryna kiss'
- bars 9 + 11 (assonance): 'Nigga tried to hit a lick and missed' / "I'ma catch his ass with the whole clip"
- bars 10 + 11 (assonance): 'Tried to run then I caught him like a fish' / "I'ma catch his ass with the whole clip"
- bars 11 + 13 (assonance): "I'ma catch his ass with the whole clip" / 'Pussy nigga ran like a Miss'
- bars 11 + 14 (assonance): "I'ma catch his ass with the whole clip" / 'I got your bitch up underwater tryna kiss'

### False negatives (hand says rhyme, detector says no)
- bars 5 + 6: 'I got six brand new foreigns on my wrist, ah' / 'I got six Forgiatos on my fist'
- bars 5 + 9: 'I got six brand new foreigns on my wrist, ah' / 'Nigga tried to hit a lick and missed'
- bars 5 + 10: 'I got six brand new foreigns on my wrist, ah' / 'Tried to run then I caught him like a fish'
- bars 5 + 13: 'I got six brand new foreigns on my wrist, ah' / 'Pussy nigga ran like a Miss'
- bars 5 + 14: 'I got six brand new foreigns on my wrist, ah' / 'I got your bitch up underwater tryna kiss'
- bars 6 + 12: 'I got six Forgiatos on my fist' / "I'ma beat they ass up like Ron Artest"
- bars 9 + 12: 'Nigga tried to hit a lick and missed' / "I'ma beat they ass up like Ron Artest"
- bars 10 + 12: 'Tried to run then I caught him like a fish' / "I'ma beat they ass up like Ron Artest"
- bars 12 + 13: "I'ma beat they ass up like Ron Artest" / 'Pussy nigga ran like a Miss'
- bars 12 + 14: "I'ma beat they ass up like Ron Artest" / 'I got your bitch up underwater tryna kiss'

---

## 4-bar window — any 2+ bars share anchor vowel

Fraction of 4-bar windows (sliding across song-order rowid) where at least two bars share their anchor vowel: **0.8836** (6521/7380 blocks).

Caveat: for most songs the vault order is alphabetical, so this stat includes both real song-order windows and alphabetical windows. The real-song-order rate is probably higher; we can't separate them without an external song-order source.
