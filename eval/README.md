# eval/ — Model G Authenticity Grading

Offline harness that scores generated verses against the real Gunna/Young-Thug ground-truth
corpus, so "is Model G getting better?" becomes a **number** instead of a vibe. Full design:
`OB CLAUDE vault/XJournal AI - App/Ground Truth & Grading System.md`.

## Quick start
```bash
python3 eval/grade_modelg.py --demo            # score the bundled sample verse
python3 eval/grade_modelg.py --verse my.txt    # score your own (one bar per line)
python3 eval/grade_modelg.py --corpus-stats    # just the corpus baseline
python3 eval/grade_modelg.py --verse my.txt --log --version-label "modelg-v2"
python3 eval/grade_modelg.py --compare v2.txt v3.txt   # side-by-side table (e.g. v2 vs v3)
```
No dependencies (Python 3.9+). Reads `XJournal AI/ground_truth_rap_bars_MODEL_G.csv`
and `XJournal AI/cmudict.txt` directly.

## What it measures (full 7-axis rubric)
| Axis | Wt | Meaning | Method | Reliable? |
|---|---|---|---|---|
| **A1 Cadence** | .20 | syllables/bar vs. corpus | CMUDICT count vs. corpus mean±std | ✅ |
| **A2 Rhyme density** | .20 | end-rhyme rate | slant-aware, 2-line window, vs. 0.50 | ⚠️ crude |
| **A3 Rhyme quality** | .15 | internal + multisyllabic depth | windowed rime density vs. corpus (multisyllabic-weighted) | ❌ see below |
| **A4 Flow/stress** | .15 | stress density + consistency | CMUDICT stress digits vs. corpus ~0.72 | ⚠️ heuristic |
| **A5 Tone** | .10 | corpus-dominant register | confident/luxurious tone-word density | ⚠️ heuristic |
| **A6 Lexical authenticity** | .10 | authentic jargon, no overuse | distinct v8-lexicon terms, minus overuse | ✅ |
| **A7 Originality** | .10 | style match w/o copying | verbatim-line + 4-gram overlap penalty | ✅ |

**Authenticity Score** = weighted sum (renormalised). **Trust A1 / A2 / A6 / A7.**

> ⚠️ **Rhyme is the grader's weak point.** A2/A3 use CMUDICT-*exact* rime matching, which (a) undercounts
> the multisyllabic/slant rhyme that defines Gunna/Thug (corpus internal density measures only ~0.02), and
> (b) is gamed by accidental rime collisions — the deliberately-bad `weak_verse.txt` scores **A3 ≈ 91**.
> **Reliable rhyme grading needs the app's `RhymeClusterEngine`, not CMUDICT-exact.** Read A3 as indicative only.

## Baseline numbers (2026-05-30)
Corpus: 9,430 bars · syllables/bar **mean 9.7, std 4.2** (829 out-of-range rows dropped) ·
top tones: confident, luxurious, aggressive.

| Verse | A1 | A2 | A3 | A4 | A5 | A6 | A7 | Score |
|---|---|---|---|---|---|---|---|---|
| `sample_verse.txt` (clean but generic) | 92.5 | 85.7 | 35.0 | 84.8 | 72.4 | 0.0 | 100 | **70.8 (C)** |
| `weak_verse.txt` (off-cadence, rambling) | 18.4 | 28.6 | 90.9 | 81.6 | 0.0 | 0.0 | 30 | **38.3 (D)** |

The reliable axes (A1/A2/A6/A7) separate them cleanly. Note the weak verse's **A3 = 90.9** — proof the
CMUDICT-exact rhyme metric is gameable (see the ⚠️ above); the score still ranks them correctly because
A3's weight is bounded and the trustworthy axes dominate.

## Comparing pipelines (v2 vs v3)
The grader scores verse *text* — it can't call the app/OpenAI. To compare Model G versions for real:
1. In the app: Settings → Model G v3 tab → toggle the version you want, generate from a **fixed** entry, copy the verse.
2. Save each as a file, one bar per line: `eval/v2.txt`, `eval/v3.txt` (hook can be the first line).
3. `python3 eval/grade_modelg.py --compare eval/v2.txt eval/v3.txt`

Use the SAME journal entry for both so only the pipeline differs. (A reusable golden prompt set is the G2 step.)

## Two findings baked in
1. **Corpus `syllable_count` has extreme outliers** (raw std ≈ 8.9). We clip to 3–20 syllables
   (mirrors the app's 8…18 clamp) so cadence tolerance stays meaningful.
2. **End-word rhyme rate of the corpus is only ~0.12** — because Gunna/Thug rhyme is largely
   **internal & multisyllabic**, which last-word matching misses. So A2 scores against a fixed
   "clearly-rhyming" target (0.50) for now; **G1 must add real multisyllabic/internal rhyme**
   (the `RhymeClusterEngine` work) to get a true rhyme baseline.

## Roadmap
- **G0 (done):** A1 + A2 + A7, corpus baseline, CLI, logging.
- **G1 (done):** full 7-axis rubric — A3 rhyme-quality + A4 flow/stress (both **corpus-grounded**),
  A5 tone, A6 lexical, and `--compare`. **Finding:** CMUDICT-exact rhyme (A2/A3) is the weak point
  (undercounts + gameable). **Next real step: replace A3 with the app's `RhymeClusterEngine`** for true
  multisyllabic/slant rhyme; then the **voice-theory axes** (A8–A10) below via `SignalIngest`.
- **G2:** golden prompt set (`eval/golden_prompts.json`) + one-command run over v1/v2/v3 → trend in `grading_log.csv`.
- **G3:** surface the score in-app (dev flag) and use it to auto-pick the best of N verses
  (replacing the weak `ScoringEngine` selection).

### Voice-theory axes (G1+) — reuse code you already wrote
Your `SignalAxes` / `SignalIngest` already compute exposure, social action, register, audience.
Grade generated verses with the SAME engine:
- **A8 Social-action coverage** — % of bars performing a `SocialAction` (warn/flex/distance/…) vs. filler.
- **A9 Exposure discipline** — penalise over-explanation (your `hasHighExplanation` = the "AI tell")
  and literal confession; reward implicature. Uses `calculateExposureRisk`.
- **A10 Register consistency** — does the verse hold one `AuthorityPosture`/`AudienceScope`?

See `OB CLAUDE vault/XJournal AI - App/Voice & Signal Theory.md`.

## Files
- `grade_modelg.py` — the grader
- `sample_verse.txt` / `weak_verse.txt` — demo inputs
- `grading_log.csv` — appended results (created on `--log`)
