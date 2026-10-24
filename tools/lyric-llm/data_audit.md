# Lyrics data audit

Read-only. No row was changed, deleted, or rewritten.

- File: `/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/XJournal AI/ground_truth_rap_bars_MODEL_G.csv`
- Audited: 2026-10-17 00:32 UTC
- Random sample seed: 20261016

## What the counts mean

- A line is one CSV data row. One header-echo row (`artist` / `song` copied from the column names) is counted separately and left out of the artist, song, BPM, and duplicate totals.
- A song is one `artist` + `song` pair, as stored, including rows whose lyric text is empty.
- BPM and scale are not columns in this CSV. Missing means the Sparkler tempo cache has no joined value for that artist and song title. Cache: `/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/style-profile/out/tempo_cache.jsonl`.
- An exact duplicate is the same `text_bar_line` string, character for character, seen more than once. Empty text is not part of this count.
- A near-duplicate group is one loose key (lowercase, punctuation and parentheticals removed, trailing yeah/uh/yo dropped) that covers two or more different raw strings. Exact copies of one string are not counted again here.
- Simhash near-duplicates are a second pass: different loose keys whose 64-bit fingerprint is within Hamming distance 3. Each band keeps only the last 32 fingerprints, so this count can miss pairs in a very crowded bucket.

## Encoding

- File size: 557,750,828 bytes
- UTF-8: valid UTF-8
- BOM: no
- Null bytes: 0
- CRLF pairs: 1,793,547
- Bare CR: 2
- Rows with U+FFFD replacement character in artist, song, or text: 2
- Rows with a non-ASCII character in artist, song, or text: 226,467
- Rows whose lyric text contains a control character other than tab or newline: 0
- No tracked mojibake sequences (`â€™`, `â€œ`, `Ã©`, `Ã¨`, `Ã±`, `Â `) in lyric text.

## Totals

- CSV data rows read: 1,793,548
- Header-echo rows: 1
- Lines in the totals below: 1,793,547
- Empty lyric text: 1 (0.00%)
- Non-empty lyric text: 1,793,546
- Songs (`artist` + `song`): 42,647
- Artists: 785
- Lines too short for the near-duplicate key (under 4 tokens after cleanup of the comparison key only): 79,559

## Lines per artist

Smallest line count is 4. 2 artists sit on that count. Bottom 20 is the alphabetical slice of that tie when the counts match.

### Top 20

| Artist | Lines | Share |
| --- | ---: | ---: |
| Lil Wayne | 123,974 | 6.91% |
| Quality Control | 73,223 | 4.08% |
| Lil Uzi Vert | 72,908 | 4.07% |
| Rick Ross | 66,349 | 3.70% |
| Juice WRLD | 63,560 | 3.54% |
| JAY-Z | 55,210 | 3.08% |
| Drake | 54,931 | 3.06% |
| Lil Yachty | 54,591 | 3.04% |
| YoungBoy Never Broke Again | 52,125 | 2.91% |
| Ty Dolla $ign | 48,078 | 2.68% |
| Tory Lanez | 46,573 | 2.60% |
| Meek Mill | 45,900 | 2.56% |
| Chief Keef | 38,537 | 2.15% |
| Yeat | 36,617 | 2.04% |
| Yo Gotti | 36,581 | 2.04% |
| J. Cole | 35,898 | 2.00% |
| Trippie Redd | 33,720 | 1.88% |
| Gunna | 32,492 | 1.81% |
| Future | 31,900 | 1.78% |
| Big Sean | 31,218 | 1.74% |

### Bottom 20

| Artist | Lines | Share |
| --- | ---: | ---: |
| Eminem | 4 | 0.0002% |
| Jam (POL) | 4 | 0.0002% |
| Cae Cartier | 5 | 0.0003% |
| Behind The Frames | 6 | 0.0003% |
| DannyTheHydrant | 6 | 0.0003% |
| Tyler, The Creator | 6 | 0.0003% |
| Bouba Savage | 7 | 0.0004% |
| Duvy | 7 | 0.0004% |
| Chaboki | 8 | 0.0004% |
| Cordae | 8 | 0.0004% |
| ISOxo | 8 | 0.0004% |
| Smileyface | 8 | 0.0004% |
| FILI & DERBY | 9 | 0.0005% |
| MAKJ | 9 | 0.0005% |
| Susie Anne | 9 | 0.0005% |
| Choo Choo | 11 | 0.0006% |
| Lil Lani | 11 | 0.0006% |
| ROSALÍA | 11 | 0.0006% |
| YBK Quan | 11 | 0.0006% |
| Bret “Epic” Mazur | 12 | 0.0007% |

