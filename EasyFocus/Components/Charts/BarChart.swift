//
//  BarChart.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/29.
//

import SwiftUI
import Charts

struct BarChart: View {
  struct Options {
    var barWidth: CGFloat = 40
    var barGap: CGFloat = 12
  }
  var events: [ChartEntity]
  var options: Options
  
  init(
    _ events: [ChartEntity] = [],
    _ options: Options = .init()
  ) {
    self.events = events
    self.options = options
  }
  
  var body: some View {
    Chart(events) { event in
      BarMark(
        x: .value("Focus", event.value),
        y: .value("Week", event.label),
        height: .fixed(options.barWidth)
      )
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .annotation(position: .trailing) {
        VStack(spacing: 0) {
          Text(event.label)
            .font(.callout)
          HStack {
            Text("\(event.value.description)m")
              .font(.caption)
            Spacer()
          }
        }
      }
      .annotation(position: .overlay) {
        HStack {
          Text("\(event.percent.description)%")
            .font(.caption)
            .foregroundColor(.white)
          
          Spacer()
        }
      }
      .foregroundStyle(.black.gradient)
    }
    .frame(height: dynamicHeight())
    .chartXAxis(.hidden)
    .chartYAxis(.hidden)
    .padding()
  }
  
  private func dynamicHeight() -> CGFloat {
    max(0, CGFloat(events.count) * options.barWidth + CGFloat(events.count - 1) * options.barGap)
  }
}

#Preview {
  BarChart()
}
