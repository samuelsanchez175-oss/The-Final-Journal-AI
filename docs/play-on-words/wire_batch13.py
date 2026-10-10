import json

new_chips_data = [
    {
        "chip": "Similac",
        "norm": "similac",
        "artist": "NoCap",
        "song": "Drown In My Styrofoam",
        "bar": "My mama's baby, I keep a gun, I don't even semi-lack",
        "setupSpans": [{"text": "mama's baby", "start": 3, "end": 14}],
        "playSpans": [{"text": "semi-lack", "start": 43, "end": 52, "heard": "Similac"}],
        "heardAs": "Similac",
        "geniusURL": "https://genius.com/22172113",
        "image": "noun-food-similac",
        "imageDecision": "created",
        "sourceLine": 1200,
        "partners": ["baby", "semi lac"],
        "brief": "Similac is baby formula, said beside baby and semi-lack."
    },
    {
        "chip": "Steph Curry / Mercury",
        "norm": "steph curry mercury",
        "artist": "NoCap",
        "song": "By Tonight",
        "bar": "I’ll never kill Stephen, I’m higher than Mer-Curry",
        "setupSpans": [{"text": "Stephen", "start": 16, "end": 23}],
        "playSpans": [{"text": "Mer-Curry", "start": 41, "end": 50, "heard": "Mercury / Curry"}],
        "heardAs": "Steph Curry / Mercury",
        "geniusURL": "https://genius.com/21787649",
        "image": "noun-mer-curry",
        "imageDecision": "reused",
        "sourceLine": 1201,
        "partners": ["stephen", "mer curry"],
        "brief": "Steph Curry / Mercury is the shooter and planet play, said beside Stephen and Mer-Curry."
    },
    {
        "chip": "when",
        "norm": "when",
        "artist": "NoCap",
        "song": "By Tonight",
        "bar": "She shoot me middle fingers, I say nguyen like I'm Vietnamese",
        "setupSpans": [{"text": "Vietnamese", "start": 51, "end": 61}],
        "playSpans": [{"text": "nguyen", "start": 35, "end": 41, "heard": "when"}],
        "heardAs": "when",
        "geniusURL": "https://genius.com/20518156",
        "image": "noun-phrase-when",
        "imageDecision": "created",
        "sourceLine": 1202,
        "partners": ["nguyen", "middle fingers"],
        "brief": "When is the spoken adverb, said beside nguyen and middle fingers."
    },
    {
        "chip": "Zach Randolph",
        "norm": "zach randolph",
        "artist": "NoCap",
        "song": "Blind Nights",
        "bar": "My plug fronted me fifty like Zach, I ranned off",
        "setupSpans": [{"text": "fifty like Zach", "start": 19, "end": 34}],
        "playSpans": [{"text": "ranned off", "start": 38, "end": 48, "heard": "Randolph"}],
        "heardAs": "Zach Randolph",
        "geniusURL": "https://genius.com/17355949",
        "image": "noun-nba-zach-randolph",
        "imageDecision": "created",
        "sourceLine": 1203,
        "partners": ["fifty", "zach", "ranned off"],
        "brief": "Zach Randolph is the Grizzlies forward Z-Bo, said beside fifty and Zach, I ranned off."
    },
    {
        "chip": "lady's",
        "norm": "ladys",
        "artist": "Cardi B",
        "song": "I Do",
        "bar": "Only time that I'm a lady's when I lay these hoes to rest (Brrt)",
        "setupSpans": [{"text": "lady's", "start": 21, "end": 27}],
        "playSpans": [{"text": "lay these", "start": 35, "end": 44, "heard": "lady's"}],
        "heardAs": "lady's",
        "geniusURL": "https://genius.com/30543561",
        "image": "noun-phrase-ladys",
        "imageDecision": "created",
        "sourceLine": 1204,
        "partners": ["ladys", "lay these"],
        "brief": "Lady's is the gentlewoman sense, said beside lady's and lay these."
    },
    {
        "chip": "Iron Man",
        "norm": "iron man",
        "artist": "Gunna",
        "song": "Still Ain’t Finished",
        "bar": "Keep the iron, man, they could call me Robert Downey (Robert Downey)",
        "setupSpans": [{"text": "Robert Downey", "start": 39, "end": 52}],
        "playSpans": [{"text": "iron, man", "start": 9, "end": 18, "heard": "Iron Man"}],
        "heardAs": "Iron Man",
        "geniusURL": "https://genius.com/25494024",
        "image": "noun-char-iron-man",
        "imageDecision": "reused",
        "sourceLine": 1205,
        "partners": ["robert downey", "iron man"],
        "brief": "Iron Man is the Marvel superhero, said beside Robert Downey and iron, man."
    }
]

# 1. Update WordplayFlips.json
with open("XJournal AI/WordplayFlips.json") as f:
    flips = json.load(f)

# Ensure no duplicate entries for these 6
existing_chips = set(f.get("chip") for f in flips)
for item in new_chips_data:
    if item["chip"] not in existing_chips:
        flips.append({
            "chip": item["chip"],
            "artist": item["artist"],
            "song": item["song"],
            "bar": item["bar"],
            "setupSpans": item["setupSpans"],
            "playSpans": item["playSpans"],
            "heardAs": item["heardAs"],
            "geniusURL": item["geniusURL"],
            "image": item["image"],
            "imageDecision": item["imageDecision"],
            "sourceLine": item["sourceLine"]
        })

with open("XJournal AI/WordplayFlips.json", "w") as f:
    json.dump(flips, f, indent=4)
