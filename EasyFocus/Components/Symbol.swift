//
//  Symbol.swift
//  Costrack
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI

struct Symbol: View {
  enum Size: Double {
    case small = 0.75, normal = 1, large = 1.25
  }
  var name: String
  var size: CGFloat
  var colors: [Color]
  var radiusSize: Size
  var contentSize: Size
  var imageScale: CGFloat
  var foregroundColor: Color
  
  init(
    _ name: String,
    size: CGFloat = 44,
    colors: [Color] = [.clear],
    radiusSize: Size = .normal,
    contentSize: Size = .normal,
    foregroundColor: Color = .slate600,
    imageScale: CGFloat = 0.5
  ) {
    self.name = name
    self.size = size
    self.radiusSize = radiusSize
    self.contentSize = contentSize
    self.colors = colors
    self.foregroundColor = foregroundColor
    self.imageScale = imageScale == .infinity ? 1 : 0.5 * contentSize.rawValue
  }

  var body: some View {
    GeometryReader {
      let size = $0.size
      let imageSize = size.width * imageScale

      ZStack {
        Group {
          if name.starts(with: "sf.") {
            let name = name.replacingOccurrences(of: "sf.", with: "")
            Image(systemName: name)
              .resizable()
          } else {
            Image(name)
              .resizable()
          }
        }
        .foregroundStyle(foregroundColor)
        .aspectRatio(contentMode: .fit)
        .frame(width: imageSize, height: imageSize)
      }
      .frame(width: size.width, height: size.height)
      .background(
        LinearGradient(
          gradient: Gradient(colors: colors),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .clipShape(.rect(cornerRadius: size.width / (radiusSize == .small ? 4 : 3)))
    }
    .frame(width: size, height: size)
  }
}

#Preview {
  Symbol("sf.xmark")
  Symbol("weixin")
  Symbol("weixin", contentSize: .large)
}
