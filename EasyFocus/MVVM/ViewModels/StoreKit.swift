//
//  StoreKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/29.
//

import Foundation

@Observable
final class StoreKit {
  static let shared = StoreKit()
  
  var focusEvents: [Focus] = []
}
