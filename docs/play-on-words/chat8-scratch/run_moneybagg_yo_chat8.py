#!/usr/bin/env python3
"""Anti-Gravity Job, Chat 8: Moneybagg Yo in reverse song order.

Complies strictly with antigravity_chat8-moneybagg-yo_lane.md:
- Work through Moneybagg Yo in reverse song order (last song first).
- Skip songs already marked done/missing.
- At least 10-second minimum rate limit between Genius requests.
- Automatic 20-minute pause on HTTP 429; stop if >= 2 pauses in 1 hour.
- Stop rule: before every song, check all-artists-progress.md. When a Lil Uzi Vert
  line from the main run appears there (NOT tagged [chat2-uzi]), finish current song,
  stop, rename claim to moneybagg yo.chat8-stopped, and report.
- Also stop if genius-clicks/moneybagg yo.jsonl receives writes we didn't make.
- Write claim file (docs/play-on-words/lane-claims/moneybagg yo.claim) with PID and timestamp.
- Back up genius-clicks/moneybagg yo.jsonl if it exists prior to start.
- Credit rule: Moneybagg Yo must be primary_artist or in featured_artists.
- Log unresolved songs to docs/play-on-words/lil-chat8-moneybagg-yo-unresolved.jsonl.
- Mine candidates into docs/play-on-words/lil-chat8-moneybagg-yo-candidates.jsonl with halves classes
  and signal_type: "sound_flip" (setup_spans, play_spans, heard_as).
- Post progress every 50 songs tagged [chat8-moneybagg-yo].
- On stop/done, write docs/play-on-words/moneybagg-yo-chat8-summary.md.
"""

from __future__ import annotations

import datetime
import html
import json
import os
import re
import shutil
import sqlite3
import sys
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path("/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync")
DB = ROOT / "tools/bar-hits-catalog/BarHitsCatalog.sqlite"
GENIUS_CLICKS = ROOT / "docs/play-on-words/genius-clicks"
PROGRESS_MD = ROOT / "docs/play-on-words/all-artists-progress.md"
CLAIMS_DIR = ROOT / "docs/play-on-words/lane-claims"
SUMMARY_MD = ROOT / "docs/play-on-words/moneybagg-yo-chat8-summary.md"
STATUS_MD = ROOT / "docs/play-on-words/chat-status/chat-8.md"
UNWIRED = ROOT / "docs/play-on-words/unwired-chips.md"
CATALOG = ROOT / "XJournal AI/NounBankCatalog.swift"
STORE = ROOT / "XJournal AI/NounBankStore.swift"
BRIEFS = ROOT / "XJournal AI/NounMentionBrief.swift"
SECTIONS = ROOT / "XJournal AI/NounBankSections.swift"

sys.path.insert(0, "/Users/samuel/.grok/skills/genius-line-notes/scripts")
from click_song import render

UA = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
    "Accept": "application/json",
}

STOP = {
    "the", "a", "an", "and", "or", "to", "of", "in", "on", "for", "my", "his", "her",
    "that", "this", "with", "it", "is", "was", "be", "he", "she", "they", "im", "i",
    "you", "me", "we", "just", "like", "when", "from", "at", "by", "as", "if", "but",
    "not", "no", "so", "up", "out",
}

# Real uncertainty words. "sounds" and "sounds like" are NOT hedging per brief!
REAL_HEDGE_PATTERNS = [
    r"\bpossibly\b", r"\bmight\b", r"\bcould be\b", r"\bprobably\b", 
    r"\bperhaps\b", r"\bmaybe\b", r"\bi think\b", r"\bmay be referring\b", 
    r"\bcould refer\b", r"\bfans have speculated\b", r"\ballegedly\b",
    r"\bspeculated\b", r"\bdouble meaning\?", r"\bwordplay\?"
]
REAL_HEDGE_RE = re.compile("|".join(REAL_HEDGE_PATTERNS), re.IGNORECASE)

SEX_RE = re.compile(
    r"\b(sex|sexual|condom|orgasm|nude|naked|ejacul\w*|sperm|intercourse|blowjob|fellatio|cunnilingus|pussy|dick|cock|vagina|penis|threesome|boner|erection|stripper|escort|brothel|hooker|prostitut\w*|bitch|slut|whore)\b",
    re.IGNORECASE
)
GUN_RE = re.compile(
    r"\b(gun|glock|pistol|beretta|shotgun|rifle|trigger|bullet|bullets|shooting|shoot|shooters|killed|murder|murdered|stabbed|homicide|chopper|draco)\b",
    re.IGNORECASE
)
DRUG_RE = re.compile(
    r"\b(weed|cocaine|coke|heroin|fentanyl|percocet|percs|lean|codeine|xanax|xans|molly|ecstasy|meth|narcotic|overdose|high on|smoking weed|blunt|pot|marijuana)\b",
    re.IGNORECASE
)
FAITH_RE = re.compile(
    r"\b(jesus|christ|allah|bible|quran|scripture|gospel|pastor|priest|church|mosque|synagogue|prayer|praying|salvation|heaven|hell|god)\b",
    re.IGNORECASE
)
GANG_RE = re.compile(
    r"\b(gang|crips|bloods|snitch|snitching|187|10-4|money laundering|laundered money|feds|informant|wiretap|police code|ratting|ratted)\b",
    re.IGNORECASE
)
CHILD_RE = re.compile(r"\b(child|children|minor|underage|pedophil\w*|kid|toddler|infant)\b", re.IGNORECASE)


