import SwiftUI

/// A suggested breath before a clause starter. The comma is not in the text
/// until the writer taps the ghost mark.
struct CommaHint: Equatable {
    var word: String
    /// UTF-16 index in the string passed to the finder. The real comma goes here.
    var utf16Location: Int
}

/// The 30–60% clause-starter pass. Syllables come from `LineSyllableCounter`.
/// A missing comma is never an error and never changes a score.
enum CommaHintEngine {
    static func hints(in line: String) -> [CommaHint] {
        guard LineSyllableCounter.syllableCount(forLine: line) >= 10 else { return [] }
        let words = tokenize(line)
        guard !words.isEmpty else { return [] }
        let length = (line as NSString).length
        var out: [CommaHint] = []
        for (index, word) in words.enumerated() {
            if index == 0 || word.inside || word.commaBefore { continue }
            guard let rule = rule(for: words, index: index) else { continue }
            if rule == "before_but" && blocksSharedSubject(words, index) { continue }
            if rule == "before_till" && isWontStopTil(words, index) { continue }
            let pct = percent(at: word.start, length: length)
            guard pct >= 30, pct <= 60 else { continue }
            out.append(CommaHint(word: word.text, utf16Location: word.start))
        }
        return out
    }

    /// Hints for a whole note. Locations are UTF-16 offsets into `text`.
    static func hints(inText text: String) -> [CommaHint] {
        let parts = text.split(separator: "\n", omittingEmptySubsequences: false)
        var out: [CommaHint] = []
        var location = 0
        for (index, part) in parts.enumerated() {
            let line = String(part)
            for hint in hints(in: line) {
                out.append(CommaHint(word: hint.word, utf16Location: hint.utf16Location + location))
            }
            location += (line as NSString).length
            if index < parts.count - 1 { location += 1 }
        }
        return out
    }

    private struct Word {
        var text: String
        var norm: String
        var start: Int
        var inside: Bool
        var commaBefore: Bool
    }

    private static func percent(at index: Int, length: Int) -> Double {
        guard length > 0 else { return 0 }
        return (1000.0 * Double(index) / Double(length)).rounded() / 10
    }

    private static func tokenize(_ line: String) -> [Word] {
        let ns = line as NSString
        let length = ns.length
        var words: [Word] = []
        var i = 0
        var paren = 0
        var brack = 0
        var commaBeforeNext = false
        while i < length {
            let ch = ns.character(at: i)
            if ch == UInt16(UnicodeScalar("(").value) { paren += 1; i += 1; continue }
            if ch == UInt16(UnicodeScalar(")").value) { paren = max(0, paren - 1); i += 1; continue }
            if ch == UInt16(UnicodeScalar("[").value) { brack += 1; i += 1; continue }
            if ch == UInt16(UnicodeScalar("]").value) { brack = max(0, brack - 1); i += 1; continue }
            if let scalar = UnicodeScalar(ch), CharacterSet.whitespacesAndNewlines.contains(scalar) {
                i += 1
                continue
            }
            let inside = paren > 0 || brack > 0
            if ch == UInt16(UnicodeScalar(",").value) || ch == UInt16(UnicodeScalar("，").value) {
                let prevDigit = i > 0 && ns.character(at: i - 1).isDigit
                let nextDigit = i + 1 < length && ns.character(at: i + 1).isDigit
                if !(prevDigit && nextDigit) && !inside {
                    commaBeforeNext = true
                }
                i += 1
                continue
            }
            var j = i
            while j < length {
                let c = ns.character(at: j)
                if c == UInt16(UnicodeScalar(",").value) || c == UInt16(UnicodeScalar("，").value) { break }
                if c == UInt16(UnicodeScalar("(").value) || c == UInt16(UnicodeScalar(")").value) { break }
                if c == UInt16(UnicodeScalar("[").value) || c == UInt16(UnicodeScalar("]").value) { break }
                if let scalar = UnicodeScalar(c), CharacterSet.whitespacesAndNewlines.contains(scalar) { break }
                j += 1
            }
            let raw = ns.substring(with: NSRange(location: i, length: j - i))
            words.append(Word(
                text: raw,
                norm: normalize(raw),
                start: i,
                inside: inside,
                commaBefore: commaBeforeNext && !inside
            ))
            commaBeforeNext = false
            i = j
        }
        return words
    }

    private static func normalize(_ raw: String) -> String {
        var w = raw.trimmingCharacters(in: CharacterSet(charactersIn: "()[]{}\"“”«»`"))
        w = w.trimmingCharacters(in: CharacterSet(charactersIn: "?.!;:…"))
        w = w.replacingOccurrences(of: "’", with: "'").replacingOccurrences(of: "‘", with: "'")
        return w.lowercased()
    }

