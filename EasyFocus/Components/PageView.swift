//
//  PageView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/25.
//

import SwiftUI

struct PageView<Content: View>: View {
  enum BackStyle {
    case back, close, none
  }
  @State var backStyle: BackStyle
  @ViewBuilder var content: () -> Content
  
  init(
    backStyle: BackStyle = .back,
    @ViewBuilder content: @escaping () -> Content = { EmptyView() }
  ) {
    self.backStyle = backStyle
    self.content = content
    Tools.transparentNavBar()
  }
  
  var body: some View {
    ScrollView {
      VStack {
        content()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .padding()
      .navigationBarBackButtonHidden(true)
      .toolbar {
        if backStyle != .none {
          if backStyle == .back {
            ToolbarItem(placement: .topBarLeading) {
              BackButton()
            }
          }
          if backStyle == .close {
            ToolbarItem(placement: .topBarTrailing) {
              BackButton("sf.xmark")
            }
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ThemeKit.theme.backgroundColor.ignoresSafeArea())
  }
}

#Preview {
  PageView {
    Text("App Content")
      .foregroundColor(.white)
  }
}
