//
//  BarChart.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/29.
//

import SwiftUI
import Charts

struct BarChart: View {
  @State var events: [ChartEntity] = []
  
  init(_ events: [ChartEntity] = []) {
    self.events = events
  }
  
  var body: some View {
    Chart {
      ForEach(events) { event in
        BarMark(
          x: .value("Focus", event.isAnimated ?  event.value : 0),
          y: .value("Week", event.day)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .annotation(position: .trailing) {
          Text("\(event.value.description)m")
            .font(.caption)
        }
        .annotation(position: .overlay) {
          HStack {
            Text("\(event.value.description)m")
              .font(.caption)
              .foregroundColor(.white)
            
            Spacer()
          }
        }
        .foregroundStyle(.black.gradient)
        .opacity(event.isAnimated ? 1 : 0)
      }
    }
    .chartXAxis(.hidden)
    .chartYAxis(.hidden)
    .padding()
  }
}

#Preview {
  BarChart()
}