print(f"WordplayFlips.json updated to {len(flips)} entries")

# 2. Update NounBankStore.swift
with open("XJournal AI/NounBankStore.swift") as f:
    store_text = f.read()

target_store = '                "Maaly Raw",\n            ])'
assert target_store in store_text, "Cannot find anchor in NounBankStore"
store_chips = ",\n".join(f'                "{item["chip"]}"' for item in new_chips_data)
store_replacement = f'                "Maaly Raw",\n{store_chips},\n            ])'
store_text = store_text.replace(target_store, store_replacement, 1)

with open("XJournal AI/NounBankStore.swift", "w") as f:
    f.write(store_text)
print("NounBankStore.swift updated")

# 3. Update NounBankSections.swift
with open("XJournal AI/NounBankSections.swift") as f:
    sec_text = f.read()

target_sec = '                    "Maaly Raw",\n                ]),\n            ]'
assert target_sec in sec_text, "Cannot find anchor in NounBankSections"
sec_chips = ",\n".join(f'                    "{item["chip"]}"' for item in new_chips_data)
sec_replacement = f'                    "Maaly Raw",\n{sec_chips},\n                ]),\n            ]'
sec_text = sec_text.replace(target_sec, sec_replacement, 1)

with open("XJournal AI/NounBankSections.swift", "w") as f:
    f.write(sec_text)
print("NounBankSections.swift updated")

# 4. Update NounBankCatalog.swift
with open("XJournal AI/NounBankCatalog.swift") as f:
    cat_text = f.read()

target_part = '        "maaly raw": ["molly", "raw"],\n    ]'
assert target_part in cat_text, "Cannot find anchor in mentionPartnerTable"
new_partners = ",\n".join(f'        "{item["norm"]}": {json.dumps(item["partners"])}' for item in new_chips_data)
part_replacement = f'        "maaly raw": ["molly", "raw"],\n{new_partners},\n    ]'
cat_text = cat_text.replace(target_part, part_replacement, 1)

target_icons = '        "maaly raw": "noun-artist-maaly-raw",\n    ]'
assert target_icons in cat_text, "Cannot find anchor in wordplayPictureIcons"
new_icons = ",\n".join(f'        "{item["norm"]}": "{item["image"]}"' for item in new_chips_data)
icons_replacement = f'        "maaly raw": "noun-artist-maaly-raw",\n{new_icons},\n    ]'
cat_text = cat_text.replace(target_icons, icons_replacement, 1)

with open("XJournal AI/NounBankCatalog.swift", "w") as f:
    f.write(cat_text)
print("NounBankCatalog.swift updated")

# 5. Update NounMentionBrief.swift
with open("XJournal AI/NounMentionBrief.swift") as f:
    brief_text = f.read()

target_brief = '        "maaly raw": "Maaly Raw is the Philadelphia producer, said beside eyes got big and molly, raw.",\n    ]'
assert target_brief in brief_text, "Cannot find anchor in NounMentionBrief"
new_briefs = ",\n".join(f'        "{item["norm"]}": "{item["brief"]}"' for item in new_chips_data)
brief_replacement = f'        "maaly raw": "Maaly Raw is the Philadelphia producer, said beside eyes got big and molly, raw.",\n{new_briefs},\n    ]'
brief_text = brief_text.replace(target_brief, brief_replacement, 1)

with open("XJournal AI/NounMentionBrief.swift", "w") as f:
    f.write(brief_text)
print("NounMentionBrief.swift updated")

# 6. Update NounBankSheetTests.swift
with open("The Final Journal AITests/NounBankSheetTests.swift") as f:
    tests_text = f.read()

target_words = '            "Maaly Raw",\n        ])'
assert target_words in tests_text, "Cannot find anchor in words array"
test_chips = ",\n".join(f'            "{item["chip"]}"' for item in new_chips_data)
words_replacement = f'            "Maaly Raw",\n{test_chips},\n        ])'
tests_text = tests_text.replace(target_words, words_replacement, 1)

target_shared = '"james harden"'
assert target_shared in tests_text, "Cannot find sharedHeardAs anchor"
tests_text = tests_text.replace(target_shared, '"james harden", "similac", "iron man"', 1)

target_plays = '            "Maaly Raw": "Maaly Raw is the Philadelphia producer, said beside eyes got big and molly, raw.",\n        ]'
assert target_plays in tests_text, "Cannot find anchor in plays dict"
new_test_plays = ",\n".join(f'            "{item["chip"]}": "{item["brief"]}"' for item in new_chips_data)
plays_replacement = f'            "Maaly Raw": "Maaly Raw is the Philadelphia producer, said beside eyes got big and molly, raw.",\n{new_test_plays},\n        ]'
tests_text = tests_text.replace(target_plays, plays_replacement, 1)

target_reused = '            ("Maaly Raw", "noun-artist-maaly-raw"),\n        ]'
assert target_reused in tests_text, "Cannot find anchor in reusedChips"
reused_items = [
    '("Steph Curry / Mercury", "noun-mer-curry")',
    '("Iron Man", "noun-char-iron-man")'
]
reused_str = ",\n".join(f'            {r}' for r in reused_items)
reused_replacement = f'            ("Maaly Raw", "noun-artist-maaly-raw"),\n{reused_str},\n        ]'
tests_text = tests_text.replace(target_reused, reused_replacement, 1)

with open("The Final Journal AITests/NounBankSheetTests.swift", "w") as f:
    f.write(tests_text)
print("NounBankSheetTests.swift updated")

