import XCTest
@testable import XJournal_AI

final class CatalogArtistSortTests: XCTestCase {
    func testDisplayOrderIsAlphabeticalIgnoringArticles() {
        let input = [
            "Lil Wayne",
            "Quality Control",
            "Lil Uzi Vert",
            "Rick Ross",
            "Juice WRLD",
            "The Weeknd",
            "Drake",
            "A$AP Rocky"
        ]
        let ordered = CatalogArtistSort.displayOrdered(input)
        XCTAssertEqual(ordered.first, "A$AP Rocky")
        XCTAssertLessThan(
            ordered.firstIndex(of: "Drake") ?? 99,
            ordered.firstIndex(of: "Juice WRLD") ?? 0
        )
        XCTAssertLessThan(
            ordered.firstIndex(of: "Juice WRLD") ?? 99,
            ordered.firstIndex(of: "Lil Wayne") ?? 0
        )
        XCTAssertEqual(ordered.last, "The Weeknd")
        XCTAssertEqual(Set(ordered), Set(input), "Count and membership stay the same")
    }

    func testStoreOrderIsNotRequiredToBeAlphabetical() {
        // artistNames() stays popularity-based; only the sheet sorts.
        XCTAssertEqual(CatalogArtistSort.sortKey("The Weeknd"), "weeknd")
        XCTAssertEqual(CatalogArtistSort.sortKey("Lil Wayne"), "lil wayne")
    }
}
