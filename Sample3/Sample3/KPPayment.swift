//
//  KPPayment.swift
//  Sample3
//
//  Created by Zaid M. Said on 01/04/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

import UIKit
import CryptoSwift

public protocol KPPaymentDelegate: class {
    func paymentDidFinish(successfully flag: Bool, withMessage message: String)
}

public class KPPayment: NSObject {
    private let merchantId: Int
    private let storeId: Int
    private let secret: String
    private var referenceId: String?

    public weak var delegate: KPPaymentDelegate?

    public init(merchantId: Int, storeId: Int, secret: String) {
        self.merchantId = merchantId
        self.storeId = storeId
        self.secret = secret
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    public func makePayment(referenceId: String, amount: Float) {
        print(#function)
        self.referenceId = referenceId
        let param1 = self.secret
        let param2 = String(self.merchantId)
        let param3 = String(storeId)
        let param4 = String(format: "%.2f", amount.rounded(toPlaces: 2))
        let param5 = referenceId
        let param6 = 0
        let param7 = "Payment"
        let checkSum = (param2 + param7 + param3 + param4 + param5 + param1).sha1()
        let deeplink = Deeplink(type: param6, merchantId: self.merchantId, storeId: self.storeId, amount: amount, referenceId: referenceId, checkSum: checkSum)
        APIManager.shared.postGenerateDeeplink(deeplinkObj: deeplink, success: { (deeplinkModelObj: Deeplink) in
            print(deeplinkModelObj)
            if let appURLString = deeplinkModelObj.deeplinkURL, let appURL = URL(string: appURLString) {
                print(appURL)
                UIApplication.shared.open(appURL) { success in
                    if !success {
                        self.delegate?.paymentDidFinish(successfully: false, withMessage: "Unable to redirect to kiplePay")
                    }
                }
            } else {
                self.delegate?.paymentDidFinish(successfully: false, withMessage: "Unable to redirect to kiplePay")
            }
        }) { (error) in
            print(error)
            self.delegate?.paymentDidFinish(successfully: false, withMessage: error)
        }
    }

    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        if let _ = self.referenceId {
            self.delegate?.paymentDidFinish(successfully: true, withMessage: "Success")
            self.referenceId = nil
        }
    }
}

extension Float {
    func rounded(digits: Int) -> Float {
        let behavior = NSDecimalNumberHandler(roundingMode: .bankers, scale: Int16(digits), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        return NSDecimalNumber(value: self).rounding(accordingToBehavior: behavior).floatValue
    }

    func rounded(toPlaces places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
