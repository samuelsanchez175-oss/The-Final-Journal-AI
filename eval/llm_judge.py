"""Model G — LLM-judge (the semantic ceiling the mechanical grader can't reach).

The mechanical/typicality grader is a FLOOR: it rejects word-salad and over-polished AI by
matching the authentic distribution, but it cannot tell a GREAT line from a competent one. "Is
there a real drug pun? does it play family x luxury? does 'Uzi' land as gun/rapper/jewelry at
once? does it sound like a human rapper or a brand's caption?" — that is semantic judgment, and
only an LLM can do it. This module is that judge.

It scores a verse on six semantic axes via Claude (claude-opus-4-8) with structured JSON output,
and is seeded with the entity knowledge base (rapper/drug lexicons) so it can verify cultural
references (Slime = Young Thug/YSL, Uzi = Lil Uzi Vert / gun / jewelry, regional drug aliases).

Run where an ANTHROPIC_API_KEY exists (your machine / CI / the app) — not in the eval sandbox.
    pip install anthropic
    python3 eval/llm_judge.py --verse path/to/verse.txt [--section verse|hook]
"""
import os, sys, json, argparse

AXES = ["wordplay", "specificity", "cultural_truth", "range", "human_not_caption", "punchline"]

JUDGE_SYSTEM = """You are a veteran rap A&R and ghostwriter with an ear for what's REAL. You judge \
whether a verse reads like something a human rapper (Atlanta trap — the Gunna/Young Thug/Lil Baby \
lineage and peers) would actually say on a song, versus competent-but-soulless AI imitation or \
motivational-poster "caption rap." You can hear what statistics cannot.

REWARD:
- WORDPLAY: real double-entendres and puns — especially drug/gun/money/sex multi-meaning (e.g. \
"Uzi" = the gun AND Lil Uzi Vert AND iced-out jewelry; "slime" = YSL brotherhood AND the word).
- SPECIFICITY: concrete, lived, surprising detail (e.g. "fall asleep at the light", "a coat his \
grandma archived") — not generic flexing.
- CULTURAL TRUTH: codes used correctly ("we ain't snitchin'", loyalty/street codes, accurate \
rapper/producer nicknames and references).
- RANGE: moving between family, luxury, and casual taboo (sex, drugs, violence) in one breath \
without flinching.
- PUNCHLINE: at least one line you'd rewind.

PENALIZE: generic gratitude/"blessed"/manifestation rap, over-explanation, vague brand-dropping \
with no image, anything that sounds like an Instagram caption or a motivational poster.

Score each axis 0-10 (0 = absent / AI-tell, 10 = elite human). `overall` is 0-100. `best_line` is \
the strongest bar, verbatim. `weakest_tell` is the most AI-sounding/inauthentic line verbatim, or \
"none". `verdict` is one blunt sentence: does this sound like a real rapper, or not?"""

_AXIS = {"type": "object", "additionalProperties": False,
         "properties": {"score": {"type": "integer"}, "note": {"type": "string"}},
         "required": ["score", "note"]}
SCHEMA = {"type": "object", "additionalProperties": False,
          "properties": {**{a: _AXIS for a in AXES},
                         "overall": {"type": "integer"}, "best_line": {"type": "string"},
                         "weakest_tell": {"type": "string"}, "verdict": {"type": "string"}},
          "required": AXES + ["overall", "best_line", "weakest_tell", "verdict"]}


def _glossary(limit=40):
    """Compact entity hints from the knowledge base so the judge can verify references."""
    import csv
    base = os.path.join(os.path.dirname(os.path.abspath(__file__)), "lexicons")
    out = []
    for fn, kcol, vcol in [("rapper_lexicon.csv", "term", "codes_note"),
                           ("drug_lexicon.csv", "canonical", "note")]:
        p = os.path.join(base, fn)
        if not os.path.exists(p):
            continue
        for r in list(csv.DictReader(open(p, encoding="utf-8")))[:limit]:
            who = r.get("canonical") or r.get(kcol, "")
            note = r.get(vcol, "")
            ali = r.get("aliases", "")
            out.append(f"- {r.get(kcol,'')}" + (f" = {who}" if who and who != r.get(kcol,'') else "")
                       + (f" (aka {ali})" if ali else "") + (f": {note}" if note else ""))
    return "\n".join(out)


def judge_verse(lines, section="verse", model="claude-opus-4-8"):
    import anthropic
    client = anthropic.Anthropic()
    glossary = _glossary()
    user = (f"Section type: {section}\n"
            + (f"\nReference glossary (verify any of these used in the verse):\n{glossary}\n" if glossary else "")
            + "\nGrade this verse:\n\"\"\"\n" + "\n".join(lines) + "\n\"\"\"")
    resp = client.messages.create(
        model=model,
        max_tokens=2000,
        thinking={"type": "adaptive"},
        system=JUDGE_SYSTEM,
        messages=[{"role": "user", "content": user}],
        output_config={"format": {"type": "json_schema", "schema": SCHEMA}, "effort": "high"},
    )
    text = next(b.text for b in resp.content if b.type == "text")
    return json.loads(text)


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="Model G LLM-judge — semantic quality of a verse")
    ap.add_argument("--verse", required=True, help="verse file, one bar per line")
    ap.add_argument("--section", choices=["verse", "hook"], default="verse")
    ap.add_argument("--model", default="claude-opus-4-8")
    a = ap.parse_args()
    if not os.environ.get("ANTHROPIC_API_KEY"):
        sys.exit("Set ANTHROPIC_API_KEY to run the judge (it calls Claude).")
    lines = [l.strip() for l in open(a.verse, encoding="utf-8") if l.strip()]
    r = judge_verse(lines, section=a.section, model=a.model)
    print(f"\nLLM-judge ({a.model})  —  OVERALL {r['overall']}/100")
    for ax in AXES:
        print(f"  {ax:18}{r[ax]['score']:>3}/10   {r[ax]['note']}")
    print(f"\n  best line   : {r['best_line']}")
    print(f"  weakest tell: {r['weakest_tell']}")
    print(f"  verdict     : {r['verdict']}")
