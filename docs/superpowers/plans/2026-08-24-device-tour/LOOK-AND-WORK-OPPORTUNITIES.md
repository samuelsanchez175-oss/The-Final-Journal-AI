# Penwork Studios — look & work opportunities

Tour date: 2026-08-24  
Driven on: iPhone 17 simulator (iOS 27), Phase 6 build. One dark-mode home shot from Somebody’s son (physical iPhone 17 Pro).  
Screenshots: this folder.

Not captured (need a live API key or extra time): Rap Suggestions deck, audio recorder / beat fingerprint sheet, Import from Notes, empty journal, selection mode, Model Preferences, paywall.

---

## What already looks strong

- Light coral “Momentum” and dark lagoon both feel like a product, not a template.
- Journal list, Profile tabs, Analytics cards, Support sheet, and rhyme overlay on lyrics are the most finished surfaces.
- Full-word rhyme backgrounds on the editor (purple / gold / green / blue) read immediately.
- Writing partner wrap block actually shows the note’s beat (`180 BPM · F Ionian`) instead of a generic 92.

---

## P0 — users hit these in the first minute

### 1. The app still has four names
Welcome: **XJournal AI**. Release notes / shop: **The Final Journal AI**. Home-screen icon: **Penwork Studios**. Nav: **Journal**.  
Pick one product name and one writing-surface name. Until then every sheet feels like a different app.

### 2. The writing partner is buried
Home is a notes list. To wrap you: open a note → tap the tiny bottom `+` → tap sparkle.  
Header already has a `+`. Editor header has undo / redo / `+`. Bottom island has another `+`.  
**Opportunity:** one obvious “Suggest lines” control on the editor, always visible. Collapse the rest.

### 3. Metadata pills overflow on iPhone
Editor pills: `BPM · KEY · SCALE · Syllables · URL · FOLDER`.  
On a 402-pt phone you get `an (Major)` cut off. Home filters cut off `Scale` / `URL` with no scroll hint.  
**Opportunity:** show *values* (`F · Major · 92`) on one row; put URL / folder / custom syllables behind an “More” chip. Don’t all-caps the labels.

### 4. Sparkle coachmark blocks the actual tool
First sparkle tap: “add your OpenAI API key… Profile page under API Settings.” The sheet is named **AI**, not API Settings. Closing it still doesn’t teach wrap.  
**Opportunity:** if there’s no key, open Profile → AI directly. If there is a key, open Suggest next lines. No interstitial.

### 5. Welcome copy is the wrong product
“Your AI writing & journaling companion” + three bullets about voice / rhyme / Keychain. Nothing about beats, wrap, or verses.  
**Opportunity:** first screen should say you write rap to a beat, and the partner times the punch.

---

## P1 — look (layout, density, type)

### Journal home
- Search bar sits on top of the last note (physical dark shot). Needs a real bottom inset so the last row clears the bar.
- Five unlabeled header icons. Long-press or a single “More” is clearer than Analytics / Profile / What’s New / Shop / Add as peer icons.
- **Created** is a sort control dressed as a filter. Two identical “Newest First / Oldest First” blocks (Time Created vs Last Modified) in one menu.
- Folders / BPM menus: **Off** vs **All Folders** — nobody knows what Off means.
- Filter chips never show the active value. Editor chips do (`180 BPM`). Match that.

### Editor
- Timestamp `Created 8 - 24 - 2026 10:31 PM` (spaces around dashes) looks unfinished.
- Collapsed toolbar is a lone blue `+` floating under the date. Easy to miss; competes with header `+`.
- Attach menu covers the toolbar it launched from.
- Ghost menu: **Free Ghost / Live Ghost / Compare costs** is store language on a writing tool. Name the modes by what they do.
- Rhyme Groups popover is good. Phonetic keys like `AW|N-D` on the writing-partner list are not. Show the words (`sound · around`) as the title; hide CMU codes.

