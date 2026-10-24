#!/usr/bin/env python3
"""Penwork Studio: Catalog Line & Pattern Retrieval Engine (Retrieve & Remix).

Core Principles:
1. Never write lines from scratch.
2. Retrieve authentic catalog lines from the target artist matching the user's note editor pattern.
3. Lightly remix 20% to 30% of words, keeping the end word, syllable density, rhythm, and flow intact.
4. Strictly forbid generic nursery rhymes ('real', 'cake', 'slide', 'light', 'tight', etc.).
5. Support song popularity scoring (Genius votes/clicks) and chosen album multipliers (Wunna, Her Loss, etc.).
"""

from __future__ import annotations

import csv
import glob
import json
import math
import os
import re
import sqlite3
import sys
import time
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
OUT = HERE / "out"
STYLE_PROFILE_DIR = HERE.parent / "style-profile"
DB_PATH = OUT / "catalog_index.sqlite"
CMU_PATH = REPO_ROOT / "XJournal AI" / "cmudict.txt"
TRAIN_JSONL = OUT / "train.jsonl"
GROUND_TRUTH_CSV = REPO_ROOT / "XJournal AI" / "ground_truth_rap_bars_MODEL_G.csv"
GENIUS_CLICKS_DIR = REPO_ROOT / "docs" / "play-on-words" / "genius-clicks"
END_WORD_HISTORY_PATH = OUT / "end_word_history.json"

# Global Cross-Generation End-Word Dedupe Window
_GLOBAL_END_WORD_WINDOW: list[str] = []
_TOPIC_CHAIN_CACHE: dict[tuple[str, str, int], str] | None = None
_SONG_DOMINANT_TOPIC_CACHE: dict[tuple[str, str], str] | None = None

# Mapping between ADHD / Frontier motifs and Phase 4 authentic catalog topic labels
MOTIF_TO_TOPIC_ALIASES = {
    "lavishness_money": {"money_flex", "luxury_brands", "party_lifestyle"},
    "romance_women": {"women_romance", "sex"},
    "street_defiance": {"violence_street", "loyalty_friends", "street_life"},
    "boss_authority": {"braggadocio_skill", "fame_industry"},
    "spiritual_faith": {"faith_hope", "spiritual", "other"},
    "pain_betrayal": {"pain_struggle", "come_up_hustle", "violence_street"},
    "money_flex": {"money_flex", "luxury_brands"},
    "luxury_brands": {"luxury_brands", "money_flex"},
    "women_romance": {"women_romance", "sex"},
    "violence_street": {"violence_street"},
    "faith_hope": {"faith_hope", "spiritual"},
    "come_up_hustle": {"come_up_hustle", "pain_struggle"},
}

from lyriclib import (
    ADLIB_TRAILING_RE,
    RAP_VOWEL_CLASSES,
    clean_line_end_word,
    end_rime,
    estimate_syllables,
    is_junk_line,
    load_cmudict,
    normalize,
    tempo_line_syllables,
    tokenize,
    words_rhyme,
)
from polish import GENERIC_END_RHYME_BLACKLIST

STOPWORDS = {
    "a", "an", "the", "and", "or", "in", "on", "at", "to", "for", "with",
    "is", "it", "of", "my", "me", "i", "you", "he", "she", "we", "they",
    "that", "this", "gotta", "been", "up", "has", "was", "be", "so", "as",
}

# Default iconic albums for user album weighting (Task 7)
DEFAULT_CHOSEN_ALBUMS = {
    "Gunna": ["WUNNA (Deluxe)", "WUNNA", "One of Wun", "Drip Harder", "DRIP SEASON 4EVER", "A Gift & A Curse"],
    "Drake": ["Her Loss", "Take Care", "Nothing Was the Same", "Views", "Certified Lover Boy", "If You're Reading This It's Too Late"],
    "NoCap": ["Mr. Crawford", "Steel Human", "The Backend Child", "Before I Go"],
    "Lil Wayne": ["Tha Carter III", "Tha Carter IV", "Tha Carter V", "No Ceilings"],
    "Lil Baby": ["My Turn", "Street Gossip", "Harder Than Ever", "Voice of the Heroes"],
    "Young Thug": ["So Much Fun", "Jeffery", "Barter 6", "Punk", "Slime Language 2"],
}

# Artist Tier Multipliers: Gunna, Drake, and NoCap are maximized at Tier 1 (4.5x)
ARTIST_TIER_MULTIPLIERS: dict[str, float] = {
    "Gunna": 4.5,
    "Drake": 4.5,
    "NoCap": 4.5,
    "Lil Wayne": 2.2,
    "Lil Baby": 2.2,
    "Young Thug": 2.2,
}

