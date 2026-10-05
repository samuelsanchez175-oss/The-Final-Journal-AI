import XCTest
@testable import XJournal_AI

final class ProfileMarketingFormClientTests: XCTestCase {
    func testFormBodyIncludesEmailMarketingAndOptionalFields() {
        let body = ProfileMarketingFormClient.formBody(for: .init(
            name: "Sam",
            email: "sam@example.com",
            phone: "(555) 010-0199",
            marketingOptIn: true
        ))
        XCTAssertTrue(body.contains("emailAddress=sam@example.com"))
        XCTAssertTrue(body.contains("entry.15172110=Sam"))
        XCTAssertTrue(body.contains("entry.1702062212="))
        XCTAssertTrue(body.contains("010-0199") || body.contains("010%2D0199"))
        XCTAssertTrue(body.contains("entry.1573850206=Yes"))
    }

    func testFormBodyOmitsEmptyNameAndPhone() {
        let body = ProfileMarketingFormClient.formBody(for: .init(
            name: "  ",
            email: "only@example.com",
            phone: "",
            marketingOptIn: false
        ))
        XCTAssertTrue(body.contains("emailAddress=only@example.com"))
        XCTAssertTrue(body.contains("entry.1573850206=No"))
        XCTAssertFalse(body.contains("entry.15172110="))
        XCTAssertFalse(body.contains("entry.1702062212="))
    }

    func testSignatureIsStableForSamePayload() {
        let payload = ProfileMarketingFormClient.Payload(
            name: "Sam",
            email: "Sam@Example.com",
            phone: "1",
            marketingOptIn: false
        )
        let a = ProfileMarketingFormClient.signature(for: payload)
        let b = ProfileMarketingFormClient.signature(for: .init(
            name: "Sam",
            email: "sam@example.com",
            phone: "1",
            marketingOptIn: false
        ))
        XCTAssertEqual(a, b)
    }
}
