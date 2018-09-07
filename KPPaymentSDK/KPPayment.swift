//
//  KPPayment.swift
//  KPPaymentSDK
//
//  Created by Zaid M. Said on 01/04/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

import UIKit

@objc public protocol KPPaymentDelegate : NSObjectProtocol {
    func paymentDidFinishSuccessfully(_ flag: Bool, withMessage message: String, andPayload payload: [String : String])
}

private protocol KPPaymentAppDelegate : NSObjectProtocol {
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
}

@objc public final class KPPaymentApplicationDelegate : NSObject {
    @objc public static let shared = KPPaymentApplicationDelegate()

    fileprivate weak var delegate: KPPaymentAppDelegate?

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

@objc public final class KPPayment : NSObject, KPPaymentAppDelegate {
    private let merchantId: Int
    private let secret: String
    private let isProduction: Bool
    private var storeId: Int?
    private var referenceId: String?

    @objc public weak var delegate: KPPaymentDelegate?

    private struct Constant {
        private init() {}

        static let unableRedirect = "Unable to redirect to kiplePay"
        static let success = "Successful"
        static let failed = "Unsuccessful payment from kiplePay"
        static let noResponse = "Invalid response from kiplePay"
        static let invalidResponse = "Invalid response from kiplePay"
        static let checkSumFailed = "Check Sum failure"
    }

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
        self.storeId = storeId
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
                        self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.unableRedirect, andPayload: [:])
                    }
                }
            } else {
                if UIApplication.shared.canOpenURL(appURL) {
                    UIApplication.shared.openURL(appURL)
                } else {
                    self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.unableRedirect, andPayload: [:])
                }
            }
        } else {
            self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.unableRedirect, andPayload: [:])
        }
    }

    @objc public final func transactionStatusForReferenceId(_ referenceId: String, completionHandler: @escaping (_ payload: [String : String]) -> Void) {
        var baseURL = "https://sandbox.kiplepay.com:94" // TODO: change to staging URL
        if self.isProduction {
            baseURL = "https://sandbox.kiplepay.com:94" // TODO: change to production URL
        }
        if let appURL = URL(string: "\(baseURL)/api/wallets/me/deeplink-payment/\(self.merchantId)/\(referenceId)") {
            var request = URLRequest(url: appURL)
            request.httpMethod = "GET"

            let dataTask = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                var queryParams = [String : String]()
                if let e = error {
                    queryParams["Error"] = e.localizedDescription
                    DispatchQueue.main.async {
                        completionHandler(queryParams)
                        return
                    }
                } else {
                    do {
                        if let responseDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] {
                            if !responseDictionary.isEmpty {
                                if responseDictionary["Code"] as? String == "TRANSACTION_NOT_FOUND" {
                                    queryParams["Error"] = Constant.failed
                                } else {
                                    queryParams["Status"] = responseDictionary["Status"] as? String
                                    queryParams["Amount"] = responseDictionary["Amount"] as? String
                                    queryParams["TransactionId"] = responseDictionary["TransactionId"] as? String
                                    queryParams["TradeDate"] = responseDictionary["TradeDate"] as? String
                                    queryParams["ReferenceId"] = referenceId
                                    queryParams["StoreId"] = String(self.storeId ?? 0)
                                }
                                DispatchQueue.main.async {
                                    completionHandler(queryParams)
                                    return
                                }
                            } else {
                                queryParams["Error"] = Constant.noResponse
                                DispatchQueue.main.async {
                                    completionHandler(queryParams)
                                    return
                                }
                            }
                        } else {
                            queryParams["Error"] = Constant.invalidResponse
                            DispatchQueue.main.async {
                                completionHandler(queryParams)
                                return
                            }
                        }
                    } catch {
                        queryParams["Error"] = Constant.invalidResponse
                        DispatchQueue.main.async {
                            completionHandler(queryParams)
                            return
                        }
                    }
                }
            }
            dataTask.resume()
        }
    }

    @objc private final func applicationDidBecomeActive(_ notification: Notification) {
        if let referenceId = self.referenceId {
            self.referenceId = nil
            transactionStatusForReferenceId(referenceId) { (payload: [String : String]) in
                if payload["Status"] == "Successful" {
                    self.delegate?.paymentDidFinishSuccessfully(true, withMessage: Constant.success, andPayload: payload)
                } else {
                    self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.failed, andPayload: payload)
                }
            }
        }
    }

    fileprivate final func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        var queryParams = [String : String]()
        if let queryItems = components.queryItems {
            for queryItem: URLQueryItem in queryItems {
                if queryItem.value == nil {
                    continue
                }
                queryParams[queryItem.name] = queryItem.value
            }
            let storeId = queryParams["StoreId"]!
            let amount = queryParams["Amount"]!
            let referenceId = queryParams["ReferenceId"]!
            let transactionId = queryParams["TransactionId"]!
            let status = queryParams["Status"]!
            let checkSum = (self.secret + String(self.merchantId) + storeId + amount + referenceId + transactionId + status).sha1()
            if queryParams["CheckSum"] == checkSum {
                if queryParams["Status"] == "Successful" {
                    self.referenceId = nil
                    self.delegate?.paymentDidFinishSuccessfully(true, withMessage: Constant.success, andPayload: queryParams)
                } else if queryParams["Status"] == "Pending" {
                    if let referenceId = self.referenceId {
                        self.referenceId = nil
                        transactionStatusForReferenceId(referenceId) { (payload: [String : String]) in
                            if payload["Status"] == "Successful" {
                                self.delegate?.paymentDidFinishSuccessfully(true, withMessage: Constant.success, andPayload: payload)
                            } else {
                                self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.failed, andPayload: payload)
                            }
                        }
                    } else {
                        self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.failed, andPayload: queryParams)
                    }
                } else {
                    self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.failed, andPayload: queryParams)
                }
            } else {
                if let referenceId = self.referenceId {
                    self.referenceId = nil
                    self.delegate?.paymentDidFinishSuccessfully(false, withMessage: "\((self.secret + String(self.merchantId) + storeId + amount + referenceId + transactionId + status)) \(checkSum) \(queryParams["CheckSum"])", andPayload: queryParams)
//                    transactionStatusForReferenceId(referenceId) { (payload: [String : String]) in
//                        if payload["Status"] == "Successful" {
//                            self.delegate?.paymentDidFinishSuccessfully(true, withMessage: Constant.success, andPayload: payload)
//                        } else {
//                            self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.failed, andPayload: payload)
//                        }
//                    }
                } else {
                    self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.checkSumFailed, andPayload: queryParams)
                }
            }
        } else {
            self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.noResponse, andPayload: [:])
        }
    }
}

fileprivate extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