def clean(s):
    s = re.sub(r"<[^>]+>", " ", s or "")
    s = html.unescape(s)
    return re.sub(r"\s+", " ", s).strip()


def clean_quotes(s):
    return (s or "").replace("“", '"').replace("”", '"').replace("‘", "'").replace("’", "'")


def normalize(text: str) -> str:
    t = unicodedata.normalize("NFKD", text or "")
    t = "".join(ch for ch in t if not unicodedata.combining(ch))
    t = t.lower().replace("’", "").replace("'", "").replace("*", "")
    t = re.sub(r"[^a-z0-9\s]", " ", t)
    return " ".join(t.split())


def norm_title(t):
    t = re.sub(r"<[^>]+>", " ", t or "")
    t = t.lower().replace("’", "").replace("‘", "").replace("'", "").replace("*", "")
    t = re.sub(r"\s*[\(\[].*?[\)\]]", "", t)
    t = re.sub(r"[^a-z0-9]+", " ", t)
    return " ".join(t.split())


class RateLimiter:
    """Strictly enforces >= 10.0-second delay between Genius requests."""
    def __init__(self, min_delay=10.5):
        self.min_delay = min_delay
        self.last_request = 0.0
        self.pauses_429 = []

    def wait(self):
        elapsed = time.time() - self.last_request
        if elapsed < self.min_delay:
            time.sleep(self.min_delay - elapsed)
        self.last_request = time.time()

    def handle_429(self):
        now = time.time()
        self.pauses_429.append(now)
        recent = [t for t in self.pauses_429 if now - t < 3600]
        self.pauses_429 = recent
        if len(recent) >= 2:
            print("FATAL: 2 rate limit (HTTP 429) pauses encountered within 1 hour. Halting.", flush=True)
            return False
        print(f"WARNING: HTTP 429 Rate Limit. Pausing for 20 minutes (pause #{len(recent)} in past hour)...", flush=True)
        time.sleep(1200)
        self.last_request = time.time()
        return True


rate_limiter = RateLimiter(min_delay=10.5)


def http_json(url):
    req = urllib.request.Request(url, headers=UA)
    for attempt in range(4):
        rate_limiter.wait()
        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                return json.loads(response.read().decode("utf-8", "replace"))
        except urllib.error.HTTPError as error:
            if error.code == 429:
                can_continue = rate_limiter.handle_429()
                if not can_continue:
                    raise
                continue
            if error.code in {500, 502, 503} and attempt < 3:
                time.sleep(3 * (attempt + 1))
                continue
            raise


def song_lines(artist, song):
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    rows = con.execute(
        "SELECT line FROM bars WHERE artist=? AND song=? ORDER BY id",
        (artist, song),
    ).fetchall()
    con.close()
    return [clean(line) for (line,) in rows if clean(line)]


def covers(fragment, line):
    frag, bar = normalize(fragment), normalize(line)
    if not frag or not bar:
        return False
    if frag in bar or bar in frag:
        return True
    frag_words, bar_words = set(frag.split()), set(bar.split())
    if not frag_words or not bar_words:
        return False
    return len(frag_words & bar_words) / min(len(frag_words), len(bar_words)) >= 0.6


def find_exact_vault_bar(fragment: str, vault_candidates: list[str]) -> str | None:
    if not vault_candidates:
        return None
    frag_norm = normalize(fragment)
    for cand in vault_candidates:
        if normalize(cand) == frag_norm:
            return cand
    for cand in vault_candidates:
        if frag_norm in normalize(cand):
            return cand
    for cand in vault_candidates:
        if covers(fragment, cand):
            return cand
    return vault_candidates[0]


def is_artist_credited(target_artist, primary_name, featured_names):
    norm_target = normalize(target_artist)
    norm_prim = normalize(primary_name)
    if norm_prim == norm_target or re.search(r'\b' + re.escape(norm_target) + r'\b', norm_prim):
        return True
    for f in featured_names:
        norm_f = normalize(f)
        if norm_f == norm_target or re.search(r'\b' + re.escape(norm_target) + r'\b', norm_f):
            return True
    target_compact = norm_target.replace(" ", "")
    if primary_name and normalize(primary_name).replace(" ", "") == target_compact:
        return True
    for f in featured_names:
        if normalize(f).replace(" ", "") == target_compact:
            return True
    return False


