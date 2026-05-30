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

## What it measures (6 of 7 rubric axes; A4 flow still pending)
| Axis | Meaning | Method |
|---|---|---|
| **A1 Cadence** | syllables/bar vs. corpus | CMUDICT syllable count vs. corpus mean±std |
| **A2 Rhyme density** | end-rhyme rate | slant-aware, 2-line window, vs. a 0.50 target |
| **A3 Rhyme quality** | internal + multisyllabic depth | nearby word-pair rime matches + multisyllabic bonus |
| **A5 Tone** | corpus-dominant register | density of confident/luxurious tone words (heuristic) |
| **A6 Lexical authenticity** | authentic jargon, no overuse | distinct v8-lexicon terms present, minus overuse |
| **A7 Originality** | style match w/o copying | verbatim-line + 4-gram overlap penalty |

Reports each axis 0–100 plus a **partial Authenticity Score** (weights A1·.20 A2·.20 A3·.15 A5·.10 A6·.10 A7·.10, renormalised).

## Baseline numbers (2026-05-30)
Corpus: 9,430 bars · syllables/bar **mean 9.7, std 4.2** (829 out-of-range rows dropped) ·
top tones: confident, luxurious, aggressive.

| Verse | A1 | A2 | A3 | A5 | A6 | A7 | Partial |
|---|---|---|---|---|---|---|---|
| `sample_verse.txt` (clean but generic) | 92.5 | 85.7 | 17.0 | 72.4 | 0.0 | 100 | **65.2 (D)** |
| `weak_verse.txt` (off-cadence, no rhyme, copied line) | 18.4 | 28.6 | 21.1 | 0.0 | 0.0 | 30 | **18.3 (D)** |

Once rhyme-depth (A3) and authentic-vocab (A6) are measured, even the "clean" sample is exposed as
generic (A6=0) and shallow-rhyming (A3=17) — the gap theme-aware + v3 generation should close.

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
- **G1 (done):** A3 rhyme-quality (internal + multisyllabic, heuristic), A5 tone, A6 lexical
  authenticity, and `--compare`. Still TODO: corpus-ground A3 with real `RhymeClusterEngine` rimes,
  A4 flow/stress, and the **voice-theory axes** below. Lock weights.
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
