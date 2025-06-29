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
  
  @State var spacing: CGFloat
  @State var backStyle: BackStyle
  @ViewBuilder var content: () -> Content
  
  init(
    spacing: CGFloat = 8,
    backStyle: BackStyle = .back,
    @ViewBuilder content: @escaping () -> Content = { EmptyView() }
  ) {
    self.spacing = spacing
    self.backStyle = backStyle
    self.content = content
  }
  
  var body: some View {
    ScrollView {
      VStack(spacing: spacing) {
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
                .stroke(width: 2, shadow: .init(radius: 2, color: .black.opacity(0.1)))
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
    .ignoresSafeArea(.container, edges: .all)
  }
}

#Preview {
  PageView {
    Text("App Content")
  }
}
