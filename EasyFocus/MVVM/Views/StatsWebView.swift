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
  
  init() {
    BridgeKit.shared.onFinish { webView in
      do {
        let events = try Tools.structToJSON(StoreService.shared.rangedCodableEvents)
        BridgeKit.shared.emit("stats", events ?? "")
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  var body: some View {
    WebView(html: "stats")
      .onChange(of: storeKit.rangeType, { oldValue, newValue in
        do {
          let events = try Tools.structToJSON(storeKit.rangedCodableEvents)
          BridgeKit.shared.emit("stats", events ?? "")
        } catch {
          print(error.localizedDescription)
        }
      })
      .task {
        BridgeKit.shared.onMessageReceived { message in
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