## BPM and scale

- Lines missing BPM: 961,984 (53.64%)
- Lines with BPM: 831,563 (46.36%)
- Lines missing scale: 1,043,986 (58.21%)
- Lines with scale: 749,561 (41.79%)

## Duplicates

- Exact-duplicate groups: 158,806
- Extra copies beyond the first of each exact string: 184,813
- Near-duplicate groups (same loose key, different raw text): 16,132
- Extra raw forms inside those groups: 19,687
- Rows sitting in those near-duplicate groups: 43,334
- Additional loose keys within simhash distance 3 of an earlier key: 17,258
- Rows on those simhash keys: 20,928

## Ten random entries, as stored

Each block is the CSV record after parsing. Column order matches the file. Seed 20261016.

Columns: `REAL LYRICS 2026 NEW JAN 24`, `artist`, `song`, `album`, `section_type`, `repeat_count`, `text_bar_line`, `rhyme_word`, `rhyme_suggestions`, `rhyme_class`, `flow_vector`, `primary_tone`, `secondary_tone`, `section_weight`, `avg_rhyme_density`, `year`, `syllable_count`, `context`, `phonetic_ending`, `phonetic_rhyme_class`, `phonetic_syllables`, `phonetic_stress_pattern`, `AuthorityClass`, `PriorityWeight`, `LeadAuthorityClass`, `LeadPriorityWeight`, `SupportingAuthorityClasses`, `bar_index`, `bar_group_2`, `bar_group_4`, `syllable_count_recalc`, `stress_pattern`, `stress_density`, `phonetic_system`, `rhyme_density`, `average_syllables`, `average_stress_density`

### Sample 1

Data row 240,169.

```json
{
  "REAL LYRICS 2026 NEW JAN 24": "rob49.additup.19",
  "artist": "Rob49",
  "song": "Add It Up",
  "album": "Unknown",
  "section_type": "unknown",
  "repeat_count": "1",
  "text_bar_line": "I got too much shit I care about, go to jail about, I'll bail out (Huh)",
  "rhyme_word": "out",
  "rhyme_suggestions": "could be|would be|might be|gon be|gotta be|loosely",
  "rhyme_class": "out",
  "flow_vector": "",
  "primary_tone": "luxurious",
  "secondary_tone": "aspirational",
  "section_weight": "1.0",
  "avg_rhyme_density": "0.0",
  "year": "",
  "syllable_count": "18",
  "context": "line_level",
  "phonetic_ending": "",
  "phonetic_rhyme_class": "",
  "phonetic_syllables": "",
  "phonetic_stress_pattern": "",
  "AuthorityClass": "LIFESTYLE_BACKGROUND",
  "PriorityWeight": "0.3",
  "LeadAuthorityClass": "LIFESTYLE_BACKGROUND",
  "LeadPriorityWeight": "0.3",
  "SupportingAuthorityClasses": "",
  "bar_index": "19",
  "bar_group_2": "10",
  "bar_group_4": "5",
  "syllable_count_recalc": "18",
  "stress_pattern": "",
  "stress_density": "",
  "phonetic_system": "CMUdict",
  "rhyme_density": "0.0",
  "average_syllables": "18",
  "average_stress_density": "0.0"
}
```

### Sample 2

Data row 534,320.

```json
{
  "REAL LYRICS 2026 NEW JAN 24": "chancetherapper.backtothego.49",
  "artist": "Chance the Rapper",
  "song": "Back To The Go",
  "album": "Unknown",
  "section_type": "unknown",
  "repeat_count": "1",
  "text_bar_line": "I been eating vegetables, more broccoli, celery",
  "rhyme_word": "celery",
  "rhyme_suggestions": "could be|would be|might be|gon be|gotta be|loosely",
  "rhyme_class": "ery",
  "flow_vector": "",
  "primary_tone": "luxurious",
  "secondary_tone": "aspirational",
  "section_weight": "1.0",
  "avg_rhyme_density": "0.0",
  "year": "",
  "syllable_count": "15",
  "context": "line_level",
  "phonetic_ending": "",
  "phonetic_rhyme_class": "",
  "phonetic_syllables": "",
  "phonetic_stress_pattern": "",
  "AuthorityClass": "LIFESTYLE_BACKGROUND",
  "PriorityWeight": "0.3",
  "LeadAuthorityClass": "LIFESTYLE_BACKGROUND",
  "LeadPriorityWeight": "0.3",
  "SupportingAuthorityClasses": "",
  "bar_index": "49",
  "bar_group_2": "25",
  "bar_group_4": "13",
  "syllable_count_recalc": "15",
  "stress_pattern": "",
  "stress_density": "",
  "phonetic_system": "CMUdict",
  "rhyme_density": "0.0",
  "average_syllables": "15",
  "average_stress_density": "0.0"
}
```

