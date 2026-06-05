import XCTest
@testable import XJournal_AI

final class ModelGV4ScoringTests: XCTestCase {
    func testV4CompositeUsesConfiguredWeights() {
        XCTAssertEqual(ScoringEngine.v4Composite(houseFit: 1, autoFit: 1, userFit: 1), 100.0, accuracy: 0.001)
        XCTAssertEqual(ScoringEngine.v4Composite(houseFit: 0.5, autoFit: 0.5, userFit: 0.5), 50.0, accuracy: 0.001)
        XCTAssertEqual(ScoringEngine.v4Composite(houseFit: 1, autoFit: 0, userFit: 0), 100 * ScoringEngine.v4HouseWeight, accuracy: 0.001)
        XCTAssertEqual(ScoringEngine.v4Composite(houseFit: 0, autoFit: 1, userFit: 0), 100 * ScoringEngine.v4AutoWeight, accuracy: 0.001)
        XCTAssertEqual(ScoringEngine.v4Composite(houseFit: 0, autoFit: 0, userFit: 1), 100 * ScoringEngine.v4UserWeight, accuracy: 0.001)
        XCTAssertEqual(ScoringEngine.v4HouseWeight + ScoringEngine.v4AutoWeight + ScoringEngine.v4UserWeight, 1.0, accuracy: 0.001)
    }
    func testSignatureSimRewardsOverlapWithExemplars() {
        let none = ScoringEngine.signatureSimilarity(norm: "totally unrelated words here", exemplarNorms: ["ice on my neck drippin"])
        let some = ScoringEngine.signatureSimilarity(norm: "ice on my wrist drippin", exemplarNorms: ["ice on my neck drippin"])
        XCTAssertGreaterThan(some, none)
    }
    func testSignatureCosineUsesNearestExemplarVectorClampedNonNegative() {
        // Semantic path: max cosine to the exemplar vectors, clamped ≥ 0; 0 when no vectors.
        let s = ScoringEngine.signatureSimilarity(candidateVector: [1, 0], exemplarVectors: [[0, 1], [0.8, 0.2]])
        XCTAssertEqual(s, Double(VectorMath.cosine([1, 0], [0.8, 0.2])), accuracy: 0.001)
        XCTAssertEqual(ScoringEngine.signatureSimilarity(candidateVector: [1, 0], exemplarVectors: []), 0)
        XCTAssertGreaterThanOrEqual(ScoringEngine.signatureSimilarity(candidateVector: [-1, 0], exemplarVectors: [[1, 0]]), 0)
    }
    func testSignatureShareScalesWithInspiration() {
        // Default inspiration (0.4 = the default Originality 0.6) preserves the tuned baseline.
        XCTAssertEqual(ScoringEngine.signatureShare(inspiration: 0.4), ScoringEngine.houseSignatureShare, accuracy: 0.001)
        // More "inspired" → corpus mimicry weighs more in selection; novel → less. Monotonic.
        XCTAssertGreaterThan(ScoringEngine.signatureShare(inspiration: 1.0), ScoringEngine.signatureShare(inspiration: 0.4))
        XCTAssertLessThan(ScoringEngine.signatureShare(inspiration: 0.0), ScoringEngine.signatureShare(inspiration: 0.4))
        // Clamped to a sane band (never zero-out quality, never dominate).
        XCTAssertGreaterThanOrEqual(ScoringEngine.signatureShare(inspiration: 0.0), 0.05)
        XCTAssertLessThanOrEqual(ScoringEngine.signatureShare(inspiration: 1.0), 0.6)
    }
    func testUserFitCountsMustUseAndSyllableRange() {
        let fit = ScoringEngine.userFit(text: "rolls royce with the suicide doors", mustUse: ["rolls", "doors"], topicTerms: ["royce"], syllables: 9, syllableMin: 7, syllableMax: 11)
        XCTAssertGreaterThan(fit, 0.8)
        let miss = ScoringEngine.userFit(text: "nothing matches here", mustUse: ["rolls"], topicTerms: ["royce"], syllables: 20, syllableMin: 7, syllableMax: 11)
        XCTAssertLessThan(miss, 0.34)
    }
}
