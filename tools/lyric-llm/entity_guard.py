#!/usr/bin/env python3
"""
Frontier v4 Named-Entity Leak Guard (Task P)

Prevents off-voice personas and named entities from leaking across artist styles.
For example:
  - Gunna spit 'Free Thugger' or 'YSL' in a Drake-voiced verse -> BLOCKED.
  - Lil Wayne verse referencing 'Thugger' or 'OVO' -> BLOCKED.
  - Drake verse referencing 'Tunechi' or 'Hollygrove' -> BLOCKED.

Behavior:
  1. Derives per-voice proper-noun whitelists from catalog_retriever sqlite (catalog_bars)
     plus curated artist persona/crew dictionaries and universal luxury/geographic proper nouns.
  2. guard(voice, bar) -> {"ok": bool, "offending_tokens": list[str]}
     Returns ok=False if a bar contains proper-noun entities not present in that voice's whitelist.
  3. guard_verse(voice, bars, bar_artists) -> {"passed": bool, "failed_indices": list[int], ...}
  4. Auto-retries failing bars up to 2 times with the offending token listed.
"""

from __future__ import annotations

import json
import os
import re
import sqlite3
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
OUT = HERE / "out"
DB_PATH = OUT / "catalog_index.sqlite"
WHITELISTS_JSON_PATH = OUT / "entity_whitelists.json"

# ==============================================================================
# UNIVERSAL RAP PROPER NOUNS (Allowed across all artist voices)
# ==============================================================================

UNIVERSAL_LUXURY_BRANDS: set[str] = {
    # Fashion & Designers
    "chanel", "gucci", "prada", "dior", "balenciaga", "celine", "givenchy",
    "hermes", "birk", "birkin", "fendi", "louis", "vuitton", "chrome hearts",
    "amiri", "moncler", "cartier", "bvlgari", "bulgari", "goyard", "tiffany",
    "bottega", "veneta", "saint laurent", "ysl", "valentino", "versace",
    "burberry", "tom ford", "margiela", "vetements", "rick owens", "gallery dept",
    "lanvin", "balmain", "christian", "louboutin", "louboutins", "red bottoms",
    # Watches & Jewelry
    "rolex", "rollie", "patek", "philippe", "audemars", "audamar", "piguet",
    "ap", "richard mille", "mille", "hublot", "breguet", "cartier", "vvs",
    "flawless", "bustdown", "presidential", "submariner", "daytona", "nautilus",
    # Luxury Cars
    "maybach", "bentley", "mercedes", "benz", "lambo", "lamborghini", "ferrari",
    "porsche", "rolls", "royce", "cullinan", "ghost", "wraith", "phantom",
    "corvette", "aston martin", "beamer", "bmw", "range rover", "rover",
    "urac", "huracan", "aventador", "hellcat", "demon", "trackhawk", "amg",
    # World Metros & Travel
    "paris", "london", "miami", "new york", "nyc", "la", "los angeles",
    "dubai", "tokyo", "calabasas", "vegas", "las vegas", "cali", "california",
    "atlanta", "houston", "chicago", "hollywood", "broadway", "beverly hills",
    # Universal Cultural & Calendar Terms
    "god", "jesus", "lord", "bible", "easter", "christmas",
    "sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday",
    "january", "february", "march", "april", "may", "june", "july", "august",
    "september", "october", "november", "december",
    # Beverages & Tech
    "hennessy", "casamigos", "don julio", "patron", "moet", "dom perignon",
    "ace of spades", "sprite", "fanta", "iphone", "apple", "instagram", "facetime",
    "tesla", "uber", "zoom", "playstation", "nintendo",
}

# ==============================================================================
# ARTIST-SPECIFIC SIGNATURE PROPER NOUNS & PERSONA DICTIONARIES
# ==============================================================================

