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
            innerRadius: .ratio(0.6),
            angularInset: 4
          )
          .foregroundStyle(by: .value("Label", event.label))
          .opacity(event.isAnimated ? 1 : 0)
          .cornerRadius(8)
        }
        .chartBackground { chartProxy in
          GeometryReader { geometry in
            if let anchor = chartProxy.plotFrame {
              let frame = geometry[anchor]
              Text("Study")
                .position(x: frame.midX, y: frame.midY)
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
    .onChange(of: StoreKit.shared.eventsWeekMap) { oldValue, newValue in
      updateEvents()
    }
    .onAppear {
      updateEvents()
      animateChart()
    }
    .onChange(of: trigger, initial: false) { oldValue, newValue in
      resetChartAnimation()
      animateChart()
    }
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
