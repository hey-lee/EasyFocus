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
        Button("Sync iCloud") {
          sync()
        }
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
  
  func sync() {
//    guard let container = context.container as? NSPersistentCloudKitContainer else { return }
//        container.syncPersistentStores()
  }
  
  @ViewBuilder
  func CardView(_ focus: Focus) -> some View {
    if let label = focus.label {
      RoundedRectangle(cornerRadius: 12)
        .fill(label.backgroundColor.isEmpty ? .white : Color(hex: label.backgroundColor))
        .frame(height: 48)
        .overlay {
          HStack {
            Text(label.name)
              .foregroundColor(.white)
            Spacer()
            Text(Tools.format(focus.createdAt))
              .foregroundColor(.white)
            Text(Tools.formatSeconds(focus.completedSecondsCount))
              .foregroundColor(.white)
          }
          .padding(.horizontal)
        }
    }
  }
}
