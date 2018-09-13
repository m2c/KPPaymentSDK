//
//  KPPaymentApplicationDelegate.swift
//  KPPaymentSDK
//
//  Created by Zaid M. Said on 01/04/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

import UIKit

internal protocol KPPaymentAppDelegate : NSObjectProtocol {
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
}

@objc public final class KPPaymentApplicationDelegate : NSObject {
    @objc public static let shared = KPPaymentApplicationDelegate()

    internal weak var delegate: KPPaymentAppDelegate?

    private override init() {}

    @objc @discardableResult public final func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        guard let scheme = url.scheme else {
            return false
        }

        let schemes = scheme.components(separatedBy: ".")

        if schemes.first == "kiple" {
            self.delegate?.application(app, open: url, options: options)
            return true
        }
        return false
    }
}
