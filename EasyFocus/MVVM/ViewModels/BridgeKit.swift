//
//  BridgeKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/29.
//

import SwiftUI
import WebKit

@Observable
final class BridgeKit: NSObject {
  static let shared = BridgeKit()
  weak var webView: WKWebView?
  var bridgeWebView: WebView?
  var messageHandlerName: String = "nativeApp"
  var handleMessageReceived: (Message) -> Void = { _ in }
  var handleFinish: (WKWebView) -> Void = { _ in }
  var handleFail: (WKWebView, Error) -> Void = { _, _ in }
  
  enum MessageType {
    case url, string
  }
  
  struct Message {
    var type: MessageType
    var content: String
  }
  
  func setWebView(_ webView: WKWebView) {
    self.webView = webView
  }
  
  func fixRelativePaths(html: String) -> String {
    // replace absolute path to relative path
    let pattern = #"(\b(src|href)\s*=\s*['"])\/_next\/static\/([^'"]+['"])"#
    
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
      
      let result = NSMutableString(string: html)
      
      regex.replaceMatches(
        in: result,
        options: [],
        range: NSRange(location: 0, length: result.length),
        withTemplate: "$1./_next/static/$3"
      )
      
      return result as String
      
    } catch {
      return html
    }
  }
  
  func evaluateJavaScriptHandler(_ result: Any?, _ error: (any Error)?) {
    if let error = error {
      print("evaluateJavaScript error: \(error)")
    } else {
      print("evaluateJavaScript result:", result as Any)
    }
  }
  
  func eval(_ js: String) {
    webView?.evaluateJavaScript(js) { result, error in
      self.evaluateJavaScriptHandler(result, error)
    }
  }
  
  func call(_ name: String, content: String) {
    eval("\(name)('\(content)')")
  }
  
  func call(_ name: String, data: [String: Any]) {
    guard let json = Tools.dictionaryToJSON(data) else {
      return
    }
    eval("\(name)('\(json)')")
  }
  
  func emit(_ key: String, _ data: String) {
    print("bridge.emit('\(key)', \(data))")
    BridgeKit.shared.eval("bridge.emit('\(key)', \(data))")
  }
  
  func emit(_ key: String, _ data: [String: Any]) {
    guard let JSON = Tools.dictionaryToJSON(data) else {
      return
    }
    BridgeKit.shared.eval("bridge.emit('\(key)', '\(JSON)')")
  }
  
  func addScript(_ name: String, injectionTime: WKUserScriptInjectionTime = .atDocumentStart) {
    if let url = Bundle.main.url(forResource: name, withExtension: "js") {
      do {
        let webridge = try String(contentsOf: url, encoding: .utf8)
        webView?.configuration.userContentController.addUserScript(
          WKUserScript(
            source: webridge,
            injectionTime: injectionTime,
            forMainFrameOnly: false
          )
        )
      } catch {
        print("read \(name).js fail", error.localizedDescription)
      }
    } else {
      print("\(name).js not found")
    }
  }
}

extension BridgeKit {
  func onMessageReceived(_ onMessageReceived: @escaping (Message) -> Void = { _ in }) {
    self.handleMessageReceived = onMessageReceived
  }
  
  func onFinish(_ didFinish: @escaping (WKWebView) -> Void = { _ in }) {
    self.handleFinish = didFinish
  }
  
  func onFail(_ didFail: @escaping (WKWebView, Error) -> Void = { _, _ in }) {
    self.handleFail = didFail
  }
}

extension BridgeKit: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    print("WebView: didStartProvisionalNavigation")
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    print("WebView: didFinish")
    handleFinish(webView)
    let scripts = webView.configuration.userContentController.userScripts
    print("scripts count: \(scripts.count)")
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    print("WebView: didFail - \(error.localizedDescription)")
    handleFail(webView, error)
  }
  
  // 处理URL拦截
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if let url = navigationAction.request.url, let scheme = url.scheme, scheme == "foca" {
      handleMessageReceived(.init(type: .url, content: url.absoluteString))
      decisionHandler(.cancel)
      return
    }
    
    decisionHandler(.allow)
  }
}

extension BridgeKit: WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == messageHandlerName {
      if let messageBody = message.body as? String {
        handleMessageReceived(.init(type: .string, content: messageBody))
      }
    }
  }
}
