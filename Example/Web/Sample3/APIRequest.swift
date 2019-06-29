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

enum APIMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

enum APIResult {
    case success(Any)
    case failure(Error)

    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    var isFailure: Bool {
        return !isSuccess
    }

    var value: Any? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

struct APIResponse {
    let request: URLRequest?
    let data: Data?
    let response: URLResponse?
    let result: APIResult

    var value: Any? { return self.result.value }
    var error: Error? { return self.result.error }

    init(
        request: URLRequest?,
        data: Data?,
        response: URLResponse?,
        result: APIResult)
    {
        self.request = request
        self.response = response
        self.data = data
        self.result = result
    }
}

struct APIRequest {
    static let shared = APIRequest()

    private init() {}

    static func request(
        url: URL,
        method: APIMethod,
        parameters: [String: Any]?,
        headers: [String: String]?,
        completionHandler: @escaping (_ response: APIResponse) -> Void
        ) {
        var request = URLRequest(url: url)
        if let h = headers {
            for header in h {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        request.httpMethod = method.rawValue

        if let p = parameters {
            do {
                if let data = try JSONSerialization.data(withJSONObject: p, options: JSONSerialization.WritingOptions(rawValue: 0)) as Data? {
                    request.httpBody = data
                }
            } catch {
                let result = APIResult.failure(error)
                let r = APIResponse(request: request, data: nil, response: nil, result: result)
                completionHandler(r)
                return
            }
        }

        let dataTask = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let e = error {
                let result = APIResult.failure(e)
                let r = APIResponse(request: request, data: data, response: response, result: result)
                DispatchQueue.main.async {
                    completionHandler(r)
                    return
                }
            } else {
                do {
                    if let responseDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        if !responseDictionary.isEmpty {
                            let result = APIResult.success(responseDictionary as Any)
                            let r = APIResponse(request: request, data: data, response: response, result: result)
                            DispatchQueue.main.async {
                                completionHandler(r)
                                return
                            }
                        } else {
                            let e = NSError(domain: "", code: 0, userInfo: [
                                NSLocalizedDescriptionKey: NSLocalizedString("Error", value: Constant.Message.failureDefault, comment: "") ,
                                NSLocalizedFailureReasonErrorKey: NSLocalizedString("Error", value: Constant.Message.failureDefault, comment: "")
                                ])
                            let result = APIResult.failure(e)
                            let r = APIResponse(request: request, data: data, response: response, result: result)
                            DispatchQueue.main.async {
                                completionHandler(r)
                                return
                            }
                        }
                    } else {
                        let e = NSError(domain: "", code: 0, userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString("Error", value: Constant.Message.failureDefault, comment: "") ,
                            NSLocalizedFailureReasonErrorKey: NSLocalizedString("Error", value: Constant.Message.failureDefault, comment: "")
                            ])
                        let result = APIResult.failure(e)
                        let r = APIResponse(request: request, data: data, response: response, result: result)
                        DispatchQueue.main.async {
                            completionHandler(r)
                            return
                        }
                    }
                } catch {
                    let result = APIResult.failure(error)
                    let r = APIResponse(request: request, data: data, response: response, result: result)
                    DispatchQueue.main.async {
                        completionHandler(r)
                        return
                    }
                }
            }
        }
        dataTask.resume()
    }
}
