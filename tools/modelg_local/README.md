# Model G — local fine-tune on Apple Silicon (offline)

Fine-tune Model G on your Mac with **MLX-LM LoRA** — fully on-device, no
OpenAI/cloud round-trip, no network-policy headaches. Your existing OpenAI
exporter (`export_genius_to_jsonl.py`) is untouched; this is a parallel local
lane.

**Requires:** Apple Silicon Mac (M1+), macOS 13.5+, Python 3.9+.

```
export_genius_to_jsonl.py ─┐
                           ├─► build_mlx_dataset.py ─► data/{train,valid}.jsonl ─► mlx_lm.lora ─► adapters/ ─► fuse ─► run
tools/rap_dataset CSV ─────┘
```

## 1. Install MLX-LM
```bash
pip install -U mlx-lm           # or: uv pip install mlx-lm
```

## 2. Build the training data (one of two sources)

**A) From your OpenAI exporter output** — chat format, keeps the Model G system
prompt (best for instruction-style "write 4 bars …" generation):
```bash
python3 export_genius_to_jsonl.py          # produces rap_finetune_*.jsonl
python3 tools/modelg_local/build_mlx_dataset.py \
    --input rap_finetune_training.jsonl rap_finetune_validation.jsonl \
    --out-dir tools/modelg_local/data
```

**B) From a rap_bars CSV** (e.g. the `tools/rap_dataset` output) — raw N-bar
text blocks (best for pure style absorption):
```bash
python3 tools/modelg_local/build_mlx_dataset.py \
    --from-csv "XJournal AI/rap_bars_from_spotify.csv" \
    --block-bars 4 --out-dir tools/modelg_local/data
```

Either way you get `tools/modelg_local/data/train.jsonl` + `valid.jsonl` in the
exact layout `mlx_lm.lora` expects.

## 3. Fine-tune (LoRA)
```bash
mlx_lm.lora --config tools/modelg_local/mlx_lora_config.yaml
```
Or the CLI form (most stable across versions — run `mlx_lm.lora --help` to confirm flags):
```bash
mlx_lm.lora \
  --model mlx-community/Llama-3.2-3B-Instruct-4bit \
  --train --data tools/modelg_local/data \
  --iters 600 --batch-size 4 --num-layers 16 \
  --adapter-path tools/modelg_local/adapters
```
Pick the base model by RAM: ~16 GB → a 3B-4bit model; 32 GB+ → 7–8B-4bit. Edit
`model:` in the config.

## 4. Test it
```bash
mlx_lm.generate \
  --model mlx-community/Llama-3.2-3B-Instruct-4bit \
  --adapter-path tools/modelg_local/adapters \
  --prompt "Write 4 bars. Theme: getting rich in silence. Tone: unbothered."
# or interactive:
mlx_lm.chat --model mlx-community/Llama-3.2-3B-Instruct-4bit \
  --adapter-path tools/modelg_local/adapters
```

## 5. Fuse adapter into a standalone model
```bash
mlx_lm.fuse \
  --model mlx-community/Llama-3.2-3B-Instruct-4bit \
  --adapter-path tools/modelg_local/adapters \
  --save-path tools/modelg_local/modelg-fused
```

## 6. Run it in a desktop app
- **LM Studio** — runs MLX models natively. Point it at the `modelg-fused`
  folder (or drop it under `~/.lmstudio/models/`). Simplest path.
- **Ollama** — needs GGUF. Convert the fused model with llama.cpp
  (`convert_hf_to_gguf.py`), then `ollama create modelg -f Modelfile`. Extra
  step vs LM Studio, but gives you the OpenAI-compatible local API.

## 7. Point the app at your local model
`RapSuggestionAPI` now reads two optional `UserDefaults` keys (defaults keep the
existing OpenAI behavior, so nothing changes unless you set them):

| Key | Value | Effect |
|---|---|---|
| `modelg_local_base_url` | `http://localhost:1234/v1` (LM Studio) or `http://localhost:11434/v1` (Ollama) | Routes all `/chat/completions` calls to your local server |
| `modelg_local_model` | the served model name (e.g. `modelg`) | What `.modelGv3` sends as the model id |

Set them once (e.g. in a debug build, app settings, or a launch argument):
```swift
UserDefaults.standard.set("http://localhost:11434/v1", forKey: "modelg_local_base_url")
UserDefaults.standard.set("modelg", forKey: "modelg_local_model")
```
Pick **Model G v3** in the app and it'll hit your local fine-tune. Clear the keys
to fall back to OpenAI. (Note: a simulator/device reaches your Mac's localhost
server over the LAN IP, not `localhost` — use the Mac's IP on a physical device.)

## Notes
- `data/`, `adapters/`, `*-fused/`, `*.gguf` are git-ignored — they're rebuilt
  from your source data, not committed.
- Start with a few hundred high-quality examples; LoRA needs far less data than
  full fine-tuning. The converter warns if you have <50.
- This keeps verbatim lyrics on your machine — nothing leaves the Mac, which is
  also the copyright-safe posture.
