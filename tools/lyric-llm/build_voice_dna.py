#!/usr/bin/env python3
"""Mine per-artist substantive end-rhyme banks, signature phrases, and NoCap double-meaning wordplay DNA."""

from __future__ import annotations

import collections
import json
import math
import re
from pathlib import Path

from lyriclib import end_rime, load_cmudict

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
CMU_PATH = HERE.parent.parent / "XJournal AI" / "cmudict.txt"

WORD_RE = re.compile(r"[a-zA-Z][a-zA-Z']*")
TRAILING_PAREN_RE = re.compile(r"(?:\s*\([^)]*\)\s*)+$")

STOPWORDS = {
    "the", "and", "to", "a", "of", "in", "it", "is", "that", "for", "on", "with",
    "as", "be", "at", "by", "an", "are", "from", "or", "have", "had", "has", "was",
    "were", "but", "not", "what", "all", "we", "when", "your", "can", "said",
    "there", "use", "each", "which", "she", "do", "how", "their", "if", "will",
    "up", "other", "about", "out", "many", "then", "them", "these", "so", "some",
    "her", "would", "make", "like", "him", "into", "look", "two", "more",
    "go", "see", "no", "way", "could", "my", "than", "been", "call", "who", "its",
    "now", "find", "long", "down", "day", "did", "get", "come", "made", "may",
    "part", "im", "i'm", "you", "me", "i", "he", "they", "this", "just", "dont",
    "don't", "aint", "ain't", "got", "know", "yeah", "uh", "oh", "ayy", "nah",
    "gon", "gonna", "wanna", "cause", "cuz", "em", "'em", "let", "put", "take",
    "one", "too", "here", "there", "where", "when", "why", "how", "off", "back",
    "still", "even", "only", "ever", "never", "always", "really", "very", "much",
    "same", "own", "new", "old", "good", "bad", "big", "lil", "little", "young",
    "real", "right", "left", "tell", "told", "say", "said", "talk", "talking",
    "talkin", "think", "thought", "feel", "felt", "want", "wanted", "need", "needed",
    "try", "tryna", "tried", "give", "gave", "keep", "kept", "left", "came", "went",
    "done", "doing", "doin", "going", "goin", "coming", "comin", "getting", "gettin",
    "making", "makin", "taking", "takin", "looking", "lookin", "orro", "ft", "feat",
    "remix", "intro", "outro", "verse", "chorus", "hook", "episode", "radio",
}

LEAD_STOPWORDS = {
    "the", "and", "to", "a", "an", "of", "in", "it", "is", "that", "for", "on", "with",
    "as", "be", "at", "by", "are", "from", "or", "have", "had", "has", "was", "were",
    "but", "not", "what", "all", "we", "when", "your", "can", "there", "she", "he",
    "they", "this", "them", "these", "so", "some", "her", "him", "my", "me", "you",
    "i", "im", "i'm", "dont", "don't", "aint", "ain't", "got", "know", "gon", "gonna",
    "wanna", "cause", "cuz", "let", "put", "get", "did", "now", "see", "go", "say",
    "said", "try", "tell", "keep", "done", "who", "which", "how", "why", "where",
    "been", "would", "could", "into", "than", "its", "then", "like", "just", "off",
    "back", "up", "down", "out", "take", "make", "want", "need", "feel", "talk",
}

ADLIB_TAILS = {
    "yeah", "yea", "yah", "uh", "oh", "ooh", "woah", "whoa", "ayy", "ay", "hey",
    "huh", "nah", "ha", "haha", "ok", "okay", "slatt", "skrrt", "woo", "ah", "ahh",
    "mmm", "hm", "hmm", "bah", "bow", "brr", "brrt", "grrt", "gang", "baby", "boy",
    "man", "bro", "dawg", "dog", "nigga", "niggas", "bitch", "bitches", "shit",
    "fuck", "damn", "god", "lord", "ya", "yo", "yuh", "what", "wait",
}

