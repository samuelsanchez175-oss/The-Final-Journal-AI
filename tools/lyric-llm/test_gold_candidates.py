#!/usr/bin/env python3
"""Test Best-of-N Candidate Generation with the Final Gold Adapter."""

import time
import random
from pathlib import Path
from mlx_lm import load
import mlx.core as mx
from mlx_lm.models.cache import make_prompt_cache
import infer
from lyriclib import estimate_syllables, normalize, tokenize, end_rime, load_cmudict

HERE = Path(__file__).resolve().parent
CMU_PATH = HERE.parent.parent / "XJournal AI" / "cmudict.txt"

print("Loading model and final Gold adapter...")
t0 = time.time()
model, tokenizer = load("mlx-community/Qwen2.5-3B-Instruct-4bit", adapter_path="adapters_gold")
print(f"Loaded in {time.time() - t0:.2f}s")

cmu = load_cmudict(CMU_PATH) if CMU_PATH.exists() else {}
dna_gunna = infer._voice_dna_profile(tokenizer, "Gunna")
dna_nocap = infer._voice_dna_profile(tokenizer, "NoCap")

DOUBLE_MEANINGS = dna_nocap.get("double_words") or set()
GUNNA_LUXURY = {"patek", "maybach", "whip", "drip", "clean", "ice", "slime", "chanel", "goyard", "diamonds", "rich", "racks", "bentley", "rolls"}
DANGLING = {
    "a", "an", "the", "to", "of", "in", "on", "for", "with", "and",
    "or", "but", "at", "by", "from", "as", "into", "like", "that",
    "who", "when", "where", "while", "if", "i", "i'm", "im", "we",
    "we're", "you", "you're", "don't", "dont", "can't", "cant",
    "ain't", "aint", "gonna", "wanna", "gotta", "my", "your", "our",
    "his", "her", "their", "its", "is", "are", "was", "were", "be",
}

CONVERSATIONAL_JUNK = [
    "how did you like", "i hope you enjoyed", "we can't do this alone", "buddy",
    "g-man", "did i tell you", "we have to work together", "what do you think",
    "let me know", "hey guys", "welcome to", "thanks for listening"
]

def score_bar_candidate(text: str, bar_idx: int, prev_lines: list[str], target_syl: int, voice: str) -> tuple[float, dict]:
    text = text.strip()
    norm = normalize(text)
    toks = tokenize(norm)
    if not toks:
        return -999.0, {"reason": "empty"}
    
    end_w = toks[-1]
    syl = estimate_syllables(text)
    score = 100.0
    details = {}
    
    # 1. Pocket Cadence
    delta = abs(syl - target_syl)
    cadence_score = max(0.0, 20.0 - 5.0 * delta)
    score += cadence_score
    details["cadence"] = round(cadence_score, 1)
    
    # 2. End word checks
    if end_w in DANGLING:
        score -= 80.0
        details["dangling"] = -80.0
    if end_w in infer.ADLIB_TAILS:
        score -= 35.0
        details["adlib_tail"] = -35.0
    if end_w.lower() in ("gunna", "drake", "wayne", "nocap", "thug"):
        score -= 90.0
        details["artist_name_end"] = -90.0
        
    # Check for immediate repetition
    for i in range(len(toks) - 1):
        if toks[i] == toks[i+1] and toks[i] not in ("no", "ha"):
            score -= 100.0
            details["repetition"] = -100.0
            
    # Check conversational assistant junk
    for cj in CONVERSATIONAL_JUNK:
        if cj in norm:
            score -= 150.0
            details["conversational_junk"] = -150.0
            
    # Check word overlap with earlier lines
    tok_set = set(toks)
    for pl in prev_lines:
        pl_toks = set(tokenize(normalize(pl)))
        overlap = len(tok_set & pl_toks) / max(1, len(tok_set))
        if overlap > 0.45:
            score -= 120.0
            details["line_overlap"] = -120.0
            break

    # 3. Rhyme pairing (Couplet structure: bar 2 rhymes with bar 1, bar 4 with 3, etc.)
    if bar_idx % 2 == 1 and prev_lines:
        prev_toks = tokenize(normalize(prev_lines[-1]))
        prev_end = prev_toks[-1] if prev_toks else ""
        if end_w == prev_end:
            score -= 100.0
            details["rhyme"] = "identical_word (-100)"
        else:
            r_cur = end_rime(end_w, cmu) if cmu else None
            r_prev = end_rime(prev_end, cmu) if cmu else None
            catalog_pairs = dna_gunna.get("rhyme_pairs", {}).get(prev_end, set())
            
            if end_w in catalog_pairs:
                score += 60.0
                details["rhyme"] = f"catalog_pair({prev_end}+{end_w}, +60)"
            elif r_cur and r_prev and r_cur == r_prev:
                score += 45.0
                details["rhyme"] = f"perfect_cmu({r_cur}, +45)"
            elif r_cur and r_prev and r_cur[0] == r_prev[0]:
                score += 25.0
                details["rhyme"] = f"slant_rhyme({r_cur[0]}, +25)"
            else:
                score -= 30.0
                details["rhyme"] = "no_rhyme (-30)"
    else:
        # First bar of couplet: bonus for landing on a catalog end word
        if end_w in dna_gunna.get("artist_end_words", set()) and end_w.lower() != "gunna":
            score += 25.0
            details["opening_anchor"] = f"+25 ({end_w})"
            
    # 4. Voice DNA & Imagery bonus
    for t in toks:
        if t in DOUBLE_MEANINGS:
            score += 25.0
            details["double_meaning"] = f"+25 ({t})"
            break
        if t in GUNNA_LUXURY:
            score += 20.0
            details["luxury_drip"] = f"+20 ({t})"
            break
            
    return score, details


