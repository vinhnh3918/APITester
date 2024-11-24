//
//  Item.swift
//  APITester
//
//  Created by Nguyen Vinh on 23/11/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var response: String
    var error: String
    var headersJSON: String // Store headers as a JSON string
    
    init(timestamp: Date, response: String = "", error: String = "", headers: [String: String] = [:]) {
        self.timestamp = timestamp
        self.response = response
        self.error = error
        self.headersJSON = headers.toJSONString() // Convert headers to JSON string
    }
    
    /// Convert stored JSON string back to a dictionary
    var headers: [String: String] {
        get {
            return headersJSON.toDictionary() ?? [:]
        }
        set {
            headersJSON = newValue.toJSONString()
        }
    }
}

extension Dictionary where Key == String, Value == String {
    /// Convert a dictionary to a JSON string
    func toJSONString() -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return "{}"
        }
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}

extension String {
    /// Convert a JSON string to a dictionary
    func toDictionary() -> [String: String]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
    }
}
