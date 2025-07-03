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
  
  var body: some View {
//    WebView(url: "http://192.168.1.6:3000/stats")
        WebView(html: "stats")
      .task {
//        StoreService.shared.rangeType = "year"
//        do {
//          let events = try Tools.structToJSON(StoreService.shared.rangedCodableEvents)
//          BridgeKit.shared.emit("stats", events ?? "")
//        } catch {
//          print("")
//        }
        BridgeKit.shared.onMessageReceived { message in
          print("message", message)
          switch message.type {
          case .url:
            if let url = URL(string: message.content) {
              switch url.host {
              case "stats":
                print(url.queryParameters)
                if let rangeType = url.queryParameters["rangeType"] {
                  print("rangeType", rangeType)
                  storeKit.rangeType = rangeType
                }
              default:
                break
              }
            }
          case .string:
            print("")
          }
        }
      }
  }
}
