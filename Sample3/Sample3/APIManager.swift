//
//  APIManager.swift
//  Sample3
//
//  Created by Zaid M. Said on 01/04/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

import Foundation

struct APIManager {
    static let shared = APIManager()

    private init() {}

    func postGenerateDeeplink(
        deeplinkObj: Deeplink,
        success: @escaping (_ deeplinkModelObj: Deeplink) -> Void,
        failure: @escaping (_ serverError: String) -> Void
        ) {
        print(#function)
        let generateDeeplinkURLString = Constant.generateDeeplinkURL
        let headers = ["Content-Type": "application/json"]
        if let generateDeeplinkURL = URL(string: generateDeeplinkURLString) {
            APIRequest.request(url: generateDeeplinkURL, method: .post, parameters: deeplinkObj.toDictionary(), headers: headers) { (response) in
                guard response.result.isSuccess else {
                    failure((response.result.error?.localizedDescription)!)
                    return
                }

                guard let value = response.result.value,
                    let responseDictionary = value as? [String: Any] else {
                        failure(Constant.Message.failureDefault)
                        return
                }

                let deeplinkModelObj = Deeplink(fromDictionary: responseDictionary)

                if deeplinkModelObj.deeplinkURL == nil {
                    let message = deeplinkModelObj.message ?? Constant.Message.failureDefault
                    failure(message)
                    return
                } else {
                    success(deeplinkModelObj)
                    return
                }
            }
        }
    }
}
