//
//  LongTapView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/24.
//

import SwiftUI
import Shimmer

struct LongTapView: View {
  @Environment(\.scenePhase) var phase
  
  @State var onTouching = false
  @State var progress: CGFloat = 0
  @State var progressTimer: Timer?
  
  var text: String
  var onStop: () -> ()
  
  init(_ text: String = "Hold To Stop", _ onStop: @escaping () -> () = {}) {
    self.text = text
    self.onStop = onStop
  }
  
  var body: some View {
    Color.white
      .opacity(0.001)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .clipShape(Rectangle())
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { gesture in
            if !self.onTouching {
              Tools.haptic()
              withAnimation {
                self.onTouching = true
              }
            }
          }
          .onEnded { _ in
            withAnimation(.linear(duration: 0.1)) {
              self.onTouching = false
            }
          }
      )
      .onChange(of: onTouching) { oldValue, newValue in
        if onTouching {
          progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
            if progress <= 1 {
              progress += 0.04
            } else {
              onTouching = false
              onStop()
            }
          })
        } else {
          progress = 0
          progressTimer?.invalidate()
          progressTimer = nil
        }
      }
      .overlay {
        progressView
      }
      .onChange(of: phase) { oldValue, newValue in
        if phase != .active {
          onTouching = false
        }
      }
  }
  
  @ViewBuilder
  var progressView: some View {
    if onTouching {
      VStack {
        ZStack(alignment: .leading) {
          let size: CGSize = CGSize(width: 200, height: 4)
          RoundedRectangle(cornerRadius: size.height / 2, style: .continuous)
            .fill(.black.opacity(0.2))
            .frame(width: size.width, height: size.height)
          
          RoundedRectangle(cornerRadius: size.height / 2, style: .continuous)
            .fill(.black.opacity(0.8))
            .frame(width: size.width * progress, height: size.height)
        }
        .padding(.top, 240)
      }
    }
    
    Text(text)
      .font(.body)
      .shimmering()
      .foregroundColor(onTouching ? Color.slate900 : Color.slate300)
      .padding(.top, 300)
  }
}

#Preview {
  LongTapView()
}
