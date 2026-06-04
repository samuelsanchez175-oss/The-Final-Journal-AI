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
    func testUserFitCountsMustUseAndSyllableRange() {
        let fit = ScoringEngine.userFit(text: "rolls royce with the suicide doors", mustUse: ["rolls", "doors"], topicTerms: ["royce"], syllables: 9, syllableMin: 7, syllableMax: 11)
        XCTAssertGreaterThan(fit, 0.8)
        let miss = ScoringEngine.userFit(text: "nothing matches here", mustUse: ["rolls"], topicTerms: ["royce"], syllables: 20, syllableMin: 7, syllableMax: 11)
        XCTAssertLessThan(miss, 0.34)
    }
}
