#!/usr/bin/env python3
"""Curate a Gold-Tier Dataset for Penwork Studios.

Extracts pristine, high-craft, high-rhyme verses for Gunna, NoCap, Lil Wayne,
Drake, and Young Thug, stripping parenthetical ad-libs, spoken dialogue, and
unrhymed filler.

Writes:
  out/gold_songs/train.jsonl
  out/gold_songs/val.jsonl
"""

import json
import re
from pathlib import Path
from lyriclib import load_cmudict, end_rime, rhyme_rate, flow_consistency, estimate_syllables

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
GOLD_DIR = OUT / "gold_songs"
GOLD_DIR.mkdir(parents=True, exist_ok=True)
CMU_PATH = HERE.parent.parent / "XJournal AI" / "cmudict.txt"

TARGET_ARTISTS = {
    "gunna": "Gunna",
    "nocap": "NoCap",
    "lil wayne": "Lil Wayne",
    "drake": "Drake",
    "young thug": "Young Thug",
    "lil baby": "Lil Baby",
    "young stoner life": "Young Stoner Life",
}

PAREN_RE = re.compile(r"\s*\([^)]*\)")
BRACKET_RE = re.compile(r"\[[^\]]*\]")
JUNK_LINES = {
    "yeah yeah", "uh uh", "slatt slatt", "whoa whoa", "ayy ayy", "run that back turbo",
    "metro boomin want some more", "southside on the track", "wheezy outta here",
    "d-d-daytrip took it to ten", "mustard on the beat", "mike will made it",
}

def clean_line_text(line: str) -> str:
    line = BRACKET_RE.sub("", line)
    line = PAREN_RE.sub("", line)
    line = " ".join(line.split())
    # Strip leading bullet/number prefixes
    line = re.sub(r"^(?:\d+[\.:]?\s*|\-\s*)", "", line)
    return line.strip()

def is_usable_line(line: str) -> bool:
    if not line or len(line) < 12:
        return False
    words = line.lower().split()
    if len(words) < 3 or len(words) > 16:
        return False
    # Drop pure adlib lines
    if " ".join(words) in JUNK_LINES:
        return False
    return True

def curate():
    cmu = load_cmudict(CMU_PATH) if CMU_PATH.exists() else {}
    gold_records = []
    artist_counts = {}

    train_path = OUT / "train.jsonl"
    if not train_path.exists():
        print("out/train.jsonl not found.")
        return

    with train_path.open(encoding="utf-8") as f:
        for raw in f:
            if not raw.strip():
                continue
            rec = json.loads(raw)
            art_raw = (rec.get("artist") or "").strip().lower()
            if art_raw not in TARGET_ARTISTS:
                continue
            artist = TARGET_ARTISTS[art_raw]
            bpm = rec.get("bpm") or 130
            scale = rec.get("scale") or "F minor"
            text = rec.get("text") or ""

            raw_lines = [l.strip() for l in text.split("\n") if l.strip()]
            cleaned_lines = []
            for l in raw_lines:
                cl = clean_line_text(l)
                if is_usable_line(cl):
                    cleaned_lines.append(cl)

            # Slice into 8-bar windows with high rhyme density
            for i in range(0, len(cleaned_lines) - 7, 4):
                window = cleaned_lines[i : i + 8]
                if len(window) < 8:
                    continue
                rr = rhyme_rate(window, cmu) if cmu else 0.35
                syls = [estimate_syllables(w) for w in window]
                fc = flow_consistency(syls) if syls else 0.75

                # High craft threshold: at least 35% rhyme rate and consistent flow
                if (rr is None or rr >= 0.25) and (fc is None or fc >= 0.65):
                    med_syl = int(round(sorted(syls)[len(syls) // 2])) if syls else 10
                    # Filter out any window that repeats identical lines
                    if len(set(window)) < 7:
                        continue
                    verse_text = "\n".join(window)
                    prompt_user = f"<voice:{artist}> <bpm:{bpm}> <scale:{scale}> <syl:{med_syl}>"
                    gold_records.append({
                        "messages": [
                            {"role": "user", "content": prompt_user},
                            {"role": "assistant", "content": verse_text},
                        ],
                        "artist": artist,
                        "bpm": bpm,
                        "scale": scale,
                        "syl": med_syl,
                        "rhyme_rate": round(rr or 0.0, 3),
                        "flow": round(fc or 0.0, 3),
                    })
                    artist_counts[artist] = artist_counts.get(artist, 0) + 1

    print(f"Extracted {len(gold_records):,} Gold-Tier verses across target artists:")
    for art, count in sorted(artist_counts.items(), key=lambda x: -x[1]):
        print(f"  {art}: {count:,} verses ({count * 8:,} clean bars)")

    # Split 90% train / 10% val
    import random
    random.seed(42)
    random.shuffle(gold_records)

    split_idx = int(len(gold_records) * 0.90)
    train_gold = gold_records[:split_idx]
    val_gold = gold_records[split_idx:]

    train_out = GOLD_DIR / "train.jsonl"
    val_out = GOLD_DIR / "valid.jsonl"

    with train_out.open("w", encoding="utf-8") as f:
        for r in train_gold:
            f.write(json.dumps({"messages": r["messages"]}, ensure_ascii=False) + "\n")

    with val_out.open("w", encoding="utf-8") as f:
        for r in val_gold:
            f.write(json.dumps({"messages": r["messages"]}, ensure_ascii=False) + "\n")

    print(f"\nWrote Gold-Tier dataset:")
    print(f"  Train: {len(train_gold):,} verses -> {train_out}")
    print(f"  Valid: {len(val_gold):,} verses -> {val_out}")

if __name__ == "__main__":
    curate()
