#!/usr/bin/env bash
# systembrief fine-tune. Samuel runs this. It does not print the API key.
# Alias v5-base-mini-systembrief. Suffix v5-base-voice-b. n_epochs=3.
# Train file was built with --seed 7 --fim 0.2. Val is the same split.
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(cd ../.. && pwd)"
ENV_FILE="$ROOT/.env.openai"

if [[ ! -s "$ENV_FILE" ]]; then
  echo "missing $ENV_FILE" >&2
  exit 1
fi
export OPENAI_API_KEY="$(cat "$ENV_FILE")"

python3 base_train/voice_register.py --check-seed 7

for f in out/train_voice_b.jsonl out/val_voice_b.jsonl; do
  if [[ ! -s "$f" ]]; then
    echo "missing $f" >&2
    echo "python3 base_train/voice_dataset.py --role val --variant systembrief --seed 7 --fim 0.2 --out out/val_voice_b.jsonl" >&2
    exit 1
  fi
done

TRAIN_ID="$(openai api files.create -f out/train_voice_b.jsonl -p fine-tune | jq -r .id)"
VAL_ID="$(openai api files.create -f out/val_voice_b.jsonl -p fine-tune | jq -r .id)"
if [[ -z "$TRAIN_ID" || "$TRAIN_ID" == "null" || -z "$VAL_ID" || "$VAL_ID" == "null" ]]; then
  echo "upload did not return an id" >&2
  exit 1
fi
echo "train=$TRAIN_ID val=$VAL_ID"

JOB_ID="$(openai api fine_tuning.jobs.create \
  -t "$TRAIN_ID" \
  -v "$VAL_ID" \
  -m gpt-4o-mini \
  --hyperparameters '{"n_epochs": 3}' \
  --suffix "v5-base-voice-b" | jq -r .id)"
if [[ -z "$JOB_ID" || "$JOB_ID" == "null" ]]; then
  echo "job create did not return an id" >&2
  exit 1
fi
echo "job=$JOB_ID"

while :; do
  STATUS="$(openai api fine_tuning.jobs.retrieve "$JOB_ID" | jq -r .status)"
  echo "[$(date +%H:%M:%S)] $STATUS"
  [[ "$STATUS" == "succeeded" || "$STATUS" == "failed" || "$STATUS" == "cancelled" ]] && break
  sleep 30
done
if [[ "$STATUS" != "succeeded" ]]; then
  echo "job $JOB_ID ended $STATUS" >&2
  exit 1
fi

MODEL_ID="$(openai api fine_tuning.jobs.retrieve "$JOB_ID" | jq -r .fine_tuned_model)"
if [[ -z "$MODEL_ID" || "$MODEL_ID" == "null" ]]; then
  echo "job $JOB_ID has no fine_tuned_model" >&2
  exit 1
fi

python3 base_train/voice_register.py \
  --alias v5-base-mini-systembrief \
  --model-id "$MODEL_ID" \
  --job-id "$JOB_ID" \
  --experiment voice_conditioning \
  --variant systembrief \
  --training-file out/train_voice_b.jsonl \
  --validation-file out/val_voice_b.jsonl \
  --n-examples 50000 \
  --n-epochs 3 \
  --sample-seed 7 \
  --fim-share 0.2

echo "model=$MODEL_ID"
