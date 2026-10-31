#!/usr/bin/env python3
"""Test Reverse-Rhyme & Best-of-N Candidate Generation for Gunna & NoCap."""

import unittest
from pathlib import Path

_ADAPTER = Path(__file__).resolve().parent / "adapters"
if not _ADAPTER.is_dir():
    raise unittest.SkipTest("missing adapters on disk: adapters")

import time
import random
from pathlib import Path
from mlx_lm import load
import infer
from lyriclib import estimate_syllables, normalize, tokenize, end_rime, load_cmudict

HERE = Path(__file__).resolve().parent
CMU_PATH = HERE.parent.parent / "XJournal AI" / "cmudict.txt"

print("Loading model and adapter...")
t0 = time.time()
model, tokenizer = load("mlx-community/Qwen2.5-3B-Instruct-4bit", adapter_path="adapters")
print(f"Loaded in {time.time() - t0:.2f}s")

cmu = load_cmudict(CMU_PATH) if CMU_PATH.exists() else {}
dna = infer._voice_dna_profile(tokenizer, "Gunna")
nocap_dna = infer._voice_dna_profile(tokenizer, "NoCap")

plan = {
    "voice": "Gunna",
    "blend": "NoCap",
    "left_prefix": "<voice:Gunna> <bpm:130> <scale:F minor> <syl:12>",
    "right_prefix": "<voice:NoCap> <bpm:130> <scale:F minor> <syl:12>",
    "bars": 8,
    "seed": 42,
    "bpm": 130,
    "syl": 12,
    "temperature": 0.8,
    "top_p": 0.95,
}

job = {"title": "70% Gunna / 30% NoCap", "share": 0.70}

print("\n--- Running Candidate-Engine Generation ---")
t1 = time.time()
lines = infer.generate_mixed(model, tokenizer, plan, job)
t_gen = time.time() - t1

print(f"\nGenerated {len(lines)} bars in {t_gen:.2f}s:\n")
for i, l in enumerate(lines, 1):
    s = estimate_syllables(l)
    toks = tokenize(normalize(l))
    w = toks[-1] if toks else ""
    r = "-".join(end_rime(w, cmu)) if (w and cmu and end_rime(w, cmu)) else ""
    print(f"Bar {i:02d} [{s:2d} syl | {w:>10} ({r})]: {l}")
