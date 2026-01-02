# AI Rules for The Final Journal AI

This document outlines the core technologies and library usage guidelines for developing "The Final Journal AI" application. Adhering to these rules ensures consistency, maintainability, and leverages the strengths of the chosen tech stack.

## Tech Stack Description

*   **Primary UI Framework**: SwiftUI is used for building the entire user interface, leveraging its declarative syntax for modern iOS app development.
*   **Data Persistence**: SwiftData is the chosen framework for managing and persisting all application data locally.
*   **Interoperability with UIKit**: The application integrates with UIKit for specific system-level functionalities, such as generating haptic feedback and observing keyboard events.
*   **Reactive Programming**: Combine is utilized for handling asynchronous events and notifications, particularly for observing system changes like keyboard appearance/disappearance.
*   **Phonetic Analysis Engine**: A custom `CMUDICTStore` is implemented to provide phonetic data and facilitate advanced rhyme analysis within the application.
*   **Custom Layouts**: While SwiftUI's built-in layout containers are preferred, custom `Layout` protocol implementations are used for specific, non-standard UI arrangements (e.g., `FlowLayout`).
*   **State Management**: SwiftUI's robust property wrappers (`@State`, `@Binding`, `@Environment`, `@Query`, `@AppStorage`, `@FocusState`, `@Bindable`) are extensively used for managing application state.

## Library Usage Rules

*   **UI Components**: All user interface elements must be built using SwiftUI views and modifiers. Direct usage of UIKit views should be avoided unless there is no equivalent SwiftUI functionality, and only for specific system integrations (e.g., `UIImpactFeedbackGenerator`).
*   **Data Storage**: SwiftData is the exclusive framework for all local data persistence operations. Do not introduce other database or storage solutions.
*   **Haptic Feedback**: For haptic feedback, always use `UIImpactFeedbackGenerator` from UIKit.
*   **Keyboard Events**: Keyboard appearance and disappearance events should be observed using `NotificationCenter` with `UIResponder.keyboardWillShowNotification` and `UIResponder.keyboardWillHideNotification`, ideally encapsulated within an `ObservableObject` like `KeyboardObserver`.
*   **Phonetic Dictionary**: The `CMUDICTStore` is the sole source for all phonetic lookups and rhyme tail generation. No other phonetic analysis libraries should be introduced.
*   **Layouts**: Prioritize SwiftUI's standard layout containers (`VStack`, `HStack`, `ZStack`, `ScrollView`, `List`, `Grid`). Custom `Layout` implementations are reserved for unique layout requirements that cannot be achieved with standard SwiftUI modifiers.
*   **State Management**: Adhere strictly to SwiftUI's recommended state management patterns using its provided property wrappers.