//
//  StrokeText.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/27.
//

import SwiftUI

extension StrokeModifier {
  struct Shadow {
    var x: CGFloat = 0
    var y: CGFloat = 4
    var radius: CGFloat = 8
    var color: Color = .black.opacity(0.2)
  }
}

struct StrokeModifier: ViewModifier {
  var lineWidth: CGFloat
  var strokeColor: Color
  var shadow: Shadow
  
  init(
    strokeSize: CGFloat,
    strokeColor: Color,
    shadow: Shadow = .init()
  ) {
    self.lineWidth = strokeSize
    self.strokeColor = strokeColor
    self.shadow = shadow
  }
  
  func body(content: Content) -> some View {
    content
      .padding(lineWidth)
      .background(
        Rectangle()
          .foregroundStyle(.white)
          .mask(outline(content))
      )
      .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
  }
  
  private func outline(_ content: Content) -> some View {
    Canvas { context, size in
      context.addFilter(.alphaThreshold(min: 0.01))
      context.drawLayer { layer in
        if let symbol = context.resolveSymbol(id: "stroke.symbol") {
          layer.draw(symbol, at: CGPoint(x: size.width / 2, y: size.height / 2))
        }
      }
    } symbols: {
      content.tag("stroke.symbol").blur(radius: lineWidth)
    }
  }
}

extension View {
  func stroke(color: Color = .white, width: CGFloat = 4, shadow: StrokeModifier.Shadow = .init()) -> some View {
    self.modifier(StrokeModifier(strokeSize: width, strokeColor: color, shadow: shadow))
  }
}
