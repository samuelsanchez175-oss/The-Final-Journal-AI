#!/usr/bin/env python3
"""Syncs Penwork Studios Frontier v4 documentation into Obsidian vaults.

Places localized, interconnected Markdown reference files in:
1. iCloud Work Studios vault:
   /Users/samuel/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work Studios vault/🧠 Penwork Studios - Model G/Frontier v4 & Studio AI Stack
2. Local OB CLAUDE V1 vault:
   /Users/samuel/Pictures/OB CLAUDE vault/OB CLAUDE V1/🧠 Penwork Studios - Model G/Frontier v4 & Studio AI Stack
"""

import os
import shutil
from pathlib import Path
from datetime import datetime

REPO_ROOT = Path("/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync")
ARTIFACTS_DIR = Path("/Users/samuel/.gemini/antigravity/brain/d69e3416-2a48-4493-bb2b-b214a37b073a")

VAULTS = [
    Path("/Users/samuel/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work Studios vault/🧠 Penwork Studios - Model G/Frontier v4 & Studio AI Stack"),
    Path("/Users/samuel/Pictures/OB CLAUDE vault/OB CLAUDE V1/🧠 Penwork Studios - Model G/Frontier v4 & Studio AI Stack")
]

DOCS_MAP = {
    # Source path -> Target file name in Obsidian
    REPO_ROOT / "docs/model-you/FRONTIER_V4_PLAN.md": "01 Frontier v4 — Master Architecture & Implementation Plan.md",
    REPO_ROOT / "docs/model-you/ANTIGRAVITY_HANDOFF.md": "02 Frontier v4 — Antigravity Engineering Handoff.md",
    REPO_ROOT / "MODEL_G_V2_PRIORITIES.md": "03 Model G v2 & Frontier v4 Engineering Priorities.md",
    REPO_ROOT / "docs/model-you/MODEL_YOU_PLAN.md": "04 Model You — Voice Mimicry & Architecture Plan.md",
    REPO_ROOT / "RAP_AGENT_INTEGRATION_ROADMAP.md": "05 Smart AI Rap Agent — Integration Roadmap.md",
    REPO_ROOT / "tools/style-profile/rater/GROK_HANDOFF.md": "06 Frontier v4 — Grok & Sparkler Rater Engineering Log.md",
    REPO_ROOT / "tools/style-profile/grok_rating_page_prompt.md": "07 Sparkler Rater Page Specification & Prompt.md",
    REPO_ROOT / "docs/architecture-rhyme-rag.md": "08 Architecture — Rhyme RAG & Catalog Ingestion.md",
    REPO_ROOT / "docs/play-on-words/ai-sparkler-style-profile-phases.md": "09 AI Sparkler — Style Profile Phases.md",
    REPO_ROOT / "docs/play-on-words/antigravity_tempo_key_lookup.md": "10 Catalog Reference — Tempo & Musical Key Lookup.md",
    ARTIFACTS_DIR / "model_milestone_report.md": "11 Frontier v4 — Milestone Report & System Benchmarks.md",
    ARTIFACTS_DIR / "v3_architecture_plan.md": "12 Frontier v3 — Multi-Modal Audio Alignment Architecture.md",
}