    private static func nextWord(_ words: [Word], _ index: Int) -> Word? {
        guard index + 1 < words.count else { return nil }
        return words[index + 1]
    }

    private static func rule(for words: [Word], index: Int) -> String? {
        let word = words[index]
        let n = word.norm
        let prev = words[index - 1].norm
        if n == "but" && !nothingBut.contains(prev) && prev != "no" && !xButX(words, index) {
            return "before_but"
        }
        if (n == "cuz" || n == "coz") && cuzIsBecause(words, index) {
            return "before_cuz"
        }
        if n == "'cause" || n == "’cause" {
            return "before_cause"
        }
        if n == "cause" && !causePrevBlock.contains(prev) {
            return "before_cause"
        }
        if n == "when" && whenIsClause(words, index) {
            return "before_when"
        }
        if n == "while" && !whilePrevBlock.contains(prev) {
            return "before_while"
        }
        if tillForms.contains(n) && !waitForms.contains(prev) {
            return "before_till"
        }
        if n == "so" && soIsClause(words, index) {
            return "before_so"
        }
        return nil
    }

    private static func xButX(_ words: [Word], _ index: Int) -> Bool {
        guard let nxt = nextWord(words, index), index > 0 else { return false }
        return words[index - 1].norm == nxt.norm
    }

    private static func whenIsClause(_ words: [Word], _ index: Int) -> Bool {
        let prev = words[index - 1].norm
        if whenBlockers.contains(prev) { return false }
        if index >= 2 && whenBlockers.contains(words[index - 2].norm) && whenObject.contains(prev) {
            return false
        }
        return true
    }

    private static func cuzIsBecause(_ words: [Word], _ index: Int) -> Bool {
        let n = words[index].norm
        guard n == "cuz" || n == "coz", index > 0 else { return false }
        let prev = words[index - 1].norm
        guard let nxt = nextWord(words, index) else { return false }
        if cuzPrevBlock.contains(prev) || preps.contains(prev) || particlePreps.contains(prev) {
            return false
        }
        return subjects.contains(nxt.norm) || iClause.contains(nxt.norm)
            || dets.contains(nxt.norm) || possessives.contains(nxt.norm) || nxt.norm == "her"
    }

    private static func soIsClause(_ words: [Word], _ index: Int) -> Bool {
        guard let nxt = nextWord(words, index) else { return false }
        if soDegree.contains(nxt.norm) { return false }
        return subjects.contains(nxt.norm) || iClause.contains(nxt.norm)
            || dets.contains(nxt.norm) || demonstratives.contains(nxt.norm)
    }

    /// "meant well but fell": the next word is a verb and an earlier word is too.
    private static func blocksSharedSubject(_ words: [Word], _ index: Int) -> Bool {
        guard let nxt = nextWord(words, index) else { return false }
        if subjectIntroducer(nxt.norm) { return false }
        guard isVerb(nxt.norm) else { return false }
        return words[..<index].contains { isVerb($0.norm) }
    }

    /// "won't stop 'til" is one span.
    private static func isWontStopTil(_ words: [Word], _ index: Int) -> Bool {
        guard index >= 2 else { return false }
        let stop = words[index - 1].norm
        let wont = words[index - 2].norm
        return stopForms.contains(stop) && wontForms.contains(wont)
    }

    private static func subjectIntroducer(_ norm: String) -> Bool {
        subjects.contains(norm) || iClause.contains(norm) || dets.contains(norm)
            || demonstratives.contains(norm) || norm == "her" || norm == "as"
    }

    private static func isVerb(_ norm: String) -> Bool {
        if subjectIntroducer(norm) { return false }
        return verbs.contains(norm) || aux.contains(norm)
    }