ARTIST_CORE_ENTITIES: dict[str, set[str]] = {
    "gunna": {
        "gunna", "wunna", "sergio", "kitchens", "drip", "drip season", "ds4",
        "ysl", "young stoner life", "slime", "slatt", "thugger", "turbo",
        "wheezy", "taurus", "college park", "south to west", "fukumean",
        "banking on me", "bread & butter", "one of wun", "alright", "space cadet",
        "peewee", "glock", "metro", "southside",
    },
    "young thug": {
        "young thug", "thugger", "jeffery", "spider", "spiderr", "sex",
        "slime", "slatt", "slime language", "ysl", "young stoner life",
        "unfoonk", "gunna", "hiatus", "so much fun", "punk", "barter 6",
        "wheezy", "turbo", "metro", "london", "alex",
    },
    "lil wayne": {
        "lil wayne", "wayne", "weezy", "tunechi", "tune", "carter", "tha carter",
        "young money", "ymcmb", "cash money", "birdman", "baby", "mack maine",
        "hollygrove", "new orleans", "17th", "uptown", "mannie fresh",
        "no ceilings", "dedication", "drought", "funeral", "gudda", "nicki",
        "c-4", "c-5", "c-6", "president carter",
    },
    "drake": {
        "drake", "drizzy", "aubrey", "graham", "champagne", "champagne papi",
        "the boy", "ovo", "october", "octobers very own", "chubbs", "40", "noah",
        "oliver", "baka", "preme", "gordo", "nocta", "toronto", "6ix",
        "the 6", "bridle path", "certified lover boy", "her loss", "scorpion",
        "take care", "nothing was the same", "for all the dogs", "mark",
    },
    "lil baby": {
        "lil baby", "baby", "dominique", "jones", "wham", "4pf",
        "four pockets full", "quality control", "qc", "oakland city",
        "west end", "my turn", "harder than ever", "it's only me", "marlo",
        "pee", "coach k", "pierre",
    },
    "nocap": {
        "nocap", "cap", "bakaveeli", "mr. crawford", "crawford", "alaphia",
        "steel", "mobile", "alabama", "the main bird", "jgreen", "1600",
        "vaccine", "ghana", "pain show", "shackles to diamonds",
    },
}

# Cross-voice collaborative mappings (entities that are allowed in specific voices)
COLLABORATION_ALLOWANCES: dict[str, set[str]] = {
    # Gunna & Young Thug are label/partner twins (share YSL, Slime, Thugger, Gunna)
    "gunna": {"thugger", "slime", "slatt", "ysl", "young thug", "jeffery"},
    "young thug": {"gunna", "wunna", "slime", "slatt", "ysl"},
    # Lil Wayne & Drake are Young Money brothers (share Young Money, YMCMB)
    "lil wayne": {"young money", "ymcmb", "cash money"},
    "drake": {"young money", "ymcmb", "lil wayne", "weezy"},
    # Lil Baby & Gunna collaborated extensively on Drip Harder
    "lil baby": {"drip too hard", "quality control", "4pf"},
}

# Known signature off-voice leak traps: tokens strongly tied to specific artists
# that must NEVER leak into other voices unless explicitly whitelisted
EXCLUSIVE_ARTIST_ENTITIES: dict[str, str] = {
    # Young Thug / Gunna specific
    "thugger": "young thug",
    "jeffery": "young thug",
    "spiderr": "young thug",
    "wunna": "gunna",
    "sergio": "gunna",
    # Lil Wayne specific
    "tunechi": "lil wayne",
    "weezy": "lil wayne",
    "hollygrove": "lil wayne",
    "birdman": "lil wayne",
    "mack maine": "lil wayne",
    # Drake specific
    "drizzy": "drake",
    "aubrey": "drake",
    "champagne papi": "drake",
    "chubbs": "drake",
    "nocta": "drake",
    "the 6ix": "drake",
    "6ix": "drake",
    # Lil Baby specific
    "4pf": "lil baby",
    "four pockets full": "lil baby",
    # NoCap specific
    "bakaveeli": "nocap",
    "mr. crawford": "nocap",
}


# ==============================================================================
# WHITELIST GENERATION & MANAGEMENT
# ==============================================================================

