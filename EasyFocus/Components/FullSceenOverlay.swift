//
//  FullSceenOverlay.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/28.
//

import SwiftUI

@Observable
final class OverlayKit {
  static let shared = OverlayKit()
  
  var show: Bool = false
}

struct FullSceenOverlay: View {
  var body: some View {
    Group {
      VStack {
        Text("sdf")
          .onTapGesture {
            print("click")
            withAnimation {
              OverlayKit.shared.show.toggle()
            }
          }
        Color.gray300.ignoresSafeArea()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.ultraThinMaterial)
    .border(.black)
  }
}

#Preview {
  VStack {
    Text("Overlay")
      .padding()
      .offset(y: 20)
  }
  .onChange(of: OverlayKit.shared.show, { oldValue, newValue in
    print(newValue)
  })
  .frame(maxWidth: .infinity, maxHeight: .infinity)
//  .overlay {
//    Text("sdf \(OverlayKit.shared.show.description)")
//    if OverlayKit.shared.show {
//      FullSceenOverlay()
//        .ignoresSafeArea()
//    }
//  }
}
