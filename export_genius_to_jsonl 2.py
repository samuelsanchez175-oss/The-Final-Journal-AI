#!/usr/bin/env python3
"""
export_genius_to_jsonl.py
─────────────────────────
Converts The Final AI Journal X's accumulated Genius API lyrics frequency
data into an OpenAI fine-tuning JSONL file for training Model G v3.

USAGE
─────
  python3 export_genius_to_jsonl.py

OUTPUT
──────
  rap_finetune_training.jsonl   → upload to OpenAI for fine-tuning
  rap_finetune_validation.jsonl → optional validation split (10%)

THEN UPLOAD + TRAIN
────────────────────
  1) Upload:
     curl https://api.openai.com/v1/files \\
       -H "Authorization: Bearer $OPENAI_API_KEY" \\
       -F purpose="fine-tune" \\
       -F file="@rap_finetune_training.jsonl"

  2) Train (replace FILE_ID with the id returned above):
     curl https://api.openai.com/v1/fine_tuning/jobs \\
       -H "Authorization: Bearer $OPENAI_API_KEY" \\
       -H "Content-Type: application/json" \\
       -d '{"training_file": "FILE_ID", "model": "gpt-4o-mini"}'

  3) Swap model ID in RapSuggestionAPI.swift:
     case .modelGv3:
         return "ft:gpt-4o-mini:your-org:rap-agent-v3:XXXXXXXX"
"""

import json
import os
import random
import re
from pathlib import Path

# ─────────────────────────────────────────────────────────────────
# CONFIG — adjust paths if needed
# ─────────────────────────────────────────────────────────────────

# Possible locations for the accumulated Genius data (app group container)
ACCUMULATED_DATA_PATHS = [
    Path.home() / "Library/Group Containers/group.com.finaljournal.app/accumulated_lyrics_frequency.json",
    Path("XJournal AI/lyrics_frequency.json"),
    Path("lyrics_frequency.json"),
]

# CSV ground truth files (if present in the project)
CSV_SEARCH_DIRS = [
    Path("XJournal AI"),
    Path("."),
]

OUTPUT_TRAIN = Path("rap_finetune_training.jsonl")
OUTPUT_VAL   = Path("rap_finetune_validation.jsonl")

VALIDATION_SPLIT = 0.10   # 10% held out for validation
MIN_EXAMPLES     = 50     # Warn if below this
TARGET_EXAMPLES  = 500    # Ideal target


# ─────────────────────────────────────────────────────────────────
# SYSTEM PROMPT (mirrors Model G v3 in RapSuggestionAPI.swift)
# ─────────────────────────────────────────────────────────────────

SYSTEM_PROMPT = """You are Model G v3 (SUPERG): an upgraded melodic-trap rap writer operating at the highest phonetic precision. You produce original Gunna-adjacent quality without copying existing lyrics.

Output exactly 4 bars per suggestion. No headings, bullets, or explanations — ONLY the 4 bars.

RULES:
- Multi-syllabic end rhymes required (2+ syllables rhyme per end word)
- All 4 bars must contain internal rhyme or strong assonance
- Target 8-10 syllables per bar, hard cap 13
- Zero filler words (no "yeah", "uh", "you know", "listen up")
- 4 bars form a single mini-story arc: setup → detail → escalation → close
- Calm, unbothered, transactional confidence
- Concrete micro-scenes, understated flex, original phrasing only"""


# ─────────────────────────────────────────────────────────────────
# EXAMPLE GENERATION PROMPTS
# These are the user-turn templates we'll fill with real words/themes
# ─────────────────────────────────────────────────────────────────

PROMPT_TEMPLATES = [
    "Write 4 bars. Rhyme family: {rhyme_family}. Theme: {theme}. Tone: {tone}.",
    "Generate 4 bars on theme: {theme}. End rhyme family: {rhyme_family}. Emotional tone: {tone}.",
    "4 bars. Theme: {theme}. Tone: {tone}. Use multi-syllabic rhymes ending in: {rhyme_family}.",
    "Write a 4-bar verse. Subject: {theme}. Rhyme scheme: AABB. Rhyme family: {rhyme_family}. Energy: {tone}.",
    "4-bar trap verse. Rhyme family: {rhyme_family}. Concept: {theme}. Voice: {tone}.",
]

THEMES = [
    "wealth and success", "loyalty and trust", "hustle and grind", "luxury lifestyle",
    "street life", "relationships", "flexing and status", "coming up from nothing",
    "family and sacrifice", "enemies and betrayal", "travel and freedom",
    "nightlife", "fashion and drip", "cars and jewelry", "staying focused",
    "money over everything", "proving doubters wrong", "success feels lonely",
    "trap life transition", "getting rich in silence",
]

TONES = [
    "confident", "unbothered", "reflective", "hungry", "celebratory",
    "detached", "assertive", "melancholic", "triumphant", "cold",
]