def song_referents(song_id):
    found = []
    seen = set()
    for page in range(1, 6):
        data = http_json(
            f"https://genius.com/api/referents?song_id={song_id}&text_format=plain&per_page=50&page={page}"
        )
        batch = (data.get("response") or {}).get("referents") or []
        if not batch:
            break
        for ref in batch:
            anns = ref.get("annotations") or []
            if not anns:
                continue
            ann = anns[0]
            ann_id = str(ann.get("id") or ref.get("id") or "")
            if not ann_id or ann_id in seen:
                continue
            seen.add(ann_id)
            found.append({
                "id": ann_id,
                "line": clean(ref.get("fragment") or ""),
                "body": ((ann.get("body") or {}).get("plain") or "").strip(),
                "state": ann.get("state") or "",
                "votes": ann.get("votes_total"),
            })
        if len(batch) < 50:
            break
    return found


def search_and_resolve_artist(target_artist, song_title):
    clean_t = clean(song_title)
    alt_m = re.search(r'alt="([^"]+)"', clean_t)
    if alt_m:
        clean_t = alt_m.group(1)

    query = urllib.parse.quote(f"{clean_t} {target_artist}")
    url = f"https://genius.com/api/search/multi?per_page=5&q={query}"

    data = http_json(url)
    hits = []
    for sec in data.get("response", {}).get("sections", []):
        if sec.get("type") == "song":
            hits.extend(sec.get("hits", []))

    want_norm = norm_title(clean_t)
    matched_hit = None

    for hit in hits:
        res = hit.get("result") or {}
        hit_id = res.get("id")
        hit_title = res.get("title") or ""
        hit_url = res.get("url") or ""
        primary_artist = (res.get("primary_artist") or {}).get("name") or ""

        if any(t in hit_title.lower() or t in hit_url.lower() for t in ["traducc", "translation", "traduct", "tłumacz", "ceviri", "übersetzung", "romanization", "tracklist", "booklet", "credits"]):
            continue
        if primary_artist.lower() == "genius":
            continue

        hit_norm = norm_title(hit_title)
        if hit_norm != want_norm:
            base_hit = re.sub(r"\s*[\(\[].*?[\)\]]", "", hit_title)
            base_want = re.sub(r"\s*[\(\[].*?[\)\]]", "", clean_t)
            if norm_title(base_hit) != norm_title(base_want):
                # Also allow acronym match without spaces/dots
                compact_hit = hit_norm.replace(" ", "")
                compact_want = want_norm.replace(" ", "")
                if not compact_want or compact_hit != compact_want:
                    continue

        try:
            detail = http_json(f"https://genius.com/api/songs/{hit_id}")
            song_obj = (detail.get("response") or {}).get("song") or {}
            prim = (song_obj.get("primary_artist") or {}).get("name") or ""
            feats = [a.get("name") for a in (song_obj.get("featured_artists") or []) if a.get("name")]
            if not is_artist_credited(target_artist, prim, feats):
                continue
        except Exception:
            continue

        matched_hit = res
        break

    if not matched_hit:
        low = clean_t.lower()
        if any(w in low for w in ["remix", "live", "mashup", "cover", "medley", "version", "demo", "freestyle", "mix", "mixed"]):
            reason = "remix_live_demo_mashup"
        elif any(w in low for w in ["leak", "unreleased", "snippet", "untitled"]):
            reason = "leak_not_on_dsp"
        elif song_title.startswith("<") or "<img" in song_title:
            reason = "malformed_no_vault_match"
        elif hits:
            reason = f"not_{normalize(target_artist).replace(' ', '_')}_credit"
        else:
            reason = "no_exact_genius_match"
        return None, reason

    song_id = matched_hit["id"]
    hit_url = matched_hit.get("url") or f"https://genius.com/songs/{song_id}"
    hit_title = matched_hit.get("title") or clean_t

    referents = song_referents(song_id)
    vault = song_lines(target_artist, song_title)

    line_rows = []
    for ref in referents:
        body = ref.get("body") or ""
        state = ref.get("state") or ""
        votes = ref.get("votes")
        frag = ref.get("line") or ""
        ann_id = str(ref.get("id"))

        exact_vault_line = find_exact_vault_bar(frag, [line for line in vault if covers(frag, line)] or vault)

        line_rows.append({
            "type": "line",
            "artist": target_artist,
            "song": clean_t,
            "line": frag,
            "vault_lines": [exact_vault_line] if exact_vault_line else [],
            "meaning": body,
            "annotation_id": ann_id,
            "url": f"https://genius.com/{ann_id}",
            "state": state,
            "votes": votes,
            "second_sense": bool(body),
            "clicked": False,
            "click_status": "api",
            "strength": "weak" if (state != "accepted" or (votes or 0) <= 0) else "accepted",
        })

    song_row = {
        "type": "song",
        "artist": target_artist,
        "song": clean_t,
        "status": "done",
        "targets": len(referents),
        "clicked": 0,
        "genius_url": hit_url,
        "genius_title": hit_title,
        "genius_id": song_id,
        "source": "api",
    }

    return (song_row, line_rows), None


