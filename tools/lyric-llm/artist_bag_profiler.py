#!/usr/bin/env python3
"""Penwork Studios: Artist Multi-Bag & Musical Conditioning Metric Profiler.

Evaluates multi-dimensional artist personas beyond one-dimensional stereotypes:
  - Gunna: Faith & Hope, In The Ditch / Betrayal, Luxury Drip, Punchlines/Metaphors, Melodic Flow, Fast Technical Pocket.
  - Correlates emotional bags with Musical Context (Tempo / BPM, Key Root, Scale / Mode: Minor vs Major).
  - Measures ADHD line-to-line topic transition velocity and conditional distribution metrics.
"""

from __future__ import annotations

import csv
import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Any, Tuple

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
CSV_PATH = REPO_ROOT / "XJournal AI" / "ground_truth_rap_bars_MODEL_G.csv"
TEMPO_CACHE = REPO_ROOT / "tools" / "style-profile" / "out" / "tempo_cache.jsonl"
OUT_DIR = HERE / "out"
OUT_DIR.mkdir(exist_ok=True, parents=True)
OUT_JSON = OUT_DIR / "artist_multibag_metrics.json"

# Cardinal Emotional / Thematic Bags
BAG_DEFINITIONS = {
    "faith_hope": {
        "title": "Religious, Faith & Spiritual Hope",
        "description": "Praying to God, asking for protection, karma, spiritual gratitude, church, blessings, soul.",
        "keywords": [
            "god", "pray", "praying", "prayer", "church", "lord", "blessed", "blessing",
            "faith", "hope", "soul", "knees", "amen", "forgive", "forgiven", "heaven",
            "grace", "sins", "cross", "savior", "thank god", "thank the lord", "on my knees",
            "higher power", "preacher", "holy", "bible", "spirit", "hallelujah"
        ],
        "weight": 1.2
    },
    "pain_ditch_betrayal": {
        "title": "In The Ditch, Pain & Betrayal",
        "description": "Feeling isolated, sitting in a ditch, snitch allegations, fake friends, jail cells, scars, paranoia.",
        "keywords": [
            "ditch", "in a ditch", "jail", "cell", "locked", "behind bars", "feds", "case",
            "betray", "betrayed", "backstab", "turned your back", "fake", "fake friends",
            "snitch", "snitching", "rumors", "scars", "alone", "lonely", "pain", "hurt",
            "cry", "tears", "trauma", "suffer", "hardship", "mud", "struggle", "lost",
            "judge", "court", "sentence", "prison", "paranoia", "trust nobody", "bleed",
            "bleeding", "broken", "grief", "mourn", "darkness", "depressed", "anxiety"
        ],
        "weight": 1.15
    },
    "luxury_drip": {
        "title": "Luxury Drip, Designer & Wealth",
        "description": "Designer fashion, Maybachs, Pateks, jewelry, diamonds, wealth, effortless nonchalant flex.",
        "keywords": [
            "drip", "maybach", "bentley", "patek", "rollie", "rolex", "celine", "chanel",
            "prada", "louis", "designer", "ice", "diamonds", "bezel", "foreign", "wraith",
            "lambo", "ferrari", "mansion", "penthouse", "racks", "hundreds", "cash", "money",
            "rich", "wealth", "yacht", "cullinan", "audemars", "cartier", "vvs", "balenciaga",
            "billionaire", "millionaire", "private jet", "richer", "baguette"
        ],
        "weight": 1.0
    },
    "punchlines_metaphors": {
        "title": "Slick Punchlines, Metaphors & Wordplay",
        "description": "Clever double meanings, sharp analogies, witty similes, finance/street wordplay.",
        "keywords": [
            "like a", "look like", "feel like", "sound like", "taste like", "metaphor",
            "steel", "steal", "peace", "piece", "bank", "chase", "check", "chess",
            "board", "game", "score", "court", "shoot", "strike", "foul", "ring",
            "trophy", "champion", "double meaning", "play on words", "puzzle", "riddle"
        ],
        "weight": 1.1
    },
    "melodic_flow": {
        "title": "Melodic Cadence & Atmospheric Float",
        "description": "Flowing vowel elongation, smooth vocal pockets, melodic half-singing, atmospheric ease.",
        "keywords": [
            "vibe", "vibes", "sing", "melody", "tune", "harmonize", "float", "floating",
            "smooth", "breeze", "wave", "sea", "ocean", "tide", "slide", "glide",
            "melodic", "serenade", "rhythm", "soulful", "air", "clouds", "sky"
        ],
        "weight": 1.05
    },
    "fast_pocket": {
        "title": "Fast-Paced Relentless Technical Pocket",
        "description": "Rapid-fire 16th delivery, high syllable velocity, breathless technical runs.",
        "keywords": [
            "fast", "speed", "rush", "turbo", "dash", "quick", "flying", "zoom", "race",
            "relentless", "run", "running", "sprint", "chase", "pace", "gas", "pedal"
        ],
        "weight": 1.0
    }
}


