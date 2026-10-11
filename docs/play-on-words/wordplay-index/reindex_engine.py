import json, os, sys, re
from pathlib import Path
from datetime import datetime

ROOT = Path("/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync")
INDEX_FILE = ROOT / "docs/play-on-words/wordplay-index/index.jsonl"
SUMMARY_FILE = ROOT / "docs/play-on-words/wordplay-index/summary.md"
RECHECK_FILE = ROOT / "docs/play-on-words/confirmed-recheck/recheck.jsonl"
STATUS_FILE = ROOT / "docs/play-on-words/chat-status/chat-7.md"

def norm_txt(t):
    if not t: return ""
    t = t.lower()
    t = re.sub(r"[’'\"“”„,.!?()\-—/\\]", " ", t)
    return " ".join(t.split())

# Preload wired chips lookup: (artist_norm, song_norm, bar_norm) -> noun
print("Loading wired chips...")
wiring_path = ROOT / "docs/play-on-words/wordplay-wiring-log.jsonl"
wired_chips = {}
if wiring_path.exists():
    for l in open(wiring_path):
        if not l.strip(): continue
        try:
            r = json.loads(l)
            if r.get("decision") in ("reused", "created", "approved_wired"):
                art = norm_txt(r.get("artist"))
                sng = norm_txt(r.get("song"))
                bar = norm_txt(r.get("bar"))
                noun = r.get("noun")
                if noun:
                    wired_chips[(art, sng, bar)] = noun
                    wired_chips[(art, sng)] = noun
        except Exception:
            pass
print(f"Loaded {len(wired_chips)} wired chip entries.")

# Preload genius-clicks into index
print("Loading genius-clicks into memory...")
click_dir = ROOT / "docs/play-on-words/genius-clicks"
ann_map = {}
line_map = {} # (art_norm, sng_norm) -> list of (line_norm, vl_norms, meaning, url)

for f in click_dir.glob("*.jsonl"):
    for l in open(f):
        if not l.strip(): continue
        try:
            r = json.loads(l)
            if r.get("type") != "line": continue
            m = r.get("meaning") or ""
            u = r.get("url") or ""
            aid = str(r.get("annotation_id") or "")
            if aid and aid != "None":
                ann_map[aid] = (m, u)
            art = norm_txt(r.get("artist"))
            sng = norm_txt(r.get("song"))
            line = norm_txt(r.get("line"))
            vl = [norm_txt(x) for x in r.get("vault_lines", [])]
            k = (art, sng)
            if k not in line_map: line_map[k] = []
            line_map[k].append((line, vl, m, u))
        except Exception:
            pass

print(f"Loaded {len(ann_map)} annotations and {len(line_map)} song maps.")

def find_meaning(art, sng, bar, url=""):
    # 1. try annotation ID
    if url:
        m_aid = re.search(r"genius\.com/(\d+)", url)
        if m_aid and m_aid.group(1) in ann_map:
            return ann_map[m_aid.group(1)]
    # 2. try line map
    an = norm_txt(art)
    sn = norm_txt(sng)
    bn = norm_txt(bar)
    cand = line_map.get((an, sn), [])
    for line, vl, m, cu in cand:
        if bn == line or bn in line or line in bn or any(bn == v or bn in v or v in bn for v in vl):
            return (m, cu)
    # 3. try artist-wide search if song name differs slightly
    return ("", url or "")

