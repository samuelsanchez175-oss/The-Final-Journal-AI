# Base LLM Fine-Tune Runbook

**Provider: Together.ai (was OpenAI).** On 2026-10-27 OpenAI returned 403
PermissionDenied when creating a fine-tune job: "OpenAI is winding down the
fine-tuning platform and your organization is no longer able to create new
fine-tuning training jobs." The 4-job experiment pivoted to Together.ai with
the same JSONLs and the same experiment matrix.

End-to-end: 4 Together.ai jobs → register winners → smoke test the catalog +
fine-tune marriage → promote to v5. Your 4 bash commands are the only step
that spends money.

Base model for first pass: `meta-llama/Meta-Llama-3.1-8B-Instruct-Reference`
(LoRA fine-tune, ~$20–30 per job). Combined final (Grok #3) steps up to
`meta-llama/Meta-Llama-3.1-70B-Instruct-Reference` (~$80–150).

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

## Step 1 — Launch the 4 fine-tune jobs on Together.ai (yours, ~$100–150)

Prereqs:
- `.env.together` at repo root, chmod 600, gitignored. One line: your
  Together.ai API key (with or without the `TOGETHER_API_KEY=` prefix).
- venv activated (`source tools/lyric-llm/.venv/bin/activate`); `requests` is
  installed in the venv.
- `jq` on PATH (preinstalled on macOS at `/usr/bin/jq`).

Together.ai signup: https://api.together.ai — generate an API key, drop it in
`.env.together` (plain key on one line is fine).

Legacy OpenAI path (dead): the old `train.sh` and `openai_cli_shim.py` are kept
for history but return 403 against the OpenAI fine-tune API. Do not run them.

```bash
cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/lyric-llm"
source .venv/bin/activate
mkdir -p out/launch_logs

# Launch all 4 (parallel). Together's queue handles concurrency.
nohup bash base_train/train_together.sh 50k     > out/launch_logs/50k.log     2>&1 &
nohup bash base_train/train_together.sh full    > out/launch_logs/full.log    2>&1 &
nohup bash base_train/train_together.sh voice_a > out/launch_logs/voice_a.log 2>&1 &
nohup bash base_train/train_together.sh voice_b > out/launch_logs/voice_b.log 2>&1 &
```

Each `train_together.sh` logs upload/job/status/done events to
`out/together_logs/<mode>.jsonl`. ~30 min – 2 h per LoRA.

**Fastest validation path:** if you don't want all 4 jobs at once, run just
50k first (~$20–25). If it beats Path A's rating, scale to the full matrix.

```bash
bash base_train/train_together.sh 50k
```

## Step 2 — When Together shows all 4 jobs `completed`

Collect model IDs from `out/together_logs/<mode>.jsonl` — the `event: done`
row carries `model_id`. Expected shape: `samuel/.../Llama-3.1-8B-...<suffix>`
(Together's user-namespaced model id).

### 2a. Register each model as a candidate

```bash
cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/lyric-llm"

# Pull model_id out of each log
jq -r 'select(.event=="done") | .alias + " " + .model_id + " " + .job_id' \
    out/together_logs/*.jsonl

# Then for each row, register (fill XXX with the real values)
python3 base_train/register_model.py add \
    --trained-by grok#1 --alias v5-base-50k \
    --experiment dataset_size --variant 50k_sample \
    --provider together \
    --model-id "<Together model_id for 50k>" \
    --job-id "<Together job id>" \
    --training-file out/train_50k_fim.jsonl \
    --validation-file out/val_50k_fim.jsonl \
    --n-examples 50000 --fim-share 0.2 \
    --base-model "meta-llama/Meta-Llama-3.1-8B-Instruct-Reference"

# Repeat for v5-base-full, v5-base-one-hot, v5-base-systembrief

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

Pulls 3 catalog scaffolds, feeds each to the winning Together.ai fine-tune.

```bash
cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/lyric-llm"
python3 base_train/smoke_catalog_generator.py --model v5-base-50k --artist Gunna --n 3
```

Exit 0 = all 3 bars came back. Exit 1 = check network, key, or the alias.
llm_client auto-detects Together.ai routing when the registry entry carries
`provider: together` and `TOGETHER_API_KEY` is in env.

## Step 4 — Full-verse batch for Sparkler rating

```bash
cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/lyric-llm"
TOGETHER_API_KEY="$(tr -d '\r\n' < ../../.env.together)" \
V5_PLAN_MODEL=claude-opus-4-7 V5_EDIT_MODEL=v5-base-50k \
python3 base_train/batch_generate_pathA.py --n 20 --bars 8 \
    --out ../style-profile/out/model_comparison.json
```

(Fallback for the plan stage: `V5_PLAN_MODEL=gpt-4o-mini` if no Anthropic key.)

Then open the rater at http://127.0.0.1:8766/rater/ and rate. Compare the
mean against Path A's base-model baseline. Fine-tune wins by ≥ +0.5 mean.

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
