//
//  StoreKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/29.
//

import Foundation

@Observable
final class StoreService {
  static let shared = StoreService()
  
  enum RangeType: String, CustomStringConvertible {
    case day, week, month, year
    var description: String { rawValue }
  }
  
  var rangeType: String = "day"
  var focusEvents: [Focus] {
    StoreService.mock(100)
  }
  var totalSeconds: Int {
    focusEvents.reduce(0) { $0 + $1.completedSecondsCount }
  }
  var totalMinutes: Int {
    toMinutes(totalSeconds)
  }
  var eventsWeekMap: [String: [Focus]] {
    focusEvents
      .sorted { $0.createdAt < $1.createdAt }
      .reduce(into: [:]) { weekMap, event in
        let createdAt = event.createdAt.format("yyyy-MM-dd")
        weekMap[createdAt, default: []].append(event)
      }
  }
  var rangedEvents: [Focus] {
    focusEvents.filter {
      let calendar = Calendar.current
      let now = Date()
      let eventDate = $0.createdAt
      
      switch rangeType {
      case "day":
        return calendar.isDate(eventDate, inSameDayAs: now)
      case "week":
        let weekRange = calendar.dateInterval(of: .weekOfYear, for: now)!
        return weekRange.contains(eventDate)
      case "month":
        return calendar.isDate(eventDate, equalTo: now, toGranularity: .month)
      case "year":
        return calendar.isDate(eventDate, equalTo: now, toGranularity: .year)
      default:
        return false
      }
    }
  }
  var labelEventsMap: [String: [Focus]] {
    Dictionary(grouping: rangedEvents.filter { $0.label != nil }) { $0.label!.name }
  }
  var labelValueMap: [(key: String, value: Int)] {
    labelEventsMap.mapValues { events in
      events.reduce(0) { $0 + $1.completedSecondsCount }
    }
    .sorted { $0.value > $1.value }
  }
  
  var chartEntities: [ChartEntity] {
    labelValueMap.map { item in
      ChartEntity(
        label: item.key,
        value: toMinutes(item.value),
        percent: percent(item.value)
      )
    }
    .filter { $0.percent > 0 }
  }
  
  func percent(_ seconds: Int) -> Int {
    Int((Double(seconds) / Double(totalSeconds) * 100.0).rounded())
  }
  
  func toMinutes(_ seconds: Int) -> Int {
    Int(Double(seconds) / 60.0)
  }
  
  static func mock(
    _ count: Int,
    range: ClosedRange<Date> = Date().addingTimeInterval(-30 * 24 * 3600)...Date()
  ) -> [Focus] {
    var events = [Focus]()
    
    let labels: [FocusLabel] = [
      .init(id: "study", name: "Study", backgroundColor: "#22c55e"),
      .init(id: "work", name: "Work", backgroundColor: "#fde047"),
      .init(id: "sport", name: "Sport", backgroundColor: "#2563eb"),
      .init(id: "reading", name: "Reading", backgroundColor: "#c4b5fd"),
      .init(id: "writing", name: "Writing", backgroundColor: "#fda4af"),
      .init(id: "meditation", name: "Meditation", backgroundColor: "#fdba74"),
      .init(id: "workout", name: "Workout", backgroundColor: "#d8b4fe"),
    ]
    
    // gen random events
    for _ in 0..<count {
      let randomDate = Date(timeIntervalSinceNow: Double.random(in: range.lowerBound.timeIntervalSinceNow..<range.upperBound.timeIntervalSinceNow))
      let minutes = Int.random(in: 20..<50)
      let sessionsCount = Int.random(in: 4..<8)
      let completedSecondsCount = sessionsCount * minutes * 60

      let event = Focus(
        minutes: minutes,
        sessionsCount: sessionsCount,
        completedSecondsCount: completedSecondsCount,
        label: labels.randomElement(),
        startedAt: randomDate,
        endedAt: randomDate.addingTimeInterval(TimeInterval(completedSecondsCount)),
        createdAt: randomDate
      )
      
      events.append(event)
    }
    
    return events
  }
}
