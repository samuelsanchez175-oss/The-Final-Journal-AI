# Base LLM Fine-Tune Runbook

End-to-end: 4 OpenAI jobs → register winners → smoke test the catalog + fine-tune
marriage → promote to v5. Your 4 bash commands are the only step that spends money.

## State of play

| Thread | Branch | What shipped | What's blocked |
|---|---|---|---|
| Grok #1 | `grok/base-llm-dataset-size` | `train.sh` (50k + full), `build_dataset.py`, `evaluate.py` (D4), tests | D5 verdict — no job run |
| Grok #2 | `grok/base-llm-voice-conditioning` | `train_voice_a.sh`, `train_voice_b.sh`, `voice_evaluate.py` (V5), `voice_register.py`, tests | V6 verdict — no job run |
| Grok #3 | `grok/base-llm-combined-production` | Docs noting both C1 gates open | Everything downstream of winners |

Already written by this session (shared, lives in `base_train/`):

- `model_registry.json` — the shared registry (empty `models`)
- `base_train/register_model.py` — generic registry writer: add, mark-winner, list, winners
- `base_train/smoke_catalog_generator.py` — catalog → fine-tune one-shot test
- `llm_client.py` — now auto-loads registry aliases + accepts `ft:` model IDs

## Step 1 — Launch the 4 fine-tune jobs (yours, ~$140 total)

Prereqs:
- `.env.openai` at repo root, chmod 600, gitignored.
- venv activated (`source tools/lyric-llm/.venv/bin/activate`); the venv ships
  an `openai` shim at `.venv/bin/openai` because OpenAI killed the real CLI in
  python-openai>=2.x. Bootstrap if missing:
  ```bash
  cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/lyric-llm"
  ln -sf "$(pwd)/base_train/openai_cli_shim.py" .venv/bin/openai
  chmod +x base_train/openai_cli_shim.py
  ```
- `jq` on PATH (preinstalled on macOS at `/usr/bin/jq`).

```bash
# Voice jobs (current branch has train_voice_*.sh)
cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/lyric-llm"
bash base_train/train_voice_a.sh
bash base_train/train_voice_b.sh

# Dataset jobs — switch branches (voice is here; dataset lives on grok/base-llm-dataset-size)
cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync"
git stash -u    # safely park your dirty tree
git checkout grok/base-llm-dataset-size
cd tools/lyric-llm
bash base_train/train.sh 50k
bash base_train/train.sh full

# Return
cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync"
git checkout grok/base-llm-voice-conditioning
git stash pop
```

Each `train.sh` logs job id + model id to `out/finetune_*_log.jsonl`. OpenAI
side runs 30 min – 2 h per job; 4 jobs can queue in parallel.

## Step 2 — When OpenAI shows all 4 jobs `succeeded`

Collect model IDs from `out/finetune_*_log.jsonl` or the OpenAI dashboard.
Expected shape: `ft:gpt-4o-mini:pennworkstudios:<suffix>:<id>`.

### 2a. Register each model as a candidate

```bash
cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/lyric-llm"

# Grok #1: dataset_size
python3 base_train/register_model.py add \
    --trained-by grok#1 --alias v5-base-mini-50k \
    --experiment dataset_size --variant 50k_sample \
    --openai-id "ft:gpt-4o-mini:pennworkstudios:v5-base-mini-50k:XXX" \
    --job-id "ftjob-XXX" \
    --training-file out/train_50k_fim.jsonl \
    --validation-file out/val_50k_fim.jsonl \
    --n-examples 50000 --fim-share 0.2

python3 base_train/register_model.py add \
    --trained-by grok#1 --alias v5-base-mini-full \
    --experiment dataset_size --variant full \
    --openai-id "ft:gpt-4o-mini:pennworkstudios:v5-base-mini-full:XXX" \
    --job-id "ftjob-XXX" \
    --training-file out/train_full_fim.jsonl \
    --validation-file out/val_full_fim.jsonl \
    --n-examples 167014 --fim-share 0.2

# Grok #2: voice_conditioning
python3 base_train/register_model.py add \
    --trained-by grok#2 --alias v5-base-mini-one-hot \
    --experiment voice_conditioning --variant one_hot \
    --openai-id "ft:gpt-4o-mini:pennworkstudios:v5-base-voice-a:XXX" \
    --job-id "ftjob-XXX" \
    --training-file out/train_voice_a.jsonl \
    --validation-file out/val_voice_a.jsonl \
    --n-examples 50000 --fim-share 0.2

python3 base_train/register_model.py add \
    --trained-by grok#2 --alias v5-base-mini-systembrief \
    --experiment voice_conditioning --variant systembrief \
    --openai-id "ft:gpt-4o-mini:pennworkstudios:v5-base-voice-b:XXX" \
    --job-id "ftjob-XXX" \
    --training-file out/train_voice_b.jsonl \
    --validation-file out/val_voice_b.jsonl \
    --n-examples 50000 --fim-share 0.2

python3 base_train/register_model.py list    # 4 candidates expected
```