PHRASE_BANNED_WORDS = {
    "nigga", "niggas", "bitch", "bitches", "shit", "fuck", "fucking", "fuckin",
    "pussy", "hoe", "hoes", "dick", "ass", "damn", "hell", "cunt", "faggot",
    "remix", "feat", "ft", "episode", "radio", "intro", "outro", "chorus",
}

# Substantive Double-Meaning & Homophone Wordplay Bank (NoCap + Gunna + Lil Wayne style)
CURATED_DOUBLE_MEANINGS = {
    "cap": {"senses": ["lie / no cap", "fitted cap / ceiling"], "homophones": [], "pair_triggers": ["lie", "hat", "truth", "fitted", "lid"]},
    "bars": {"senses": ["rap lines / 16s", "prison cell bars / Xanax"], "homophones": [], "pair_triggers": ["cell", "jail", "prison", "write", "beat", "judge"]},
    "scale": {"senses": ["digital weigh scale", "musical key / climb / fish scale"], "homophones": [], "pair_triggers": ["weigh", "grams", "piano", "key", "fish", "balance"]},
    "keys": {"senses": ["piano keys / melody", "kilos / car ignition keys"], "homophones": [], "pair_triggers": ["piano", "lock", "door", "push", "ignition", "notes"]},
    "charge": {"senses": ["felony indictment", "battery % / Amex charge / attack"], "homophones": [], "pair_triggers": ["court", "case", "battery", "card", "plug", "judge"]},
    "court": {"senses": ["trial courtroom", "basketball hardwood / caught"], "homophones": ["caught"], "pair_triggers": ["judge", "trial", "ball", "case", "lawyer", "bench"]},
    "bail": {"senses": ["bond out the county", "bail out / hay bale"], "homophones": ["bale"], "pair_triggers": ["bond", "jail", "cell", "judge", "court"]},
    "safe": {"senses": ["out of danger", "combination steel vault"], "homophones": [], "pair_triggers": ["combination", "lock", "vault", "cash", "dangerous", "code"]},
    "bank": {"senses": ["Chase / Wells Fargo vault", "river bank / glass bank shot"], "homophones": [], "pair_triggers": ["teller", "deposit", "money", "river", "shot", "account"]},
    "checks": {"senses": ["direct deposit paychecks", "Nike swooshes / chess moves"], "homophones": ["chess"], "pair_triggers": ["nike", "stripe", "bank", "cash", "sign", "clear"]},
    "rock": {"senses": ["VVS diamond stone", "heavy stone / rock & roll"], "homophones": [], "pair_triggers": ["diamond", "ice", "wrist", "shine", "roll", "solid"]},
    "ice": {"senses": ["flawless VVS diamonds", "frozen water / cold vein"], "homophones": [], "pair_triggers": ["water", "freeze", "cold", "wrist", "neck", "patek", "melt"]},
    "drip": {"senses": ["designer wardrobe", "water leak / IV bag"], "homophones": [], "pair_triggers": ["drown", "water", " puddle", "chanel", "splash", "ocean", "wave"]},
    "wave": {"senses": ["ocean tide", "style trend / hand wave"], "homophones": ["waive"], "pair_triggers": ["ocean", "sea", "surf", "drown", "water", "tide", "boat"]},
    "plug": {"senses": ["main supplier / connect", "wall socket / spark plug"], "homophones": [], "pair_triggers": ["socket", "outlet", "charge", "cord", "connect", "power"]},
    "trap": {"senses": ["the spot / hustle", "bear trap / snare"], "homophones": [], "pair_triggers": ["mouse", "cheese", "spot", "phone", "jump", "kitchen"]},
    "paper": {"senses": ["blue hundred-dollar bills", "notebook sheet / rolling paper"], "homophones": [], "pair_triggers": ["pen", "ink", "write", "stack", "fold", "chase"]},
    "bread": {"senses": ["bankroll / dough", "bakery loaf / toast"], "homophones": ["bred"], "pair_triggers": ["loaf", "crumbs", "toast", "butter", "yeast", "dough"]},
    "plates": {"senses": ["ceramic dinner dishes", "temp license plates / 45lb gym plates"], "homophones": [], "pair_triggers": ["eat", "fork", "food", "table", "tags", "weight"]},
    "bonds": {"senses": ["bail bondsman", "blood brotherhood / Barry Bonds"], "homophones": [], "pair_triggers": ["bail", "jail", "brother", "trust", "family"]},
    "cases": {"senses": ["open felony cases", "Goyard briefcases / luggage"], "homophones": [], "pair_triggers": ["lawyer", "beat", "court", "judge", "pack", "flight"]},
    "sentences": {"senses": ["federal prison years", "spoken grammar lines"], "homophones": [], "pair_triggers": ["judge", "time", "period", "bars", "prison", "words"]},
    "degrees": {"senses": ["college diplomas", "Fahrenheit heat / first-degree"], "homophones": [], "pair_triggers": ["college", "school", "hot", "cold", "burn", "heat"]},
    "quarters": {"senses": ["25-cent coins / 4th quarter", "quarter-pound / living quarters"], "homophones": [], "pair_triggers": ["dime", "nickel", "change", "clock", "game", "half"]},
    "lines": {"senses": ["written rap bars", "phone lines / highway lanes"], "homophones": [], "pair_triggers": ["read", "between", "phone", "call", "cross", "page"]},
    "shots": {"senses": ["Casamigos pours", "jump shots / hollow rounds"], "homophones": [], "pair_triggers": ["glass", "bar", "pour", "bottle", "aim", "miss", "hoop"]},
    "bucks": {"senses": ["hundred-dollar bills", "Milwaukee Bucks / deer"], "homophones": [], "pair_triggers": ["giannis", "deer", "money", "spend", "racks"]},
    "rings": {"senses": ["championship / pinky rings", "missed phone rings / boxing ring"], "homophones": ["wrings"], "pair_triggers": ["finger", "phone", "call", "bell", "champ", "diamond"]},
    "coach": {"senses": ["sideline head coach", "back-row economy flight / Coach bag"], "homophones": [], "pair_triggers": ["first", "class", "flight", "plane", "play", "team", "bench"]},
    "stars": {"senses": ["Rolls-Royce Wraith ceiling", "astronomy / Hollywood stars"], "homophones": [], "pair_triggers": ["wraith", "roof", "ceiling", "sky", "moon", "space"]},
    "space": {"senses": ["coupe legroom / distance", "outer cosmos / NASA"], "homophones": [], "pair_triggers": ["stars", "moon", "mars", "coupe", "room", "planet"]},
    "son": {"senses": ["young boy / protégé", "blazing sun (homophone)"], "homophones": ["sun"], "pair_triggers": ["shine", "bright", "father", "sky", "morning", "raise"]},
    "sun": {"senses": ["solar star", "firstborn son (homophone)"], "homophones": ["son"], "pair_triggers": ["shine", "son", "moon", "light", "shades", "blind"]},
    "pain": {"senses": ["deep scars / struggle", "glass window pane (homophone)"], "homophones": ["pane"], "pair_triggers": ["window", "glass", "rain", "hurt", "scars", "feel"]},
    "rain": {"senses": ["storm clouds", "king's reign / make it rain"], "homophones": ["reign"], "pair_triggers": ["umbrella", "storm", "king", "crown", "clouds", "puddle"]},
    "reign": {"senses": ["royal rule", "falling rain (homophone)"], "homophones": ["rain"], "pair_triggers": ["king", "crown", "throne", "rain", "storm"]},
    "peace": {"senses": ["quiet mind / truce", "chrome piece / pendant (homophone)"], "homophones": ["piece"], "pair_triggers": ["war", "mind", "chain", "neck", "quiet", "puzzle"]},
    "piece": {"senses": ["custom diamond pendant / steel", "inner peace (homophone)"], "homophones": ["peace"], "pair_triggers": ["chain", "ice", "peace", "hit", "neck", "puzzle"]},
    "soul": {"senses": ["human spirit", "red shoe sole (homophone)"], "homophones": ["sole"], "pair_triggers": ["heart", "shoes", "feet", "walk", "devil", "spirit"]},
    "sole": {"senses": ["bottom of the sneaker", "human soul (homophone)"], "homophones": ["soul"], "pair_triggers": ["shoe", "walk", "step", "soul", "red", "tracks"]},
    "steel": {"senses": ["heavy metal / AP watch", "steal / take (homophone)"], "homophones": ["steal"], "pair_triggers": ["metal", "iron", "chrome", "rob", "take", "wrist"]},
    "steal": {"senses": ["take without asking", "stainless steel (homophone)"], "homophones": ["steel"], "pair_triggers": ["rob", "thief", "steel", "heart", "base"]},
    "cell": {"senses": ["county jail block / iPhone", "sell product (homophone)"], "homophones": ["sell"], "pair_triggers": ["bars", "jail", "phone", "call", "ring", "sell"]},
    "weight": {"senses": ["heavy bricks / pressure", "wait patiently (homophone)"], "homophones": ["wait"], "pair_triggers": ["scale", "heavy", "lift", "wait", "patience", "tons"]},
    "morning": {"senses": ["sunrise AM", "mourning in black (homophone)"], "homophones": ["mourning"], "pair_triggers": ["wake", "sun", "cry", "grief", "early", "night"]},
    "mourning": {"senses": ["grieving a loss", "early morning sunrise (homophone)"], "homophones": ["morning"], "pair_triggers": ["cry", "tears", "morning", "wake", "black"]},
    "patience": {"senses": ["staying calm for the turn", "hospital patients (homophone)"], "homophones": ["patients"], "pair_triggers": ["doctor", "wait", "hospital", "sick", "nurse", "time"]},
    "patients": {"senses": ["people in the clinic", "having patience (homophone)"], "homophones": ["patience"], "pair_triggers": ["doctor", "nurse", "wait", "patience", "medicine"]},
    "plain": {"senses": ["Plain Jane watch (no ice)", "G5 private plane (homophone)"], "homophones": ["plane"], "pair_triggers": ["jane", "watch", "rollie", "fly", "jet", "pilot", "sky"]},
    "plane": {"senses": ["private G5 jet", "Plain Jane watch (homophone)"], "homophones": ["plain"], "pair_triggers": ["fly", "pilot", "airport", "land", "plain", "clouds"]},
    "whole": {"senses": ["entire / 100%", "deep hole in the ground (homophone)"], "homophones": ["hole"], "pair_triggers": ["half", "dig", "deep", "piece", "trap"]},
    "hole": {"senses": ["deep pit / bullet hole", "the whole thing (homophone)"], "homophones": ["whole"], "pair_triggers": ["dig", "deep", "wall", "whole", "climb"]},
    "roll": {"senses": ["bankroll / Rolls-Royce / dice", "acting role (homophone)"], "homophones": ["role"], "pair_triggers": ["dice", "bankroll", "royce", "play", "movie", "cast"]},
    "role": {"senses": ["part in the movie", "bankroll / roll the dice (homophone)"], "homophones": ["roll"], "pair_triggers": ["play", "actor", "movie", "roll", "dice"]},
    "knight": {"senses": ["armored warrior / Suge Knight", "late night (homophone)"], "homophones": ["night"], "pair_triggers": ["armor", "shine", "dark", "late", "king", "chess"]},
    "night": {"senses": ["after dark / 3 AM", "armored knight (homophone)"], "homophones": ["knight"], "pair_triggers": ["day", "dark", "stars", "sleep", "late", "moon"]},
    "flu": {"senses": ["sick / fever", "flew on a jet (homophone)"], "homophones": ["flew"], "pair_triggers": ["sick", "cold", "cough", "plane", "jet", "clouds"]},
    "flew": {"senses": ["took a private flight", "caught the flu (homophone)"], "homophones": ["flu"], "pair_triggers": ["plane", "jet", "sky", "sick", "flu", "first"]},
    "sense": {"senses": ["common logic / sixth sense", "pennies & cents / cologne scents"], "homophones": ["cents", "scents"], "pair_triggers": ["money", "change", "dollar", "smell", "mind"]},
    "cents": {"senses": ["pocket change / coins", "make common sense (homophone)"], "homophones": ["sense", "scents"], "pair_triggers": ["dollar", "change", "sense", "quarters", "money"]},
    "profit": {"senses": ["net money return", "chosen prophet (homophone)"], "homophones": ["prophet"], "pair_triggers": ["money", "loss", "bible", "preach", "vision", "gain"]},
    "prophet": {"senses": ["visionary / preacher", "financial profit (homophone)"], "homophones": ["profit"], "pair_triggers": ["god", "preach", "future", "profit", "money"]},
    "board": {"senses": ["executive board / chessboard", "bored of the game (homophone)"], "homophones": ["bored"], "pair_triggers": ["meeting", "boss", "flight", "game", "tired", "plane"]},
    "week": {"senses": ["seven calendar days", "weak / fragile (homophone)"], "homophones": ["weak"], "pair_triggers": ["days", "strong", "seven", "tired", "month"]},
    "weak": {"senses": ["soft / no strength", "seven-day week (homophone)"], "homophones": ["week"], "pair_triggers": ["strong", "days", "soft", "heart", "knees"]},
    "brake": {"senses": ["coupe brake pedal", "catch a break / shatter (homophone)"], "homophones": ["break"], "pair_triggers": ["gas", "pedal", "stop", "car", "coupe", "heart"]},
    "break": {"senses": ["shatter / intermission", "hit the brake pedal (homophone)"], "homophones": ["brake"], "pair_triggers": ["glass", "heart", "gas", "stop", "promise"]},
}