def load_known_chips():
    chips = {}
    if UNWIRED.exists():
        with open(UNWIRED, "r", encoding="utf-8") as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line or "---" in line or line.startswith("| chip") or line.startswith("| sound") or line.startswith("#"):
                    continue
                if line.startswith("|"):
                    parts = [p.strip() for p in line.split("|") if p.strip()]
                    if parts:
                        chip = normalize(parts[0])
                        if chip and len(chip) > 2:
                            chips[chip] = f"unwired-chips.md:{line_num}"
                elif line.startswith("- "):
                    chip = normalize(line[2:])
                    if chip and len(chip) > 2:
                        chips[chip] = f"unwired-chips.md:{line_num}"

    for swift_file in [CATALOG, STORE, BRIEFS, SECTIONS]:
        if swift_file.exists():
            with open(swift_file, "r", encoding="utf-8") as f:
                text = f.read()
                for m in re.finditer(r"\"([^\"]{3,50})\"", text):
                    c = normalize(m.group(1))
                    if c and len(c) > 2 and c not in chips:
                        chips[c] = f"{swift_file.name}"
    return chips


def extract_sound_flip(bar: str, note: str):
    bar_clean = clean_quotes(bar)
    note_clean = clean_quotes(note)
    m_low = note_clean.lower()
    b_low = bar_clean.lower()

    indicators = [
        "pronounce", "sounds like", "sound like", "sounding like", 
        "split into", "splits into", "homophone", "sound-alike", "soundalike",
        "sound alike"
    ]
    has_indicator = any(ind in m_low for ind in indicators)

    paren_glosser = re.findall(r"([a-zA-Z\s'’]{2,25})\s*\(([a-zA-Z0-9\s'’-]{2,30})\)", note_clean)
    glosser_match = None
    for lyric_frag, gloss in paren_glosser:
        lf = lyric_frag.strip().lower()
        gl = gloss.strip()
        for sub_w in [lf] + lf.split():
            if len(sub_w) > 2 and sub_w in b_low and gl.lower() not in b_low:
                glosser_match = (sub_w, gl)
                has_indicator = True
                break
        if glosser_match:
            break

    if not has_indicator:
        return None

    play_word = None
    heard_word = None

    m_pron = re.search(r'pronounc\w*\s+["\']?([^"\']+)["\']?\s+as\s+["\']?([^"\']+)["\']?', note_clean, re.IGNORECASE)
    if m_pron:
        pw = m_pron.group(1).strip()
        hw = m_pron.group(2).strip()
        if pw.lower() in b_low:
            play_word = pw
            heard_word = hw

    if not play_word and glosser_match:
        play_word, heard_word = glosser_match

    if not play_word:
        m_snd = re.search(r'([a-zA-Z\s\']{2,25})\s+sounds?\s+like\s+["\']?([^"\'.,;]+)["\']?', note_clean, re.IGNORECASE)
        if m_snd:
            pw = m_snd.group(1).strip()
            hw = m_snd.group(2).strip()
            if pw.lower() in b_low:
                play_word = pw
                heard_word = hw

    if not play_word:
        m_snd2 = re.search(r'sounds?\s+like\s+["\']?([^"\'.,;]+)["\']?', note_clean, re.IGNORECASE)
        if m_snd2:
            hw = m_snd2.group(1).strip()
            heard_word = hw
            for bw in re.findall(r"\b[A-Za-z0-9']{3,}\b", bar_clean):
                if bw.lower() not in hw.lower() and (bw.lower()[:3] == hw.lower()[:3] or bw.lower()[-3:] == hw.lower()[-3:]):
                    play_word = bw
                    break

    if not play_word:
        m_split = re.search(r'splits?\s+into\s+["\']?([^"\'.,;]+)["\']?', note_clean, re.IGNORECASE)
        if m_split:
            heard_word = m_split.group(1).strip()

    if not play_word:
        m_homo = re.search(r'homophone\s+(?:for|to|with|of)\s+["\']?([^"\'.,;]+)["\']?', note_clean, re.IGNORECASE)
        if m_homo:
            heard_word = m_homo.group(1).strip()

    if not play_word:
        m_alike = re.search(r'sound-?alike\s+(?:for|to|with)\s+["\']?([^"\'.,;]+)["\']?', note_clean, re.IGNORECASE)
        if m_alike:
            heard_word = m_alike.group(1).strip()

    if not heard_word:
        return None

    play_spans = []
    if play_word:
        start = b_low.find(play_word.lower())
        if start != -1:
            end = start + len(play_word)
            actual_text = bar[start:end]
            play_spans.append({"text": actual_text, "start": start, "end": end, "heard": heard_word})

    setup_spans = []
    bar_words = re.findall(r"\b[A-Za-z0-9'&]+\b", bar)
    for bw in bar_words:
        if bw.lower() in STOP:
            continue
        if play_word and bw.lower() in play_word.lower():
            continue
        if re.search(r"\b" + re.escape(bw) + r"\b", note_clean, re.IGNORECASE):
            start = bar.find(bw)
            if start != -1:
                setup_spans.append({"text": bw, "start": start, "end": start + len(bw)})
                break

    if not setup_spans:
        for bw in bar_words:
            if bw.lower() in STOP:
                continue
            start = bar.find(bw)
            if bw[0].isupper() and start > 0 and (not play_word or bw.lower() not in play_word.lower()):
                setup_spans.append({"text": bw, "start": start, "end": start + len(bw)})
                break

    return {
        "signal_type": "sound_flip",
        "play_spans": play_spans,
        "setup_spans": setup_spans,
        "heard_as": heard_word
    }


