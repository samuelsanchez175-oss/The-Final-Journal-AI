#!/usr/bin/env python3
"""Unit tests for Frontier v4 Task S: Whisper Hum-to-Flow Seed Audio Ingestion.

Acceptance criteria from FRONTIER_V4_PLAN.md:
- tools/lyric-llm/test_whisper_seed.py — mock the Whisper API; assert BPM and syl calc.
- CLI arg --seed-audio file.m4a on frontier_v4.py and desk.py.
- Return {text, bpm_estimate, median_syl_per_line}.
- v4 picks up bpm_estimate and median_syl_per_line as defaults if user didn't pass them.
"""

from __future__ import annotations

import os
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

HERE = Path(__file__).resolve().parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

import desk
import frontier_v4
import polish
import whisper_seed
from whisper_seed import (
    build_multipart_payload,
    estimate_bpm_from_timestamps,
    estimate_median_syllables_per_line,
    resolve_flow_bpm,
    transcribe_and_extract_flow,
    transcribe_audio,
)


class TestWhisperSeed(unittest.TestCase):
    def setUp(self):
        self.cmu = polish._get_cmu()

    def test_build_multipart_payload(self):
        """Verifies standard-library multipart form data generation."""
        fields = {
            "model": "whisper-1",
            "response_format": "verbose_json",
            "timestamp_granularities[]": ["word", "segment"],
        }
        files = {
            "file": ("test_hum.m4a", b"\x00\x01\x02\x03FAKE_AUDIO_DATA", "audio/m4a"),
        }
        body, content_type = build_multipart_payload(fields, files, boundary="TEST_BOUNDARY_12345")
        self.assertIn("multipart/form-data; boundary=TEST_BOUNDARY_12345", content_type)
        body_str = body.decode("latin1")
        self.assertIn('--TEST_BOUNDARY_12345\r\nContent-Disposition: form-data; name="model"\r\n\r\nwhisper-1\r\n', body_str)
        self.assertIn('name="file"; filename="test_hum.m4a"\r\nContent-Type: audio/m4a\r\n\r\n', body_str)
        self.assertIn("FAKE_AUDIO_DATA", body_str)
        self.assertTrue(body_str.endswith("--TEST_BOUNDARY_12345--\r\n"))

    def test_resolve_flow_bpm(self):
        """Tests that half-time and double-time flows normalize into hip-hop/trap clock range."""
        # 140 BPM direct
        clock, est = resolve_flow_bpm(140.0)
        self.assertEqual(est, 140)

        # 70 BPM Halftime -> 140 BPM Clock
        clock, est = resolve_flow_bpm(70.0)
        self.assertEqual(est, 140)

        # 65 BPM Halftime -> 130 BPM Clock
        clock, est = resolve_flow_bpm(65.0)
        self.assertEqual(est, 130)

        # 260 BPM Double-time -> 130 BPM Clock
        clock, est = resolve_flow_bpm(260.0)
        self.assertEqual(est, 130)

        # 280 BPM Double-time -> 140 BPM Clock
        clock, est = resolve_flow_bpm(280.0)
        self.assertEqual(est, 140)

    def test_estimate_bpm_from_timestamps_140bpm(self):
        """Tests BPM derivation from words timed at 140 BPM (0.4286s interval)."""
        # Create 8 words spaced exactly at 0.4286s intervals (~140 BPM)
        interval = 60.0 / 140.0  # 0.42857s
        words = []
        for i in range(8):
            start = i * interval
            end = start + 0.35
            words.append({"word": "cash", "start": start, "end": end})

        raw_bpm, clock_bpm, med_int = estimate_bpm_from_timestamps(words, duration=8 * interval, cmu=self.cmu)
        self.assertAlmostEqual(med_int, interval, places=2)
        self.assertEqual(clock_bpm, 140)
        self.assertAlmostEqual(raw_bpm, 140.0, places=0)

    def test_estimate_bpm_from_timestamps_halftime_normalized(self):
        """Tests that a slow 70 BPM hum is recognized and normalized to 140 Clock BPM."""
        interval = 60.0 / 70.0  # ~0.857s
        words = []
        for i in range(6):
            start = i * interval
            end = start + 0.50
            words.append({"word": "stack", "start": start, "end": end})

        raw_bpm, clock_bpm, med_int = estimate_bpm_from_timestamps(words, duration=6 * interval, cmu=self.cmu)
        self.assertAlmostEqual(raw_bpm, 70.0, places=0)
        self.assertEqual(clock_bpm, 140)

    def test_estimate_median_syllables_per_line_segments(self):
        """Tests syllable estimation across Whisper segments."""
        mock_whisper = {
            "text": "Yeah count up the money in the morning\nForeign coupe rolling through the warning\nDiamonds on my wrist they keep on shining\nNever look behind I keep on climbing",
            "segments": [
                {"id": 0, "text": "Yeah count up the money in the morning", "start": 0.0, "end": 2.2},  # 10 syl
                {"id": 1, "text": "Foreign coupe rolling through the warning", "start": 2.8, "end": 5.0},  # 9 syl
                {"id": 2, "text": "Diamonds on my wrist they keep on shining", "start": 5.5, "end": 7.7},  # 10 syl
                {"id": 3, "text": "Never look behind I keep on climbing", "start": 8.3, "end": 10.5},     # 10 syl
            ],
            "words": [],
        }
        med_syl, line_syls, lines = estimate_median_syllables_per_line(mock_whisper, cmu=self.cmu)
        self.assertEqual(len(lines), 4)
        self.assertEqual(len(line_syls), 4)
        self.assertEqual(med_syl, 10)
        self.assertIn(10, line_syls)
        self.assertIn(9, line_syls)

    def test_estimate_median_syllables_per_line_pause_clustering(self):
        """Tests word clustering into lines using breath gaps (>= 0.55s)."""
        words = [
            # Line 1: 0.0s -> 1.0s (3 words)
            {"word": "Bank", "start": 0.0, "end": 0.3},
            {"word": "on", "start": 0.35, "end": 0.6},
            {"word": "me", "start": 0.65, "end": 1.0},
            # Breath gap of 0.8s (1.0 -> 1.8s) -> Line break!
            # Line 2: 1.8s -> 2.8s (3 words)
            {"word": "Watch", "start": 1.8, "end": 2.1},
            {"word": "it", "start": 2.15, "end": 2.4},
            {"word": "grow", "start": 2.45, "end": 2.8},
        ]
        mock_whisper = {"text": "Bank on me Watch it grow", "segments": [], "words": words}
        med_syl, line_syls, lines = estimate_median_syllables_per_line(mock_whisper, pause_threshold=0.55, cmu=self.cmu)
        self.assertEqual(len(lines), 2)
        self.assertEqual(lines[0], "Bank on me")
        self.assertEqual(lines[1], "Watch it grow")
        self.assertEqual(line_syls, [3, 3])
        self.assertEqual(med_syl, 6)  # Bounded min is 6

    def test_transcribe_and_extract_flow_end_to_end_mock(self):
        """Tests complete end-to-end flow extraction from mock Whisper response."""
        interval = 60.0 / 130.0  # ~0.4615s (130 BPM)
        mock_words = []
        for i in range(12):
            start = i * interval
            end = start + 0.35
            mock_words.append({"word": "cash", "start": start, "end": end})

        mock_response = {
            "text": "Cash on cash in the bank all day\nStack my cash till it blow away",
            "duration": 6.0,
            "words": mock_words,
            "segments": [
                {"id": 0, "text": "Cash on cash in the bank all day", "start": 0.0, "end": 2.5},
                {"id": 1, "text": "Stack my cash till it blow away", "start": 3.0, "end": 5.8},
            ],
        }

        flow = transcribe_and_extract_flow(
            audio_path="mock_audio.m4a",
            mock_response=mock_response,
            cmu=self.cmu,
        )

        self.assertIn("text", flow)
        self.assertIn("bpm_estimate", flow)
        self.assertIn("median_syl_per_line", flow)
        self.assertIn("line_syllables", flow)
        self.assertIn("lines", flow)
        self.assertEqual(flow["bpm_estimate"], 130)
        self.assertEqual(flow["text"], "Cash on cash in the bank all day\nStack my cash till it blow away")
        self.assertEqual(len(flow["lines"]), 2)
        self.assertEqual(flow["duration"], 6.0)

    def test_frontier_v4_seed_audio_integration(self):
        """Verifies that frontier_v4.generate_v4 adopts flow BPM and syl budget when not explicitly provided."""
        mock_flow = {
            "text": "Money multiply foreign coupe roll by",
            "bpm_estimate": 145,
            "median_syl_per_line": 12,
            "lines": ["Money multiply", "foreign coupe roll by"],
            "line_syllables": [5, 6],
            "raw_bpm": 145.0,
            "median_syllable_interval": 0.4138,
            "words": [],
            "segments": [],
            "duration": 4.0,
        }

        # Mock LLM call_fn to return 4 valid 4x4 bars
        def mock_llm_fn(sys_prompt: str, user_prompt: str) -> str:
            return (
                "Bank on me, watch the money multiply, coupe outside, rolling by\n"
                "Diamonds bright, shining in the daylight, hold the wheel, hold it tight\n"
                "In the lab, cooking up a new track, got the bag, brought it back\n"
                "Solid gold, story never been told, keep the faith, never fold"
            )

        res = frontier_v4.generate_v4(
            voice="Gunna",
            bars_count=4,
            bpm=None,         # Omitted -> should pick up 145 from audio flow
            target_syl=None,  # Omitted -> should pick up 12 from audio flow
            seed_line="",     # Omitted -> should pick up text from audio flow
            audio_flow_override=mock_flow,
            use_cache=False,
            call_fn=mock_llm_fn,
        )

        self.assertTrue(res["ok"])
        self.assertEqual(res["bpm"], 145.0)
        self.assertEqual(res["clock_bpm"], 145.0)
        self.assertEqual(res["target_syllables"], 12)
        self.assertEqual(res["audio_flow"], mock_flow)

    def test_desk_live_generation_seed_audio(self):
        """Verifies that desk.run_live_generation consumes seed_audio parameter."""
        mock_flow = {
            "text": "Living lavish stacking paper every day",
            "bpm_estimate": 136,
            "median_syl_per_line": 11,
            "lines": ["Living lavish stacking paper every day"],
            "line_syllables": [11],
            "raw_bpm": 136.0,
            "median_syllable_interval": 0.4412,
            "words": [],
            "segments": [],
            "duration": 3.0,
        }

        with patch("whisper_seed.transcribe_and_extract_flow", return_value=mock_flow):
            with patch("frontier_v4.generate_v4") as mock_v4:
                mock_v4.return_value = {"ok": True, "provider": "mock"}
                params = {
                    "adapter": "v4",
                    "seed_audio": "freestyle_take_1.m4a",
                    "voice": "Gunna",
                    "bars": 4,
                }
                res = desk.run_live_generation(HERE, params)
                self.assertTrue(res.get("ok"))
                # Check that frontier_v4.generate_v4 was called with bpm=136 and target_syl=11
                _, kwargs = mock_v4.call_args
                self.assertEqual(kwargs.get("bpm"), 136.0)
                self.assertEqual(kwargs.get("target_syl"), 11)
                self.assertEqual(kwargs.get("seed_audio"), "freestyle_take_1.m4a")
                self.assertEqual(kwargs.get("seed_line"), "Living lavish stacking paper every day")


if __name__ == "__main__":
    unittest.main()
