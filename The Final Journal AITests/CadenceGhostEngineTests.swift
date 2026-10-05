import XCTest
@testable import XJournal_AI

final class CadenceGhostEngineTests: XCTestCase {

    private func row(
        _ line: String,
        syllables: Int,
        end: String,
        klass: String,
        artist: String = "Test"
    ) -> BarHitsCatalogStore.Row {
        BarHitsCatalogStore.Row(
            id: line,
            line: line,
            artist: artist,
            song: "Demo",
            syllables: syllables,
            endWord: end,
            phoneticClass: klass
        )
    }

    func testVvsPrefixYieldsBlinkInsert() {
        let query = CadenceQuery(
            currentLine: "vvs making you",
            priorLine: "ice so loud they think",
            syllablesSoFar: 4,
            targetSyllables: 5,
            elasticity: 1,
            rhymeClass: "IH1 NG K"
        )
        let slice = CadenceCatalogSlice(
            wrap: [
                row("vvs making you blink", syllables: 5, end: "blink", klass: "IH1 NG K"),
                row("vvs making you squint", syllables: 5, end: "squint", klass: "IH1 NG K"),
            ],
            meaning: []
        )
        let blend = CadenceGhostEngine.suggest(query: query, slice: slice, borrow: 0.55)
        XCTAssertEqual(blend.ghostTail, "blink")
        XCTAssertEqual(blend.suggestions.first { $0.bucket == .exact }?.insert, "blink")
    }

    func testCopyPasteUsesFullCatalogBar() {
        let query = CadenceQuery(
            currentLine: "pockets on",
            priorLine: "running out of time",
            syllablesSoFar: 3,
            targetSyllables: 5,
            elasticity: 1,
            rhymeClass: "AY1 M"
        )
        let slice = CadenceCatalogSlice(
            wrap: [row("jet fuel running low tonight", syllables: 5, end: "tonight", klass: "AY1 M")],
            meaning: []
        )
        let copy = CadenceGhostEngine.suggest(query: query, slice: slice, borrow: 1)
        let exact = copy.suggestions.first { $0.bucket == .exact }
        XCTAssertEqual(exact?.insert, "jet fuel running low tonight")
        XCTAssertEqual(exact?.replacesLine, true)
    }

    func testOriginalBorrowIsLandingWordOnly() {
        let query = CadenceQuery(
            currentLine: "vvs making you",
            priorLine: "ice so loud they think",
            syllablesSoFar: 4,
            targetSyllables: 5,
            elasticity: 1,
            rhymeClass: "IH1 NG K"
        )
        let slice = CadenceCatalogSlice(
            wrap: [row("vvs making you blink", syllables: 5, end: "blink", klass: "IH1 NG K")],
            meaning: []
        )
        let original = CadenceGhostEngine.suggest(query: query, slice: slice, borrow: 0)
        XCTAssertEqual(original.suggestions.first?.insert, "blink")
        XCTAssertEqual(original.suggestions.first?.replacesLine, false)
    }

    func testStretchAndTwistBuckets() {
        let query = CadenceQuery(
            currentLine: "glass half",
            priorLine: "nothing in the tank",
            syllablesSoFar: 2,
            targetSyllables: 5,
            elasticity: 1,
            rhymeClass: "AE1 NG K"
        )
        let slice = CadenceCatalogSlice(
            wrap: [
                row("last sip sitting in the tank", syllables: 5, end: "tank", klass: "AE1 NG K"),
                row("engine sputtering out the tank tonight", syllables: 7, end: "tonight", klass: "AE1 NG K"),
            ],
            meaning: [
                row("plane still flying on the fumes", syllables: 6, end: "fumes", klass: "UW1 M Z"),
            ]
        )
        let result = CadenceGhostEngine.suggest(query: query, slice: slice, borrow: 0.5)
        XCTAssertNotNil(result.suggestions.first { $0.bucket == .exact })
        XCTAssertNotNil(result.suggestions.first { $0.bucket == .stretch })
        XCTAssertNotNil(result.suggestions.first { $0.bucket == .twist })
        XCTAssertEqual(result.suggestions.first { $0.bucket == .twist }?.sourceLine, "plane still flying on the fumes")
    }

