#!/usr/bin/env python3
"""
Run a real Gemini generation, faithfully mirroring Model G's prompts, to A/B the v3 approach
(theme + exposure-voice + plan->verse) against a naive prompt — same entry, same model.

Key is read from env GEMINI_API_KEY (never stored). Writes verses to eval/captures/.
Then grade with:  python3 eval/grade_modelg.py --compare eval/captures/baseline.txt eval/captures/v3.txt
No third-party deps (urllib).
"""
import json, os, sys, urllib.request, urllib.error

KEY = os.environ.get("GEMINI_API_KEY", "").strip()
if not KEY:
    sys.exit("set GEMINI_API_KEY")
MODEL = "gemini-2.5-flash"
HERE = os.path.dirname(os.path.abspath(__file__))


def gemini(system, user, max_tokens, temperature, json_mode):
    cfg = {"temperature": temperature, "maxOutputTokens": max_tokens,
           "thinkingConfig": {"thinkingBudget": 0}}   # 2.5 "thinking" otherwise eats the output budget
    if json_mode:
        cfg["responseMimeType"] = "application/json"
    body = {
        "system_instruction": {"parts": [{"text": system}]},
        "contents": [{"role": "user", "parts": [{"text": user}]}],
        "generationConfig": cfg,
    }
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent?key={KEY}"
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            data = json.loads(r.read())
    except urllib.error.HTTPError as e:
        sys.exit(f"Gemini HTTP {e.code}: {e.read().decode()[:400]}")
    return data["candidates"][0]["content"]["parts"][0]["text"]


def write_verse(path, hook, bars):
    lines = ([hook] if hook else []) + bars
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(l.strip() for l in lines if l.strip()) + "\n")
    print(f"  wrote {os.path.relpath(path, os.path.dirname(HERE))} ({len(bars)} bars)")


def main():
    entry = open(os.path.join(HERE, "golden_entry.txt"), encoding="utf-8").read().strip()
    os.makedirs(os.path.join(HERE, "captures"), exist_ok=True)

    # ---- BASELINE: naive prompt (no theme, no voice, no plan) -------------------------------
    print("Generating BASELINE (naive prompt) ...")
    raw = gemini(
        "You write rap lyrics. Respond ONLY with JSON.",
        f'Turn this journal entry into a melodic trap verse: a hook and exactly 16 bars.\n'
        f'Entry: "{entry}"\nReturn JSON: {{"hook": "...", "bars": ["...", "... 16 total"]}}',
        max_tokens=1500, temperature=0.8, json_mode=True)
    b = json.loads(raw)
    write_verse(os.path.join(HERE, "captures", "baseline.txt"), b.get("hook", ""), b.get("bars", []))

    # ---- V3: theme + exposure-voice + plan -> verse (mirrors ModelGCoreCoordinatorV3) --------
    # Representative theme/voice context for this entry (the app computes these via
    # ThematicStateDetector / SignalIngest; here we set the equivalents explicitly).
    theme_name, tone = "The Come-Up / Quiet Money", "confident, guarded"
    palette = "paid it off, new place, stay low, the lawyers, the plug, few I trust, foreign, quiet"
    voice = ("Voice (stay in character):\n"
             "- Posture: established authority, speaking to the public.\n"
             "- Social move: flex early, distance mid-verse, land with finality.\n"
             "- Exposure: LOW. Imply, don't explain. Signal wealth/risk through one concrete detail; "
             "never justify, never name the act. Over-explaining kills the line.")
    arc = ("Let the voice shift across the verse: open establishing (flex), a turn to distance "
           "mid-verse for tension, escalate at the peak, then land with finality. Don't hold one posture.")

    print("Generating V3 plan ...")
    plan_raw = gemini(
        "You are Model G's planning step. Respond ONLY with valid JSON.",
        f'Plan a 16-bar melodic trap verse. JSON only.\nTheme: {theme_name} (tone: {tone})\n'
        f'Direction: {entry}\nVoice: established authority to public, exposure low.\n'
        f'Return JSON exactly: {{"centralImage": "...", "angle": "...", "anchorRhymes": ["...","...","..."]}}',
        max_tokens=320, temperature=0.6, json_mode=True)
    plan = json.loads(plan_raw)
    plan_text = (f"Central image: {plan.get('centralImage','')}. Angle: {plan.get('angle','')}. "
                 f"Anchor rhyme sounds: {', '.join(plan.get('anchorRhymes', []))}.")
    print(f"  plan: {plan_text}")

    print("Generating V3 verse ...")
    verse_raw = gemini(
        "You are Model G. Respond ONLY with valid JSON: a hook and exactly 16 bars.",
        f'Write a melodic trap verse: a 1-2 line HOOK and EXACTLY 16 bars. JSON only.\n'
        f'Topic: {entry}\nTheme: {theme_name} — emotional tone: {tone}.\n'
        f"Draw on this theme's vocabulary where it fits (don't force all): {palette}.\n"
        f'{plan_text}\n{arc}\n{voice}\n'
        f'Rules: ~8-12 syllables per bar; rhyme hard (multisyllabic/internal welcome); '
        f'imply more than you state; no numbering inside the bars.\n'
        f'Return JSON exactly: {{"hook": "...", "bars": ["...", "... 16 total"]}}',
        max_tokens=1500, temperature=0.85, json_mode=True)
    v = json.loads(verse_raw)
    write_verse(os.path.join(HERE, "captures", "v3.txt"), v.get("hook", ""), v.get("bars", []))
    print("Done.")


if __name__ == "__main__":
    main()
