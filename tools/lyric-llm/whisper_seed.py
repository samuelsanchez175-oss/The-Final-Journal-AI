#!/usr/bin/env python3
"""Penwork Studios Frontier V4: Whisper Hum-to-Flow Seed Audio Ingestion.

Transcribes vocal hums, freestyle audio, or melodic mumbles (.m4a, .wav, .mp3)
via OpenAI Whisper (whisper-1) with word-level timestamps, extracts rhythmic cadence
and syllable density, and estimates BPM to seed the Frontier v4 generation pipeline.

Formula:
  - BPM estimation: 60 / median_syllable_interval (normalized to hip-hop clock tempo)
  - Cadence budget: median syllables per hum line/phrase
"""

from __future__ import annotations

import argparse
import json
import mimetypes
import os
import re
import statistics
import sys
import urllib.error
import urllib.request
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

import polish
from lyriclib import estimate_syllables


def build_multipart_payload(fields: Dict[str, Any], files: Dict[str, Tuple[str, bytes, str]], boundary: Optional[str] = None) -> Tuple[bytes, str]:
    """Constructs multipart/form-data payload in pure Python standard library."""
    boundary = boundary or f"----WhisperBoundary{uuid.uuid4().hex}"
    body = bytearray()

    for name, value in fields.items():
        if isinstance(value, (list, tuple)):
            for v in value:
                body.extend(f"--{boundary}\r\n".encode("utf-8"))
                body.extend(f'Content-Disposition: form-data; name="{name}"\r\n\r\n{v}\r\n'.encode("utf-8"))
        else:
            body.extend(f"--{boundary}\r\n".encode("utf-8"))
            body.extend(f'Content-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n'.encode("utf-8"))

    for name, (filename, content, content_type) in files.items():
        body.extend(f"--{boundary}\r\n".encode("utf-8"))
        body.extend(f'Content-Disposition: form-data; name="{name}"; filename="{filename}"\r\n'.encode("utf-8"))
        body.extend(f"Content-Type: {content_type}\r\n\r\n".encode("utf-8"))
        body.extend(content)
        body.extend(b"\r\n")

    body.extend(f"--{boundary}--\r\n".encode("utf-8"))
    content_type_header = f"multipart/form-data; boundary={boundary}"
    return bytes(body), content_type_header


def resolve_flow_bpm(raw_bpm: float) -> Tuple[float, int]:
    """Normalizes raw flow BPM into hip-hop/trap clock tempo range (100–185 BPM).
    
    Handles half-time hums (e.g., 65-85 BPM -> 130-170 BPM) and double-time 
    eighth/sixteenth note hums (e.g. 260-280 BPM -> 130-140 BPM).
    """
    if raw_bpm <= 0:
        return 130.0, 130

    b = float(raw_bpm)
    while b > 185.0:
        b /= 2.0
    while b < 85.0:
        b *= 2.0

    clock_bpm, _, _ = polish.normalize_trap_tempo(b)
    return clock_bpm, int(round(clock_bpm))


def estimate_bpm_from_timestamps(words: List[Dict[str, Any]], duration: float = 0.0, cmu: Optional[dict] = None) -> Tuple[float, int, float]:
    """Derives flow BPM from word timestamps using median syllable intervals.
    
    Returns (raw_bpm, clock_bpm_estimate, median_syllable_interval).
    """
    if not words:
        return 130.0, 130, 0.4615

    cmu = cmu or polish._get_cmu()
    all_syl_onsets: List[float] = []

    for w_info in words:
        w_text = re.sub(r"[^\w']", "", str(w_info.get("word", "")).lower()).strip()
        if not w_text:
            continue
        start = float(w_info.get("start", 0.0))
        end = float(w_info.get("end", start + 0.2))
        syl_count = max(1, polish.count_cmu_syllables(w_text, cmu))
        duration_w = max(0.05, end - start)

        if syl_count == 1:
            all_syl_onsets.append(start)
        else:
            step = duration_w / syl_count
            for s_idx in range(syl_count):
                all_syl_onsets.append(start + s_idx * step)

    all_syl_onsets.sort()
    if len(all_syl_onsets) < 2:
        return 130.0, 130, 0.4615

    intervals: List[float] = []
    for i in range(len(all_syl_onsets) - 1):
        delta = all_syl_onsets[i + 1] - all_syl_onsets[i]
        # Ignore inter-phrase breath pauses (> 1.2s) and micro-glitches (< 0.04s)
        if 0.04 <= delta <= 1.2:
            intervals.append(delta)

    if not intervals:
        med_interval = 0.4615
    else:
        med_interval = float(statistics.median(intervals))

    if med_interval <= 0:
        med_interval = 0.4615

    raw_bpm = round(60.0 / med_interval, 2)
    clock_bpm, bpm_est = resolve_flow_bpm(raw_bpm)
    return raw_bpm, bpm_est, round(med_interval, 4)


