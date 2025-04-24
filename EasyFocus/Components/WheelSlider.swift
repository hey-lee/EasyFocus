//
//  WheelSlider.swift
//  EasyFocus
//
//  Created by DBL on 2024/8/11.
//

import SwiftUI

struct WheelSlider: View {
  struct Config: Equatable {
    var count: Int
    var steps: Int = 5
    var multiplier: Int = 10
    var spacing: CGFloat = 10
    var showIndicator: Bool = false
  }
  
  @Binding var value: CGFloat
  let config: Config
  @State var isLoaded: Bool = false
  @State private var lastHapticValue: CGFloat = 0
  
  var body: some View {
    GeometryReader {
      let size = $0.size
      let barWidth: CGFloat = 8
      let offsetX = (size.width - barWidth) / 2
      
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: config.spacing) {
          let totalSteps = config.steps * config.count
          
          ForEach(0...totalSteps, id: \.self) { index in
            let remainder = index % config.steps
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
              .opacity(remainder == 0 ? 1 : 0.3)
              .frame(width: barWidth, height: remainder == 0 ? 40 : 20, alignment: .center)
              .frame(maxHeight: 40, alignment: .top)
              .overlay(alignment: .top) {
                if remainder == 0 && config.showIndicator {
                  Text("\((index / config.steps) * config.multiplier)")
                    .font(.custom("Code Next ExtraBold", size: 32))
                    .fontWeight(.semibold)
                    .textScale(.secondary)
                    .fixedSize()
                    .offset(y: -48)
                }
              }
          }
        }
        .frame(height: size.height)
        .scrollTargetLayout()
      }
      .scrollTargetBehavior(.viewAligned)
      .scrollPosition(id: Binding(get: {
        isLoaded ? (Int(value) * config.steps) / config.multiplier : nil
      }, set: { newValue in
        if let newValue {
          value = (CGFloat(newValue) / CGFloat(config.steps)) * CGFloat(config.multiplier)
          
          handleHaptic(by: value)
        }
      }))
      .overlay(alignment: .center) {
        VStack {
          Image(systemName: "triangle.fill")
            .offset(y: 40)
        }
      }
      .safeAreaPadding(.horizontal, offsetX)
      .onAppear {
        if !isLoaded { isLoaded = true }
      }
    }
  }
  
  private func handleHaptic(by value: CGFloat) {
    let stepIncrement = CGFloat(config.multiplier) / CGFloat(config.steps)
    let currentStep = round(value / stepIncrement)

    if currentStep != round(lastHapticValue / stepIncrement) {
        Tools.haptic(.rigid)
        lastHapticValue = value
    }
  }
}

#Preview {
  WheelSlider(value: .constant(120), config: .init(
    count: 12,
    showIndicator: true
  ))
}