def tokenize_line(line: str) -> list[str]:
    return [m.group(0).lower().strip("'") for m in WORD_RE.finditer(line) if len(m.group(0).strip("'")) >= 2]


def extract_clean_end_word(line: str) -> str:
    """Strip trailing parenthetical ad-libs and filler interjections to get the true bar-ending rhyme word."""
    cleaned = TRAILING_PAREN_RE.sub("", line.strip()).strip()
    toks = tokenize_line(cleaned)
    while len(toks) > 1 and toks[-1] in ADLIB_TAILS:
        toks.pop()
    return toks[-1] if toks else ""


def main() -> int:
    cmu = load_cmudict(CMU_PATH)

    word_to_rime: dict[str, str] = {}
    for word, phones in cmu.items():
        if not phones or not word.isalpha() or len(word) < 2:
            continue
        rm = end_rime(word, cmu)
        if rm:
            word_to_rime[word] = "-".join(rm)

    artist_lines: collections.Counter[str] = collections.Counter()
    artist_end_counts: dict[str, collections.Counter[str]] = collections.defaultdict(collections.Counter)
    global_end_counts: collections.Counter[str] = collections.Counter()

    artist_rhyme_pairs: dict[str, dict[str, collections.Counter[str]]] = collections.defaultdict(
        lambda: collections.defaultdict(collections.Counter)
    )
    artist_ngrams: dict[str, collections.Counter[str]] = collections.defaultdict(collections.Counter)
    global_ngrams: collections.Counter[str] = collections.Counter()
    artist_word_counts: dict[str, collections.Counter[str]] = collections.defaultdict(collections.Counter)
    global_word_counts: collections.Counter[str] = collections.Counter()

    train_path = OUT / "train.jsonl"
    print(f"Scanning {train_path} for substantive artist voice DNA...")
    with train_path.open("r", encoding="utf-8") as handle:
        for raw_line in handle:
            row = json.loads(raw_line)
            artist = row.get("artist") or "Unknown"
            text = row.get("text") or ""
            lines = [ln.strip() for ln in text.splitlines() if ln.strip() and not ln.strip().startswith("[")]
            if not lines:
                continue
            artist_lines[artist] += len(lines)

            recent_ends: list[tuple[str, str]] = []
            for ln in lines:
                clean_ln = TRAILING_PAREN_RE.sub("", ln).strip()
                toks = tokenize_line(clean_ln)
                if not toks:
                    continue
                for w in toks:
                    artist_word_counts[artist][w] += 1
                    global_word_counts[w] += 1

                # Collect substantive 2-grams and 3-grams
                for n in (2, 3):
                    for i in range(len(toks) - n + 1):
                        gram = toks[i : i + n]
                        if any(g in PHRASE_BANNED_WORDS or g in ADLIB_TAILS for g in gram):
                            continue
                        content_words = [g for g in gram if g not in STOPWORDS and len(g) >= 3]
                        if not content_words:
                            continue
                        # Avoid phrases that are just two stopwords or start AND end with stopwords
                        if len(content_words) == 1 and n == 2 and (gram[0] in STOPWORDS and len(content_words[0]) < 4):
                            continue
                        if gram[0] in STOPWORDS and gram[-1] in STOPWORDS:
                            continue
                        # Avoid duplicate stutter like "gunna gunna" or "gucci gucci"
                        if len(set(gram)) == 1:
                            continue
                        phrase = " ".join(gram)
                        artist_ngrams[artist][phrase] += 1
                        global_ngrams[phrase] += 1

                end_w = extract_clean_end_word(ln)
                if not end_w or len(end_w) < 3 or end_w in STOPWORDS or end_w in ADLIB_TAILS or end_w in PHRASE_BANNED_WORDS:
                    continue
                artist_end_counts[artist][end_w] += 1
                global_end_counts[end_w] += 1
                end_rm = word_to_rime.get(end_w)
                if end_rm:
                    for prev_w, prev_rm in recent_ends[-4:]:
                        if prev_rm == end_rm and prev_w != end_w:
                            artist_rhyme_pairs[artist][prev_w][end_w] += 1
                            artist_rhyme_pairs[artist][end_w][prev_w] += 1
                    recent_ends.append((end_w, end_rm))

    total_ends = sum(global_end_counts.values()) or 1
    total_grams = sum(global_ngrams.values()) or 1

    nocap_words = artist_word_counts.get("NoCap", collections.Counter())
    gunna_words = artist_word_counts.get("Gunna", collections.Counter())

    double_meaning_lexicon: dict[str, dict] = {}
    for word, meta in CURATED_DOUBLE_MEANINGS.items():
        rm = word_to_rime.get(word)
        double_meaning_lexicon[word] = {
            "word": word,
            "rime": rm,
            "senses": meta["senses"],
            "homophones": meta["homophones"],
            "pair_triggers": meta.get("pair_triggers", []),
            "nocap_count": nocap_words[word],
            "gunna_count": gunna_words[word],
            "corpus_count": global_word_counts[word],
        }

    artists_dna: dict[str, dict] = {}
    for artist, line_count in artist_lines.most_common():
        if line_count < 100:
            continue
        end_counter = artist_end_counts[artist]
        artist_total_ends = sum(end_counter.values()) or 1

        scored_ends: list[tuple[float, str, int, str | None]] = []
        rime_to_artist_words: dict[str, list[str]] = collections.defaultdict(list)

        for w, cnt in end_counter.items():
            if cnt < 2 or len(w) < 3:
                continue
            p_artist = cnt / artist_total_ends
            p_global = (global_end_counts[w] + 5) / (total_ends + 500)
            lift = math.log2(max(0.25, p_artist / p_global))
            # Balance artist staple frequency with artist distinctiveness
            weight = (cnt ** 0.62) * (1.0 + 0.55 * max(0.0, lift))
            rm = word_to_rime.get(w)
            scored_ends.append((weight, w, cnt, rm))

        scored_ends.sort(key=lambda x: -x[0])
        top_end_words = []
        for weight, w, cnt, rm in scored_ends[:220]:
            top_end_words.append({
                "word": w,
                "count": cnt,
                "rime": rm,
                "weight": round(weight, 2),
            })
            if rm and len(rime_to_artist_words[rm]) < 14:
                rime_to_artist_words[rm].append(w)

        pairs_out: dict[str, list[str]] = {}
        for w, partner_counts in artist_rhyme_pairs[artist].items():
            best_partners = [pw for pw, pc in partner_counts.most_common(10) if pc >= 1]
            if best_partners:
                pairs_out[w] = best_partners

        gram_counter = artist_ngrams[artist]
        artist_total_grams = sum(gram_counter.values()) or 1
        scored_phrases: list[tuple[float, str, int]] = []
        artist_tokens = set(tokenize_line(artist))
        for phrase, cnt in gram_counter.items():
            if cnt < 3:
                continue
            parts = phrase.split()
            # Skip self-name tags like "young gunna" or "lil wayne" so phrases are lyrical expressions
            if any(p in artist_tokens for p in parts):
                continue
            p_a = cnt / artist_total_grams
            p_g = (global_ngrams[phrase] + 10) / (total_grams + 2000)
            lift = math.log2(max(0.1, p_a / p_g))
            if lift < 0.85:
                continue
            score = (cnt ** 0.58) * (1.0 + 0.75 * lift)
            scored_phrases.append((score, phrase, cnt))

        scored_phrases.sort(key=lambda x: -x[0])
        signature_phrases = []
        seen_leads: collections.Counter[str] = collections.Counter()
        for score, phrase, cnt in scored_phrases:
            parts = phrase.split()
            lead = parts[0]
            if lead in LEAD_STOPWORDS or lead in ADLIB_TAILS or lead in PHRASE_BANNED_WORDS or len(lead) < 3:
                continue
            if seen_leads[lead] >= 2:
                continue
            seen_leads[lead] += 1
            signature_phrases.append({
                "phrase": phrase,
                "lead": lead,
                "rest": " ".join(parts[1:]),
                "count": cnt,
                "score": round(score, 2),
            })
            if len(signature_phrases) >= 65:
                break

        # Mix artist's own usage + NoCap's double-meaning usage
        artist_double_words = []
        for dw, dmeta in double_meaning_lexicon.items():
            acnt = artist_word_counts[artist][dw]
            ncnt = nocap_words[dw]
            # Blend 55% artist's own affinity + 45% NoCap double-meaning affinity
            combined = (acnt ** 0.75) * 1.4 + (ncnt ** 0.75) * 1.2
            artist_double_words.append((combined, dw, acnt, ncnt))
        artist_double_words.sort(key=lambda x: -x[0])

        artists_dna[artist] = {
            "artist": artist,
            "train_lines": line_count,
            "top_end_words": top_end_words[:160],
            "rime_to_words": dict(rime_to_artist_words),
            "rhyme_pairs": pairs_out,
            "signature_phrases": signature_phrases,
            "double_meaning_words": [w for _, w, _, _ in artist_double_words[:50]],
        }

    payload = {
        "version": 2,
        "artists_count": len(artists_dna),
        "double_meaning_lexicon": double_meaning_lexicon,
        "artists": artists_dna,
    }
    out_path = OUT / "artist_voice_dna.json"
    out_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(f"Wrote {out_path} ({out_path.stat().st_size / (1024*1024):.2f} MB) across {len(artists_dna)} artists.")

    for name in ("Gunna", "NoCap", "Lil Wayne", "Drake"):
        if name in artists_dna:
            d = artists_dna[name]
            ends = [f"{e['word']}({e['count']})" for e in d["top_end_words"][:22]]
            phrases = [p["phrase"] for p in d["signature_phrases"][:15]]
            doubles = d["double_meaning_words"][:15]
            sample_pairs = list(d["rhyme_pairs"].items())[:6]
            print(f"\n=== {name} ({d['train_lines']} lines) ===")
            print("  Top Substantive End-Rhymes:", ", ".join(ends))
            print("  Sample Artist Rhyme Pairs:", "; ".join(f"{k} -> {v[:4]}" for k, v in sample_pairs))
            print("  Signature Phrases:", " | ".join(phrases))
            print("  Double-Meaning Mix (Artist + NoCap):", ", ".join(doubles))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
