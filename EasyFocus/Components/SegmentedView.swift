//
//  SegmentedView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/27.
//

import SwiftUI

struct SegmentedView<T: Equatable>: View {
  @Binding var selection: T
  let segments: [(key: T, name: String)]
  @Namespace var animation
  
  var body: some View {
    VStack {
      HStack(spacing: 8) {
        ForEach(Array(zip(segments.indices, segments)), id: \.0) { index, segment in
          Text(segment.name)
            .font(.system(size: 14))
            .fontWeight(.bold)
            .foregroundColor(isActive(segment.key) ? .slate700 : .slate300)
            .padding(12)
            .background(
              ZStack {
                if isActive(segment.key) {
                  Color.slate50
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
        SegmentedView<String>(selection: $selection, segments: [
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
