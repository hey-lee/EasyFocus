//
//  BarChart.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/29.
//

import SwiftUI
import SwiftData
import Charts

struct FocusEvent: Identifiable, Equatable {
  var id: String = UUID().uuidString
  var completedSeconds: Int = 0
  var createdAt: Date = Date()
  var isAnimated: Bool = false
  
  var day: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return formatter.string(from: createdAt)
  }
  
  var completedMinutes: Int {
    Int(Double(completedSeconds / 60).rounded())
  }
  
  static func == (lhs: FocusEvent, rhs: FocusEvent) -> Bool {
    lhs.id == rhs.id &&
    lhs.completedSeconds == rhs.completedSeconds &&
    lhs.createdAt == rhs.createdAt &&
    lhs.isAnimated == rhs.isAnimated
  }
}


struct BarChart: View {
  @State var events: [FocusEvent] = []
  @State var isAnimated: Bool = false
  @State var trigger: Bool = false

  
  var body: some View {
    Chart {
      ForEach(events) { event in
        BarMark(
          x: .value("Week", event.day),
          y: .value("Focus", event.isAnimated ?  event.completedMinutes : 0)
        )
        .annotation(position: .top) {
          Text("\(event.completedMinutes.description)m")
            .font(.caption)
        }
        .foregroundStyle(.black.gradient)
        .opacity(event.isAnimated ? 1 : 0)
      }
    }
    .chartYAxis(.hidden)
    .frame(height: 280)
    .padding()
    .background(.background, in: .rect(cornerRadius: 12))
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
    events = StoreKit.shared.eventsWeekMap.reduce(into: [FocusEvent]()) { array, entry in
      let (date, focuses) = entry
      let totalSeconds = focuses.reduce(0) { $0 + $1.completedSecondsCount }
      array.append(FocusEvent(
        completedSeconds: totalSeconds,
        createdAt: focuses.first?.createdAt ?? Date(),
        isAnimated: true
      ))
    }
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
  BarChart()
}
