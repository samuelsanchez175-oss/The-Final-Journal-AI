#!/usr/bin/env python3
"""Penwork Studios V3: Audio Stem Alignment & Grid Quantization Engine.

Features:
  1. Tempo-to-Millisecond Grid Mathematics: Computes exact timing grids for any BPM.
  2. Sub-Beat Syllable Interpolation: Quantizes words to 16th-note and triplet ticks.
  3. Pocket Micro-Timing Offsets: Laid-back/lagging vs. on-top/pushing timing.
  4. Audio Stem Synchronization: Maps drum/melody markers to lyric downbeats.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import List, Dict, Any

from lyriclib import tokenize, normalize, estimate_syllables


def compute_tempo_metrics(bpm: float) -> dict:
    """Calculate millisecond durations for musical units at a given BPM."""
    bpm_safe = max(50.0, min(220.0, float(bpm)))
    beat_ms = 60000.0 / bpm_safe
    bar_ms = beat_ms * 4.0
    tick_16th_ms = beat_ms / 4.0
    tick_triplet_ms = beat_ms / 3.0

    return {
        "bpm": bpm_safe,
        "bar_duration_ms": round(bar_ms, 2),
        "beat_duration_ms": round(beat_ms, 2),
        "tick_16th_ms": round(tick_16th_ms, 2),
        "tick_triplet_ms": round(tick_triplet_ms, 2),
    }


def align_bar_to_stems(
    bar_index: int,
    beat_groups: list[str],
    bpm: float = 130.0,
    pocket_offset_ms: float = 0.0,
) -> dict:
    """Align a single 4-beat bar to stem time markers and sub-beat ticks."""
    metrics = compute_tempo_metrics(bpm)
    bar_ms = metrics["bar_duration_ms"]
    beat_ms = metrics["beat_duration_ms"]
    bar_start_ms = round((bar_index - 1) * bar_ms, 2)
    bar_end_ms = round(bar_start_ms + bar_ms, 2)

    beats_alignment = []
    beat_roles = [
        {"role": "Setup 1", "stem_cue": "Kick / Downbeat"},
        {"role": "Setup 2", "stem_cue": "Snare / Clap 1"},
        {"role": "Turnaround", "stem_cue": "808 Slide / Hat Roll"},
        {"role": "Punchline & Rhyme", "stem_cue": "Snare / Clap 2"},
    ]

    for b_idx in range(4):
        phrase = beat_groups[b_idx] if b_idx < len(beat_groups) else ""
        role_info = beat_roles[b_idx]
        b_start_ms = round(bar_start_ms + (b_idx * beat_ms) + pocket_offset_ms, 2)
        b_end_ms = round(b_start_ms + beat_ms, 2)

        # Tokenize and interpolate word timestamps within beat
        words = phrase.split()
        word_timings = []
        if words:
            word_slot = beat_ms / len(words)
            for w_i, w in enumerate(words):
                w_start = round(b_start_ms + (w_i * word_slot), 2)
                w_end = round(w_start + word_slot, 2)
                word_timings.append({
                    "word": w,
                    "start_ms": w_start,
                    "end_ms": w_end,
                    "syllables": estimate_syllables(w),
                })

        beats_alignment.append({
            "beat": b_idx + 1,
            "role": role_info["role"],
            "stem_cue": role_info["stem_cue"],
            "text": phrase,
            "start_ms": b_start_ms,
            "end_ms": b_end_ms,
            "words": word_timings,
        })

    return {
        "bar": bar_index,
        "start_ms": bar_start_ms,
        "end_ms": bar_end_ms,
        "duration_ms": bar_ms,
        "beats": beats_alignment,
    }


def generate_full_stem_alignment(
    bars: list[dict],
    bpm: float = 130.0,
    pocket_style: str = "laid_back",
) -> dict:
    """Generate the comprehensive V3 Stem Alignment Grid for an entire take."""
    # Pocket micro-timing offsets
    pocket_offsets = {
        "laid_back": 35.0,   # Gunna / Thug: relaxed behind the beat
        "on_the_grid": 0.0,  # Strict quantized metronome
        "pushing": -20.0,    # Drill / Lil Baby: forward energy ahead of beat
    }
    offset = pocket_offsets.get(pocket_style, 0.0)

    aligned_bars = []
    for b in bars:
        idx = b.get("index", 1)
        groups = b.get("beat_groups") or [b.get("text", ""), "", "", ""]
        aligned = align_bar_to_stems(
            bar_index=idx,
            beat_groups=groups,
            bpm=bpm,
            pocket_offset_ms=offset,
        )
        aligned["motif"] = b.get("motif")
        aligned["end_word"] = b.get("end_word")
        aligned["rhyme_family"] = b.get("rhyme_family")
        aligned["couplet_rhymes"] = b.get("couplet_rhymes")
        aligned_bars.append(aligned)

    metrics = compute_tempo_metrics(bpm)
    total_duration_ms = round(len(aligned_bars) * metrics["bar_duration_ms"], 2)

    return {
        "version": "v3",
        "bpm": bpm,
        "pocket_style": pocket_style,
        "pocket_offset_ms": offset,
        "total_duration_ms": total_duration_ms,
        "total_duration_sec": round(total_duration_ms / 1000.0, 2),
        "tempo_metrics": metrics,
        "bars": aligned_bars,
    }


if __name__ == "__main__":
    sample_bars = [
        {"index": 1, "text": "Diamonds on neck, we cruising the lane, foreigns in the spot, stacking up the gains.", "beat_groups": ["Diamonds on neck", "we cruising the lane", "foreigns in the spot", "stacking up the gains"], "motif": "Lavishness & Money"},
        {"index": 2, "text": "Count up the racks, we living so great, money in the vault, never touch a plate.", "beat_groups": ["Count up the racks", "we living so great", "money in the vault", "never touch a plate"], "motif": "Lavishness & Money"},
    ]

    res = generate_full_stem_alignment(sample_bars, bpm=130.0, pocket_style="laid_back")
    print(f"[Penwork V3 Stem Alignment Grid] {res['bpm']} BPM ({res['pocket_style']} pocket: +{res['pocket_offset_ms']}ms)")
    print(f"Total Duration: {res['total_duration_sec']}s ({res['total_duration_ms']}ms)\n")

    for bar in res["bars"]:
        print(f"Bar {bar['bar']} ({bar['start_ms']}ms -> {bar['end_ms']}ms) [{bar['motif']}]:")
        for b in bar["beats"]:
            print(f"   Beat {b['beat']} [{b['start_ms']}ms]: \"{b['text']}\" ({b['role']} | Cue: {b['stem_cue']})")
        print()
