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
  struct Options {
    var ratio: CGFloat = 0.6
  }

  @State var selection: ChartEntity?
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
    Chart(events, id: \.label) { event in
      SectorMark(
        angle: .value("Focus", event.value),
        innerRadius: .ratio(options.ratio),
        angularInset: 2
      )
      .foregroundStyle(by: .value("Label", event.label))
      .cornerRadius(8)
      .annotation(position: .overlay) {
        VStack {
          Text("\(event.value)m")
          HStack {
            Text(event.label)
              .font(.caption)
              .fontWeight(.semibold)
            Spacer()
          }
        }
        .foregroundColor(.white)
      }
    }
    .chartBackground { chartProxy in
      GeometryReader { geometry in
        if let anchor = chartProxy.plotFrame {
          let frame = geometry[anchor]
          if let entity = selection {
            VStack {
              Text(entity.label)
                .font(.title3)
                .fontWeight(.bold)
              Text("\(entity.percent)%")
                .font(.caption)
                .fontWeight(.semibold)
            }
            .position(x: frame.midX, y: frame.midY)
          }
        }
      }
    }
    .chartOverlay { chartProxy in
      GeometryReader { proxy in
        if let anchor = chartProxy.plotFrame {
          let frame = proxy[anchor]
          Color.clear
            .contentShape(Rectangle())
            .onTapGesture { location in
              let angle = getAngle(at: location, in: frame)
              withAnimation(.snappy) {
                selection = getSelection(by: angle)
              }
            }
        }
      }
    }
    .frame(height: 280)
    .padding()
    .scaledToFit()
    .chartLegend(alignment: .center, spacing: 16)
  }
  
  private func getAngle(at point: CGPoint, in rect: CGRect) -> Double {
    // Convert touch point to angle
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let deltaX = point.x - center.x
    let deltaY = point.y - center.y
    
    // Skip if touch is outside the donut
    let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
    let radius = min(rect.width, rect.height) / 2
    if distance > radius || distance < radius * (1 - options.ratio) {
      return 0
    }
    
    // Calculate angle in radians and convert to degrees
    var angle = atan2(deltaY, deltaX) * 180 / .pi
    // 调整角度使其从12点钟方向开始
    angle = (angle + 90).truncatingRemainder(dividingBy: 360)
    if angle < 0 {
      angle += 360
    }
    
    return angle
  }
  
  private func getSelection(by angle: Double?) -> ChartEntity? {
    if let angle = angle {
      let total = events.reduce(0) { $0 + $1.value }
      var startAngle: Double = 0
      
      for item in events {
        let sliceAngle = Double(item.value) / Double(total) * 360
        let endAngle = startAngle + sliceAngle
        
        if angle >= startAngle && angle <= endAngle {
          return item
        }
        
        startAngle += sliceAngle
      }
    }
    return nil
  }
}
