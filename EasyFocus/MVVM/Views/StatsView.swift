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
  @Query(sort: \Focus.createdAt, order: .reverse)
  var focuses: [Focus] = []

  var body: some View {
    PageView {
      HStack {
        Spacer()
        BackButton("sf.xmark")
      }
      HStack {
        Button("Clear All") {
          Task {
            focuses.forEach { context.delete($0) }
          }
        }
      }
      VStack {
        ForEach(focuses.filter { $0.label != nil }) { focus in
          CardView(focus)
        }
      }
      .padding()
    }
  }
  
  func getDynamicHeight(_ seconds: Int) -> CGFloat{
    let minutes = seconds / 60
    if minutes < 5 {
      return 48
    } else if (5..<10).contains(minutes) {
      return 60
    } else if (10..<25).contains(minutes) {
      return 80
    } else if (25..<50).contains(minutes) {
      return 100
    } else if (50..<100).contains(minutes) {
      return 120
    } else {
      return 140
    }
    
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