    private static let subjects: Set<String> = [
        "i", "you", "he", "she", "we", "they", "it", "yall", "y'all", "ya'll"
    ]
    private static let demonstratives: Set<String> = ["this", "that", "these", "those"]
    private static let possessives: Set<String> = ["my", "your", "his", "our", "their", "ya"]
    private static let dets: Set<String> = [
        "the", "a", "an", "my", "your", "his", "our", "their", "some", "every", "each"
    ]
    private static let preps: Set<String> = [
        "to", "into", "onto", "from", "of", "with", "without", "at", "by", "for",
        "about", "through", "thru", "across", "against", "between", "over", "under",
        "around", "upon", "via", "per", "offa"
    ]
    private static let particlePreps: Set<String> = [
        "in", "on", "up", "out", "off", "down", "back", "away"
    ]
    private static let nothingBut: Set<String> = [
        "nothing", "anything", "everything", "nobody", "noone", "none", "all",
        "nothin", "nothin'", "nuthin", "nuthin'", "nuttin", "nuttin'"
    ]
    private static let tillForms: Set<String> = ["till", "til", "'til", "’til"]
    private static let waitForms: Set<String> = [
        "wait", "waited", "waiting", "waitin", "waitin'"
    ]
    private static let stopForms: Set<String> = [
        "stop", "stopped", "stopping", "stoppin", "stoppin'"
    ]
    private static let wontForms: Set<String> = ["won't", "wont", "won’t"]
    private static let iClause: Set<String> = [
        "i", "i'm", "im", "i'll", "i'd", "i've", "ive", "i'ma", "ima", "i'mma", "imma"
    ]
    private static let whenBlockers: Set<String> = [
        "love", "loved", "loves", "like", "liked", "likes", "hate", "hated", "hates",
        "know", "knew", "knows", "remember", "forget", "forgot", "enjoy", "enjoyed"
    ]
    private static let whenObject: Set<String> = [
        "me", "him", "her", "us", "them", "em", "'em", "ya", "it", "that", "this", "you"
    ]
    private static let cuzPrevBlock: Set<String> = [
        "my", "your", "his", "our", "their", "ya", "the", "a", "an", "some", "every", "each",
        "this", "that", "these", "those", "big", "lil", "little", "young", "old", "real",
        "fake", "main", "blood", "gang", "twin", "her", "cousin"
    ]
    private static let causePrevBlock: Set<String> = [
        "the", "a", "an", "my", "your", "his", "our", "their", "some", "every", "each",
        "this", "that", "these", "those", "no", "one", "real", "good", "just"
    ]
    private static let whilePrevBlock: Set<String> = [
        "a", "the", "an", "my", "your", "his", "our", "their", "some", "every", "each"
    ]
    private static let soDegree: Set<String> = [
        "much", "many", "far", "long", "hard", "bad", "good", "well", "fast", "high",
        "low", "real", "really", "damn", "fucking", "fuckin", "fuckin'", "crazy",
        "sick", "cold", "hot", "big", "small", "little", "deep", "quick", "quickly",
        "soon", "late", "early", "close", "near", "often", "just", "very", "too",
        "more", "most", "super", "hella", "mad", "extra", "clean", "dirty", "rich",
        "poor", "sad", "happy", "dope", "fire", "soft", "loud", "tough", "ill",
        "raw", "wavy", "icy", "sweet", "thick", "thin", "tall", "short", "young",
        "old", "new", "black", "white", "red", "blue", "green", "gold", "paid",
        "broke", "drunk", "gone", "lost", "dead", "wild", "stupid", "dumb", "smart",
        "serious", "funny", "badass", "motherfucking", "mf", "goddamn", "goddam",
        "pretty", "ugly", "nice", "fine", "heavy", "light", "dark", "bright",
        "smooth", "rough", "wet", "dry", "full", "empty", "ready", "tired",
        "scared", "afraid", "proud", "sure", "alone", "asleep", "awake", "quiet",
        "silent", "busy", "easy", "harder", "faster", "bigger", "smaller", "better",
        "worse", "best", "worst", "longer", "strong", "stronger", "weak", "richer",
        "poorer", "deeper", "higher", "lower", "colder", "hotter", "fly", "fresh",
        "lit", "turnt", "out", "in", "up", "down", "off", "on", "back"
    ]
    private static let aux: Set<String> = [
        "am", "is", "are", "was", "were", "be", "been", "being",
        "do", "does", "did", "have", "has", "had",
        "can", "could", "will", "would", "shall", "should", "may", "might", "must",
        "ain't", "aint", "can't", "cant", "cannot", "don't", "dont", "won't", "wont",
        "didn't", "didnt", "isn't", "isnt", "wasn't", "wasnt", "aren't", "arent",
        "weren't", "werent", "haven't", "havent", "hasn't", "hasnt", "hadn't", "hadnt",
        "wouldn't", "wouldnt", "couldn't", "couldnt", "shouldn't", "shouldnt",
        "gonna", "gotta", "wanna", "finna", "tryna"
    ]
    private static let verbs: Set<String> = [
        "want", "wants", "wanted", "need", "needs", "needed", "got", "get", "gets",
        "getting", "gettin", "gettin'", "take", "takes", "took", "taking", "takin",
        "share", "shares", "shared", "keep", "keeps", "kept", "keeping", "hold",
        "holds", "held", "holding", "buy", "buys", "bought", "buying", "cop", "cops",
        "copped", "spend", "spends", "spent", "spending", "give", "gives", "gave",
        "given", "giving", "bring", "brings", "brought", "bringing", "make", "makes",
        "made", "making", "makin", "makin'", "love", "loves", "loved", "hate", "hates",
        "hated", "wear", "wears", "wore", "wearing", "rock", "rocks", "rocked",
        "lose", "loses", "lost", "find", "finds", "found", "use", "uses", "used",
        "pay", "pays", "paid", "sell", "sells", "sold", "smoke", "smokes", "smoked",
        "drink", "drinks", "drank", "pour", "pours", "poured", "push", "pushes",
        "pushed", "pull", "pulls", "pulled", "hit", "hits", "drop", "drops", "dropped",
        "pick", "picks", "picked", "catch", "catches", "caught", "leave", "leaves",
        "left", "order", "orders", "ordered", "grab", "grabs", "grabbed", "send",
        "sends", "sent", "show", "shows", "showed", "call", "calls", "called",
        "count", "counts", "counted", "ride", "rides", "rode", "riding", "drive",
        "drives", "drove", "eat", "eats", "ate", "cut", "cuts", "break", "breaks",
        "broke", "broken", "build", "builds", "built", "carry", "carries", "carried",
        "throw", "throws", "threw", "flip", "flips", "flipped", "stack", "stacks",
        "stacked", "bag", "bags", "bagged", "cook", "cooks", "cooked", "serve",
        "serves", "served", "load", "loads", "loaded", "shoot", "shoots", "shot",
        "bust", "busts", "clap", "claps", "clapped", "pop", "pops", "popped",
        "grip", "grips", "gripped", "touch", "touches", "touched", "kiss", "kisses",
        "kissed", "fuck", "fucks", "fucked", "suck", "sucks", "sucked", "lick",
        "licks", "licked", "taste", "tastes", "tasted", "smell", "smells", "smelled",
        "read", "reads", "write", "writes", "wrote", "play", "plays", "played",
        "watch", "watches", "watched", "move", "moves", "moved", "change", "changes",
        "changed", "open", "opens", "opened", "close", "closes", "closed", "start",
        "starts", "started", "stop", "stops", "stopped", "try", "tries", "tried",
        "let", "lets", "put", "puts", "set", "sets", "mean", "means", "meant",
        "meaning", "fall", "falls", "fell", "fallen", "falling", "say", "says",
        "said", "saying", "see", "sees", "saw", "seen", "seeing", "know", "knows",
        "knew", "knowing", "think", "thinks", "thought", "thinking", "tell", "tells",
        "told", "telling", "come", "comes", "came", "coming", "go", "goes", "going",
        "gone", "went", "run", "runs", "ran", "running", "feel", "feels", "felt",
        "feeling", "look", "looks", "looked", "looking", "talk", "talks", "talked",
        "talking", "walk", "walks", "walked", "walking", "stay", "stays", "stayed",
        "live", "lives", "lived", "living", "turn", "turns", "turned", "sit", "sits",
        "sat", "stand", "stands", "stood", "hear", "hears", "heard", "bring",
        "follow", "follows", "followed", "kill", "kills", "killed", "die", "dies",
        "died", "grow", "grows", "grew", "grown", "speak", "speaks", "spoke",
        "steal", "steals", "stole", "stolen", "stealin", "stealin'", "choose",
        "chose", "wake", "woke", "win", "won", "meet", "met", "lead", "led",
        "fight", "fought", "sleep", "slept", "teach", "taught", "seek", "sought",
        "shake", "shook", "strike", "struck", "swing", "swung", "swim", "swam",
        "sing", "sang", "ring", "rang", "rise", "rose", "arise", "arose", "bear",
        "bore", "beat", "bind", "bound", "bleed", "bled", "blow", "blew", "draw",
        "drew", "feed", "fed", "flee", "fled", "freeze", "froze", "hang", "hung",
        "hide", "hid", "lay", "laid", "lie", "light", "lit", "quit", "split",
        "spread", "shut", "hurt", "cost", "cast", "bet", "slide", "slid", "bite",
        "bit", "deal", "dealt", "creep", "crept", "sweep", "swept", "weep", "wept",
        "lend", "lent", "bend", "bent", "build", "spend", "send", "leave", "keep",
        "mean", "feel", "dream", "dreamt", "burn", "burnt", "learn", "learnt"
    ]
}