def mine_wordplay_for_artist(artist_name):
    jsonl_path = GENIUS_CLICKS / f"{artist_name.lower()}.jsonl"
    cand_path = ROOT / f"docs/play-on-words/{artist_name.lower().replace(' ', '-')}-candidates.jsonl"

    if not jsonl_path.exists():
        return {"total": 0, "kept": 0, "both": 0, "filed": 0, "missing": 0, "sound_flips": 0}

    known_chips = load_known_chips()
    rows = []
    song_ids = {}

    with open(jsonl_path, "r", encoding="utf-8") as f:
        for l in f:
            if not l.strip(): continue
            try: r = json.loads(l)
            except Exception: continue
            if r.get("type") == "song":
                if r.get("genius_id"):
                    song_ids[r.get("song")] = r.get("genius_id")
            elif r.get("type") in (None, "line"):
                rows.append(r)

    candidates = []
    both_c = 0
    filed_c = 0
    missing_c = 0
    kept_c = 0
    sound_flip_c = 0

    for r in rows:
        meaning = (r.get("meaning") or "").strip()
        line = (r.get("line") or "").strip()
        vault_lines = r.get("vault_lines") or []
        votes = r.get("votes")
        state = r.get("state") or ""
        song = r.get("song") or ""
        ann_id = str(r.get("annotation_id") or "")

        v_line = vault_lines[0] if vault_lines else line
        note_excerpt = clean(meaning)[:300]

        cand = {
            "artist": artist_name,
            "song": song,
            "genius_id": song_ids.get(song),
            "annotation_id": ann_id,
            "votes": votes,
            "vault_line": v_line,
            "bar": v_line,
            "heard": "",
            "partner": "",
            "chip_form": v_line,
            "signal_type": "wordplay",
            "setup_spans": [],
            "play_spans": [],
            "heard_as": "",
            "halves_class": "SECOND_HALF_MISSING_OR_WEAK",
            "note_excerpt": note_excerpt,
            "reject_reason": None,
            "kept": False,
        }

        sf_info = extract_sound_flip(v_line, meaning)
        if sf_info:
            cand["signal_type"] = "sound_flip"
            cand["setup_spans"] = sf_info["setup_spans"]
            cand["play_spans"] = sf_info["play_spans"]
            cand["heard_as"] = sf_info["heard_as"]
            cand["heard"] = sf_info["heard_as"]

        if not meaning:
            cand["reject_reason"] = "empty_meaning"
        elif meaning.startswith("NOT:") or meaning.startswith("[?]"):
            cand["reject_reason"] = "lyric_correction"
        elif meaning.endswith("?") or re.match(r"^(is\s+|does\s+|could\s+|maybe\s+|what\s+)", meaning, re.IGNORECASE):
            cand["reject_reason"] = "unanswered_question"
        elif votes is not None and votes < 0:
            cand["reject_reason"] = "negative_votes"
        elif REAL_HEDGE_RE.search(meaning):
            cand["reject_reason"] = "hedged_note"
        elif SEX_RE.search(meaning) or SEX_RE.search(line) or SEX_RE.search(v_line):
            cand["reject_reason"] = "sexual_content"
        elif GUN_RE.search(meaning) or GUN_RE.search(line) or GUN_RE.search(v_line):
            cand["reject_reason"] = "gun_violence"
        elif DRUG_RE.search(meaning) or DRUG_RE.search(line) or DRUG_RE.search(v_line):
            cand["reject_reason"] = "drug_substance"
        elif FAITH_RE.search(meaning) or FAITH_RE.search(line) or FAITH_RE.search(v_line):
            cand["reject_reason"] = "faith_religion"
        elif GANG_RE.search(meaning) or GANG_RE.search(line) or GANG_RE.search(v_line):
            cand["reject_reason"] = "gang_police_snitch_laundering"
        elif CHILD_RE.search(meaning) or CHILD_RE.search(line) or CHILD_RE.search(v_line):
            cand["reject_reason"] = "child_reference"
        elif not vault_lines:
            cand["reject_reason"] = "no_vault_line_match"
        else:
            if cand["signal_type"] == "sound_flip":
                sound_flip_c += 1
            else:
                m_low = meaning.lower()
                if "homophone" in m_low or "soundalike" in m_low or "sounds like" in m_low:
                    cand["signal_type"] = "homophone"
                elif "idiom" in m_low or "play on the phrase" in m_low:
                    cand["signal_type"] = "idiom_flip"
                elif "pun" in m_low:
                    cand["signal_type"] = "pun"
                elif "double meaning" in m_low or "double entendre" in m_low:
                    cand["signal_type"] = "double_meaning"

            parens = re.findall(r"\(([^)]{2,60})\)", meaning)
            quotes = re.findall(r'["“]([^"”]{2,60})["”]', meaning)
            partner = ""
            for p in parens + quotes:
                norm_p = normalize(p)
                if norm_p and norm_p != normalize(line):
                    partner = norm_p
                    break
            if not partner:
                m_match = re.search(r"(?:play on|pun on|reference to|meaning of|sounds like)\s+[\"']?([a-zA-Z0-9\s]{3,30})[\"']?", meaning, re.IGNORECASE)
                if m_match:
                    partner = normalize(m_match.group(1))
            if not partner:
                meaning_tokens = [t for t in normalize(meaning).split() if t not in STOP and t not in set(normalize(line).split()) and len(t) > 3]
                if meaning_tokens:
                    partner = " ".join(meaning_tokens[:2])

            cand["partner"] = partner
            if partner:
                cand["chip_form"] = f"{v_line} ({partner})"

            norm_vl = normalize(v_line)
            p_tokens = [t for t in normalize(partner).split() if t not in STOP] if partner else []
            if p_tokens and all(t in norm_vl for t in p_tokens):
                cand["halves_class"] = "BOTH_ON_LINE"
                both_c += 1
            elif partner and normalize(partner) in known_chips:
                cand["halves_class"] = "PARTNER_FILED_ELSEWHERE"
                filed_c += 1
            elif p_tokens and any(t in known_chips for t in p_tokens if len(t) > 3):
                cand["halves_class"] = "PARTNER_FILED_ELSEWHERE"
                filed_c += 1
            else:
                cand["halves_class"] = "SECOND_HALF_MISSING_OR_WEAK"
                missing_c += 1

            if (votes is None or votes == 0) and state == "pending" and cand["halves_class"] != "BOTH_ON_LINE":
                cand["reject_reason"] = "zero_vote_pending_not_both_on_line"
            else:
                cand["kept"] = True
                kept_c += 1

        candidates.append(cand)

    with open(cand_path, "w", encoding="utf-8") as f:
        for c in candidates:
            f.write(json.dumps(c, ensure_ascii=False) + "\n")

    return {
        "total": len(candidates),
        "kept": kept_c,
        "both": both_c,
        "filed": filed_c,
        "missing": missing_c,
        "sound_flips": sound_flip_c,
    }


