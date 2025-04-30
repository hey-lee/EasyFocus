//
//  ChartsView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/30.
//

import SwiftUI
import SwiftData
import Charts

struct ChartEntity: Identifiable, Equatable {
  var id: String = UUID().uuidString
  var label: String = ""
  var value: Int = 0
  var percent: Int = 0
  var createdAt: Date = Date()
  var isAnimated: Bool = false
  
  var day: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return formatter.string(from: createdAt)
  }
  
  static func == (lhs: ChartEntity, rhs: ChartEntity) -> Bool {
    lhs.id == rhs.id &&
    lhs.label == rhs.label &&
    lhs.value == rhs.value &&
    lhs.createdAt == rhs.createdAt &&
    lhs.isAnimated == rhs.isAnimated
  }
}

struct ChartsView: View {
  @State var events: [ChartEntity] = []
  @State var trigger: Bool = false
  @State var isAnimated: Bool = false
  @State var selectedAngle: Double?
  @State var pieChartRatio: Double = 0.6
  @State var selectedEntity: ChartEntity?
  
  var body: some View {
    Group {
      VStack {
        Chart(events) { event in
          BarMark(
            x: .value("Focus", event.isAnimated ?  event.value : 0),
            y: .value("Week", event.label)
          )
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .annotation(position: .trailing) {
            VStack {
              Text(event.label)
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
          .opacity(event.isAnimated ? 1 : 0)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 280)
        .padding()
        .background(.background, in: .rect(cornerRadius: 16))
        
        Chart(events, id: \.label) { event in
          SectorMark(
            angle: .value("Focus", event.isAnimated ?  event.value : 0),
            innerRadius: .ratio(pieChartRatio),
            angularInset: 2
          )
          .foregroundStyle(by: .value("Label", event.label))
          .opacity(event.isAnimated ? 1 : 0)
          .cornerRadius(8)
        }
        .chartBackground { chartProxy in
          GeometryReader { geometry in
            if let anchor = chartProxy.plotFrame {
              let frame = geometry[anchor]
              if let entity = selectedEntity {
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
                    selectedEntity = getSelection(by: angle)
                  }
                }
            }
          }
        }
        .frame(height: 280)
        .padding()
        .scaledToFit()
        .chartLegend(alignment: .center, spacing: 16)
        .background(.background, in: .rect(cornerRadius: 16))
      }
    }
    .onAppear {
      updateEvents()
      animateChart()
    }
    .onChange(of: trigger, initial: false) { oldValue, newValue in
      resetChartAnimation()
      animateChart()
    }
    .onChange(of: StoreKit.shared.eventsWeekMap) { oldValue, newValue in
      updateEvents()
    }
    .onChange(of: selectedEntity) { oldValue, newValue in
      if let entity = selectedEntity {
        print(entity.label)
      }
    }
  }
  
  private func getAngle(at point: CGPoint, in rect: CGRect) -> Double {
    // Convert touch point to angle
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let deltaX = point.x - center.x
    let deltaY = point.y - center.y
    
    // Skip if touch is outside the donut
    let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
    let radius = min(rect.width, rect.height) / 2
    if distance > radius || distance < radius * (1 - pieChartRatio) {
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
  
  private func updateEvents() {
    events = StoreKit.shared.labelValueMap.reduce(into: [ChartEntity](), { array, item in
      array.append(
        ChartEntity(
          label: item.key,
          value: StoreKit.shared.toMinutes(item.value),
          percent: StoreKit.shared.percent(item.value)
        )
      )
    })
    .filter { $0.percent > 0 }
    .sorted { $0.value > $1.value }
  }
  
  private func animateChart() {
    guard !isAnimated else { return }
    isAnimated = true
    
    $events.enumerated().forEach { index, event in
      if index > 7 {
        event.wrappedValue.isAnimated = true
      } else {
        let delay = Double(index) * 0.05
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
          withAnimation(.smooth) {
            event.wrappedValue.isAnimated = true
          }
        }
      }
    }
  }
  
  private func resetChartAnimation() {
    $events.forEach { event in
      event.wrappedValue.isAnimated = false
    }
    isAnimated = false
  }
}

#Preview {
  ChartsView()
}
