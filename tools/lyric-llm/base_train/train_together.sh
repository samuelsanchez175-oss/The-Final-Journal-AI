#!/usr/bin/env bash
# Together.ai fine-tune runbook. One script, 4 modes.
#
# Usage (run from tools/lyric-llm):
#   bash base_train/train_together.sh 50k
#   bash base_train/train_together.sh full
#   bash base_train/train_together.sh voice_a
#   bash base_train/train_together.sh voice_b
#
# Reads .env.together from repo root (one line: TOGETHER_API_KEY=... prefix OK,
# or just the key alone). Does not print the key.
#
# Logs: out/together_logs/{mode}.jsonl with per-event rows:
#   {ts, event: upload|job|status|done, ...}
# Model id and status land there; evaluate.py and register_model.py read them.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
LYRIC_LLM="$(cd "$HERE/.." && pwd)"
cd "${LYRIC_LLM_ROOT:-$LYRIC_LLM}"
REPO_ROOT="$(cd ../.. && pwd)"

MODE="${1:-}"
BASE_MODEL="${TOGETHER_BASE_MODEL:-meta-llama/Meta-Llama-3.1-8B-Instruct-Reference}"
POLL_SECONDS="${POLL_SECONDS:-60}"

case "$MODE" in
  50k)
    TRAIN_FILE="out/train_50k_fim.jsonl"
    VAL_FILE="out/val_50k_fim.jsonl"
    SUFFIX="v5-base-50k"
    ALIAS="v5-base-50k"
    EXPERIMENT="dataset_size"
    VARIANT="50k_sample"
    N_EXAMPLES=50000
    ;;
  full)
    TRAIN_FILE="out/train_full_fim.jsonl"
    VAL_FILE="out/val_full_fim.jsonl"
    SUFFIX="v5-base-full"
    ALIAS="v5-base-full"
    EXPERIMENT="dataset_size"
    VARIANT="full"
    N_EXAMPLES=167014
    ;;
  voice_a)
    TRAIN_FILE="out/train_voice_a.jsonl"
    VAL_FILE="out/val_voice_a.jsonl"
    SUFFIX="v5-base-voice-a"
    ALIAS="v5-base-one-hot"
    EXPERIMENT="voice_conditioning"
    VARIANT="one_hot"
    N_EXAMPLES=50000
    ;;
  voice_b)
    TRAIN_FILE="out/train_voice_b.jsonl"
    VAL_FILE="out/val_voice_b.jsonl"
    SUFFIX="v5-base-voice-b"
    ALIAS="v5-base-systembrief"
    EXPERIMENT="voice_conditioning"
    VARIANT="systembrief"
    N_EXAMPLES=50000
    ;;
  *)
    echo "usage: bash base_train/train_together.sh 50k|full|voice_a|voice_b" >&2
    exit 2
    ;;
esac

if [[ -n "${TOGETHER_ENV_FILE:-}" ]]; then
  ENV_FILE="$TOGETHER_ENV_FILE"
elif [[ -s .env.together ]]; then
  ENV_FILE=".env.together"
elif [[ -s "$REPO_ROOT/.env.together" ]]; then
  ENV_FILE="$REPO_ROOT/.env.together"
else
  echo "missing .env.together (one line: your Together.ai API key)" >&2
  exit 1
fi

# Accept both KEY= and raw key formats
RAW="$(tr -d '\r\n' < "$ENV_FILE")"
case "$RAW" in
  TOGETHER_API_KEY=*)  export TOGETHER_API_KEY="${RAW#TOGETHER_API_KEY=}" ;;
  *)                    export TOGETHER_API_KEY="$RAW" ;;
esac
unset RAW

for f in "$TRAIN_FILE" "$VAL_FILE"; do
  [[ -s "$f" ]] || { echo "missing $f" >&2; exit 1; }
done

command -v jq >/dev/null 2>&1 || { echo "jq is not on PATH" >&2; exit 1; }

