# Momentum Reskin — P0 Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the Momentum design-system foundation — the tokens, typography, and signature primitives (line work, square buttons, selection toggle, circle graphic, flat surface) — so every later phase reskins screens by *composing* this kit. No screen changes in P0.

**Architecture:** Additive only. A `MomentumTheme.swift` foundation **already exists** on branch `ui-momentum-reskin` (tokens, `Color(hex:)`, `AtmosphereBackground` glow, `MomentumFilterPill`, `ThemeMode`). This plan *extends* that file with the missing tokens/typography and adds three small component files. Nothing existing is removed; no app screen imports these yet, so the app is unchanged and shippable after every task. Verification = unit test for tokens + `xcodebuild build` + SwiftUI `#Preview` screenshots.

**Tech stack:** SwiftUI, iOS, Xcode. Project `The Final Journal AI.xcodeproj`, scheme `The Final Journal AI` (module `The_Final_Journal_AI`). Test target `The Final Journal AITests` (XCTest). Note: a second project `XJournal AI.xcodeproj` (scheme `XJournal AI`) shares the same source folder — **new files must be added to BOTH app targets** (see Setup).

---

## Reference values (from the mockups — use these exact numbers)

| Element | Value |
|---|---|
| section-title | 12px, weight 700, UPPERCASE, letter-spacing 1.5, color `textSecondary`; trailing thin rule at 0.2 opacity |
| main divider | height **3px** (`lineThick`), `textMain` (reset screen uses 0.2 opacity) |
| primary button | full-width, padding 20, `inverseSurface` bg, `onInverse` text, **square**, press-scale 0.98 |
| secondary button | transparent, `lineThin` border `textMain`, square |
| selection toggle | square 44pt, `lineThin` border (thick 3px variant for the primary check), fills `textMain` + white checkmark when on |
| counter pill | coral `accent` bg, white text 12px, **capsule** (intentionally rounded — it's a badge, matches mockup) |
| circle graphic | concentric `Circle().stroke` at 0.15 opacity, sizes ~[300,220], spin 20s / reverse 15s |
| hero numeral | ~72px, weight 700, tracking ‑3 |

> Signature must-keeps (Samuel): **line work**, **soft coral glow** (already in `AtmosphereBackground`), **square buttons**. The counter pill is the only intentionally-rounded element.

---

## File Structure

- **Modify** `XJournal AI/MomentumTheme.swift` — add line/layout/inverse tokens + typography helpers.
- **Create** `XJournal AI/MomentumComponents.swift` — `MomentumSectionHeader`, `MomentumDivider`, `MomentumSurface` + `.momentumSurface()`.
- **Create** `XJournal AI/MomentumControls.swift` — `MomentumPressStyle`, `MomentumPrimaryButton`, `MomentumSecondaryButton`, `MomentumSelectionToggle`, `MomentumCounterPill`.
- **Create** `XJournal AI/MomentumGraphics.swift` — `MomentumCircleGraphic`.
- **Create** `The Final Journal AITests/MomentumThemeTests.swift` — token + hex-parser unit tests.

Each new view ships with a `#Preview`. Keep files focused; do not add screen logic here.

---

## Setup (do once, before Task 1)

- [ ] **S1: Confirm branch + clean compile baseline**

Run:
```bash
cd "/Users/samuel/Documents/The Final Journal AI"
git rev-parse --abbrev-ref HEAD            # expect: ui-momentum-reskin
xcodebuild build -project "The Final Journal AI.xcodeproj" -scheme "The Final Journal AI" \
  -destination 'generic/platform=iOS Simulator' -quiet
```
Expected: prints `ui-momentum-reskin`; build succeeds (`** BUILD SUCCEEDED **`). If the simulator destination errors, list installed sims with `xcrun simctl list devices available` and use a concrete `-destination 'platform=iOS Simulator,name=<device>'`.

- [ ] **S2: Target-membership rule (read, act on every Create task)**

Every new `.swift` file created below must belong to the **app** target so screens can use it, and the foundation must be visible to tests via `@testable import`. After creating each file, in Xcode select it → File Inspector → **Target Membership** → check **both** `XJournal AI` and `The Final Journal AI`. (Test files: check only `The Final Journal AITests`.) If a build later fails with "cannot find 'MomentumPrimaryButton' in scope", the cause is almost always an unchecked target membership.

---

## Task 1: Foundation tokens + typography

**Files:**
- Modify: `XJournal AI/MomentumTheme.swift` (extend the `MomentumTheme` enum, ends at line 57; add a typography extension after it)
- Test: `The Final Journal AITests/MomentumThemeTests.swift`

- [ ] **Step 1: Write the failing token test**

Create `The Final Journal AITests/MomentumThemeTests.swift`:
```swift
import XCTest
import SwiftUI
@testable import The_Final_Journal_AI

final class MomentumThemeTests: XCTestCase {

    func testHexInitDecodesChannels() {
        let ui = UIColor(Color(hex: 0xFF8C66))
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, CGFloat(0xFF) / 255, accuracy: 0.01)
        XCTAssertEqual(g, CGFloat(0x8C) / 255, accuracy: 0.01)
        XCTAssertEqual(b, CGFloat(0x66) / 255, accuracy: 0.01)
    }

    func testLineAndLayoutTokens() {
        XCTAssertEqual(MomentumTheme.lineThin, 1)
        XCTAssertEqual(MomentumTheme.lineThick, 3)
        XCTAssertEqual(MomentumTheme.edge, 24)
    }
}
```
Add the file to the `The Final Journal AITests` target (Setup S2).

- [ ] **Step 2: Run the test, verify it fails**

Run:
```bash
xcodebuild test -project "The Final Journal AI.xcodeproj" -scheme "The Final Journal AI" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:"The Final Journal AITests/MomentumThemeTests" -quiet
```
Expected: FAIL — `testLineAndLayoutTokens` can't compile / `lineThin` not a member of `MomentumTheme`. (`testHexInitDecodesChannels` would pass — the hex init already exists.)

- [ ] **Step 3: Add the missing tokens**

In `XJournal AI/MomentumTheme.swift`, inside `enum MomentumTheme`, immediately after the `folderTints` array (line 56) and before the enum's closing `}` (line 57), add:
```swift

    // Line work (signature — thin/thick rules + strokes)
    static let lineThin: CGFloat = 1
    static let lineThick: CGFloat = 3

    // Layout
    static let edge: CGFloat = 24

    // Inverted surface (emphasis banner, primary button)
    static let inverseSurface = Color(hex: 0x1C1C1E)
    static let onInverse      = Color(hex: 0xF8F8F8)

    // Calm accent (empathy / re-engagement states only)
    static let accentCalm = Color(hex: 0x6688FF)
```

- [ ] **Step 4: Run the test, verify it passes**

Run the Step 2 command again.
Expected: PASS — both tests green.

- [ ] **Step 5: Add typography helpers**

In `XJournal AI/MomentumTheme.swift`, append at end of file (after line 161):
```swift

// MARK: - Typography (Momentum text styles)

extension Text {
    /// 12pt UPPERCASE tracked label (section headers).
    func momentumSectionTitle() -> some View {
        self.font(.system(size: 12, weight: .bold))
            .tracking(1.5)
            .textCase(.uppercase)
            .foregroundStyle(MomentumTheme.textSecondary)
    }
    /// 18pt semibold card/row title.
    func momentumCardTitle() -> some View {
        self.font(.system(size: 18, weight: .semibold))
            .foregroundStyle(MomentumTheme.textMain)
    }
    /// 16pt body content (never below 16 for readability).
    func momentumBody() -> some View {
        self.font(.system(size: 16))
            .foregroundStyle(MomentumTheme.textMain)
    }
    /// 13pt secondary metadata.
    func momentumMetadata() -> some View {
        self.font(.system(size: 13))
            .foregroundStyle(MomentumTheme.textSecondary)
    }
    /// Giant editorial numeral (stats / milestones). Pass the rendered size.
    func momentumHeroNumeral(size: CGFloat = 72) -> some View {
        self.font(.system(size: size, weight: .bold))
            .tracking(-size * 0.04)
            .foregroundStyle(MomentumTheme.textMain)
    }
}
```

- [ ] **Step 6: Build to verify the typography compiles**

Run:
```bash
xcodebuild build -project "The Final Journal AI.xcodeproj" -scheme "The Final Journal AI" \
  -destination 'generic/platform=iOS Simulator' -quiet
```
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 7: Commit**

```bash
git add "XJournal AI/MomentumTheme.swift" "The Final Journal AITests/MomentumThemeTests.swift"
git commit -m "feat(momentum): P0 line/layout/inverse tokens + typography helpers + tests"
```

---

## Task 2: Structural primitives — SectionHeader, Divider, Surface

**Files:**
- Create: `XJournal AI/MomentumComponents.swift`

- [ ] **Step 1: Create the components with previews**

Create `XJournal AI/MomentumComponents.swift`:
```swift
//
//  MomentumComponents.swift
//  XJournal AI
//
//  Momentum structural primitives: section header, divider, flat surface.
//  Additive — composed by screens in later phases. No behavior here.
//

import SwiftUI

/// UPPERCASE label + a thin trailing rule (the "Today" / "Recommended" headers).
struct MomentumSectionHeader: View {
    let title: String
    var body: some View {
        HStack(spacing: 12) {
            Text(title).momentumSectionTitle()
            Rectangle()
                .fill(MomentumTheme.textMain.opacity(0.2))
                .frame(height: MomentumTheme.lineThin)
        }
    }
}

/// The signature 3px section break. `faint` = 0.2 opacity (reset/empathy screens).
struct MomentumDivider: View {
    var faint: Bool = false
    var body: some View {
        Rectangle()
            .fill(MomentumTheme.textMain.opacity(faint ? 0.2 : 1))
            .frame(height: MomentumTheme.lineThick)
    }
}

/// Flat, square surface that REPLACES `.ultraThinMaterial`.
/// Opaque white (elevated) / muted in light; near-black in dark. Optional hairline.
struct MomentumSurface<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    var elevated: Bool = true
    var bordered: Bool = false
    @ViewBuilder var content: () -> Content

    private var fill: Color {
        if scheme == .dark { return Color(hex: 0x1C1C1E) }
        return elevated ? MomentumTheme.surface : MomentumTheme.surfaceMuted
    }

    var body: some View {
        content()
            .background(fill)                       // square — no cornerRadius
            .overlay(
                Rectangle()
                    .stroke(MomentumTheme.hairline,
                            lineWidth: bordered ? MomentumTheme.lineThin : 0)
            )
    }
}

extension View {
    /// Wrap any view in a flat Momentum surface.
    func momentumSurface(elevated: Bool = true, bordered: Bool = false) -> some View {
        MomentumSurface(elevated: elevated, bordered: bordered) { self }
    }
}

#Preview("Structural") {
    ZStack {
        AtmosphereBackground()
        VStack(alignment: .leading, spacing: 20) {
            MomentumSectionHeader(title: "Recent")
            VStack(alignment: .leading, spacing: 4) {
                Text("Street Echo").momentumCardTitle()
                Text("84 BPM · A minor").momentumMetadata()
            }
            .padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .momentumSurface(bordered: true)
            MomentumDivider()
            Text("Faint break").momentumMetadata()
            MomentumDivider(faint: true)
        }
        .padding(MomentumTheme.edge)
    }
}
```
Add to both app targets (Setup S2).

- [ ] **Step 2: Build to verify it compiles**

Run:
```bash
xcodebuild build -project "The Final Journal AI.xcodeproj" -scheme "The Final Journal AI" \
  -destination 'generic/platform=iOS Simulator' -quiet
```
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Visual check the preview**

Open `MomentumComponents.swift` in Xcode → Canvas → Resume. Confirm: coral glow at top; UPPERCASE "RECENT" with a thin trailing rule; a flat white card with hairline; a solid 3px divider; a faint 0.2 divider. Capture a screenshot for the phase record.

- [ ] **Step 4: Commit**

```bash
git add "XJournal AI/MomentumComponents.swift"
git commit -m "feat(momentum): SectionHeader, Divider, flat Surface primitives"
```

---

## Task 3: Square controls — buttons, selection toggle, counter pill

**Files:**
- Create: `XJournal AI/MomentumControls.swift`

- [ ] **Step 1: Create the controls with previews**

Create `XJournal AI/MomentumControls.swift`:
```swift
//
//  MomentumControls.swift
//  XJournal AI
//
//  Square action controls + micro-compression press style. Signature: sharp corners.
//

import SwiftUI

/// Press-in compression on touch-down (Segment 4). Used by all Momentum buttons.
struct MomentumPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Full-width dark SQUARE primary action (optional trailing icon).
struct MomentumPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title).font(.system(size: 16, weight: .semibold))
                if let systemImage {
                    Spacer(minLength: 0)
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .foregroundStyle(MomentumTheme.onInverse)
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(MomentumTheme.inverseSurface)   // square
        }
        .buttonStyle(MomentumPressStyle())
    }
}

/// Transparent SQUARE secondary action with a hairline border.
struct MomentumSecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title).font(.system(size: 16, weight: .semibold))
                if let systemImage {
                    Spacer(minLength: 0)
                    Image(systemName: systemImage).font(.system(size: 18, weight: .semibold))
                }
            }
            .foregroundStyle(MomentumTheme.textMain)
            .padding(20)
            .frame(maxWidth: .infinity)
            .overlay(Rectangle().stroke(MomentumTheme.textMain, lineWidth: MomentumTheme.lineThin))
        }
        .buttonStyle(MomentumPressStyle())
    }
}

/// Square check toggle. `thickBorder` = the 3px primary-action variant from the dashboard mockup.
struct MomentumSelectionToggle: View {
    let isOn: Bool
    var size: CGFloat = 44
    var thickBorder: Bool = false
    var body: some View {
        ZStack {
            Rectangle().fill(isOn ? MomentumTheme.textMain : Color.clear)
            Rectangle().stroke(
                isOn ? MomentumTheme.textMain : MomentumTheme.textMain.opacity(0.25),
                lineWidth: thickBorder ? MomentumTheme.lineThick : MomentumTheme.lineThin
            )
            Image(systemName: "checkmark")
                .font(.system(size: size * 0.38, weight: .bold))
                .foregroundStyle(MomentumTheme.bg)
                .opacity(isOn ? 1 : 0)
                .scaleEffect(isOn ? 1 : 0.5)
        }
        .frame(width: size, height: size)
        .animation(.easeOut(duration: 0.18), value: isOn)
    }
}

/// Small coral count badge (intentionally a capsule — matches the mockup's counter-pill).
struct MomentumCounterPill: View {
    let count: Int
    var body: some View {
        Text("\(count)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8).padding(.vertical, 2)
            .background(Capsule().fill(MomentumTheme.accent))
    }
}

#Preview("Controls") {
    ZStack {
        AtmosphereBackground()
        VStack(spacing: 16) {
            MomentumPrimaryButton(title: "Generate", systemImage: "arrow.right")
            MomentumSecondaryButton(title: "Keep going", systemImage: "arrow.right")
            HStack(spacing: 16) {
                MomentumSelectionToggle(isOn: true)
                MomentumSelectionToggle(isOn: false)
                MomentumSelectionToggle(isOn: true, thickBorder: true)
                MomentumCounterPill(count: 2)
            }
        }
        .padding(MomentumTheme.edge)
    }
}
```
Add to both app targets (Setup S2).

- [ ] **Step 2: Build to verify it compiles**

Run:
```bash
xcodebuild build -project "The Final Journal AI.xcodeproj" -scheme "The Final Journal AI" \
  -destination 'generic/platform=iOS Simulator' -quiet
```
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Visual check the preview**

In Xcode Canvas confirm: full-width dark **square** "Generate" button; square outlined "Keep going"; three square toggles (filled, empty, thick-border filled) with checkmarks; a coral count pill. Press the buttons in the live preview → they compress slightly. Screenshot for the record.

- [ ] **Step 4: Commit**

```bash
git add "XJournal AI/MomentumControls.swift"
git commit -m "feat(momentum): square primary/secondary buttons, selection toggle, counter pill"
```

---

## Task 4: Circle line-art graphic

**Files:**
- Create: `XJournal AI/MomentumGraphics.swift`

- [ ] **Step 1: Create the graphic with a preview**

Create `XJournal AI/MomentumGraphics.swift`:
```swift
//
//  MomentumGraphics.swift
//  XJournal AI
//
//  Concentric line-art circles (empty states, milestone celebration). Signature line work.
//

import SwiftUI

struct MomentumCircleGraphic<Center: View>: View {
    var sizes: [CGFloat] = [300, 220]
    var spins: Bool = false
    var lineWidth: CGFloat = MomentumTheme.lineThin
    var opacity: Double = 0.15
    @ViewBuilder var center: () -> Center

    @State private var angle: Double = 0

    var body: some View {
        ZStack {
            ForEach(Array(sizes.enumerated()), id: \.offset) { index, diameter in
                Circle()
                    .stroke(MomentumTheme.textMain.opacity(opacity), lineWidth: lineWidth)
                    .frame(width: diameter, height: diameter)
                    .rotationEffect(.degrees(spins ? (index % 2 == 0 ? angle : -angle) : 0))
            }
            center()
        }
        .onAppear {
            guard spins else { return }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                angle = 360
            }
        }
    }
}

#Preview("Circle graphic") {
    ZStack {
        AtmosphereBackground(warm: true)
        MomentumCircleGraphic(sizes: [300, 220], spins: true) {
            VStack(spacing: 8) {
                Text("7").momentumHeroNumeral(size: 120)
                Text("Verses").momentumMetadata()
            }
        }
    }
}
```
Add to both app targets (Setup S2).

- [ ] **Step 2: Build to verify it compiles**

Run:
```bash
xcodebuild build -project "The Final Journal AI.xcodeproj" -scheme "The Final Journal AI" \
  -destination 'generic/platform=iOS Simulator' -quiet
```
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Visual check the preview**

In Xcode Canvas confirm: two faint concentric circles slowly counter-rotating around a giant "7" with a "Verses" label, over a warm coral glow. Screenshot for the record.

- [ ] **Step 4: Commit**

```bash
git add "XJournal AI/MomentumGraphics.swift"
git commit -m "feat(momentum): concentric line-art circle graphic"
```

---

## Task 5: P0 acceptance — full build + kit gallery + phase record

**Files:** none (verification only)

- [ ] **Step 1: Full app build (Debug)**

Run:
```bash
xcodebuild build -project "The Final Journal AI.xcodeproj" -scheme "The Final Journal AI" \
  -configuration Debug -destination 'generic/platform=iOS Simulator' -quiet
```
Expected: `** BUILD SUCCEEDED **`. (Confirms the kit compiles into the app even though no screen uses it yet — the app is visually unchanged.)

- [ ] **Step 2: Run the token tests once more**

Run:
```bash
xcodebuild test -project "The Final Journal AI.xcodeproj" -scheme "The Final Journal AI" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:"The Final Journal AITests/MomentumThemeTests" -quiet
```
Expected: PASS.

- [ ] **Step 3: Capture the kit gallery screenshots**

From the three component previews (Tasks 2–4) capture screenshots into the phase record (e.g. attach to the Obsidian `UI Overhaul — Phased Plan.md` log or `docs/superpowers/` notes). These are the visual baseline P1 builds on.

- [ ] **Step 4: Confirm app launches unchanged (optional smoke)**

Boot the app in the simulator and confirm the home screen looks exactly as before (P0 is additive). No screenshot diff expected.

---

## Notes & deferred (do NOT do in P0)

- `momentumFloatingBar()` (in `MomentumTheme.swift:139`) still uses `.ultraThinMaterial` + 32pt rounded corners — a glass holdover that conflicts with square/line-work. **Decision deferred to P5**: convert to a flat square bar, or keep it as the single intentional frosted bar for search/keyboard. Leave it untouched in P0.
- No screen imports the kit yet — that begins in **P1 (Home + core flow)**, which gets its own plan once these primitives' real APIs are committed.
- Dark mode: `MomentumSurface`/`AtmosphereBackground` already branch on `colorScheme`, but the editorial-dark pass is **P6** — do not tune dark values now.

---

## Self-Review

**Spec coverage (P0 scope):** tokens ✓ (Task 1) · typography ✓ (Task 1) · flat `Surface` replacing `.ultraThinMaterial` ✓ (Task 2) · SectionHeader + MainDivider (line work) ✓ (Task 2) · square buttons ✓ (Task 3) · SelectionToggle ✓ (Task 3) · CounterPill ✓ (Task 3) · CircleLineGraphic ✓ (Task 4) · AtmosphereGlow — pre-existing, reused in previews ✓. Layer-0 of the spec's component list is fully covered; `SuggestionGrid`/`HeroStat`/screen components are P1+ (correctly deferred).

**Placeholder scan:** no TBD/TODO; every code step is complete and compiles as written; commands are concrete with expected output.

**Type consistency:** `MomentumTheme.lineThin/lineThick/edge/inverseSurface/onInverse/accentCalm` defined in Task 1 and used verbatim in Tasks 2–4. `MomentumPressStyle` defined before its use by both buttons. Typography helpers (`momentumSectionTitle/CardTitle/Body/Metadata/HeroNumeral`) defined in Task 1, used in Tasks 2 & 4. `AtmosphereBackground` / `MomentumTheme.surface/peach/textMain/hairline/accent` are pre-existing (confirmed in `MomentumTheme.swift`). No undefined references.

**Scope:** single shippable unit (the design-system foundation). Correct.
