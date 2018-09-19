//
//  KPPayment+Extension.swift
//  KPPaymentSDK
//
//  Created by Zaid M. Said on 01/04/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

import Foundation

public extension KPPayment {
    @objc public enum KPPaymentStatus : Int {
        case Successful
        case Pending
        case Failed
        case Cancelled

        public func toString() -> String {
            switch self {
            case .Successful:
                return "Successful"
            case .Pending:
                return "Pending"
            case .Failed:
                return "Failed"
            case .Cancelled:
                return "Cancelled"
            }
        }

        public static func status(fromString string: String) -> KPPaymentStatus? {
            for c in KPPaymentStatus.allValues {
                if c.toString() == string {
                    return c
                }
            }
            return nil
        }

        public static let allValues: [KPPaymentStatus] = {
            var elements: [KPPaymentStatus] = []
            for i in 0...KPPaymentStatus.count - 1 {
                if let menu = KPPaymentStatus(rawValue: i) {
                    elements.append(menu)
                }
            }
            return elements
        }()

        public static let count: Int = {
            var max: Int = 0
            while let _ = KPPaymentStatus(rawValue: max) { max += 1 }
            return max
        }()
    }

    @objc public final func makePaymentForStoreId(_ storeId: NSInteger, withReferenceId referenceId: String, andAmount amount: Double) {
        self.storeId = storeId
        self.referenceId = referenceId

        let baseURL = self.isProduction ? Constant.productionPaymentBaseURL : Constant.stagingPaymentBaseURL
        let param1 = self.secret
        let param2 = String(self.merchantId)
        let param3 = String(storeId)
        let param4 = String(format: "%.2f", amount.rounded(toPlaces: 2))
        let param5 = referenceId
        let checkSum = (param1 + param2 + param3 + param4 + param5).sha1()

        if let appURL = URL(string: "\(baseURL)/ios?MerchantId=\(param2)&StoreId=\(param3)&Amount=\(param4)&ReferenceId=\(param5)&CheckSum=\(checkSum)") {
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
        let baseURL = self.isProduction ? Constant.productionStatusBaseURL : Constant.stagingStatusBaseURL
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
                        if let d = data {
                            if let responseDictionary = try JSONSerialization.jsonObject(with: d, options: []) as? [String : Any] {
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
                        } else {
                            queryParams["Error"] = Constant.noResponse
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
}

fileprivate extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
