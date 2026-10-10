#!/usr/bin/env python3
"""Mine wordplay candidate chips from newly recovered Drake songs + 288 API songs + GODSPLAN.

Outputs to docs/play-on-words/drake-recovery-candidates.jsonl.
Keeps rejected rows with reject_reason populated for auditing.
"""

import html
import json
import re
import sqlite3
from pathlib import Path

ROOT = Path("/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync")
DB = ROOT / "tools/bar-hits-catalog/BarHitsCatalog.sqlite"
DRAKE_JSONL = ROOT / "docs/play-on-words/genius-clicks/drake.jsonl"
OUT_CANDIDATES = ROOT / "docs/play-on-words/drake-recovery-candidates.jsonl"
UNWIRED = ROOT / "docs/play-on-words/unwired-chips.md"
STORE = ROOT / "XJournal AI/NounBankStore.swift"

HEDGE_WORDS = [
    "possibly", "might", "could be", "probably", "likely", "perhaps", 
    "sounds like", "may be referring", "could refer", "fans have speculated", 
    "allegedly", "speculated", "may refer", "unclear", "speculation"
]

BANNED_TOPICS = [
    r"\b(sex|sexual|condom|orgasm|nude|naked|ejacul\w*|sperm|intercourse|from the rear|rear end|in bed|one night stand|penis|vagina|pussy|dick|blowjob|fellatio)\b",
    r"\b(cocaine|heroin|meth|fentanyl|percocet|xanax|promethazine|codeine|lean|weed|marijuana|ecstasy|molly)\b",
    r"\b(gun|glock|beretta|choppa|trigger|bullet|shoot|clip|draco|revolver|pistol|mac-10|uzi)\b",
    r"\b(blood|crip|bd|gd|gang|snitch|police code|10-4|10-40|laundering|money laundering)\b",
    r"\b(god|jesus|christ|allah|bible|quran|prayer|synagogue|church)\b"
]

SEX_STRICT = re.compile(
    r"\b(sex|sexual|condom|orgasm|nude|naked|ejacul\w*|sperm|intercourse|"
    r"from the rear|rear end|in bed|one night stand|penis|vagina|pussy|dick|blowjob|fellatio)\b",
    re.I,
)


def clean(s):
    s = re.sub(r"<[^>]+>", " ", s or "")
    s = html.unescape(s)
    return re.sub(r"\s+", " ", s).strip()


