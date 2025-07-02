//
//  WebView.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/28.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
  let url: String?
  let html: String?
  let bridge: BridgeKit
  
  init(url: String, bridge: BridgeKit = BridgeKit.shared) {
    self.url = url
    self.html = nil
    self.bridge = bridge
  }
  
  init(html: String, bridge: BridgeKit = BridgeKit.shared) {
    self.url = nil
    self.html = html
    self.bridge = bridge
  }
  
  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    config.defaultWebpagePreferences.allowsContentJavaScript = true
    config.userContentController.add(bridge, name: bridge.messageHandlerName)
    
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = bridge
    webView.isInspectable = true
    
    bridge.setWebView(webView)
    bridge.addScript("webridge")
    
    if let url, let url = URL(string: url) {
      webView.load(URLRequest(url: url))
    }
    if let html, let fileURL = Bundle.main.url(forResource: html, withExtension: "html") {
      webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
    }
    
    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
  StatsWebView()
}
