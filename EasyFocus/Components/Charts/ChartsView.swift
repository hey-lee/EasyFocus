//
//  ChartsView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/30.
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

struct ChartsView: View {
  @State var events: [FocusEvent] = []
  @State var isAnimated: Bool = false
  @State var trigger: Bool = false
  
  var body: some View {
    Group {
      VStack {
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
        .frame(height: 280)
        .padding()
        .background(.background, in: .rect(cornerRadius: 16))
//        BarChart(events)
//          .frame(height: 280)
//        PieChart(events)
//          .frame(height: 280)
        
        Chart {
          ForEach(events) { event in
            SectorMark(
              angle: .value("Focus", event.isAnimated ?  event.completedMinutes : 0),
              innerRadius: .ratio(0.6),
              angularInset: 4
            )
            .foregroundStyle(by: .value("Week", event.day))
            .opacity(event.isAnimated ? 1 : 0)
            .cornerRadius(8)
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
  ChartsView()
}
