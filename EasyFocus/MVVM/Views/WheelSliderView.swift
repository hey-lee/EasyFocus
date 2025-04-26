//
//  WheelSliderView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/25.
//

import SwiftUI

struct WheelSliderView: View {
  @Environment(FocusKit.self) var focus
  @EnvironmentObject var show: ShowKit

  var body: some View {
    VStack {
      WheelSlider(value: .init(
        get: { CGFloat(focus.minutes) },
        set: {
          focus.minutes = Int($0)
        }
      ), config: .init(
        count: 12,
        showIndicator: true
      ))
      .frame(height: 180)
      
      Text("Done")
        .font(.custom("Code Next ExtraBold", size: 18))
        .foregroundStyle(.white)
        .padding()
        .background(.black)
        .clipShape(Capsule())
        .onTapGesture {
          withAnimation {
            show.WheelSliderView = false
          }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ThemeKit.theme.backgroundColor.ignoresSafeArea())
    .gesture(DragGesture(minimumDistance: 0))
  }
}

#Preview {
  WheelSliderView()
    .environment(FocusKit())
    .environmentObject(ShowKit())
}
