"""Model G v5 — recalibrated, section-aware, music/intent-ready grader (standalone eval).

Built from the 6-lyric ablation + the big corpus baseline. Changes vs v4:
  - CUT Flow + Originality-as-a-score (flat; no signal).
  - FIX Rhyme: slant + monorhyme + OOV aware, two-tier (vowel + vowel/coda) so random
    end-words don't score; rewards an actual rhyme SCHEME, not chance vowel coincidence.
  - BROADEN Jargon -> Specificity: lexicon + numbers + rare/distinctive vocabulary
    (relative to corpus frequency). Word-identity based, so word-order can't game it.
  - RELAX Cadence -> Meter: broad authentic band + consistency, or an explicit
    intent/BPM target; stops over-punishing intentional length variation.
  - SOFT Through-line: rewards thematic cohesion, NEVER penalises (associative is fine).
  - SPLIT Repetition: refrain-exempt + lexical-monotony, softened per section, hard floor.
  - ROUTER: detect verse vs hook, switch active axes + weights.
  - GATE: plagiarism is a SEPARATE downstream flag (net vs net_raw). Authenticity uses
    net_raw; the gate needs a held-out reference (it self-matches the corpus otherwise).

Pure text/number -> on-device-able. Audio axes (Pocket@BPM, Singability@Key) are OFF here.
No app code is touched.
"""
import os, re, sys, json, math, statistics, csv as _csv
from collections import Counter
from itertools import combinations
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import grade_modelg as G

WORD = re.compile(r"[A-Za-z']+")
ADLIB = re.compile(r"\([^)]*\)")
VOWELS = re.compile(r"[aeiouy]+")
STOP = G.STOPWORDS
SPELL_VOWEL = {"a": "AE", "e": "EH", "i": "AY", "o": "OW", "u": "UW", "y": "AY"}

# ---- Punch / coded-vocabulary axis ------------------------------------------
_CODED = None

def _load_coded():
    global _CODED
    if _CODED is not None:
        return _CODED
    coded = set()
    lex_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "lexicons")
    for fn in ("drug_lexicon.csv", "rapper_lexicon.csv"):
        p = os.path.join(lex_dir, fn)
        if not os.path.exists(p):
            continue
        for row in _csv.DictReader(open(p, encoding="utf-8")):
            cells = [row.get("canonical") or row.get("term") or "", row.get("aliases") or ""]
            for cell in cells:
                for term in re.split(r"[;,]", cell):
                    t = term.strip().lower()
                    if len(t) >= 2:
                        coded.add(t)
    # curated flex / jewelry / weapon / money double-meaning terms
    coded |= {"ice","iced","rocks","stones","bands","racks","guap","knot","pipe","stick","steel",
              "chopper","draco","dracos","bird","brick","bricks","pack","plug","whip","coupe","wraith",
              "drip","drippin","dripping","wave","heat","pole","hammer","beam","switch","drum","glock",
              "cake","bread","cheese","dough","sauce","juice","ticket","paper","presi","patek","audemar",
              "vvs","cuban","bezel","busted","froze","frozen","opp","opps","pressure","demon","styrofoam",
              "two-tone","double cup","pushin p","the p","spaceship","kingface","rolex","gucci","prada"}
    _CODED = coded
    return coded


def _words(text):
    return WORD.findall(ADLIB.sub(" ", text))


def _content(text):
    return [w.lower() for w in _words(text) if w.lower() not in STOP and len(w) > 2]


# ---------------- Rhyme: two-tier (vowel + vowel/coda), scheme-aware -----------
def _end_keys(text, cmu):
    """(vowel_key, strict_key) of the line's last word; OOV -> spelling fallback."""
    w = G.last_word(text)
    if not w:
        return None, None
    ph = cmu.get(w)
    if ph:
        v, coda = G._vowel_and_coda(ph)
        if v:
            return v[:2], (v[:2], coda[-1] if coda else "")
    m = VOWELS.findall(w)
    if not m:
        return None, None
    vk = SPELL_VOWEL.get(m[-1][0], m[-1][0].upper())
    return vk, (vk, w[-1])