# Certified Platinum Hits & Iconic Anthems (Highest Priority Retrieval)
ICONIC_ANTHEMS: dict[str, set[str]] = {
    "gunna": {
        "fukumean", "drip too hard", "pushin p", "top floor", "pedestrian", "hot",
        "one of wun", "neck on a yacht", "hakuna matata", "bread & butter", "rodeo dr",
        "prada dem", "alotta cake", "style stealer", "blindfold", "nothing 4 free",
        "ca$h $hit", "dollaz on my head", "skybox", "met gala", "oh okay", "sold out dates",
        "too easy", "space cadet", "200 for lunch", "motw", "nasty girl / on camera",
        "wunna", "far", "feelingistooloud", "idk nomore", "back to the basics",
        "clear my head", "whatsapp (wats & pans)", "south to west", "banking on me",
        "idk that bitch", "mop", "trio", "whatsapp", "prada dem"
    },
    "drake": {
        "first person shooter", "rich flex", "god's plan", "knife talk", "jimmy cooks",
        "broke boys", "in my feelings", "nonstop", "hotline bling", "laugh now cry later",
        "fair trade", "slime you out", "idgaf", "what's next", "no friends in the industry",
        "headlines", "started from the bottom", "energy", "jumpman", "back to back",
        "chicago freestyle", "marvins room", "hold on, we're going home", "know yourself",
        "passionfruit", "one dance", "nice for what", "money in the grave", "wants and needs",
        "girls want girls", "way 2 sexy", "search & rescue", "virginia beach", "members only",
        "stories about my brother", "shoe fits", "redbutton", "the shoe fits", "wicked man"
    },
    "nocap": {
        "blind nights", "vaccine", "grew up fast", "shackles to diamonds", "point guard",
        "mistake", "very special", "sun up to sun down", "dead faces", "flaws",
        "by tonight", "save the day", "i can't", "heaven for the thugs", "pain show",
        "free draco", "radar", "tweet bird", "no mercy", "in 4", "corner",
        "brag different", "fortune teller", "choppers & bricks", "mr. crawford",
        "the backend child", "steel human", "before i go", "grenade", "diamond dent",
        "uninvited", "house bigger", "tight end", "standin on business", "joy-den"
    },
    "lil wayne": {
        "a milli", "6 foot 7 foot", "lollipop", "how to love", "drop the world",
        "mr. carter", "hustler musik", "fireman", "got money", "blunt blowin",
        "she will", "john", "mirror", "love me", "uproar", "mona lisa",
        "right above it", "i'm me", "go dj", "best rapper alive"
    },
    "lil baby": {
        "drip too hard", "freestyle", "yes indeed", "woah", "the bigger picture",
        "my dawg", "close friends", "we paid", "grace", "pure cocaine", "sum 2 prove",
        "southside", "in a minute", "heyy", "california breeze", "forever"
    },
    "young thug": {
        "hot", "the london", "ski", "lifestyle", "pick up the phone", "check",
        "best friend", "with that", "halftime", "digits", "guwop", "relationship",
        "bad bad bad", "surf", "solid"
    }
}

CACHE_PATH = OUT / "song_metadata_cache.json"

