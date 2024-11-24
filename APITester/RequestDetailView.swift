//
//  RequestDetailView.swift
//  APITester
//
//  Created by Nguyen Vinh on 24/11/24.
//

import SwiftUI

struct RequestDetailView: View {
    let item: Item
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                bodySection
                headersSection
                cookiesSection
            }
            .padding()
        }
    }
    
    // Computed property to format the timestamp into a string
    private var formattedTimestamp: String {
        // Ensure item.timestamp is a Date and format it as a string
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: item.timestamp)
    }
    
    private var bodySection: some View {
        Section(header: Text("Body").font(.headline)) {
            VStack(alignment: .leading, spacing: 10) {
                Text(item.response.isEmpty ? "No response body available." : item.response)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private var headersSection: some View {
        Section(header: Text("Headers").font(.headline)) {
            VStack(alignment: .leading, spacing: 10) {
                if item.headers.isEmpty {
                    Text("No headers available.")
                        .font(.body)
                } else {
                    headerRows
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private var headerRows: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(item.headers.sorted(by: { $0.key < $1.key })), id: \.key) { key, value in
                headerRow(key: key, value: value)
                Divider()
            }
        }
    }
    
    private func headerRow(key: String, value: String) -> some View {
        return VStack(alignment: .leading, spacing: 5) {
            Text(key)
                .font(.subheadline)
                .bold()
            Text(value)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }
    
    private var cookiesSection: some View {
        let cookies = extractCookies(from: item.headers)
        guard !cookies.isEmpty else { return AnyView(EmptyView()) }
        
        return AnyView(
            Section(header: Text("Set-Cookie").font(.headline)) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(cookies, id: \.self) { cookie in
                        Text(cookie)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        )
    }
    
    private func extractCookies(from headers: [String: String]) -> [String] {
        headers.filter { $0.key.lowercased() == "set-cookie" }
            .map { $0.value }
    }
}