def rhyme_score(lines, cmu):
    vk, sk = [], []
    for l in lines:
        a, b = _end_keys(l, cmu)
        if a:
            vk.append(a); sk.append(b)
    if len(vk) < 2:
        return 0.0
    fv, fs = Counter(vk), Counter(sk)
    cov_v = sum(1 for k in vk if fv[k] >= 2) / len(vk)   # assonance coverage (lenient)
    cov_s = sum(1 for k in sk if fs[k] >= 2) / len(sk)   # perfect/near coverage (strict)
    return round(min(100.0, 100 * (0.35 * cov_v + 0.65 * cov_s)), 1)


# ---------------- Meter: broad band + consistency (or intent/BPM target) ------
def meter_score(lines, cmu, intent_syll=None, tol=2):
    counts = [c for c in (G.line_syllables(l, cmu) for l in lines) if c > 0]
    if not counts:
        return 0.0
    if intent_syll:
        inband = sum(1 for c in counts if abs(c - intent_syll) <= tol)
        return round(100 * inband / len(counts), 1)
    inband = sum(1 for c in counts if 4 <= c <= 18) / len(counts)
    sd = statistics.pstdev(counts) if len(counts) > 1 else 0.0
    consistency = max(0.0, 1 - sd / 8.0)
    return round(min(100.0, 100 * (0.7 * inband + 0.3 * consistency)), 1)


# ---------------- Specificity: lexicon + numbers + rare vocabulary -------------
def specificity_score(lines, lexicon_set, common=None):
    toks = [w.lower() for w in _words(" ".join(lines))]
    if not toks:
        return 0.0
    low = " ".join(lines).lower()
    tokset = set(toks)
    lex = sum(1 for t in lexicon_set if (t in tokset) or (" " in t and t in low))
    specific = set()
    for w in toks:
        if any(ch.isdigit() for ch in w):
            specific.add(w)
        elif len(w) > 2 and w not in STOP and (common is None or w not in common):
            specific.add(w)                      # distinctive (rare) content word
    per_line = (lex + len(specific)) / len(lines)
    return round(min(100.0, per_line * 22), 1)


# ---------------- Through-line: reward-only thematic cohesion -----------------
def throughline_bonus(lines):
    sets = [set(_content(l)) for l in lines]
    sets = [s for s in sets if s]
    if len(sets) < 2:
        return 0.0
    sims = [len(a & b) / len(a | b) for a, b in combinations(sets, 2) if (a | b)]
    cohesion = sum(sims) / len(sims) if sims else 0.0
    return round(min(100.0, cohesion * 300), 1)


def craft_score(lines):
    cw = [w for l in lines for w in _content(l)]
    return round(min(100.0, 100 * len(set(cw)) / len(cw)), 1) if cw else 50.0


# ---------------- Punch: coded-vocab density + turn-word + compound ending ----
def punch_score(lines, common=None):
    """Heuristic punchline/wordplay proxy: 3 signals weighted 0.55/0.15/0.30."""
    coded = _load_coded()
    n = len(lines)
    if n == 0:
        return 0.0
    coded_hits = turn_hits = cmpd_hits = 0
    for l in lines:
        low = l.lower()
        toks = WORD.findall(low)
        if not toks:
            continue
        # 1) coded vocabulary (double-meaning drug/rap/flex terms)
        if any(w in coded for w in toks) or any(" " in c and c in low for c in coded):
            coded_hits += 1
        # 2) surprising turn: last content word not common, not foreshadowed earlier in bar
        content = [w for w in toks if w not in STOP and len(w) > 2]
        if content:
            last, setup = content[-1], set(content[:-1])
            if len(last) > 3 and last not in (common or set()) and last not in setup:
                turn_hits += 1
        # 3) compound / hyphen ending (phrase-pun proxy: send-off, two-tone, kingface)
        endtok = low.split()[-1].strip(".,!?\"'") if low.split() else ""
        if "-" in endtok or endtok in {"sendoff", "kingface", "spaceship", "backwood", "stylewise"}:
            cmpd_hits += 1
    return round(min(100.0, 100 * (0.55 * coded_hits/n + 0.15 * turn_hits/n
                                   + 0.30 * min(1.0, cmpd_hits/2.0))), 1)