def load_song_metadata_cache() -> dict[str, dict[str, str]]:
    """Loads pre-cached song title and album mappings for instant retrieval."""
    if CACHE_PATH.exists():
        try:
            with CACHE_PATH.open("r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {}


def get_word_stressed_vowel(w: str, cmu: dict[str, list[str]]) -> Optional[str]:
    phones = cmu.get(w.lower())
    if not phones:
        return None
    vowels = [x for x in phones if any(c.isdigit() for c in x)]
    if not vowels:
        return None
    for v in vowels:
        if v[-1] in "12":
            return v
    return vowels[-1]


def detect_inner_rhymes(line: str, cmu: dict[str, list[str]]) -> list[dict[str, Any]]:
    """Detects internal assonances and rime matches across words in a single line."""
    toks = tokenize(normalize(line))
    if len(toks) < 2:
        return []
    end_w = toks[-1]
    words_info = []
    for idx, w in enumerate(toks):
        if w in STOPWORDS:
            continue
        v = get_word_stressed_vowel(w, cmu)
        if v:
            v_class = RAP_VOWEL_CLASSES.get(v, v.rstrip("012"))
            r = end_rime(w, cmu)
            words_info.append({
                "word": w,
                "pos": idx,
                "vowel": v,
                "v_class": v_class,
                "rime": " ".join(r) if r else "",
                "is_end": (idx == len(toks) - 1),
            })

    inner_matches = []
    for i in range(len(words_info)):
        for j in range(i + 1, len(words_info)):
            w1 = words_info[i]
            w2 = words_info[j]
            # Match if rime is equal or stressed vowel class matches
            if (w1["rime"] and w1["rime"] == w2["rime"]) or (w1["v_class"] == w2["v_class"] and w1["vowel"] == w2["vowel"]):
                inner_matches.append({
                    "w1": w1["word"],
                    "pos1": w1["pos"],
                    "w2": w2["word"],
                    "pos2": w2["pos"],
                    "vowel": w1["vowel"],
                    "v_class": w1["v_class"],
                    "is_to_end": w2["is_end"],
                    "exact_rime": bool(w1["rime"] and w1["rime"] == w2["rime"]),
                })
    return inner_matches


def load_genius_popularity_map() -> dict[tuple[str, str], int]:
    """Scans docs/play-on-words/genius-clicks/ for community votes and click counts per (artist, song)."""
    pop_map: dict[tuple[str, str], int] = {}
    if not GENIUS_CLICKS_DIR.exists():
        return pop_map

    for fpath in GENIUS_CLICKS_DIR.glob("*.jsonl"):
        art = fpath.stem.lower().strip()
        try:
            with fpath.open("r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    if not line.strip():
                        continue
                    try:
                        d = json.loads(line)
                        s = (d.get("song") or "").strip().lower()
                        v = int(d.get("votes") or 0)
                        if s:
                            key = (art, s)
                            pop_map[key] = pop_map.get(key, 0) + v
                    except Exception:
                        pass
        except Exception:
            pass
    return pop_map


def load_song_album_map() -> dict[tuple[str, str], str]:
    """Scans ground_truth_rap_bars_MODEL_G.csv for song -> album mappings."""
    album_map: dict[tuple[str, str], str] = {}
    if not GROUND_TRUTH_CSV.exists():
        return album_map

    try:
        with GROUND_TRUTH_CSV.open("r", encoding="utf-8", errors="ignore") as f:
            reader = csv.DictReader(f)
            for r in reader:
                art = (r.get("artist") or "").strip().lower()
                s = (r.get("song") or "").strip().lower()
                alb = (r.get("album") or "").strip()
                if art and s and alb and alb.lower() != "unknown":
                    key = (art, s)
                    if key not in album_map:
                        album_map[key] = alb
    except Exception as e:
        print(f"[CatalogRetriever] Error reading album map: {e}", file=sys.stderr)
    return album_map


def load_topic_chain_map() -> tuple[dict[tuple[str, str, int], str], dict[tuple[str, str], str]]:
    """Loads bar-level topic mappings and song-level dominant topics from style-profile topic cache (Task H)."""
    global _TOPIC_CHAIN_CACHE, _SONG_DOMINANT_TOPIC_CACHE
    if _TOPIC_CHAIN_CACHE is not None and _SONG_DOMINANT_TOPIC_CACHE is not None:
        return _TOPIC_CHAIN_CACHE, _SONG_DOMINANT_TOPIC_CACHE

    bar_topics: dict[tuple[str, str, int], str] = {}
    song_topics: dict[tuple[str, str], str] = {}
    from collections import Counter

    topic_files = [
        OUT / "topic_chain.jsonl",
        STYLE_PROFILE_DIR / "out" / "topic_cache.jsonl",
        STYLE_PROFILE_DIR / "out" / "topic_chain_songs.jsonl",
        STYLE_PROFILE_DIR / "out" / "topic_chain_artists.jsonl",
    ]

    for tf in topic_files:
        if not tf.exists():
            continue
        try:
            with tf.open("r", encoding="utf-8") as f:
                for line in f:
                    try:
                        obj = json.loads(line)
                        art = (obj.get("artist") or "").strip().lower()
                        song = (obj.get("song") or "").strip().lower()
                        if not art or not song:
                            continue
                        chain = obj.get("chain") or []
                        if chain and (art, song) not in song_topics:
                            counts = Counter(chain)
                            song_topics[(art, song)] = counts.most_common(1)[0][0]

                        for r in obj.get("runs", []):
                            top = r.get("topic") or "other"
                            s = r.get("start", 1)
                            e = r.get("end", 1)
                            for b in range(s, e + 1):
                                bar_topics[(art, song, b)] = top
                    except Exception:
                        continue
        except Exception:
            continue

    _TOPIC_CHAIN_CACHE = bar_topics
    _SONG_DOMINANT_TOPIC_CACHE = song_topics
    return _TOPIC_CHAIN_CACHE, _SONG_DOMINANT_TOPIC_CACHE


def get_topic_for_bar(artist: str, song: str, line_seq: int, text: str = "") -> str:
    """Returns the authentic topic label for a bar, with song-level and keyword fallback."""
    bar_map, song_map = load_topic_chain_map()
    art_low = (artist or "").strip().lower()
    song_low = (song or "").strip().lower()
    t = bar_map.get((art_low, song_low, line_seq))
    if t:
        return t
    t = song_map.get((art_low, song_low))
    if t:
        return t
    if text:
        text_low = text.lower()
        KEYWORD_TOPICS = {
            "money_flex": ["patek", "maybach", "racks", "bands", "cash", "million", "billion", "rich", "bank", "check", "goyard", "diamonds", "rollie", "audemars", "audamar", "dollars"],
            "luxury_brands": ["celine", "chanel", "gucci", "prada", "louis", "ferragamo", "amiri", "vetements", "balenciaga", "designer", "drip"],
            "women_romance": ["she", "her", "girl", "bitch", "shawty", "lady", "love", "heart", "date", "stylist"],
            "violence_street": ["glock", "switch", "steel", "trigger", "shoot", "body", "opp", "smoke", "bullet", "draco", "gun", "chopper"],
            "loyalty_friends": ["brother", "slime", "gang", "solid", "loyalty", "trust", "snitch", "inmate", "prison", "homie"],
            "come_up_hustle": ["ditch", "corner", "block", "hustle", "starve", "cold", "trap", "kitchen", "work"],
        }
        for top_name, kws in KEYWORD_TOPICS.items():
            if any(k in text_low for k in kws):
                return top_name
    return "other"


def get_end_word_history(window_size: int = 16, history_path: Path = END_WORD_HISTORY_PATH) -> list[str]:
    """Retrieves recently used end-words across generations to enforce cross-generation deduplication (Task H)."""
    global _GLOBAL_END_WORD_WINDOW
    if not _GLOBAL_END_WORD_WINDOW and history_path.exists():
        try:
            with history_path.open("r", encoding="utf-8") as f:
                data = json.load(f)
                if isinstance(data, list):
                    _GLOBAL_END_WORD_WINDOW = [str(w).lower() for w in data]
        except Exception:
            _GLOBAL_END_WORD_WINDOW = []
    return _GLOBAL_END_WORD_WINDOW[-window_size:] if _GLOBAL_END_WORD_WINDOW else []


def record_used_end_words(words: list[str], max_history: int = 64, history_path: Path = END_WORD_HISTORY_PATH) -> list[str]:
    """Appends newly generated end-words to the persistent cross-generation dedupe window (Task H)."""
    global _GLOBAL_END_WORD_WINDOW
    clean_words = [re.sub(r"[^a-zA-Z0-9']", "", str(w).strip().lower()) for w in words if w]
    clean_words = [w for w in clean_words if w and w not in GENERIC_END_RHYME_BLACKLIST]

    get_end_word_history(max_history, history_path)
    _GLOBAL_END_WORD_WINDOW.extend(clean_words)
    _GLOBAL_END_WORD_WINDOW = _GLOBAL_END_WORD_WINDOW[-max_history:]

    try:
        history_path.parent.mkdir(parents=True, exist_ok=True)
        with history_path.open("w", encoding="utf-8") as f:
            json.dump(_GLOBAL_END_WORD_WINDOW, f)
    except Exception:
        pass
    return _GLOBAL_END_WORD_WINDOW


def clear_end_word_history(history_path: Path = END_WORD_HISTORY_PATH) -> None:
    """Clears the persistent cross-generation dedupe window."""
    global _GLOBAL_END_WORD_WINDOW
    _GLOBAL_END_WORD_WINDOW = []
    if history_path.exists():
        try:
            history_path.unlink()
        except Exception:
            pass


def normalize_vowel_class(v: str) -> str:
    """Normalizes vowel phoneme or class alias (e.g. 'V_aa', 'AA', 'V_broad') to standard RAP_VOWEL_CLASSES label."""
    if not v:
        return ""
    v_clean = str(v).strip()
    if v_clean in RAP_VOWEL_CLASSES.values():
        return v_clean
    upper = v_clean.upper()
    if upper.startswith("V_"):
        upper = upper[2:]
    if upper in RAP_VOWEL_CLASSES:
        return RAP_VOWEL_CLASSES[upper]
    PHONEME_TO_CLASS = {
        "AA": "V_broad",
        "AO": "V_broad",
        "AW": "V_broad",
        "AE": "V_front_open",
        "EH": "V_front_open",
        "IY": "V_front_high",
        "IH": "V_weak",
        "AH": "V_weak",
        "EY": "V_front_mid",
        "AY": "V_front_low",
        "OW": "V_round_mid",
        "UW": "V_round_high",
        "UH": "V_round_mid",
        "OY": "V_round_dip",
        "ER": "V_rhot",
    }
    return PHONEME_TO_CLASS.get(upper, v_clean)


def init_catalog_db(db_path: Path = DB_PATH) -> sqlite3.Connection:
    """Creates the SQLite schema if not already present."""
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(db_path))
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute("PRAGMA synchronous=NORMAL;")
    conn.execute("""
        CREATE TABLE IF NOT EXISTS catalog_bars (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            artist TEXT NOT NULL,
            song TEXT NOT NULL,
            song_id TEXT,
            album TEXT,
            text TEXT NOT NULL,
            end_word TEXT NOT NULL,
            end_rime TEXT NOT NULL,
            vowel_class TEXT NOT NULL,
            syllables INTEGER NOT NULL,
            inner_rhymes_json TEXT,
            inner_rhyme_count INTEGER NOT NULL,
            popularity_score REAL DEFAULT 0.0,
            is_generic INTEGER DEFAULT 0,
            line_seq INTEGER DEFAULT 1,
            total_lines INTEGER DEFAULT 1,
            relative_pos REAL DEFAULT 0.5,
            chronological_arc TEXT DEFAULT 'verse_build',
            next_bar_text TEXT DEFAULT '',
            next_bar_end_word TEXT DEFAULT '',
            is_iconic_anthem INTEGER DEFAULT 0,
            topic TEXT DEFAULT '',
            inner_vowel_class TEXT DEFAULT ''
        );
    """)
    conn.execute("CREATE INDEX IF NOT EXISTS idx_artist_rime ON catalog_bars(artist, end_rime, syllables);")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_artist_vowel ON catalog_bars(artist, vowel_class, syllables);")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_artist_album ON catalog_bars(artist, album);")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_artist_pos ON catalog_bars(artist, relative_pos);")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_artist_song_seq ON catalog_bars(artist, song, line_seq);")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_popularity ON catalog_bars(popularity_score);")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_artist_topic ON catalog_bars(artist, topic);")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_artist_inner_vowel ON catalog_bars(artist, inner_vowel_class);")

    # Migrate existing tables if columns missing
    cur = conn.cursor()
    cur.execute("PRAGMA table_info(catalog_bars);")
    cols = {c[1] for c in cur.fetchall()}
    if "topic" not in cols:
        conn.execute("ALTER TABLE catalog_bars ADD COLUMN topic TEXT DEFAULT '';")
    if "inner_vowel_class" not in cols:
        conn.execute("ALTER TABLE catalog_bars ADD COLUMN inner_vowel_class TEXT DEFAULT '';")

    conn.commit()
    return conn


