//
//  BackButton.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/25.
//

import SwiftUI

struct BackButton: View {
  @Environment(\.dismiss) var dismiss
  @State var iconName: String
  
  init(_ iconName: String = "sf.arrow.left") {
    self.iconName = iconName
  }

  var body: some View {
    Symbol(iconName, size: 44, colors: [Color.white])
      .onTapGesture {
        dismiss()
        Tools.haptic()
      }
  }
}
