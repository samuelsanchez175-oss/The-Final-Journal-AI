//
// ContentView.CCV.15.swift
//
// This file contains RhymeGroupListView.
//
// Dependencies:
// - ContentView.CCV.2.swift (for GlassSettings, lightHaptic)
// - ContentView.CCV.3.swift (for RhymeHighlighterEngine)
//
import SwiftUI
import UIKit
import Combine
import NaturalLanguage

struct RhymeGroupListView: View {
    let groups: [RhymeHighlighterEngine.RhymeGroup]
    let currentText: String
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isSortReversed = false
    @State private var showSuggestions = false
    
    // Device-aware sizing - uses modern API to get screen bounds
    private var popoverWidth: CGFloat {
        let screenWidth = getScreenWidth()
        // iPhone sizing: use 85% of screen width, max 400pt
        // iPad sizing: use fixed width
        if horizontalSizeClass == .compact {
            // iPhone
            return min(screenWidth * 0.85, 400)
        } else {
            // iPad
            return 520
        }
    }
    
    private var popoverMaxHeight: CGFloat {
        let screenHeight = getScreenHeight()
        // Use 60% of screen height, max 500pt
        return min(screenHeight * 0.6, 500)
    }
    
    // Helper to get screen width using modern API
    private func getScreenWidth() -> CGFloat {
        // #region agent log
        let logData: [String: Any] = ["sessionId": "debug-session", "runId": "run1", "hypothesisId": "A", "location": "ContentView.CCV.15.swift:43", "message": "getScreenWidth entry", "data": ["horizontalSizeClass": String(describing: horizontalSizeClass)], "timestamp": Int(Date().timeIntervalSince1970 * 1000)]
        if let logFile = FileHandle(forWritingAtPath: "/Users/samuel/Documents/The Final Journal AI/.cursor/debug.log") {
            logFile.seekToEndOfFile()
            if let jsonData = try? JSONSerialization.data(withJSONObject: logData) {
                logFile.write(jsonData)
                logFile.write("\n".data(using: .utf8)!)
            }
            logFile.closeFile()
        }
        // #endregion
        // Try modern API first (iOS 13+)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let width = window?.bounds.width ?? (horizontalSizeClass == .compact ? 390 : 768)
        // #region agent log
        let logData2: [String: Any] = ["sessionId": "debug-session", "runId": "run1", "hypothesisId": "A", "location": "ContentView.CCV.15.swift:50", "message": "getScreenWidth exit", "data": ["windowSceneFound": windowScene != nil, "windowFound": window != nil, "width": width], "timestamp": Int(Date().timeIntervalSince1970 * 1000)]
        if let logFile2 = FileHandle(forWritingAtPath: "/Users/samuel/Documents/The Final Journal AI/.cursor/debug.log") {
            logFile2.seekToEndOfFile()
            if let jsonData2 = try? JSONSerialization.data(withJSONObject: logData2) {
                logFile2.write(jsonData2)
                logFile2.write("\n".data(using: .utf8)!)
            }
            logFile2.closeFile()
        }
        // #endregion
        return width
    }
    
    // Helper to get screen height using modern API
    private func getScreenHeight() -> CGFloat {
        // Try modern API first (iOS 13+)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let height = window?.bounds.height ?? (horizontalSizeClass == .compact ? 844 : 1024)
        return height
    }

