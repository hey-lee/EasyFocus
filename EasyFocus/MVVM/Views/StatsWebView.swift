//
//  StatsWebView.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/28.
//

import SwiftUI
import SwiftData

struct StatsWebView: View {
  @Environment(\.modelContext) var context
  @Environment(StoreService.self) var storeKit
  @EnvironmentObject var show: ShowKit
  
//  @State var rangeType: String = ""
  
  var body: some View {
    WebView(html: "stats")
    .task {
      storeKit.rangeType = "year"
      BridgeKit.shared.onMessageReceived { message in
        switch message.type {
        case .url:
          if let url = URL(string: message.content) {
            print("url.scheme", url.scheme as Any)
            print("url.host", url.host as Any)
            print("url.query", url.queryParameters)
          }
        case .string:
          print("string", message.content)
        }
      }
      BridgeKit.shared.onFinish { webView in
        print("onFinish")
        do {
          let events = try Tools.structToJSON(storeKit.chartEntities)
          BridgeKit.shared.emit("stats", events ?? "")
        } catch {
          print("")
        }
      }
    }
  }
}
