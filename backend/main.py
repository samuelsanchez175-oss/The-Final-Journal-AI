"""
Generate Lyrics from Flow - Onset detection backend (Scenario B: mumble).
Accepts audio file, returns syllable-per-bar skeleton for lyric generation.
"""
import io
from typing import Optional

import librosa
import numpy as np
from fastapi import FastAPI, File, HTTPException, Query, UploadFile

app = FastAPI(title="Flow Skeleton API", version="1.0.0")

BEATS_PER_BAR = 4


@app.post("/skeleton")
async def extract_flow_skeleton(
    audio: UploadFile = File(...),
    bpm: Optional[int] = Query(None, ge=60, le=220, description="BPM; if not provided, estimated from audio"),
    bar_offset_ms: int = Query(0, ge=0, description="Offset in ms to first bar"),
) -> dict:
    """
    Accepts an audio file (multipart/form-data). Returns JSON:
    { "perBar": [ { "bar": 1, "count": N, "perBeat": [a,b,c,d] }, ... ], "bpm": int }
    """
    try:
        data = await audio.read()
    except Exception as e:
        raise HTTPException(400, f"Failed to read audio: {e}") from e

    try:
        y, sr = librosa.load(io.BytesIO(data), sr=22050, mono=True)
    except Exception as e:
        raise HTTPException(400, f"Failed to load audio: {e}") from e

    if len(y) == 0:
        raise HTTPException(400, "Audio file is empty")

    # BPM: use provided or estimate
    if bpm is not None and bpm > 0:
        tempo = float(bpm)
    else:
        try:
            tempo, _ = librosa.beat.beat_track(y=y, sr=sr, units="time")
            if np.isscalar(tempo):
                tempo = float(tempo)
            else:
                tempo = float(np.mean(tempo))
            tempo = max(60, min(220, tempo))
        except Exception:
            tempo = 90.0

    # Onset detection → frame indices
    onset_frames = librosa.onset.onset_detect(y=y, sr=sr, units="time", backtrack=True)
    if len(onset_frames) == 0:
        # No clear onsets: distribute pseudo-syllables by duration
        duration_sec = len(y) / sr
        bar_duration_sec = (60.0 / tempo) * BEATS_PER_BAR
        num_bars = max(1, int(duration_sec / bar_duration_sec))
        per_bar = [
            {
                "bar": i + 1,
                "count": 8,
                "conf": 0.5,
                "perBeat": [2, 2, 2, 2],
            }
            for i in range(num_bars)
        ]
        return {"perBar": per_bar, "bpm": int(round(tempo))}

    # Map onset times to bars/beats
    beat_duration_sec = 60.0 / tempo
    bar_duration_sec = beat_duration_sec * BEATS_PER_BAR
    offset_sec = bar_offset_ms / 1000.0

    bar_beat_counts: dict[int, list[int]] = {}
    for t in onset_frames:
        t_adj = t - offset_sec
        if t_adj < 0:
            continue
        bar_index = int(t_adj / bar_duration_sec) + 1
        in_bar = t_adj % bar_duration_sec
        beat_in_bar = int(in_bar / beat_duration_sec)
        if beat_in_bar >= BEATS_PER_BAR:
            beat_in_bar = BEATS_PER_BAR - 1
        if bar_index not in bar_beat_counts:
            bar_beat_counts[bar_index] = [0] * BEATS_PER_BAR
        if 0 <= beat_in_bar < BEATS_PER_BAR:
            bar_beat_counts[bar_index][beat_in_bar] += 1

    if not bar_beat_counts:
        bar_beat_counts[1] = [2, 2, 2, 2]

    per_bar = []
    for bar in sorted(bar_beat_counts.keys()):
        per_beat = bar_beat_counts[bar]
        total = sum(per_beat)
        per_bar.append({
            "bar": bar,
            "count": total,
            "conf": 0.85,
            "perBeat": per_beat,
        })

    return {"perBar": per_bar, "bpm": int(round(tempo))}


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