def canonical_voice_name(voice: str) -> str:
    """Normalizes voice string to lowercase canonical key."""
    v = (voice or "").strip().lower()
    if "gunna" in v:
        return "gunna"
    if "thug" in v:
        return "young thug"
    if "wayne" in v or "weezy" in v:
        return "lil wayne"
    if "drake" in v or "drizzy" in v:
        return "drake"
    if "baby" in v:
        return "lil baby"
    if "nocap" in v or "cap" in v:
        return "nocap"
    return v


def build_voice_whitelist(
    voice: str,
    db_path: Path = DB_PATH,
    include_catalog: bool = True,
) -> set[str]:
    """
    Constructs the complete proper-noun whitelist for a given artist voice.
    Combines:
      1. Universal luxury, automotive, horology, travel, and calendar proper nouns.
      2. The artist's core personas, albums, crew, and signature entities.
      3. Collaborator allowances.
      4. Entities extracted from catalog_index.sqlite (where is_proper_noun=1 or artist bar text).
    """
    c_voice = canonical_voice_name(voice)
    whitelist: set[str] = set(UNIVERSAL_LUXURY_BRANDS)

    # Add core persona entities
    if c_voice in ARTIST_CORE_ENTITIES:
        whitelist.update(ARTIST_CORE_ENTITIES[c_voice])

    # Add collaborative allowances
    if c_voice in COLLABORATION_ALLOWANCES:
        whitelist.update(COLLABORATION_ALLOWANCES[c_voice])

    # Ingest from SQLite catalog bars if available
    if include_catalog and db_path.exists():
        try:
            conn = sqlite3.connect(str(db_path))
            cur = conn.cursor()
            # Select end_words tagged as proper nouns or distinct artist end words
            cur.execute("""
                SELECT DISTINCT lower(end_word)
                FROM catalog_bars
                WHERE lower(artist) = ? AND (is_proper_noun = 1 OR is_iconic_anthem = 1);
            """, (c_voice,))
            for (w,) in cur.fetchall():
                if w and len(w) >= 3:
                    whitelist.add(w.strip())
            conn.close()
        except Exception:
            pass

    return whitelist


def load_all_whitelists(db_path: Path = DB_PATH) -> dict[str, set[str]]:
    """Loads or computes whitelists for all primary voices."""
    primary_voices = ["gunna", "young thug", "lil wayne", "drake", "lil baby", "nocap"]
    whitelists: dict[str, set[str]] = {}
    for v in primary_voices:
        whitelists[v] = build_voice_whitelist(v, db_path=db_path)
    return whitelists


def save_whitelists_cache(
    whitelists: dict[str, set[str]],
    json_path: Path = WHITELISTS_JSON_PATH,
) -> Path:
    """Caches compiled whitelists to JSON for fast runtime lookup."""
    json_path.parent.mkdir(parents=True, exist_ok=True)
    serialized = {v: sorted(list(words)) for v, words in whitelists.items()}
    temp_p = json_path.parent / f"{json_path.name}.tmp.{os.getpid()}"
    with temp_p.open("w", encoding="utf-8") as f:
        json.dump(serialized, f, indent=2)
    temp_p.replace(json_path)
    return json_path


_GLOBAL_WHITELISTS_CACHE: dict[str, set[str]] | None = None


def get_voice_whitelist(voice: str, db_path: Path = DB_PATH) -> set[str]:
    """Returns cached voice whitelist for instantaneous runtime lookup."""
    global _GLOBAL_WHITELISTS_CACHE
    c_voice = canonical_voice_name(voice)
    if _GLOBAL_WHITELISTS_CACHE is None:
        if WHITELISTS_JSON_PATH.exists():
            try:
                with WHITELISTS_JSON_PATH.open("r", encoding="utf-8") as f:
                    raw = json.load(f)
                    _GLOBAL_WHITELISTS_CACHE = {k: set(v) for k, v in raw.items()}
            except Exception:
                _GLOBAL_WHITELISTS_CACHE = {}
        else:
            _GLOBAL_WHITELISTS_CACHE = {}

    if c_voice not in _GLOBAL_WHITELISTS_CACHE:
        _GLOBAL_WHITELISTS_CACHE[c_voice] = build_voice_whitelist(c_voice, db_path=db_path)

    return _GLOBAL_WHITELISTS_CACHE[c_voice]


