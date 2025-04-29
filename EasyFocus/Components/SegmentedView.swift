//
//  SegmentedView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/27.
//

import SwiftUI

struct SegmentedView<T: Equatable>: View {
  struct Config {
    var spacing: CGFloat = 8
    var fontSize: CGFloat = 14
    var cornerRadius: CGFloat = 12
    var color: Color
    var activeColor: Color
    var activeBackgroundColor: Color
  }
  
  @Namespace var animation
  @Binding var selection: T
  
  var segments: [(key: T, name: String)]
  var config: Config
  
  init(
    selection: Binding<T>,
    segments: [(key: T, name: String)],
    config: Config = .init(
      color: .slate300,
      activeColor: .slate700,
      activeBackgroundColor: .white
    )
  ) {
    self._selection = selection
    self.segments = segments
    self.config = config
  }
  
  var body: some View {
    VStack {
      HStack(spacing: config.spacing) {
        ForEach(Array(zip(segments.indices, segments)), id: \.0) { index, segment in
          Text(segment.name)
            .font(.system(size: config.fontSize))
            .fontWeight(.bold)
            .foregroundColor(isActive(segment.key) ? config.activeColor : config.color)
            .padding(12)
            .background(
              ZStack {
                if isActive(segment.key) {
                  config.activeBackgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous))
                    .matchedGeometryEffect(id: "SegmentedView", in: animation)
                }
              }
            )
            .onTapGesture {
              withAnimation(.easeInOut) {
                selection = segment.key
              }
            }
        }
      }
      .padding(4)
    }
    .onAppear {
      selection = segments[0].key
    }
  }
  
  func isActive(_ key: T) -> Bool {
    return selection == key
  }
}

#Preview {
  struct PreviewView: View {
    @State var selection: String = ""

    var body: some View {
      VStack {
        SegmentedView(selection: $selection, segments: [
          (key: "strict", name: "Strict Mode"),
          (key: "whitelist", name: "Whitelist Mode"),
          (key: "loose", name: "Loose Mode"),
        ])
      }
      .onChange(of: selection, { oldValue, newValue in
        print(selection)
      })
      .background(ThemeKit.theme.backgroundColor)
    }
  }
  
  return PreviewView()
}
