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

import UIKit

public extension KPPayment {

    /// Specifies the payment type of a payment object.
    @objc enum KPPaymentType : Int, CaseIterable {

        /// Represents payment.
        case Payment

        /// Represents mobile reload payment type.
        case MobileReload

        /// Represents pay bill payment type.
        case PayBill

        /// Method to convert enum type to string type.
        ///
        /// - Returns: String representation of payment type.
        public func toString() -> String {
            switch self {
            case .Payment:
                return "Payment"
            case .MobileReload:
                return "MobileReload"
            case .PayBill:
                return "PayBill"
            }
        }

        /// Method to convert enum type to lowercased string type.
        ///
        /// - Returns: Lowercased string representation of payment type.
        public func toLowercasedString() -> String {
            return self.toString().lowercased()
        }

        /// Implemented by subclasses to initialize a new enum object immediately after memory for it has been allocated, if able.
        ///
        /// - Parameter string: String representation of payment type.
        public init?(stringValue string: String) {
            for c in KPPaymentType.allCases {
                if c.toString() == string {
                    self = c
                }
            }
            return nil
        }
    }

    /// Specifies the payment status of a payment object.
    @objc enum KPPaymentStatus : Int, CaseIterable {

        /// Represents successful transaction.
        case Successful

        /// Represents pending transaction.
        case Pending

        /// Represents failed transaction.
        case Failed

        /// Represents cancelled transaction.
        case Cancelled

        /// Method to convert enum type to string type.
        ///
        /// - Returns: String representation of payment status.
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

        /// Implemented by subclasses to initialize a new enum object immediately after memory for it has been allocated, if able.
        ///
        /// - Parameter string: String representation of payment status.
        public init?(stringValue string: String) {
            for c in KPPaymentStatus.allCases {
                if c.toString() == string {
                    self = c
                }
            }
            return nil
        }
    }

    /// Method that will perform transaction with kiplePay's App. Will redirect to kiplePay App if installed.
    ///
    /// - Parameters:
    ///   - storeId: kiplePay's storeId.
    ///   - type: The payment type enum.
    ///   - referenceId: Unique referenceId generated from sender to keep track of transaction details.
    ///   - amount: Double representation of transation amount (will be rounded to two decimal places).
    @objc final func makePaymentForStoreId(_ storeId: NSInteger, withType type: KPPaymentType, withReferenceId referenceId: String, andAmount amount: Double) {
        self.storeId = storeId
        self.referenceId = referenceId
        self.type = type

        let baseURL = self.isProduction ? Constant.productionPaymentBaseURL : Constant.stagingPaymentBaseURL
        let param1 = self.secret
        let param2 = String(self.merchantId)
        let param3 = String(storeId)
        let param4 = String(format: "%.2f", amount.rounded(toPlaces: 2))
        let param5 = referenceId
        let param6 = type.rawValue
        let param7 = type.toString()
        let checkSum = (param2 + param7 + param3 + param4 + param5 + param1).sha1()

        if let appURL = URL(string: "\(baseURL)/ios?MerchantId=\(param2)&StoreId=\(param3)&Amount=\(param4)&ReferenceId=\(param5)&CheckSum=\(checkSum)&Type=\(param6)") {
            self.engine.open(url: appURL) { (success) in
                if !success {
                    self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.unableRedirect, andPayload: [:])
                }
            }
        } else {
            self.delegate?.paymentDidFinishSuccessfully(false, withMessage: Constant.unableRedirect, andPayload: [:])
        }
    }

    /// Method that will check transaction details based on referenceId.
    ///
    /// - Parameters:
    ///   - referenceId: Unique referenceId generated from sender to keep track of transaction details.
    ///   - completionHandler: The block to execute with the results.
    ///                        Provide a value for this parameter if you want to inspect the payload of the transaction details.
    ///                        This block is executed asynchronously on your app's main thread.
    ///                        The block has no return value and takes the following parameter:
    ///   - payload: A string valued dictionary of the transaction details based on referenceId.
    ///              The key for the dictionary are if unsuccessful: Error; if successful:
    ///              Status, Amount, TransactionId, TradeDate, ReferenceId, StoreId.
    @objc final func transactionStatusForReferenceId(_ referenceId: String, completionHandler: @escaping (_ payload: [String : String]) -> Void) {
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

internal class URLEngine {
    class func open(url: URL, completionHandler: @escaping (Bool) -> Void) {
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, completionHandler: completionHandler)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            completionHandler(false)
        }
    }
}

fileprivate extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