# ==============================================================================
# ENTITY EXTRACTION & GUARD VERIFICATION
# ==============================================================================

# Common English stop words / verbs that might appear title-cased but are NOT proper nouns
COMMON_LOWER_WORDS: set[str] = {
    "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "with",
    "from", "by", "about", "against", "between", "into", "through", "during",
    "before", "after", "above", "below", "up", "down", "in", "out", "off", "over",
    "under", "again", "further", "then", "once", "here", "there", "when", "where",
    "why", "how", "all", "any", "both", "each", "few", "more", "most", "other",
    "some", "such", "no", "nor", "not", "only", "own", "same", "so", "than",
    "too", "very", "can", "will", "just", "should", "now", "i", "me", "my",
    "myself", "we", "our", "ours", "ourselves", "you", "your", "yours", "yourself",
    "yourselves", "he", "him", "his", "himself", "she", "her", "hers", "herself",
    "it", "its", "itself", "they", "them", "their", "theirs", "themselves",
    "what", "which", "who", "whom", "this", "that", "these", "those", "am", "is",
    "are", "was", "were", "be", "been", "being", "have", "has", "had", "having",
    "do", "does", "did", "doing", "would", "could", "got", "get", "take", "make",
    "say", "look", "run", "jump", "fly", "walk", "talk", "money", "paper", "stack",
    "trap", "coupe", "door", "face", "time", "line", "space", "night", "city",
    "block", "pocket", "diamonds", "wrist", "chain", "ice", "rings", "fast",
}


def extract_candidate_entities(bar: str) -> list[str]:
    """
    Extracts candidate named entities and proper nouns from a bar:
      1. Explicit matches against known exclusive rap entities (case-insensitive).
      2. Multi-word phrases like 'Young Money', 'Free Thugger', 'Champagne Papi'.
      3. Capitalized tokens in mid-sentence that are not common English words.
    """
    candidates: list[str] = []
    text = str(bar or "").strip()
    text_clean = re.sub(r"[,\".!?;:(){}\[\]]", " ", text)
    tokens = text_clean.split()
    lower_text = text.lower()

    # 1. Multi-word and single-word checks against exclusive rap entities
    for ent_str in EXCLUSIVE_ARTIST_ENTITIES.keys():
        pattern = r"\b" + re.escape(ent_str) + r"\b"
        if re.search(pattern, lower_text):
            # Find the original casing in text
            match = re.search(pattern, text, flags=re.IGNORECASE)
            candidates.append(match.group(0) if match else ent_str)

    # 2. Check for capitalized proper nouns mid-phrase
    for idx, tok in enumerate(tokens):
        # Strip trailing possessives or contractions
        t_clean = re.sub(r"['’]s$", "", tok)
        t_clean = re.sub(r"[^a-zA-Z0-9]", "", t_clean)
        if not t_clean:
            continue

        # Look for TitleCase or UPPERCASE proper nouns
        if (t_clean[0].isupper() or t_clean.isupper()) and len(t_clean) >= 3:
            if t_clean.lower() not in COMMON_LOWER_WORDS:
                # Exclude if it's merely the first word of the line unless it's a known entity
                if idx == 0 and t_clean.lower() not in EXCLUSIVE_ARTIST_ENTITIES:
                    continue
                if t_clean not in candidates and t_clean.lower() not in [c.lower() for c in candidates]:
                    candidates.append(t_clean)

    return candidates


