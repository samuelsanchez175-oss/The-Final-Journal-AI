#!/usr/bin/env bash
# D3 fine-tune runbook. Samuel runs this. It does not print the API key.
#
# From tools/lyric-llm:
#   bash base_train/train.sh 50k
#   bash base_train/train.sh full
#
# 50k uploads out/train_50k_fim.jsonl and out/val_50k_fim.jsonl.
# full uploads out/train_full_fim.jsonl and out/val_full_fim.jsonl.
# out/val.jsonl is the MLX song split. This script does not upload it.
# The two val files are byte-identical, so both jobs see the same held-out bars.
# Logs: out/finetune_50k_log.jsonl and out/finetune_full_log.jsonl.
# Model registration is D5. This script stops after the job id and model id are in the log.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_ROOT="$(cd "$HERE/.." && pwd)"
cd "${LYRIC_LLM_ROOT:-$DEFAULT_ROOT}"
REPO_ROOT="$(cd ../.. && pwd)"

MODE="${1:-}"
case "$MODE" in
  50k)
    TRAIN_FILE="out/train_50k_fim.jsonl"
    VAL_FILE="out/val_50k_fim.jsonl"
    LOG_FILE="out/finetune_50k_log.jsonl"
    SUFFIX="v5-base-mini-50k"
    ;;
  full)
    TRAIN_FILE="out/train_full_fim.jsonl"
    VAL_FILE="out/val_full_fim.jsonl"
    LOG_FILE="out/finetune_full_log.jsonl"
    SUFFIX="v5-base-mini-full"
    ;;
  *)
    echo "usage: bash base_train/train.sh 50k|full" >&2
    exit 2
    ;;
esac

if [[ -n "${OPENAI_ENV_FILE:-}" ]]; then
  ENV_FILE="$OPENAI_ENV_FILE"
elif [[ -s .env.openai ]]; then
  ENV_FILE=".env.openai"
elif [[ -s "$REPO_ROOT/.env.openai" ]]; then
  ENV_FILE="$REPO_ROOT/.env.openai"
else
  echo "missing .env.openai" >&2
  exit 1
fi
if [[ ! -s "$ENV_FILE" ]]; then
  echo "missing .env.openai" >&2
  exit 1
fi

for f in "$TRAIN_FILE" "$VAL_FILE"; do
  if [[ ! -s "$f" ]]; then
    echo "missing $f" >&2
    exit 1
  fi
done

command -v openai >/dev/null 2>&1 || { echo "openai CLI is not on PATH" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is not on PATH" >&2; exit 1; }

OPENAI_API_KEY="$(tr -d '\r\n' < "$ENV_FILE")"
export OPENAI_API_KEY

mkdir -p out
POLL_SECONDS="${POLL_SECONDS:-30}"

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }

log_event() {
  printf '%s\n' "$1" >> "$LOG_FILE"
}

upload() {
  local path="$1"
  local role="$2"
  local response id
  response="$(openai api files.create -f "$path" -p fine-tune)"
  id="$(printf '%s' "$response" | jq -r .id)"
  if [[ -z "$id" || "$id" == "null" ]]; then
    echo "upload did not return an id for $path" >&2
    exit 1
  fi
  log_event "$(jq -nc \
    --arg ts "$(now)" \
    --arg event upload \
    --arg role "$role" \
    --arg file "$path" \
    --arg file_id "$id" \
    '{ts:$ts,event:$event,role:$role,file:$file,file_id:$file_id}')"
  printf '%s' "$id"
}

TRAIN_ID="$(upload "$TRAIN_FILE" train)"
VAL_ID="$(upload "$VAL_FILE" val)"
echo "train=$TRAIN_ID val=$VAL_ID"

JOB_RESPONSE="$(openai api fine_tuning.jobs.create \
  -t "$TRAIN_ID" \
  -v "$VAL_ID" \
  -m gpt-4o-mini \
  --hyperparameters '{"n_epochs": 3}' \
  --suffix "$SUFFIX")"
JOB_ID="$(printf '%s' "$JOB_RESPONSE" | jq -r .id)"
if [[ -z "$JOB_ID" || "$JOB_ID" == "null" ]]; then
  echo "job create did not return an id" >&2
  exit 1
fi
echo "job=$JOB_ID"
log_event "$(jq -nc \
  --arg ts "$(now)" \
  --arg event job \
  --arg job_id "$JOB_ID" \
  --arg suffix "$SUFFIX" \
  --arg model gpt-4o-mini \
  --argjson n_epochs 3 \
  '{ts:$ts,event:$event,job_id:$job_id,suffix:$suffix,model:$model,n_epochs:$n_epochs,status:"created"}')"

while :; do
  RETRIEVE="$(openai api fine_tuning.jobs.retrieve "$JOB_ID")"
  STATUS="$(printf '%s' "$RETRIEVE" | jq -r .status)"
  EST="$(printf '%s' "$RETRIEVE" | jq -r '.estimated_finish // empty')"
  echo "[$(date +%H:%M:%S)] $STATUS"
  log_event "$(jq -nc \
    --arg ts "$(now)" \
    --arg event status \
    --arg job_id "$JOB_ID" \
    --arg status "$STATUS" \
    --arg estimated_finish "$EST" \
    '{ts:$ts,event:$event,job_id:$job_id,status:$status,estimated_finish:$estimated_finish}')"
  [[ "$STATUS" == "succeeded" || "$STATUS" == "failed" || "$STATUS" == "cancelled" ]] && break
  sleep "$POLL_SECONDS"
done

if [[ "$STATUS" != "succeeded" ]]; then
  echo "job $JOB_ID ended $STATUS" >&2
  exit 1
fi

MODEL_ID="$(printf '%s' "$RETRIEVE" | jq -r .fine_tuned_model)"
if [[ -z "$MODEL_ID" || "$MODEL_ID" == "null" ]]; then
  RETRIEVE="$(openai api fine_tuning.jobs.retrieve "$JOB_ID")"
  MODEL_ID="$(printf '%s' "$RETRIEVE" | jq -r .fine_tuned_model)"
fi
if [[ -z "$MODEL_ID" || "$MODEL_ID" == "null" ]]; then
  echo "job $JOB_ID has no fine_tuned_model" >&2
  exit 1
fi
log_event "$(jq -nc \
  --arg ts "$(now)" \
  --arg event done \
  --arg job_id "$JOB_ID" \
  --arg model_id "$MODEL_ID" \
  '{ts:$ts,event:$event,job_id:$job_id,status:"succeeded",fine_tuned_model:$model_id}')"
echo "model=$MODEL_ID"
