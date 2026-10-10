import json

new_chips_data = [
    {
        "chip": "Saddam",
        "norm": "saddam",
        "artist": "Meek Mill",
        "song": "Pullin Up",
        "bar": "And she's-a-dime like Hussein",
        "setupSpans": [{"text": "Hussein", "start": 22, "end": 29}],
        "playSpans": [{"text": "she's-a-dime", "start": 4, "end": 16, "heard": "Saddam"}],
        "heardAs": "Saddam",
        "geniusURL": "https://genius.com/7187941",
        "image": "noun-celeb-saddam",
        "imageDecision": "reused",
        "sourceLine": 1206,
        "partners": ["she's-a-dime", "hussein"],
        "brief": "Saddam is the Iraqi president, said beside she's-a-dime and Hussein."
    }
]

# 1. Update WordplayFlips.json
with open("XJournal AI/WordplayFlips.json") as f:
    flips = json.load(f)

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

target_store = '                "Iron Man",\n            ])'
store_chips = ",\n".join(f'                "{item["chip"]}"' for item in new_chips_data)
store_replacement = f'                "Iron Man",\n{store_chips},\n            ])'
store_text = store_text.replace(target_store, store_replacement, 1)

with open("XJournal AI/NounBankStore.swift", "w") as f:
    f.write(store_text)
print("NounBankStore.swift updated")

# 3. Update NounBankSections.swift
with open("XJournal AI/NounBankSections.swift") as f:
    sec_text = f.read()

target_sec = '                    "Iron Man",\n                ]),\n            ]'
sec_chips = ",\n".join(f'                    "{item["chip"]}"' for item in new_chips_data)
sec_replacement = f'                    "Iron Man",\n{sec_chips},\n                ]),\n            ]'
sec_text = sec_text.replace(target_sec, sec_replacement, 1)

with open("XJournal AI/NounBankSections.swift", "w") as f:
    f.write(sec_text)
print("NounBankSections.swift updated")

# 4. Update NounBankCatalog.swift
with open("XJournal AI/NounBankCatalog.swift") as f:
    cat_text = f.read()

target_part = '        "iron man": ["robert downey", "iron man"],\n    ]'
new_partners = ",\n".join(f'        "{item["norm"]}": {json.dumps(item["partners"])}' for item in new_chips_data)
part_replacement = f'        "iron man": ["robert downey", "iron man"],\n{new_partners},\n    ]'
cat_text = cat_text.replace(target_part, part_replacement, 1)

target_icons = '        "iron man": "noun-char-iron-man",\n    ]'
new_icons = ",\n".join(f'        "{item["norm"]}": "{item["image"]}"' for item in new_chips_data)
icons_replacement = f'        "iron man": "noun-char-iron-man",\n{new_icons},\n    ]'
cat_text = cat_text.replace(target_icons, icons_replacement, 1)

with open("XJournal AI/NounBankCatalog.swift", "w") as f:
    f.write(cat_text)
print("NounBankCatalog.swift updated")

# 5. Update NounMentionBrief.swift
with open("XJournal AI/NounMentionBrief.swift") as f:
    brief_text = f.read()

target_brief = '        "iron man": "Iron Man is the Marvel superhero, said beside Robert Downey and iron, man.",\n    ]'
new_briefs = ",\n".join(f'        "{item["norm"]}": "{item["brief"]}"' for item in new_chips_data)
brief_replacement = f'        "iron man": "Iron Man is the Marvel superhero, said beside Robert Downey and iron, man.",\n{new_briefs},\n    ]'
brief_text = brief_text.replace(target_brief, brief_replacement, 1)

with open("XJournal AI/NounMentionBrief.swift", "w") as f:
    f.write(brief_text)
print("NounMentionBrief.swift updated")

# 6. Update NounBankSheetTests.swift
with open("The Final Journal AITests/NounBankSheetTests.swift") as f:
    tests_text = f.read()

target_words = '            "Iron Man",\n        ])'
test_chips = ",\n".join(f'            "{item["chip"]}"' for item in new_chips_data)
words_replacement = f'            "Iron Man",\n{test_chips},\n        ])'
tests_text = tests_text.replace(target_words, words_replacement, 1)

target_shared = '"similac", "iron man"'
tests_text = tests_text.replace(target_shared, '"similac", "iron man", "saddam"', 1)

target_plays = '            "Iron Man": "Iron Man is the Marvel superhero, said beside Robert Downey and iron, man.",\n        ]'
new_test_plays = ",\n".join(f'            "{item["chip"]}": "{item["brief"]}"' for item in new_chips_data)
plays_replacement = f'            "Iron Man": "Iron Man is the Marvel superhero, said beside Robert Downey and iron, man.",\n{new_test_plays},\n        ]'
tests_text = tests_text.replace(target_plays, plays_replacement, 1)

target_reused = '            ("Iron Man", "noun-char-iron-man"),\n        ]'
reused_items = [
    '("Saddam", "noun-celeb-saddam")'
]
reused_str = ",\n".join(f'            {r}' for r in reused_items)
reused_replacement = f'            ("Iron Man", "noun-char-iron-man"),\n{reused_str},\n        ]'
tests_text = tests_text.replace(target_reused, reused_replacement, 1)

with open("The Final Journal AITests/NounBankSheetTests.swift", "w") as f:
    f.write(tests_text)
print("NounBankSheetTests.swift updated")
