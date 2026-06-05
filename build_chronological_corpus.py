#!/usr/bin/env python3
"""
build_chronological_corpus.py
─────────────────────────────
Rebuilds the chronological ground-truth corpus that Model G v4's RAG retrieves on.

This is the same pipeline the "LLM builder" Obsidian vault documents, reproduced in-repo
(no vault/Drive access required):

  1. Extract lyrics in TRUE song order from the Excel source of truth
       "X Journal CSV  files /LLM DATA 2026/2026 LLM MS EXCEL SHEET .xlsx"
     Priority per song: "Individual lyric definitions" -> "Lyrics" -> "Individual lyric lines".
     Parse "[Section: Artist]" headers for section + active-artist attribution; drop headers
     and blank lines but keep every real lyric line in order.
  2. Merge tone/rhyme metadata (primary_tone, secondary_tone, rhyme_class, phonetic_ending,
     syllable_count, AuthorityClass) from the alphabetized
       "XJournal AI/ground_truth_rap_bars_MODEL_G.csv"
     by normalized line text (~92% match).
  3. Write "XJournal AI/chronological_rap_bars_MODEL_G.csv" — bundled into the app and loaded
     (preferentially) by GroundTruthCorpus.swift.

No third-party deps (stdlib only; the .xlsx is parsed as a zip of XML).
Run from the repo root:  python3 build_chronological_corpus.py
"""
import zipfile, re, csv, os
import xml.etree.ElementTree as ET

NS = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"
XLSX = "X Journal CSV  files /LLM DATA 2026/2026 LLM MS EXCEL SHEET .xlsx"
TONECSV = "XJournal AI/ground_truth_rap_bars_MODEL_G.csv"
OUT = "XJournal AI/chronological_rap_bars_MODEL_G.csv"


def norm(t):
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9 ]", "", t.lower())).strip()


def parse_xlsx(path):
    z = zipfile.ZipFile(path)
    sst = ["".join(t.text or "" for t in si.iter(f"{NS}t"))
           for si in ET.fromstring(z.read("xl/sharedStrings.xml")).findall(f"{NS}si")]

    def cidx(ref):
        s = re.match(r"([A-Z]+)\d+", ref).group(1)
        n = 0
        for ch in s:
            n = n * 26 + (ord(ch) - 64)
        return n - 1

    rows = []
    for row in ET.fromstring(z.read("xl/worksheets/sheet1.xml")).iter(f"{NS}row"):
        cells = {}
        for c in row.findall(f"{NS}c"):
            t, v, isv, val = c.get("t"), c.find(f"{NS}v"), c.find(f"{NS}is"), ""
            if t == "s" and v is not None:
                val = sst[int(v.text)]
            elif t == "inlineStr" and isv is not None:
                val = "".join(x.text or "" for x in isv.iter(f"{NS}t"))
            elif v is not None:
                val = v.text or ""
            cells[cidx(c.get("r"))] = val
        rows.append(cells)
    return rows


def load_tone(path):
    craw = list(csv.reader(open(path, encoding="utf-8", errors="replace")))
    H = [c.strip().lower() for c in craw[0]]

    def col(*names):
        for nm in names:
            for i, h in enumerate(H):
                if h == nm:
                    return i
        return None

    c = {k: col(*v) for k, v in {
        "text": ("text_bar_line", "text"), "primary_tone": ("primary_tone",),
        "secondary_tone": ("secondary_tone",), "rhyme_class": ("rhyme_class",),
        "phonetic_ending": ("phonetic_ending",), "syllable_count": ("syllable_count",),
        "authority": ("authorityclass",)}.items()}
    ct = c["text"] or 6
    tone = {}
    for r in craw[1:]:
        if len(r) <= ct or "." not in r[0]:
            continue
        key = norm(r[ct])
        if not key or key in tone:
            continue
        tone[key] = {k: (r[i].strip() if i is not None and i < len(r) else "")
                     for k, i in c.items() if k != "text"}
    return tone


def main():
    rows = parse_xlsx(XLSX)
    tone = load_tone(TONECSV)
    hdr_re = re.compile(r"^\[(.+)\]$")
    out, songs, matched, total = [], 0, 0, 0

    for r in rows[1:]:
        title, artist, album = r.get(0, "").strip(), r.get(2, "").strip(), r.get(5, "").strip()
        lyrics = next((r.get(col, "") for col in (8, 7, 9) if r.get(col, "").strip()), "")
        if not title or not lyrics.strip():
            continue
        songs += 1
        sid = norm(title).replace(" ", "")
        line_no, active, section = 0, artist, ""
        for raw in lyrics.split("\n"):
            s = raw.strip()
            if not s:
                continue
            m = hdr_re.match(s)
            if m:
                inside = m.group(1)
                if ":" in inside:
                    section, who = inside.split(":", 1)
                    active, section = who.strip(), section.strip()
                else:
                    section = inside.strip()
                continue
            line_no += 1
            total += 1
            td = tone.get(norm(s))
            if td:
                matched += 1
            out.append({"order": len(out) + 1, "song_id": sid, "song": title, "artist": artist,
                        "active_artist": active or artist, "album": album, "section": section,
                        "line_no": line_no, "text": s,
                        "primary_tone": (td or {}).get("primary_tone", ""),
                        "secondary_tone": (td or {}).get("secondary_tone", ""),
                        "rhyme_class": (td or {}).get("rhyme_class", ""),
                        "phonetic_ending": (td or {}).get("phonetic_ending", ""),
                        "syllable_count": (td or {}).get("syllable_count", ""),
                        "authority": (td or {}).get("authority", "")})

    cols = ["order", "song_id", "song", "artist", "active_artist", "album", "section", "line_no",
            "text", "primary_tone", "secondary_tone", "rhyme_class", "phonetic_ending",
            "syllable_count", "authority"]
    w = csv.DictWriter(open(OUT, "w", newline="", encoding="utf-8"), fieldnames=cols)
    w.writeheader()
    w.writerows(out)

    print(f"songs: {songs}  lines: {total}  tone-matched: {matched} ({100*matched/max(1,total):.1f}%)")
    print(f"wrote {len(out)} rows -> {OUT} ({os.path.getsize(OUT)//1024} KB)")


if __name__ == "__main__":
    main()
