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
    let parameters: [String: String]
    let proxy: String?
}

extension ParsedCurlCommand {
    var alamofireMethod: HTTPMethod {
        return HTTPMethod(rawValue: method.uppercased())
    }
    
    var alamofireHeaders: HTTPHeaders {
        return HTTPHeaders(headers.map { HTTPHeader(name: $0.key, value: $0.value) })
    }
}

func parseCurlCommand(_ curl: String) -> ParsedCurlCommand? {
    var url: String = ""
    var method: String = "GET" // Default to GET if not specified
    var headers: [String: String] = [:]
    var parameters: [String: String] = [:]
    var proxy: String? = nil
    
    let lines = curl.split(separator: "\\").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    
    for line in lines {
        if line.hasPrefix("curl ") {
            if let match = line.range(of: "curl '(.+?)'", options: .regularExpression) {
                url = String(line[match].dropFirst(6).dropLast(1))
            }
        } else if line.hasPrefix("-X ") {
            method = line.replacingOccurrences(of: "-X ", with: "")
        } else if line.hasPrefix("-H ") {
            if let match = line.range(of: "-H '(.+?): (.+?)'", options: .regularExpression) {
                let header = line[match].dropFirst(4).dropLast(1).split(separator: ": ", maxSplits: 1)
                if header.count == 2 {
                    headers[String(header[0])] = String(header[1])
                }
            }
        } else if line.hasPrefix("--data-raw ") {
            if let match = line.range(of: "--data-raw '(.+?)'", options: .regularExpression) {
                let body = line[match].dropFirst(12).dropLast(1)
                body.split(separator: "&").forEach { param in
                    let pair = param.split(separator: "=", maxSplits: 1)
                    if pair.count == 2 {
                        parameters[String(pair[0])] = String(pair[1])
                    }
                }
            }
        } else if line.hasPrefix("--proxy ") {
            if let match = line.range(of: "--proxy (.+)", options: .regularExpression) {
                proxy = String(line[match].dropFirst(8))
            }
        }
    }
    
    guard !url.isEmpty else { return nil }
    
    return ParsedCurlCommand(url: url, method: method, headers: headers, parameters: parameters, proxy: proxy)
}