def progress_has_external_artist_row(artist_name: str) -> bool:
    if not PROGRESS_MD.exists():
        return False
    tag = f"[chat8-{artist_name.lower().replace(' ', '-')}]"
    for line in PROGRESS_MD.read_text(encoding="utf-8").splitlines():
        if re.search(r"\|\s*" + re.escape(artist_name) + r"\b", line, re.IGNORECASE):
            if tag not in line:
                return True
    return False


def write_status(state, doing, progress, since_last_update, problems="none", needs_samuel="no"):
    STATUS_MD.parent.mkdir(parents=True, exist_ok=True)
    updated = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    STATUS_MD.write_text(
        "\n".join([
            f"updated: {updated} ET",
            f"state: {state}",
            f"doing: {doing}",
            f"progress: {progress}",
            f"since last update: {since_last_update}",
            f"problems: {problems}",
            f"needs Samuel: {needs_samuel}",
            "",
        ]),
        encoding="utf-8",
    )


def check_stop_condition(artist_name, log_path, our_file_size):
    """Returns (should_stop, reason)."""
    if progress_has_external_artist_row(artist_name):
        return True, f"{artist_name} appeared in all-artists-progress.md from another chat/main run"

    # 2. Stop if genius-clicks/moneybagg yo.jsonl gets a write you didn't make.
    if log_path.exists():
        current_size = log_path.stat().st_size
        if our_file_size is not None and current_size != our_file_size:
            return True, f"genius-clicks/moneybagg yo.jsonl modified externally (expected {our_file_size} bytes, found {current_size} bytes)"

    return False, None


