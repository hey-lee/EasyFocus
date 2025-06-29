//
//  ChartsView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/30.
//

import SwiftUI
import SwiftData
import Charts

struct ChartsView: View {
  @Environment(StoreService.self) var storeKit
  
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
  }
  
  private func updateEvents() {
    events = storeKit.chartEntities
  }
}

#Preview {
  ChartsView()
    .environment(StoreService.shared)
}
