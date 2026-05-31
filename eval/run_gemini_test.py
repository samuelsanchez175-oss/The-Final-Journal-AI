#!/usr/bin/env python3
"""
5x A/B against live Gemini: tweaked v3 (theme+voice+plan, SHORT punchy bars + HARD multisyllabic/
internal rhyme, imply-don't-explain) vs a naive baseline, across 5 different starting entries.

Key via env GEMINI_API_KEY (never stored). Writes eval/captures/e{i}_{baseline,v3}.txt, then:
  python3 eval/grade_modelg.py --compare eval/captures/e1_baseline.txt eval/captures/e1_v3.txt ...
No third-party deps.
"""
import datetime, json, os, sys, urllib.request, urllib.error
from collections import defaultdict
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import grade_modelg as G

KEY = os.environ.get("GEMINI_API_KEY", "").strip()
if not KEY:
    sys.exit("set GEMINI_API_KEY")
MODEL = "gemini-2.5-flash"
BIAS = float(os.environ.get("ORIG_BIAS", "0.6"))   # originality/inspiration target (matches the in-app slider)
HERE = os.path.dirname(os.path.abspath(__file__))
CAP = os.path.join(HERE, "captures")

ENTRIES = [
    "Long day but a good one. Paid the car off, moved mama into the new place. I don't tell people my "
    "business; let the lawyers and paperwork talk. Watching it come together quiet, staying low, keeping "
    "the same few close. Feels like it's working but I'm not saying it out loud.",
    "Lost my dawg last winter and I still don't talk about it. Keep his chain on me, pour one out when "
    "it's quiet. People ask what happened, I change the subject. Some things you just carry, you don't explain.",
    "Dropped a check on the watch today, iced out. Valet took the foreign when I pulled up. Bottles on the "
    "table, whole section watching. Worked too hard for this not to let it shine a little.",
    "Can't sleep, phone keep buzzing, somebody talking too much. Switched my whole routine up, watching who "
    "I let close. Money still moving but the block been hot lately. Stay low, trust few, keep my circle small.",
    "Twenty years deep and still standing when half of them folded. Put my little brother on, watch him eat "
    "now. I don't chase the noise anymore — the work speaks. Built something they can't take from me.",
]


def gemini(system, user, max_tokens, temperature):
    cfg = {"temperature": temperature, "maxOutputTokens": max_tokens,
           "thinkingConfig": {"thinkingBudget": 0}, "responseMimeType": "application/json"}
    body = {"system_instruction": {"parts": [{"text": system}]},
            "contents": [{"role": "user", "parts": [{"text": user}]}], "generationConfig": cfg}
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent?key={KEY}"
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=90) as r:
            return json.loads(r.read())["candidates"][0]["content"]["parts"][0]["text"]
    except urllib.error.HTTPError as e:
        sys.exit(f"Gemini HTTP {e.code}: {e.read().decode()[:300]}")


def write(path, hook, bars):
    lines = ([hook] if hook else []) + list(bars)
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(l.strip() for l in lines if l and l.strip()) + "\n")


def baseline(entry):
    o = json.loads(gemini(
        "You write rap lyrics. Respond ONLY with JSON.",
        f'Turn this journal entry into a melodic trap verse: a hook and exactly 16 bars.\n'
        f'Entry: "{entry}"\nReturn JSON: {{"hook": "...", "bars": ["...", "... 16 total"]}}',
        1500, 0.8))
    return o.get("hook", ""), o.get("bars", [])


def v3(entry):
    plan = json.loads(gemini(
        "You are Model G's planning step. Respond ONLY with valid JSON.",
        f'Plan a 16-bar melodic trap verse from this entry. Infer the theme and slang yourself. JSON only.\n'
        f'Entry: "{entry}"\nReturn JSON exactly: {{"theme": "...", "jargon": ["...","...","..."], '
        f'"centralImage": "...", "angle": "...", "anchorRhymes": ["...","...","..."]}}',
        320, 0.6))
    plan_text = (f"Theme: {plan.get('theme','')}. Central image: {plan.get('centralImage','')}. "
                 f"Angle: {plan.get('angle','')}. Anchor rhyme sounds: {', '.join(plan.get('anchorRhymes', []))}. "
                 f"Slang to weave (don't force all): {', '.join(plan.get('jargon', []))}.")
    voice = ("Voice: established, guarded. IMPLY, don't explain — signal through one concrete detail, never "
             "justify, never name the act. Let the posture shift across the verse (open flexing, turn distant "
             "mid-verse, escalate, land with finality). No motivational or filler lines.")
    inspiration = ("Be grounded in the culture — reference music, brands, places, slang and play on familiar "
                   "phrases; borrow the genre's idioms. Clever and referential beats sterile-original."
                   if BIAS < 0.5 else
                   "Lean fresh and novel, but stay grounded in the culture — references and wordplay over invention.")
    o = json.loads(gemini(
        "You are Model G. Respond ONLY with valid JSON: a hook and exactly 16 bars.",
        f'Write a melodic trap verse: a 1-2 line HOOK and EXACTLY 16 bars. JSON only.\n'
        f'Source feeling: "{entry}"\n{plan_text}\n{voice}\n{inspiration}\n'
        f'RULES (strict): each bar SHORT and punchy, 8-10 syllables MAX — no wordy or run-on lines; '
        f'rhyme HARD — multisyllabic and INTERNAL rhyme, not just line-ends; concrete images over statements; '
        f'do not repeat the same word; no numbering inside bars.\n'
        f'Return JSON exactly: {{"hook": "...", "bars": ["...", "... 16 total"]}}',
        1400, 0.9))
    return o.get("hook", ""), o.get("bars", [])


def main():
    os.makedirs(CAP, exist_ok=True)
    # Grading deps loaded once, so every generation is auto-scored + recorded to the log.
    cmu = G.load_cmudict(G.DEFAULT_CMUDICT)
    corpus = G.load_corpus(G.DEFAULT_CORPUS)
    base = G.corpus_baseline(corpus, cmu)
    clines, c4 = G.build_originality_index(corpus)
    lex = G.load_lexicon_terms(G.DEFAULT_LEXICON)
    G.ORIGINALITY_TARGET = BIAS   # score originality against the same target the generation used
    run_id = datetime.datetime.now().isoformat(timespec="seconds")
    sums = defaultdict(list)

    for i, entry in enumerate(ENTRIES, 1):
        for version, gen in (("baseline", baseline), ("v3", v3)):
            print(f"[{i}/5] {version} ...", flush=True)
            hook, bars = gen(entry)
            write(os.path.join(CAP, f"e{i}_{version}.txt"), hook, bars)
            lines = [l for l in ([hook] + list(bars)) if l and l.strip()]
            pos, neg, net, _ = G.grade_verse(lines, cmu, base, lex, clines, c4)
            G.append_log(version, f"e{i}_{version}", pos, neg, net, run_id)
            sums[version].append(net)

    print("\n=== this run — mean NET (auto-graded + logged) ===")
    for v in sorted(sums):
        print(f"  {v:<10} {sum(sums[v]) / len(sums[v]):6.1f}")
    print("Logged to eval/grading_log.csv. Trend over runs:  python3 eval/grade_modelg.py --history")


if __name__ == "__main__":
    main()
