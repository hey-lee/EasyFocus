//
//  URL++.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/28.
//

import Foundation

extension URL {
  var queryParameters: [String: String] {
    guard
      let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
      let queryItems = components.queryItems
    else {
      return [:]
    }
    
    return queryItems.reduce(into: [String: String]()) { result, item in
      result[item.name] = item.value
    }
  }
}