### Sample 3

Data row 1,500,177.

```json
{
  "REAL LYRICS 2026 NEW JAN 24": "meekmill.lilsnupefreestylesinthestudiowithmeekmil.51",
  "artist": "Meek Mill",
  "song": "Lil Snupe Freestyles In The Studio With Meek Mill & French Montana",
  "album": "Unknown",
  "section_type": "unknown",
  "repeat_count": "1",
  "text_bar_line": "We smoking no mini sticks, we smoking big wands",
  "rhyme_word": "wands",
  "rhyme_suggestions": "could be|would be|might be|gon be|gotta be|loosely",
  "rhyme_class": "nds",
  "flow_vector": "",
  "primary_tone": "luxurious",
  "secondary_tone": "aspirational",
  "section_weight": "1.0",
  "avg_rhyme_density": "0.0",
  "year": "",
  "syllable_count": "12",
  "context": "line_level",
  "phonetic_ending": "",
  "phonetic_rhyme_class": "",
  "phonetic_syllables": "",
  "phonetic_stress_pattern": "",
  "AuthorityClass": "LIFESTYLE_BACKGROUND",
  "PriorityWeight": "0.3",
  "LeadAuthorityClass": "LIFESTYLE_BACKGROUND",
  "LeadPriorityWeight": "0.3",
  "SupportingAuthorityClasses": "",
  "bar_index": "51",
  "bar_group_2": "26",
  "bar_group_4": "13",
  "syllable_count_recalc": "12",
  "stress_pattern": "",
  "stress_density": "",
  "phonetic_system": "CMUdict",
  "rhyme_density": "0.0",
  "average_syllables": "12",
  "average_stress_density": "0.0"
}
```

### Sample 4

Data row 829,624.

```json
{
  "REAL LYRICS 2026 NEW JAN 24": "juicewrld.soldierfullsessionedit.204",
  "artist": "Juice WRLD",
  "song": "Soldier (Full Session Edit)",
  "album": "Unknown",
  "section_type": "unknown",
  "repeat_count": "1",
  "text_bar_line": "Maybe I'll be thinking smarter",
  "rhyme_word": "smarter",
  "rhyme_suggestions": "could be|would be|might be|gon be|gotta be|loosely",
  "rhyme_class": "ter",
  "flow_vector": "",
  "primary_tone": "luxurious",
  "secondary_tone": "aspirational",
  "section_weight": "1.0",
  "avg_rhyme_density": "0.0",
  "year": "",
  "syllable_count": "7",
  "context": "line_level",
  "phonetic_ending": "",
  "phonetic_rhyme_class": "",
  "phonetic_syllables": "",
  "phonetic_stress_pattern": "",
  "AuthorityClass": "LIFESTYLE_BACKGROUND",
  "PriorityWeight": "0.3",
  "LeadAuthorityClass": "LIFESTYLE_BACKGROUND",
  "LeadPriorityWeight": "0.3",
  "SupportingAuthorityClasses": "",
  "bar_index": "204",
  "bar_group_2": "102",
  "bar_group_4": "51",
  "syllable_count_recalc": "7",
  "stress_pattern": "",
  "stress_density": "",
  "phonetic_system": "CMUdict",
  "rhyme_density": "0.0",
  "average_syllables": "7",
  "average_stress_density": "0.0"
}
```

### Sample 5

Data row 859,355.

