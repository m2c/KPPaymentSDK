//  Copyright © 2019 Kiple Sdn Bhd. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import XCTest
@testable import KPPaymentSDK

final class KPPaymentSDKTests: XCTestCase {

    var sut: KPPayment!
    var engineSpy: URLEngineSpy.Type!

    override func setUp() {
        super.setUp()
        self.sut = KPPayment(merchantId: 141, secret: "l43wrf8cai", isProduction: false)
        self.engineSpy = URLEngineSpy.self
        self.engineSpy.openURLCalled = false
        self.engineSpy.openURLValue = nil
        self.sut.engine = self.engineSpy
    }

    override func tearDown() {
        self.sut = nil
        self.engineSpy = nil
        super.tearDown()
    }

    func testMakePayment() {
        // given
        let expectedResult = true
        let storeID = 103
        let paymentType: KPPayment.KPPaymentType = .Payment
        let referenceId = "abcd\(Int(arc4random_uniform(UInt32(9999))))"
        let amount = 12.34

        // when
        self.sut.makePaymentForStoreId(storeID, withType: paymentType, withReferenceId: referenceId, andAmount: amount)
        let actualResult = self.engineSpy.openURLCalled

        // then
        XCTAssertEqual(actualResult, expectedResult, "makePayment should make payment")
    }

    static var allTests = [
        ("testExample", testMakePayment),
    ]
}

extension KPPaymentSDKTests {
    final class URLEngineSpy: URLEngine {
        static var openURLCalled = false
        static var openURLValue: URL!
        override class func open(url: URL, completionHandler: @escaping (Bool) -> Void) {
            self.openURLCalled = true
            self.openURLValue = url
        }
    }
}
