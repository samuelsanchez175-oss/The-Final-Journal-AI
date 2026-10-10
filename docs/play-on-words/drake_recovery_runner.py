#!/usr/bin/env python3
"""Drake missing URL recovery and malformed scrape cleanup runner.

Runs sequentially with 3.5s spacing between Genius API calls.
Batches updates and merges to drake.jsonl, rendering after each batch.
Writes progress to docs/play-on-words/drake-cleanup-progress.txt.
"""

import html
import json
import re
import sqlite3
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path("/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync")
DB = ROOT / "tools/bar-hits-catalog/BarHitsCatalog.sqlite"
GENIUS_CLICKS = ROOT / "docs/play-on-words/genius-clicks"
DRAKE_JSONL = GENIUS_CLICKS / "drake.jsonl"
DRAKE_MD = GENIUS_CLICKS / "drake.md"
PROGRESS_TXT = ROOT / "docs/play-on-words/drake-cleanup-progress.txt"
UNRESOLVED_JSONL = ROOT / "docs/play-on-words/drake-unresolved.jsonl"

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


def clean(s):
    s = re.sub(r"<[^>]+>", " ", s or "")
    s = html.unescape(s)
    return re.sub(r"\s+", " ", s).strip()


def norm(s):
    s = clean(s).lower().replace("*", "").replace("’", "'").replace("‘", "'")
    s = re.sub(r"[^a-z0-9' ]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def title_key(s):
    alt_match = re.search(r'alt="([^"]+)"', s or "")
    if alt_match:
        s = alt_match.group(1)
    s = norm(s).replace("'", "")
    return re.sub(r"\s+", " ", s).strip()


def clean_search_title(s):
    alt_match = re.search(r'alt="([^"]+)"', s or "")
    if alt_match:
        return alt_match.group(1)
    s = clean(s)
    return s


def is_drake_artist(artist_names):
    if not artist_names:
        return False
    tokens = re.findall(r"\b[a-zA-Z0-9]+\b", artist_names.lower())
    return "drake" in tokens


def covers(fragment, line):
    frag, bar = norm(fragment), norm(line)
    if not frag or not bar:
        return False
    if frag in bar or bar in frag:
        return True
    frag_words, bar_words = set(frag.split()), set(bar.split())
    if not frag_words or not bar_words:
        return False
    return len(frag_words & bar_words) / min(len(frag_words), len(bar_words)) >= 0.6


def second_sense(line, body):
    text = body or ""
    low = text.lower()
    if not text:
        return False
    if norm(text) == norm(line):
        return False
    parens = re.findall(r"\(([^)]{2,80})\)", text)
    line_words = set(norm(line).split())
    for paren in parens:
        extra = [word for word in norm(paren).split() if word not in STOP and word not in line_words]
        if extra:
            return True
    markers = ("play on", "wordplay", "double", "pun", "sounds like", "homophone", "short for", "stands for")
    if any(marker in low for marker in markers):
        return True
    if re.search(r"\b(means|aka|stands for|is an|is a)\b", low):
        return True
    extra = [word for word in norm(text).split() if word not in STOP and word not in line_words and len(word) > 3]
    return len(extra) >= 2


def http_json(url):
    req = urllib.request.Request(url, headers=UA)
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                return json.loads(response.read().decode("utf-8", "replace"))
        except urllib.error.HTTPError as error:
            if error.code == 429:
                raise
            if error.code in {500, 502, 503} and attempt < 3:
                time.sleep(2 * (attempt + 1))
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


def song_rows_db(artist):
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    rows = con.execute(
        "SELECT song, COUNT(*) FROM bars WHERE artist=? GROUP BY song ORDER BY COUNT(*) DESC",
        (artist,),
    ).fetchall()
    con.close()
    return rows


def song_order(artist):
    rows = song_rows_db(artist)
    return [song for song, _count in rows]


def dump_row(row):
    raw = json.dumps(row, ensure_ascii=False)
    return raw.replace("\u2028", " ").replace("\u2029", " ")


def jsonl_rows(path):
    if not path.exists():
        return
    for line in path.read_text().split("\n"):
        if line.strip():
            yield json.loads(line)


def render(artist):
    path = GENIUS_CLICKS / f"{artist.lower()}.jsonl"
    rows = []
    songs = []
    if path.exists():
        for row in jsonl_rows(path):
            if row.get("type") == "song":
                songs.append(row)
            else:
                rows.append(row)
    catalog = song_order(artist)
    done = {row.get("song") for row in songs if row.get("status") == "done"}
    lines = [
        f"# {artist}, line by line",
        "",
        "Each row is a highlighted Genius line that was clicked.",
        "The meaning is the community note that opened.",
        "A line with no highlight is listed as no note.",
        "",
        f"Songs finished: {len(done)} of {len(catalog)}.",
        "",
        "| song | line | community meaning | second sense | Genius | votes | state |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    for row in rows:
        def cell(value):
            if value is None:
                return ""
            return str(value).replace("|", "/").replace("\n", " ")[:180]

        lines.append("| " + " | ".join([
            cell(row.get("song")),
            cell(row.get("line")),
            cell(row.get("meaning")),
            "yes" if row.get("second_sense") else "no",
            cell(row.get("annotation_id") or "no note"),
            cell(row.get("votes") if row.get("votes") is not None else ""),
            cell(row.get("state")),
        ]) + " |")
    (GENIUS_CLICKS / f"{artist.lower()}.md").write_text("\n".join(lines) + "\n")


def song_referents(song_id):
    found = []
    seen = set()
    for page in range(1, 6):
        time.sleep(3.5)
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


def search_and_resolve(song_key):
    clean_title = clean_search_title(song_key)
    query = urllib.parse.quote(f"{clean_title} Drake")
    url = f"https://genius.com/api/search/multi?per_page=5&q={query}"
    
    time.sleep(3.5)
    data = http_json(url)
    hits = []
    for sec in data.get("response", {}).get("sections", []):
        if sec.get("type") == "song":
            hits.extend(sec.get("hits", []))
            
    want_key = title_key(clean_title)
    
    matched_hit = None
    for hit in hits:
        res = hit.get("result") or {}
        hit_title = res.get("title") or ""
        hit_id = res.get("id")
        hit_url = res.get("url") or ""
        hit_artist_names = res.get("artist_names") or ""
        primary_artist = (res.get("primary_artist") or {}).get("name") or ""
        
        # Skip translation pages
        if any(t in hit_title.lower() or t in hit_url.lower() or t in primary_artist.lower() 
               for t in ["traducc", "translation", "traduct", "tłumacz", "ceviri", "übersetzung", "romanization"]):
            continue
        # Skip Genius administrative / tracklist pages
        if primary_artist.lower() == "genius" or any(t in hit_title.lower() for t in ["tracklist", "booklet", "credits", "album art"]):
            continue
            
        hit_key = title_key(hit_title)
        
        # Check title key match
        if hit_key != want_key:
            base_hit_title = re.sub(r"\s*[\(\[].*?[\)\]]", "", hit_title)
            base_want_title = re.sub(r"\s*[\(\[].*?[\)\]]", "", clean_title)
            if title_key(base_hit_title) != title_key(base_want_title):
                continue
                
        # Check Drake credit in artist_names
        if not is_drake_artist(hit_artist_names):
            time.sleep(3.5)
            try:
                song_detail = http_json(f"https://genius.com/api/songs/{hit_id}")
                song_res = (song_detail.get("response") or {}).get("song") or {}
                full_artist_names = song_res.get("artist_names") or ""
                if not is_drake_artist(full_artist_names):
                    continue
            except Exception:
                continue
                
        matched_hit = res
        break
        
    if not matched_hit:
        low_title = clean_title.lower()
        if "remix" in low_title or "live" in low_title or "mashup" in low_title or "cover" in low_title or "medley" in low_title or "version" in low_title or "demo" in low_title or "freestyle" in low_title:
            reason = "remix_live_demo_mashup"
        elif "leak" in low_title or "unreleased" in low_title or "snippet" in low_title or "untitled" in low_title:
            reason = "leak_not_on_dsp"
        elif song_key.startswith("<") or "<img" in song_key:
            reason = "malformed_no_vault_match"
        elif hits and not any(is_drake_artist(h.get("result", {}).get("artist_names", "")) for h in hits):
            reason = "not_drake_credit"
        else:
            reason = "no_exact_genius_match"
        return None, reason

    # Matched! Pull referents
    song_id = matched_hit["id"]
    hit_url = matched_hit.get("url") or f"https://genius.com/songs/{song_id}"
    hit_title = matched_hit.get("title") or clean_title
    
    referents = song_referents(song_id)
    vault = song_lines("Drake", song_key)
    
    line_rows = []
    for ref in referents:
        body = ref.get("body") or ""
        state = ref.get("state") or ""
        votes = ref.get("votes")
        frag = ref.get("line") or ""
        ann_id = str(ref.get("id"))
        
        line_rows.append({
            "type": "line",
            "artist": "Drake",
            "song": song_key,
            "line": frag,
            "vault_lines": [line for line in vault if covers(frag, line)],
            "meaning": body,
            "annotation_id": ann_id,
            "url": f"https://genius.com/{ann_id}",
            "state": state,
            "votes": votes,
            "second_sense": second_sense(frag, body) if body else False,
            "clicked": False,
            "click_status": "api",
            "strength": "weak" if (state != "accepted" or (votes or 0) <= 0) else "accepted",
        })
        
    song_row = {
        "type": "song",
        "artist": "Drake",
        "song": song_key,
        "status": "done",
        "targets": len(referents),
        "clicked": 0,
        "genius_url": hit_url,
        "genius_title": hit_title,
        "genius_id": song_id,
        "source": "api",
    }
    
    return (song_row, line_rows), None


def merge_batch(newly_done_map):
    if not newly_done_map:
        return
    lines = DRAKE_JSONL.read_text().split("\n")
    kept = []
    for line in lines:
        if not line.strip():
            continue
        row = json.loads(line)
        s = row.get("song")
        if s in newly_done_map:
            continue
        kept.append(row)
        
    for song_key, (song_row, line_rows) in newly_done_map.items():
        kept.extend(line_rows)
        kept.append(song_row)
        
    DRAKE_JSONL.write_text("".join(dump_row(row) + "\n" for row in kept))
    render("Drake")


def main():
    print("Starting Drake Missing URL Recovery Pass...", flush=True)
    
    # Read existing progress
    processed_songs = {}
    if PROGRESS_TXT.exists():
        with open(PROGRESS_TXT, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                m_rec = re.match(r"RECOVERED:\s*'([^']+)'", line)
                if m_rec:
                    processed_songs[m_rec.group(1)] = "recovered"
                    continue
                m_unres = re.match(r"UNRESOLVED:\s*'([^']+)'\s*->\s*reason=([a-zA-Z0-9_]+)", line)
                if m_unres:
                    processed_songs[m_unres.group(1)] = m_unres.group(2)
                    
    # Read existing missing songs in jsonl
    missing_songs = []
    for row in jsonl_rows(DRAKE_JSONL):
        if row.get("type") == "song" and row.get("status") == "missing":
            missing_songs.append(row.get("song"))
            
    print(f"Total missing songs in jsonl: {len(missing_songs)} (already recorded in progress: {len(processed_songs)})", flush=True)
    
    unresolved_records = []
    # populate existing unresolved from progress file
    for s_clean, reason in processed_songs.items():
        if reason != "recovered":
            # find original key
            orig = s_clean
            for ms in missing_songs:
                if clean_search_title(ms) == s_clean or ms == s_clean:
                    orig = ms
                    break
            unresolved_records.append({"song": orig, "reason": reason})
            
    newly_done_batch = {}
    batch_size = 20
    
    with open(PROGRESS_TXT, "a", encoding="utf-8") as prog_file:
        for idx, song_key in enumerate(missing_songs, 1):
            clean_title = clean_search_title(song_key)
            if clean_title in processed_songs or song_key in processed_songs:
                continue
                
            print(f"[{idx}/{len(missing_songs)}] Processing: {clean_title[:60]}...", flush=True)
            try:
                res, reason = search_and_resolve(song_key)
            except urllib.error.HTTPError as e:
                if e.code == 429:
                    msg = f"HTTP 429 Rate Limit on {song_key}. Halting."
                    print(f"FATAL: {msg}", flush=True)
                    prog_file.write(f"FAIL 429: {song_key}\n")
                    prog_file.flush()
                    unresolved_records.append({"song": song_key, "reason": "rate_limited"})
                    for remaining in missing_songs[idx:]:
                        unresolved_records.append({"song": remaining, "reason": "rate_limited"})
                    break
                else:
                    print(f"HTTPError {e.code} on {song_key}: {e}", flush=True)
                    reason = "no_exact_genius_match"
                    res = None
            except Exception as e:
                print(f"Error on {song_key}: {e}", flush=True)
                reason = "no_exact_genius_match"
                res = None
                
            if res:
                song_row, line_rows = res
                newly_done_batch[song_key] = (song_row, line_rows)
                msg = f"RECOVERED: '{clean_title}' -> {song_row.get('genius_title')} ({song_row.get('genius_url')}) [referents={len(line_rows)}]"
                print(f"  {msg}", flush=True)
                prog_file.write(f"{msg}\n")
            else:
                unresolved_records.append({"song": song_key, "reason": reason})
                msg = f"UNRESOLVED: '{clean_title}' -> reason={reason}"
                print(f"  {msg}", flush=True)
                prog_file.write(f"{msg}\n")
                
            prog_file.flush()
            
            if len(newly_done_batch) >= batch_size:
                print(f"Merging batch of {len(newly_done_batch)} recovered songs to drake.jsonl...", flush=True)
                merge_batch(newly_done_batch)
                newly_done_batch = {}
                
        if newly_done_batch:
            print(f"Merging final batch of {len(newly_done_batch)} recovered songs...", flush=True)
            merge_batch(newly_done_batch)
            newly_done_batch = {}
            
    # Write unresolved jsonl
    print(f"Writing {len(unresolved_records)} records to {UNRESOLVED_JSONL}...", flush=True)
    with open(UNRESOLVED_JSONL, "w", encoding="utf-8") as f:
        for rec in unresolved_records:
            f.write(json.dumps(rec, ensure_ascii=False) + "\n")
            
    print(f"Done! Unresolved total: {len(unresolved_records)}", flush=True)


if __name__ == "__main__":
    main()
