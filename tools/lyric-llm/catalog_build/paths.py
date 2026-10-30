"""Paths the catalog build reads and writes. Generation does not use this module."""

from __future__ import annotations

from pathlib import Path

LYRIC_ROOT = Path(__file__).resolve().parent.parent
REPO_ROOT = LYRIC_ROOT.parent.parent
OUT = LYRIC_ROOT / "out"
CMU_PATH = REPO_ROOT / "XJournal AI" / "cmudict.txt"
TRAIN_JSONL = OUT / "train.jsonl"
GROUND_TRUTH_CSV = REPO_ROOT / "XJournal AI" / "ground_truth_rap_bars_MODEL_G.csv"
SONG_META = OUT / "song_metadata_cache.json"
DB_PATH = OUT / "catalog_index.sqlite"
SPOTIFY_CACHE = OUT / "spotify_cache.json"
EVAL_PATH = OUT / "catalog_eval.md"
TOPIC_CHAIN = LYRIC_ROOT.parent / "style-profile" / "out" / "topic_chain.jsonl"