### 2b. Run both evals + pick winners

```bash
# Dataset A/B (Grok #1 harness)
python3 base_train/evaluate.py \
    --model-a "ft:gpt-4o-mini:pennworkstudios:v5-base-mini-50k:XXX" \
    --model-b "ft:gpt-4o-mini:pennworkstudios:v5-base-mini-full:XXX" \
    --fixture out/test_50k_fim.jsonl \
    --out out/compare_50k_vs_full.md
# Report prints "Overall: A" (50k) or "Overall: B" (full)

# Voice A/B (Grok #2 harness) — on grok/base-llm-voice-conditioning branch
python3 base_train/voice_evaluate.py \
    --model-a "ft:gpt-4o-mini:pennworkstudios:v5-base-voice-a:XXX" \
    --model-b "ft:gpt-4o-mini:pennworkstudios:v5-base-voice-b:XXX" \
    --fixture out/test_voice_a.jsonl \
    --out out/compare_voice.md
# Report prints "Overall: A" (one_hot) or "Overall: B" (systembrief)
```

### 2c. Promote the winners

Read `out/compare_*.md`, take the "Overall" line, then:

```bash
# Dataset winner (replace alias with the one the eval named)
python3 base_train/register_model.py mark-winner \
    --experiment dataset_size --alias v5-base-mini-50k \
    --eval-report out/compare_50k_vs_full.md

# Voice winner
python3 base_train/register_model.py mark-winner \
    --experiment voice_conditioning --alias v5-base-mini-one-hot \
    --eval-report out/compare_voice.md

# Gate — Grok #3's C1 check (exits 0 only when both experiments have a winner)
python3 base_train/register_model.py winners \
    --require dataset_size,voice_conditioning
```

## Step 3 — Catalog + generator smoke (the "marriage")

Isolated test. Pulls 3 catalog scaffolds, feeds each to the winning fine-tune,
prints input/output pairs with syllable counts.

```bash
cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/lyric-llm"
python3 base_train/smoke_catalog_generator.py --model v5-base-mini-50k --artist Gunna --n 3
```

Exit 0 = all 3 bars came back. Exit 1 = check network, key, or the alias.

## Step 4 — Full verse through v5 with the fine-tune

```bash
V5_EDIT_MODEL=v5-base-mini-50k python3 desk.py --artist Gunna --section verse --n 1
```

Generate 20–50 verses with the fine-tune, then 20–50 with the base. Rate blind
in Sparkler. Winner by mean score ≥ +0.5.

## Step 5 — Grok #3

Once Step 2c's `winners --require ...` exits 0, un-pause Grok #3:

> Both winners in registry. Run C2 (`build_combined.py`) through C5 (promotion).

Grok #3 reads `model_registry.json`, picks the two winning variants, builds a
combined dataset (winning size × winning conditioning), fine-tunes once more,
runs a 4-column eval (base / dataset winner / voice winner / combined), and
sets `shared.v5_polish_default` to the combined alias if it wins ≥ 6/8.

## File inventory

Shared across all three Groks (lives on main after merge):

- `tools/lyric-llm/model_registry.json`
- `tools/lyric-llm/base_train/register_model.py`
- `tools/lyric-llm/base_train/smoke_catalog_generator.py`
- `tools/lyric-llm/base_train/RUNBOOK.md` (this file)
- `tools/lyric-llm/llm_client.py` (patched to auto-load registry + accept `ft:` ids)

Branch-specific (merge into main when PRs open):

- Grok #1: `base_train/{train.sh, build_dataset.py, evaluate.py, test_*.py}`
- Grok #2: `base_train/{train_voice_*.sh, voice_*.py, voice_test_*.py, voice_briefs.json}`
- Grok #3: (TBD when C2+ ships)
