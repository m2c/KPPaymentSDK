import XCTest
@testable import KPPaymentSDK

final class KPPaymentSDKTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(KPPaymentSDK().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
