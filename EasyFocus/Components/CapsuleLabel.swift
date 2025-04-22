//
//  Capsule.swift
//  EasyFocus
//
//  Created by DBL on 2024/8/19.
//

import SwiftUI

struct CapsuleLabel: View {
  @State var label: CapLabel
  
  init(_ label: CapLabel) {
    self.label = label
  }
  
  var body: some View {
    HStack {
      Circle()
        .fill(Color.white.gradient.opacity(0.2))
        .frame(width: 48, height: 48)
        .overlay {
          Image(systemName: label.icon)
        }
      
      Text(label.name)
        .fontWeight(.bold)
        .frame(width: 80, alignment: .leading)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .truncationMode(.tail)
        .padding(.trailing, 8)
    }
    .foregroundColor(.white)
    .padding(8)
    .background(Color(hex: "").gradient)
    .clipShape(Capsule())
  }
}

#Preview {
  VStack {}
  .sheet(isPresented: .constant(true)) {
    TagsView()
      .presentationDetents([
        .medium,
      ])
      .presentationDragIndicator(.visible)
      .presentationCornerRadius(32)
  }
}
