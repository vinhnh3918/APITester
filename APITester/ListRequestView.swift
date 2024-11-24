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
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func addItem() {
        let curlCommand = """
        curl 'https://superapi-uat.huttonsgroup.com/Project/GetProjectById?Id=88282' \\
        -X POST \\
        -H 'Host: superapi-uat.huttonsgroup.com' \\
        -H 'Accept: */*' \\
        -H 'Connection: keep-alive' \\
        -H 'User-Agent: Super App/1.4.7 (com.huttonsgroup.app-staging; build:25; iOS 18.1.0) Alamofire/5.8.0' \\
        -H 'Accept-Language: en-GB;q=1.0, vi-SG;q=0.9' \\
        -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiJhcHAiLCJqdGkiOiI1NDY0N2Y1OTQwYzBlNmE3YTEyYjI2ODE4MzZiZGQyYzliNDM2YWFkOTI5M2RiMDI1ZWNjOTA3OWVmYjMxMmNjYTg4Yjc5ODNlOTA4ZDY1ZSIsImlhdCI6MTczMDI3NzM2Mi45NjQ1MDMsIm5iZiI6MTczMDI3NzM2Mi45NjQ1MDUsImV4cCI6MTczODIyNjE2Mi45NDY1MDQsInN1YiI6IjQiLCJzY29wZXMiOlsiYmFzaWMiLCJhZG1pbiJdfQ.VMR5qw_vfCp5ul6iNcY_CHySo3lUBa5ARbAE_3eQM3Tezc-2ugvF6SCve3nMCVBHxXVwIGrPU253VYpBS7TfVWrOeuc3gj6jztZuZFH46xcNU0N7xs30Moo8EhsiawZJqQev8Gxtvk69NT1Y6ig7I3XXz0mrxCM4FMY4fwJDKswGVYC8FK2lp4eZzCPEhRFmUWKCpz6ecHNDT6nMfYIrEk9-wh7qcC4JawPikKkd7DMseWOKN4kEz97-moct4LaTL51KQnQvOlfIN9F5Bfk1h3r5kG_eHMsaMpAijoU4qBMoBNg2TwjZnYoGTPn4sMPMncuecosJlNQSpHHAM6Is-A' \\
        -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \\
        --data-raw 'key=huttons&secret=jqhncxdxlxpsvsqslybdpdouetkvkpmpbtfnuonpwxgfixgbezzoelkoknghkemk' \\
        --proxy http://localhost:9090
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
}

#Preview {
    ListRequestView()
        .modelContainer(for: Item.self, inMemory: true)
}