private extension UInt16 {
    var isDigit: Bool {
        self >= UInt16(UnicodeScalar("0").value) && self <= UInt16(UnicodeScalar("9").value)
    }
}

/// Faint comma drawn in the gap before a starter. Tap inserts one real comma.
struct CommaHintOverlay: UIViewRepresentable {
    var text: String
    var enabled: Bool

    func makeUIView(context: Context) -> Host {
        let host = Host()
        host.backgroundColor = .clear
        host.isOpaque = false
        host.isUserInteractionEnabled = true
        host.text = text
        host.enabled = enabled
        return host
    }

    func updateUIView(_ uiView: Host, context: Context) {
        uiView.text = text
        uiView.enabled = enabled
        uiView.setNeedsLayout()
        DispatchQueue.main.async {
            uiView.setNeedsLayout()
        }
    }

    final class Host: UIView {
        var text = ""
        var enabled = true
        private var marks: [Mark] = []

        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            marks.contains { !$0.isHidden && $0.frame.contains(point) }
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            marks.first { !$0.isHidden && $0.frame.contains(point) }
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            setNeedsLayout()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            relayout()
        }

        private func relayout() {
            let hints = enabled ? CommaHintEngine.hints(inText: text) : []
            while marks.count < hints.count {
                let mark = Mark()
                addSubview(mark)
                marks.append(mark)
            }
            for mark in marks { mark.isHidden = true }
            guard enabled, let textView = findWritingTextView() else { return }
            textView.layoutManager.ensureLayout(for: textView.textContainer)
            let ns = (textView.text ?? "") as NSString
            for (index, hint) in hints.enumerated() {
                guard hint.utf16Location >= 0, hint.utf16Location < ns.length else { continue }
                guard let rect = glyphRect(at: hint.utf16Location, in: textView) else { continue }
                let mark = marks[index]
                let font = textView.font ?? .systemFont(ofSize: 17)
                let side = max(font.pointSize, 17)
                mark.titleLabel?.font = font
                let frame = CGRect(
                    x: rect.minX - side * 0.72,
                    y: rect.midY - side * 0.55,
                    width: side,
                    height: side
                )
                mark.frame = convert(frame, from: textView)
                mark.word = hint.word
                mark.utf16Location = hint.utf16Location
                mark.isHidden = false
                mark.accessibilityLabel = "Comma hint before \(hint.word)"
            }
        }

