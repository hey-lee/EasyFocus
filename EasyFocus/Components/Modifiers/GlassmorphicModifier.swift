//
//  GlassmorphicModifier.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/27.
//

import SwiftUI

struct GlassmorphicModifier: ViewModifier {
  var cornerRadius: CGFloat
  var glowWidth: CGFloat
  
  func body(content: Content) -> some View {
    
    content
      .background(.ultraThinMaterial)
      .overlay {
        glow()
      }
      .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
      .shadow(color: Color.black.opacity(0.1), radius: 10, x: 4, y: 8)
  }
  
  @ViewBuilder
  func glow() -> some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .stroke(
        LinearGradient(
          gradient: Gradient(colors: [
            .white.opacity(0.7),
            .clear
          ]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        lineWidth: glowWidth
      )
  }
}

extension View {
  func glassmorphic(cornerRadius: CGFloat = 0, glowWidth: CGFloat = 2) -> some View {
    self.modifier(GlassmorphicModifier(cornerRadius: cornerRadius, glowWidth: glowWidth))
  }
}

#Preview {
  SettingsView()
}