```json
{
  "REAL LYRICS 2026 NEW JAN 24": "drake.iddoanythingtomakeyousmile.29",
  "artist": "Drake",
  "song": "I’d Do Anything to Make You Smile",
  "album": "Unknown",
  "section_type": "unknown",
  "repeat_count": "1",
  "text_bar_line": "Hotels five star like they play for Coach Cal",
  "rhyme_word": "cal",
  "rhyme_suggestions": "could be|would be|might be|gon be|gotta be|loosely",
  "rhyme_class": "cal",
  "flow_vector": "",
  "primary_tone": "luxurious",
  "secondary_tone": "aspirational",
  "section_weight": "1.0",
  "avg_rhyme_density": "0.0",
  "year": "",
  "syllable_count": "10",
  "context": "line_level",
  "phonetic_ending": "",
  "phonetic_rhyme_class": "",
  "phonetic_syllables": "",
  "phonetic_stress_pattern": "",
  "AuthorityClass": "LIFESTYLE_BACKGROUND",
  "PriorityWeight": "0.3",
  "LeadAuthorityClass": "LIFESTYLE_BACKGROUND",
  "LeadPriorityWeight": "0.3",
  "SupportingAuthorityClasses": "",
  "bar_index": "29",
  "bar_group_2": "15",
  "bar_group_4": "8",
  "syllable_count_recalc": "10",
  "stress_pattern": "",
  "stress_density": "",
  "phonetic_system": "CMUdict",
  "rhyme_density": "0.0",
  "average_syllables": "10",
  "average_stress_density": "0.0"
}
```

### Sample 6

Data row 791,159.

```json
{
  "REAL LYRICS 2026 NEW JAN 24": "juicewrld.hennessy.26",
  "artist": "Juice WRLD",
  "song": "Hennessy",
  "album": "Unknown",
  "section_type": "unknown",
  "repeat_count": "1",
  "text_bar_line": "She said that she need us, she really need Jesus",
  "rhyme_word": "jesus",
  "rhyme_suggestions": "could be|would be|might be|gon be|gotta be|loosely",
  "rhyme_class": "sus",
  "flow_vector": "",
  "primary_tone": "luxurious",
  "secondary_tone": "aspirational",
  "section_weight": "1.0",
  "avg_rhyme_density": "0.0",
  "year": "",
  "syllable_count": "12",
  "context": "line_level",
  "phonetic_ending": "",
  "phonetic_rhyme_class": "",
  "phonetic_syllables": "",
  "phonetic_stress_pattern": "",
  "AuthorityClass": "LIFESTYLE_BACKGROUND",
  "PriorityWeight": "0.3",
  "LeadAuthorityClass": "LIFESTYLE_BACKGROUND",
  "LeadPriorityWeight": "0.3",
  "SupportingAuthorityClasses": "",
  "bar_index": "26",
  "bar_group_2": "13",
  "bar_group_4": "7",
  "syllable_count_recalc": "12",
  "stress_pattern": "",
  "stress_density": "",
  "phonetic_system": "CMUdict",
  "rhyme_density": "0.0",
  "average_syllables": "12",
  "average_stress_density": "0.0"
}
```

### Sample 7

Data row 1,547,159.

```json
{
  "REAL LYRICS 2026 NEW JAN 24": "rickross.warready.46",
  "artist": "Rick Ross",
  "song": "War Ready",
  "album": "Unknown",
  "section_type": "unknown",
  "repeat_count": "1",
  "text_bar_line": "Damn right, fuck around, clear my safe out",
  "rhyme_word": "out",
  "rhyme_suggestions": "could be|would be|might be|gon be|gotta be|loosely",
  "rhyme_class": "out",
  "flow_vector": "",
  "primary_tone": "luxurious",
  "secondary_tone": "aspirational",
  "section_weight": "1.0",
  "avg_rhyme_density": "0.0",
  "year": "",
  "syllable_count": "9",
  "context": "line_level",
  "phonetic_ending": "",
  "phonetic_rhyme_class": "",
  "phonetic_syllables": "",
  "phonetic_stress_pattern": "",
  "AuthorityClass": "LIFESTYLE_BACKGROUND",
  "PriorityWeight": "0.3",
  "LeadAuthorityClass": "LIFESTYLE_BACKGROUND",
  "LeadPriorityWeight": "0.3",
  "SupportingAuthorityClasses": "",
  "bar_index": "46",
  "bar_group_2": "23",
  "bar_group_4": "12",
  "syllable_count_recalc": "9",
  "stress_pattern": "",
  "stress_density": "",
  "phonetic_system": "CMUdict",
  "rhyme_density": "0.0",
  "average_syllables": "9",
  "average_stress_density": "0.0"
}
```

### Sample 8

Data row 1,430,352.

