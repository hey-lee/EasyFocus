//
//  PresentKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/27.
//

import SwiftUI

@Observable
final class PresentKit {
  static let shared = PresentKit()
  
  var presentView: AnyView?
  
  func present<Content: View>(@ViewBuilder _ sheet: @escaping () -> Content = { EmptyView() }) {
    presentView = AnyView(sheet())
  }
  
  func dismiss() {
    presentView = nil
  }
}
