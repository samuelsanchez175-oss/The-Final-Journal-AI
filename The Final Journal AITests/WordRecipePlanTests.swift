import XCTest
@testable import XJournal_AI

final class WordRecipePlanTests: XCTestCase {
    func testFromJSONObjectBackCompatWithoutRecipe() {
        let plan = VersePlan.fromJSONObject([
            "centralImage": "first week checks",
            "angle": "nothing to something",
            "anchorRhymes": ["eck", "et"]
        ])
        XCTAssertEqual(plan.centralImage, "first week checks")
        XCTAssertEqual(plan.anchorRhymes, ["eck", "et"])
        XCTAssertNil(plan.wordRecipe)
        XCTAssertNil(plan.semanticCage)
    }

    func testFromJSONObjectParsesRecipeAndCage() {
        let plan = VersePlan.fromJSONObject([
            "centralImage": "scrolls and sights",
            "angle": "old light / new scope",
            "anchorRhymes": ["ope", "otes"],
            "wordRecipe": [
                "seed": "laser",
                "meanings": ["firearm sight", "Herculaneum light"],
                "rimeFamily": ["scope", "notes", "hope"],
                "culturalRef": "Herculaneum scrolls",
                "combinedImage": "working laser and scope / Herculaneum notes"
            ],
            "semanticCage": [
                "sound": "switch",
                "senses": ["swap", "walk", "pistol", "circuit"]
            ]
        ])
        XCTAssertEqual(plan.wordRecipe?.seed, "laser")
        XCTAssertEqual(plan.wordRecipe?.combinedImage, "working laser and scope / Herculaneum notes")
        XCTAssertEqual(plan.semanticCage?.sound, "switch")
        XCTAssertEqual(plan.semanticCage?.senses.count, 4)
        XCTAssertTrue(plan.wordRecipe?.isUsable == true)
        XCTAssertTrue(plan.semanticCage?.isUsable == true)
    }

    func testEmptyRecipeObjectIsDropped() {
        let plan = VersePlan.fromJSONObject([
            "centralImage": "x",
            "angle": "y",
            "anchorRhymes": ["z"],
            "wordRecipe": ["seed": "laser", "combinedImage": "  "]
        ])
        XCTAssertNil(plan.wordRecipe)
    }

    func testSingleMustUseBecomesRecipeSeedNotCage() {
        let params = DirectedGenerationParams(mustUseTokens: ["laser"])
        XCTAssertEqual(params.resolvedRecipeSeed, "laser")
        XCTAssertTrue(params.resolvedKeywordCage.isEmpty)
        XCTAssertTrue(params.resolvedMustUseVerbatim.isEmpty)
    }

    func testFourMustUseBecomesKeywordCage() {
        let params = DirectedGenerationParams(mustUseTokens: ["drip", "ice", "whip", "trap"])
        XCTAssertTrue(params.resolvedRecipeSeed.isEmpty)
        XCTAssertEqual(params.resolvedKeywordCage.count, 4)
        XCTAssertTrue(params.resolvedMustUseVerbatim.isEmpty)
    }

    func testExplicitRecipeSeedWinsOverMustUse() {
        let params = DirectedGenerationParams(mustUseTokens: ["ice"], recipeSeed: "switch")
        XCTAssertEqual(params.resolvedRecipeSeed, "switch")
        XCTAssertEqual(params.resolvedMustUseVerbatim, ["ice"])
    }

    func testCageSoundFallsBackToRecipeSeed() {
        let params = DirectedGenerationParams(recipeSeed: "switch")
        XCTAssertEqual(params.resolvedSemanticSound, "switch")
    }
}
