//
//  ParsedCurlCommand.swift
//  APITester
//
//  Created by Nguyen Vinh on 23/11/24.
//

import Foundation
import Alamofire

struct ParsedCurlCommand {
    let url: String
    let method: String
    let headers: [String: String]
    let parameters: [String: Any]  // Dynamic parameters
    let proxy: String?
    let cookies: [String: String]? // Optional cookies field
}


extension ParsedCurlCommand {
    var alamofireMethod: HTTPMethod {
        return HTTPMethod(rawValue: method.uppercased())
    }
    
    var alamofireHeaders: HTTPHeaders {
        return HTTPHeaders(headers.map { HTTPHeader(name: $0.key, value: $0.value) })
    }
}