### Suggest next lines
- Sticky **Generate** covers the last rhyme-group row and the optional-schemes chevron.
- Wrap block is a wall: two paragraphs + three segmented controls + two toggles before you can type a topic.
- **Gunna wrap** as a toggle: if wrap is the product, default it on and move the off-switch to Optional schemes.
- Style = tiny coral **Auto ▾**. Easy to miss vs the huge wrap section.
- Tone is eight unlabeled checkboxes. A single “feel” picker would scan better.
- Rhyme-group cells are huge gray slabs for two words.

### Profile / Analytics / Shop
- Profile always lands on **AI** when no key, so **You** looks empty until you hunt for it. The coral “Connect a key” banner on You is the right pattern — use it instead of auto-switching tabs.
- **Test** on the key field is 11-pt gray, almost un-tappable.
- Avatar says “Your name” and then a Name field repeats it.
- App tab color dots have no names except LIGHT / DARK section headers.
- Analytics overview: gray achievement circles clipped by the sheet; “Most used words” is `each`, `line,` (stopwords + punctuation).
- Diagnostics **JSON** chip is clipped. Lyric Scores empty state is the best empty state in the app — reuse that voice.
- Release notes and Shop have no Done — only the grabber. Analytics does. Make every sheet have Done or a consistent grabber-only rule.

### Brand / chrome
- Light mode is peach-white; dark mode on Somebody’s son is a real lagoon. Light needs more coral in the list rows so it doesn’t feel like iOS Notes with a tinted header.
- Notifications permission fires over the journal with no setup. Ask it from Profile → App, or after the first successful generate.

---

## P1 — work (how the app behaves)

### Path to wrap
The seeded notes have rhyme but no audio. Wrap then invents a beat from whatever pill you last tapped (tour accidentally set **180 BPM / F / Ionian**).  
**Opportunity:** if the note has no audio and no BPM, ask for a beat *or* use 92 and say so in one line, not three.

### Generate is a form, not a partner
You scroll Wrap → Style → Lines → Punch content → Keyword cage → Copy rhythm → Topics → Tones → Rhyme groups, then Generate.  
Most of that should be defaults. First screen: topic + Generate. Everything else under “Tune this pass.”

### Icon-only island
Paperclip / sparkle / eye / magnifier / ghost / keyboard have accessibility labels but nothing on-screen. First-run coachmarks are sheets, not tooltips on the icons.  
**Opportunity:** one-time caption under the island (“Suggest · Rhymes · Ghost”) or a long-press that names the button.

### Home vs editor mental model
Home still thinks “journal entry.” Rows could show BPM / key when present (physical device already does: `60 · G# Major`). Sim seeds don’t. Always show beat chips on rows that have them; show a quiet “no beat” on rows that don’t.

### Can’t try Model G on a fresh sim
No key → sparkle → Profile. There’s no demo / offline wrap-read of the current verse.  
**Opportunity:** overlay + wrap-read should work on the user’s own bars with zero API key. Generation is what needs the key.

---

## P2 — later / polish

- Unify version numbers (Welcome vs Profile `3 (1)` vs release notes `1.5.0`).
- “Signal Layer Advanced Mode” belongs in a debug / diagnostics screen, not Profile → App.
- “Flatten editor buttons” is a design-debug toggle. Don’t ship it next to Notifications.
- Export Data still prints a TODO.
- Share Invite Link on a local journal is unclear.
- Achievements (Getting Started, Century Club, Novel Writer) are prose-journal trophies. Re-theme around verses, wrap, and bars.
- Search mic: focus didn’t bring up the keyboard in the tour — verify dictation vs software keyboard.
- Plus-menu “New Note (Record Audio)” vs editor attach “Record Audio” — one recording entry point.
- Scale menu lists both **Major** and **Ionian (Major)**. Pick one naming scheme.

---

## Suggested edit batches (when we start)

1. **Name + first run** — one product name, welcome copy about wrap, no sparkle interstitial.
2. **Editor chrome** — one Suggest button, pills that show values and don’t overflow, timestamp format, fewer + buttons.
3. **Writing partner** — first screen is topic + Generate; wrap defaults on; Generate doesn’t cover content; rhyme groups titled by words.
4. **Home filters** — sort vs filter, visible scroll, values on chips, search inset.
5. **Profile / Analytics copy** — You tab as default with a key banner, tappable Test, stopword-free word cloud, Done on every sheet.
