# Editor wrap surfaces — implementation plan

> **For agentic workers:** Inline execution. Samuel OK’d A–H on 2026-08-24 (“do all and build app”).

**Goal:** Ship the approved in-app surfaces: overlay default on, play attached beat, BarClock strip, syllable gutter, tap-to-rhyme, same-pocket spark, honest 429 copy, Suggest Advanced, sparkle always on the island.

**Architecture:** Logic in small types (`BarClock` beat math, `LineSyllableCounter`, error copy, `DirectedGenerationParams.samePocketNewNouns`). UI wires those into `NoteEditorView` / `DynamicIslandToolbarView`. Suggest Advanced already lives in `ModelGControlSurfaceView`.

**Tech Stack:** SwiftUI, AVAudioPlayer, existing `RhymeFinder` / `Syllabifier` / `PlaybackAudioSession`.

## Global Constraints

- No AVAudioSession.setActive on main.
- User-facing copy: plain words, sentence-case hints (clear-ui-labels).
- Overlay default follows `defaultRhymeOverlayVisible` (default **on**).
- 429 is not an API-key failure. Destination `.none` or Retry, never Profile AI.
