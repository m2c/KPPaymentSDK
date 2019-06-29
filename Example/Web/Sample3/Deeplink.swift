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

import Foundation

struct Deeplink : Codable {
    let type: Int?
    let merchantId: Int?
    let storeId: Int?
    let amount: Float?
    let referenceId: String?
    let checkSum: String?
    let deeplinkURL: String?
    let createAt: Date?
    var message: String?

    init(type: Int = 0, merchantId: Int = 0, storeId: Int = 0, amount: Float = 0.0, referenceId: String = "", checkSum: String = "") {
        self.type = type
        self.merchantId = merchantId
        self.storeId = storeId
        self.amount = amount
        self.referenceId = referenceId
        self.checkSum = checkSum
        self.deeplinkURL = nil
        self.createAt = nil
        self.message = nil
    }

    init(fromDictionary dictionary: [String: Any]) {
        self.deeplinkURL = dictionary["DeepLinkUrl"] as? String
        self.createAt = (dictionary["CreateAt"] as? String)?.formattedKiple
        self.referenceId = dictionary["ReferenceId"] as? String
        self.checkSum = dictionary["CheckSum"] as? String
        self.message = dictionary["Message"] as? String
        self.merchantId = nil
        self.storeId = nil
        self.amount = nil
        self.type = nil
    }

    func toDictionary() -> [String: Any] {
        print(#function)
        var dictionary = [String: Any]()
        if type != nil {
            dictionary["Type"] = type
        }
        if merchantId != nil {
            dictionary["MerchantId"] = merchantId
        }
        if storeId != nil {
            dictionary["StoreId"] = storeId
        }
        if amount != nil {
            dictionary["Amount"] = amount
        }
        if referenceId != nil {
            dictionary["ReferenceId"] = referenceId
        }
        if checkSum != nil {
            dictionary["CheckSum"] = checkSum
        }
        print(dictionary)
        return dictionary
    }
}