```json
{
  "REAL LYRICS 2026 NEW JAN 24": "travisscott.guidance.27",
  "artist": "Travis Scott",
  "song": "guidance",
  "album": "Unknown",
  "section_type": "unknown",
  "repeat_count": "1",
  "text_bar_line": "You need some guidance, you stay wildin'",
  "rhyme_word": "wildin'",
  "rhyme_suggestions": "could be|would be|might be|gon be|gotta be|loosely",
  "rhyme_class": "in'",
  "flow_vector": "",
  "primary_tone": "luxurious",
  "secondary_tone": "aspirational",
  "section_weight": "1.0",
  "avg_rhyme_density": "0.0",
  "year": "",
  "syllable_count": "9",
  "context": "line_level",
  "phonetic_ending": "",
  "phonetic_rhyme_class": "",
  "phonetic_syllables": "",
  "phonetic_stress_pattern": "",
  "AuthorityClass": "LIFESTYLE_BACKGROUND",
  "PriorityWeight": "0.3",
  "LeadAuthorityClass": "LIFESTYLE_BACKGROUND",
  "LeadPriorityWeight": "0.3",
  "SupportingAuthorityClasses": "",
  "bar_index": "27",
  "bar_group_2": "14",
  "bar_group_4": "7",
  "syllable_count_recalc": "9",
  "stress_pattern": "",
  "stress_density": "",
  "phonetic_system": "CMUdict",
  "rhyme_density": "0.0",
  "average_syllables": "9",
  "average_stress_density": "0.0"
}
```

### Sample 9

Data row 1,718,200.

```json
{
  "REAL LYRICS 2026 NEW JAN 24": "blacyoungsta.dissme.6",
  "artist": "Blac Youngsta",
  "song": "Diss Me",
  "album": "Unknown",
  "section_type": "unknown",
  "repeat_count": "1",
  "text_bar_line": "Next rap nigga take a shot or diss me",
  "rhyme_word": "me",
  "rhyme_suggestions": "could be|would be|might be|gon be|gotta be|loosely",
  "rhyme_class": "me",
  "flow_vector": "",
  "primary_tone": "luxurious",
  "secondary_tone": "aspirational",
  "section_weight": "1.0",
  "avg_rhyme_density": "0.0",
  "year": "",
  "syllable_count": "10",
  "context": "line_level",
  "phonetic_ending": "",
  "phonetic_rhyme_class": "",
  "phonetic_syllables": "",
  "phonetic_stress_pattern": "",
  "AuthorityClass": "LIFESTYLE_BACKGROUND",
  "PriorityWeight": "0.3",
  "LeadAuthorityClass": "LIFESTYLE_BACKGROUND",
  "LeadPriorityWeight": "0.3",
  "SupportingAuthorityClasses": "",
  "bar_index": "6",
  "bar_group_2": "3",
  "bar_group_4": "2",
  "syllable_count_recalc": "10",
  "stress_pattern": "",
  "stress_density": "",
  "phonetic_system": "CMUdict",
  "rhyme_density": "0.0",
  "average_syllables": "10",
  "average_stress_density": "0.0"
}
```

### Sample 10

Data row 1,033,286.

```json
{
  "REAL LYRICS 2026 NEW JAN 24": "lilwayne.studio.8",
  "artist": "Lil Wayne",
  "song": "Studio",
  "album": "Unknown",
  "section_type": "unknown",
  "repeat_count": "1",
  "text_bar_line": "Let Me Finish This Song",
  "rhyme_word": "song",
  "rhyme_suggestions": "could be|would be|might be|gon be|gotta be|loosely",
  "rhyme_class": "ong",
  "flow_vector": "",
  "primary_tone": "luxurious",
  "secondary_tone": "aspirational",
  "section_weight": "1.0",
  "avg_rhyme_density": "0.0",
  "year": "",
  "syllable_count": "6",
  "context": "line_level",
  "phonetic_ending": "",
  "phonetic_rhyme_class": "",
  "phonetic_syllables": "",
  "phonetic_stress_pattern": "",
  "AuthorityClass": "LIFESTYLE_BACKGROUND",
  "PriorityWeight": "0.3",
  "LeadAuthorityClass": "LIFESTYLE_BACKGROUND",
  "LeadPriorityWeight": "0.3",
  "SupportingAuthorityClasses": "",
  "bar_index": "8",
  "bar_group_2": "4",
  "bar_group_4": "2",
  "syllable_count_recalc": "6",
  "stress_pattern": "",
  "stress_density": "",
  "phonetic_system": "CMUdict",
  "rhyme_density": "0.0",
  "average_syllables": "6",
  "average_stress_density": "0.0"
}
```

