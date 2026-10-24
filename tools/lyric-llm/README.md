# Penwork lyric model

Local QLoRA setup for the Penwork bar catalog. Prep reads the private CSV, joins BPM and scale from the Sparkler tempo cache, and writes a song-level 95/3/2 split. Training and inference run on this Mac with MLX.

The corpus and the adapters stay in `out/`, `adapters/`, and `adapters_smoke/`. All three are gitignored.

## Legal

Training on these artists' lyrics is legally gray. Fair use for model training is still being fought over in court. Keep the corpus private. Do not redistribute the weights commercially without counsel. The base checkpoint is under the Qwen research license. Do not fuse the adapter and upload it.

## Model

Use `mlx-community/Qwen2.5-3B-Instruct-4bit`.

A 4-bit 3B LoRA fits in this M1 Pro's 16GB; a 7B or 8B QLoRA run does not once activations are counted. Qwen2.5 follows a short control prefix, so the voice, BPM, and scale tags steer generation without adding 780 new embedding rows.

## Voice token

Each training window is one chat. The user turn is the voice token, then `<bpm:VALUE>` and `<scale:VALUE>` only when that song has them, then `<syl:N>` for the window. The assistant turn is the lyric window. `mask_prompt: true` puts the loss on the lyrics, so the LoRA learns that `<voice:ARTIST>` is followed by that artist's writing.

```text
<voice:Artist Name> <bpm:140> <scale:A minor> <syl:11>
```

`<bpm>` is the tempo rounded to the nearest 5. `<syl>` is the median syllable estimate of the lyric lines in that eight-line window. A new voice uses `<voice:custom>` plus an `<exemplar>` block of bars you supply. The adapter is LoRA on `self_attn.q_proj` and `self_attn.v_proj` in the last 8 layers. No new embedding row is added.

A 70/30 blend is applied at generation time. The model scores the next token once under `<voice:Artist A>` and once under `<voice:Artist B>`. Those scores become probabilities, and the sampler draws from 70% of A plus 30% of B. Solo A uses only A's prefix. Solo B uses only B's prefix. The three samples share the seed, the opening line, and the BPM.

```bash
.venv/bin/python infer.py --compare --voice "Gunna" --blend "Young Thug" --mix 70 \
  --bpm 140 --bars 16 --seed 7 \
  --seed-line "Count the room before I say the number"
```

At generation time, `--bpm` sets the line budget: 8 syllables at 70 BPM and 14 at 140, linear in between, held between 6 and 18. The sampler closes each bar when that count is reached. A fast tempo gets a denser line. A slow tempo gets a roomier line. `--scale` is written in the same prefix and does not change the syllable count. Training windows still use the median of that window. Catalog lines stay near 10–11 syllables at both 70 and 140, so this budget is a generation control.

```bash
.venv/bin/python infer.py --voice "Gunna" --scale "A minor" --bars 16 --seed 7 --tempos 70,140
```

The same command works with `--voice "Young Thug"`. Young Stoner Life is its own token.

## Everyday generation

`generate.py` writes the bars only. Each bar is one line. The same text is printed and saved under `out/bars/` with the date and time in the file name. Temperature defaults to 0.8 and top-p to 0.95. A seed line is the first bar. A topic stays in the prompt. `--bpm` still sets the syllable budget.

```bash
.venv/bin/python generate.py --voice "Gunna" --bpm 140 --scale "A minor" \
  --bars 16 --seed-line "Count the room before I say the number"

.venv/bin/python generate.py --voice "Gunna" --blend "Young Thug" --mix 70 \
  --bpm 140 --scale "A minor" --bars 16 \
  --seed-line "Count the room before I say the number"

.venv/bin/python generate.py --voice "Young Thug" --bpm 90 --scale "D minor" \
  --bars 8 --topic "rain on the windshield" --temperature 1.2 --top-p 0.99
```

## Tuning desk

One local page. This step shows the three areas and the numbers already on disk. Training loss stays "no data yet" until a run writes `out/training_log.csv`. Generate is not connected. The page does not upload the catalog or the weights. The listen sheet stays on port 8765.

```bash
/usr/bin/python3 desk.py
```

Open http://127.0.0.1:8766/. Stop the desk with Ctrl-C.

After training, the same prefix is what generation sends:

```bash
.venv/bin/python infer.py --voice "Gunna" --bpm 140 --bars 8
```

`python3 train.py --list-voices` writes every `<voice:...>` token from the leak-checked songs. An artist with fewer than 200 train lines is flagged. The token is still created, and the name can still be typed. Generation prints a warning and still writes the bars.

## Data the prep actually sees

Bars come from `XJournal AI/ground_truth_rap_bars_MODEL_G.csv` (`artist`, `song`, `text_bar_line`, `syllable_count`). BPM and musical scale are not columns on that file. They are joined from `tools/style-profile/out/tempo_cache.jsonl` by artist and song title. Songs the cache missed keep null BPM and scale. The training prefix includes `<bpm>` and `<scale>` only when the song has them.

Section tags in the CSV are almost all `unknown`. Structure is learned from line order inside the song window, eight lines at a time.

Cross-song repeats are dropped. The copy kept is the one on the song that has BPM, then scale. Up to four copies can remain inside the song that owns the line, so a hook can still repeat. Short ad-libs are not cross-deduped.

## Commands

From `tools/lyric-llm`. Use the venv's Python 3.12. Xcode's Python 3.9 cannot import MLX.

