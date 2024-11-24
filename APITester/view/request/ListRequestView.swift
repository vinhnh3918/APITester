//
//  ListRequestView.swift
//  APITester
//
//  Created by Nguyen Vinh on 23/11/24.
//

import SwiftUI
import SwiftData

struct ListRequestView: View {
    @StateObject private var networkManager = NetworkManager()
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    // State to manage the presentation of the sheet
    @State private var isSheetPresented = false
    @State private var inputText = "" // State for the text input
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        RequestDetailView(item: item)
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        // Show the sheet when the Add Item button is pressed
                        isSheetPresented = true
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                // Sheet content
                VStack {
                    Text("Import Request")
                        .font(.headline)
                        .padding()
                    
                    TextEditor(text: $inputText) // User can input long text
                        .frame(height: 200)
                        .padding()
                        .border(Color.gray, width: 1)
                    
                    HStack {
                        Spacer()
                        
                        Button("Done") {
                            // Add the callback for the text input when Done is pressed
                            addItemWithText(inputText)
                            isSheetPresented = false // Dismiss the sheet
                        }
                        .padding()
                    }
                }
                .padding()
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func addItemWithText(_ text: String) {
        let curlCommand = """
        \(text)
        """
        
        if let parsed = parseCurlCommand(curlCommand) {
            networkManager.requestAPI(
                url: parsed.url,
                method: parsed.alamofireMethod,
                headers: parsed.alamofireHeaders,
                parameters: parsed.parameters,
                proxy: parsed.proxy.map { ["http": $0] }
            ) { headers, cookies, response, error in
                withAnimation {
                    let newItem = Item(
                        timestamp: Date(),
                        response: response ?? "",
                        error: error ?? "",
                        headers: headers ?? [:]
                    )
                    modelContext.insert(newItem)
                    
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save context: \(error)")
                    }
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func parseCurlCommand(_ curl: String) -> ParsedCurlCommand? {
        var url: String = ""
        var method: String = "GET" // Default to GET if not specified
        var headers: [String: String] = [:]
        var parameters: [String: Any] = [:]  // Dynamic parameters
        var proxy: String? = nil
        var cookies: [String: String] = [:] // Store cookies separately
        
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
                        let key = String(header[0])
                        let value = String(header[1])
                        headers[key] = value
                        
                        // Handle cookies if present
                        if key.lowercased() == "cookie" {
                            let cookieParts = value.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
                            cookieParts.forEach { cookie in
                                let cookiePair = cookie.split(separator: "=", maxSplits: 1)
                                if cookiePair.count == 2 {
                                    cookies[String(cookiePair[0])] = String(cookiePair[1])
                                }
                            }
                        }
                    }
                }
            } else if line.hasPrefix("--data-raw ") {
                if let match = line.range(of: "--data-raw '(.+?)'", options: .regularExpression) {
                    let body = line[match].dropFirst(12).dropLast(1)
                    
                    // Try to parse JSON if it's in a valid format
                    if let jsonData = try? JSONSerialization.jsonObject(with: Data(body.utf8), options: []),
                       let jsonDict = jsonData as? [String: Any] {
                        // Store the parsed JSON directly into parameters
                        jsonDict.forEach { key, value in
                            parameters[key] = value
                        }
                    } else {
                        // If it's not JSON, treat as key-value pairs (URL-encoded)
                        body.split(separator: "&").forEach { param in
                            let pair = param.split(separator: "=", maxSplits: 1)
                            if pair.count == 2 {
                                parameters[String(pair[0])] = String(pair[1])
                            }
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
        
        return ParsedCurlCommand(
            url: url,
            method: method,
            headers: headers,
            parameters: parameters,
            proxy: proxy,
            cookies: cookies.isEmpty ? nil : cookies
        )
    }
}

#Preview {
    ListRequestView()
        .modelContainer(for: Item.self, inMemory: true)
}