def load_tempo_cache() -> Dict[str, Dict[str, Any]]:
    """Load per-song tempo, key, and scale metrics from tempo_cache.jsonl."""
    metadata = {}
    if not TEMPO_CACHE.exists():
        return metadata

    with open(TEMPO_CACHE, "r", encoding="utf-8") as f:
        for line in f:
            try:
                obj = json.loads(line.strip())
                artist = (obj.get("artist") or "").strip().lower()
                song = (obj.get("song") or "").strip().lower()
                if not artist or not song:
                    continue
                key_id = f"{artist}::{song}"
                if key_id not in metadata:
                    metadata[key_id] = {}

                if "tempo" in obj and obj["tempo"] is not None:
                    metadata[key_id]["tempo"] = float(obj["tempo"])
                if "scale" in obj and obj["scale"] is not None:
                    metadata[key_id]["scale"] = str(obj["scale"]).lower()
                if "key_root" in obj and obj["key_root"] is not None:
                    metadata[key_id]["key_root"] = str(obj["key_root"])
                if "valence" in obj and obj["valence"] is not None:
                    metadata[key_id]["valence"] = float(obj["valence"])
                if "energy" in obj and obj["energy"] is not None:
                    metadata[key_id]["energy"] = float(obj["energy"])
            except Exception:
                continue
    return metadata


def classify_bar_bag(text: str, tone_primary: str = "", auth_class: str = "") -> Tuple[str, float]:
    """Score a bar against cardinal bags and return primary bag and confidence."""
    norm_text = text.lower()
    combined_context = f"{norm_text} {tone_primary.lower()} {auth_class.lower()}"

    scores = {}
    for bag_name, defn in BAG_DEFINITIONS.items():
        score = 0.0
        for kw in defn["keywords"]:
            if " " in kw:
                if kw in combined_context:
                    score += 2.0 * defn["weight"]
            else:
                # Word boundary match
                if re.search(r"\b" + re.escape(kw) + r"\b", combined_context):
                    score += 1.0 * defn["weight"]
        scores[bag_name] = score

    # Syllable length check for fast pocket
    words = norm_text.split()
    if len(words) >= 12:
        scores["fast_pocket"] += 1.2

    # Pick max score
    best_bag = max(scores, key=scores.get)
    best_score = scores[best_bag]

    if best_score == 0:
        # Default heuristic based on general rap baseline
        return "luxury_drip", 0.3

    return best_bag, round(best_score, 2)


