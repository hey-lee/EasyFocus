//
//  OffsetKey.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/28.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}
