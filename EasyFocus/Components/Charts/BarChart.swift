//
//  BarChart.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/29.
//

import SwiftUI
import Charts

struct BarChart: View {
  @State var events: [FocusEvent] = []
  
  init(_ events: [FocusEvent] = []) {
    self.events = events
  }
  
  var body: some View {
    Chart {
      ForEach(events) { event in
        BarMark(
          x: .value("Focus", event.isAnimated ?  event.completedMinutes : 0),
          y: .value("Week", event.day)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .annotation(position: .trailing) {
          Text("\(event.completedMinutes.description)m")
            .font(.caption)
        }
        .annotation(position: .overlay) {
          HStack {
            Text("\(event.completedMinutes.description)m")
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