def build_catalog_index(
    target_artists: list[str] = None,
    force_rebuild: bool = False,
    db_path: Path = DB_PATH,
) -> int:
    """Indexes catalog lines for prioritized artists from train.jsonl and ground truth CSV with chronological metadata."""
    if target_artists is None:
        target_artists = ["Gunna", "Drake", "NoCap", "Lil Wayne", "Lil Baby", "Young Thug"]

    target_set = {a.lower() for a in target_artists}

    # Check if table exists and has chronological columns before deciding rebuild
    has_chrono = False
    count = 0
    if db_path.exists():
        c_test = sqlite3.connect(str(db_path))
        c_cur = c_test.cursor()
        c_cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='catalog_bars';")
        if c_cur.fetchone():
            c_cur.execute("PRAGMA table_info(catalog_bars);")
            cols = {c[1] for c in c_cur.fetchall()}
            has_chrono = ("line_seq" in cols and "relative_pos" in cols)
            c_cur.execute("SELECT COUNT(*) FROM catalog_bars;")
            count = c_cur.fetchone()[0]
        c_test.close()

    if count > 0 and has_chrono and not force_rebuild:
        print(f"[CatalogRetriever] Database already indexed with {count} chronological lines. Skipping build.")
        return count

    # Drop existing table to ensure clean chronological schema
    if db_path.exists():
        c_drop = sqlite3.connect(str(db_path))
        c_drop.execute("DROP TABLE IF EXISTS catalog_bars;")
        c_drop.commit()
        c_drop.close()

    conn = init_catalog_db(db_path)
    cur = conn.cursor()

    print(f"[CatalogRetriever] Building chronological catalog index for {target_artists}...")
    t0 = time.time()
    cmu = load_cmudict(CMU_PATH)
    pop_map = load_genius_popularity_map()
    album_map = load_song_album_map()
    song_metadata = load_song_metadata_cache()

    inserted = 0
    batch = []
    seen_hashes = set()

    # 1. Ingest from train.jsonl (maintains exact chronological line sequence per song)
    if TRAIN_JSONL.exists():
        with TRAIN_JSONL.open("r", encoding="utf-8") as f:
            for line_str in f:
                try:
                    obj = json.loads(line_str)
                    art = (obj.get("artist") or "").strip()
                    if art.lower() not in target_set:
                        continue
                    sid = str(obj.get("song_id") or "")
                    meta = song_metadata.get(sid) or {}
                    song_title = (meta.get("song") or obj.get("song") or sid).strip()
                    album_name = (meta.get("album") or album_map.get((art.lower(), song_title.lower())) or obj.get("album") or "Catalog").strip()

                    is_anthem = 1 if song_title.lower() in ICONIC_ANTHEMS.get(art.lower(), set()) else 0
                    pop_votes = pop_map.get((art.lower(), song_title.lower()), 0)
                    pop_score = round(math.log10(1 + max(0, pop_votes)) * 10.0, 2)
                    if is_anthem:
                        pop_score = max(pop_score, 45.0)

                    text_body = obj.get("text") or ""
                    raw_lines = [l.strip() for l in text_body.splitlines() if l.strip()]
                    cleaned_song_lines = []
                    for r_l in raw_lines:
                        if is_junk_line(r_l):
                            continue
                        c_l = ADLIB_TRAILING_RE.sub("", r_l).strip()
                        toks = tokenize(normalize(c_l))
                        if len(toks) >= 3:
                            cleaned_song_lines.append((c_l, toks))

                    total_lines = len(cleaned_song_lines)
                    if total_lines == 0:
                        continue

                    for idx, (clean_line, toks) in enumerate(cleaned_song_lines):
                        line_seq = idx + 1
                        rel_pos = round(line_seq / float(total_lines), 3)

                        if rel_pos <= 0.25:
                            arc = "intro"
                        elif rel_pos <= 0.50:
                            arc = "verse_build"
                        elif rel_pos <= 0.75:
                            arc = "verse_turn"
                        else:
                            arc = "climax_punch"

                        next_text = cleaned_song_lines[idx + 1][0] if idx + 1 < total_lines else ""
                        next_end = cleaned_song_lines[idx + 1][1][-1] if idx + 1 < total_lines else ""

                        end_w = toks[-1]
                        is_gen = 1 if (end_w in GENERIC_END_RHYME_BLACKLIST or len(end_w) <= 2) else 0
                        rime_tuple = end_rime(end_w, cmu)
                        rime_str = " ".join(rime_tuple) if rime_tuple else ""

                        v_str = get_word_stressed_vowel(end_w, cmu) or "V_other"
                        v_class = RAP_VOWEL_CLASSES.get(v_str, "V_other")
                        syl_cnt = estimate_syllables(clean_line)

                        line_key = (art.lower(), song_title.lower(), clean_line.lower())
                        if line_key in seen_hashes:
                            continue
                        seen_hashes.add(line_key)

                        inner_matches = detect_inner_rhymes(clean_line, cmu)
                        inner_json = json.dumps(inner_matches[:8])
                        inner_vclass = inner_matches[0]["v_class"] if inner_matches else ""
                        bar_topic = get_topic_for_bar(art, song_title, line_seq, clean_line)

                        batch.append((
                            art,
                            song_title,
                            sid,
                            album_name,
                            clean_line,
                            end_w,
                            rime_str,
                            v_class,
                            syl_cnt,
                            inner_json,
                            len(inner_matches),
                            pop_score,
                            is_gen,
                            line_seq,
                            total_lines,
                            rel_pos,
                            arc,
                            next_text,
                            next_end,
                            is_anthem,
                            bar_topic,
                            inner_vclass,
                        ))

                        if len(batch) >= 5000:
                            cur.executemany("""
                                INSERT INTO catalog_bars (
                                    artist, song, song_id, album, text, end_word, end_rime,
                                    vowel_class, syllables, inner_rhymes_json,
                                    inner_rhyme_count, popularity_score, is_generic,
                                    line_seq, total_lines, relative_pos, chronological_arc,
                                    next_bar_text, next_bar_end_word, is_iconic_anthem,
                                    topic, inner_vowel_class
                                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                            """, batch)
                            conn.commit()
                            inserted += len(batch)
                            batch = []
                except Exception:
                    continue

    # 2. Ingest from ground_truth_rap_bars_MODEL_G.csv for missing album tracks
    if GROUND_TRUTH_CSV.exists():
        try:
            with GROUND_TRUTH_CSV.open("r", encoding="utf-8", errors="ignore") as f:
                reader = csv.DictReader(f)
                for r in reader:
                    art = (r.get("artist") or "").strip()
                    if art.lower() not in target_set:
                        continue
                    clean_line = (r.get("text_bar_line") or "").strip()
                    clean_line = ADLIB_TRAILING_RE.sub("", clean_line).strip()
                    if not clean_line or is_junk_line(clean_line):
                        continue
                    toks = tokenize(normalize(clean_line))
                    if len(toks) < 3:
                        continue

                    song_title = (r.get("song") or "Track").strip()
                    album_name = (r.get("album") or "Catalog").strip()

                    line_key = (art.lower(), song_title.lower(), clean_line.lower())
                    if line_key in seen_hashes:
                        continue
                    seen_hashes.add(line_key)

                    end_w = toks[-1]
                    is_gen = 1 if (end_w in GENERIC_END_RHYME_BLACKLIST or len(end_w) <= 2) else 0
                    rime_tuple = end_rime(end_w, cmu)
                    rime_str = " ".join(rime_tuple) if rime_tuple else ""
                    v_str = get_word_stressed_vowel(end_w, cmu) or "V_other"
                    v_class = RAP_VOWEL_CLASSES.get(v_str, "V_other")
                    try:
                        syl_cnt = int(r.get("syllable_count") or estimate_syllables(clean_line))
                    except Exception:
                        syl_cnt = estimate_syllables(clean_line)

                    b_idx = int(r.get("bar_index") or 1)
                    rel_pos = round(min(1.0, b_idx / 32.0), 3)
                    if rel_pos <= 0.25:
                        arc = "intro"
                    elif rel_pos <= 0.50:
                        arc = "verse_build"
                    elif rel_pos <= 0.75:
                        arc = "verse_turn"
                    else:
                        arc = "climax_punch"

                    is_anthem = 1 if song_title.lower() in ICONIC_ANTHEMS.get(art.lower(), set()) else 0
                    pop_votes = pop_map.get((art.lower(), song_title.lower()), 0)
                    pop_score = round(math.log10(1 + max(0, pop_votes)) * 10.0, 2)
                    if is_anthem:
                        pop_score = max(pop_score, 45.0)

                    inner_matches = detect_inner_rhymes(clean_line, cmu)
                    inner_json = json.dumps(inner_matches[:8])
                    inner_vclass = inner_matches[0]["v_class"] if inner_matches else ""
                    bar_topic = get_topic_for_bar(art, song_title, b_idx, clean_line)

                    batch.append((
                        art,
                        song_title,
                        "",
                        album_name,
                        clean_line,
                        end_w,
                        rime_str,
                        v_class,
                        syl_cnt,
                        inner_json,
                        len(inner_matches),
                        pop_score,
                        is_gen,
                        b_idx,
                        32,
                        rel_pos,
                        arc,
                        "",
                        "",
                        is_anthem,
                        bar_topic,
                        inner_vclass,
                    ))

                    if len(batch) >= 5000:
                        cur.executemany("""
                            INSERT INTO catalog_bars (
                                artist, song, song_id, album, text, end_word, end_rime,
                                vowel_class, syllables, inner_rhymes_json,
                                inner_rhyme_count, popularity_score, is_generic,
                                line_seq, total_lines, relative_pos, chronological_arc,
                                next_bar_text, next_bar_end_word, is_iconic_anthem,
                                topic, inner_vowel_class
                            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                        """, batch)
                        conn.commit()
                        inserted += len(batch)
                        batch = []
        except Exception as e:
            print(f"[CatalogRetriever] CSV parse error: {e}", file=sys.stderr)

    if batch:
        cur.executemany("""
            INSERT INTO catalog_bars (
                artist, song, song_id, album, text, end_word, end_rime,
                vowel_class, syllables, inner_rhymes_json,
                inner_rhyme_count, popularity_score, is_generic,
                line_seq, total_lines, relative_pos, chronological_arc,
                next_bar_text, next_bar_end_word, is_iconic_anthem,
                topic, inner_vowel_class
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, batch)
        conn.commit()
        inserted += len(batch)

    conn.close()
    elapsed = round(time.time() - t0, 2)
    print(f"[CatalogRetriever] Indexed {inserted} high-quality chronological bars in {elapsed}s.")
    return inserted


def extract_seed_pattern(seed_lines: list[str], cmu: dict[str, list[str]], bpm: float = 130.0) -> list[dict[str, Any]]:
    """Extracts end-rhyme sounds, inner-rhyme positions, and syllable counts from user's note editor bars."""
    base_target = max(16, tempo_line_syllables(bpm) + 2)
    patterns = []

    for idx, raw in enumerate(seed_lines):
        clean = ADLIB_TRAILING_RE.sub("", raw).strip()
        if not clean:
            continue
        toks = tokenize(normalize(clean))
        end_w = toks[-1] if toks else ""
        rime_tuple = end_rime(end_w, cmu) if end_w else None
        rime_str = " ".join(rime_tuple) if rime_tuple else ""
        v_str = get_word_stressed_vowel(end_w, cmu) if end_w else ""
        v_class = RAP_VOWEL_CLASSES.get(v_str, "V_other") if v_str else "V_other"
        syl = estimate_syllables(clean)
        inner = detect_inner_rhymes(clean, cmu)
        inner_vclass = inner[0]["v_class"] if inner else ""
        is_generic = end_w in GENERIC_END_RHYME_BLACKLIST
        # Respect user's explicit syllable density (Task 4)
        line_target_syl = max(base_target, syl) if syl >= 14 else base_target

        patterns.append({
            "line_index": idx + 1,
            "raw_text": raw,
            "clean_text": clean,
            "tokens": toks,
            "end_word": end_w,
            "end_rime": rime_str,
            "vowel_class": v_class,
            "inner_vowel_class": inner_vclass,
            "syllables": syl,
            "target_syllables": line_target_syl,
            "inner_rhymes": inner,
            "inner_rhyme_count": len(inner),
            "is_generic_rhyme": is_generic,
        })
    return patterns


def retrieve_matching_catalog_lines(
    artist: str,
    pattern: dict[str, Any],
    chosen_albums: list[str] = None,
    limit: int = 8,
    bar_number: int = 1,
    previous_retrieved_line: dict[str, Any] = None,
    topic_hint: str = "",
    target_inner_vowel: str = "",
    recent_end_words: list[str] | set[str] = None,
    end_word_dedupe_window: int = 16,
    db_path: Path = DB_PATH,
) -> list[dict[str, Any]]:
    """Retrieves real catalog lines matching the pattern with chronological ordering, couplet chaining, popularity, and artist tier weighting."""
    if not db_path.exists():
        build_catalog_index(target_artists=[artist], db_path=db_path)

    conn = sqlite3.connect(str(db_path))
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    target_rime = pattern.get("end_rime", "")
    target_vowel = pattern.get("vowel_class", "")
    target_word = (pattern.get("end_word") or "").lower()
    target_syl = pattern.get("target_syllables") or pattern.get("syllables") or 16
    user_albums = set(a.lower() for a in (chosen_albums or DEFAULT_CHOSEN_ALBUMS.get(artist, [])))

    # Task H: Resolve Topic-Chain Aliases
    target_topic = (topic_hint or pattern.get("topic") or "").strip().lower()
    target_topics: set[str] = set()
    if target_topic:
        target_topics.add(target_topic)
        target_topics.update(MOTIF_TO_TOPIC_ALIASES.get(target_topic, []))
        for k, aliases in MOTIF_TO_TOPIC_ALIASES.items():
            if k in target_topic or target_topic in k:
                target_topics.add(k)
                target_topics.update(aliases)
    primary_topic = list(target_topics)[0] if target_topics else target_topic

    # Task H: Resolve Inner-Rhyme Target Vowel Class
    raw_inner = target_inner_vowel or pattern.get("inner_vowel_class") or pattern.get("target_inner_vowel") or ""
    norm_inner_vowel = normalize_vowel_class(raw_inner)

    # Task H: Resolve Cross-Generation End-Word Dedupe Window
    if recent_end_words is None:
        recent_end_words = get_end_word_history(window_size=end_word_dedupe_window)
    recent_list = [str(w).lower() for w in recent_end_words if w]

    # Chronological Arc & Position Map for 8-bar structures
    target_arc_map = {
        1: ("intro", 0.15),
        2: ("intro", 0.25),
        3: ("verse_build", 0.35),
        4: ("verse_build", 0.45),
        5: ("verse_turn", 0.60),
        6: ("verse_turn", 0.70),
        7: ("climax_punch", 0.85),
        8: ("climax_punch", 0.95),
    }
    target_arc, target_pos = target_arc_map.get(bar_number, ("verse_build", 0.5))

    scored_candidates = []

    # 1. Chronological Couplet Continuity (Consecutive Line Chaining)
    # If this is the 2nd line of a couplet (Bars 2, 4, 6, 8) and previous line was from the same artist
    if previous_retrieved_line and (bar_number in (2, 4, 6, 8)):
        prev_song = previous_retrieved_line.get("song")
        prev_seq = previous_retrieved_line.get("line_seq")
        prev_art = previous_retrieved_line.get("artist")
        if prev_song and prev_seq and (prev_art == artist):
            cur.execute("""
                SELECT id, artist, song, album, text, end_word, end_rime,
                       vowel_class, syllables, inner_rhyme_count, popularity_score,
                       line_seq, total_lines, relative_pos, chronological_arc,
                       next_bar_text, is_iconic_anthem, topic, inner_vowel_class
                FROM catalog_bars
                WHERE artist = ? AND song = ? AND line_seq IN (?, ?) AND is_generic = 0;
            """, (artist, prev_song, prev_seq + 1, prev_seq + 2))
            c_rows = [dict(r) for r in cur.fetchall()]
            for cr in c_rows:
                cr_end = (cr["end_word"] or "").lower()
                prev_end = (previous_retrieved_line.get("end_word") or "").lower()
                if cr_end != prev_end:
                    cr_rime = cr.get("end_rime") or ""
                    cr_vowel = cr.get("vowel_class") or ""
                    prev_rime = previous_retrieved_line.get("end_rime") or ""
                    prev_vowel = previous_retrieved_line.get("vowel_class") or ""

                    rhymes = (
                        (target_rime and cr_rime == target_rime) or
                        (target_vowel and cr_vowel == target_vowel) or
                        (prev_rime and cr_rime == prev_rime) or
                        (prev_vowel and cr_vowel == prev_vowel)
                    )
                    syl_diff = abs(cr["syllables"] - target_syl)
                    if rhymes and syl_diff <= 6:
                        # Massive continuity score for authentic consecutive chronological lines
                        cr["match_score"] = 99999.0
                        cr["is_consecutive_couplet"] = True
                        cr["topic_match"] = bool(target_topics and cr.get("topic") in target_topics)
                        cr["inner_vowel_match"] = bool(norm_inner_vowel and cr.get("inner_vowel_class") == norm_inner_vowel)
                        cr["dedupe_penalty"] = 0.0
                        scored_candidates.append(cr)
                        break

    rime_last = target_rime.split()[-1] if target_rime else ""
    rime_like = f"% {rime_last}" if rime_last else "%"

    # Composite SQL retrieval ranking combining exact end-word, exact rime, suffix rime, vowel class, popularity, anthems, topic, and inner vowel
    sql = """
        SELECT id, artist, song, album, text, end_word, end_rime,
               vowel_class, syllables, inner_rhyme_count, popularity_score,
               line_seq, total_lines, relative_pos, chronological_arc,
               next_bar_text, is_iconic_anthem, topic, inner_vowel_class,
               (CASE 
                    WHEN lower(end_word) = ? OR (lower(?) = 'audamar' AND lower(end_word) = 'audemars') THEN 300
                    WHEN end_rime = ? THEN 150
                    WHEN end_rime LIKE ? THEN 80
                    WHEN vowel_class = ? THEN 40
                    ELSE 10 
                END) + (popularity_score * 2.5) + (is_iconic_anthem * 150)
                + (CASE WHEN topic != '' AND ? != '' AND topic = ? THEN 60 ELSE 0 END)
                + (CASE WHEN inner_vowel_class != '' AND ? != '' AND inner_vowel_class = ? THEN 50 ELSE 0 END) as retrieval_rank
        FROM catalog_bars
        WHERE artist = ? AND is_generic = 0
          AND (
            lower(end_word) = ? OR (lower(?) = 'audamar' AND lower(end_word) = 'audemars')
            OR end_rime = ? OR end_rime LIKE ? OR vowel_class = ?
            OR (topic != '' AND ? != '' AND topic = ?)
            OR (inner_vowel_class != '' AND ? != '' AND inner_vowel_class = ?)
          )
          AND ABS(syllables - ?) <= 6
        ORDER BY retrieval_rank DESC
        LIMIT 60;
    """

    cur.execute(
        sql,
        (
            target_word,
            target_word,
            target_rime,
            rime_like,
            target_vowel,
            primary_topic,
            primary_topic,
            norm_inner_vowel,
            norm_inner_vowel,
            artist,
            target_word,
            target_word,
            target_rime,
            rime_like,
            target_vowel,
            primary_topic,
            primary_topic,
            norm_inner_vowel,
            norm_inner_vowel,
            target_syl,
        ),
    )
    rows = cur.fetchall()

    # Fallback to general artist pool if no strict match found
    if not rows and not scored_candidates:
        sql_fallback = """
            SELECT id, artist, song, album, text, end_word, end_rime,
                   vowel_class, syllables, inner_rhyme_count, popularity_score,
                   line_seq, total_lines, relative_pos, chronological_arc,
                   next_bar_text, is_iconic_anthem, topic, inner_vowel_class
            FROM catalog_bars
            WHERE artist = ? AND is_generic = 0
              AND ABS(syllables - ?) <= 4
            ORDER BY is_iconic_anthem DESC, popularity_score DESC, inner_rhyme_count DESC
            LIMIT 40;
        """
        cur.execute(sql_fallback, (artist, target_syl))
        rows = cur.fetchall()

    for r in rows:
        row_dict = dict(r)
        score = 0.0
        row_end = (row_dict["end_word"] or "").lower()

        # 0. Exact or Alias End-Word Match (Task 1 & 2)
        if target_word and (row_end == target_word or (target_word == "audamar" and row_end == "audemars")):
            score += 200.0

        # 1. Phoneme / Hard Rhyme Match (Task 3)
        if target_rime and row_dict["end_rime"] == target_rime:
            score += 120.0
        elif target_rime and target_rime.split()[0] in row_dict["end_rime"]:
            score += 60.0
        elif target_vowel and row_dict["vowel_class"] == target_vowel:
            score += 35.0

        # 2. Syllable Proximity (Task 4)
        syl_diff = abs(row_dict["syllables"] - target_syl)
        score += max(0.0, 35.0 - (syl_diff * 4.0))

        # 3. Inner Rhymes (Task 5 - High Priority)
        score += min(40.0, row_dict["inner_rhyme_count"] * 7.0)

        # Task H: Inner-Rhyme-Indexed Retrieval (+65.0 boost)
        row_inner = row_dict.get("inner_vowel_class") or ""
        is_inner_match = False
        if norm_inner_vowel and row_inner and (row_inner == norm_inner_vowel):
            is_inner_match = True
            score += 65.0
        row_dict["inner_vowel_match"] = is_inner_match

        # Task H: Topic-Chain Binding (+75.0 boost)
        row_top = (row_dict.get("topic") or "").lower()
        is_topic_match = False
        if target_topics and row_top:
            if row_top in target_topics or any(tt in row_top for tt in target_topics) or (target_topic and target_topic in row_top):
                is_topic_match = True
                score += 75.0
        row_dict["topic_match"] = is_topic_match

        # 4. Popularity Score (Task 6 & 8)
        score += (row_dict.get("popularity_score") or 0.0) * 2.5

        # 5. Certified Iconic Anthem Boost
        if row_dict.get("is_iconic_anthem"):
            score += 180.0

        # 6. Chronological Order & Arc Alignment
        rel_pos = row_dict.get("relative_pos", 0.5)
        pos_diff = abs(rel_pos - target_pos)
        score += max(0.0, 75.0 - (pos_diff * 120.0))
        if row_dict.get("chronological_arc") == target_arc:
            score += 40.0

        # 7. Chosen Album Multiplier (Task 7)
        alb = (row_dict["album"] or "").lower()
        if any(ua in alb for ua in user_albums):
            score *= 2.5
            row_dict["is_chosen_album"] = True
        else:
            row_dict["is_chosen_album"] = False

        # 8. Artist Tier Multiplier (Gunna, Drake, NoCap maximized at 4.5x!)
        artist_mult = ARTIST_TIER_MULTIPLIERS.get(artist, 1.0)
        score *= artist_mult

        # Task H: Cross-Generation End-Word Dedupe Window
        # Waived if user/caller explicitly seeded this end_word
        dedupe_penalty = 0.0
        if not (target_word and (row_end == target_word or (target_word == "audamar" and row_end == "audemars"))):
            if recent_list and row_end:
                last_4 = recent_list[-4:] if len(recent_list) >= 4 else recent_list
                if row_end in last_4:
                    dedupe_penalty = -160.0
                elif row_end in recent_list[-16:]:
                    dedupe_penalty = -80.0
        if dedupe_penalty != 0.0:
            score += dedupe_penalty
        row_dict["dedupe_penalty"] = dedupe_penalty

        row_dict["match_score"] = round(score, 2)
        scored_candidates.append(row_dict)

    conn.close()
    scored_candidates.sort(key=lambda x: x["match_score"], reverse=True)
    return scored_candidates[:limit]

    conn.close()
    scored_candidates.sort(key=lambda x: x["match_score"], reverse=True)
    return scored_candidates[:limit]


def calculate_edit_distance_ratio(original: str, edited: str) -> float:
    """Calculates word-level edit ratio (percentage of words changed)."""
    orig_toks = tokenize(normalize(original))
    edit_toks = tokenize(normalize(edited))
    if not orig_toks:
        return 0.0

    # Common word count
    orig_set = set(orig_toks)
    kept_words = sum(1 for w in edit_toks if w in orig_set)
    total_words = max(len(orig_toks), len(edit_toks))
    diff_ratio = 1.0 - (kept_words / float(total_words)) if total_words > 0 else 0.0
    return round(diff_ratio, 3)


def verify_remix_compliance(catalog_line: str, remixed_line: str) -> dict[str, Any]:
    """Ensures 20-30% edit distance cap and end-word preservation (Task 9)."""
    cat_toks = tokenize(normalize(catalog_line))
    remix_toks = tokenize(normalize(remixed_line))

    cat_end = cat_toks[-1] if cat_toks else ""
    remix_end = remix_toks[-1] if remix_toks else ""

    edit_ratio = calculate_edit_distance_ratio(catalog_line, remixed_line)
    end_word_preserved = (cat_end == remix_end)

    is_compliant = (edit_ratio <= 0.35 and end_word_preserved)

    return {
        "is_compliant": is_compliant,
        "edit_distance_ratio": edit_ratio,
        "catalog_end_word": cat_end,
        "remix_end_word": remix_end,
        "end_word_preserved": end_word_preserved,
        "catalog_words": len(cat_toks),
        "remixed_words": len(remix_toks),
    }


if __name__ == "__main__":
    print("Testing Catalog Retriever...")
    build_catalog_index(target_artists=["Gunna", "Drake", "NoCap"])
    cmu = load_cmudict(CMU_PATH)

    test_seed = [
        "Locked in the cell feel the weight on my soul",
        "Friends turnin fake and they payin the toll",
        "Penthouse is large, gotta fast car, maximum withdraws, blue audamar",
    ]

    print("\n--- Extracting Seed Pattern ---")
    patterns = extract_seed_pattern(test_seed, cmu, bpm=130.0)
    for p in patterns:
        print(f"Bar {p['line_index']}: '{p['clean_text']}' -> End: {p['end_word']} ({p['end_rime']}) | Syl: {p['syllables']} | Inners: {p['inner_rhyme_count']}")

    print("\n--- Retrieving Matching Gunna Lines (With Album Multipliers) ---")
    matches = retrieve_matching_catalog_lines("Gunna", patterns[0], chosen_albums=["WUNNA (Deluxe)", "One of Wun"])
    for m in matches[:3]:
        print(f"[{m['match_score']} pts] {m['song']} ({m['album']}): '{m['text']}' (End: {m['end_word']}, Syl: {m['syllables']})")
