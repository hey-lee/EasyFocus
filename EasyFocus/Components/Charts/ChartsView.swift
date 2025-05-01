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
  @Environment(StoreKit.self) var storeKit
  
  @State var events: [ChartEntity] = []
  
  var body: some View {
    Group {
      VStack {
        BarChart(events)
        .background(.background, in: .rect(cornerRadius: 16))
        
        PieChart(events)
        .background(.background, in: .rect(cornerRadius: 16))
      }
    }
    .onAppear {
      updateEvents()
    }
    .onChange(of: storeKit.rangeType) { oldValue, newValue in
      updateEvents()
    }
    .onChange(of: storeKit.chartEntities) { oldValue, newValue in
      print("chartEntities", storeKit.chartEntities)
    }
  }
  
  private func updateEvents() {
    events = storeKit.chartEntities
  }
}

#Preview {
  ChartsView()
    .environment(StoreKit.shared)
}
