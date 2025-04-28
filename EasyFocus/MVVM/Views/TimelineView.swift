//
//  TimelineView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/28.
//

import SwiftUI
import SwiftData

struct TimelineView: View {
  @Query var events: [Focus]
  @State var date: Date = Date()
  var body: some View {
    VStack {
      HStack {
        Spacer()
        BackButton("sf.xmark")
      }
      .padding(.horizontal)
      WeekSlider(date: $date)
      HStack {
        Text(date.formatted(date: .complete, time: .omitted))
          .font(.callout)
          .fontWeight(.semibold)
          .textScale(.secondary)
          .foregroundStyle(.gray)

        Spacer()
      }
      .padding(.horizontal)
      Timeline(events)
    }
  }
}

#Preview("TimelineView") {
  TimelineView()
    .modelContainer(for: [
      Focus.self,
      FocusLabel.self,
    ])
}
