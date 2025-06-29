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
  @EnvironmentObject var show: ShowKit
  
  @State var rangeType: String = ""
  
  var body: some View {
    PageView(backStyle: .none) {
      HStack {
        Spacer()
        BackButton("sf.xmark")
      }
      
      SegmentedView(selection: $rangeType, segments: storeKit.segments, .init(animationDuration: 0.2))
      
      VStack {
        ChartsView()
        Text("count: \(storeKit.chartEntities.count)")
      }
    }
    .onChange(of: rangeType) { oldValue, newValue in
      storeKit.rangeType = rangeType
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Symbol("sf.calendar")
          .onTapGesture {
            // stack.settings.append("stats")
            show.TimelineView = true
          }
      }
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
    .environmentObject(ShowKit())
}