mkdir -p out/together_logs
LOG_FILE="out/together_logs/${MODE}.jsonl"
: > "$LOG_FILE"

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }
log() { printf '%s\n' "$1" >> "$LOG_FILE"; }
shim() { python3 "$HERE/together_client.py" "$@"; }

upload() {
  local path="$1"
  local role="$2"
  local resp id
  resp="$(shim api files.create -f "$path" -p fine-tune)"
  id="$(printf '%s' "$resp" | jq -r '.id // .filename // empty')"
  if [[ -z "$id" ]]; then
    echo "upload failed for $path: $resp" >&2
    exit 1
  fi
  log "$(jq -nc --arg ts "$(now)" --arg role "$role" --arg path "$path" --arg file_id "$id" \
    '{ts:$ts,event:"upload",role:$role,path:$path,file_id:$file_id}')"
  printf '%s' "$id"
}

echo "mode=$MODE base=$BASE_MODEL"
TRAIN_ID="$(upload "$TRAIN_FILE" train)"
VAL_ID="$(upload "$VAL_FILE" val)"
echo "train=$TRAIN_ID val=$VAL_ID"

JOB_RESP="$(shim api fine_tunes.create \
  -t "$TRAIN_ID" -v "$VAL_ID" -m "$BASE_MODEL" \
  --n-epochs 3 --suffix "$SUFFIX" --lora)"
JOB_ID="$(printf '%s' "$JOB_RESP" | jq -r '.id // empty')"
if [[ -z "$JOB_ID" ]]; then
  echo "job create failed: $JOB_RESP" >&2
  exit 1
fi
echo "job=$JOB_ID"
log "$(jq -nc --arg ts "$(now)" --arg job_id "$JOB_ID" --arg suffix "$SUFFIX" --arg base "$BASE_MODEL" --arg alias "$ALIAS" \
  --arg experiment "$EXPERIMENT" --arg variant "$VARIANT" --argjson n_examples $N_EXAMPLES \
  '{ts:$ts,event:"job",job_id:$job_id,suffix:$suffix,base_model:$base,alias:$alias,experiment:$experiment,variant:$variant,n_examples:$n_examples,status:"created"}')"

while :; do
  RESP="$(shim api fine_tunes.retrieve "$JOB_ID")"
  STATUS="$(printf '%s' "$RESP" | jq -r '.status // .state // "unknown"')"
  echo "[$(date +%H:%M:%S)] $STATUS"
  log "$(jq -nc --arg ts "$(now)" --arg job_id "$JOB_ID" --arg status "$STATUS" \
    '{ts:$ts,event:"status",job_id:$job_id,status:$status}')"
  case "$STATUS" in
    completed|succeeded|failed|cancelled|error) break ;;
  esac
  sleep "$POLL_SECONDS"
done

if [[ "$STATUS" != "completed" && "$STATUS" != "succeeded" ]]; then
  echo "job $JOB_ID ended $STATUS" >&2
  exit 1
fi

MODEL_ID="$(printf '%s' "$RESP" | jq -r '.output_name // .model_output_name // .fine_tuned_model // empty')"
if [[ -z "$MODEL_ID" ]]; then
  RESP="$(shim api fine_tunes.retrieve "$JOB_ID")"
  MODEL_ID="$(printf '%s' "$RESP" | jq -r '.output_name // .model_output_name // .fine_tuned_model // empty')"
fi
if [[ -z "$MODEL_ID" ]]; then
  echo "job $JOB_ID has no output model id in response" >&2
  exit 1
fi
log "$(jq -nc --arg ts "$(now)" --arg job_id "$JOB_ID" --arg model_id "$MODEL_ID" --arg alias "$ALIAS" --arg suffix "$SUFFIX" --arg base "$BASE_MODEL" \
  '{ts:$ts,event:"done",job_id:$job_id,model_id:$model_id,alias:$alias,suffix:$suffix,base_model:$base,status:"succeeded"}')"
echo "model=$MODEL_ID"
echo "alias=$ALIAS experiment=$EXPERIMENT variant=$VARIANT"