def estimate_median_syllables_per_line(
    whisper_data: Dict[str, Any],
    pause_threshold: float = 0.55,
    cmu: Optional[dict] = None,
) -> Tuple[int, List[int], List[str]]:
    """Segments transcription into lines (via segments or pause thresholds) and counts syllables."""
    cmu = cmu or polish._get_cmu()
    segments = whisper_data.get("segments") or []
    words = whisper_data.get("words") or []
    detected_lines: List[str] = []

    # Priority 1: Whisper native segments if multiple segments present
    if len(segments) > 1:
        for seg in segments:
            t = str(seg.get("text", "")).strip()
            if t:
                detected_lines.append(t)
    elif words:
        # Priority 2: Cluster words by inter-word pause threshold (e.g., breath gaps >= 0.55s)
        current_line_words: List[str] = []
        for i, w in enumerate(words):
            word_str = str(w.get("word", "")).strip()
            if not word_str:
                continue
            current_line_words.append(word_str)
            # Check pause gap to next word
            if i < len(words) - 1:
                gap = float(words[i + 1].get("start", 0.0)) - float(w.get("end", 0.0))
                if gap >= pause_threshold or word_str.endswith((".", "!", "?", "\n")):
                    detected_lines.append(" ".join(current_line_words).strip())
                    current_line_words = []
        if current_line_words:
            detected_lines.append(" ".join(current_line_words).strip())
    else:
        full_text = str(whisper_data.get("text", "")).strip()
        if full_text:
            lines = [l.strip() for l in full_text.splitlines() if l.strip()]
            detected_lines.extend(lines if lines else [full_text])

    line_syllables: List[int] = []
    for line in detected_lines:
        tokens = [re.sub(r"[^\w']", "", tok).lower() for tok in line.split() if tok.strip()]
        s_count = sum(max(1, polish.count_cmu_syllables(tok, cmu)) for tok in tokens if tok)
        if s_count > 0:
            line_syllables.append(s_count)

    if not line_syllables:
        median_syl = 18
    else:
        median_syl = int(round(statistics.median(line_syllables)))

    # Bound to standard hip-hop verse/hook ranges [6, 26]
    bounded_syl = max(6, min(26, median_syl))
    return bounded_syl, line_syllables, detected_lines