def draft_bar(model, tokenizer, prompt_text: str, target_syl: int, temp: float, rng_seed: int, partner_words: set = None) -> str:
    rng = random.Random(rng_seed)
    prompt_ids = infer._encode(tokenizer, prompt_text)
    newline_ids = infer._encode(tokenizer, "\n")
    newline_set = set(newline_ids)
    eos = infer._eos_ids(tokenizer)
    profane = dna_gunna.get("profane_banned_tids", set())
    
    cache = make_prompt_cache(model)
    logits = infer._forward_last(model, prompt_ids, cache)
    
    line_ids = []
    limit = 32
    steps = 0
    
    while len(line_ids) < limit and steps < limit + 12:
        steps += 1
        current = infer._decode(tokenizer, line_ids) if line_ids else ""
        cur_syl = estimate_syllables(current) if current else 0
        
        ban = set(eos)
        ban.update(profane)
        
        if cur_syl < max(4, target_syl - 3):
            ban.update(newline_set)
            
        if line_ids:
            ban.add(line_ids[-1])
            
        cur_toks = tokenize(normalize(current)) if current else []
        last_w = cur_toks[-1] if cur_toks else ""
        if last_w in DANGLING or last_w in infer.ADLIB_TAILS:
            ban.update(newline_set)
            
        boost = None
        if partner_words and cur_syl >= target_syl - 2:
            partner_boost = {}
            w_to_tids = dna_gunna.get("word_to_tids", {})
            for pw in partner_words:
                for tid in w_to_tids.get(pw, ()):
                    partner_boost[tid] = 2.4
            if partner_boost:
                boost = partner_boost
                
        token = infer._draw_logits(logits, None, 1.0, temp, 0.92, rng, ban_ids=ban, boost_map=boost)
        if token in eos:
            break
            
        trial = infer._decode(tokenizer, line_ids + [token])
        if "\n" in trial:
            head = trial.split("\n", 1)[0].strip()
            if head:
                return infer.clean_bar(head)
            break
            
        line_ids.append(token)
        logits = infer._forward_last(model, [token], cache)
        
        if cur_syl >= target_syl:
            head = infer._decode(tokenizer, line_ids).strip()
            toks_h = tokenize(normalize(head))
            if toks_h and toks_h[-1] not in DANGLING and toks_h[-1] not in infer.ADLIB_TAILS:
                return infer.clean_bar(head)
                
    res = infer._decode(tokenizer, line_ids).strip()
    return infer.clean_bar(res)


def generate_verse_gold(voice: str = "Gunna", bars_count: int = 8, target_syl: int = 12) -> list[str]:
    prompt_base = f"<voice:{voice}> <bpm:130> <scale:F minor> <syl:{target_syl}>\n"
    lines = []
    
    for b_idx in range(bars_count):
        prompt_full = prompt_base + "\n".join(lines) + ("\n" if lines else "")
        partner_words = set()
        
        if b_idx % 2 == 1 and lines:
            prev_toks = tokenize(normalize(lines[-1]))
            if prev_toks:
                prev_end = prev_toks[-1]
                catalog_pairs = dna_gunna.get("rhyme_pairs", {}).get(prev_end, set())
                partner_words.update(catalog_pairs)
                r_prev = end_rime(prev_end, cmu) if cmu else None
                if r_prev:
                    _, rime_to_tids = infer._rhyme_index(tokenizer)
                    for _, rw in rime_to_tids.get(r_prev, ()):
                        if rw != prev_end and rw.lower() not in ("gunna", "drake", "wayne", "nocap"):
                            partner_words.add(rw)
                            
        candidates = []
        temps = [0.70, 0.76, 0.82, 0.88]
        for c_idx in range(4):
            cand_text = draft_bar(
                model, tokenizer, prompt_full, target_syl, 
                temp=temps[c_idx], rng_seed=500 + b_idx * 10 + c_idx,
                partner_words=partner_words if b_idx % 2 == 1 else None
            )
            if cand_text:
                score, details = score_bar_candidate(cand_text, b_idx, lines, target_syl, voice)
                candidates.append((score, cand_text, details))
                
        candidates.sort(key=lambda x: -x[0])
        best_score, best_text, best_details = candidates[0]
        lines.append(best_text)
        print(f"Bar {b_idx+1:02d} [Score {best_score:.1f}]: {best_text}")
        print(f"   Craft details: {best_details}")
        
    return lines

print("\n--- Generating 8 Bars with Final Gold Adapter + Best-of-N Candidate Selector ---")
t_start = time.time()
verse = generate_verse_gold("Gunna", 8, 12)
print(f"\nCompleted in {time.time() - t_start:.2f}s")
