//
//  Constant.swift
//  Sample3
//
//  Created by Zaid M. Said on 01/04/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

import Foundation

struct Constant {
    struct Message {
        static let failureDefault = "We're sorry, but something went wrong."
    }

    static let generateDeeplinkURL = "https://sandbox.kiplepay.com:94/api/deeplinks/generate"
}

extension String {
    var formattedKiple: Date {
        if let date = String.formatterKiple.date(from: self) {
            return date
        } else {
            return Date()
        }
    }

    static let formatterKiple: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSzzzz"

        return formatter
    }()
}