def norm(s):
    s = clean(s).lower().replace("*", "").replace("’", "'").replace("‘", "'")
    s = re.sub(r"[^a-z0-9' ]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def load_known_chips():
    chips = {}
    if STORE.exists():
        text = STORE.read_text()
        for m in re.finditer(r'NounBankItem\([^)]*name:\s*"([^"]+)"', text):
            name = m.group(1).strip()
            chips[name.lower()] = "NounBankStore.swift"
    if UNWIRED.exists():
        for line in UNWIRED.read_text().splitlines():
            line = line.strip()
            if line.startswith("|") and not line.startswith("| ---") and not line.startswith("| Chip"):
                parts = [p.strip() for p in line.split("|")]
                if len(parts) > 1 and parts[1]:
                    name = parts[1].strip()
                    chips.setdefault(name.lower(), "unwired-chips.md")
    return chips


def extract_wordplay_signal(meaning, line):
    """
    Returns (signal_type, heard, partner) or (None, None, None)
    """
    low_m = meaning.lower()
    low_l = line.lower()
    
    # 1. Look for explicit play on words / pun / double meaning markers
    # e.g., "play on words with X and Y", "pun on 'X'", "double entendre referring to X and Y"
    
    # Check parens in meaning: e.g. "(cancel)", "(Drake)"
    parens = re.findall(r"\(([^)]{2,60})\)", meaning)
    
    # Check markers
    is_play = any(m in low_m for m in ["play on words", "wordplay", "pun on", "play on", "double meaning", "double entendre", "homophone", "sounds like", "idiom", "idiomatic"])
    
    signal_type = None
    if "homophone" in low_m or "sounds like" in low_m or "soundalike" in low_m:
        signal_type = "Soundalike / Homophone"
    elif "idiom" in low_m or "idiomatic" in low_m:
        signal_type = "Idiom / Idiomatic flip"
    elif "double meaning" in low_m or "double entendre" in low_m:
        signal_type = "Double meaning"
    elif "play on" in low_m or "pun" in low_m or "wordplay" in low_m:
        signal_type = "Play-on-words"
    elif "juxtaposition" in low_m or "contrast" in low_m:
        signal_type = "Juxtaposition"
    elif is_play:
        signal_type = "Play-on-words"
        
    if not signal_type:
        return None, None, None
        
    # Find heard & partner
    # Try to extract quoted words or paren words
    quotes = re.findall(r'["“\']([^"”\']{2,40})["”\']', meaning)
    
    heard = ""
    partner = ""
    
    # Look for quoted or paren terms from meaning that are not in line
    line_words = set(norm(line).split())
    for q in quotes + parens:
        q_norm = norm(q)
        q_words = set(q_norm.split())
        if q_words and not (q_words & line_words) and len(q_norm) > 2:
            partner = q.strip()
            break
            
    # For heard word, find word in line that is mentioned in meaning or sounds like partner
    for w in norm(line).split():
        if len(w) > 3 and w in low_m:
            heard = w
            break
    if not heard and norm(line).split():
        heard = norm(line).split()[0]
        
    return signal_type, heard, partner


def mine_candidates():
    print("Mining wordplay candidates from Drake API songs...", flush=True)
    known_chips = load_known_chips()
    
    # Find all songs with source == "api" or GODSPLAN
    songs_to_mine = set()
    song_genius_ids = {}
    
    lines_by_song = []
    
    with open(DRAKE_JSONL, "r", encoding="utf-8") as f:
        for line in f:
            if not line.strip():
                continue
            row = json.loads(line)
            t = row.get("type")
            if t == "song" and (row.get("source") == "api" or row.get("song") == "GODSPLAN"):
                songs_to_mine.add(row.get("song"))
                song_genius_ids[row.get("song")] = row.get("genius_id")
            elif t == "line":
                lines_by_song.append(row)
                
    print(f"Total API/recovered songs to mine: {len(songs_to_mine)}")
    
    candidates = []
    
    kept_count = 0
    reject_count = 0
    
    for row in lines_by_song:
        song = row.get("song")
        if song not in songs_to_mine:
            continue
            
        meaning = (row.get("meaning") or "").strip()
        frag = (row.get("line") or "").strip()
        vault_lines = row.get("vault_lines") or []
        votes = row.get("votes")
        state = row.get("state") or ""
        ann_id = str(row.get("annotation_id") or "")
        genius_id = song_genius_ids.get(song)
        
        vault_line = vault_lines[0] if vault_lines else frag
        
        # Check reject reasons
        reject_reason = None
        
        # 1. Empty meaning or restatement
        if not meaning:
            reject_reason = "empty_note"
        elif norm(meaning) == norm(frag):
            reject_reason = "restatement"
        elif meaning.startswith("NOT:") or "[?]" in meaning:
            reject_reason = "lyric_correction"
        elif votes is not None and votes < 0:
            reject_reason = "negative_votes"
            
        # 2. Check hedged language
        if not reject_reason:
            low_m = meaning.lower()
            for hedge in HEDGE_WORDS:
                if re.search(r"\b" + re.escape(hedge) + r"\b", low_m):
                    reject_reason = f"hedged_note: {hedge}"
                    break
                    
        # 3. Check sexual content / banned topics
        if not reject_reason:
            if SEX_STRICT.search(frag) or SEX_STRICT.search(vault_line) or SEX_STRICT.search(meaning):
                reject_reason = "sexual_content"
            else:
                for pattern in BANNED_TOPICS:
                    if re.search(pattern, frag, re.I) or re.search(pattern, meaning, re.I):
                        reject_reason = "banned_topic"
                        break
                        
        # 4. Check scope (>12 chars or whole bar)
        if not reject_reason:
            if len(frag) < 12 and not vault_lines:
                reject_reason = "fragment_too_short"
                
        # 5. Extract signal
        signal_type, heard, partner = None, None, None
        if not reject_reason:
            signal_type, heard, partner = extract_wordplay_signal(meaning, frag)
            if not signal_type:
                reject_reason = "no_wordplay_signal"
            elif meaning.lower().strip() in ["double entendre", "clever wordplay", "wordplay", "double meaning"]:
                reject_reason = "bare_wordplay_label"
                
        # 6. Check 0-vote pending rule: 0-vote pending notes OK only if both halves sit on one stored bar
        halves_class = "SECOND_HALF_MISSING_OR_WEAK"
        if not reject_reason:
            # Check if partner exists in line
            if partner and partner.lower() in vault_line.lower():
                halves_class = "BOTH_ON_LINE"
            elif partner and partner.lower() in known_chips:
                halves_class = "PARTNER_FILED_ELSEWHERE"
            else:
                halves_class = "SECOND_HALF_MISSING_OR_WEAK"
                
            if state != "accepted" and (votes is None or votes <= 0) and halves_class != "BOTH_ON_LINE":
                reject_reason = "pending_zero_votes_not_both_on_line"

        # Chip form
        if partner:
            chip_form = f"{vault_line} ({partner})"
        else:
            chip_form = vault_line
            
        note_excerpt = meaning[:300].replace("\n", " ")
        
        rec = {
            "song": song,
            "genius_id": genius_id,
            "annotation_id": ann_id,
            "votes": votes,
            "vault_line": vault_line,
            "heard": heard or "",
            "partner": partner or "",
            "chip_form": chip_form,
            "signal_type": signal_type or "",
            "halves_class": halves_class if not reject_reason else "",
            "note_excerpt": note_excerpt,
            "reject_reason": reject_reason,
        }
        
        candidates.append(rec)
        if reject_reason is None:
            kept_count += 1
        else:
            reject_count += 1
            
    print(f"Mining complete. Kept: {kept_count}, Rejected: {reject_count}, Total candidate rows: {len(candidates)}")
    
    with open(OUT_CANDIDATES, "w", encoding="utf-8") as f:
        for c in candidates:
            f.write(json.dumps(c, ensure_ascii=False) + "\n")
            
    # Breakdown of kept
    kept_by_class = {}
    kept_by_signal = {}
    for c in candidates:
        if c["reject_reason"] is None:
            hc = c["halves_class"]
            st = c["signal_type"]
            kept_by_class[hc] = kept_by_class.get(hc, 0) + 1
            kept_by_signal[st] = kept_by_signal.get(st, 0) + 1
            
    print("Kept breakdown by halves_class:", kept_by_class)
    print("Kept breakdown by signal_type:", kept_by_signal)


if __name__ == "__main__":
    mine_candidates()