def profile_artist(artist_name: str = "Gunna") -> Dict[str, Any]:
    """Analyze all songs for a specific artist across thematic bags and musical scales."""
    tempo_data = load_tempo_cache()
    norm_artist = artist_name.strip().lower()

    songs_bars = defaultdict(list)
    songs_album = {}

    if not CSV_PATH.exists():
        print(f"Error: {CSV_PATH} not found.")
        return {}

    print(f"Scanning {CSV_PATH.name} for {artist_name}...")
    with open(CSV_PATH, "r", encoding="utf-8", errors="replace") as f:
        reader = csv.reader(f)
        header = next(reader)
        try:
            idx_art = header.index("artist")
            idx_song = header.index("song")
            idx_bar = header.index("text_bar_line")
            idx_tone = header.index("primary_tone") if "primary_tone" in header else -1
            idx_auth = header.index("AuthorityClass") if "AuthorityClass" in header else -1
            idx_album = header.index("album") if "album" in header else -1
        except ValueError as e:
            print("CSV Header missing required columns:", e)
            return {}

        for row in reader:
            if len(row) <= max(idx_art, idx_song, idx_bar):
                continue
            art_val = row[idx_art].strip().lower()
            if art_val == norm_artist:
                song_val = row[idx_song].strip()
                bar_text = row[idx_bar].strip()
                tone_val = row[idx_tone].strip() if idx_tone != -1 else ""
                auth_val = row[idx_auth].strip() if idx_auth != -1 else ""
                if idx_album != -1:
                    songs_album[song_val] = row[idx_album].strip()
                songs_bars[song_val].append({
                    "text": bar_text,
                    "tone": tone_val,
                    "auth": auth_val,
                })

    print(f"Loaded {len(songs_bars)} unique songs for {artist_name}.")

    # Song-level classification and musical context association
    song_profiles = []
    total_bag_counts = defaultdict(int)
    bag_by_scale = defaultdict(lambda: defaultdict(int))
    bag_by_tempo_tier = defaultdict(lambda: defaultdict(int))
    transitions = defaultdict(lambda: defaultdict(int))
    total_transitions = 0

    for song_title, bars in songs_bars.items():
        if len(bars) < 4:
            continue
        key_id = f"{norm_artist}::{song_title.lower()}"
        m_info = tempo_data.get(key_id, {})
        bpm = m_info.get("tempo")
        scale = m_info.get("scale") or ("minor" if "curse" in songs_album.get(song_title, "").lower() else "minor")
        key_root = m_info.get("key_root") or "F"

        # Determine tempo tier
        if bpm:
            if bpm < 120:
                tempo_tier = "slow_soulful"
            elif bpm <= 138:
                tempo_tier = "mid_trap"
            else:
                tempo_tier = "fast_double_time"
        else:
            tempo_tier = "mid_trap"

        song_bag_counts = defaultdict(int)
        prev_bag = None
        song_switches = 0

        for b in bars:
            bag, conf = classify_bar_bag(b["text"], b["tone"], b["auth"])
            song_bag_counts[bag] += 1
            total_bag_counts[bag] += 1
            bag_by_scale[scale][bag] += 1
            bag_by_tempo_tier[tempo_tier][bag] += 1

            if prev_bag is not None:
                transitions[prev_bag][bag] += 1
                total_transitions += 1
                if prev_bag != bag:
                    song_switches += 1
            prev_bag = bag

        total_b = len(bars)
        bag_percentages = {k: round((v / total_b) * 100, 1) for k, v in song_bag_counts.items()}
        adhd_velocity = round(song_switches / max(1, total_b - 1), 3)

        song_profiles.append({
            "song": song_title,
            "album": songs_album.get(song_title, "Unknown"),
            "bars_count": total_b,
            "bpm": bpm,
            "tempo_tier": tempo_tier,
            "scale": scale,
            "key_root": key_root,
            "bag_percentages": bag_percentages,
            "adhd_transition_velocity": adhd_velocity,
        })

    # Global Distribution Percentages
    grand_total_bars = sum(total_bag_counts.values())
    global_distribution = {
        k: round((v / grand_total_bars) * 100, 2) for k, v in total_bag_counts.items()
    }

    # Scale-Conditioned Distributions
    scale_distributions = {}
    for s_name, counts in bag_by_scale.items():
        sub_tot = sum(counts.values())
        if sub_tot > 0:
            scale_distributions[s_name] = {
                k: round((v / sub_tot) * 100, 2) for k, v in counts.items()
            }

    # Tempo-Conditioned Distributions
    tempo_distributions = {}
    for t_name, counts in bag_by_tempo_tier.items():
        sub_tot = sum(counts.values())
        if sub_tot > 0:
            tempo_distributions[t_name] = {
                k: round((v / sub_tot) * 100, 2) for k, v in counts.items()
            }

    # ADHD Transition Matrix P(Bag_{t+1} | Bag_t)
    transition_matrix = {}
    for from_b, to_map in transitions.items():
        row_tot = sum(to_map.values())
        transition_matrix[from_b] = {
            to_b: round(cnt / row_tot, 3) for to_b, cnt in to_map.items()
        }

    # Overall Average ADHD Transition Velocity
    all_velocities = [s["adhd_transition_velocity"] for s in song_profiles]
    avg_adhd_velocity = round(sum(all_velocities) / max(1, len(all_velocities)), 3)

    result = {
        "artist": artist_name,
        "total_songs_measured": len(song_profiles),
        "total_bars_measured": grand_total_bars,
        "global_bag_distribution_pct": global_distribution,
        "scale_conditioned_distribution_pct": scale_distributions,
        "tempo_conditioned_distribution_pct": tempo_distributions,
        "average_adhd_transition_velocity": avg_adhd_velocity,
        "transition_probability_matrix": transition_matrix,
        "sample_songs": song_profiles[:25],
    }

    with open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2)

    print(f"Saved metric report to {OUT_JSON}")
    return result


if __name__ == "__main__":
    profile = profile_artist("Gunna")
    print("\n=======================================================")
    print(f"  PENWORK STUDIOS: {profile['artist'].upper()} MULTI-BAG METRIC PROFILE")
    print("=======================================================")
    print(f"Total Songs Profiled: {profile['total_songs_measured']}")
    print(f"Total Bars Profiled: {profile['total_bars_measured']}")
    print(f"ADHD Topic Transition Velocity: {profile['average_adhd_transition_velocity']} (Switches every ~{round(1/max(0.01, profile['average_adhd_transition_velocity']), 1)} bars)\n")

    print("--- 1. OVERALL MULTI-BAG PERCENTAGE METRIC ---")
    for bag, pct in profile["global_bag_distribution_pct"].items():
        info = BAG_DEFINITIONS.get(bag, {})
        print(f"  • {info.get('title', bag):<40} : {pct:>5.1f}%")

    print("\n--- 2. MUSICAL SCALE CONDITIONING (MINOR VS MAJOR) ---")
    for s_name, dist in profile["scale_conditioned_distribution_pct"].items():
        print(f"  Scale Mode: [{s_name.upper()}]")
        for bag, pct in dist.items():
            info = BAG_DEFINITIONS.get(bag, {})
            print(f"      - {info.get('title', bag):<36} : {pct:>5.1f}%")

    print("\n--- 3. TEMPO (BPM) TIER CONDITIONING ---")
    for t_name, dist in profile["tempo_conditioned_distribution_pct"].items():
        print(f"  Tempo Tier: [{t_name.upper()}]")
        for bag, pct in dist.items():
            info = BAG_DEFINITIONS.get(bag, {})
            print(f"      - {info.get('title', bag):<36} : {pct:>5.1f}%")
