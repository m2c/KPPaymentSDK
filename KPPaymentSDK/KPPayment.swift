//
//  KPPayment.swift
//  KPPaymentSDK
//
//  Created by Zaid M. Said on 01/04/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

import UIKit

@objc public protocol KPPaymentDelegate: class {
    func paymentDidFinishSuccessfully(_ flag: Bool, withMessage message: String, andPayload payload: [String : Any])
}

private protocol KPPaymentAppDelegate: class {
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any])
}

@objc public final class KPPaymentApplicationDelegate: NSObject {
    @objc public static let shared = KPPaymentApplicationDelegate()

    fileprivate weak var delegate: KPPaymentAppDelegate?

    private override init() {}

    @objc public final func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
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

@objc public final class KPPayment: NSObject, KPPaymentAppDelegate {
    private let merchantId: Int
    private let secret: String
    private let isProduction: Bool
    private var referenceId: String?

    @objc public weak var delegate: KPPaymentDelegate?

    @objc public init(merchantId: NSInteger, secret: String, isProduction: Bool) {
        self.merchantId = merchantId
        self.secret = secret
        self.isProduction = isProduction
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        KPPaymentApplicationDelegate.shared.delegate = self
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        KPPaymentApplicationDelegate.shared.delegate = nil
    }

    @objc public final func makePaymentForStoreId(_ storeId: NSInteger, withReferenceId referenceId: String, andAmount amount: Double) {
        self.referenceId = referenceId
        var baseURL = "https://sandbox.webcash.com.my" // TODO: change to staging URL
        if self.isProduction {
            baseURL = "https://sandbox.webcash.com.my" // TODO: change to production URL
        }
        let checkSum = (self.secret + String(self.merchantId) + String(storeId) + String(format: "%.2f", amount.rounded(toPlaces: 2)) + referenceId).sha1()
        if let appURL = URL(string: "\(baseURL)/ios?MerchantId=\(String(self.merchantId))&StoreId=\(String(storeId))&Amount=\(String(format: "%.2f", amount.rounded(toPlaces: 2)))&ReferenceId=\(referenceId)&CheckSum=\(checkSum)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL) { success in
                    if !success {
                        self.delegate?.paymentDidFinishSuccessfully(false, withMessage: "Unable to redirect to kiplePay", andPayload: [:])
                    }
                }
            } else {
                if UIApplication.shared.canOpenURL(appURL) {
                    UIApplication.shared.openURL(appURL)
                } else {
                    self.delegate?.paymentDidFinishSuccessfully(false, withMessage: "Unable to redirect to kiplePay", andPayload: [:])
                }
            }
        } else {
            self.delegate?.paymentDidFinishSuccessfully(false, withMessage: "Unable to redirect to kiplePay", andPayload: [:])
        }
    }

    @objc private final func applicationDidBecomeActive(_ notification: Notification) {
        if let _ = self.referenceId {
            self.referenceId = nil
            self.delegate?.paymentDidFinishSuccessfully(true, withMessage: "Success", andPayload: [:])
        }
    }

    fileprivate final func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        var queryParams = [String: String]()
        if let queryItems = components.queryItems {
            for queryItem: URLQueryItem in queryItems {
                if queryItem.value == nil {
                    continue
                }
                queryParams[queryItem.name] = queryItem.value
            }
            if queryParams["success"] == "true" {
                self.referenceId = nil
                self.delegate?.paymentDidFinishSuccessfully(true, withMessage: "Success", andPayload: [:])
            } else {
                self.delegate?.paymentDidFinishSuccessfully(false, withMessage: "Unsuccessful payment from kiplePay", andPayload: [:])
            }
        } else {
            self.delegate?.paymentDidFinishSuccessfully(false, withMessage: "No response from kiplePay", andPayload: [:])
        }
    }
}

fileprivate extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