        private func glyphRect(at location: Int, in textView: UITextView) -> CGRect? {
            let layout = textView.layoutManager
            let container = textView.textContainer
            let glyph = layout.glyphIndexForCharacter(at: location)
            guard glyph != NSNotFound, glyph < layout.numberOfGlyphs else { return nil }
            var rect = layout.boundingRect(
                forGlyphRange: NSRange(location: glyph, length: 1),
                in: container
            )
            rect.origin.x += textView.textContainerInset.left
            rect.origin.y += textView.textContainerInset.top
            return rect
        }

        private func findWritingTextView() -> UITextView? {
            if let live = EditorWritingMetrics.activeTextView { return live }
            var node: UIView? = superview
            var depth = 0
            while let current = node, depth < 16 {
                if let found = search(current) { return found }
                node = current.superview
                depth += 1
            }
            return nil
        }

        private func search(_ view: UIView) -> UITextView? {
            if let textView = view as? UITextView, textView.isEditable { return textView }
            for sub in view.subviews {
                if let found = search(sub) { return found }
            }
            return nil
        }
    }

    final class Mark: UIButton {
        var utf16Location = 0
        var word = ""

        override init(frame: CGRect) {
            super.init(frame: frame)
            setTitle(",", for: .normal)
            setTitleColor(UIColor.secondaryLabel.withAlphaComponent(0.55), for: .normal)
            titleLabel?.font = .systemFont(ofSize: 22, weight: .regular)
            backgroundColor = .clear
            addTarget(self, action: #selector(insertComma), for: .touchUpInside)
        }

        required init?(coder: NSCoder) { return nil }

        @objc private func insertComma() {
            guard let textView = EditorWritingMetrics.activeTextView else { return }
            let ns = (textView.text ?? "") as NSString
            guard utf16Location >= 0, utf16Location <= ns.length else { return }
            if utf16Location > 0 {
                let prev = ns.substring(with: NSRange(location: utf16Location - 1, length: 1))
                if prev == "," || prev == "，" { return }
            }
            textView.becomeFirstResponder()
            textView.selectedRange = NSRange(location: utf16Location, length: 0)
            textView.insertText(",")
        }
    }
}