    // Computed property to avoid complex expression in body
    private var orderedGroups: [RhymeHighlighterEngine.RhymeGroup] {
        // #region agent log
        let logData: [String: Any] = ["sessionId": "debug-session", "runId": "run1", "hypothesisId": "D", "location": "ContentView.CCV.15.swift:65", "message": "orderedGroups computed", "data": ["groupsCount": groups.count, "isSortReversed": isSortReversed], "timestamp": Int(Date().timeIntervalSince1970 * 1000)]
        if let logFile = FileHandle(forWritingAtPath: "/Users/samuel/Documents/The Final Journal AI/.cursor/debug.log") {
            logFile.seekToEndOfFile()
            if let jsonData = try? JSONSerialization.data(withJSONObject: logData) {
                logFile.write(jsonData)
                logFile.write("\n".data(using: .utf8)!)
            }
            logFile.closeFile()
        }
        // #endregion
        let baseOrdered = groups.sorted { g1, g2 in
            guard
                let r1 = g1.words.map({ $0.range.lowerBound }).min(),
                let r2 = g2.words.map({ $0.range.lowerBound }).min()
            else { return false }
            return r1 < r2
        }
        let result = isSortReversed ? Array(baseOrdered.reversed()) : baseOrdered
        // #region agent log
        let logData2: [String: Any] = ["sessionId": "debug-session", "runId": "run1", "hypothesisId": "D", "location": "ContentView.CCV.15.swift:73", "message": "orderedGroups result", "data": ["resultCount": result.count], "timestamp": Int(Date().timeIntervalSince1970 * 1000)]
        if let logFile2 = FileHandle(forWritingAtPath: "/Users/samuel/Documents/The Final Journal AI/.cursor/debug.log") {
            logFile2.seekToEndOfFile()
            if let jsonData2 = try? JSONSerialization.data(withJSONObject: logData2) {
                logFile2.write(jsonData2)
                logFile2.write("\n".data(using: .utf8)!)
            }
            logFile2.closeFile()
        }
        // #endregion
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Button {
                    isSortReversed.toggle()
                } label: {
                    HStack {
                        Text("Rhyme Groups")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption)
                            .foregroundStyle(Momentum.contentSecondary)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    showSuggestions.toggle()
                } label: {
                    Image(systemName: showSuggestions ? "lightbulb.fill" : "lightbulb")
                        .font(.headline)
                        .foregroundStyle(showSuggestions ? .blue : .secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 6)


            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if orderedGroups.isEmpty {
                            Text("No rhymes found.")
                                .font(.callout)
                                .foregroundStyle(Momentum.contentSecondary)
                                .id("top")
                        } else {
                            ForEach(Array(orderedGroups.enumerated()), id: \.element.id) { index, group in
                                groupRowView(index: index, group: group)
                                    .id(index == 0 ? "top" : group.id.uuidString)

                                if index < orderedGroups.count - 1 {
                                    Divider().opacity(0.25)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    // #region agent log
                    let logData: [String: Any] = ["sessionId": "debug-session", "runId": "run1", "hypothesisId": "E", "location": "ContentView.CCV.15.swift:127", "message": "ScrollView onAppear", "data": ["orderedGroupsCount": orderedGroups.count], "timestamp": Int(Date().timeIntervalSince1970 * 1000)]
                    if let logFile = FileHandle(forWritingAtPath: "/Users/samuel/Documents/The Final Journal AI/.cursor/debug.log") {
                        logFile.seekToEndOfFile()
                        if let jsonData = try? JSONSerialization.data(withJSONObject: logData) {
                            logFile.write(jsonData)
                            logFile.write("\n".data(using: .utf8)!)
                        }
                        logFile.closeFile()
                    }
                    // #endregion
                    // Scroll to top when view appears
                    withAnimation {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
        .padding(16)
        .frame(width: popoverWidth)
        .frame(maxHeight: popoverMaxHeight)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Momentum.surfaceElevated)        )
    }
    
    // Helper view builder to break up complex expression
    @ViewBuilder
    private func groupRowView(index: Int, group: RhymeHighlighterEngine.RhymeGroup) -> some View {
        let groupColor = Color(RhymeColorPalette.colors[group.colorIndex])
        let uniqueWords = Array(Set(group.words.map { $0.word })).sorted()
        let suggestions = showSuggestions ? findRhymeSuggestions(for: group) : []
        
        VStack(alignment: .leading, spacing: 8) {
            // Group header
            Text("Group \(index + 1)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(groupColor)
            
            // Current words in group
            Text(uniqueWords.joined(separator: " · "))
                .font(.callout)
                .foregroundStyle(groupColor.opacity(0.8))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            // Suggestions section
            if showSuggestions && !suggestions.isEmpty {
                Text(suggestions.joined(separator: " · "))
                    .font(.callout)
                    .foregroundStyle(.blue)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // Find rhyming words that aren't in the current text
    private func findRhymeSuggestions(for group: RhymeHighlighterEngine.RhymeGroup) -> [String] {
        // #region agent log
        let logData: [String: Any] = ["sessionId": "debug-session", "runId": "run1", "hypothesisId": "C", "location": "ContentView.CCV.15.swift:177", "message": "findRhymeSuggestions entry", "data": ["groupWordsCount": group.words.count, "currentTextLength": currentText.count], "timestamp": Int(Date().timeIntervalSince1970 * 1000)]
        if let logFile = FileHandle(forWritingAtPath: "/Users/samuel/Documents/The Final Journal AI/.cursor/debug.log") {
            logFile.seekToEndOfFile()
            if let jsonData = try? JSONSerialization.data(withJSONObject: logData) {
                logFile.write(jsonData)
                logFile.write("\n".data(using: .utf8)!)
            }
            logFile.closeFile()
        }
        // #endregion
        // Get all words currently in the text (lowercased)
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = currentText
        var wordsInText: Set<String> = []
        tokenizer.enumerateTokens(in: currentText.startIndex..<currentText.endIndex) { range, _ in
            wordsInText.insert(String(currentText[range]).lowercased())
            return true
        }
        
        // Get the phonetic signature from the first word in the group
        guard let firstWord = group.words.first,
              let phonemes = FJCMUDICTStore.shared.phonemesByWord[firstWord.word.lowercased()],
              let groupSignature = RhymeHighlighterEngine.extractSignature(from: phonemes) else {
            return []
        }
        
        // Find all words in CMUDICT that rhyme with this group
        let dict = FJCMUDICTStore.shared.phonemesByWord
        var perfectRhymes: [String] = []
        var nearRhymes: [String] = []
        
        for (word, wordPhonemes) in dict {
            // Skip if word is already in the text
            if wordsInText.contains(word.lowercased()) {
                continue
            }
            
            // Skip if word is already in this group
            if group.words.contains(where: { $0.word.lowercased() == word.lowercased() }) {
                continue
            }
            
            // Check if it rhymes with the group
            guard let wordSignature = RhymeHighlighterEngine.extractSignature(from: wordPhonemes),
                  let strength = RhymeHighlighterEngine.rhymeScore(groupSignature, wordSignature) else {
                continue
            }
            
            // Prioritize perfect rhymes, then near rhymes (skip slant)
            let capitalizedWord = word.capitalized
            switch strength {
            case .perfect:
                perfectRhymes.append(capitalizedWord)
            case .near:
                nearRhymes.append(capitalizedWord)
            case .slant:
                continue
            }
            
            // Stop if we have enough perfect rhymes (7 for better suggestions)
            if perfectRhymes.count >= 7 {
                break
            }
        }
        
        // Return perfect rhymes first, then fill with near rhymes up to 7 total
        let allSuggestions = perfectRhymes + nearRhymes
        let result = Array(allSuggestions.prefix(7)).sorted() // Increased from 3 to 7 suggestions
        // #region agent log
        let logData2: [String: Any] = ["sessionId": "debug-session", "runId": "run1", "hypothesisId": "C", "location": "ContentView.CCV.15.swift:235", "message": "findRhymeSuggestions exit", "data": ["perfectRhymesCount": perfectRhymes.count, "nearRhymesCount": nearRhymes.count, "resultCount": result.count], "timestamp": Int(Date().timeIntervalSince1970 * 1000)]
        if let logFile2 = FileHandle(forWritingAtPath: "/Users/samuel/Documents/The Final Journal AI/.cursor/debug.log") {
            logFile2.seekToEndOfFile()
            if let jsonData2 = try? JSONSerialization.data(withJSONObject: logData2) {
                logFile2.write(jsonData2)
                logFile2.write("\n".data(using: .utf8)!)
            }
            logFile2.closeFile()
        }
        // #endregion
        return result
    }
}