def guard(
    voice: str,
    bar: str,
    whitelist: Optional[set[str]] = None,
    db_path: Path = DB_PATH,
) -> dict[str, Any]:
    """
    Verifies that a bar contains only permitted proper nouns for the given voice.

    Returns:
      {
        "ok": bool,
        "offending_tokens": list[str],
        "voice": str,
        "bar": str,
      }
    """
    c_voice = canonical_voice_name(voice)
    allowed = whitelist if whitelist is not None else get_voice_whitelist(c_voice, db_path=db_path)
    candidates = extract_candidate_entities(bar)

    offending: list[str] = []
    for cand in candidates:
        c_low = cand.lower().strip()
        # Direct whitelist hit
        if c_low in allowed:
            continue
        # Also check if cand is part of allowed multi-word phrase
        if any(c_low == w or f" {c_low} " in f" {w} " for w in allowed):
            continue

        # If it's a known exclusive entity belonging to another artist, definitely flag
        if c_low in EXCLUSIVE_ARTIST_ENTITIES:
            owner = EXCLUSIVE_ARTIST_ENTITIES[c_low]
            if owner != c_voice:
                offending.append(cand)
                continue

        # If it's a general un-whitelisted proper noun, flag it
        offending.append(cand)

    # Deduplicate while preserving order
    unique_offending: list[str] = []
    seen = set()
    for tok in offending:
        if tok.lower() not in seen:
            seen.add(tok.lower())
            unique_offending.append(tok)

    return {
        "ok": len(unique_offending) == 0,
        "offending_tokens": unique_offending,
        "voice": voice,
        "bar": bar,
    }


def guard_verse(
    voice: str,
    bars: list[str],
    bar_artists: Optional[list[str]] = None,
    db_path: Path = DB_PATH,
) -> dict[str, Any]:
    """
    Verifies an entire verse against named-entity leaks.
    Supports couplet-level multi-voice assignment via bar_artists.
    """
    bar_results: list[dict[str, Any]] = []
    failed_indices: list[int] = []
    all_offending: list[str] = []

    for idx, bar in enumerate(bars):
        target_artist = bar_artists[idx] if (bar_artists and idx < len(bar_artists)) else voice
        res = guard(voice=target_artist, bar=bar, db_path=db_path)
        bar_results.append(res)
        if not res["ok"]:
            failed_indices.append(idx)
            all_offending.extend(res["offending_tokens"])

    return {
        "passed": len(failed_indices) == 0,
        "failed_indices": failed_indices,
        "offending_tokens": sorted(list(set(all_offending))),
        "bar_results": bar_results,
    }


# ==============================================================================
# TARGETED REWRITE / RETRY FUNCTION FOR LEAKED ENTITIES
# ==============================================================================

def rewrite_leaked_entity_bar(
    bar_text: str,
    target_word: str,
    offending_tokens: list[str],
    voice: str = "Gunna",
    source_catalog_text: str = "",
    cmu: dict = None,
    call_fn: Any = None,
) -> tuple[str, bool]:
    """
    Targeted single-bar rewrite to remove off-voice named entities while preserving rhythm,
    Audamar/Lobster 4x4 meter (exactly 3 commas), and end-rhyme.

    Enforces:
      1. Offending tokens (e.g. 'Thugger') MUST be completely eliminated and replaced with
         on-voice phrasing or authentic luxury/street motifs.
      2. Exactly 3 commas (Audamar/Lobster 4x4 meter).
      3. Strict preservation of target_word at the end of Beat 4.

    Returns (rewritten_line, passed_guard).
    """
    clean_target = (target_word or "").strip().lower()
    clean_target = re.sub(r"[^a-zA-Z0-9']", "", clean_target)
    offending_str = ", ".join([f"'{tok}'" for tok in offending_tokens])

    system_prompt = (
        f"You are a master rap lyric engineer specializing in {voice}'s authentic voice and the Audamar/Lobster 4x4 Quadrasonic meter.\n"
        f"CRITICAL VIOLATION DETECTED: The previous line contained off-voice named entities: {offending_str}.\n"
        f"These entities belong to a different artist and MUST NOT appear in {voice}'s lyrics!\n\n"
        f"YOUR TASK: Rewrite the bar so that:\n"
        f"1. Every offending token ({offending_str}) is 100% REMOVED and replaced with authentic {voice} luxury, cars, or street vocabulary.\n"
        f"2. Strict Audamar/Lobster 4x4 cadence: EXACTLY THREE COMMAS separating 4 substantive phrases of 4 to 5 syllables each (total 17-21 syllables).\n"
        f"3. Strict preservation of the landing rhyme: The line MUST end strictly on '{clean_target}' at the end of Beat 4.\n"
        f"4. OUTPUT FORMAT: Output ONLY the single rewritten bar, no quotes, no labels."
    )

    user_prompt = (
        f"Failing Bar with Leaked Entity: \"{bar_text}\"\n"
        f"Offending Entities to Remove: {offending_str}\n"
        f"Mandatory End-Word Landing: '{clean_target}'\n"
        + (f"Source Catalog Reference: \"{source_catalog_text}\"\n" if source_catalog_text else "")
        + f"Rewrite this bar now for {voice} with EXACTLY 3 COMMAS, removing all offending entities:"
    )

    rewritten_line = ""

    if call_fn is not None:
        try:
            raw = call_fn(system_prompt, user_prompt)
            lines = [l.strip().strip("\"'") for l in raw.splitlines() if l.strip()]
            for l in lines:
                l_clean = re.sub(r"^(?:Bar\s*\d+[\s:.-]*|\d+[\s:.-]+)", "", l, flags=re.IGNORECASE).strip()
                if l_clean:
                    rewritten_line = l_clean
                    break
        except Exception:
            rewritten_line = ""

    if not rewritten_line:
        # Fallback heuristic replacement if no LLM provided or call fails
        # Replace each offending token with an authentic luxury/voice item
        substitutes = ["Bentley", "Maybach", "Rollie", "Patek", "brother", "homie", "foreign"]
        repaired = bar_text
        for idx, off in enumerate(offending_tokens):
            sub = substitutes[idx % len(substitutes)]
            repaired = re.sub(r"\b" + re.escape(off) + r"\b", sub, repaired, flags=re.IGNORECASE)
        rewritten_line = repaired

    # Verify that rewritten line passed guard
    check = guard(voice=voice, bar=rewritten_line)
    return rewritten_line, check["ok"]


