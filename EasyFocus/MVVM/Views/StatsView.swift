//
//  StatsView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/25.
//

import SwiftUI
import SwiftData
import CoreData

struct StatsView: View {
  @Environment(\.modelContext) var context
  @Environment(StoreService.self) var storeKit
  @Query(sort: \Focus.createdAt, order: .reverse)
  var focuses: [Focus] = []
  let segments: [(key: String, name: String)] = [
    (key: "day", name: "Day"),
    (key: "week", name: "Week"),
    (key: "month", name: "Month"),
    (key: "year", name: "Year"),
  ]
  
  @State var rangeType: String = ""
  @State var chunkedEvents: [Focus] = []
  
  var body: some View {
    PageView {
      HStack {
        Spacer()
        BackButton("sf.xmark")
      }
      
      SegmentedView(selection: $rangeType, segments: segments, .init(animationDuration: 0.2))
      
      VStack {
        ChartsView()
        Text("count: \(storeKit.chartEntities.count)")
      }
    }
//    .onAppear {
//      storeKit.focusEvents = focuses
//    }
//    .onChange(of: focuses) { oldValue, newValue in
//      storeKit.focusEvents = focuses
//    }
    .onChange(of: rangeType) { oldValue, newValue in
      storeKit.rangeType = rangeType
    }
  }
  
  func getDynamicHeight(_ seconds: Int) -> CGFloat{
    let minutes = seconds / 60
    let ranges: [(Range<Int>, CGFloat)] = [
      (0..<5, 48),
      (5..<10, 60),
      (10..<25, 80),
      (25..<50, 100),
      (50..<100, 120)
    ]
    
    return ranges.first { $0.0.contains(minutes) }?.1 ?? 140
  }
  
  @ViewBuilder
  func CardView(_ focus: Focus) -> some View {
    if let label = focus.label {
      RoundedRectangle(cornerRadius: 12)
        .fill(label.backgroundColor.isEmpty ? .white : Color(hex: label.backgroundColor))
        .frame(height: getDynamicHeight(focus.completedSecondsCount))
        .overlay {
          VStack {
            HStack {
              Text(label.name)
                .foregroundColor(.white)
              Spacer()
              Text(Tools.format(focus.createdAt))
                .foregroundColor(.white)
              Text(Tools.formatSeconds(focus.completedSecondsCount))
                .foregroundColor(.white)
            }
            .padding()
            Spacer()
          }
        }
    }
  }
}

#Preview {
  StatsView()
    .environment(StoreService.shared)
}
