//
//  WebView.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/28.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
  let html: String
  let bridge: BridgeKit
  
  init(html: String, bridge: BridgeKit = BridgeKit.shared) {
    self.html = html
    self.bridge = bridge
  }
  
  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences.allowsContentJavaScript = true
    config.userContentController.add(bridge, name: bridge.messageHandlerName)
    
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = bridge
    
    bridge.setWebView(webView)
    bridge.addScript("webridge")
    bridge.addScript("vconsole.min")
    
    if let url = Bundle.main.url(forResource: html, withExtension: "html") {
      webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
    
    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
  StatsWebView()
}