# ---------------- Repetition: refrain-exempt + monotony, section-softened -----
def repetition_penalty(lines, section):
    norm = [re.sub(r"\W+", " ", l.lower()).strip() for l in lines]
    refrains = {l for l, c in Counter(norm).items() if c >= 2}
    body = [l for l, n in zip(lines, norm) if n not in refrains]
    cw = [w for l in body for w in _content(l)]
    monotony = max(0.0, 0.6 - (len(set(cw)) / len(cw))) * 100 if cw else 0.0
    factor = 0.35 if section == "hook" else 1.0
    pen = monotony * factor * 0.4
    allcw = [w for l in lines for w in _content(l)]
    if allcw and len(set(allcw)) / len(allcw) < 0.25:
        pen += 12
    return round(min(25.0, pen), 1)


def plagiarism_gate(lines, corpus_4grams):
    """Downstream flag for EXTERNAL input. Needs a held-out reference: it self-matches
    anything already in the corpus, so it is NOT part of the authenticity score."""
    grams = set()
    for l in lines:
        ws = [w.lower() for w in _words(l)]
        grams.update(tuple(ws[k:k + 4]) for k in range(len(ws) - 3))
    if not grams:
        return 1.0
    overlap = sum(1 for g in grams if g in corpus_4grams) / len(grams)
    return 0.4 if overlap > 0.5 else 1.0


# ---------------- Router ------------------------------------------------------
def detect_section(lines):
    norm = [re.sub(r"\W+", " ", l.lower()).strip() for l in lines]
    if any(v >= 3 for v in Counter(norm).values()):
        return "hook"
    tails = Counter(tuple(_words(l.lower())[-2:]) for l in lines if len(_words(l)) >= 2)
    if tails and tails.most_common(1)[0][1] >= max(4, len(lines) * 0.4):
        return "hook"
    return "verse"


WEIGHTS = {
    # Punch added (0.10); Rhyme reduced 0.32→0.22 (was the punchline-killer: a turn breaks neat rhyme).
    "verse": {"Meter": 0.25, "Rhyme": 0.22, "Specificity": 0.25, "Throughline": 0.08, "Craft": 0.10, "Punch": 0.10},
    "hook":  {"Meter": 0.28, "Rhyme": 0.22, "Specificity": 0.20, "Throughline": 0.08, "Craft": 0.12, "Punch": 0.10},
}


def grade_v5(lines, cmu, corpus_4grams, lexicon_set, common=None, section=None, intent_syll=None):
    lines = [l for l in (x.strip() for x in lines) if l]
    if section is None:
        section = detect_section(lines)
    axes = {
        "Meter": meter_score(lines, cmu, intent_syll),
        "Rhyme": rhyme_score(lines, cmu),
        "Specificity": specificity_score(lines, lexicon_set, common),
        "Throughline": throughline_bonus(lines),
        "Craft": craft_score(lines),
        "Punch": punch_score(lines, common=common),
    }
    W = WEIGHTS[section]
    pos = sum(axes[k] * W[k] for k in W)
    rep = repetition_penalty(lines, section)
    gate = plagiarism_gate(lines, corpus_4grams)
    net_raw = max(0.0, min(100.0, pos - rep))            # weighted-axis authenticity (no plagiarism gate)
    net = max(0.0, min(100.0, net_raw * gate))           # final, with downstream plagiarism gate
    typ = typicality_net(axes, section)                  # learned grader: proximity to authentic band
    return {"section": section, "axes": axes, "weights": W, "rep": rep, "gate": gate,
            "net_raw": round(net_raw, 1), "net": round(net, 1), "typicality": typ}