# Common melodic-trap rhyme families (vowel + coda pattern descriptions)
RHYME_FAMILIES = [
    "-AY1-T (late/great/weight/fate)",
    "-AY1-N (rain/chain/pain/gain)",
    "-IY1-P (deep/sleep/keep/creep)",
    "-OW1-N (zone/phone/alone/stone)",
    "-AH1-N (run/done/one/gun)",
    "-EY1 (way/play/stay/day)",
    "-AY1 (time/night/find/mind)",
    "-IY1-N (clean/mean/green/seen)",
    "-OW1-L (soul/whole/control/roll)",
    "-AH1-NG (young/lung/tongue/sung)",
    "-AE1-K (back/stack/track/crack)",
    "-EH1-D (head/bread/said/led)",
    "-IH1-T (hit/split/lit/wit)",
    "-UW1-P (loop/scoop/group/soup)",
    "-AO1-L (ball/fall/call/all)",
]


# ─────────────────────────────────────────────────────────────────
# LOAD SOURCE DATA
# ─────────────────────────────────────────────────────────────────

def load_accumulated_lyrics() -> dict:
    """Load accumulated_lyrics_frequency.json from any known location."""
    for path in ACCUMULATED_DATA_PATHS:
        if path.exists():
            print(f"✓ Found lyrics frequency data: {path}")
            with open(path) as f:
                return json.load(f)
    print("⚠  No accumulated_lyrics_frequency.json found. Using built-in word lists only.")
    return {}


def load_csv_ground_truth() -> list[str]:
    """Load any CSV files in the project that contain ground truth lyrics."""
    lines = []
    for search_dir in CSV_SEARCH_DIRS:
        for csv_file in search_dir.glob("**/*.csv"):
            try:
                with open(csv_file, encoding="utf-8", errors="ignore") as f:
                    for line in f:
                        stripped = line.strip()
                        if len(stripped) > 15 and not stripped.startswith("#"):
                            lines.append(stripped)
                print(f"✓ Loaded {len(lines)} lines from {csv_file}")
            except Exception as e:
                print(f"⚠  Could not read {csv_file}: {e}")
    return lines


# ─────────────────────────────────────────────────────────────────
# TRAINING EXAMPLE BUILDERS
# ─────────────────────────────────────────────────────────────────

def build_prompt_completion_pair(theme: str, tone: str, rhyme_family: str,
                                  completion: str) -> dict:
    """Build a single fine-tuning example in OpenAI chat format."""
    template = random.choice(PROMPT_TEMPLATES)
    user_msg = template.format(theme=theme, tone=tone, rhyme_family=rhyme_family)
    return {
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user",   "content": user_msg},
            {"role": "assistant", "content": completion.strip()},
        ]
    }


def extract_bar_blocks_from_lines(lines: list[str]) -> list[str]:
    """
    Try to group CSV/lyrics lines into 4-bar blocks for training completions.
    Groups consecutive non-empty lines into blocks of 4.
    """
    blocks = []
    buffer = []
    for line in lines:
        clean = line.strip()
        if not clean:
            if len(buffer) >= 4:
                block = "\n".join(buffer[:4])
                if block_looks_like_rap(block):
                    blocks.append(block)
            buffer = []
        else:
            buffer.append(clean)
    # flush
    if len(buffer) >= 4:
        block = "\n".join(buffer[:4])
        if block_looks_like_rap(block):
            blocks.append(block)
    return blocks


def block_looks_like_rap(block: str) -> bool:
    """Basic quality filter — skip blocks that are too short or look like headers."""
    lines = [l.strip() for l in block.split("\n") if l.strip()]
    if len(lines) < 4:
        return False
    avg_len = sum(len(l) for l in lines) / len(lines)
    if avg_len < 20:   # too short, probably headers
        return False
    if avg_len > 120:  # too long, probably paragraphs
        return False
    return True


def generate_synthetic_examples(n: int) -> list[dict]:
    """
    Generate synthetic prompt/completion pairs by combining random themes,
    tones, and rhyme families. These are scaffolded examples — good for
    teaching the model the output FORMAT, not necessarily perfect content.
    The real value comes from CSV ground truth completions.
    """
    examples = []
    for _ in range(n):
        theme = random.choice(THEMES)
        tone  = random.choice(TONES)
        rf    = random.choice(RHYME_FAMILIES)

        # Build a simple synthetic 4-bar completion as a scaffold
        # These are intentionally minimal — real bars come from CSV
        completion = generate_scaffold_bars(theme, tone)
        examples.append(build_prompt_completion_pair(theme, tone, rf, completion))
    return examples