    func testEmptyCurrentLineDoesNotTrap() {
        XCTAssertNil(CadenceGhostEngine.makeQuery(from: "   "))
        XCTAssertNotNil(CadenceGhostEngine.makeQuery(from: "ice so loud they think\n"))
    }

    func testCompletionSuffixFromSharedPrefix() {
        XCTAssertEqual(
            CadenceGhostEngine.completionSuffix(typed: "vvs making you", catalog: "vvs making you blink"),
            "blink"
        )
    }

    func testKeptSignatureRanksAheadWhenTheCountTies() {
        let suite = UserDefaults(suiteName: "signature-memory-test")!
        let previous = SignatureMemory.store
        SignatureMemory.store = suite
        SignatureMemory.reset()
        defer {
            SignatureMemory.reset()
            SignatureMemory.store = previous
        }
        let query = CadenceQuery(
            currentLine: "otf",
            priorLine: nil,
            syllablesSoFar: 0,
            targetSyllables: 2,
            elasticity: 1,
            rhymeClass: ""
        )
        let before = CadenceGhostEngine.suggest(
            query: query,
            slice: CadenceCatalogSlice(wrap: [], meaning: []),
            borrow: 0.5
        )
        XCTAssertEqual(before.suggestions.first { $0.bucket == .signature }?.artist, "Durk")
        SignatureMemory.recordKept(personId: "noun-artist-king-von", aspectId: "otf")
        let after = CadenceGhostEngine.suggest(
            query: query,
            slice: CadenceCatalogSlice(wrap: [], meaning: []),
            borrow: 0.5
        )
        let signatureArtists = after.suggestions.filter { $0.bucket == .signature }.map(\.artist)
        XCTAssertEqual(signatureArtists.first, "Von")
        XCTAssertTrue(signatureArtists.contains("Durk"))
        XCTAssertEqual(after.ghostTail, "like Von")
    }

    func testEyeRollOffersUziSignature() {
        let query = CadenceQuery(
            currentLine: "she made my eye roll",
            priorLine: nil,
            syllablesSoFar: 5,
            targetSyllables: 8,
            elasticity: 1,
            rhymeClass: ""
        )
        let result = CadenceGhostEngine.suggest(
            query: query,
            slice: CadenceCatalogSlice(wrap: [], meaning: []),
            borrow: 0.5
        )
        let sig = result.suggestions.first { $0.bucket == .signature }
        XCTAssertEqual(sig?.insert, "like Uzi")
        XCTAssertEqual(sig?.isOriginal, true)
        XCTAssertEqual(sig?.artist, "Uzi")
        XCTAssertEqual(sig?.metaphor, "eye roll")
        XCTAssertEqual(result.ghostTail, "like Uzi")
    }

    func testSignatureRidesBesideExactWithoutStealingTheTail() {
        let query = CadenceQuery(
            currentLine: "she made my eye roll",
            priorLine: nil,
            syllablesSoFar: 5,
            targetSyllables: 6,
            elasticity: 1,
            rhymeClass: "OH1 L"
        )
        let slice = CadenceCatalogSlice(
            wrap: [row("she made my eye roll cold", syllables: 6, end: "cold", klass: "OH1 L")],
            meaning: []
        )
        let result = CadenceGhostEngine.suggest(query: query, slice: slice, borrow: 0.55)
        XCTAssertEqual(result.ghostTail, "cold")
        XCTAssertEqual(result.suggestions.first { $0.bucket == .signature }?.insert, "like Uzi")
    }

    func testReplacingCurrentLinePastesOntoFreshLine() {
        let out = GhostSuggestionEngine.replacingCurrentLine("blink twice", in: "ice so loud they think\n")
        XCTAssertEqual(out, "ice so loud they think\nblink twice")
    }
}
