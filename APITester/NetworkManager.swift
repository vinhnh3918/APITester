//
//  NetworkManager.swift
//  APITester
//
//  Created by Nguyen Vinh on 23/11/24.
//

import Alamofire
import SwiftUI

class NetworkManager: ObservableObject {
    @Published var response: String = ""
    @Published var headers: [String: String] = [:]
    @Published var cookies: String = ""
    @Published var errorMessage: String? = nil
    
    /// Common function for making API requests
    /// - Parameters:
    ///   - url: The endpoint URL
    ///   - method: HTTP method (default is `.get`)
    ///   - headers: HTTP headers
    ///   - parameters: Request parameters
    ///   - proxy: Optional proxy settings
    ///   - completion: Completion handler to notify when the request is finished
    func requestAPI(
        url: String,
        method: HTTPMethod = .get,
        headers: HTTPHeaders? = nil,
        parameters: Parameters? = nil,
        proxy: [String: Any]? = nil,
        completion: @escaping ([String: String]?, String?, String?, String?) -> Void
    ) {
        // Apply proxy settings if provided
        if let proxy = proxy {
            Session.default.sessionConfiguration.connectionProxyDictionary = proxy
        }
        
        // Make the request
        AF.request(url, method: method, parameters: parameters, headers: headers)
            .response { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        // Parse headers
                        let responseHeaders = response.response?.allHeaderFields as? [String: String] ?? [:]
                        self.headers = responseHeaders
                        
                        // Parse cookies from the headers
                        let setCookie = responseHeaders["Set-Cookie"] ?? ""
                        self.cookies = setCookie
                        
                        // Parse body
                        let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                        self.response = body
                        
                        self.errorMessage = nil
                        completion(responseHeaders, setCookie, body, nil)
                        
                    case .failure(let error):
                        self.response = ""
                        self.headers = [:]
                        self.cookies = ""
                        self.errorMessage = error.localizedDescription
                        completion(nil, nil, nil, error.localizedDescription)
                    }
                }
            }
    }
}