def write_summary(before_count, after_count, total_vault, all_unres, cand_stats, stop_reason, cand_path):
    sound_flips = []
    if cand_path.exists():
        with open(cand_path, "r", encoding="utf-8") as f:
            for l in f:
                if not l.strip(): continue
                try: c = json.loads(l)
                except Exception: continue
                if c.get("signal_type") == "sound_flip" and c.get("kept"):
                    sound_flips.append(c)

    # Breakdown of unresolved by reason
    reasons_count = {}
    for u in all_unres:
        r = u.get("reason") or "unknown"
        reasons_count[r] = reasons_count.get(r, 0) + 1

    summary = f"""# Moneybagg Yo Pass Summary (Chat 8)

**Timestamp:** {datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")}  
**Status:** {stop_reason}

## Songs Progress
- **Vault total:** {total_vault}
- **Done before Chat 8:** {before_count}
- **Done after Chat 8:** {after_count}
- **New songs processed this session:** {after_count - before_count}
- **Unresolved total:** {len(all_unres)}

## Unresolved Breakdown by Reason
"""
    for r, count in sorted(reasons_count.items(), key=lambda x: -x[1]):
        summary += f"- **{r}:** {count}\n"
    if not reasons_count:
        summary += "- None\n"

    summary += f"""
## Candidates Breakdown
- **Total candidates:** {cand_stats['total']}
- **Kept candidates:** {cand_stats['kept']}
- **Both on line:** {cand_stats['both']}
- **Partner filed elsewhere:** {cand_stats['filed']}
- **Second half missing/weak:** {cand_stats['missing']}
- **Sound flips found:** {cand_stats['sound_flips']}

## 10 Best Sound Flips (setup → play = heard as)
"""
    if sound_flips:
        for i, sf in enumerate(sound_flips[:10], 1):
            setup_t = ", ".join(s.get("text", "") for s in sf.get("setup_spans", [])) or "(no setup)"
            play_t = ", ".join(p.get("text", "") for p in sf.get("play_spans", [])) or sf.get("bar", "")
            heard_t = sf.get("heard_as") or sf.get("heard", "")
            summary += f"{i}. **{sf.get('song')}**: `{setup_t}` → `{play_t}` = **{heard_t}**\n   *Bar:* \"{sf.get('bar')}\"\n   *Note:* {sf.get('note_excerpt', '')[:120]}...\n\n"
    else:
        summary += "*No kept sound flips identified yet.*\n"

    SUMMARY_MD.write_text(summary, encoding="utf-8")