```bash
cd "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/lyric-llm"
uv venv --python 3.12 .venv
uv pip install -r requirements.txt
python3 test_train_setup.py
python3 test_pipeline.py
python3 train.py --list-voices
.venv/bin/python train.py --dry-run --epochs 1
.venv/bin/python train.py --epochs 1
tail -f "out/training_log.csv"
kill -INT "$(cat out/train.pid)"
.venv/bin/python train.py --resume
.venv/bin/python train.py --check-resume
.venv/bin/python evaluate.py
.venv/bin/python infer.py --voice "Gunna" --bpm 140 --bars 8 --temperature 0.9 --top-p 0.9
.venv/bin/python infer.py --voice "Gunna" --scale "A minor" --bars 16 --seed 7 --tempos 70,140
.venv/bin/python infer.py --compare --voice "Gunna" --blend "Young Thug" --mix 70 --bpm 140 --bars 16 --seed 7 --seed-line "Count the room before I say the number"
```

`train.py` reads the leak-checked songs in `out/train.jsonl`, `out/val.jsonl`, and `out/test.jsonl`. It cuts each song into eight-line windows with the voice prefix and writes those chats to `out/mlx_songs/`. `--epochs 1` is one pass over those windows. That pass is many hours on this Mac. Running it again while `adapters/resume_state.json` exists exits with an error and does not train. `--fresh` is the only start-over, and it renames the old adapter directory and the log instead of deleting them.

Watch the loss with `tail -f` on `out/training_log.csv`. Stop with one Ctrl-C, or `kill -INT` of the pid in `out/train.pid`. That finishes the current step and saves it. A second Ctrl-C drops the in-progress step and keeps the previous checkpoint. `kill -9` does not save. A crash keeps the last 500-step checkpoint, so up to 499 steps can be missing. The next launch will not start over.

`.venv/bin/python train.py --resume` loads that checkpoint and continues. The next row in the log is the saved step plus one, and the saved step's loss stays the same. `--resume-status` prints the checkpoint and does not train. After the next row appears, `--check-resume` exits 0 when that row is the next step and the saved loss is unchanged. Exit 2 means the next step is not logged yet. Exit 1 means the saved step is missing or its loss changed.

`--smoke` trains on 20 train songs, each cut to the first 16 lines, which is at most two windows and 40 steps. After the 4-bit weights are already on disk, that run is sized to finish in under 15 minutes. It writes `adapters_smoke/`. Resume it with `--resume --smoke`. Smoke and the full run share `out/training_log.csv`, so one checkpoint blocks the other until you resume it or pass `--fresh`. `--pilot` is an older cap of 20 optimizer steps on the full window set. Resume a pilot with `--pilot` as well. It is a different switch from the 20-song smoke test.

Every reported step is appended to `out/training_log.csv`. A checkpoint is the adapter, the AdamW moments, the MLX random state, and the step, written every 500 steps and on a safe stop. A new run also writes a step-0 `resume_state.json` before the first step, so a crash in the first 499 steps refuses the next launch instead of wiping the log and starting at step 1. A smoke run never hits 500 steps, so only a safe stop leaves weights to resume.

`prep.py --limit-songs 200` is a parse check. It is not the training corpus. The older `out/mlx/` chats come from that prep, and `train.py` does not read them.

## Outputs

| Path | What it is |
| --- | --- |
| `out/{train,val,test}.jsonl` | leak-checked songs: `text`, `artist`, `bpm`, `scale`, `song_id` |
| `out/voices.txt` | one `<voice:...>` token per stored artist string |
| `out/voice_tokens.md` | token, train/val/test lines, train windows, thin-voice flag |
| `out/voice_counts.json` | the same counts, so generation can warn before it writes bars |
| `out/mlx_songs/{train,valid,test}.jsonl` | eight-line chats the full run trains on |
| `out/smoke/` | 20-song smoke chats |
| `out/training_log.csv` | step, train loss, val loss, learning rate, tokens/sec, peak GB |
| `out/resume_check.json` | saved step and loss from the last resume, for `--check-resume` |
| `out/train.pid` | pid of the live run; `kill -INT` that pid stops safely |
| `out/train_config.run.yaml` | config copy whose cosine length matches this run |
| `out/lines/{train,valid,test}.jsonl` | older line records |
| `out/mlx/{train,valid,test}.jsonl` | older line-level chats; `train.py` does not read these |
| `out/syllable_curve.json` | syllables per BPM bucket |
| `out/bpm_compare.txt` | generated bars at two tempos, plus corpus syllable means |
| `out/bars/` | dated text files from `generate.py`, bars only |
| `out/originality.sqlite` | hashes of train lines, not the lines |
| `out/eval_report.md` | corpus baseline, then model scores (base checkpoint until an adapter exists) |
| `adapters/resume_state.json` | saved step, loss, and where the weights and optimizer are |
| `adapters/` | full-run LoRA, AdamW state, and RNG, every 500 steps and on a safe stop |
| `adapters_smoke/` | smoke-run checkpoint; resume with `--resume --smoke` |

## Eval

Held-out perplexity is the prompt-masked next-token loss from `evaluate.py` on eight-line windows of the leak-checked `out/test.jsonl`. It does not use `mlx_lm.lora --test` or the older `out/mlx` chats. Rhyme rate and syllable flow are compared with the training curve at the same BPM bucket. The voice check asks whether a generated block is closer, on syllable count, line length, type-token ratio, and end-rhyme rate, to that artist's held-out lines than to a random artist's. A generated line whose simhash is within Hamming distance 3 of a training line is flagged. The training line is not printed. With no adapter on disk, the scores are the base checkpoint.
