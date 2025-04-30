//
//  PieChart.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/30.
//

import SwiftUI
import SwiftData
import Charts


import SwiftUI
import Charts

struct PieChart: View {
  @State var events: [ChartEntity] = []
  
  init(_ events: [ChartEntity] = []) {
    self.events = events
  }
  
  var body: some View {
    Chart {
      ForEach(events) { event in
        SectorMark(
          angle: .value("Focus", event.isAnimated ?  event.value : 0),
          innerRadius: .ratio(0.6),
          angularInset: 4
        )
        .foregroundStyle(by: .value("Week", event.day))
        .opacity(event.isAnimated ? 1 : 0)
        .cornerRadius(8)
      }
    }
    .scaledToFit()
    .padding()
  }
}

#Preview {
  PieChart()
}
