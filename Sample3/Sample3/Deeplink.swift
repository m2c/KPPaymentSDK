//
//  Deeplink.swift
//  Sample3
//
//  Created by Zaid M. Said on 01/04/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

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
