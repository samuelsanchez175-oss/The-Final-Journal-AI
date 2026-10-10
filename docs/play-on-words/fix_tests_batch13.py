import json

new_chips_data = [
    {
        "chip": "Similac",
        "norm": "similac",
        "partners": ["baby", "semi lac"],
        "brief": "Similac is baby formula, said beside baby and semi-lack."
    },
    {
        "chip": "Steph Curry / Mercury",
        "norm": "steph curry mercury",
        "partners": ["stephen", "mer curry"],
        "brief": "Steph Curry / Mercury is the shooter and planet play, said beside Stephen and Mer-Curry."
    },
    {
        "chip": "when",
        "norm": "when",
        "partners": ["nguyen", "middle fingers"],
        "brief": "When is the spoken adverb, said beside nguyen and middle fingers."
    },
    {
        "chip": "Zach Randolph",
        "norm": "zach randolph",
        "partners": ["fifty", "zach", "ranned off"],
        "brief": "Zach Randolph is the Grizzlies forward Z-Bo, said beside fifty and Zach, I ranned off."
    },
    {
        "chip": "lady's",
        "norm": "ladys",
        "partners": ["ladys", "lay these"],
        "brief": "Lady's is the gentlewoman sense, said beside lady's and lay these."
    },
    {
        "chip": "Iron Man",
        "norm": "iron man",
        "partners": ["robert downey", "iron man"],
        "brief": "Iron Man is the Marvel superhero, said beside Robert Downey and iron, man."
    }
]

with open("The Final Journal AITests/NounBankSheetTests.swift") as f:
    tests_text = f.read()

target_words = '            "Maaly Raw",\n        ])'
assert target_words in tests_text, "Cannot find anchor in words array"
test_chips = ",\n".join(["            " + json.dumps(item["chip"]) for item in new_chips_data])
words_replacement = '            "Maaly Raw",\n' + test_chips + ',\n        ])'
tests_text = tests_text.replace(target_words, words_replacement, 1)

target_shared = '"james harden"'
assert target_shared in tests_text, "Cannot find sharedHeardAs anchor"
tests_text = tests_text.replace(target_shared, '"james harden", "similac", "iron man"', 1)

target_plays = '            "Maaly Raw": "Maaly Raw is the Philadelphia producer, said beside eyes got big and molly, raw.",\n        ]'
assert target_plays in tests_text, "Cannot find anchor in plays dict"
new_test_plays = ",\n".join(["            " + json.dumps(item["chip"]) + ": " + json.dumps(item["brief"]) for item in new_chips_data])
plays_replacement = '            "Maaly Raw": "Maaly Raw is the Philadelphia producer, said beside eyes got big and molly, raw.",\n' + new_test_plays + ',\n        ]'
tests_text = tests_text.replace(target_plays, plays_replacement, 1)

target_reused = '            ("Nike Air Max", "noun-air-max"),\n        ]'
assert target_reused in tests_text, "Cannot find anchor in reusedChips"
reused_items = [
    '("Steph Curry / Mercury", "noun-mer-curry")',
    '("Iron Man", "noun-char-iron-man")'
]
reused_str = ",\n".join(["            " + r for r in reused_items])
reused_replacement = '            ("Nike Air Max", "noun-air-max"),\n' + reused_str + ',\n        ]'
tests_text = tests_text.replace(target_reused, reused_replacement, 1)

with open("The Final Journal AITests/NounBankSheetTests.swift", "w") as f:
    f.write(tests_text)
print("NounBankSheetTests.swift updated successfully!")
