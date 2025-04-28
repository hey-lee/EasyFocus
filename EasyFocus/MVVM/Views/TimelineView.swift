//
//  TimelineView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/28.
//

import SwiftUI
import SwiftData

struct TimelineView: View {
  @Query var events: [Focus]
  @Environment(\.modelContext) var context

  @State var date: Date = Date()

  var body: some View {
    VStack {
      HStack {
        Spacer()
        BackButton("sf.xmark")
      }
      .padding(.horizontal)
      WeekSlider(date: $date)
      HStack {
        Text(date.formatted(date: .complete, time: .omitted))
          .font(.callout)
          .fontWeight(.semibold)
          .textScale(.secondary)
          .foregroundStyle(.gray)
        
        Spacer()
      }
      .padding(.horizontal)
      Timeline(getEvents(by: date))
    }
  }
  
  private func getEvents(by date: Date) -> [Focus] {
    var events: [Focus] = []
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    let predicate = #Predicate<Focus> {
      $0.createdAt >= startOfDay && $0.createdAt < endOfDay
    }
    let descriptor = FetchDescriptor<Focus>(predicate: predicate)
    
    do {
      events = try context.fetch(descriptor)
    } catch {
      print("getAuthUser fail: \(error)")
    }
    
    return events
  }
}

#Preview("TimelineView") {
  TimelineView()
    .modelContainer(for: [
      Focus.self,
      FocusLabel.self,
    ])
}