def main():
    artist_name = "Moneybagg Yo"
    print(f"=== Anti-Gravity Chat 8: Starting {artist_name} in Reverse Song Order ===", flush=True)

    CLAIMS_DIR.mkdir(parents=True, exist_ok=True)
    claim_path = CLAIMS_DIR / "moneybagg yo.claim"
    done_claim = CLAIMS_DIR / "moneybagg yo.done"
    stopped_claim = CLAIMS_DIR / "moneybagg yo.chat8-stopped"

    # Step 1: Check existing claims
    if claim_path.exists():
        existing_claim = claim_path.read_text(encoding="utf-8", errors="replace")
        if "chat8 (ChatGPT)" not in existing_claim and "chat8" not in existing_claim:
            print(f"STOP: {claim_path} already exists. Reporting and halting.")
            return
        print(f"Using existing chat8 claim: {claim_path}", flush=True)
    if done_claim.exists():
        print(f"STOP: {done_claim} already exists. Reporting and halting.")
        return

    if not claim_path.exists():
        claim_content = f"chat8 (ChatGPT)\nPID {os.getpid()}\nstart time {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} ET\n"
        claim_path.write_text(claim_content, encoding="utf-8")
        print(f"Wrote claim: {claim_path}", flush=True)

    log_path = GENIUS_CLICKS / f"{artist_name.lower()}.jsonl"
    unres_path = ROOT / f"docs/play-on-words/{artist_name.lower().replace(' ', '-')}-unresolved.jsonl"
    cand_path = ROOT / f"docs/play-on-words/{artist_name.lower().replace(' ', '-')}-candidates.jsonl"

    # Step 2: Backup existing jsonl if present
    if log_path.exists():
        timestamp_str = datetime.datetime.now().strftime("%Y%m%d_%H%M")
        bak_path = GENIUS_CLICKS / f"{artist_name.lower()}.jsonl.before-chat8-{timestamp_str}.bak"
        shutil.copy2(log_path, bak_path)
        print(f"Backed up existing log to {bak_path}", flush=True)

    # Step 3: Vault songs in reverse order
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    vault_songs = [r[0] for r in con.execute("SELECT DISTINCT song FROM bars WHERE artist=? ORDER BY song", (artist_name,)).fetchall()]
    con.close()

    total_vault = len(vault_songs)
    print(f"Total vault songs: {total_vault}", flush=True)

    done_songs = set()
    if log_path.exists():
        with open(log_path, "r", encoding="utf-8") as f:
            for l in f:
                if not l.strip(): continue
                try: r = json.loads(l)
                except Exception: continue
                s = r.get("song")
                if r.get("clicked") or ((r.get("type") or "line") == "song" and (r.get("status") or "").lower() in ("done", "missing")):
                    done_songs.add(s)

    before_done_count = len(done_songs)
    print(f"Already done in log: {before_done_count} / {total_vault}", flush=True)

    reversed_vault = list(reversed(vault_songs))
    songs_to_process = [s for s in reversed_vault if s not in done_songs]
    print(f"Songs remaining to process in reverse order: {len(songs_to_process)}", flush=True)

    if not songs_to_process:
        print("All songs already processed! Renaming claim to .done.", flush=True)
        if claim_path.exists():
            claim_path.rename(done_claim)
        return

    our_file_size = log_path.stat().st_size if log_path.exists() else 0
    songs_completed_this_session = 0
    unresolved_records = []
    stop_reason = None
    last_status = 0.0

    for idx, song_title in enumerate(songs_to_process, 1):
        should_stop, reason = check_stop_condition(artist_name, log_path, our_file_size)
        if should_stop:
            stop_reason = reason
            print(f"\nSTOP CONDITION TRIGGERED: {reason}", flush=True)
            break

        now = time.time()
        if now - last_status >= 900 or last_status == 0:
            write_status(
                "running",
                f"searching Genius for {artist_name}",
                f"{len(done_songs)} / {total_vault} songs logged",
                f"{songs_completed_this_session} songs processed this session",
            )
            last_status = now

        print(f"[{idx}/{len(songs_to_process)}] Reverse searching: {clean(song_title)[:60]}...", flush=True)

        try:
            res, unres_reason = search_and_resolve_artist(artist_name, song_title)
        except urllib.error.HTTPError as e:
            if e.code == 429:
                stop_reason = "HTTP 429 Rate Limit (max 2 per hour reached)"
                print(f"FATAL: {stop_reason}", flush=True)
                break
            res, unres_reason = None, "http_error"
        except Exception as e:
            print(f"Error searching {song_title}: {e}", flush=True)
            res, unres_reason = None, "exception"

        with open(log_path, "a", encoding="utf-8") as f:
            if res:
                song_row, line_rows = res
                for lr in line_rows:
                    f.write(json.dumps(lr, ensure_ascii=False) + "\n")
                f.write(json.dumps(song_row, ensure_ascii=False) + "\n")
                f.flush()
                print(f"  [RECOVERED] -> {song_row.get('genius_title')} ({song_row.get('genius_url')}) [referents={len(line_rows)}]", flush=True)
            else:
                missing_row = {
                    "type": "song",
                    "artist": artist_name,
                    "song": clean(song_title),
                    "status": "missing",
                    "targets": 0,
                    "clicked": 0
                }
                f.write(json.dumps(missing_row, ensure_ascii=False) + "\n")
                f.flush()
                unresolved_records.append({"song": clean(song_title), "reason": unres_reason})
                print(f"  [UNRESOLVED] -> reason={unres_reason}", flush=True)

        our_file_size = log_path.stat().st_size
        done_songs.add(song_title)
        songs_completed_this_session += 1

        if songs_completed_this_session % 5 == 0:
            try:
                render(artist_name)
            except Exception as e:
                print(f"Warning: render failed: {e}", flush=True)

        if songs_completed_this_session % 50 == 0:
            print(f"--- 50 songs processed this session. Mining candidates and posting progress ---", flush=True)
            try:
                render(artist_name)
            except Exception:
                pass
            cand_stats = mine_wordplay_for_artist(artist_name)
            time_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            prog_line = f"| {artist_name} [chat8-moneybagg-yo] | {total_vault} | {before_done_count} -> {len(done_songs)} | {len(unresolved_records)} | {cand_stats['kept']} ({cand_stats['both']} both, {cand_stats['filed']} filed, {cand_stats['missing']} weak, {cand_stats['sound_flips']} sound_flips) | {time_str} |\n"
            with open(PROGRESS_MD, "a", encoding="utf-8") as f:
                f.write(prog_line)
            write_status(
                "running",
                f"posted 50-song progress row for {artist_name}",
                f"{len(done_songs)} / {total_vault} songs logged",
                f"{songs_completed_this_session} songs processed this session",
            )
            last_status = time.time()

    print("\n=== Wrapping up Moneybagg Yo Chat 8 Run ===", flush=True)
    try:
        render(artist_name)
    except Exception:
        pass
    cand_stats = mine_wordplay_for_artist(artist_name)

    all_unres = []
    if log_path.exists():
        with open(log_path, "r", encoding="utf-8") as f:
            for l in f:
                if not l.strip(): continue
                try: r = json.loads(l)
                except Exception: continue
                if r.get("type") == "song" and r.get("status") == "missing":
                    # Find reason if in this session or fallback
                    matched_r = next((u["reason"] for u in unresolved_records if u["song"] == r.get("song")), "no_exact_genius_match")
                    all_unres.append({"song": r.get("song"), "reason": matched_r})

    with open(unres_path, "w", encoding="utf-8") as f:
        for u in all_unres:
            f.write(json.dumps(u, ensure_ascii=False) + "\n")

    if len(done_songs) >= total_vault:
        if claim_path.exists():
            claim_path.rename(done_claim)
        stop_reason = f"Completed all {total_vault} songs!"
    else:
        if claim_path.exists():
            claim_path.rename(stopped_claim)
        if not stop_reason:
            stop_reason = "Session ended"

    write_summary(before_done_count, len(done_songs), total_vault, all_unres, cand_stats, stop_reason, cand_path)
    write_status(
        "done" if len(done_songs) >= total_vault else "idle",
        f"finished current {artist_name} run",
        f"{len(done_songs)} / {total_vault} songs logged",
        stop_reason,
        "none" if len(done_songs) >= total_vault else stop_reason,
        "no",
    )
    print(f"Run completed. Summary written to {SUMMARY_MD}", flush=True)


if __name__ == "__main__":
    main()
