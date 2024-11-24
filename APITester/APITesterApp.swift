//
//  APITesterApp.swift
//  APITester
//
//  Created by Nguyen Vinh on 23/11/24.
//

import SwiftUI
import SwiftData

@main
struct APITesterApp: App {
    var modelContainer: ModelContainer = {
        let schema = Schema([Item.self]) // Ensure `Item` is included
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ListRequestView()
        }
        .modelContainer(modelContainer)
    }
}