# ---------------- Typicality scorer (the LEARNED grader) ----------------------
# The big-baseline + real-vs-AI fit showed authenticity is NON-monotonic: word-salad scores
# too LOW on rhyme/meter, AI imitation scores too HIGH (too clean). So the right model isn't
# "maximise the axes" or a linear fit (its weights flip sign depending on the negative class) —
# it's "match the authentic distribution". The learned parameters are the per-section mean/std
# per axis (eval/v5_fingerprint.json), built from the real corpus alone; a verse scores high by
# being TYPICAL of real lyrics, which rejects both word-salad and over-polished AI.
_FP = None


def load_fingerprint(path=None):
    global _FP
    if _FP is None:
        p = path or os.path.join(os.path.dirname(os.path.abspath(__file__)), "v5_fingerprint.json")
        _FP = json.load(open(p)) if os.path.exists(p) else {}
    return _FP


def typicality_net(axes, section, fp=None):
    fp = fp if fp is not None else load_fingerprint()
    band = fp.get(section) if fp else None
    if not band:
        return None
    k = fp.get("k", 1.5)
    closeness = []
    for a, (mean, std) in band.items():
        z = (axes.get(a, mean) - mean) / (k * (std or 1e-9))
        closeness.append(math.exp(-0.5 * z * z))
    return round(100 * sum(closeness) / len(closeness), 1)


# ---------------- setup helpers ----------------------------------------------
def corpus_texts():
    path = os.path.join(G.REPO_ROOT, "XJournal AI", "chronological_rap_bars_MODEL_G.csv")
    if not os.path.exists(path):
        return []
    import csv
    return [r.get("text", "") for r in csv.DictReader(open(path, encoding="utf-8"))]


def build_common(texts, n=300):
    c = Counter()
    for t in texts:
        c.update(w.lower() for w in _words(t) if len(w) > 2 and w.lower() not in STOP)
    return {w for w, _ in c.most_common(n)}


def _setup():
    cmu = G.load_cmudict(G.DEFAULT_CMUDICT)
    _, grams = G.build_originality_index(G.load_corpus(G.DEFAULT_CORPUS))
    lex = {t.lower() for t in G.load_lexicon_terms(G.DEFAULT_LEXICON) if len(t) > 2}
    common = build_common(corpus_texts())
    _load_coded()   # warm the module-level cache
    return cmu, grams, lex, common


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(description="Model G v5 grader — recalibrated, section-aware")
    ap.add_argument("--verse", required=True, help="verse file, one bar per line")
    ap.add_argument("--section", choices=["verse", "hook"], help="force section (default: auto)")
    ap.add_argument("--intent-syll", type=int, help="target syllables/line (default: broad band)")
    a = ap.parse_args()
    cmu, grams, lex, common = _setup()
    lines = [l.strip() for l in open(a.verse, encoding="utf-8") if l.strip()]
    r = grade_v5(lines, cmu, grams, lex, common, section=a.section, intent_syll=a.intent_syll)
    print(f"\nModel G v5  —  section={r['section']}   NET = {r['net_raw']}"
          + ("" if r["gate"] == 1.0 else f"   (plagiarism gate ×{r['gate']} -> {r['net']})"))
    for k, v in r["axes"].items():
        print(f"  {k:12}{v:6.1f}   w={r['weights'][k]:.2f}")
    print(f"  {'-Repetition':12}{r['rep']:6.1f}")
    if r.get("typicality") is not None:
        print(f"  TYPICALITY  {r['typicality']:6.1f}   (learned: proximity to the authentic {r['section']} band)")
