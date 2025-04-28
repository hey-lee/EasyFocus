//
//  View++.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/28.
//

import SwiftUI

extension View {
  @ViewBuilder
  func hLayout(_ alignment: Alignment) -> some View {
    self
      .frame(maxWidth: .infinity, alignment: alignment)
  }
  
  @ViewBuilder
  func vLayout(_ alignment: Alignment) -> some View {
    self
      .frame(maxHeight: .infinity, alignment: alignment)
  }
}