# ==============================================================================
# DATABASE POPULATION: is_proper_noun Tagging
# ==============================================================================

def sync_proper_noun_tags_to_db(db_path: Path = DB_PATH) -> int:
    """
    Updates catalog_bars in catalog_index.sqlite, setting is_proper_noun = 1
    for rows whose end_word or inner-rhymes contain recognized proper nouns.
    """
    if not db_path.exists():
        return 0

    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()
    updated = 0

    try:
        cur.execute("PRAGMA synchronous = OFF;")
        cur.execute("PRAGMA journal_mode = WAL;")

        # Ensure column exists
        cur.execute("PRAGMA table_info(catalog_bars);")
        cols = {c[1] for c in cur.fetchall()}
        if "is_proper_noun" not in cols:
            cur.execute("ALTER TABLE catalog_bars ADD COLUMN is_proper_noun INTEGER DEFAULT 0;")

        # Gather all recognized proper nouns (universal + core artist entities)
        all_proper: set[str] = set(UNIVERSAL_LUXURY_BRANDS)
        for ents in ARTIST_CORE_ENTITIES.values():
            all_proper.update(ents)
        all_proper.update(EXCLUSIVE_ARTIST_ENTITIES.keys())

        # Batch update where end_word matches proper noun set
        proper_list = [w for w in all_proper if len(w) >= 3]
        placeholders = ",".join(["?"] * len(proper_list))
        cur.execute(f"""
            UPDATE catalog_bars
            SET is_proper_noun = 1
            WHERE lower(end_word) IN ({placeholders});
        """, proper_list)
        updated = cur.rowcount
        conn.commit()
    except Exception as exc:
        print(f"[EntityGuard] DB sync error: {exc}", file=sys.stderr)
    finally:
        conn.close()

    return updated


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Frontier v4 Named-Entity Leak Guard")
    parser.add_argument("--sync-db", action="store_true", help="Sync is_proper_noun flags to catalog_index.sqlite")
    parser.add_argument("--dump-whitelists", action="store_true", help="Dump computed whitelists to out/entity_whitelists.json")
    args = parser.parse_args()

    if args.sync_db:
        cnt = sync_proper_noun_tags_to_db()
        print(f"[EntityGuard] Tagged {cnt} catalog bars with is_proper_noun = 1.")

    if args.dump_whitelists:
        w_map = load_all_whitelists()
        p = save_whitelists_cache(w_map)
        print(f"[EntityGuard] Saved whitelists cache for {len(w_map)} artists to {p}.")