INDEX_CONTENT = """---
title: Penwork Studios — Frontier v4 & Studio AI Stack Documentation
tags: [penwork-studios, model-g, frontier-v4, architecture, ai-engine, docs]
updated: {date}
---

# 🎙️ Penwork Studios — Frontier v4 & Studio AI Stack Documentation

Welcome to the localized engineering reference for **Penwork Studios** and the **Frontier v4 (QLoRA-free)** rap lyric generation pipeline.

---

## 📑 Core Documentation Index

1. [[01 Frontier v4 — Master Architecture & Implementation Plan]]
   *Complete pivot specification: Reasoning planner (Opus), fast draft (GPT-4o-mini), high-precision polish (GPT-4o), 4x4 Quadrasonic grid gate, and dynamic edit caps.*

2. [[02 Frontier v4 — Antigravity Engineering Handoff]]
   *Detailed task-by-task breakdown of all pipeline stages, dependencies, and integration contracts.*

3. [[03 Model G v2 & Frontier v4 Engineering Priorities]]
   *Core priorities for multisyllabic rhyme schemes, slang/CMU normalization, and cadence adherence.*

4. [[04 Model You — Voice Mimicry & Architecture Plan]]
   *Blueprint for artist persona capture, bag modeling, and catalog grounding.*

5. [[05 Smart AI Rap Agent — Integration Roadmap]]
   *Three core studio engines: Whisper Hum-to-Flow (`--seed-audio`), Genius dataset training, and real-time cadence scoring.*

6. [[06 Frontier v4 — Grok & Sparkler Rater Engineering Log]]
   *Living engineering log documenting Tasks A through S, rater taste blocks, telemetry schema, and style scorer.*

7. [[07 Sparkler Rater Page Specification & Prompt]]
   *Design and data contracts for subjective evaluation (`sparkler.ratings.v1` schema).*

8. [[08 Architecture — Rhyme RAG & Catalog Ingestion]]
   *Database indexing schema (`catalog_bars`), phonetic rime signatures, and SQLite retrieval.*

9. [[09 AI Sparkler — Style Profile Phases]]
   *Step-by-step phases for style profile harvesting, topic chaining, and persona synthesis.*

10. [[10 Catalog Reference — Tempo & Musical Key Lookup]]
    *Curated BPM, musical scales, and mood mappings across major catalog artists.*

11. [[11 Frontier v4 — Milestone Report & System Benchmarks]]
    *Comprehensive milestone status report, unit test suites (68/68 passing), and system performance audit.*

12. [[12 Frontier v3 — Multi-Modal Audio Alignment Architecture]]
    *Quadrasonic 4x4 meter specifications, syllable budgets, and tempo alignment math.*

13. [[13 Frontier v4 — Live 20-Verse Multi-Artist Anthology]]
    *Freshly generated collection of 20 live studio-grade verses across 10 top catalog artists with full bar metrics, grid compliance, and style scores.*

---

## ⚡ Quick CLI Reference

```bash
# Generate a verse with Frontier v4 (Opus Planner + Fast Draft + Frontier Polish)
python3 tools/lyric-llm/frontier_v4.py --voice "Gunna" --bpm 130 --bars 8

# Generate with secondary voice blend (70% Gunna / 30% NoCap)
python3 tools/lyric-llm/frontier_v4.py --voice "Gunna" --blend "NoCap" --mix 70 --bars 8

# Generate from vocal hum/mumble audio file
python3 tools/lyric-llm/frontier_v4.py --voice "Gunna" --seed-audio vocal_hum.m4a

# Launch Local Interactive Studio & Tuning Desk
python3 tools/lyric-llm/desk.py --port 8766 --no-browser

# Run All 12 Automated Regression Test Suites (68/68 Tests)
tools/lyric-llm/.venv/bin/python -m unittest \\
  tools/lyric-llm/test_grid_gate.py \\
  tools/lyric-llm/test_taste_blocks_v4.py \\
  tools/lyric-llm/test_v4_planner.py \\
  tools/lyric-llm/test_frontier_v4.py \\
  tools/lyric-llm/test_catalog_retriever_v2.py \\
  tools/lyric-llm/test_v4_telemetry.py \\
  tools/lyric-llm/test_prompt_cache.py \\
  tools/lyric-llm/test_spotify_popularity.py \\
  tools/lyric-llm/test_entity_guard.py \\
  tools/lyric-llm/test_dynamic_cap.py \\
  tools/lyric-llm/test_section_modes.py \\
  tools/lyric-llm/test_whisper_seed.py
```

---
*Maintained automatically by Penwork Studios AI Engineering.*
"""

def sync():
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    for vault in VAULTS:
        vault.mkdir(parents=True, exist_ok=True)
        print(f"Syncing into {vault}...")

        # Write index
        index_file = vault / "00 Frontier v4 — Master Documentation Index.md"
        index_file.write_text(INDEX_CONTENT.format(date=now_str), encoding="utf-8")
        print(f"  [+] Wrote index: {index_file.name}")

        # Copy docs
        for src, dest_name in DOCS_MAP.items():
            if src.exists():
                content = src.read_text(encoding="utf-8", errors="replace")
                dest_file = vault / dest_name
                # Add obsidian frontmatter if not present
                if not content.startswith("---"):
                    frontmatter = f"---\ntitle: {dest_name.replace('.md', '')}\ntags: [penwork-studios, frontier-v4, docs]\nupdated: {now_str}\n---\n\n"
                    content = frontmatter + content
                dest_file.write_text(content, encoding="utf-8")
                print(f"  [+] Copied: {src.name} -> {dest_name}")
            else:
                print(f"  [!] Source not found: {src}")

if __name__ == "__main__":
    sync()