def transcribe_audio(
    audio_path: str | Path,
    api_key: Optional[str] = None,
    api_base: Optional[str] = None,
    model: str = "whisper-1",
    mock_response: Optional[Dict[str, Any]] = None,
    timeout: int = 45,
) -> Dict[str, Any]:
    """Transcribes an audio file via OpenAI Whisper REST API with word-level timestamps."""
    if mock_response is not None:
        return mock_response

    p = Path(audio_path).resolve()
    if not p.is_file():
        raise FileNotFoundError(f"Seed audio file not found: {p}")

    api_key = api_key or os.environ.get("OPENAI_API_KEY") or os.environ.get("OMNIROUTE_API_KEY")
    if not api_key:
        raise ValueError("OPENAI_API_KEY or OMNIROUTE_API_KEY required for Whisper audio transcription.")

    api_base = (api_base or os.environ.get("OPENAI_API_BASE") or "https://api.openai.com/v1").rstrip("/")
    url = f"{api_base}/audio/transcriptions"

    mime_type, _ = mimetypes.guess_type(str(p))
    if not mime_type:
        mime_type = "audio/m4a" if p.suffix.lower() == ".m4a" else "application/octet-stream"

    with open(p, "rb") as f:
        audio_bytes = f.read()

    fields = {
        "model": model,
        "response_format": "verbose_json",
        "timestamp_granularities[]": ["word", "segment"],
    }
    files = {
        "file": (p.name, audio_bytes, mime_type),
    }

    body, content_type_header = build_multipart_payload(fields, files)

    req = urllib.request.Request(
        url,
        data=body,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": content_type_header,
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = resp.read().decode("utf-8")
            return json.loads(data)
    except urllib.error.HTTPError as exc:
        err_msg = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"Whisper API HTTP {exc.code} error: {err_msg}") from exc
    except Exception as exc:
        raise RuntimeError(f"Whisper API request failed: {exc}") from exc


def transcribe_and_extract_flow(
    audio_path: str | Path,
    api_key: Optional[str] = None,
    api_base: Optional[str] = None,
    mock_response: Optional[Dict[str, Any]] = None,
    cmu: Optional[dict] = None,
) -> Dict[str, Any]:
    """End-to-end ingestion: transcribes audio and extracts flow BPM and syllable cadence.
    
    Returns:
      {
        "text": str,
        "bpm_estimate": int,
        "raw_bpm": float,
        "median_syl_per_line": int,
        "line_syllables": list[int],
        "lines": list[str],
        "median_syllable_interval": float,
        "words": list[dict],
        "segments": list[dict],
        "duration": float
      }
    """
    whisper_data = transcribe_audio(
        audio_path=audio_path,
        api_key=api_key,
        api_base=api_base,
        mock_response=mock_response,
    )

    cmu = cmu or polish._get_cmu()
    words = whisper_data.get("words") or []
    segments = whisper_data.get("segments") or []
    duration = float(whisper_data.get("duration") or 0.0)
    full_text = str(whisper_data.get("text") or "").strip()

    raw_bpm, bpm_est, med_interval = estimate_bpm_from_timestamps(words, duration=duration, cmu=cmu)
    median_syl, line_syllables, detected_lines = estimate_median_syllables_per_line(whisper_data, cmu=cmu)

    return {
        "text": full_text,
        "bpm_estimate": bpm_est,
        "raw_bpm": raw_bpm,
        "median_syl_per_line": median_syl,
        "line_syllables": line_syllables,
        "lines": detected_lines,
        "median_syllable_interval": med_interval,
        "words": words,
        "segments": segments,
        "duration": duration,
    }


def main():
    parser = argparse.ArgumentParser(description="Whisper Hum-to-Flow Cadence & BPM Extractor")
    parser.add_argument("--audio", "--seed-audio", dest="seed_audio", required=True, help="Path to vocal audio file (.m4a/.wav/.mp3)")
    parser.add_argument("--api-key", default=None, help="OpenAI API key override")
    parser.add_argument("--json", action="store_true", help="Output full JSON flow extraction")
    args = parser.parse_args()

    flow = transcribe_and_extract_flow(args.seed_audio, api_key=args.api_key)

    if args.json:
        print(json.dumps(flow, indent=2))
    else:
        print(f"\n[Whisper Hum-to-Flow Seed] {args.seed_audio}")
        print(f"Transcribed Text: \"{flow['text']}\"")
        print(f"BPM Estimate: {flow['bpm_estimate']} BPM (raw: {flow['raw_bpm']} BPM | interval: {flow['median_syllable_interval']}s)")
        print(f"Median Syllables/Line: {flow['median_syl_per_line']} syl (detected lines: {len(flow['lines'])})")
        for idx, (line, syl) in enumerate(zip(flow["lines"], flow["line_syllables"])):
            print(f"  Line {idx+1:02d} [{syl:2d} syl]: {line}")
        print()


if __name__ == "__main__":
    main()