def generate_scaffold_bars(theme: str, tone: str) -> str:
    """
    Returns a minimal 4-bar scaffold. These teach format, not content.
    Real completions from CSV will carry the actual rap quality.
    """
    scaffolds = [
        "I been on my grind since the sun went down\nPaper stackin' silent, barely make a sound\nEvery move I make gotta count for somethin'\nRose from nothin', now I'm way above it",
        "Designer on my body, got the bag secured\nChain on my neck and my future insured\nTold my mama wait, now she livin' good\nDid exactly what they said I never could",
        "Wrist cost a quarter, diamonds start to dance\nTook the long route, never left it to chance\nPull up in the coupe with the curtains on\nSee me in the morning like the rise of dawn",
        "I been in the trenches where the nights was cold\nNow my pockets heavy and my story's told\nEvery hater watching through a broken glass\nMade it out the mud and I'm moving fast",
        "Step inside the room and the energy shift\nDrip on automatic, every bar a gift\nBuilt this from the bottom with my hands alone\nNow I'm at the top and I'm on the throne",
    ]
    return random.choice(scaffolds)


# ─────────────────────────────────────────────────────────────────
# MAIN EXPORT LOGIC
# ─────────────────────────────────────────────────────────────────

def main():
    print("\n═══════════════════════════════════════════════════")
    print("  Final AI Journal X — Model G v3 Fine-Tune Export")
    print("═══════════════════════════════════════════════════\n")

    # 1. Load source data
    lyrics_freq = load_accumulated_lyrics()
    csv_lines   = load_csv_ground_truth()

    all_examples: list[dict] = []

    # 2. Build examples from CSV ground truth (highest quality)
    if csv_lines:
        bar_blocks = extract_bar_blocks_from_lines(csv_lines)
        print(f"✓ Extracted {len(bar_blocks)} 4-bar blocks from CSV ground truth")

        for block in bar_blocks:
            theme = random.choice(THEMES)
            tone  = random.choice(TONES)
            rf    = random.choice(RHYME_FAMILIES)
            all_examples.append(build_prompt_completion_pair(theme, tone, rf, block))
    else:
        print("ℹ  No CSV ground truth found — using synthetic scaffolds only")

    # 3. Supplement with synthetic examples if below target
    current = len(all_examples)
    if current < TARGET_EXAMPLES:
        needed = TARGET_EXAMPLES - current
        print(f"ℹ  Adding {needed} synthetic scaffold examples to reach target of {TARGET_EXAMPLES}")
        all_examples.extend(generate_synthetic_examples(needed))

    # 4. Shuffle
    random.shuffle(all_examples)

    # 5. Split train / validation
    val_count   = max(1, int(len(all_examples) * VALIDATION_SPLIT))
    train_count = len(all_examples) - val_count
    train_examples = all_examples[:train_count]
    val_examples   = all_examples[train_count:]

    # 6. Write JSONL files
    def write_jsonl(path: Path, examples: list[dict]):
        with open(path, "w", encoding="utf-8") as f:
            for ex in examples:
                f.write(json.dumps(ex, ensure_ascii=False) + "\n")

    write_jsonl(OUTPUT_TRAIN, train_examples)
    write_jsonl(OUTPUT_VAL,   val_examples)

    # 7. Summary
    print(f"\n✅ Export complete:")
    print(f"   Training examples : {train_count}  → {OUTPUT_TRAIN}")
    print(f"   Validation examples: {val_count}  → {OUTPUT_VAL}")

    if train_count < MIN_EXAMPLES:
        print(f"\n⚠  WARNING: Only {train_count} training examples. OpenAI recommends ≥50.")
        print("   Add more CSV ground truth or Genius API data and re-run.")
    elif train_count < 100:
        print(f"\n⚠  NOTE: {train_count} examples is the minimum. 500+ gives much better results.")
    else:
        print(f"\n✓  Good dataset size. Proceed to upload + train.")

    print("\nNEXT STEPS:")
    print("  1) Upload training file:")
    print(f"     curl https://api.openai.com/v1/files \\")
    print(f'       -H "Authorization: Bearer $OPENAI_API_KEY" \\')
    print(f'       -F purpose="fine-tune" \\')
    print(f'       -F file="@{OUTPUT_TRAIN}"')
    print()
    print("  2) Start fine-tune job (use file ID returned above):")
    print(f'     curl https://api.openai.com/v1/fine_tuning/jobs \\')
    print(f'       -H "Authorization: Bearer $OPENAI_API_KEY" \\')
    print(f'       -H "Content-Type: application/json" \\')
    print(f"       -d '{{\"training_file\": \"FILE_ID\", \"model\": \"gpt-4o-mini\"}}'")
    print()
    print("  3) When training completes, copy the model ID and update RapSuggestionAPI.swift:")
    print('     case .modelGv3: return "ft:gpt-4o-mini:your-org:rap-agent-v3:XXXXXXXX"')
    print()


if __name__ == "__main__":
    main()
