# AI Rules for The Final Journal AI

This document outlines the core technologies and guidelines for library usage within this application.

## Tech Stack Description

*   **SwiftUI**: The primary declarative UI framework used for building all user interfaces across the application.
*   **SwiftData**: The modern persistence framework for managing and storing all structured application data, such as journal entries.
*   **UIKit**: Utilized for specific low-level system interactions, including haptic feedback generation and keyboard observation, where SwiftUI's abstractions are not directly available or sufficient.
*   **Combine**: Employed for reactive programming patterns, handling asynchronous events, and managing complex data flows.
*   **CMUDICTStore**: A custom, in-app dictionary and phonetic analysis engine specifically designed for rhyme detection and linguistic diagnostics.
*   **Custom Layouts**: SwiftUI's `Layout` protocol is implemented for specific, flexible UI arrangements that go beyond standard container views (e.g., `FlowLayout`).
*   **AppStorage**: Used for lightweight, user-specific data storage, such as application settings or initial setup flags.
*   **NavigationSplitView**: Forms the foundational structure for the application's primary navigation flow, enabling adaptive layouts for different device sizes.

## Library Usage Rules

*   **UI Development**: Always use **SwiftUI** for building all user interface components and views. New components should be created as SwiftUI `View` structs.
*   **Data Storage**: **SwiftData** is the exclusive framework for all application data persistence. All models should conform to `@Model`.
*   **System-Level Interactions**: For functionalities like haptic feedback, keyboard management, or other platform-specific low-level interactions, **UIKit** components or APIs should be used. These should be encapsulated and bridged to SwiftUI where necessary.
*   **Reactive Programming**: **Combine** should be used for handling asynchronous events, data streams, and complex data flow logic, especially when dealing with UI updates based on external changes.
*   **Phonetic Analysis**: The custom **CMUDICTStore** and related `RhymeHighlighterEngine` are to be used for all phonetic data lookup, rhyme detection, and linguistic analysis within the application.
*   **Styling**: Leverage **SwiftUI modifiers** and built-in materials (e.g., `.ultraThinMaterial`) for consistent visual styling. Avoid direct UIKit styling unless absolutely necessary for a specific UIKit component.
*   **Layouts**: Prefer SwiftUI's standard layout containers (e.g., `VStack`, `HStack`, `ZStack`, `Grid`). For complex, custom arrangements that cannot be achieved with standard containers, implement the **SwiftUI `Layout` protocol**.