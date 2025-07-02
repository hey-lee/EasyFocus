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
    WebView(url: "http://192.168.1.4:3000/stats")
//    WebView(html: "stats")
      .onChange(of: storeKit.rangedCodableEvents) { oldValue, newValue in
        do {
          let events = try Tools.structToJSON(storeKit.rangedCodableEvents)
          print("events", events)
          BridgeKit.shared.emit("stats", events ?? "")
        } catch {
          print("")
        }
      }
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
              //            print("url.scheme", url.scheme as Any)
              //            print("url.host", url.host as Any)
              //            print("url.query", url.queryParameters)
            }
          case .string:
            print("")
          }
        }
        storeKit.rangeType = "year"
        do {
          let events = try Tools.structToJSON(storeKit.rangedCodableEvents)
          BridgeKit.shared.emit("stats", events ?? "")
        } catch {
          print("")
        }
      }
  }
}
