import SwiftUI
import Combine
import UIKit

// MARK: - Keyboard Observer
// File: ContentView.CCV.5.swift
// Dependencies: None (standalone)
// Used by: ContentView.swift, NoteEditorView

final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0

    private var cancellable: AnyCancellable?
    private let keyboardFrame = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
        .compactMap { note -> CGFloat? in
            guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return nil }
            let window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)
            let converted = window?.convert(frame, from: nil) ?? frame
            let visible = (window?.bounds ?? converted).intersection(converted).height
            return visible.isFinite && visible > 1 ? visible : 0
        }

    private let keyboardWillHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .compactMap { _ -> CGFloat? in 0 }

    private let keyboardDidHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardDidHideNotification)
        .compactMap { _ -> CGFloat? in 0 }

    init() {
        cancellable = keyboardFrame
            .merge(with: keyboardWillHide, keyboardDidHide)
            .receive(on: DispatchQueue.main)
            .assign(to: \.height, on: self)
    }
}
