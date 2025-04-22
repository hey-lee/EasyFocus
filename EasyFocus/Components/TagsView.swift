//
//  TagsView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI

struct TagsView: View {
  @Environment(\.dismiss) var dismiss
  @Environment(TagsKit.self) var tagsKit
  
  let cols: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
  
  var body: some View {
    ZStack(alignment: .center) {
      Text("Timer Tags")
      //        .lineLimit(1)
        .font(.custom("Code Next ExtraBold", size: 24))
        .padding(.top)
        .padding(.horizontal)
      HStack {
        Spacer()
        Symbol("sf.plus")
      }
      .padding(.top)
      .padding(.horizontal)
    }
    
    ScrollView(showsIndicators: false) {
      LazyVGrid(columns: cols, spacing: 16) {
        ForEach(ResourceKit.shared.tags) { tag in
          CapsuleLabel(tag)
            .onTapGesture {
              tagsKit.label = tag
              dismiss()
            }
        }
      }
      .padding(.vertical)
      .padding(.horizontal)
    }
    .offset(y: -16)
  }
}

#Preview {
  VStack {
    Text("tag.label.name")
    Spacer()
  }
  .sheet(isPresented: .constant(true)) {
    TagsView()
      .presentationDetents([
        .medium,
      ])
      .presentationDragIndicator(.visible)
      .presentationCornerRadius(32)
  }
}
